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
ds-migration-performance()
{
    setup
    performance
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
#  performance		    #
#############################		

performance()
{
	rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
	rlRun "echo $ADMINPW | ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389" 0	

}

cleanup()
{
	rlPhaseStartTest "CLEANUP FUNCTIONAL TESTING"
		rlRun "ssh -o StrictHostKeyChecking=no root@$CLIENT /usr/sbin/remove-ds.pl -i $INSTANCE" 0 "Removing directory server instance"
		rlRun "SetMigrationConfig FALSE" 0 "Set migration mode to FALSE"
	rlPhaseEnd
}
