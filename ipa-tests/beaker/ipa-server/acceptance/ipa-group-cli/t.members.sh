
########################################################################
# Globals
########################################################################

USERRDN="cn=users,cn=accounts,"
USERDN="$USERRDN$BASEDN"
USERRDN="cn=users,cn=accounts,"
GROUPRDN="$GROUPRDN$BASEDN"
echo "USERDN is $USERDN"
echo "GROUPDN is $GROUPDN"
echo "Server is $MASTER"

########################################################################
# Test Sections
########################################################################

members()
{
	memberships
}

memberships()
{
    rlPhaseStartSetup
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-001: Add Nested Groups Memberships"
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

    rlPhaseStartTest "ipa-group-members-002: Add Nested User Memberships"
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

    rlPhaseStartTest "ipa-group-members-003: Verify Group Memberships - Group: disneyworld"

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

    rlPhaseStartTest "ipa-group-members-004: Verify Group Memberships - Group: epcot"

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

    rlPhaseStartTest "ipa-group-members-005: Verify Group Memberships - Group: animalkingdom"

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

    rlPhaseStartTest "ipa-group-members-006: Verify Group Memberships - Group: dinasaurs"

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

    rlPhaseStartTest "ipa-group-members-007: Verify Group Memberships - Group: fish"

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

    rlPhaseStartTest "ipa-group-members-009: Verify Group Memberships - Group: germany"

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

    rlPhaseStartTest "ipa-group-members-010: Verify Group Memberships - Group: japan"

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

    rlPhaseStartTest "ipa-group-members-011: Negative - Add Group Member that is already a member"
        result=`ipa group-add-member --groups=germany epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-012: Negative - Add User Member that is already a member"
        result=`ipa group-add-member --users=euser1 epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-013: Negative - Add Group Member that doesn't exist"
        result=`ipa group-add-member --groups=doesntexist epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-014: Negative - Add User Member that doesn't exist"
        result=`ipa group-add-member --users=doesntexist epcot`
        echo $result | grep "Number of members added 0"
        rc=$?
        rlAssert0 "0 Members should be added" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-015: Negative - Remove Group Member that doesn't exist"
        result=`ipa group-remove-member --users=doesntexist epcot`
        echo $result | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "0 Members should be removed" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-016: Negative - Remove User Member that doesn't exist"
        result=`ipa group-remove-member --users=doesntexist epcot`
        echo $result | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "0 Members should be removed" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-017: Removed Single User Member"
	rlRun "removeGroupMembers users mdolphin fish" 0 "Removing user mdolphin from group fish."
        ipa group-find fish > /tmp/findgroup.out
        users=`cat /tmp/findgroup.out | grep "Member users:"`
        echo $users | grep mdolpin
	rc=$?
	rlAssertNotEquals "Checking that user is no longer a member of direct group fish" $rc 0

	rlRun "verifyGroupMember mdolphin user fish" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-018: Removed Single Group Member"
	rlRun "removeGroupMembers groups fish animalkingdom" 0 "Removing user mdolphin from group fish."
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep fish
        rc=$?
        rlAssertNotEquals "Checking that group is no longer a member of direct group animalkingdom" $rc 0

	rlRun "verifyGroupMember fish group animalkingdom" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-members-019: Removed Multiple Group Members"
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

    rlPhaseStartTest "ipa-group-members-020: Removed Multiple User Members"
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

    rlPhaseStartTest "ipa-group-members-021: Delete User that is a member of two Groups"
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

    rlPhaseStartTest "ipa-group-members-022: Delete group with two members"
	rlRun "deleteGroup dinasaurs" 0 "Deleting lower level nested group"
        ipa group-find animalkingdom > /tmp/findgroup.out
        groups=`cat /tmp/findgroup.out | grep "Member groups:"`
        echo $groups | grep dinasaurs
        rc=$?
        rlAssertNotEquals "Checking that group dinasaur is no longer a member of direct group animalkingdom" $rc 0

	rlRun "verifyGroupMember trex user dinasaurs" 3 "member and memberOf attributes removed verification"
	rlRun "verifyGroupMember guser1 group dinasaurs" 3 "member and memberOf attributes removed verification"
    rlPhaseEnd

    rlPhaseStartCleanup 
	# lets clean up
	for item in disneyworld animalkingdom epcot japan germany fish ; do
		rlRun "deleteGroup $item" 0 "Deleting group $item"
	done

	for item in wdisney trainer1 trainer2 euser1 euser2 juser2 guser1 guser2 trex mdolphin ; do
		rlRun "ipa user-del $item" 0 "Deleting user $item"
	done

	rlRun "kdestroy" 0 "Destroy Admin Credentials."
    rlPhaseEnd
}
