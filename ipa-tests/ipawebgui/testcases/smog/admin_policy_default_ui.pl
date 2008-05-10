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
$sel->click_ok("link=IPA Policy");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Manage IPA Policy");
$sel->is_text_present_ok("Search Time Limit (sec.): 	2\nSearch Records Limit: 	0\nUser Search Fields: 	uid,givenName,sn,telephoneNumber,ou,title\nGroup Search Fields: 	cn,description");
$sel->is_text_present_ok("Password Expiration Notification (days): 	1\nMin. Password Lifetime (hours): 	0\nMax. Password Lifetime (days): 	9\nMin. Number of Character Classes: 	0\nMin. Length of Password: 	6\nPassword History Size: 	1");
$sel->is_text_present_ok("Max. Username Length: 	8\nRoot for Home Directories: 	/home\nDefault Shell: 	/bin/sh\nDefault User Group: 	ipausers\nDefault E-mail Domain: 	test.com");


