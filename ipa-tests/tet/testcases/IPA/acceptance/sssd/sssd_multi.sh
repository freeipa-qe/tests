#!/bin/sh

######################################################################
#  File: sssd_ldap.sh - LDAP BE acceptance tests for SSSD
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7"
ic1="sssd_multi_001 sssd_multi_002 sssd_multi_003 sssd_multi_004 sssd_multi_005 sssd_multi_006 sssd_multi_007 sssd_multi_008"
ic2="sssd_multi_009 sssd_multi_010 sssd_multi_011 sssd_multi_012 sssd_multi_013 sssd_multi_014 sssd_multi_015 sssd_multi_016"
ic3="sssd_multi_017"
ic4="sssd_multi_018 sssd_multi_019 sssd_multi_020" 
ic5="sssd_multi_021 sssd_multi_022 sssd_multi_023 sssd_multi_024"
ic6="sssd_multi_025 sssd_multi_026 sssd_multi_027"
ic7="sssd_multi_028 sssd_multi_029 sssd_multi_030 sssd_multi_031 sssd_multi_032"
#################################################################
#  GLOBALS
#################################################################
RH_DIRSERV="jennyv4.bos.redhat.com"
RH_BASEDN1="dc=example,dc=com"
PORT1=389
RH_BASEDN2="dc=bos,dc=redhat,dc=com"
PORT2=11329
ROOTDN="cn=Directory Manager"
ROOTDNPWD="Secret123"
export RH_DIRSERV ROOTDN ROOTDNPWD
#CONFIG_DIR=$TET_ROOT/testcases/IPA/acceptance/sssd/config
#SSSD_CONFIG_DIR=/etc/sssd
#SSSD_CONFIG_FILE=$SSSD_CONFIG_DIR/sssd.conf
#SSSD_CONFIG_DB=/var/lib/sss/db/config.ldb
#SSSD_LOCAL_DB=/var/lib/sss/db/sssd.ldb
###################
# LDAP domains
###################
DOMAIN1="EXAMPLE.COM"
DOMAIN2="BOS.REDHAT.COM"
###################
# KNOW LDAP USERS #
###################
# Posix Users
PUSER1=puser1
PUSER2=puser2
PUSER3=puser3
PUSER4=puser4
PUSER5=user2000
PUSER6=user2009
###################
# KNOW LDAP GROUP #
###################
#Posix Groups
PGROUP1=Group1
PGROUP2=Group2
PGROUP3=Group3
PGROUP4=Group4
PGROUP5=Group1000
PGROUP6=group2000
PGROUP7=Duplicate
######################################################################
# Tests
######################################################################

sssd_multi_001()
{
   ####################################################################
   #   Configuration 1
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 1 - LDAP PROXY and LOCAL - RHDS"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                sssdLDAPSetup $FULLHOSTNAME $RH_DIRSERV $RH_BASEDN1 $PORT1
                if [ $? -ne 0 ] ; then
                        message "ERROR: SSSD LDAP Setup Failed for $FULLHOSTNAME."
                        myresult=FAIL
                fi

                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_multi1.conf
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

                verifyCfg $FULLHOSTNAME LDAP enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_002()
{
        myresult=PASS
        message "START $tet_thistest: Only users in domain configured ranges are returned - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

   # add some of local users
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

                ssh root@$FULLHOSTNAME "sss_useradd -u 2000 -h /home/user2000 -s /bin/bash user2000 ; sss_useradd -u 2001 -h /home/user2001 -s /bin/bash user2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain users.  Return Code: $?"
                        myresult=FAIL
                fi

	   	# verify user enumeration
	   	# Users that should be returned
		RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`	
              	for item in $PUSER1 $PUSER2 user2000 user2001 ; do
              		echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                		message "ERROR: Expected $item user to be returned."
                        	myresult=FAIL
                	else
                        	message "$item user returned as expected."
                	fi
              	done

	    	# users that shouldn't be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER3 $PUSER4 ; do
                	echo $RET | grep $item
                	if [ $? -eq 0 ] ; then
                        	message "ERROR: Expected $item user not to be returned. Out of configured range"
                        	myresult=FAIL
                	else
                        	message "$item user was NOT returned as expected."
                	fi
              	done

		# clean up
		ssh root@$FULLHOSTNAME "sss_userdel user2000 ; sss_userdel user2001"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_003()
{
        myresult=PASS
        message "START $tet_thistest: Only groups in domain configured ranges are returned - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

                ssh root@$FULLHOSTNAME "sss_groupadd -g 2000 group2000 ; sss_groupadd -g 2001 group2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain groups.  Return Code: $?"
                        myresult=FAIL
                fi

           	# verify group enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP1 $PGROUP2 group2000 group2001 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item group to be returned."
                        	myresult=FAIL
                	else
                        	message "$item group returned as expected."
                	fi
              	done

            	# groups that shouldn't be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP3 $PROUP4 ; do
                	echo $RET | grep $item
                	if [ $? -eq 0 ] ; then
                        	message "ERROR: Expected $item group not to be returned. Out of configured range"
                        	myresult=FAIL
                	else
                        	message "$item group was NOT returned as expected."
                	fi
              	done

		# clean up
		ssh root@$FULLHOSTNAME "sss_groupdel group2000 ; sss_groupdel group2001"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_004()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to modify LDAP Domain Users - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Could not modify user - check if user names are correct"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		MSG=`ssh root@$FULLHOSTNAME "sss_usermod -g 2000 puser1 2>&1"`
		if [ $? -eq 0 ] ; then
			message "ERROR: Modification of LDAP user was successful."
			myresult=FAIL
		fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 100"
                        myresult=FAIL
                else
                        message "Modifying LDAP user error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_005()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to delete LDAP Domain User - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	EXPMSG="The selected UID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_userdel puser1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deletion of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Deleting LDAP user error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_multi_006()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to modify LDAP Domain Groups - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	EXPMSG="Could not modify group - check if member group names are correct"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupmod -g 2000 Group1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Modification of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Modifying LDAP group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_007()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to delete LDAP Domain Group - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	EXPMSG="The selected GID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupdel Group1 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deletion of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Deleting LDAP group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_multi_008()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to LOCAL User to LDAP Domain Group - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		# add a user to the local sssd database
		ssh root@$FULLHOSTNAME "sss_useradd myuser"
                MSG=`ssh root@$FULLHOSTNAME "sss_usermod -g 1010 myuser 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding LOCAL user to LDAP Domain group was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 164"
                        myresult=FAIL
                else
                        message "Attempting to Add LOCAL user to LDAP DOMAIN group error message was as expected."
                fi
		
		# clean up the user
		ssh root@$FULLHOSTNAME "sss_userdel myuser"
        done

        result $myresult
        message "END $tet_thistest"

}


#############################################################################################################################

sssd_multi_009()
{
   ####################################################################
   #   Configuration 2
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 2 - LDAP and LOCAL - RHDS - FQDN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                sssdCfg $FULLHOSTNAME sssd_multi2.conf
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

                verifyCfg $FULLHOSTNAME LOCAL fullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP fullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_010()
{
        myresult=PASS
        message "START $tet_thistest: Only users in domain configured ranges are returned - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

                ssh root@$FULLHOSTNAME "sss_useradd -u 2000 -h /home/user2000 -s /bin/bash user2000 ; sss_useradd -u 2001 -h /home/user2001 -s /bin/bash user2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain users.  Return Code: $?"
                        myresult=FAIL
                fi

           	# verify user enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER1@LDAP $PUSER2@LDAP user2000@LOCAL user2001@LOCAL ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item user to be returned."
                        	myresult=FAIL
                	else
                        	message "$item user returned as expected."
                	fi
              	done

            	# users that shouldn't be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER3 $PUSER4 ; do
                	echo $RET | grep $item
                	if [ $? -eq 0 ] ; then
                        	message "ERROR: Expected $item user not to be returned. Out of configured range"
                        	myresult=FAIL
                	else
                        	message "$item user was NOT returned as expected."
                	fi
              	done

		# clean up
		ssh root@$FULLHOSTNAME "sss_userdel user2000 ; sss_userdel user2001"
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_011()
{
        myresult=PASS
        message "START $tet_thistest: Only groups in domain configured ranges are returned - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

      # add some of local groups
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

                ssh root@$FULLHOSTNAME "sss_groupadd -g 2000 group2000 ; sss_groupadd -g 2001 group2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain groups.  Return Code: $?"
                        myresult=FAIL
                fi

           	# verify group enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP1@LDAP $PGROUP2@LDAP group2000@LOCAL group2001@LOCAL ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item group to be returned."
                        	myresult=FAIL
                	else
                        	message "$item group returned as expected."
                	fi
              done

            	# groups that shouldn't be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP3 $PROUP4 ; do
                	echo $RET | grep $item
                	if [ $? -eq 0 ] ; then
                        	message "ERROR: Expected $item group not to be returned. Out of configured range"
                        	myresult=FAIL
                	else
                        	message "$item group was NOT returned as expected."
               		fi
              	done

		#clean up
		ssh root@$FULLHOSTNAME "sss_groupdel group2000 ; sss_groupdel group2001"
              
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_012()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to modify LDAP Domain Users - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="The selected UID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_usermod -g 2000 puser1@LDAP 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Modification of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 188"
                        myresult=FAIL
                else
                        message "Modifying LDAP user error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_013()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to delete LDAP Domain User - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="The selected UID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_userdel puser1@LDAP 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deletion of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 188"
                        myresult=FAIL
                else
                        message "Deleting LDAP user error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_multi_014()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to modify LDAP Domain Groups - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="The selected GID is outside the allowed range"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupmod -g 2000 Group1@LDAP 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Modification of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Modifying LDAP group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_015()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to delete LDAP Domain Group - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME "sss_groupdel Group1@LDAP 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Deletion of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 188"
                        myresult=FAIL
                else
                        message "Deleting LDAP group error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_multi_016()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to add LOCAL User to LDAP Domain Group - LDAP and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                # add a user to the local sssd database
                ssh root@$FULLHOSTNAME "sss_useradd myuser"
                MSG=`ssh root@$FULLHOSTNAME "sss_usermod -g 1001 myuser 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Adding LOCAL user to LDAP Domain group was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
			message "Trac issue 164"
                        myresult=FAIL
                else
                        message "Attempting to Add LOCAL user to LDAP DOMAIN group error message was as expected."
                fi
 
                # clean up the user
                ssh root@$FULLHOSTNAME "sss_userdel myuser" 
        done 

        result $myresult
        message "END $tet_thistest"
}


########################################################################################################################

sssd_multi_017()
{
   ####################################################################
   #   Configuration 3
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 3 - LOCAL and LOCAL - SSSD Should fail to start"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	EXPMSG="Multiple LOCAL domains are not allowed"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                sssdCfg $FULLHOSTNAME sssd_multi3.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $FULLHOSTNAME."
                        myresult=FAIL
                else
                        ssh root@$FULLHOSTNAME "service sssd stop ; rm -rf /var/lib/sss/*.ldb"
                        ssh root@$FULLHOSTNAME "service sssd start"
                        if [ $? -eq 0 ] ; then
                                message "ERROR: SSSD Should have failed to start with 2 LOCAL domains configured on $FULLHOSTNAME"
                                myresult=FAIL
                	else
                        	message "SSSD failed to start as expected with more than one local domain configured."
                	fi
		fi
        done

        result $myresult
        message "END $tet_thistest"
}

############################################################################################################################

sssd_multi_018()
{
   ####################################################################
   #   Configuration 4
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 4 - LDAP and LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

                sssdCfg $FULLHOSTNAME sssd_multi4.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $FULLHOSTNAME."
                        myresult=FAIL
                else
                        restartSSSD $FULLHOSTNAME
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $FULLHOSTNAME"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $FULLHOSTNAME"
                        fi
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" minId 2000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" maxId 2010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_019()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify user enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER1 $PUSER2 $PUSER5 $PUSER6 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item user to be returned."
                        	myresult=FAIL
                	else
                        	message "$item user returned as expected."
                	fi
              	done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_020()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify group enumeration
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP1 $PGROUP2 $PGROUP6 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item group to be returned."
                        	myresult=FAIL
                	else
                        	message "$item group returned as expected."
                	fi
              	done

		# Let's make sure we do get both Duplicate groups without useFullyQualifiedNames
        	RET=`ssh root@$FULLHOSTNAME getent -s sss group | grep $PGROUP7 2>&1`
		echo $RET | grep 1010
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 1010 to be returned."
                        myresult=FAIL
                else
                        message "First Duplicate group name returned as expected."
                fi

                echo $RET | grep 2010
		if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 2010 to be returned."
                        myresult=FAIL
                else
                        message "Second Duplicate group name returned as expected."
                fi
	done

        result $myresult
        message "END $tet_thistest"
}

##########################################################################################################################

sssd_multi_021()
{
   ####################################################################
   #   Configuration 5
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 5 - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                sssdCfg $FULLHOSTNAME sssd_multi5.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $FULLHOSTNAME."
                        myresult=FAIL
                else
                        restartSSSD $FULLHOSTNAME
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $FULLHOSTNAME"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $FULLHOSTNAME"
                        fi
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

		verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_022()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify user enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER1@$DOMAIN1 $PUSER2@$DOMAIN1 $PUSER5@$DOMAIN2 $PUSER6@$DOMAIN2 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item user to be returned."
                        	myresult=FAIL
                	else
                        	message "$item user returned as expected."
                	fi
              	done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_023()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify group enumeration
           	# Groups that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP1@$DOMAIN1 $PGROUP2@$DOMAIN1 $PGROUP5@$DOMAIN2 $PGROUP6@$DOMAIN2 $PGROUP7@$DOMAIN1 $PGROUP7@$DOMAIN2 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item group to be returned."
                        	myresult=FAIL
                	else
                        	message "$item group returned as expected."
                	fi
              	done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_024()
{
        myresult=PASS
        message "START $tet_thistest:  Invalid memberuid is not returned - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		RET=`ssh root@$FULLHOSTNAME getent -s sss group | grep $PGROUP6@$DOMAIN2 2>&1`
		ID="foo,bar,baz"
		echo $RET | grep $ID
		if [ $? -eq 0 ] ; then
			message "ERROR: Invalid memberuid was returned."
			myresult=FAIL
		else
			message "Invalid memberuid was not returned."
		fi		
        done

        result $myresult
        message "END $tet_thistest"
}

#######################################################################################################################################

sssd_multi_025()
{
   ####################################################################
   #   Configuration 6
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 6 - LDAP and PROXY LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
        	sssdLDAPSetup $FULLHOSTNAME $RH_DIRSERV $RH_BASEDN2 $PORT2
        	if [ $? -ne 0 ] ; then
                	message "ERROR: SSSD LDAP Setup Failed for $FULLHOSTNAME."
                	myresult=FAIL
        	fi

                sssdCfg $FULLHOSTNAME sssd_multi6.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $FULLHOSTNAME."
                        myresult=FAIL
                else
                        restartSSSD $FULLHOSTNAME
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $FULLHOSTNAME"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $FULLHOSTNAME"
                        fi
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" minId 2000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" maxId 2010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_026()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and PROXY LDAP - RHDS - Ranges - No FQN - Proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify user enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER1 $PUSER2 $PUSER5 $PUSER6 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item user to be returned."
				message "Trac issue 187"
                        	myresult=FAIL
                	else
                        	message "$item user returned as expected."
                	fi
              done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_027()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and PROXY LDAP - RHDS - Ranges - No FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify group enumeration
              	RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              	for item in $PGROUP1 $PGROUP2 $PGROUP6 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item group to be returned."
				message "Trac issue 187"
                        	myresult=FAIL
                	else
                        	message "$item group returned as expected."
                	fi
              	done

		# Let's make sure we get both Duplicate groups without useFullyQualifiedNames and enumerating
		echo $RET | grep 1010
                	if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 1010 to be returned."
                        myresult=FAIL
                else
                        message "First Duplicate group name returned as expected."
                fi

                echo $RET | grep 2010
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 2010 not to be returned."
			message "Trac issue 187"
                        myresult=FAIL
                else
                        message "Second Duplicate group name not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_028()
{
   ####################################################################
   #   Configuration 7
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 7 - LDAP and PROXY LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                sssdLDAPSetup $FULLHOSTNAME $RH_DIRSERV $RH_BASEDN2 $PORT2
                if [ $? -ne 0 ] ; then
                        message "ERROR: SSSD LDAP Setup Failed for $FULLHOSTNAME."
                        myresult=FAIL
                fi

                sssdCfg $FULLHOSTNAME sssd_multi7.conf
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

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

		verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "EXAMPLE\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME "BOS\.REDHAT\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_029()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           	# verify user enumeration
           	# Users that should be returned
              	RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
              	for item in $PUSER1@$DOMAIN1 $PUSER2@$DOMAIN1 $PUSER5@$DOMAIN2 $PUSER6@$DOMAIN2 ; do
                	echo $RET | grep $item
                	if [ $? -ne 0 ] ; then
                        	message "ERROR: Expected $item user to be returned."
				message "Trac issue 186"
                        	myresult=FAIL
                	else
                        	message "$item user returned as expected."
                	fi
              	done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_030()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

           # verify group enumeration
           # Groups that should be returned
              RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
              for item in $PGROUP1@$DOMAIN1 $PGROUP2@$DOMAIN1 $PGROUP5@$DOMAIN2 $PGROUP6@$DOMAIN2 $PGROUP7@$DOMAIN1 $PGROUP7@$DOMAIN2 ; do
                echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item group to be returned."
			message "Trac issue 186"
                        myresult=FAIL
                else
                        message "$item group returned as expected."
                fi

              done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_031()
{
        myresult=PASS
        message "START $tet_thistest:  Invalid memberuid is not returned - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		RET=`ssh root@$FULLHOSTNAME getent -s sss group | grep $PGROUP6@$DOMAIN2 2>&1`
		ID="foo,bar,baz"
		echo $RET | grep $ID
		if [ $? -eq 0 ] ; then
			message "ERROR: Invalid memberuid was returned."
			myresult=FAIL
		else
			message "Invalid memberuid was not returned."
		fi		
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_032()
{
        myresult=PASS
        message "START $tet_thistest:  Add User to Group in Different Domain - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	EXPMSG="Cannot get domain info"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                MSG=`ssh root@$FULLHOSTNAME sss_usermod -g 2010 puser1 2>&1`
                        if [ $? -eq 0 ] ; then
                                message "ERROR: Adding LDAP user to Group in Different LDAP Domain was successful."
				message "Trac issue 164"
                                myresult=FAIL
                        fi

                        if [[ $EXPMSG != $MSG ]] ; then
                                message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
				message "Trac issue 164"
                                myresult=FAIL
                        else
                                message "Attempting to add user to LDAP group in another domain error message was as expected."
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

