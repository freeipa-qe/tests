#!/bin/ksh

######################################################################
#  File: sssd_services.ksh - acceptance tests for SSSD Services
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic4 ic99"
ic0="startup"
ic1="bug512733"
ic2="sssd_service_001"
ic3="sssd_service_002"
ic4="sssd_service_003"
ic99="cleanup"

#################################################################
#  GLOBALS
#################################################################
#C1="jennyv2.bos.redhat.com"
#C1="jennyv2.bos.redhat.com dhcp\-100\-2\-185.bos.redhat.com"
C1="dhcp-100-2-185.bos.redhat.com"
SSSD_CLIENTS="$C1"
export SSSD_CLIENTS
PIDFILE=/var/run/sssd.pid
######################################################################
# Tests
######################################################################
startup()
{
  myresult=PASS
  message "START $tet_thistest: Setup NSS and PAM AUTH Configurations"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        sssdClientSetup $c 
        if [ $? -ne 0 ] ; then
                message "ERROR: SSSD Client Setup Failed for $c."
                myresult=FAIL
        fi

        ssh root@$c "yum -y install sssd"
        if [ $? -ne 0 ] ; then
                message "ERROR:  Failed to install SSSD. Return code: $?"
                myresult=FAIL
        else
                message "SSSD installed successfully."
        fi

  done

  tet_result $myresult
  message "END $tet_thistest"
}

bug512733()
{
  myresult=PASS
  message "START $tet_thistest: Start Services with No Domains Configured - bug 512733"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
	ssh root@$c "service sssd start"
	if [ $? -eq 0 ] ; then
		message "ERROR: Starting service should return non zero return code."
		myresult=FAIL
	fi

	MSG="sssd dead but pid file exists"
	# check the status of the service should not be running
	STATUS=`ssh root@$c "service sssd status"`
	if [[ $STATUS == $MSG ]] ; then
		message "ERROR: Bug 512733 Still Exists"
		myresult=FAIL
	fi
  done
  tet_result $myresult
  message "END $tet_thistest"
}


sssd_service_001()
{
  myresult=PASS
  message "START $tet_thistest: Start Services and Verify Status"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

	# Need atleast one domain configured for services to start
        sssdCfg $c sssd_local1.conf
        if [ $? -ne 0 ] ; then
        	message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
        	restartSSSD $c
                if [ $? -ne 0 ] ; then
                	message "ERROR: Restart SSSD failed on $c"
                        myresult=FAIL
                else
                	message "SSSD Server restarted on client $c"
                fi
        fi
	
	# get Process ID
	PID=`ssh root@$c "cat $PIDFILE"`
	message "Process ID is $PID"

	# check service status
	STATUS=`ssh root@$c "service sssd status"`	
	echo $STATUS | grep $PID
	if [ $? -ne 0 ] ; then
		message "ERROR: expected status message to contain process id number $PID.  GOT: $STATUS"
		myresult=FAIL
	fi
	echo $STATUS | grep running
	if [ $? -ne 0 ] ; then
		message "ERROR: Expected status message to say service is running."
		myresult=FAIL
	fi

	if [[ $myresult == PASS ]] ; then
		message "SSSD service with process id $PID is running as expected."
	fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_service_002()
{
  myresult=PASS
  message "START $tet_thistest: Verify if a back end service dies - it is automatically restarted"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
	SERVICES="sssd_dp sssd_nss sssd_pam"
	for s in $SERVICES ; do	
		OPID=`ssh root@$c "ps -e | grep $s | cut -d \" \" -f 1 2>&1"`
		if [ $? -ne 0 ] ; then
			message "ERROR: Failed to get PID for $s"
			myresult=FAIL
		else
			message "Original PID for $s was $OPID"
			ssh root@$c "kill $OPID"
			if [ $? -ne 0 ] ; then
				message "ERROR: Failed to kill $s. return code: $?"
				myresult=FAIL
			else
				sleep 5
				NPID=`ssh root@$c "ps -e | grep $s | cut -d \" \" -f 1 2>&1"`
				if [ $? -ne 0 ] ; then
					message "ERROR: Failed to get new PID for $s - may not have restarted. return code: $?"
					myresult=FAIL
				else
					if [ $OPID -eq $NPID ] ; then
						message "New PID is the same as the original.  Service never died."
						myresult=FAIL
					else
						message "$s was automatically restarted. New PID is $NPID"
					fi
				fi
			fi
		fi
	done
  done
  tet_result $myresult
  message "END $tet_thistest"
}

sssd_service_003()
{
  myresult=PASS
  message "START $tet_thistest: Stop Services and Check Status"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "service sssd stop"
        if [ $? -ne 0 ] ; then
                message "ERROR: SSSD Service failed to stop. Return Code: $?"
                myresult=FAIL
        fi

        MSG="sssd is stopped"
        # check the status of the service should not be running
        STATUS=`ssh root@$c "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Unexpected status returned.  Expected: $MSG Got: $STATUS"
                myresult=FAIL
        else
                message "SSSD service is stopped as expected."
        fi
  done
  tet_result $myresult
  message "END $tet_thistest"
}



cleanup()
{
  myresult=PASS
  message "START $tet_thistest: Cleanup Clients"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        sssdClientCleanup $c 
        if [ $? -ne 0 ] ; then
                message "ERROR:  SSSD Client Cleanup did not complete successfully on client $c."
                myresult=FAIL
        fi

        ssh root@$c "yum -y erase sssd ; rm -rf /var/lib/sss/ ; yum clean all"
        if [ $? -ne 0 ] ; then
                message "ERROR: Failed to uninstall and cleanup SSSD. Return code: $?"
                myresult=FAIL
        else
                message "SSSD Uninstall and Cleanup Success."
        fi

  done

  result $myresult
  message "END $tet_thistest"
}

##################################################################
. $TESTING_SHARED/shared.ksh
. $TESTING_SHARED/sssdlib.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

#EOF

