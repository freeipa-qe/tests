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
testResult="$TmpDir/test.result.$RANDOM.txt"

# constance used for cert autorenew test
threedays=259200
sixdays=518400
oneday=86400 
halfday=43200
sixhour=21600
onehour=3600
halfhour=1800
wait4renew=10
maxwait=`echo "$wait4renew * 12" | bc`
continueTest="no"
allcerts="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaAgentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd"
notRenewedCerts="$allcerts"
soonTobeRenewedCerts=""
justRenewedCerts=""
renewedCerts=""
checkTestConditionRequired="true"

#data storage used
certdata_notafter="$TmpDir/cert.data.not.after.sec.txt"

minRound=10
certRenewCounter=0

log_httpd="/var/log/httpd/error_log"
log_ldap_error="/var/log/dirsrv/slapd-*/errors"
log_ldap_access="/var/log/dirsrv/slapd-*/access"
log_sys="/var/log/messages"
log_krb5="/var/log/krb5kdc.log"
log_selinux="/var/log/audit/audit.log"
log_pkica="/var/log/pki-ca/debug /var/log/pki-ca/selftests.log /var/log/pki-ca/catalina.out /var/log/pki-ca/system /var/log/pki-ca/transactions"
logs="$log_sys $log_ldap_error $log_ldap_access $log_httpd $log_krb5 $log_selinux $log_pkica"

preservRecordFile="$TmpDir/preserve.records.conf"
