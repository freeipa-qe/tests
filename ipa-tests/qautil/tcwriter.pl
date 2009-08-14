#!/usr/bin/perl
#
# file: tcwriter.pl
# whatfor: automatic test case writing tool
# by: yi zhang
#

########### global variables ################
our $origin;
our @dirs;
our %maps;
our $trunk="/home/yi/tmp/dstrunk";
our $tcfile="/tmp/";
my $rand=rand();
our $tcfile="/tmp/tc".$rand.".txt";
our $conffile;

########## command line argument parsing ##########
print "\nAutomatic test case help tool starts... write to"; 
if ($#ARGV == -1){
	print " default tese case name: $tcfile";
}elsif ($#ARGV ==0){
	$conffile = $ARGV[0];
	print " given [$conffile]";
}else{
	print "I just need one argument for now, thanks\n";
	exit;
}
print "\n";

############# main ##########################
##### prepare for tc file
if (open (TC,">$tcfile")){
	print "TestCase File [$tcfile] is ready";
}else{
	print "TestCase File [$tcfile] is NOT ready, [$!}";
	exit;
}
##### open config file
print "\n";
if (open (CONF,">$conffile")){
	print "Config File [$conffile] is ready";
}else{
	print "Config File [$conffile] is NOT ready, [$!}";
	exit;
}

##### prepare for log file
my $log="/tmp/tcwriting.log";
if (open(LOG,">$log")){
	print "LOG FILE: [$log] is ready";
}else{
	print "LOG FILE: [$log] is NOT ready, [$!}";
	exit;
}
print "\n";

##### clean up
close LOG;
close TC;
print "\n-------------- end of program ---------------\n";


########################## sub routines #####################
sub findsubdirs {

	while ($#dirs >=0){
		my $currentdir=shift (@dirs);
		#print "\ncurrent: [$currentdir]";
		my @files;
		if (!opendir (DIR, $currentdir) ){
			#print "can not open [$currentdir], returns: $!";
			next;
		}
		my $filename;
		while ($filename= readdir(DIR)) {
			next if ($filename =~ m/^\./);
			my $currentfile = $currentdir."/".$filename;
			#print "\nprocess [$currentfile]";
			if (-f "$currentfile")    { push @files, $currentfile ;}
			elsif (-d "$currentfile") { push @dirs,  $currentfile ;}
			#else { print " [ERROR!]";}
			my $detection = isksh ($currentfile);
			debug  ("[$currentfile]=$detection\n");
			if ($detection == 3) { push @type3, $currentfile;}
			elsif ($detection == 2) { push @type2, $currentfile;}
			elsif ($detection == 1) { push @type1, $currentfile;}
			elsif ($detection == 0) { push @type0, $currentfile;}
			else{ push @typeerror, $currentfile;}
		}# inner while
		close DIR;
		if (! exists($maps{$currentdir})){
			#print "\nstores [$currentdir] into maps";
			$maps{$currentdir}=\@files;
		}
	}# OUTTER while
	return
} # findsubdirs

sub printa{
	my $all=shift;
	my @elements=@$all;
	for (my $i=0; $i<= $#elements; $i++ ){
		print "\n\t[$i]: $elements[$i]";
	}
}

sub writea{
	my ($all,$file)=@_;
	if (!open(FILE,">$file")){
		print "\nWrite ERROR: $!";
		return;
	}
	my @elements=@$all;
	for (my $i=0; $i<= $#elements; $i++ ){
		print FILE "\n\t[$i]: $elements[$i]";
	}
	close FILE;
}

sub printh{
	my $hashtable=shift;
	my %hash = %$hashtable;
	my @keys=keys(%hash);
	for my $k (sort @keys){
		print "\n$k ->";
		my $value=$hash{$k};
		my $reftype = reftype $value;
		if ($reftype eq 'SCALAR'){ print $value;}
		elsif ($reftype eq 'ARRAY') { print " [ARRAY]"; printa($value) ;}
		elsif ($reftype eq 'HASH')  { print " [HASH]"; printh($value) ;}
		else { print " [ERROR]!";}
	}
}

sub isksh{
# return true if the input file is ksh file
	my $file=shift;
	my $retval=99;
	debug ("\nisksh check :[$file]");
	if (! -f $file ){return -1;} # if this is not a file, then false
	if (! -T $file ){return -1;} # if this is not a text file, then false
	if (! -r $file ){return -1;} # if this file is not readalbe, return false
	my ($filename,$dir,$ext) = fileparse($file,qr{\..*});
	debug ("\n\tfilename:[$filename], dir=[$dir], ext=[$ext]");
	if ( ($ext eq "") || ($ext eq ".sh") || ($ext eq ".ksh")){
		# only read files that: 1. no file extension, 2. has .ksh 3. has .sh
		my $firstline = firstline($file);
		debug ("\n\tfirst line = [$firstline]");
		if ($firstline =~ m/ksh/){
			if ($ext =~ m/[K|k][S|s][H|h]/) { $retval = 3;}
			else { $retval = 2;}
		}else{
			if ($ext =~ m/[K|k][S|s][H|h]/) { $retval = 1;}
			else { $retval=0;}
		}
		# store file into hashtable: "kshfiles"
		my $key=$dir.$filename;
		my %temph;
		if (exists($kshfiles{$key}) ) {
			my $tmp = $kshfiles{$key};
			%temph = %$tmp;
		}
		if ($retval > 0) { 
			$temph{"ksh"}=$file;
		}elsif ( ($retval == 0) && ($ext eq ".sh" ) ){
			$temph{"sh"}=$file;
		}else {
			$temph{"error"}=$file;
		}
		$kshfiles{$key}=\%temph;

	}else { $retval=-1;}
	return $retval;
}

sub firstline{
	my $file = shift;
	my $firstline="justjunk";
	if( (-f $file) && (-T $file) ){
		$firstline=`head -n1 $file`;
		chop $firstline;
		return $firstline;
	}else{
		return "error";
	}
	#while ($firstline=<FILE>){
	#	if ( ($firstline =~ m/^\s*$/) || ($firstline =~ m/^#*$/) )
	#	{
	#		next;
	#	}else{
	#		last;
	#	}
	#}
	#close FILE;
	#print "\n[$file] :(first line): $firstline";
	#chop $firstline;
	#return $firstline;
}

sub debug{
	my $msg=shift;
	print LOG $msg;
}

sub logdiff {
	my ($ksh,$sh,$diff)=@_;
	print DIFF "\n======================================";
	print DIFF "\n	ksh->[$ksh]"; 
	print DIFF "\n	 sh->[$sh]";
	print DIFF "\n--------------------------------------";
	print DIFF "\n$diff";
	print DIFF "\n";
}

sub logmod {
	my ($sh)=@_;
	open (SH,$sh);
	print MODIFY "\n======================================";
	print MODIFY "\n	 sh->[$sh]";
	print MODIFY "\n--------------------------------------";
	while (my $line=<SH>){
		if ($line =~ m/\[\[/){ print MODIFY "Attention[boolean]: $line";}
		if ($line =~ m/ksh/){ print MODIFY "Attention [ksh]: $line";}
		if ($line =~ m/=\$\(\(/){ print MODIFY "Attention [expr]: $line";}
		if ($line =~ m/pid\[/){ print MODIFY "Attention [pid]: $line";}
		if ($line =~ m/=\$\(date/){ print MODIFY "Attention [date]: $line";}
		if ($line =~ m/tet_scen /){ print MODIFY "Attention [tet_scen]: $line";}
	}
	print MODIFY "\n";
	close SH;
}

sub logremove {
	my ($key, $sh, $ksh, $svn) = @_;
	print REMOVE "\n$key";
	print REMOVE "\n [sh  file]:\t$sh";	
	print REMOVE "\n [ksh file]:\t$ksh";	
	print REMOVE "\n [snv log ]:\t$svn";	
}

############ analysis ############
sub analysis{
	# count total possible work
	my @keys=(sort keys(%kshfiles));
	my $kshcounter=0;
	my $shcounter=0;
	my $convertcounter=0;
	my $needworkcounter=0;
	
	foreach my $key (@keys){
		my $tmp = $kshfiles{$key};
		my %hash = %$tmp;
		if (exists($hash{"ksh"})){ 
			my $kshfile=$hash{"ksh"};
			debug ("\n[$key]");
			$kshcounter ++; 
			debug("\n\t[ksh]: ".$kshfile);
			if (exists($hash{"sh"})) { 
				my $shfile = $hash{"sh"};
				# save the diff between sh and ksh file
				# bash command: diff dbintegrity.ksh dbintegrity.sh | sed 's/^</ksh/' | sed 's/^>/sh/'
				my $diff=`diff $kshfile $shfile | grep -v "#" | sed 's/^</ksh/' | sed 's/^>/sh/'`;
				my $svn = `svn remove $kshfile`;
				#my $svn = "svn will remove [$kshfile]";
				logmod ($shfile);
				logdiff ($kshfile,$shfile,$diff);
				logremove ($key, $shfile, $kshfile, $svn);
				$shcounter ++;   
				debug("\n\t[sh]: ".$shfile);
				my $kshtime=`svn info $kshfile | grep "Last Changed Date" | cut -d ":" -f2`;
				my $shtime=`svn info $shfile | grep "Last Changed Date" | cut -d ":" -f2`;
				chop $kshtime;
				chop $shtime;
				debug("\n\t ksh time [$kshtime]");
				debug("\n\t  sh time [$shtime]");
				if ($kshtime gt $shtime){
					debug ("\n\t sh file is older, need work");
					$needworkcounter++;
					push @needworklist, $kshfile;
				}else{
					debug ("\n\t sh file is newer, no work needed");
				}
			}else{
				$convertcounter++;
				push @convertlist, $hash{"ksh"};
			}
		}
	}
	my $finished=$shcounter;
	my $work=$needworkcounter+$convertcounter;
	my $finishrate =int( ($finished/$kshcounter)*100 );
	my $workrate=int( ($work/$kshcounter) *100 );
	my $convertedrate=int( ($shcounter/$kshcounter) * 100 );
	print "\n=== [the following files need to be convered]";
	printa (\@convertlist);
	print "\n=== [the following files need more work, ksh file is newer than sh file]";
	printa (\@needworklist);
	print "\n================= SUMMARY ===============";
	print "\n[$kshcounter] total ksh";
	print "\n[$shcounter] has been converted to sh";
	print "\n[$convertcounter] need converte to sh";
	print "\n[$convertedrate]% has been converted ";
	print "\n[$needworkcounter] ksh files been modified after convert to sh";
	print "\n[$work] files in total still need attention";
	print "\n[$workrate]% work load";
}#analysis
