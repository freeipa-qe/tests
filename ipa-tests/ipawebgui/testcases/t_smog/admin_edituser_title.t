
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 6;
use Test::Exception;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $configfile="test.conf";
our $testid=1101;
our $testuid;
our $testgid;
our $testfulluid;
our $testfullgid;
our $testdata;
our @datakeys=("form_title");

our $host;
our $port;
our $browser;
our $browser_url;
our $sel;

our $ldap_server;
our $base;
our $scope;
our $adminpw;
our $ldap;

our $ssh;
our $ipaadmin; 
our $ipaadminpw; 
our $grpdesc;

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};

$ldap_server=$config->{'ldap_server'};
$base=$config->{'base'};
$scope=$config->{'scope'};
$adminpw = $config->{'adminpw'};
$ldap = Net::LDAP->new($ldap_server)or die "ldap error: $@ \nsuggest: check your firewall";  
my $result=$ldap->bind( "cn=directory manager", password => $adminpw, version => 3 );

	# we might not need this block, but leave them here for now
	# ldap bind need test before all test starts
	if ( $result->code )
	{
		print " failed, error as below: ";
		my $errstr = $result->code;
		print "Error code:  $errstr\n";
		$errstr = ldap_error_text($errstr);
		print "$errstr\n";
		exit 1;
	}else{
		print "bind as 'cn=directory manager' success\n";
	}

$ssh = "ssh root\@$host";
$ipaadmin = $config->{"ipaadmin"};
$ipaadminpw = $config->{"ipaadminpw"};

# Test starts here 
$testuid="seluser_".$testid;
$testgid="selgrp_".$testid;
$testfulluid="uid=sel_user_".$testid.",".$base;
$testfullgid="cn=sel_grp_".$testid.",cn=groups,cn=accounts,".$base;

$grpdesc = "automatic generated, gid=$testgid";

IPAutil::env_check($host, $port, $browser, $browser_url, $ldap_server, $base, $scope, $adminpw);
prepare_data();
run_test($testdata);
cleanup_data($testdata);


#=========== sub =============

sub run_test {
   # test case name (admin_edituser_title) from source (admin_edituser_title.pl)
   # auto generated at 2008/5/26:10:37:52
	$sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_url=>$browser_url);
	#$sel->open_ok("https://ipaserver.test.com/ipa/user/show?uid=a001");
	$sel->open_ok("/ipa/user/edit?uid=$testuid");
	$sel->type_ok("form_title", "$testdata->{'form_title'}");
	$sel->click_ok("submit");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("$testuid updated!");
	$sel->is_text_present_ok("Title: $testdata->{'form_title'}");
} #admin_edituser_title


sub prepare_data{
        kinit(); # this has to run before any selenium test starts
        
        $testdata = IPADataStore::construct_testdata($testid, @datakeys);      
        #IPAutil::ldap_adddummyuser($ldap, $testfulluid);
        #IPAutil::ldap_adddummygroup($ldap, $testfullgid);
        
        IPAutil::ipa_createuser($ssh, $testuid);
        #IPAutil::ipa_creategroup($ssh, $testgid, $grpdesc);
}

sub cleanup_data{
        #IPADataStore::cleanup_testdata($testid, $testdata);
        #IPAutil::ldap_delete($ldap, $testfulluid);
        #IPAutil::ldap_delete($ldap, $testfullgid);
        
        IPAutil::ipa_deleteuser($ssh, $testuid);
        #IPAutil::ipa_deletegroup($ssh, $testgid);
        kdestroy();
}


sub kinit{ 
	my $kinitcmd = "$ssh \"echo $ipaadminpw | kinit $ipaadmin\"";
	my $result = `$kinitcmd`;
	if ($result =~/kinit/){
		#error 1: kinit(v5): Cannot resolve network address for KDC in realm ...bla bla bla
		#error 2: kinit(v5): Password incorrect while getting initial credentials
		return 0;
	}else{
		my $klist = "$ssh klist";
		my $init_result = `$klist`;
		if ($init_result =~ /klist: No credentials cache found/){
			return 0;
		}else{
			return 1;
		}
	}#if kinit success, then double confirm with klist
}#kinit

sub kdestroy{
	my $kdestroycmd = "$ssh kdestroy";
	my $result = `$kdestroycmd`;
}#kdestroy

