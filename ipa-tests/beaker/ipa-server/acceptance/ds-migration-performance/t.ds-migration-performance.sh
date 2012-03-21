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
		if [ $COMPAT == FALSE ] ; then
			rlLog "Test Running with compat plugin Disabled"
			echo $ADMINPW | ipa-compat-manage status | grep Enabled
			if [ $? -ne 0 ] ; then
				rlRun "ipa-compat-manage disable" 0 "Turn off compat plugin"
				rlRun "service dirsrv restart" 0 "Restart directory server"
			fi
		else
			rlLog "Test Running with compat plugin Enabled"
			echo $ADMINPW | ipa-compat-manage status | grep Disabled
			if [ $? -ne 0 ] ; then
				rlRun "ipa-compat-manage enable" 0 "Turning on compat plugin"
				rlRun "service dirsrv restart" 0 "Restart directory server"
			fi
			
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "SetMigrationConfig TRUE" 0 "Set migration mode to TRUE"
        rlPhaseEnd
}

#############################
#  performance		    #
#############################		

performance()
{
	rlPhaseStartTest "Migration 10000 users and 12 groups"
		# record the current free memory
		prememfree=`free -p | grep Mem: | cut -d " " -f9`
		rlLog "Before migration free memory :: $prememfree"
		
		if [ "$COMPAT" != "FALSE" ] ; then
			rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" --with-compat ldap://$CLIENT:389"
			time -p echo $ADMINPW | ipa migrate-ds --with-compat ldap://$CLIENT:389 > /tmp/compat.perf > 2>&1
		else
			rlLog "EXECUTING: ipa migrate-ds --user-container=\"$USERCONTAINER\" --group-container=\"$GROUPCONTAINER\" ldap://$CLIENT:389"
			time -p echo $ADMINPW | ipa migrate-ds ldap://$CLIENT:389 > /tmp/compat.perf > 2>&1
		fi

		realtime=`cat /tmp/compat.perf | grep real | cut -d " " -f 2`
		rlLog "Migration time :: $realtime"
		postmemfree=`free -p | grep Mem: | cut -d " " -f9`
		rlLog "After migration free memory :: $postmemfree"
	rlPhaseEnd
}

cleanup()
{
	rlPhaseStartTest "CLEANUP FUNCTIONAL TESTING"
		#rlRun "ssh -o StrictHostKeyChecking=no root@$CLIENT /usr/sbin/remove-ds.pl -i $INSTANCE" 0 "Removing directory server instance"
		rlRun "SetMigrationConfig FALSE" 0 "Set migration mode to FALSE"
	rlPhaseEnd
}
