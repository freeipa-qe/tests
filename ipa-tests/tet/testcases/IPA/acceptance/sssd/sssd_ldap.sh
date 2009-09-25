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
ic1="sssd_ldap_001 sssd_ldap_002 sssd_ldap_003 sssd_ldap_004 sssd_ldap_005 sssd_ldap_006 sssd_ldap_007 sssd_ldap_008 sssd_ldap_009 sssd_ldap_010 sssd_ldap_011"
ic2="sssd_ldap_012 sssd_ldap_013 sssd_ldap_014 sssd_ldap_015 sssd_ldap_016 sssd_ldap_017 sssd_ldap_018 sssd_ldap_019 sssd_ldap_020"
ic3="sssd_ldap_021 sssd_ldap_022 sssd_ldap_023 sssd_ldap_024 sssd_ldap_025 sssd_ldap_026 sssd_ldap_027 sssd_ldap_028 sssd_ldap_029 sssd_ldap_030 sssd_ldap_031"
ic4="sssd_ldap_032 sssd_ldap_033 sssd_ldap_034 sssd_ldap_035 sssd_ldap_036 sssd_ldap_037 sssd_ldap_038 sssd_ldap_039 sssd_ldap_040"
ic5="sssd_ldap_041 sssd_ldap_042 sssd_ldap_043 sssd_ldap_044"
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
HOMEDIR="$TET_ROOT/testcases/IPA/acceptance/sssd"
export HOMEDIR LDIFS
USEFQN="use_fully_qualified_names"
PROVIDER="id_provider"
MAXID="max_id"
MINID="min_id"
CACHECREDS="cache_credentials"
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

sssd_ldap_001()
{
   ####################################################################
   #   Configuration 1
   #    enumerate: TRUE
   #    $MINID: 1000
   #    $MAXID: 1010
   #    $PROVIDER: proxy
   #    cache-credentials: FALSE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 1 - RHDS - $PROVIDER proxy"
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

                verifyCfg $FULLHOSTNAME LDAP $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $MAXID 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $PROVIDER proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $CACHECREDS FALSE
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
        message "START $tet_thistest: Get Valid LDAP Users - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
		RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
		for item in $PUSER1 $PUSER2 ; do
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
        message "START $tet_thistest: Get Valid LDAP Groups - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $PGROUP1 $PGROUP2 ; do
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
        message "START $tet_thistest: Users uidNumbers below $MINID and above $MAXID - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $PUSER3 $PUSER4 ; do
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
        message "START $tet_thistest: Groups gidNumbers below $MINID and above $MAXID - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $PGROUP3 $PGROUP4 ; do
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
        message "START $tet_thistest: Non Posix User - RHDS - $PROVIDER proxy"
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
        message "START $tet_thistest: Non Posix Group - RHDS - $PROVIDER proxy"
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

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with password assigned - proxy - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		rm -rf $TET_TMP_DIR/expect-ssh-success-proxyldap-out.txt
		
                expect $HOMEDIR/expect/ssh.exp puser1 $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-success-proxyldap-out.txt
		cat $TET_TMP_DIR/expect-ssh-success-proxyldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
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

sssd_ldap_009()
{

        myresult=PASS
        message "START $tet_thistest: Change User's password - proxy - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	# change LDAP user's password
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
		rm -rf $TET_TMP_DIR/expect-ssh-success-newpwd-proxyldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1 $FULLHOSTNAME onLine4now > $TET_TMP_DIR/expect-ssh-success-newpwd-proxyldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-newpwd-proxyldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
                        echo $?
                        message "ERROR: User with password assigned failed authentication!"
                        myresult=FAIL
                else
                        message "User with password assigned successfully authentication."
                fi

        done

	# change LDAP user's password back to original
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_010()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user without password assigned - proxy - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi 

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-nopasswd-proxyldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser2 $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-nopasswd-proxyldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-nopasswd-proxyldap-out.txt | grep "Permission denied"
                if [ $? -ne 0 ] ; then
                        echo $? 
                        message "ERROR: User without password assigned did not get Permission denied.  See $TET_TMP_DIR/expect-ssh-nopasswd-proxyldap-out.txt!"
                        myresult=FAIL
                else
                        message "User without password assigned failed authentication - Permission denied."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_011()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with incorrect password - proxy - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-badpasswd-proxyldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1 $FULLHOSTNAME thisisabadpwd > $TET_TMP_DIR/expect-ssh-badpasswd-proxyldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-badpasswd-proxyldap-out.txt | grep "Permission denied"
                if [ $? -ne 0 ] ; then
                        echo $?
                        message "ERROR: User with incorrect password did not get Permission denied.  See $TET_TMP_DIR/expect-ssh-nopasswd-proxyldap-out.txt!"
                        myresult=FAIL
                else
                        message "User with incorrect password assigned failed authentication - Permission denied."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}


sssd_ldap_012()
{
   ####################################################################
   #   Configuration 2
   #    enumerate: TRUE
   #    $MINID: 1000
   #	$USEFQN: TRUE
   #    $PROVIDER: proxy
   #    cache-credentials: TRUE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 2 - RHDS - $PROVIDER proxy"
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

                verifyCfg $FULLHOSTNAME LDAP $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $PROVIDER proxy
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $CACHECREDS TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $USEFQN TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_013()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - No $MAXID - FQN - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME "getent -s sss passwd 2>&1"`
                for item in $PUSER1 $PUSER2 $PUSER4 ; do
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

sssd_ldap_014()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - No $MAXID - FQN - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME "getent -s sss group 2>&1"`
                for item in $PGROUP1 $PGROUP2 $PGROUP4 ; do
		   echo $RET
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

sssd_ldap_015()
{
        myresult=PASS
        message "START $tet_thistest: User uidNumber not within allowed range - FQN - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME "getent -s sss passwd 2>&1"`
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

sssd_ldap_016()
{
        myresult=PASS
        message "START $tet_thistest: Group gidNumber not within allowed range - FQN - RHDS - $PROVIDER proxy"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi 
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME "getent -s sss group 2>&1"`
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

sssd_ldap_017()
{
        myresult=PASS
        message "START $tet_thistest: New User added - cache test - RHDS - $PROVIDER proxy"

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

sssd_ldap_018()
{
        myresult=PASS
        message "START $tet_thistest: New Group added - cache test - RHDS - $PROVIDER proxy"

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

sssd_ldap_019()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with password assigned - Proxy - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt
 
                expect $HOMEDIR/expect/ssh.exp puser1@LDAP $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
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

sssd_ldap_020()
{

        myresult=PASS
        message "START $tet_thistest: Caching on - Change User's password - proxy - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        # change LDAP user's password
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt
		message "Authenticate with new password expecting success"
                expect $HOMEDIR/expect/ssh.exp puser1@LDAP $FULLHOSTNAME onLine4now > $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
                        message "ERROR: User authentication with new password against failed! See $TET_TMP_DIR/expect-ssh-success-fqn-proxyldap-out.txt for details."
                        myresult=FAIL
                else
                        message "User authentication with new password successful."
                fi
        done

        # change LDAP user's password back to original
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_021()
{
   ####################################################################
   #   Configuration 3
   #    enumerate: TRUE
   #    $MINID: 1000
   #    $MAXID: 1010
   #    $PROVIDER: ldap 
   #    cache-credentials: FALSE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 3 - RHDS - $PROVIDER ldap"

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

                verifyCfg $FULLHOSTNAME LDAP $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $MAXID 1010
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $PROVIDER ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $CACHECREDS FALSE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_022()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - RHDS - $PROVIDER ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do 
		eval_vars $c
                message "Working on $FULLHOSTNAME" 
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $PUSER1 $PUSER2 ; do
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

sssd_ldap_023()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - RHDS - $PROVIDER ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $PGROUP1 $PGROUP2 ; do
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

sssd_ldap_024()
{
        myresult=PASS
        message "START $tet_thistest: Users uidNumbers below $MINID and above $MAXID - RHDS - $PROVIDER ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $PUSER3 $PUSER4 ; do
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

sssd_ldap_025()
{
        myresult=PASS
        message "START $tet_thistest: Groups gidNumbers below $MINID and above $MAXID - RHDS - $PROVIDER ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $PGROUP3 $PGROUP4 ; do
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

sssd_ldap_026()
{
        myresult=PASS
        message "START $tet_thistest: Non Posix User - RHDS - $PROVIDER ldap"
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

sssd_ldap_027()
{
        myresult=PASS
        message "START $tet_thistest: Non Posix Group - RHDS - $PROVIDER ldap"
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

sssd_ldap_028()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with password assigned - native - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-nativeldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1 $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-success-nativeldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-nativeldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
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

sssd_ldap_029()
{

        myresult=PASS
        message "START $tet_thistest: Change User's password - native - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        # change LDAP user's password
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-newpwd-nativeldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1 $FULLHOSTNAME onLine4now > $TET_TMP_DIR/expect-ssh-success-newpwd-nativeldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-newpwd-nativeldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
                        echo $?
                        message "ERROR: User with password assigned failed authentication!"
                        myresult=FAIL
                else
                        message "User with password assigned successfully authentication."
                fi

        done

        # change LDAP user's password back to original
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_030()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user without password assigned - native - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-nopasswd-nativeldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser2 $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-nopasswd-nativeldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-nopasswd-nativeldap-out.txt | grep "Permission denied"
                if [ $? -ne 0 ] ; then
                        echo $?
                        message "ERROR: User without password assigned did not get Permission denied.  See $TET_TMP_DIR/expect-ssh-nopasswd-nativeldap-out.txt!"
                        myresult=FAIL
                else
                        message "User without password assigned failed authentication - Permission denied."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_031()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with incorrect password - native - no FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-badpasswd-nativeldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1 $FULLHOSTNAME thisisabadpwd > $TET_TMP_DIR/expect-ssh-badpasswd-nativeldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-badpasswd-nativeldap-out.txt | grep "Permission denied"
                if [ $? -ne 0 ] ; then
                        echo $?
                        message "ERROR: User with incorrect password did not get Permission denied.  See $TET_TMP_DIR/expect-ssh-nopasswd-nativeldap-out.txt!"
                        myresult=FAIL
                else
                        message "User with incorrect password assigned failed authentication - Permission denied."
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_032()
{
   ####################################################################
   #   Configuration 4
   #    enumerate: TRUE
   #    $MINID: 1000
   #    $USEFQN: TRUE
   #    $PROVIDER: ldap
   #    cache-credentials: TRUE
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 4 - RHDS - $PROVIDER ldap"
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

                verifyCfg $FULLHOSTNAME LDAP $MINID 1000
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $PROVIDER ldap
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $CACHECREDS TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

                verifyCfg $FULLHOSTNAME LDAP $USEFQN TRUE
                if [ $? -ne 0 ] ; then
                        myresult=FAIL
                fi

        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_033()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - No $MAXID - FQN - RHDS - $PROVIDER ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $PUSER1 $PUSER2 $PUSER4 ; do
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

sssd_ldap_034()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - No $MAXID - FQN - RHDS - $PROVIDER ldap"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
		eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $PGROUP1 $PGROUP2 $PGROUP4 ; do
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

sssd_ldap_035()
{
        myresult=PASS
        message "START $tet_thistest: User uidNumber not within allowed range - FQN - RHDS - $PROVIDER ldap"
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

sssd_ldap_036()
{
        myresult=PASS
        message "START $tet_thistest: Group gidNumber not within allowed range - FQN - RHDS - $PROVIDER ldap"
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

sssd_ldap_037()
{
        myresult=PASS
        message "START $tet_thistest: New User added - cache test - RHDS - $PROVIDER ldap"

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

sssd_ldap_038()
{
        myresult=PASS
        message "START $tet_thistest: New Group added - cache test - RHDS - $PROVIDER ldap"

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

sssd_ldap_039()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with password assigned - native - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1@LDAP $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
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

sssd_ldap_040()
{

        myresult=PASS
        message "START $tet_thistest: Change User's password - native - FQN"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        # change LDAP user's password
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/newpwd.ldif

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt
                message "Authenticate with new password expecting success"
                expect $HOMEDIR/expect/ssh.exp puser1@LDAP $FULLHOSTNAME onLine4now > $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
                        message "ERROR: User authentication with new password against failed! See $TET_TMP_DIR/expect-ssh-success-fqn-nativeldap-out.txt for details."
                        myresult=FAIL
                else
                        message "User authentication with new password successful."
                fi
        done

        # change LDAP user's password back to original
        echo "/usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif"
        /usr/bin/ldapmodify -x -h $RH_DIRSERV -p $PORT -D "$ROOTDN" -w $ROOTDNPW -f $LDIFS/restorepwd.ldif

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_041()
{
   ####################################################################
   #   Configuration 5
   #    ldaps 
   #    tls_reqcert = hard 
   ####################################################################

        myresult=PASS
        message "START $tet_thistest: Setup LDAP SSSD Configuration 5 - native - FQN - LDAPS - TLS"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                message "Backing up original sssd.conf and copying over test sssd.conf"
                sssdCfg $FULLHOSTNAME sssd_ldap5.conf
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
        done

        result $myresult
        message "END $tet_thistest"
}

sssd_ldap_042()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Users - native - FQN - LDAPS - TLS"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss passwd 2>&1`
                for item in $PUSER1 $PUSER2 $PUSER4 ; do
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

sssd_ldap_043()
{
        myresult=PASS
        message "START $tet_thistest: Get Valid LDAP Groups - native - FQN - LDAPS - TLS"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $CLIENTS ; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                RET=`ssh root@$FULLHOSTNAME getent -s sss group 2>&1`
                for item in $PGROUP1 $PGROUP2 $PGROUP4 ; do
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

sssd_ldap_044()
{

        myresult=PASS
        message "START $tet_thistest: Authentication ldap user with password assigned - native - FQN - LDAPS - TLS"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

        for c in $CLIENTS; do
                eval_vars $c
                message "Working on $FULLHOSTNAME"
                rm -rf $TET_TMP_DIR/expect-ssh-success-fqn-nativeldaps-out.txt

                expect $HOMEDIR/expect/ssh.exp puser1@LDAP $FULLHOSTNAME Secret123 > $TET_TMP_DIR/expect-ssh-success-fqn-nativeldaps-out.txt
                cat $TET_TMP_DIR/expect-ssh-success-fqn-nativeldapx-out.txt | grep "Permission denied"
                if [ $? -eq 0 ] ; then
                        echo $?
                        message "ERROR: User with password assigned failed authentication! See $TET_TMP_DIR/expect-ssh-success-fqn-nativeldaps-out.txt for details."
                        myresult=FAIL
                else
                        message "User with password assigned successfully authentication."
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

