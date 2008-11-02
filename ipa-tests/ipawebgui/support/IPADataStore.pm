#!/usr/bin/perl
# filename: IPADataStore
#

package IPADataStore;
use Carp;
#use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use strict;
require Exporter;
#require AutoLoader;

our $VERSION='0.01';
our @ISA=qw(Exporter); 
our @EXPORT = qw(genarate_form_user construct_teestdata);

sub hash2arrayref{
	my ($d) = shift;
	my %hash = %$d;
	my @s;
	foreach my $key (keys %hash){
	#	$s['$key'] = $hash{$key}; 
		if ($key =~ /form_loginshell/){
			push @s, "email";
			push @s, "yzhang\@rdhat.com";
		}else{
			push @s , $key;
			push @s , $hash{$key};
		}
		
	}
		push @s , 'objectclass';
		push @s , ['person', 'inetOrgPerson']; 
		
		push @s , 'cn';
		push @s , 'somecn';
		push @s , 'sn';
		push @s , 'somesn';
		push @s , 'uid';
		push @s , 'someuid';
		
	print "\n===debug ==";
	print @s;
	return \@s;
}
sub construct_testdata{
	my ($testid, @datakeys) = @_;
	my %testdata;
	foreach my $key (@datakeys){
		my $value = dataengine($key);
		$testdata{$key} = $value;
	}
	return \%testdata;
}#construct_testdata

sub cleanup_testdata{
	my ($testid, $testdata) = @_;
	
}#cleanup_testdata

sub getloginshell{
	return "/usr/bash"; # FIXME : need more flexible data here
}#getloginshell

sub gethomedir{
	my $level = int(rand(5)); #FIXME: directory level could be longer in future test
	my $homedir="";
	for( my $l =0; $l <= $level; $l++){
		my $dir = getstring(1,10);
		$homedir .="/".$dir;
	}	
	return $homedir; # FIXME : need some change here
}#gethomedir

sub dataengine{
	my $datakey = shift;
	
	my $password = getpassword();
	my $loginshell = getloginshell();
	
	my %datastore;
	
	# admin_add_delegate_displayname 
	# 	 dest_criteria -> users
	#	source_criteria -> editor 
	$datastore{"dest_criteria"} = "users";
	$datastore{"source_criteria"} = "editor";

	# admin_add_delegate_firstname : dest_criteria -> users
	#	form_name -> firstname
	#	source_criteria -> editor

	# admin_add_delegate_fullname : dest_criteria -> users
	#	form_name -> fullname
	#	source_criteria -> editor

	# admin_add_delegate_initial : dest_criteria -> users
  	#	form_name -> initials
  	#	source_criteria -> editor

	# admin_add_delegate_lastname : dest_criteria -> users
	#	form_name -> lastname
	#	source_criteria -> editor

	# admin_add_delegate_title : dest_criteria -> users
	#	form_name -> title
	#	source_criteria -> editor

	# admin_add_group 
	#  : form_cn -> autogrp001
	#  : form_description -> automation group 001
	$datastore{"form_cn"} = getgroupname();
	$datastore{"form_description"} = getdescription();

	# admin_adduser 
	#  : form_businesscategory -> qa
	#  : form_carlicense -> b123456
	#  : form_description -> quality engineer department
	#  : form_employeetype -> quality engineer
	#  : form_facsimiletelephonenumbers_0_facsimiletelephonenumber -> 400-100-1001
	#  : form_gecos -> auto
	#  : form_givenname -> auto
	#  : form_homephones_0_homephone -> 400-100-1004
	#  : form_initials -> a001
	#  : form_krbprincipalkey -> automatic001
	#  : form_krbprincipalkey_confirm -> automatic001
	#  : form_labeleduri -> http://qa.com/
	#  : form_l -> Mountain View
	#  : form_loginshell -> /bin/sh
	#  : form_mobiles_0_mobile -> 400-100-1002
	#  : form_ou -> QA Department
	#  : form_pagers_0_pager -> 400-100-1003
	#  : form_postalcode -> 94041
	#  : form_roomnumber -> 1200
	#  : form_sn -> 001
	#  : form_st -> California
	#  : form_street -> 444 Castro St.
	#  : form_telephonenumbers_0_telephonenumber -> 400-100-1000
	#  : form_title -> automation
	$datastore{"form_businesscategory"} = getbusinesscategory();
	$datastore{"form_carlicense"} = getcarlicense();
	$datastore{"form_description"} = getdescription(); # I know this one has been called before, but it won't hurt to call it again
	$datastore{"form_employeetype"} = getemployeetype();
	$datastore{"form_facsimiletelephonenumbers_0_facsimiletelephonenumber"} = getphone();
	$datastore{"form_gecos"} = getgecos();
	$datastore{"form_givenname"} = getfirstname();
	$datastore{"form_homephones_0_homephone"} = getphone();
	$datastore{"form_homephones_1_homephone"} = getphone();
	$datastore{"form_homephones_2_homephone"} = getphone();
	$datastore{"form_initials"} = getinitial();
	$datastore{"form_krbprincipalkey"} = getpassword();
	$datastore{"form_krbprincipalkey_confirm"} = $datastore{"form_krbprincipalkey"};
	$datastore{"form_labeleduri"} = gethomepage();
	$datastore{"form_l"} = getcity();
	$datastore{"form_loginshell"} = getloginshell();
	$datastore{"form_mobiles_0_mobile"} = getphone();
	$datastore{"form_mobiles_1_mobile"} = getphone();
	$datastore{"form_mobiles_2_mobile"} = getphone();
	$datastore{"form_ou"} = getou();
	$datastore{"form_pagers_0_pager"} = getphone();
	$datastore{"form_pagers_1_pager"} = getphone();
	$datastore{"form_pagers_2_pager"} = getphone();
	$datastore{"form_postalcode"} = getzipcode();
	$datastore{"form_roomnumber"} = getroom();
	$datastore{"form_sn"} = getlastname();
	$datastore{"form_st"} = getstate();
	$datastore{"form_street"} = getstreet();
	$datastore{"form_telephonenumbers_0_telephonenumber"} = getphone();
	$datastore{"form_telephonenumbers_1_telephonenumber"} = getphone();
	$datastore{"form_telephonenumbers_2_telephonenumber"} = getphone();
	$datastore{"form_title"} = gettitle();

	#
	# admin_delegation_add_all
	#  : dest_criteria -> a
	#  : form_name -> supervisor
	#  : source_criteria -> editor
	#
	# admin_delegation_add_firstname
	#  : dest_criteria -> firstname
	#  : form_name -> edit-firstname
	#  : source_criteria -> firstname
	#
	# admin_edit_group_addgroupmember
	#  : criteria -> ipauser
	$datastore{"criteria"} = "ipasuer"; # FIXME : only use this in smog test

	#
	# admin_edit_group_addusermember
	#  : criteria -> admin
	$datastore{"criteria"} = "admin" ; # FIXME: only use this in smog test

	#
	# admin_edit_group_cancle_editing 
	#  : form_description -> automation group 001 edit edit again
	$datastore{"form_description"} = getdescription();

	#
	# admin_edit_group_description
	#  : form_description -> automation group 001 edit
	$datastore{"form_description"} = getdescription();

	#
	# admin_edit_group_gid
	#  : form_gidnumber -> 1108001
	$datastore{"form_gidnumber"} = getgidnumber();

	#
	# admin_edit_group_name
	#  : form_cn -> autogrp001-edit
	$datastore{"form_cn"} = getgroupname();

	#
	# admin_edit_user_cancle_editing
	#  : form_givenname -> auto edit edit again
	$datastore{"form_givenname"} = getlastname();

	#
	# admin_edituser_carlicense
	#  : form_carlicense -> b123456edit
	$datastore{"form_carlicense"} = getcarlicense();

	#
	# admin_edituser_cellphone_add
	#  : form_mobiles_1_mobile -> 500-200-1002
	$datastore{"form_mobiles_1_mobile"} = getphone();

	#
	# admin_edituser_cellphone
	#  : form_mobiles_0_mobile -> 400-200-1002
	$datastore{"form_mobiles_0_mobile"} =  getphone();

	#
	# admin_edituser_city
	#  : form_l -> Mountain View edit
	$datastore{"form_l"} = getcity();
	
	#
	# admin_edituser_description
	#  : form_description -> quality engineer department edit
	#
	# admin_edituser_displayname
	#  : form_displayname -> auto 001 edit
	$datastore{"form_displayname"} = getfullname();
	#
	# admin_edituser_employeetype
	#  : form_employeetype -> quality engineer edit
	#
	# admin_edituser_faxnumber_add
	#  : form_facsimiletelephonenumbers_1_facsimiletelephonenumber -> 500-200-1001
	$datastore{"form_facsimiletelephonenumbers_0_facsimiletelephonenumber"} = getphone();
	$datastore{"form_facsimiletelephonenumbers_1_facsimiletelephonenumber"} = getphone();
	$datastore{"form_facsimiletelephonenumbers_2_facsimiletelephonenumber"} = getphone();

	#
	# admin_edituser_faxnumber
	#  : form_facsimiletelephonenumbers_0_facsimiletelephonenumber -> 400-200-1001
	#
	# admin_edituser_firstname
	#  : form_givenname -> auto edit
	#
	# admin_edituser_fullname_add
	#  : form_cns_1_cn -> new full name
	#
	# admin_edituser_fullname
	#  : form_cns_0_cn -> auto 001 edit
	$datastore{"form_cns_0_cn"} = getcn();
	$datastore{"form_cns_1_cn"} = getcn();
	$datastore{"form_cns_2_cn"} = getcn();

	#
	# admin_edituser_gecos
	#  : form_gecos -> autoedit
	#
	# admin_edituser_gid
	#  : form_gidnumber -> 200802
	#
	# admin_edituser_homedir
	#  : form_homedirectory -> /home/a001edit
	$datastore{"form_homedirectory"} = gethomedir();

	#
	# admin_edituser_homepage
	#  : form_labeleduri -> http://qa.com/edit
	#
	# admin_edituser_homephone
	#  : form_homephones_0_homephone -> 400-200-1004
	#
	# admin_edituser_homnumber_add
	#  : form_homephones_1_homephone -> 500-200-1004
	#
	# admin_edituser_initial
	#  : form_initials -> a001edit
	#
	# admin_edituser_lastname
	#  : form_sn -> 001 edit
	#
	# admin_edituser_loginname
	#  : form_uid -> a001edit
	#
	# admin_edituser_manager_add
	#  : manager_criteria -> admin
	#
	# admin_edituser_org
	#   : form_ou -> QA Department edit
	#
	# admin_edituser_pagernumber_add
	#  : form_pagers_1_pager -> 500-200-1003
	#
	# admin_edituser_pagernumber
	#  : form_pagers_0_pager -> 400-200-1003
	#
	# admin_edituser_password 
	#  : form_krbprincipalkey_confirm -> newpassword
	#  : form_krbprincipalkey -> newpassword
	#
	# admin_edituser_room
	#  : form_roomnumber -> 1200 edit
	#
	# admin_edituser_secretary_add
	#  : secretary_criteria -> admin
	$datastore{"secretary_criteria"} = "admin" ; # FIXME: not sure 

	#
	# admin_edituser_shell
	#  : form_loginshell -> /bin/shedit
	#
	# admin_edituser_state
	#  : form_st -> California edit
	#
	# admin_edituser_streetaddress
	#  : form_street -> 444 Castro St. edit
	#
	# admin_edituser_tags
	#  : form_businesscategory -> qa edit
	#
	# admin_edituser_title
	#  : form_title -> automation edited
	#
	# admin_edituser_uid
	#  : form_uidnumber -> 200801
	$datastore{"form_uidnumber"} = getuidnumber();

	#
	# admin_edituser_worknumber_add
	#  : form_telephonenumbers_1_telephonenumber -> 500-100-2000
        $datastore{"form_telephonenumbers_1_telephonenumber"} = getphone();

	#
	# admin_edituser_worknumber
	#  : form_telephonenumbers_0_telephonenumber -> 400-100-2000
	#
	# admin_edituser_zipcode
	#  : form_postalcode -> 10000
	#
	# admin_policy_edit_cancled
	#  : form_ipasearchtimelimit -> 100
        $datastore{"form_ipasearchtimelimit"} = getint(1);

	#
	# admin_policy_edit_password_historysize
	#  : form_krbpwdhistorylength -> 3
        $datastore{"form_krbpwdhistorylength"} = getint(1,999);

	#
	# admin_policy_edit_password_maxlifetime
	#  : form_krbmaxpwdlife -> 90
        $datastore{"form_krbmaxpwdlife"} = getint(1,999);

	#
	# admin_policy_edit_password_minclass
	#  : form_krbpwdmindiffchars -> 2
        $datastore{"form_krbpwdmindiffchars"} = getint(1,999);

	#
	# admin_policy_edit_password_minlength
	#  : form_krbpwdminlength -> 8
        $datastore{"form_krbpwdminlength"} = getint(1,999);

	#
	# admin_policy_edit_password_minlifetime
	#  : form_krbminpwdlife -> 1
	$datastore{"form_krbminpwdlife"} = getint(1,999);

	#
	# admin_policy_edit_password_notifyday
	#  : form_ipapwdexpadvnotify -> 2
	$datastore{"form_ipapwdexpadvnotify"} = getint(1,999);

	#
	# admin_policy_edit_search_searchgroupfields
	#  : form_ipagroupsearchfields -> description
	$datastore{"form_ipagroupsearchfields"} = "description,cn" ; # FIXME: need more

	#
	# admin_policy_edit_search_searchrecordlimit
	#  : form_ipasearchrecordslimit -> 100
	$datastore{"form_ipasearchrecordslimit"} = getint();

	#
	# admin_policy_edit_search_searchtimelimit
	#  : form_ipasearchtimelimit -> 1
	$datastore{"form_ipasearchtimelimit"} = getint();

	#
	# admin_policy_edit_search_searchuserfields
	#  : form_ipausersearchfields -> uid,givenName,sn,telephoneNumber,ou,title,
	$datastore{"form_ipausersearchfields"} = "uid,givenName,sn,telephoneNumber,ou,title"; # FIXME: need more

	#
	# admin_policy_edit_usersetting_defaultemaildomain
	#  : form_ipadefaultemaildomain -> email.test.com
	$datastore{"form_ipadefaultemaildomain"} = "test.com" ; # FIXME: need more

	#
	# admin_policy_edit_usersetting_defaultgroup
	#  : form_ipadefaultprimarygroup -> nogroup
	$datastore{"form_ipadefaultprimarygroup"} = "defaultipagrp"; # FIXME: need test it to verify

	#
	# admin_policy_edit_usersetting_homedir
	#  : form_ipahomesrootdir -> /newhome
	$datastore{"form_ipahomesrootdir"} = gethomedir();

	#
	# admin_policy_edit_usersetting_shell
	#  : form_ipadefaultloginshell -> /bin/newshell
	$datastore{"form_ipadefaultloginshell"} = getloginshell();

	#
	# admin_policy_edit_usersetting_usernamelength
	#  : form_ipamaxusernamelength -> 15
	$datastore{"form_ipamaxusernamelength"} = getint(1,999);

	#
	# admin_principal_add_cifs
	#  : form_hostname -> cifs.test.com
	$datastore{"form_hostname"} = gethostname();

	#
	# admin_principal_add_dhcp
	#  : form_hostname -> dhcp.test.com
	#
	# admin_principal_add_dns
	#  : form_hostname -> dns.test.com
	#
	# admin_principal_add_host
	#  : form_hostname -> host.test.com
	#
	# admin_principal_add_HTTP
	#  : form_hostname -> HTTP.test.com
	#
	# admin_principal_add_ldap
	#  : form_hostname -> ldap.test.com
	#
	# admin_principal_add_negative
	#  : form_hostname -> tempprincipal.test.com
	#
	# admin_principal_add_other
	#  : form_hostname -> other.test.com
	#  : form_other -> other services
	$datastore{"form_other"} = gethostname();

	#
	# admin_principal_add_rpc
	#  : form_hostname -> rpc.test.com
	#
	#admin_principal_add_snmp
	#  : form_hostname -> snmp.test.com
	#
	#admin_search_principal
	#  : hostname -> a
	#
	# admin_searchuser
	#  : uid -> auto
	#
	# general_findgroup
	#  : criteria -> ipa
	#
	#general_finduser
	#  : uid -> admin
	#
	# general_selfservice
	#  : form_businesscategory -> qa
	#  : form_carlicense -> b123456
	#  : form_cns_0_cn -> pre exist edit
	#  : form_description -> quality engineer department
	#  : form_displayname -> pre exist edit
	#  : form_employeetype -> quality engineer
	#  : form_facsimiletelephonenumbers_0_facsimiletelephonenumber -> 408-100-1001
	#  : form_gecos -> preexistedit
	#  : form_givenname -> pre edit
	#  : form_homephones_0_homephone -> 408-100-1004
	#  : form_initials -> peedit
	#  : form_labeleduri -> http://qa.com/
	#  : form_l -> Mountain View
	#  : form_loginshell -> /bin/shedit
	#  : form_mobiles_0_mobile -> 408-100-1002
	#  : form_ou -> QA Department
	#  : form_pagers_0_pager -> 408-100-1003
	#  : form_postalcode -> 94041
	#  : form_roomnumber -> 1200
	#  : form_sn -> exist edit
	#  : form_st -> California
	#  : form_street -> 444 Castro St.
	#  : form_telephonenumbers_0_telephonenumber -> 408-100-1000
	#  : form_title -> pre-exist edit
 
	return $datastore{$datakey};

}

sub getint{
	my ($min, $max) = @_;
	if (!defined $min){
		$min = 0;
	}
	if (!defined $max){
		$max=1000000 ; # 1 million
	}
	my $num = (int(rand($max))+$min) % $max;
	return $num;
}#getint

sub getuidnumber{
	my $range = 10000;
	my $num = int(rand($range))+1;
	#my $uid=sprintf("%05d", $num);
	return $num;
}#getuidnumber

sub getgidnumber{
	my $range = 10000;
	my $gid = int(rand($range))+1000;
	return $gid;
}

sub getgroupname{
	my @chars = ('a'..'z','0'..'9');
	my $length=int(rand(10))+1;
	my $groupname = generate_random_string($length, @chars);
	return $groupname;
}#getgroupname

sub getipapwdexpadvnotify{
	my $range = 1000;
	my $num = int(rand($range));
	return $num;
}#getipapwdexpadvnotify

sub getphone{ 
	my $areacode = int(rand(999));
	my $num1=int(rand(999));
	my $num2=int(rand(9999));
	my $a = sprintf("%03d", $areacode);
	my $b = sprintf("%03d", $num1);
	my $c = sprintf("%04d", $num2);
	my $phone = "$a-$b-$c";
	return $phone;
}#getphone

sub getzipcode{
	my $range = 99999;
	my $random_number = int(rand($range));
	my $zip=sprintf("%05d", $random_number);
	return $zip;
}#getzipcode

sub getroom{
	my $range = 9999;
	my $random_number = int(rand($range));
	return $random_number;
}#getroom

sub gettitle{
	my @chars = ('a'..'z');
	my $length=int(rand(10))+1;
	my $title = generate_random_string($length, @chars);
	return $title;
}#gettitle

sub getstring{
	my ($min, $max)=@_;
	if (!defined $min){
		$min=0;
	}
	if (!defined $max){
		$max=50;
	}
	my @chars = ('a'..'z');
	my $length=int(rand($max))+$min;
	my $firstname = generate_random_string($length, @chars);
	return $firstname;
}#getstring

sub gethostname(){
	my $host = getstring(1);
	my $server = getstring(1);
	my $suffix = randompick("com","org","net","tv","info","us");
	return "$host.$server.$suffix";
}# gethostname

sub randompick{
	my @strs = @_;
	my $total = @strs;
	my $index = int(rand($total));
	return $strs[$index];
}
sub getfirstname{
	return getstring(2);
}#getfirstname

sub getlastname{
	return getstring(@_);
}#getlastname

sub getcn{
	return getfullname(@_);
}#cn is fullname

sub getfullname{
	return getfirstname(@_)." ".getlastname();
}#getfullname

sub getdisplayname{
	return getfullname(@_);
}#getdisplayname

sub getinitial{
	my @chars=('a'..'z','0'..'9');
	my $length=int(rand(5))+1;
	generate_random_string($length, @chars);
}#getinitial

sub getstate{
	my @chars = ('A'..'Z');
	my $length=2;
	return generate_random_string($length, @chars);
}#getstate

sub getcity{
	my @chars = ('a'..'z', ' ');
	my $length = int(rand(15))+1;
	return generate_random_string($length, @chars);
}#getcity

sub getgecos{
	my @chars = ('a'..'z');
	my $length = int(rand(5))+1;
	return generate_random_string($length, @chars);
}
sub getcarlicense{
	my @chars = ('A'..'Z','0'..'9',' ');
	my $length = int(rand(7))+1;
	return generate_random_string($length, @chars);
}

sub getpassword{
	my @chars=('a'..'z','A'..'Z','0'..'9','_','@','*','&','^','~','#','$','%','(',')','+','+','{','}','[',']','|','\\',',','.','?','/','`');
	my $length=int(rand(15))+8;
	return generate_random_string($length, @chars);
}#getpassword

sub getemail{
	my $domain=shift;
	my @chars=('a'..'z','0'..'9');
	my $length = int(rand(15))+5;
	my $firsthalf = generate_random_string($length, @chars);
	if (defined $domain){
		return $firsthalf."@".$domain;
	}else{
		return $firsthalf."\@test.com";
	}
}#getemail

sub getbusinesstype{
	my @chars = ('a'..'z');
	my $length = int(rand(5))+1;
	return generate_random_string($length, @chars);
}#getbusinesstype

sub getbusinesscategory{
	my @chars = ('a'..'z');
	my $length = int (rand(10))+1;
	return generate_random_string($length, @chars);
}# getbusinesscategory

sub getemployeetype{
	my @chars = ('a'..'z');
	my $length = int(rand(5))+1;
	return generate_random_string($length, @chars);
}# getemployeetype

sub getou{
	my @chars = ('a'..'z');
	my $length = int(rand(5))+1;
	return generate_random_string($length, @chars);
}#getou

sub getdescription{
	my $maxchar = shift;
	if (!defined $maxchar){
		$maxchar=255;
	}
	my @chars=('a'..'z','A'..'Z','0'..'9','_','@','*','&','^','~','#','$','%','(',')','+','+','{','}','[',']','|','\\',',','.','?','/','`','\n');
	my $desc="";
	my $len=int(rand(15))+1;
	while( (length($desc)+$len)<= $maxchar){
		my $str = generate_random_string($len, @chars);
		$desc .=" ".$str;
		$len=int(rand(15))+1;
	}
	return $desc;
}#getdescription

sub getstreet{
	my $numstrs=int(rand(3))+1;
	return generate_multi_strs($numstrs);
}

sub gethomepage{
	my @chars=('a'..'z','0'..'9','_','-');
	my $length=int(rand(50))+1;
	my $site = generate_random_string($length,@chars);
	return "http://".$site.".com";
}

sub generate_multi_strs{
	my $numstrs=shift; 
	my $counter=0;
	my @chars=('a'..'z');
	my $strs=""; 
	while( $counter <= $numstrs ){
		my $len=int(rand(15))+1;
		my $str = generate_random_string($len, @chars);
		$strs .=" ".$str; 
		$counter ++;
	}
	return $strs;
}#getcity

sub generate_random_string
{
	my ($length_of_randomstring, @chars)=@_;# the length of the random string to generate 
	#my @chars=('a'..'z','A'..'Z','0'..'9','_');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}
