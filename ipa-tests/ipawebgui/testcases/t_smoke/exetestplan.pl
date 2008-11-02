#!/usr/bin/perl 

use strict;
use warnings;

#******** Global variables ********#
our $testplanfile;
our @testcases;
our $total=0;
our $pass=0;
our $fail=0;
our $skip=0;
our @case_passed;
our @case_failed;
our @case_skipped;
our $log="/tmp/testplan.log";

#**************************#
our $x=@ARGV;
if ($x==1){
	$testplanfile = $ARGV[0];
	print "\nUsing test plan file [$testplanfile]";
	print "\nUsing default log file [$log]";
	loadtestcases();
}
elsif ($x==2){
	$testplanfile = $ARGV[0];
	$log = $ARGV[1];
	print "\nUsing test plan file [$testplanfile]";
	loadtestcases();

	if (!open (LOG , ">$log")){
		print  "\nopen to write [$log] ERROR";
		exit (0);
	}
	print "\nUsing log file [$log]";
}else{
	print "\nUsage: exetestplan.pl <testplan> <log file>\n";
	exit (0);
}

#**************************#
print "\n\nTest plan [$testplanfile] starts ...";
foreach my $testcase (@testcases){
	my $testresult = run_one_test($testcase);
	$total ++;
	if ($testresult == 0){ # if test failed
		$fail++;
		push @case_failed, $testcase;
	}
	if ($testresult == 1){ # if test success
		$pass++;
		push @case_passed, $testcase;
	}
	if ($testresult == 2){ # if test script file does not exist
		$skip++;
		push @case_skipped, $testcase;
	}
}
print "\n================ summary report =================\n";
print "\ntotal test $total, passed ($pass), failed ($fail), skipped ($skip)";
print "\ntest case failed";
foreach (@case_failed){
	print "\n  ".$_;
}
print "\ntest case skipped"; 
foreach (@case_skipped){
	print "\n  ".$_;
}
print "\ntest case success"; 
foreach (@case_passed){
	print "\n  ".$_;
}
close LOG;
print "\nlog file: [$log]\n";
print "\n\n================ end of summary report =================\n";

#******** sub routines ********#

sub run_one_test{
  my $testscript = shift;
  my $cmd;
  my $return;
  my $result;
  my @ok;
  my @notok;
  my $subtotal=0;
  my $subpass=0;
  my $subfail=0;

  print LOG "\n";
  print LOG gettimestamp()."[$testscript] starts ...";
  print "\ntestcase [$testscript]...";
  if (-e $testscript){
    $cmd="perl $testscript 2>&1";
  }else{
    print "skipped";
    print LOG gettimestamp()."file [$testscript] does not exist, skip this one";
    return 2;
  }
  print LOG gettimestamp()."cmd is [$cmd]";
  $result =`$cmd`;
  
  print LOG gettimestamp()."the testcase response is below";
  my @lines = split(/\n/, $result );
  foreach my $line (@lines){
    print LOG "\n\t".$line;
    if ($line =~ /^ok/){
      push @ok, $line;
      $subtotal++;
      $subpass++;
    }
    if ($line =~ /^not ok/){
      push @notok, $line;
      $subtotal++;
      $subfail++;
    }
  }
  print LOG gettimestamp()."end of the testcase response";
  print LOG gettimestamp()."total steps $subtotal, passed ($subpass), failed ($subfail)";
  print LOG gettimestamp()."the following test steps success:";
  foreach my $okline (@ok){
    print LOG gettimestamp().$okline;
  }
  print LOG gettimestamp()."the following test steps failed";
  foreach my $notokline (@notok){
    print LOG gettimestamp().$notokline;
  }
  print LOG gettimestamp()."[$testscript] ends";
  if ($subtotal == $subpass){
    print "success";
    return 1;
  }else{
    print "failed";
    return 0;
  }
}#run_one_test

sub gettimestamp {
	# return current string type timestamp 
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time) ;
	my $timestamp = ($year+1900)."/".($mon+1)."/".$mday.":".$hour.":".$min.":".$sec;
	return "\n[".$timestamp."] ";
}#gettimestamp	

sub loadtestcases{
	print "\n\tLoading test plan file...";
	if (!open(TESTPLAN, $testplanfile)){
		print "\nCan not read test plan file [$testplanfile]";
		exit(0);
	}
	my $single_testcase;
	while ($single_testcase = <TESTPLAN>){
		next if $single_testcase =~ m/^#/;		# ignore commends line ==> starts with "#" char
		next if $single_testcase =~ m/^\s*$/;	# ignore empty lines
		chop $single_testcase;
		print "\n\tLoad $single_testcase";
		push @testcases , $single_testcase;
	}
	close TESTPLAN;	
	print "\n\tLoading test case finished\n";
}
