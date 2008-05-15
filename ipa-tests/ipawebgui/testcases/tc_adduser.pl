#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 11;
use Test::Exception;

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;

# global veriables
our $host;
our $port;
our $browser;
our $browser_url;
our $configfile="test.conf";

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};

# check testing environment
if (envcheck()){ 
	print "\nEnvironment is ready for testing...";
}else{
	exit 1;
}
my $testdata=prepare_data();

# run test
run_test($testdata);

cleanup_data($testdata);

print "\ntest finished\n";


#######################################################
########            sub routiens            ###########
#######################################################

# run all test case here
sub run_test{
	print "\ntest starts...\n";
	my $data=shift; 
	my $sel = Test::WWW::Selenium->new( host => $host, 
    	                                port => $port, 
        	                            browser => $browser, 
            	                        browser_url => $browser_url);
	$sel->open_ok("/ipa");
	$sel->click_ok("link=Add User");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->type_ok("form_title", $data->{'title'});
	$sel->type_ok("form_givenname", $data->{'givenname'});
	$sel->type_ok("form_sn", $data->{'sn'});
	$sel->type_ok("form_krbprincipalkey", $data->{'krbprincipalkey'});
	$sel->type_ok("form_krbprincipalkey_confirm", $data->{'krbprincipalkey'});
	$sel->click_ok("document.form.submit[1]");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok($data->{'sn'}." added!");
}# run_test


# loadconfig : this sub will call readconfig, and do environment check on the input data
#              return 1 if (1) config file can read (2) configuration data is ok
sub envcheck{
	my $retval=0;
	if (defined $host || defined $port || defined $browser || defined $browser_url) 
	{ 
		print "\ntest with the following configuration:\n";
		print "\nhost   : $host";
		print "\nport   : $port";
		print "\nbrowser: $browser";
		print "\nurl    : $browser_url";
		print "\nstart environment check";
		if (pinghost($host, $port)){
			print "\nEnviromnent report: selenium server alive at [$host:$port]";
			$retval=1;
		}else{
			print "\nEnvironment report: selenium server can not be reached at [$host:$port]";
			print "\nexit testing on error: can not reach selenium server\n"; 
		}
	}else
	{
		print "no test.conf found, and no default value defined, exit test"; 
	}	
	return $retval;
}#envcheck

# prepare_data : this sub will generate testing data.
sub prepare_data{
	#TODO: i need make sure this data does not exist before we start test
	my %newuser=('title'=>'auto001',
				 'givenname'=>'selenium',
				 'sn'=>'002',
				 'krbprincipalkey'=>'password123');
				 
	return \%newuser;
}# prepare_data

sub cleanup_data{
	#TODO: Clean data from server, so we have clean system each time
	print "\ntest data should be deleted from server, so we have a clean system after we finish the test";
}
