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

# Find group UI
$sel->click_ok("link=Find Groups");
$sel->is_text_present_ok("Find Groups");
$sel->is_text_present_ok("Logged in as: preexist");

# Find group Functional 
$sel->type_ok("criteria", "ipa");
$sel->click_ok("//input[\@value='Find Groups']");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("results returned");
$sel->is_text_present_ok("ipausers");
$sel->is_text_present_ok("Default group for all users");

# verify the link works
$sel->click_ok("link=ipausers");
$sel->wait_for_page_to_load_ok("30000");
pass;
