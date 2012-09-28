#!/usr/bin/perl
# by yi zhang 
# @ 9/27/2012
#
use strict;
use warnings;


our %autofs;
our %autofsMap;
our $location="yztest001";

if ($#ARGV==0){
    $location = $ARGV[0];
    #print "Checking ipa automount location [$location] information\n";
}else{
    print "Usage: read.pl <ipa automount location name>\n";
    exit;
}
our $output=`ipa automountlocation-tofiles $location`;
#print "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
#print "$output";
#print "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";

parseAutofsFiles($output);
#printAutofsConf();
readAutofsMaster();
printAutofsMap();

print "\n";

############### subroutine #################

sub parseAutofsFiles{
    my ($output) = shift;
    $output="\n$output";
    my @lines=split(/\n/,$output);
    my $currentKey="";
    my $currentContent="";

#    open (IPA, "ipa automountlocation-tofiles $location |") || die "Command failed $!\n";
#    @lines = <IPA>;
    foreach my $line (@lines){
        $line =~ s/\n//;
        next if $line =~ /^\s*$/ ;
        next if $line =~ /maps not connected to/; # hard code is ok here
        #print "\n\tparse line [$line]";
        $line = replaceSpecialChars($line);

        if ($line =~ /^\/etc\/auto.(\w+){1}:$/){
            $currentKey = "auto.$1";
            #print " Found autofs conf :[$currentKey]";
        }elsif ($line =~ /^(-+)$/){
            #print " ignore it ---";
            $autofs{$currentKey} = $currentContent;
            $currentKey="";
            $currentContent="";
        }else{
            #print " at else [$line]";
            $currentContent = "$currentContent\n$line";
        }
    }
    # there is always exact one left over
    $autofs{$currentKey} = $currentContent;
    #print " ... Parse autofs finished";
}

sub readAutofsMaster{
    my $autoMaster = "auto.master";
    my $autoMasterContent = $autofs{$autoMaster};
    my @content = split (/\n/,$autoMasterContent);
    foreach my $configuration (@content){
        next if ( ($configuration =~ /^\s*$/) || ($configuration =~ /^#/) );
        my @map = split(/\s+/,$configuration);
        my $absolutePath = $map[0];
        my $configFile   = $map[1];
        #print "\n[$configFile] contains configuration for path [$absolutePath], now parse it...";
        if ($configFile =~ /^\/etc\/auto.(\w+){1}$/){
            my $key= "auto.$1";
            if (exists $autofs{$key}){
                my $value = $autofs{$key};
                next if ( ($value =~ /^\s*$/) || ($configuration =~ /^#/) );
                my @level2mapping = split(/\s/,$value);
                my $subPath = $level2mapping[1];
                my $remotePath = $level2mapping[$#level2mapping];
                my $localPath = $absolutePath. "/". $subPath;
                #print "\n   Final map: local [".$localPath."] map to remote: [". $remotePath. "]";
                $autofsMap{$localPath} = $remotePath;
            }
        }
    }
}

sub printAutofsConf{
    foreach my $conf (keys %autofs){
        print "\n[$conf]    [".$autofs{$conf}."]";
    }
}

sub printAutofsMap{
    foreach my $local (keys %autofsMap){
        print "\n[$local]-->[".$autofsMap{$local}."]";
    }
}

sub printCharsInString{
    my ($string) = shift;
    my @chars = split(//,$string);
    foreach my $c (@chars){
        print "{$c (".ord($c).")} ";
    }
}

sub replaceSpecialChars{
    my $string = shift;
    #print "\nInput :::::";
    #printCharsInString($string);
    my $header = substr($string,0,8);
    #print "\nHeader:::::";
    #printCharsInString($header);
    if ($header =~ /\[?1034h/){
        $string = substr($string,8);
    }
    return $string;
    #print "\nOutput:::::";
    #printCharsInString($string);
    #print "\n";
}
