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
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="user_cleanup"
iclist="ic1 ic2 ic3 ic4"
ic1="kinit"
ic2="addusersetup addusera adduserb adduserc adduserd addusere adduserf negadduser"
ic3="addlockuser kinit lock kinitlock kinit unlock kinitunlock kinit"
ic4="addmoduser addmodgroup modfirst modlast modemail modprinc modhome modgecos modgroup modgroup2 moduid modstreet modshell"

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
mshell="/bin/sh"
mstreet="334 wolfsten way"
muid="gidmodb"
mgroup1="mgroup1"
mgroup2="mgroup2"

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
# ipa-adduser
######################################################################
addusersetup()
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
			if [ $? -ne 0 ]
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
			if [ $? -ne 0 ]
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
			if [ $? -ne 0 ]; then
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
			if [ $? -ne 0 ]
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
			if [ $? -ne 0 ]
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
			if [ $? -ne 0 ]
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
			if [ $? -ne 0 ]
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
			if [ $? -ne 0 ]
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
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# add a group to be used with mod tests
######################################################################
addmodgroup()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa group-add --description=\"group that the user in the user-mod will include\" $mgroup"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-find $mgroup"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for group $mgroup failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the first name of $musr and verify
######################################################################
modfirst()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --first=$mfirst $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep $mfirst"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the last name of $musr and verify
######################################################################
modlast()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --last=$mlast $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep $mlast"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the email of $musr and verify
######################################################################
modemail()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --email=\'$memail\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \'$memail\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the principal of $musr and verify
######################################################################
modprinc()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --principal=\'$mprinc\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep $mlast"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the home dir of $musr and verify
######################################################################
modhome()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --home=\'$mhome\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \'$mhome\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the gecos entry of $musr and verify
######################################################################
modgecos()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --gecos=\'$mgecos\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \'$mgecos\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the group that $musr is in and verify
######################################################################
modgroup()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --groups=\'$mgroup1\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all $mgroup1 | grep \'$musr\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for $musr in $mgroup1 failed failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# place musr into 2 groups and verify
######################################################################
modgroup2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --groups=\'$mgroup1,$mgroup2\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all $mgroup1 | grep \'$musr\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for $musr in $mgroup1 failed failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all $mgroup2 | grep \'$musr\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for $musr in $mgroup2 failed failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the uid entry of $musr and verify
######################################################################
moduid()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --uid=\'$muid\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \'$muid\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the street entry of $musr and verify
######################################################################
modstreet()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --street=\'$muid\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \'$mstreet\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# modify the shell entry of $musr and verify
######################################################################
modshell()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --shell=\'$mshell\' $musr"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \'$mshell\'"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# ipa del-user 
# Create a user, verify that it exists, delete that user, then verify
#  that the user no longer exists.
######################################################################
deluser()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast --gecos=$superusergecos --home=$superuserhome --principal=$superuserprinc --email=$superuseremail deluser1"
	if [ $? -ne 0 ]
	then 
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-find $deluser1 | grep uid | grep $userdel1"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi


	ssh root@$FULLHOSTNAME "ipa user-del deluser1"
	if [ $? -ne 0 ]
	then
		echo "ERROR - Search for created user failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-find deluser1 | grep uid | grep userdel1"
	if [ $? -eq 0 ]
	then
		echo "ERROR - Search for deluser1 on $FULLHOSTNAME when is should not have"
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

	ssh root@$FULLHOSTNAME "ipa group-del $mgroup1"
	let code=$code+$?

	ssh root@$FULLHOSTNAME "ipa group-del $mgroup2"
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
