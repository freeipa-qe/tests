
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use use Test::More tests => 43;
use Test::Exception;

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $host;
our $port;
our $browser;
our $browser_url;
our $configfile="test.conf";
our $testid=1003;
our $testdata;
our @datakeys=("form_title","form_givenname","form_sn","form_initials","form_krbprincipalkey","form_krbprincipalkey_confirm","form_loginshell","form_gecos","form_telephonenumbers_0_telephonenumber","form_facsimiletelephonenumbers_0_facsimiletelephonenumber","form_mobiles_0_mobile","form_pagers_0_pager","form_homephones_0_homephone","form_street","form_roomnumber","form_l","form_st","form_postalcode","form_ou","form_businesscategory","form_description","form_employeetype","form_carlicense","form_labeleduri");

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};

## Test starts here 
IPAutil::env_check($host, $port, $browser, $browser_url);
prepare_data();
run_test($testdata);
cleanup_data($testdata);


#=========== sub =============

sub run_test {
    # test case name (admin_adduser)
    # source (admin_adduser.pl)
    # [2008/5/15:11:41:14]

	my ($data, $sel) = @_;  
	if (!defined $sel){
		my $sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_ur =>$browser_url);
	}
	$sel->click_ok("link=Free IPA");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("Logged in as: admin");
	$sel->click_ok("link=Add User");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->type_ok("form_title", "$testdata->{'form_title'}");
	$sel->type_ok("form_givenname", "$testdata->{'form_givenname'}");
	$sel->type_ok("form_sn", "$testdata->{'form_sn'}");
	$sel->is_text_present_ok("* Add User\n    * Find Users\n\n    * Add Group\n    * Find Groups\n\n    * Add Service Principal\n    * Find Service Principal\n\n    * Manage Policy\n\n    * Self Service\n\n    * Delegations");
	$sel->type_ok("form_initials", "$testdata->{'form_initials'}");
	$sel->type_ok("form_krbprincipalkey", "$testdata->{'form_krbprincipalkey'}");
	$sel->type_ok("form_krbprincipalkey_confirm", "$testdata->{'form_krbprincipalkey_confirm'}");
	$sel->type_ok("form_loginshell", "$testdata->{'form_loginshell'}");
	$sel->type_ok("form_gecos", "$testdata->{'form_gecos'}");
	$sel->type_ok("form_telephonenumbers_0_telephonenumber", "$testdata->{'form_telephonenumbers_0_telephonenumber'}");
	$sel->type_ok("form_facsimiletelephonenumbers_0_facsimiletelephonenumber", "$testdata->{'form_facsimiletelephonenumbers_0_facsimiletelephonenumber'}");
	$sel->type_ok("form_mobiles_0_mobile", "$testdata->{'form_mobiles_0_mobile'}");
	$sel->type_ok("form_pagers_0_pager", "$testdata->{'form_pagers_0_pager'}");
	$sel->type_ok("form_homephones_0_homephone", "$testdata->{'form_homephones_0_homephone'}");
	$sel->type_ok("form_street", "$testdata->{'form_street'}");
	$sel->is_text_present_ok("");
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
	$sel->click_ok("document.form.submit[1]");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("a001 added!");
	$sel->is_text_present_ok("View User");
	$sel->is_text_present_ok("a001's password has expired");
	$sel->is_text_present_ok("Title: 	automation\nFirst Name: 	auto\nLast Name: 	001\nFull Name: 	\nauto 001\nDisplay Name: 	auto 001\nInitials: 	a001");
	$sel->is_text_present_ok("Account Status: 	active\nLogin: 	a001\nUID: 	1140\nGID: 	1002\nHome Directory: 	/home/a001\nLogin Shell: 	/bin/sh\nGECOS: 	auto");
	$sel->is_text_present_ok("E-mail Address: 	auto.001\@test.com\nWork Number: 	\n400-100-1000\nFax Number: 	\n400-100-1001\nCell Number: 	\n400-100-1002\nPager Number: 	\n400-100-1003\nHome Number: 	\n400-100-1004");
	$sel->is_text_present_ok("Street Address: 	444 Castro St.\nRoom Number: 	1200\nCity: 	Mountain View\nState: 	California\nZIP: 	94041");
	$sel->is_text_present_ok("Org Unit: 	QA Department\nTags: 	qa\nDescription: 	quality engineer department\nEmployee Type: 	quality engineer");
	$sel->is_text_present_ok("Car License: 	b123456\nHome Page: 	http://qa.com/");
	$sel->is_text_present_ok("ipausers");
} #admin_adduser


sub prepare_data(){
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data(){
	IPADataStore::cleanup_testdata($testid, $testdata);
}
