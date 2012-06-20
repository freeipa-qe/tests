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
user1="user1"
user2="user2"
userpw="Secret123"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACKAGE3="samba-common"
basedn=`getBaseDN`

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

	# kinit as admin and creating users
#	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
#	rlRun "create_ipauser $user1 $user1 $user1 $userpw"
#	sleep 5
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
#	rlRun "create_ipauser $user2 $user2 $user2 $userpw"
#        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
#        rlRun "pushd $TmpDir"

	# stopping firewall
	rlRun "service iptables stop"

popd
	# winsync setup #

	# Importing ADcert
	rlRun "certutil -A -i ADcert.cer -d /etc/dirsrv/slapd-TESTRELM-COM/ -n \"AD cert\" -t \"CT,,C\" -a"
	# Adding conditional forwarder
	rlRun "cp -p /etc/named.conf /etc/named.conf.winsync" 0 "Backup named.conf before adding conditional forwarder for AD"
	echo -e "\nzone \"adrelm.com\" IN {\n\ttype forward;\n\tforwarders { $ADIP; };\n\tforward only;\n};" >> /etc/named.conf
	rlRun "service named restart"

	# Specifying TLS_CACERTDIR
	grep -q "TLS_CACERTDIR" /etc/openldap/ldap.conf
	if [ $? -eq 0 ]; then
	  sed -i "s/.*TLS_CACERTDIR.*/TLS_CACERTDIR \/etc\/dirsrv\/slapd\-TESTRELM\-COM/" /etc/openldap/ldap.conf
	else
	  echo "TLS_CACERTDIR /etc/dirsrv/slapd-TESTRELM-COM/" >> /etc/openldap/ldap.conf
	fi
	# Verify you can connect via TLS to ADS server
	rlRun "ldapsearch -x -ZZ -h melman.adrelm.com -D \"cn=Administrator,cn=users,dc=adrelm,dc=com\" -w Secret123 -b \"cn=Administrator,cn=users,dc=adrelm,dc=com\"" 0 "Verifying connection via TLS to ADS server"

	# Creating the Agreement
	rlRun "ipa-replica-manage connect --winsync --passsync=password --cacert=ADcert.cer $ADHost --binddn "cn=Administrator,cn=Users,dc=adrelm,dc=com" --bindpw Secret123 -v -p Secret123" 0 "Initializing Winsync Agreement"

	# Restart PassSync after winsync agreement is established
	rlRun "net rpc service stop PassSync -I $ADIP -U administrator%Secret123"
	rlRun "net rpc service start PassSync -I $ADIP -U administrator%Secret123" 0 "Restarting PassSync Service"

rlPhaseEnd
}

winsync_connect_0001() {

rlPhaseStartTest "winsync_connect_0001: "
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        #rlRun "pushd $TmpDir"
	rlRun "certutil -L -d /etc/dirsrv/slapd-TESTRELM-COM | grep \"AD cert\"" 0 "Verifying AD cert is imported in db"

	# Test case cleanup
	rlRun "rm -fr $TmpDir" 
#	rlRun "popd"
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
