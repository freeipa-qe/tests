#!/bin/bash
# This script was written to test ticket:
# https://engineering.redhat.com/trac/ipa-tests/ticket/278, aka:
# https://bugzilla.redhat.com/show_bug.cgi?id=783606
# Run the master-setup.bash script on the master, then run the run-on-slave.bash script on the replica 
. /opt/rhqa_ipa/env.sh
. /opt/rhqa_ipa/ipa-server-shared.sh

INFFILE=/opt/rhqa_ipa/ticket-278.inf
LDIFIN=./10.entries.example.dc.com.ldif
LDIFOUT=/opt/rhqa_ipa/import-278.ldif
NEWPORT=29719
# number of users to add to server for replication
maxusers=100

if [ ! -f /opt/rhqa_ipa/env.sh ]; then
	echo 'ERROR - Sorry, this script needs to be run on a IPA provisioned master from beaker'
	exit
fi

hostnames=$(hostname -s)
echo "Hostname is: " 
echo $BEAKERMASTER | grep $hostnames
if [ $? -ne 0 ]; then
	echo "ERROR - this script needs to be run on the beaker master, sorry."
	exit
fi

if [ "$SLAVE" == "" ]; then
	echo "ERROR - This test needs to be run on a master that has one slave replicated to it"
	exit
fi

echo "[General]
FullMachineName = $BEAKERMASTER
ServerRoot = /usr/lib64/dirsrv
SuiteSpotGroup = root
SuiteSpotUserID = root
[slapd]
AddOrgEntries = Yes
AddSampleEntries = Yes
HashedRootDNPwd = {SSHA}mjyyLDoeQWzyQydc2YQ+PhZVvha6wfpEdJL/yQ==
InstallLdifFile = suggest
RootDN = $ROOTDN
RootDNPwd = $ROOTDNPWD
ServerIdentifier = $hostnames
ServerPort = $NEWPORT
Suffix = $BASEDN
bak_dir = /var/lib/dirsrv/slapd-ipaqa64vme/bak
bindir = /usr/bin
cert_dir = /etc/dirsrv/slapd-$hostnames
config_dir = /etc/dirsrv/slapd-$hostnames
datadir = /usr/share
db_dir = /var/lib/dirsrv/slapd-$hostnames/db
ds_bename = userRoot
inst_dir = /usr/lib64/dirsrv/slapd-$hostnames
ldif_dir = /var/lib/dirsrv/slapd-$hostnames/ldif
localstatedir = /var
lock_dir = /var/lock/dirsrv/slapd-$hostnames
log_dir = /var/log/dirsrv/slapd-$hostnames
naming_value = testrelm
run_dir = /var/run/dirsrv
sbindir = /usr/sbin
schema_dir = /etc/dirsrv/slapd-$hostnames/schema
sysconfdir = /etc
tmp_dir = /tmp" > $INFFILE

/usr/sbin/setup-ds.pl --file=$INFFILE --silent
if [ $? -ne 0 ]; then
	echo "/usr/sbin/setup-ds.pl --file=$INFFILE --silent did not return 0, exiting"
	exit
fi

# make sure that the server was set up
/usr/bin/ldapsearch -x -h $hostnames -p $NEWPORT -D "$ROOTDN" -w $ROOTDNPWD -b "$BASEDN" $> /dev/null
if [ $? -ne 0 ]; then
	echo "/usr/bin/ldapsearch -x -h $hostnames -p $NEWPORT -D \"$ROOTDN\" -w $ROOTDNPWD -b \"$BASEDN\" did not work, please check."
	exit
fi

# add 1k users to new server
cat $LDIFIN > $LDIFOUT

# Add more users to the ldif file
x=11;
while [ $x -lt $maxusers ]; do
	echo "" >> $LDIFOUT
	echo "dn: uid=guest$x,ou=people,dc=example,dc=com
userCertificate;binary:: MIICgzCCAeygAwIBAgICA/YwDQYJKoZIhvcNAQEFBQAwKzELMAkG
 A1UEBhMCVVMxHDAaBgNVBAMTE0NlcnRpZmljYXRlIE1hbmFnZXIwHhcNMDcwNjExMDQ0NzM2WhcN
 MDcxMjA4MDQ0NzM2WjBBMRMwEQYKCZImiZPyLGQBGRYDY29tMQ8wDQYDVQQLEwZwZW9wbGUxGTAX
 BgoJkiaJk/IsZAEBEwlndWVzdDIwMTUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAOgmBgmt
 oXkFYYsLD9laKSkR7yBKqKVQvqn2auvaILeuwwN/sPke+X5+ijA+TN3XDLjDen9jgcJcVo3USEAz
 CfI/E20CJM5E3cfIVqHDg1jTPjwkaCUaIdJ1qhTq72krhEGm9nirt3cXlodDg+d9QY6qcS9fY2NG
 PMxGAJD3qaslAgMBAAGjgZ8wgZwwHwYDVR0jBBgwFoAUvL2ars4/XtSPVjNKv2gAtF2Ijn0wSgYI
 KwYBBQUHAQEEPjA8MDoGCCsGAQUFBzABhi5odHRwOi8vbXMtcmhlbDR1NS0yLnVzZXJzeXMucmVk
 aGF0LmNvbTo4MC9vY3NwMA4GA1UdDwEB/wQEAwIF4DAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYB
 BQUHAwQwDQYJKoZIhvcNAQEFBQADgYEAEzpnEzyuuQB8clPCeTeBIviXyc+8+xlazxPg9ZMejO0d
 iQQfQCm3ieENgKM3XpNkGom+j9h7jh8B4ALuPP/E319qFMWVvtDLTAJASF7he4Dwti1IEq/CmxYP
 adUS1I38fXPpYvtfOB0Ej0mNCXm8CJ1wON+4KHlWNsdtkFjKQ+U=
homeDirectory: /home/guests/guest3
gidNumber: 1000$x
uidNumber: 1000$x
loginShell: /bin/bash
shadowWarning: 7
shadowMax: 99999
shadowLastChange: 13670
userPassword: {crypt}$1$Qx4lUKuc$Vz0wk7roOV5gkS3REkqAZ0
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
objectClass: shadowAccount
mail: guest3@station16.example.com
sn: guest3
cn: guest3
uid: guest3
telephoneNumber: +1 111 222 3333
facsimileTelephoneNumber: +1 111 222 3333
mobile: +1 111 222 3333
roomNumber: 0123456789
carLicense: 6ZBC246
displayName: somedisplayname texttexttext texttexttext texttexttext
givenName: somegivenname texttexttext texttexttext texttexttext
initials: someinitials
title: manager, myslelf an others texttexttext texttexttext texttexttext
departmentNumber: 01234567$x
employeeNumber: 01234567$x
employeeType: full time texttexttext texttexttexttexttexttexttexttexttext
preferredLanguage: fr, en-gb;q=0.8, en;q=0.7" >> $LDIFOUT
	let x=$x+1;
done

# Fix the dn name in the ldif file
sed -i s/dc=example,dc=com/$BASEDN/g $LDIFOUT
sed -i s/example.com/$DOMAIN/g $LDIFOUT

/usr/bin/ldapadd -x -h $hostnames -p $NEWPORT -D "$ROOTDN" -w $ROOTDNPWD -f $LDIFOUT
if [ $? -ne 0 ]; then
	echo "ERROR - ldapadd did not work."
	echo "ran /usr/bin/ldapadd -x -h $hostnames -p $NEWPORT -D \"$ROOTDN\" -w $ROOTDNPWD -f $LDIFOUT"
fi

echo "kinit as admin"
KinitAsAdmin

echo $ROOTDNPWD | ipa-nis-manage disable

echo $ROOTDNPWD | ipa-compat-manage disable

chmod 777 /var/run/dirsrv

/sbin/service dirsrv restart

KinitAsAdmin

echo $ROOTDNPWD | ipa config-mod --enable-migration=TRUE
if [ $? -ne 0 ]; then echo "ERROR - enable migration did not seem to work"; fi

echo $ROOTDNPWD | ipa -d migrate-ds --user-container=ou=people ldap://$hostnames:$NEWPORT
if [ $? -ne 0 ]; then echo "ERROR - Migration step failed."; fi

ipa-replica-manage del $SLAVE
if [ $? -ne 0 ]; then echo "ERROR - Unable to remove $SLAVE from replicated server list."; fi

# repairing DNS for slave after it was removed
ipa dnsrecord-add $DOMAIN $SLAVE --a-rec=$SLAVEIP
# Determine reverse ip info
ipoc1=$(echo $SLAVEIP | cut -d\. -f1)
ipoc2=$(echo $SLAVEIP | cut -d\. -f2)
ipoc3=$(echo $SLAVEIP | cut -d\. -f3)
ipoc4=$(echo $SLAVEIP | cut -d\. -f4)
ipa dnsrecord-add $ipoc3.$ipoc2.$ipoc1.in-addr.arpa. $ipoc4 --ptr-rec=$SLAVE.

