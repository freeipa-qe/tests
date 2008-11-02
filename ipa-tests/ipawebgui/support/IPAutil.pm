#!/usr/bin/perl
# filename: general utilities
#
package IPAutil;
use Carp;
#use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use IO::Socket;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

require Exporter;
#require AutoLoader;

$VERSION='0.01';
@ISA=qw(Exporter); 
@EXPORT = qw(printhash printarray readconfig pinghost timestamp);


#######################
#  General Utilities  #
#######################

# in: hash reference
# out:NONE, just print
sub printhash {
    my $hash=shift;
    my %h=%$hash;
    foreach (sort keys %h){
        print "\nkey=[$_] value=[$h{$_}]";
    }
}

sub printarray {
    my $arrey=shift;
    my @a=@$array;
    foreach (sort  @a){
        print "\n value=[$_]";
    }
}


# readconfig : input: a key=value pair config file
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
			my @pair = split(/\t/,$line);
			# FIXME shall i remove 
			$pair[0] =~s/\s+$//g; $pair[0] =~s/^\s+//g;
			$pair[1] =~s/\s+$//g; $pair[1] =~s/^\s+//g;
			$c{$pair[0]} = $pair[1]; 
			print "\n\t".$pair[0];
			print "\t\t==>  ".$pair[1];
		}
		print "\n============================================\n";
		close CONFIG;
	}else{
		print "\nfile [$configfile] can not open ";
	}
	return \%c; 
}#readconfig

sub logger
{
	my ($message) = shift;
	if (!(-e $logfile)){
		system ("touch $logfile");
	}
	if (!open (WRITE ,">>$logfile")){
		print "\ncan not open log file [$logfile]"; 
		return 0;
	} 
	print WRITE "\n".timestamp().": ".$log_message;	# write msg at the beginning
	close WRITE; 
}#logger

# get timestamp string
sub timestamp {
	# return current string type timestamp 
	# ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time) 
	# my ($mday,$mon,$year) = (localtime(time))[3,4,5];
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time) ;
	my $timestamp = ($year+1900)."/".($mon+1)."/".$mday.":".$hour.":".$min.":".$sec;
	return $timestamp;
}#timestamp

##############################
#     network utilities      #
##############################
sub pinghost {
	# input: ($host, $port)
	# output: return 1 if remote host active on given port, otherwise, return 0
	my ($host, $port)= @_; 
	my $return = 0;
	#  Try to connect
	my $remote = IO::Socket::INET->new(
    	Proto    => "tcp",
    	PeerAddr => $host,
    	PeerPort => $port,
    	Timeout  => 8,
	);
	# verify response
	if ($remote) {
    	# print "$host is alive\n";
    	close $remote;
    	$return = 1;
	} 
	return $return;
}

##########################
#     ipa utilities      #
##########################

sub env_check{
	my ($host, $port, $browser, $browser_url, $ldap_server,$base, $scope, $adminpw) = @_;
	my $retval=0;
	if (defined $host || defined $port || defined $browser || defined $browser_url) 
	{ 
		print "\ntest with the following configuration:\n";
		print "\nhost   : $host";
		print "\nport   : $port";
		print "\nbrowser: $browser";
		print "\nurl    : $browser_url";
		print "\nldap server : $ldap_server";
		print "\nldap base   : $base";
		print "\nldap scope  : $scope";
		print "\nldap passwd : $adminpw";
		print "\nstart environment check";
		if (pinghost($host, $port)){
			print "\nEnviromnent report: selenium server alive at [$host:$port]";
			$retval++;
		}else{
			print "\nEnvironment report: selenium server can not be reached at [$host:$port]";
			print "\nexit testing on error: can not reach selenium server\n"; 
		}
	}else
	{
		print "no default value defined, check 'test.conf', exit test"; 
	}
	
	# ldap server test
	print "\ntry to bind with ldap server...";
	my $ldap = Net::LDAP->new($ldap_server); 
	my $result = $ldap->bind("cn=directory manager", password => $adminpw, version => 3 ); 
	if ( $result->code )
	{
		print " failed, error as below: ";
		my $errstr = $result->code;
		print "Error code:  $errstr\n";
		$errstr = ldap_error_text($errstr);
		print "$errstr\n";
	}else{
		print "bind as 'cn=directory manager' success\n";
		$retval++;
	} 
	
	if ($retval == 2){ 
		print "\nEnvironment is ready for testing...\n";
	}else{
		print "\nEnvironment is not ready for testing, exit program";
		exit 1;
	}

}#envcheck

sub ldap_search{
	my ($ldap, $base, $scope, $filter, $attrs) = @_; 
	my $result = $ldap->search(base  => $base,
	                       scope  => $scope,
	                       filter => $filter,
	                       attrs  => $attrs
                      );
	 if ( $result->code )
	 {
	 	print "\nsearch failed";
	    my $errstr = $result->code;
	    print "Error code:  $errstr\n";
	    $errstr = ldap_error_text($errstr);
	    print "$errstr\n";
	 }else{ 
	 	print "\nsearch success!";
	 } 
	 return $result;
}#ldap_search

sub ldap_adddummyuser{
	my ($ldap,$fulluid) = @_; 
	$attrs = ['cn' => 'John Smith',
                          'sn' => 'Smith',  
                          'givenName' => 'John',
                          'homePhone' => '555-2020',
                          'mail' => 'john@domain.name',
                          'objectclass' => [ 'person', 'inetOrgPerson']];
	ldap_adduser($ldap, $fulluid, $attrs);
}# ldap_adddummyuser;

sub ldap_adduser{
	my ($ldap, $fulluid, $attrs) = @_;
	my $return=0;
	my $result = $ldap->add($fulluid, attr=> $attrs );
	if ( $result->code )
	{
		my $errstr = $result->code;
	    print "Error code:  $errstr\n";
	    $errstr = ldap_error_text($errstr);
	    print "$errstr\n";
	 }else{
	 	print "\nadd user '$fulluid' success\n";
	 	$return=1;
	 } 
	 return $return;
}#ldap_adduser

sub ldap_adddummygroup{
	my ($ldap, $fullgid) = @_;
	my $attrs = [ 'description' => "this is added by ldap_adddumygroup",
                  'objectclass' => ['groupofnames','inetUser']];
	ldap_addgroup($ldap, $fullgid, $attrs);
}# ldap_adddummygroup

sub ldap_addgroup{
	my ($ldap, $fullgid, $attrs) = @_ ;
	my $return=0;
	my $result = $ldap->add($fullgid, attr=> $attrs); 
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    print "Error code:  $errstr\n";
	    $errstr = ldap_error_text($errstr);
		print "$errstr\n";
	}else{
	 	print "\nadd group '$fullgid' success\n";
	 	$return=1;
	}  
	return $return;
}#ldap_addgroup

sub ldap_delete{
	my ($ldap, $fulluid) = @_;
	my $return=0;
	my $result = $ldap->delete($fulluid);
	if ( $result->code )
	 {
	    my $errstr = $result->code;
	    print "Error code:  $errstr\n";
	    $errstr = ldap_error_text($errstr);
		print "$errstr\n";
	}else{
	 	print "\ndelete '$fulluid' success";
	 	$return=1;
	} 
	return $return;
}#ldap_delete

sub ipa_finduser{
	my ($ssh, $uid) = @_;
	my $cmd = " $ssh $ipa_finduser -a $uid";
	my $result = `$cmd`;
	print "\nSearching user $uid ... ";
	if ($result =~ /No entries found for $uid/){
		print " no such user\n";
		return 0;
	}else{
		print " got it\n";
		print "$result";
		return 1;
	} 
}#finduser

sub ipa_searchuserattrs{
	my ($ssh, $uid, $match) = @_;
	my $found;
	my $cmd = " $ssh $ipa_finduser -a $uid";
	my $result = `$cmd`;
	my @lines = split($result , /\n/);
	foreach my $line (@lines){
		if ($line =~ /$match/){
			$found=$line;
			return $found;
		}
	}
	return $found;
}
sub ipa_createuser{
	my ($ssh,$uid,$attrs) = @_;
	my $addusercmd = "$ssh ipa-adduser -c GECOS -d /home/".$uid." -f default -l ".$uid." -p redhat123 -s /bin/bash ".$uid;
	my $result = `$addusercmd`;
	print "\ncreate user: $result";
	# if add user success "u101 successfully added"
	if($result =~ /$uid successfully added/){ 
		my %t = %$attrs; 
		foreach my $key (keys %t){
			my $value = $t{$key};
			print "\nuse ipa-moduser at [$key]=>[$value]";
			if (ipa_modifyuser($uid, $key, $value)){ 
				print " success  \n";
			}else{
				print " failed \n";
				return 0;
			}
		}		
		return 1;
	}else{
		return 0;
	} 
}#createuser

sub ipa_modifyuser{
	my ($ssh, $uid, $key, $value) = @_;
	my $modcmd = "$ssh ipa-moduser $uid --setattr \"$key=$value\"";
	my $result = `$modcmd`;
	print "\n$result";
	if ($result =~/$uid successfully updated/){
		return 1;
	}else{
		return 0;
	}
}#modifyuser

sub ipa_deleteuser{
	my ($ssh, $uid) = @_;
	my $delcmd = $ssh." ipa-deluser ".$uid;
	my $result = `$delcmd`;
	print "\ndelete user: $result";
	if ($result =~ /$uid successfully deleted/){ 
		return 1;
	}else{
		return 0;
	} 
}#deleteuser

sub ipa_creategroup{
	my ($ssh, $gid, $description) = @_;
	my $addgrpcmd = "$ssh \'ipa-addgroup -d \"$description\" $gid\'";
	my $result = `$addgrpcmd`;
	print "\nadd group : $result";
	if ($result =~ /$gid successfully added/){
		return 1;
	}else{
		return 0;
	}
}#ipa_addgroup

sub ipa_findgroup{
	my ($ssh,$str) = @_;
	my $findgroupcmd = "$ssh ipa-findgroup '$str'";
	my $result = `$findgroupcmd`;
	print "\nfind group: $result";
	if ($result =~/No entries found for $gid/){
		return 0;
	}else{
		return 1;
	}
}#ipa_findgroup

sub ipa_adduser2group{
	my ($ssh, $uid, $gid)= @_;
	my $adduser2groupcmd = "$ssh ipa-modgroup -a $uid $gid";
	my $result = `$adduser2groupcmd`;
	print "add user to group: $result";
	if ($result =~ /$uid successfully added to $gid/){
		return 1;
	}else{
		return 0;	
	}
}#ipa_adduser2group

sub ipa_removeuser{
	my ($ssh, $uid, $gid)= @_;
	my $adduser2groupcmd = "$ssh ipa-modgroup -r $uid $gid";
	my $result = `$adduser2groupcmd`;
	print "remove user from group: $result";
	if ($result =~ /$uid successfully removed/){
		return 1;
	}else{
		return 0;	
	}
}

sub ipa_addgroup2group{
	my ($ssh, $gid_tobeadd, $gid)= @_;
	my $addgroup2groupcmd= "$ssh ipa-modgroup -g $gid_tobeadd $gid";
	my $result = `$addgroup2groupcmd`;
	print "add group to group: $result";
	if ($result =~ /$gid_tobeadd successfully added to $gid/){
		return 1;
	}else{
		return 0;	
	}
}# ipa_addgroup2group

sub ipa_removegroup{
	my ($ssh, $gid_toberemove, $gid)= @_;
	my $addgroup2groupcmd= "$ssh ipa-modgroup -e $gid_toberemove $gid";
	my $result = `$addgroup2groupcmd`;
	print "remove group from group: $result";
	if ($result =~ /$gid_toberemove successfully removed $gid/){
		return 1;
	}else{
		return 0;	
	}
}#ipa_removegroup

sub ipa_deletegroup{
	my ($ssh, $gid) = @_;
	my $delgroupcmd = "$ssh ipa-delgroup $gid";
	my $result = `$delgroupcmd`;
	print "\ndelete group: $result";
	if ($result =~ /$gid successfully added/){
		return 1;
	}else{
		return 0;
	}
}#ipa_delgroup

1;

