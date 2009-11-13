#!/bin/sh

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
iclist="ic1 ic2 ic3 ic4 ic5"
ic1="kinit"
ic2="addusersetup addusera adduserb adduserc adduserd addusere adduserf negadduser"
ic3="addlockuser kinit lock kinitlock kinit unlock kinitunlock kinit"
ic4="addmoduser modfirst modlast modemail modprinc modhome modgecos modgroup modgroup2 moduid modstreet modshell"
ic5="deluser user_cleanup"

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
memail="$musr@really.cool.domain.co.uk.us.fi.com"
mprinc="principal$musr"
mhome="/home2/$musr"
mgecos="whatsgecos?"
mfirst="NewFirst"
mlast="NewLast"
mshell="/bin/sh"
mstreet="334 wolfsten way"
muid="412842"
mgroup1="mgroup1"
mgroup2="mgroup2"

######################################################################
kinit()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: Kinit Everywhere"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			if [ $? -ne 0 ]; then
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
			if [ $? -ne 0 ]; then
				message "ERROR - kinit on $s failed"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser
######################################################################
addusersetup()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add User"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast --gecos=$superusergecos --home=$superuserhome --principal=$superuserprinc --email=$superuseremail $superuser"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-add failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep id | grep $superuser"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 1. First name
######################################################################
addusera()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Verify User's First Name"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep $superuserfirst"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 2. Last name
######################################################################
adduserb()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Verify User's Last Name"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep $superuserlast"
			if [ $? -ne 0 ]; then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 3. gecos name
######################################################################
adduserc()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Verify User's GECOS"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find --all $superuser | grep $superusergecos"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 4. Home directory 
######################################################################
adduserd()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Verify User's Home Directory"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $superuser | grep $superuserhome"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 5. Principal
######################################################################
addusere()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Verify User's Principal Name"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find --all $superuser | grep $superuserprinc"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa-adduser content test 6. email
######################################################################
adduserf()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Verify User's Email"

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find --all $superuser | grep $superuseremail"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# Negitive test case of ipa-adduser
######################################################################
negadduser()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add Duplication User - Negative"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast --gecos=$superusergecos --home=$superuserhome --principal=$superuserprinc --email=$superuseremail $superuser"
	if [ $? -eq 0 ]
	then 
		message "ERROR - ipa user-add passed when it should not have $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# add a user to be used with lock tests
######################################################################
addlockuser()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add user - Set Password - Kinit"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast $lusr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-add failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh root@$FULLHOSTNAME "ipa user-find $lusr | grep id | grep $lusr"
			if [ $? -ne 0 ]
			then
				message "ERROR - Search for created user failed on $FULLHOSTNAME"
				myresult=FAIL
			fi
		fi
	done

	# Set up the password of the new user so that they can kinit later
	SetUserPassword M1 $lusr pw
	if [ $? -ne 0 ]; then
		message "ERROR - SetUserPassword failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	KinitAsFirst M1 $lusr pw $lusrpw
	if [ $? -ne 0 ]; then
		message "ERROR - kinit failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# lock the user that we just created in addlockuser 
# kinit should get called before this test
######################################################################
lock()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Lock User"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-lock $lusr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-lock failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# kinit as lusr to ensure that it doesn't work
######################################################################
kinitlock()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Kinit Locked User"
	eval_vars M1

 	KinitAs $s $lusr $lusrpw
	if [ $? -eq 0 ]
	then 
		message "ERROR - kinit as $lusr worked on $FULLHOSTNAME when it should not have"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# uplock the user that we just created in addlockuser 
# kinit should be run before this test
######################################################################
unlock()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Unlock User"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-unlock $lusr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-lock failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# kinit as lusr to ensure that it doesn't work
######################################################################
kinitunlock()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Kinit As Unlocked User"
	eval_vars M1

 	KinitAs $s $lusr $lusrpw
	if [ $? -ne 0 ]
	then 
		message "ERROR - kinit as $lusr failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# add a user to be used with mod tests
######################################################################
addmoduser()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add User - Define Only Required Attributes"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-add --first=superuserfirst --last=superuserlast $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-add failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-find $musr | grep id | grep $musr"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the first name of $musr and verify
######################################################################
modfirst()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify First Name"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --first=$mfirst $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep $mfirst"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the last name of $musr and verify
######################################################################
modlast()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Last Name"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --last=$mlast $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep $mlast"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the email of $musr and verify
######################################################################
modemail()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Email"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --email=\'$memail\' $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep '$memail'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the principal of $musr and verify
######################################################################
modprinc()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Principal Name"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --principal=$mprinc $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep $mprinc"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the home dir of $musr and verify
######################################################################
modhome()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Home Directory"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --home=\'$mhome\' $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep '$mhome'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result PASS
	message "END $tet_thistest"
}

######################################################################
# modify the gecos entry of $musr and verify
######################################################################
modgecos()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify GECOS"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --gecos=$mgecos $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep '$mgecos'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result PASS
	message "END $tet_thistest"
}

######################################################################
# modify the group that $musr is in and verify
######################################################################
modgroup()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Group Membership"
	eval_vars M1

        ssh root@$FULLHOSTNAME "ipa group-add --desc=\"group that the user in the user-mod will include\" $mgroup1"
        if [ $? -ne 0 ]
        then
                message "ERROR - ipa group-add failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "ipa group-find $mgroup1"
        if [ $? -ne 0 ]
        then
                message "ERROR - Search for group $mgroup1 failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --users $musr $mgroup1"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		message "ERROR possibly related to https://bugzilla.redhat.com/show_bug.cgi?id=502114"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all $mgroup1 | grep '$musr'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for $musr in $mgroup1 failed failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# place musr into 2 groups and verify
######################################################################
modgroup2()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Second Group Membership"
	eval_vars M1

        ssh root@$FULLHOSTNAME "ipa group-add --desc=\"group2 that the user in the user-mod will include\" $mgroup2"
        if [ $? -ne 0 ]
        then
                message "ERROR - ipa group-add failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "ipa group-find $mgroup2"
        if [ $? -ne 0 ]
        then
                message "ERROR - Search for group $mgroup2 failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

	ssh root@$FULLHOSTNAME "ipa group-add-member --users $musr $mgroup2"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		message "ERROR possibly related to ttps://bugzilla.redhat.com/show_bug.cgi?id=502114"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all $mgroup1 | grep '$musr'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for $musr in $mgroup1 failed failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa group-show --all $mgroup2 | grep '$musr'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for $musr in $mgroup2 failed failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the uid entry of $musr and verify
######################################################################
moduid()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify UID"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --uid=$muid $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		message "ERROR may be related to https://bugzilla.redhat.com/show_bug.cgi?id=502684"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep '$muid'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME."
		message "ERROR may be related to https://bugzilla.redhat.com/show_bug.cgi?id=519481"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the street entry of $musr and verify
######################################################################
modstreet()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Street"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --street=\"$mstreet\" $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep \"$mstreet\""
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# modify the shell entry of $musr and verify
######################################################################
modshell()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Modify Default Shell"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-mod --shell=\'$mshell\' $musr"
	if [ $? -ne 0 ]
	then 
		message "ERROR - ipa user-mod failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-show --all $musr | grep '$mshell'"
	if [ $? -ne 0 ]
	then
		message "ERROR - Search for created user failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}

######################################################################
# ipa del-user 
# Create a user, verify that it exists, delete that user, then verify
#  that the user no longer exists.
######################################################################
deluser()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Delete User"
	eval_vars M1

	ssh root@$FULLHOSTNAME "ipa user-del $superuser"
	if [ $? -ne 0 ]
	then
		message "ERROR - Deleting user $superuser failed on $FULLHOSTNAME"
		myresult=FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa user-find $superuser"
	if [ $? -eq 0 ]
	then
		message "ERROR - Search for deleted user was successful on $FULLHOSTNAME when is should not have"
		message "ERROR possibly related to https://bugzilla.redhat.com/show_bug.cgi?id=504021"
		myresult=FAIL
	fi

        ssh root@$FULLHOSTNAME "ipa user-del $musr"
        if [ $? -ne 0 ]
        then
                message "ERROR - Deleting user $musr failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "ipa user-find $musr"
        if [ $? -eq 0 ]
        then
                message "ERROR - Search for deleted user was successful on $FULLHOSTNAME when is should not have"
		message "ERROR possibly related to https://bugzilla.redhat.com/show_bug.cgi?id=504021"
		message 
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "ipa user-del $lusr"
        if [ $? -ne 0 ]
        then
                message "ERROR - Deleting user $lusr failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

        ssh root@$FULLHOSTNAME "ipa user-find $lusr"
        if [ $? -eq 0 ]
        then
                message "ERROR - Search for deleted user was successful on $FULLHOSTNAME when is should not have"
		message "ERROR possibly related to https://bugzilla.redhat.com/show_bug.cgi?id=504021"
                myresult=FAIL
        fi

	result $myresult
	message "END $tet_thistest"
}


######################################################################
# Cleanup Section for the cli tests
######################################################################
user_cleanup()
{
	myresult=PASS
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Cleanup"
	eval_vars M1
	code=0

	ssh root@$FULLHOSTNAME "ipa group-del $mgroup1"
	if [ $? -ne 0 ]
        then
                message "ERROR - setup for $tet_thistest failed - not that it matters"
                myresult=FAIL
        fi

	ssh root@$FULLHOSTNAME "ipa group-del $mgroup2"
	if [ $? -ne 0 ]
	then
		message "ERROR - setup for $tet_thistest failed - not that it matters"
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
