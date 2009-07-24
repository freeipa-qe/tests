#!/bin/ksh

######################################################################
#  File: sssd.ksh - acceptance tests for SSSD
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic99"
ic0="startup"
ic1="sssd_001 sssd_002 sssd_003 sssd_004 sssd_005 sssd_006 sssd_007 sssd_008 sssd_009 sssd_010 sssd_011 sssd_012 sssd_013 sssd_014 sssd_015 sssd_016 sssd_017 sssd_018 sssd_019 sssd_020 sssd_021 sssd_022 sssd_023 sssd_024 sssd_025 sssd_026 sssd_027 sssd_028"
ic2="sssd_029 sssd_030 sssd_031 sssd_032 sssd_033 sssd_034 sssd_035"
ic3="sssd_036 sssd_037 sssd_038 sssd_039"
ic99="cleanup"
#################################################################
#  GLOBALS
#################################################################
#C1="jennyv2.bos.redhat.com"
C1="jennyv2.bos.redhat.com dhcp\-100\-2\-185.bos.redhat.com"
#C1="dhcp-100-2-185.bos.redhat.com"
SSSD_CLIENTS="$C1"
export SSSD_CLIENTS
DIRSERV="jennyv4.bos.redhat.com"
export DIRSERV
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
  message "START $tet_this_test: Setup for SSSD Local Domain Testing"
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
	sssdClientSetup $c
	if [ $? -ne 0 ] ; then
		message "ERROR: SSSD Client Setup Failed for $c."
		myresult=FAIL
	fi
  done
  tet_result $myresult
  message "END $tet_this_test"
}

sssd_001()
{
   ####################################################################
   #   Configuration 1
   #	enumerate: 3
   #	minId: 1000
   #	maxId: 1010
   #	legacy: FALSE
   #	magicPrivateGroups: TRUE
   #	provider: local
   ####################################################################

	myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 1"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
		message "Backing up original sssd.conf and copying over test sssd.conf"
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
		
		verifyCfg $c LOCAL enumerate 3
		if [ $? -ne 0 ] ; then
			myresult=FAIL
		fi

                verifyCfg $c LOCAL minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL legacy FALSE
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

	done

	result $myresult
	message "END $tet_thistest"
}

sssd_002()
{
        myresult=PASS
        message "START $tet_thistest: Add Local User within uidNumber Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	
        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
		ssh root@$c "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
		if [ $? -ne 0 ] ; then
			message "ERROR: Adding LOCAL domain user1000.  Return Code: $?"
			myresult=FAIL
		else
			ssh root@$c "getent -s sss passwd | grep user1000"
			if [ $? -ne 0 ] ; then
				message "ERROR: user1000:  getent failed to return LOCAL user.  Return Code: $?"
				myresult=FAIL
			else
				message "LOCAL domain user1000 added successfully."
			fi
		fi
	done

        result $myresult
        message "END $tet_thistest"
}

sssd_003()
{
        myresult=PASS
        message "START $tet_thistest: Modify Shell Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_usermod -s /bin/ksh user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modifying LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        SHELL=`ssh root@$c getent -s sss passwd | grep user1000 | cut -d : -f 7 | cut -d / -f 2`
                        if [ $SHELL -ne ksh ] ; then
                                message "ERROR: user1000: getent failed to return expected shell for LOCAL user.  Return Code: $?"
				message "Expected: ksh  Got: $SHELL"
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 default shell modified successfully."
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_004()
{
        myresult=PASS
        message "START $tet_thistest: Modify Home Directory Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_usermod -h /export/user1000 user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modifying LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
			HOMEDIR=`ssh root@$c getent -s sss passwd | grep user1000 | cut -d : -f 6 | cut -d / -f 2`
                        if [ $HOMEDIR -ne export ] ; then
                                message "ERROR: user1000: getent failed to return expected home directory for LOCAL user.  Return Code: $?"
                                message "Expected: export  Got: $SHELL"
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 home directory modified successfully."
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_005() 
{
        myresult=PASS
        message "START $tet_thistest: Modify Gecos Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_usermod -c \"User Thousand\" user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modifying LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        GECOS=`ssh root@$c getent -s sss passwd | grep user1000 | cut -d : -f 5`
                        if [[ $GECOS != "User Thousand" ]] ; then
                                message "ERROR: user1000: getent failed to return expected gecos comment for LOCAL user.  Return Code: $?"
                                message "Expected: User Thousand  Got: $GECOS"
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 gecos modified successfully."
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_006()
{
        myresult=PASS
        message "START $tet_thistest: Lock Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_usermod -L user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Locking LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        verifyAttr $c "name=user1000,cn=users,cn=LOCAL,cn=sysdb" disabled true
                        if [ $? -ne 0 ] ; then
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 is disabled."
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_007()
{
        myresult=PASS
        message "START $tet_thistest: Unlock Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_usermod -U user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Unlocking LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        verifyAttr $c "name=user1000,cn=users,cn=LOCAL,cn=sysdb" disabled false
                        if [ $? -ne 0 ] ; then
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 is no longer disabled."
                        fi
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_008()
{
        myresult=PASS
        message "START $tet_thistest: Add Duplicate Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXPMSG="The user user1000 already exists"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding Duplicate LOCAL user1000.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

		if [[ $EXPMSG != $MSG ]] ; then
			message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			myresult=FAIL
		else
			message "Adding duplicate user error message was as expected."
		fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_009()
{
        myresult=PASS
        message "START $tet_thistest: Add Duplicate Local uidNumber"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        EXPMSG="The uid number 1000 is already in use"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_useradd -u 1000 -h /home/user1002 -s /bin/bash user1002 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding Duplicate LOCAL uidNumber 1000.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding duplicate uidNumber error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}


sssd_010()
{
        myresult=PASS
        message "START $tet_thistest: Modify user that doesn't exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		EXPMSG="The user myuser does not exist"
                MSG=`ssh root@$c "sss_usermod -c \"User Thousand\" myuser 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Modifying LOCAL user that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Modifying user that doesn't exist error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_011()
{
        myresult=PASS
        message "START $tet_thistest: Delete user that doesn't exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		EXPMSG="The user myuser does not exist"
                MSG=`ssh root@$c "sss_userdel user1001 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Deleting LOCAL user that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Deleting user that doesn't exist error message was as expected."
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_012()
{
        myresult=PASS
        message "START $tet_thistest: Add user to group that doesn't exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		EXPMSG="The group mygroup does not exist"
                MSG=`ssh root@$c "sss_usermod -a mygroup user1000 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding LOCAL user to group that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding user to a group that doesn't exist error message was as expected."
                fi

        done

        result $myresult
        message "END $tet_thistest"
}


sssd_013()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local User within uidNumber Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_userdel user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss passwd | grep user1000"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: LOCAL domain user1000 still exists after successful delete operation."
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 deleted successfully."
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_014()
{
	################################################################################################################
	#  NOTE: if this test fails with Segmentation Fault return code 139 on the local machine and return code 255   #
	#  when executed via ssh like these tests - maybe regression of bug in sssd trac #86                           #
	#  bug description: sss_useradd: Segmentation Fault Trying to add user with uidNumber below minId              #
	################################################################################################################ 
        myresult=PASS
        message "START $tet_thistest: Add user with uidNumber below Allowed minId- User added to Legacy Local"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_useradd -u 999 -h /home/user999 -s /bin/bash user999"
		rc=$?	
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Adding user999 to Legacy Local.  Return Code: $rc"
                        myresult=FAIL
                else
			# verify user was not Added to LOCAL domain database
                        ssh root@$c ldbsearch -H /var/lib/sss/db/sssd.ldb -b "cn=Users,cn=LOCAL,cn=sysdb" | grep user999
                        if [ $? -eq 0 ] ; then
                                message "ERROR: User with uidNumber below minId was added to the LOCAL domain database."
                                myresult=FAIL
                        else
				# verify user was added to /etc/passwd
				ssh root@$c "cat /etc/passwd | grep user999"
				if [ $? -eq 0 ] ; then
                                	message "user999 added to /etc/passwd with uidNumber below minId successfully."
					ssh root@c$ "userdel -r user999"
					if [ $? -ne 0 ] ; then
						message "Failed to cleanup and delete legacy local user user999. Return Code: $?"
					fi
				else
					message "ERROR: user999 was not found in the /etc/passwd file as expected.  Return Code: $?"
					myresult=FAIL
				fi
                        fi	
                fi

	done

        result $myresult
        message "END $tet_thistest"

}

sssd_015()
{
        ################################################################################################################
        #  NOTE: if this test fails with Segmentation Fault return code 139 - maybe regression of bug in sssd trac #86 #
        #  bug description: sss_useradd: Segmentation Fault Trying to add user with uidNumber below minId              #
        ################################################################################################################
        myresult=PASS
        message "START $tet_thistest: Add user with uidNumber above Allowed maxId - User added to Legacy Local"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
		message "Working on $c"
                ssh root@$c "sss_useradd -u 1011 -h /home/user1011 -s /bin/bash user1011"
		rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Adding user1011 to Legacy Local.  Return Code: $rc"
                        myresult=FAIL
                else
                        # verify user was not Added to LOCAL domain database
                        ssh root@$c ldbsearch -H /var/lib/sss/db/sssd.ldb -b "cn=Users,cn=LOCAL,cn=sysdb" | grep user1011
                        if [ $? -eq 0 ] ; then
                                message "ERROR: User with uidNumber above maxId was added to the LOCAL domain database."
                                myresult=FAIL
                        else
                                # verify user was added to /etc/passwd
                                ssh root@$c "cat /etc/passwd | grep user1011"
                                if [ $? -eq 0 ] ; then
                                        message "user999 added to /etc/passwd with uidNumber above maxId successfully."
                                        ssh root@c$ "userdel -r user1011"
                                        if [ $? -ne 0 ] ; then
                                                message "Failed to cleanup and delete legacy local user user1011. Return Code: $?"
                                        fi
                                else
                                        message "ERROR: user1011 was not found in the /etc/passwd file as expected.  Return Code: $?"
                                        myresult=FAIL
                                fi
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_016()
{
        myresult=PASS
        message "START $tet_thistest: Add group with gidNumber in Allowed Range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		ssh root@$c "sss_groupadd -g 1010 group1010"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain group1010.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss group | grep group1010"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: group1010:  getent failed to return LOCAL group.  Return Code: $?"
                                myresult=FAIL
                        else
                                message "LOCAL domain group1010 added successfully."
 			fi
		fi                  
	done

	result $myresult
        message "END $tet_thistest"
}

sssd_017()
{
        myresult=PASS
        message "START $tet_thistest: Add group with gidNumber below Allowed minId- Group added to Legacy Local"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_groupadd -g 999 group999"
                rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Adding group999 to Legacy Local.  Return Code: $rc"
                        myresult=FAIL
                else
                        # verify group was not Added to LOCAL domain database
                        ssh root@$c ldbsearch -H /var/lib/sss/db/sssd.ldb -b "cn=groups,cn=LOCAL,cn=sysdb" | grep group999
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Group with gidNumber below minId was added to the LOCAL domain database."
                                myresult=FAIL
                        else
                                # verify group was added to /etc/group
                                ssh root@$c "cat /etc/group | grep group999"
                                if [ $? -eq 0 ] ; then
                                        message "group999 added to /etc/group with gidNumber below minId successfully."
                                        ssh root@$c "groupdel group999"
                                        if [ $? -ne 0 ] ; then
                                                message "Failed to cleanup and delete legacy local group group999. Return Code: $?"
                                        fi
                                else
                                        message "ERROR: group999 was not found in the /etc/group file as expected.  Return Code: $?"
                                        myresult=FAIL
                                fi
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_018()
{
        myresult=PASS
        message "START $tet_thistest: Add group with gidNumber above Allowed maxId- Group added to Legacy Local"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_groupadd -g 1011 group1011"
                rc=$?
                if [ $rc -ne 0 ] ; then
                        message "ERROR: Adding group1011 to Legacy Local.  Return Code: $rc"
                        myresult=FAIL
                else 
                        # verify group was not Added to LOCAL domain database
                        ssh root@$c ldbsearch -H /var/lib/sss/db/sssd.ldb -b "cn=groups,cn=LOCAL,cn=sysdb" | grep group1011
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Group with gidNumber below minId was added to the LOCAL domain database."
                                myresult=FAIL
                        else
                                # verify group was added to /etc/group
                                ssh root@$c "cat /etc/group | grep group1011"
                                if [ $? -eq 0 ] ; then
                                        message "group1011 added to /etc/group with gidNumber below minId successfully."
                                        ssh root@$c "groupdel group1011"
                                        if [ $? -ne 0 ] ; then
                                                message "Failed to cleanup and delete legacy local group group1011. Return Code: $?"
                                        fi
                                else
                                        message "ERROR: group1011 was not found in the /etc/group file as expected.  Return Code: $?"
                                        myresult=FAIL
                                fi
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_019()
{
        myresult=PASS
        message "START $tet_thistest: Add Duplicate Local Group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        EXPMSG="The group group1010 already exists"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_groupadd -g 1010 group1010 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding Duplicate LOCAL group1010.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding duplicate group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_020()
{
        myresult=PASS
        message "START $tet_thistest: Add Duplicate Local gidNumber"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        EXPMSG="The gid number 1010 is already in use"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_groupadd -g 1010 group1010 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding Duplicate LOCAL gidNumber 1010.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi 

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding duplicate gidNumber error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_021()
{
        myresult=PASS
        message "START $tet_thistest: Add non-existing group to a group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The group mygroup does not exist"
                MSG=`ssh root@$c "sss_groupmod -a mygroup group1009 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding non-existing group to LOCAL group.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding non-existant group to a group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_022()
{
        myresult=PASS
        message "START $tet_thistest: Add non-existing user to a group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The user myuser does not exist"
                MSG=`ssh root@$c "sss_usermod -a group1009 myuser 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding non-existing user to LOCAL group.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding non-existant user to a group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_023()
{
        myresult=PASS
        message "START $tet_thistest: Add nested group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                #Adding another group to add to first group
                ssh root@$c "sss_groupadd -g 1009 group1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain group1010.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c sss_groupmod -a group1009 group1010
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Failed to add nested group.  Return Code: $?"
                                myresult=FAIL
                        else
                                verifyAttr $c "name=group1009,cn=groups,cn=LOCAL,cn=sysdb" memberof "name=group1010,cn=groups,cn=LOCAL,cn=sysdb"
                                if [ $? -ne 0 ] ; then
					echo $?
                                        myresult=FAIL
                                else
                                        message "LOCAL domain group1009 member attribute is correct."
                                fi

                                verifyAttr $c "name=group1010,cn=groups,cn=LOCAL,cn=sysdb" member "name=group1009,cn=groups,cn=LOCAL,cn=sysdb"
                                if [ $? -ne 0 ] ; then
                                        myresult=FAIL
                                else
                                        message "LOCAL domain group1010 memberof attribute is correct."
                                fi
                        fi
                fi

        done

        result $myresult
        message "END $tet_thistest"

}

sssd_024()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local Group That has Nested Group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_groupdel group1010"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain group1010.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss group | grep group1010"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: LOCAL domain group1010 still exists after successful delete operation."
                                myresult=FAIL
                        else
                                message "LOCAL domain group1010 deleted successfully."
                        fi

			verifyAttr $c "name=group1009,cn=groups,cn=LOCAL,cn=sysdb" member "name=group1010,cn=groups,cn=LOCAL,cn=sysdb"
			if [ $? -eq 0 ] ; then
				message "ERROR: Parent group deleted, but child group still has member attribute defined."
				myresult=FAIL
			else
				message "Child group member attribute was removed."
			fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_025()
{
        myresult=PASS
        message "START $tet_thistest: Add user group member"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do 
                message "Working on $c"
                ssh root@$c "sss_useradd -u 1009 -h /home/user1009 -s /bin/bash user1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain user1009.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c sss_usermod -a group1009 user1009
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Failed to add user to group.  Return Code: $?"
                                myresult=FAIL
                        else
                                verifyAttr $c "name=user1009,cn=users,cn=LOCAL,cn=sysdb" memberof "name=group1009,cn=groups,cn=LOCAL,cn=sysdb"
                                if [ $? -ne 0 ] ; then
                                        myresult=FAIL
                                else
                                        message "LOCAL domain user1009 member attribute is correct."
                                fi

                                verifyAttr $c "name=group1009,cn=groups,cn=LOCAL,cn=sysdb" member "name=user1009,cn=users,cn=LOCAL,cn=sysdb"
                                if [ $? -ne 0 ] ; then
                                        myresult=FAIL
                                else
                                        message "LOCAL domain group1009 memberof attribute is correct."
                                fi
                        fi
                fi

        done

        result $myresult
        message "END $tet_thistest"
}


sssd_026()
{
        myresult=PASS
        message "START $tet_thistest: Delete Local Group That has User Member"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                ssh root@$c "sss_groupdel group1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain group1009.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss group | grep group1009"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: LOCAL domain group1009 still exists after successful delete operation."
                                myresult=FAIL
                        else
                                message "LOCAL domain group1009 deleted successfully."
                        fi

                        verifyAttr $c "name=user1009,cn=users,cn=LOCAL,cn=sysdb" member "name=group1009,cn=groups,cn=LOCAL,cn=sysdb"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Parent group deleted, but child group still has member attribute defined."
                                myresult=FAIL
                        else
                                message "Child group member attribute was removed."
                        fi
		fi

		#cleanup - delete the user added
                ssh root@$c "sss_userdel user1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain user1009.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$c "getent -s sss passwd | grep user1009"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: LOCAL domain user1009 still exists after successful delete operation."
                                myresult=FAIL
                        else
                                message "Test Cleanup: LOCAL domain user1009 deleted successfully."
                        fi
                fi

	done

        result $myresult
        message "END $tet_thistest"
}

sssd_027()
{
        myresult=PASS
        message "START $tet_thistest: Modify group that doesn't exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The group mygroup does not exist"
                MSG=`ssh root@$c "sss_groupmod -a group1009 mygroup 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Modifying LOCAL group that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Modifying group that doesn't exist error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_028()
{
        myresult=PASS
        message "START $tet_thistest: Delete group that doesn't exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                EXPMSG="The group mygroup does not exist"
                MSG=`ssh root@$c "sss_groupdel mygroup 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Deleting LOCAL group that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Deleting group that doesn't exist error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_029()
{
   ####################################################################
   #   Configuration 2
   #    enumerate: 1
   #    legacy: FALSE
   #	useFullyQualifiedNames TRUE
   #    provider: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 2"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $c sssd_local2.conf
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

                verifyCfg $c LOCAL enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi
  
                verifyCfg $c LOCAL legacy FALSE
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
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_030()
{
  myresult=PASS
  message "START $tet_this_test: User Fully Qualified Name"

  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
        if [ $? -ne 0 ] ; then
        	message "ERROR: Adding LOCAL domain user1000.  Return Code: $?"
                myresult=FAIL
        else
		ssh root@$c getent -s sss passwd | grep user1000@LOCAL
		if [ $? -ne 0 ] ; then
			message "ERROR: User not returned with fully qualified name."
			myresult=FAIL
		else
			message "User returned with fully qualified name as expected."
		fi
	fi 
  done

  result $myresult
  message "END $tet_thistest"

}

sssd_031()
{
  myresult=PASS
  message "START $tet_this_test: Add Group Fully Qualified Name"

  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "sss_groupadd -g 1000 group1000"
        if [ $? -ne 0 ] ; then
                message "ERROR: Adding LOCAL domain group1000.  Return Code: $?"
                myresult=FAIL
        else
                ssh root@$c getent -s sss group | grep group1000@LOCAL
                if [ $? -ne 0 ] ; then
                        message "ERROR: Group not returned with fully qualified name."
                        myresult=FAIL
                else
                        message "Group returned with fully qualified name as expected."
                fi
        fi
  done

  result $myresult
  message "END $tet_thistest"

}


sssd_032()
{
  myresult=PASS
  message "START $tet_this_test: Modify User Using Fully Qualified Name"
  
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        # add a user to sssd db
        ssh root@$c "sss_usermod  -c UserThousand user1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Modifying LOCAL domain user1000@LOCAL."
                myresult=FAIL
        else
                ssh root@$c getent -s sss passwd | grep user1000@LOCAL | grep UserThousand
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modification using Fully Qualified Name failed. Return code: $?"
                        myresult=FAIL
                else
                        message "User modification using fully qualified name was successful."
                fi
        fi
  done

  result $myresult
  message "END $tet_thistest"
}

sssd_033()
{
  myresult=PASS
  message "START $tet_this_test: Add user to group Using Fully Qualified Names"
  
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "sss_usermod  -a user1000@LOCAL group1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Adding user1000@LOCAL to group@LOCAL failed."
                myresult=FAIL
        else
                ssh root@$c getent -s sss group | grep user1000@LOCAL
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding user to group using Fully Qualified Name failed. Return code: $?"
                        myresult=FAIL
                else
                        message "User addition to group using fully qualified name was successful."
                fi
        fi
  done

  result $myresult
  message "END $tet_thistest"
}


sssd_034()
{
  myresult=PASS
  message "START $tet_this_test: Delete User Using Fully Qualified Name"
  
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "sss_userdel user1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Deleting LOCAL domain user1000@LOCAL."
                myresult=FAIL
        else
                ssh root@$c getent -s sss passwd | grep user1000@LOCAL
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deleting user using Fully Qualified Name failed. User still exists"
                        myresult=FAIL
			ssh root@$c "sss_userdel user1000"
                else
                        message "User deletion using fully qualified name was successful."
                fi
        fi
  done

  result $myresult
  message "END $tet_thistest"
}

sssd_035()
{
  myresult=PASS
  message "START $tet_this_test: Delete Group Using Fully Qualified Name"
  
  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "sss_groupdel group1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Deleting LOCAL domain group1000@LOCAL."
                myresult=FAIL
        else
                ssh root@$c getent -s sss group | grep group1000@LOCAL
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deleting group using Fully Qualified Name failed. Group still exists"
                        myresult=FAIL
                        ssh root@$c "sss_groupdel group1000"
                else
                        message "Group deletion using fully qualified name was successful."
                fi
        fi
  done

  result $myresult
  message "END $tet_thistest"
}

sssd_036()
{
   ####################################################################
   #   Configuration 3
   #    enumerate: 1
   #    minId: 1000
   #    maxId: 1010
   #    legacy: FALSE
   #    magicPrivateGroups: TRUE
   #    provider: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 2"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $c sssd_local3.conf
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

                verifyCfg $c LOCAL enumerate 1
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL legacy FALSE
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

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_037()
{
  myresult=PASS
  message "START $tet_this_test: Enumerate users only"

  for c in $SSSD_CLIENTS; do
        message "Working on $c"
        ssh root@$c "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
	ssh root@$c "sss_groupadd -g 1000 group1000"

	ssh root@$c getent -s sss passwd | grep user1000
        if [ $? -ne 0 ] ; then
                message "ERROR: Enumerate 1 should return the user added but did not."
                myresult=FAIL
        else
                message "User returned successfully with configuration enumerate set to 1."
        fi

        ssh root@$c getent -s sss group | grep group1000
        if [ $? -eq 0 ] ; then
                message "ERROR: Enumerate 1 should not return the group added but it did."
                myresult=FAIL
        else
                message "Group was not returned as expected with configuration enumerate set to 1."
        fi

  done

  result $myresult
  message "END $tet_thistest"
}

sssd_038()
{
   ####################################################################
   #   Configuration 4
   #    enumerate: 2
   #    minId: 1000
   #    maxId: 1010
   #    legacy: FALSE
   #    magicPrivateGroups: TRUE
   #    provider: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 4"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $c sssd_local4.conf
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

                verifyCfg $c LOCAL enumerate 2
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LOCAL legacy FALSE
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

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_039()
{
  myresult=PASS
  message "START $tet_this_test: Enumerate groups only"

  for c in $SSSD_CLIENTS; do
        message "Working on $c"

        ssh root@$c getent -s sss group | grep group1000
        if [ $? -ne 0 ] ; then
                message "ERROR: Enumerate 2 should return the group added but did not."
                myresult=FAIL
        else
                message "Group returned successfully with configuration enumerate set to 2."
        fi

        ssh root@$c getent -s sss passwd | grep user1000
        if [ $? -eq 0 ] ; then
                message "ERROR: Enumerate 2 should not return the user added but it did."
                myresult=FAIL
        else
                message "User was not returned as expected with configuration enumerate set to 2."
        fi

        ssh root@$c "sss_userdel user1000"
        ssh root@$c "sss_groupdel group1000"

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
		message "ERROR:  SSSD Client Cleanup did not complete successfully."
		myresult=FAIL
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
