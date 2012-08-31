# test data used by ipa autorenew cert test suite

dir=$( cd "$( dirname "$0" )" && pwd )
# helping tools used for this test
ldapsearch="/usr/bin/ldapsearch"
readCert="$dir/readLoadedCert.pl"
readRenewalCert="$dir/readRenewalCert.pl"
sortlist="$dir/sortlist.pl"
grouplist="$dir/grouplist.pl"
countlist="$dir/countlist.pl"
difflist="$dir/difflist.pl"
testResult="$dir/test.result.$RANDOM.txt"

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
allcerts="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaRAagentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd"
notRenewedCerts="$allcerts"
soonTobeRenewedCerts=""
justRenewedCerts=""
renewedCerts=""
checkTestConditionRequired="true"
