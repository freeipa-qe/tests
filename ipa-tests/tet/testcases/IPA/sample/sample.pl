# filename : sample.pl
#
$tet'startup="ServerInfo";
$tet'cleanup="";
@iclist=(ic1,ic2);
@ic1=("SampleStartState");
@ic2=("tp1" );
@ic3=("SampleEndState");

my ($DATA,$BASESUFFIX,$LDIFFILE);
$DATA=$ENV{"TET_ROOT"}."/../data";
$BASESUFFIX="o=airius.com";
$LDIFFILE=$ENV{"IROOT"}."/ldif/Airius.ldif";
$TMPLDIFFILE=$ENV{"RESULTS"}."/a.ldif";

sub SampleStartState
{
print "hello";
my $testds = GetDsInst($ENV{"IROOT"});
$testds->setPW("secret12");
print "From Iroot".$testds->getPort()."\n";
print $testds->getHost()." ".$testds->getDN()." ".$testds->getPW()." ".$testds->
getPort()."\n";

 if ($testds->HasSuffix($BASESUFFIX))
  {  print "Already has suffix $BASESUFFIX";}
 else
  { if($testds->AddSuffix($BASESUFFIX) ne 1)
     { result("FAIL"); return 1;}
   }

if ($testds->Import($LDIFFILE) ne 0)
 {  result("FAIL"); return 1;}
    result("PASS");

}
sub
tp1
{
message("anonymous search uid=mlott");

$testds = GetDsInst($ENV{"IROOT"});
my $dn =$testds->getDN();
$testds->setPW("secret12");
$testds->setBase("o=airius.com");
$testds->setScope("LDAP_SCOPE_SUBTREE");
print "From Iroot".$testds->getPort()."\n";
print $testds->getHost()." ".$testds->getDN()." ".$testds->getPW()."\n";

if($testds->open() ne 0)
 {
    print "Counld not establish connection";
    return;
  }


while($e=$testds->ldapsearch("uid=mlott"))
{
   if($e eq -1) {
       $testds->printError();
                print "error stirng : ", $testds->getErrorString(), "\n";
                print "error code   : ", $testds->getErrorCode(), "\n";
                last;
     }
    else {
            $oufile= $ENV{"RESULTS"}."/acceptance_tp9.out";
            $f=">".$oufile;
            $srfile=$DATA."/DS/".$ENV{"VER"}."/acceptance/".$ENV{"CHARSET"}."/tp
9.in";
            $testds->writeLDIF($oufile);
           print "The two file :".$oufile ." ,".$srfile."\n";
            if (os_sortdiff($oufile,$srfile) ne 0) {
               message("exact search failed");
               result("FAIL");
            }
            else {  print "search passed";result("PASS"); }
        }
} # end of while

$testds->close();
}
use lib "$ENV{\"TESTING_SHARED\"}/DS/$ENV{\"VER\"}/perl";
use baserc;
use baselib;
use DsInst;
use applib;
require "$ENV{\"TET_ROOT\"}/lib/perl/tcm.pl";
require "$ENV{\"TET_ROOT\"}/lib/perl/api.pl";
