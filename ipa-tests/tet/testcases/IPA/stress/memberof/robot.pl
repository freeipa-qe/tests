#!/usr/bin/perl

use strict;
use warnings;

use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

####################################################
#   global variable and pre-defined initial data   #
####################################################

our $configfile = "test.conf"; 
our $logfile = "/tmp/robot.log";

	# LDAP variable
our $ipahost = "ipa52.test.com";
our $ldap;
our $admin;
our $dn="cn=directory manager";
our $passwd="redhat123";
our $base="cn=accounts,dc=test,dc=com";
our $scope="sub";
our $usr_suffix="cn=users,cn=accounts,dc=test,dc=com";
our $grp_suffix="cn=groups,cn=accounts,dc=test,dc=com";
    
    # test character
our @base_ops = ('add','moidfy','del');
our @base_tps = ('group', 'user');
our @operation=('add','moidfy','del');	# init will over-write this value based on the weight of each operation
our @type=('group','user');				# init will over-write this value based on the weight of each type

	# test data size variables
our %g;									# hash data to store all group type test data
our %u; 								# hash data to store all user type test data
our $gsize = 100; 						# how many groups in the same level
our $glevel = 4; 						# how many levels in total
							# weight of each operation means how often you want to run this type of operation
our $add_weight = 15;		# add+mod+del = 100%
our $mod_weight = 70;
our $del_weight = 15;		# weight of each operation means how often you want to run test targing this type of entry
our $grp_weight = 50;		# grp + usr = 100%
our $usr_weight = 50;

	# the following are calculated test data
our $usize = $gsize * 10; 
our $ulevel = $glevel;
our $baseuid_index = $usize * $ulevel * 200;
our $basegid_index = $gsize * $glevel * 100;  
our $maxloop = $usize * $ulevel * 10;
our $loopindex = 0;
 
# init data 
init();
printmembers(\%g);
printmembers(\%u);

# define all counters here
our $addcounter = 0;
our $modcounter = 0;
our $delcounter = 0;
our $grpcounter = 0;
our $usrcounter = 0;
our $add_grp=0;
our $add_usr=0;
our $mod_grp=0;
our $mod_usr=0;
our $del_grp=0;
our $del_usr=0;

print "\n".gettimestamp()."ROBOT starts...";
while ($loopindex < $maxloop){
	$loopindex++;
	my $current_operation = $operation[(int(rand($#operation+1)))];
	my $current_type = $type[(int(rand($#type+1)))];
	my $percent = int (($loopindex/$maxloop)*100);
	logger ("debug", "[$percent % done] LOOP (".$loopindex." of $maxloop ) starts... operation: ".$current_operation." for ".$current_type);
	
	# perform test right here:
		# group operation: add, mod, del
	if($current_operation eq 'add' && $current_type eq 'group'){
		# add a new group into ldap server
		addgroup();
		$add_grp++;
	}
	if($current_operation eq 'modify' && $current_type eq 'group'){
		# modify an existing group
		mod_memberof();
		$mod_grp ++;
	}
	if($current_operation eq 'del' && $current_type eq 'group'){
		# delete an existing group
		delgroup();
		$del_grp++;
	}
		#user operation: add, mod, del
	if($current_operation eq 'add' && $current_type eq 'user'){
		# add a new user into ldap server
		adduser();
		$add_usr ++;
	}
	if($current_operation eq 'modify' && $current_type eq 'user'){
		# modify an existing user
		#getrandom_existinguser();
		$mod_usr ++;
	}
	if($current_operation eq 'del' && $current_type eq 'user'){
		# delete an existing user
		deluser();
		$del_usr ++;
	}
	
	
	# keep track of all operation and operation target type
	if ($current_operation eq 'add')   { $addcounter++;}
	if ($current_operation eq 'modify'){ $modcounter++;}
	if ($current_operation eq 'del')   { $delcounter++;}
	
	if ($current_type eq 'group'){ $grpcounter++;}
	if ($current_type eq 'user') { $usrcounter++;}
	print "\nLOOP (".$loopindex.") finished  operation: ".$current_operation." for ".$current_type;
	
}# giant while loop

print "\n".gettimestamp()." after all of those random operations, the data looks like below";
printmembers(\%g);
printmembers(\%u);

print "\n--------------------------------------------";
print "\ntotal loop [$maxloop], add [$addcounter], mod [$modcounter], del [$delcounter]";
print "\ntotal loop [$maxloop], grp [$grpcounter], usr [$usrcounter]";
print "\n Add: add usr [$add_usr] + add grp [$add_grp] = ".($add_usr + $add_grp);
print "\n Mod: mod usr [$mod_usr] + mod grp [$mod_grp] = ".($mod_usr + $mod_grp);
print "\n Del: del usr [$del_usr] + del grp [$del_grp] = ".($del_usr + $del_grp);
print "\n--------------------------------------------";
print "\n total group layers: [$glevel] group size in each layer: [$gsize] \n total user layers: [$ulevel], user size in each layer [$usize]";
print "\n total running loop: $maxloop";
print "\n uid end at [$baseuid_index], gid end at [$basegid_index]";
 
cleanup();
system_cleanup();

# end of program close logfile

logger ("debug", "ROBOT finished");
close LOG;
################################
#*     sub routines           *#
################################

sub init { 
	
	# init log file
	if (!(-e $logfile)){
		system ("touch $logfile");
	}
	if (!open (LOG ,">>$logfile")){
		print "\n[init] can not open log file [$logfile]";  
	}else{
		logger ("debug", "[init] use [$logfile] as log file");
	}
	
	# load config file to re-define global variables 
	my $config = readconfig ($configfile);
	$ipahost = $config->{"ipahost"};
	$dn = $config->{"admindn"};
	$passwd = $config->{"adminpasswd"};
	$base = $config->{"base"};
	$usr_suffix = $config->{"usr_suffix"};
	$grp_suffix = $config->{"grp_suffix"};
	$gsize = $config->{"gsize"};
	$glevel = $config->{"glevel"};
	$add_weight = $config->{"add_weight"};
	$mod_weight = $config->{"mod_weight"};
	$del_weight = $config->{"del_weight"};
	$grp_weight = $config->{"grp_weight"};
	$usr_weight = $config->{"usr_weight"};
	$usize = $gsize * 10; 
	$ulevel = $glevel;
	$baseuid_index = $usize * $ulevel * 200;
	$basegid_index = $gsize * $glevel * 100;  
	$maxloop = $usize * $ulevel * 10;
	$loopindex = 0; 
	$ldap = Net::LDAP->new($ipahost) or die "$@";
	$admin = $ldap->bind( $dn, password => $passwd, version => 3 ); 
	
	# construct the operations and type queue based on the weight 
	for (my $w = 0; $w < $add_weight ; $w++){ push @operation, "add";}#for loop 
	for (my $w = 0; $w < $mod_weight ; $w++){ push @operation, "modify";}#for loop
	for (my $w = 0; $w < $del_weight ; $w++){ push @operation, "del";}#for loop
	for (my $t = 0; $t < $grp_weight ; $t++){ push @type, "group";}	#for loop
	for (my $t = 0; $t < $usr_weight ; $t++){ push @type, "users";}	#for loop
	
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
}#init

sub cleanup {
	# cleanup will scan all existing group and user array and delete them from ldap server
	print gettimestamp()." data clean up starts ...";
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
	print " done";
}# cleanup

sub system_cleanup {
	logger ("debug", "[system_cleanup] starts...");
	# even we called cleanup(), I still see there are some left over , that's why I need this system wide clean up
	# step 1, find all user that match this filter: "uid=u-*"
	my @leftover;
	logger ("debug", "[system_cleanup] searching leftover users "); 
	my $mesg = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => "uid=u-*",
	                       attrs  => ['uid']
                      );
	 if ( $mesg->code ){
	    my $errstr = $mesg->code;
	    logger ("debug", "search error, code:  $errstr\n");
	    $errstr = ldap_error_text($errstr);
	    print "$errstr\n";
	 }else{ 
	 	my $max = $mesg->count; 
		print " ... found total [$max] user: ";
		for( my $index = 0 ; $index < $max ; $index++) {
			my $entry = $mesg->entry($index);
			my $id = $entry->get_value('uid');
			print " [$id]";
			my $uid = "uid=".$id.",$usr_suffix";
			push @leftover, $uid; 
		} 
	} 
	
	logger ("debug", "[system_cleanup] searching leftover groups ");
	 
	$mesg = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => "cn=g-*",
	                       attrs  => ['cn']
                      );
	 if ( $mesg->code ){
	    my $errstr = $mesg->code;
	    logger ("debug", "search error, code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    print "$errstr\n";
	 }else{ 
	 	my $max = $mesg->count; 
		print "... found total [$max] group records, ";
		for( my $index = 0 ; $index < $max ; $index++) {
			my $entry = $mesg->entry($index);
			my $id = $entry->get_value("cn"); 
			print " [$id]";
			my $gid = "cn=".$id.",$grp_suffix";
			push @leftover, $gid;
		}# all entries
	} 
	
	logger ("debug", "[system_cleanup] start deleting...");
	foreach my $id (@leftover){
		logger ("debug", "[system_cleanup] delete [$id]");
		if(ldap_delete($id)){
			print "... success";
		}else{
			print "... failed";
		}
	}#delete all in leftover queue
	logger ("debug", "[system_cleanup] finished");
}# system_cleanup

########################################
# user and group operation functions   #
#######################################

sub adduser{
	# adduser means move user in a "u-somelevel-new" array to "u-samelevel-existing" array
	my $level_index = int(rand($ulevel))+1; #user level starts from 1 to 10
	my $current_level_newuser_index = "u-".$level_index."-new";
	my $current_level_existinguser_index= "u-".$level_index."-existing";
	
	my $newusers_ref = $u{$current_level_newuser_index};
	my @newusers = @$newusers_ref;
	
	if ($#newusers==-1){return;} # if the new user array has size 0, then do nothing
	
	my $existingusers_ref = $u{$current_level_existinguser_index};
	my @existingusers = @$existingusers_ref;
	
	# move user out of "new user" array and put it into "existing user" array"
	my $index = int(rand($#newusers+1));
	my $random_user = $newusers[$index];
	my $uid = "uid=".$random_user.",$usr_suffix";
	if (ldap_adduser($uid)){
		# if add this user into ldap success
		my @removed = splice (@newusers, $index,1);
		push @existingusers, @removed;
		logger ("debug", " move ($current_level_newuser_index)[".$removed[0]."] to existing user pool");
		# put the new arrays back to hash
		$u{$current_level_newuser_index} = \@newusers;
		$u{$current_level_existinguser_index} = \@existingusers;
	}else{
		#logger ("debug", " move ($current_level_newuser_index)[".$removed[0]."] to existing failed";
	}	
}#adduser

sub mod_memberof{
	logger ("debug", "[memberof] starts...");
	my @target_pool = ();
	my $targetid,
	my $gid, 
	
	# choose one user or group from next level, unless this is the deepest level of group
	my $level = int(rand($glevel)); 
	my $current_level_grp = "g-".$level."-existing";
	my $grps_ref = $g{$current_level_grp};
	my @grps = @$grps_ref;
	if ($#grps==-1){ 
		 # if the group array has size 0, then do nothing
		logger ("debug", "[memberof] group pool [$current_level_grp] is empty, return without any further action,"); 
		return;
	}else{
		my $grp_index = int(rand($#grps+1));
		my $random_grp = $grps[$grp_index];
		$gid = "cn=".$random_grp.",$grp_suffix"; 
		logger ("debug", "[memberof] pick group [$gid]");
	}
 
	my $next_level_usr = "u-".($level+1)."-existing"; #user is always one level lower than group
	my $usrs_ref = $u{$next_level_usr};
	my @usrs = @$usrs_ref;
	if ($#usrs >= 0){
		my $all = "@usrs";
		logger ("debug", "[memberof] user pool: ".$all);
		push @target_pool, @usrs;
	}else{
		logger ("debug", "[memberof] next level usr pool is empty");
	}
	if ($level < ($glevel-1)){
		my $next_level_grp = "g-".($level+1)."-existing";
		my $next_grp_ref = $g{$next_level_grp};
		my @next_grps = @$next_grp_ref;
		if ($#next_grps >= 0){
			my $all = "@grps";
			logger ("debug", "[memberof] group pool:".$all);
			push @target_pool, @next_grps;
		}
	}else{
		logger ("debug", "[memberof] max group level = [$glevel], [$gid] is already the last layer of group, only users can be added");
	}
	
	if ($#target_pool == -1){
		# randomly choose one group and one target from target pool
		logger ("debug", "[memberof] next level pool is empty, return without any further action");
		return;
	}else{ 
		my $all = "@target_pool";
		logger ("debug", "[memberof] pick from this pool:");
		logger ("debug", "[memberof] $all");
	 	my $target_index = int(rand($#target_pool+1)); 
		my $random_target = $target_pool[$target_index];
		if ($random_target =~ /^u/){
			$targetid = "uid=".$random_target.",$usr_suffix";
		}elsif ($random_target =~ /^g/){
			$targetid = "cn=".$random_target.",$grp_suffix";
		}else{
			logger ("debug", "[memberof] unexpected error, please check");
			logger ("debug", "[memberof] targetid = [$targetid]");
			return;
		} 
		logger ("debug", "[memberof] final draft add [$random_target] as memberof [$gid]");
	}

	# 'add' 'del' 'replace' should be in another random function as well
	my @memberof_ops = ('add','replace','del');
	my $op_index = int(rand($#memberof_ops+1));
	my $memberof_op = $memberof_ops[$op_index];
	logger ("debug", "[memberof] [$memberof_op] target=[$targetid]  group=[$gid] starts");
	if (ldap_mod_memberof($gid,$targetid, $memberof_op )){
		logger ("debug", "[memberof] [$memberof_op] target=[$targetid]  group=[$gid] success");
	}else{
		logger ("debug", "[memberof] [$memberof_op] target=[$targetid]  group=[$gid] failed");
	}	
}#moduser_memberof

sub deluser {
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
	if(ldap_delete($uid)){
		my @removed = splice (@existingusers, $index,1);
		push @newusers, @removed; 
		logger ("debug", " move ($current_level_existinguser_index)[".$removed[0]."] to new user pool");
		# put the new arrays back to hash
		$u{$current_level_newuser_index} = \@newusers;
		$u{$current_level_existinguser_index} = \@existingusers;
	}

}# group: move existing -> new

sub addgroup{
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
	if(ldap_addgroup($gid)){
		my @removed = splice (@newgroups, $index,1);
		push @existinggroups, @removed; 
		# put the new arrays back to hash
		$g{$current_level_newgroup_index} = \@newgroups;
		$g{$current_level_existinggroup_index} = \@existinggroups;
		logger ("debug", "[addgroup] move ($current_level_newgroup_index)[".$removed[0]."] to existing group pool success");
	}else{
		logger ("debug", "[addgroup] add group [$gid] failed");
	}
}

sub delgroup {
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
	if (ldap_delete($gid)){
		my @removed = splice (@existinggroups, $index,1);
		push @newgroups, @removed; 
		logger ("debug", " move ($current_level_existinggroup_index)[".$removed[0]."] to new group pool \n");
		# put the new arrays back to hash
		$g{$current_level_newgroup_index} = \@newgroups;
		$g{$current_level_existinggroup_index} = \@existinggroups;
	} 
}#delgroup

sub printmembers {
    my $hash=shift;
    my %h=%$hash;
    foreach (sort keys %h){
    	my $m = $h{$_};
    	my @members = @$m;
        logger ("debug", "[$_]\t");
        foreach (sort @members) {
  			print "$_ ";
		}
    }
}#printmembers

#####################################
#  LDAP functions                   #
#####################################
sub ldap_search{
	my ($filter, $attrs) = @_;  
	my $mesg = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => $filter,
	                       attrs  => $attrs
                      );
	 if ( $mesg->code )
	 {
	    my $errstr = $mesg->code;
	    logger ("debug", "search error, code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    print "$errstr\n";
	 }else{
	 	logger ("debug", "search [$filter] ");
	 	ldap_printall($mesg); 
	 } 
}#ldap_search

sub ldap_printall{
	my $mesg=shift;
	my $max = $mesg->count; 
	print "... found total [$max] records";
	for( my $index = 0 ; $index < $max ; $index++) {
		my $entry = $mesg->entry($index);
		my @attrs = $entry->attributes;
		logger ("debug", "\tentry# [$index]");
		foreach my $attr (@attrs){
			logger ("debug", "\t[$attr]\t");
  			foreach ($entry->get_value( $attr )) {
      			print $_." ,";
    		}# all value of each attr
		}# all attrs
	}# all entries
}


sub ldap_mod_memberof{
	my ($gid, $id, $operation) = @_;
	my $return=0;
	logger ("debug", "[memberof] op=[$operation], usr=[$id], grp=[$gid]");
	
	#operation = add, delete, replace
	if ($operation eq 'add'){ 
		my @t = split(/,/,$gid);
		my $filter = $t[0];
        ldap_search($filter);
        my %allmembers = ldap_attr_readvalues($filter, 'member');
        if (exists $allmembers{$id} ){ 
        	logger ("debug", "[memberof add] ($id) is already member of group ($gid) do nothing");
        	return 1;
        }
        my @addArrayList = [ 'member', "$id"];
        my $result = $ldap->modify ( $gid,changes => [
                                                 add => @addArrayList
                                                     ]
                                   );# ldap->modify function call
		@t = split(/,/,$id);
		$filter = $t[0];
		ldap_search($filter); 
		if ( $result->code )
		{
			my $errstr = $result->code;
  			logger ("debug", "[memberof add] Error code:  $errstr");
			$errstr = ldap_error_text($errstr);
			logger ("debug", "[memberof add] $errstr");
		}else{
			logger ("debug", "[memberof add] add [$id] as [$gid]'s member success");
			$return=1;
		}# verify the ldap call result
	}# add 
	
	if ($operation eq 'del'){
		my @t = split(/,/, $gid);
		my $filter = $t[0];
		ldap_search($filter);
		my %allmembers = ldap_attr_readvalues($filter, 'member');
		my @all = keys %allmembers; 
		if ($#all == -1 ){
			logger ("debug", "[memberof del] ($gid) has no member at all, do nothing, just return");
			return 1;
		} 
		logger ("debug", "[memberof del] found member for [$gid] here: ");
		foreach (keys %allmembers){print $_." ";}; 
		my $attr_to_be_del = $all[(int(rand($#all+1)))]; 
		my @deleteArrayList = ['member'=>'$attr_to_be_del'];
		logger ("debug", "[memberof-del] step 1: delete one existing member [$attr_to_be_del]");
		#$mesg = $ldap->modify( $dn, delete => { 'telephoneNumber' => '911' } );
		#my $result_del = $ldap->modify ($gid, delete => {member =>'$attr_to_be_del'});
		ldap_search($filter);
		my $result_del = $ldap->modify ( $gid,
										changes => [
												delete => ['member'=>"$attr_to_be_del"]
											   ]
										);# ldap->modify function call
		if ( $result_del->code )
		{ 
			logger ("debug", "[memberof-del] step 1 failed");
			my $errstr = $result_del->code;
	    	logger ("debug", "[memberof-del] step 1 failed  Error code:  $errstr");
	    	$errstr = ldap_error_text($errstr);
	    	logger ("debug", "[memberof-del] step 1 failed  error message: $errstr");
	 	}else{
	 		logger ("debug", "[memberof-del] step 1 success"); 
	 		my $attr_to_be_add = $id;
	 		my @addArrayList = ['member'=>'$attr_to_be_add'];
	 		logger ("debug", "[memberof-del] step 2: add one new member [$attr_to_be_add]");
	 		my $result_add =  $ldap->modify ( $gid,changes => [
                                  			  add => ['member'=>"$attr_to_be_add"]
                                			]
                              		);# ldap->modify function call
            ldap_search($filter);
			if ($result_add->code){
				logger ("debug", "[memberof del] step 2 failed");
				my $errstr = $result_add->code;
	    		logger ("debug", "[memberof del] step 2 Error code:  $errstr");
	    		$errstr = ldap_error_text($errstr);
	    		logger ("debug", "[memberof del] step 2 $errstr");
			}else{
				#only when del and add both success , we can say this replace one attribute success;
				logger ("debug", "[memberof-del] step 2 success");
				$return = 1;
			} # if add one attribute value success
	 	}#if del one attribute value success
		logger ("debug", "[memberof-del] end of found function"); 
	}# del
	
	if ($operation eq 'replace') {
		my @ReplaceArrayList = [ 'member', "$id"];
		my @t = split(/,/,$id);
        my $filter = $t[0];
        logger ("debug", "[memberof replace] before replace");
        ldap_search($filter);
		my $result = $ldap->modify ( $gid,changes => [
                                  			  replace => @ReplaceArrayList
                                			]
                              		);# ldap->modify function call
        logger ("debug", "[memberof replace] after replace");
        ldap_search($filter);
		if ( $result->code )
		{
			my $errstr = $result->code;
	    	logger ("debug", "[memberof replace] Error code:  $errstr");
	    	$errstr = ldap_error_text($errstr);
	    	logger ("debug", "[memberof replace] $errstr");
	 	}else{
	 		logger ("debug", "[memberof replace] [$gid]'s member value with [$id] success");
	 		my %members = ldap_attr_readvalues($gid, "member");
	 		my @all = keys %members;
	 		logger ("debug", "[memberof replace] member of ($gid) now are:");
	 		foreach (@all){logger ("debug", "\t\t".$_);};
	 		logger ("debug", "");
	 		$return=1;
	 	}# verify the ldap call result
	}# replace 
	
	 return $return;
}#ldap_mod_memberof

sub ldap_adduser{ 
	my $uid = shift; # logger ("debug", "add ($uid)"; return 1;
	my $return=0;
	my $usr_attrs = ldap_make_usrattrs();
	my $result = $ldap->add($uid, attr=> $usr_attrs );
	if ( $result->code )
	{
		my $errstr = $result->code;
	    logger ("debug", "[ldap_adduser] Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    logger ("debug", "[ldap_adduser] $errstr");
	 }else{
	 	logger ("debug", "[ldap_adduser]  '$uid' success");
	 	$return=1;
	 } 
	 return $return;
}#adduser 

sub ldap_addgroup{ 
	my $gid = shift ; # logger ("debug", "add ($gid)"; return 1;
	my $return=0;
	my $grp_attrs = ldap_make_grpattrs();
	my $result = $ldap->add($gid, attr=> $grp_attrs); 
	if ( $result->code )
	 {
	 	logger ("debug", "[ldap_addgroup] add group [$gid] failed");
	    my $errstr = $result->code;
	    logger ("debug", "[ldap_addgroup] Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger ("debug", "[ldap_addgroup] $errstr");
	}else{
	 	logger ("debug", "[ldap_addgroup] add [$gid] success");
	 	$return=1;
	}  
	return $return;
}# ldap_addgroup

sub ldap_delete{
	# data sample
	#    $id = "cn=testgrp100,cn=groups,cn=accounts,dc=test,dc=com"  # for user 
	# or $id = "uid=sub100,cn=users, cn=accounts,dc=test,dc=com"     # for group
	my $id = shift; # logger ("debug", "delete ($id) "; return 1;
	my $return=0;
	my $result = $ldap->delete($id);
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger ("debug", "[ldap_delete] delete ($id) has error, Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger ("debug", "[ldap_delete] $errstr");
	}else{
	 	#logger ("debug", "[ldap_delete] delete '$id' success";
	 	$return=1;
	} 
	return $return;
}

sub ldap_attr_addvalue {
	my ($id, $attr,$attr_value)=@_;
	my $return = 0;
	logger ("debug", "[ldap_attr_addvalue] input values:\n[id]=[$id]\n[attr]=[$attr]\n[value]=[$attr_value]"); 
	my @t = split(/,/,$id);
	my $filter = $t[0];
	ldap_search($filter);
	@t = split(/,/,$attr_value);
	$filter = $t[0];
	ldap_search($filter);
	my $result = $ldap->modify ( $id,
								changes => [
                                  			add => [ '$attr'=> "$attr_value"]
                                		   ]
                              	);# ldap->modify function call
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    print "n[ldap_attr_addvalue] add attr error: Error code:  $errstr";
	    $errstr = ldap_error_text($errstr);
		logger ("debug", "[ldap_attr_addvalue] $errstr");
	}else{
		$return = 1;
	 	print "n[ldap_attr_addvalue] add value to attribute [$attr] for group [$id] success\n"; 
	}  					
	return $return;
}# add one value into one given attribute

sub ldap_attr_delvalue {
	my ($id, $attr,$attr_value)=@_;
	#logger ("debug", "input values:\n[id]=[$id]\n[attr]=[$attr]\n[value]=[$attr_value]"; 
	my $result = $ldap->modify ( $id,
								changes => [
                                  			delete => [ '$attr'=> "$attr_value"]
                                		   ]
                              	);# ldap->modify function call
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger ("debug", "delete attr error: Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger ("debug", "$errstr");
	}else{
	 	logger ("debug", "delete one attribute [$attr] value [$attr_value] from group [$id] success"); 
	}  					
}# del one value into one given attribute

sub ldap_attr_replacevalue {
	my ($id, $attr,$attr_value)=@_;
	#logger ("debug", "input values:\n[id]=[$id]\n[attr]=[$attr]\n[value]=[$attr_value]"; 
	my $result = $ldap->modify ( $id,
								changes => [
                                  			replace => [ '$attr'=> "$attr_value"]
                                		   ]
                              	);# ldap->modify function call
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    logger ("debug", "replace attr error: Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
		logger ("debug", "$errstr");
	}else{
	 	logger ("debug", "replace one attribute [$attr] value [$attr_value] from group [$id] success"); 
	}  					
}# replace one value into one given attribute

sub ldap_attr_readvalues {
	my ($filter, $attr_name) = @_;
	my %values=(); 
	my $result = $ldap->search (base => $base,
								scope => $scope,
								filter => $filter,
								attrs => $attr_name);
	if ($result->code){
		my $errstr = $result->code;
		logger ("debug", "[attr read value] Error code:  $errstr");
	    $errstr = ldap_error_text($errstr);
	    logger ("debug", "[attr read value] $errstr");
	    
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
	my ($loglevel,$msg) = @_;
	if ($loglevel eq "debug"){
		print LOG "\n".gettimestamp()." ".$msg;  
	}
	print "\n".gettimestamp().$msg; 
	
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
		logger ("debug", "loading configruation fle [$configfile] ...");
		logger ("debug", "============================================");
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
			logger ("debug", $k);
			print " => ".$pair[1];
		}
		logger ("debug", "============================================\n");
		close CONFIG;
	}else{
		logger ("debug", "file [$configfile] can not open ");
	}
	return \%c; 
}#readconfig