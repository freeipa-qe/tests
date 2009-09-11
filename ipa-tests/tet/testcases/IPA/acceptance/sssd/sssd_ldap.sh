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
iclist="ic1 ic2 ic3 ic4"

ic1="sssd_ldap_001 sssd_ldap_002 sssd_ldap_003 sssd_ldap_004 sssd_ldap_005 sssd_ldap_006 sssd_ldap_007"
ic2="sssd_ldap_008 sssd_ldap_009 sssd_ldap_010 sssd_ldap_011 sssd_ldap_012 sssd_ldap_013 sssd_ldap_014"
ic3="sssd_ldap_015 sssd_ldap_016 sssd_ldap_017 sssd_ldap_018 sssd_ldap_019 sssd_ldap_020 sssd_ldap_021"
ic4="sssd_ldap_022 sssd_ldap_023 sssd_ldap_024 sssd_ldap_025 sssd_ldap_026 sssd_ldap_027 sssd_ldap_028"

#################################################################
#  GLOBALS
#################################################################
RH_DIRSERV="jennyv4.bos.redhat.com"
RH_BASEDN="dc=example,dc=com"
PORT=389
ADS_DIRSERV="jennyv3.bos.redhat.com"
ADS_BASEDN="dc=bos,dc=redhat,dc=com"
ROOTDN="cn=Directory Manager"
ROOTDNPWD="Secret123"
export RH_DIRSERV ADS_DIRSRV ROOTDN ROOTDNPWD
LDIFS=$TET_ROOT/testcases/IPA/acceptance/sssd/ldifs
###################
# KNOW LDAP USERS #
###################
# Posix Users
PUSER1=puser1
PUSER2=puser2
PUSER3=puser3
PUSER4=puser4
# Non posix user
USER5=test
###################
# KNOW LDAP GROUP #
###################
#Posix Groups
PGROUP1=Group1
PGROUP2=Group2
PGROUP3=Group3
PGROUP4=Group4
# Non Posix Group
GROUP5=test
######################################################################
# Tests
######################################################################
startup()
{
  myresult=PASS
  message "START $tet_this_test: Setup for NSS and PAM AUTH"
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        sssdClientSetup $FULLHOSTNAME 
        if [ $? -ne 0 ] ; then
                message "ERROR: SSSD Client Setup Failed for $FULLHOSTNAME."
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "yum -y install sssd"
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

sssd_ldap_001()
{
   ####################################################################
   #   Configuration 1
   #    enumerate: TRUE
   #    minId: 1000
   #    maxId: 1010
   #    provider: proxy
   #    cache-credentials: FALSE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 1 - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
        	sssdLDAPSetup $FULLHOSTNAME $RH_DIRSERV $RH_BASEDN $PORT
        	if [ $? -ne 0 ] ; then
                	message "ERROR: SSSD LDAP Setup Failed for $FULLHOSTNAME."
                	myresult=FAIL
        	fi

                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_ldap1.conf
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

                verifyCfg $FULLHOSTNAME LDAP cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_002()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        USERS="$PUSER1 $PUSER2"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
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

sssd_ldap_003()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	GROUPS="$PGROUP1 $PGROUP2"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
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

sssd_ldap_004()
{
        myresult=PASS
        message "START $tet_thistest: Users uidNumbers below minId and above maxId - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	USERS="$PUSER3 $PUSER4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $USERS ; do
                   echo $RET | grep $item
                   if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item user not to be returned: uidNumber out of allowed range."
                        myresult=FAIL
                   else
                        message "$item user not returned as expected."
                  fi
                done

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_005()
{
        myresult=PASS
        message "START $tet_thistest: Groups gidNumbers below minId and above maxId - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	GROUPS="$PGROUP3 $PGROUP4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $GROUPS ; do
                   echo $RET | grep $item
                   if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item group not to be returned: gidNumber out of allowed range."
                        myresult=FAIL
                   else
                        message "$item group not returned as expected."
                  fi
		done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_006()
{
        myresult=PASS
        message "START $tet_thistest: Non Posix User - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                echo $RET | grep $USER5
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $USER5 user not to be returned: user not a Posix User."
                        myresult=FAIL
                   else
                        message "$USER5 user not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_007()
{
        myresult=PASS
        message "START $tet_thistest: Non Posix Group - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                echo $RET | grep $GROUP5
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $GROUP5 group not to be returned: group not a Posix Group."
                        myresult=FAIL
                   else
                        message "$GROUP5 group not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_008()
{
   ####################################################################
   #   Configuration 2
   #    enumerate: TRUE
   #    minId: 1000
   #	useFullyQualifiedNames: TRUE
   #    provider: proxy
   #    cache-credentials: TRUE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 2 - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_ldap2.conf
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

                verifyCfg $FULLHOSTNAME LDAP enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP provider proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP cache\-credentials TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_009()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - No maxId - FQN - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        USERS="$PUSER1 $PUSER2 $PUSER4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $USERS ; do
                   echo $RET | grep $item@LDAP
                   if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item@LDAP user to be returned."
                        myresult=FAIL
                   else
                        message "$item@LDAP user returned as expected."
                  fi
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_010()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - No maxId - FQN - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        GROUPS="$PGROUP1 $PGROUP2 $PGROUP4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $GROUPS ; do
                   echo $RET | grep $item@LDAP
                   if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item@LDAP group to be returned."
                        myresult=FAIL
                   else
                        message "$item@LDAP group returned as expected."
                  fi
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_011()
{
        myresult=PASS
        message "START $tet_thistest: User uidNumber not within allowed range - FQN - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                echo $RET | grep $PUSER3@LDAP
                if [ $? -eq 0 ] ; then
                	message "ERROR: Expected $PUSER3@LDAP user not to be returned: uidNumber out of allowed range."
                        myresult=FAIL
                else
                        message "$PUSER3@LDAP user not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_012()
{
        myresult=PASS
        message "START $tet_thistest: Group gidNumber not within allowed range - FQN - RHDS - provider proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi 
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
		echo $RET | grep $PGROUP3@LDAP
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $PGROUP3@LDAP group not to be returned: gidNumber out of allowed range."
                        myresult=FAIL
                else
                        message "$PGROUP3@LDAP group not returned as expected."
               fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_013()
{
        myresult=PASS
        message "START $tet_thistest: New User added - cache test - RHDS - provider proxy"

        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do 
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		# add a new ldap user within valid ID range
		echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -a -f $LDIFS/newuser.ldif"
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -a -f $LDIFS/newuser.ldif

		# search for the new user
		ssh root@$FULLHOSTNAME "getent -s sss passwd nuser@LDAP"
		if [ $? -ne 0 ] ; then
			message "New user not found yet. Waiting for cache to expire."
			sleep 10
			ssh root@$FULLHOSTNAME "getent -s sss passwd nuser@LDAP"
			if [ $? -ne 0 ] ; then
				message "New user still not found even after cache timeout expired"
				message "Trac issue 162"
				myresult=FAIL
			else
				message "New user found after cache expired."
			fi
		else
			message "New user added was found on first search attempt."
		fi

		# delete the ldap user
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/deluser.ldif
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_ldap_014()
{
        myresult=PASS
        message "START $tet_thistest: New Group added - cache test - RHDS - provider proxy"

        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do 
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                # add a new ldap group within valid ID range
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -a -f $LDIFS/newgroup.ldif

                # search for the new group
                ssh root@$FULLHOSTNAME "getent -s sss group group1005@LDAP"
                if [ $? -ne 0 ] ; then
                        message "New group not found yet. Waiting for cache to expire."
                        sleep 10
                        ssh root@$FULLHOSTNAME "getent -s sss group nuser@LDAP"
                        if [ $? -ne 0 ] ; then
                                message "New group still not found even after cache timeout expired"
				message "Trac issue 162"
                                myresult=FAIL
                        else
                                message "New group found after cache expired."
                        fi
                else
                        message "New group added was found on first search attempt."
                fi

                # delete the ldap user
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/delgroup.ldif
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_ldap_015()
{
   ####################################################################
   #   Configuration 3
   #    enumerate: TRUE
   #    minId: 1000
   #    maxId: 1010
   #    provider: ldap 
   #    cache-credentials: FALSE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 3 - RHDS - provider ldap"

        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"

                message "Working on $FULLHOSTNAME"
                sssdLDAPSetup $FULLHOSTNAME $RHDS_DIRSERV $RHDS_BASEDN $PORT
                if [ $? -ne 0 ] ; then
                        message "ERROR: SSSD LDAP Setup Failed for $FULLHOSTNAME."
                        myresult=FAIL
                fi

                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_ldap3.conf
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

                verifyCfg $FULLHOSTNAME LDAP cache\-credentials FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_016()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        USERS="$PUSER1 $PUSER2"
        for c in $CLIENTS ; do 
		eval_vars $c
                message "Working on $FULLHOSTNAME" 
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
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

sssd_ldap_017()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        GROUPS="$PGROUP1 $PGROUP2"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
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

sssd_ldap_018()
{
        myresult=PASS
        message "START $tet_thistest: Users uidNumbers below minId and above maxId - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        USERS="$PUSER3 $PUSER4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $USERS ; do
                   echo $RET | grep $item
                   if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item user not to be returned: uidNumber out of allowed range."
                        myresult=FAIL
                   else
                        message "$item user not returned as expected."
                  fi
                done

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_019()
{
        myresult=PASS
        message "START $tet_thistest: Groups gidNumbers below minId and above maxId - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        GROUPS="$PGROUP3 $PGROUP4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $GROUPS ; do
                   echo $RET | grep $item
                   if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $item group not to be returned: gidNumber out of allowed range."
                        myresult=FAIL
                   else
                        message "$item group not returned as expected."
                  fi
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_020()
{
        myresult=PASS
        message "START $tet_thistest: Non Posix User - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                echo $RET | grep $USER5
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $USER5 user not to be returned: user not a Posix User."
                        myresult=FAIL
                   else
                        message "$USER5 user not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_021()
{
        myresult=PASS
        message "START $tet_thistest: Non Posix Group - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                echo $RET | grep $GROUP5
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $GROUP5 group not to be returned: group not a Posix Group."
                        myresult=FAIL
                   else
                        message "$GROUP5 group not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_022()
{
   ####################################################################
   #   Configuration 4
   #    enumerate: TRUE
   #    minId: 1000
   #    useFullyQualifiedNames: TRUE
   #    provider: ldap
   #    cache-credentials: TRUE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 4 - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_ldap4.conf
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

                verifyCfg $FULLHOSTNAME LDAP enumerate TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP minId 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP provider ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP cache\-credentials TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP useFullyQualifiedNames TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_023()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - No maxId - FQN - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        USERS="$PUSER1 $PUSER2 $PUSER4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $USERS ; do
                   echo $RET | grep $item@LDAP
                   if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item@LDAP user to be returned."
                        myresult=FAIL
                   else
                        message "$item@LDAP user returned as expected."
                  fi
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_024()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - No maxId - FQN - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        GROUPS="$PGROUP1 $PGROUP2 $PGROUP4"
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $GROUPS ; do
                   echo $RET | grep $item@LDAP
                   if [ $? -ne 0 ] ; then
                        message "ERROR: Expected $item@LDAP group to be returned."
                        myresult=FAIL
                   else
                        message "$item@LDAP group returned as expected."
                  fi
                done
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_025()
{
        myresult=PASS
        message "START $tet_thistest: User uidNumber not within allowed range - FQN - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                echo $RET | grep $PUSER3@LDAP
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $PUSER3@LDAP user not to be returned: uidNumber out of allowed range."
                        myresult=FAIL
                else
                        message "$PUSER3@LDAP user not returned as expected."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_026()
{
        myresult=PASS
        message "START $tet_thistest: Group gidNumber not within allowed range - FQN - RHDS - provider ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi 
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                echo $RET | grep $PGROUP3@LDAP
                if [ $? -eq 0 ] ; then
                        message "ERROR: Expected $PGROUP3@LDAP group not to be returned: gidNumber out of allowed range."
                        myresult=FAIL
                else
                        message "$PGROUP3@LDAP group not returned as expected."
               fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_027()
{
        myresult=PASS
        message "START $tet_thistest: New User added - cache test - RHDS - provider ldap"

        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
               # add a new ldap user within valid ID range
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -a -f $LDIFS/newuser.ldif

                # search for the new user
                ssh root@$FULLHOSTNAME "getent -s sss passwd nuser@LDAP"
                if [ $? -ne 0 ] ; then
                        message "New user not found yet. Waiting for cache to expire."
                        sleep 10
                        ssh root@$FULLHOSTNAME "getent -s sss passwd nuser@LDAP"
                        if [ $? -ne 0 ] ; then
                                message "New user still not found even after cache timeout expired"
                                myresult=FAIL
                        else
                                message "New user found after cache expired."
                        fi
		else
                        message "New user added was found on first search attempt."
                fi

                # delete the ldap user
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/deluser.ldif
        done

        result $myresult
        message "END $tet_thistest"

}

sssd_ldap_028()
{
        myresult=PASS
        message "START $tet_thistest: New Group added - cache test - RHDS - provider ldap"

        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                # add a new ldap group within valid ID range
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -a -f $LDIFS/newgroup.ldif

                # search for the new group
                ssh root@$FULLHOSTNAME "getent -s sss group group1005@LDAP"
                if [ $? -ne 0 ] ; then
                        message "New group not found yet. Waiting for cache to expire."
                        sleep 10
                        ssh root@$FULLHOSTNAME "getent -s sss group nuser@LDAP"
                        if [ $? -ne 0 ] ; then
                                message "New group still not found even after cache timeout expired"
                                myresult=FAIL
                        else
                                message "New group found after cache expired."
                        fi
                else
                        message "New group added was found on first search attempt."
                fi

                # delete the ldap user
		/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/delgroup.ldif
        done

        result $myresult
        message "END $tet_thistest"

}

cleanup()
{
  myresult=PASS
  message "START $tet_this_test: Cleanup Clients"
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"
        sssdClientCleanup $FULLHOSTNAME 
        if [ $? -ne 0 ] ; then
                message "ERROR:  SSSD Client Cleanup did not complete successfully on client $FULLHOSTNAME."
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "yum -y erase sssd ; rm -rf /var/lib/sss/ ; rm -rf /etc/sssd/ ; yum clean all"
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
. $TESTING_SHARED/shared.sh
. $TESTING_SHARED/sssdlib.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF

