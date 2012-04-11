#####################
#  GLOBALS	    #
#####################
NETMGD="NGP Definition"
USRMGD="UPG Definition"

######################
# test suite         #
######################
ipa-managedentrycli()
{
    listmanagedentries
    userprivategroups
    managednetgroups
    negative
} 

listmanagedentries()
{
   rlPhaseStartTest "List Managed Entries - Supply Password"
	kdestroy
	rlRun "ipa-managed-entries --list -p $ADMINPW" 0
   rlPhaseEnd 

   rlPhaseStartTest "List Managed Entries - Prompt for Password"
	rlRun "echo $ADMINPW | ipa-managed-entries -l" 0
   rlPhaseEnd

   rlPhaseStartTest "Verify List Includes Default Managed Entries"
	ipa-managed-entries --list -p $ADMINPW > /tmp/mgdentries.out
	rlAssertGrep "$NETMGD" "/tmp/mgdentries.out"
	rlAssertGrep "$USRMGD" "/tmp/mgdentries.out"
   rlPhaseEnd

   rlPhaseStartTest "List with invalid DM password"
	rlRun "ipa-managed-entries --list -p badpassword > /tmp/badpwd.out 2>&1" 1
	rlAssertGrep "Invalid credentials" "/tmp/badpwd.out"
   rlPhaseEnd

   rlPhaseStartTest "List with admin kerberos credentials"
	KinitAsAdmin
	rlRun "ipa-managed-entries --list" 0
   rlPhaseEnd
}

userprivategroups()
{
   rlPhaseStartTest "Get Default Status of User Private Groups Plugin"
	rlRun "ipa-managed-entries -e \"$USRMGD\" status > /tmp/upgstatus.out 2>&1" 0 
	rlAssertGrep "Plugin Enabled" "/tmp/upgstatus.out"
   rlPhaseEnd

   rlPhaseStartTest "Disable User Private Groups Plugin"
	rlRun "ipa-managed-entries -e \"$USRMGD\" disable" 0 "Disable UPG Plugin"
	rlRun "service dirsrv restart" 0 "Required directory server restart"
	rlRun "ipa-managed-entries -e \"$USRMGD\" status > /tmp/upgstatus.out 2>&1" 0 "Get the status of the plugin"
	rlAssertGrep "Plugin Disabled" "/tmp/upgstatus.out"
   rlPhaseEnd

   rlPhaseStartTest "Add user with User Private Group Plugin Disabled - Default Group Non-Posix"
        command="ipa user-add --first=disabled --last=disabled disabled"
        expmsg="ipa: ERROR: Default group for new users is not POSIX"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
   rlPhaseEnd

   rlPhaseStartTest "Add user with User Private Group Plugin Disabled - Default Group Posix"
	rlRun "ipa group-add --desc=posix posix" 0 "Add a new posix group"
	rlRun "ipa config-mod --defaultgroup=posix" 0 "Change default group to the posix group"
	rlRun "ipa user-add --first=disabled --last=disabled disabled" 0 "Add posix user"

	# cleanup
	rlRun "ipa config-mod --defaultgroup=ipausers" 0 "Change default group back to default 'ipausers'"
	rlRun "ipa user-del disabled" 0 "Delete the posix user added"
	rlRun "ipa group-del posix" 0 "Delete the posix group added"
   rlPhaseEnd

   rlPhaseStartTest "Re-Enable User Private Groups Plugin"
        rlRun "ipa-managed-entries -e \"$USRMGD\" enable" 0 "Re-enable UPG Plugin"
	rlRun "service dirsrv restart" 0 "Required directory server restart"
        rlRun "ipa-managed-entries -e \"$USRMGD\" status > /tmp/upgstatus.out 2>&1" 0 "Get the status of the plugin"
        rlAssertGrep "Plugin Enabled" "/tmp/upgstatus.out"
   rlPhaseEnd

   rlPhaseStartTest "Add user with User Private Groups Plugin Re-Enabled"
	rlRun "ipa user-add --first=enabled --last=enabled enabled" 0 "Add user with plugin re-enabled"
        rlRun "ipa group-find --private enabled" 0 "Make sure user private group was added"
        rlRun "ipa user-del enabled" 0 "Delete the test user added"
	rlRun "ipa group-find --private enabled" 1 "Make sure user private group was delete too"
   rlPhaseEnd
} 

managednetgroups()
{
   rlPhaseStartTest "Get Default Status of Netgroups Plugin"
        rlRun "ipa-managed-entries -e \"$NETMGD\" status > /tmp/upgstatus.out 2>&1" 0
        rlAssertGrep "Plugin Enabled" "/tmp/upgstatus.out"
   rlPhaseEnd

   rlPhaseStartTest "Disable Netgroups Plugin"
        rlRun "ipa-managed-entries -e \"$NETMGD\" disable" 0 "Disable NGP Plugin"
        rlRun "service dirsrv restart" 0 "Required directory server restart"
        rlRun "ipa-managed-entries -e \"$NETMGD\" status > /tmp/upgstatus.out 2>&1" 0 "Get the status of the plugin"
        rlAssertGrep "Plugin Disabled" "/tmp/upgstatus.out"
   rlPhaseEnd

   rlPhaseStartTest "Add hostgroup Netgroup Plugin Disabled"
        rlRun "ipa hostgroup-add --desc=disabled disabled" 0 "Add hostgroup with plugin disabled"
        rlRun "ipa netgroup-find disabled" 1 "Make sure managed netgroup was not added"
        rlRun "ipa hostgroup-del disabled" 0 "Delete the test hostgroup added"
   rlPhaseEnd

   rlPhaseStartTest "Re-Enable Netgroups Plugin"
        rlRun "ipa-managed-entries -e \"$NETMGD\" enable" 0 "Re-enable UPG Plugin"
        rlRun "service dirsrv restart" 0 "Required directory server restart"
        rlRun "ipa-managed-entries -e \"$NETMGD\" status > /tmp/upgstatus.out 2>&1" 0 "Get the status of the plugin"
        rlAssertGrep "Plugin Enabled" "/tmp/upgstatus.out"
   rlPhaseEnd

   rlPhaseStartTest "Add hostgroup with netgroups Plugin Re-Enabled"
        rlRun "ipa hostgroup-add --desc=enabled enabled" 0 "Add hostgroup with plugin re-enabled"
        rlRun "ipa netgroup-find --managed enabled" 0 "Make sure managed netgroup was added"
        rlRun "ipa hostgroup-del enabled" 0 "Delete the test hostgroup added"
        rlRun "ipa netgroup-find --managed enabled" 1 "Make sure the managed netgroup was delete too"
   rlPhaseEnd

} 

negative()
{
  rlPhaseStartTest "Bad Managed Entry Definition - negative"
	rlRun "ipa-managed-entries -e \"BOGUS Definition\" status > /tmp/error.out 2>&1" 1 
	rlAssertGrep "not a valid Managed Entry" "/tmp/error.out"
  rlPhaseEnd

  rlPhaseStartTest "Invalid action - negative"
	rlRun "ipa-managed-entries -e \"UPG Definition\" stop > /tmp/error.out 2>&1" 1
	rlAssertGrep "Unrecognized action \[stop\]" "/tmp/error.out"
  rlPhaseEnd
}
