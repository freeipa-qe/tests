#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-config-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-add          Create a new SELinux User Map.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Asha Akkiangady <aakkiang@redhat.com>
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
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

########################################################################

run_selinuxusermap_config_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-config-cli-startup: Create temp directory and Kinit"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-001: Check ipa config for selinuxuser map order and default user"

	expected_default_selinuxusermap_order_config="SELinux user map order: guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"

        rlRun "ipa config-show > $TmpDir/selinuxusermap_test1.out" 0 "Show ipa config"
	rlRun "cat $TmpDir/selinuxusermap_test1.out"
	rlAssertGrep "$expected_default_selinuxusermap_order_config" "$TmpDir/selinuxusermap_test1.out"
	rlAssertGrep "Default SELinux user: $default_selinuxuser" "$TmpDir/selinuxusermap_test1.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-002: Modify ipa config selinuxuser map order"
        new_selinuxusermap_order_config="xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"

        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_default.out" 0 "Show ipa default config"
	rlRun "cat  $TmpDir/selinuxusermap_default.out"
        #rlRun "ipa config-mod --ipaselinuxusermaporder=\"$new_selinuxusermap_order_config\"" 0 "Modify ipa config selinuxuser map order: ipa config-mod --ipaselinuxusermaporder=\"$new_selinuxusermap_order_config\""
        rlLog " Executing: ipa config-mod --ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
        rlRun "ipa config-show > $TmpDir/selinuxusermap_neworder.out" 0 "Show ipa config"
	rlRun "cat  $TmpDir/selinuxusermap_neworder.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_neworder.out"
        rlRun "ipa config-mod --ipaselinuxusermaporder=$default_selinuxusermap_order_config" 0 "Cleanup: back on default ipa config selinuxuser map order"
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2938"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-003: Modify ipa config default selinuxuser"
        new_selinuxuser="user_u:s0-s0:c0.c1023"
        expected_default_selinuxuser="Default SELinux user: user_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --ipaselinuxusermapdefault=$new_selinuxuser" 0 "Modify ipa config default selinuxuser"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_new_default.out" 0 "Show ipa config"
        rlAssertGrep "$expected_default_selinuxuser" "$TmpDir/selinuxusermap_new_default.out"
        #rlRun "ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser" 0 "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        rlLog "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-004: Modify ipa config selinuxuser map order with non existing selinux user - selinux user order should get updated since there is no way to detect that contexts are available"
        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_order_unknown.out"
	ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_order_unknown.out
        rlRun "ipa config-show > $TmpDir/selinuxusermap_order_unkown.out" 0 "Show ipa config"
	rlRun "cat  $TmpDir/selinuxusermap_order_unknown.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_order_unkown.out"
	rlLog "Cleanup: back on default ipa config selinuxuser map order: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
	ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2938"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-005: Modify ipa config default selinuxuser with non existing selinux user"
        new_selinuxuser="unknowntype_u:s0"
	command="ipa config-mod --ipaselinuxusermapdefault=$new_selinuxuser"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': Default SELinux user map default user not in order list"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-006: Modify ipa config selinuxuser map order with existing order"
        command="ipa config-mod --ipaselinuxusermaporder=$default_selinuxusermap_order_config"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2938"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-007: Modify ipa config default selinuxuser with existing selinux user"
        command="ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-008: setattr ipa config selinuxuser map order"
	new_selinuxusermap_order_config="xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"

        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_default.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_default.out"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder.out" 0 "Show ipa setattr_neworder config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder.out"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-009: setattr ipa config default selinuxuser with a selinux user"
	new_selinuxuser="user_u:s0-s0:c0.c1023"
        expected_default_selinuxuser="Default SELinux user: user_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod \"--setattr=ipaselinuxusermapdefault=$new_selinuxuser\"" 0 "Modify ipa config default selinuxuser: ipa config-mod --setattr=ipaselinuxusermapdefault=$new_selinuxuser"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_new_default.out" 0 "Show ipa config"
        rlAssertGrep "$expected_default_selinuxuser" "$TmpDir/selinuxusermap_setattr_new_default.out"
        rlRun "ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser" 0 "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-010: setattr ipa config selinuxuser map order with non existing selinux user - selinux user order should get updated since there is no way to detect that contexts are available"
        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_setattr_unknown.out"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_setattr_unknown.out
	rlRun "cat $TmpDir/selinuxusermap_setattr_unknown.out"
	rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_order_unknown.out" 0 "Show ipa config: ipa config-show"
        rlRun "cat $TmpDir/selinuxusermap_setattr_order_unknown.out"
        rlAssertGrep "$expected_selinuxusermap_setattr_order_config_entry" "$TmpDir/selinuxusermap_setattr_order_unknown.out"
        rlLog "Cleanup: back on default ipa config selinuxuser map order: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0-s0:c0.c1023\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-011: setattr ipa config default selinuxuser with non existing selinux user"
        new_selinuxuser="unknowntype_u:s0"
        command="ipa config-mod --setattr=ipaselinuxusermapdefault=$new_selinuxuser"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': Default SELinux user map default user not in order list"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
	rlLog "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2940"
    rlPhaseEnd
 
 
    rlPhaseStartCleanup "ipa-selinuxusermap-config-cli-cleanup: Destroying admin credentials."
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
