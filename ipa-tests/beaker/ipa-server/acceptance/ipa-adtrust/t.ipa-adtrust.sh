#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-adtrust
#   Description: Adtrust Install test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
#   Date: August 13, 2012
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
PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACKAGE3="ipa-server-trust-ad"
PACKAGE4="samba4-common"
PACKAGE5="expect"

exp=`which expect`
trust_bin=`which ipa-adtrust-install`
userpw="Secret123"
user="tuser"
adminpw="Secret123"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.adtrust"
krb5_conf="/etc/krb5.conf"
krb5_conf_bkp="/etc/krb5.conf.bkp"
AD_binddn="CN=Administrator,CN=Users,$ADdc"
DS_binddn="CN=Directory Manager"
SyncPlugin="cn=ipa-winsync,cn=plugins,cn=config"
IPAhost="`hostname`"
IPAhostIP="`host $IPAhost | awk '{print $NF}'`"
IPAdomain="testrelm.com"
NBname="TESTRELM"
rec1="_ldap._tcp.Default-First-Site-Name._sites.dc._msdcs"
rec2="_ldap._tcp.dc._msdcs"
rec3="_kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs"
rec4="_kerberos._tcp.dc._msdcs"
rec5="_kerberos._udp.Default-First-Site-Name._sites.dc._msdcs"
rec6="_kerberos._udp.dc._msdcs"
rec1re='\_ldap\.\_tcp\.Default\-First\-Site\-Name\.\_sites\.dc\.\_msdcs'
rec2re='\_ldap\.\_tcp\.dc\.\_msdcs'
rec3re='\_kerberos\.\_tcp\.Default\-First\-Site\-Name\.\_sites\.dc\.\_msdcs'
rec4re='\_kerberos\.\_tcp\.dc\.\_msdcs'
rec5re='\_kerberos\.\_udp\.Default\-\First\-\Site\-Name\.\_sites\.dc\.\_msdcs'
rec6re='\_kerberos\.\_udp\.dc\.\_msdcs'

setup() {
rlPhaseStartTest "Setup for adtrust sanity tests"
	# check for packages
	rlRun "rlDistroDiff ipa_pkg_check"

	# Checking other important pacakges	
	for item in $PACKAGE3 $PACKAGE4 $PACKAGE5; do
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

	# Adding conditional forwarder
        rlRun "cp -p $named_conf $named_conf_bkp" 0 "Backup $named_conf before adding conditional forwarder for AD"
        echo -e "\nzone \"$ADdomain\" IN {\n\ttype forward;\n\tforwarders { $ADip; };\n\tforward only;\n};" >> $named_conf
        rlServiceStop "named"
        rlServiceStart "named"
        sleep 30
        rlRun "host $ADhost"

	rlRun "./adsetup.exp add $ADadmin $ADpswd $ADip $IPAhost $IPAhostIP > /dev/null 2>&1" 0 "Adding conditional forwarder for IPA domain in ADS"

	rlRun "cp -p $krb5_conf $krb5_conf_bkp" 0 "Backup $krb5_conf"
	rlRun "sed \"s/\(dns_lookup_kdc\).*/\dns_lookup_kdc = true/\" $krb5_conf"
#	rlrun "setenforce 0" 0 "Setting selinux in permissive mode"

rlPhaseEnd
}


adtrust_test_0001() {

rlPhaseStartTest "0001 Adtrust install with lowercase netbios name"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 10 
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --netbios-name=testrelm" >> $expfile
	echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
	echo 'sleep .5' >> $expfile
	echo 'send -s -- "y\r"' >> $expfile
	echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "Illegal*NetBIOS*name*\[$var2\]*ASCII*\."
}' >> $expfile
	echo 'send_user "\nLowercase NetBios name not permitted.\n" ; exit 2' >> $expfile
        rlRun "$exp $expfile" 2 "Giving lowercase Netbios name fails as expected"
rlPhaseEnd
}

adtrust_test_0002() {

rlPhaseStartTest "0002 Adtrust install with netbios name starting or ending with dot/hyphen"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --netbios-name=.TESTME-" >> $expfile
        echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "Illegal*NetBIOS*name*\[$var2\]*ASCII*\."
}' >> $expfile
        echo 'send_user "\nNetBios name starting or ending with dot/hyphen is invalid.\n" ; exit 2' >> $expfile

        rlRun "$exp $expfile" 2 "Netbios name cannot start or end with dot/hyphen"
rlPhaseEnd
}

adtrust_test_0003() {

rlPhaseStartTest "0003 Adtrust install with special characters in Netbios name"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --netbios-name='Te!5@relm'" >> $expfile
        echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "Illegal*NetBIOS*name*\[$var2\]*ASCII*\."
}' >> $expfile
        echo 'send_user "\nNetBios name with special characters is invalid.\n" ; exit 2' >> $expfile

        rlRun "$exp $expfile" 2 "Netbios name cannot consist of special characters"
rlPhaseEnd
}

adtrust_test_0004() {

rlPhaseStartTest "0004 Adtrust install with random values in --ip-address"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
	echo 'set var1 [lindex $argv 0]' > $expfile
	echo 'set var2 [lindex $argv 1]' >> $expfile
	echo 'set timeout 5
	set send_slow {1 .1}' >> $expfile
	echo "spawn $trust_bin --\$var1=\"$var2\"" >> $expfile
	echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "error:*option*--ip-address:*invalid*IP*address"
}' >> $expfile
	echo 'send_user "\n$var2 is not a valid ip address\n" ; exit 2' >> $expfile

	rlRun "$exp $expfile ip-address 1234.10.10.10" 2 "IP Address 1234.10.10.10 exited with an error"
	rlRun "$exp $expfile ip-address 10.1234.10.10" 2 "IP Address 10.1234.10.10 exited with an error"
	rlRun "$exp $expfile ip-address 10.10.1234.10" 2 "IP Address 10.10.1234.10 exited with an error"
	rlRun "$exp $expfile ip-address 10.10.10.1234" 2 "IP Address 10.10.10.1234 exited with an error"
	rlRun "$exp $expfile ip-address abcd" 2 "Alphabets for IP address exited with an error"
	
rlPhaseEnd
}

adtrust_test_0005() {

rlPhaseStartTest "0005 Adtrust install with empty string in --ip-address"
	rlRun "$exp $expfile ip-address \"\"" 2 "Empty quotes exited with an error"
        rlRun "$exp $expfile ip-address \" \"" 2 "Empty string exited with an error"

rlPhaseEnd
}

adtrust_test_0006() {

rlPhaseStartTest "0006 Adtrust install with wrong IP address"
	
#	rlRun "ip addr | egrep \'inet \' | grep eth0 | cut -f1 -d/ | awk \'{print $NF}\'"
	rlRun "echo \"IPA server IP is $IPAhostip\", but using and invalid IP to configure adtrust"
        rlRun "$exp $expfile ip-address 10.25.11.21" 2 "10.25.11.21 does not belong to this server. Adtrust install failed as expected"

rlPhaseEnd
}

adtrust_test_0007() {

rlPhaseStartTest "0007 Adtrust install with invalid IPv6 address"
	V6IP=`ip addr | egrep 'inet6 ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
	invalid_V6IP="3632:51:0:c41c:7054:ff:ae3c:c981"
	rlRun "echo \"Server IPv6 address is $V6IP, but using an invalid IPv6 address to configure adtrust\""
	rlRun "$exp $expfile ip-address \"$invalid_V6IP\"" 2 "Invalid IPv6 Address exited with an error"

rlPhaseEnd
}

adtrust_test_0008() {

rlPhaseStartTest "0008 Adtrust install with invalid IP Address but valid Netbios Name and vice versa"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
	echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set var3 [lindex $argv 2]' >> $expfile
        echo 'set var4 [lindex $argv 3]' >> $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' >> $expfile
        echo "spawn $trust_bin --\$var1=\$var2 --\$var3=\"\$var4\"" >> $expfile
	echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "error:*option*--ip-address:*invalid*IP*address" {
     send_user "\n$var2 is not a valid ip address\n" ; exit 2 }
  "Overwrite smb.conf?*:*" {
     send -s -- "y\r"
     expect "Illegal*NetBIOS*name*\[$var4\]*ASCII*\."
     send_user "\n Invalid Netbios name \"$var4\" fails as expected\n" ; exit 2 }' >>  $expfile

	rlRun "$exp $expfile ip-address 10.31.10.0 netbios-name TESTRELM" 2 "Valid Netbios-name and Invalid IP Address fails"
	rlRun "$exp $expfile ip-address $IPAhostIP netbios-name TESTrELm" 2 "Valid IP Address and Invalid Netbios Name fails"

rlPhaseEnd
}

adtrust_test_0009() {

rlPhaseStartTest "0009 Adtrust install as a non-root user"
	rlRun "create_ipauser test user tuser $userpw"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
	echo 'set timeout 10
	set send_slow {1 .1}' > $expfile
	echo "spawn ssh -o StrictHostKeychecking=no -l $user $IPAhost" >> $expfile
	echo 'expect "*password:*"' >> $expfile
	echo 'sleep .5' >> $expfile
	echo "send -s -- \"$userpw\\r\"" >> $expfile
	echo 'expect "*$ "' >> $expfile
	echo "send -s -- \"$trust_bin\\r\"" >> $expfile
	echo 'expect "Must*be*root*" {' >> $expfile
	echo 'send_user "\nUser is not root\n" ; exit 2 }' >> $expfile
	echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 2 "Failed as expected. Must be root to setup AD trusts on server"
rlPhaseEnd
}

adtrust_test_0010() {

rlPhaseStartTest "0010 Adtrust install by a user with administrative privileges"
	rlRun "ipa group-add-member --users=$user admins" 0 "Adding tuser to the admins group"
	rlRun "$exp $expfile" 2 "Failed as expected. Still need to be root to setup AD trusts"

rlPhaseEnd
}

adtrust_test_0011() {

rlPhaseStartTest "0011 Adtrust with invalid value for RID"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 10
        set send_slow {1 .1}
        spawn /bin/bash
        expect "*#"' > $expfile
        echo "send \"$trust_bin --rid-base=RIDBase\r\"" >> $expfile
        echo 'expect "invalid integer value:*"
        expect "*#" {' >> $expfile
        echo "send \"$trust_bin --rid-base=63.3\r\"" >> $expfile
        echo 'expect "invalid integer value:*" }' >> $expfile
        echo 'send_user "\n\nOnly intergers accepted\n" ; exit 2' >> $expfile

	rlRun "$exp $expfile" 2 "--rid-base only accepts integers"

rlPhaseEnd
}

adtrust_test_0012() {

rlPhaseStartTest "0012 Adtrust with invalid value for Secondary RIDs"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
	echo 'set timeout 10
        set send_slow {1 .1}
        spawn /bin/bash
        expect "*#"' > $expfile
        echo "send \"$trust_bin --secondary-rid-base=SRIDBase\r\"" >> $expfile
        echo 'expect "invalid integer value:*"
        expect "*#" {' >> $expfile
        echo "send \"$trust_bin --secondary-rid-base=23.7\r\"" >> $expfile
        echo 'expect "invalid integer value:*" }' >> $expfile
        echo 'send_user "\n\nOnly intergers accepted\n"; exit 2' >> $expfile

        rlRun "$exp $expfile" 2 "--secondary-rid-base only accepts integers"
rlPhaseEnd
}

adtrust_test_0011() {

rlPhaseStartTest "0011 Adtrust install without creating DNS Service records"
local expfile_dns=/tmp/adtrust_install_dns.exp
#        rm -rf $expfile
	echo 'set timeout 300
	set send_slow {1 .1}' > $expfile
	echo "spawn $trust_bin --no-msdcs" >> $expfile
	echo 'expect "*]: "' >> $expfile
	echo 'send -s -- "y\r"' >> $expfile
	echo 'expect "*]: "' >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect "*assword: "' >> $expfile
	echo "send -s -- \"$adminpw\r\"" >> $expfile
	echo 'expect {
    timeout { send_user "\nExpected message not received\n"; exit 1 }
    eof { send_user "\nSome issue\n"; exit 1 }
        echo "Setup*complete" {
        expect "DNS*management*was*not*enabled"' >> $expfile
        echo "expect '$rec1re'" >> $expfile
        echo "expect '$rec2re'" >> $expfile
        echo "expect '$rec3re'" >> $expfile
        echo "expect '$rec4re'" >> $expfile
        echo "expect '$rec5re'" >> $expfile
        echo "expect '$rec6re'" >> $expfile
        echo '} }
        send_user "\nAdtrust installed successfully without service records\n"  
        expect eof' >> $expfile

        rlRun "$exp $expfile_dns" 0 "Running $trust_bin with --no-msdcs option"

#	for i in $rec1 $rec2 $rec3 $rec4 $rec5 $rec6; do
#	rlRun "ipa dnsrecord-find $IPAdomain $i" 2 "$i SRV record not created as expected"
#	done

rlPhaseEnd
}

adtrust_test_0012() {

rlPhaseStartTest "0012 Install adtrust without options on CLI"
local expfile=/tmp/adtrust_install.exp
	rm -rf $expfile
	echo 'set timeout 300
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
        echo 'expect {
    timeout { send_user "\nExpected message not received\n"; exit 1 }
    eof { send_user "\nSome issue\n"; exit 1 }
        "Setup*complete" { expect "*#" }
 }
  send_user "\nAdtrust installed successfully in interactive mode\n"
  exit 0' >> $expfile

	rlRun "$exp $expfile" 0 "Running $trust_bin without cli options"
	if [ $? -eq 0 ]; then
	  for i in $rec{1..6}; do
            rlRun "ipa dnsrecord-find $IPAdomain $i" 0 "$i SRV record created"
	  done
	fi
rlPhaseEnd
}

adtrust_test_0013() {

rlPhaseStartTest "0013 Adtrust install with uppercase alphanumeric netbios name"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 300
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --netbios-name=$NBname" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
        "Setup*complete" { expect "*#" }
}' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
	rlRun "$exp $expfile" 0 "ADtrust installed with uppercase alphanumberic netbios name"
rlPhaseEnd
}

adtrust_test_0014() {

rlPhaseStartTest "0014 Adtrust install with valid IP Address"
local expfile=/tmp/adtrust_install.exp
	rm -rf $expfile
	echo 'set timeout 300
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --ip-address=$IPAhostIP" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
        "Setup*complete" { expect "*#" }
}' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
	rlRun "$exp $expfile" 0 "ADtrust installed with valid server IPv4 address"

rlPhaseEnd
}

adtrust_test_0015() {

rlPhaseStartTest "0015 Adtrust install with valid IP Address and Netbios Name on CLI"
local expfile=/tmp/adtrust_install.exp
	rm -rf $expfile
	echo 'set timeout 300
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --ip-address=$IPAhostIP --netbios-name=$NBname" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
        "Setup*complete" { expect "*#" }
}' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
	rlRun "$exp $expfile" 0 "ADtrust installed with valid server IPv4 address and Netbios name."

rlPhaseEnd
}
cleanup() {

rlPhaseStartTest "Clean up for adtrust sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "rm -f $named_conf && cp -p $named_conf_bkp $named_conf" 0 "Restoring $named_conf file from backup"
	rlServiceStop "named"
        rlServiceStart "named"

	rlRun "sed -i \"/^TLS_CACERTDIR.*/d\" /etc/openldap/ldap.conf"

	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "rm -fr /tmp/krb5cc_*"

rlPhaseEnd
}
