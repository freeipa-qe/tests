#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-get-rm-keytab
#   Description: ipa-getkeytab and ipa-rmkeytab acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date  : Dec 22, 2010
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./t.ipa-get-rm-keytab.sh

PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

getkeytab() {
"getkeytab_001"
"getkeytab_002"
"getkeytab_003"
"getkeytab_004"
"getkeytab_005"
"getkeytab_006"
"getkeytab_007"
}

rmkeytab() {
"rmkeytab_001"
"rmkeytab_002"
"rmkeytab_003"
}


rlJournalStart

    rlPhaseStartSetup "ipa-get-rm-keytab-startup: Check for admintools package and Kinit"
		rlRun "setup"
    rlPhaseEnd

	# tests start...
	getkeytab
	rmkeytab
	# tests end.

    rlPhaseStartCleanup "ipa-get-rm-keytab-cleanup: Destroying admin credentials."
		rlRun "cleanup"
    rlPhaseEnd

 rlJournalPrintText
 report=/tmp/rhts.report.$RANDOM.txt
 makereport $report
 rhts-submit-log -l $report
rlJournalEnd

