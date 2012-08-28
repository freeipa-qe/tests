# test data used by ipa autorenew cert test suite

dir=$( cd "$( dirname "$0" )" && pwd )

# prepare for storage directories for autorenew cert test
#TmpDir="$dir/tmp"
#testid=$RANDOM
#testdir="$TmpDir/autorenewcert/$testid"
#currentCertDir="$testdir/current"
#renewalCertDir="$testdir/renewal"

# helping tools used for this test
certconf="$dir/certs.conf"
readCert="$dir/readLoadedCert.pl"
readRenewalCert="$dir/readRenewalCert.pl"
sortlist="$dir/sortlist.pl"
grouplist="$dir/grouplist.pl"
countlist="$dir/countlist.pl"
difflist="$dir/difflist.pl"

ldapsearch="/usr/bin/ldapsearch"
host=`hostname`
domain=`hostname -d`
# assumption constances, need work FIXME
CAINSTANCE="pki-ca"
DSINSTANCE="YZHANG-REDHAT-COM"
CA_DSINSTANCE="PKI-IPA"
DN="cn=directory manager"
DNPW="Secret123"
ADMINPW="Secret123"

# constance used for cert autorenew test
sixdays=518400
oneday=86400 
halfday=43200
sixhour=21600
onehour=3600
halfhour=1800
wait4renew=10
maxwait=`echo "$wait4renew * 12" | bc`
continueTest="no"
# cert names
#allcerts="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaRAagentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd caJarSigningCert"
allcerts="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaRAagentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd"
notRenewedCerts="$allcerts"
soonTobeRenewedCerts=""
justRenewedCerts=""
renewedCerts=""
checkTestConditionRequired="true"
loglevel=debug #loglevel: info/debug
