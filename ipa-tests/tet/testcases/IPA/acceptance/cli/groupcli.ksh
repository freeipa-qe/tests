#!/bin/ksh

######################################################################

# The following ipa cli commands needs to be tested:
#  group-add                 Add a new group.
#  group-add-member          Add a member to a group.
#  group-del                 Delete an existing group.
#  group-find                Search the groups.
#  group-mod                 Edit an existing group.
#  group-remove-member       Remove a member from a group.
#  group-show                Examine an existing group.

######################################################################
echo "groupcli"
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="kinit"
tet_cleanup="user_cleanup"
iclist="ic1"
ic1="add_group_users group_add group_find group_find_neg group_show group_show_neg group_add_posix group_mod_neg_posix group_mod_posix group_mod_description group_add_member_user group_add_member_user_neg group_add_member_group group_add_member_group_neg group_del"
# These services will be used by the tests, and removed when the cli test is complete
host1='alpha.dsdev.sjc.redhat.com'

# Users to be used in varios tests
superuser="sup64"
grp1="grpkl1"
grp2="ghml4pam"

usr1="usermk4"
usr2="usermk5"

######################################################################
kinit()
{
	tet_thistest="kinit"
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

# This is the startup for the group tests. Mainly, it just creates the users to be used in the add and remove member tests 
add_group_users()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa user-add --first=\"firstuname\" --last=\"lastuname\" $usr1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa user-add --first=\"firstuname2\" --last=\"lastuname2\" $usr2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}


group_add()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add --description=group-to-test-find-user $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep group-to-test-find-user"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_find()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep group-to-test-find-user"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_find_neg()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-find nonexistgroup"
	let code=$code+$?

	if [ $code -eq 0 ]
	then
		echo "ERROR - $tet_thistest failed. ipa group-find passed when it should not have"
		echo "ERROR - This failure might be related to https://bugzilla.redhat.com/show_bug.cgi?id=501840"
		tet_result FAIL
	fi

	tet_result PASS
}

group_show()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-show $grp1 | grep group-to-test-find-user"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_show_neg()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-show nonexistgroup"
	let code=$code+$?

	if [ $code -eq 0 ]
	then
		echo "ERROR - $tet_thistest failed. ipa group-find passed when it should not have"
		tet_result FAIL
	fi

	tet_result PASS
}

group_add_posix()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add --description=group-to-test-posix $grp2"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp2 | grep posixgroup"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_mod_posix()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-mod --posix $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep posixgroup"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_mod_neg_posix()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	# This should fail because this group should already be a posix group
	ssh root@$FULLHOSTNAME "ipa group-mod --posix $grp1"
	if [ $? -eq 0 ]
	then
		echo "ERROR - $tet_thistest failed. ipa group-mod --posix $grp1 worked when it should not have."
		tet_result FAIL
	fi

	tet_result PASS
}

group_mod_description()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-mod --description=desc2 $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep desc2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_add_member_user()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$usr1,$usr2 $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $usr1"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_add_member_user_neg()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	# This should fail because these users should already be in this group
	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$usr1,$usr2 $grp1"
	if [ $? -eq 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		echo "ERROR - This is likley related to bug https://bugzilla.redhat.com/show_bug.cgi?id=499464"
		tet_result FAIL
	fi

	tet_result PASS
}

group_add_member_group()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grp2 $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $grp2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	tet_result PASS
}

group_add_member_group_neg()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	# This should fail because this group should already be in this group
	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grp2 $grp1"
	if [ $? -eq 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		echo "ERROR - This is likley related to bug https://bugzilla.redhat.com/show_bug.cgi?id=499464"
		tet_result FAIL
	fi

	tet_result PASS
}

group_del()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-del $grp1"
	if [ $? -ne 0 ]
	then
		echo "ERROR - $tet_thistest failed."
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep desc2"
	if [ $? -eq 0 ]
	then
		echo "ERROR - $tet_thistest failed. ipa group-find passed when it should not have."
		tet_result FAIL
	fi

	tet_result PASS
}



######################################################################
# Cleanup Section for the cli tests
######################################################################
user_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0


	ssh root@$FULLHOSTNAME "ipa user-del $usr1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa user-del $usr2"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-del $grp2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "WARNING - $tet_thistest failed... not that it matters"
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
