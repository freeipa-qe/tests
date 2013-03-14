#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-user-add-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-add-user    Add users and groups to an SELinux User Map rule.
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
selinuxusermap4="testselinuxusermap4"
selinuxusermap5="testselinuxusermap5"

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

run_selinuxusermap_add_user_tests(){
    rlPhaseStartSetup "ipa-selinuxusermap-user-add-cli-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-configtest: ipa help selinuxusermap-add-user"
	rlRun "ipa help selinuxusermap-add-user > $TmpDir/selinuxusermap-add-user_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "Purpose: Add users and groups to an SELinux User Map rule." "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-add-user NAME \[options\]" "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "Positional arguments:
  NAME              Rule name" "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "\--all         Retrieve and print all attributes from the server. Affects
                command output." "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "\--raw         Print entries as stored on the server. Only affects output
                format." "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "\--users=STR   comma-separated list of users to add" "$TmpDir/selinuxusermap-add-user_cfg.out"
	rlAssertGrep "\--groups=STR  comma-separated list of groups to add" "$TmpDir/selinuxusermap-add-user_cfg.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-001: Add a user to the se-linux usermap"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" $selinuxusermap1" 0 "Add a selinuxusermap"	
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap1" 0 "Add user $user1 to selinuxusermap"
	rlRun "findSelinuxusermapByOption selinuxuser \"guest_u:s0\" $selinuxusermap1" 0 "Verifying selinuxusermap was added with given selinuxuser"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-user-001.out" 0 "Show selinuxusermap"
	rlAssertGrep "Users: $user1" "$TmpDir/selinuxusermap-add-user-001.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-002: Add a duplicate user to the se-linux usermap"
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap1 >  $TmpDir/selinuxusermap-user-add-002.out" 1 "Add user $user1 to selinuxusermap again"
	rlRun "cat  $TmpDir/selinuxusermap-user-add-002.out"
	rlAssertGrep "member user: $user1: This entry is already a member" "$TmpDir/selinuxusermap-user-add-002.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-003:  Remove user from the se-linux usermap"
        rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap1" 0 "Delete user from selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-user-003.out" 0 "Show selinuxusermap"
	rlAssertNotGrep "Users: $user1" "$TmpDir/selinuxusermap-add-user-003.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-004: Add multiple users to the se-linux usermap"
        rlRun "ipa selinuxusermap-add-user --users=$user1,$user2,$user3 $selinuxusermap1" 0 "Add users $user1 $user2 $user3 to selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-user-004.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-add-user-004.out"
        rlAssertGrep "Users: $user1, $user2, $user3" "$TmpDir/selinuxusermap-add-user-004.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1,$user2,$user3 $selinuxusermap1" 0 "Delete users from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-005: Add multiple users to the se-linux usermap - not all users added successfully"
        rlRun "ipa selinuxusermap-add-user --users=$user1,$user4,$user2,$user3,$user5 $selinuxusermap1 > $TmpDir/selinuxusermap-user-add-005.out" 1 "Add users $user1 $user4 $user2 $user3 $user5 to selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-user-add-005.out"
	rlAssertGrep  "member user: $user4: no such entry" "$TmpDir/selinuxusermap-user-add-005.out"
	rlAssertGrep  "member user: $user5: no such entry" "$TmpDir/selinuxusermap-user-add-005.out"
	rlAssertGrep "Number of members added 3" "$TmpDir/selinuxusermap-user-add-005.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-add-user-show-005.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-add-user-show-005.out"
        rlAssertGrep "Users: $user1, $user2, $user3" "$TmpDir/selinuxusermap-add-user-show-005.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1,$user2,$user3 $selinuxusermap1" 0 "Delete users from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-006: Add user Category - unknown"
        rlRun "ipa selinuxusermap-add-user --users=bad $selinuxusermap1 >  $TmpDir/selinuxusermap-user-add-006.out" 1 "Add unknown user to selinuxusermap"
	rlAssertGrep "member user: bad: no such entry" "$TmpDir/selinuxusermap-user-add-006.out"
	rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-user-add-006.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-007: Add user to a unkown selinuxusermap "
	command="ipa selinuxusermap-add-user --users=$user1 unknown"
	expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add user to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-008: Add a user group to the se-linux usermap"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap2" 0 "Add user group $usergroup1 to selinuxusermap"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-user-008.out" 0 "Show selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-add-user-008.out"
        rlAssertGrep "User Groups: $usergroup1" "$TmpDir/selinuxusermap-add-user-008.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-009: Add a duplicate user group to the se-linux usermap"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap2 >  $TmpDir/selinuxusermap-user-add-009.out" 1 "Add user group $usergroup1 to selinuxusermap again"
	rlRun "cat $TmpDir/selinuxusermap-user-add-009.out"
        rlAssertGrep "member group: $usergroup1: This entry is already a member" "$TmpDir/selinuxusermap-user-add-009.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-010:  Remove user group from the se-linux usermap"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1 $selinuxusermap2" 0 "Delete user group from selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-user-010.out" 0 "Show selinuxusermap"
        rlAssertNotGrep "User Groups: $usergroup1" "$TmpDir/selinuxusermap-add-user-010.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-011: Add multiple user groups to the se-linux usermap - all usergroups added successfully"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1,$usergroup2,$usergroup3  $selinuxusermap2" 0 "Add user groups $usergroup1 $usergroup2 $usergroup3 to $selinuxusermap2"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-user-011.out" 0 "Show $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-add-user-011.out"
        rlAssertGrep "User Groups: $usergroup1, $usergroup2, $usergroup3" "$TmpDir/selinuxusermap-add-user-011.out"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1,$usergroup2,$usergroup3 $selinuxusermap2" 0 "Delete user group from selinuxusermap"
    rlPhaseEnd

   rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-012: Add multiple user groups to the se-linux usermap - not all user groups added successfully"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1,$usergroup4,$usergroup2,$usergroup3,$usergroup5 $selinuxusermap2 > $TmpDir/selinuxusermap-user-add-012.out" 1 "Add user groups $usergroup1 $usergroup4 $usergroup2 $usergroup3 $usergroup5 to $selinuxusermap2"
        rlRun "cat $TmpDir/selinuxusermap-user-add-012.out"
        rlAssertGrep  "member group: $usergroup4: no such entry" "$TmpDir/selinuxusermap-user-add-012.out"
        rlAssertGrep  "member group: $usergroup5: no such entry" "$TmpDir/selinuxusermap-user-add-012.out"
        rlAssertGrep "Number of members added 3" "$TmpDir/selinuxusermap-user-add-012.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-add-user-show-012.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-user-show-012.out"
        rlAssertGrep "User Groups: $usergroup1, $usergroup2, $usergroup3" "$TmpDir/selinuxusermap-add-user-show-012.out"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1,$usergroup2,$usergroup3 $selinuxusermap2" 0 "Delete user groups from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-013: Add user group Category - unknown"
        rlRun "ipa selinuxusermap-add-user --groups=bad $selinuxusermap2 >  $TmpDir/selinuxusermap-user-add-013.out" 1 "Add unknown user group to selinuxusermap"
        rlAssertGrep "member group: bad: no such entry" "$TmpDir/selinuxusermap-user-add-013.out"
        rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-user-add-013.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-014: Add user group to a unkown selinuxusermap"
        command="ipa selinuxusermap-add-user --groups=$usergroup1 unknown"
        expmsg="ipa: ERROR: unknown: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add user to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-015: Add user with all available attributes"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" $selinuxusermap3" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-add-user --users=$user1 --groups=$usergroup1,$usergroup2 --all --raw $selinuxusermap3 > $TmpDir/selinuxusermap-user-add-015.out" 0 "Add user $user1 and user group $usergroup1 to selinuxusermap"
	rlRun "cat $TmpDir/selinuxusermap-user-add-015.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-add-015.out"
        rlAssertGrep "memberuser: cn=$usergroup1,cn=groups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-add-015.out"
        rlAssertGrep "memberuser: cn=$usergroup2,cn=groups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-add-015.out"
        rlAssertGrep "memberuser: uid=$user1,cn=users,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-add-015.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-user-add-015.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-user-add-015.out"
        rlRun "ipa selinuxusermap-show $selinuxusermap3 > $TmpDir/selinuxusermap-add-user-show-015.out" 0 "Show selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-add-user-show-015.out"
        rlAssertGrep "Users: $user1" "$TmpDir/selinuxusermap-add-user-show-015.out"
        rlAssertGrep "User Groups: $usergroup1, $usergroup2" "$TmpDir/selinuxusermap-add-user-show-015.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap3" 0 "Delete user from selinuxusermap"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1,$usergroup2 $selinuxusermap3" 0 "Delete user groups from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-016: Add a user with a empty string"
	rlRun "ipa selinuxusermap-add-user --users=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-user-add-016.out" 0 "Add user with empty string to selinuxusermap"
	rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-user-add-016.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-017: Add a user groups with a empty string"
        rlRun "ipa selinuxusermap-add-user --groups=\"\" $selinuxusermap3 > $TmpDir/selinuxusermap-user-add-017.out" 0 "Add user group with empty string to selinuxusermap"
        rlAssertGrep "Number of members added 0" "$TmpDir/selinuxusermap-user-add-017.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-018: Add a user with --all option"
        rlLog "Executing:  ipa selinuxusermap-add-user --users=$user1 --all $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --users=$user1 --all $selinuxusermap3  > $TmpDir/selinuxusermap-user-add-018.out" 0 "Add a user with --all option"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-user-add-018.out"
        rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-user-add-018.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-user-add-018.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap3" 0 "Clean-up: Delete user from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-019: Add a user with --raw option without --all"
        rlLog "Executing:  ipa selinuxusermap-add-user --users=$user1 --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --users=$user1 --raw $selinuxusermap3  > $TmpDir/selinuxusermap-user-add-019.out" 0 "Add a user with --raw option"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-add-019.out"
        rlAssertGrep "memberuser: uid=$user1,cn=users,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-add-019.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-user-add-019.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap3" 0 "Clean-up: Delete user from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-020: Add a user with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-user --users=$user1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --users=$user1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-user-add-020.out" 0 "Add a user with --all --raw option"
	rlRun "cat $TmpDir/selinuxusermap-user-add-020.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-add-020.out"
        rlAssertGrep "memberuser: uid=$user1,cn=users,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-add-020.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-user-add-020.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-user-add-020.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-user-add-020.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap3" 0 "Clean-up: Delete user from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-021: Add a user group with --all --raw option"
        rlLog "Executing:  ipa selinuxusermap-add-user --groups=$usergroup1 --all --raw $selinuxusermap3 "
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1 --all --raw $selinuxusermap3  > $TmpDir/selinuxusermap-user-add-021.out" 0 "Add a user group with --all --raw option"
	rlRun "cat $TmpDir/selinuxusermap-user-add-021.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-user-add-021.out"
        rlAssertGrep "memberuser: cn=$usergroup1,cn=groups,cn=accounts,$basedn" "$TmpDir/selinuxusermap-user-add-021.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-user-add-021.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-user-add-021.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-user-add-021.out"
        rlRun "ipa selinuxusermap-remove-user --groups=$usergroup1 $selinuxusermap3" 0 "Clean-up: Delete user group from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-022: Add a user when selinuxusermap already has a hbacrule defined"
	rlRun "ipa hbacrule-add rule1"
	rlRun "ipa hbacrule-add-user rule1 --users=$user1"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=rule1 $selinuxusermap4"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=rule1 $selinuxusermap4" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap4" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule rule1 $selinuxusermap4" 0 "Verifying selinuxusermap was added with given HbacRule"
	command="ipa selinuxusermap-add-user --users=$user1 $selinuxusermap4"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify add user to a unknown selinuxusermap fails"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-user-add-cli-023: Create a selinux context for a user with unconfined_u:s0-s0:c0.c1023 on any machine"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap5"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap5" 0 "Add a selinuxusermap with --hostcat=all"
        rlRun "findSelinuxusermap $selinuxusermap5" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap5" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hostcat all $selinuxusermap5" 0 "Verifying selinuxusermap was added with --hostcat=all"
        rlLog "Executing: ipa selinuxusermap-add-user --users=$user1 $selinuxusermap5"
        rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap5 > $TmpDir/selinuxusermap-user-add-023.out" 0 "Add a user to access any machine"
        rlAssertGrep "Number of members added 1" "$TmpDir/selinuxusermap-user-add-023.out"
        rlRun "ipa selinuxusermap-remove-user --users=$user1 $selinuxusermap5" 0 "Clean-up: Delete user from selinuxusermap"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-user-add-cli-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 $selinuxusermap5 ; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done
	for item in $user1 $user2 $user3; do
		rlRun "ipa user-del $item" 0 "Delete user $item."
	done

	for item in $usergroup1 $usergroup2 $usergroup3; do
		rlRun "deleteGroup $item" 0 "Deleting User Group associated with rule."
	done
	rlRun "deleteHBACRule rule1" 0 "Deleting hbac rule1"
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
