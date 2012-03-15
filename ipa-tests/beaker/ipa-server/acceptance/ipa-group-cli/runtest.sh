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
#  --pkey-only          search groups using --pkey-only option
#  --in-groups          search groups using --in-groups option
#  --not-in-groups      search groups using --not-in-groups option
#  --in-netgroups       search groups using --in-netgroups option
#  --not-in-netgroups   search groups using --not-in-netgroups option

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
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################
# ADMINID is now part of env.sh
PACKAGE="ipa-admintools"
ADMINPWD=$ADMINPW

USERRDN="cn=users,cn=accounts,"
USERDN="$USERRDN$BASEDN"
USERRDN="cn=users,cn=accounts,"
GROUPRDN="$GROUPRDN$BASEDN"
echo "USERDN is $USERDN"
echo "GROUPDN is $GROUPDN"
echo "Server is $MASTER"

if [ -z $MASTER ] ; then
	export MASTER=`hostname`
fi
rlLog "MASTER: $MASTER"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-group-cli-startup: Check for admintools package and Kinit"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
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

    rlPhaseStartTest "ipa-group-cli-03: Verify private with group-find command"
        result=`ipa group-find jennyg`
	echo $result | grep "0 groups matched"
	rc=$?
	rlAssert0 "0 Groups should be matched" $rc

	result=`ipa group-find --private jennyg`
	echo $result | grep "1 group matched"
	rc=$?
	rlAssert0 "1 Group should be matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-04: Verify private group is returned with group-show command"
	rlRun "verifyGroupAttr jennyg Description \"User private group for jennyg\"" 0 "Verify UPG description."
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

    rlPhaseStartTest "ipa-group-cli-10 Add IPA Posix Group"
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

    rlPhaseStartTest "ipa-group-cli-13: Add IPA NON Posix Group"
	rlRun "addNonPosixGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
	rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-14: Modify IPA NON Posix Group"
        rlRun "modifyGroup regular desc \"My New IPA Group Description\"" 0 "Modifying ipa group description"
        rlRun "verifyGroupAttr regular Description \"My New IPA Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-15: Delete IPA NON Posix Group"
        rlRun "deleteGroup regular" 0 "Deleting non posix group"
        rlRun "findGroup regular" 1 "Verify non posix group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-16: Add Group - NON Posix - Modify to be Posix"
	rlRun "addNonPosixGroup test testgroup" 0 "Adding a non posix test group"
	rlRun "verifyGroupClasses testgroup ipa" 0 "Verify group has ipa non posix group objectclasses."
        rlRun "ipa group-mod --posix testgroup" 0 "Making NON posix group a posix group"
        rlRun "verifyGroupClasses testgroup posix" 0 "Verify group has ipa non posix group objectclasses."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-17: Negative - modify Posix to group that is already posix"
        command="ipa group-mod --posix testgroup"
        expmsg="ipa: ERROR: This is already a posix group"
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
        expmsg="ipa: ERROR: group with name test already exists"
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
		rlAssert0 "Checking if group $item is a direct member of group disneyworld - group-show" $rc
	done 

        groups=`cat /tmp/showgroup.out | grep "Indirect Member groups:"`
	for item in fish dinasaurs germany japan ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is an indirect member of group disneyworld - group-show" $rc
        done

        users=`cat /tmp/showgroup.out | grep "Member users:"`
        for item in wdisney ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a directory member of group disneyworld - group-show" $rc
        done	

        users=`cat /tmp/showgroup.out | grep "Indirect Member users:"`
        for item in euser1 euser2 guser1 guser2 juser1 juser2 trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is an indirect member of group disneyworld - group-show" $rc
        done

	rlLog "=====================  group-find ==================="
        ipa group-find disneyworld > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        for item in epcot animalkingdom ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a direct member of group disneyworld - group-find" $rc
        done

        groups=`cat /tmp/findgroup.out | grep "Indirect Member groups:"`
        for item in fish dinasaurs germany japan ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is an indirect member of group disneyworld - group-show" $rc
        done

	users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in wdisney ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a direct member of group disneyworld - group-show" $rc
        done

        users=`cat /tmp/findgroup.out | grep "Indirect Member users:"`
        for item in euser1 euser2 guser1 guser2 juser1 juser2 trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is an indirect member of group disneyworld - group-show" $rc
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
	rlRun "removeGroupMembers users mdolphin fish" 0 "Removing user mdolphin from group fish."
        ipa group-find fish > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep mdolpin
	rc=$?
	rlAssertNotEquals "Checking that user is no longer a member of direct group fish" $rc 0

	rlRun "verifyGroupMember mdolphin user fish" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-42: Removed Single Group Member"
	rlRun "removeGroupMembers groups fish animalkingdom" 0 "Removing user mdolphin from group fish."
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep fish
        rc=$?
        rlAssertNotEquals "Checking that group is no longer a member of direct group animalkingdom" $rc 0

	rlRun "verifyGroupMember fish group animalkingdom" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-43: Removed Multiple Group Members"
        rlRun "removeGroupMembers groups \"germany,japan\" epcot" 0 "Removing groups germany and japan from group epcot."
        ipa group-find epcot > /tmp/findgroup.out
	groups=`cat /tmp/findgroup.out | grep "Member groups:"`
	for item in germany japan ; do
        	echo $groups | grep $item
        	rc=$?
        	rlAssertNotEquals "Checking that group $item is no longer a member of direct group epcot" $rc 0
	done

	rlRun "verifyGroupMember germany group epcot" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember japan group epcot" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-44: Removed Multiple User Members"
        rlRun "removeGroupMembers users \"trainer1,trainer2\" animalkingdom" 0 "Removing users trainer1 and trainer2 from group animalkingdom."
        ipa group-find animalkingdom > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        for item in trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssertNotEquals "Checking that user $item is no longer a member of direct group animalkingdom" $rc 0
        done

	rlRun "verifyGroupMember trainer1 user animalkingdom" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember trainer2 user animalkingdom" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-45: Delete User that is a member of two Groups"
	rlRun "ipa user-del juser1" 0 "Deleting user that is member of two groups"
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

	rlRun "verifyGroupMember juser1 group japan" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember juser1 group fish" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-46: Delete group with two members"
	rlRun "deleteGroup dinasaurs" 0 "Deleting lower level nested group"
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep dinasaurs
        rc=$?
        rlAssertNotEquals "Checking that group dinasaur is no longer a member of direct group animalkingdom" $rc 0

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

    rlPhaseStartTest "ipa-group-cli-49: Negative - setattr and addattr on cn"
	# add a test group
	addGroup mynewgroup mynewgroup
	rlRun "setAttribute group cn blah mynewgroup" 0 "Setting new cn attribute"
	rlRun "verifyGroupAttr blah \"Group name\" blah" 0 "Verifying new cn attribute"
	expmsg="ipa: ERROR: cn: Only one value allowed."
        command="ipa group-mod --addattr cn=another blah"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	# delete the test group
	deleteGroup blah
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-50: setattr and addattr on description"
        rlRun "setAttribute group description new fish" 0 "Setting attribute $attr to value of new."
        rlRun "verifyGroupAttr fish Description new" 0 "Verifying group $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa group-mod --addattr description=newer fish"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-51: setattr and addattr on member"
	member1="uid=trex,$USERDN"
	member2="uid=mdolphin,$USERDN"
	#ipa group-mod --setattr member=\"$member1\" fish
	#ipa group-mod --addattr member=\"$member2\" fish
	rlRun "setAttribute group member \"$member1\" fish" 0 "setting member attribute member to $member"
	rlRun "addAttribute group member \"$member2\" fish" 0 "Adding attribute member $member"
	rlRun "verifyGroupMember trex user fish" 0 "member and memberOf attribute verification"
	rlRun "verifyGroupMember mdolphin user fish" 0 "member and memberOf attribute verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-52: setattr and addattr on memberOf"
        attr="memberOf"
        member1="cn=bogus,$GROUPRDN"
        member2="cn=bogus2,$GROUPRDN"
        command="ipa group-mod --setattr $attr=\"$member1\" fish"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'cn=fish,cn=groups,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr $attr=\"$member2\" fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-53: Negative - setattr and addattr on ipauniqueid"
        command="ipa group-mod --setattr ipauniqueid=mynew-unique-id fish"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --addattr ipauniqueid=another-new-unique-id fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd


    rlPhaseStartTest "ipa-group-cli-54: Negative - setattr and addattr on invalid attribute"
        command="ipa group-mod --setattr bad=test fish"
        expmsg="ipa: ERROR: attribute \"bad\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa group-mod --setattr bad=test fish"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-55: Allowed special characters"
	rlRun "addGroup \"Special Group\" \"my_gr-ou.p$\"" 0 "Adding group with special characters"
	rlRun "modifyGroup  \"my_gr-ou.p$\" desc  \"my_gr-ou.p$\"" 0 "Modifying group with special characters"
	rlRun "addGroupMembers users mdolphin \"my_gr-ou.p$\"" 0 "Adding member to group with special characters"
	rlRun "removeGroupMembers users mdolphin \"my_gr-ou.p$\"" 0 "Removing member from group with special characters"
	rlRun "deleteGroup \"my_gr-ou.p$\"" 0 "Deleting group with special characters"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-56: Not Allowed special characters @"
        command="ipa group-add --desc=\"test@\" \"test@\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-57: Not Allowed special characters %"
        command="ipa group-add --desc=\"test%\" \"test%\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-58: Not Allowed special characters ^"
        command="ipa group-add --desc=\"test^\" \"test^\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-59: Not Allowed special characters *"
        command="ipa group-add --desc=\"test*\" \"test*\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-60: Not Allowed special characters +"
        command="ipa group-add --desc=\"test+\" \"test+\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-61: Not Allowed special characters ~"
        command="ipa group-add --desc=\"test~\" \"test~\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-62: Not Allowed special characters ="
        command="ipa group-add --desc=\"test=\" \"test=\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-63: Negative - Add self as group member"
        ipa group-add-member --groups=fish fish > /tmp/error.out
        cat /tmp/error.out | grep "Number of members added 0"
        rc=$?
        rlAssert0 "Number of members added 0" $rc
	rlRun "deleteGroup fish" 0 "Cleanup: Deleting group fish."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-64: Add 10 groups and test find returns limit of 5"
	rlRun "ipa config-mod --searchrecordslimit=5" 0 "Set default search records limit to 5"
	i=1
	while [ $i -le 10 ] ; do
		addGroup Group$i Group$i
		let i=$i+1
	done

	ipa group-find > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "5 groups returned as expected with size limit of 0"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-65: find 0 groups"
	ipa group-find --sizelimit=0 > /tmp/groupfind.out
	result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
	if [ $number -eq 13 ] ; then
		rlPass "All groups returned as expected with size limit of 0"
	else
		rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 13"
	fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-66: find 10 groups"
        ipa group-find --sizelimit=10 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 10 ] ; then
                rlPass "All group returned as expected with size limit of 10"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-67: find 9 groups"
        ipa group-find --sizelimit=9 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 9 ] ; then
                rlPass "All group returned as expected with size limit of 9"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 9"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-68: find more groups than exist"
	ipa group-find --sizelimit=20 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 13 ] ; then
                rlPass "All group returned as expected with size limit of 20"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 13"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-69: find groups - size limit not an integer"
        expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa group-find --sizelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa group-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-70: find groups - time limit 0"
        ipa group-find --timelimit=0 > /tmp/groupfind.out
        result=`cat /tmp/groupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Limit of 5 groups returned as expected with time limit of 0"
        else
                rlFail "Number of groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-71: find groups - time limit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa group-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa group-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-72: Setting GID's to 0 and negative numbers."
    # Test for: https://fedorahosted.org/freeipa/ticket/2335
    # https://bugzilla.redhat.com/show_bug.cgi?id=786240
	rlRun "ipa group-add --desc=j-test jennygn" 0 "Adding Test Group"
	expmsg="ipa: ERROR: invalid 'gid': must be at least 1"
	for value in 0 -0 -100 ; do
        	command="ipa group-mod --gid=$value jennygn"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	done
    rlPhaseEnd 

    grp=gmodtest
    rlPhaseStartTest "ipa-group-cli-73: group-mod --addattr positive test case."
        rlRun "ipa group-add --desc=j-test $grp" 0 "Adding Test Group $grp" 
        rlRun "ipa group-mod --addattr memberUid=22344 $grp" 0 "Adding memberuid to $grp"
	rlRun "ipa group-find --all --raw $grp | grep 22344" 0 "Making sure new uid is in $grp"
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-group-cli-74: test deleting the attribute that was added in the last test"
	rlRun "ipa group-mod --delattr memberUid=22344 $grp" 0 "Deleting new memberUid"
	rlRun "ipa group-find --all --raw $grp | grep 22344" 1 "Making sure new uid is no longer in $grp"
    rlPhaseEnd

    var=Description
    rlPhaseStartTest "ipa-group-cli-75: group-mod --delattr negative test case for Description."
	val=$(ipa group-find --all $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var=$val $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=cn
    rlPhaseStartTest "ipa-group-cli-76: group-mod --delattr negative test case for cn."
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var='$val' $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep '$val'" 0 "Making sure $var still exists as '$val' in $grp"
    rlPhaseEnd

    var=gidnumber
    rlPhaseStartTest "ipa-group-cli-77: group-mod --delattr negative test case for gidnumber."
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var=$val $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=ipauniqueid
    rlPhaseStartTest "ipa-group-cli-78: group-mod --delattr negative test case for ipauniqueid."
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --delattr $var=$val $grp" 1 "trying to delete $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=memberuid
    rlPhaseStartTest "ipa-group-cli-79: group-mod --delattr + --addattr null op for non existant var memberUid."
	val=928374
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value maniuplation for $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 1 "Making sure $var still does not exist in $grp"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-80: group-mod --setattr + --addattr null op for field in memberUid."
	val="928374"
	val2="abcde"
	rlRun "ipa group-mod --addattr $var=$val --setattr $var=$val2 $grp" 0 "Testing a multi-value maniuplation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 0 "Making sure $var exists as $val2 in $grp"
    rlPhaseEnd

    var=Description
    rlPhaseStartTest "ipa-group-cli-81: group-mod --delattr + --addattr null op for Description."
	val=$(ipa group-find --all $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value maniuplation for $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=cn
    rlPhaseStartTest "ipa-group-cli-82: group-mod --delattr + --addattr null op for cn."
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var='$val' --delattr $var='$val' $grp" 1 "Testing a multi-value maniuplation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=gidnumber
    rlPhaseStartTest "ipa-group-cli-83: group-mod --delattr + --addattr null op for gidnumber."
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value maniuplation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=ipauniqueid
    rlPhaseStartTest "ipa-group-cli-84: group-mod --delattr + --addattr null op for ipauniqueid."
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	rlRun "ipa group-mod --addattr $var=$val --delattr $var=$val $grp" 1 "Testing a multi-value maniuplation for $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
    rlPhaseEnd

    var=Description
    rlPhaseStartTest "ipa-group-cli-85: group-mod --setattr + --addattr null op for Description."
	val=$(ipa group-find --all $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	val2="alt-description"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    var=cn
    rlPhaseStartTest "ipa-group-cli-86: group-mod --setattr + --addattr null op for cn."
	val=$(ipa group-find --all --raw $grp | grep $var: | cut -d: -f2 | sed s/\ //g)
	val2="cn2"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    var=gidnumber
    rlPhaseStartTest "ipa-group-cli-87: group-mod --setattr + --addattr null op for gidnumber."
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	val2="23456"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    var=ipauniqueid
    rlPhaseStartTest "ipa-group-cli-88: group-mod --setattr + --addattr null op for ipauniqueid."
	val=$(ipa group-find --all --raw $grp | grep $var | cut -d: -f2 | sed s/\ //g)
	val2="b77627fc-5dae-11e1-a45f-111111111111"
	rlRun "ipa group-mod --addattr $var='$val' --setattr $var='$val2' $grp" 1 "ensuring that we are unable to write multiple definitions of $var"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val" 0 "Making sure $var still exists as $val in $grp"
	rlRun "ipa group-find --all --raw $grp | grep $var | grep $val2" 1 "Making sure $var does not contain $val2 in $grp"
    rlPhaseEnd

    # Details for the next test
    #1) add a group
    #2) add a user to the group
    #3) attempt to --delattr on the user's memberOf attribute (this should NOT be allowed)
    #4) attempt to --delattr on the group's member attribute (this should be allowed)
    #5) then verify that the user's memberOf attribute no longer exists.
    rlPhaseStartTest "ipa-group-cli-89: delattr test of member attributes"
	rlRun "ipa group-add-member --users=trex $grp" 0 "adding trex to group"
	rlRun "ipa user-find --all --raw trex | grep memberof | grep $grp" 0 "making sure that the memberof entry was added to user trex"
	rlRun "ipa user-mod --delattr=memberof='cn=$grp,cn=groups,cn=accounts,dc=testrelm,dc=com' trex" 1 "trying to delete memberof entry from $usr, this should fail"
	rlRun "ipa user-find --all --raw trex | grep memberof | grep $grp" 0 "making sure that the memberof entry is still in user trex"
	rlRun "ipa group-mod --delattr=member='uid=trex,cn=users,cn=accounts,dc=testrelm,dc=com' $grp" 0 "Removing the member entry from the group"
	rlRun "ipa user-find --all --raw trex | grep memberof | grep $grp" 1 "making sure that the memberof entry was removed from user trex"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-90: check of --pkey-only"
	ipa_command_to_test="group"
	pkey_addstringa="--desc=junk-desc"
	pkey_addstringb="--desc=junk-desc"
	pkeyobja="39user"
	pkeyobjb="39userb"
	grep_string='Group\ name'
	general_search_string=$pkeyobja
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in group-find"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-91: bz773488 - Make ipausers a non-posix group on new installs"
        rlRun "verifyGroupClasses ipausers ipa" 0 "Verify ipauser group objectclasses."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-92: Negative  Test of --in-groups in group-find"
	ipa group-add --desc=desc1 uuu
	ipa group-add --desc=desc1 ggg
	rlRun "ipa group-find --in-groups=ggg | grep Group\ name: | grep uuu" 1 "Making sure that group uuu does not come back when searching --in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-93: Positive Test of --in-groups in group-find"
	ipa group-add-member --groups=uuu ggg
	rlRun "ipa group-find --in-groups=ggg | grep uuu" 0 "Making sure that group uuu comes back when searching --in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-94: Negative Test of --not-in-groups in group-find"
	ipa group-add --desc=desc1 tusera
	rlRun "ipa group-find --not-in-groups=ggg | grep Group\ name: | grep uuu" 1 "Making sure that group ggg does not come back when searching --not-in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-95: Positive test of --not-in-groups in group-find"
	rlRun "ipa group-find --not-in-groups=ggg | grep Group\ name: | grep tusera" 0 "Making sure that group tusera comes back when searching --not-in-groups=ggg"
    rlPhaseEnd
    # these -in-group tests are continued at test number 120

    hb="hbrut"
    gb="grpbt"
    rlPhaseStartTest "ipa-group-cli-96: Positive test of --in-hbacrules in group-find"
	ipa group-add --desc=groupb $gb
	rlRun "ipa hbacrule-add $hb" 0 "Adding hbac rule for testing with group-find"
	rlRun "ipa hbacrule-add-user --groups=ggg $hb" 0 "adding user $ua to hostgroup $hb"
	rlRun "ipa group-find --in-hbacrules=$hb | grep ggg" 0 "make sure that ggg returns in a search constrained to $hb"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-97: Negative test of --in-hbacrules in group-find"
	rlRun "ipa group-find --in-hbacrules=$hb | grep $gb" 1 "make sure that $gb does not return in a search constrained to $hb"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-98: Positive test of --not-in-hbacrules in group-find"
	rlRun "ipa group-find --not-in-hbacrules=$hb | grep $gb" 0 "make sure that $gb returns in a search excluding hbacrule $hb"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-99: Negative test of --not-in-hbacrules in group-find"
	rlRun "ipa group-find --not-in-hbacrules=$hb | grep ggg" 1 "make sure that ggg does not return in a search excluding hbacrule $hb"
    rlPhaseEnd

    sru=sruleta
    ua=ggg
    ub=tusera
    rlPhaseStartTest "ipa-group-add-100: Positive test of search of groups in a sudorules"
	rlRun "ipa sudorule-add $sru" 0 "Adding sudorule to test with"
	rlRun "ipa sudorule-add-user --groups=$ua $sru" 0 "adding group ua to sudorule sru"
	rlRun "ipa group-find --in-sudorule=$sru | grep $ua" 0 "ensuring that group ua is returned when searching for groups in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-101: Negative test of search of groups in a sudorule"
	rlRun "ipa group-find --in-sudorule=$sru | grep $ub" 1 "ensuring that group ub is notreturned when searching for groups in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-102: Positive test of search of groups not in a sudorule"
	rlRun "ipa group-find --not-in-sudorule=$sru | grep $ub" 0 "ensuring that group ub is returned when searching for groups not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-103: Negative test of search of groups not in a sudorule"
	rlRun "ipa group-find --not-in-sudorule=$sru | grep $ua" 1 "ensuring that group ua is notreturned when searching for groups not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-104: Positive test of search of groups not in a sudorule"
	rlRun "ipa sudorule-remove-user --groups=$ua $sru" 0 "removing group ua from sudorule sru"
	rlRun "ipa group-find --not-in-sudorule=$sru | grep $ua" 0 "ensuring that group ub is returned when searching for groups not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-105: Negative test of search of groups not in a sudorule after user is removed from group"
	rlRun "ipa group-find --in-sudorule=$sru | grep $ua" 1 "ensuring that group ua is notreturned when searching for groups not in a given sudorule"
    rlPhaseEnd

    ua=trex
    gb=$ub
    ub=mdolphin
    ga=ggg
    rlPhaseStartTest "ipa-group-add-106: Positive search of group when filtering by user in group."
	rlRun "ipa group-add-member --users=$ua $ga" 0 "adding user ua to group ga"
	rlRun "ipa group-find --users=$ua | grep $ga" 0 "Positive search of group when filtering by user in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-107: Negative search of group when filtering by user in group."
	rlRun "ipa group-find --users=$ub | grep $ga" 1 "Negative search of group when filtering by user in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-108: Positive search of group when filtering by user not in group."
	rlRun "ipa group-find --no-users=$ua | grep $gb" 0 "Positive search of group when filtering by user not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-109: Negative search of group when filtering by user not in group."
	rlRun "ipa group-find --no-users=$ua | grep 'Group name: $ga'" 1 "Negative search of group when filtering by user not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-110: Positive search of group when filtering by user in group for removed user."
	rlRun "ipa group-remove-member --users=$ua $ga" 0 "removing user ua from group ga"
	rlRun "ipa group-find --no-users=$ua | grep $ga" 0 "Positive search of group when filtering by user not in group for removed user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-111: Negative search of group when filtering by user in group for removed user."
	rlRun "ipa group-find --users=$ua | grep 'Group name: $ga'" 1 "Negative search of group when filtering by user in group for removed user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-112: positive search of group when filtering by user not in group for removed user."
	rlRun "ipa group-find --no-users=$ub | grep $ga" 0 "Positive search of group when filtering by user not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-113: Positive search of group when filtering by group in group."
	rlRun "ipa group-add-member --groups=$gb $ga" 0 "adding group gb to group ga"
	rlRun "ipa group-find --groups=$gb | grep 'Group name: $ga'" 0 "Positive search of group when filtering by groups in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-114: Negative search of group when filtering by group in group."
	rlRun "ipa group-find --groups=$ga | grep 'Group name: $gb'" 1 "Negative search of group when filtering by groups in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-115: Positive search of group when filtering by group not in group."
	rlRun "ipa group-find --no-groups=$ga | grep 'Group name: $gb'" 0 "Positive search of group when filtering by groups not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-116: Negative search of group when filtering by groups not in group."
	rlRun "ipa group-find --no-groups=$gb | grep 'Group name: $ga'" 1 "Negative search of group when filtering by groups not in group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-117: Positive search of group when filtering by groups in group for removed group."
	rlRun "ipa group-remove-member --groups=$gb $ga" 0 "removing group gb from group ga"
	rlRun "ipa group-find --no-groups=$gb | grep 'Group name: $ga'" 0 "Positive search of group when filtering by group not in group for removed group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-118: Negative search of group when filtering by groups in group for removed group."
	rlRun "ipa group-find --groups=$gb | grep 'Group name: $ga'" 1 "Negative search of group when filtering by groups in group for removed group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-add-119: positive search of group when filtering by groups not in group for removed group."
	rlRun "ipa group-find --no-groups=$gb | grep 'Group name: $ga'" 0 "Positive search of group when filtering by groups not in group."
    rlPhaseEnd

    # continuing from test 95  
    rlPhaseStartTest "ipa-group-cli-120: Negative Test of --not-in-groups in group-find after group removal"
	rlRun "ipa group-remove-member --groups=uuu ggg" 0 "remove group uuu from group ggg"
	rlRun "ipa group-find --in-groups=ggg | grep Group\ name: | grep uuu" 1 "Making sure that group ggg does not come back when searching --in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-121: Positive test of --not-in-groups in group-find after group removal"
	rlRun "ipa group-find --not-in-groups=ggg | grep Group\ name: | grep tusera" 0 "Making sure that group tusera comes back when searching --not-in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-122: Negative test of --not-in-groups in group-find after group removal"
	rlRun "ipa group-find --in-groups=ggg | grep Group\ name: | grep tusera" 1 "Making sure that group tusera does not comes back when searching --in-groups=ggg"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-123: check of filtering by group in roles"
	ipa_command_to_test="group"
	role_addstringa="--desc=junk-desc"
	role_addstringb="--desc=junk-desc"
	roleobja="39usera"
	roleobjb="39userb"
	roleobjc="39userc"
	grep_string='Group\ name'
	rlRun "in_roles_return_check" 0 "running checks of --in-roles and --not-in-roles in group-find"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-group-cli-cleanup: Delete remaining users and group and Destroying admin credentials"
	rlRun "ipa config-mod --searchrecordslimit=100" 0 "setting search records limit back to default"
	rlRun "ipa user-del trex" 0 "Deleting user trex."
	rlRun "ipa user-del mdolphin" 0 "Deleting user mdolphin."
        rlRun "ipa group-del jennygn" 0 "Removing Test Group" 
        rlRun "ipa group-del $grp" 0 "Removing Test Group" 
	rlRun "ipa sudorule-del $sru" 0 "Removing sudorule for cleanup"
	ipa group-del $gb
	ipa group-del ggg
	ipa group-del uuu
	ipa group-del tusera
	ipa hbacrule-del $hb
        i=1
        while [ $i -le 10 ] ; do
                deleteGroup Group$i
                let i=$i+1
        done
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
