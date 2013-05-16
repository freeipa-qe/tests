########################################################################
# Test Sections
########################################################################
addmodify()
{
   addsetup
   private
   posix
   negative
   pkey
   addcleanup
}

addsetup()
{
    rlPhaseStartSetup 
        rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd
}

private()
{
    rlPhaseStartTest "ipa-group-private-001: Add user and check for Private Group Creation"
        rlRun "ipa user-add --first Jenny --last Galipeau jennyg" 0 "Adding Test User"
        rlRun "verifyGroupClasses \"jennyg\" upg" 0 "Verifying user's private group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-002: Attempted to delete managed private group"
        command="ipa group-del jennyg"
        expmsg="ipa: ERROR: Deleting a managed group is not allowed. It must be detached first."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-003: Verify private with group-find command"
        result=`ipa group-find jennyg`
	echo $result | grep "0 groups matched"
	rc=$?
	rlAssert0 "0 Groups should be matched" $rc

	result=`ipa group-find --private jennyg`
	echo $result | grep "1 group matched"
	rc=$?
	rlAssert0 "1 Group should be matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-004: Verify private group is returned with group-show command"
	rlRun "verifyGroupAttr jennyg Description \"User private group for jennyg\"" 0 "Verify UPG description."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-005: Verify User Private Group"
	rlRun "verifyUPG jennyg" 0 "UPG verification"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-006: Delete user and check for Private Group Removal"
	rlRun "ipa user-del jennyg" 0 "Deleting Test User"
	rlRun "verifyGroupClasses jennyg upg" 2 "Verify user's private group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-007: Detach UPG"
        rlRun "ipa user-add --first Jenny --last Galipeau jennyg" 0 "Adding Test User"
        rlRun "detachUPG jennyg" 0 "Detach user's private group."
	rlRun "verifyGroupClasses jennyg posix" 0 "Verify group is regular group now."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-008: Verify group find returns detached group" 
 	rlRun "findGroup jennyg" 0 "Group should now be returned by group-find command."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-private-009: Delete Detached UPG"
	rlRun "deleteGroup jennyg" 0 "Deleting detached user private group."
	rlRun "ipa user-del jennyg" 0 "Cleanup - Delete the test user."
    rlPhaseEnd
}

posix()
{
    rlPhaseStartTest "ipa-group-posix-001: Add IPA Posix Group"
	rlRun "addGroup \"My Posix Group\" myposixgroup" 0 "Adding IPA posix group"
	rlRun "verifyGroupClasses myposixgroup posix" 0 "Verify group has posixgroup objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-002: Modify IPA Posix Group"
	rlRun "modifyGroup myposixgroup desc \"My New Posix Group Description\"" 0 "Modifying IPA posix group description"
	rlRun "verifyGroupAttr myposixgroup Description \"My New Posix Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-003: Delete IPA posix Group"
        rlRun "deleteGroup myposixgroup" 0 "Deleting posix group"
        rlRun "findGroup myposixgroup" 1 "Verify IPA posix group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-004: Add IPA NON Posix Group"
	rlRun "addNonPosixGroup \"My IPA Group\" regular" 0 "Adding regular IPA Group"
	rlRun "verifyGroupClasses regular ipa" 0 "Verify group has ipa group objectclass."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-005: Modify IPA NON Posix Group"
        rlRun "modifyGroup regular desc \"My New IPA Group Description\"" 0 "Modifying ipa group description"
        rlRun "verifyGroupAttr regular Description \"My New IPA Group Description\"" 0 "Verifying description was modified."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-006: Delete IPA NON Posix Group"
        rlRun "deleteGroup regular" 0 "Deleting non posix group"
        rlRun "findGroup regular" 1 "Verify non posix group was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-007: Add Group - NON Posix - Modify to be Posix"
	rlRun "addNonPosixGroup test testgroup" 0 "Adding a non posix test group"
	rlRun "verifyGroupClasses testgroup ipa" 0 "Verify group has ipa non posix group objectclasses."
        rlRun "ipa group-mod --posix testgroup" 0 "Making NON posix group a posix group"
        rlRun "verifyGroupClasses testgroup posix" 0 "Verify group has ipa non posix group objectclasses."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-posix-008: Negative - modify Posix to group that is already posix"
        command="ipa group-mod --posix testgroup"
        expmsg="ipa: ERROR: This is already a posix group"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlRun "deleteGroup testgroup" 0 "Cleaning up the test group"
    rlPhaseEnd
}

negative()
{
    rlPhaseStartTest "ipa-group-negative-001: Delete group that doesn't exist"
        command="ipa group-del doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-002: Modify group that doesn't exist"
        command="ipa group-mod --desc=description doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-003: Find group that doesn't exist"
        result=`ipa group-find doesntexist`
        echo $result | grep "0 groups matched"
        rc=$?
        rlAssert0 "0 Groups should be matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-004: Show group that doesn't exist"
        command="ipa group-show doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-005: Detach group that doesn't exist"
        command="ipa group-detach doesntexist"
        expmsg="ipa: ERROR: doesntexist: group not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-006: Not Allowed special characters @"
        command="ipa group-add --desc=\"test@\" \"test@\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-007: Not Allowed special characters %"
        command="ipa group-add --desc=\"test%\" \"test%\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-008: Not Allowed special characters ^"
        command="ipa group-add --desc=\"test^\" \"test^\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-009: Not Allowed special characters *"
        command="ipa group-add --desc=\"test*\" \"test*\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg '$command' \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-010: Not Allowed special characters +"
        command="ipa group-add --desc=\"test+\" \"test+\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-gegative-011: Not Allowed special characters ~"
        command="ipa group-add --desc=\"test~\" \"test~\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-012: Not Allowed special characters ="
        command="ipa group-add --desc=\"test=\" \"test=\""
        expmsg="ipa: ERROR: invalid 'group_name': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-013: Add self as group member"
	ipa group-add --desc=fish fish
        ipa group-add-member --groups=fish fish > /tmp/error.out
        cat /tmp/error.out | grep "Number of members added 0"
        rc=$?
        rlAssert0 "Number of members added 0" $rc
	rlRun "deleteGroup fish" 0 "Cleanup: Deleting group fish."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-negative-014: Add Duplicate Group"
        rlRun "addGroup test test" 0 "Setup - Adding a group"
        command="ipa group-add --desc=test test"
        expmsg="ipa: ERROR: group with name test already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlRun "deleteGroup test" 0 "Cleanup - Deleting the group"
    rlPhaseEnd

}

pkey()
{
    rlPhaseStartTest "ipa-group-pkey-001: check of --pkey-only"
	ipa_command_to_test="group"
	pkey_addstringa="--desc=junk-desc"
	pkey_addstringb="--desc=junk-desc"
	pkeyobja="39user"
	pkeyobjb="39userb"
	grep_string='Group\ name'
	general_search_string=$pkeyobja
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in group-find"
    rlPhaseEnd
}

addcleanup()
{
    rlPhaseStartCleanup
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd
}
