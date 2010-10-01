#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-group-cli
#   Description: IPA group CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  group-add            Create a new group.
#  group-add-member     Add members to a group.
#  group-del            Delete group.
#  group-detach         Detach a managed group from a user
#  group-find           Search for groups.
#  group-mod            Modify a group.
#  group-remove-member  Remove members from a group.
#  group-show           Display information about a named group.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
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
. /usr/lib/beakerlib/beakerlib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################
# ADMINID is now part of env.sh
#ADMINID="admin"
ADMINPWD=$ADMINPW

BASEDN="dc=$RELM"
USERRDN="cn=users,cn=accounts,"
USERDN="$USERRDN$BASEDN"
USERRDN="cn=users,cn=accounts,"
GROUPDN="$GROUPRDN$BASEDN"
echo "USERDN is $USERDN"
echo "GROUPDN is $GROUPDN"
echo "Server is $MASTER"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-group-cli-startup: Check for admintools package and Kinit"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-01: Add user and check for Private Group Creation"
        rlRun "ipa user-add --first Jenny --last Galipeau jennyg" 0 "Adding Test User"
        rlRun "verifyGroupClasses \"jennyg\" upg" 0 "Verifying user's private group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-02: Attempted to delete managed private group"
        command="ipa group-del jennyg"
        expmsg="ipa: ERROR: Deleting a managed group is not allowed. It must be detached first."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-03: Verify private group not returned with group-find command"
        result=`ipa group-find jennyg`
	echo $result | grep "0 groups matched"
	rc=$?
	rlAssert0 "0 Groups should be matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-04: Verify private group is returned with group-show command"
	rlRun "verifyGroupAttr jennyg Description \"Description: User private group for jennyg\"" 0 "Verify UPG description."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-05: Verify User Private Group"
	rlRun "verifyUPG jennyg" 0 "UPG verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-06: Delete user and check for Private Group Removal"
	rlRun "ipa user-del jennyg" 0 "Deleting Test User"
	rlRun "verifyGroupClasses jennyg upg" 2 "Verify user's private group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-07: Detach UPG"
        rlRun "ipa user-add --first Jenny --last Galipeau jennyg" 0 "Adding Test User"
        rlRun "detachUPG jennyg" 0 "Detach user's private group."
	rlRun "verifyGroupClasses jennyg posix" 0 "Verify group is regular group now."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-08: Verify group find returns detached group" 
 	rlRun "findGroup jennyg" 0 "Group should now be returned by group-find command."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-09: Delete Detached UPG"
	rlRun "deleteGroup jennyg" 0 "Deleting detached user private group."
	rlRun "ipa user-del jennyg" 0 "Cleanup - Delete the test user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-10 Add IPA Group"
	rlRun "addGroup \"My Posix Group\" myposixgroup" 0 "Adding IPA posix group"
	rlRun "verifyGroupClasses myposixgroup posix" 0 "Verify group has posixgroup objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-11: Modify IPA Posix Group"
	rlRun "modifyGroup myposixgroup desc \"My New Posix Group Description\"" 0 "Modifying IPA posix group description"
	rlRun "verifyGroupAttr myposixgroup Description \"My New Posix Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-12: Delete IPA posix Group"
        rlRun "deleteGroup myposixgroup" 0 "Deleting posix group"
        rlRun "findGroup myposixgroup" 1 "Verify IPA posix group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-13: Add Regular IPA Group"
	rlRun "addNonPosixGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
	rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-14: Modify IPA Regular Group"
        rlRun "modifyGroup regular desc \"My New IPA Group Description\"" 0 "Modifying ipa group description"
        rlRun "verifyGroupAttr regular Description \"My New IPA Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-15: Delete IPA regular Group"
        rlRun "deleteGroup regular" 0 "Deleting non posix group"
        rlRun "findGroup regular" 1 "Verify non posix group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-16: Modify IPA Group - NON Posix"
	rlRun "addGroup test testgroup" 0 "Adding a test group"
        rlRun "ipa group-mod --nonposix testgroup" 0 "Making IPA group a non posix group"
        rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa non posix group objectclasses."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-17: Negative - modify non Posix to group that is already non posix"
        command="ipa group-mod --nonposix testgroup"
        expmsg="ipa: ERROR: This is already not a posix group"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlRun "deleteGroup testgroup" 0 "Cleaning up the test group"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-18: Negative - Delete group that doesn't exist"
        command="ipa group-del doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-19: Negative - Modify group that doesn't exist"
        command="ipa group-mod --desc=description doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-20: Negative - Find group that doesn't exist"
        result=`ipa group-find doesntexist`
        echo $result | grep "0 groups matched"
        rc=$?
        rlAssert0 "0 Groups should be matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-21: Negative - Show group that doesn't exist"
        command="ipa group-show doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-22: Negative - Detach group that doesn't exist"
        command="ipa group-detach doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-23: Negative - setattr group that doesn't exist"
        command="ipa group-mod --setattr dn=mynewDN doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-24: Negative - addattr group that doesn't exist"
        command="ipa group-mod --addattr dn=mynewDN doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-25: Negative - Add Duplicate Group"
	rlRun "addGroup test test" 0 "Setup - Adding a group"
        command="ipa group-add --desc=test test"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlRun "deleteGroup test" 0 "Cleanup - Deleting the group"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-26: Add Nested Groups Memberships"
	# add the groups
        rlRun "addGroup \"Florida Resort\" disneyworld" 0 "Adding Parent group"
	rlRun "addGroup \"All around the world\" epcot" 0 "Adding Second level group"
	rlRun "addGroup \"Where the wildlife is\" animalkingdom" 0 "Adding Second level group"
	rlRun "addGroup \"Country 1\" germany" 0 "Adding Third level group"
	rlRun "addGroup \"Country 2\" japan" 0 "Adding Third level group"
	rlRun "addGroup \"Prehistoric ones\" dinasaurs" 0 "Adding Third level group"
	rlRun "addGroup \"Under water ones\" fish" 0 "Adding Third level group"

	# nest the groups
	rlRun "addGroupMembers groups \"epcot,animalkingdom\" disneyworld" 0 "Nesting second level groups"
	rlRun "addGroupMembers groups \"germany,japan\" epcot" 0 "Nesting first third level"
	rlRun "addGroupMembers groups \"dinasaurs,fish\" animalkingdom" 0 "Nesting second third level"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-27: Add Nested User Memberships"
	# add the users
	rlRun "ipa user-add --first=Walt --last=Disney wdisney" 0 "Adding user wdisney"
	rlRun "ipa user-add --first=Epcot --last=User1 euser1" 0 "Adding user euser1"
	rlRun "ipa user-add --first=Epcot --last=User2 euser2" 0 "Adding user euser2"
	rlRun "ipa user-add --first=German --last=User1 guser1" 0 "Adding user guser1"
	rlRun "ipa user-add --first=German --last=User2 guser2" 0 "Adding user guser2"
	rlRun "ipa user-add --first=Japan --last=User1 juser1" 0 "Adding user juser1"
	rlRun "ipa user-add --first=Japan --last=User2 juser2" 0 "Adding user juser2"
	rlRun "ipa user-add --first=My --last=Trainer1 trainer1" 0 "Adding user trainer1"
	rlRun "ipa user-add --first=My --last=Trianer2 trainer2" 0 "Adding user trainer2"
	rlRun "ipa user-add --first=Mister --last=Dolphin mdolphin" 0 "Adding user mdolphin"
	rlRun "ipa user-add --first=Tee --last=Rex trex" 0 "Adding user trex" 

	# add the user memberships
	rlRun "addGroupMembers users wdisney disneyworld" 0 "Adding user wdisney to group disneyworld."
	rlRun "addGroupMembers users \"euser1,euser2\" epcot" 0 "Adding users euser1 and euser2 to group epcot."
	rlRun "addGroupMembers users \"guser1,guser2\" germany" 0 "Adding users guser1 and guser2 to group germany."
	rlRun "addGroupMembers users \"juser1,juser2\" japan" 0 "Adding users juser1 and juser2 to group japan."
	rlRun "addGroupMembers users \"trainer1,trainer2\" animalkingdom" 0 "Adding users trainer1 and trainer2 to group animalkingdom."
	rlRun "addGroupMembers users \"mdolphin,juser1\" fish" 0 "Adding users mdolphin and juser1 to group fish."
	rlRun "addGroupMembers users \"trex,guser1\" dinasaurs" 0 "Adding users trex and guser1 to group dinasaurs."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-28: Verify Group Memberships - Group: disneyworld"

        rlRun "verifyGroupMember epcot group disneyworld" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember animalkingdom group disneyworld" 0 "member and memberOf attribute verification"
	rlRun "verifyGroupMember wdisney user disneyworld" 0 "member and memberOf attribute verification"

	rlLog "=====================  group-show ==================="
	ipa group-show disneyworld > /tmp/showgroup.out
	groups=`cat /tmp/showgroup.out | grep "Member groups:"`
	for item in epcot animalkingdom ; do
		echo $groups | grep $item
		rc=$?
		rlAssert0 "Checking if group $item is a member of group disneyworld - group-show" $rc
	done 

        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in wdisney ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group disneyworld - group-show" $rc
        done	

	rlLog "=====================  group-find ==================="
        ipa group-find disneyworld > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        for item in epcot animalkingdom ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group disneyworld - group-find" $rc
        done

	users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in wdisney ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group disneyworld - group-show" $rc
        done

    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-29: Verify Group Memberships - Group: epcot"

        rlRun "verifyGroupMember germany group epcot" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember japan group epcot" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember euser1 user epcot" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember euser2 user epcot" 0 "member and memberOf attribute verification"

	rlLog "=====================  group-show ==================="
        ipa group-show epcot > /tmp/showgroup.out
        groups=`cat /tmp/showgroup.out | grep "Member groups:"`
        for item in japan germany ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group epcot - group-show" $rc
        done

        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in euser1 euser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group epcot - group-show" $rc
        done

	rlLog "=====================  group-find ==================="
        ipa group-find epcot > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        for item in japan germany ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group epcot - group-find" $rc
        done

	users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in euser1 euser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group epcot - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-30: Verify Group Memberships - Group: animalkingdom"

        rlRun "verifyGroupMember fish group animalkingdom" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember dinasaurs group animalkingdom" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember trainer1 user animalkingdom" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember trainer2 user animalkingdom" 0 "member and memberOf attribute verification"

	rlLog "=====================  group-show ==================="
        ipa group-show animalkingdom > /tmp/showgroup.out
        groups=`cat /tmp/showgroup.out | grep "Member groups:"`
        for item in fish dinasaurs ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group animalkingdom group-show" $rc
        done

	users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group animalkingdom - group-show" $rc
        done

	rlLog "=====================  group-find ==================="
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        for item in fish dinasaurs ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group animalkingdom - group-find" $rc
        done

        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group animalkingdom - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-31: Verify Group Memberships - Group: dinasaurs"

        rlRun "verifyGroupMember trex user dinasaurs" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember guser1 user dinasaurs" 0 "member and memberOf attribute verification"

        rlLog "=====================  group-show ==================="
        ipa group-show dinasaurs > /tmp/showgroup.out
        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in trex guser1 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group dinasaurs - group-show" $rc
        done

        rlLog "=====================  group-find ==================="
        ipa group-find dinasaurs > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in trex guser1 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group dinasaurs - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-32: Verify Group Memberships - Group: fish"

        rlRun "verifyGroupMember mdolphin user fish" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember juser1 user fish" 0 "member and memberOf attribute verification"

        rlLog "=====================  group-show ==================="
        ipa group-show fish > /tmp/showgroup.out
        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in mdolphin juser1 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group fish - group-show" $rc
        done

        rlLog "=====================  group-find ==================="
        ipa group-find fish > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in mdolphin juser1 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group fish - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-33: Verify Group Memberships - Group: germany"

        rlRun "verifyGroupMember guser1 user germany" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember guser2 user germany" 0 "member and memberOf attribute verification"

        rlLog "=====================  group-show ==================="
        ipa group-show germany > /tmp/showgroup.out
        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in guser1 guser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group germany - group-show" $rc
        done


        rlLog "=====================  group-find ==================="
        ipa group-find germany > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in guser1 guser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group germany -  group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-34: Verify Group Memberships - Group: japan"

        rlRun "verifyGroupMember juser1 user japan" 0 "member and memberOf attribute verification"
        rlRun "verifyGroupMember juser2 user japan" 0 "member and memberOf attribute verification"

        rlLog "=====================  group-show ==================="
        ipa group-show japan > /tmp/showgroup.out
        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in juser1 juser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group japan - group-show" $rc
        done

        rlLog "=====================  group-find ==================="
        ipa group-find japan > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in juser1 juser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group japan -  group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-35: Negative - Add Group Member that is already a member"
        result=`ipa group-add-member --groups=germany epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-36: Negative - Add User Member that is already a member"
        result=`ipa group-add-member --users=euser1 epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-37: Negative - Add Group Member that doesn't exist"
        result=`ipa group-add-member --groups=doesntexist epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-38: Negative - Add User Member that doesn't exist"
        result=`ipa group-add-member --users=doesntexist epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-39: Negative - Remove Group Member that doesn't exist"
        result=`ipa group-remove-member --users=doesntexist epcot`
        echo $result | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "0 Members should be removed" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-40: Negative - Remove User Member that doesn't exist"
        result=`ipa group-remove-member --users=doesntexist epcot`
        echo $result | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "0 Members should be removed" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-41: Removed Single User Member"
	# DIRECT MEMBERSHIP - fish
	rlRun "removeGroupMembers users mdolphin fish" 0 "Removing user mdolphin from group fish."
        ipa group-find fish > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep mdolpin
	rc=$?
	rlAssertNotEquals "Checking that user is no longer a member of direct group fish" $rc 0

	# INDIRECT MEMBERSHIPS - animalkingdom and disneyworld
        ipa group-find animalkingdon > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep mdolpin
        rc=$?
        rlAssertNotEquals "Checking that user is no longer a member of indirect group animalkingdom" $rc 0

        ipa group-find disneyworld > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep mdolpin
        rc=$?
        rlAssertNotEquals "Checking that user is no longer a member of indirect group disneyworld" $rc 0

	rlRun "verifyGroupMember mdolphin user fish" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-42: Removed Single Group Member"
	# DIRECT MEMBERSHIP - animalkingdom
        rlRun "removeGroupMembers groups fish animalkingdom" 0 "Removing group fish from group animalkingdom."
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep fish
        rc=$?
        rlAssertNotEquals "Checking that group is no longer a member of direct group animalkingdom" $rc 0

	# INDIRECT MEMBERSHIP - disneyworld
        ipa group-find disneyworld > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep fish
        rc=$?
        rlAssertNotEquals "Checking that group is no longer a member of indirect group disneyworld" $rc 0

	# INDIRECT USER MEMBERSHIP - juser1
        ipa group-find animalkingdom > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
        rc=$?
        rlAssertNotEquals "Checking that user is no longer a member of indirect group animalkingdom" $rc 0

        ipa group-find disneyworld > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
        rc=$?
        rlAssertNotEquals "Checking that user is no longer a member of indirect group disneyworld" $rc 0

	rlRun "verifyGroupMember fish group animalkingdom" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-43: Removed Multiple Group Members"
	# DIRECT GROUP MEMBERSHIP - epcot
        rlRun "removeGroupMembers groups \"germany,japan\" epcot" 0 "Removing groups germany and japan from group epcot."
        ipa group-find epcot > /tmp/findgroup.out
	groups=`cat /tmp/findgroup.out | grep "Member groups:"`
	for item in germany japan ; do
        	echo $groups | grep $item
        	rc=$?
        	rlAssertNotEquals "Checking that group $item is no longer a member of direct group epcot" $rc 0
	done

        # INDIRECT USER MEMBERSHIPS - epcot
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in juser1 juser2 guser1 guser2; do
                echo $groups | grep $item
                rc=$?
                rlAssertNotEquals "Checking that user $item is no longer a member of indirect group disneyworld" $rc 0
        done

        # INDIRECT GROUP MEMBERSHIPS - disneyworld
        ipa group-find disneyworld > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        for item in germany japan ; do
                echo $groups | grep $item
                rc=$?
                rlAssertNotEquals "Checking that group $item is no longer a member of indirect group disneyworld" $rc 0
        done

	# INDIRECT USER MEMBERSHIPS - disneyworld
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in juser1 juser2 guser1 guser2; do
                echo $groups | grep $item
                rc=$?
                rlAssertNotEquals "Checking that user $item is no longer a member of indirect group disneyworld" $rc 0
        done

	rlRun "verifyGroupMember germany group epcot" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember japan group epcot" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-44: Removed Multiple User Members"
        rlRun "removeGroupMembers users \"trainer1,trainer2\" animalkingdom" 0 "Removing users trainer1 and trainer2 from group animalkingdom."
	# DIRECT GROUP MEMBERSHIPS - animalkingdom
        ipa group-find animalkingdom > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssertNotEquals "Checking that user $item is no longer a member of direct group animalkingdom" $rc 0
        done

        # INDIRECT GROUP MEMBERSHIPS - disneyworld
        ipa group-find disneyworld > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssertNotEquals "Checking that user $item is no longer a member of indirect group disneyworld" $rc 0
        done

	rlRun "verifyGroupMember trainer1 user animalkingdom" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember trainer2 user animalkingdom" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-45: Delete User that is a member of two Groups"
	rlRun "ipa user-del juser1" 0 "Deleting user that is member of two groups"
	# DIRECT MEMBERSHIPS
        ipa group-find fish > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
        rc=$?
        rlAssertNotEquals "Checking that user $item is no longer a member of direct group fish" $rc 0

        ipa group-find japan > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
        rc=$?
        rlAssertNotEquals "Checking that user $item is no longer a member of direct group japan" $rc 0

	# INDIRECT MEMBERSHIPS
        ipa group-find animalkingdom > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
        rc=$?
        rlAssertNotEquals "Checking that user $item is no longer a member of indirect group animalkingdom" $rc 0

        ipa group-find disneyworld > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
        rc=$?
        rlAssertNotEquals "Checking that user $item is no longer a member of indirect group disneyworld" $rc 0

	rlRun "verifyGroupMember juser1 group japan" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember juser1 group fish" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-46: Delete group with two members"
	rlRun "deleteGroup dinasaurs" 0 "Deleting lower level nested group"
	# DIRECT MEMBERSHIP
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep dinasaurs
        rc=$?
        rlAssertNotEquals "Checking that group dinasaur is no longer a member of direct group animalkingdom" $rc 0

	# INDIRECT MEMBERSHIP
        ipa group-find disneyworld > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep dinasaurs
        rc=$?
        rlAssertNotEquals "Checking that group dinasaur is no longer a member of indirect group disneyworld" $rc 0

	rlRun "verifyGroupMember trex user dinasaurs" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember guser1 group dinasaurs" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-47: Delete Groups"
	# lets clean up
	for item in disneyworld animalkingdom epcot japan germany ; do
		rlRun "deleteGroup $item" 0 "Deleting group $item"
	done

	for item in wdisney trainer1 trainer2 euser1 euser2 juser2 guser1 guser2 ; do
		rlRun "ipa user-del $item" 0 "Deleting user $item"
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-48: Negative - setattr and addattr on dn"
        command="ipa group-mod --setattr dn=mynewDN fish"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr dn=anothernewDN fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-49: Negative - setattr and addattr on ipauniqueid"
        command="ipa group-mod --setattr ipauniqueid=mynew-unique-id fish"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'ipaUniqueID' attribute of entry 'cn=fish,cn=groups,cn=accounts,dc=testrelm'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr ipauniqueid=another-new-unique-id fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-50: Negative - setattr and addattr on cn"
        command="ipa group-mod --setattr cn=\"cn=new,cn=groups,dc=domain,dc=com\" fish"
        expmsg="ipa: ERROR: Operation not allowed on RDN:"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr cn=\"cn=new,cn=groups,dc=domain,dc=com\" fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-51: setattr and addattr on description"
        attr="description"
        rlRun "setAttribute group $attr new fish" 0 "Setting attribute $attr to value of new."
        rlRun "verifyGroupAttr fish desc new" 0 "Verifying group $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa group-mod --addattr description=newer fish"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-52: setattr and addattr on member"
        attr="member"
	member1="uid=trex,$USERDN"
	member2="uid=mdolphin,$USERDN"
	command="ipa group-mod --setattr member=\"$member1\" fish"
	expmsg="ipa: ERROR: Operation not allowed on member"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	command="ipa group-mod --addattr member=\"$member2\" fish"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-53: Negative - setattr and addattr on invalid attribute"
        command="ipa group-mod --setattr bad=test fish"
        expmsg="ipa: ERROR: attribute \"bad\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --setattr bad=test fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-54: Allowed special characters"
	rlRun "addGroup \"Special Group\" \"my_gr-ou.p$\"" 0 "Adding group with special characters"
	rlRun "modifyGroup  \"my_gr-ou.p$\" desc  \"my_gr-ou.p$\"" 0 "Modifying group with special characters"
	rlRun "addGroupMembers users mdolphin \"my_gr-ou.p$\"" 0 "Adding member to group with special characters"
	rlRun "removeGroupMembers users mdolphin \"my_gr-ou.p$\"" 0 "Removing member from group with special characters"
	rlRun "deleteGroup \"my_gr-ou.p$\"" 0 "Deleting group with special characters"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-55: Not Allowed special characters @"
        command="ipa group-add --desc=\"test@\" \"test@\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-56: Not Allowed special characters %"
        command="ipa group-add --desc=\"test%\" \"test%\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-57: Not Allowed special characters ^"
        command="ipa group-add --desc=\"test^\" \"test^\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-58: Not Allowed special characters *"
        command="ipa group-add --desc=\"test*\" \"test*\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-59: Not Allowed special characters +"
        command="ipa group-add --desc=\"test+\" \"test+\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-60: Not Allowed special characters ~"
        command="ipa group-add --desc=\"test~\" \"test~\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-61: Not Allowed special characters ="
        command="ipa group-add --desc=\"test=\" \"test=\""
        expmsg="ipa: ERROR: invalid 'cn': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-group-cli-cleanup: Delete remaining users and group and Destroying admin credentials"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "ipa user-del trex" 0 "Deleting user trex."
	rlRun "ipa user-del mdolphin" 0 "Deleting user mdolphin."
	rlRun "deleteGroup fish" 0 "Deleting group fish."
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd
