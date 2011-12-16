USERCONTAINER="ou=People"
GROUPCONTAINER="ou=groups"
USEROBJCLASS="posixAccount"
GROUPOBJCLASS="posixGroup"
BASEDN="dc=example,dc=com"
USER1=puser1
USER2=puser2
GROUP1=group1
GROUP2=group2

######################
# test suite         #
######################
ds-migration-acceptance()
{
    setup
    migrationconfig
    migratecmd
    cleanup
}

######################
# SETUP              #
######################

setup()
{
        rlPhaseStartTest "SETUP: Kinit As Administrator"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
        rlPhaseEnd
}

migrationconfig()
{
	# NOTE: Invalid values passed to the enable migration switch is covered in the ipa-config tests
	rlPhaseStartTest "ds-migration-config-001 Verify default configuration mode is FALSE"
		rlRun "VerifyMigrationConfig FALSE" 0 	
	rlPhaseEnd

        rlPhaseStartTest "ds-migration-config-002 Set migration mode FALSE - already FALSE"
		SetMigrationConfig FALSE
	        command="ipa config-mod --enable-migration FALSE"
        	expmsg="ipa: ERROR: no modifications to be performed"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"	
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-config-003 Set migration mode TRUE - already TRUE"
                SetMigrationConfig TRUE
                command="ipa config-mod --enable-migration TRUE"
                expmsg="ipa: ERROR: no modifications to be performed"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-config-004 Attempt migration with configuration FALSE"
		SetMigrationConfig FALSE
		rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 1 "Check return code"
		echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out 2>&1
		rlAssertGrep "Migration mode is disabled. Use 'ipa config-mod' to enable it." "/tmp/error.out"
        rlPhaseEnd
}

migratecmd()
{
	rlPhaseStartTest "ds-migration-cmd-001 Invalid Directory Server - Unreachable"
		SetMigrationConfig TRUE
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://ldap.example.com:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://ldap.example.com:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" ldap://ldap.example.com:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Can't contact LDAP server:" "/tmp/error.out"
	rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-002 Invalid User Container"
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"ou=bad\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"ou=bad\" ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="ou=bad" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Container for user not found" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-003 Invalid Group Container"
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"ou=bad\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --group-container=\"ou=bad\" ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="ou=bad" ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Container for group not found" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-004 Invalid User Object Class"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-objectclass=badclass ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-objectclass=badclass ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --user-objectclass=badclass ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Objectclass for user not found" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-005 Invalid Group Object Class"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-objectclass=badclass ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-objectclass=badclass ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --group-objectclass=badclass ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Objectclass for group not found" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-006 Invalid Schema option"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --schema=RFC9999 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --schema=RFC9999 ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --schema=RFC9999 ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: invalid 'schema': must be one of (u'RFC2307bis', u'RFC2307')" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-007 Invalid bind password"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo badPWd882 | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 1 "Check return code"
                echo badpWd882 | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Insufficient access:  Invalid credentials" "/tmp/error.out"
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-008 Non directory manager bind-dn - binding as $USER1"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --bind-dn=\"uid=$USER1,$USERCONTAINER,$BASEDN\" ldap://$CLIENT:389"
                rlRun "echo fo0m4nchU | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --bind-dn=\"uid=$USER1,$USERCONTAINER,$BASEDN\" ldap://$CLIENT:389" 0

		rlRun "ipa user-find $USER1" 0 "Verifying $USER1 was migrated"
		rlRun "ipa user-find $USER2" 0 "Verifying user '$USER2' was migrated"
		rlRun "ipa group-find $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
		rlRun "ipa group-find $GROUP2" 0 "Verifying group '$GROUP2' was migrated"
	rlPhaseEnd
}

cleanup()
{
	rlPhaseStartTest "CLEANUP: Set config to false and delete migrated objects"
		SetMigrationConfig FALSE
		ipa user-del $USER1
		ipa user-del $USER2
		ipa group-del $GROUP1
		ipa group-del $GROUP2
	rlPhaseEnd
}
