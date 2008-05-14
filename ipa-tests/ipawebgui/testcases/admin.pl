#!/usr/bin/perl

use strict;
use warnings; 

our $sdir = "/home/yi/workspace/ipawebgui/testcases/smog";	# source dir
our $tdir ="/tmp/t/";										# target dir
our $ddir = "/home/yi/workspace/ipawebgui/testcases/";		# data dir
our $dfile = "smogdata.txt";
#our $tdir=$sdir;

if (!open (DATA, ">$ddir$dfile")){
	print "Can not open data file to write";
	exit;
}

our @infiles =getdirfiles($sdir);
if ($#infiles < 0 ){
	print "\nsource dir has no files [$sdir]";
	exit;
}
our $BEGIN=q[
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests
use Test::Exception;

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;

# global veriables
our $host;
our $port;
our $browser;
our $browser_url;
our $configfile="test.conf";

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};

# check testing environment
if (envcheck()){ 
	print "\nEnvironment is ready for testing...";
}else{
	exit 1;
}
my $testdata=prepare_data();

# run test
run_test($testdata);

cleanup_data($testdata);

print "\ntest finished\n";
];

our $PREFIX=q/
	my ($data, $sel) = @_;  
	if (!defined $sel){
		my $sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_ur =>$browser_url);
	}/;
foreach my $file (@infiles){  
	my $body= "";
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
				$body .= "\n#=========== sub =============\n";
				$body .="\nsub run_test {\n";
				$body .= "    # test case name ($tc_name)\n"; 
				$body .= "    # source ($file)\n"; 
				$body .= "    # [".gettimestamp()."]\n"; 
				$body .= $PREFIX ."\n";
				$flag=0;
			}
			#format:  $sel->open_ok(https://ipaserver.test.com/ipa/user/show?uid=a001);
			if ($line =~ /open_ok/){  
				$body .= "\t#".$line;
				my $t = q[https://ipaserver.test.com];
				$line =~ s/$t//; 
			}			
			#format: $sel->type_ok("form_title", "automation");
			if ($line =~ /type_ok\(\"(.*)\"(.*)\"(.*)\"\)/){
				my $key = $1;
				my $value = $3;
				my $replace = "\$testdata->{\'".$key."\'}";
				print DATA "\n$tc_name : $key -> $value";
				$line =~ s/$value/$replace/; 
			} 
			$body .="\t$line";
		}
	} 
	close DATAFILE; 
	$body .=  "} #$tc_name\n\n" ;
	my $tc = $BEGIN.$body;
	$tc =~ s/Test::More tests/use Test::More tests => $counter;/;
	print SCRIPT $tc;
	close SCRIPT;
}
print "\n$ddir$dfile closed";
close DATA;

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
