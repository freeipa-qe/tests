#!/usr/bin/perl
#
#File: at.3.testcase.pl
#Date: Jan. 6, 2011
#By  : Yi Zhang <yzhang@redhat.com>
#       this is a step 3 program for at.pl 
#       this program will translate signuture file into test case file
#
use File::Basename;
use strict;
use warnings;

$|=1; #flush output
print "test case generator starts...";
our $ipacmd;
our $basedir;
our $scenariofile;
our $testcasefile;
our $testdatafile;
our @dataArray; # store data for testdata file, i want to sort it before i write into file
our $total;
our %scenario;
our $indent="\n    ";
our $indent2="\n        ";
our $indent4="\n                ";
our $now_string = localtime;

# command line argument parse
our $totalArgs=$#ARGV;
if ($totalArgs == 0){
    $scenariofile = $ARGV[0];
    $basedir=dirname($scenariofile);
    my $filename=basename($scenariofile);
    print "\nbasedir=[$basedir], filename : [$filename]";
    if ($filename=~ /^(.*)\.(.*)/){
        $ipacmd=$1;
    }else{
        $ipacmd=$filename;
        $ipacmd =~ s/\./_/;
        $ipacmd =~ s/-/_/;
        $ipacmd =~ s/ /_/;
    }
    $testcasefile = "$basedir/t.".$ipacmd.".sh";
    $testdatafile = "$basedir/d.".$ipacmd.".sh";
}else{
    usage();
    exit;
}

if ( -r $scenariofile ){
    %scenario = parseScenarioFile($scenariofile);
    #printScenario(\%scenario);
}# load scenario file
else{
    print "\nCan not read scenario file [$scenariofile]";
    exit;
}

writeTestDataFileHeader($testdatafile);
writeTestCaseFileHeader($testcasefile, \%scenario);

foreach my $ipasubcmd (sort keys %scenario){
    my %tc; # hash table to hold each test case scenario and their index;
    my $array_ref = $scenario{$ipasubcmd};
    my @list = @$array_ref;
    my @scenarioList= sortArray(@list);
    my $ipasubcmdF = $ipasubcmd;
    $ipasubcmdF =~ s/-/_/;

    #print "\n------------ $ipasubcmd ---------------";
    #printArray(@scenarioList);
    @dataArray = (); # re-init for data array holder
    foreach (0..$#scenarioList){
        my %testcase;
        my $index = 1001 + $_;
        my $testname = "$ipasubcmdF"."_".$index;
        my $testscenario = $scenarioList[$_];
        $testcase{"index"} = "$index";
        $testcase{"name"}  = $testname;
        $testcase{"scenario"} = $testscenario;
        my $tc_type="positive";
        if ($testscenario=~ /negative/){
            $tc_type = "negative";
        }elsif ($testscenario=~ /boundary/){
            $tc_type = "boundary";
        }else{
            $tc_type = "positive";
        }
        $testcase{"testtype"} = $tc_type;
        $tc{"$index"} = \%testcase;
        print "\n[$index]=>[$testname]";
        $total=$_+1;
    }#foreach to parse each scenario under ipa sub command
    appendToTestFiles ($testcasefile, $testdatafile, $ipasubcmd, \%tc, $total);
}#foreach to walk through scenario hash table

print "\nEND of test case generator\n";

#####################################
#       subrutine                  #
#####################################

sub usage{
    print "\nUsage: at.3.testcase.pl <test scenario file>";
    print "\nexample: at.3.testcase.pl permission.scenario\n";
    exit;
}#usage

sub writeTestCaseFileHeader {
    my ($testcasefile, $scenario_ref) = @_;
    my %tc = %$scenario_ref;

    if (open (DEST,">$testcasefile")){
        print "\ntestcase file is ready to write: [$testcasefile]";
    }else{
        print "\ntestcase file is not be able to open for write [$testcasefile]";
        exit;
    }

    # test case file part 1: introduction
    print DEST "#!/bin/bash"; #first line
    print DEST "\n# By  : Automatic Generated by at.3.testcase.pl";
    print DEST "\n# Date: $now_string";
    print DEST "\n";
    print DEST "\n$ipacmd()";
    print DEST "\n{";
    foreach (sort keys %tc){
        my $ipasubcmd = $_;
        $ipasubcmd =~ s/-/_/;
        print DEST "$indent".$ipasubcmd;
    }
    print DEST "\n} #$ipacmd\n";

    close DEST;
} #writeTestFileHeader


sub writeTestDataFileHeader {
    my ($testdatafile) = shift;

    if (open (DATA,">$testdatafile")){
        print "\ntestdata file is ready to write: [$testdatafile]";
    }else{
        print "\ntestdata file is not be able to open for write [$testdatafile]";
        exit;
    }
    print DATA "\n# DATA file";
    print DATA "\n# By  : Automatic Generated by at.3.testcase.pl";
    print DATA "\n# Date: $now_string";
    print DATA "\n";

    close DATA;
} #writeTestFileHeader

sub appendToTestFiles {
    my ($testcasefile, $testdatafile, $ipasubcmd, $testcase_ref, $total) = @_;
    my %tc = %$testcase_ref;
    my $ipasubcmdF= $ipasubcmd;
    $ipasubcmdF=~ s/-/_/;

    if (open (DEST,">>$testcasefile")){
        print "\ntestcase file is ready to write: [$testcasefile]";
    }else{
        print "\ntestcase file is not be able to open for write [$testcasefile]";
        exit;
    }

    if (open (DATA,">>$testdatafile")){
        print "\ntestdata file is ready to write: [$testdatafile]";
    }else{
        print "\ntestdata file is not be able to open for write [$testdatafile]";
        exit;
    }

    # test case file part 2.1: test cases grouping 
    print DEST "\n#############################################";
    print DEST "\n#  test suite: $ipasubcmd ($total test cases)";
    print DEST "\n#############################################";
    print DEST "\n$ipasubcmdF()";
    print DEST "\n{";
    print DEST "$indent"."$ipasubcmdF"."_envsetup";

    foreach my $index (sort keys %tc){
        my $tc_ref = $tc{$index};
        my %testcase = %$tc_ref;
        my $name = $testcase{"name"};
        my $testscenario = $testcase{"scenario"};
        my $tc_type= $testcase{"testtype"};
        print DEST "$indent"."$name  #test_scenario ($tc_type test): [$testscenario]";
        print "$indent"."[$index]: $name  #test_scenario ($tc_type test): [$testscenario]";
    }# parse the tc hash data and generate test case content
    print DEST "$indent"."$ipasubcmdF"."_envcleanup";
    print DEST "\n} #$ipasubcmd\n";

    # create env setup and cleanup test case
    print DEST "\n$ipasubcmdF"."_envsetup()";
    print DEST "\n{";
    print DEST "$indent"."rlPhaseStartSetup \"$ipasubcmdF"."_envsetup\"";
    print DEST "$indent2"."#environment setup starts here";
    print DEST "$indent2"."#environment setup ends   here";
    print DEST "$indent"."rlPhaseEnd";
    print DEST "\n} #envsetup\n";

    print DEST "\n$ipasubcmd"."_envcleanup()";
    print DEST "\n{";
    print DEST "$indent"."rlPhaseStartCleanup \"$ipasubcmdF"."_envcleanup\"";
    print DEST "$indent2"."#environment cleanup starts here";
    print DEST "$indent2"."#environment cleanup ends   here";
    print DEST "$indent"."rlPhaseEnd";
    print DEST "\n} #envcleanup\n";
    # end of create env setup & cleanup block

    foreach my $index (sort keys %tc){
        my $tc_ref = $tc{$index};
        my $testcase = createTestCase($ipasubcmd,$tc_ref);
        #print DEST "\n#[$index] [$name],[$scenario]";
        print DEST $testcase;
        print DEST "\n";
    }# parse the tc hash data and generate test case content


    # test case file part 3: end of test file
    print DEST "\n#END OF TEST CASE for [$ipasubcmd]\n";

    # sort the data array and write into data file
    print DATA "\n#TEST DATA file for IPA sub command: $ipasubcmd";
    my @sortedDataArray = sortArray(@dataArray);
    foreach (@sortedDataArray){
        print DATA "\n$_";
    }
    print DATA "\n#END OF TEST DATA for [$ipasubcmd]\n";

    # end of program, close files and exit
    close DEST;
    close DATA;
}#

sub fileToArray {
    # lines start with '#' will be ignored
    # empty line will be ignored
    my $file = shift;
    my @array= ();
    if (open (IN, "$file")){
        print "\nopen file to read: [$file]";
    }else{
        print "\nCannot open file : [$file]";
    }
    while (<IN>){
        my $line = $_;
        next if ($line =~/^#/);
        next if ($line =~/^\s*$/);
        chomp $line;
        push @array, $line;
    }
    close IN;
    return @array ;
}# fileToArray

sub sortArray {
    my (@a) = @_;
    my %h;
    foreach (@a){
        next if exists $h{$_};
        $h{$_}="1";
    }
    my @sorted = sort keys %h;
    return @sorted;
}#sortArray

sub printArray {
    my (@a) = @_;
    print "\n";
    foreach (0..$#a ) {
        print "\n[$_]". $a[$_];
    }
}#printArray

sub createTestCase{
    my ($subcmd,$tc_ref) = @_;
    my %testcase = %$tc_ref;
    my $name = $testcase{"name"};
    my $scenario = $testcase{"scenario"};
    my $index = $testcase{"index"};
    my $tc_type = $testcase{"testtype"};
    my $tc="";
    $tc .= "\n$name()";
    $tc .= "\n{ #test_scenario ($tc_type): $scenario";
    $tc .= "$indent"."rlPhaseStartTest \"$name\"";
    $tc .= "$indent2"."KinitAsAdmin";
    my @ipatestcommand = buildTestStatement($subcmd, $scenario);
    foreach my $ipatestcommand_parts (@ipatestcommand){
        $tc .="$indent2"."$ipatestcommand_parts";
    }
    $tc .= "$indent2"."Kcleanup";
    $tc .= "$indent"."rlPhaseEnd";
    $tc .= "\n} #$name";
    return $tc;
}#createTestCase

sub buildTestStatement{
    my ($subcmd, $scenario) = @_;
    my @returnArray=();

    my @localVariableDeclarition = (); # local veriable declarition block
    my $testExpectedResult=0; #default expection: 0 = pass
    my $testCmdStatement = "ipa $subcmd ";
    my $testCommentStatement = "test options: ";
    my @eachOptions=();

    print "\nbuild test statement [$scenario]";
    my @allOptions = split(/--/,$scenario);
    foreach my $eachoption (@allOptions){
        next if ($eachoption =~ /^\s*$/);
        push @eachOptions, $eachoption;
    }
    foreach my $option (@eachOptions){
        my @optionParts = split(/;/,$option);
        my $totalOpts = $#optionParts;
        if ($totalOpts == 0 ){ #if only 1 element in option line, 
            my $optionName = $optionParts[0];
            $optionName =~ s/^\s*//g;
            $optionName =~ s/\s$//g;
            $testCmdStatement .= "--$optionName ";
        }elsif ($#optionParts == 2){ #if 3 elements in option line,
            my $optionName = $optionParts[0];
            my $optionVariableName = "$optionName"."TestValue";
            my $expectedResult = $optionParts[1];
            if ($expectedResult =~ /negative/){
                $testExpectedResult = 1;
            }
            my $optionData = $optionParts[2];

            my $localVariableStatement = "local $optionVariableName=`getTestValue \"$subcmd;$option\" \"$testdatafile\"` ";
            my $str = clearSpaces("$subcmd;$option");
            push @dataArray, "$str=replace_me";
            push @localVariableDeclarition, $localVariableStatement;
            $testCmdStatement .= " --$optionName \$$optionVariableName ";
            $testCommentStatement .=" [$optionName]=[\$$optionVariableName]";
        }else{
            print "\nformat error in [$option], expect 3 parts";
            print "\n<option itself><positive/negative><data>";
            print "\nexit program";
            exit;
        } 
    }#walk  through each option 
    my $fullTestStatement = "rlRun \"$testCmdStatement\" $testExpectedResult \"$testCommentStatement\" ";
    push @returnArray, @localVariableDeclarition;
    push @returnArray, $fullTestStatement;
    return @returnArray;
}# buildTestStatement

sub clearSpaces {
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return $str;
} #clear leading and trailing spaces

sub parseScenarioFile{
    my $scenariofile = shift;
    my %scenario;
    if (open IN,"<$scenariofile"){
        print "\nLoading scenario file: [$scenariofile]";
    }else{
        print "\nCan not read scenario file: [$scenariofile], exit\n";
        exit;
    }

    my $currentsubcmd="";
    while (<IN>){
        my $line = $_;
        chomp $line;
        next if ($line =~/^#/);
        next if ($line =~/^\s*$/);
        $line =~ s/^\s+//; #remove leading spaces
        $line =~ s/\s+$//; #remove trailing spaces
        #print "\nreadline: [$line]";
        if ($line =~/^\[(.*)\]$/){
            $currentsubcmd = $1;
            my @list = ();
            $scenario{$currentsubcmd} = \@list;
        }#parse the perticular line: [ipa sub command], create a new blank hashtable for it
        else{
            #print "\nline: $line";
            my $currentlist_ref = $scenario{$currentsubcmd};
            my @list = @$currentlist_ref;
            push @list, $line;
            $scenario{$currentsubcmd} = \@list;
        }#parse lines under [ipa sub cmd]
    }#while loop
    close (IN);
    return %scenario;
}#end of parseConfFile

sub printScenario{
    my $scenario_ref = shift;
    my %scenario= %$scenario_ref;
    foreach my $key (keys %scenario){
        print "\n[$key]";
        my $list_ref= $scenario{$key};
        my @list = @$list_ref;
        foreach (0..$#list){
            print "\n[$_] ".$list[$_];
        }#foreach inner
    }#foreach outter
}#printScenario

