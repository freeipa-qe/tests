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

$sel->open_ok("/ipa/delegate/list");
$sel->is_text_present_ok("Logged in as: admin");
$sel->click_ok("link=add new delegation");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("form_name", "title");
$sel->type_ok("source_criteria", "editor");
$sel->click_ok("//input[\@value='Find']");
$sel->click_ok("//a[\@onclick=\"selectGroup('source', 'cn=editor-title,cn=groups,cn=accounts,dc=test,dc=com', 'editor-title');                 return false;\"]");
$sel->click_ok("form_attrs_title");
$sel->click_ok("//a[\@onclick=\"selectGroup('dest', 'cn=users-title,cn=groups,cn=accounts,dc=test,dc=com', 'users-title');                 return false;\"]");
$sel->click_ok("document.form.submit[2]");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("delegate created");
$sel->is_text_present_ok("title 	editor-title 	Title 	users-title");
$sel->type_ok("dest_criteria", "users");




