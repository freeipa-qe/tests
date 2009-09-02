#!/bin/ksh

######################################################################
#  File: sssd_files.ksh - acceptance tests for SSSD and Local files
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic99"
ic0="startup"
ic1="sssd_files_001 sssd_files_002 sssd_files_003 sssd_files_004 sssd_files_005 sssd_files_006 sssd_files_007 sssd_files_008 sssd_files_009 sssd_files_010 sssd_files_011 sssd_files_012 sssd_files_013"
ic99="cleanup"
#################################################################
#  GLOBALS
#################################################################
#C1="jennyv2.bos.redhat.com dhcp\-100\-2\-185.bos.redhat.com"
C1="dhcp\-100\-2\-185.bos.redhat.com"
SSSD_CLIENTS="$C1"
export SSSD_CLIENTS
CONFIG_DIR=$TET_ROOT/testcases/IPA/acceptance/sssd/config
SSSD_CONFIG_DIR=/etc/sssd
SSSD_CONFIG_FILE=$SSSD_CONFIG_DIR/sssd.conf
SSSD_CONFIG_DB=/var/lib/sss/db/config.ldb
PAMCFG=/etc/pam.d/system-auth
LDAPCFG=/etc/ldap.conf
NSSCFG=/etc/nsswitch.conf
SYS_CFG_FILES="$PAMCFG $LDAPCFG $NSSCFG $SSSD_CONFIG_FILE"
######################################################################
# Tests
######################################################################
startup()
{
  myresult=PASS
  message "START $tet_thistest: Setup for SSSD Local Domain Testing"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        ssh root@$c "yum -y install sssd"
        if [ $? -ne 0 ] ; then
                message "ERROR:  Failed to install SSSD. Return code: $?"
                myresult=FAIL
        else
                message "SSSD installed successfully."
        fi

        sssdClientSetup $c
        if [ $? -ne 0 ] ; then
                message "ERROR: SSSD Client Setup Failed for $c."
                myresult=FAIL
        fi
  done
  tet_result $myresult
  message "END $tet_thistest"
}

sssd_files_001()
{
   ####################################################################
   #   Configuration 1
   #    enumerate: TRUE
   # 	maxId = 1999
   #    provider: files
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 1 - FILES - Max ID"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $c sssd_files1.conf
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

                verifyCfg $c FILES enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c FILES maxId 1999
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c FILES provider files
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_002()
{
	myresult=PASS
  	message "START $tet_thistest: getent -s sss passwd returns passwd file users"
  	for c in $SSSD_CLIENTS; do
        	message "Working on $c"
		ssh root@$c "getent -s files passwd" > $TET_TMP_DIR/fileusers
		ssh root@$c "getent -s sss passwd" > $TET_TMP_DIR/sssusers
		diff $TET_TMP_DIR/fileusers $TET_TMP_DIR/sssusers
		if [ $? -ne 0 ] ; then
			message "ERROR: Legacy Local user returned by getent -s sss did not match getent -s files"
			myresult=FAIL
		fi
	done

	if [ $myresult == PASS ] ; then
		message "All Local passwd file users returned by getent"
	fi

        result $myresult
        message "END $tet_thistest"
}

sssd_files_003()
{
        myresult=PASS
        message "START $tet_thistest: getent -s sss group returns group file groups"
        for c in $SSSD_CLIENTS; do
                message "Working on $c"
		ssh root@$c "getent -s files group" > $TET_TMP_DIR/filegroups
                ssh root@$c "getent -s sss group" > $TET_TMP_DIR/sssgroups
                diff $TET_TMP_DIR/filegroups $TET_TMP_DIR/sssgroups
                if [ $? -ne 0 ] ; then
                        message "ERROR: Legacy Local group returned by getent -s sss did not match getent -s files"
                        myresult=FAIL
                fi

        done

        if [ $myresult == PASS ] ; then
                message "All Local group file groups returned by getent"
        fi

        result $myresult
        message "END $tet_thistest"
}

sssd_files_004()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to add User with SSS Tools"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
		EXPMSG="Operation not allowed"
                MSG=`ssh root@$c "sss_useradd -h /home/user1 -s /bin/bash user1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add user with SSS Tools with provider = files was successful, but expected to fail."
                        myresult=FAIL
			ssh root@$c "sss_userdel user1"
		fi

		if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			 message "Trac issue 145"
                        myresult=FAIL
                else
                        message "Adding user failed with expected error message."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_005()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to add Group with SSS Tools"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="Operation not allowed"
                MSG=`ssh root@$c "sss_groupadd group1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add group with SSS Tools with provider = files was successful, but expected to fail."
                        myresult=FAIL
                        ssh root@$c "sss_groupdel group1"
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 145"
                        myresult=FAIL
                else
                        message "Adding user failed with expected error message."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}


sssd_files_006()
{
        myresult=PASS
        message "START $tet_thistest: Add legacy user with uidNumber above maxId"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "useradd -u 2000 myuser2000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Add legacy user failed. return code: $?"
                        myresult=FAIL
		else
			ssh root@$c "getent -s sss passwd | grep myuser2000"
			if [ $? -eq 0 ] ; then
				message "ERROR: Local provider files user out of range was returned."
				message "Trac issue 139"
				myresult=FAIL
			else
				message "Local provider files user with uidNumber above maxId not returned as expected."
			fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_007()
{
        myresult=PASS
        message "START $tet_thistest: Verify MPG of user with gidNumber above maxId"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "getent -s sss group | grep myuser2000"
                if [ $? -eq 0 ] ; then
                	message "ERROR: Local provider files group out of range was returned."
			message "Trac issue 139"
                	myresult=FAIL
               else
               		message "Local provider files group with gidNumber above maxId not returned as expected."
               fi

		ssh root@$c "userdel -r myuser2000"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_008()
{
        myresult=PASS
        message "START $tet_thistest: Add legacy user with uidNumber below minId"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "useradd -u 999 myuser999"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Add legacy user failed. return code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss passwd | grep myuser999"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Local provider files user out of range was returned."
                                message "Trac issue 139"
                                myresult=FAIL
                        else
                                message "Local provider files user with uidNumber below minId not returned as expected."
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_009()
{
        myresult=PASS
        message "START $tet_thistest: Verify MPG of user with gidNumber below minId"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "getent -s sss group | grep myuser999"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Local provider files group out of range was returned."
                        message "Trac issue 139"
                        myresult=FAIL
               else
                        message "Local provider files group with gidNumber below minId not returned as expected."
               fi

		ssh root@$c "userdel -r myuser999"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_010()
{
        myresult=PASS
        message "START $tet_thistest: Add user within Allowed Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		ssh root@$c "useradd -u 1500 myuser1500"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Add legacy user failed. return code: $?"
                        myresult=FAIL
                fi 

                ssh root@$c "getent -s sss passwd | grep myuser1500"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Local provider files new user within range was not returned. return code: $?"
                        myresult=FAIL
               else
                        message "Local provider files user within ID range was returned as expected."
               fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_011()
{
        myresult=PASS
        message "START $tet_thistest: Add group within Allowed Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "groupadd -g 1600 group1600"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Add legacy group failed. return code: $?"
                        myresult=FAIL
                fi

                ssh root@$c "getent -s sss group | grep group1600"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Local provider files new group within range was not returned. return code: $?"
                        myresult=FAIL 
               else
                        message "Local provider files group within ID range was returned as expected."
               fi
        done

        result $myresult
        message "END $tet_thistest"
}


sssd_files_012()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "userdel myuser1500"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to delete local user. return code: $rc"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss passwd | grep myuser1500"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: myuser1500 deleted successfully, but getent still found the user."
                                myresult=FAIL
                        fi

			ssh root$c "getent -s sss group | grep myuser1500"
			if [ $? -eq 0 ] ; then 
				message "ERROR: myuser1500's MPG was still returned by getent."
				myresult=FAIL
			fi
                fi

                if [ $myresult == PASS ] ; then
			message "getent did not find the user" 
			message "getent did not find user's magic private group"
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_013()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local Group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "groupdel group1600"
		rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Failed to delete group1600. return code: $rc"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss group | grep group1600"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: group1600 deleted successfully, but getent still found the group."
                                myresult=FAIL
                        fi
                fi

                if [ $myresult == PASS ] ; then
			message "getent did not find the group."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

cleanup()
{
  myresult=PASS
  message "START $tet_this_test: Cleanup Clients"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        sssdClientCleanup $c 
        if [ $? -ne 0 ] ; then
                message "ERROR:  SSSD Client Cleanup did not complete successfully on client $c."
                myresult=FAIL
        fi

        ssh root@$c "yum -y erase sssd ; rm -rf /var/lib/sss/ ; rm -rf /etc/sssd/ ; yum clean all"
        if [ $? -ne 0 ] ; then
                message "ERROR: Failed to uninstall and cleanup SSSD. Return code: $?"
                myresult=FAIL
        else
                message "SSSD Uninstall and Cleanup Success."
        fi

  done

  result $myresult
  message "END $tet_this_test"
}

##################################################################
. $TESTING_SHARED/shared.ksh
. $TESTING_SHARED/sssdlib.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

#EOF

