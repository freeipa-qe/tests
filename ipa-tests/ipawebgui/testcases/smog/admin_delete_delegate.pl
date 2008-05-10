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

$sel->open_ok("/ipa");
$sel->is_text_present_ok("Logged in as: admin");
$sel->click_ok("link=Delegations");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=Delegations");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=edit-firstname");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("//input[\@value='Delete Delegation']");
$sel->wait_for_page_to_load_ok("30000");
ok($sel->get_confirmation() =~ /^Are you sure you want to delete this delegation[\s\S]$/);

pass;
