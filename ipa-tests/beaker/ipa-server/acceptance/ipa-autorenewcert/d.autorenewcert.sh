# test data used by ipa autorenew cert test suite

dir=$( cd "$( dirname "$0" )" && pwd )

# prepare for storage directories for autorenew cert test
TmpDir="$dir/tmp"
testid=$RANDOM
testdir="$TmpDir/autorenewcert/$testid"
currentCertDir="$testdir/current"
renewalCertDir="$testdir/renewal"

# helping tools used for this test
certconf="$dir/certs.conf"
readCert="$dir/readLoadedCert.pl"
readRenewalCert="$dir/readRenewalCert.pl"
sortlist="$dir/sortlist.pl"
grouplist="$dir/grouplist.pl"
countlist="$dir/countlist.pl"
difflist="$dir/difflist.pl"

# assumption constances, need work FIXME
CAINSTANCE="pki-ca"
DSINSTANCE="YZHANG-REDHAT-COM"
CA_DSINSTANCE="PKI-IPA"
DN="cn=directory manager"

# constance used for cert autorenew test
oneday=86400 
halfday=43200
onehour=3600
halfhour=1800
wait4renew=30
maxwait=`echo "$wait4renew * 3" | bc`
numofround=1
continueTest="no"
# cert names
allcerts="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaRAagentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd caJarSigningCert"
soonTobeRenewedCerts=""
justRenewedCerts=""
renewedCerts=""
sortedValidCerts=""
