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
iclist="adduserlist locklist modlist"
adduserlist="kinit adduser addusera adduserb adduserc adduserd addusere adduserf negadduser"
locklist="addlockuser kinit lock kinitlock kinit unlock kinitunlock kinit"
modlist="addmoduser"
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

lusr="locku44"
lusrpw="o3948cyhdg65"

# Users to be used in user-mod tests
musr="msup88"
musremail="$musr@really.cool.domain.co.uk.us.fi.com"
musrprinc="principal$musr"
mhome="/home2/$musr"
mgecos="whatsgecos?"
mfirst="Superuser"
mlast="crazylastnametoolong"

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
			ssh root@$FULLHOSTNAME "ipa user-find --all $superuser | grep $superuserprinc"
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
# add a user to be used with lock tests
######################################################################
addlockuser()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast $lusr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $lusr | grep uid | grep $lusr"
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - Search for created user failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
		fi
	done

	# Set up the password of the new user so that they can kinit later
	SetUserPassword M1 $lusr pw
	if [ $? -ne 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	KinitAsFirst M1 $lusr pw $lusrpw
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# lock the user that we just created in addlockuser 
# kinit should get called before this test
######################################################################
lock()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-lock $lusr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-lock failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# kinit as lusr to ensure that it doesn't work
######################################################################
kinitlock()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

 	KinitAs $s $lusr $lusrpw
	if [ $? -eq 0 ]
	then 
		echo "ERROR - kinit as $lusr worked on $FULLHOSTNAME when it should not have"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# uplock the user that we just created in addlockuser 
# kinit should be run before this test
######################################################################
unlock()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-lock $lusr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-lock failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# kinit as lusr to ensure that it doesn't work
######################################################################
kinitunlock()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

 	KinitAs $s $lusr $lusrpw
	if [ $? -ne 0 ]
	then 
		echo "ERROR - kinit as $lusr failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# add a user to be used with mod tests
######################################################################
addmoduser()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=superuserfirst --last=superuserlast $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-find $musr | grep uid | grep $musr"
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
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

	ssh root@$FULLHOSTNAME "ipa user-del $lusr"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa user-del $musr"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "ERROR - setup for $tet_thistest failed - not that it matters"
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
