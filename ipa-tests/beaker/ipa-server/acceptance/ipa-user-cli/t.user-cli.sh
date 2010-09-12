#############################################
# this is a testcase file for user-cli test #
#############################################

t_addusersetup()
{
    rlPhaseStartTest "add user setup"

        rlRun "ipa user-add --first=$superuserfirst --last=$superuserlast --gecos=$superusergecos --home=$superuserhome --principal=$superuserprinc --email=$superuseremail $superuser"
        if [ $? -ne 0 ];then 
         message "ERROR - ipa user-add failed on $FULLHOSTNAME"
         myresult=FAIL
        fi

        rlRun "ipa user-find $superuser | grep id | grep $superuser"
        if [ $? -ne 0 ];then
            message "ERROR - Search for created user failed on $FULLHOSTNAME"
            myresult=FAIL
        fi 
        result $myresult
        message "END $tet_thistest"

    rlPhaseEnd
} #t_addusersetup

t_addusera()
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
} #t_addusera

t_adduserb()
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
} #t_adduserb

t_adduserc()
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
} #t_adduserc

t_adduserd()
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
} #t_adduserd

t_addusere()
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
} #t_addusere

t_adduserf()
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
} #t_adduserf

t_negative_adduser()
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
} #t_negative_adduser

t_addlockuser
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
} #t_addlockuser

t_lockuser()
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
} # t_lockuser

t_kinitlock()
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
} #t_kinitlock

t_unlock()
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
} #t_unlock

t_addmoduser()
t_modlastname()
t_modfirstname()
t_modemail()
t_modprinc()
t_modhome()
t_modgecos()
t_modgroup()
t_modgroup2()
t_moduid()
t_modstreet()
t_modshell()
t_adddeluser()
t_deluser()

