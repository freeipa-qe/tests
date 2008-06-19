#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10"
ic1="tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"
ic5="tp5"
ic6="tp6"
ic7="tp7"
ic8="tp8"
ic9="tp9"
ic10="tp10"

######################################################################
tp1()
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
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Create two groups on M1
	echo "START $tet_thistest"
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group1 -v -g 444 -d 'group1 for testing'"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of group1 on M1 failed"
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group2 -v -g 888 -d 'group2 for testing'"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of group2 on M1 failed"
		tet_result FAIL
	fi
	
	tet_result PASS
	echo "END $tet_thistest"
}

tp3()
{
	# verify those two groups exist everywhere
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group1 exists on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group1 | /bin/grep GID | /bin/grep 444'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group1 does not exist on $s"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group2 | /bin/grep GID | /bin/grep 888'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group2 does not exist on $s"
				tet_result FAIL
			fi

		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group1 exists on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group1 | /bin/grep GID | /bin/grep 444'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group1 does not exist on $s"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group2 | /bin/grep GID | /bin/grep 888'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group2 does not exist on $s"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# join group 2 as a user in group 1 on M1
	echo "START $tet_thistest"
	eval_vars M1 
	ssh root@$FULLHOSTNAME 'ipa-modgroup --groupadd group1 group2'
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, add of group2 to group1 on M1 failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

tp5()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# join group 1 as a user in group 2 on M1
	echo "START $tet_thistest"

	eval_vars M1 
	ssh root@$FULLHOSTNAME 'ipa-modgroup --groupadd group2 group1'
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, add of group1 to group2 on M1 failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

tp6()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Verify that group 2 is in group 1 on all hosts
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group2 is in group1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group1 | /bin/grep group2'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group2 does not exist in group1 on $s"
				tet_result FAIL
			fi

			echo "Verifying that group1 is in group2 on $s"
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group2 | /bin/grep group1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group1 does not exist in group2 on $s"
				tet_result FAIL
			fi

		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group2 is in group1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group1 | /bin/grep group2'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group2 does not exist in group1 on $s"
				tet_result FAIL
			fi

			echo "Verifying that group1 is in group2 on $s"
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group2 | /bin/grep group1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group1 does not exist in group2 on $s"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

tp7()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Verify that ipa-findgroup and grep fails when it's given bad info on all servers
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that groupf does not exist in group1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group1 | /bin/grep groupf'
			ret=$?
			if [ $ret -eq 0 ]; then
				echo "ERROR - That didn't work! $s"
				tet_result FAIL
			fi
		fi
	done


	tet_result PASS
	echo "END $tet_thistest"
}

tp8()
{
	# From: https://idmwiki.sjc.redhat.com/export/idmwiki/Testplan/ipa/replica#memberof_feature_test
	# test 1 0
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group-1-0 -v -g 555 -d 'group-1-0 for testing'"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of group-1-0 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group-1-0 is on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-1-0 | /bin/grep dn: | /bin/grep cn=group-1-0'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group-1-0 does not exist on $s"
				tet_result FAIL
			fi
		fi
	done

	# renaming group-1-0 to group-test0-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --setattr cn=group-test0-test1 group-1-0"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, rename of group-1-0 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group-test0-test1  is on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-test0-test1  | /bin/grep dn: | /bin/grep cn=group-test0-test1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - group-test0-test1 does not exist on $s"
				tet_result FAIL
			fi
		fi
	done

	# deleting group-test0-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup group-test0-test1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, delete of group-test0-test1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group-test0-test1 does not exist on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-test0-test1  | /bin/grep dn: | /bin/grep cn=group-test0-test1 '
			ret=$?
			if [ $ret -eq 0 ]; then
				echo "ERROR - group-test0-test1 exists on $s"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-1-0  | /bin/grep dn: | /bin/grep cn=group-1-0 '
			ret=$?
			if [ $ret -eq 0 ]; then
				echo "ERROR - group-1-0 exists on $s"
				tet_result FAIL
			fi
		fi
	done

	
	tet_result PASS
	echo "END $tet_thistest"
}

tp9()
{
	# From: https://idmwiki.sjc.redhat.com/export/idmwiki/Testplan/ipa/replica#memberof_feature_test
	# test 2 1
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group-2-1 -v -g 666 -d 'group 2 1 for testing'"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of group-2-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-adduser -f 'user-2-1' -l 'lastname' user-2-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of user-2-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --add user-2-1 group-2-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, add of user-2-1 to group-2-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-2-1 exists in group-2-1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-2-1 | grep uid=user-2-1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - user-2-1 does not exist in group-2-1 on $s"
				tet_result FAIL
			fi
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-moduser --firstname look user-2-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, change of firstname for user 2-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --setattr cn=group-test2-test1 group-2-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, rename of group-2-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-2-1 exists in group-test2-test1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-test2-test1 | grep uid=user-2-1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - user-2-1 does not exist in group-test2-test1 on $s"
				tet_result FAIL
			fi
			# verifying that the old group doesn't exist
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-2-1'
			ret=$?
			if [ $ret -eq 0 ]; then
				echo "ERROR - group-2-1 exists on $s"
				tet_result FAIL
			fi
		fi
	done

	# deleting group-test2-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup group-test2-test1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, delete of group-test2-test1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-deluser user-2-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, delete of user-2-1 on M1 failed"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

tp10()
{
	# From: https://idmwiki.sjc.redhat.com/export/idmwiki/Testplan/ipa/replica#memberof_feature_test
	# test 3 1
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group-3-1 -v -g 777 -d 'group 3 1 for testing'"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of group-3-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-adduser -f 'user-3-1' -l 'lastname' user-3-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, creation of user-3-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --add user-3-1 group-3-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, add of user-3-1 to group-3-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-3-1 exists in group-3-1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-3-1 | grep uid=user-3-1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - user-3-1 does not exist in group-3-1 on $s"
				tet_result FAIL
			fi
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --setattr cn=group-test3-test1 group-3-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, rename of group-3-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-3-1 exists in group-test3-test1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-test3-test1 | grep uid=user-3-1'
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - user-3-1 does not exist in group-test3-test1 on $s"
				tet_result FAIL
			fi
			# verifying that the old group doesn't exist
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-findgroup group-3-1'
			ret=$?
			if [ $ret -eq 0 ]; then
				echo "ERROR - group-3-1 exists on $s"
				tet_result FAIL
			fi
		fi
	done

	# deleting group-test3-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup group-test3-test1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, delete of group-test3-test1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-deluser user-3-1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, delete of user-3-1 on M1 failed"
		tet_result FAIL
	fi


	tet_result PASS
	echo "END $tet_thistest"
}

instclean()
{
	echo "START Cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup group1"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - delete of group1 on $s failed"
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup group2"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - delete of group2 on $s failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kdestroying on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "kdestroy"
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kdestroy $s failed"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "kdestroying on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "kdestroy"
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kdestroy $s failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END Cleanup"

}

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
