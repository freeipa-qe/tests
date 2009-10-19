#!/bin/sh

######################################################################
#  File: sssd.ksh - acceptance tests for SSSD
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic1 ic2 ic3 ic4 ic5"
ic1="sssd_001 sssd_002 sssd_003 sssd_004 sssd_005 sssd_006 sssd_007 sssd_008 sssd_009 sssd_010 sssd_011 sssd_012 sssd_013 sssd_014 sssd_015 sssd_016 sssd_017 sssd_018 sssd_019 sssd_020 sssd_021 sssd_022 sssd_023 sssd_024 sssd_025 sssd_026 sssd_027 sssd_028"
ic2="sssd_029 sssd_030 sssd_031 sssd_032 sssd_033 sssd_034 sssd_035"
ic3="sssd_036 sssd_037"
ic4="sssd_040 sssd_041 sssd_042 sssd_043 sssd_044 sssd_045 sssd_046"
ic5="sssd_047 sssd_049 sssd_050 sssd_051 sssd_052 sssd_053 sssd_054 sssd_055 sssd_056 sssd_057 sssd_058 sssd_059 sssd_060 sssd_061"
#####################################################################
# Globals
####################################################################
HOMEDIR="$TET_ROOT/testcases/IPA/acceptance/sssd"
USEFQN="use_fully_qualified_names"
MPG="magic_private_groups"
PROVIDER="id_provider"
MAXID="max_id"
MINID="min_id"
SSSDCFG="/etc/sssd/sssd.conf"
######################################################################
# Tests
######################################################################

sssd_001()
{
   ####################################################################
   #   Configuration 1
   #	enumerate: TRUE
   #	$MINID: 1000
   #	$MAXID: 1010
   #	$MPG: TRUE
   #	$PROVIDER: local
   ####################################################################

	myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 1"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
		message "Backing up original sssd.conf and copying over test sssd.conf"
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
		
		verifyCfg $FULLHOSTNAME LOCAL enumerate TRUE
		if [ $? -ne 0 ] ; then
			myresult=FAIL
		fi

                verifyCfg $FULLHOSTNAME LOCAL $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MAXID 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MPG TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $PROVIDER local
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
	
        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
		
		if [ $? -ne 0 ] ; then
			message "ERROR: Adding LOCAL domain user1000.  Return Code: $?"
			myresult=FAIL
		else
			ssh root@$FULLHOSTNAME "getent -s sss passwd user1000"
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
	EXP="/bin/ksh"
        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_usermod -s /bin/ksh user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modifying LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        #SHELL=`ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user1000 | cut -d : -f 7 | cut -d / -f 2"`
			SHELL=`ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user1000 | cut -d : -f 7"`
                        if [ "$SHELL" != "$EXP" ] ; then
                                message "ERROR: user1000: getent failed to return expected shell for LOCAL user.  Return Code: $?"
				message "Expected: $EXP  Got: $SHELL"
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

        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_usermod -h /export/user1000 user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modifying LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
			HOMEDIR=`ssh root@$FULLHOSTNAME getent -s sss passwd | grep user1000 | cut -d : -f 6 | cut -d / -f 2`
                        if [ $HOMEDIR != "export" ] ; then
                                message "ERROR: user1000: getent failed to return expected home directory for LOCAL user.  Return Code: $?"
                                message "Expected: export  Got: $HOMEDIR"
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

        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_usermod -c \"User Thousand\" user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Modifying LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        GECOS=`ssh root@$FULLHOSTNAME getent -s sss passwd | grep user1000 | cut -d : -f 5`
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

        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_usermod -L user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Locking LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        verifyAttr $FULLHOSTNAME "name=user1000,cn=users,cn=LOCAL,cn=sysdb" disabled true
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

        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_usermod -U user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Unlocking LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        verifyAttr $FULLHOSTNAME "name=user1000,cn=users,cn=LOCAL,cn=sysdb" disabled false
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
	EXPMSG="A user or group with the same name or ID already exists"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_useradd -u 1010 -h /home/user1000 -s /bin/bash user1000 2>&1"`
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
        EXPMSG="A user or group with the same name or ID already exists"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_useradd -u 1000 -h /home/user1002 -s /bin/bash user1002 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Adding Duplicate LOCAL uidNumber 1000.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "sss_userdel user1002"
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

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		EXPMSG="Cannot find user in local domain, modifying users is allowed only in local domain"
                MSG=`ssh root@$FULLHOSTNAME "sss_usermod -c \"User Thousand\" myuser 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Modifying LOCAL user that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 100"
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

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		EXPMSG="No such user in local domain. Removing users only allowed in local domain."
                MSG=`ssh root@$FULLHOSTNAME "sss_userdel user1001 2>&1"`
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

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		EXPMSG="Cannot find group mygroup in local domain, only groups in local domain are allowed"
                MSG=`ssh root@$FULLHOSTNAME "sss_usermod -a mygroup user1000 2>&1"`
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
        message "START $tet_thistest: Delete Local User"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_userdel user1000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain user1000.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user1000"
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
	#  bug description: sss_useradd: Segmentation Fault Trying to add user with uidNumber below $MINID              #
	################################################################################################################ 
        myresult=PASS
        message "START $tet_thistest: Add user with uidNumber below Allowed $MINID"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXPMSG="The selected UID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_useradd -u 999 -h /home/user999 -s /bin/bash user999 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding user999 with uid below $MINID was successful."
                        myresult=FAIL
                fi
 
                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding user with uid below $MINID error message was as expected."
                fi
	done

        result $myresult
        message "END $tet_thistest"

}

sssd_015()
{
        ################################################################################################################
        #  NOTE: if this test fails with Segmentation Fault return code 139 - maybe regression of bug in sssd trac #86 #
        #  bug description: sss_useradd: Segmentation Fault Trying to add user with uidNumber below $MINID              #
        ################################################################################################################
        myresult=PASS
        message "START $tet_thistest: Add user with uidNumber above Allowed $MAXID - User added to Legacy Local"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXPMSG="The selected UID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
		message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_useradd -u 1011 -h /home/user1011 -s /bin/bash user1011 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding user1011 with uid above $MAXID was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding user with uid above $MAXID error message was as expected."
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

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "sss_groupadd -g 1010 group1010"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain group1010.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep group1010"
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
        message "START $tet_thistest: Add group with gidNumber below Allowed $MINID"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXPMSG="The selected GID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupadd -g 999 group999 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding group999 with gid below $MINID was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding group with gid below $MINID error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_018()
{
        myresult=PASS
        message "START $tet_thistest: Add group with gidNumber above Allowed $MAXID"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXPMSG="The selected GID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupadd -g 1011 group1011 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding group1011 with gid above $MAXID was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding group with gid above $MAXID error message was as expected."
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
        EXPMSG="A group with the same name or GID already exists"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupadd -g 1001 group1010 2>&1"`
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
        EXPMSG="A group with the same name or GID already exists"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupadd -g 1010 group1010 2>&1"`
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                EXPMSG="Cannot find group in local domain, modifying groups is allowed only in local domain"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupmod -a mygroup group1009 2>&1"`
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                EXPMSG="Cannot find user in local domain, modifying users is allowed only in local domain"
                MSG=`ssh root@$FULLHOSTNAME "sss_usermod -a group1009 myuser 2>&1"`
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                #Adding another group to add to first group
                ssh root@$FULLHOSTNAME "sss_groupadd -g 1009 group1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain group1010.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME sss_groupmod -a group1009 group1010
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Failed to add nested group.  Return Code: $?"
                                myresult=FAIL
                        else

                        	verifyAttr $FULLHOSTNAME "name=group1009,cn=groups,cn=LOCAL,cn=sysdb" member "name=group1010,cn=groups,cn=LOCAL,cn=sysdb"
                        	if [ $? -ne 0 ] ; then
                        		myresult=FAIL
                        	else
                                	message "LOCAL domain group1009 member attribute is correct."
                        	fi

				verifyAttr $FULLHOSTNAME "name=group1010,cn=groups,cn=LOCAL,cn=sysdb" memberof "name=group1009,cn=groups,cn=LOCAL,cn=sysdb"
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_groupdel group1010"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain group1010.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep group1010"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: LOCAL domain group1010 still exists after successful delete operation."
                                myresult=FAIL
                        else
                                message "LOCAL domain group1010 deleted successfully."
                        fi

			verifyAttr $FULLHOSTNAME "name=group1009,cn=groups,cn=LOCAL,cn=sysdb" memberof "name=group1010,cn=groups,cn=LOCAL,cn=sysdb"
			if [ $? -eq 0 ] ; then
				message "ERROR: Parent group deleted, but child group still has member attribute defined."
				myresult=FAIL
			else
				message "Child group memberof attribute was removed."
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
        for c in $CLIENTS ; do 
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_useradd -u 1009 -h /home/user1009 -s /bin/bash user1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain user1009.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME sss_usermod -a group1009 user1009
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Failed to add user to group.  Return Code: $?"
                                myresult=FAIL
                        else
                                verifyAttr $FULLHOSTNAME "name=user1009,cn=users,cn=LOCAL,cn=sysdb" memberof "name=group1009,cn=groups,cn=LOCAL,cn=sysdb"
                                if [ $? -ne 0 ] ; then
                                        myresult=FAIL
                                else
                                        message "LOCAL domain user1009 member attribute is correct."
                                fi

                                verifyAttr $FULLHOSTNAME "name=group1009,cn=groups,cn=LOCAL,cn=sysdb" member "name=user1009,cn=users,cn=LOCAL,cn=sysdb"
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_groupdel group1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain group1009.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME "getent -s sss group | grep group1009"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: LOCAL domain group1009 still exists after successful delete operation."
                                myresult=FAIL
                        else
                                message "LOCAL domain group1009 deleted successfully."
                        fi

                        verifyAttr $FULLHOSTNAME "name=user1009,cn=users,cn=LOCAL,cn=sysdb" memberof "name=group1009,cn=groups,cn=LOCAL,cn=sysdb"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Parent group deleted, but user group member still has memberof attribute defined."
                                myresult=FAIL
                        else
                                message "Child group member attribute was removed."
                        fi
		fi

		#cleanup - delete the user added
                ssh root@$FULLHOSTNAME "sss_userdel user1009"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Deleting LOCAL domain user1009.  Return Code: $?"
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user1009"
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                EXPMSG="Cannot find group in local domain, modifying groups is allowed only in local domain"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupmod -a group1009 mygroup 2>&1"`
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
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                EXPMSG="No such group in local domain. Removing groups only allowed in local domain."
                MSG=`ssh root@$FULLHOSTNAME "sss_groupdel mygroup 2>&1"`
                if [ $? -ne 1 ] ; then
                        message "ERROR: Deleting LOCAL group that doesn't exist.  Unexpected return code. Expected: 1  Got: $?"
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 136"
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
   #    enumerate: TRUE
   #	$USEFQN TRUE
   #    $PROVIDER: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 2"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_local2.conf
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

                verifyCfg $FULLHOSTNAME LOCAL enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MAXID 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi
  
                verifyCfg $FULLHOSTNAME LOCAL $PROVIDER local
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MPG TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $USEFQN TRUE
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
  message "START $tet_thistest: User Fully Qualified Name"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        ssh root@$FULLHOSTNAME "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
	RC=$?
        if [ $RC -ne 0 ] ; then
        	message "ERROR: Adding LOCAL domain user1000.  Return Code: $?"
                myresult=FAIL
        else
		ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user1000@LOCAL"
		RC=$?
		if [ $RC -ne 0 ] ; then
			message "ERROR: User not returned with fully qualified name. return code: $RC"
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
  message "START $tet_thistest: Add Group Fully Qualified Name"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        ssh root@$FULLHOSTNAME "sss_groupadd -g 1000 group1000"
        if [ $? -ne 0 ] ; then
                message "ERROR: Adding LOCAL domain group1000.  Return Code: $?"
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME "getent -s sss group | grep group1000@LOCAL"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Group not returned with fully qualified name. return code: $?"
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
  message "START $tet_thistest: Modify User Using Fully Qualified Name"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        # add a user to sssd db
        ssh root@$FULLHOSTNAME "sss_usermod  -c UserThousand user1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Modifying LOCAL domain user1000@LOCAL."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME getent -s sss passwd | grep user1000@LOCAL | grep UserThousand
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
  message "START $tet_thistest: Add user to group Using Fully Qualified Names"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
	ERRMSG="Could not modify user - check if group names are correct"
        MSG=`ssh root@$FULLHOSTNAME "sss_usermod -a group1000@LOCAL user1000@LOCAL 2>&1"`
        if [ $? -ne 0 ] ; then
                message "ERROR: Adding user1000@LOCAL to group1000@LOCAL failed."
                myresult=FAIL
                if [[ $ERRMSG == $MSG ]] ; then
                        message "ERROR: Got: $MSG - might be regression of trac issue 121"
                fi
        else
                ssh root@$FULLHOSTNAME getent -s sss group | grep user1000@LOCAL
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
  message "START $tet_thistest: Delete User Using Fully Qualified Name"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        ssh root@$FULLHOSTNAME "sss_userdel user1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Deleting LOCAL domain user1000@LOCAL."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME getent -s sss passwd | grep user1000@LOCAL
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deleting user using Fully Qualified Name failed. User still exists"
                        myresult=FAIL
			ssh root@$FULLHOSTNAME "sss_userdel user1000"
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
  message "START $tet_thistest: Delete Group Using Fully Qualified Name"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        ssh root@$FULLHOSTNAME "sss_groupdel group1000@LOCAL"
        if [ $? -ne 0 ] ; then
                message "ERROR: Deleting LOCAL domain group1000@LOCAL."
                myresult=FAIL
        else
                ssh root@$FULLHOSTNAME getent -s sss group | grep group1000@LOCAL
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deleting group using Fully Qualified Name failed. Group still exists"
                        myresult=FAIL
                        ssh root@$FULLHOSTNAME "sss_groupdel group1000"
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
   #    enumerate: FALSE
   #    $MINID: 1000
   #    $MAXID: 1010
   #    $MPG: TRUE
   #    $PROVIDER: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 3"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_local3.conf
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

                verifyCfg $FULLHOSTNAME LOCAL enumerate FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MAXID 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MPG TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $PROVIDER local
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
  message "START $tet_thistest: Enumerate users only"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        ssh root@$FULLHOSTNAME "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
	ssh root@$FULLHOSTNAME "sss_groupadd -g 1000 group1000"

	ssh root@$FULLHOSTNAME getent -s sss passwd | grep user1000
        if [ $? -eq 0 ] ; then
                message "ERROR: Enumerate FALSE should not return the user added but it did."
                myresult=FAIL
        else
                message "User was not returned as expected with configuration enumerate set to FALSE."
        fi

        ssh root@$FULLHOSTNAME getent -s sss group | grep group1000
        if [ $? -eq 0 ] ; then
                message "ERROR: Enumerate FALSE should not return the group added but it did."
                myresult=FAIL
        else
                message "Group was not returned as expected with configuration enumerate set to FALSE."
        fi

  done

  result $myresult
  message "END $tet_thistest"
}

#######################################################################################################
# Enumeration has been changed to boolean TRUE = enumeration users and groups, FALSE = enumerate
# users only.  This means tests 38 and 39 are now invalid
#######################################################################################################
sssd_038()
{
   ####################################################################
   #   Configuration 4
   #    enumerate: 2
   #    $MINID: 1000
   #    $MAXID: 1010
   #    $MPG: TRUE
   #    $PROVIDER: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 4"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_local4.conf
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

                verifyCfg $FULLHOSTNAME LOCAL enumerate 2
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MAXID 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MPG TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $PROVIDER local
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
  message "START $tet_thistest: Enumerate groups only"
  if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"

        ssh root@$FULLHOSTNAME getent -s sss group | grep group1000
        if [ $? -ne 0 ] ; then
                message "ERROR: Enumerate 2 should return the group added but did not."
                myresult=FAIL
        else
                message "Group returned successfully with configuration enumerate set to 2."
        fi

        ssh root@$FULLHOSTNAME getent -s sss passwd | grep user1000
        if [ $? -eq 0 ] ; then
                message "ERROR: Enumerate 2 should not return the user added but it did."
                myresult=FAIL
        else
                message "Group was not returned as expected with configuration enumerate set to 2."
        fi

        ssh root@$FULLHOSTNAME "sss_userdel user1000"
        ssh root@$FULLHOSTNAME "sss_groupdel group1000"

  done

  result $myresult
  message "END $tet_thistest"
}

sssd_040()
{
   ####################################################################
   #   Configuration 5
   #    enumerate: TRUE
   #    $MINID: 2000
   # 	$MAXID: 2010
   #    legacy: TRUE
   #    $MPG: TRUE
   #    $PROVIDER: local
   #	[user_defaults]
   #	defaultShell = /bin/sh
   #    baseDirectory = /export 
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 5"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_local5.conf
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

                verifyCfg $FULLHOSTNAME LOCAL enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MINID 2000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MAXID 2010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MPG TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $PROVIDER local
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_041()
{
        myresult=PASS
        message "START $tet_thistest: Add Local User - User Default Shell Not Specified"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXP="/bin/sh"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_useradd -u 2000 -h /home/user2000 user2000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain user2000.  Return Code: $?"
                        myresult=FAIL
                else
                        SHELL=`ssh root@$FULLHOSTNAME getent -s sss passwd | grep user2000 | cut -d : -f 7`
			message "Shell returned is $SHELL"
                        if [ "$SHELL" != "$EXP" ] ; then
                                message "ERROR: user2000: getent failed to return expected shell for LOCAL user.  Return Code: $?"
                                message "Expected: $EXP  Got: $SHELL"
                                myresult=FAIL
                        else
                                message "LOCAL domain user2000 default shell is correct."
                        fi

                fi

	        # delete the user added
        	ssh root@$FULLHOSTNAME "sss_userdel user2000"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_042()
{
        myresult=PASS
        message "START $tet_thistest: Add Local User - User Home Directory Not Specified"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                ssh root@$FULLHOSTNAME "sss_useradd -u 2000 user2000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain user2000.  Return Code: $?"
                        myresult=FAIL
                else
                        HOMEDIR=`ssh root@$FULLHOSTNAME getent -s sss passwd | grep user2000 | cut -d : -f 6 | cut -d / -f 2`
			message "Base Home Directory returned is $HOMEDIR"
                        if [ $HOMEDIR != export ] ; then
                                message "ERROR: user2000: getent failed to return expected home directory for LOCAL user.  Return Code: $?"
                                message "Expected: export  Got: $HOMEDIR"
                                myresult=FAIL
                        else
                                message "LOCAL domain user2000 home directory is correct."
                        fi

                fi

        	#delete the user added
        	ssh root@$FULLHOSTNAME "sss_userdel user2000"

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_043()
{
        myresult=PASS
        message "START $tet_thistest: Add Local Users - No uidNumber Specified - use up allowed uidNumbers"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		i=2000
		while [ $i -le 2010 ] ; do
			ssh root@$FULLHOSTNAME "sss_useradd user$i"
			rc=$?
			if [ $rc -ne 0 ] ; then
				message "ERROR: Failed to add LOCAL user$i.  Return Code: $rc"
				myresult=FAIL
			else
                        	UIDNUM=`ssh root@$FULLHOSTNAME getent -s sss passwd | grep user$i | cut -d : -f 3`
                        	if [ $UIDNUM -ne $i ] ; then
                                	message "ERROR: user$i: getent failed to return expected uidNumber for LOCAL user.  Expected: $i  Got: $UIDNUM"
                                	myresult=FAIL
                        	else
                                	message "LOCAL domain user$i uidNumber is correct."
                        	fi

			fi
			let i=$i+1
		done

		# try to add one more user that should fail because no more allowed uidNumbers
               	EXPMSG="Failed to allocate new id, out of range"
                MSG=`ssh root@$FULLHOSTNAME "sss_useradd user2011 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding LOCAL user was expected to fail no more allowed uidNumbers, but was successful."
                        myresult=FAIL
                fi

		echo $MSG | grep "$EXPMSG"
		if [ $? -ne 0 ] ; then
                #if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Adding LOCAL user failed as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_044()
{
        myresult=PASS
        message "START $tet_thistest: Add Local Groups - No gidNumber Specified - $MPG - Shared ID Space"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                i=2000
                while [ $i -le 2010 ] ; do
			EXPMSG="Failed to allocate new id, out of range"
                        MSG=`ssh root@$FULLHOSTNAME "sss_groupadd group$i 2>&1"`
	                if [ $? -eq 0 ] ; then
        	                message "ERROR: Adding LOCAL group was expected to fail no more allowed gidNumbers, but was successful."
                	        myresult=FAIL
				ssh root@$FULLHOSTNAME "sss_groupdel group$i"
               	 	fi

                	echo $MSG | grep "$EXPMSG"
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        	myresult=FAIL
                	else
                        	message "Adding LOCAL group failed as expected."
                	fi

                        let i=$i+1
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_045()
{
        myresult=PASS
        message "START $tet_thistest: Add Local Groups - gidNumber Specified - $MPG - Shared Name Space"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		u=2000
		EXPMSG="A group with the same name or GID already exists"
                while [ $u -le 2010 ] ; do
                        MSG=`ssh root@$FULLHOSTNAME "sss_groupadd user$u 2>&1"`
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Adding LOCAL group was expected to fail no more allowed gidNumbers, but was successful."
                                myresult=FAIL
                                ssh root@$FULLHOSTNAME "sss_groupdel user$u"
                        fi

                        echo $MSG | grep "$EXPMSG"
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                                myresult=FAIL
                        else
                                message "Adding LOCAL group failed as expected."
                        fi      

			let u=$u+1
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_046()
{
        myresult=PASS
        message "START $tet_thistest: Delete Users - magic Private Group Deleted"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
        
        	i=2000
        	while [ $i -le 2010 ] ; do
                	ssh root@$FULLHOSTNAME "sss_userdel user$i"
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Failed to delete LOCAL user$i.  Return Code: $?"
                        	myresult=FAIL
                	fi

			ssh root@$FULLHOSTNAME "getent -s sss group | grep user$i"
			if [ $? -eq 0 ] ; then
				message "ERROR: User was deleted but the user's magic private group still exists."
				myresult=FAIL
				ssh root@$FULLHOSTNAME "sss_groupdel user$i"
			else
				message "User's magic private group was removed as expected."
			fi
                	let i=$i+1
		done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_047()
{
   ####################################################################
   #   Configuration 6
   #    enumerate: TRUE
   #	$USEFQN TRUE
   #    $PROVIDER: local
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 6"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_local6.conf
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

                verifyCfg $FULLHOSTNAME LOCAL enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $MAXID 1003
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi
  
                verifyCfg $FULLHOSTNAME LOCAL $PROVIDER local
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LOCAL $USEFQN TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_048()
{
	###########################################################################################
        #  This test is no longer valid because the fix to ticket 95 was to always set to TRUE
	###########################################################################################
        myresult=PASS
        message "START $tet_thistest: Trac Ticket 95 - $MPG set to FALSE, Local user added with gidNumber of 0"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	#################################################################################
	# If the user is added successfully, but fails to be found with getent, you may
	# be seeing a regression of bug https://fedorahosted.org/sssd/ticket/95
	# with $MPG set to FALSE user is added with gidNumber of 0 and
	# then getent fails to return 0 - debug output will show an error - but no error
	# returned on the search
	#################################################################################
  	for c in $CLIENTS; do
		eval_vars $c
        	message "Working on $FULLHOSTNAME"
        	ssh root@$FULLHOSTNAME "sss_useradd -u 1000 -h /home/user1000 -s /bin/bash user1000"
        	if [ $? -ne 0 ] ; then
                	message "ERROR: Adding LOCAL domain user1000.  Return Code: $?"
                	myresult=FAIL
        	else
                        verifyAttr $FULLHOSTNAME "name=user1000,cn=users,cn=LOCAL,cn=sysdb" gidNumber 0
                        if [ $? -eq 0 ] ; then
				message "ERROR: User added with gidNumber 0, trac ticket issue 95 still exists."
                                myresult=FAIL
                        else
                                message "LOCAL domain user1000 has non 0 gidNumber."
                        fi
        	fi

		# clean up
		ssh root@$FULLHOSTNAME "sss_userdel user1000"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_049()
{
        myresult=PASS
        message "START $tet_thistest: Trac Ticket 57 - sssd assigning uid number already in use"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		# add a user manually defining uid 1001
		ssh root@$FULLHOSTNAME "sss_useradd -u 1000 -h /home/user1001 -s /bin/bash user1000"
		# add another users and verify the uid number 1000 was not used, but the next available
		# should skip uid number already in use
		ssh root@$FULLHOSTNAME "sss_useradd -h /home/user1001 -s /bin/bash user1001"

		# now verify user1001's uidNumber
		USER=`ssh root@$FULLHOSTNAME getent -s sss passwd user1001@LOCAL`
		if [ $OS == "RHEL" ] ; then
			MYUID=`echo $USER | cut -d ":" -f 3`
		else
			MYUID=`echo $USER | cut -d ":" -f 2`
		fi

		if [ $MYUID -ne 1001 ] ; then
			message "ERROR: uidNumber not as expected - could be regression of trac issue 57 Expected: 1001 Got: $MYUID"
			myresult=FAIL
		else
			message "Trac Issue 57 appears to be fixed - uidNumber assigned correctly"
		fi

		# clean up
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_050()
{

        myresult=PASS
        message "START $tet_thistest: Authentication local user with no password assigned"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi 
        for c in $CLIENTS; do 
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "cat /dev/null > /var/log/secure"
		rm -rf $TET_TMP_DIR/expect-ssh-nopasswd-out.txt
		# test authentication via ssh
		expect $HOMEDIR/expect/ssh_deny.exp user1000@LOCAL $FULLHOSTNAME ihavenopassword > $TET_TMP_DIR/expect-ssh-nopasswd-out.txt
		cat $TET_TMP_DIR/expect-ssh-nopasswd-out.txt | grep "Permission denied"
		if [ $? -ne 0 ] ; then
			message "ERROR: User without password successfully authenticated to client.  See $TET_TMP_DIR/expect-ssh-nopasswd-out.txt for details!"
			myresult=FAIL
		else
			message "User without password assigned failed authentication."
			# now check for failure message in /var/log/secure
			ssh root@$FULLHOSTNAME "cat /var/log/secure | grep \"authentication failure\""
			if [ $? -ne 0 ] ; then
				message "Authentication failure message not found in /var/log/secure"
				myresult=FAIL
			else
				message "Authentication failure message found in /var/log/secure"
			fi
		fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_051()
{

        myresult=PASS
        message "START $tet_thistest: Authentication local user with password assigned"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	rm -rf $TET_TMP_DIR/SetUserPassword.exp
	echo "spawn passwd user1000@LOCAL" >> $TET_TMP_DIR/SetUserPassword.exp
	echo "expect \"New password: \"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send onLine4now" >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send \"\\r\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo "expect \"Retype new password: \"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send onLine4now"  >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send \"\\r\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo "expect eof" >> $TET_TMP_DIR/SetUserPassword.exp

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		rm -rf $TET_TMP_DIR/expect-ssh-success-out.txt
        	ssh root@$FULLHOSTNAME 'rm -f /tmp/SetUserPassword.exp'
        	scp $TET_TMP_DIR/SetUserPassword.exp root@$FULLHOSTNAME:/tmp/.

        	ssh root@$FULLHOSTNAME '/usr/bin/expect /tmp/SetUserPassword.exp > /tmp/SetUserPassword-output.txt'
		
                expect $HOMEDIR/expect/ssh.exp user1000@LOCAL $FULLHOSTNAME onLine4now > $TET_TMP_DIR/expect-ssh-success-out.txt
		cat $TET_TMP_DIR/expect-ssh-success-out.txt | grep "$"
                if [ $? -ne 0 ] ; then
			echo $?
                        message "ERROR: User with password assigned failed authentication!"
                        myresult=FAIL
                else
                        message "User with password assigned successfully authentication."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_052()
{

        myresult=PASS
        message "START $tet_thistest: Authentication local user with incorrect password assigned"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "cat /dev/null > /var/log/secure"
		rm -rf $TET_TMP_DIR/expect-ssh-badpasswd-out.txt
                expect $HOMEDIR/expect/ssh_deny.exp user1000@LOCAL $FULLHOSTNAME abcd123xyz789 > $TET_TMP_DIR/expect-ssh-badpasswd-out.txt
		cat $TET_TMP_DIR/expect-ssh-badpasswd-out.txt | grep "Permission denied"
                if [ $? -ne 0 ] ; then
			echo $?
                        message "ERROR: User authentication with incorrect password was successful.  Please see $TET_TMP_DIR/expect-ssh-badpasswd-out.txt for details!"
                        myresult=FAIL
                else
                        message "User authentication with incorrect password assigned failed authentication."
                        # now check for failure message in /var/log/secure
                        ssh root@$FULLHOSTNAME "cat /var/log/secure | grep \"authentication failure\""
                        if [ $? -ne 0 ] ; then
                                message "Authentication failure message not found in /var/log/secure"
                                myresult=FAIL
                        else
                                message "Authentication failure message found in /var/log/secure"
                        fi
                fi

		ssh root@$FULLHOSTNAME "sss_userdel user1000@LOCAL ; sss_userdel user1001@LOCAL"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_053()
{
        myresult=PASS
        message "START $tet_thistest: Modify Allowed Range with Existing Local Users - Users and MPGs now out of range"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"

                ssh root@$FULLHOSTNAME "sss_useradd user1 ; sss_useradd user2"
                if [ $? -ne 0 ] ; then
                	message "ERROR: Failed to add LOCAL users.  Return Code: $?"
                	myresult=FAIL
                else
			for i in 1 2 ; do
                		ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user$i"
                        	if [ $? -ne 0 ] ; then
                                	message "ERROR: User$i was not returned by getent."
                                	myresult=FAIL
				else
					message "New user User$i returned by getent"
				fi	
                                ssh root@$FULLHOSTNAME "getent -s sss group | grep user$i"
                                if [ $? -ne 0 ] ; then
                                        message "ERROR: User$i's MPG was not returned by getent."
                                        myresult=FAIL
				else
					message "User$i's MPG returned by getent"
                                fi
                        done

			# change the minId and maxId configuration so users are out of range
			ssh root@$FULLHOSTNAME "sed -i -e \"s%max_id = 1003%max_id = 2003%g\" $SSSDCFG ; sed -i -e \"s%min_id = 1000%min_id = 2000%g\" $SSSDCFG"
                        restartSSSD $FULLHOSTNAME
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $FULLHOSTNAME"
                                myresult=FAIL
                        else
                                message "SSSD Server restarted on client $FULLHOSTNAME"
                        fi

	                verifyCfg $FULLHOSTNAME LOCAL $MAXID 2003
        	        if [ $? -ne 0 ] ; then
                	        myresult=FAIL
                	fi

                	verifyCfg $FULLHOSTNAME LOCAL $MINID 2000
                	if [ $? -ne 0 ] ; then
                        	myresult=FAIL
                	fi

			# Search for users and MPGs - shouldn't find them
                        for i in 1 2 ; do
                                ssh root@$FULLHOSTNAME "getent -s sss passwd | grep user$i"
                                if [ $? -eq 0 ] ; then
                                        message "ERROR: User$i was returned by getent and the userid is out of range."
                                        myresult=FAIL
				else
					message "Getent did not return user whose userid is now out of range"
                                fi

                                ssh root@$FULLHOSTNAME "getent -s sss group | grep user$i"
                                if [ $? -eq 0 ] ; then
                                        message "ERROR: User$i's MPG was returned by getent and the groupid is out of range."
                                        myresult=FAIL
				else
					message "Getent did not return user's MPG whose groupid is now out of range"
                                fi
                        done
		fi

		# cleanup 
		ssh root@$FULLHOSTNAME "sss_userdel user1 ; sss_useradd user2"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_054()
{
        myresult=PASS
        message "START $tet_thistest: Add local user - MPG already exists"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		# add group manually
		ssh root@$FULLHOSTNAME "sss_groupadd -g 2000 user2000"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to add LOCAL group"
                        myresult=FAIL
		else
			EXPMSG="A user or group with the same name or ID already exists"
                	ERR=`ssh root@$FULLHOSTNAME "sss_useradd -u 2000 user2000 2>&1"`
			if [ "$EXPMSG" != "$ERR" ] ; then
                        	message "ERROR: Unexpected error message. Expected: $EXPMSG Got: $ERR"
                        	myresult=FAIL
			else
				message "Error message as expected: $ERR"
			fi
		fi
	
		# cleanup
		ssh root@$FULLHOSTNAME "sss_userdel user2000 ; sss_groupdel user2000"
        done

        result $myresult
        message "END $tet_thistest" 
}

sssd_055()
{
        myresult=PASS
        message "START $tet_thistest: sss utils as non root user - sss_useradd"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		
		# add a local user and set their password
		ssh root@$FULLHOSTNAME "/usr/sbin/useradd myuser"
		expect $HOMEDIR/expect/setpwd.exp myuser $FULLHOSTNAME online4now
		
		COMMAND="/usr/sbin/sss_useradd test"
		ERRMSG="sss_useradd must be run as root"
		expect $HOMEDIR/expect/execute.exp myuser $FULLHOSTNAME online4now "$COMMAND" > $TET_TMP_DIR/sss_useradd.exp.out
		cat $TET_TMP_DIR/sss_useradd.exp.out | grep "$ERRMSG"
		if [ $? -ne 0 ] ; then
			message "ERROR: expected error was not found. Expected: $ERRMSG"
			myresult=FAIL
		fi

		# make sure the user really wasn't added 
                ssh root@$FULLHOSTNAME "getent -s sss password | grep test"
                if [ $? -eq 0 ] ; then
                	message "ERROR: User was added to the local sssd database by non root user."
                        myresult=FAIL
                        ssh root@$FULLHOSTNAME "sss_userdel test"
                else
                        message "User does not exist in the sssd local database."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_056()
{
        myresult=PASS
        message "START $tet_thistest: sss utils as non root user - sss_usermod"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		# add an sssd user
		ssh root@$FULLHOSTNAME "sss_useradd test"

                COMMAND="/usr/sbin/sss_usermod test -s /bin/ksh"
                ERRMSG="sss_usermod must be run as root"
                expect $HOMEDIR/expect/execute.exp myuser $FULLHOSTNAME online4now "$COMMAND" > $TET_TMP_DIR/sss_usermod.exp.out
                cat $TET_TMP_DIR/sss_usermod.exp.out | grep "$ERRMSG"
                if [ $? -ne 0 ] ; then
                        message "ERROR: expected error was not found. Expected: $ERRMSG"
                        myresult=FAIL
                fi

		# check to make user user's shell is not /bin/ksh
		MOD="/bin/ksh"
		SHELL=`ssh root@$FULLHOSTNAME getent -s sss passwd | grep test | cut -d : -f 7`
		if [ "$MOD" == "$SHELL" ] ; then
			message "ERROR: User's shell was modified and is now $SHELL"
			myresult=FAIL
		else
			message "User's shell was not modified."
		fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_057()
{
        myresult=PASS
        message "START $tet_thistest: sss utils as non root user - sss_userdel"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"

                COMMAND="/usr/sbin/sss_userdel test"
                ERRMSG="sss_userdel must be run as root"
                expect $HOMEDIR/expect/execute.exp myuser $FULLHOSTNAME online4now "$COMMAND" > $TET_TMP_DIR/sss_userdel.exp.out
                cat $TET_TMP_DIR/sss_userdel.exp.out | grep "$ERRMSG"
                if [ $? -ne 0 ] ; then
                        message "ERROR: expected error was not found. Expected: $ERRMSG"
                        myresult=FAIL
                fi

                # check to make the user still exists
                ssh root@$FULLHOSTNAME "getent -s sss passwd | grep test"
                if [ $? -ne 0 ] ; then
                        message "ERROR: User was not returned by getent."
                        myresult=FAIL
                else
                        message "User still exists."
                fi

		#clean up - delete test user
		ssh root@$FULLHOSTNAME "sss_userdel test"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_058()
{
        myresult=PASS
        message "START $tet_thistest: sss utils as non root user - sss_groupadd"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"

                COMMAND="/usr/sbin/sss_groupadd test"
                ERRMSG="sss_groupadd must be run as root"
                expect $HOMEDIR/expect/execute.exp myuser $FULLHOSTNAME online4now "$COMMAND" > $TET_TMP_DIR/sss_groupadd.exp.out
                cat $TET_TMP_DIR/sss_groupadd.exp.out | grep "$ERRMSG"
                if [ $? -ne 0 ] ; then
                        message "ERROR: expected error was not found. Expected: $ERRMSG"
                        myresult=FAIL
                fi

                # make sure the group really wasn't added 
                ssh root@$FULLHOSTNAME "getent -s sss group | grep test"
                if [ $? -eq 0 ] ; then
                        message "ERROR: Group was added to the local sssd database by non root user."
                        myresult=FAIL
                        ssh root@$FULLHOSTNAME "sss_groupdel test"
                else
                        message "Group does not exist in the sssd local database."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_059()
{
        myresult=PASS
        message "START $tet_thistest: sss utils as non root user - sss_groupmod"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                # add an sssd group
                ssh root@$FULLHOSTNAME "sss_groupadd test"

                COMMAND="/usr/sbin/sss_groupmod -a test2 test"
                ERRMSG="sss_groupmod must be run as root"
                expect $HOMEDIR/expect/execute.exp myuser $FULLHOSTNAME online4now "$COMMAND" > $TET_TMP_DIR/sss_groupmod.exp.out
                cat $TET_TMP_DIR/sss_groupmod.exp.out | grep "$ERRMSG"
                if [ $? -ne 0 ] ; then
                        message "ERROR: expected error was not found. Expected: $ERRMSG"
                        myresult=FAIL
		else
			message "Group was not modified and error message as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_060()
{
        myresult=PASS
        message "START $tet_thistest: sss utils as non root user - sss_groupdel"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"

                COMMAND="/usr/sbin/sss_groupdel test"
                ERRMSG="sss_groupdel must be run as root"
                expect $HOMEDIR/expect/execute.exp myuser $FULLHOSTNAME online4now "$COMMAND" > $TET_TMP_DIR/sss_groupdel.exp.out
                cat $TET_TMP_DIR/sss_groupdel.exp.out | grep "$ERRMSG"
                if [ $? -ne 0 ] ; then
                        message "ERROR: expected error was not found. Expected: $ERRMSG"
                        myresult=FAIL
                fi

                # check to make the group still exists
                ssh root@$FULLHOSTNAME "getent -s sss group | grep test"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Group was not returned by getent."
                        myresult=FAIL
                else
                        message "Group still exists."
                fi

                #clean up - delete test group
                ssh root@$FULLHOSTNAME "sss_groupdel test"

		#delete the non-root user
		ssh root@$FULLHOSTNAME "userdel -r myuser"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_061()
{
        myresult=PASS
        message "START $tet_thistest: Filtered user as member of Group - Trac Issue 108"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		# change the max_id value - there are none left
		ssh root@$FULLHOSTNAME "sed -i -e \"s%max_id = 2003%max_id = 2010%g\" $SSSDCFG"
		restartSSSD $FULLHOSTNAME
		sleep 5

		# first we need to add two users - one that is filtered and one that isn't - in sssd_local6.conf, user jenny is filtered
		ssh root@$FULLHOSTNAME "sss_useradd jenny ; sss_useradd jimi"
		# verify jenny is in the database, but not returned by getent
		ssh root@$FULLHOSTNAME "ldbsearch -H /var/lib/sss/db/sssd.ldb -b \"cn=users,cn=LOCAL,cn=sysdb\" | grep jenny"
		if [ $? -ne 0 ] ; then
			message "ERROR: User add was not found in the sssd database"
			myresult=FAIL
		else
			ssh root@$FULLHOSTNAME "getent -s sss passwd jenny@LOCAL"
			if [ $? -eq 0 ] ; then
				message "ERROR: Filtered user was returned by getent"
				myresult=FAIL
			else
				message "Filtered user found in database but was not returned by getent as expected."
			fi
		fi
		# now add a group and make jenny and jimi members
		ssh root@$FULLHOSTNAME "sss_groupadd test@LOCAL ; sss_usermod -a test@LOCAL jenny@LOCAL ; sss_usermod -a test@LOCAL jimi@LOCAL"
		
		# verify the memberships from the database
                verifyAttr $FULLHOSTNAME "name=jenny,cn=users,cn=LOCAL,cn=sysdb" memberof "name=test,cn=groups,cn=LOCAL,cn=sysdb"
                if [ $? -ne 0 ] ; then
                	myresult=FAIL
                else
                	message "LOCAL domain jenny memberof attribute is correct."
                fi

                verifyAttr $FULLHOSTNAME "name=jimi,cn=users,cn=LOCAL,cn=sysdb" memberof "name=test,cn=groups,cn=LOCAL,cn=sysdb"
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                else
                        message "LOCAL domain jimi memberof attribute is correct."
                fi

		# now verify getent on the group , does not return the filter user, but does return the non filtered user
		GROUP=`ssh root@$FULLHOSTNAME "getent -s sss group test@LOCAL"`
		echo $GROUP | grep "jimi@LOCAL"
		if [ $? -ne 0 ] ; then
			message "ERROR: User jimi is not filtered and was not returned as member of group test"
			myresult=FAIL
		else
			message "Unfiltered user was returned as member of the group."
		fi
		echo $GROUP | grep "jenny@LOCAL"
                if [ $? -eq 0 ] ; then
                        message "ERROR: User jenny is filtered and was returned as member of group test"
                        myresult=FAIL
                else
                        message "Filtered user was not returned as member of the group."
                fi
	
		# cleanup!
		ssh root@$FULLHOSTNAME "sss_userdel jenny ; sss_userdel jimi ; sss_groupdel test"
        done

        result $myresult
        message "END $tet_thistest"
}

##################################################################
. $TESTING_SHARED/shared.sh
. $TESTING_SHARED/sssdlib.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF
