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
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh
. /opt/rhqa_ipa/ipa-hbac-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`
default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
default_selinuxusermap_order_config="guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"



########################################################################

run_selinuxusermap_config_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-config-cli-startup: Create temp directory and Kinit"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-001: Check ipa config for selinuxuser map order and default user"

	expected_default_selinuxusermap_order_config="SELinux user map order: guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"

        rlRun "ipa config-show > $TmpDir/selinuxusermap_test1.out" 0 "Show ipa config"
	rlRun "cat $TmpDir/selinuxusermap_test1.out"
	rlAssertGrep "$expected_default_selinuxusermap_order_config" "$TmpDir/selinuxusermap_test1.out"
	rlAssertGrep "Default SELinux user: $default_selinuxuser" "$TmpDir/selinuxusermap_test1.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-002: Modify ipa config selinuxuser map order"
        new_selinuxusermap_order_config="xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"

        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_default.out" 0 "Show ipa default config"
	rlRun "cat  $TmpDir/selinuxusermap_default.out"
        rlLog " Executing: ipa config-mod --ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
        rlRun "ipa config-show > $TmpDir/selinuxusermap_neworder.out" 0 "Show ipa config"
	rlRun "cat  $TmpDir/selinuxusermap_neworder.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_neworder.out"
        rlLog "Cleanup: back on default ipa config selinuxuser map order"
        ipa config-mod --ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-003: Modify ipa config default selinuxuser"
        new_selinuxuser="user_u:s0"
        expected_default_selinuxuser="Default SELinux user: user_u:s0"
        rlRun "ipa config-mod --ipaselinuxusermapdefault=$new_selinuxuser" 0 "Modify ipa config default selinuxuser"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_new_default.out" 0 "Show ipa config"
        rlAssertGrep "$expected_default_selinuxuser" "$TmpDir/selinuxusermap_new_default.out"
        rlLog "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-004: Modify ipa config selinuxuser map order with non existing selinux user - selinux user order should get updated since there is no way to detect that contexts are available"
        expected_selinuxusermap_order_config_entry="SELinux user map order: guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_order_unknown.out"
	ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_order_unknown.out
        rlRun "ipa config-show > $TmpDir/selinuxusermap_order_unkown.out" 0 "Show ipa config"
	rlRun "cat  $TmpDir/selinuxusermap_order_unknown.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_order_unkown.out"
	rlLog "Cleanup: back on default ipa config selinuxuser map order: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
	ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-005: Modify ipa config default selinuxuser with non existing selinux user"
        new_selinuxuser="unknowntype_u:s0"
	command="ipa config-mod --ipaselinuxusermapdefault=$new_selinuxuser"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermapdefault': SELinux user map default user not in order list"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-006: Modify ipa config selinuxuser map order with existing order"
        command="ipa config-mod --ipaselinuxusermaporder=guest_u:s0\\\$xguest_u:s0\\\$user_u:s0\\\$staff_u:s0-s0:c0.c1023\\\$unconfined_u:s0-s0:c0.c1023"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-007: Modify ipa config default selinuxuser with existing selinux user"
        command="ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-008: setattr ipa config selinuxuser map order"
	new_selinuxusermap_order_config="xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"

        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_default.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_default.out"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder.out" 0 "Show ipa setattr_neworder config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder.out"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-009: setattr ipa config default selinuxuser with a selinux user"
	new_selinuxuser="user_u:s0"
        expected_default_selinuxuser="Default SELinux user: user_u:s0"
        rlRun "ipa config-mod \"--setattr=ipaselinuxusermapdefault=$new_selinuxuser\"" 0 "Modify ipa config default selinuxuser: ipa config-mod --setattr=ipaselinuxusermapdefault=$new_selinuxuser"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_new_default.out" 0 "Show ipa config"
        rlAssertGrep "$expected_default_selinuxuser" "$TmpDir/selinuxusermap_setattr_new_default.out"
        rlRun "ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser" 0 "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-010: setattr ipa config selinuxuser map order with non existing selinux user - selinux user order should get updated since there is no way to detect that contexts are available"
        expected_selinuxusermap_order_config_entry="SELinux user map order: xguest_u:s0\$guest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_setattr_unknown.out"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023\$unkown_u:s0 > $TmpDir/selinuxusermap_setattr_unknown.out
	rlRun "cat $TmpDir/selinuxusermap_setattr_unknown.out"
	rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_order_unknown.out" 0 "Show ipa config: ipa config-show"
        rlRun "cat $TmpDir/selinuxusermap_setattr_order_unknown.out"
        rlAssertGrep "$expected_selinuxusermap_setattr_order_config_entry" "$TmpDir/selinuxusermap_setattr_order_unknown.out"
        rlLog "Cleanup: back on default ipa config selinuxuser map order: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-config-cli-011: setattr ipa config default selinuxuser with non existing selinux user"
        new_selinuxuser="unknowntype_u:s0"
        command="ipa config-mod --setattr=ipaselinuxusermapdefault=$new_selinuxuser"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermapdefault': SELinux user map default user not in order list"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for non existing selinux user"
	rlLog "Cleanup: back on default ipa config default selinuxuser: ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser"
        ipa config-mod --ipaselinuxusermapdefault=$default_selinuxuser
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-selinuxusermap-config-cli-012: Remove selinux user from the order list when its default"
        expected_selinuxusermap_order_config_entry="SELinux user map order: guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_default.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_default.out"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user map default user not in order list"
        rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023
        if [ $? -eq 0 ] ; then
                rlFail "ERROR: Command expected to fail."
        else
                ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023 2> $TmpDir/selinuxusermap_no_defaultuser.out
                actual=`cat $TmpDir/selinuxusermap_no_defaultuser.out`
                if [[ "$actual" = "$expmsg" ]] ; then
                        rlPass "Error message $expmsg is as expected"
                else
                        rlFail "ERROR: Message not as expected. GOT: $actual  EXP: $expmsg"
                fi
        fi
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_chkconfig.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_chkconfig.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_chkconfig.out"
    rlPhaseEnd
 
     rlPhaseStartTest "ipa-selinuxusermap-config-cli-013: selinuxuser syntax check - selinuxuser name:MLS:MCS"
	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - user does not end in traditional _u"
        expected_selinuxusermap_order_config_entry="SELinux user map order: newuser:s0\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_default.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_default.out"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=newuser:s0\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='newuser:s0\$unconfined_u:s0-s0:c0.c1023'"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_1.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_1.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_1.out"

        rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - user has characters other than \^\[a-z\]\[A-Z\]\[a-zA-Z\]"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test123:s0' is not valid: Invalid SELinux user name, only a-Z and _ are allowed"
	rlLog "Executing:ipa config-mod --setattr=ipaselinuxusermaporder=test123:s0\$unconfined_u:s0-s0:c0.c1023"	
 	rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test123:s0\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_non_alphabet.out 2>&1" 1
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_non_alphabet.out"
	rlRun "cat $TmpDir/selinuxusermap_non_alphabet.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test123:s0\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_2.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_2.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_2.out" 
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_2.out" 

	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - user has beginning non alphabet characters "
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user '4test:s0' is not valid: Invalid SELinux user name, only a-Z and _ are allowed"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=4test:s0\$unconfined_u:s0-s0:c0.c1023"
	rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='4test:s0\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_non_alphabetbegin.out 2>&1" 1
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_non_alphabetbegin.out"

	rlRun "cat $TmpDir/selinuxusermap_non_alphabetbegin.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: 4test:s0\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_3.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_3.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_3.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_3.out"

	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - user part is missing"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user ':s0' is not valid: Invalid SELinux user name, only a-Z and _ are allowed"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=:s0\$unconfined_u:s0-s0:c0.c1023"
	rlRun "ipa config-mod --setattr=ipaselinuxusermaporder=':s0\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_missing_user.out 2>&1" 1
	rlRun "cat $TmpDir/selinuxusermap_missing_user.out"
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_missing_user.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: :s0\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_4.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_4.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_4.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_4.out"

	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MLS and MCS part is missing"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u' is not valid: Invalid MLS value, must match s[0-15](-s[0-15])"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u' is not valid: Invalid MLS value, must match"
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=test_u\$unconfined_u:s0-s0:c0.c1023"
	rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test_u\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_missing_mls.out 2>&1" 1
	rlRun "cat $TmpDir/selinuxusermap_missing_mls.out"
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_missing_mls.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_5.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_5.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_5.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_5.out"

	
	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MLS characters other than s\[0-15\]\(-s\[0-15\]\)"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:a0-a1' is not valid: Invalid MLS value, must match s[0-15](-s[0-15])"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:a0-a1' is not valid: Invalid MLS value, must match "
	rlLog "Executing: ipa config-mod --ipaselinuxusermaporder=test_u:a0-a1\$unconfined_u:s0-s0:c0.c1023"
	rlRun "ipa config-mod --ipaselinuxusermaporder='test_u:a0-a1\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_mls_invalid_syntax.out 2>&1" 1
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_mls_invalid_syntax.out"
	rlRun "cat $TmpDir/selinuxusermap_mls_invalid_syntax.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u:a0-a1\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_6.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_6.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_6.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_6.out"

	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MLS characters - s16"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s16' is not valid: Invalid MLS value, must match s[0-15](-s[0-15])"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s16' is not valid: Invalid MLS value, must match "
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=test_u:s16\$unconfined_u:s0-s0:c0.c1023"
	rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test_u:s16\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_mls_syntax_s16.out 2>&1" 1
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_mls_syntax_s16.out"
	rlRun "cat $TmpDir/selinuxusermap_mls_syntax_s16.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u:s16\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_7.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_7.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_7.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_7.out"

        rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MLS characters missing '-' s1s15"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s1s15' is not valid: Invalid MLS value, must match s[0-15](-s[0-15])"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s1s15' is not valid: Invalid MLS value, must match "
	rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=test_u:s1s15\$unconfined_u:s0-s0:c0.c1023"
	rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test_u:s1s15\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_mls_incorrect_syntax.out 2>&1" 1
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_mls_incorrect_syntax.out"
	rlRun "cat $TmpDir/selinuxusermap_mls_incorrect_syntax.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u:s1s15\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_8.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_8.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_8.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_8.out"

	rlLog "Executing: Positive: Syntax check - selinuxuser name:MLS:MCS - testuser_u:s0"
        expected_selinuxusermap_order_config_entry="SELinux user map order: testuser_u:s0\$unconfined_u:s0-s0:c0.c1023"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=testuser_u:s0\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='testuser_u:s0\$unconfined_u:s0-s0:c0.c1023'"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_9.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_9.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_9.out"

	rlLog "Executing: Positive: Syntax check - selinuxuser name:MLS:MCS - testuser_u:s0-s1"
        expected_selinuxusermap_order_config_entry="SELinux user map order: testuser_u:s0-s1\$unconfined_u:s0-s0:c0.c1023"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=testuser_u:s0-s1\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='testuser_u:s0-s1\$unconfined_u:s0-s0:c0.c1023'"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_10.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_10.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_10.out"

	rlLog "Executing: Positive: Syntax check - selinuxuser name:MLS:MCS - testuser_u:s0-s15:c0.c1023"
        expected_selinuxusermap_order_config_entry="SELinux user map order: testuser_u:s0-s15:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=testuser_u:s0-s15:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='testuser_u:s0-s15:c0.c1023\$unconfined_u:s0-s0:c0.c1023'"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_11.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_11.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_11.out"

	rlLog "Executing: Positive: Syntax check - selinuxuser name:MLS:MCS - testuser_u:s0-s1:c0,c2,c15.c26"
        expected_selinuxusermap_order_config_entry="SELinux user map order: testuser_u:s0-s1:c0,c2,c15.c26\$unconfined_u:s0-s0:c0.c1023"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=testuser_u:s0-s1:c0,c2,c15.c26\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='testuser_u:s0-s1:c0,c2,c15.c26\$unconfined_u:s0-s0:c0.c1023'"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_12.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_12.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_12.out"

	rlLog "Executing: Positive: Syntax check - selinuxuser name:MLS:MCS - testuser_u:s0-s0:c0.c1023"
        expected_selinuxusermap_order_config_entry="SELinux user map order: testuser_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlLog "ipa config-mod --setattr=ipaselinuxusermaporder=testuser_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='testuser_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023'"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_13.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_13.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_13.out"
	
	rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MCS characters not c0.c1023"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s0-s0:c0.c2048' is not valid: Invalid MCS value, must match c[0-1023].c[0-1023] and/or c[0-1023]-c[0-c0123]"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s0-s0:c0.c2048' is not valid: Invalid MCS value, must match "
        rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=test_u:s0-s0:c0.c2048\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test_u:s0-s0:c0.c2048\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_mls_incorrect_syntax.out 2>&1" 1
        rlRun "cat $TmpDir/selinuxusermap_mls_incorrect_syntax.out"
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_mls_incorrect_syntax.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u:s0-s0:c0.c2048\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_14.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_14.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_14.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_14.out"

        rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MCS characters missing . and , (c0c1023)"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s0-s0:c0c1023' is not valid: Invalid MCS value, must match c[0-1023].c[0-1023] and/or c[0-1023]-c[0-c0123]"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s0-s0:c0c1023' is not valid: Invalid MCS value, must match "
        rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=test_u:s0-s0:c0c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test_u:s0-s0:c0c1023\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_mls_incorrect_syntax.out 2>&1" 1
        rlRun "cat $TmpDir/selinuxusermap_mls_incorrect_syntax.out"
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_mls_incorrect_syntax.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u:s0-s0:c0c1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_15.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_15.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_15.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_15.out"

        rlLog "Executing: Syntax check - selinuxuser name:MLS:MCS - MCS characters othen than c0.c1023"
        #expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s0-s0:a0.a1023' is not valid: Invalid MCS value, must match c[0-1023].c[0-1023] and/or c[0-1023]-c[0-c0123]"
        expmsg="ipa: ERROR: invalid 'ipaselinuxusermaporder': SELinux user 'test_u:s0-s0:a0.a1023' is not valid: Invalid MCS value, must match "
        rlLog "Executing: ipa config-mod --setattr=ipaselinuxusermaporder=test_u:s0-s0:a0.a1023\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-mod --setattr=ipaselinuxusermaporder='test_u:s0-s0:a0.a1023\$unconfined_u:s0-s0:c0.c1023' > $TmpDir/selinuxusermap_mls_incorrect_syntax.out 2>&1" 1
        rlRun "cat $TmpDir/selinuxusermap_mls_incorrect_syntax.out"
	rlAssertGrep "$expmsg" "$TmpDir/selinuxusermap_mls_incorrect_syntax.out"
        not_expected_selinuxusermap_order_config_entry="SELinux user map order: test_u:s0-s0:a0.a1024\$unconfined_u:s0-s0:c0.c1023"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_setattr_neworder_13_16.out" 0 "Show ipa config"
        rlRun "cat  $TmpDir/selinuxusermap_setattr_neworder_13_16.out"
        rlAssertGrep "$expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_16.out"
        rlAssertNotGrep "$not_expected_selinuxusermap_order_config_entry" "$TmpDir/selinuxusermap_setattr_neworder_13_16.out"

	rlLog "Clean up: back on original configuration: ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023"
        ipa config-mod --setattr=ipaselinuxusermaporder=guest_u:s0\$xguest_u:s0\$user_u:s0\$staff_u:s0-s0:c0.c1023\$unconfined_u:s0-s0:c0.c1023
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2993"
    rlPhaseEnd
 
    rlPhaseStartCleanup "ipa-selinuxusermap-config-cli-cleanup: Destroying admin credentials."
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
