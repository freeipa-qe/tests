#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-cli
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
. /dev/shm/ipa-selinuxusermap-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

selinuxusermap1="testselinuxusermap1"
selinuxusermap2="testselinuxusermap2"
selinuxusermap3="testselinuxusermap3"
selinuxusermap4="testselinuxusermap4"
default_selinuxuser="guest_u:s0"
host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"
servicegroup="remote_access"

########################################################################

run_selinuxusermap_add_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-cli-startup: Create temp directory and Kinit"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	# add host for testing
        rlRun "addHost $host1" 0 "SETUP: Adding host $host1 for testing."
        # add host group for testing
        rlRun "addHostGroup $hostgroup1 $hostgroup1" 0 "SETUP: Adding host group $hostgroup1 for testing."
        # add user for testing
        rlRun "ipa user-add --first=$user1 --last=$user1 $user1" 0 "SETUP: Adding user $user1."
        # add group for testing
        rlRun "addGroup $usergroup1 $usergroup1" 0 "SETUP: Adding user $usergroup1."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-001: Check ipa config for selinuxuser map order and default user"
	default_selinuxusermap_order_config=\"SELinux user map order: guest_u:s0$xguest_u:s0$user_u:s0-s0:c0.c1023$staff_u:s0-s0:c0.c1023$unconfined_u:s0-s0:c0.c1023\"
        rlRun "ipa config-show > $TmpDir/selinuxusermap_test1.out" 0 "Show ipa config"
	rlAssertGrep "$default_selinuxusermap_order_config" "$TmpDir/selinuxusermap_test1.out"
	rlAssertGrep "Default SELinux user: $default_selinuxuser" "$TmpDir/selinuxusermap_test1.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-002: Add a  selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "findSelinuxusermap $selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Verifying selinuxusermap was added with given selinuxuser"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-003: Add a duplicate selinuxusermap"
        command="ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1"
        expmsg="ipa: ERROR: SELinux User Map rule with name $selinuxusermap1 already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for duplicate selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-004: Add a new selinux user type to existing selinuxusermap"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser $selinuxusermap1"
        expmsg="ipa: ERROR: SELinux User Map rule with name $selinuxusermap1 already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for new selinux user type with existing selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-005: selinuxuser type Required - give empty string"
        command="ipa selinuxusermap-add --selinuxuser=\"\" $selinuxusermap2"
        expmsg="ipa: ERROR: 'selinuxuser' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty selinuxuser type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-006: selinuxuser option - unknown"
	command="ipa selinuxusermap-add --selinuxuser=unknown $selinuxusermap2"
        expmsg="ipa: ERROR: SELinux user unknown not found in ordering list (in config)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for unknown selinuxuser type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-007: Add a  selinuxuser map with User Category \'all\'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=all $selinuxusermap2 > $TmpDir/selinuxusermap_usercat_all.out" 0 "Add a selinuxusermap with User Category all"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlAssertGrep "User category: all" "$TmpDir/selinuxusermap_usercat_all.out"
        rlRun "findSelinuxusermapByOption usercat all $selinuxusermap2" 0 "Verifying selinuxusermap was added with user category all"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-008: Users cannot be added when user category=\'all\' "
        command="ipa selinuxusermap-add-user --user=$user1 $selinuxusermap2"
        expmsg="ipa: ERROR: users cannot be added when user category='all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding users to selinuxusermap  when user category=\'all\'"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-009: Groups cannot be added when user category=\'all\' "
        command="ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap2"
        expmsg="ipa: ERROR: users cannot be added when user category='all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding groups to selinuxusermap when user category=\'all\'"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-010: Add a  selinuxuser map with User Category \'all\' while there are allowed users"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap3" 0 "Add a selinuxusermap with allowed user"
	rlRun "ipa selinuxusermap-add-user --user=$user1 $selinuxusermap3 > $TmpDir/selinuxusermap_user.out"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlAssertGrep "Users: $user1" "$TmpDir/selinuxusermap_user.out"
	command="ipa selinuxusermap-mod --usercat=all $selinuxusermap3"
        expmsg="ipa: ERROR: user category cannot be set to 'all' while there are allowed users"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding user category=\'all\' while there are allowed users"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-011: selinuxuser User Category - unknown"
        command="ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=unknown $selinuxusermap4"
        expmsg="ipa: ERROR: invalid 'usercat': must be one of (u'all',)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for unknown user category"
    rlPhaseEnd
 
    rlPhaseStartCleanup "ipa-selinuxusermap-cli-cleanup: Destroying admin credentials."
	# delete service group
	rlRun "ipa selinuxusermap-del $selinuxusermap1" 0 "CLEANUP: Deleting selinuxuser $selinuxusermap1"
	rlRun "ipa selinuxusermap-del $selinuxusermap2" 0 "CLEANUP: Deleting selinuxuser $selinuxusermap2"
	rlRun "ipa selinuxusermap-del $selinuxusermap3" 0 "CLEANUP: Deleting selinuxuser $selinuxusermap3"
	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "ipa user-del $user1" 0 "Delete user $user1."

	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
