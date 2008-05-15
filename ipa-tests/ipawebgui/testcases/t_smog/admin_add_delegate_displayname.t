
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use use Test::More tests => 13;
use Test::Exception;

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $host;
our $port;
our $browser;
our $browser_url;
our $configfile="test.conf";
our $testid=1028;
our $testdata;
our @datakeys=("dest_criteria","source_criteria");

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};

## Test starts here 
IPAutil::env_check($host, $port, $browser, $browser_url);
prepare_data();
run_test($testdata);
cleanup_data($testdata);


#=========== sub =============

sub run_test {
    # test case name (admin_add_delegate_displayname)
    # source (admin_add_delegate_displayname.pl)
    # [2008/5/15:11:41:14]

	my ($data, $sel) = @_;  
	if (!defined $sel){
		my $sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_ur =>$browser_url);
	}
	#$sel->open_ok("/ipa/delegate/list");
	$sel->open_ok("/ipa/delegate/list");
	$sel->is_text_present_ok("Logged in as: admin");
	$sel->click_ok("link=add new delegation");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("//a[\@onclick=\"selectGroup('dest', 'cn=users-displayname,cn=groups,cn=accounts,dc=test,dc=com', 'users-displayname');                 return false;\"]");
	$sel->click_ok("document.form.submit[2]");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("displayname 	editor-displayname 	Display Name 	users-displayname");
	$sel->click_ok("//input[\@value='Find']");
	$sel->click_ok("//a[\@onclick=\"selectGroup('source', 'cn=editor-displayname,cn=groups,cn=accounts,dc=test,dc=com', 'editor-displayname');                 return false;\"]");
	$sel->click_ok("form_attrs_displayname");
	$sel->type_ok("dest_criteria", "$testdata->{'dest_criteria'}");
	$sel->type_ok("source_criteria", "$testdata->{'source_criteria'}");
} #admin_add_delegate_displayname


sub prepare_data(){
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data(){
	IPADataStore::cleanup_testdata($testid, $testdata);
}
