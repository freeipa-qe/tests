#!/bin/sh

######################################################################
#  File: sssd_services.ksh - acceptance tests for SSSD Services
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic1 ic2 ic3 ic4"
ic1="bug512733"
ic2="sssd_service_001"
ic3="sssd_service_002"
ic4="sssd_service_003"
#################################################################
#  GLOBALS
#################################################################
PIDFILE=/var/run/sssd.pid
######################################################################
# Tests
######################################################################

bug512733()
{
  myresult=PASS
  message "START $tet_thistest: Start Services with No Domains Configured - bug 512733"
  for c in $CLIENTS; do
	 eval_vars $c
        message "Working on $FULLHOSTNAME"
	ssh root@$FULLHOSTNAME "cat /dev/null > /var/log/messages ; service sssd start"
	if [ $? -eq 0 ] ; then
		message "ERROR: Starting service should return non zero return code."
		myresult=FAIL
	else
		message "This part fixed. Non-zero return code: $?"
	fi

        MSG="PID file exists"
        # check the status of the service should not be running
        STATUS=`ssh root@$FULLHOSTNAME "if [ -f /var/run/sssd.pid ] ; then echo "PID file exists" ; fi"`
        if [[ $STATUS == $MSG ]] ; then
                message "PID file /var/run/sssd.pid exists."
                myresult=FAIL
        else
                message "PID file was not created."
        fi

	MSG="sssd dead but pid file exists"
	STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
	if [[ $STATUS == $MSG ]] ; then
		message "ERROR: Bug 512733 Still Exists"
		myresult=FAIL
	else
		message "This part fixed. Status did not return \"$MSG\"."
	fi

	# check /var/log/messages for error message
#	ERR="No domains configured"
#	message "Searching /var/log/messages for \"$ERR\""
#	ssh root@$FULLHOSTNAME cat /var/log/messages | grep "$ERR"
#	if [ $? -ne 0 ] ; then
#		message "ERROR: \"$ERR\" not found in /var/log/messages"
#		sftp root@$FULLHOSTNAME:/var/log/messages $TET_TMP_DIR/messages_bug512733
#		myresult=FAIL
#	else
#		message "\"$ERR\" found in /var/log/messages"
#	fi

	ssh root@$FULLHOSTNAME "service sssd stop"
	ssh root@$FULLHOSTNAME "rm -rf /var/run/sssd.pid"
  done
  tet_result $myresult
  message "END $tet_thistest"
}


sssd_service_001()
{
  myresult=PASS
  message "START $tet_thistest: Start Services and Verify Status"
  for c in $CLIENTS; do
	 eval_vars $c
        message "Working on $FULLHOSTNAME"

	# Need atleast one domain configured for services to start
        sssdCfg $FULLHOSTNAME sssd_local1.conf
        if [ $? -ne 0 ] ; then
        	message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
        	restartSSSD $FULLHOSTNAME
                if [ $? -ne 0 ] ; then
                	message "ERROR: Restart SSSD failed on $FULLHOSTNAME"
                        myresult=FAIL
                else
                	message "SSSD Server restarted on client $FULLHOSTNAME"
                fi
        fi
	
	# get Process ID
	PID=`ssh root@$FULLHOSTNAME "cat $PIDFILE"`
	message "Process ID is $PID"

	# check service status
	STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`	
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
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	SERVICES="sssd_dp sssd_nss sssd_pam"
	for s in $SERVICES ; do	
                OPID=`ssh root@$FULLHOSTNAME "ps -e | grep $s | cut -d \" \" -f 1 2>&1"`
		if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to find running process id for $s"
                        myresult=FAIL
		else
			message "Original PID for $s was $OPID"
			ssh root@$FULLHOSTNAME "kill $OPID"
			if [ $? -ne 0 ] ; then
				message "ERROR: Failed to kill $s. return code: $?"
				myresult=FAIL
			else
				sleep 5
				NPID=`ssh root@$FULLHOSTNAME "ps -e | grep $s | cut -d \" \" -f 1 2>&1"`
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
  for c in $CLIENTS; do
	 eval_vars $c
        message "Working on $FULLHOSTNAME"
        ssh root@$FULLHOSTNAME "service sssd stop"
        if [ $? -ne 0 ] ; then
                message "ERROR: SSSD Service failed to stop. Return Code: $?"
                myresult=FAIL
        fi

        MSG="sssd is stopped"
        # check the status of the service should not be running
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
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

##################################################################
. $TESTING_SHARED/shared.sh
. $TESTING_SHARED/sssdlib.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF

