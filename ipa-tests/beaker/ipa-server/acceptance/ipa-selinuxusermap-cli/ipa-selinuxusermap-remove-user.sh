#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-user-remove-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-remove-user    Remove users and groups from an SELinux User Map rule.
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
. /opt/rhqa_ipa/ipa-selinuxusermap-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`
basedn=`getBaseDN`

selinuxusermap1="testselinuxusermap1"
selinuxusermap2="testselinuxusermap2"
selinuxusermap3="testselinuxusermap3"

user1="dev"
user2="testuser2"
user3="testuser3"
user4="testuser4"
user5="testuser5"
usergroup1="dev_ugrp"
usergroup2="ipaqe_ugrp"
usergroup3="csqe_ugrp"
usergroup4="dsqe_ugrp"
usergroup5="desktopqe_ugrp"

########################################################################

run_selinuxusermap_remove_user_tests(){
    rlPhaseStartSetup "ipa-selinuxusermap-user-remove-cli-startup: Create temp directory and Kinit"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	 # add user for testing
        rlRun "ipa user-add --first=$user1 --last=$user1 $user1" 0 "SETUP: Adding user $user1."
        rlRun "ipa user-add --first=$user2 --last=$user2 $user2" 0 "SETUP: Adding user $user2."
        rlRun "ipa user-add --first=$user3 --last=$user3 $user3" 0 "SETUP: Adding user $user3."

	 # add group for testing
        rlRun "addGroup $usergroup1 $usergroup1" 0 "SETUP: Adding user $usergroup1."
        rlRun "addGroup $usergroup2 $usergroup2" 0 "SETUP: Adding user $usergroup2."
        rlRun "addGroup $usergroup3 $usergroup3" 0 "SETUP: Adding user $usergroup3."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-configtest: ipa help selinuxusermap-remove-user"
	rlRun "ipa help selinuxusermap-remove-user > $TmpDir/selinuxusermap-remove-user_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "Purpose: Remove users and groups from an SELinux User Map rule." "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-remove-user NAME \[options\]" "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "Positional arguments:
  NAME              Rule name" "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "\--all         Retrieve and print all attributes from the server. Affects
                command output." "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "\--raw         Print entries as stored on the server. Only affects output
                format." "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "\--users=STR   comma-separated list of users to remove" "$TmpDir/selinuxusermap-remove-user_cfg.out"
	rlAssertGrep "\--groups=STR  comma-separated list of groups to remove" "$TmpDir/selinuxusermap-remove-user_cfg.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-001: Remove user from the se-linux usermap"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" $selinuxusermap1" 0 "Add a selinuxusermap"	
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap1" 0 "Add user $user1 to selinuxusermap"
	rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap1" 0 "Remove user $user1 from selinuxusermap"
	rlRun "findSelinuxusermapByOption selinuxuser \"guest_u:s0\" $selinuxusermap1" 0 "Verifying selinuxusermap has given selinuxuser"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-remove-user-001.out" 0 "Show selinuxusermap"
	rlAssertNotGrep "Users: $user1" "$TmpDir/selinuxusermap-remove-user-001.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-002: Remove a user that does not exit from a selinuxusermap"
	rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap1 >  $TmpDir/selinuxusermap-user-remove-002.out" 1 "Remove user $user1 from selinuxusermap"
	rlRun "cat  $TmpDir/selinuxusermap-user-remove-002.out"
	rlAssertGrep "member user: $user1: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-002.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-003: Remove multiple users from the se-linux usermap"
        rlRun "ipa selinuxusermap-add-user --users=$user1,$user2,$user3 $selinuxusermap1" 0 "Add users $user1 $user2 $user3 to selinuxusermap"
        rlRun "ipa selinuxusermap-remove-user --users=$user1,$user2,$user3 $selinuxusermap1" 0 "Remove users $user1 $user2 $user3 from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-remove-user-003.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-remove-user-003.out"
        rlAssertNotGrep "Users: $user1, $user2, $user3" "$TmpDir/selinuxusermap-remove-user-003.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-004: Remove multiple users from the se-linux usermap - not all users removed successfully"
        rlRun "ipa selinuxusermap-add-user --users=$user1,$user2,$user3 $selinuxusermap1" 0 "Add users $user1 $user2 $user3 to selinuxusermap"
        rlRun "ipa selinuxusermap-remove-user --users=$user1,$user4,$user2,$user3,$user5 $selinuxusermap1 > $TmpDir/selinuxusermap-user-remove-004.out" 1 "Remove users $user1 $user4 $user2 $user3 $user5 from selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-user-remove-004.out"
	rlAssertGrep  "member user: $user4: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-004.out"
	rlAssertGrep  "member user: $user5: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-004.out"
	rlAssertGrep "Number of members removed 3" "$TmpDir/selinuxusermap-user-remove-004.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-remove-user-show-004.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-remove-user-show-004.out"
        rlAssertNotGrep "Users: $user1, $user2, $user3" "$TmpDir/selinuxusermap-remove-user-show-004.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-005: Remove user Category - that's not associted with selinuxusermap"
        rlRun "ipa selinuxusermap-remove-user --users=bad $selinuxusermap1 >  $TmpDir/selinuxusermap-user-remove-005.out" 1 "Remove unknown user from selinuxusermap"
	rlAssertGrep "member user: bad: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-005.out"
	rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-user-remove-005.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-006: Remove user from an unkown selinuxusermap "
	command="ipa selinuxusermap-remove-user --users=$user1 unknown"
	expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add user to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-007: Remove a user group from the se-linux usermap"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap2" 0 "Add user group $usergroup1 to selinuxusermap"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1 $selinuxusermap2" 0 "Remove user group $usergroup1 from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-remove-user-007.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-remove-user-007.out"
        rlAssertNotGrep "User Groups: $usergroup1" "$TmpDir/selinuxusermap-remove-user-007.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-008: Remove a user group that does not exist "
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1 $selinuxusermap2 >  $TmpDir/selinuxusermap-user-remove-008.out" 1 "Remove user group $usergroup1 from selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-user-remove-008.out"
        rlAssertGrep "member group: $usergroup1: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-008.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-009: Remove multiple user groups from the se-linux usermap - all usergroups removed successfully"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1,$usergroup2,$usergroup3  $selinuxusermap2" 0 "Add user groups $usergroup1 $usergroup2 $usergroup3 to $selinuxusermap2"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1,$usergroup2,$usergroup3  $selinuxusermap2" 0 "Remove user groups $usergroup1 $usergroup2 $usergroup3 from $selinuxusermap2"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-remove-user-009.out" 0 "Show $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-remove-user-009.out"
        rlAssertNotGrep "User Groups: $usergroup1, $usergroup2, $usergroup3" "$TmpDir/selinuxusermap-remove-user-009.out"
    rlPhaseEnd

   rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-010: Remove multiple user groups from the se-linux usermap - not all user groups removed successfully"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1,$usergroup2,$usergroup3 $selinuxusermap2" 0 "Add user groups $usergroup1 $usergroup2 $usergroup3to $selinuxusermap2"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1,$usergroup4,$usergroup2,$usergroup3,$usergroup5 $selinuxusermap2 > $TmpDir/selinuxusermap-user-remove-010.out" 1 "Remove user groups $usergroup1 $usergroup4 $usergroup2 $usergroup3 $usergroup5 from $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-user-remove-010.out"
        rlAssertGrep  "member group: $usergroup4: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-010.out"
        rlAssertGrep  "member group: $usergroup5: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-010.out"
        rlAssertGrep "Number of members removed 3" "$TmpDir/selinuxusermap-user-remove-010.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-remove-user-show-010.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-remove-user-show-010.out"
        rlAssertNotGrep "User Groups: $usergroup1, $usergroup2, $usergroup3" "$TmpDir/selinuxusermap-remove-user-show-010.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-011: Remove user group Category - unknown"
        rlRun "ipa selinuxusermap-remove-user --groups=bad $selinuxusermap2 >  $TmpDir/selinuxusermap-user-remove-011.out" 1 "Remove unknown user group from selinuxusermap"
        rlAssertGrep "member group: bad: This entry is not a member" "$TmpDir/selinuxusermap-user-remove-011.out"
        rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-user-remove-011.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-012: Remove user group from a unkown selinuxusermap"
        command="ipa selinuxusermap-remove-user --groups=$usergroup1 unknown"
        expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add user to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-013: Remove a user with a empty string"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap3" 0 "Add a selinuxusermap"
	rlRun "ipa selinuxusermap-remove-user --users=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-user-remove-013.out" 0 "Remove user with empty string to selinuxusermap"
	rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-user-remove-013.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-014: Remove a user groups with a empty string"
        rlRun "ipa selinuxusermap-remove-user --groups=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-user-remove-014.out" 0 "Add user group with empty string to selinuxusermap"
        rlAssertGrep "Number of members removed 0" "$TmpDir/selinuxusermap-user-remove-014.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-015: Remove a user with --all option"
        rlLog "Executing:  ipa selinuxusermap-add-user --users=$user1 --all $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --users=$user1 --all $selinuxusermap3" 0 "Add a user with --all option"
        rlLog "Executing:  ipa selinuxusermap-remove-user --users=$user1 --all $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-user --users=$user1 --all $selinuxusermap3  > $TmpDir/selinuxusermap-user-remove-015.out" 0 "Remove user with --all option"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-user-remove-015.out"
        rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-user-remove-015.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-user-remove-015.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-016: Remove user with --raw option without --all"
        rlLog "Executing:  ipa selinuxusermap-add-user --users=$user1 --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --users=$user1 --raw $selinuxusermap3 " 0 "Add a user with --raw option"
        rlLog "Executing:  ipa selinuxusermap-remove-user --users=$user1 --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-user --users=$user1 --raw $selinuxusermap3  > $TmpDir/selinuxusermap-user-remove-016.out" 0 "Remove user with --raw option"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-remove-016.out"
        rlAssertNotGrep "memberuser: uid=$user1,cn=users,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-remove-016.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-user-remove-016.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-017: Remove user with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-user --users=$user1,$user2 --all --raw $selinuxusermap3"
        rlRun "ipa selinuxusermap-add-user --users=$user1,$user2 --all --raw $selinuxusermap3" 0 "Add a user with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-remove-user --users=$user1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-user --users=$user1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-user-remove-017.out" 0 "Remove user with --all --raw option"
	rlRun "cat $TmpDir/selinuxusermap-user-remove-017.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-remove-017.out"
        rlAssertNotGrep "memberuser: uid=$user1,cn=users,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-remove-017.out"
        rlAssertGrep "memberuser: uid=$user2,cn=users,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-remove-017.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-user-remove-017.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-user-remove-017.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-user-remove-017.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user2 $selinuxusermap3" 0 "Clean-up: Delete user from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-remove-cli-018: Remove a user group with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-user --groups=$usergroup1,$usergroup2 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1,$usergroup2 --all --raw $selinuxusermap3" 0 "Add a user group with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-remove-user --groups=$usergroup1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-user-remove-018.out" 0 "Remove a user group with --all --raw option"
	rlRun "cat $TmpDir/selinuxusermap-user-remove-018.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-remove-018.out"
        rlAssertNotGrep "memberuser: cn=$usergroup1,cn=groups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-remove-018.out"
        rlAssertGrep "memberuser: cn=$usergroup2,cn=groups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-remove-018.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-user-remove-018.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-user-remove-018.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/selinuxusermap-user-remove-018.out"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup2 $selinuxusermap3" 0 "Clean-up: Delete user group from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-user-remove-cli-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 ; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done
	for item in $user1 $user2 $user3; do
		rlRun "ipa user-del $item" 0 "Delete user $item."
	done

	for item in $usergroup1 $usergroup2 $usergroup3; do
		rlRun "deleteGroup $item" 0 "Deleting User Group associated with rule."
	done
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
