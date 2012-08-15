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
our $certRef;
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
        $certRef = findCert($cert_nickname);
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
            my $certRef = $certs{$_};
            # FIXME: big problem here, valid vs invalid
            #if ($certRef->{"status"} eq "valid" && exists $certRef->{$property_name}){
            if (exists $certRef->{$property_name}){
                $property_value .= $certRef->{$property_name}. ",";
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
        printCertToFile($certRef, $cert_outputfile);
    }else{
        printCert($certRef);
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
            #print "found nickname [$nickname]\n";
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
        $currentCert{"certdb"} = $cert_dbdir;
        $currentCert{"nickname"} = $cert_nickname;
        $certs{$serial} = \%currentCert;
    }
}

sub printCert{
    my ($certRef) = shift;
    if (ref($certRef) eq "HASH"){
        foreach (keys %$certRef){
            my $key = $_;
            $key = sprintf ("%-18s",$key);
            print "$key: ".$certRef->{$_}."\n";
        }
    }
}

sub printAllCerts{
    if (%certs){
        foreach (sort keys %certs){
            print "cert# ($_)\n";
            my $certRef = $certs{$_};
            printCert($certRef);
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

sub findCert{
    my $nickname=shift;
    if (%certs){
        foreach (sort keys %certs){
            my $certRef = $certs{$_};
            #FIXME: the status=valid need some work here
            #if (   $certRef->{"nickname"} eq $cert_nickname 
            #    && $certRef->{"status"} eq "valid" ){
            if ($certRef->{"nickname"} eq $cert_nickname){
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
    }
}
