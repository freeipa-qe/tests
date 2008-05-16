
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 12;
use Test::Exception;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $configfile="test.conf";
our $testid=1092;
our $testdata;
our @datakeys=();

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

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};
$sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_url=>$browser_url);

$ldap_server=$config->{'ldap_server'};
$base=$config->{'base'};
$scope=$config->{'scope'};
$adminpw = $config->{'adminpw'};
$ldap = Net::LDAP->new($ldap_server); 

## Test starts here 
IPAutil::env_check($host, $port, $browser, $browser_url, $ldap_server, $base, $scope, $adminpw);
prepare_data();
run_test($testdata);
cleanup_data($testdata);


#=========== sub =============

sub run_test {
   # test case name (admin_policy_default_ui) from source (admin_policy_default_ui.pl)
   # auto generated at 2008/5/16:10:54:41
	#$sel->open_ok(https://ipaserver.test.com/ipa); 
	$sel->open_ok("/ipa"); 
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("link=Manage Policy");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("Manage Policy");
	$sel->is_text_present_ok("IPA Policy");
	$sel->click_ok("link=IPA Policy");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("Manage IPA Policy");
	$sel->is_text_present_ok("Search Time Limit (sec.): 	2\nSearch Records Limit: 	0\nUser Search Fields: 	uid,givenName,sn,telephoneNumber,ou,title\nGroup Search Fields: 	cn,description");
	$sel->is_text_present_ok("Password Expiration Notification (days): 	1\nMin. Password Lifetime (hours): 	0\nMax. Password Lifetime (days): 	9\nMin. Number of Character Classes: 	0\nMin. Length of Password: 	6\nPassword History Size: 	1");
	$sel->is_text_present_ok("Max. Username Length: 	8\nRoot for Home Directories: 	/home\nDefault Shell: 	/bin/sh\nDefault User Group: 	ipausers\nDefault E-mail Domain: 	test.com");
} #admin_policy_default_ui


sub prepare_data{
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data{
	IPADataStore::cleanup_testdata($testid, $testdata);
}
