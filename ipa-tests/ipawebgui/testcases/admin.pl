#!/usr/bin/perl

use strict;
use warnings; 

our $sdir = "/home/yi/workspace/ipawebgui/testcases/smog";
our $tdir ="/tmp/t/";
#our $tdir=$sdir;

our @infiles =getdirfiles($sdir);
if ($#infiles < 0 ){
	print "\nsource dir has no files [$sdir]";
	exit;
}
our $PREFIX=q/
	my ($data, $sel) = @_;  
	if (!defined $sel){
		my $sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_ur =>$browser_url);
	}/;
foreach my $file (@infiles){  
	my $tc_name = $file;
	$tc_name =~ s/\.pl$//;
	my $tfile = $tdir.$tc_name.".t";
	print "\n[$file] -> [$tfile]";
	if (!open (DATAFILE , $sdir."/".$file)){
		print  "\nopen to read [$file] ERROR, skip this file";
		next;
	}

	if (!open (SCRIPT , ">$tfile")){
		print  "\nopen to write [$tfile] ERROR, skip this file";
		close DATAFILE;
		next;
	}
	my $flag=1;
	my @lines = <DATAFILE>;
	my $counter=0;
	foreach my $line (@lines) {
		if ($line =~ /\$sel-\>/){
			if ($line =~ /ok/){
				$counter++;
			}
			if ($flag){
				print SCRIPT "sub $tc_name {\n\n";
				print SCRIPT "    # source ($file)\n"; 
				print SCRIPT "    # [".gettimestamp()."]\n"; 
				print SCRIPT $PREFIX;
				print SCRIPT "\n";
				$flag=0;
			}
			#format:  $sel->open_ok(https://ipaserver.test.com/ipa/user/show?uid=a001);
			if ($line =~ /open_ok/){ 
				print SCRIPT "\t#".$line;
				my $t = q[https://ipaserver.test.com];
				$line =~ s/$t//; 
			}			
			#format: $sel->type_ok("form_title", "automation");
			if ($line =~ /type_ok\(\"(.*)\"(.*)\"(.*)\"\)/){
				my $key = $1;
				my $value = $3;
				my $replace = "\$testdata->{\'".$key."\'}";
				$line =~ s/$value/$replace/; 
			}
			print SCRIPT "\t".$line;
		}
	} 
	close DATAFILE;
	print SCRIPT "\n    #use Test::More tests => $counter;\n\n}#$tc_name\n" ;
	close SCRIPT;
}

print "\nend of execution\n";

################################################
sub getdirfiles{
	my $sourceDIR=shift;
	my @flist;
	if (opendir(SOURCEDIR,$sourceDIR)) {
		print "\n[".gettimestamp()."] Source=[$sourceDIR] reading directory ...";
	}
	else{
		print "can not open ($sourceDIR)";
		return;
	} 
	foreach my $entry (readdir(SOURCEDIR)){
		next if $entry eq ".";
		next if $entry eq ".."; 
		next if $entry =~/\.t/;
		push @flist, $entry if -f "$sourceDIR/$entry"; 
		print "\nfile name:"."$sourceDIR/$entry"."\n";
	}
	closedir(SOURCEDIR);
	print "done\n";
	return @flist;
}

# get timestamp string
sub gettimestamp {
	# return current string type timestamp 
	# ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time) 
	# my ($mday,$mon,$year) = (localtime(time))[3,4,5];
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time) ;
	my $timestamp = ($year+1900)."/".($mon+1)."/".$mday.":".$hour.":".$min.":".$sec;
	return $timestamp;
}#timestamp
