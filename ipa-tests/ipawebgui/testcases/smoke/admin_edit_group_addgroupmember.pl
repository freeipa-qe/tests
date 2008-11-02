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


$sel->open_ok(https://ipaserver.test.com/ipa/group/show?cn=autogrp001);
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("//input[\@value='Edit Group']");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("criteria", "ipauser");
$sel->click_ok("//input[\@value='Find']");
$sel->is_text_present_ok("ipausers [group]");
$sel->click_ok("link=add");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("autogrp001-edit updated!");
# group member might not easy to verify, we need do this verification from command line as well
$sel->is_text_present_ok("Administrator (admin)\nauto edit 001 edit (a001edit)\npre edit exist edit (preexist)");


pass;
