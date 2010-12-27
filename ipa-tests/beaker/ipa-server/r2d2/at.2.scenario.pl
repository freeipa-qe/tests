#!/usr/bin/perl
#
#File: at.2.scenario.pl
#Date: Dec. 22, 2010
#By  : Yi Zhang <yzhang@redhat.com>
#       this is a step 2 program for at.pl 
#       the input of this program are two files: syntax file and data file
#       these two files should be prepared by step 1 (at.1.prepare.pl)
#

use strict;
use warnings;

$|=1; #flush output
print "scenario engine starts...";
our $ipacmd;
our $syntaxfile;
our $datafile;

# command line argument parse
our $totalArgs=$#ARGV;
if ($totalArgs == 2) {
    $ipacmd     = $ARGV[0];
    $syntaxfile = $ARGV[1];
    $datafile   = $ARGV[2];
}else{
    usage();
    exit;
}

our %syntax = parseConfFile($syntaxfile);
#printConf (\%syntax);
our %data= parseConfFile($datafile);
#printConf (\%data);
our @allsmogtest=();
# calculate all possible combination for each ipa sub command
foreach my $ipasubcmd (keys %syntax){
    print "\nwork on [$ipasubcmd]...";
    my $syntax_ref = $syntax{$ipasubcmd};
    my %syntax_details = %$syntax_ref;
    my @options = keys %syntax_details;
    my @all=optengine($ipasubcmd, \@options, \%syntax_details);
    print "\nget all options";
    my @tempAll;
    foreach my $option (@all){
        my $sortedOption= arrayTostring(sortArray(stringToarray($option)));
        push @tempAll , $sortedOption;
    }
    my @sortedAll = sortArray (@tempAll);
    #printArray(@sortedAll);
    my @smog = scenarioExtractor ("smog", @sortedAll);
    print "\n===== smog test cases ======";
    my @sortedSmog;
    foreach my $option (@smog){
        my $sortedOption = arrayTostring(sortArray(stringToarray($option)));
        push @sortedSmog, $sortedOption;
    }
    printArray(@sortedSmog);
    push @allsmogtest,@sortedSmog;
    print " done";
}#foreach

print "\n============ all smog test cases option ================";
printArray(@allsmogtest);
print "\n========================================================";
print "\nOption engine ends\n";

#
################# sub routine ##################
#

sub scenarioExtractor{
    # extract scenario based on given keyword
    my ($keyword, @scenario) = @_;
    if ($keyword eq "smog"){
        print "\nextract smog level test cases";
        extractSmog(@scenario);
    }elsif ($keyword eq "acceptance"){
        extractAcceptance(@scenario);
    }elsif ($keyword eq "functional"){
        extractFunctional(@scenario);
    }else{
        print "\n$keyword not supported";
        return (""); #return empty array
    }
}# scenarioExtractor

sub extractSmog {
    my @allscenario = @_;
    # what is smog level scenario:
    # assuming there are 3 options: "a", "b", "c", assume syntax for each option is "any"
    # the following wil returned: 
    # a ; b ; c ; a b c;
    my @allsmog=();
    my %smog = arrayTohash(@allscenario);
    # get distinguished shortest option combination
    my $loopn = 0;
    my $experimentUpperLimit=10; # i don't know why 10 works, if not, try 100
     while ($loopn < $experimentUpperLimit){
        my @allkeys = keys %smog;
        foreach my $key (@allkeys){
            my @rest = @allkeys; #array copy
            shift @rest; # remove the first element,since it is $key
            foreach my $thiskey (@rest){
                #return 1: if $key is part of $thiskey
                #return -1 if $thiskey is part of $key
                #return 0 if there is no such relation
                #return 2 if $key == $thiskey
                my $containstatus = contains($key, $thiskey);
                #print "\nstatuscode: [$containstatus], 1=[$key], 2=[$thiskey]";
                if ($containstatus == 1){
                    delete $smog{$thiskey};
                    #print "\nreplace\t[$thiskey]\nwith\t[$key]\n";
                    last;
                } #if $key is part of $thiskey
                elsif ($containstatus == -1 ){
                    delete $smog{$key};
                    #print "\nreplace\t[$key]\nwith\t[$thiskey]\n";
                }# if $thiskey is part of $key
                elsif ($containstatus == 2){
                    #print "\nleave it: [$thiskey]";
                    next;    
                }# if $key same as $thiskey
                elsif ($containstatus == 0){
                    #print "\nleave it: [$thiskey]";
                    next;    
                }# if no relation
                else{
                    print "\nerror , exit";
                    exit;
                }#we should never hit this block
                @rest = keys %smog;
            }#foreach in rest
            @allkeys = keys %smog;
        }#foreach
        print "\n==== loop [$loopn] step ==============";
        printArray(@allkeys); 
        print "\n======================================";
        $loopn++;
    }#while loop
    my @smogoptions = keys %smog;
    push @allsmog, @smogoptions;
    #reset smog
    %smog = arrayTohash(@allscenario);
    $loopn=0; #reset loop counter
    # get distinguished longest option combination
    #print "\ntotal: [$#allscenario]";
    # we have to exercies the foreach loop couple times to get final answer
    while ($loopn < $experimentUpperLimit){
        my @allkeys = keys %smog;
        foreach my $key (@allkeys){
            my @rest = @allkeys; #array copy
            shift @rest; # remove the first element,since it is $key
            foreach my $thiskey (@rest){
                #return 1: if $key is part of $thiskey
                #return -1 if $thiskey is part of $key
                #return 0 if there is no such relation
                my $containstatus = contains($key, $thiskey);
                if ($containstatus == 1){
                    delete $smog{$key};
                    print "\nreplace\t[$key]\nwith\t[$thiskey]\n";
                    last;
                } #if $key is part of $thiskey
                elsif ($containstatus == -1 ){
                    $smog{$key} = 1; #add it back
                    delete $smog{$thiskey};
                    print "\nreplace\t[$thiskey]\nwith\t[$key]\n";
                }# if $thiskey is part of $key
                elsif ($containstatus == 0){
                    #print "\nleave it: [$thiskey]";
                    next;    
                }# if no relation
                elsif ($containstatus == 2){
                    #print "\nleave it: [$thiskey]";
                    next;    
                }# if $key same as $thiskey
                else{
                    print "\nerror , exit";
                    exit;
                }#we should never hit this block
                @rest = keys %smog;
            }#foreach in rest
            @allkeys = keys %smog;
        }#foreach
        print "\n==== loop [$loopn] step ==============";
        printArray(@allkeys); 
        print "\n======================================";
        $loopn++;
    }#while loop
    @smogoptions = keys %smog;
    push @allsmog, @smogoptions;
    #return @smogoptions;
    return @allsmog;
}# extractSmog

sub optengine {
    my ($cmd, $options_ref, $rules_ref) = @_ ;
    my %rules= %$rules_ref;
    my @allopts = computeAllOpts($options_ref); 
    #print "\n-------ALl possible combinations--------";
    #printArray (sortArray(@allopts));
    #print "\n----------------------------------";
    my @optsafter = applyRules(\@allopts, \%rules);
    #print "\n===== After rules applied =======";
    #printArray (sortArray(@optsafter));
    #print "\n===================================";
    #return sortArray(@optsafter);
    return @optsafter;
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
            #print "\nbefore sort: [$combination]";
            #my $sortedCombination = arrayTostring(sortArray(stringToarray($combination)));
            #print "\nafter sort: [$sortedCombination]";
            #push @newcomb, $sortedCombination;
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
        #print "\ncheck [$opt]'s rule: [$rule]";
        foreach my $line (@allopts){
           # print "\nsyntax check [$line] with rule: [$rule] for option:[$opt]";
            if ($line =~ /$opt/){
                #print "\nrule apply";
                if (obeyRule($opt, $line, $rule)){
                    push @newopts, $line;
                    #print "\t--> Pass\n";
                }else{
                    print "\t--> Delete: [$line]\n";
                }
            }#apply rules
            else{
                #print "\t-->N/A, pass\n";
                push @newopts, $line;
            }
        }#foreach loop
        @allopts=@newopts;
        #print "\nafter check, we have:";
        #printArray (@allopts);
    }#while loop
    my $total = $#allopts;
    print "\napplyRules : before return, total in queue [$total]";
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
        
sub printArray {
    my (@a) = @_;
    print "\n";
    foreach (0..$#a ) {
        print "\n[$_]". $a[$_];
    }
}
         
sub sortArray {
    my (@a) = @_;
    my %h;
    foreach (@a){
        next if exists $h{$_};
        $h{$_}="1";
    }
    my @sorted = sort keys %h;
    return @sorted;
}


sub usage{
    print "\nusage  : at.2.scenario.pl <ipa command>  <syntax file> <data file> ";
    print "\nexample: at.2.scenario.pl permission permission.syntax permission.data";
    print "\nNotes  : the order is very important, it has to be syntax file then data file";
    print "\n";
}#usage

sub parseSyntaxFile{
    my $configfile = shift;
    our %syntax;
    if (open SYNTAX,"<$configfile"){
        print "\nLoading syntax file: [$configfile]";
    }else{
        print "\nCan not read syntax file: [$configfile], exit";
        exit;
    }

    my $currentcmd="";
    my %currentsyntax;
    while (<SYNTAX>){
        my $line = $_;
        chop $line;
        next if ($line =~/^#/);
        next if ($line =~/^\s*$/);
        #print "\nreadline: [$line]";
        if ($line =~/\[(.*)\]/){
            my $cmd = $1;
            #print "\nRead cmd: [$cmd]";
            if ($currentcmd eq ""){
                # this is the first syntax group detected
                $currentcmd = $cmd;
            }else{
                if (exists $syntax{$currentcmd}){
                    # report error and exit program
                    print "\nFormat error, duplicate cmd syntax detected, [$currentcmd], exit";
                    exit;
                }else{
                    #load into syntax hashtable;
                    #print "\nSave cmd: [$currentcmd], new commer: [$cmd]";
                    $syntax{$currentcmd} = \%currentsyntax;
                    $currentcmd = $cmd;
                }
            }#
        }else{
            #print "\nsyntax line: $line";
            my @syntaxline = split(/:/, $line);
            if ($#syntaxline == 1){
                my $option = $syntaxline[0];
                my $detail = $syntaxline[1];
                $option =~ s/^\s+//; # remove leading spaces
                $option =~ s/\s+$//; # remove trailing spaces
                $detail =~ s/^\s+//; # remove leading spaces
                $detail =~ s/\s+$//; # remove trailing spaces
                $currentsyntax{$option} = $detail;
            }else{
                print "\nFormat error: expect format <option>: <details> -- use ':' as delimiter";
                print "\nActually get: $line";
                exit;
            }
        }
    }
    close (SYNTAX);

    # some left over to save
    if (exists $syntax{$currentcmd}){
        # report error and exit program
        print "\nFormat error, duplicate cmd syntax detected, [$currentcmd], exit";
        exit;
    }else{
        #load into syntax hashtable;
        #print "\nSave cmd: [$currentcmd]";
        $syntax{$currentcmd} = \%currentsyntax;
    }
    return %syntax;
}#end of parseSyntaxFile


sub parseConfFile{
    my $configfile = shift;
    my %conf;
    if (open CONF,"<$configfile"){
        print "\nLoading config file: [$configfile]";
    }else{
        print "\nCan not read syntax file: [$configfile], exit";
        exit;
    }

    my $currentcmd="";
    my %currentrule;
    while (<CONF>){
        my $line = $_;
        chop $line;
        next if ($line =~/^#/);
        next if ($line =~/^\s*$/);
        #print "\nreadline: [$line]";
        if ($line =~/\[(.*)\]/){
            my $cmd = $1;
            #print "\nRead cmd: [$cmd]";
            if ($currentcmd eq ""){
                # this is the first syntax group detected
                $currentcmd = $cmd;
            }else{
                if (exists $conf{$currentcmd}){
                    # report error and exit program
                    print "\nFormat error, duplicate command detected, [$currentcmd], exit";
                    exit;
                }else{
                    #load into rules hashtable;
                    #print "\nSave cmd: [$currentcmd], new commer: [$cmd]";
                    $conf{$currentcmd} = \%currentrule;
                    $currentcmd = $cmd;
                }
            }#
        }else{
            #print "\nline: $line";
            my @option_rules = split(/:/, $line);
            if ($#option_rules == 1){
                my $option = $option_rules[0];
                my $detail = $option_rules[1];
                $option =~ s/^\s+//; # remove leading spaces
                $option =~ s/\s+$//; # remove trailing spaces
                $detail =~ s/^\s+//; # remove leading spaces
                $detail =~ s/\s+$//; # remove trailing spaces
                $currentrule{$option} = $detail;
            }else{
                print "\nFormat error: expect format <option>: <details> -- use ':' as delimiter";
                print "\nActually get: $line";
                exit;
            }
        }
    }
    close (CONF);

    # some left over to save
    if (exists $conf{$currentcmd}){
        # report error and exit program
        print "\nFormat error, duplicate comand detected, [$currentcmd], exit";
        exit;
    }else{
        #load into conf hashtable;
        #print "\nSave cmd: [$currentcmd]";
        $conf{$currentcmd} = \%currentrule;
    }
    return %conf;
}#end of parseConfFile

sub printConf{
    my $conf_ref = shift;
    my %conf = %$conf_ref;
    foreach my $key (keys %conf){
        print "\n[$key]";
        my $conf_ref = $conf{$key};
        my %conf_details = %$conf_ref;
        while (my ($key, $value) = each %conf_details){
            print "\n  [$key] ==> [$value]";
        }#while loop
    }#foreach
}#printCOnf

sub arrayTostring {
    my @array = @_;
    my $string="";
    foreach (@array){
        $string = "$string $_";
    }#foreach
    $string =~ s/^\s*//;
    $string =~ s/\s*$//;
    return $string;
}#arrayToString

sub stringToarray {
    my $string = shift;
    my @array = split (/ /,$string);
    return @array;
}#stringToarray

sub arrayTohash {
    my @array = @_;
    my %hasharray;
    foreach (@array){
        next if exists $hasharray{$_};
        $hasharray{$_}=1;
    }
    return %hasharray;
}#arrayTohash

sub contains {
    # return 1: if $first is part of $second
    # return -1 if $second is part of $first
    # return 0 if there is no such relation
    # retuen 2 if $first same as $second
    my ($first , $second) = @_;
    my $code = 0;
    #print "\nfirst: [$first]";
    #print "\nsecond [$second]";
    my @firstarray = stringToarray($first);
    my @secondarray = stringToarray($second);
    my %firsthash = arrayTohash(@firstarray);
    my %secondhash = arrayTohash(@secondarray);
    my $firstTotalElement = $#firstarray;
    my $secondTotalElement = $#secondarray;

    if ($firstTotalElement == $secondTotalElement){
        foreach my $element (keys %secondhash){
            if (exists $firsthash{$element}){
                $code = 2;
            }else{
                $code = 0;
                return $code;
            }
        }
    }#if first string contains more number of options
    elsif ($firstTotalElement > $secondTotalElement){
        foreach my $element (keys %secondhash){
            if (exists $firsthash{$element}){
                $code = -1;
            }else{
                $code = 0;
                return $code;
            }
        }
    }#if first string contains more number of options
    else{
        foreach my $element (keys %firsthash){
            if (exists $secondhash{$element}){
                $code = 1;
            }else{
                $code = 0;
                return $code;
            }
        }
    }
    return $code;
}#contains


