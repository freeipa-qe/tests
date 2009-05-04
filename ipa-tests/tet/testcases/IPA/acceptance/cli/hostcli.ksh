#!/bin/ksh

######################################################################
# The following ipa cli commands needs to be tested:
#  host-add                  Add a new host.
#  host-del                  Delete an existing host.
#  host-find                 Search the hosts.
#  host-mod                  Edit an existing host.
#  host-show                 Examine an existing host.
#  hostgroup-add             Add a new hostgroup.
#  hostgroup-add-member      Add a member to a hostgroup.
#  hostgroup-del             Delete an existing hostgroup.
#  hostgroup-find            Search the groups.
#  hostgroup-mod             Edit an existing hostgroup.
#  hostgroup-remove-member   Remove a member from a hostgroup.
#  hostgroup-show            Examine an existing hostgroup.
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10"
ic0="kinit"
ic1="hostcli_001" 
ic2="hostcli_002"
ic3="hostcli_003"
ic4="hostcli_004"
ic5="hostcli_005" 
ic6="hostcli_006" 
ic7="hostcli_007"
ic8="hostcli_008"
ic9="hostcli_009"
ic10="hostcli_010"

######################################################################
#  Variables
######################################################################

REALM="bos.redhat.com"

host1="jennyv4."$REALM
host2="JENNYV4."$REALM
host3="JENNYV3."$REALM
host4="jennyv3."$REALM
host5="my-dashing-host."$REALM

######################################################################

kinit()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		else
			echo "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

hostcli_001()
{
        echo "START $tet_thistest: Add lower case host"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa host-add
			ssh root@$FULLHOSTNAME "ipa host-add \"$host1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa host-add failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# Verifying lower case
			ssh root@$FULLHOSTNAME "ipa host-find \"$host1\" | grep $host1"
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-find \"$host1\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# Verifying upper case
                        ssh root@$FULLHOSTNAME "ipa host-find \"$host2\" | grep $host1"
                        if [ $? -ne 0 ]
                        then
                                echo "ERROR - ipa host-find \"$host2\" failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

hostcli_002()
{
        echo "START $tet_thistest: Add host UPPER case"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s

                        # test for ipa host-add
                        ssh root@$FULLHOSTNAME "ipa host-add \"$host3\""
                        ret=$?
                        if [ $ret -ne 0 ]
                        then
                                echo "ERROR - ipa host-add failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi
                        # Verifying upper case
                        ssh root@$FULLHOSTNAME "ipa host-find \"$host3\" | grep $host4"
                        if [ $? -ne 0 ]
                        then
                                echo "ERROR - ipa host-find \"$host3\" failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi
                        # Verifying lower case
                        ssh root@$FULLHOSTNAME "ipa host-find \"$host4\" | grep $host4"
                        if [ $? -ne 0 ]
                        then
                                echo "ERROR - ipa host-find \"$host4\" failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi

                fi
        done

        tet_result PASS
        echo "END $tet_thistest"

}

hostcli_003()
{
        echo "START $tet_thistest: Add host with dashes in hostname"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s

                        # test for ipa host-add
                        ssh root@$FULLHOSTNAME "ipa host-add \"$host5\""
                        ret=$?
                        if [ $ret -ne 0 ]
                        then
                                echo "ERROR - ipa host-add failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi
                        # Verifying
                        ssh root@$FULLHOSTNAME "ipa host-find \"$host5\" | grep $host5"
                        if [ $? -ne 0 ]
                        then
                                echo "ERROR - ipa host-find \"$host5\" failed on $FULLHOSTNAME"
                               tet_result FAIL
                        fi
                fi
        done

        tet_result PASS
        echo "END $tet_thistest"
}

hostcli_004()
{
	echo "START $tet_thistest: Modify host location"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
		   for item in $host1 $host3 $host5 ; do

                        location='IDM Westford lab 3'
			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --location=\"$location\" \"$item\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi

			# check value
			value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep location:"`
		        value=`echo $value | awk -F: '{print $2}'`
			#trim white space
			value=`echo $value`
			if [ "$value" != "$location" ]
			then
				echo "ERROR - \"$item\" location not correct on $FULLHOSTNAME expected: $location  got: $value"
				tet_result FAIL
			else
				echo "Host \"$item\" location is as expected: $value"
			fi
		  done
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

hostcli_005()
{
	echo "START $tet_thistest: Modify host platform"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
		  for item in $host1 $host3 $host5 ; do

			platform="MAC"
		  	# check return code
			  ssh root@$FULLHOSTNAME "ipa host-mod --platform=$platform \"$item\""
		  	if [ $? -ne 0 ] ; then
				echo "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi

			# check value
			value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep platform:"`
                        value=`echo $value | awk -F: '{print $2}'`
                        #trim white space
                        value=`echo $value`
                        if [ "$value" != "$platform" ]
                        then
                                echo "ERROR - \"$item\" platform not correct on $FULLHOSTNAME expected: $platform  got: $value"
                                tet_result FAIL
                        else
                                echo "Host \"$item\" location is as expected: $value"
                        fi
                   done
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

hostcli_006()
{
	echo "START $tet_thistest: Modify host os"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ] ; then
		eval_vars $s
                 for item in $host1 $host3 $host5 ; do

			os=osx
			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --os=$os \"$item\""
			if [ $? -ne 0 ] ; then
				echo "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi

			# check value
			value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep nsosversion:"`
                        value=`echo $value | awk -F: '{print $2}'`
                        #trim white space
                        value=`echo $value`
                        if [ "$value" != "$os" ]
                        then
                                echo "ERROR - \"$item\" OS not correct on $FULLHOSTNAME expected: $os  got: $value"
                                tet_result FAIL
                        else
                                echo "Host \"$item\" OS is as expected: $value"
                        fi

                 done
		fi
	done
	
        tet_result PASS
	echo "END $tet_thistest"
}

hostcli_007()
{
	echo "START $tet_thistest: Modify host description"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
		 for item in $host1 $host3 $host5 ; do

			description='interesting description'
			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --description=\"$description\" \"$item\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			
			# check output
			value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep description:"`
                        value=`echo $value | awk -F: '{print $2}'`
                        #trim white space
                        value=`echo $value`
                        if [ "$value" != "$description" ]
                        then
                                echo "ERROR - \"$item\" description not correct on $FULLHOSTNAME expected: \"$description\"  got: \"$value\""
                                tet_result FAIL
                        else
                                echo "Host \"$item\" description is as expected: \"$description\""
                        fi
		 done

		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

hostcli_008()
{
	echo "START $tet_thistest: Modify host locality"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
                   for item in $host1 $host3 $host5 ; do

			local='Mountain View, CA'
			# check return code
			ssh root@$FULLHOSTNAME "ipa host-mod --locality=\"$local\" \"$item\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-mod \"$item\" failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			# check output
			value=`ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep localityname:"`
                        value=`echo $value | awk -F: '{print $2}'`
                        #trim white space
                        value=`echo $value`
                        if [ "$value" != "$local" ]
                        then
                                echo "ERROR - \"$item\" locality not correct on $FULLHOSTNAME expected: $local  got: $value"
                                tet_result FAIL
                        else
                                echo "Host \"$item\" local is as expected: $value"
                        fi
                     done
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

hostcli_009()
{
        echo "START $tet_thistest: Show existing valid host"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s
                  for item in $host1 $host4 $host5 ; do
                        # check return code
                        ssh root@$FULLHOSTNAME "ipa host-show \"$item\""
                        if [ $? -ne 0 ]
                        then
                                echo "ERROR - ipa host-show \"$item\" failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi
                        # check output
                        ssh root@$FULLHOSTNAME "ipa host-show \"$item\" | grep $item"
                        if [ $? -ne 0 ]
                        then
                                echo "ERROR - ipa host-show \"$item\" failed on $FULLHOSTNAME"
                                tet_result FAIL
                        fi
                  done
                fi
        done

        tet_result PASS
        echo "END $tet_thistest"

}

hostcli_010()
{
	echo "START $tet_thistest: Delete hosts"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
		  for item in $host1 $host3 $host5 ; do
			# check return code
			ssh root@$FULLHOSTNAME "ipa host-del \"$item\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa host-del \"$item\" failed on $FULLHOSTNAME rc:$?"
				tet_result FAIL
			fi
			# check return code
			ssh root@$FULLHOSTNAME "ipa host-show \"$item\""
			if [ $? -ne 161 ]
			then
				echo "ERROR - ipa host-show \"$item\" return code not as expected on $FULLHOSTNAME got:$? expected: 161"
				tet_result FAIL
			fi
		  done
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

