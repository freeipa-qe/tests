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
. ./t.ipa-sudo-func.sh

# Bugzilla regression automation
. ./bz-regression.sh

PACKAGE="ipa-server"

##########################################
#   Sanity Tests
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

	"sudorule_add_000"
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

	"sudorule-add-runasuser_001"
	"sudorule-add-runasuser_002"
	"sudorule-add-runasuser_003"

	"sudorule-remove-runasuser_001"
	"sudorule-remove-runasuser_002"
	"sudorule-remove-runasuser_003"
	"sudorule-remove-runasuser_004"
	"sudorule-remove-runasuser_005"

	"sudorule-add-runasgroup_001"
	"sudorule-add-runasgroup_002"

	"sudorule-remove-runasgroup_001"
	"sudorule-remove-runasgroup_002"

	"sudorule-mod_001"
	"sudorule-mod_002"
	"sudorule-mod_003"
	"sudorule-mod_004"
	"sudorule-mod_005"
	"sudorule-mod_006"
	"sudorule-mod_007"
	"sudorule-mod_008"
	"sudorule-mod_009"
	"sudorule-mod_010"
	"sudorule-mod_011"
	"sudorule-mod_012"
	"sudorule-mod_013"

	"sudorule-find_001"
	"sudorule-find_002"
	"sudorule-find_003"
	"sudorule-find_004"
	"sudorule-find_005"
	"sudorule-find_006"
	"sudorule-find_007"
	"sudorule-find_008"
	"sudorule-find_009"
	"sudorule-find_010"
	"sudorule-find_011"
	#"sudorule-find_012"
	"sudorule-find_013"
	"sudorule-find_014"

	"sudorule_del_001"
	"sudorule_del_002"
	"sudorule_del_003"

}

sanity() {
	"sudocmd"
	"sudocmdgroup"
	"sudorule"
}

bugs() {
	"bug711786"
	"bug710601"
	"bug710598"
	"bug710592"
	"bug710245"
	"bug710240"
}

functional() {
	"sudorule-add-allow-command_func001"
	"sudorule-add-allow-commandgrp_func001"
	"sudorule-remove-allow-command_func001"
	"sudorule-remove-allow-commandgrp_func001"
	"sudorule-add-deny-command_func001"
	"sudorule-remove-deny-command_func001"
	"sudorule-add-deny-commandgrp_func001"
	"sudorule-remove-deny-commandgrp_func001"
	##"sudorule-add-host_func001"
	##"sudorule-remove-host_func001"
	"sudorule-add-hostgrp_func001"
	"sudorule-remove-hostgrp_func001"
	##"sudorule-add-option_func001"
	##"sudorule-add-option_func002"
	"sudorule-add-option_func003"
	##"sudorule-remove-option_func001"
	##"sudorule-remove-option_func002"
	"sudorule-remove-option_func003"
	"sudorule-add-runasuser_func001"
	"sudorule-remove-runasuser_func001"
	"sudorule-add-runasuser_func002"
	"sudorule-remove-runasuser_func002"
	"sudorule-add-runasuser_func003"
	"sudorule-remove-runasuser_func003"
	"sudorule-add-runasuser_func004"
	"sudorule-remove-runasuser_func004"
	"sudorule-add-runasuser_func005"
#	"sudorule-remove-runasuser_func005" this test is invalid because of sudorule-add-runasuser_func005
	"sudorule-add-runasgroup_func001"
#	"sudorule-remove-runasgroup_func001" this test is invalid because of sudorule-add-runasgroup_func001
	"sudorule-disable_func001"
	"sudorule-enable_func001"
	"cleanup-func"
}

functional_client_offline() {
	"sudorule-offline-caching-allow-command"
	"sudorule-offline-caching-deny-command"
	"sudorule-offline-caching-runasuser-command"
	"sudorule-offline-caching-runasgroup-command"
	"sudorule-offline-caching-hostgroup-command"
	"sudorule-offline-caching-group"
	"sudorule-offline-caching-option"
	"disable-sudorule-offline-caching"
	"cleanup-func"
}

TESTORDER=0

rlJournalStart
	############## sudo cli sanity tests #############
	rlPhaseStartSetup "ipa-sudo-cli-sanity-tests-setup"
		env|sort
		rlLog "============================================"
		cat /dev/shm/env.sh
		rlLog "******* HOSTNAME = $HOSTNAME"
                rpm -q libsss_sudo
                if [ $? -eq 1 ];then
                 rlRun "yum install libsss_sudo -y" 0 "Installing libsss_sudo for communication between SUDO and SSSD"
                fi
	rlPhaseEnd

       
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa-sudo-cli-sanity-tests - cli regression and sanity tests for ipa sudo functionality"
		if [ $(hostname) = "$CLIENT" ]; then
			rlLog "rhts-sync-block -s '$TESTORDER.ipa_sudo.0' $BEAKERMASTER"
			rlRun "rhts-sync-block -s '$TESTORDER.ipa_sudo.0' $BEAKERMASTER"
		else
			setup
			# tests start...
			sudo_001
			sanity
			# tests end.
			cleanup
			
			rlLog "rhts-sync-set -s '$TESTORDER.ipa_sudo.0' -m $BEAKERMASTER"
			rlRun "rhts-sync-set -s '$TESTORDER.ipa_sudo.0' -m $BEAKERMASTER"
		fi
	rlPhaseEnd

	#rlPhaseStartCleanup "ipa-sudo-cli-sanity-tests-cleanup"
	#	rlLog
	#rlPhaseEnd

	############## sudo cli functional tests #############
	#rlPhaseStartTest "ipa-sudo-func-tests - functional tests for ipa sudo"
	#	rlLog
	#rlPhaseEnd

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa-sudo-func-tests - functional and bugzilla tests for ipa sudo"
		if [ $(hostname) = "$CLIENT" ]; then
			func_setup_sudoclient
                        functional_client_offline
			func_cleanup
			rlLog "rhts-sync-set -s '$TESTORDER.ipa_sudo_func.0' -m $BEAKERCLIENT"
			rlRun "rhts-sync-set -s '$TESTORDER.ipa_sudo_func.0' -m $BEAKERCLIENT"

			rlLog "rhts-sync-block -s '$TESTORDER.ipa_sudo_func.1' $BEAKERMASTER"
			rlRun "rhts-sync-block -s '$TESTORDER.ipa_sudo_func.1' $BEAKERMASTER"

		else
			# On MASTER wait for func_setup_sudoclient to complete on client first
			rlLog "rhts-sync-block -s '$TESTORDER.ipa_sudo_func.0' $BEAKERCLIENT"
			rlRun "rhts-sync-block -s '$TESTORDER.ipa_sudo_func.0' $BEAKERCLIENT"

			func_setup

			# tests start...
			functional
			bugs

			bug769491
			bug741604
			bug782976
			bug783286
			bug800537
			bug800544
			# tests end.

			func_cleanup

			rlLog "rhts-sync-set -s '$TESTORDER.ipa_sudo_func.1' -m $BEAKERMASTER" 
			rlRun "rhts-sync-set -s '$TESTORDER.ipa_sudo_func.1' -m $BEAKERMASTER"
		fi
	rlPhaseEnd

	#rlPhaseStartCleanup "ipa-sudo-func-cleanup: Destroying admin credentials & and disabling nis."
	#	rlLog
	#rlPhaseEnd

	rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report

rlJournalEnd

