USERCONTAINER="ou=People"
GROUPCONTAINER="ou=groups"
USEROBJCLASS="posixAccount"
GROUPOBJCLASS="posixGroup"

######################
# test suite         #
######################
ds-migration-acceptance()
{
    setup
    migrationconfig
#    migratecmd
#    verifymigration
#    cleanup
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
		setMigrationConfig FALSE
	        command="ipa config-mod --enable-migration FALSE"
        	expmsg="ipa: ERROR: no modifications to be performed"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"	
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-config-003 Set migration mode TRUE - already TRUE"
                setMigrationConfig TRUE
                command="ipa config-mod --enable-migration TRUE"
                expmsg="ipa: ERROR: no modifications to be performed"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-config-004 Attempt migration with configuration FALSE"
		setMigrationConfig FALSE
		rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 1 "Check return code"
		echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out
		rlAssertGrep "Migration mode is disabled. Use 'ipa config-mod' to enable it." "/tmp/error.out"
        rlPhaseEnd
}

migratecmd()
{
	setMigrationConfig TRUE

	rlPhaseStartTest"ds-migration-cmd-001 Invalid Directory Server - Unreachable"
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://ldap.example.com:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://ldap.example.com:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" ldap://ldap.example.com:389 > /tmp/error.out
                rlAssertGrep "ipa: ERROR: Can't contact LDAP server:" "/tmp/error.out"
	rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-002 Invalid User Container"
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"ou=bad\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"ou=bad\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="ou=bad" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out
                rlAssertGrep "" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-003 Invalid Group Container"
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"ou=bad\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"ou=bad\" ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="ou=bad" ldap://$CLIENT:389 > /tmp/error.out
                rlAssertGrep "" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-004 Invalid User Object Class"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-objectclass=badclass ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-objectclass=badclass ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --user-objectclass=badclass ldap://$CLIENT:389 > /tmp/error.out
                rlAssertGrep "" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-005 Invalid Group Object Class"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-objectclass=badclass ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-objectclass=badclass ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --group-objectclass=badclass ldap://$CLIENT:389 > /tmp/error.out
                rlAssertGrep "" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-006 Invalid Schema option"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --schema=RFC9999 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --schema=RFC9999 ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --schema=RFC9999 ldap://$CLIENT:389 > /tmp/error.out
                rlAssertGrep "" "/tmp/error.out"
        rlPhaseEnd
}
