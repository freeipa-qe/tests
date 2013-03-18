#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-trust-cli
#   Description: IPA trust CLI test cases
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
#   Date: March 07, 2013
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

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`
########################################################################

######################
#     Variables      #
######################

ipainstall=`which ipa-server-install`
IPAhost=`hostname`
IPAhostIP=`ip addr | egrep 'inet ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAhostIP6=`ip addr | egrep 'inet6 ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAdomain="testrelm.com"
IPARealm="TESTRELM.COM"
srv_name=`hostname -s`
NBname="TESTRELM"
ipacmd=`which ipa`
trust_bin=`which ipa-adtrust-install`
newsuffix='dc=testrelm,dc=com'
DS_binddn="CN=Directory Manager"
DMpswd="Secret123"
slapd_dir="/etc/dirsrv/slapd-TESTRELM-COM"
ADcrt="ADcert.cer"
ADfn="New"
ADsn="user" 
ADln="nuser"
AD_binddn="CN=Administrator,CN=Users,$ADdc"
userpw="Secret123"

setup() {
rlPhaseStartSetup "Setup both ADS and IPA Servers for trust"
	# check for packages
	rlRun "rlDistroDiff ipa_pkg_check" 0 "Packages installed for current OS flavor"

	# stopping firewall
	rlServiceStop "iptables"
	rlServiceStop "ip6tables"

	# Setup both ADs with conditional forwarder for IPA domain
	./adsetup.exp add $ADadmin $ADpswd $ADip $IPAdomain $IPAhostIP
	./adsetup.exp add $ADadmin2 $ADpswd2 $ADip2 $IPAdomain $IPAhostIP

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "$ipacmd dnszone-add $ADdomain --name-server=$ADhost --admin-email='hostmaster@$ADdomain' --force --forwarder=$ADip --forward-policy=only" 0 "Adding forwarder for  $ADdomain"
	rlRun "$ipacmd dnszone-add $ADdomain2 --name-server=$ADhost2 --admin-email='hostmaster@$ADdomain2' --force --forwarder=$ADip2 --forward-policy=only" 0 "Adding forwarder for  $ADdomain2"
	sleep 30

	# Prepare IPA server for trust
	rlRun "$trust_bin -a $adminpw --netbios-name $NBname -U" 0 "Preparing server to establish trust"
	
	# Checking DNS records are in place or AD and IPA
	rlRun "dig +short SRV @$ADip _ldap._tcp.$IPAdomain | grep $IPAhost" 0 "Conditional forwarder for IPA server setup on $ADhost"
	rlRun "dig +short SRV @$ADip2 _ldap._tcp.$IPAdomain | grep $IPAhost" 0 "Conditional forwarder for IPA server setup on $ADhost2"

	rlRun "dig +short SRV _ldap._tcp.$ADdomain | grep $ADhost" 0 "Forwarder for $ADdomain setup"
	rlRun "dig +short SRV _ldap._tcp.$ADdomain2 | grep $ADhost2" 0 "Forwarder for $ADdomain2 setup"

	# Using valid AD cert
        rlRun "certutil -A -i $ADcrt -d $slapd_dir -n \"AD cert\" -t \"CT,C,C\" -a"
        rlRun "certutil -L -d $slapd_dir | grep \"AD cert\"" 0 "Verifying AD cert is imported in db"

        # Verify you can connect via TLS to ADS server
        rlRun "ldapsearch -x -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -b \"$AD_binddn\"" 0 "Verifying connection via TLS to ADS server"

	# Adding a user in AD
        rlRun "ADuser_ldif $ADfn $ADsn $ADln $userpw 512 add" 0 "Generate ldif file to add $ADln"
        rlRun "ldapmodify -ZZ -h $ADhost -D \"$AD_binddn\" -w $ADpswd -f ADuser.ldif" 0 "Adding new user in AD before winsync $ADln"

#	rlRun "create_ipauser $user test user $userpw"
#	rlRun "create_ipauser $user1 new user $userpw"
#	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
#	rlRun "$ipacmd group-add --desc Test-Group $group2" 0 "Adding a test group"


rlPhaseEnd
}

trust_test_0001() {

rlPhaseStartTest "0001 Add trust for invalid domain"
	rlRun "$ipacmd trust-add no-$ADdomain --admin $ADadmin --password"
rlPhaseEnd
}

trust_test_0002() {

rlPhaseStartTest "0002 Add trust with type and domain"

rlPhaseEnd
}

trust_test_0003() {

rlPhaseStartTest "0003 Give invalid server name in --server option"

rlPhaseEnd
}

trust_test_0004() {

rlPhaseStartTest "0004 Give password on CLI for --password"

rlPhaseEnd
}

trust_test_0005() {

rlPhaseStartTest "0005 Give user with no admin rights for --admin option"

rlPhaseEnd
}

trust_test_0006() {

rlPhaseStartTest "0006 trust-add interactively"

rlPhaseEnd
}

trust_test_0007() {

rlPhaseStartTest "0007 Trust add with minimum options on CLI"

rlPhaseEnd
}

trust_test_0008() {

rlPhaseStartTest "0008 Delete trust with invalid domain"

rlPhaseEnd
}

trust_test_0009() {

rlPhaseStartTest "0009 Delete trust interactively"

rlPhaseEnd
}

trust_test_0010() {

rlPhaseStartTest "0010 Add trust with --server option"

rlPhaseEnd
}

trust_test_0011() {

rlPhaseStartTest "0011 Delete trust with --continue and invalid domain"

rlPhaseEnd
}

trust_test_0012() {

rlPhaseStartTest "0012 Having existing AD trust add trust with a new domain"

rlPhaseEnd
}

trust_test_0013() {

rlPhaseStartTest "0013 Delete trust with --continue option"

rlPhaseEnd
}

trust_test_0014() {

rlPhaseStartTest "0014 Add trust with --trust-secret"

rlPhaseEnd
}

trust_test_0015() {

rlPhaseStartTest "0015 Add trust with --trust-secret with empty string"

rlPhaseEnd
}

trust_test_0016() {

rlPhaseStartTest "0016 Provide user with admin rights in --admin option"

rlPhaseEnd
}

trust_test_0017() {

rlPhaseStartTest "0017 Delete trust as a non-admin user"

rlPhaseEnd
}

trust_test_0018() {

rlPhaseStartTest "0018 Find trust for invalid domain"

rlPhaseEnd
}

trust_test_0019() {

rlPhaseStartTest "0019 Find trust with valid domain"

rlPhaseEnd
}

trust_test_0020() {

rlPhaseStartTest "0020 Find trust with --timelimit"

rlPhaseEnd
}

trust_test_0021() {

rlPhaseStartTest "0021 Find trust with --sizelimit"

rlPhaseEnd
}

trust_test_0022() {

rlPhaseStartTest "0022 Find trust with --pkey-only"

rlPhaseEnd
}

trust_test_0023() {

rlPhaseStartTest "0023 Show trust for invalid/non-existent domain"

rlPhaseEnd
}

trust_test_0024() {

rlPhaseStartTest "0024 Show trust for valid domain"

rlPhaseEnd
}

trust_test_0025() {

rlPhaseStartTest "0025 Show trust entries of Realm with --all and --raw"

rlPhaseEnd
}
