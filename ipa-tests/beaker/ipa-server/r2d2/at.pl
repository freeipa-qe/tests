#!/usr/bin/perl
#File: at.pl
#Date: Nov 18, 2010
#By  : Yi Zhang <yzhang@redhat.com>
#
#       at.pl is used to automate the test case writing for ipa test automation
#       it read input file: <ipafeature.at.conf>
#       and outpt standard type test script including data file
#

use strict;
use warnings;

our $ipacmd;
our @subcmds;
our $tempint=int(rand()*1000);
our %understanding;

# command line argument parse
our $totalArgs=$#ARGV;
if ($totalArgs == 0) {
    $ipacmd=$ARGV[0];
}else{
    usage();
    exit;
}

print "\nat.pl starts...";


our $cmd="ipa help $ipacmd";
our $out=`$cmd`;
@subcmds=parseIPAcmd ($out);
foreach my $subcmd (@subcmds){
    my %subunderstanding;
    print "\nfound ipa command: [$subcmd], parsing ...";
    my $o = `ipa help $subcmd`;
    my @opts=parseIPASUBcmd($o);
    $subunderstanding{"cmd"} = $subcmd;
    $subunderstanding{"alloptions"} = \@opts;
    foreach my $opt (@opts){
        my %optProperty;
        %optProperty = parseOption($opt);
        my $optkey = $optProperty{"body"};
        print "\nSave optkey:[$optkey]";
        if (exists $subunderstanding{"eachoption"}){
            my $optionhash_tmp = $subunderstanding{"eachoption"};
            my %optionhash = %$optionhash_tmp ;
            $optionhash{"$optkey"} = \%optProperty;         # store new option into hashtable
            $subunderstanding{"eachoption"} = \%optionhash; # then save this new hashtable back to master
            print "\nSave(second) [$optkey]";
        }else{
            print "\nSave(firsttime) [$optkey]";
            my %optionhash;
            $optionhash{"$optkey"}=\%optProperty;
            $subunderstanding{"eachoption"} = \%optionhash;
        }
        #$subunderstanding{"$opt"} = \%optProperty;
    }# parsing the option to read option and its property
    $understanding{$subcmd} = \%subunderstanding;
}
print "\nparsing finished";
print "\n--------- my understanding -------------";
printIPAcmd(\%understanding);
print "\n--------- end of my understanding ------";
print "\nEnd of at.pl\n";

##################
# notes from yi  #
##################
# 1. test case should have "id" attach to it. ID could be strings, such as ipaconfig_search_limit
# 2. Once we have id, we can then sync between actual script and the script generator
# 3. "at.pl" should have the ability to "sync" between test case descript file and test case script 
# 4. use file system as storage
# 5. Syncing: "test case description" <--> "test script"
#            Idealy, one can write "test case description" and "at.pl" can understand it and transfer it to test script. At same time, "at.pl" can read test case and update the "test case description" as well
# 6. The utimite goal of "at.pl" it grow to be a true "automation tool"
# 7. User can write "test case description" in (as close as possible) nature language. at.pl understands it and transfer it to "test script" (in shell script in ipa's case

################################################################################
#                              sub routines                                    #
################################################################################

sub usage{
    print "\nusage  : at.pl <ipa command> ";
    print "\nexample: at.pl config";
    print "\n       means find out all possible CLI test for ipa config feature";
    print "\n";
}

sub parseIPAcmd{
    my ($helpmsg) = shift;
    my @cmds;
    my @alllines= (split /\n/, $helpmsg);
    my $skip=1;
    foreach my $line (@alllines){
        next if $line =~/^\s*$/; #skip empty line
        if ($line =~ /Topic commands/){
            $skip=0;
            next;
        }
        if ($skip){
            #print "\nSkip: $line";
        }else{
            #print "\nCatch: $line";
            $line =~ s/^\s*//;
            my @temp = split (/ /,$line);
            #print "\nParse cmd: $#temp, $temp[0]";
            push @cmds, $temp[0];
        }
    }#foreach
    return @cmds;
}# parse ipa command

sub parseIPASUBcmd{
    my ($helpmsg) = shift;
    my @options;
    my @alllines= (split /\n/, $helpmsg);
    my @optionlines;
    my $skip=1;
    # get all lines after "Options"
    foreach my $line (@alllines){
        next if $line =~/^\s*$/; #skip empty line
        if ($line =~ /Options/){
            $skip=0;
            next;
        }
        if (! $skip){
            chomp $line;
            push @optionlines, $line;
            #print "\nGrab  option line: [$line]";
        }
    }
    # merge lines in options, 
    my @opts;
    my $templine="";
    foreach my $line (@optionlines){
        next if $line =~ /-h/; 
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        #print "\nparse line: [$line]";
        if ($line =~ /^--all\)$/){ #FIXME This line is sooo hardcoded
                $templine .= " $line";
        }elsif ($line =~ /^--/){
            if ($templine =~ /^--(\w?)(\s?)/ ){
                push @opts, $templine;
                #print "\npush: [$templine]";
                $templine = $line;
            }else{
                $templine=$line;
            }
        }else{
            $templine = "$templine $line";
        }
    }#optionlines
    #print "\npush: [$templine]";
    push @opts, $templine; # don't forget the last line
    return @opts;
}#parseIPASUBcmd()

sub parseOption {
    my ($opt) = shift;
    #print "\nread [$opt]";
    my ($optbody, $optcmt, $optdatatype);
    my %properties;
    my @prop = split(/\s/,$opt);
    my @tmp_body = split(/=/,$prop[0]);
    if ($#tmp_body == 1){
            $optbody = $tmp_body[0];
            $optdatatype=$tmp_body[1];
    }else{
            $optbody=$prop[0];
            $optdatatype="unknow";
    }
    if ($opt =~ /(\S+)(\s+)(.*)/){
            $optcmt = $3;
    }
    $properties{"datatype"}=$optdatatype;
    $properties{"body"}=$optbody;
    $properties{"comment"}=$optcmt;
    #print "\n\tparse option: [$opt] : ";
    #print "\n\tbody->[$optbody], datatype-> [$optdatatype], comment->[$optcmt]";
    return %properties;
}#parseOption

sub printIPAcmd {
    my $temp=shift;
    my %hashdata=%$temp;
    foreach my $key (keys %hashdata){
        print "\n[$key]:";
        my $data = $hashdata{$key};
        my $name= $data->{"cmd"};
        #print "\n\tcommand: [ipa $name] options:";
        my $tmp_options = $data->{"alloptions"};
        my @options = @$tmp_options;
        printArray("\n\t", @options);
        #foreach my $opt (@options){
        #    print "\n\t$opt";
        #}#foreach opt
        my $tmp_optproperty = $data->{"eachoption"};
        my %optproperty = %$tmp_optproperty;
        my @keys = keys %optproperty;
        print "\n\t$name Optionkeys:";
        printArray ("\n\t",@keys);
        foreach my $key (keys %optproperty){
            print "\n\toption: [$key]";
            my $opt_tmp = $optproperty{$key};
            my %optvalues = %$opt_tmp;
            printHash ("\n\t\t", %optvalues);
            #my $tmp_value = $optproperty{"$key"};
            #my %hashvalue = %$tmp_value;
            #foreach my $valuekey (keys %hashvalue){
            #    print "\n\t[$valuekey] [".$hashvalue{"$valuekey"};
            #}#foreach
        }#read option property
    }#foreach key
}# printIPAcmd

sub printHash {
    my ($indent, %data) = @_;
    foreach my $key (keys %data){
        print "$indent"."[$key] -> [$data{$key}]";
    }
}#printHash

sub printArray {
    my ($indent, @data) = @_;
    foreach my $d (@data){
        print "$indent"."[$d] ";
    }
}#printArray

sub optengine {
    my ($cmd, $options_ref, $rules_ref) = @_ ;
    my %rules= %$rules_ref;
    my @allopts = computeAllOpts($options_ref); 
    print "\n-------ALl possible combinations--------";
    printArray (sortArray(@allopts));
    print "\n----------------------------------";
    my @optsafter = applyRules(\@allopts, \%rules);
    print "\n===== After rules applied =======";
    printArray (sortArray(@optsafter));
    print "\n===================================";
    return sortArray(@optsafter);
}# optengine

sub computeAllOpts {
    my $options_ref = shift;
    my @options = @$options_ref;
    my @queue=();
    @queue = comb(\@options, \@queue);
    return @queue;
}#computeAllOpts

sub comb {
    my ($opts_ref, $queue_ref) = @_;
    my @opts = @$opts_ref;
    my @queue = @$queue_ref;
    #print "\nopts [$#opts], queue [$#queue]";
    if ($#opts == 0){
        #print "\n$#opts";
        push @queue, $opts[0];
        #printArray (@queue);
        return @queue;
    }else{
        my $first = shift @opts;
        #print "\n1->[$first]";
        #printArray (@opts);
        @queue = comb (\@opts, \@queue);
        my @newcomb=();
        foreach my $q (@queue){
            my $combination = "$first $q";
            push @newcomb, $combination;
        }
        push @queue, @newcomb;
        push @queue, $first;
        return @queue;
    }
}

sub applyRules {
    my ($allopts_ref , $rules_ref) = @_;
    my @allopts = @$allopts_ref;
    my %rules = %$rules_ref;
    while (my ($opt, $rule)=each %rules){
        my @newopts=();
        print "\ncheck [$opt]'s rule: [$rule]";
        foreach my $line (@allopts){
            print "for opt comb [$line]";
            if ($line =~ /$opt/){
                if (obeyRule($opt, $line, $rule)){
                    push @newopts, $line;
                    print "\t--> Pass\n";
                }else{
                    print "\t--> Delete: [$line]\n";
                }
            }#apply rules
            else{
                print "\t-->N/A, pass\n";
                push @newopts, $line;
            }
        }#foreach loop
        @allopts=@newopts;
        print "\nafter check, we have:";
        printArray (@allopts);
    }#while loop
    return @allopts;
}# applyRules;

sub obeyRule {
    my ($option, $optioncomb, $rule) = @_;
    my $ret=0; 
    if ($rule eq "any"){
        $ret=1; #rule passed
    }#rule: any
    elsif ($rule eq "only"){
        if ($option eq "$optioncomb"){
            $ret=1;
        }else{
            $ret=0;
        }
    }#rule: only
    elsif ($rule =~ /must (.*)/){
        my $check = $1;
        if ($optioncomb =~ /$check/){
            $ret=1;
        }else {
            $ret=0;
        }
    }#must
    else{
        $ret=1; #otherwise, just make it pass
    }
    if (! $ret){
        print "\n[$optioncomb] violates [$option]'s rule: [$rule]";
    }
    return $ret;
}#obeyRule
 
