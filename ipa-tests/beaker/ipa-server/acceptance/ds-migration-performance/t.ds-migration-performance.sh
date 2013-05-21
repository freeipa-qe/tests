export IPAINSTANCE=`echo $RELM | sed 's/\./-/g'`
export DSINSTANCE="slapd-instance1"

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
        rlPhaseStartSetup "SETUP FUNCTIONAL TESTING"
		rlLog "Compat Plugin Enabled Mode :: $COMPAT"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

		# turn up the memory cache size
		service dirsrv stop
		cp /etc/dirsrv/slapd-$IPAINSTANCE/dse.ldif /tmp/dse.ldif
		cat /tmp/dse.ldif | sed 's/10485760/20971520/g' > /etc/dirsrv/slapd-$IPAINSTANCE/dse.ldif
		service dirsrv start
		cat /etc/dirsrv/slapd-$IPAINSTANCE/dse.ldif | grep 20971520

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
			if [ $? -eq 0 ] ; then
				rlRun "echo $ADMINPW | ipa-compat-manage enable" 0 "Turning on compat plugin"
				rlRun "service dirsrv restart" 0 "Restart directory server"
			fi
		fi
			
        rlPhaseEnd
}

#############################
#  performance		    #
#############################		

perftest()
{
	rlPhaseStartTest "ipa-migration-performance-001: Migration 10000 users and 12 groups"
		# record the current free memory
		prememfree=`free -b | grep Mem: | awk '{print $4}'`
	
		# get slapd process mem in use
		slapdpid=`cat /var/run/dirsrv/slapd-$IPAINSTANCE.pid`
		rlLog "slapd pid : $slapdpid"
		slapdVmRSS=`cat /proc/$slapdpid/status | grep "VmRSS" | awk '{print $2 $3}'`
		slapdVmHWM=`cat /proc/$slapdpid/status | grep "VmHWM" | awk '{print $2 $3}'`
			
		rlLog "Before migration free memory : $prememfree"
		rlLog "Before migration slapd VmRSS : $slapdVmRSS"
		rlLog "Before migration slapd VmHWM : $slapdVmHWM"

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

                # get slapd process mem in use
		slapdpid=`cat /var/run/dirsrv/slapd-$IPAINSTANCE.pid`
		rlLog "slapd pid : $slapdpid"
                slapdVmRSS=`cat /proc/$slapdpid/status | grep "VmRSS" | awk '{print $2 $3}'`
                slapdVmHWM=`cat /proc/$slapdpid/status | grep "VmHWM" | awk '{print $2 $3}'`

                rlLog "After migration free memory : $postmemfree"
                rlLog "After migration slapd VmRSS : $slapdVmRSS"
                rlLog "After migration slapd VmHWM : $slapdVmHWM"
	rlPhaseEnd
}

cleanup()
{
	rlPhaseStartCleanup "CLEANUP FUNCTIONAL TESTING"
		rlRun "ipa config-mod --enable-migration=FALSE" 0 "Set migration mode to FALSE"
	rlPhaseEnd
}
