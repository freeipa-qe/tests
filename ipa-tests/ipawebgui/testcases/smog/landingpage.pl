use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "ipaserver", 
                                    port => 4444, 
                                    browser => "*firefox", 
                                    browser_url => "http://ipaserver.test.com" );

$sel->open_ok("/ipa");
$sel->click_ok("link=Free IPA");
$sel->is_text_present_ok("Welcome to Red Hat Enterprise IPA");
$sel->is_text_present_ok("Logged in as: preexist");
$sel->is_text_present_ok("Tasks\n\n    * Find Users\n\n    * Find Groups\n\n    * Self Service");
$sel->wait_for_page_to_load_ok("30000");
