#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil ;

our $host="ipaserver";
our $port=4444;

our $configfile="../ipatest.conf";
our $config=loadconfig($configfile);
#printhash ($config);

if (pinghost($host,$port)) {
	print "\nserver [$host:$port] alive\n";
}
else {
    print "\nserver [$host:$port] no response\n";
}
