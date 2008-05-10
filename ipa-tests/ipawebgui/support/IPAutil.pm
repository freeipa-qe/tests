#!/usr/bin/perl
# filename: general utilities
#
package Util;
use Carp;
#use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use IO::Socket;

require Exporter;
#require AutoLoader;

$VERSION='0.01';
@ISA=qw(Exporter); 
@EXPORT = qw(printhash printarray loadconfig pinghost);


# in: hash reference
# out:NONE, just print
sub printhash {
    my $hash=shift;
    my %h=%$hash;
    foreach (sort keys %h){
        print "\nkey=[$_] value=[$h{$_}]";
    }
}

sub printarray {
    my $arrey=shift;
    my @a=@$array;
    foreach (sort  @a){
        print "\n value=[$_]";
    }
}


# readconfig : input: a key=value pair config file
sub readconfig{
	my $configfile=shift; 
	my %c; 
	if (open(CONFIG,$configfile)){ 
		print "\nloading configruation fle [$configfile] ...";
		my @con= <CONFIG>;
		foreach my $line (@con){ 
			chomp($line);
			# the basic format of config file would be: position = name ; sample data 0=version
			next if $line=~ m/^#/;	# ignore commends line ==> starts with "#" char
			next if $line=~ m/^\s*$/;	# ignore empty lines
			next if $line=~ m/^\[/;	# ignore lines such as [system]
			my @pair = split(/=/,$line);
			$pair[0] =~s/ //g; # replace " " - white space with nothing, which means delete all white space
			$pair[1] =~s/ //g; 
			$c{$pair[0]} = $pair[1]; 
			#print $pair[0];
			#print $pair[1];
		}
		print " done \n";
		close CONFIG;
	}else{
		print "\nfile [$configfile] can not open ";
	}
	return \%c; 
}#readconfig

##############################
#     network utilities      #
##############################
sub pinghost{
	# input: ($host, $port)
	# output: return 1 if remote host active on given port, otherwise, return 0
	my ($host, $port)= @_; 
	my $return = 0;
	#  Try to connect
	my $remote = IO::Socket::INET->new(
    	Proto    => "tcp",
    	PeerAddr => $host,
    	PeerPort => $port,
    	Timeout  => 8,
	);
	# verify response
	if ($remote) {
    	# print "$host is alive\n";
    	close $remote;
    	$return = 1;
	} 
	return $return;
}

1;

