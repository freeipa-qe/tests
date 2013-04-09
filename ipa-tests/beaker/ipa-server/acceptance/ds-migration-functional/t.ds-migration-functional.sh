USERCONTAINER="ou=People"
GROUPCONTAINER="ou=groups"
USEROBJCLASS="posixAccount"
GROUPOBJCLASS="posixGroup"
USER1="puser1"
USER1PWD="fo0m4nchU"
USER2PWD="Secret123"
USER2="puser2"
GROUP1="group1"
GROUP2="group2"
CACERT="/etc/ipa/ca.crt"
INSTANCE="slapd-instance1"

######################
# test suite         #
######################
ds-migration-functional()
{
    setup
    hashedpwdmigration_sssd
    #hashedpwdmigration_http
    cleanup
}

######################
# SETUP              #
######################

setup()
{
        rlPhaseStartTest "SETUP FUNCTIONAL TESTING"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "SetMigrationConfig TRUE" 0 "Set migration mode to TRUE"
        rlPhaseEnd
}

#############################
#  SSSD Password Migration  #
#############################		

hashedpwdmigration_sssd()
{
	rlPhaseStartTest "ds-migration-functional-001 Migrate users with hashed passwords"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --with-compat ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --with-compat ldap://$CLIENT:389" 0

		rlRun "verifyUserAttr $USER1 \"Kerberos keys available\" False" 0 "Verify migrated user $USER1 does not have a keytab"
		rlRun "verifyUserAttr $USER2 \"Kerberos keys available\" False" 0 "Verify migrated user $USER2 does not have a keytab"
	rlPhaseEnd

                #sleep 300
        rlPhaseStartTest "ds-migration-functional-002 SSSD password migration $USER1"
		rlRun "ssh_auth_success $USER1 $USER1PWD $HOSTNAME"
		rlRun "verifyUserAttr $USER1 \"Kerberos keys available\" True" 0 "Verify migrated user $USER1 now has a keytab"
                if [ $? -eq 1 ] ;then
                 rlLog "Failing because of https://fedorahosted.org/sssd/ticket/1873"
                fi
		# https://bugzilla.redhat.com/show_bug.cgi?id=822608
                KinitAsUser $USER1 $USER1PWD
                rlRun "klist | grep $USER1" 0 "Ensuring that kinit as $USER1 worked"
                rlLog "Running kinit"
                KinitAsUser $USER1 $USER1PWD

        rlPhaseEnd

        rlPhaseStartTest "ds-migration-functional-003 SSSD password migration $USER2"
		rlRun "ssh_auth_success $USER2 $USER2PWD $HOSTNAME"
		rlRun "verifyUserAttr $USER2 \"Kerberos keys available\" True" 0 "Verify migrated user $USER2 now has a keytab"
                if [ $? -eq 1 ] ;then
                 rlLog "Failing because of https://fedorahosted.org/sssd/ticket/1873"
                fi
                # https://bugzilla.redhat.com/show_bug.cgi?id=822608
                KinitAsUser $USER2 $USER2PWD
                rlRun "klist | grep $USER2" 0 "Ensuring that kinit as $USER2 worked"
                rlLog "Running kinit"
                KinitAsUser $USER2 $USER2PWD
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-functional-004 Cleanup SSSD Migration"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                ipa user-del $USER1
		ipa user-del $USER2
		ipa group-del $GROUP1
		ipa group-del $GROUP2

		rlRun "ipa user-show $USER1" 2 "Make sure $USER1 was deleted"
		rlRun "ipa user-show $USER2" 2 "Make sure $USER2 was deleted"
		rlRun "ipa group-show $GROUP1" 2 "Make sure $GROUP1 was deleted"
		rlRun "ipa group-show $GROUP2" 2 "Make sure $GROUP2 was deleted"
        rlPhaseEnd

}

#############################
#  HTTP Password Migration  #
#############################    

hashedpwdmigration_http()
{
        rlPhaseStartTest "ds-migration-functional-005 Re-Migrate users with hashed passwords"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --with-compat ldap://$CLIENT:389"
                rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --with-compat ldap://$CLIENT:389" 0

                rlRun "verifyUserAttr $USER1 \"Kerberos keys available\" False" 0 "Verify migrated user $USER1 does not have a keytab"
                rlRun "verifyUserAttr $USER2 \"Kerberos keys available\" False" 0 "Verify migrated user $USER2 does not have a keytab"
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-functional-006 HTTP password migration $USER1"
                rlRun "curl -v -e https://$MASTER/ipa/migration/ https://$MASTER/ipa/migration/migration.py --form-string 'username=$USER1' --form-string 'password=$USER1PWD' --cacert $CACERT" 0 "Hitting the migration page via curl"
		rlRun "verifyUserAttr $USER1 \"Kerberos keys available\" True" 0 "Verify migrated user $USER1 now has a keytab"
                # https://bugzilla.redhat.com/show_bug.cgi?id=822608
                KinitAsUser $USER1 $USER1PWD 
                rlRun "klist | grep $USER1" 0 "Ensuring that kinit as $USER1 worked" 
                rlLog "Running kinit"
                KinitAsUser $USER1 $USER1PWD 
        rlPhaseEnd

        rlPhaseStartTest "ds-migration-functional-007 HTTP password migration $USER2"
		rlRun "curl -v -e https://$MASTER/ipa/migration/ https://$MASTER/ipa/migration/migration.py --form-string 'username=$USER2' --form-string 'password=$USER2PWD' --cacert $CACERT" 0 "Hitting the migration page via curl"
                rlRun "verifyUserAttr $USER2 \"Kerberos keys available\" True" 0 "Verify migrated user $USER2 now has a keytab"
		# https://bugzilla.redhat.com/show_bug.cgi?id=822608
                KinitAsUser $USER2 $USER2PWD
                rlRun "klist | grep $USER2" 0 "Ensuring that kinit as $USER2 worked"
                rlLog "Running kinit"
                KinitAsUser $USER2 $USER2PWD

        rlPhaseEnd

        rlPhaseStartTest "ds-migration-functional-008 Cleanup HTTP Migration"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                ipa user-del $USER1
                ipa user-del $USER2
                ipa group-del $GROUP1
                ipa group-del $GROUP2

                rlRun "ipa user-show $USER1" 2 "Make sure $USER1 was deleted"
                rlRun "ipa user-show $USER2" 2 "Make sure $USER2 was deleted"
                rlRun "ipa group-show $GROUP1" 2 "Make sure $GROUP1 was deleted"
                rlRun "ipa group-show $GROUP2" 2 "Make sure $GROUP2 was deleted"
        rlPhaseEnd
}

cleanup()
{
	rlPhaseStartTest "CLEANUP FUNCTIONAL TESTING"
		rlRun "ssh -o StrictHostKeyChecking=no root@$CLIENT /usr/sbin/remove-ds.pl -i $INSTANCE" 0 "Removing directory server instance"
		rlRun "SetMigrationConfig FALSE" 0 "Set migration mode to FALSE"
	rlPhaseEnd
}
