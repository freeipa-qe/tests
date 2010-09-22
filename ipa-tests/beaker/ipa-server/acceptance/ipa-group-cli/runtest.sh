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

########################################################################
# Test Suite Globals
########################################################################
ADMINID="admin"
ADMINPWD="Admin123"

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

    rlPhaseStartTest "ipa-group-cli-05: Verify user's UID and Users' private group GID match"
	ipa user-show --all jennyg > /tmp/showuser.out
	USERIDNUM=`cat /tmp/showuser.out | grep UID | cut -d ":" -f 2`
	USERIDNUM=`echo $USERIDNUM`
	rlLog " User's uidNumber is $USERIDNUM"
	rlRun "verifyGroupAttr jennyg uidNumber $USERIDNUM" 0 "Verify User's Private Group GID matches user's UID"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-06: Delete user and check for Private Group Removal"
	rlRun "ipa user-del jennyg" 0 "Deleting Test User"
	rlRun "verifyGroupClasses jennyg upg" 2 "Verify user's private group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-07: Detach UPG"
        rlRun "ipa user-add --first Jenny --last Galipeau jennyg" 0 "Adding Test User"
        rlRun "detachUPG jennyg" 0 "Detach user's private group."
	rlRun "verifyGroupClasses jennyg ipa" 0 "Verify group is regular group now."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-08: Verify group find returns detached group" 
 	rlRun "findGroup jennyg" 0 "Group should now be returned by group-find command."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-09: Delete Detached UPG"
	rlRun "deleteGroup jennyg" 0 "Deleting detached user private group."
	rlRun "ipa user-del jennyg" 0 "Cleanup - Delete the test user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-10: Add Posix Group"
	rlRun "addPosixGroup \"My Posix Group\" myposixgroup" 0 "Adding posix group"
	rlRun "verifyGroupClasses myposixgroup posix" 0 "Verify group has posixgroup objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-11: Modify Posix Group"
	rlRun "modifyGroup myposixgroup desc \"My New Posix Group Description\"" 0 "Modifying posix group description"
	rlRun "verifyGroupAttr myposixgroup Description \"My New Posix Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-12: Delete posix Group"
        rlRun "deleteGroup myposixgroup" 0 "Deleting posix group"
        rlRun "findGroup myposixgroup" 1 "Verify posix group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-13: Add Regular IPA Group"
	rlRun "addGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
	rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-14: Modify IPA Group"
        rlRun "modifyGroup regular desc \"My New IPA Group Description\"" 0 "Modifying ipa group description"
        rlRun "verifyGroupAttr regular Description \"My New IPA Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-15: Modify IPA Group - add Posix"
        rlRun "ipa group-mod --posix regular" 0 "Making IPA group a posix group"
        rlRun "verifyGroupClasses regular posix" 0 "Verify group has ipa posix group objectclasses."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-16: Negative - add Posix to group that is already posix"
        command="ipa group-mod --posix regular"
        expmsg="ipa: ERROR: This is already a posix group"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-17: Delete IPA Group"
	rlRun "deleteGroup regular" 0 "Deleting IPA group"
	rlRun "findGroup regular" 1 "Verify posix group was removed."
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

    rlPhaseStartTest "ipa-group-cli-23: Negative - Add Duplicate Group"
	rlRun "addGroup test test" 0 "Setup - Adding a group"
        command="ipa group-add --desc=test test"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlRun "deleteGroup test" 0 "Cleanup - Deleting the group"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-24: Add Nested Groups Memberships"
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

    rlPhaseStartTest "ipa-group-cli-25: Add Nested User Memberships"
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

    rlPhaseStartTest "ipa-group-cli-26: Verify Group Memberships - Group: disneyworld"

	rlLog "=====================  group-show ==================="
	ipa group-show disneyworld > /tmp/showgroup.out
	groups=`cat /tmp/showgroup.out | grep "Member groups:"`
	for item in epcot animalkingdom japan germany fish dinasaurs ; do
		echo $groups | grep $item
		rc=$?
		rlAssert0 "Checking if group $item is a member of group disneyworld - group-show" $rc
	done 

        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in wdisney euser1 euser2 trainer1 trainer2 guser1 guser2 juser1 juser2 mdolphin trex ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group disneyworld - group-show" $rc
        done	

	rlLog "=====================  group-find ==================="
        ipa group-find disneyworld > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        for item in epcot animalkingdom japan germany fish dinasaurs ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group disneyworld - group-find" $rc
        done

	users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in wdisney euser1 euser2 trainer1 trainer2 guser1 guser2 juser1 juser2 mdolphin trex ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group disneyworld - group-show" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-27: Verify Group Memberships - Group: epcot"

	rlLog "=====================  group-show ==================="
        ipa group-show epcot > /tmp/showgroup.out
        groups=`cat /tmp/showgroup.out | grep "Member groups:"`
        for item in japan germany ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group epcot - group-show" $rc
        done

        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in euser1 euser2 guser1 guser2 juser1 juser2 ; do
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

	userss=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in euser1 euser2 guser1 guser2 juser1 juser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group epcot - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-28: Verify Group Memberships - Group: animalkingdom"

	rlLog "=====================  group-show ==================="
        ipa group-show animalkingdom > /tmp/showgroup.out
        groups=`cat /tmp/showgroup.out | grep "Member groups:"`
        for item in fish dinasaurs ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group animalkingdom group-show" $rc
        done

	users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in trainer1 trainer2 trex guser1 mdolphin juser1; do
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
        for item in trainer1 trainer2 trex guser1 mdolphin juser1; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group animalkingdom - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-29: Verify Group Memberships - Group: dinasaurs"
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

    rlPhaseStartTest "ipa-group-cli-30: Verify Group Memberships - Group: fish"
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

    rlPhaseStartTest "ipa-group-cli-31: Verify Group Memberships - Group: germany"
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

    rlPhaseStartTest "ipa-group-cli-32: Verify Group Memberships - Group: japan"
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

    rlPhaseStartTest "ipa-group-cli-33: Negative - Add Group Member that is already a member"
        result=`ipa group-add-member --groups=germany epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-35: Negative - Add User Member that is already a member"
        result=`ipa group-add-member --users=euser1 epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-36: Negative - Add Group Member that doesn't exist"
        result=`ipa group-add-member --groups=doesntexist epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-37: Negative - Add User Member that doesn't exist"
        result=`ipa group-add-member --users=doesntexist epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-38: Negative - Remove Group Member that doesn't exist"
        result=`ipa group-remove-member --users=doesntexist epcot`
        echo $result | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "0 Members should be removed" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-39: Negative - Remove User Member that doesn't exist"
        result=`ipa group-remove-member --users=doesntexist epcot`
        echo $result | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "0 Members should be removed" $rc
    rlPhasEnd

    rlPhaseStartTest "ipa-group-cli-40: Removed Single User Member"
	rlRun "removeGroupMembers users juser1 fish" 0 "Removing user juser1 from group fish."
        ipa group-find fish > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep juser1
	rc=$?
	rlAssertNotEquals "Checking that user is no longer a member" $rc 0
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-41: Removed Single Group Member"
        rlRun "removeGroupMembers groups fish animalkingdom" 0 "Removing group fish from group animalkingdom."
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep fish
        rc=$?
        rlAssertNotEquals "Checking that group is no longer a member" $rc 0
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-42: Removed Multiple Group Members"
        rlRun "removeGroupMembers groups \"germany,japan\" epcot" 0 "Removing groups germany and japan from group epcot."
        ipa group-find epcot > /tmp/findgroup.out
	groups=`cat /tmp/findgroup.out | grep "Member groups:"`
	for items in germany japan ; do
        	echo $groups | grep $item
        	rc=$?
        	rlAssertNotEquals "Checking that group $item is no longer a member" $rc 0
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-43: Removed Multiple User Members"
        rlRun "removeGroupMembers users \"guser1,guser2\" germany" 0 "Removing users guser1 and guser2 from group germany."
        ipa group-find germany > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for items in guser1 guser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssertNotEquals "Checking that user $item is no longer a member" $rc 0
        done
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-group-cli-cleanup: Destroying admin credentials."
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd
