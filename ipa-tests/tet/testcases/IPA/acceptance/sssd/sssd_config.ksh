#!/bin/ksh

######################################################################
#  File: sssd_config.ksh - acceptance tests for SSSD Services
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10 ic99"
ic0="startup"
ic1="sssd_config_001"
ic2="sssd_config_002"
ic3="sssd_config_003"
ic4="sssd_config_004"
ic5="sssd_config_005"
ic6="sssd_config_006"
ic7="sssd_config_007"
ic8="sssd_config_008"
ic9="sssd_config_009"
ic10="sssd_config_010"
ic99="cleanup"

#################################################################
#  GLOBALS
#################################################################
#C1="jennyv2.bos.redhat.com"
#C1="jennyv2.bos.redhat.com dhcp\-100\-2\-185.bos.redhat.com"
C1="dhcp-100-2-185.bos.redhat.com"
SSSD_CLIENTS="$C1"
export SSSD_CLIENTS
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

sssd_config_001()
{
  myresult=PASS
  message "START $tet_thistest: MaxId is less than MinId"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config1.conf
        if [ $? -ne 0 ] ; then
        	message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
		ssh root@$c "service sssd stop"
		MSG=`ssh root@$c "service sssd start 2>&1"`
		if [ $? -eq 0 ] ; then
			message "$MSG"
			message "ERROR: Invalid configuration MaxId less than MinId - service started"
			myresult=FAIL
		else
	                if [[ $EXPMSG != $MSG ]] ; then
        	                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                	        myresult=FAIL
                	else
                        	message "Starting services with invalid configuration failed as expected."
                	fi
			
		fi
	fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_002()
{
  myresult=PASS
  message "START $tet_thistest: MaxId is the same as MinId"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config2.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
			message "$MSG"
                        message "ERROR: Invalid configuration MaxId is the same as MinId - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_003()
{
  myresult=PASS
  message "START $tet_thistest: Negative minId"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config3.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
			message "$MSG"
                        message "ERROR: Invalid configuration Negative minId - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_004()
{
  myresult=PASS
  message "START $tet_thistest: Negative MaxId"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config4.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
			message "$MSG"
                        message "ERROR: Invalid configuration Negative maxId - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_005()
{
  myresult=PASS
  message "START $tet_thistest: Duplicate Defined Parameters - Last One Read Wins"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config5.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                restartSSSD $c
                if [ $? -ne 0 ] ; then
                	message "ERROR: Restart SSSD failed on $c"
                        myresult=FAIL
                fi

		# check for trac issue 128 - duplicate minIds defined causes seg fault
		ssh root@$c "/usr/sbin/sssd"
		if [ $? -eq 255 ] ; then
			message "ERROR: Trac issue 128 still exists. Segmentation Fault"
			myresult=FAIL
		else
                	verifyCfg $c LOCAL enumerate 3
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
			fi

                	verifyCfg $c LOCAL minId 2000
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $c LOCAL maxId 2010
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $c LOCAL magicPrivateGroups TRUE
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $c LOCAL provider local
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

                	verifyCfg $c LOCAL useFullyQualifiedNames TRUE
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

        	fi
	fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_006()
{
  myresult=PASS
  message "START $tet_thistest: Required Key provider Not Defined"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config6.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "$MSG"
                        message "ERROR: Invalid configuration no Provider defined - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_007()
{
  myresult=PASS
  message "START $tet_thistest: Enumeration defined with Non Integer"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config7.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "$MSG"
                        message "ERROR: Invalid configuration enumeration defined with non integer - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_008()
{
  myresult=PASS
  message "START $tet_thistest: Enumeration defined with Negative Integer"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config8.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "$MSG"
                        message "ERROR: Invalid configuration enumeration defined with negative integer - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_009()
{
  myresult=PASS
  message "START $tet_thistest: useFullyQualifiedNames defined with a string"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config9.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "$MSG"
                        message "ERROR: Invalid configuration boolean defined with a string - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
        fi
  done

  tet_result $myresult
  message "END $tet_thistest"
}

sssd_config_010()
{
  myresult=PASS
  message "START $tet_thistest: useFullyQualifiedNames defined with an integer"
  EXPMSG=""
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        sssdCfg $c sssd_config10.conf
        if [ $? -ne 0 ] ; then
                message "ERROR Configuring SSSD on $c."
                myresult=FAIL
        else
                ssh root@$c service sssd stop
                MSG=`ssh root@$c "service sssd start 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "$MSG"
                        message "ERROR: Invalid configuration boolean defined with an integer - service started"
                        myresult=FAIL
                else
                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Starting services with invalid configuration failed as expected."
                        fi
                fi
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

