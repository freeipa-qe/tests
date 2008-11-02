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

# this is a negative test, there is no DNS record for the new principal
$sel->open_ok(https://ipaserver.test.com/ipa);
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=Add Service Principal");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("form_hostname", "tempprincipal.test.com");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("Service principal add failed: The requested hostname is not a DNS A record. This is required by Kerberos.");


pass;
