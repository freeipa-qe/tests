#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-winsync
#   Description: winsync test cases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <sgoveas@redhat.com>
#   Date  : June 14, 2012
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

# Install samba-common package if not already installed
rpm1="samba-common"
rpm2="rdesktop"

   rlCheckRpm "$rpm1"
	if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm1"
        fi

   rlCheckRpm "$rpm2"
        if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm2"
        fi
# Include test case file
. ./t.ipa-winsync.sh

PACKAGE="ipa-server"
##########################################
#   Sanity Tests
#########################################

	winsync_connect() {
		"winsync_test_0001"
		"winsync_test_0002"
		"winsync_test_0003"
		"winsync_test_0004"
		"winsync_test_0005"
		"winsync_test_0006"
		"winsync_test_0007"
		"winsync_test_0008"
		"winsync_test_0009"
		"winsync_test_0010"
		"winsync_test_0011"
		"winsync_test_0012"
		"winsync_test_0013"
		"winsync_test_0014"
		"winsync_test_0015"
	}

rlJournalStart

    rlPhaseStartSetup "ipa-winsync-startup: Check for admintools package, setup certificates."
		rlRun "setup"
    rlPhaseEnd

	# tests start...
winsync_connect
	# tests end...

    rlPhaseStartCleanup "ipa-winsync-cleanup: Destroying admin credentials & removing certificates."
		rlRun "cleanup"
    rlPhaseEnd


rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
