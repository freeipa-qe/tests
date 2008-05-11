#!/usr/bin/perl

use strict;
use warnings; 

our $sdir = "/home/yi/workspace/ipawebgui/testcases/smog";
#our $tdir ="/tmp/t/";
our $tdir=$sdir;

our @infiles =getdirfiles($sdir);
if ($#infiles < 0 ){
	print "\nsource dir has no files [$sdir]";
	exit;
}
foreach my $file (@infiles){ 
	my $tfile = $tdir.$file;
	$tfile =~ s/\.pl$/\.t/;
	print "\n[$file] -> [$tfile]";
	if (!open (DATAFILE , $file)){
		print  "\nreading [$file]ERROR, skip this file";
		next;
	}

	if (!open (SCRIPT , ">$tfile")){
		print  "\nreading [$tfile]ERROR, skip this file";
		close DATAFILE;
		next;
	}
	my $flag=1;
	my @lines = <DATAFILE>;
	foreach my $line (@lines) {
		#print "$line";
		if ($line =~ /\$sel-\>/){
			if ($flag){
				print SCRIPT "# source ($file)"; 
				print SCRIPT "\n# [".gettimestamp()."]\n";
				$flag=0;
			}
			print SCRIPT $line;
		}
	} 
	close DATAFILE;
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