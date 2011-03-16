#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/install-client-cli
#   Description: IPA Client Install and Uninstall tests
#   Author: Namita Krishnan <namita.krishnan@redhat.com>
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

# Include the data file to verify tests
. ./data.ipaclientinstall.acceptance

# Include test case file
. ../ipa-delegation/lib.ipadelegation.sh
. ./t.ipa-client-install.sh
. ./lib.ipaclientverify.sh


PACKAGE="ipa-client"
SERVICE="ipa_kpasswd"

##########################################
#   test main
#########################################

rlJournalStart
    rlPhaseStartSetup "ipadelegation startup: Check for ipa-server package"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd


	rlPhaseStartTest "Environment check"
		echo "$CLIENT" | grep "$HOSTNAME"
		if [ $? -eq 0 ]; then
			# This machine is a client
			rlLog "I am a client"
                        ipaclientinstall
		else
			echo "not a client, CLIENT is $CLIENT"
			echo "SLAVE list is $SLAVE, MASTER list is $MASTER, CLIENT list is $CLIENT"
		fi
	rlPhaseEnd

	rlPhaseStartCleanup
            # TODO: Should client be uninstalled at end of these tests.
            # But I do not have a setup piece....so maybe no cleanup piece
	rlPhaseEnd

#    rlPhaseStartCleanup "ipaclientinstall cleanup"
#        rlRun "popd"
#        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
#    rlPhaseEnd

rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report
rlJournalEnd 
