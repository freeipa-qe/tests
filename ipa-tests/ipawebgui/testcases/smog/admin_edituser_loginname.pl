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

$sel->open_ok(https://ipaserver.test.com/ipa/user/show?uid=a001);
$sel->wait_for_page_to_load_ok("30000"); 
$sel->click_ok("//input[\@value='Edit User']");
$sel->wait_for_page_to_load_ok("30000");
$sel->value_is("toggleprotected_checkbox", "off");
$sel->click_ok("toggleprotected_checkbox");
$sel->type_ok("form_uid", "a001edit");
ok($sel->get_confirmation() =~ /^Are you sure you want to change the login name[\s\S]
This can have unexpected results\. Additionally, a password change will be required\.$/);
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Login: 	a001edit");



