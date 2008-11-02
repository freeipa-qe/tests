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

# ipa-addgroup -d  "editors that can modify user's firstname" editor-firstname
$sel->open_ok(https://ipaserver.test.com/ipa/delegate/list); 
$sel->wait_for_page_to_load_ok("30000");

$sel->click_ok("link=add new delegation");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("form_name", "edit-firstname");
$sel->type_ok("source_criteria", "firstname");
$sel->click_ok("//input[\@value='Find']");
$sel->is_text_present_ok("editor-firstname");
$sel->click_ok("link=select");
$sel->click_ok("form_attrs_givenname");
$sel->type_ok("dest_criteria", "firstname");
$sel->click_ok("//input[\@value='Find' and \@type='button' and \@onclick=\"return doSearch('dest');\"]");
$sel->is_text_present_ok("editor-firstname");
$sel->click_ok("//a[\@onclick=\"selectGroup('dest', 'cn=editor-firstname,cn=groups,cn=accounts,dc=test,dc=com', 'editor-firstname');                 return false;\"]");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("delegate created");
$sel->is_text_present_ok("edit-firstname 	editor-firstname 	First Name 	editor-firstname");

