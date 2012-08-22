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
rec1="kerberos._tcp.dc._msdcs"
rec2="_kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs"
rec3="_ldap._tcp.dc._msdcs"

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

rlPhaseEnd
}

adtrust_test_0001() {

rlPhaseStartTest "0001 Adtrust install without creating DNS Service records"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --no-msdcs" >> $expfile
        echo 'expect "*]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "\r"' >> $expfile
        echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 0 "Running $trust_bin with --no-msdcs option"

	for i in $rec1 $rec2 $rec3; do
	rlRun "ipa dnsrecord-find $IPAdomain $i" 2 "$i SRV record not created as expected"
	done

rlPhaseEnd
}

adtrust_test_0002() {

rlPhaseStartTest "0002 Install adtrust without options on CLI"
local expfile=/tmp/adtrust_install.exp
	rm -rf $expfile
	echo 'set timeout 30
	set send_slow {1 .1}' > $expfile
	echo "spawn $trust_bin" >> $expfile
	echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
	echo 'expect "*]: "' >> $expfile
	echo 'sleep .5' >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect eof ' >> $expfile
	
	rlRun "$exp $expfile" 0 "Running $trust_bin without cli options"

	for i in $rec1 $rec2 $rec3; do
        rlRun "ipa dnsrecord-find $IPAdomain $i" 0 "$i SRV record created"
        done
rlPhaseEnd
}

adtrust_test_0003() {

rlPhaseStartTest "0003 Adtrust install with netbios name"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --netbios-name=TESTRELM" >> $expfile
	echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
	echo 'sleep .5' >> $expfile
	echo 'send -s -- "y\r"' >> $expfile
	echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 0 "Running $trust_bin giving Netbios name"
rlPhaseEnd
}

adtrust_test_0004() {

rlPhaseStartTest "0004 Adtrust install with Preferred/Invalid Netbios Name"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --netbios-name=TESTME" >> $expfile
        echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 0 "Running $trust_bin giving Preferred/Invalid Netbios name"
rlPhaseEnd
}

adtrust_test_0005() {

rlPhaseStartTest "0005 Adtrust install with IP Address"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --ip-address=$IPAhostIP" >> $expfile
	echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
	echo 'expect "*]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "\r"' >> $expfile
        echo 'expect eof ' >> $expfile

	rlRun "$exp $expfile" 0 "Running $trust_bin giving IP Address"
rlPhaseEnd
}

adtrust_test_0006() {

rlPhaseStartTest "0006 Adtrust install with wrong IP Address"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --ip-address=10.65.10.10" >> $expfile
        echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 2 "Running $trust_bin giving wrong IP Address failed as expected"

rlPhaseEnd
}

adtrust_test_0007() {

rlPhaseStartTest "0007 Adtrust install with both IP Address and Netbios Name on CLI"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin --ip-address=$IPAhostIP --netbios-name=TESTRELM -U" >> $expfile
	echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 0 "Running $trust_bin giving both valid IP Address and Netbios Name"
rlPhaseEnd
}

adtrust_test_0008() {

rlPhaseStartTest "0008 Adtrust install as a non-root user"
	rlRun "create_ipauser test user tuser $userpw"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn ssh -l tuser $IPAhost" >> $expfile
	echo 'expect "*password:*"' >> $expfile
	echo 'sleep .5' >> $expfile
        echo "send -s -- \"$userpw\\r\"" >> $expfile
	echo 'expect "*$ "' >> $expfile
	echo "send -s -- \"$trust_bin\\r\"" >> $expfile
	echo 'expect eof ' >> $expfile

        rlRun "$exp $expfile" 1 "Failed as expected. Must be root to setup AD trusts on server"
rlPhaseEnd
}

adtrust_test_0009() {

rlPhaseStartTest "0009 Adtrust install after kdestroy should ask for admin password"
	rlRun "kdestroy" 0 "Destroying admin credentials."
        rlRun "rm -fr /tmp/krb5cc_*"
local expfile=/tmp/adtrust_install.exp
        rm -rf $expfile
        echo 'set timeout 30
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin" >> $expfile
	echo 'expect "*password:*"' >> $expfile
	echo "send -s -- \"$adminpw\\r\"" >> $expfile
	echo 'expect "Overwrite smb.conf? [no]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
	echo 'expect "*]: "' >> $expfile
        echo 'sleep .5' >> $expfile
        echo 'send -s -- "\r"' >> $expfile
	echo 'expect eof ' >> $expfile

	rlRun "$exp $expfile" 0 "Adtrust install after kdestroy asks for admin password"
rlPhaseEnd
}

adtrust_test_0010() {

rlPhaseStartTest "0010 "

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
