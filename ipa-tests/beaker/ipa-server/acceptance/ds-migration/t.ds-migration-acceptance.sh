USERCONTAINER="ou=People"
GROUPCONTAINER="ou=groups"
USEROBJCLASS="posixAccount"
GROUPOBJCLASS="posixGroup"
BASEDN="dc=example,dc=com"
USER1=puser1
USER1PWD="fo0m4nchU"
USER2PWD="Secret123"
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
    cleartxtpwdmigration
    cleanup
}

######################
# SETUP              #
######################

setup()
{
        rlPhaseStartTest "SETUP MIGRATION ACCEPTANCE"
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

		rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
		rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
		rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
		rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

		#cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
	rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-009 Exclude User"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
                rlRun "ipa user-show $USER2" 2 "Verifying user '$USER2' was NOT migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-010 Exclude Group"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups=$GROUP2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups=$GROUP2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-011 Exclude Mulitple Users"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER1,$USER2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER1,$USER2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 2 "Verifying $USER1 was NOT migrated"
                rlRun "ipa user-show $USER2" 2 "Verifying user '$USER2' was NOT migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-012 Exclude Mulitple Groups"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups=$GROUP1,$GROUP2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups=$GROUP1,$GROUP2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
                rlRun "ipa group-show $GROUP1" 2 "Verifying group '$GROUP1' was NOT migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-013 Exclude Users and Groups"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER1,$USER2 --exclude-groups=$GROUP1,$GROUP2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER1,$USER2 --exclude-groups=$GROUP1,$GROUP2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 2 "Verifying $USER1 was NOT migrated"
                rlRun "ipa user-show $USER2" 2 "Verifying user '$USER2' was NOT migrated"
                rlRun "ipa group-show $GROUP1" 2 "Verifying group '$GROUP1' was NOT migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd
}

cleartxtpwdmigration()
{
	rlPhaseStartTest "ds-migration-cleartxt-pwd-001 Clear Text Password Migration"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 0

                rlRun "ssh_auth_success $USER1 $USER1PWD $HOSTNAME"
		rlRun "ssh_auth_success $USER2 $USER2PWD $HOSTNAME"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cleartxt-pwd-002 Cleanup migration"
                SetMigrationConfig FALSE
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2

		rlRun "ipa user-show $USER1" 2 "Make sure $USER1 was deleted"
		rlRun "ipa user-show $USER2" 2 "Make sure $USER2 was deleted"
		rlRun "ipa group-show $GROUP1" 2 "Make sure $GROUP1 was deleted"
		rlRun "ipa group-show $GROUP1" 2 "Make sure $GROUP1 was deleted"
        rlPhaseEnd
}

cleanup()
{
        rlPhaseStartTest "CLEANUP MIGRATION ACCEPTANCE"
		SetMigrationConfig FALSE
		rlRun "ssh root@$CLIENT /usr/sbin/remove-ds.pl -i $INSTANCE" 0 "Removing directory server instance"
        rlPhaseEnd
}

