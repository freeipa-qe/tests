
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use use Test::More tests => 12;
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
our $testid=1015;
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
    # test case name (admin_edit_group_addgroupmember)
    # source (admin_edit_group_addgroupmember.pl)
    # [2008/5/15:11:41:14]

	my ($data, $sel) = @_;  
	if (!defined $sel){
		my $sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_ur =>$browser_url);
	}
	#$sel->open_ok(https://ipaserver.test.com/ipa/group/show?cn=autogrp001);
	$sel->open_ok(/ipa/group/show?cn=autogrp001);
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("//input[\@value='Edit Group']");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->type_ok("criteria", "$testdata->{'criteria'}");
	$sel->click_ok("//input[\@value='Find']");
	$sel->is_text_present_ok("ipausers [group]");
	$sel->click_ok("link=add");
	$sel->click_ok("submit");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("autogrp001-edit updated!");
	$sel->is_text_present_ok("Administrator (admin)\nauto edit 001 edit (a001edit)\npre edit exist edit (preexist)");
} #admin_edit_group_addgroupmember


sub prepare_data(){
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data(){
	IPADataStore::cleanup_testdata($testid, $testdata);
}
