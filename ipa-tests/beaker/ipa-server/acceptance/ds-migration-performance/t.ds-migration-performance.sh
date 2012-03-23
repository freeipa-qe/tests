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
performance()
{
    setup
    perftest 
    cleanup
}

######################
# SETUP              #
######################

setup()
{
        rlPhaseStartTest "SETUP FUNCTIONAL TESTING"
		rlLog "Compat Plugin Enabled Mode :: $COMPAT"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                rlRun "ipa config-mod --enable-migration=TRUE" 0 "Set migration mode to TRUE"

		echo $COMPAT | grep "FALSE"
		if [ $? -eq 0 ] ; then
			rlLog "Test Running with compat plugin Disabled"
			echo $ADMINPW | ipa-compat-manage status | grep Enabled
			if [ $? -eq 0 ] ; then
				rlRun "echo $ADMINPW | ipa-compat-manage disable" 0 "Turn off compat plugin"
				rlRun "service dirsrv restart" 0 "Restart directory server"
			fi
		else
			rlLog "Test Running with compat plugin Enabled"
			echo $ADMINPW | ipa-compat-manage status | grep Disabled
			rlRun "echo $ADMINPW | ipa-compat-manage enable" 0 "Turning on compat plugin"
			rlRun "service dirsrv restart" 0 "Restart directory server"
		fi
			
        rlPhaseEnd
}

#############################
#  performance		    #
#############################		

perftest()
{
	rlPhaseStartTest "Migration 10000 users and 12 groups"
		# record the current free memory
		prememfree=`free -b | grep Mem: | awk '{print $4}'`
		rlLog "Before migration free memory : $prememfree"
                starttime=`date`
                rlLog "======================= Migration started: $starttime ========================"
		
		if [ "$COMPAT" != "FALSE" ] ; then
			rlLog "EXECUTING: time -p echo $ADMINPW | ipa migrate-ds --with-compat ldap://$CLIENT:389"
			echo $ADMINPW | ipa migrate-ds --with-compat ldap://$CLIENT:389
			if [ $? -ne 0 ] ; then
				rlFail "Migration did not complete successfully."
			else
				rlPass "Migration completed successfully."
			fi
		else
			rlLog "EXECUTING: echo $ADMINPW | ipa migrate-ds ldap://$CLIENT:389"
			echo $ADMINPW | ipa migrate-ds ldap://$CLIENT:389 > /tmp/compat.perf 2>&1
                        if [ $? -ne 0 ] ; then
                                rlFail "Migration did not complete successfully."
                        else
                                rlPass "Migration completed successfully."
                        fi
		fi
                endtime=`date`
                rlLog "======================= Migration finished: $endtime ========================"
		postmemfree=`free -b | grep Mem: | awk '{print $4}'`
		rlLog "After migration free memory : $postmemfree"
	rlPhaseEnd
}

cleanup()
{
	rlPhaseStartTest "CLEANUP FUNCTIONAL TESTING"
		#rlRun "ssh -o StrictHostKeyChecking=no root@$CLIENT /usr/sbin/remove-ds.pl -i $INSTANCE" 0 "Removing directory server instance"
		rlRun "ipa config-mod --enable-migration=FALSE" 0 "Set migration mode to FALSE"
	rlPhaseEnd
}
