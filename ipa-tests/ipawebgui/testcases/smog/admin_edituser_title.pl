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

# open page
$sel->open_ok("https://ipaserver.test.com/ipa/user/show?uid=a001");

#make one change
$sel->type_ok("form_title", "automation edited");
$sel->click_ok("submit");

#verify the change (logic flow)
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("a001 updated!");
$sel->is_text_present_ok("Title: 	automation edited");

pass;
