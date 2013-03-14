#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-automount
#   Description: automount configuration tests for autofs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date  : May 9, 2011
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
. ./t.ipa-automount.sh
. ./t.ipa-automount-func.sh

PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

automount_help() {
	"automount_001"
	"automount_002"
	"automount_003"
	"automount_004"
	"automount_005"
	"automount_006"
	"automount_007"
	"automount_008"
	"automount_009"
	"automount_010"
	"automount_011"
	"automount_012"
	"automount_013"
	"automount_014"
	"automount_015"
	"automount_016"
	"automount_017"
	"automount_018"
	"automount_019"
}

automount_location_add() {
	"automount_location_add_001"
	"automount_location_add_002"
	"automount_location_add_003"
}

automount_location_find() {
	"automount_location_find_001"
	"automount_location_find_002"
	"automount_location_find_003"
	"automount_location_find_004"
	"automount_location_find_005"
}

automount_location_show() {
	"automount_location_show_001"
	"automount_location_show_002"
	"automount_location_show_003"
	"automount_location_show_004"
}

automount_location_del() {
	"automount_location_del_001"
	"automount_location_del_002"
}
automount_map_add() {
	"automountmap_add_001"
	"automountmap_add_002"
	"automountmap_add_003"
	"automountmap_add_004"
	"automountmap_add_005"
	"automountmap_add_006"
	"automountmap_add_007"
	"automountmap_add_008"
}

automountmap_find() {
	"automountmap_find_001"
	"automountmap_find_002"
	"automountmap_find_003"
	"automountmap_find_004"
	"automountmap_find_005"
}

automountmap_show() {
	"automountmap_show_001"
	"automountmap_show_002"
	"automountmap_show_003"
}

automountkey_add() {
	"automountkey_add_001"
	"automountkey_add_002"
	"automountkey_add_003"
}

automountkey_mod() {
	"automountkey_mod_001"
	"automountkey_mod_002"
	"automountkey_mod_003"
	"automountkey_mod_004"
}

automountkey_find() {
	"automountkey_find_001"
	"automountkey_find_002"
	"automountkey_find_003"
	"automountkey_find_004"
	"automountkey_find_005"
	"automountkey_find_006"
}

automountkey_show() {
	"automountkey_show_001"
	"automountkey_show_002"
	"automountkey_show_003"
	"automountkey_show_004"
	"automountkey_show_005"
}

rlJournalStart

    rlPhaseStartSetup "ipa-automount-startup: Check for admintools package, kinit and enabling nis"
		rlRun "setup"
		rlRun "echo setup"
    rlPhaseEnd

	# sanity tests start...
automount_help
automount_location_add
automount_location_find
automount_location_show
automount_map_add 
automountmap_find
automountmap_show
automountkey_add
automountkey_mod
automountkey_find
automountkey_show
automount_location_del
automountkey_del
automountmap_del

bz725433
bz726725
bz726722
	# sanity tests end.

    rlPhaseStartCleanup "ipa-automount-cleanup: Destroying admin credentials & and disabling nis."
		rlRun "cleanup"
		rlRun "echo cleanup"
    rlPhaseEnd


    rlPhaseStartSetup "ipa-automount-func-startup: Check for admintools package, kinit, configuring nfs, configure autofs"
                rlRun "func_setup"
                rlRun "echo func_setup"
    rlPhaseEnd

        # func tests start...
automountlocation-add_func_001
automountlocation-del_func_001
automountlocation-import_func_001
automountmap-add_func_001
automountmap-del_func_001
automountmap-mod_func_001
direct_mount_functionality_001
indirect_mount_functionality_001
        # func tests end.

    rlPhaseStartCleanup "ipa-automount-func-cleanup: Destroying admin credentials and removing users and configs."
                rlRun "func_cleanup"
                rlRun "echo func_cleanup"
    rlPhaseEnd



rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
