USERCONTAINER="ou=People"
GROUPCONTAINER="ou=groups"
USEROBJCLASS="posixAccount"
GROUPOBJCLASS="posixGroup"
MYBASEDN="dc=example,dc=com"
USER1=puser1
USER1PWD="fo0m4nchU"
USER2PWD="Secret123"
USER2=puser2
USER3="philomena_hazen"
GROUP1=group1
GROUP2=group2
GROUP3=group3

######################
# test suite         #
######################
ds-migration-acceptance()
{
    setup
    migrationconfig
    migratecmd
    bugzillas
    #cleartxtpwdmigration
    cleanup
}

######################
# SETUP              #
######################

setup()
{
        rlPhaseStartTest "SETUP MIGRATION ACCEPTANCE"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		# turn off compat plugin and restart directory server
		rlLog "EXECUTING: echo $ADMINPW | ipa-compat-manage disable"
		rlRun "echo $ADMINPW | ipa-compat-manage disable" 0
		rlDistroDiff dirsrv_svc_restart

		# For ldaps tests dependent on openldap and trust directory server CA certificate
		rlLog "EXECUTING: restorecon /etc/ipa/remoteds.crt"
		restorecon /etc/ipa/remoteds.crt
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
                rlAssertGrep "ipa: ERROR: cannot connect to 'ldap://ldap.example.com:389':" "/tmp/error.out"
		#rlAssertGrep "ipa: ERROR: cannot connect to u'ldap://ldap.example.com:389': LDAP Server Down" "/tmp/error.out"
	rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-002 Invalid User Container"
                rlDistroDiff dirsrv_svc_restart
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"ou=bad\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"ou=bad\" ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="ou=bad" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out 2>&1
		rlAssertGrep "ipa: ERROR: user LDAP search did not return any result (search base: ou=bad,dc=example,dc=com, objectclass: person)" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-003 Invalid Group Container"
		rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"ou=bad\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --group-container=\"ou=bad\" ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="ou=bad" ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: group LDAP search did not return any result (search base: ou=bad,dc=example,dc=com, objectclass: groupofuniquenames, groupofnames)" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-004 Invalid User Object Class"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-objectclass=badclass ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-objectclass=badclass ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --user-objectclass=badclass ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: user LDAP search did not return any result (search base: ou=People,dc=example,dc=com, objectclass: badclass)" "/tmp/error.out"
		rlLog "Related Bugzilla :: https://bugzilla.redhat.com/show_bug.cgi?id=768510"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-005 Invalid Group Object Class"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-objectclass=badclass ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-objectclass=badclass ldap://$CLIENT:389" 2 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --group-objectclass=badclass ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: group LDAP search did not return any result (search base: ou=groups,dc=example,dc=com, objectclass: badclass)" "/tmp/error.out"
		rlLog "Related Bugzilla :: https://bugzilla.redhat.com/show_bug.cgi?id=768510"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-006 Invalid Schema option"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --schema=RFC9999 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --schema=RFC9999 ldap://$CLIENT:389" 1 "Check return code"
                echo $ADMINPW | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" --schema=RFC9999 ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: invalid 'schema': must be one of 'RFC2307bis', 'RFC2307'" "/tmp/error.out"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-007 Invalid bind password"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo badPWd882 | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 1 "Check return code"
                echo badpWd882 | ipa migrate-ds --user-container="$USERCONTAINER" --group-container="$GROUPCONTAINER" ldap://$CLIENT:389 > /tmp/error.out 2>&1
                rlAssertGrep "ipa: ERROR: Insufficient access:  Invalid credentials" "/tmp/error.out"
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-008 Non directory manager bind-dn - binding as $USER1"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --bind-dn=\"uid=$USER1,$USERCONTAINER,$MYBASEDN\" ldap://$CLIENT:389"
                rlRun "echo fo0m4nchU | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --bind-dn=\"uid=$USER1,$USERCONTAINER,$MYBASEDN\" ldap://$CLIENT:389" 0

		rlRun "ipa user-show $USER1" 0 "Verifying '$USER1' was migrated"
		rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
		rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
		rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

		#cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
	rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-009 Exclude User"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"ou=people,\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users=$USER2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying '$USER1' was migrated"
                rlRun "ipa user-show $USER2" 2 "Verifying user '$USER2' was NOT migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-010 Exclude Group"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups=$GROUP2 ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups=$GROUP2 ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying '$USER1' was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-011 Exclude Mulitple Users"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users={$USER1,$USER2} ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users={$USER1,$USER2} ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 2 "Verifying '$USER1' was NOT migrated"
                rlRun "ipa user-show $USER2" 2 "Verifying user '$USER2' was NOT migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-012 Exclude Mulitple Groups"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups={$GROUP1,$GROUP2} ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-groups={$GROUP1,$GROUP2} ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying '$USER1' was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 2 "Verifying group '$GROUP1' was NOT migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-013 Exclude Users and Groups"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users={$USER1,$USER2} --exclude-groups={$GROUP1,$GROUP2} ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --exclude-users={$USER1,$USER2} --exclude-groups={$GROUP1,$GROUP2} ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 2 "Verifying '$USER1' was NOT migrated"
                rlRun "ipa user-show $USER2" 2 "Verifying user '$USER2' was NOT migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 2 "Verifying group '$GROUP1' was NOT migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-014 Ignore User Objectclass"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-ignore-objectclass=inetorgperson ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --user-ignore-objectclass=inetorgperson ldap://$CLIENT:389" 0

                rlRun "ipa user-show $USER1" 0 "Verifying '$USER1' was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"
		rlRun "ipa user-show $USER3" 2 "Verify '$USER3' inetorperson user was NOT migrated"

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-015 Ignore Group Objectclass"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-ignore-objectclass=posixGroup ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-ignore-objectclass=posixGroup ldap://$CLIENT:389" 0
        
                rlRun "ipa user-show $USER1" 0 "Verifying '$USER1' was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying user '$USER2' was migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 2 "Verifying group '$GROUP1' was NOT migrated"
                rlRun "ipa group-show $GROUP2" 2 "Verifying group '$GROUP2' was NOT migrated"
                
                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-016 Existing User is skipped"
		# adding a bit of a wait in case the managed entry plugin is not done getting rid of the UPG
		sleep 10
		rlRun "ipa user-add --first=posix --last=user $USER1" 0 "Add user that will be migrated"
		# get the ipa user id
		preipauserid=`ipa user-show $USER1 | grep UID | cut -d ":" -f 2`
		#trim whitespace
		preipauserid=`echo $preipauserid`
		rlLog "IPA User ID for $USER1: $preipauserid"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 0

                # get the userid of user1 and make sure it was not changed
		postipauserid=`ipa user-show $USER1 | grep UID | cut -d ":" -f 2`
		#trim whitespace
                postipauserid=`echo $postipauserid`
		if [ $preipauserid -ne $postipauserid ] ; then
			rlFail "Existing user should have been skipped during migration.  UID before migration: $preipauserid  UID post migration: $postipauserid"
		else
			rlPass "Existing IPA user. UID before migration: $preipauserid  UID post migration: $postipauserid"
		fi

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

	rlPhaseStartTest "ds-migration-cmd-017 Overwrite Group GID"
                rlRun "ipa group-add --desc=test $GROUP1" 0 "Add group that will be migrated"
                # get the ipa group id
                preipagroupid=`ipa group-show $GROUP1 | grep GID | cut -d ":" -f 2`
                #trim whitespace
                preipagroupid=`echo $preipagroupid`
                rlLog "IPA Group ID for $GROUP1: $preipagroupid"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-overwrite-gid ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --group-overwrite-gid ldap://$CLIENT:389" 0

                # get the gid of group1 and make sure it was overwritten
                postipagroupid=`ipa group-show $GROUP1 | grep GID | cut -d ":" -f 2`
                #trim whitespace
                postipagroupid=`echo $postipagroupid`
                if [ $preipagroupid -eq $postipagroupid ] ; then
                        rlFail "Existing group's GID should have been overwritten  GID before migration: $preipagroupid  GID post migration: $postipagroupid"
                else
                        rlPass "Existing IPA Group. GID before migration: $preipagroupid  GID post migration: $postipagroupid"
                fi

                #cleanup for next migration test
                ipa user-del $USER1
                ipa user-del $USER2
		ipa user-del $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-cmd-018 migration over ldaps"
		# setup /etc/openldap/ldap.conf/
		sed -i 's/ca.crt/remoteds.crt/g' /etc/openldap/ldap.conf
		service httpd restart

                rlLog "EXECUTING: ipa migrate-ds --with-compat --user-container=\"$USERCONTAINER,$MYBASEDN\" --group-container=\"$GROUPCONTAINER,$MYBASEDN\" ldaps://$CLIENT:636"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER,$MYBASEDN\" --group-container=\"$GROUPCONTAINER,$MYBASEDN\" ldaps://$CLIENT:636" 0
                rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying '$USER2' was migrated"
                rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

                rlLog "Cleaning up migrated users"
                ipa user-del $USER1 $USER2 $USER3
                ipa group-del $GROUP1 $GROUP2 "HR Managers" "PD Managers" "QA Managers" "Accounting Managers"
                sed -i 's/remoteds.crt/ca.crt/g' /etc/openldap/ldap.conf
                service httpd restart

        rlPhaseEnd

}

bugzillas()
{
        rlPhaseStartTest "bz804807 Internal Server Error specifying invalid RDN for container - User Container"
                # just in case you are running just bugzillas ... migration will not be enabled
                ipa config-mod --enable-migration=TRUE
                rlLog "EXECUTING: echo $ADMINPW | ipa migrate-ds --user-container=\"BostonUsers\" --group-container=\"ou=BostonGroups\" --base-dn=\"ou=Boston,dc=example,dc=com\" ldap://$CLIENT:389"
                echo $ADMINPW | ipa migrate-ds --user-container="BostonUsers" --group-container="ou=BostonGroups" --base-dn="ou=Boston,dc=example,dc=com" ldap://$CLIENT:389 > /tmp/bz804807.txt 2>&1
                cat /tmp/bz804807.txt | grep "Internal Server Error"
                if [ $? -eq 0 ] ; then
                        rlFail "https://bugzilla.redhat.com/show_bug.cgi?id=804807"
                else
                        rlPass "Internal Server Error bz804807 fixed - User Container"
                fi
        rlPhaseEnd

        rlPhaseStartTest "bz804807 Internal Server Error specifying invalid RDN for container - Group Container"
                rlLog "EXECUTING: echo $ADMINPW | ipa migrate-ds --user-container=\"ou=BostonUsers\" --group-container=\"BostonGroups\" --base-dn=\"ou=Boston,dc=example,dc=com\" ldap://$CLIENT:389"
                echo $ADMINPW | ipa migrate-ds --user-container="ou=BostonUsers" --group-container="BostonGroups" --base-dn="ou=Boston,dc=example,dc=com" ldap://$CLIENT:389 > /tmp/bz804807.txt 2>&1
                cat /tmp/bz804807.txt | grep "Internal Server Error"
                if [ $? -eq 0 ] ; then
                        rlFail "https://bugzilla.redhat.com/show_bug.cgi?id=804807"
                else
                        rlPass "Internal Server Error bz804807 fixed - Group Container"
                fi
        rlPhaseEnd

	rlPhaseStartTest "bz786185 Allow basedn to be passed into migrate-ds"
		rlLog "EXECUTING: echo $ADMINPW | ipa migrate-ds --user-container=\"ou=BostonUsers\" --group-container=\"ou=BostonGroups\" --base-dn=\"ou=Boston,dc=example,dc=com\" ldap://$CLIENT:389"
		rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"ou=BostonUsers\" --group-container=\"ou=BostonGroups\" --base-dn=\"ou=Boston,dc=example,dc=com\" ldap://$CLIENT:389" 0
		rlRun "ipa user-show bosusr" 0 "Verifying bosusr was migrated"
		rlRun "ipa group-show bosgrp" 0 "Verifying bosgrp was migrated"
		rlLog "Cleaning up migrated user and group"
		ipa user-del bosusr
		ipa group-del bosgrp
	rlPhaseEnd

        rlPhaseStartTest "bz783270 Warn if compat plugin is enabled"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                rlLog "EXECUTING: echo $ADMINPW | ipa-compat-manage enable"
                rlRun "echo $ADMINPW | ipa-compat-manage enable" 0
                rlDistroDiff dirsrv_svc_restart
		sleep 10
                rlLog "EXECUTING : echo $ADMINPW | ipa migrate-ds ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds ldap://$CLIENT:389 > /tmp/compatenabled.out 2>&1" 1
                rlAssertGrep "The compat plug-in is enabled." "/tmp/compatenabled.out"
		rlRun "cat /tmp/compatenabled.out"
        rlPhaseEnd

        rlPhaseStartTest "bz783270 Migrate with compat plugin enabled"
                rlLog "EXECUTING: echo $ADMINPW | ipa migrate-ds --with-compat ldap://$CLIENT:389"
		rlRun "echo $ADMINPW | ipa migrate-ds --with-compat ldap://$CLIENT:389" 0 "Migrating with compat plugin enabled"
                rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying '$USER2' was migrated"
		rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"
        rlPhaseEnd

	rlPhaseStartTest "bz804609 Internal Server Error - non-posix user-show --all"
		rlRun "ipa user-show --all $USER3 > /tmp/bz804609.out 2>&1" 0 "Show migrated non-posix user"
		rlAssertNotGrep "ipa: ERROR: an internal error has occurred" "/tmp/bz804609.out"
	rlPhaseEnd

	rlPhaseStartTest "bz753966 unable to delete migrated groups containing spaces"
		rlRun "ipa group-del \"HR Managers\" \"PD Managers\" \"QA Managers\" \"Accounting Managers\"" 0 "Delete migrated groups with spaces in the group names"
	rlPhaseEnd

	rlPhaseStartTest "bz809560 Do not create private groups for migrated users"
		for myuser in $USER1 $USER2 $USER3 ; do
			rlRun "ipa group-find --private $myuser" 1 "Verify user '$myuser' does not have a private group"
		done
		rlLog "Cleaning up migrated users"
                ipa user-del $USER1 $USER2 $USER3
                ipa group-del $GROUP1
                ipa group-del $GROUP2
	rlPhaseEnd

        rlPhaseStartTest "bz807371 migration: don't append basedn to container if it is included"
		rlLog "EXECUTING: ipa migrate-ds --with-compat --user-container=\"$USERCONTAINER,$MYBASEDN\" --group-container=\"$GROUPCONTAINER,$MYBASEDN\" ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --with-compat --user-container=\"$USERCONTAINER,$MYBASEDN\" --group-container=\"$GROUPCONTAINER,$MYBASEDN\" ldap://$CLIENT:389" 0
                rlRun "ipa user-show $USER1" 0 "Verifying $USER1 was migrated"
                rlRun "ipa user-show $USER2" 0 "Verifying '$USER2' was migrated"
                rlRun "ipa user-show $USER3" 0 "Verifying '$USER3' was migrated"
                rlRun "ipa group-show $GROUP1" 0 "Verifying group '$GROUP1' was migrated"
                rlRun "ipa group-show $GROUP2" 0 "Verifying group '$GROUP2' was migrated"

                rlLog "Cleaning up migrated users"
                ipa user-del $USER1 $USER2 $USER3
		ipa group-del $GROUP1 $GROUP2 "HR Managers" "PD Managers" "QA Managers" "Accounting Managers"
        rlPhaseEnd

	rlPhaseStartTest "bz813389 Improve migration plugin error when 2 groups have identical GID"
		cat > addgroup.ldif << addgroup.ldif_EOF

dn: cn=Group3,ou=groups,dc=example,dc=com
gidNumber: 1002
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: Group3
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
modifiersName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8d-1dd211b2-8f88fe1c-fcc30004
addgroup.ldif_EOF

		rlRun "/usr/bin/ldapmodify -a -x -h $CLIENT -p 389 -D \"cn=Directory Manager\" -w $ADMINPW -c -f addgroup.ldif" 0 "Add group with duplicate GID to existing ldap group"
		rlRun "/usr/bin/ldapsearch -x -h $CLIENT -p 389 -D \"cn=Directory Manager\" -w $ADMINPW -b cn=Group2,ou=groups,dc=example,dc=com"
		rlRun "/usr/bin/ldapsearch -x -h $CLIENT -p 389 -D \"cn=Directory Manager\" -w $ADMINPW -b cn=Group3,ou=groups,dc=example,dc=com"
		rlLog "EXECUTING: ipa migrate-ds --with-compat --user-container=\"$USERCONTAINER,$MYBASEDN\" --group-container=\"$GROUPCONTAINER,$MYBASEDN\" ldap://$CLIENT:389"
		rlRun "echo $ADMINPW | ipa migrate-ds --with-compat --user-container=\"$USERCONTAINER,$MYBASEDN\" --group-container=\"$GROUPCONTAINER,$MYBASEDN\" ldap://$CLIENT:389"
		rlAssertGrep "WARNING: GID number 1002 of migrated user puser2 should match 1 group, but it matched 2 groups" "/var/log/httpd/error_log"

		cat > delgroup.ldif << delgroup.ldif_EOF

dn: cn=Group3,ou=groups,dc=example,dc=com
changetype: delete
delgroup.ldif_EOF

		rlRun "/usr/bin/ldapmodify -a -x -h $CLIENT -p 389 -D \"cn=Directory Manager\" -w $ADMINPW -c -f delgroup.ldif" 0 "delete ldap group"

                rlLog "Cleaning up migrated users"
                ipa user-del $USER1 $USER2 $USER3
                ipa group-del $GROUP1 $GROUP2 $GROUP3 "HR Managers" "PD Managers" "QA Managers" "Accounting Managers"
	rlPhaseEnd
}

cleanup()
{
        rlPhaseStartTest "CLEANUP MIGRATION ACCEPTANCE"
		SetMigrationConfig FALSE
		rlRun "ssh -o StrictHostKeyChecking=no root@$CLIENT /usr/sbin/remove-ds.pl -i $INSTANCE" 0 "Removing directory server instance"
        rlPhaseEnd
}

