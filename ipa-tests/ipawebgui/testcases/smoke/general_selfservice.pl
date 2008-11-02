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

# get into the self service page
$sel->click_ok("link=Free IPA");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=Self Service");
$sel->wait_for_page_to_load_ok("30000");

# UI verification
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

# functional 
$sel->type_ok("form_title", "pre-exist edit");
$sel->type_ok("form_givenname", "pre edit");
$sel->type_ok("form_sn", "exist edit");
$sel->type_ok("form_cns_0_cn", "pre exist edit");
$sel->type_ok("form_displayname", "pre exist edit");
$sel->type_ok("form_loginshell", "/bin/shedit");
$sel->type_ok("form_gecos", "preexistedit"); 
$sel->type_ok("form_telephonenumbers_0_telephonenumber", "408-100-1000");
$sel->type_ok("form_facsimiletelephonenumbers_0_facsimiletelephonenumber", "408-100-1001");
$sel->type_ok("form_mobiles_0_mobile", "408-100-1002");
$sel->type_ok("form_pagers_0_pager", "408-100-1003");
$sel->type_ok("form_homephones_0_homephone", "408-100-1004");
$sel->type_ok("form_street", "444 Castro St.");
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
$sel->click_ok("submit"); 

# Logic flow: page change to user information display page
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("preexist updated!");
$sel->is_text_present_ok("Title: 	pre-exist edit\nFirst Name: 	pre edit\nLast Name: 	exist edit\nFull Name: 	\npre exist edit\nDisplay Name: 	pre exist edit\nInitials: 	peedit");
$sel->is_text_present_ok("Account Status: 	active\nLogin: 	preexist\nUID: 	1136\nGID: 	1002\nHome Directory: 	/home/preexist\nLogin Shell: 	/bin/shedit\nGECOS: 	preexistedit");
$sel->is_text_present_ok("E-mail Address: 	pre.exist\@test.com\nWork Number: 	\n408-100-1000\nFax Number: 	\n408-100-1001\nCell Number: 	\n408-100-1002\nPager Number: 	\n408-100-1003\nHome Number: 	\n408-100-1004");
$sel->is_text_present_ok("Street Address: 	444 Castro St.\nRoom Number: 	1200\nCity: 	Mountain View\nState: 	California\nZIP: 	94041");
$sel->is_text_present_ok("Org Unit: 	QA Department\nTags: 	qa\nDescription: 	quality engineer department\nEmployee Type: 	quality engineer");
$sel->is_text_present_ok("Car License: 	b123456\nHome Page: 	http://qa.com/");
$sel->is_text_present_ok("Logged in as: preexist");
$sel->type_ok("form_initials", "peedit");
pass;
