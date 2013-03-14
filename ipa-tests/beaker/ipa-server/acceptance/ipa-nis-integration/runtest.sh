#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA ipa-nis-integration acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Feb 01, 2012
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

. /opt/rhqa_ipa/nis.sh

# Force initialization of TESTORDER for rhts-sync for RHEL5
export TESTORDER=1

# Include test case files
for file in $(ls tests.d/t.*.sh); do
	. ./$file
done

PACKAGE="ipa-server"

startDate=`date "+%F %r"`
startEpoch=`date "+%s"`

export MASTER_IP=$(dig +short $MASTER)
if [ -z "$MASTER_IP" ]; then
	export MASTER_IP=$(getent ahostsv4 $MASTER | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export NISMASTER_IP=$(dig +short $NISMASTER)
if [ -z "$NISMASTER_IP" ]; then
	export NISMASTER_IP=$(getent ahostsv4 $NISMASTER | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export NISCLIENT_IP=$(dig +short $NISCLIENT)
if [ -z "$NISCLIENT_IP" ]; then
	export NISCLIENT_IP=$(getent ahostsv4 $NISCLIENT | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

case $HOSTNAME in
"$MASTER")    MYROLE="MASTER"    ;;
"$NISMASTER") MYROLE="NISMASTER" ;;
"$NISCLIENT") MYROLE="NISCLIENT" ;;
*)            MYROLE="UNKNOWN"   ;;
esac

MASTER_REAL=$MASTER
NISMASTER_REAL=$NISMASTER
NISCLIENT_REAL=$NISCLIENT


rlLog_hostnames()
{
	HOSTNAME=$(hostname)
	myhostname=`hostname`
	HOSTNAME_S=$(echo $HOSTNAME|cut -f1 -d.)
	hostmaster=$(host $MASTER 2>&1)
	hostnismaster=$(host $NISMASTER 2>&1)
	hostnisclient=$(host $NISCLIENT 2>&1)
	rlLog "hostname command : $myhostname"
	rlLog "HOSTNAME         : $HOSTNAME"
	rlLog "HOSTNAME_S       : $HOSTNAME_S"
	rlLog "------------------------------"
	rlLog "MASTER           : $MASTER"
	rlLog "MASTER_IP        : $MASTER_IP"
	rlLog "host MASTER      : $hostmaster"
	rlLog "------------------------------"
	rlLog "NISMASTER        : $NISMASTER"
	rlLog "NISMASTER_IP     : $NISMASTER_IP"
	rlLog "host NISMASTER   : $hostnismaster"
	rlLog "------------------------------"
	rlLog "NISCLIENT        : $NISCLIENT"
	rlLog "NISCLIENT_IP     : $NISCLIENT_IP"
	rlLog "host NISCLIENT   : $hostnisclient"
	rlLog "------------------------------"
	rlLog "NISDOMAIN        : $NISDOMAIN"
}

##########################################
#   test main 
#########################################

rlJournalStart
	rlPhaseStartSetup "ipa-nis-integration startup: Check for ipa-server package"
		#rlAssertRpm $PACKAGE
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
		rlRun "yum -y install openldap-clients"
		ENABLE_ETHERS=$(ldapsearch -h $MASTER_IP -xLLL -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=NIS Server,cn=plugins,cn=config" "nis-map=ethers.byaddr"|grep "dn: nis-domain=$DOMAIN+nis-map=ethers.byaddr"|wc -l)
		rlLog_hostnames
	rlPhaseEnd
	
	##############################################################
	# Initial Setup of servers
	##############################################################
	nisint_ipamaster_setup
	nisint_nismaster_setup
	nisint_nisclient_setup

	##############################################################
	# NIS Integration 
	##############################################################
	nisint_ipamaster_integration # Import NIS Maps/Data/Configuration...
	nisint_nisclient_integration # Switch NIS Config to point to IPA Master
	nisint_user_tests
	nisint_group_tests
	nisint_netgroup_tests
	nisint_automount_tests
	if [ $ENABLE_ETHERS -gt 0 ]; then
		nisint_ethers_tests
	fi
	nisint_client_is_nis_bz_tests

	##############################################################
	# NIS Migration
	##############################################################
	nisint_nisclient_migration # Switch NIS Client to use SSSD/IPA
	nisint_user_tests
	nisint_group_tests
	nisint_netgroup_tests
	nisint_automount_tests
	if [ $ENABLE_ETHERS -gt 0 ]; then
		nisint_ethers_tests
	fi
	nisint_client_is_ipa_bz_tests

	nisint_end
		
	rlPhaseStartCleanup "ipa-nis-integration cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd


# manifest:
