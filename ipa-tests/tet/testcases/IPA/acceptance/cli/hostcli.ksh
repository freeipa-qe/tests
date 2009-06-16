#!/bin/ksh

######################################################################
# The following ipa cli commands needs to be tested:
#  host-add                  Add a new host.
#  host-del                  Delete an existing host.
#  host-find                 Search the hosts.
#  host-mod                  Edit an existing host.
#  host-show                 Examine an existing host.
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10 ic11 ic12 ic13 ic14 ic15"
ic0="kinit1"
ic1="hostcli_001" 
ic2="hostcli_002"
ic3="hostcli_003"
ic4="hostcli_004"
ic5="hostcli_005" 
ic6="hostcli_006" 
ic7="hostcli_007"
ic8="hostcli_008"
ic9="hostcli_009"
ic10="bug499016"
ic11="bug499018"
ic12="hostcli_010"
ic13="hostcli_011"
ic14="hostcli_012"
ic15="hostcli_013"
########################################################################
#  sub routines
########################################################################
os_nslookup()
{
h=$1
case $ARCH in
	"Linux "*)
		rval=`nslookup -sil $h`
		if [ `expr "$rval" : "server can't find"` -gt 0 ]; then
			tmpdn=`domainname -f`
			echo "Name: $tmpdn"
			tmpaddr=`/sbin/ifconfig -a | egrep inet | egrep -v 127.0.0.1 | egrep -v inet6 | awk '{print $2}' | awk -F: '{print $2}'`
			echo "Addr: $tmpaddr"
		else
			nslookup -sil $h
		fi
		;;
	*)
		nslookup $h
		;;
esac
}

os_getdomainname()
{
   mydn=`hostname | os_nslookup 2> /dev/null | grep 'Name:' | cut -d"." -f2-`
   if [ "$mydn" = "" ]; then
     mydn=`hostname -f |  cut -d"." -f2-`
   fi
   echo "$mydn"
}

mykinit()
{
   	userid=$1
  	userpwd=$2
	rc=0
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        # Kinit everywhere
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        message "kiniting as $userid, password $userpwd on $s"
                        KinitAs $s $userid $userpwd
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
				rc=1
                        fi
                else
                        message "skipping $s"
                fi
        done
        for s in $CLIENTS; do
                if [ "$s" != "" ]; then
                        message "kiniting as $userid, password $userpwd on $s"
                        KinitAs $s $userid $userpwd
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
                      		rc=1
                        fi
                fi
        done

	return $rc
}

#######################################################################
#  Variables
######################################################################
REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN="idm.lab.bos.redhat.com"

host1="nightcrawler."$DOMAIN
host2="NIGHTCRAWLER."$DOMAIN
host3="SHADOWFALL."$DOMAIN
host4="shadowfall."$DOMAIN
host5="qe-blade-01."$DOMAIN

########################################################################
#  The following tests will be executed as the default super user - admin
########################################################################
kinit1()
{
	
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest"

	mykinit $DS_USER $DM_ADMIN_PASS
	if [ $? -ne 0 ]; then
		result FAIL
	else
		result PASS
	fi

	message "END $tet_thistest"
}

hostcli_001()
{
	myresult=PASS
        message "START $tet_thistest: Add lower case host"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	# test for ipa host-add
	ssh root@$FULLHOSTNAME "ipa host-add \"$host1\""
	if [ $? -ne 0 ]
	then
		message "ERROR - ipa host-add failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	for s in $SERVERS; do
		eval_vars $s
		message "Working on $s"
		# Verifying lower case
		ssh root@$FULLHOSTNAME "ipa host-find \"$host1\" | grep $host1"
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-find \"$host1\" failed on $FULLHOSTNAME"
			myresult=FAIL
		else
			message "ipa host-find successful for \"$host1\" on $FULLHOSTNAME"
		fi
		# Verifying upper case
                ssh root@$FULLHOSTNAME "ipa host-find \"$host2\" | grep $host1"
                if [ $? -ne 0 ] ; then
                        message "ERROR - ipa host-find \"$host2\" failed on $FULLHOSTNAME"
                        myresult=FAIL
                else
                        message "ipa host-find successful for \"$host2\" on $FULLHOSTNAME"

                fi

	done

	result $myresult
	message "END $tet_thistest"

}

hostcli_002()
{
	myresult=PASS
        message "START $tet_thistest: Add host UPPER case"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        eval_vars M1
        # test for ipa host-add
        ssh root@$FULLHOSTNAME "ipa host-add \"$host3\""
        if [ $? -ne 0 ] ; then
        	message "ERROR - ipa host-add failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
                # Verifying upper case
                ssh root@$FULLHOSTNAME "ipa host-find \"$host3\" | grep $host4"
                if [ $? -ne 0 ] ; then
                	message "ERROR - ipa host-find \"$host3\" failed on $FULLHOSTNAME"
                        myresult=FAIL
                else
                        message "ipa host-find successful for \"$host3\" on $FULLHOSTNAME"
		fi
                # Verifying lower case
                ssh root@$FULLHOSTNAME "ipa host-find \"$host4\" | grep $host4"
                if [ $? -ne 0 ] ; then
                	message "ERROR - ipa host-find \"$host4\" failed on $FULLHOSTNAME"
                        myresult=FAIL
                else
                        message "ipa host-find successful for \"$host4\" on $FULLHOSTNAME"
                fi
        done

        result $myresult
        message "END $tet_thistest"

}

hostcli_003()
{
	myresult=PASS
        message "START $tet_thistest: Add host with dashes in hostname"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        eval_vars M1
        # test for ipa host-add
        ssh root@$FULLHOSTNAME "ipa host-add \"$host5\""
        if [ $? -ne 0 ] ; then
        	message "ERROR - ipa host-add failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
                # Verifying
                ssh root@$FULLHOSTNAME "ipa host-find \"$host5\" | grep $host5"
                if [ $? -ne 0 ] ; then
                	message "ERROR - ipa host-find \"$host5\" failed on $FULLHOSTNAME"
                        myresult=FAIL
                else
                        message "ipa host-find successful for \"$host5\" on $FULLHOSTNAME"
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

hostcli_004()
{
	myresult=PASS
	message "START $tet_thistest: Modify host location"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	for item in $host1 $host3 $host5 ; do
        	location='IDM Westford lab 3'
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-mod --location=\"$location\" \"$item\""
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
			myresult=FAIL
		fi
	done
	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
		# check value
		value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep location:"`
		value=`echo $value | awk -F: '{print $2}'`
		#trim white space
		value=`echo $value`
		if [ "$value" != "$location" ] ; then
			message "ERROR - \"$item\" location not correct on $FULLHOSTNAME expected: $location  got: $value"
			myresult=FAIL
		else
			message "Host \"$item\" location is as expected: $value"
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

hostcli_005()
{
	myresult=PASS
	message "START $tet_thistest: Modify host platform"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	for item in $host1 $host3 $host5 ; do
		platform="x86_64"
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-mod --platform=\"$platform\" \"$item\""
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
			myresult=FAIL
		fi
	done
	
	# check value
	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
		value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep nshardwareplatform:"`
                value=`echo $value | awk -F: '{print $2}'`
                #trim white space
                value=`echo $value`
		echo $value
                if [ "$value" != "$platform" ] ; then
                	message "ERROR - \"$item\" platform not correct on $FULLHOSTNAME expected: $platform  got: $value"
                        myresult=FAIL
                else
                        message "Host \"$item\" platform is as expected: $value"
                fi
	done

	result $myresult
	message "END $tet_thistest"

}

hostcli_006()
{
	myresult=PASS
	message "START $tet_thistest: Modify host os"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
        for item in $host1 $host3 $host5 ; do
		os="Fedora 11"
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-mod --os=\"$os\" \"$item\""
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
			myresult=FAIL
		fi
	done

	# check value
	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
		value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep nsosversion:"`
                value=`echo $value | awk -F: '{print $2}'`
                #trim white space
                value=`echo $value`
                if [ "$value" != "$os" ] ; then
                	message "ERROR - \"$item\" OS not correct on $FULLHOSTNAME expected: $os  got: $value"
                        myresult=FAIL
                else
                        message "Host \"$item\" OS is as expected: $value"
                fi
	done
	
        result $myresult
	message "END $tet_thistest"
}

hostcli_007()
{
	myresult=PASS
	message "START $tet_thistest: Modify host description"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	for item in $host1 $host3 $host5 ; do
		description='interesting description'
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-mod --description=\"$description\" \"$item\""
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
			myresult=FAIL
		fi
	done

	# check output
	for s in $SERVERS ; do
		eval_vars $s
		message "Working on M1"
		value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep description:"`
                value=`echo $value | awk -F: '{print $2}'`
                #trim white space
                value=`echo $value`
                if [ "$value" != "$description" ] ; then
                	message "ERROR - \"$item\" description not correct on $FULLHOSTNAME expected: \"$description\"  got: \"$value\""
                        myresult=FAIL
                else
                        message "Host \"$item\" description is as expected: \"$description\""
                fi
	done

	result $myresult
	message "END $tet_thistest"
}

hostcli_008()
{
	myresult=PASS
	message "START $tet_thistest: Modify host locality"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
        for item in $host1 $host3 $host5 ; do
		local='Mountain View, CA'
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-mod --locality=\"$local\" \"$item\""
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
			myresult=FAIL
		fi
	done

	# check output
	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
		value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep localityname:"`
                value=`echo $value | awk -F: '{print $2}'`
                #trim white space
                value=`echo $value`
                if [ "$value" != "$local" ] ; then
                	message "ERROR - \"$item\" locality not correct on $FULLHOSTNAME expected: $local  got: $value"
                        myresult=FAIL
                else
                        message "Host \"$item\" local is as expected: $value"
                fi
 	done

	result $myresult
	message "END $tet_thistest"

}

hostcli_009()
{
   myresult=PASS
   tmpfile=$TET_TMP_DIR"/showall.txt"
   message "START $tet_thistest: host-show --all"
   echo "Tempory file is: " $tmpfile
   if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
   for s in $SERVERS ; do
	  eval_vars $s
	  message "Working on $s"
	  #verify objectclasses are returned
	  set -A classes nshost ipahost pkiuser krbprincipalaux krbprincipal top
          
	  ssh root@$FULLHOSTNAME "ipa host-show --all \"$host1\"" > $tmpfile
	  i=0 
          while [ $i -le 5 ] ; do
		cat $tmpfile | grep "${classes[$i]}"
		if [ $? -ne 0 ] ; then
			message "ERROR - objectclass \"${classes[$i]}\" was not returned with host-show --all"
			myresult=FAIL
		else
			message "objectclass \"${classes[$i]}\" was returned as expected with host-show --all"
		fi
		((i=$i+1))
	  done
	  
	  # verify enrolledby
	  value=`cat $tmpfile | grep enrolledby: | awk -F: '{print $2}' | awk -F, '{print $1}' | awk -F= '{print $2}'`
	  if [ $value != "admin" ] ; then
		message "ERROR - host-show all returned unexpected value for enrolledby. expected: admin got: $value"
		myresult=FAIL
	  else
		message "host-show --all returned expected value for enrolledby - $value."
 	  fi

	  # verify serverhostname
	  shortname=`echo $host1 | cut -d. -f1`
	  value=`cat $tmpfile | grep serverhostname: | awk -F: '{print $2}'`
	  # trim white space
	  echo $value
	  if [ $value != $shortname ] ; then
		message "ERROR - host-show --all returned unexpected value for serverhostname. expected: $shortname got: $value"
		myresult=FAIL
	  else
		message "host-show --all returned expected value for serverhostname - $value."
 	  fi

	  # verify krbprincipalname
	  princname="host/$host1@$REALM"
	  value=`cat $tmpfile | grep krbprincipalname: | awk -F: '{print $2}'`
	  # trim white space
	  echo $value
	  if [ $value != $princname ] ; then
		message "ERROR - host-show --all returned unexpected value for krbprincipalname. expected: $princname got: $value"
		myresult=FAIL
	  else
		message "host-show --all returned expected value for krbprincipalname - $value"
	  fi

	  rm -rf $tmpfile
   done

   result $myresult
   message "END $tet_thistest"
}

bug499016()
{
   # modifying any option, results in the os and platform attributes to be modified to the values on which the modification is 
   # being done - can't garantee that - it may be happening on an admin's machine that has a different OS and platform
   # modify the os
   # verify the value
   # modify a different attribute - description
   # verify the os is unchanged

   myresult=PASS
   message "START $tet_thistest: os and platform after modification"

   if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
   os="Fedora 11"
   # check return code
   ssh root@$FULLHOSTNAME "ipa host-mod --os=\"$os\" \"$host1\""
   if [ $? -ne 0 ] ; then
	message "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
        myresult=FAIL
   fi

   # check value
   for s in $SERVERS ; do
	eval_vars $s
	message "Working on $s"
        value=`ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep nsosversion:"`
        value=`echo $value | awk -F: '{print $2}'`
        #trim white space
        value=`echo $value`
        if [ "$value" != "$os" ] ; then
        	message "ERROR - \"$host1\" OS not correct on $FULLHOSTNAME expected: $os  got: $value"
                myresult=FAIL
        else
                message "Host \"$host1\" OS is as expected: $value"
        fi
    done

    eval_vars M1
    description='this is a really interesting description'
    # check return code
    ssh root@$FULLHOSTNAME "ipa host-mod --description=\"$description\" \"$host1\""
    if [ $? -ne 0 ] ; then
    	message "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
        myresult=FAIL
    fi

    # check value
    for s in $SERVERS ; do
	eval_vars $s
	message "Working on $s"
    	value=`ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep nsosversion:"`
        value=`echo $value | awk -F: '{print $2}'`
        #trim white space
        value=`echo $value`
        if [ "$value" != "$os" ] ; then
        	message "ERROR - \"$host1\" OS not correct on $FULLHOSTNAME expected: $os  got: $value"
        	myresult=FAIL
        else
         	message "Host \"$host1\" OS is as expected: $value"
        fi  
   done

   result $myresult
   message "END $tet_thistest"
}

bug499018()
{
   myresult=PASS
   # modifying a host's locality results in the adding of another localityname attribute instead of modifying the existing.
   message "START $tet_thistest: modifying locality results in additional localityname attributes"
   
   # the hosts already have a value for locality so let's just modify the value again

   if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
   eval_vars M1
   local='Mountain View, CA'
   # check return code
   ssh root@$FULLHOSTNAME "ipa host-mod --locality=\"$local\" \"$host1\""
   if [ $? -ne 0 ] ; then
   	message "ERROR - ipa host-mod \"$host1\" failed on $FULLHOSTNAME"
   	myresult=FAIL
   fi

   # check output
   for s in $SERVERS ; do
	eval_vars $s
	message "Working on $s"
   	value=`ssh root@$FULLHOSTNAME "ipa host-show \"$host1\" | grep localityname:"`
        value=`echo $value | awk -F: '{print $2}'`
        #trim white space
        value=`echo $value`
        if [ "$value" != "$local" ] ; then
        	message "ERROR - \"$host1\" locality not correct on $FULLHOSTNAME expected: $local  got: $value"
        	myresult=FAIL
        else
        	message "Host \"$host1\" local is as expected: $value"
        fi
   done

   result $myresult
   message "END $tet_thistest"
}

hostcli_010()
{
	myresult=PASS
	errorcode=162
	message "START $tet_thistest: Negative - add duplicate host"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                eval_vars $s
		message "Working on $s"
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-add \"$host5\""
		ret=`echo $?`
		if [ $ret -ne $errorcode ] ; then
			message "ERROR - unexpected return code from ipa host-add.  expected: $errorcode got: $?"
			myresult=FAIL
		else
			message "ipa host-add returned expected code trying to add duplicate host."
		fi
	done
	result $myresult
	message "END $tet_thistest"
}

hostcli_011()
{
        myresult=PASS
	errorcode=161
	myhost=notthere.$DOMAIN
        message "START $tet_thistest: Negative - Host Doesn't Exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                eval_vars $s
		message "Working on $s"
                # check return code for ipa-del
                ssh root@$FULLHOSTNAME "ipa host-del \"$myhost\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-del.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-del returned expected code trying to delete a host that doesn't exist."
                fi

                # check return code for ipa-find
                ssh root@$FULLHOSTNAME "ipa host-find \"$myhost\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-find.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-find returned expected code trying to find a host that doesn't exist."
                fi

                # check return code for ipa-show
                ssh root@$FULLHOSTNAME "ipa host-show \"$myhost\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-show.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-show returned expected code trying to show a host that doesn't exist."
                fi

                # check return code for ipa-mod
                ssh root@$FULLHOSTNAME "ipa host-mod --os="Windows" \"$myhost\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-mod.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-mod returned expected code trying to modify a host that doesn't exist."
                fi
        done
        result $myresult
        message "END $tet_thistest"
}

hostcli_012()
{
        myresult=PASS
        shortname=`echo $host5 | cut -d. -f1`
        errorcode=193
        message "START $tet_thistest: Negative - Not fully qualified"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                eval_vars $s
		message "Working on $s"
                # check return code for ipa-add
                ssh root@$FULLHOSTNAME "ipa host-add \"$shortname\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-add.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-add returned expected code trying to add non FQDN host."
                fi

                # check return code for ipa-del
                ssh root@$FULLHOSTNAME "ipa host-del \"$shortname\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-del.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-del returned expected code trying to delete non FQDN host."
                fi

                # check return code for ipa-find
                ssh root@$FULLHOSTNAME "ipa host-find \"$shortname\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-find.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-find returned expected code trying to find non FQDN host."
                fi
                # check return code for ipa-show
                ssh root@$FULLHOSTNAME "ipa host-show \"$shortname\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-show.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-show returned expected code trying to show non FQDN host."
                fi

                # check return code for ipa-mod
                ssh root@$FULLHOSTNAME "ipa host-mod --os="Windows" \"$shortname\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa host-mod.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa host-mod returned expected code trying to modify non FQDN host."
                fi
        done
        result $myresult
        message "END $tet_thistest"
}
hostcli_013()
{
	myresult=PASS
	message "START $tet_thistest: Delete hosts"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	for item in $host1 $host3 $host5 ; do
		# check return code
		ssh root@$FULLHOSTNAME "ipa host-del \"$item\""
		if [ $? -ne 0 ] ; then
			message "ERROR - ipa host-del \"$item\" failed on $FULLHOSTNAME rc:$?"
			myresult=FAIL
		fi
	done

	# check return code
	for s in $SERVERS ; do
		eval_vars $s
		message "Working on $s"
		ssh root@$FULLHOSTNAME "ipa host-show \"$item\""
		if [ $? -ne 161 ] ; then
			message "ERROR - ipa host-show \"$item\" return code not as expected on $FULLHOSTNAME got:$? expected: 161"
			myresult=FAIL
		else
			message "\"$item\" deleted successfully."
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

