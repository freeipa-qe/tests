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
$sel->select_ok("form_nsAccountLock", "label=inactive");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Group Status: 	inactive");
$sel->is_text_present_ok("autogrp001-edit updated!");


pass;
