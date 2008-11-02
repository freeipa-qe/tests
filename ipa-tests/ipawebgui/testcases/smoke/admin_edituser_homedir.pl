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
$sel->type_ok("form_homedirectory", "/home/a001edit");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("a001edit updated!");
$sel->is_text_present_ok("Home Directory: 	/home/a001edit");


