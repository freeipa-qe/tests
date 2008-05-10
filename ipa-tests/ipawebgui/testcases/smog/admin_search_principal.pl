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


$sel->open_ok(https://ipaserver.test.com/ipa);
$sel->wait_for_page_to_load_ok("30000");
$sel->select_window_ok("null");
$sel->click_ok("link=Find Service Principal");
$sel->wait_for_page_to_load_ok("30000");

$sel->type_ok("hostname", "a");
$sel->click_ok("//input[\@value='Find Service Principals']");
$sel->wait_for_page_to_load_ok("30000");

