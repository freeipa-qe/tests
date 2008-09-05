#!/bin/ksh

######################################################################

######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="pw_cleanup"
iclist="ic1 ic2"
ic1="tp1"
#ic2="tp2a tp2b"
ic2="tp2 tp2a tp2b tp3 tp4 tp5 tp6"
hour=0
min=0
sec=0
month=0
day=0
year=0

# options to use throughout the tests
minlife=2
# this value must not be 7 as that number is used in the end of tp3
maxlife=2
phistory=2

# This function populates the current date into the hour, min, sec, month, day and year vars
get_time()
{
	export month=$(date +%m)
	export day=$(date +%d)
	export year=$(date +%Y)
	export hour=$(date +%H)
	export min=$(date +%M)
	export sec=$(date +%S)
}

######################################################################
ResetKinit()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        # Kinit everywhere
        for s in $SERVERS; do
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
}

tp1()
{
        echo "START $tet_thistest"
	ResetKinit
        tet_result PASS
        echo "END $tet_thistest"

}

######################################################################
# minlife
# tp2 runs multiple tests
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusr1"
	user1pw1="D4mkcidytte3."
	user1pw2="93847ccjdmeo8765"
	user1pw3="lo9sh3nchd765"
	user1pw4="lso9383j4nchst63^"

	eval_vars M1
	# set date on m1 to make sure it's what we think it is
	get_time
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife $minlife"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Now attempt to set the password of user1, this should fail.
	echo "This should fail because the min password age hasn't been reached yet"
	SetUserPassword M1 $user1 $user1pw3
	# Download the output from M1 to ensuer that it didn't work
	rm -f $TET_TMP_DIR/SetUserPassword.tmp
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - change password produced a error"
		echo "kinit is:"
		ssh root@$FULLHOSTNAME "klist"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# incriment date 
	let newhour=$hour+$minlife+1
	if [ $newhour -gt 23 ]; then
		# Hour would be two high, incrimenting day
		let newday=$day+1;
		export hour='02'
		day=`printf "%02d" $newday`
		export day
	fi

	# Set the date forward to make the date change valid
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Now attempt to set the password of user1, this should pass.
	SetUserPassword M1 $user1 $user1pw4
	# Download the output from M1 to ensure that it didn't work
	rm -f $TET_TMP_DIR/SetUserPassword.tmp
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	grep 'Password Fails to meet minimum strength criteria' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - change password didn't seem to fail in the way it should have"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# Now, parse the output of the last SetUserPassword to ensure that everything worked.
	
	tet_result PASS

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minlife
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 1
# 1 minlife = 0
#    1.   setup default environment
#    2. setup default password policy
#    3. change Min. password lifetime to 0
#      verify user can change their password immediately 
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 2
######################################################################
tp2a()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusra"
	user1pw1="D4mkcidyte3."
	user1pw2="93847ccjmeo8765"
	user1pw3="lo9sh3ncd765"

	eval_vars M1
	# set date on m1 to make sure it's what we think it is
	get_time
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set password policy
	# first set it to a value so the change to 0 won't fail
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Now attempt to set the password of user1, this should fail.
	echo "This should work because the minpassword age has been set to 0"
	SetUserPassword M1 $user1 $user1pw3
	# Download the output from M1 to ensuer that it didn't work
	rm -f $TET_TMP_DIR/SetUserPassword.tmp
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - change password produced a error"
		echo "kinit is:"
		ssh root@$FULLHOSTNAME "klist"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# Now, parse the output of the last SetUserPassword to ensure that everything worked.
	
	tet_result PASS

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minlife
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 2
# 2 minlife = -1
#   1. setup default environment
#   2. setup default password policy
#   3. change Min. password lifetime to -1 via CLI
#      verify this number can not be accepted through CLI (ipa-pwpolicy) 
######################################################################
tp2b()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrb"
	user1pw1="D4mkcidyte3."
	user1pw2="93847ccjmeo8765"
	user1pw3="lo9sh3ncd765"

	eval_vars M1
	# set date on m1 to make sure it's what we think it is
	get_time
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	
	eval_vars M1

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife -1"
	if [ $? -eq 0 ]; then
		echo "ERROR - ipa-pwpolicy --minlife -1 on $FULLHOSTNAME passed when it should not have, "
		echo "This could be failing because of bug https://bugzilla.redhat.com/show_bug.cgi?id=461213"
		tet_result FAIL
	fi


	tet_result PASS

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# maxlife
######################################################################
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrc"
	user1pw1="D4mkidytte3."
	user1pw2="9384c.dmeo8765"
	user1pw3="lo9s3n.hd765"
	user1pw4="lso983.4nchst63^"

	eval_vars M1
	# set date on m1 to make sure it's what we think it is
	get_time
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	
	eval_vars M1

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife $maxlife"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# kinit as the user to make sure the password is valid
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# incriment hour by $minlife+1 days for testing positive case later 
	let newhour=$hour+$minlife+1
	if [ $newhour -gt 23 ]; then
		# Hour would be two high, incrimenting day
		export hour='02'
		let newday=$day+1;
		if [ $newday -gt 28 ]; then
			# Day might be two high, setting the month higher
			export day='01'
			let newmonth=$month+1;
			if [ $newmonth -gt 12 ]; then
				# month will now be greater than december, incrimenting year
				export month='01'
				let year=$year+1
				export year
			else 
				export month=`printf "%02d" $newmonth`
			fi
		else
			export day=`printf "%02d" $newday`
		fi
	else
		export hour=`printf "%02d" $newhour`
	fi

	# incriment date by day + maxlife + 2
	let newday=$day+$maxlife+2;
	if [ $newday -gt 28 ]; then
		# Day might be two high, setting the month higher
		export day='01'
		let newmonth=$month+1;
		if [ $newmonth -gt 12 ]; then
			# month will now be greater than december, incrimenting year
			export month='01'
			let year=$year+1
			export year
		else 
			export month=`printf "%02d" $newmonth`
		fi
	else
		export day=`printf "%02d" $newday`
	fi

	# Set the date to the new data
	echo "Setting date to $month$day$hour$min$year" 
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw2 $user1pw3
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password expired' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - password did not seem to expire when it should have"
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 7"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# pw history
######################################################################
tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrd"
	user1pw1="D4mkidytte3."
	user1pw2="9384.jdm.o8765"
	user1pw3="lo9s3.chd.65"
	user1pw4="lso983j4nc.st63^"

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1	
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password for user $user1 failed"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history $phistory"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# kinit as the user to make sure the password is valid
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw3 for user $user1 failed"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a password 2 passwords ago, this should fail
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minclasses
######################################################################
tp5()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusre"
	user1pw1="D4mkcidytte3." # pw with 2 classes
	user1pw2="lo9sh3NCh.765" # pw with 4 classes
	user1pw3="938478765" # pw with one class
	user1pw4="lo9sh3765" # pw with 2 classes

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 2"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Kinit as that user, ensure that it worked
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a password with only one class, this should fail
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a pw that should work
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minlength
######################################################################
tp6()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrf"
	user1pw1="D4mkcidytte3." # pw 
	user1pw2="lo9sh3NCh.765" # pw with greater than 5 char
	user1pw3="9nH." # pw with less than 5 char
	user1pw4="lo9sh3765" # pw with greater than 5 char

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlength 5"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Kinit as that user, ensure that it worked
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a password with only 4 char, this should fail
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a pw that should work
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	# cleaning up the user
	ssh root@$FULLHOSTNAME "ipa-deluser $user1"

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlength 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Cleanup Section for the cli tests
######################################################################
pw_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0


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
