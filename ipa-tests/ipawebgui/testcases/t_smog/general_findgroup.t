
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use use Test::More tests => 11;
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
our $testid=1042;
our $testdata;
our @datakeys=("criteria");

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
    # test case name (general_findgroup)
    # source (general_findgroup.pl)
    # [2008/5/15:11:41:14]

	my ($data, $sel) = @_;  
	if (!defined $sel){
		my $sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_ur =>$browser_url);
	}
	$sel->click_ok("link=Find Groups");
	$sel->is_text_present_ok("Find Groups");
	$sel->is_text_present_ok("Logged in as: preexist");
	$sel->type_ok("criteria", "$testdata->{'criteria'}");
	$sel->click_ok("//input[\@value='Find Groups']");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("results returned");
	$sel->is_text_present_ok("ipausers");
	$sel->is_text_present_ok("Default group for all users");
	$sel->click_ok("link=ipausers");
	$sel->wait_for_page_to_load_ok("30000");
} #general_findgroup


sub prepare_data(){
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data(){
	IPADataStore::cleanup_testdata($testid, $testdata);
}
