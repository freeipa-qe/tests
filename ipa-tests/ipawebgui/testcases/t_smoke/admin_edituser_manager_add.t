
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
our $testid=1056;
our $testdata;
our @datakeys=("manager_criteria");

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
   # test case name (admin_edituser_manager_add) from source (admin_edituser_manager_add.pl)
   # auto generated at 2008/5/16:10:54:41
	#$sel->open_ok(https://ipaserver.test.com/ipa/user/show?uid=a001);
	$sel->open_ok("/ipa/user/show?uid=a001");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("//input[\@value='Edit User']");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("link=change");
	$sel->type_ok("manager_criteria", "$testdata->{'manager_criteria'}");
	$sel->click_ok("//input[\@value='Find']");
	$sel->click_ok("link=select");
	$sel->click_ok("document.form.submit[2]");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("a001edit updated!");
	$sel->is_text_present_ok("Manager: 	Administrator");
} #admin_edituser_manager_add


sub prepare_data{
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data{
	IPADataStore::cleanup_testdata($testid, $testdata);
}
