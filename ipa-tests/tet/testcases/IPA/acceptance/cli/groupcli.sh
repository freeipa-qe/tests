#!/bin/sh

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
message "groupcli"
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="kinit"
tet_cleanup="group_cleanup"
iclist="ic1 ic2 ic3 ic4"
ic1="add_group_users group_add group_find group_find_neg group_show group_show_neg"
ic2="group_add_posix group_mod_posix group_mod_neg_posix group_mod_description"
ic3="group_add_member_user group_add_member_user_neg group_add_member_group group_add_member_group_neg group_remove_member_group group_remove_member_group_neg group_remove_member_user group_remove_member_user_neg"
ic4="group_del"
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
	myresult=PASS
	tet_thistest="kinit"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: kinit everywhere"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			ret=$?
			if [ $ret -ne 0 ]; then
				message "ERROR - kinit on $s failed"
				myresult=FAIL
			fi
		else
			message "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			ret=$?
			if [ $ret -ne 0 ]; then
				message "ERROR - kinit on $s failed"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

# This is the startup for the group tests. Mainly, it just creates the users to be used in the add and remove member tests 
add_group_users()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add Users for Testing Memberships"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa user-add --first=\"firstuname\" --last=\"lastuname\" $usr1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa user-add --first=\"firstuname2\" --last=\"lastuname2\" $usr2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}


group_add()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add Group"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add --description=group-to-test-groups $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep group-to-test-groups"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_find()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Find Group"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep group-to-test-groups"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_find_neg()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Find Group That Doesn't Exist -Negative"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-find nonexistgroup"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. ipa group-find passed when it should not have"
		message "ERROR - This failure might be related to https://bugzilla.redhat.com/show_bug.cgi?id=501840"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_show()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Show Group"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-show $grp1 | grep group-to-test-groups"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_show_neg()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Show Group That Doesn't Exist - Negative"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-show nonexistgroup"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. ipa group-find passed when it should not have"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_add_posix()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add Posix Group"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add --posix --description=group-to-test-posix $grp2"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-show --all $grp2 | grep posixGroup"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_mod_posix()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Group - Add Posix"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-mod --posix $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-show --all $grp1 | grep posixgroup"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_mod_neg_posix()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Posix Group - Add Posix - Negative"
	eval_vars M1
	code=0

	# This should fail because this group should already be a posix group
	ssh root@$FULLHOSTNAME "ipa group-mod --posix $grp1"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. ipa group-mod --posix $grp1 worked when it should not have."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_mod_description()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Group Description"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-mod --description=desc2 $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep desc2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_add_member_user()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add User Members"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$usr1,$usr2 $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-show $grp1 | grep $usr1"
	let code=$code+$?

        ssh root@$FULLHOSTNAME "ipa group-show $grp1 | grep $usr2"
        let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_add_member_user_neg()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add User Member That Already is a Member - Negative"
	eval_vars M1
	code=0

	# This should fail because these users should already be in this group
	ssh root@$FULLHOSTNAME "ipa group-add-member --users=$usr1,$usr2 $grp1"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed."
		message "ERROR - This is likley related to bug https://bugzilla.redhat.com/show_bug.cgi?id=499464"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_add_member_group()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add Group Members"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grp2 $grp1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $grp2"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_add_member_group_neg()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add Group Member That Already is a Member - Negative"
	eval_vars M1
	code=0

	# This should fail because this group should already be in this group
	ssh root@$FULLHOSTNAME "ipa group-add-member --groups=$grp2 $grp1"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed."
		message "ERROR - This is likley related to bug https://bugzilla.redhat.com/show_bug.cgi?id=499464"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_remove_member_group()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Remove Group Member"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-remove-member --groups=$grp2 $grp1"
	if [ $? -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $grp2"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. $grp2 still appears to be in $grp1 when it should not be"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_remove_member_group_neg()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Remove Group Member That isn't a Member - Negative"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-remove-member --groups=$grp2 $grp1"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. group-remove-member returned a 0 when it should not have"
		message "ERROR - This failure may be related to https://bugzilla.redhat.com/show_bug.cgi?id=501841"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $grp2"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. $grp2 still appears to be in $grp1 when it should not be"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_remove_member_user()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Remove User Member"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-remove-member --users=$usr2 $grp1"
	if [ $? -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $usr2"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. $grp2 still appears to be in $grp1 when it should not be"
		myresult=FAIL
	fi

        ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $usr1"
        if [ $? -ne 0 ]
        then
                message "ERROR - $tet_thistest failed. $grp1 is not in $grp1 when it should be"
                myresult=FAIL
        fi

	result $myresult
	message "END $tet_thistest"
}

group_remove_member_user_neg()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Remove User Member That isn't a Member - Negative"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-remove-member --users=$usr2 $grp1"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. group-remove-member returned a 0 when it should not have"
		message "ERROR - This failure may be related to https://bugzilla.redhat.com/show_bug.cgi?id=501841"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep $usr2"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. $grp2 still appears to be in $grp1 when it should not be"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

group_del()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Delete Group"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-del $grp1"
	if [ $? -ne 0 ]
	then
		message "ERROR - $tet_thistest failed."
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $grp1 | grep desc2"
	if [ $? -eq 0 ]
	then
		message "ERROR - $tet_thistest failed. ipa group-find passed when it should not have."
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}



######################################################################
# Cleanup Section for the cli tests
######################################################################
group_cleanup()
{
	myresult=PASS
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Cleanup"
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
		message "WARNING - $tet_thistest failed... not that it matters"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
#
. $TESTING_SHARED/instlib.sh
. $TESTING_SHARED/shared.sh
. $TET_ROOT/lib/sh/tcm.sh
