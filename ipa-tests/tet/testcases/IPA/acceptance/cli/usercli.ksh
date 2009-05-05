#!/bin/ksh

######################################################################

# The following ipa cli commands needs to be tested:
#  user-add                  Add a new user.
#  user-del                  Delete an existing user.
#  user-find                 Search for users.
#  user-lock                 Lock a user account.
#  user-mod                  Edit an existing user.
#  user-show                 Examine an existing user.
#  user-unlock               Unlock a user account.

######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="user_cleanup"
iclist="ic1"
ic1="kinit adduser addusera adduserb adduserc adduserd addusere adduserf negadduser"
# These services will be used by the tests, and removed when the cli test is complete
host1='alpha.dsdev.sjc.redhat.com'
service1="ssh/$host1"
service2="nfs/$host1"
service3="ldap/$host1"

# Users to be used in varios tests
superuser="sup34"
superuseremail="$superuser@really.cool.domain.co.uk.us.fi.com"
superuserprinc="principal$superuser"
superuserhome="/home2/$superuser"
superusergecos="whatsgecos?"
superuserfirst="Superuser"
superuserlast="crazylastnametoolong"

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

######################################################################
# ipa-adduser
######################################################################
adduser()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast --gecos=$superusergecos --home=$superuserhome --principal=$superuserprinc --email=$superuseremail $superuser"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep uid | grep $superuser"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 1. First name
######################################################################
addusera()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep $superuserfirst"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 2. Last name
######################################################################
adduserb()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep $superuserlast"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 3. gecos name
######################################################################
adduserc()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find --all $superuser | grep $superusergecos"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 4. Home directory 
######################################################################
adduserd()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep $superuserhome"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 5. Principal
######################################################################
addusere()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find -all $superuser | grep $superuserprinc"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 6. email
######################################################################
adduserf()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find --all $superuser | grep $superuseremail"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# Negitive test case of ipa-adduser
######################################################################
negadduser()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast --gecos=$superusergecos --home=$superuserhome --principal=$superuserprinc --email=$superuseremail $superuser"
	if [ $? -eq 0 ]
	then 
		echo "ERROR - ipa user-add passed when it should not have $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
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


	ssh root@$FULLHOSTNAME "ipa user-del $superuser"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - setup for $tet_thistest failed"
		tet_result FAIL
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
