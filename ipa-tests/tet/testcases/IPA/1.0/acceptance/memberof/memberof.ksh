#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10 ic11 ic12"
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
ic11="tp11"
ic12="tp12"

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

######################################################################
# From: https://idmwiki.sjc.redhat.com/export/idmwiki/Testplan/ipa/replica#memberof_feature_test
# test 4 1
# 1. add empty group as member
# 2. add user as member
# 3. mix operation 1 & 2 to randomly add user and empty group
# 4. modify group (rename) member
# 5. modify user member 
# 6. delete user member
# 7. delete empty group member
# 8. mix operation 6 & 7 to randomly delete user and empty group till only one user type member left
# 9  mix operation 6 & 7 to randomly delete user and empty group till only one empty group type member left
# 10. rename the top level group name 
# 11. delete group member till the top level group became an empty group
######################################################################

tp11()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group-4-1 -g 755 -d 'group 4 1 for testing'; \
/usr/sbin/ipa-addgroup group-e4-1 -g 756 -d 'empty group 4 1 for testing'; \
/usr/sbin/ipa-adduser -f 'user 4 1' -l 'lastname' user-4-1; \
/usr/sbin/ipa-modgroup --add group-e4-1 group-4-1; \
/usr/sbin/ipa-modgroup --add user-4-1 group-4-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1"
		tet_result FAIL
	fi
		
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-moduser --firstname look1 user-4-1; \
/usr/sbin/ipa-moduser --firstname look2 user-4-1; \
/usr/sbin/ipa-moduser --firstname look3 user-4-1; \
/usr/sbin/ipa-deluser user-4-1; \
/usr/sbin/ipa-modgroup --setattr cn=group-4c-1 group-4-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa-findgroup group-4c-1"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup group-4-1a -g 761 -d 'group 4 1a for testing'; \
/usr/sbin/ipa-addgroup group-4-1b -g 762 -d 'group 4 1b for testing'; \
/usr/sbin/ipa-addgroup group-4-1c -g 763 -d 'group 4 1c for testing'; \
/usr/sbin/ipa-addgroup group-4-1d -g 764 -d 'group 4 1d for testing'; \
/usr/sbin/ipa-adduser -f 'user 4 1a' -l 'lastname' user-41a; \
/usr/sbin/ipa-adduser -f 'user 4 1b' -l 'lastname' user-41b; \
/usr/sbin/ipa-adduser -f 'user 4 1c' -l 'lastname' user-41c; \
/usr/sbin/ipa-adduser -f 'user 4 1d' -l 'lastname' user-41d; "
	ret=$?

	if [ $ret -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 3"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa-modgroup --groupadd group-4-1a group-4c-1;\
ipa-modgroup --groupadd group-4-1b group-4c-1; \
ipa-modgroup --groupadd group-4-1c group-4c-1; \
ipa-modgroup --groupadd group-4-1d group-4c-1; \
ipa-modgroup --add user-41a group-4c-1; \
ipa-modgroup --add user-41b group-4c-1; \
ipa-modgroup --add user-41c group-4c-1; \
ipa-modgroup --add user-41d group-4c-1;"
	ret=$?

	if [ $ret -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 4"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --setattr cn=group-4d-1 group-4c-1;"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, rename of group-4c-1 on M1 failed"
		tet_result FAIL
	fi

# Now, check to make sure that the groups and users exist in group-4d-1
	checklist="group-4-1a group-4-1b group-4-1c group-4-1d user-41a user-41b user-41c user-41d"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa-findgroup group-4d-1 | grep $c"
				if [ $? -ne 0 ]; then
					echo "ERROR - $tet_thistest failed in section 5 at $c"
					tet_result FAIL
				fi
			done
		else
			echo "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa-findgroup group-4-d-1 | grep $c"
				if [ $? -ne 0 ]; then
					echo "ERROR - $tet_thistest failed in section 6 at $c"
					tet_result FAIL
				fi
			done
		else
			echo "skipping $s"
		fi
	done

	ssh root@$FULLHOSTNAME "ipa-delgroup group-4-1a; \
ipa-delgroup group-4-1b; \
ipa-delgroup group-4-1c; \
ipa-delgroup group-4-1d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 7"
		tet_result FAIL
	fi


	ssh root@$FULLHOSTNAME "ipa-deluser user-41a; \
ipa-deluser user-41b; \
ipa-deluser user-41c; \
ipa-deluser user-41d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 8"
		tet_result FAIL
	fi

# Now, check to make sure that the groups and users exist in group-4d-1
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa-findgroup group-4-d-1 | grep $c"
				if [ $? -eq 0 ]; then
					echo "ERROR - $tet_thistest failed in section 9 at $c"
					tet_result FAIL
				fi
			done
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# From: https://idmwiki.sjc.redhat.com/export/idmwiki/Testplan/ipa/replica#memberof_feature_test
# test 5 2 
#1. all test in test set 2
####1. add user as member
####2. modify user member
####3. rename the top level group name 
####4. delete user member till the group became empty member
#2. all test in test set 3
####1. add empty group as member
####2. modify group (rename)
####3. rename the top level group name 
####4. delete group member till the top level group became an empty group
#3. all test in test set 4
#--- additional test ---
#4. delete all member at level 2
#5. delete all member at level 1
######################################################################
tp12()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	grp1="grp-5-2"
	grp2="grp-52-1"
	user1="user-5-2"
	sec=1
	eval_vars M1
	# Set up level 0 and level 1
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-addgroup $grp1 -g 855 -d 'group 5 2 for testing'; \
/usr/sbin/ipa-addgroup $grp2 -g 856 -d 'group for test 5 2 containing only 1 member level 2'; \
/usr/sbin/ipa-modgroup --groupadd $grp2 $grp1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# test set 2
	grp2alt="group-test5-level2"
	newfirstname="looklookd"
	# Create user that will be in level 3
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-adduser -f 'user 5 2' -l 'lastname' $user1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# Add the level 3 user to the level 2 group
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --add $user1 $grp2;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# modify the user
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-moduser --firstname $newfirstname $user1"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# modify the group
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-modgroup --setattr cn=$grp2alt $grp2"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, rename of $grp2 on M1 failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# Check to ensure the group changed to include the user, and that the firstname change took.
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			ssh root@$FULLHOSTNAME "ipa-findgroup -a $grp1 | grep $grp2alt"
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - $grp2alt does not exist in $grp1"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa-findgroup -a $grp1 | grep $newfirstname"
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - The altered First Name for user $user1 does not exist in $grp1"
				echo "ERROR - possibly from bug https://bugzilla.redhat.com/show_bug.cgi?id=451318"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			ssh root@$FULLHOSTNAME "ipa-findgroup -a $grp1 | grep $grp2alt"
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - $grp2alt does not exist in $grp1"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa-findgroup -a $grp1 | grep $newfirstname"
			ret=$?

			if [ $ret -ne 0 ]; then
				echo "ERROR - The altered First Name for user $user1 does not exist in $grp1"
				echo "ERROR - possibly from bug https://bugzilla.redhat.com/show_bug.cgi?id=451318"
				if [ "$IGNORE_KNOWN_BUGS" != "y" ]; then
					tet_result FAIL
				else
					echo "Ignoring because IGNORE_KNOWN_BUGS is set"
				fi
			fi
		fi
	done

	# Cleanup of test set 2
	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup $grp1; \
/usr/sbin/ipa-delgroup $grp2alt; \
/usr/sbin/ipa-delgroup $grp2; \
/usr/sbin/ipa-deluser $user1; "
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR, cleanup of test set 2 failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# Test Set 4	

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################


######################################################################
tpx()
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

	ssh root@$FULLHOSTNAME "/usr/sbin/ipa-delgroup group-e4-1; \
/usr/sbin/ipa-delgroup group-4-1; \
/usr/sbin/ipa-delgroup group-4a-1; \
/usr/sbin/ipa-delgroup group-4b-1; \
/usr/sbin/ipa-delgroup group-4c-1; \
/usr/sbin/ipa-delgroup group-4d-1; \
/usr/sbin/ipa-deluser user-4-1"

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
