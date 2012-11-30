#!/usr/bin/perl
#
#

use strict;
use warnings;
use Getopt::Std;
use Date::Parse;

our %options=();
getopts("d:n:p:f:", \%options);

our $certutil="/bin/certutil";
our $cert_dbdir;
our $cert_nickname;
our @cert_nicknamelist;
our %certs;
our $theCert;
our $property_name;
our $property_value;
our $property_separator;
our $cert_outputfile;

# check -d user input
if (defined $options{"d"} ){
    $cert_dbdir = $options{"d"};
    if (! -d $cert_dbdir){
        print "Cert directory [$cert_dbdir] not exist\n";
        exit 1;
    }elsif (! -r $cert_dbdir){
        print "Cert directory [$cert_dbdir] not readable\n";
        exit 1;
    }
}else{
    print "Cert directory required, use -d <dir>\n";
    exit 1;
}

# check -n user input
findAllNickname();

if (defined $options{"n"} ){
    $cert_nickname= $options{"n"};
    if (! grep /$cert_nickname/, @cert_nicknamelist){
        print "Nickname [$cert_nickname] not found\n";
        printAllCertNickname();
        exit 1;
    }else{
        parseCertDetails();
        $theCert = findValidCert($cert_nickname);
    }
}else{
    print "Cert nickname is required, use -n <nick name>\n";
    printAllCertNickname();
    exit 1;
}

if (defined $options{"p"} ){
    $property_name = $options{"p"};
    $property_value = "";
    if (%certs){
        foreach (sort keys %certs){
            my $cert = $certs{$_};
            setCertStatus($cert);
            setCertLifeLeft($cert);
            next if (! isValid($cert));
            if (exists $cert->{$property_name}){
                $property_value .= $cert->{$property_name}. ",";
                last;
            }
        }
    }
    # print property value if -p is given, regardless of -f
    chop $property_value;
    print "$property_value\n"; 
}else{
    if (defined $options{"f"} ){
        $cert_outputfile= $options{"f"};
        printCertToFile($theCert, $cert_outputfile);
    }else{
        printCert($theCert);
    }
}

#########################################
##           subroutine                  #
##########################################

sub trim{
    my $input = shift;
    $input =~ s/^([\t|\s])*//g;
    $input =~ s/([\t|\s])*$//g;
    return $input;
}

sub findAllNickname{
    my $cmdoutput = `$certutil -L -d $cert_dbdir`;
    my @lines = split(/\n/,$cmdoutput);
    foreach my $line (@lines){
        if ($line =~ /^(.*)\s+(\w*,\w*,\w*)$/){
            my $nickname=trim($1);
            print "found nickname [$nickname]\n";
            push @cert_nicknamelist, $nickname;
        }
    }
}

sub printAllCertNickname{
    if ($#cert_nicknamelist >= 0){
        print "nicknames in $cert_dbdir\n";
        foreach (@cert_nicknamelist){
            print "$_\n";
        }
    }
}

sub parseCertDetails{
    my $cmdoutput = `$certutil -L -d $cert_dbdir -n "$cert_nickname"`;
    my @lines = split(/\n/,$cmdoutput);
    my $flag=0;
    my $key=""; 
    my $value="";
    my %currentCert;
    foreach my $line (@lines){
        if ($line =~ /^Certificate:$/){
            if (%currentCert){
                my $serial = $currentCert{"serial"};
                $currentCert{"certdb"} = $cert_dbdir;
                $currentCert{"nickname"} = $cert_nickname;
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
        $currentCert{"certdb"} = $cert_dbdir;
        $currentCert{"nickname"} = $cert_nickname;
        $certs{$serial} = \%currentCert;
    }
}

sub printCert{
    my ($cert) = shift;
    if (ref($cert) eq "HASH"){
        foreach (keys %$cert){
            my $key = $_;
            $key = sprintf ("%-18s",$key);
            print "$key: ".$cert->{$_}."\n";
        }
    }}

sub printAllCerts{
    if (%certs){
        foreach (sort keys %certs){
            print "cert# ($_)\n";
            my $cert= $certs{$_};
            printCert($cert);
        }
    }
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
    #my $years = int($time / (86400*365) ); 
    #$time -= ($years * 86400 * 365); 
    my $days = int($time / 86400); 
    $time -= ($days * 86400); 
    my $hours = int($time / 3600); 
    $time -= ($hours * 3600); 
    my $minutes = int($time / 60); 
    my $seconds = $time % 60; 
  
    #$years = $years < 1 ? '' : $years .' Y '; 
    $days = $days < 1 ? '' : $days .' D '; 
    $hours = $hours < 1 ? '' : $hours .' h '; 
    $minutes = $minutes < 1 ? '' : $minutes . ' m '; 
    #$time = $prefix.$years. $days . $hours . $minutes . $seconds . ' s'. $suffix; 
    $time = $prefix.$days.$hours.$minutes.$seconds.' s'.$suffix; 
    return $time; 
}

sub findCert{
    my ($nickname,$status)=@_;
    if (%certs){
        foreach (sort keys %certs){
            my $cert = $certs{$_};
            setCertStatus($cert);
            if ($cert->{"nickname"} eq $nickname
               && $cert->{"status"} eq $status ){
                setCertLifeLeft($cert);
                return $cert;
            }
        }
    }
}

sub findPreValidCert{
    my $nickname=shift;
    my $status="preValid";
    return findCert($nickname,$status);
}

sub findValidCert{
    my $nickname=shift;
    my $status="valid";
    return findCert($nickname,$status);
}

sub findExpiredCert{
    my $nickname=shift;
    my $status="expired";
    return findCert($nickname,$status);
}

sub printCertToFile{
    my ($cert, $output) = @_;
    if (ref($cert) eq "HASH"){
        if (! open OUT, ">$output"){
            return;
        }
        setCertStatus($cert);
        setCertLifeLeft($cert);
        foreach (sort keys $cert){
            my $key = $_;
            print OUT $key."=".$cert->{$_}."\n";
        }
        close OUT;
    }
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
