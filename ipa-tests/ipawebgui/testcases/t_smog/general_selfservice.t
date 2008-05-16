
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 47;
use Test::Exception;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $configfile="test.conf";
our $testid=1054;
our $testdata;
our @datakeys=("form_title","form_givenname","form_sn","form_cns_0_cn","form_displayname","form_loginshell","form_gecos","form_telephonenumbers_0_telephonenumber","form_facsimiletelephonenumbers_0_facsimiletelephonenumber","form_mobiles_0_mobile","form_pagers_0_pager","form_homephones_0_homephone","form_street","form_roomnumber","form_l","form_st","form_postalcode","form_ou","form_businesscategory","form_description","form_employeetype","form_carlicense","form_labeleduri","form_initials");

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
   # test case name (general_selfservice) from source (general_selfservice.pl)
   # auto generated at 2008/5/16:10:54:41
	$sel->click_ok("link=Free IPA");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("link=Self Service");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("Logged in as: preexist");
	$sel->is_text_present_ok("Edit User");
	$sel->is_text_present_ok("Identity Details");
	$sel->is_text_present_ok("Account Details");
	$sel->value_is("toggleprotected_checkbox", "off");
	$sel->value_is("form_givenname", "pre");
	$sel->value_is("form_sn", "exist");
	$sel->value_is("form_title", "pre-exist");
	$sel->value_is("form_displayname", "pre exist");
	$sel->value_is("form_initials", "pe");
	$sel->value_is("form_loginshell", "/bin/sh");
	$sel->value_is("form_gecos", "preexist");
	$sel->value_is("form_mail", "pre.exist\@test.com");
	$sel->value_is("form_telephonenumbers_0_telephonenumber", "");
	$sel->value_is("form_facsimiletelephonenumbers_0_facsimiletelephonenumber", "");
	$sel->value_is("form_mobiles_0_mobile", "");
	$sel->value_is("form_pagers_0_pager", "");
	$sel->value_is("form_homephones_0_homephone", "");
	$sel->is_text_present_ok("Mailing Address");
	$sel->value_is("form_street", "");
	$sel->value_is("form_roomnumber", "");
	$sel->value_is("form_l", "");
	$sel->value_is("form_st", "");
	$sel->value_is("form_postalcode", "");
	$sel->is_text_present_ok("Employee Information");
	$sel->value_is("form_ou", "");
	$sel->value_is("form_businesscategory", "");
	$sel->is_text_present_ok("Misc Information");
	$sel->value_is("form_carlicense", "");
	$sel->value_is("form_labeleduri", "");
	$sel->is_text_present_ok("Groups");
	$sel->is_text_present_ok("ipausers");
	$sel->value_is("document.form.submit[3]", "Cancel Edit");
	$sel->value_is("document.form.submit[2]", "Update User");
	$sel->value_is("form_description", "");
	$sel->value_is("form_employeetype", "");
	$sel->type_ok("form_title", "$testdata->{'form_title'}");
	$sel->type_ok("form_givenname", "$testdata->{'form_givenname'}");
	$sel->type_ok("form_sn", "$testdata->{'form_sn'}");
	$sel->type_ok("form_cns_0_cn", "$testdata->{'form_cns_0_cn'}");
	$sel->type_ok("form_displayname", "$testdata->{'form_displayname'}");
	$sel->type_ok("form_loginshell", "$testdata->{'form_loginshell'}");
	$sel->type_ok("form_gecos", "$testdata->{'form_gecos'}"); 
	$sel->type_ok("form_telephonenumbers_0_telephonenumber", "$testdata->{'form_telephonenumbers_0_telephonenumber'}");
	$sel->type_ok("form_facsimiletelephonenumbers_0_facsimiletelephonenumber", "$testdata->{'form_facsimiletelephonenumbers_0_facsimiletelephonenumber'}");
	$sel->type_ok("form_mobiles_0_mobile", "$testdata->{'form_mobiles_0_mobile'}");
	$sel->type_ok("form_pagers_0_pager", "$testdata->{'form_pagers_0_pager'}");
	$sel->type_ok("form_homephones_0_homephone", "$testdata->{'form_homephones_0_homephone'}");
	$sel->type_ok("form_street", "$testdata->{'form_street'}");
	$sel->type_ok("form_roomnumber", "$testdata->{'form_roomnumber'}");
	$sel->type_ok("form_l", "$testdata->{'form_l'}");
	$sel->type_ok("form_st", "$testdata->{'form_st'}");
	$sel->type_ok("form_postalcode", "$testdata->{'form_postalcode'}");
	$sel->type_ok("form_ou", "$testdata->{'form_ou'}");
	$sel->type_ok("form_businesscategory", "$testdata->{'form_businesscategory'}");
	$sel->type_ok("form_description", "$testdata->{'form_description'}");
	$sel->type_ok("form_employeetype", "$testdata->{'form_employeetype'}");
	$sel->type_ok("form_carlicense", "$testdata->{'form_carlicense'}");
	$sel->type_ok("form_labeleduri", "$testdata->{'form_labeleduri'}");
	$sel->click_ok("submit"); 
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("preexist updated!");
	$sel->is_text_present_ok("Title: 	pre-exist edit\nFirst Name: 	pre edit\nLast Name: 	exist edit\nFull Name: 	\npre exist edit\nDisplay Name: 	pre exist edit\nInitials: 	peedit");
	$sel->is_text_present_ok("Account Status: 	active\nLogin: 	preexist\nUID: 	1136\nGID: 	1002\nHome Directory: 	/home/preexist\nLogin Shell: 	/bin/shedit\nGECOS: 	preexistedit");
	$sel->is_text_present_ok("E-mail Address: 	pre.exist\@test.com\nWork Number: 	\n408-100-1000\nFax Number: 	\n408-100-1001\nCell Number: 	\n408-100-1002\nPager Number: 	\n408-100-1003\nHome Number: 	\n408-100-1004");
	$sel->is_text_present_ok("Street Address: 	444 Castro St.\nRoom Number: 	1200\nCity: 	Mountain View\nState: 	California\nZIP: 	94041");
	$sel->is_text_present_ok("Org Unit: 	QA Department\nTags: 	qa\nDescription: 	quality engineer department\nEmployee Type: 	quality engineer");
	$sel->is_text_present_ok("Car License: 	b123456\nHome Page: 	http://qa.com/");
	$sel->is_text_present_ok("Logged in as: preexist");
	$sel->type_ok("form_initials", "$testdata->{'form_initials'}");
} #general_selfservice


sub prepare_data{
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data{
	IPADataStore::cleanup_testdata($testid, $testdata);
}
