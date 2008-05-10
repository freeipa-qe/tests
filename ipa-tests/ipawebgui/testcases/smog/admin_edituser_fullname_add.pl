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

# remove / add full name
$sel->open_ok(https://ipaserver.test.com/ipa/user/show?uid=a001);
$sel->wait_for_page_to_load_ok("30000"); 
$sel->click_ok("//input[\@value='Edit User']");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=Remove");
$sel->alert_is("This item cannot be removed.");
$sel->click_ok("form_cns_doclink");
$sel->type_ok("form_cns_1_cn", "new full name");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("a001edit updated!");
$sel->is_text_present_ok("Full Name: 	\nauto 001 edit\nnew full name");

pass;
