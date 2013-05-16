#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   group_mod_rename.sh of /CoreOS/ipa-tests/acceptance/ipa-group-cli
#   Description: IPA group CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  group-mod  --rename           Rename a group.
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
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/lib.user-cli.sh
. /opt/rhqa_ipa/env.sh

########################################################################
renamegroup(){
    rlPhaseStartSetup 
        rlRun "tempDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $tempDir"
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-01: Add user to create a private group and rename the group."
        rlRun "ipa user-add --first superuser --last crazylonglastname supercr1 " 0 "Adding Test User"
        rlRun "verifyGroupClasses \"supercr1\" upg" 0 "Verifying user private group."
        rlLog "Executing: ipa group-mod --rename=new_group1 supercr1" 0 "Renaming upg supercr1 to new_group1"
        command="ipa group-mod --rename=new_group1 supercr1" 
        expmsg="ipa: ERROR: Server is unwilling to perform: Renaming a managed entry is not allowed. It needs to be manually unlinked first."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for renaming a user private group."
        rlRun "verifyGroupClasses \"supercr1\" upg" 0 "Verifying user's private group is not renamed."
    rlPhaseEnd

        rlPhaseStartTest "ipa-group-cli-rename-02: Rename group after detaching from the UPG"
        rlRun "detachUPG supercr1" 0 "Detach user's private group."
        rlRun "verifyGroupClasses supercr1 posix" 0 "Verify group is regular group now."
        rlLog "Executing: ipa group-mod --rename=new_group1 supercr1" 
        rlRun "ipa group-mod --rename=new_group1 supercr1" 0 "Renaming upg supercr1 to new_group1"
        rlRun "findGroup new_group1" 0 " Renamed group should now be returned by group-find command."
        rlRun "verifyGroupClasses new_group1 posix" 0 "Verify group is renamed now."
        rlRun "deleteGroup new_group1" 0 "Cleanup - Deleting renamed detached user private group."
        rlRun "ipa user-del supercr1" 0 "Cleanup - Delete the test user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-03: Rename a IPA Posix Group"
        rlRun "addGroup \"My Posix Group\" myposixgroup" 0 "Adding IPA posix group"
        rlRun "verifyGroupClasses myposixgroup posix" 0 "Verify group has posixgroup objectclass."
        rlLog "Executing: ipa group-mod --rename=ren_posixgroup1 myposixgroup" 
        rlRun "ipa group-mod --rename=ren_posixgroup1 myposixgroup" 0 "Renaming myposixgroup to ren_posixgroup1"
        rlRun "findGroup ren_posixgroup1" 0 " Renamed group should now be returned by group-find command."
        rlRun "verifyGroupClasses ren_posixgroup1 posix" 0 "Verify group has posixgroup objectclass."
        rlRun "deleteGroup ren_posixgroup1" 0 "Cleanup - Deleting renamed posix group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-04: Rename and modify desc attribute of IPA Posix Group"
        rlRun "addGroup \"My Posix Group\" myposixgroup" 0 "Adding IPA posix group"
        rlLog "Executing: ipa group-mod --rename=ren_posixgroup2 --desc=\"My New Posix Group Description\" myposixgroup"             
        rlRun "ipa group-mod --rename=ren_posixgroup2 --desc=\"My New Posix Group Description\" myposixgroup" 0 "Renaming myposixgroup to ren_posixgroup2 and changing description"
        rlRun "findGroup ren_posixgroup2" 0 " Renamed group should now be returned by group-find command."
        rlRun "verifyGroupClasses ren_posixgroup2 posix" 0 "Verify group has posixgroup objectclass after renaming."
        rlRun "verifyGroupAttr ren_posixgroup2 Description \"My New Posix Group Description\"" 0 "Verifying description was modified for the renamed group."
        rlRun "deleteGroup ren_posixgroup2" 0 "Cleanup - Deleting renamed posix group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-05: Rename an IPA NON Posix Group"
        rlRun "addNonPosixGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
        rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
        rlLog "Executing: ipa group-mod --rename=ren_nonposixgroup1 regular"   
        rlRun "ipa group-mod --rename=ren_nonposixgroup1 regular" 0 "Renaming NON Posix Group regular to ren_nonposixgroup1"
        rlRun "findGroup ren_nonposixgroup1" 0 " Renamed group should now be returned by group-find command."
        rlRun "verifyGroupClasses ren_nonposixgroup1 ipa" 0 "Verify renamed group has ipa group objectclass."
        rlRun "deleteGroup ren_nonposixgroup1" 0 "Cleanup - Deleting renamed IPA Non Posix group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-06: Rename an IPA NON Posix Group and modify description attribute"
        rlRun "addNonPosixGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
        rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
        rlLog "Executing: ipa group-mod --rename=ren_nonposixgroup1 --desc=\"My New IPA Group Description\" regular"
        rlRun "ipa group-mod --rename=ren_nonposixgroup1 --desc=\"My New IPA Group Description\" regular" 0 "Renaming NON Posix Group regular to ren_nonposixgroup1 and modifying desciption attribute"
        rlRun "findGroup ren_nonposixgroup1" 0 " Renamed group should now be returned by group-find command."
        rlRun "verifyGroupClasses ren_nonposixgroup1 ipa" 0 "Verify renamed group has ipa group objectclass."
        rlRun "verifyGroupAttr ren_nonposixgroup1 Description \"My New IPA Group Description\"" 0 "Verifying description was modified for the renamed group."
        rlRun "deleteGroup ren_nonposixgroup1" 0 "Cleanup - Deleting renamed IPA Non Posix group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-07: Rename a NON Posix group and Modify to be Posix"
        rlRun "addNonPosixGroup test testgroup" 0 "Adding a non posix test group"
        rlRun "verifyGroupClasses testgroup ipa" 0 "Verify group has ipa non posix group objectclasses."
        rlLog "Executing: ipa group-mod --rename=ren_nonposixgroup1 --posix testgroup"
        rlRun "ipa group-mod --rename=ren_nonposixgroup1 --posix testgroup " 0 "Renaming NON Posix Group testgroup to ren_nonposixgroup1 and modify to be Posix"
        rlRun "findGroup ren_nonposixgroup1" 0 " Renamed group should now be returned by group-find command."
        rlRun "verifyGroupClasses ren_nonposixgroup1 posix" 0 "Verify group has ipa posix group objectclasses."
        rlRun "deleteGroup ren_nonposixgroup1" 0 "Cleanup - Deleting renamed IPA Non Posix group."
    rlPhaseEnd

   rlPhaseStartTest "ipa-group-cli-rename-08: Negative - Rename a Posix group to a name that already posix"
        rlRun "addNonPosixGroup test testgroup1" 0 "Adding a non posix test group 1"
        rlRun "ipa group-mod --posix testgroup1" 0 "Modify group to be Posix"
        command="ipa group-mod --posix testgroup1"
        rlRun "addNonPosixGroup test testgroup2" 0 "Adding a non posix test group 2"
        command="ipa group-mod --rename=testgroup1 --posix testgroup2"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlRun "deleteGroup testgroup1" 0 "Cleaning up the test group 1"
        rlRun "deleteGroup testgroup2" 0 "Cleaning up the test group 2"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-09: Negative - Rename a Posix group to a name that's non posix"
        rlRun "addNonPosixGroup test testgroup1" 0 "Adding a non posix test group 1"
        command="ipa group-mod --posix testgroup1"
        rlRun "addNonPosixGroup test testgroup2" 0 "Adding a non posix test group 2"
        rlRun "ipa group-mod --posix testgroup2" 0 "Modify group to be Posix"
        command="ipa group-mod --rename=testgroup1 testgroup2"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlRun "deleteGroup testgroup1" 0 "Cleaning up the test group 1"
        rlRun "deleteGroup testgroup2" 0 "Cleaning up the test group 2"
    rlPhaseEnd

     rlPhaseStartTest "ipa-group-cli-rename-10: Negative - Rename a non Posix group to a name that's user private group"
        rlRun "ipa user-add --first superuser --last crazylonglastname supercr1 " 0 "Adding Test User"
        rlRun "verifyGroupClasses \"supercr1\" upg" 0 "Verifying user private group."
        rlRun "addNonPosixGroup test testgroup1" 0 "Adding a non posix test group 1"
        command="ipa group-mod --rename=supercr1 testgroup1"
        rlLog "Executing: ipa group-mod --rename=supercr1 testgroup1"
        command="ipa group-mod --rename=supercr1 testgroup1"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for renaming a user private group."
        rlRun "deleteGroup testgroup1" 0 "Cleaning up the test group 1"
        rlRun "ipa user-del supercr1" 0 "Cleanup - Delete the test user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-11: Negative - Rename a Posix group to a name that's user private group"
        rlRun "ipa user-add --first superuser --last crazylonglastname supercr1 " 0 "Adding Test User"
        rlRun "verifyGroupClasses \"supercr1\" upg" 0 "Verifying user private group."
        rlRun "addNonPosixGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
        rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
        command="ipa group-mod --rename=supercr1 regular"
        rlLog "Executing: ipa group-mod --rename=supercr1 regular"
        command="ipa group-mod --rename=supercr1 regular"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for renaming a user private group."
        rlRun "deleteGroup regular" 0 "Cleaning up the ipa group regular"
        rlRun "ipa user-del supercr1" 0 "Cleanup - Delete the test user."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-12: Negative - Rename a group that doesn't exist"
        command="ipa group-mod --rename=mynewtestgroup doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-13: Negative - Rename a group with the same old name"
        rlRun "addGroup test test" 0 "Setup - Adding a group"
        command="ipa group-mod --rename=test test"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlRun "deleteGroup test" 0 "Cleanup - Deleting the group"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-14: Rename a Parent group when groups are Nested"
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

        # Rename the parent group
        rlLog "Executing: ipa group-mod --rename=disneyworldFlorida disneyworld"
        rlRun "ipa group-mod --rename=waltdisneyworld disneyworld" 0 "Renaming disneyworld to waltdisneyworld"
        rlRun "findGroup waltdisneyworld" 0 " Renamed group should now be returned by group-find command."
        ipa group-find waltdisneyworld > $tempDir/rename_findgroup.out
        groups=`cat $tempDir/rename_findgroup.out | grep "Member groups:"`
        for item in epcot animalkingdom ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a direct member of renamed group waltdisneyworld - group-find" $rc
        done
        groups=`cat $tempDir/rename_findgroup.out | grep "Indirect Member groups:"`
        for item in dinasaurs fish germany japan ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is an indirect member of renamed group waltdisneyworld - group-show" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-15: Rename a Child group when groups are Nested"
        # Rename the child group
        rlLog "Executing: ipa group-mod --rename=animalkingdompark animalkingdom"
        rlRun "ipa group-mod --rename=animalkingdompark animalkingdom" 0 "Renaming animalkingdom to animalkingdompark"
        rlRun "findGroup animalkingdompark" 0 " Renamed group should now be returned by group-find command."
        ipa group-find waltdisneyworld > $tempDir/rename_findgroup.out
        groups=`cat $tempDir/rename_findgroup.out | grep "Member groups:"`
        for item in epcot animalkingdompark ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a direct member of renamed group waltdisneyworld - group-find" $rc
        done
        groups=`cat $tempDir/rename_findgroup.out | grep "Indirect Member groups:"`
        for item in dinasaurs fish germany japan ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is an indirect member of renamed group waltdisneyworld - group-show" $rc
        done
	ipa group-find animalkingdompark > $tempDir/rename_findgroup2.out
        groups=`cat $tempDir/rename_findgroup2.out | grep "Member groups:"`
        for item in fish dinasaurs ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a member of group animalkingdompark - group-find" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-16: Rename a Nested User Member"
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
	rlRun "addGroupMembers users wdisney waltdisneyworld" 0 "Adding user wdisney to group waltdisneyworld."
	rlRun "addGroupMembers users \"euser1,euser2\" epcot" 0 "Adding users euser1 and euser2 to group epcot."
	rlRun "addGroupMembers users \"guser1,guser2\" germany" 0 "Adding users guser1 and guser2 to group germany."
	rlRun "addGroupMembers users \"juser1,juser2\" japan" 0 "Adding users juser1 and juser2 to group japan."
	rlRun "addGroupMembers users \"trainer1,trainer2\" animalkingdompark" 0 "Adding users trainer1 and trainer2 to group animalkingdompark."
	rlRun "addGroupMembers users \"mdolphin,juser1\" fish" 0 "Adding users mdolphin and juser1 to group fish."
	rlRun "addGroupMembers users \"trex,guser1\" dinasaurs" 0 "Adding users trex and guser1 to group dinasaurs."
	#Rename a user
	rlRun "ipa user-mod --rename=weliasdisney wdisney" 0 "Renaming user wdisney to weliasdisney"
        rlRun "verifyUserAttr weliasdisney \"User login\" weliasdisney " 0 "Verify user Login attribute."

	#Verify user membership
        ipa group-find waltdisneyworld > $tempDir/rename_findgroup3.out
        groups=`cat $tempDir/rename_findgroup3.out | grep "Member groups:"`
        for item in epcot animalkingdompark ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a direct member of renamed group waltdisneyworld - group-find" $rc
        done
        users=`cat $tempDir/rename_findgroup3.out | grep "Member users:"`
        for item in weliasdisney ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a directory member of group waltdisneyworld - group-show" $rc
        done	
	users=`cat $tempDir/rename_findgroup3.out | grep "Indirect Member users:"`
        for item in euser1 euser2 guser1 guser2 juser1 juser2 trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is an indirect member of group waltdisneyworld - group-show" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-17: Rename a Nested Indirect Member user"
	#Rename a user
        rlRun "ipa user-mod --rename=newjuser2 juser2" 0 "Renaming user juser2 to newjuser2"
        rlRun "verifyUserAttr newjuser2 \"User login\" newjuser2 " 0 "Verify user Login attribute."
	
	#Verify user membership
        ipa group-find waltdisneyworld > $tempDir/rename_findgroup4.out
        groups=`cat $tempDir/rename_findgroup4.out | grep "Member groups:"`
        for item in epcot animalkingdompark ; do
                echo $groups | grep $item
                rc=$?
                rlAssert0 "Checking if group $item is a direct member of renamed group waltdisneyworld - group-find" $rc
        done
        users=`cat $tempDir/rename_findgroup4.out | grep "Member users:"`
        for item in weliasdisney ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a directory member of group waltdisneyworld - group-show" $rc
        done
        users=`cat $tempDir/rename_findgroup4.out | grep "Indirect Member users:"`
        for item in euser1 euser2 guser1 guser2 juser1 newjuser2 trainer1 trainer2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is an indirect member of group waltdisneyworld - group-show" $rc
        done
	ipa group-show japan > $tempDir/rename_showgroup5.out
        users=`cat $tempDir/rename_showgroup5.out | grep "Member users:"`
        for item in juser1 newjuser2 ; do
                echo $users | grep $item
                rc=$?
                rlAssert0 "Checking if user $item is a member of group japan - group-show" $rc
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-18: Negative - Rename a Group Member that is already a member"
	command="ipa group-mod --rename=germany epcot"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-19: Negative - Rename a Group Member that is already a user member"
        command="ipa group-mod --rename=epcot guser2"
        expmsg="ipa: ERROR: Server is unwilling to perform: Renaming a managed entry is not allowed. It needs to be manually unlinked first."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-20: Negative - Rename a User Member that is already a group member"
	existing_group="epcot"
	command="ipa user-mod --rename=euser1  $existing_group"
        expmsg="ipa: ERROR: $existing_group: user not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-21: Negative - Rename a User Member that is already a user member"
        command="ipa user-mod --rename=euser1  weliasdisney"
        expmsg="ipa: ERROR: This entry already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-22: Rename a User that is a member of two Groups"
	rlRun "ipa user-mod --rename=newjuser1 juser1" 0 "Renaming user that is member of two groups"
        ipa group-find fish > $tempDir/rename_findgroup5.out
        users=`cat $tempDir/rename_findgroup5.out | grep "Member users:"`
        echo $users | grep newjuser1
        rc=$?
	rlAssert0 "Checking if user newjuser1 is a member of group fish - group-show" $rc
 
        ipa group-find japan > $tempDir/rename_findgroup6.out
        users=`cat $tempDir/rename_findgroup6.out | grep "Member users:"`
        echo $users | grep newjuser1
        rc=$?
	rlAssert0 "Checking if user newjuser1 is a member of group japan - group-show" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-23: setattr, rename and addattr on description"
        rlRun "setAttribute group description newdescfish fish" 0 "Setting attribute description value of new."
        rlRun "verifyGroupAttr fish Description newdescfish" 0 "Verifying group description was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa group-mod --rename=newfish --addattr description=newer fish"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "findGroup fish" 0 "Group should not be renamed, old group still exist."
        rlRun "findGroup newfish" 1 "New groupname should not exist."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-24: Rename group with allowed special characters"
        rlRun "addGroup \"Special Group\" specialgroup1" 0 "Adding a group"
        rlLog "Executing: ipa group-mod --rename=my_gr-ou.p$ specialgroup1"
        rlRun "ipa group-mod --rename=my_gr-ou.p$ specialgroup1" 0 "Renaming specialgroup1 to \"my_gr-ou.p$\""
        rlRun "ipa group-find \"my_gr-ou.p$\"" 0 " Renamed group should now be returned by group-find command."
        rlRun "modifyGroup  \"my_gr-ou.p$\" desc  \"my_gr-ou.p$\"" 0 "Modifying group with special characters"
        rlRun "addGroupMembers users mdolphin \"my_gr-ou.p$\"" 0 "Adding member to group with special characters"
        rlRun "removeGroupMembers users mdolphin \"my_gr-ou.p$\"" 0 "Removing member from group with special characters"
        rlRun "deleteGroup \"my_gr-ou.p$\"" 0 "Deleting group with special characters"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-25: Rename group with Not Allowed special characters @"
        rlRun "addGroup \"Special Group\" specialgroup2" 0 "Adding a group"
        command="ipa group-mod --rename=\"test@\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-26: Rename group with Not Allowed special characters %"
        command="ipa group-mod --rename=\"test%\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-27: Rename group with Not Allowed special characters ^"
        command="ipa group-mod --rename=\"test^\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-28: Rename group with Not Allowed special characters *"
        command="ipa group-mod --rename=\"test*\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-29: Rename group with Not Allowed special characters +"
        command="ipa group-mod --rename=\"test+\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-30: Rename group with Not Allowed special characters ~"
        command="ipa group-mod --rename=\"test~\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-31: Rename group with Not Allowed special characters ="
        command="ipa group-mod --rename=\"test=\" specialgroup2"
        expmsg="ipa: ERROR: invalid 'rename': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-rename-32: Delete renamed Groups"
        # lets clean up
        for item in waltdisneyworld animalkingdompark epcot japan germany dinasaurs fish specialgroup2; do
                rlRun "deleteGroup $item" 0 "Deleting group $item"
        done

        for item in weliasdisney trainer1 trainer2 euser1 euser2 newjuser1 newjuser2 guser1 guser2 mdolphin trex ; do
                rlRun "ipa user-del $item" 0 "Deleting user $item"
        done
    rlPhaseEnd

 
    rlPhaseStartCleanup
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rlRun "rm -r $tempDir" 0 "Removing temp directory"
    rlPhaseEnd

}

