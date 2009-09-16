#!/bin/sh

######################################################################
#  File: sssd_files.sh - acceptance tests for SSSD and Local files
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1"
ic0="startup"
ic1="sssd_files_001 sssd_files_002 sssd_files_003 sssd_files_004 sssd_files_005 sssd_files_006 sssd_files_007 sssd_files_008 sssd_files_009 sssd_files_010 sssd_files_011 sssd_files_012"
######################################################################
# Tests
######################################################################

startup()
{
        myresult=PASS
        message "START $tet_thistest: Configuration 1 - FILES - Max ID"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		# add local users for testing
		ssh root@$FULLHOSTNAME "useradd -u 999 user999 ; useradd -u 1000 user1000 ; useradd -u 1999 user1999 ; useradd -u 2000 user2000"
		if [ $? -ne 0 ] ; then
			message "ERROR: Failed to add legacy passwd file users with shadow utils. return code: $?"
			myresult=FAIL
		else
			message "Legacy passwd file users added successfully using shadow utils."
		fi
        done

        result $myresult
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_files1.conf
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

                verifyCfg $FULLHOSTNAME FILES enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME FILES maxId 1999
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME FILES provider files
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
  	message "START $tet_thistest: getent -s sss passwd returns passwd file users - default minId 1000"
	
  	for c in $CLIENTS; do
		eval_vars $c
        	message "Working on $FULLHOSTNAME"

		# search for users out of range
		for num in 999 2000 ; do
			ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user$num"
			if [ $? -eq 0 ] ; then
				message "ERROR: user$num returned and uid is out of allowed range"
				myresult=FAIL
			fi
		done

		# search for users in range
		for num in 1000 1999 ; do
                        ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user$num"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: user$num with uid in valid range was not returned."
                                myresult=FAIL
                        fi
		done

	done
	
	if [ $myresult == PASS ] ; then
		message "Only Local passwd file users with in valid range returned by getent -s sss"
	fi

        result $myresult
        message "END $tet_thistest"
}

sssd_files_003()
{
        myresult=PASS
        message "START $tet_thistest: getent -s sss group returns group file groups - default minId 1000"
        for c in $CLIENTS; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                # search for user's MPGs out of range
                for num in 999 2000 ; do
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep user$num"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: MPG user$num returned and gid is out of allowed range"
                                myresult=FAIL
                        fi
                done

                # search for user's MPGs in range
                for num in 1000 1999 ; do
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep user$num"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: MPG user$num with gid in valid range was not returned."
                                myresult=FAIL
                        fi
                done

        done

        if [ $myresult == PASS ] ; then
                message "Only Local group file groups within in valid range returned by getent"
        fi

        result $myresult
        message "END $tet_thistest"
}

sssd_files_004()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to add User with SSS Tools"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
		EXPMSG="Operation not allowed"
                MSG=`ssh root@$FULLHOSTNAME "sss_useradd -h /home/user1 -s /bin/bash user1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add user with SSS Tools with provider = files was successful, but expected to fail."
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "sss_userdel user1"
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                EXPMSG="Operation not allowed"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupadd group1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add group with SSS Tools with provider = files was successful, but expected to fail."
                        myresult=FAIL
                        ssh root@$FULLHOSTNAME "sss_groupdel group1"
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
   ####################################################################
   #   Configuration 2
   #    enumerate: TRUE
   #    minId = 500
   #    provider: files
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 2 - FILES - Min ID"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_files2.conf
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

                verifyCfg $FULLHOSTNAME FILES enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME FILES minId 500
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME FILES provider files
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_007()
{
        myresult=PASS
        message "START $tet_thistest: getent -s sss passwd returns passwd file users - minId 500 - no maxId"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                # search for users in range
                for num in 999 1000 1999 2000; do
                        ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user$num"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: user$num with uid in valid range was not returned."
                                myresult=FAIL
                        fi
                done

        if [ $myresult == PASS ] ; then
                message "Only Local passwd file users with in valid range returned by getent -s sss"
        fi


        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_008()
{
        myresult=PASS
        message "START $tet_thistest: getent -s sss passwd returns group file groups - minId 500 - no maxId"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                # search for user's MPGs in range
                for num in 999 1000 1999 2000; do
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep user$num"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: user's MPG user$num with gid in valid range was not returned."
                                myresult=FAIL
                        fi
                done

        	if [ $myresult == PASS ] ; then
                	message "Only Local group file groups with in valid range returned by getent -s sss"
        	fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_009()
{
        myresult=PASS
        message "START $tet_thistest: Add New Group within Allowed Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "groupadd -g 1600 group1600"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Add legacy group failed. return code: $?"
                        myresult=FAIL
                fi

		sleep 30

                ssh root@$FULLHOSTNAME "getent -s sss group | grep group1600"
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

sssd_files_010()
{
        myresult=PASS
        message "START $tet_thistest: Add New Group outside of Allowed Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "groupadd -g 400 group400"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Add legacy group failed. return code: $?"
                        myresult=FAIL
                fi

		sleep 30

                ssh root@$FULLHOSTNAME "getent -s sss group | grep group400"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Local provider files new group outside of range was returned."
                        myresult=FAIL
               else
                        message "Local provider files group outside of ID range was not returned as expected."
               fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_011()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local Users"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "userdel -r user999 ; userdel -r user1000; userdel -r user1999 ; userdel -r user2000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to delete local user. return code: $rc"
                        myresult=FAIL
                else
			sleep 10
			for num in 999 1000 1999 2000 ; do
                        	ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user$num"
                        	if [ $? -eq 0 ] ; then
                                	message "ERROR: user$num deleted successfully, but getent still found the user."
					message "Trac issue 160"
                                	myresult=FAIL
                        	fi

				ssh root$FULLHOSTNAME "getent -s sss group | grep user$num"
				if [ $? -eq 0 ] ; then 
					message "ERROR: user$num's MPG was still returned by getent."
					myresult=FAIL
				fi
			done
                fi

                if [ $myresult == PASS ] ; then
			message "getent did not find the deleted users" 
			message "getent did not find deleted user's magic private group"
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_012()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local Group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "groupdel group1600 ; groupdel group400"
		rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Failed to delete groups with shadow utils. return code: $rc"
                        myresult=FAIL
                else
			sleep 2
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep group1600"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: group1600 deleted successfully, but getent still found the group."
				message "Trac issue 160"
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

##################################################################
. $TESTING_SHARED/shared.sh
. $TESTING_SHARED/sssdlib.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF

