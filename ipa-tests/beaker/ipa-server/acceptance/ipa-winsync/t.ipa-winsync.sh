#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-winsync
#   Description: winsync test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
#   Date: June 14, 2012
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# AD values
. ./Config

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################

######################
#     Variables      #
######################
firstname="ipauser1"
surname="user"
userpw="Secret123"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACKAGE3="samba-common"
basedn=`getBaseDN`

slapd_dir="/etc/dirsrv/slapd-TESTRELM-COM"
ldap_conf="/etc/openldap/ldap.conf"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.winsync"
error_log="/var/log/dirsrv/slapd-TESTRELM-COM/errors"
binddn="cn=Administrator,cn=Users,dc=adrelm,dc=com"

create_ldif() {
# $1 first name # $2 Surname # $3 Username # $4 changetype (add, modify, delete)

cat > ADuser.ldif << EOF
dn: CN=$1 $2,CN=Users,DC=adrelm,DC=com
changetype: $4
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: $1 $2
sn: $2
givenName: $1
distinguishedName: CN=$1 $2,CN=Users,DC=adrelm,DC=com
name: $1 $2
sAMAccountName: $3
displayName: $1 $2
userPrincipalName: $3@adrelm.com
EOF
}

# Microsoft stores a quoted password in little endian UTF16 base64 encoded. Hence to generate the password, use the command:
#echo -n "\"Secret123\"" | iconv -f UTF8 -t UTF16LE | base64 -w 0

create_passwd_ldif() {
cat > ADuser_passwd.ldif << EOF
dn: CN=$1 $2,CN=Users,DC=adrelm,DC=com
changetype: modify
replace: unicodePwd
unicodePwd::IgBTAGUAYwByAGUAdAAxADIAMwAiAA==
EOF
}

# Modify userAccountControl
create_cntrl_ldif() {
cat > ADuser_cntrl.ldif << EOF
dn: CN=$1 $2,CN=Users,DC=adrelm,DC=com
changetype: modify
replace: userAccountControl
userAccountControl: $3
EOF
}

setup() {
rlPhaseStartTest "Setup for winsync sanity tests"

	# check for packages
pushd .
	for item in $PACKAGE1 $PACKAGE2 $PACKAGE3; do
        	rpm -qa | grep $item
        	if [ $? -eq 0 ] ; then
                	rlPass "$item package is installed"
        	else
                	rlFail "$item package NOT found!"
        	fi
	done

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	# stopping firewall
#	rlRun "service iptables stop"
	rlServiceStop "iptables"
	rlServiceStop "ip6tables"

popd
	# winsync setup #

	# Importing ADcert
	rlRun "certutil -A -i ADcert.cer -d $slapd_dir -n \"AD cert\" -t \"CT,,C\" -a"
	rlRun "certutil -L -d $slapd_dir | grep \"AD cert\"" 0 "Verifying AD cert is imported in db"
	# Adding conditional forwarder
	rlRun "cp -p $named_conf $named_conf_bkp" 0 "Backup $named_conf before adding conditional forwarder for AD"
	echo -e "\nzone \"$ADdomain\" IN {\n\ttype forward;\n\tforwarders { $ADip; };\n\tforward only;\n};" >> $named_conf
#	rlRun "service named restart"
	rlServiceStop "named"
	rlServiceStart "named"

	# Specifying TLS_CACERTDIR
	grep -q "TLS_CACERTDIR" $ldap_conf
	if [ $? -eq 0 ]; then
	  sed -i "s/.*TLS_CACERTDIR.*/TLS_CACERTDIR \/etc\/dirsrv\/slapd\-TESTRELM\-COM/" $ldap_conf
	else
	  echo "TLS_CACERTDIR $slapd_dir" >> $ldap_conf
	fi
	# Verify you can connect via TLS to ADS server
	rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$binddn\" -w $ADpasswd -b \"cn=Administrator,cn=users,dc=adrelm,dc=com\"" 0 "Verifying connection via TLS to ADS server"

	# Creating the Agreement
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADhost --binddn "$binddn" --bindpw Secret123 -v -p Secret123" 0 "Initializing Winsync Agreement"

	# Restart PassSync after winsync agreement is established
	rlRun "net rpc service stop PassSync -I $ADip -U administrator%Secret123"
	rlRun "net rpc service start PassSync -I $ADip -U administrator%Secret123" 0 "Restarting PassSync Service"

rlPhaseEnd
}

syncinterval_ldif() {
cat > syncinterval.ldif << EOF
dn: cn=meTo$ADhost,cn=replica,cn=dc\3Dtestrelm\2Cdc\3Dcom,cn=mapping tree,cn=config
changetype: modify
add: winSyncInterval
winSyncInterval: $1
EOF
}

errorlog_ldif() {
cat > errorlog.ldif << EOF
dn: cn=config
changetype: modify
replace: nsslapd-errorlog-level
nsslapd-errorlog-level: $1
EOF
}

winsync_test_0001() {

rlPhaseStartTest "winsync_test_0001: Change Winsync Interval from default 300 seconds"
	rlrun "errorlog_ldif 8192"
	rlrun "ldapmodify -x -D "cn=Directory Manager" -w Secret123 -f errorlog.ldif" 0 "Setting the error log level"
	rlRun "syncinterval_ldif 30"
	rlRun "ldapmodify -x -D "cn=Directory Manager" -w Secret123 -f syncinterval.ldif" 0 "Change winsync interval to 30 seconds"
	rlRun "sleep 310"
	x=`grep "Running Dirsync" $error_log | tail -n2 | head -1| awk -F: '{print $3}'`
	y=`grep "Running Dirsync" $error_log | tail -n1 | awk -F: '{print $3}'`
	z=`expr $y - $x | awk -F- '{print $NF}'`
	if [ $z -eq 5 ]; then
	 rlLogError "Winsync interval change did not take effect"
	 rlRun "service dirsrv restart" 0 "Restarting dirsrv for winsync interval change to take effect"
	 rlRun "sleep 75"
	 x=`grep "Running Dirsync" /var/log/dirsrv/slapd-TESTRELM-COM/errors | tail -n2 | head -1| awk -F: '{print $4}' | cut -f1 -d+`
	 y=`grep "Running Dirsync" /var/log/dirsrv/slapd-TESTRELM-COM/errors | tail -n1 | head -1| awk -F: '{print $4}' | cut -f1 -d+`
	 z=`expr $y - $x | awk -F- '{print $NF}'`
	 if [ $z -le 30 ]; then
	  rlLog "Winsync Interval Changed to 30 Seconds successfull"
	 else
	 
	else
	 
	rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=820258"

rlPhaseEnd
}
winsync_test_0002_a() {

rlPhaseStartTest "winsync_test_0002_a: Create users(numeric/alphanumeric) in AD"

	# Creating user in AD
	rlRun "create_ldif aduser1 ads aduser1 add" 0 "Generate ldif file to add user aduser1"
	rlRun "create_passwd_ldif aduser1 ads" 0 "Generate ldif file for setting passwd for aduser1"
	rlRun "create_cntrl_ldif aduser1 ads 512" 0 "Generate ldif file to enable user aduser1"
	rlRun "ldapmodify -h $ADhost -D "$binddn" -w Secret123 -f ADuser.ldif" 0 "Adding new user in AD aduser1"
	rlrun "ldapmodify -ZZ -h $ADhost -D "$binddn" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting aduser1 passwd"
	rlrun "ldapmodify -ZZ -h $ADhost -D "$binddn" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling aduser1"

	rlRun "create_ldif 456 ads 456 add" 0 "Generate ldif file to add user 456"
	rlRun "create_passwd_ldif 456 ads" 0 "Generate ldif file for setting passwd for 456"
	rlRun "create_cntrl_ldif 456 ads 512" 0 "Generate ldif file to enable user 456"
	rlRun "ldapmodify -h $ADhost -D "$binddn" -w Secret123 -f ADuser.ldif" 0 "Adding new user in AD 456"
	rlrun "ldapmodify -ZZ -h $ADhost -D "$binddn" -w Secret123 -f ADuser_passwd.ldif" 0 "Setting 456 passwd"
	rlrun "ldapmodify -ZZ -h $ADhost -D "$binddn" -w Secret123 -f ADuser_cntrl.ldif" 0 "Enabling user 456"

rlPhaseEnd
}


winsync_test_0003() {

rlPhaseStartTest "winsync_test_0002: User added in IPA is not replicated on AD"
	rlRun "create_ipauser $firstname $surname $firstname $userpw"
	sleep 5
	rlRun "ldapsearch -x -ZZ -h $ADhost -D "$binddn" -w Secret123 -b "cn=$firstname $surname,cn=users,dc=adrelm,dc=com"" 32 "IPA user sync on AD"

	# Test case cleanup
	rlRun "ipa user-del $firstname"
rlPhaseEnd
}

modify_ldif() {
cat > modify.ldif << EOF
dn: cn=ipa-winsync,cn=plugins,cn=config
changetype: modify
replace: ipawinsyncacctdisable
ipawinsyncacctdisable: $1
EOF
}
winsync_test_0004() {

rlPhaseStartTest "winsync_test_0003: Synchronization behaviour of account lock status"
	rlRun "modify_ldif both" 0 "Creating ldif file to set ipawinsyncacctdisable to both"
	rlRun "ldapmodify -x -D "cn=Directory Manager" -w Secret123 -f modify.ldif" 0 "Setting account disable sync to both"

	rlRun "modify_ldif none" 0 "Creating ldif file to set ipawinsyncacctdisable to none"
	rlRun "ldapmodify -x -D "cn=Directory Manager" -w Secret123 -f modify.ldif" 0 "Setting account disable sync to none"
	
rlPhaseEnd
}

cleanup() {

rlPhaseStartTest "Clean up for winsync sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0
#	rlRun "ipa user-del $user1"
	sleep 5
#	rlRun "ipa user-del $user2"
	rlRun "certutil -D -n \"AD cert\" -d /etc/dirsrv/slapd-TESTRELM-COM"
	rlRun "rm -f /etc/named.conf && cp -p /etc/named.conf.winsync /etc/named.conf" 0 "Replacing named.conf file from backup"
	rlRun "service named restart"
	rlRun "ipa-replica-manage disconnect melman.adrelm.com"
	rlRun "sed -i \"/^TLS_CACERTDIR.*/d\" /etc/openldap/ldap.conf"
	rlRun "rm -fr /tmp/krb5cc_1*"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	

rlPhaseEnd
}
