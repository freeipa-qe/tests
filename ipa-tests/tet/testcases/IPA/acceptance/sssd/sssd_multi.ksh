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
iclist="ic0 ic1 ic2 ic99"
#iclist="ic99"
ic0="startup"
ic1="sssd_multi_001 sssd_multi_002 sssd_multi_003 sssd_multi_004 sssd_multi_005 sssd_multi_006 sssd_multi_007"
ic2="sssd_multi_008 sssd_multi_009 sssd_multi_010 sssd_multi_011 sssd_multi_012 sssd_multi_013 sssd_multi_014"
ic99="cleanup"

#################################################################
#  GLOBALS
#################################################################
#C1="jennyv2.bos.redhat.com dhcp\-100\-2\-185.bos.redhat.com"
C1="dhcp\-100\-2\-185.bos.redhat.com"
SSSD_CLIENTS="$C1"
export SSSD_CLIENTS
RH_DIRSERV="jennyv4.bos.redhat.com"
RH_BASEDN="dc=example,dc=com"
ADS_DIRSERV="jennyv3.bos.redhat.com"
ADS_BASEDN="dc=bos,dc=redhat,dc=com"
ROOTDN="cn=Directory Manager"
ROOTDNPWD="Secret123"
export RH_DIRSERV ADS_DIRSRV ROOTDN ROOTDNPWD
CONFIG_DIR=$TET_ROOT/testcases/IPA/acceptance/sssd/config
SSSD_CONFIG_DIR=/etc/sssd
SSSD_CONFIG_FILE=$SSSD_CONFIG_DIR/sssd.conf
SSSD_CONFIG_DB=/var/lib/sss/db/config.ldb
SSSD_LOCAL_DB=/var/lib/sss/db/sssd.ldb
###################
# KNOW LDAP USERS #
###################
# Posix Users
PUSER1=puser1
PUSER2=puser2
PUSER3=puser3
PUSER4=puser4
###################
# KNOW LDAP GROUP #
###################
#Posix Groups
PGROUP1=Group1
PGROUP2=Group2
PGROUP3=Group3
PGROUP4=Group4
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
        message "START $tet_thistest: Setup Multiple SSSD Back Ends Configuration 1 - RHDS - provider proxy and LOCAL"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdLDAPSetup $c $RH_DIRSERV $RH_BASEDN
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

                verifyCfg $c LDAP cache\-credentials FALSE
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
        message "START $tet_thistest: Only users in domain configured ranges are returned - provider proxy and LOCAL"
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
        message "START $tet_thistest: Only groups in domain configured ranges are returned - provider proxy and LOCAL"
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
        message "START $tet_thistest: Attempt to modify LDAP Domain Users - provider proxy and LOCAL"
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
        message "START $tet_thistest: Attempt to delete LDAP Domain User - provider proxy and LOCAL"
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
        message "START $tet_thistest: Attempt to modify LDAP Domain Groups - provider proxy and LOCAL"
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
        message "START $tet_thistest: Attempt to delete LDAP Domain Group - provider proxy and LOCAL"
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

sssd_multi_008()
{
   ####################################################################
   #   Configuration 2
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup Multiple SSSD Back Ends Configuration 2 - RHDS - provider local and LOCAL - FQDN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
                message "Working on $c"
                sssdCfg $c sssd_multi2.conf
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

                verifyCfg $c LDAP legacy FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $c LDAP cache\-credentials FALSE
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
        message "START $tet_thistest: Only users in domain configured ranges are returned - provider local and LOCAL - FQN"
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
        message "START $tet_thistest: Only groups in domain configured ranges are returned - provider local and LOCAL - FQN"
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
        message "START $tet_thistest: Attempt to modify LDAP Domain Users - provider ldap and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Could not modify user - check if user names are correct"
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
        message "START $tet_thistest: Attempt to delete LDAP Domain User - provider ldap and LOCAL - FQN"
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
        message "START $tet_thistest: Attempt to modify LDAP Domain Groups - provider ldap and LOCAL - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        EXPMSG="Could not modify group - check if member group names are correct"
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
        message "START $tet_thistest: Attempt to delete LDAP Domain Group - provider ldap and LOCAL - FQN"
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

