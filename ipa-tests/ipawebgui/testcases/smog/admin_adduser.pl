use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*firefox", 
                                    browser_url => "http://localhost:4444" ); 

# open add user page
$sel->click_ok("link=Free IPA");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Logged in as: admin");
# verify the menu
$sel->click_ok("link=Add User");
$sel->wait_for_page_to_load_ok("30000");

# add user UI
$sel->type_ok("form_title", "automation");
$sel->type_ok("form_givenname", "auto");
$sel->type_ok("form_sn", "001");
$sel->is_text_present_ok("* Add User\n    * Find Users\n\n    * Add Group\n    * Find Groups\n\n    * Add Service Principal\n    * Find Service Principal\n\n    * Manage Policy\n\n    * Self Service\n\n    * Delegations");
$sel->type_ok("form_initials", "a001");
$sel->type_ok("form_krbprincipalkey", "automatic001");
$sel->type_ok("form_krbprincipalkey_confirm", "automatic001");
$sel->type_ok("form_loginshell", "/bin/sh");
$sel->type_ok("form_gecos", "auto");
$sel->type_ok("form_telephonenumbers_0_telephonenumber", "400-100-1000");
$sel->type_ok("form_facsimiletelephonenumbers_0_facsimiletelephonenumber", "400-100-1001");
$sel->type_ok("form_mobiles_0_mobile", "400-100-1002");
$sel->type_ok("form_pagers_0_pager", "400-100-1003");
$sel->type_ok("form_homephones_0_homephone", "400-100-1004");
$sel->type_ok("form_street", "444 Castro St.");
$sel->is_text_present_ok("");
$sel->type_ok("form_roomnumber", "1200");
$sel->type_ok("form_l", "Mountain View");
$sel->type_ok("form_st", "California");
$sel->type_ok("form_postalcode", "94041");
$sel->type_ok("form_ou", "QA Department");
$sel->type_ok("form_businesscategory", "qa");
$sel->type_ok("form_description", "quality engineer department");
$sel->type_ok("form_employeetype", "quality engineer");
$sel->type_ok("form_carlicense", "b123456");
$sel->type_ok("form_labeleduri", "http://qa.com/");

# add user Functional 
$sel->click_ok("document.form.submit[1]");
$sel->wait_for_page_to_load_ok("30000");

# add user Logic flow
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
pass;
