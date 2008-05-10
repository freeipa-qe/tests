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

# make sure the dns record has been setup 
$sel->open_ok(https://ipaserver.test.com/ipa); 
$sel->wait_for_page_to_load_ok("30000");

$sel->click_ok("link=Manage Policy");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Manage Policy");
$sel->is_text_present_ok("IPA Policy");


