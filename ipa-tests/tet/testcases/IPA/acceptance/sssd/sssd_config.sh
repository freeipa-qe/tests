#!/bin/sh

######################################################################
#  File: sssd_config.ksh - acceptance tests for SSSD Services
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

env
ls $TESTING_SHARED/sssdlib.sh
ls $TESTING_SHARED/

######################################################################
#  Test Case List
#####################################################################
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9"
ic1="sssd_config_001"
ic2="sssd_config_002"
ic3="sssd_config_003"
ic4="sssd_config_004"
ic5="sssd_config_005"
ic6="sssd_config_006"
ic7="sssd_config_007"
ic8="sssd_config_008"
ic9="sssd_config_009"
######################################################################
# Tests
######################################################################

sssd_config_001()
{
  myresult=PASS
  message "START $tet_thistest: MaxId is less than MinId"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG="Invalid domain range"
        sssdCfg $FULLHOSTNAME sssd_config1.conf
        if [ $? -ne 0 ] ; then
        	message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
		ssh root@$FULLHOSTNAME "service sssd stop"
		ssh root@$FULLHOSTNAME "service sssd start"
		if [ $? -eq 0 ] ; then
			message "ERROR: Invalid configuration MaxId less than MinId - service started"
			message "Trac issue 126"
			myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
		else
                        message "Starting services with invalid configuration failed as expected."
		fi
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

	MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi

  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_002()
{
  myresult=PASS
  message "START $tet_thistest: Negative minId"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG="Invalid value for minId"
        sssdCfg $FULLHOSTNAME sssd_config3.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration Negative minId - service started"
			message "Trac issue 127"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_003()
{
  myresult=PASS
  message "START $tet_thistest: Negative MaxId"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG="Invalid value for maxId"
        sssdCfg $FULLHOSTNAME sssd_config4.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration Negative maxId - service started"
			message "Trac issue 127"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_004()
{
  myresult=PASS
  message "START $tet_thistest: Duplicate Defined Parameters - Last One Read Wins"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"

        sssdCfg $FULLHOSTNAME sssd_config5.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                restartSSSD $FULLHOSTNAME
                if [ $? -ne 0 ] ; then
                	message "ERROR: Restart SSSD failed on $FULLHOSTNAME"
                        myresult=FAIL
                fi

		# check for trac issue 128 - duplicate minIds defined causes seg fault
		ssh root@$FULLHOSTNAME "/usr/sbin/sssd"
		if [ $? -eq 255 ] ; then
			message "ERROR: Trac issue 128 still exists. Segmentation Fault"
			myresult=FAIL
		else
                	verifyCfg $FULLHOSTNAME LOCAL enumerate TRUE
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
			fi

                	verifyCfg $FULLHOSTNAME LOCAL minId 2000
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $FULLHOSTNAME LOCAL maxId 2010
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $FULLHOSTNAME LOCAL magicPrivateGroups TRUE
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $FULLHOSTNAME LOCAL provider local
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $FULLHOSTNAME LOCAL useFullyQualifiedNames TRUE
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

        	fi
	fi

	ssh root@$FULLHOSTNAME "service sssd stop"
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_005()
{
  myresult=PASS
  message "START $tet_thistest: Required Key provider Not Defined"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG="Domain [LOCAL] does not specify a provider, disabling!"
        sssdCfg $FULLHOSTNAME sssd_config6.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration no Provider defined - service started"
			message "Trac issue 130"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_006()
{
  myresult=PASS
  message "START $tet_thistest: Enumeration defined with Integer"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG=""
        sssdCfg $FULLHOSTNAME sssd_config7.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration enumeration defined with integer - service started"
			message "Trac issue 131"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_007()
{
  myresult=PASS
  message "START $tet_thistest: Enumeration defined with non boolean"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG=""
        sssdCfg $FULLHOSTNAME sssd_config8.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration enumeration defined with non boolean - service started"
			message "Trac issue 131"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_008()
{
  myresult=PASS
  message "START $tet_thistest: useFullyQualifiedNames defined with a string"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG=""
        sssdCfg $FULLHOSTNAME sssd_config9.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration boolean defined with a string - service started"
			message "Trac issue 132"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "service sssd stop"
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_009()
{
  myresult=PASS
  message "START $tet_thistest: useFullyQualifiedNames defined with an integer"
  EXPMSG=""
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	EXPMSG=""
        sssdCfg $FULLHOSTNAME sssd_config10.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $FULLHOSTNAME."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "service sssd stop"
                ssh root@$FULLHOSTNAME "service sssd start"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Invalid configuration boolean defined with an integer - service started"
			message "Trac issue 132"
                        myresult=FAIL
                else
                        message "Starting services with invalid configuration failed as expected."
                fi
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

        MSG="sssd is stopped"
        STATUS=`ssh root@$FULLHOSTNAME "service sssd status"`
        if [[ $STATUS != $MSG ]] ; then
                message "ERROR: Status returned \"$MSG\"."
                myresult=FAIL
        else
                message "Status as expected: \"$MSG\"."
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

