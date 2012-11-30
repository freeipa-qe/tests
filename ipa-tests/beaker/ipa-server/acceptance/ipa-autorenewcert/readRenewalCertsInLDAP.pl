#!/usr/bin/perl
#
use strict;
use warnings;
use Getopt::Std;
use Date::Parse;
use Net::LDAP;

our %options=();
getopts("n:p:f:", \%options);

our @output;
our %certs;
our $certRef;
our $cert_nickname;
our $cert_outputfile;

##### ldap ###############
our $ldap;
our $host=`hostname`;
chop $host;
our $connection;
our $dn="cn=directory manager";
our $password="Secret123";
our $suffix="dc=yzhang,dc=redhat,dc=com";

$ldap = Net::LDAP->new ($host) or die "$@";
$connection = $ldap->bind ("$dn", password=>$password, version=>3);
my $base="cn=ca_renewal,cn=ipa,cn=etc,$suffix";
my @attrs=("cn","userCertificate");
LDAPsearch ($ldap,"objectclass=*",\@attrs,$base);

##### parse command line options #######################

if (defined $options{"n"} ){
    $cert_nickname= $options{"n"};
    $certRef = findCert($cert_nickname);
}else{
    usage();
    exit 1;
}
if (defined $options{"f"} ){
    $cert_outputfile= $options{"f"};
    printCertToFile($certRef, $cert_outputfile);
}else{
    # when no -f given, output to standard output (terminal)
    printCert($certRef);
}

##########################################
#           subroutine                   #
##########################################
sub usage{
    print "\nreadRenewalCertsInLDAP.pl -n <cert nick name> -f <out put file>\n";
}

sub LDAPsearch{
    my ($ldap,$searchString,$attrs,$base) = @_;
    if (!$attrs ) { 
        $attrs = [ 'cn','userCertificate' ]; 
    }

    my $result = $ldap->search ( 
                    base    => "$base",
                    scope   => "sub",
                    filter  => "$searchString",
                    attrs   =>  $attrs
                    );
    my $href = $result->as_struct;
    my @arrayOfDNs  = keys %$href;        # use DN hashes
    foreach ( @arrayOfDNs ) {
        next if ( $_ =~ /^cn=ca_renewal/ );
        print "found renewal cert DN [$_] \n";
        my $valref = $$href{$_};
        my @arrayOfAttrs = sort keys %$valref; #use Attr hashes
        my $attrName;        
        my $nickname;
        foreach $attrName (@arrayOfAttrs) {
            next if ( $attrName =~ /;binary$/ );
            my $attrVal =  @$valref{$attrName};
            if ($attrName =~ /cn/i){
                $nickname = @$attrVal[0];
            }
            if ($attrName =~ /userCertificate/i){
                my $derfile="/tmp/cert.".rand().".der";
                my $certfile="$derfile".".cert";
                if (saveAsFile($certfile,$derfile, @$attrVal)){
                    #print "\t $attrName: der file: [$derfile], cert file [$certfile]\n";
                    parseCertDetails($nickname, $certfile);
                }
            }else{
                #print "\t $attrName: @$attrVal \n";
            }
        }
        #print "#-------------------------------\n";
    }
}


sub saveAsFile{
    my ($certfile,$derfile,@content) = @_;
    if (open PKCS12,">$derfile"){
        foreach (@content){
            print PKCS12 $_;
        }
        close PKCS12; 
        my $certDetail=`openssl x509 -inform der -in $derfile -text > $certfile`;
        return 1;
    }else{
        print "can not open file [$derfile] to write\n";
        return 0;
    } 
}

sub parseCertDetails{
    my ($nickname, $certfile)= @_;
    open CERT,"<$certfile";
    my @lines = <CERT>;
    close CERT;
    my $flag=0;
    my $key=""; 
    my $value="";
    my %currentCert;
    foreach my $line (@lines){
        if ($line =~ /^Certificate:$/){
            if (%currentCert){
                $currentCert{"nickname"} = $nickname;
                my $serial = $currentCert{"serial"};
                my %copy = %currentCert;
                $certs{$serial} = \%copy;
            }
            next;
        }
        if ($line =~ /Serial Number:\s*(\d+)\s*/){
           $currentCert{"serial"} = trim($1); 
           next;
        }
        if ($line =~ /Issuer: "(.*)"/){
            $currentCert{"issuer"} = trim($1); 
            next;
        }
        if ($line =~ /Subject: "(.*)"/){
            $currentCert{"subject"} = trim($1); 
            next;
        }
        if ($line =~ /Not Before:(.*)$/){
            my $date = trim($1);
            my $epoch = str2time($date);
            #my $d = localtime($time); # this is to convert it back to local time so I know this is epoch time
            $currentCert{"NotBefore"}="$date";
            $currentCert{"NotBefore_sec"}="$epoch";
            $currentCert{"Life"} = $epoch;
            next;
        }
        if ($line =~ /Not After :(.*)$/){
            my $date = trim($1);
            my $epoch = str2time($date) + 0;
            $currentCert{"NotAfter"}="$date";
            $currentCert{"NotAfter_sec"}="$epoch";

            my $cert_life_insecond = $epoch - $currentCert{"Life"};
            my $cert_life_str = convert_time ($cert_life_insecond);
            $currentCert{"Life"} = $cert_life_str;
            $currentCert{"Life_sec"} = $cert_life_insecond;

            my $now = localtime;
            my $time_epoch_now = str2time($now);
            if ($time_epoch_now > $epoch){
                $currentCert{"status"} = "exipred";
            }else{
                $currentCert{"status"} = "valid";
            }

            my $time_left_str = convert_time($epoch - $time_epoch_now);
            $currentCert{"LifeLeft"} = $time_left_str;
            next;
        }
        if ($line =~ /Fingerprint \(SHA1\)/){
            $flag=1;
            $key = "Fingerprint SHA1";
            next;
        }
        if ($flag && $key ne "" ){
            $value = trim ($line);
            $currentCert{$key} = $value;
            $key="";
            $value="";
            $flag = 0;
            next;
        }
    }
    if (%currentCert){
        my $serial = $currentCert{"serial"};
        $currentCert{"nickname"} = $nickname;
        $certs{$serial} = \%currentCert;
    }
}

sub printAllCerts{
    if (%certs){
        foreach (sort keys %certs){
            print "cert# ($_)\n";
            my $certRef = $certs{$_};
            foreach (sort keys %$certRef){
                my $key = $_;
                $key = sprintf ("%-18s",$key);
                print "\t".$key.": ".$certRef->{$_}."\n";
            }
        }
    }
}

sub findCert{
    my $nickname=shift;
    if (%certs){
        foreach (sort keys %certs){
            my $certRef = $certs{$_};
            #if (   $certRef->{"nickname"} eq $cert_nickname 
            #    && $certRef->{"status"} eq "valid" ){
            if ($certRef->{"nickname"} eq $cert_nickname ){
                print "cert [$nickname] found\n";
                return $certRef;
            }
        }
    }
}

sub printCertToFile{
    my ($certRef, $output) = @_;
    if (ref($certRef) eq "HASH"){
        if (! open OUT, ">$output"){
            return;
        }
        foreach (sort keys $certRef){
            my $key = $_;
            print OUT $key."=".$certRef->{$_}."\n";
        }
        close OUT;
        print "save to [$output] success\n";
    }
}

sub printCert{
    my ($certRef) = shift;
    if (ref($certRef) eq "HASH"){
        my %cert = %$certRef;
        foreach (sort keys %cert){
            my $key = $_;
            $key = sprintf ("%-18s",$key);
            print $key."= ".$cert{$_}."\n";
        }
    }
}

sub trim{
    my $input = shift;
    $input =~ s/^([\t|\s])*//g;
    $input =~ s/([\t|\s])*$//g;
    return $input;
}

sub convert_time { 
    # this function is from: http://neilang.com/entries/converting-seconds-into-a-readable-format-in-perl/
    # my change: add years
    my $time = shift; 
    my $prefix="";
    my $suffix="";
    if ($time < 0){
        $prefix="Expired ";
        $suffix=" ago";
        $time = abs($time);
    }
    my $years = int($time / (86400*365) ); 
    $time -= ($years * 86400 * 365); 
    my $days = int($time / 86400); 
    $time -= ($days * 86400); 
    my $hours = int($time / 3600); 
    $time -= ($hours * 3600); 
    my $minutes = int($time / 60); 
    my $seconds = $time % 60; 
  
    $years = $years < 1 ? '' : $years .' year,'; 
    $days = $days < 1 ? '' : $days .' day,'; 
    $hours = $hours < 1 ? '' : $hours .' hour,'; 
    $minutes = $minutes < 1 ? '' : $minutes . ' minutes,'; 
    $time = $prefix.$years. $days . $hours . $minutes . $seconds . ' second'. $suffix; 
    return $time; 
}

sub setCertLifeLeft{
    my $cert=shift;
    my $now = localtime;
    my $time_epoch_now = str2time($now);
    my $notafter=$cert->{"NotAfter_sec"}+0;
    my $time_left = $notafter - $time_epoch_now;
    my $time_left_str = convert_time($time_left);
    $cert->{"LifeLeft_sec"} = $time_left;
    $cert->{"LifeLeft"} = $time_left_str;
}

sub setCertStatus{
    my $cert=shift;
    my $now = localtime;
    my $time_epoch_now = str2time($now);
    my $notbefore=$cert->{"NotBefore_sec"}+0;
    my $notafter=$cert->{"NotAfter_sec"}+0;
    if ($time_epoch_now < $notbefore){
        $cert->{"status"} = "preValid";
    }elsif ($notbefore <= $time_epoch_now && $time_epoch_now <= $notafter){
        $cert->{"status"} = "valid";
    }else{ 
        $cert->{"status"} = "exipred";
    }  
    #print "debug: set cert [".$cert->{"nickname"}." status to :".$cert->{"status"}."\n";
}

sub isValid{
    my $cert=shift;
    setCertStatus($cert);
    if ($cert->{"status"} eq "valid" ){
        return 1;
    }else{
        return 0;
    }
}
