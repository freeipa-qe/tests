#!/usr/bin/perl
#
use strict;
use warnings;
use Getopt::Std;
use Date::Parse;
use Net::LDAP;
require "certfunctions.pl";

our %options=();
getopts("n:p:f:s:", \%options);

our @output;
our %certs;
our $theCert;
our $nickname;
our $outputfile;
our $status;

##### ldap ###############
our $ldap;
our $connection;
our $dn="cn=directory manager";
our $password="Secret123";
our @attrs=("cn","userCertificate");
our $base="cn=ca_renewal,cn=ipa,cn=etc,dc=yzhang,dc=redhat,dc=com";
our $host=`hostname`;
chop $host;

$ldap = Net::LDAP->new ($host) or die "$@";
$connection = $ldap->bind ("$dn", password=>$password, version=>3);
#LDAPsearch ($ldap,$searchString,$attrs,$base) = @_;
LDAPsearch($ldap,"objectclass=*",\@attrs,$base);

##### parse command line options #######################

if (defined $options{"n"} ){
    $nickname= $options{"n"};
    #$theCert = findValidCert($nickname);
    $theCert = findPreValidCert($nickname);
}else{
    exit 1;
}

if (defined $options{"s"} ){
    $status = $options{"s"};
    $theCert = findCert($nickname,$status);
}else{
    $theCert = findPreValidCert($nickname);
}

if (defined $options{"f"} ){
    $outputfile= $options{"f"};
    printCertToFile($theCert, $outputfile);
}else{
    # when no -f given, output to standard output (terminal)
    printCert($theCert);
}

