
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 15;
use Test::Exception;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $configfile="test.conf";
our $testid=1043;
our $testdata;
our @datakeys=("form_name","source_criteria","dest_criteria");

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
   # test case name (admin_add_delegate_title) from source (admin_add_delegate_title.pl)
   # auto generated at 2008/5/16:10:54:41
	#$sel->open_ok("/ipa/delegate/list");
	$sel->open_ok(""/ipa/delegate/list"");
	$sel->is_text_present_ok("Logged in as: admin");
	$sel->click_ok("link=add new delegation");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->type_ok("form_name", "$testdata->{'form_name'}");
	$sel->type_ok("source_criteria", "$testdata->{'source_criteria'}");
	$sel->click_ok("//input[\@value='Find']");
	$sel->click_ok("//a[\@onclick=\"selectGroup('source', 'cn=editor-title,cn=groups,cn=accounts,dc=test,dc=com', 'editor-title');                 return false;\"]");
	$sel->click_ok("form_attrs_title");
	$sel->click_ok("//a[\@onclick=\"selectGroup('dest', 'cn=users-title,cn=groups,cn=accounts,dc=test,dc=com', 'users-title');                 return false;\"]");
	$sel->click_ok("document.form.submit[2]");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("delegate created");
	$sel->is_text_present_ok("title 	editor-title 	Title 	users-title");
	$sel->type_ok("dest_criteria", "$testdata->{'dest_criteria'}");
} #admin_add_delegate_title


sub prepare_data{
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data{
	IPADataStore::cleanup_testdata($testid, $testdata);
}
