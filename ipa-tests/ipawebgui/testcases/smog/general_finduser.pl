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

#Find User UI
$sel->open_ok("/ipa");
$sel->click_ok("link=Find Users");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Find Users");
$sel->is_text_present_ok("Logged in as: preexist");

#Find user Functional
$sel->type_ok("uid", "admin");
$sel->click_ok("//input[\@value='Find Users']");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("results returned");
$sel->is_text_present_ok("Administrator(admin)");

#Need verify the link is clickable
$sel->click_ok("link=Administrator");
$sel->wait_for_page_to_load_ok("30000");

pass;
