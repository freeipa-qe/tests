#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10 ic11 ic12 ic13 ic14"
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
ic12="tp12 tp13 tp14"
ic13="tp15"
ic14="bug438891 bug439097 bug439450 bug439628"

group1=grp1af
group2=grpt2m

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
			if [ $? -ne 0 ]; then
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
			if [ $? -ne 0 ]; then
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
	ssh root@$FULLHOSTNAME "ipa group-add --gid=444 --description='$group1 for testing' $group1"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of $group1 on M1 failed"
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa group-add --gid=888 --description='$group2 for testing' $group2"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of $group2 on M1 failed"
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
			echo "Verifying that $group1 exists on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find $group1 | /bin/grep gidnumber | /bin/grep 444"
			if [ $? -ne 0 ]; then
				echo "ERROR - $group1 does not exist on $s"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-find $group2 | /bin/grep gidnumber | /bin/grep 888"
			if [ $? -ne 0 ]; then
				echo "ERROR - $group2 does not exist on $s"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				echo "Verifying that $group1 exists on $s"
				ssh root@$FULLHOSTNAME "ipa group-find $group1 | /bin/grep gidnumber | /bin/grep 444"
				if [ $? -ne 0 ]; then
					echo "ERROR - $group1 does not exist on $s"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-find $group2 | /bin/grep gidnumber | /bin/grep 888"
				if [ $? -ne 0 ]; then
					echo "ERROR - $group2 does not exist on $s"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
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
	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$group1 $group2"
	if [ $? -ne 0 ]; then
		echo "ERROR, add of $group2 to $group1 on M1 failed"
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
	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$group2 $group1"
	if [ $? -ne 0 ]; then
		echo "ERROR, add of $group1 to $group2 on M1 failed"
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
			echo "Verifying that $group2 is in $group1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find $group1 | /bin/grep $group2"
			if [ $? -ne 0 ]; then
				echo "ERROR - $group2 does not exist in $group1 on $s"
				tet_result FAIL
			fi

			echo "Verifying that $group1 is in $group2 on $s"
			ssh root@$FULLHOSTNAME "ipa group-find $group2 | /bin/grep $group1"
			if [ $? -ne 0 ]; then
				echo "ERROR - $group1 does not exist in $group2 on $s"
				tet_result FAIL
			fi

		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then			
				echo "Verifying that $group2 is in $group1 on $s"
				ssh root@$FULLHOSTNAME "ipa group-find $group1 | /bin/grep $group2"
				if [ $? -ne 0 ]; then
					echo "ERROR - $group2 does not exist in $group1 on $s"
					tet_result FAIL
				fi

				echo "Verifying that $group1 is in $group2 on $s"
				ssh root@$FULLHOSTNAME "ipa group-find $group2 | /bin/grep $group1"
				if [ $? -ne 0 ]; then
					echo "ERROR - $group1 does not exist in $group2 on $s"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

tp7()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Verify that ipa group-show --all and grep fails when it's given bad info on all servers
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that groupf does not exist in $group1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find $group1 | /bin/grep groupf"
			if [ $? -eq 0 ]; then
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
	ssh root@$FULLHOSTNAME "ipa group-add --description 'group-1-0 for testing' --gid=555 group-1-0"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of group-1-0 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group-1-0 is on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find group-1-0 | /bin/grep dn: | /bin/grep cn=group-1-0"
			if [ $? -ne 0 ]; then
				echo "ERROR - group-1-0 does not exist on $s"
				tet_result FAIL
			fi
		fi
	done

	# renaming group-1-0 to group-test0-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-mod --gid=group-test0-test1 group-1-0"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of group-1-0 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group-test0-test1  is on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find group-test0-test1  | /bin/grep dn: | /bin/grep cn=group-test0-test1"
			if [ $? -ne 0 ]; then
				echo "ERROR - group-test0-test1 does not exist on $s"
				tet_result FAIL
			fi
		fi
	done

	# deleting group-test0-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del group-test0-test1"
	if [ $? -ne 0 ]; then
		echo "ERROR, delete of group-test0-test1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that group-test0-test1 does not exist on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find group-test0-test1  | /bin/grep dn: | /bin/grep cn=group-test0-test1 "
			if [ $? -eq 0 ]; then
				echo "ERROR - group-test0-test1 exists on $s"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-find group-1-0  | /bin/grep dn: | /bin/grep cn=group-1-0 "
			if [ $? -eq 0 ]; then
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
	ssh root@$FULLHOSTNAME "ipa group-add --description 'group 2 1 for testing' --gid=666 group-2-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of group-2-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-add --first='user-2-1' --last='lastname' user-2-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of user-2-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=user-2-1 group-2-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, add of user-2-1 to group-2-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-2-1 exists in group-2-1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find group-2-1 | grep uid=user-2-1"
			if [ $? -ne 0 ]; then
				echo "ERROR - user-2-1 does not exist in group-2-1 on $s"
				tet_result FAIL
			fi
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa user-mod --first=look user-2-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, change of firstname for user 2-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-mod --gid=group-test2-test1 group-2-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of group-2-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-2-1 exists in group-test2-test1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find group-test2-test1 | grep uid=user-2-1"
			if [ $? -ne 0 ]; then
				echo "ERROR - user-2-1 does not exist in group-test2-test1 on $s"
				tet_result FAIL
			fi
			# verifying that the old group doesn't exist
			ssh root@$FULLHOSTNAME "ipa group-find group-2-1"
			if [ $? -eq 0 ]; then
				echo "ERROR - group-2-1 exists on $s"
				tet_result FAIL
			fi
		fi
	done

	# deleting group-test2-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del group-test2-test1"
	if [ $? -ne 0 ]; then
		echo "ERROR, delete of group-test2-test1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-del user-2-1"
	if [ $? -ne 0 ]; then
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
	ssh root@$FULLHOSTNAME "ipa group-add --description 'group 3 1 for testing' --gid=777 group-3-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of group-3-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-add --first='user-3-1' --last='lastname' user-3-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, creation of user-3-1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=user-3-1 group-3-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, add of user-3-1 to group-3-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-3-1 exists in group-3-1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-show --all group-3-1 | grep uid=user-3-1"
			if [ $? -ne 0 ]; then
				echo "ERROR - user-3-1 does not exist in group-3-1 on $s"
				tet_result FAIL
			fi
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-mod --gid=group-test3-test1 group-3-1"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of group-3-1 on M1 failed"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "Verifying that user-3-1 exists in group-test3-test1 on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find group-test3-test1 | grep uid=user-3-1"
			if [ $? -ne 0 ]; then
				echo "ERROR - user-3-1 does not exist in group-test3-test1 on $s"
				tet_result FAIL
			fi
			# verifying that the old group doesn't exist
			ssh root@$FULLHOSTNAME "ipa group-find group-3-1"
			if [ $? -eq 0 ]; then
				echo "ERROR - group-3-1 exists on $s"
				tet_result FAIL
			fi
		fi
	done

	# deleting group-test3-test1
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del group-test3-test1"
	if [ $? -ne 0 ]; then
		echo "ERROR, delete of group-test3-test1 on M1 failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-del user-3-1"
	if [ $? -ne 0 ]; then
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
	ssh root@$FULLHOSTNAME "ipa group-add --description 'group 4 1 for testing' --gid=775 group-4-1; \
ipa group-add --description 'empty group 4 1 for testing' --gid=756 group-e4-1; \
ipa user-add --first='user 4 1' --last='lastname' user-4-1; \
ipa group-add-member --groups=group-e4-1 --users=user-4-1 group-4-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1"
		tet_result FAIL
	fi
		
	ssh root@$FULLHOSTNAME "ipa user-mod --first=look1 user-4-1; \
ipa user-mod --first=look2 user-4-1; \
ipa user-mod --first=look3 user-4-1; \
ipa user-del user-4-1; \
ipa group-mod --gid=group-4c-1 group-4-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find group-4c-1"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add --description='group 4 1a for testing' --gid=761 group-4-1a; \
ipa group-add --description='group 4 1b for testing' --gid=762 group-4-1b; \
ipa group-add --description='group 4 1c for testing' --gid=763 group-4-1c; \
ipa group-add --description='group 4 1d for testing' --gid=764 group-4-1d; \
ipa user-add --first='user 4 1a' --last='lastname' user-41a; \
ipa user-add --first='user 4 1b' --last='lastname' user-41b; \
ipa user-add --first='user 4 1c' --last='lastname' user-41c; \
ipa user-add --first='user 4 1d' --last='lastname' user-41d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 3"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=group-4-1a,group-4-1b,group-4-1c,group-4-1d --users=user-41a,user-41b,user-41c,user-41d group-4c-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 4"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-mod --gid=group-4d-1 group-4c-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of group-4c-1 on M1 failed"
		tet_result FAIL
	fi

# Now, check to make sure that the groups and users exist in group-4d-1
	checklist="group-4-1a group-4-1b group-4-1c group-4-1d user-41a user-41b user-41c user-41d"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa group-find group-4d-1 | grep $c"
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
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				for c in $checklist; do
					ssh root@$FULLHOSTNAME "ipa group-find group-4d-1 | grep $c"
					if [ $? -ne 0 ]; then
						echo "ERROR - $tet_thistest failed in section 6 at $c"
						tet_result FAIL
					fi
				done
			else	
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		else
			echo "skipping $s"
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del group-4-1a; \
ipa group-del group-4-1b; \
ipa group-del group-4-1c; \
ipa group-del group-4-1d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 7"
		tet_result FAIL
	fi


	ssh root@$FULLHOSTNAME "ipa user-del user-41a; \
ipa user-del user-41b; \
ipa user-del user-41c; \
ipa user-del user-41d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 8"
		tet_result FAIL
	fi

# Now, check to make sure that the groups and users do not exist in group-4d-1
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa group-find group-4d-1 | grep $c"
				if [ $? -eq 0 ]; then
					echo "ERROR - $tet_thistest failed in section 9 at $c"
					tet_result FAIL
				fi
			done
		fi
	done

# Cleanup
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del group-4d-1"	
	if [ $? -ne 0 ]; then
		echo "ipa group-del group-4d-1 failed"
		tet_result FAIL
	fi

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
####1. add empty group as member
####2. add user as member
####3. mix operation 1 & 2 to randomly add user and empty group
####4. modify group (rename) member
####5. modify user member 
####6. delete user member
####7. delete empty group member
####8. mix operation 6 & 7 to randomly delete user and empty group till only one user type member left
####9  mix operation 6 & 7 to randomly delete user and empty group till only one empty group type member left
####10. rename the top level group name 
####11. delete group member till the top level group became an empty group
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
	echo "Set up level 0 and level 1"
	ssh root@$FULLHOSTNAME "ipa group-add --description 'group 5 2 for testing' --gid=855 $grp1; \
ipa group-add --description 'group for test 5 2 containing only 1 member level 2' --gid=656 $grp2; \
ipa group-add-member --groups=$grp2 $grp1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	# test set 2
	grp2alt="group-test5-level2"
	newfirstname="looklookd"
	echo "Create user that will be in level 3"
	ssh root@$FULLHOSTNAME "ipa user-add --first='user 5 2' --last='lastname' $user1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	echo "Add the level 3 user to the level 2 group"
	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$user1 $grp2;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	echo "modify the user"
	ssh root@$FULLHOSTNAME "ipa user-mod --first=$newfirstname $user1"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	echo "modify the group"
	ssh root@$FULLHOSTNAME "ipa group-mod --gid=$grp2alt $grp2"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of $grp2 on M1 failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	echo "Check to ensure the group changed to include the user, and that the firstname change took."
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $grp2alt"
			if [ $? -ne 0 ]; then
				echo "ERROR - $grp2alt does not exist in $grp1"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa user-find --all $user1 | grep $newfirstname"
			if [ $? -ne 0 ]; then
				echo "ERROR - The altered First Name for user $user1 does not exist in $grp1"
				echo "ERROR - possibly from bug https://bugzilla.redhat.com/show_bug.cgi?id=451318"
				tet_result FAIL
			fi
		fi
	done
	# wait some time for the change to propigate.
	sleep 60
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $grp2alt"
				if [ $? -ne 0 ]; then
					echo "ERROR - $grp2alt does not exist in $grp1"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $newfirstname"

				if [ $? -ne 0 ]; then
					echo "ERROR - The altered First Name for user $user1 does not exist in $grp1"
					echo "ERROR - possibly from bug https://bugzilla.redhat.com/show_bug.cgi?id=451318"
					if [ "$IGNORE_KNOWN_BUGS" != "y" ]; then
						tet_result FAIL
					else
						echo "Ignoring because IGNORE_KNOWN_BUGS is set"
					fi
			
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done

	eval_vars M1
	echo "Cleanup of test set 2"
	ssh root@$FULLHOSTNAME "ipa group-del $grp1; \
ipa group-del $grp2alt; \
ipa group-del $grp2; \
ipa user-del $user1; "
	if [ $? -ne 0 ]; then
		echo "ERROR, cleanup of test set 2 failed in section $sec"
		tet_result FAIL
	fi
	let sec=$sec+1

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# This is actually a continuation of tp12, but it was getting long, so I'm breaking it up.
######################################################################
tp13()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	sec=1
	eval_vars M1

	# Test Set 3	
####1. add empty group as member
####2. modify group (rename)
####3. rename the top level group name 
####4. delete group member till the top level group became an empty group
	grp1="group-5-2"
	grp2="group-5-4-1"
	grp3="group-e5-4-1"
	grp4="new-groupe541"
	grp5="new-group541"
	grpa="group-a-5-2"
	grpb="group-b-5-2"
	grpc="group-c-5-2"
	grpd="group-d-5-2"
	user1="user-4-1"
	usera="user-41a"
	userb="user-41b"
	userc="user-41c"
	userd="user-41d"
	# grp1 is the top level group for test 5
	# grp2 is the top level group for test 4, but it sits under test 5
	# grp3 is a empty group to get added to grp2
	# grp4 is the name the name that grp2 gets renamed to. 
	# grp5 is the name that grp2 gets renamed to
	ssh root@$FULLHOSTNAME "ipa group-add --description 'group 5 2 for group 4 1 for testing' --gid=767 $grp1; \
ipa group-add --description 'group 4 1 for testing' --gid=765 $grp2; \
ipa group-add --description 'empty group 4 1 for testing' --gid=766 $grp3; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1a"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-add --first='user 4 1' --last='lastname' $user1; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1b"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grp2,$grp3 --users=$user1 $grp1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1c"
		tet_result FAIL
	fi
		
	ssh root@$FULLHOSTNAME "ipa user-mod --first=look1 $user1; \
ipa user-mod --first=look2 $user1; \
ipa user-mod --first=look3 $user1; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp2"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 3"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add --description 'group 4 1a for testing' --gid=771 $grpa; \
ipa group-add --description 'group 4 1b for testing' --gid=772 $grpb; \
ipa group-add --description 'group 4 1c for testing' --gid=773 $grpc; \
ipa group-add --description 'group 4 1d for testing' --gid=774 $grpd; \
ipa user-add --first='user 4 1a' --last='lastname' $usera; \
ipa user-add --first='user 4 1b' --last='lastname' $userb; \
ipa user-add --first='user 4 1c' --last='lastname' $userc; \
ipa user-add --first='user 4 1d' --last='lastname' $userd; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 4"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grpa,$grpb,$grpc,$grpd --users=$usera,$userb,$userc,$userd $grp2; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 5"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-mod --setattr cn=$grp4 $grp2;"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of $grp2 on M1 failed"
		tet_result FAIL
	fi

	# Now, check to make sure that the groups and users exist in grp1
	checklist="$grpa $grpb $grpc $grpd $usera $userb $userc $userd"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $c"
				if [ $? -ne 0 ]; then
					echo "ERROR - $tet_thistest failed in section 6 at $c for $grp1"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-find $grp4 | grep $c"
				if [ $? -ne 0 ]; then
					echo "ERROR - $tet_thistest failed in section 6 at $c for $grp4"
					tet_result FAIL
				fi

			done
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				for c in $checklist; do
					ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $c"
					if [ $? -ne 0 ]; then
						echo "ERROR - $tet_thistest failed in section 7 at $c"
						tet_result FAIL
					fi
				done
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done

	eval_vars M1
	checklist="$grpa $grpb $grpc $grpd"
	for c in $checklist; do
		ssh root@$FULLHOSTNAME "ipa group-del $c; "
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 8 on $c"
			tet_result FAIL
		fi
	done 

	checklist="$usera $userb $userc $userd $user1"
	for c in $checklist; do
		ssh root@$FULLHOSTNAME "ipa user-del $c; "
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 9 on $c"
			tet_result FAIL
		fi
	done 

	checklist="$grpa $grpb $grpc $grpd $usera $userb $userc $userd"
	# Now, check to make sure that the groups and users do not exist in group-4d-1
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa group-find $grp4 | grep $c"
				if [ $? -eq 0 ]; then
					echo "ERROR - $tet_thistest passed when it shouldn't have in section 10 at $c"
					tet_result FAIL
				fi
			done
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del $grp1; \
ipa group-del $grp2; \
ipa group-del $grp3; \
ipa group-del $grp4; "
	if [ $? -ne 0 ]; then
		echo "ERROR, ipa group-del failed on M1, section 12"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# This is actually a continuation of tp12, but it was getting long, so I'm breaking it up.
######################################################################
tp14()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	sec=1
	eval_vars M1

	# Test Set 4
####1. add empty group as member
####2. add user as member
####3. mix operation 1 & 2 to randomly add user and empty group
####4. modify group (rename) member
####5. modify user member 
####6. delete user member
####7. delete empty group member
####8. mix operation 6 & 7 to randomly delete user and empty group till only one user type member left
####9  mix operation 6 & 7 to randomly delete user and empty group till only one empty group type member left
####10. rename the top level group name 
####11. delete group member till the top level group became an empty group

	# Cleanup, just in case things exist that shouldn't
ssh root@$FULLHOSTNAME "ipa group-del group-4-1; \
ipa group-del group-4a-1; \
ipa group-del group-4b-1; \
ipa group-del group-4c-1; \
ipa group-del group-4d-1; \
ipa user-del user-4-1; \
ipa user-del user-5-1"

	ssh root@$FULLHOSTNAME "ipa group-add --gid=977 --description='this group will be the top level group' group-5-1; \
ipa group-add --gid=755 --description='group 4 1 for testing' group-4-1; \
ipa group-add --gid=756 --description='empty group 4 1 for testing' group-e4-1; \
ipa user-add --first='user 4 1' --last='lastname' user-4-1; \
ipa group-add-member --groups=group-e4-1 group-4-1;\
ipa group-add-member --groups=group-4-1 group-5-1;\
ipa group-add-member --users=user-4-1 group-4-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1"
		tet_result FAIL
	fi
		
	ssh root@$FULLHOSTNAME "ipa-moduser --firstname look1 user-4-1; \
ipa-moduser --firstname look2 user-4-1; \
ipa-moduser --firstname look3 user-4-1; \
ipa user-del user-4-1; \
ipa group-mod --setattr cn=group-4c-1 group-4-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all group-4c-1"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add --gid=761 --description='group 4 1a for testing' group-4-1a; \
ipa group-add --gid=762 --description='group 4 1b for testing' group-4-1b; \
ipa group-add --gid=763 --description='group 4 1c for testing' group-4-1c; \
ipa group-add --gid=764 --description='group 4 1d for testing' group-4-1d; \
ipa user-add --first='user 4 1a' --last='lastname' user-41a; \
ipa user-add --first='user 4 1b' --last='lastname' user-41b; \
ipa user-add --first='user 4 1c' --last='lastname' user-41c; \
ipa user-add --first='user 4 1d' --last='lastname' user-41d; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 3"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=user-41a,user-41b,user-41c,user-41d --groups=group-4-1a,group-4-1b,group-4-1c,group-4-1d group-4c-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 4"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-mod --setattr cn=group-4d-1 group-4c-1;"
	if [ $? -ne 0 ]; then
		echo "ERROR, rename of group-4c-1 on M1 failed"
		tet_result FAIL
	fi

# Now, check to make sure that the groups and users exist in group-4d-1
	checklist="group-4-1a group-4-1b group-4-1c group-4-1d user-41a user-41b user-41c user-41d"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa group-show --all group-5-1 | grep $c"
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
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				for c in $checklist; do
					ssh root@$FULLHOSTNAME "ipa group-show --all group-5-1 | grep $c"
					if [ $? -ne 0 ]; then
						echo "ERROR - $tet_thistest failed in section 6 at $c"
						tet_result FAIL
					fi
				done
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		else
			echo "skipping $s"
		fi
	done

	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del group-4-1a; \
ipa group-del group-4-1b; \
ipa group-del group-4-1c; \
ipa group-del group-4-1d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 7"
		tet_result FAIL
	fi


	ssh root@$FULLHOSTNAME "ipa user-del user-41a; \
ipa user-del user-41b; \
ipa user-del user-41c; \
ipa user-del user-41d;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 8"
		tet_result FAIL
	fi

# Now, check to make sure that the groups and users exist in group-4d-1
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			for c in $checklist; do
				ssh root@$FULLHOSTNAME "ipa group-show --all group-5-1 | grep $c"
				if [ $? -eq 0 ]; then
					echo "ERROR - $tet_thistest failed in section 9 at $c"
					tet_result FAIL
				fi
			done
		fi
	done

	# A little more cleanup
	ssh root@$FULLHOSTNAME "ipa group-del group-5-1; \
ipa group-del group-4-d-1; "

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# Test 6 2 from:
# https://idmwiki.sjc.redhat.com/export/idmwiki/Testplan/ipa/replica#memberof_feature_test
#-- For members in level 2 --
#1. all operation on test set 5
###### Bypassing this step as it's assumed that tp12, tp13, and tp14 should cover this part.
#-- For members in level 1 --
#2. add user type member at level 1
#3. modify user type member at level 1
#4. delete user type member at level 1
#-- Change member's 
#5. user in level 2 move to level 1
#6. user in level 1 move to level 2
######################################################################
tp15()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	grp1="group-6-2-a" #Level 1
	grp2="group-6-2-b" #Level 2
	grp3="group-6-2-c" #Level 3
	user1="user62b1" # User for level 2
	user2="user62b2" # User for level 2
	user3="user62b3" # User for level 1
	user1alt="userb1a1" # username that user 1 will be changed to

	eval_vars M1
	# set up groups
	ssh root@$FULLHOSTNAME "ipa group-add --gid=87 --description='group 6 2 for testing' $grp1; \
ipa group-add --gid=75 --description='group 6 2 for level 2 testing' $grp2; \
ipa group-add --gid=76 --description=' group 6 2 for level 3 testing' $grp3; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 1"
		tet_result FAIL
	fi

	# set up users
	ssh root@$FULLHOSTNAME "ipa user-add --first='user 6 2a' --last='lastname' $user1; \
	ipa user-add --first='user 6 2b' --last='lastname' $user2; \
	ipa user-add --first='user 6 2c' --last='lastname' $user3; "
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 2"
		tet_result FAIL
	fi

	# add groups to themselfs 
	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grp2,$grp3 $grp1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 3"
		tet_result FAIL
	fi

	# add users to group 2
	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$user1,$user2 $grp2; \
ipa group-add-member --users=$user3 $grp1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 4"
		tet_result FAIL
	fi

	# confirm that the users are in the right place, and not in group 3
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user1"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 5"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user2"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 6"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user3"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 6a"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp3 | grep -e $user2 -e $user3"
			if [ $? -eq 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 7"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user1"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 8"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user2"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 9"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user3"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 9a"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp3 | grep -e $user2 -e $user3"
				if [ $? -eq 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 10"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done
	eval_vars M1
	# modify user type member at level 1
	ssh root@$FULLHOSTNAME "ipa-moduser --setattr \"uid=$user1alt\" $user1"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 11"
		tet_result FAIL
	fi

	# delete user type member at level 1
	ssh root@$FULLHOSTNAME "ipa user-del $user2"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 12"
		tet_result FAIL
	fi

	# confirm that the users are in the right place, and with the right info
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user1alt"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 13"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user1alt"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 14"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user2"
			if [ $? -eq 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 15"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user2"
			if [ $? -eq 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 16"
				tet_result FAIL
			fi

		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user1alt"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 17"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user1alt"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 18"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user2"
				if [ $? -eq 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 19"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user2"
				if [ $? -eq 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 20"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done

	eval_vars M1
	# user in level 2 move to level 1
	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$user1alt $grp1; \
ipa group-remove-member --users=$user1alt $grp2;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 21"
		tet_result FAIL
	fi

	# user in level 1 move to level 2
ssh root@$FULLHOSTNAME "ipa group-add-member --users=$user3 $grp2; \
ipa group-remove-member --users=$user3 $grp1;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 22"
		tet_result FAIL
	fi

	# confirm that the users are in the right place.
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user1alt"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 23"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user1alt"
			if [ $? -eq 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 24"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user3"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 25"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user3"
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 26"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user1alt"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 27"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user1alt"
				if [ $? -eq 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 28"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user3"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 29"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user3"
				if [ $? -ne 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 30"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done

	# delete user type member at level 1
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa user-del $user3;"
	if [ $? -ne 0 ]; then
		echo "ERROR - $tet_thistest failed in section 31"
		tet_result FAIL
	fi
	# confirm that the user3 does not exist
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user3"
			if [ $? -eq 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 32"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user3"
			if [ $? -eq 0 ]; then
				echo "ERROR - ipa group-show --all failed on section 33"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $user3"
				if [ $? -eq 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 34"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $user3"
				if [ $? -eq 0 ]; then
					echo "ERROR - ipa group-show --all failed on section 35"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
			fi
		fi
	done


	# Cleanup
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del $grp1; \
ipa group-del $grp2; \
ipa group-del $grp3; \
ipa user-del $user1alt; \
ipa user-del $user3; \
ipa user-del $user1; \
ipa user-del $user2"

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=438891
######################################################################
bug438891()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	# Setup
	grp1="group438891a" #
	grp2="group438891b" #
	grp1alt="group438891alt"
	user1="u438891" 
	
	eval_vars M1

	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		echo "Test $tet_thistest Itteration $runnum"
		ssh root@$FULLHOSTNAME "ipa group-add --gid=37 --description='group 438891a for testing' $grp1; \
ipa group-add --gid=35 --description='group 438891b for testing' $grp2; \
ipa user-add --first='438891' --last='lastname' $user1; \
ipa group-add-member --groups=$grp2 --users=$user1 $grp1; \
ipa group-mod --setattr cn=$grp1alt $grp1"
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 1 itteration $runnum"
			tet_result FAIL
		fi

		# Now check to make sure that grp1 got renamed in user1's memberof
		ssh root@$FULLHOSTNAME "ipa-finduser -a $user1 | grep $grp1alt"
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 2 itteration $runnum"
			tet_result FAIL
		fi

		# Cleanup
		ssh root@$FULLHOSTNAME "ipa user-del $user1; \
ipa group-del $grp2; \
ipa group-del $grp1alt;"
		
		let runnum=$runnum+1
	done	

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=439097
######################################################################
bug439097()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	# Setup
	grp1="group439097" #
	user1="u439097" 
	
	eval_vars M1

	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		echo "Test $tet_thistest Itteration $runnum"
		ssh root@$FULLHOSTNAME "ipa group-add --gid=37 --description='group 438891a for testing' $grp1; \
ipa user-add --first='438891' --last='lastname' $user1; \
ipa group-add-member --users=$user1 $grp1; \
ipa group-remove-member --users=$user1 $grp1;"
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 1 itteration $runnum"
			tet_result FAIL
		fi

		# Now check to make sure that worked
		ssh root@$FULLHOSTNAME "ipa-finduser -a $user1 | grep $grp1"
		if [ $? -eq 0 ]; then
			echo "ERROR - $tet_thistest failed in section 2 itteration $runnum"
			tet_result FAIL
		fi

		# Cleanup
		ssh root@$FULLHOSTNAME "ipa user-del $user1; \
ipa group-del $grp1;"
		
		let runnum=$runnum+1
	done	

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=439450
######################################################################
bug439450()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	# Setup
	grp1="group439450a" #
	grp2="group439450b" #
	
	eval_vars M1

	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		echo "Test $tet_thistest Itteration $runnum"
		ssh root@$FULLHOSTNAME "ipa group-add --gid=37 --description='group a for testing' $grp1; \
ipa group-add $grp2 --gid=39 --description='group b for testing' $grp2; \
ipa group-add-members --groups=$grp2 $grp1; \
ipa group-add-members --groups=$grp1 $grp2;" 
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 1 itteration $runnum"
			tet_result FAIL
		fi

		# Now check to make sure that grp1 isn't listed as a member of grp1
		ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep $grp1:"
		if [ $? -eq 0 ]; then
			echo "ERROR - $tet_thistest failed in section 2 itteration $runnum"
			tet_result FAIL
		fi

		# Now check to make sure that grp2 isn't a member of grp2
		ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep $grp2:"
		if [ $? -eq 0 ]; then
			echo "ERROR - $tet_thistest failed in section 3 itteration $runnum"
			tet_result FAIL
		fi

		# Cleanup
		ssh root@$FULLHOSTNAME "ipa group-del $grp1; \
ipa group-del $grp2;"
		
		let runnum=$runnum+1
	done	

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=439628
######################################################################
bug439628()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	# Setup
	grp1="group439628a" #
	grp2="group439628b" #
	user1="u439628" 
	
	eval_vars M1

	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		echo "Test $tet_thistest Itteration $runnum"
		ssh root@$FULLHOSTNAME "ipa group-add $grp1 --gid=87 --description='group a for testing' $grp1; \
ipa group-add --gid=85 --description='group b for testing' $grp2; \
ipa user-add --first='u1' --last='lastname' $user1; \
ipa group-add-members --groups=$grp2 $grp1; \
ipa group-add-members --users=$user1 $grp2; \
ipa group-add-members --users=$user1 $grp1; \
ipa group-remove-members --users=$user1 $grp1;"
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 1 itteration $runnum"
			tet_result FAIL
		fi

		# Now check to make sure that worked
		ssh root@$FULLHOSTNAME "ipa-finduser -a $user1 | grep $grp1"
		if [ $? -ne 0 ]; then
			echo "ERROR - $tet_thistest failed in section 2 itteration $runnum"
			echo "ERROR - $grp1 doesn't exist in $user1"
			tet_result FAIL
		fi

		# Cleanup
		ssh root@$FULLHOSTNAME "ipa user-del $user1; \
ipa group-del $grp1; \
ipa group-del $grp2;"
		
		let runnum=$runnum+1
	done	

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
			if [ $? -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		else
			echo "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
				KinitAs $s $DS_USER $DM_ADMIN_PASS
				if [ $? -ne 0 ]; then
					echo "ERROR - kinit on $s failed"
					tet_result FAIL
				fi
			else
				echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
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
	ssh root@$FULLHOSTNAME "ipa group-del $group1"
	if [ $? -ne 0 ]; then
		echo "ERROR - delete of $group1 on $s failed"
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa group-del $group2"
	if [ $? -ne 0 ]; then
		echo "ERROR - delete of $group2 on $s failed"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-del $grp3; \
ipa group-del group-4-1; \
ipa group-del group-4a-1; \
ipa group-del group-4b-1; \
ipa group-del group-4c-1; \
ipa group-del group-4d-1; \
ipa user-del user-4-1"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kdestroying on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "kdestroy"
			if [ $? -ne 0 ]; then
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
			if [ $? -ne 0 ]; then
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
