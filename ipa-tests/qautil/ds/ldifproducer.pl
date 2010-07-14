#!/usr/bin/perl
# filename: ldifproducer.pl
# used for automatic data genaration, used for sasl stress testing. 
# notes:  users are under suffix of: dc=example,dc=com

use warnings;
use strict ;

# Usage: ldifproducer.pl <output file name> <total records desired>
# default output filename: test.ldif
# default record number: 999

# command line options
our $total=999;
our $output="data.$total.ldif"; 

if($#ARGV == 0){
	$output=$ARGV[0]; 
} 
if($#ARGV == 1){
	$output=$ARGV[0]; 
	$total=$ARGV[1]; 
} 

print "\nstarts... create $total entries in $output file ...";
##########
# GLobal #
##########

if (!(open (OUT, ">$output"))){
	#print "can not open output file [$output]";
	print 0;
	exit;
}
our $len=length($total);
our $root=qq(# define the top
dn: dc=example,dc=com
objectClass: top
objectClass: domain
dc: example

dn: ou=people,dc=example,dc=com
objectClass: top
objectClass: organizationalunit
ou: people);

print OUT $root;

# define entry for members in group A
for my $i (1..$total){
	my $id=sprintf("%0${len}d", $i);
	my $nextid;
	if ($id == $total){
		$nextid=1;
	}
	else{
		$nextid=$id+1;
	}
	$nextid=sprintf("%0${len}d", $nextid);
	#my $id="$i";
	print OUT "\n\ndn: uid=test.".$id.",ou=people,dc=example,dc=com";
	print OUT "\ncn: test.".$id;
	print OUT "\nsn: ".$id;
	print OUT "\nuid: test.".$id;
	print OUT "\nmail: test".$id."\@example.com";
	print OUT "\npostalAddress: test.".$id;
	print OUT "\nobjectclass: top";
	print OUT "\nobjectclass: person";
	print OUT "\nobjectclass: inetorgperson";
	print OUT "\nuserpassword: redhat"; 
	#print OUT "\nsecretary: uid=ref.".$nextid.",ou=people,dc=example,dc=com"; 
}

close OUT;
# the output "1" will be callected by caller
print "done\n";
print 1;

