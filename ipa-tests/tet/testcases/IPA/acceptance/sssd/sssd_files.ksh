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
ic1="sssd_files_001 sssd_files_002 sssd_files_003 sssd_files_006 sssd_files_007 sssd_files_008 sssd_files_009"
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
   #    enumerate: 3
   # 	minId = 1000
   #    maxId = 1999
   #    magicPrivateGroups: TRUE
   #    provider: files
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 1 - FILES - Min and max ID"
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

                verifyCfg $c FILES enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c FILES minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c FILES maxId 1999
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c FILES magicPrivateGroups TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c FILES provider proxy
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
  	message "START $tet_thistest: getent -s files passwd returns passwd file users"
  	for c in $SSSD_CLIENTS; do
        	message "Working on $c"
		TMPFILE=$TET_TMP_DIR/localusers
		sftp root@$c:/etc/passwd $TET_TMP_DIR/passwd
		ssh root@$c "getent -s files passwd" > $TMPFILE
		diff $TET_TMP_DIR/passwd $TMPFILE
		if [ $? -ne 0 ] ; then
			message "ERROR: Legacy Local user returned by getent did not match /etc/passwd file"
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
        message "START $tet_thistest: getent -s files group returns group file groups"
        for c in $SSSD_CLIENTS; do
                message "Working on $c"
		TMPFILE=$TET_TMP_DIR/localgroup
                sftp root@$c:/etc/group $TET_TMP_DIR/group
                ssh root@$c "getent -s files group" > $TMPFILE
                diff $TET_TMP_DIR/group $TMPFILE
                if [ $? -ne 0 ] ; then
                        message "ERROR: Legacy Local group returned by getent did not match /etc/group file"
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
        message "START $tet_thistest: Add user no uidNumber defined - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
		EXPMSG="The selected UID is outside all domain ranges"
                MSG=`ssh root@$c "sss_useradd -h /home/user1 -s /bin/bash user1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add user without uidNumber defined was successful but expected to fail."
                        myresult=FAIL
			ssh root@$c "sss_userdel user1"
		fi

		if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
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
        message "START $tet_thistest: Add group no gidNumber defined - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		EXPMSG="The selected GID is outside all domain ranges"
                MSG=`ssh root@$c "sss_groupadd group1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add group without gidNumber defined was successful but expected to fail."
                        myresult=FAIL
                        ssh root@$c "sss_groupdel group1"
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding group failed with expected error message."
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_006()
{
        myresult=PASS
        message "START $tet_thistest: Add user uidNumber below minId - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		EXPMSG="The selected UID is outside all domain ranges"
                MSG=`ssh root@$c "sss_useradd -u 999 -h /home/user999 -s /bin/bash user999 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add user with uidNumber below minId was successful but expected to fail."
                        myresult=FAIL
                        ssh root@$c "sss_userdel group999"
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding user with uidNumber below minId failed with expected error message."
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_007()
{
        myresult=PASS
        message "START $tet_thistest: Add user uidNumber above maxId - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The selected UID is outside all domain ranges"
                MSG=`ssh root@$c "sss_useradd -u 2000 -h /home/user2000 -s /bin/bash user2000 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add user with uidNumber above maxId was successful but expected to fail."
                        myresult=FAIL
                        ssh root@$c "sss_userdel user2000"
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding user with uidNumber above maxId failed with expected error message."
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_008()
{
        myresult=PASS
        message "START $tet_thistest: Add group gidNumber below minId - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The selected GID is outside all domain ranges"
                MSG=`ssh root@$c "sss_groupadd -g 999 group999 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add group with gidNumber below minId was successful but expected to fail."
                        myresult=FAIL
                        ssh root@$c "sss_groupdel group999"
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding group with gidNumber below minId failed with expected error message."
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_009()
{
        myresult=PASS
        message "START $tet_thistest: Add group gidNumber above maxId - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The selected GID is outside all domain ranges"
                MSG=`ssh root@$c "sss_groupadd -g 2000 group2000 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Add group with gidNumber above maxId was successful but expected to fail."
                        myresult=FAIL
                        ssh root@$c "sss_groupdel group2000"
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding group with gidNumber above maxId failed with expected error message."
                fi

        done

        result $myresult
        message "END $tet_thistest" 
}

sssd_files_010()
{
        myresult=PASS
        message "START $tet_thistest: Add user uidNumber defined - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to add user1000. return code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s files passwd | grep user1000"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: user1000 added successfully, but getent failed to find the user. return code: $?"
                                myresult=FAIL
                        fi

                        ssh root@$c "cat /etc/passwd | grep user1000"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: user1000 added successfully, but was not added to the passwd file."
                                myresult=FAIL
                        fi
                fi

                if [ $myresult == PASS ] ; then
                        message "user1000 added to legacy passwd file successfully and getent found the user."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_011()
{
        myresult=PASS
        message "START $tet_thistest: Verify User's Magic Group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		ssh root@$c "getent -s files group | grep user1000"
		if [ $? -ne 0 ] ; then
			message "ERROR: getent failed to return user's magic group"
			myresult=FAIL
		fi

		ssh root@$c "cat /etc/group | grep user1000"
		if [ $? -ne 0 ] ; then
			message "ERROR: user's magic group not found in the legacy group file"	
			myresult=FAIL
		fi

		if [ $myresult == PASS ] ; then
			message "User's magic group found in the legacy group file and getent found the group."
		fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_files_012()
{
        myresult=PASS
        message "START $tet_thistest: Add group gidNumber already used - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		EXPMSG="groupadd: GID 1000 is not unique Cannot add group to domain using the legacy tools"
                MSG=`ssh root@$c "sss_groupadd -g 1000 group1000 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding group with unique Id already in user was successful."
                        myresult=FAIL
			ssh root@$c "sss_groupdel group1000"
                fi
		
		 MSG=`echo $MSG`
                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding group with Id aleady in use failed with expected error message."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_013()
{
        myresult=PASS
        message "START $tet_thistest: Add group unique gidNumber - Range Defined"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_groupadd -g 1001 group1001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to add group1001. return code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s files group | grep group1001"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: group1001 added successfully, but getent failed to find the group. return code: $?"
                                myresult=FAIL
                        fi

                        ssh root@$c "cat /etc/group | grep group1001"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: group1001 added successfully, but was not added to the group file."
                                myresult=FAIL
                        fi
                fi

                if [ $myresult == PASS ] ; then
                        message "group1001 added to legacy group file successfully and getent found the group."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_014()
{
        myresult=PASS
        message "START $tet_thistest: Delete User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_userdel user1000"
		rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Failed to delete user1000. return code: $rc"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s files passwd | grep user1000"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: user1000 deleted successfully, but getent still found the user."
                                myresult=FAIL
                        fi

                        ssh root@$c "cat /etc/passwd | grep user1000"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: user1000 deleted successfully, but still exists in the passwd file."
                                myresult=FAIL
                        fi

			ssh root@$c "cat /etc/group | grep user1000"
			if [ $? -eq 0 ] ; then
				message "ERROR: user1000 deleted but user's magic private group still exists."
			fi
                fi

                if [ $myresult == PASS ] ; then
                        message "user1000 removed from legacy passwd file successfully" 
			message "getent did not find the user" 
			message "user's magic private group was removed."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_015()
{
        myresult=PASS
        message "START $tet_thistest: Delete group - provider FILES"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_groupdel group1001"
		rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Failed to delete group1001. return code: $rc"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s files group | grep group1001"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: group1001 deleted successfully, but getent still found the group."
                                myresult=FAIL
                        fi

                        ssh root@$c "cat /etc/group | grep group1001"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: group1000 deleted successfully, but still exists in the group file."
                                myresult=FAIL
                        fi
                fi

                if [ $myresult == PASS ] ; then
                        message "group1000 removed from legacy group file successfully"
			message "getent did not find the group."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_016()
{
        myresult=PASS
        message "START $tet_thistest: Delete user added with shadow utils - uid in range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "useradd -u 1000 myuser"
		MSG=`ssh root@$c "sss_userdel myuser 2>&1"`
                rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Failed to delete userdel. return code: $rc"
                        myresult=FAIL
		else
			message "user deleted successfully."
                fi

                ssh root@$c "getent -s files passwd | grep myuser"
                if [ $? -eq 0 ] ; then
                	message "ERROR: getent still found the user."
                        myresult=FAIL
		else
			message "getent did not find the user"
                fi

                ssh root@$c "cat /etc/group | grep myuser"
                if [ $? -eq 0 ] ; then
             	   message "ERROR: user's private group still exists in the group file."
                   myresult=FAIL
		else
			message "User's private group was removed"
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_files_017()
{
        myresult=PASS
        message "START $tet_thistest: Delete user added with shadow utils - uid out of range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "useradd -u 2000 myuser" 
                MSG=`ssh root@$c "sss_userdel myuser 2>&1"`
                rc=$?
                if [ $rc -ne 0 ] ; then 
                        message "ERROR: Failed to delete userdel. return code: $rc"
                        myresult=FAIL
		else
			message "user deleted successfully"
                fi

                ssh root@$c "getent -s files passwd | grep myuser"
                if [ $? -eq 0 ] ; then
                        message "ERROR: getent still found the user."
                        myresult=FAIL
		else
			message "getent did not return user"
                fi

                ssh root@$c "cat /etc/group | grep myuser"
                if [ $? -eq 0 ] ; then
                	message "ERROR: user's private group still exists in the group file."
                	myresult=FAIL
		else
			message "User's private group was removed"
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

