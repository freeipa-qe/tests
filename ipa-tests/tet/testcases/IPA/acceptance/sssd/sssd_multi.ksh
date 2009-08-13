#!/bin/ksh

######################################################################
#  File: sssd_ldap.ksh - LDAP BE acceptance tests for SSSD
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic99"
#iclist="ic99"
ic0="startup"
ic1="sssd_multi_001 sssd_multi_002 sssd_multi_003 sssd_multi_004 sssd_multi_005 sssd_multi_006 sssd_multi_007"
ic2="sssd_multi_008 sssd_multi_009 sssd_multi_010 sssd_multi_011 sssd_multi_012 sssd_multi_013 sssd_multi_014"
ic3="sssd_multi_015"
ic4="sssd_multi_016 sssd_multi_017 sssd_multi_018" 
ic5="sssd_multi_019 sssd_multi_020 sssd_multi_021 sssd_multi_022"
ic6="sssd_multi_023 sssd_multi_024 sssd_multi_025"
ic7="sssd_multi_026 sssd_multi_027 sssd_multi_028 sssd_multi_029"
ic99="cleanup"
#################################################################
#  GLOBALS
#################################################################
#C1="jennyv2.bos.redhat.com dhcp\-100\-2\-185.bos.redhat.com"
C1="dhcp\-100\-2\-185.bos.redhat.com"
SSSD_CLIENTS="$C1"
export SSSD_CLIENTS
RH_DIRSERV="jennyv4.bos.redhat.com"
RH_BASEDN1="dc=example,dc=com"
PORT1=389
RH_BASEDN2="dc=bos,dc=redhat,dc=com"
PORT2=11329
ROOTDN="cn=Directory Manager"
ROOTDNPWD="Secret123"
export RH_DIRSERV ROOTDN ROOTDNPWD
CONFIG_DIR=$TET_ROOT/testcases/IPA/acceptance/sssd/config
SSSD_CONFIG_DIR=/etc/sssd
SSSD_CONFIG_FILE=$SSSD_CONFIG_DIR/sssd.conf
SSSD_CONFIG_DB=/var/lib/sss/db/config.ldb
SSSD_LOCAL_DB=/var/lib/sss/db/sssd.ldb
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
PGROUP5=Group1
PGROUP6=Group2000
PGROUP7=Duplicate
######################################################################
# Tests
######################################################################
startup()
{
  myresult=PASS
  message "START $tet_this_test: Setup for NSS and PAM AUTH"
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
  message "END $tet_this_test"
}

sssd_multi_001()
{
   ####################################################################
   #   Configuration 1
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 1 - LDAP PROXY and LOCAL - RHDS"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdLDAPSetup $c $RH_DIRSERV $RH_BASEDN1 $PORT1
                if [ $? -ne 0 ] ; then
                        message "ERROR: SSSD LDAP Setup Failed for $c."
                        myresult=FAIL
                fi

                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $c sssd_multi1.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        restartSSSD $c
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $c"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $c"
                        fi
                fi

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

                verifyCfg $c LDAP enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP legacy FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP "cache\-credentials" FALSE
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
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

                ssh root@$c "sss_useradd -u 2000 -h /home/user2000 -s /bin/bash user2000 ; sss_useradd -u 2001 -h /home/user2001 -s /bin/bash user2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain users.  Return Code: $?"
                        myresult=FAIL
                fi

	   # verify user enumeration
	   # Users that should be returned
	      USERS="$PUSER1 $PUSER2 user2000 user2001"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
              	echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                	message "ERROR: Expected $item user to be returned."
                        myresult=FAIL
                else
                        message "$item user returned as expected."
                fi

              done

	     ssh root@$c "sss_userdel user2000 ; sss_userdel user2001"

	    # users that shouldn't be returned
              USERS="$PUSER3 $PUSER4"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
                echo $RET | grep $item
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item user not to be returned. Out of configured range"
                        myresult=FAIL
                else
                        message "$item user was NOT returned as expected."
                fi
		
              done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_003()
{
        myresult=PASS
        message "START $tet_thistest: Only groups in domain configured ranges are returned - LDAP PROXY and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

                ssh root@$c "sss_groupadd -g 2000 group2000 ; sss_groupadd -g 2001 group2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain groups.  Return Code: $?"
                        myresult=FAIL
                fi

           # verify group enumeration
           # Users that should be returned
              GROUPS="$PGROUP1 $PGROUP2 group2000 group2001"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
                echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item group to be returned."
                        myresult=FAIL
                else
                        message "$item group returned as expected."
                fi
	
              done

	      ssh root@$c "sss_groupdel group2000 ; sss_groupdel group2001"

            # groups that shouldn't be returned
              GROUPS="$PGROUP3 $PROUP4"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
                echo $RET | grep $item
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item group not to be returned. Out of configured range"
                        myresult=FAIL
                else
                        message "$item group was NOT returned as expected."
                fi
              done
              
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
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		MSG=`ssh root@$c "sss_usermod -g 2000 puser1 2>&1"`
		if [ $? -eq 0 ] ; then
			message "ERROR: Modification of LDAP user was successful."
			myresult=FAIL
		fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
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

	EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_userdel puser1 2>&1"`
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
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_groupmod -g 2000 Group1 2>&1"`
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

	EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_groupdel Group1 2>&1"`
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

#############################################################################################################################

sssd_multi_008()
{
   ####################################################################
   #   Configuration 2
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 2 - LDAP and LOCAL - RHDS - FQDN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdCfg $c sssd_multi2.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        restartSSSD $c
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $c"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $c"
                        fi
                fi
		
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

                verifyCfg $c LOCAL fullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP fullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_009()
{
        myresult=PASS
        message "START $tet_thistest: Only users in domain configured ranges are returned - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

                ssh root@$c "sss_useradd -u 2000 -h /home/user2000 -s /bin/bash user2000 ; sss_useradd -u 2001 -h /home/user2001 -s /bin/bash user2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain users.  Return Code: $?"
                        myresult=FAIL
                fi

           # verify user enumeration
           # Users that should be returned
              USERS="$PUSER1@LDAP $PUSER2@LDAP user2000@LOCAL user2001@LOCAL"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
                echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item user to be returned."
                        myresult=FAIL
                else
                        message "$item user returned as expected."
                fi

              done

             ssh root@$c "sss_userdel user2000 ; sss_userdel user2001"

            # users that shouldn't be returned
              USERS="$PUSER3 $PUSER4"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
                echo $RET | grep $item
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item user not to be returned. Out of configured range"
                        myresult=FAIL
                else
                        message "$item user was NOT returned as expected."
                fi

              done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_010()
{
        myresult=PASS
        message "START $tet_thistest: Only groups in domain configured ranges are returned - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

      # add some of local groups
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

                ssh root@$c "sss_groupadd -g 2000 group2000 ; sss_groupadd -g 2001 group2001"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Adding LOCAL domain groups.  Return Code: $?"
                        myresult=FAIL
                fi

           # verify group enumeration
           # Users that should be returned
              GROUPS="$PGROUP1@LDAP $PGROUP2@LDAP group2000@LOCAL group2001@LOCAL"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
                echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item group to be returned."
                        myresult=FAIL
                else
                        message "$item group returned as expected."
                fi

              done

              ssh root@$c "sss_groupdel group2000 ; sss_groupdel group2001"

            # groups that shouldn't be returned
              GROUPS="$PGROUP3 $PROUP4"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
                echo $RET | grep $item
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item group not to be returned. Out of configured range"
                        myresult=FAIL
                else
                        message "$item group was NOT returned as expected."
                fi
              done
              
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_011()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to modify LDAP Domain Users - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_usermod -g 2000 puser1@LDAP 2>&1"`
                if [ $? -eq 0 ] ; then
                        message "ERROR: Modification of LDAP user was successful."
                        myresult=FAIL
                fi

                if [[ $EXPMSG != $MSG ]] ; then
                        message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        myresult=FAIL
                else
                        message "Modifying LDAP user error message was as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_012()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to delete LDAP Domain User - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_userdel puser1@LDAP 2>&1"`
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

sssd_multi_013()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to modify LDAP Domain Groups - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Selected domain LDAP conflicts with selected GID 2000"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_groupmod -g 2000 Group1@LDAP 2>&1"`
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

sssd_multi_014()
{
        myresult=PASS
        message "START $tet_thistest: Attempt to delete LDAP Domain Group - LDAP and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                MSG=`ssh root@$c "sss_groupdel Group1@LDAP 2>&1"`
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

########################################################################################################################

sssd_multi_015()
{
   ####################################################################
   #   Configuration 3
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 3 - LOCAL and LOCAL - SSSD Should fail to start"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	EXPMSG="Multiple LOCAL domains are not allowed"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdCfg $c sssd_multi3.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        ssh root@$c "rm -rf /var/lib/sss/*.ldb ; service sssd stop"
                        MSG=` ssh root@$c "service sssd start 2>&1"`
                        if [ $? -ne 0 ] ; then
                                message "ERROR: SSSD Should have failed to start with 2 LOCAL domains configured on $c"
                                myresult=FAIL
                        fi

                	if [[ $EXPMSG != $MSG ]] ; then
                        	message "ERROR: Unexpected Error message.  Got: $MSG  Expected: $EXPMSG"
                        	myresult=FAIL
                	else
                        	message "Deleting LDAP group error message was as expected."
                	fi
		fi
        done

        result $myresult
        message "END $tet_thistest"
}

############################################################################################################################

sssd_multi_016()
{
   ####################################################################
   #   Configuration 4
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 4 - LDAP and LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

                sssdCfg $c sssd_multi4.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        ssh root@$c "rm -rf /var/lib/sss/*.ldb"
                        restartSSSD $c
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $c"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $c"
                        fi
                fi

                verifyCfg $c "EXAMPLE\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" minId 2000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" maxId 2010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_017()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify user enumeration
           # Users that should be returned
              USERS="$PUSER1 $PUSER2 $PUSER5 $PUSER6"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
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

sssd_multi_018()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify group enumeration
           # Groups that should be returned
              GROUPSS="$PGROUP1 $PGROUP2 $PGROUP5 $PGROUP6"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
                echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item group to be returned."
                        myresult=FAIL
                else
                        message "$item group returned as expected."
                fi

              done

		# Let's make sure we got both Duplicate groups - since they have different gids - they are unique
        	RET=`ssh root@$c getent -s sss group | grep $PGROUP7 2>&1`
		echo $RET | grep 1010
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 1010 to be returned."
                        myresult=FAIL
                else
                        message "Duplicate group name with unique gid 1010 returned as expected."
                fi

                echo $RET | grep 2010
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 2010 to be returned."
                        myresult=FAIL
                else
                        message "Duplicate group name with unique gid 2010 returned as expected."
                fi


        done

        result $myresult
        message "END $tet_thistest"
}

##########################################################################################################################

sssd_multi_019()
{
   ####################################################################
   #   Configuration 5
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 5 - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdCfg $c sssd_multi5.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        ssh root@$c "rm -rf /var/lib/sss/*.ldb"
                        restartSSSD $c
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $c"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $c"
                        fi
                fi

                verifyCfg $c "EXAMPLE\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

		verifyCfg $c "EXAMPLE\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_020()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify user enumeration
           # Users that should be returned
              USERS="$PUSER1@$DOMAIN1 $PUSER2@$DOMAIN1 $PUSER5@$DOMAIN2 $PUSER6@$DOMAIN2"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
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

sssd_multi_021()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify group enumeration
           # Groups that should be returned
              GROUPS="$PGROUP1@$DOMAIN1 $PGROUP2@$DOMAIN1 $PGROUP5@$DOMAIN2 $PGROUP6@$DOMAIN2 $PGROUP7@$DOMAIN1 $PGROUP7@$DOMAIN2"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
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

sssd_multi_022()
{
        myresult=PASS
        message "START $tet_thistest:  Invalid memberuid is not returned - LDAP and LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		RET=`ssh root@$c getent -s sss group | grep $PGROUP6@$DOMAIN2 2>&1`
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

sssd_multi_023()
{
   ####################################################################
   #   Configuration 6
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 6 - LDAP and PROXY LDAP - RHDS - Ranges - No FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
        	sssdLDAPSetup $c $RH_DIRSERV $RH_BASEDN2 $PORT2
        	if [ $? -ne 0 ] ; then
                	message "ERROR: SSSD LDAP Setup Failed for $c."
                	myresult=FAIL
        	fi

                sssdCfg $c sssd_multi6.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        ssh root@$c "rm -rf /var/lib/sss/*.ldb"
                        restartSSSD $c
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $c"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $c"
                        fi
                fi

                verifyCfg $c "EXAMPLE\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" maxId 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" minId 2000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" maxId 2010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" "cache\-credentials" FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_024()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and PROXY LDAP - RHDS - Ranges - No FQN - Proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify user enumeration
           # Users that should be returned
              USERS="$PUSER1 $PUSER2 $PUSER5 $PUSER6"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
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

sssd_multi_025()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and PROXY LDAP - RHDS - Ranges - No FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Unsupported domain type"
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify group enumeration
           # Groups that should be returned
              GROUPSS="$PGROUP1 $PGROUP2 $PGROUP5 $PGROUP6"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
                echo $RET | grep $item
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item group to be returned."
                        myresult=FAIL
                else
                        message "$item group returned as expected."
                fi

              done

		# Let's make sure we got both Duplicate groups - since they have different gids - they are unique
        	RET=`ssh root@$c getent -s sss group | grep $PGROUP7 2>&1`
		echo $RET | grep 1010
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 1010 to be returned."
                        myresult=FAIL
                else
                        message "Duplicate group name with unique gid 1010 returned as expected."
                fi

                echo $RET | grep 2010
                if [ $? -ne 0 ] ; then
                        message "ERROR: Expected group with gid 2010 to be returned."
                        myresult=FAIL
                else
                        message "Duplicate group name with unique gid 2010 returned as expected."
                fi


        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_026()
{
   ####################################################################
   #   Configuration 7
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Configuration 7 - LDAP and PROXY LDAP - RHDS - No Ranges - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdLDAPSetup $c $RH_DIRSERV $RH_BASEDN2 $PORT2
                if [ $? -ne 0 ] ; then
                        message "ERROR: SSSD LDAP Setup Failed for $c."
                        myresult=FAIL
                fi

                sssdCfg $c sssd_multi7.conf
                if [ $? -ne 0 ] ; then
                        message "ERROR Configuring SSSD on $c."
                        myresult=FAIL
                else
                        ssh root@$c "rm -rf /var/lib/sss/*.ldb"
                        restartSSSD $c
                        if [ $? -ne 0 ] ; then
                                message "ERROR: Restart SSSD failed on $c"
                             sssd_ldap_014   myresult=FAIL
                        else
                                message "SSSD Server restarted on client $c"
                        fi
                fi

                verifyCfg $c "EXAMPLE\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

		verifyCfg $c "EXAMPLE\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "EXAMPLE\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" enumerate 3
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c "BOS\.REDHAT\.COM" cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_multi_027()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Users - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify user enumeration
           # Users that should be returned
              USERS="$PUSER1@$DOMAIN1 $PUSER2@$DOMAIN1 $PUSER5@$DOMAIN2 $PUSER6@$DOMAIN2"
              RET=`ssh root@$c getent -s sss passwd 2>&1`
              for item in $USERS ; do
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

sssd_multi_028()
{
        myresult=PASS
        message "START $tet_thistest:  Enumerated Groups - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"

           # verify group enumeration
           # Groups that should be returned
              GROUPS="$PGROUP1@$DOMAIN1 $PGROUP2@$DOMAIN1 $PGROUP5@$DOMAIN2 $PGROUP6@$DOMAIN2 $PGROUP7@$DOMAIN1 $PGROUP7@$DOMAIN2"
              RET=`ssh root@$c getent -s sss group 2>&1`
              for item in $GROUPS ; do
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

sssd_multi_029()
{
        myresult=PASS
        message "START $tet_thistest:  Invalid memberuid is not returned - LDAP and PROXY LDAP - RHDS - No Ranges - FQN - proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
		RET=`ssh root@$c getent -s sss group | grep $PGROUP6@$DOMAIN2 2>&1`
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

        ssh root@$c "yum -y erase sssd ; rm -rf /var/lib/sss/ ; yum clean all"
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

