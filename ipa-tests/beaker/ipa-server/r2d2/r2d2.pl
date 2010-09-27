#!/usr/bin/perl
#File: r2d2.pl
#Date: Sept 22, 2010
#By  : Yi Zhang <yzhang@redhat.com>
#
#       r2d2.pl is used to automate the test case writing for data-driven test
#       it read input file: <testsuite.manifest>
#       and outpt a bounch standard type test script including data file
#

use strict;
use warnings;

our $manifest;
our $tfile;
our $output="";
our $totalArgs=$#ARGV;

if ( $totalArgs < 0 ){
    print "usage: r2d2.pl <manifest file> ";
    exit;
}elsif ($totalArgs == 0) {
    $manifest=$ARGV[0];
    my @temp = split(/\./,$manifest);
    $tfile = "t.".$temp[0].".sh";
}elsif ($totalArgs == 1){
    $manifest=$ARGV[0];
    $tfile=$ARGV[1];
}else{
    print "usage: r2d2.pl <manifest file> <testcase file - this is optional>";
    exit;
}
print "\nmanifest file: [$manifest]";
print "\ntestcase file: [$tfile]";

# FIXME: get testsuite name out of manifest file
#       the manifest file format is expected as:
#       <test suite name>.manifest

if ( ! open(MANIFEST, "$manifest")){
    print "can not open manifest file [$manifest]";
    exit;
}

if ( ! open (OUTPUT, ">$tfile")){
    print "can not open test case file to write: [$tfile]";
    exit;
}
close (OUTPUT); #just test to verify we are be able to write, the actual writing will be later

# ############ main parsing and work starts here ########33

# ######################## #
#      global variables    #
# ######################## #
our %testsuite;
our @logics;
our @parsingErrors;
our $setindex=0;
our $caseindex=0;
our $lineIndex=0;
our $errorFlags=0;

######### parsing the manifest file ############
while (<MANIFEST>){
    $lineIndex++;
    my $line=$_;
    chomp $line;
    $line =~  s/^\s+//; # remove the leading spaces
    $line =~ s/\s+$//;  # remove the trailing spaces
    if ($line =~ m/^#{4}/){  #### parsing the test case element line
        my $thisline = $line;
        $thisline =~ s/####//; #remove the '#' charactars
        my $current_testset = $testsuite{"$setindex"};
        my $current_testcase = $current_testset->{"$caseindex"};
        my $key = ""; 
        my $value = "";
        my @pair = split (/:/ , $thisline);
        if ($#pair == 0){
            $key = $pair[0]; 
            $key =~ s/^\s+//;
            $key =~ s/\s+$//;
        }elsif ($#pair == 1){
            $key = $pair[0];
            $key =~ s/^\s+//;
            $key =~ s/\s+$//;

            $value = $pair[1];
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;
        }else{
            recordError($lineIndex, 
                        "Format error", 
                        "test case property has to e a pair of strings that separated by \":\" ");
            next;
        }
        # save above property into current testcase in current test set
        $current_testcase->{$key} = $value;
    }# parsing testcase elements 

    elsif ($line =~ m/^#{3}/){  #### parsing the test case line
        my $thisline = $line;
        $thisline =~ s/###//; #remove the '#' charactars
        # start a new test case
        $caseindex++;
        my $next_testcase_index = $caseindex ;
        #get current test set save above new testcase into current testset
        my $current_testset = $testsuite{"$setindex"};
        my $testcase_name = parseName ($thisline, $lineIndex);
        my %testcase; # start a new testcase
        if ($testcase_name =~ m/^_/){
            $testcase_name = $current_testset->{"name"}."$testcase_name";
        }
        $testcase {"name"} = $testcase_name;
        $testcase {"logic"} = $testcase_name."_logic";
        $current_testset->{"$next_testcase_index"} = \%testcase;
        $current_testset->{"total"} = $caseindex;
    }# parsing test case

    elsif ($line =~ m/^#{2}/){  #### parsing the test set line
        my $thisline = $line;
        $thisline =~ s/##//; #remove the '#' charactars
        # start a new set
        $setindex ++;
        $caseindex = 0; # reset the testcase counter since we have a new set
        my $testset_name = parseName ($thisline, $lineIndex);
        my $next_testset_index = $setindex ;
        my %testset;
        if ($testset_name =~ m/^_/){
            $testset_name= $testsuite{"name"}."$testset_name";
        }
        $testset{"name"} = $testset_name;
        $testset{"total"} = 0;
        $testsuite{"$next_testset_index"} = \%testset;
        $testsuite{"total"} = $setindex;
    }# parsing test set 

    elsif ($line =~ m/^#{1}/){  ### parsing the test suite line
        my $thisline = $line;
        $thisline =~ s/#//; #remove the '#' charactars
        my $testsuitename = parseName ($thisline, $lineIndex);
        if ( (! exists $testsuite{"name"}) && ($testsuitename ne "") ){
           #create a brand new hash table for test suite
           $testsuite{"name"}=$testsuitename;
           $testsuite{"total"} = 0;
        }else{
           recordError($lineIndex, 
                        "Format error", 
                        "one manifest file can only contain one test suit");
        }#else
    }# parsing test suite
    else{
        print "\nIngore: [$line]";
    }
} #while loop to read the file
close (MANIFEST);
#################### end of manifest file parsing ##################

########### exit if there are any parsing error ####################
if ($errorFlags > 0){
    print "\nParsing error found, exist program\n";
    exit 1;
} # exit if error found

#print "\n--------- parsing output ---------";
printTestSuite() ;

###################### start produce automation file ################


# maintest function includes all test set information
appendline ("# main test function ");
our $maintest = $testsuite{"name"};
appendline("$maintest()");
appendline("{");
appendTestSet_to_TestSuite();
appendline("} # $maintest");
appendline ("");

# create each testset that contains its test case
appendline ("# testset");
appendTestCase_to_TestSet();


appendline ("# test cases");
appendTestCaseElement_to_TestCase();

#print "\n test case file:";
foreach my $f (@logics){
    writelogic ($f);
}

#print "\n function file: ";
$output =~ s/__/\$/g;
#print "$output";
if ( ! open (OUTPUT, ">$tfile")){
    print "can not open test case file to write: [$tfile]";
    exit;
}
print  OUTPUT $output;
close (OUTPUT);

###################### end of produce automation file ###############
print "\n--- end of program ---\n";


# ---------------------------------------------- #
# -------------- subroutine ---------------------#
# ---------------------------------------------- #

sub parseName
{
    my ($line,$lineIndex) = @_;
    my $name="";
    my @pair = split (/:/,$line);
    if ($#pair == 0){
        $name = $pair[0];
    }elsif ($#pair == 1){
        $name = $pair[1];
    }else{
        print "\nEorror on format, line:[$lineIndex]";
        print "\nAllowed format: # testsuite: <testsuite name>";
        print "\n Or just have <test suite name>";
        recordError($lineIndex, 
                    "Format error", 
                    "example: #testsuite: <test suite name>");
    }# wrong format
    if ( $name ne ""){
        $name =~ s/^\s+//; # remove leading spaces
        $name =~ s/\s/_/g;  # replace spaces in middle with _
    }
    return $name;
} #parseName

sub recordError
{
    my ($linenum, $errtype, $msg) = @_;
    my %error;
    $error{"line"} = $linenum;
    $error{"error type"}= $errtype;
    $error{"message"} = $msg;
    print "\n[Error] line [$linenum]";
    print "\n        Error Type: $errtype";
    print "\n        Message   : $msg";
    push @parsingErrors, \%error;
    $errorFlags++;
}

sub printTestSuite
{
    if (! exists $testsuite{"name"}){
        print "\nNo Test Suite found";
        return;
    }
    my $name = $testsuite{"name"};
    my $totalsets = $testsuite{"total"};
    if ($totalsets < 1){
        print "\nEmpty test sets";
        return;
    }else{
        print "\nTest Sets: [$name] has total [$totalsets] sets";
        foreach (1..$totalsets){
                my $setindex="$_";
                my $set = $testsuite{$setindex};
                printTestSet ($set);
        }
    }# non-empty set
} # print all information from manifest file

sub printTestSet
{
    my ($set) = shift;
    my $total = $set->{"total"};
    my $name = $set->{"name"};
    if ($total < 1){
        print "\nThis set has no test case defined";
        return;
    }else{
        print "\n  testset: [$name] has [$total] testcases";
        foreach (1..$total){
            my $testcaseIndex = "$_";
            my $testcase = $set->{$testcaseIndex};
            print "\n   testcase : [$testcaseIndex]";
            printTestCase($testcase);
        } #foreach
    } 
}# printTestSet

sub printTestCase
{
    my ($testcase) = shift;
    foreach (sort keys %$testcase){
        my $k = $_;
        my $v = $testcase->{$k};
        print "\n     ";
        print "[$k] => [$v]";
    }
    print "\n";
} #printTestCase

sub debug
{
    my $msg = shift;
    print "\n[Debug] $msg";
}

sub appendline
{
    my ($line) = shift;
    $output = $output."\n".$line;
} #appendline

sub appendTestSet_to_TestSuite
{
    my $totalsets = $testsuite{"total"};
    if ($totalsets < 1){
        appendline ("# Empty test sets");
    }else{
        appendline ("# Test Sets: $totalsets");
        foreach (1..$totalsets){
                my $setindex="$_";
                my $testset_name = $testsuite{$setindex}->{"name"};
                appendline ("   $testset_name");
        }
    }# non-empty set
} #appendTestSet_to_TestSuite

sub appendTestCase_to_TestSet
{
    my $totalsets = $testsuite{"total"};
    if ($totalsets < 1){
        appendline ("# Empty test sets, skip");
    }else{
        foreach (1..$totalsets){
            my $setindex="$_";
            my $testset = $testsuite{$setindex};
            my $testset_name = $testset->{"name"};
            appendline ("$testset_name()");
            appendline ("{");
            my $totalcase = $testset->{"total"};
            foreach (1..$totalcase){
                my $testcaseIndex = "$_";
                my $testcase = $testset->{$testcaseIndex};
                my $testcase_name = $testcase->{"name"};
                appendline ("   $testcase_name");
            }#foreach to append test case name under test set
            appendline ("} #$testset_name");
            appendline ("");
        }#foreach to loop through test set in test suite
    }# non-empty set
} #appendTestCase_to_TestSet

sub appendTestCaseElement_to_TestCase
{
    my $totalsets = $testsuite{"total"};
    if ($totalsets < 1){
        appendline ("# Empty test sets, skip");
    }else{
        foreach (1..$totalsets){
            my $setindex="$_";
            my $testset = $testsuite{$setindex};
            my $testset_name = $testset->{"name"};
            my $totalcase = $testset->{"total"};
            foreach (1..$totalcase){
                my $testcaseIndex = "$_";
                my $testcase = $testset->{$testcaseIndex};
                my $testcase_name = $testcase->{"name"};
                appendline ("$testcase_name()");
                appendline ("{");
                my $comment = $testcase->{"comment"};
                my $logic   = $testcase->{"logic"};
                my $loop    = $testcase->{"data-loop"};
                my $noloop  = $testcase->{"data-no-loop"};
                appendline ("# loop   : $loop");
                appendline ("# no loop: $noloop");
                appendline ("");
                appendline ("   rlPhaseStartTest \"$comment\"");
                my $indent="    ";
                my $level=2; #level 2 means put double size of indent before each line of loop
                my $fcall = getFunctionLine($logic, $noloop);
                my $fbody = loopit ($level,$indent,$fcall,$loop);
                appendline ($fbody);
                appendline ("   rlPhaseEnd");
                appendline ("");
                appendline ("} #$testcase_name");
                appendline ("");
            }#foreach to append test case name under test set
        }#foreach to loop through test set in test suite
    }# non-empty set
} # appendTestCaseElement_to_TestCase

sub getFunctionLine
{
    my($fcall, $fixedArgs)= @_;
    my @fixedvars = split(/ /,$fixedArgs);
    foreach my $var (@fixedvars){
        $fcall .=" __".$var;
    }
    return $fcall;
}#getFuncionLine

sub loopit
{
    my ($level, $indent, $fcall, $dynamic) = @_;
    my $localreturn="";
    my $currentIndent="";
    for (my $i=0; $i<$level; $i++){
        $currentIndent .=$indent;
    }
    
    if($dynamic eq ""){
        #print "\nno loop necessary";
        return $fcall;
    } #program hits here only when no loop data defined
    elsif($dynamic =~ /^(\w+)\s(.*)$/){
        my $first = $1;
        my $rest = $2;
        #print "\n[level: $level] first=>[$first]  rest=>[$rest]";
        $localreturn = "$currentIndent"."for __".$first."_value in __".$first;
        $localreturn = $localreturn."\n$currentIndent"."do";
        my $functionline = loopit($level+1, $indent, $fcall." __".$first."_value", $rest); 
        $localreturn = $localreturn."\n$functionline";
        $localreturn = $localreturn."\n$currentIndent"."done";
        #print "\n----localreturn----";
        #print $localreturn;
        #print "\n-------------------";
    }else{
        #print "\n[level: $level] first=>[$dynamic]  rest=>[]";
        $localreturn = "$currentIndent"."for __".$dynamic."_value in __".$dynamic;
        $localreturn = $localreturn."\n$currentIndent"."do";
        $fcall = $fcall." __".$dynamic;
        push @logics, $fcall;
        $localreturn = $localreturn."\n$currentIndent".$indent.$fcall."_value";
        $localreturn = $localreturn."\n$currentIndent"."done";
        #print "\n----localreturn----";
        #print $localreturn;
        #print "\n-------------------";
    }
    return $localreturn;
}# loopit

sub writelogic
{
    my ($logic) = shift;
    print "\nLogic=[$logic]";
    if ($logic =~ m/(\w+)\s(.*)$/){
        my $function = $1;
        my $parameters = $2;
        print "\n   function name: [$function]";
        print "\n   parameters   : [$parameters]";
        appendline ("$function()");
        appendline ("{");
        appendline ("   # accept parameters:");
        appendline ("   # $parameters");
        my @params = split(/ /,$parameters);
        foreach (0..$#params){
            my $index = $_;
            my $param = $params[$index];
            appendline ("   ".$param."=__".($index+1));   
        } #foreach
        appendline ("");
        appendline ("   # test logic starts");
        appendline ("");
        appendline ("   # test logic ends");
        appendline ("} #$function ");
        appendline ("");
    }else{
        print "\n   Format error";
    }
} #writelogic
