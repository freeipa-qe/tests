#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-sudo
#   Description: sudo test cases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date  : May 23, 2011
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

# Include test case file
. ./t.ipa-sudo.sh

PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

sudocmd() {
"sudocmd_001"
"sudocmd_002"
"sudocmd_003"
"sudocmd_004"
"sudocmd_005"
"sudocmd_006"
"sudocmd_007"
"sudocmd_008"
"sudocmd_009"
"sudocmd_010"
}

sudocmdgroup() {
"sudocmdgroup_001"
"sudocmdgroup_002"
"sudocmdgroup_003"
"sudocmdgroup_004"
"sudocmdgroup_005"
"sudocmdgroup_006"
"sudocmdgroup_007"
"sudocmdgroup_008"
"sudocmdgroup_009"
"sudocmdgroup_010"
"sudocmdgroup_011"
"sudocmdgroup_012"
"sudocmdgroup_013"
"sudocmdgroup_014"
"sudocmdgroup_015"
}

sudorule() {
"sudorule_001"

"sudorule_add_001"
"sudorule_add_002"
"sudorule_add_003"
"sudorule_add_004"
"sudorule_add_005"
"sudorule_add_006"
"sudorule_add_007"
"sudorule_add_008"
"sudorule_add_009"

"sudorule-add-allow-command_001"
"sudorule-remove-allow-command_001"
"sudorule-add-allow-command_002"
"sudorule-remove-allow-command_002"
"sudorule-add-allow-command_003"
"sudorule-remove-allow-command_003"

"sudorule-add-host_001"
"sudorule-add-host_002"
"sudorule-add-host_003"
"sudorule-add-host_004"
"sudorule-add-host_005"
"sudorule-add-host_006"

"sudorule-remove-host_001"
"sudorule-remove-host_002"
"sudorule-remove-host_003"
"sudorule-remove-host_004"
"sudorule-remove-host_005"
"sudorule-remove-host_006"

"sudorule_enable_flag_001"
"sudorule_enable_flag_002"

"sudorule-add-user_001"
"sudorule-add-user_002"
"sudorule-add-user_003"

"sudorule-remove-user_001"
"sudorule-remove-user_002"
"sudorule-remove-user_003"

"sudorule-show_001"
"sudorule-show_002"
"sudorule-show_003"
"sudorule-show_004"
"sudorule-show_005"

"sudorule-add-option_001"
"sudorule-add-option_002"
"sudorule-add-option_003"
"sudorule-add-option_004"

"sudorule-remove-option_001"
"sudorule-remove-option_002"
"sudorule-remove-option_003"
"sudorule-remove-option_004"

"sudorule_del_001"
"sudorule_del_002"
"sudorule_del_003"
}

rlJournalStart

    rlPhaseStartSetup "ipa-sudo-startup: Check for admintools package, kinit and enabling nis"
#		rlRun "setup"
		rlRun "echo setup"
    rlPhaseEnd

	# tests start...
sudo_001
sudocmd
sudocmdgroup
sudorule
	# tests end.

    rlPhaseStartCleanup "ipa-sudo-cleanup: Destroying admin credentials & and disabling nis."
#		rlRun "cleanup"
		rlRun "echo cleanup"
    rlPhaseEnd

rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
