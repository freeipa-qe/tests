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

named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.winsync"
AD_binddn="CN=Administrator,CN=Users,$ADdc"
DS_binddn="CN=Directory Manager"
SyncPlugin="cn=ipa-winsync,cn=plugins,cn=config"

setup() {
rlPhaseStartTest "Setup for winsync sanity tests"
	# check for packages
pushd .
	for item in $PACKAGE1 $PACKAGE2 $PACKAGE3 $PACKAGE4 $PACKAGE5; do
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
	# Adding conditional forwarder
        rlRun "cp -p $named_conf $named_conf_bkp" 0 "Backup $named_conf before adding conditional forwarder for AD"
        echo -e "\nzone \"$ADdomain\" IN {\n\ttype forward;\n\tforwarders { $ADip; };\n\tforward only;\n};" >> $named_conf
        rlServiceStop "named"
        rlServiceStart "named"
        sleep 30
        rlRun "host $ADhost"

rlPhaseEnd
}

cleanup() {

rlPhaseStartTest "Clean up for winsync sanity tests"

	rlRun "kinitAs $ADMINID $ADMINPW" 0

	rlRun "certutil -D -n \"AD cert\" -d /etc/dirsrv/slapd-TESTRELM-COM"

	rlRun "rm -f /etc/named.conf && cp -p /etc/named.conf.winsync /etc/named.conf" 0 "Replacing named.conf file from backup"
	rlRun "service named restart"

#	rlRun "kill -15 `pidof rdesktop`"
	rlRun "rm -f *.ldif"
	rlRun "rm -f $ipacrt"
	rlRun "rm -fr $TmpDir"

	rlRun "sed -i \"/^TLS_CACERTDIR.*/d\" /etc/openldap/ldap.conf"

	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "rm -fr /tmp/krb5cc_*"

rlPhaseEnd
}
