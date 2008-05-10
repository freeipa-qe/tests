#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;
use lib '/home/yi/workspace/ipawebgui/testuitl';
use Util ;


our $host="ipaserver";
our $port=4444;
our $browser="*firefox";
our $browser_url="https://ipaserver.test.com";

our $configfile="ipatest.conf";
our $config=loadconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'testurl'};

printhash ($config);

if (pinghost($host,$port)) {
        print "\nserver [$host:$port] alive\n";
}
else {
    print "\nserver [$host:$port] no response\n";
}


my $sel = Test::WWW::Selenium->new( host => $host, 
                                    port => $port, 
                                    browser => $browser, 
                                    browser_url => $browser_url);

$sel->open_ok("/ipa");

