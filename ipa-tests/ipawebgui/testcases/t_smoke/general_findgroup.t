
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 11;
use Test::Exception;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $configfile="test.conf";
our $testid=1042;
our $testdata;
our @datakeys=("criteria");

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
   # test case name (general_findgroup) from source (general_findgroup.pl)
   # auto generated at 2008/5/16:10:54:41
	$sel->click_ok("link=Find Groups");
	$sel->is_text_present_ok("Find Groups");
	$sel->is_text_present_ok("Logged in as: preexist");
	$sel->type_ok("criteria", "$testdata->{'criteria'}");
	$sel->click_ok("//input[\@value='Find Groups']");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("results returned");
	$sel->is_text_present_ok("ipausers");
	$sel->is_text_present_ok("Default group for all users");
	$sel->click_ok("link=ipausers");
	$sel->wait_for_page_to_load_ok("30000");
} #general_findgroup


sub prepare_data{
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data{
	IPADataStore::cleanup_testdata($testid, $testdata);
}
