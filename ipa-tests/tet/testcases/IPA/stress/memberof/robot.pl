#!/usr/bin/perl

use strict;
use warnings;

use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

############### read command line input ##########
$|=1;
our $x=@ARGV;
our $configfile; 
our $logdir;

if ($x==1){
	$configfile = $ARGV[0]; 
	$logdir = "/tmp/"; 
	print "\nUsage: robot.pl <config file> <log dir>\n";
	print "\nUsing config file [$configfile]";
	print "\nUsing default log directory [$logdir]"; 
}
elsif ($x==2){
	$configfile = $ARGV[0];
	$logdir = $ARGV[1];
	print "\nUsing config file [$configfile]";  
	print "\nUsing log directory [$logdir]";
}else{
	print "\nUsage: robot.pl <config file> <log dir>\n";
	exit (0);
}

####################################################
#   global variable and pre-defined initial data   #
####################################################
	# LDAP variable, the following should come from test.conf file
our $ipahost;			# which ipa host machine to test, sample data: ipa52.test.com
our $ldap;				# variable used to hold LDAP connection with ipa server
our $admin;				# the object to hold ldap connection, and authenticated as administrator of LDAP server
our $dn;				# the DN of ipa server, sample data: $dn="cn=directory manager"
our $passwd;			# password for the given admin, sample data : $passwd="redhat123"
our $base;				# search base, sample data : $base = "cn=accounts,dc=test,dc=com"
our $scope="sub";		# throught out this test, use "sub"
our $usr_suffix;		# sample data : $usr_suffix="cn=users,cn=accounts,dc=test,dc=com"
our $grp_suffix;		# sample data : $grp_suffix="cn=groups,cn=accounts,dc=test,dc=com"
    
    # test character 
our @base_operation=('add','moidfy','del');	# basic operation that could perform against ldap entries
our @base_type=('group','user');			# basic data type in ldap server
our @operation = ();						# operation pool, it contains all basic operation in base_operation, 
our @type = ();								# data entry type pool, it contains all basic type in base_type

	# test data size variables
our %g;						# hash data to store all group type test data
our %u; 					# hash data to store all user type test data
our $gsize_max = 100; 		# how many groups in the same level
our $glevel_max = 4; 		# how many levels in total

							# weight of each operation means how often you want to run this type of operation
our $add_weight = 15;		# add+mod+del = 100%
our $mod_weight = 70;
our $del_weight = 15;		

our $grp_weight = 50;		# weight of each operation means how often you want to run test targing this type of entry
our $usr_weight = 50;		# grp + usr = 100%
 
our $baseuid_index;			# starting number for uid 
our $basegid_index;  		# starting number for gid
our $maxloop;				# maximum loop for each test cycle
our $gsize;					# number of group type entry in each layer
our $glevel;				# how many group layers
our $usize;					# how many users in each layer
our $ulevel;				# how many user layers, it usually same as groups layers

our $loopcounter = 0;		# record current loop number
our $addcounter = 0;		# counter for add operation
our $modcounter = 0;		# counter for modifiy operation
our $delcounter = 0;		# counter for delete operation
our $grpcounter = 0;		# counter for operations to group entry
our $usrcounter = 0;		# counter for operations to user entry 
our $testcyclecounter = 0;	# counter for each test cycle 
our $std_indent="   ";


# init global data 
print "\nrobot starts...\n";
print ("[init_global] starts...");
init_global();
print ("\n[init_global] finished");

########################## begin of test ########## 

for ( $glevel=2; $glevel <= $glevel_max; $glevel ++){
	for ( $gsize = 1; $gsize <= $gsize_max; $gsize++ ){   
		$testcyclecounter ++;
		my $logfile = $logdir."/robot.".$testcyclecounter.".log";
		if (!open (LOG , ">$logfile")){
			print "\nCan not open log file [$logfile] to write, exit program";
			exit (0);
		}
		logger ("cycle [$testcyclecounter] starts..."); 
		print "\ncycle [$testcyclecounter] starts...\t"; 
		run_test($testcyclecounter);
		logger ("cycle [$testcyclecounter] finished");
		close LOG;
		print "\tfinished";
	}
} 

print "\nrobot finished\n";
######################## end of test ###############

################################
#*     sub routines           *#
################################

sub run_test{ 
	my $cycle = shift; 
	my $indent = "[$cycle]".$std_indent; 
	print "glevel=[$glevel] gsize=[$gsize]";
	logger ($indent."current : glevel    = [$glevel]     gsize = [$gsize]");
	logger ($indent."max     : glevel_max= [$glevel_max] gsize_max = [$gsize_max]");
	
	logger ($indent."[innit_local] starts...");
	init_local($indent.$std_indent);
	logger ($indent."[init_local] finished");
	print " usize=[$usize], total test: [$maxloop]\t[";
	my $loopcounter = 0;
	my $finished = 0;
	while ($loopcounter < $maxloop){
		# randomly choose an operation from operation pool
		# randomly choose an object type (user/group) from object type pool
		my $current_operation = $operation[(int(rand($#operation+1)))];
		my $current_type = $type[(int(rand($#type+1)))];
		my $percent = int (($loopcounter/$maxloop)*10);
		if ($percent > $finished){
			print "#";
			$finished = $percent;
		}
		if ($loopcounter == ($maxloop-1)){
			print "#] ";
		}
		logger($indent."Test($loopcounter/$maxloop) starts...");
		run_single_test($current_operation, $current_type, $indent);
		logger($indent."Test($loopcounter/$maxloop) finished");
		$loopcounter++;
	}# giant while loop
	
	logger ($indent, "data looks like below after test");
	printmembers($indent, \%g);
	printmembers($indent, \%u); 
	cleanup($indent);
	system_cleanup($indent); 
	logger ($indent."--------------- Summary Report -----------------------------");
	logger ($indent."Total operations [$maxloop], add [$addcounter], mod [$modcounter], del [$delcounter]");
	logger ($indent."Total operations [$maxloop], grp [$grpcounter], usr [$usrcounter]");  
	logger ($indent."Total group layers: [$glevel] group size in each layer: [$gsize]");
	logger ($indent."Total user  layers: [$ulevel],user  size in each layer: [$usize]");
	logger ($indent."Total running loop: $maxloop"); 
	logger ($indent."-------------------------------------------------------------"); 

}#run_test

sub  run_single_test{
	my ($operation, $type, $indent) = @_;
	$indent .= $std_indent;
	logger ($indent."operation: [$operation] type [$type]");
	# group operation: add, mod, del
	if($operation eq 'add' && $type eq 'group'){
	# add a new group into ldap server
		logger ($indent."[addgroup] starts...");
		addgroup($indent.$std_indent);
		logger ($indent."[addgroup] finished");
		$addcounter ++;
		$grpcounter ++;
	}
	if($operation eq 'modify' && $type eq 'group'){
		# modify an existing group
		logger ($indent."[mod_memberof] starts...");
		mod_memberof($indent.$std_indent);
		logger ($indent."[mod_memberof] finished");
		$modcounter ++;
		$grpcounter ++;
	}
	if($operation eq 'del' && $type eq 'group'){
		# delete an existing group
		logger ($indent."[delgroup] starts...");
		delgroup($indent.$std_indent);
		logger ($indent."[delgroup] finished");
		$delcounter ++;
		$grpcounter ++;
	}
	#user operation: add, mod, del
	if($operation eq 'add' && $type eq 'user'){
		# add a new user into ldap server
		logger ($indent."[adduser] starts...");
		adduser($indent.$std_indent);
		logger ($indent."[adduser] finished");
		$addcounter ++;
		$usrcounter ++;
	}
	if($operation eq 'modify' && $type eq 'user'){
		# modify an existing user
		logger ($indent."[modusr] starts...");
		#getrandom_existinguser();
		logger ($indent."[modusr] finished");
		$modcounter ++;
		$usrcounter ++;
	}
	if($operation eq 'del' && $type eq 'user'){
		# delete an existing user
		logger($indent."[delusr] starts...");
		deluser($indent.$std_indent);
		logger($indent."[delusr] finished");
		$delcounter ++;
		$usrcounter ++;
	}
}#run_single_test

sub init_global {  
	 
	# load config file to re-define global variables 
	my $config = readconfig ($configfile);
	$ipahost = $config->{"ipahost"};
	$dn = $config->{"admindn"};
	$passwd = $config->{"adminpasswd"};
	$base = $config->{"base"};
	$usr_suffix = $config->{"usr_suffix"};
	$grp_suffix = $config->{"grp_suffix"};
	$gsize_max = $config->{"gsize"};
	$glevel_max = $config->{"glevel"};
	$add_weight = $config->{"add_weight"};
	$mod_weight = $config->{"mod_weight"};
	$del_weight = $config->{"del_weight"};
	$grp_weight = $config->{"grp_weight"};
	$usr_weight = $config->{"usr_weight"}; 
	
	$ldap = Net::LDAP->new($ipahost) or die "$@";
	$admin = $ldap->bind( $dn, password => $passwd, version => 3 );  
	print "LDAP connection created";
	print "bind as [$dn] success"; 
	
	# construct the operations and type queue based on the weight 
	for (my $w = 0; $w < $add_weight ; $w++){ push @operation, "add";}#for loop 
	for (my $w = 0; $w < $mod_weight ; $w++){ push @operation, "modify";}#for loop
	for (my $w = 0; $w < $del_weight ; $w++){ push @operation, "del";}#for loop
	for (my $t = 0; $t < $grp_weight ; $t++){ push @type, "group";}	#for loop
	for (my $t = 0; $t < $usr_weight ; $t++){ push @type, "user";}	#for loop
	 
}# init

sub init_local{
	my ($indent) = shift;  
	undef %g  ;
	undef %u  ; 
	$usize = $gsize * 100; 
	$ulevel = $glevel; 
	$loopcounter = 0;
	$addcounter = 0;
	$modcounter = 0;
	$delcounter = 0;
	$grpcounter = 0;
	$usrcounter = 0; 
	$baseuid_index = $usize * $ulevel * 200;
	$basegid_index = $gsize * $glevel * 100;  
	$maxloop = $usize * $ulevel * 10; 
	logger ($indent."all previous testing data has been cleared");
	
	# init group data 
	for (my $l=0; $l< $glevel; $l++){
		my @newgroups;
		for(my $i=0; $i<$gsize; $i++){
			my $id = "g-".$l."-".$i; 
			push @newgroups, $id;
		}# inner for
		$g{"g-$l-new"} = \@newgroups;
		my @existing=();
		$g{"g-$l-existing"}=\@existing;
	}# outter for
	logger ($indent."re-create the %g done");
	
	# init user data
	for (my $l=1; $l<= $ulevel; $l++){
		my @newusers;
		for(my $i=0; $i<$usize; $i++){
			my $id = "u-".$l."-".$i;
			push @newusers, $id;
		}# inner for
		$u{"u-$l-new"}=\@newusers;
		my @existing=();
		$u{"u-$l-existing"}=\@existing;
	}# outter for
	logger ($indent."re-create the %u done");  
	logger ($indent."The init group pool data as below:");
	printmembers($indent, \%g);
	logger ($indent."The init usr pool data as below:");
	printmembers($indent, \%u);
}#init_local

sub cleanup {
	# cleanup will scan all existing group and user array and delete them from ldap server
	my $indent = shift; 
	my $logmsg ="[cleanup] test data clean up starts ...";
	for (my $l=0; $l< $glevel; $l++){
		my $existing_ref = $g{"g-$l-existing"};
		my @existing_grp = @$existing_ref;
		foreach (sort @existing_grp){
			my $gid = "cn=".$_.",$grp_suffix";
			ldap_delete($gid);
		}# inner foreach to delete existing group
	}# outter for
	 
	for (my $l=1; $l <= $ulevel; $l++){ 
		my $existing_ref = $u{"u-$l-existing"};
		my @existing_usr = @$existing_ref; 
		foreach (sort @existing_usr){
			my $uid = "uid=".$_.",$usr_suffix";
			ldap_delete($uid);
		}
	}
	$logmsg .=" done";
	logger ($indent.$logmsg);
}# cleanup

sub system_cleanup {
	my $indent = shift; 
	logger($indent."[system_cleanup] starts...");
	# even we called cleanup(), I still see there are some left over , that's why I need this system wide clean up
	# step 1, find all user that match this filter: "uid=u-*"
	my @leftover;
	my $logmsg = "[system_cleanup] searching leftover users ..."; 
	my $mesg = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => "uid=u-*",
	                       attrs  => ['uid']
                      );
	 if ( $mesg->code ){
	    my $errstr = $mesg->code;
	    $logmsg .= "search error, code = $errstr :";
	    $errstr = ldap_error_text($errstr);
	    $logmsg .= "err msg from LDAP: $errstr\n"; 
	 }else{ 
	 	my $max = $mesg->count; 
		$logmsg .=  " ... found total [$max] user: "; 
		for( my $index = 0 ; $index < $max ; $index++) {
			my $entry = $mesg->entry($index);
			my $id = $entry->get_value('uid');
			$logmsg .= " [$id]";
			my $uid = "uid=".$id.",$usr_suffix";
			push @leftover, $uid; 
		} 
	} 
	logger ($indent.$logmsg);
	
	$logmsg = "[system_cleanup] searching leftover groups "; 
	$mesg = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => "cn=g-*",
	                       attrs  => ['cn']
                      );
	 if ( $mesg->code ){
	    my $errstr = $mesg->code;
	    $logmsg .="search error, code:  $errstr";
	    $errstr = ldap_error_text($errstr);
	    $logmsg .= " err msg from LDAP: $errstr\n";
	 }else{ 
	 	my $max = $mesg->count; 
		$logmsg .= "... found total [$max] group records, ";
		for( my $index = 0 ; $index < $max ; $index++) {
			my $entry = $mesg->entry($index);
			my $id = $entry->get_value("cn"); 
			$logmsg .= " [$id]";
			my $gid = "cn=".$id.",$grp_suffix";
			push @leftover, $gid;
		}# all entries
	} 
	logger ($indent.$logmsg);
	if ($#leftover == -1){
		logger ($indent."[system_cleanup] system is clean");
	}else{
		logger($indent."[system_cleanup] start deleting..."); 
		foreach my $id (@leftover){
			$logmsg ="[system_cleanup] delete [$id]";
			if(ldap_delete($id)){
				$logmsg .= "... success";
			}else{
				$logmsg .= "... failed";
			}
			logger($indent.$logmsg);
		}#delete all in leftover queue
	}
	logger($indent."[system_cleanup] finished");
}# system_cleanup

########################################
# user and group operation functions   #
#######################################

sub adduser{
	my $indent = shift;  
	# adduser means move user in a "u-somelevel-new" array to "u-samelevel-existing" array
	my $level_index = int(rand($ulevel))+1; #user level starts from 1 to 10
	my $current_level_newuser_index = "u-".$level_index."-new";
	my $current_level_existinguser_index= "u-".$level_index."-existing";
	
	my $newusers_ref = $u{$current_level_newuser_index};
	my @newusers = @$newusers_ref;
	
	if ($#newusers==-1){
		logger ($indent."[adduser] newuser pool is empty, no more user can be added, doing nothing");
		return;
	} # if the new user array has size 0, then do nothing
	
	my $existingusers_ref = $u{$current_level_existinguser_index};
	my @existingusers = @$existingusers_ref;
	
	# move user out of "new user" array and put it into "existing user" array"
	my $index = int(rand($#newusers+1));
	my $random_user = $newusers[$index];
	my $uid = "uid=".$random_user.",$usr_suffix";
	if (ldap_adduser($uid,$indent.$std_indent)){
		logger($indent."add user [$uid] success");
		# if add this user into ldap success
		my @removed = splice (@newusers, $index,1);
		push @existingusers, @removed;
		#logger($indent."move ($current_level_newuser_index)[".$removed[0]."] to existing user pool");
		# put the new arrays back to hash
		$u{$current_level_newuser_index} = \@newusers;
		$u{$current_level_existinguser_index} = \@existingusers;
	}else{
		logger($indent."add user [$uid] failed");
	}	
}#adduser

sub mod_memberof{
	my $indent = shift;
	my @target_pool = ();
	my $targetid,
	my $gid, 
	
	# choose one user or group from next level, unless this is the deepest level of group
	logger($indent."1. select a group");
	my $level = int(rand($glevel)); 
	my $current_level_grp = "g-".$level."-existing";
	my $grps_ref = $g{$current_level_grp};
	my @grps = @$grps_ref;
	if ($#grps==-1){ 
		 # if the group array has size 0, then do nothing
		logger($indent."  result: group pool [$current_level_grp] is empty, doing nothing"); 
		return;
	}else{
		my $grp_index = int(rand($#grps+1));
		my $random_grp = $grps[$grp_index];
		$gid = "cn=".$random_grp.",$grp_suffix"; 
		logger($indent."   result: pick group [$gid]");
	}
 
 	logger($indent."2. select another user or group");
 	# put existing users into target pool
	my $next_level_usr = "u-".($level+1)."-existing"; #user is always one level lower than group
	my $usrs_ref = $u{$next_level_usr};
	my @usrs = @$usrs_ref;
	if ($#usrs >= 0){ 
		push @target_pool, @usrs;
	}
	# put existing groups into target pool
	if ($level < ($glevel-1)){
		my $next_level_grp = "g-".($level+1)."-existing";
		my $next_grp_ref = $g{$next_level_grp};
		my @next_grps = @$next_grp_ref;
		if ($#next_grps >= 0){ 
			push @target_pool, @next_grps;
		}
	}
	
	if ($#target_pool == -1){
		# randomly choose one group and one target from target pool
		logger($indent."   result: there is no user nor groups at next level, doing nothing");
		return;
	}else{ 
		my $all = "@target_pool";
		logger($indent."   result: pick from this pool: $all"); 
	 	my $target_index = int(rand($#target_pool+1)); 
		my $random_target = $target_pool[$target_index];
		if ($random_target =~ /^u/){
			$targetid = "uid=".$random_target.",$usr_suffix";
		}elsif ($random_target =~ /^g/){
			$targetid = "cn=".$random_target.",$grp_suffix";
		}else{
			logger($indent."unexpected error");
		}
		logger($indent."   result: pick [$random_target]");
	}

	# 'add' 'del' 'replace' should be in another random function as well
	my @memberof_ops = ('add','replace','del');
	my $op_index = int(rand($#memberof_ops+1));
	my $memberof_op = $memberof_ops[$op_index];
	logger($indent."[memberof $memberof_op] starts");
	if (ldap_mod_memberof($gid,$targetid, $memberof_op, $indent.$std_indent )){
		logger($indent."[memberof $memberof_op] target=[$targetid]  group=[$gid] success");
	}else{
		logger($indent."[memberof $memberof_op] target=[$targetid]  group=[$gid] failed");
	}	
	logger($indent."[memberof $memberof_op] finished");
}#moduser_memberof

sub deluser {
	my $indent = shift;
	
	# deluser means move user in a "u-somelevel-existing" array to "u-samelevel-new" array 
	my $level_index = int(rand($ulevel))+1;
	my $current_level_newuser_index = "u-".$level_index."-new";
	my $current_level_existinguser_index= "u-".$level_index."-existing";
	
	my $newusers_ref = $u{$current_level_newuser_index};
	my @newusers = @$newusers_ref;
	
	my $existingusers_ref = $u{$current_level_existinguser_index};
	my @existingusers = @$existingusers_ref;
	
	if ($#existingusers==-1){return;} # if the existing user array has size 0, then do nothing
	
	# move user out of "new user" array and put it into "existing user" array"
	my $index = int(rand($#existingusers+1));
	my $random_user = $existingusers[$index];
	my $uid = "uid=".$random_user.",$usr_suffix";
	if(ldap_delete($uid,$indent.$std_indent)){
		logger ($indent."delete user [$uid] success");
		my @removed = splice (@existingusers, $index,1);
		push @newusers, @removed; 
		logger($indent."move ($current_level_existinguser_index)[".$removed[0]."] to new user pool for reuse");
		# put the new arrays back to hash
		$u{$current_level_newuser_index} = \@newusers;
		$u{$current_level_existinguser_index} = \@existingusers;
	}else{
		logger ($indent."delete user [$uid] failed");
	}

}# group: move existing -> new

sub addgroup{
	my $indent = shift;
	
	# addgroup means move group in a "g-somelevel-new" array to "g-samelevel-existing" array
	my $level_index = int(rand($glevel)); 
	my $current_level_newgroup_index = "g-".$level_index."-new";
	my $current_level_existinggroup_index= "g-".$level_index."-existing";
	
	my $newgroups_ref = $g{$current_level_newgroup_index};
	my @newgroups = @$newgroups_ref;
	
	if ($#newgroups==-1){return;} # if the new group array has size 0, then do nothing
	
	my $existinggroups_ref = $g{$current_level_existinggroup_index};
	my @existinggroups = @$existinggroups_ref;
	
	# move user out of "new group" array and put it into "existing group" array"
	my $index = int(rand($#newgroups+1));
	my $random_group = $newgroups[$index];
	my $gid = "cn=".$random_group.",$grp_suffix";
	if(ldap_addgroup($gid,$indent.$std_indent)){
		logger ($indent."add group [$gid] success");
		my @removed = splice (@newgroups, $index,1);
		push @existinggroups, @removed; 
		# put the new arrays back to hash
		$g{$current_level_newgroup_index} = \@newgroups;
		$g{$current_level_existinggroup_index} = \@existinggroups;
		logger($indent."move ($current_level_newgroup_index)[".$removed[0]."] to existing group pool for reuse");
	}else{
		logger($indent."add group [$gid] failed");
	}
}

sub delgroup {
	my $indent = shift;
	
	## delgroup means move group in a "g-somelevel-existing" array to "g-samelevel-new" array
	my $level_index = int(rand($glevel)); 
	my $current_level_newgroup_index = "g-".$level_index."-new";
	my $current_level_existinggroup_index= "g-".$level_index."-existing";
	
	my $newgroups_ref = $g{$current_level_newgroup_index};
	my @newgroups = @$newgroups_ref;
	
	my $existinggroups_ref = $g{$current_level_existinggroup_index};
	my @existinggroups = @$existinggroups_ref;
	
	if ($#existinggroups==-1){return;} # if the existing group array has size 0, then do nothing
	
	# move user out of "new user" array and put it into "existing user" array"
	my $index = int(rand($#existinggroups+1));
	my $random_group = $existinggroups[$index];
	my $gid = "cn=".$random_group.",$grp_suffix";
	if (ldap_delete($gid,$indent.$std_indent)){
		logger ($indent."delete group [$gid] success");
		my @removed = splice (@existinggroups, $index,1);
		push @newgroups, @removed; 
		logger($indent."move ($current_level_existinggroup_index)[".$removed[0]."] to new group pool for reuse");
		# put the new arrays back to hash
		$g{$current_level_newgroup_index} = \@newgroups;
		$g{$current_level_existinggroup_index} = \@existinggroups;
	}else{
		logger ($indent."delete [$gid] failed");
	}
}#delgroup

sub printmembers {
    my ($indent,$hash) = @_;
    my %h=%$hash;
    foreach (sort keys %h){
    	my $m = $h{$_};
    	my @members = @$m;
        my $m_str = "[$_]\t";
        foreach (sort @members) {
  			$m_str .= "$_ ";
		}
	logger ($indent.$m_str);
    }
}#printmembers

#####################################
#  LDAP functions                   #
#####################################
sub ldap_search_entry{
	my ($logheader, $id) = @_;
	my @t = split(/,/,$id);
	my $filter = $t[0];
	ldap_search_and_print($logheader,$filter);
}# ldap_search_entry

sub ldap_search_and_print{
	my ($logheader, $filter,$attrs) = @_;  
	$logheader .= "[search]";
	my $mesg = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => $filter,
	                       attrs  => $attrs
                      );
	 if ( $mesg->code )
	 {
	    my $errstr = $mesg->code;
	    logger($logheader."search error, code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    logger($logheader."error message: $errstr");
	 }else{ 
		my $max = $mesg->count; 
		logger ($logheader."search [$filter]... found total [$max] records");
		
		for( my $index = 0 ; $index < $max ; $index++) {
			my $entry = $mesg->entry($index);
			my @attrs = $entry->attributes;
			logger("\t\t\t== entry #[$index]==");
			foreach my $attr (@attrs){
				my $attrvalue="";
	  			foreach ($entry->get_value( $attr )) {
	      				$attrvalue .= $_.", ";
	    			}# all value of each attr

				my $f_attr = sprintf("%15s",$attr);
				logger("\t\t\t[$f_attr]\t".$attrvalue);
			}# all attrs
		}# all entries  
	 } 
}#ldap_search_and_print

sub ldap_printall{
	my ($mesg, $indent) = @_;
	my $max = $mesg->count; 
	my $logmsg = "... found total [$max] records";
	for( my $index = 0 ; $index < $max ; $index++) {
		my $entry = $mesg->entry($index);
		my @attrs = $entry->attributes;
		$logmsg .= "\n\tentry# [$index]";
		foreach my $attr (@attrs){
			my $f_attr = sprintf("%12s",$attr);
			$logmsg .= "\n\t[$f_attr]\t";
  			foreach ($entry->get_value( $attr )) {
      			$logmsg .= $_.", ";
    		}# all value of each attr
		}# all attrs
	}# all entries
	logger ($logmsg);
}


sub ldap_mod_memberof{
	my ($gid, $id, $operation,$indent) = @_;
	my $return=0;
	my $logheader = $indent."[ldap_mod_memberof] ";
	logger($logheader." input: op=[$operation]");
	logger($logheader." input: usr=[$id]");
	logger($logheader." input: grp=[$gid]");
	
	#operation = add, delete, replace
	if ($operation eq 'add'){ 
		$logheader.="[add] ";
		logger($logheader."before add");
		ldap_search_entry($logheader, $gid);
		
		my @t = split(/,/,$gid);
		my $filter = $t[0];  
		my %allmembers = ldap_attr_readvalues($filter, 'member', $indent.$std_indent);
		if (exists $allmembers{$id} ){ 
        		logger($logheader."do nothing, since already a member");
       		 	$return=1;
		}else{
			logger ($logheader, "performing add");
			my @addArrayList = [ 'member', "$id"];
			my $result = $ldap->modify ( $gid,changes => [
						add => @addArrayList
						]
					);# ldap->modify function call
			@t = split(/,/,$id);
			$filter = $t[0];
 
			if ( $result->code )
			{
				logger($logheader."failed");
				my $errstr = $result->code;
				logger($logheader."Error code:  $errstr");
				$errstr = ldap_error_text($errstr);
				logger($logheader."$errstr");
			}else{
				logger($logheader."success");
				logger($logheader."after add");
				ldap_search_entry($logheader, $gid);
				$return=1;
			}# verify the ldap call result
		}
	}# add 
	
	if ($operation eq 'del'){
		$logheader .="[delete]";
		logger ($logheader, "expected result: just delete one member from group's member list");
		logger ($logheader, "before delete");
		ldap_search_entry($logheader, $gid);
		
		logger($logheader."1. search for members");
		my @t = split(/,/, $gid);
		my $filter = $t[0]; 
		my %allmembers = ldap_attr_readvalues($filter, 'member',$indent.$std_indent);
		my @all = keys %allmembers; 
		if ($#all == -1 ){
			logger($logheader."there is no member at all, do nothing");
			return 1;
		}  
		logger ($logheader."    found following member for [$gid]:");
		foreach (keys %allmembers){logger ($logheader. "\t$_");};  
		
		logger($logheader."2. delete one existing member from member list");
		my $attr_to_be_del = $all[(int(rand($#all+1)))]; 
		logger ($logheader."   pick this one: [$attr_to_be_del]");
		my @deleteArrayList = ['member'=>'$attr_to_be_del'];  
		
		logger ($logheader."3. performing delete");
		my $result_del = $ldap->modify ( $gid,
						changes => [
							delete => ['member'=>"$attr_to_be_del"]
						]
					);# ldap->modify function call
		if ( $result_del->code ){ 
			logger($logheader."failed");
			my $errstr = $result_del->code;
	    		logger($logheader."Error code:  $errstr");
	    		$errstr = ldap_error_text($errstr);
	    		logger($logheader."Error message: $errstr");
	 	}else{
				logger($logheader."success, verify data as below");
				ldap_search_entry($logheader, $gid);
				$return = 1; 
	 	}#if del one attribute value success
	}# del
	
	if ($operation eq 'replace') {
		$logheader .= "[replace]";
		logger($logheader,"expected result: [$id] will be the only member of [$gid]");
		logger($logheader."before replace");
		ldap_search_entry($logheader, $gid);		
		my @ReplaceArrayList = [ 'member', "$id"]; 
		my $result = $ldap->modify ( $gid,changes => [
                                  			  replace => @ReplaceArrayList
                                			]
                              		);# ldap->modify function call
		if ( $result->code )
		{
			logger($logheader."failed");
			my $errstr = $result->code;
    		logger($logheader."Error code:  $errstr");
    		$errstr = ldap_error_text($errstr);
    		logger($logheader."Error message:$errstr");
	 	}else{
	 		logger($logheader."success");
			logger($logheader."after replace");
			ldap_search_entry($logheader,$gid);
	 		$return=1;
	 	}# verify the ldap call result
	}# replace 
	
	 return $return;
}#ldap_mod_memberof

sub ldap_adduser{ 
	my ($uid, $indent)= @_; # logger("add ($uid)"; return 1;
	my $return=0;
	my $usr_attrs = ldap_make_usrattrs();
	my $result = $ldap->add($uid, attr=> $usr_attrs );
	if ( $result->code )
	{
		my $errstr = $result->code;
	    logger($indent."[ldap_adduser] Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    logger($indent."[ldap_adduser] $errstr");
	 }else{ 
	 	$return=1;
	 } 
	 return $return;
}#adduser 

sub ldap_addgroup{ 
	my ($gid,$indent) = @_ ; # logger("add ($gid)"; return 1;
	my $return=0;
	my $grp_attrs = ldap_make_grpattrs();
	my $result = $ldap->add($gid, attr=> $grp_attrs); 
	if ( $result->code )
	 { 
	    my $errstr = $result->code;
	    logger($indent."[ldap_addgroup] Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger($indent."[ldap_addgroup] $errstr");
	}else{ 
	 	$return=1;
	}  
	return $return;
}# ldap_addgroup

sub ldap_delete{
	# data sample
	#    $id = "cn=testgrp100,cn=groups,cn=accounts,dc=test,dc=com"  # for user 
	# or $id = "uid=sub100,cn=users, cn=accounts,dc=test,dc=com"     # for group
	my ($id,$indent) = @_; # logger("delete ($id) "; return 1;
	my $return=0;
	my $result = $ldap->delete($id);
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger($indent."[ldap_delete] delete ($id) has error, Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger($indent."[ldap_delete] $errstr");
	}else{ 
	 	$return=1;
	} 
	return $return;
}

sub ldap_attr_addvalue {
	my ($id, $attr,$attr_value,$indent)=@_;
	my $return = 0;
	logger($indent."[ldap_attr_addvalue] input values:\n[id]=[$id]\n[attr]=[$attr]\n[value]=[$attr_value]"); 
	my @t = split(/,/,$id);
	my $filter = $t[0];
	#ldap_search_and_print($filter);
	@t = split(/,/,$attr_value);
	$filter = $t[0];
	#ldap_search_and_print($filter);
	my $result = $ldap->modify ( $id,
								changes => [
                                  			add => [ '$attr'=> "$attr_value"]
                                		   ]
                              	);# ldap->modify function call
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger($indent."[ldap_attr_addvalue] add attr error: Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger($indent."[ldap_attr_addvalue] $errstr");
	}else{
		$return = 1; 
	}  					
	return $return;
}# add one value into one given attribute

sub ldap_attr_delvalue {
	my ($id, $attr,$attr_value,$indent)=@_;
	logger($indent."input values:\n[id]=[$id]\n[attr]=[$attr]\n[value]=[$attr_value]"); 
	my $result = $ldap->modify ( $id,
								changes => [
                                  			delete => [ '$attr'=> "$attr_value"]
                                		   ]
                              	);# ldap->modify function call
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger($indent."delete attr error: Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger($indent."$errstr");
	}else{ 
		return;
	}  					
}# del one value into one given attribute

sub ldap_attr_replacevalue {
	my ($id, $attr,$attr_value,$indent)=@_;
	logger($indent."input values:\n[id]=[$id]\n[attr]=[$attr]\n[value]=[$attr_value]"); 
	my $result = $ldap->modify ( $id,
								changes => [
                                  			replace => [ '$attr'=> "$attr_value"]
                                		   ]
                              	);# ldap->modify function call
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger($indent."replace attr error: Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger($indent."$errstr");
	}else{ 
		return;
	}  					
}# replace one value into one given attribute

sub ldap_attr_readvalues {
	my ($filter, $attr_name,$indent) = @_;
	my %values=(); 
	my $result = $ldap->search (base => $base,
								scope => $scope,
								filter => $filter,
								attrs => $attr_name);
	if ($result->code){
		my $errstr = $result->code;
		logger($indent."[attr read value] Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    logger($indent."[attr read value] $errstr");
	    
	 }else{   
		while (my $entry = $result->shift_entry){   
    		foreach my $value ($entry->get_value($attr_name)) { 
    			if(!(exists $values{$value})){
    				$values{$value}=1;
    			} 
    		} # value loop
  		} # while loop  
	}#else if we find result
	return %values;
}# ldap_attr_readvalues

sub ldap_make_usrattrs{ 
	my $uid_index = $baseuid_index++;
	my $gid_index = $basegid_index++;
	my $ipausrattrs = ['cn' => 'user',
                          'sn' => $uid_index,  
                          'givenName' => 'IPA', 
                          'homeDirectory' => '/home/user_'.$uid_index,
                          'uidNumber' => $uid_index,
                          'gidNumber' => $gid_index,
                          'objectclass' => [ 'person','inetOrgPerson','inetUser','posixAccount','krbPrincipalAux','radiusprofile']];   
	return $ipausrattrs;
}# construct user entry attrs

sub ldap_make_grpattrs {
	my $ipagrpattrs = [ 'description' => "ipa group",
                  		'objectclass' => ['groupofnames','inetUser','posixGroup']
                	  ];  
	return $ipagrpattrs;
}# construct group entry attrs

############################
#	general utilities      #
############################

sub logger { 
	my ($msg) = shift;  
	print LOG "\n".gettimestamp()." ".$msg; 
}#logger

sub gettimestamp {
	# return current string type timestamp 
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time) ;
	my $timestamp = ($year+1900)."/".($mon+1)."/".$mday.":".$hour.":".$min.":".$sec;
	return "[".$timestamp."] ";
}#gettimestamp	

sub readconfig {
	my $configfile=shift; 
	my %c; 
	if (open(CONFIG,$configfile)){ 
		print "\nloading configruation fle [$configfile] ...";
		print "\n============================================";
		my @con= <CONFIG>;
		foreach my $line (@con){ 
			chomp($line);
			# the basic format of config file would be: position = name ; sample data 0=version
			next if $line=~ m/^#/;	# ignore commends line ==> starts with "#" char
			next if $line=~ m/^\s*$/;	# ignore empty lines
			next if $line=~ m/^\[/;	# ignore lines such as [system]
			my @pair = split(/:/,$line);
			# FIXME shall i remove 
			$pair[0] =~s/\s+$//g; $pair[0] =~s/^\s+//g;
			$pair[1] =~s/\s+$//g; $pair[1] =~s/^\s+//g;
			$c{$pair[0]} = $pair[1]; 
			my $k = sprintf ("%12s", $pair[0]); 
			print "\n".$k." => ".$pair[1]; 
		}
		print "\n============================================\n";
		close CONFIG;
	}else{
		logger("\nError: configuration file [$configfile] can not open,exit program\n"); 
		exit;
	}
	return \%c; 
}#readconfig
