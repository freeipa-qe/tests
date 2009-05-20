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
ic1="add_group_users group_add group_find group_add_posix group_mod_neg_posix group_mod_posix group_mod_description group_add_member_user group_add_member_group group_del"
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
	tet_thistest="cleanup"
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
	tet_thistest="cleanup"
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
	tet_thistest="cleanup"
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

group_add_posix()
{
	tet_thistest="cleanup"
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
	tet_thistest="cleanup"
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
	tet_thistest="cleanup"
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
	tet_thistest="cleanup"
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
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$usr1 $grp1"
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

group_add_member_group()
{
	tet_thistest="cleanup"
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

group_del()
{
	tet_thistest="cleanup"
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
