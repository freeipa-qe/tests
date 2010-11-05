#!/usr/bin/perl

use warnings;
#use strict;

# file : parser.pl
#     parsing all schema file and save into db
# date : Jan. 6, 2010
# by   : yzhang@redhat.com

our $base=".";
our $standardDir="$base/standard";
our $db="$base/db";
our $formatted="$base/formatted";

our (%attributeTypes , %objectClasses) ;
our (%attr_name, %attr_numericoid, %attr_desc, %attr_sup, %attr_equality, %attr_ordering, %attr_substr, %attr_syntax, %attr_usage, %attr_extensions);
our (%obj_name, %obj_numericoid, %obj_desc, %obj_sup, %obj_may, %obj_must, %obj_extensions);

print "\nparser starts...";

# format the file for future parsing
if (opendir (DIR, $standardDir)){
    while (my $schemafile = readdir(DIR)){
        if ($schemafile =~/\.ldif$/){
            formatfile("$standardDir/$schemafile", "$formatted/$schemafile");
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
    # save to db -- currently use file as data holder
    savetodb ("$db/attributeTypes.txt", \%attributeTypes);
    savetodb ("$db/objectClasses.txt", \%objectClasses);
} else {
    print "[$standardDir] ERROR";
}
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

sub savetodb {
    my ($dbfile,$data)=@_;
    if (! open (FILE, ">$dbfile")){
        print "\n error, can not write to file, return";
        return;
    }
    if (ref($data) eq "ARRAY"){
    # save array type to file, each line for each element
        foreach my $value (@$data){
            print FILE $value;
            print FILE "\n";
        }
    }
    if (ref($data) eq "HASH"){
    # save hash type to file, each line using format: key=value
        my %hash = %$data;
        foreach my $key (sort keys %hash){
            print FILE $key."=".$hash{$key};
            print FILE "\n";
        }
    }
    print "\nSave to [$dbfile] done";
    close FILE;
}#end of savetodb
