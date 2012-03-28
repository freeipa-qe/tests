#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/forms-cli
#   Description: IPA DNS acceptance tests to test usage of kerberos forms.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#   Date  : Jan 21, 2011
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

PACKAGE="ipa-server"

# Init master var
export master=0;

hostname_s=$(hostname -s)

##########################################
#   test main 
#########################################

# Determine if this is a master

if [ "$MASTER" = "$HOSTNAME" ]; then 
	export master=1;
fi

rlJournalStart
    rlPhaseStartSetup "forms-cli startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

    rlPhaseEnd

	rlPhaseStartTest "Installing rpcbind yptools"
		yum -y install wget rpcbind
	rlPhaseEnd

# all testing should be with selinux enforcing!
#if [ $master -eq 1 ]; then
#	setenforce 0
#fi

	# Determine my IP address
	currenteth=$(route | grep ^default | awk '{print $8}')

	# get the ip address of that interface
	ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
	echo "Ip address is $ipaddr"
	ipoc1=$(echo $ipaddr | cut -d\. -f1) 
	ipoc2=$(echo $ipaddr | cut -d\. -f2) 
	ipoc3=$(echo $ipaddr | cut -d\. -f3) 
	ipoc4=$(echo $ipaddr | cut -d\. -f4) 

	rlPhaseStartTest "forms-cli-01: "

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=804562"
		rlLog "closes https://engineering.redhat.com/trac/ipa-tests/ticket/376"

		verifyErrorMsg "ipa dnsrecord-add $DOMAIN dns176 --ns-hostname=ns1.shanks.$DOMAIN" "ipa: ERROR: Nameserver 'ns1.shanks.$DOMAIN' does not have a corresponding A/AAAA record"

        rlPhaseEnd

	rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report

rlJournalEnd
