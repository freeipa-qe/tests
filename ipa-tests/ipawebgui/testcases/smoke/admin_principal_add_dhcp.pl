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



$sel->click_ok("link=Add Service Principal");
$sel->wait_for_page_to_load_ok("30000");
$sel->select_ok("form_service", "label=dhcp");
$sel->type_ok("form_hostname", "dhcp.test.com");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->value_is("hostname", "dhcp.test.com");
$sel->is_text_present_ok("dhcp/dhcp.test.com added!");

