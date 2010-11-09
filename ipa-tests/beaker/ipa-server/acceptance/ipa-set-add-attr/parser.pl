#!/usr/bin/perl

use warnings;
#use strict;

# file : parser.pl
#     parsing all schema file and save into db
# date : Nov. 5, 2010
# by   : yzhang@redhat.com

our $schemaDir="/etc/dirsrv/schema";
our $outdir="./";

if ($#ARGV == -1){
    print "\nUsing default ...";
    print "\nSchema dir : $schemaDir";
    print "\noutput dir : $outdir";
}elsif ($#ARGV == 0){
    $schemaDir=$ARGV[0];
}elsif ($#ARGV == 1){
    $schemaDir=$ARGV[0];
    $outdir=$ARGV[1];
}else {
    print "\nargs=$#ARGV";
    print "\nUsage: schemaparser.pl <schema dir> <output file>";
    print "\nDefault schema dir : $schemaDir";
    print "\nDefault output dir : $outdir";
    exit 0;
}


our $formatted="";
createtmp();

our (%attributeTypes , %objectClasses) ;

print "\nSchema parser starts...";

# format the file for future parsing
if (opendir (DIR, $schemaDir)){
    while (my $schemafile = readdir(DIR)){
        if ($schemafile =~/\.ldif$/){
            formatfile("$schemaDir/$schemafile", "$formatted/$schemafile");
        }
    }
}#format file

# open schema file to read - or exit program if not be able to read
if (opendir (DIR,$formatted) ){ 
    while (my $schemafile = readdir(DIR)){
        # only .ldif file will be parsed
        if ($schemafile =~/\.ldif$/){
            parsefile ("$formatted/$schemafile");
        }
    }
    close DIR;

    print "\n\n------- attributeTypes ---------------------------";
    printhash (\%attributeTypes);
    print "\n\n------- objectClass---------------------------";
    printhash (\%objectClasses);

    # save to outfile
    saveto("$outdir/attributeTypes.txt", \%attributeTypes);
    saveto("$outdir/objectClasses.txt", \%objectClasses);
} else {
    print "[$schemaDir] ERROR";
}

deletetmp();
print "\nend of programm\n";
#end of main


#########################################
#    sub routine 
#########################################
sub parsefile {
    my ($schemafile) = shift;
    if (open(SCHEMA,"<$schemafile"))
    {
        print "\nreading [$schemafile]...";
    }else{
        print "\ncannot read [$schemafile],exit";
        return;
    }

    # parsing starts
    while (<SCHEMA>){
        my ($line)=$_;
        chomp $line;
        parseline($line);
    }
    # close schema file at end of parsing
    close SCHEMA;
    print " done. file closed";
}# end of parsefile

sub parseline {
    # str has following format:
    # attributetypes: ( 2.16.840.1.113730.3.1.601 NAME 'adminRole' DESC 'Administrative role' SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 X-ORIGIN 'Netscape Delegated Administrator' )
    # objectclasses: ( 2.5.6.6 NAME 'person' SUP top STRUCTURAL MUST ( sn $ cn ) MAY ( userPassword $ telephoneNumber $ seeAlso $ description ) X-ORIGIN 'RFC 4519' )
    my $str=shift;
    my %hash;
    my $name;
    print "\nParsing :[$str]";
    if ($str =~ m/\(\s*([\d|\.]+)\s/){
        my $s=$1;
        $hash{"numericoid"}=$s;
    }
    if ($str =~ m/ NAME\s+\'([\w|-]+)\' /){
        #print " 1=[$1], 2=[$2] 3=[$3] 4=[$4] 5=[$5]";
        $name=$1;
        $hash{"name"}=$name;
        print " name=[$name]";
    }    
    if ($str =~ m/ NAME \( \'([\w|-]+)\' \'([\w|-]+)\' \)/){
        #print " 1=[$1], 2=[$2] 3=[$3] 4=[$4] 5=[$5]";
        $name="$1 $2";
        $hash{"name"}="$name";
        print " name=[$name]";
    }    
    if ($str =~ m/ NAME \( \'([\w|-]+)\' \)/){
        #print " 1=[$1], 2=[$2] 3=[$3] 4=[$4] 5=[$5]";
        $name="$1";
        $hash{"name"}="$name";
        print " name=[$name]";
    }    
    if ($str =~ m/ DESC \'([\w| ]+)\' /){
        $hash{"desc"}=$1;
    }
    if ($str =~ m/ SUP (\w+) /){
        $hash{"sup"}=$1;
    }
    if ($str =~ m/ SINGLE-VALUE/){
        $hash{"valueType"}="single-value";
    }
    if ($str =~ m/ X-ORIGIN \'(.+)\'/){
        my $s="X-ORIGIN \'$1\'";
        $hash{"x-orgin"}=$1;
    }
    if ($str =~ m/ EQUALITY (\w+) /){
        $hash{"equality"}=$1;
    }
    if ($str =~ m/ ORDERING (\w+) /){
        $hash{"ordering"}=$1;
    }
    if ($str =~ m/ SUBSTR (\w+) /){
        $hash{"substr"}=$1;
    }
    if ($str =~ m/ SYNTAX ([\d|\.]+) \w+/){
        $hash{"syntax"}=$1;
    }    
    if ($str =~ m/ USAGE ([\d|\.]+) \w+/){
        $hash{"usage"}=$1;
    }    
    if ($str =~ m/ MAY \({1}([\s|\w|\$]+)\){1} /){
        $hash{"may"}=$1;
    }
    if ($str =~ m/ MUST \({1}([\s|\w|\$]+)\){1} /){
        $hash{"must"}=$1;
    }
    if (! defined $hash{"valueType"}){
        $hash{"valueType"}="multi-value";
    }
    if ($str =~ m/attributeTypes/i){
        $attributeTypes{$name}=\%hash;
    }elsif ($str =~ m/objectClasses/i){
        $objectClasses{$name}=\%hash;
    }
    else{
        print "\n===format error, skip this line================";
        print "\n$str";
        print "\n=================================\n";
    }
}# parseline

sub formatfile {
    my ($in, $out)=@_;
    print "\n============================================";
    print "\n| $in ==> $out";
    print "\n============================================";
    if (! open (INPUT, "$in")){
        print "\nCan not read input file [$in]";
        return;
    }
    if (! open (OUTPUT, ">$out")){
        print "\nCan not write to output file [$out]";
        return;
    }
    #formatting starts here
    my $longline="";
     while (<INPUT>){
        my ($line)=$_;
        next if $line =~ /^#/;
        chop $line;
        if ( ($line =~ m/^objectclasses:/i ) || ( $line =~ m/^attributetypes:/i ) ){
            if ( $longline eq ""){
                print "\nHeader:[$line]";
                $longline="$line";
            }else{
                print OUTPUT "$longline"."\n";
                print "\nsave line=[$longline]"."\n";
                $longline = "$line";
                print "\nHeader:[$line]";
            }
            $longline="$line"; #reset
        }elsif ( $line =~ m/^dn/ ){
            print "\nIngnore: [$line]"
        }else{
            print "\n\tAppend [$line]";
            print "\n\tcurrent Line:[$longline]";
            $longline .= $line;
        }#
    }
    #formatting ends here
    # before we close the file, we might still have some data holds at $longline, check it
    if ( $longline ne ""){
        print "\nLast line to write: [$longline]";
        print OUTPUT "$longline";
    }
    close INPUT;
    close OUTPUT;
}#formatfile

sub printhash {
    my $h = shift;
    my %hash = %$h;
    my @keys = keys %hash;
    print "\ntotal [".$#keys."] values";
    foreach my $key (sort keys %hash){
        print "\n=========== hash key [$key]===========";
        my $tmphash=$hash{$key};
        my %content = %$tmphash;
        foreach my $k (sort keys %content){
            print "\n[$k]=>[$content{$k}]";
        }
        print "\n=====================================\n";
    }
}

sub saveto {
    my ($dbfile,$h)=@_;
    if (! open (FILE, ">$dbfile")){
        print "\n error, can not write to file, return";
        return;
    }

    my %hash = %$h;
    my @keys = keys %hash;
    print "\ntotal [".$#keys."] values";
    foreach my $key (sort keys %hash){
        print FILE "\n[$key]";
        my $tmphash=$hash{$key};
        my %content = %$tmphash;
        foreach my $k (sort keys %content){
            print FILE "\n [$k] ==> [$content{$k}]";
        }
        print FILE "\n";
    }

    print "\nSave to [$dbfile] done";
    close FILE;
}#end of savetodb

sub createtmp{
    my $num=int(rand() * 10000 );
    my $dirname="/tmp/formatted".$num;
    if (! -d $dirname ){
        mkdir ($dirname, 0777) || die $!;
        $formatted=$dirname;
        print "\ncreate temp dir [$formatted]";
    }else{
        print "\nCan not make temp dir";
        exit 0;
    }
} #createtmp

sub deletetmp{
    if ( -d $formatted){
        system ("rm -rf $formatted");
        print "\nremove temp dir [$formatted]";
    }
}# deletetmp
