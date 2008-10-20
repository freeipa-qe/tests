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
ic1="tp1 tp1a"
ic2="tp2 tp2a tp2b tp2c tp3 tp3a tp3b tp4 tp4a tp4b tp5 tp5a tp6 tp6a"
hour=0
min=0
sec=0
month=0
day=0
year=0

# options to use throughout the tests
minlife=5
# this value must not be 7 as that number is used in the end of tp3
maxlife=1
phistory=3

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

#####################################################################
SyncDate()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"&
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"&
		fi
	done
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
				echo "Test - $tet_thistest - ResetKinit"
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
				echo "Test - $tet_thistest - ResetKinit"
                                tet_result FAIL
                        fi
                fi
        done
}

tp1()
{
        echo "START $tet_thistest"
	# Setting the time and date on all of the servers and clients if we can
	SyncDate
	eval_vars M1
        tet_result PASS
        echo "END $tet_thistest"
}


tp1a()
{
        echo "START $tet_thistest"
	ResetKinit
	/etc/init.d/ipa_kpasswd restart
        tet_result PASS
        echo "END $tet_thistest"
}

######################################################################
# minlife
# tp2 runs multiple tests
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 4
#   1.   setup default environment
#   2. setup default password policy
#   3. change Min.password lifetime to 5
#       a.   change system time to now + 5 hours - 1 hour, the password is still valid, and user can not change password
#       b. change system time to now + 5 hours, the password still valid, but user IS be able to change its password
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife $minlife"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# incriment date by minlife - 1 
	let newhour=$hour+$minlife-1
	if [ $newhour -gt 23 ]; then
		# Hour would be two high, incrimenting day
		let newday=$day+1;
		let thour=$newhour-23
		hour=`printf "%02d" $thour`
		export hour
		day=`printf "%02d" $newday`
		export day
	fi

	# Set the date forward to make the date change valid
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME to $month$day$hour$min$year failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - change password produced a error"
		echo "Test - $tet_thistest"
		echo "kinit is:"
		ssh root@$FULLHOSTNAME "klist"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# incriment date 
	let newhour=$hour+$minlife
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
		echo "ERROR - setting the date on $FULLHOSTNAME to $month$day$hour$min$year failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Now attempt to set the password of user1, this should pass.
	SetUserPassword M1 $user1 $user1pw4
	# Download the output from M1 to ensure that it didn't work
	rm -f $TET_TMP_DIR/SetUserPassword.tmp
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	grep 'Password Fails to meet minimum strength criteria' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - change password didn't seem to fail in the way it should have"
		echo "Test - $tet_thistest"
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

	SyncDate
	eval_vars M1

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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set password policy
	# first set it to a value so the change to 0 won't fail
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - change password produced a error"
		echo "Test - $tet_thistest"
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

	SyncDate
	eval_vars M1

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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	
	eval_vars M1

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife -1"
	if [ $? -eq 0 ]; then
		echo "ERROR - ipa-pwpolicy --minlife -1 on $FULLHOSTNAME passed when it should not have, "
		echo "Test - $tet_thistest"
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

	SyncDate
	eval_vars M1

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minlife > maxlife
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 12
#
#   1.   setup default environment
#   2. setup default password policy
#   3. change max passowrd life to 2
#   4. change Min.password lifetime to 2160
#   Verify that it fails
######################################################################
tp2c()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"


	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	
	# Set max life to 2 
	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 2"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy --maxlife 2 on $FULLHOSTNAME passed when it should not have"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set minlife to 2160 this should fail 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 2160"
	if [ $? -eq 0 ]; then
		echo "ERROR - ipa-pwpolicy --minlife 2160 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		echo "Possibly it failed because https://bugzilla.redhat.com/show_bug.cgi?id=461332 is still open?"
		tet_result FAIL
	fi

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 7"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 2"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	SyncDate
	eval_vars M1

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# maxlife
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 9
#   1.   setup default environment
#   2. setup default password policy
#   3. change Max. password lifetime to 1
#   4. change system time to 1 days later, and do kinit <username>
# Verify that it worked
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	
	eval_vars M1

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife $maxlife"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user to make sure the password is valid
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw2 $user1pw3
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password expired' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - password did not seem to expire when it should have"
		echo "Test - $tet_thistest"
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
	if [ $? -ne 0 ]; then
		ResetKinit
		ssh root@$FULLHOSTNAME "ipa-deluser $user1"
	fi

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 7"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	SyncDate
	eval_vars M1

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# maxlife < minlife
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 6
#
#   1.   setup default environment
#   2. setup default password policy
#   3. change Min.password lifetime to 2160
#   4. change max passowrd life to 5
#   Verify that it fails
######################################################################
tp3a()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"


	# Reset the kinit on all of the machines
	ResetKinit
	# Return pw policy to default
	eval_vars M1
	
	# set minlife to 2160 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 400"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 2160"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy --minlife 2160 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Set max life to 5 (this should fail
	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 5"
	if [ $? -eq 0 ]; then
		echo "ERROR - ipa-pwpolicy --maxlife 5 on $FULLHOSTNAME passed when it should not have"
		echo "Test - $tet_thistest"
		echo "Possibly becuase https://bugzilla.redhat.com/show_bug.cgi?id=461325 is not fixed"
		tet_result FAIL
	fi
	
	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 7"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 2"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	SyncDate
	eval_vars M1

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# maxlife
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 10
#   1.   setup default environment
#   2. setup default password policy
#   3. change Min. password lifetime to 0
# Verify that user can change password
######################################################################
tp3b()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrh"
	user1pw1="D4mkidyte3."
	user1pw2="9384c.deo8765"
	user1pw3="lo9s3n.h765"
	user1pw4="lso983.4nhst63^"

	eval_vars M1
	# set date on m1 to make sure it's what we think it is
	get_time
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	
	eval_vars M1

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 4"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user to make sure the password is valid
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw2 $user1pw3
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password expired' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - password seemed to expire when it should not have"
		echo "Test - $tet_thistest"
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
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 44"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --maxlife 7"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	SyncDate
	eval_vars M1

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# pw history
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 19
#   1.   setup default environment
#   2. setup default password policy
#   3. change min. password lifetime to 0
#   4. change history size = 3
#   5. create a user "usr", set the default password to "redhat000"
#    1.   modify "usr" 's password to "redhat001", it should be accepted
#    2. modify "usr" 's password to "redhat002", it should be accepted
#    3. modify "usr" 's password to "redhat003", it should be accepted
#    4. modify "usr" 's password to "redhat001", it should NOT be accepted
#    5. modify "usr" 's password to "redhat002", it should NOT be accepted
#    6. modify "usr" 's password to "redhat003", it should NOT be accepted
#    7. modify "usr" 's password to "redhat004", it should be accepted
######################################################################
tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrd"
	user1pw0="redhat000"
	user1pw1="redhat001"
	user1pw2="redhat002"
	user1pw3="redhat003"
	user1pw4="redhat004"

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1	

	# Set minlife 2 zero so that the user can rapidly change it's passowrd
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 0"

	#   5. create a user "usr", set the default password to "redhat000"

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw0	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password for user $user1 failed"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history $phistory"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user to make sure the password is valid
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw0 $user1pw1
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	#    2. modify "usr" 's password to "redhat002", it should be accepted

	# set that users password
	SetUserPassword M1 $user1 $user1pw2
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi


	#    3. modify "usr" 's password to "redhat003", it should be accepted

	# set that users password
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw3 for user $user1 failed"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	#    4. modify "usr" 's password to "redhat001", it should NOT be accepted

	# set that users password to a password 2 passwords ago, this should fail
	SetUserPassword M1 $user1 $user1pw1
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	#    5. modify "usr" 's password to "redhat002", it should NOT be accepted

	SetUserPassword M1 $user1 $user1pw2
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	#    6. modify "usr" 's password to "redhat003", it should NOT be accepted

	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	#    7. modify "usr" 's password to "redhat004", it should be accepted

	# set that users password
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw3 for user $user1 failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# pw history
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 18
#   1.   setup default environment
#   2. setup default password policy
#   3. change min. password lifetime to 0
#   4. change history size = 0
#   5. create a user "usr", set its default password to "redhat001"
#   6. run ipa-passwd to modify "usr" 's password with same value "redhat001"
#  verify that the user can set password back to redhat001
######################################################################
tp4a()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusre"
	user1pw1="D4mkidytte3."
	user1pw2="redhat001"
	user1pw3="redhat001"
	user1pw4="redhat001"

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1	
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password for user $user1 failed"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# kinit as the user to make sure the password is valid
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw3 for user $user1 failed"
		echo "Test - $tet_thistest"
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
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# pw history 
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 20
#   1.   setup default environment
#   2. setup default password policy
#   3. change pw min lifetime to 0
#   4. change history size to -1 via ldapmodify
# confirm that pwpolicy gives a non-zero exit code, and a error message 
######################################################################
tp4b()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	# Get a new admin ticket to be sure that the ticket won't be expired
	ResetKinit	

	eval_vars M1	

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history -1" 
	if [ $? -eq 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME passed when is should not have"
		echo "possibly because bug https://bugzilla.redhat.com/show_bug.cgi?id=461543 is not fixed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# resetting password policy 
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --history 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
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

	user1="testusri"
	user1pw1="D4mkcidytte3." # pw with 2 classes
	user1pw2="lo9sh3NCh.765" # pw with 4 classes
	user1pw3="938478765" # pw with one class
	user1pw4="lo9sh3765" # pw with 2 classes

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 2"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Kinit as that user, ensure that it worked
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a password with only one class, this should fail
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

	# set that users password to a pw that should work
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minclasses
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 14
#   1.   setup default environment
#   2. setup default password policy
#   3. change min. password lifetime to 0
#   4. change character class to 0
#   5. change one user's password to 12345678
# verify that the value is accepted
######################################################################
tp5a()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrt"
	user1pw1="D4mkcidytte3." # pw with 2 classes
	user1pw2="12345678" # pw with 4 classes

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 44"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Kinit as that user, ensure that it worked
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "Test - $tet_thistest"
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
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 0"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minlength
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 24
#   1.   setup default environment
#   2. setup default password policy
#   3. change min. password lifetime to 0
#   4. change min. character class to 0
#   5. change min. password length to 9
#   6. create a user "usr", set its default password to "redhat0000"
#   7. verify user password is valid
#    1.   user can change its password to "123456789"
#    2. user can change its password to "1234567890"
#    3. user can NOT change its password to "12345678"
#    4. user can NOT change its password to "1"
#    5. user can NOT change its password to "" (blank) -- I'm probably not going to test this step

######################################################################
tp6()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrf"
	user1pw1="redhat0000" # pw 
	user1pw2="123456789" 
	user1pw3="12345767890" 
	user1pw4="12345678" #
	user1pw5="1"

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 0"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlength 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlength 9"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

#    1.   user can change its password to "123456789"
	# Kinit as that user, ensure that it worked
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

#    2. user can change its password to "1234567890"

	# set that users password to a pw that should work
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

#    3. user can NOT change its password to "12345678"
	# set that users password to a password with 8 char, this should fail
	SetUserPassword M1 $user1 $user1pw4
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt are:"
		cat $TET_TMP_DIR/SetUserPassword-output.txt
		echo "contents of $TET_TMP_DIR/SetUserPassword-output.txt complete:"
		tet_result FAIL
	fi

#    4. user can NOT change its password to "1"
	# set that users password to a password with 1 char, this should fail
	SetUserPassword M1 $user1 $user1pw5
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'Password Fails to meet minimum' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -ne 0 ]; then
		echo "ERROR - set password either passed or failed incorrectly when trying to set a invalid password"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	tet_result PASS

	echo "END $tet_thistest"
}
######################################################################

######################################################################
# minlength
# From ../../../../ipa-tests/testplans/functional/passwordpolicy/IPA_Password_Policy_test_plan.html test # 25
#   1.   setup default environment
#   2. setup default password policy
#   3. change min. password lifetime to 0
#   4. change min. character class to 0
#   5. change min. password length to '1
#   6. create a user "usr", set its default password to "1"
#   7. verify user password is valid
#    1. user can change its password to "2"
#    2. user can change its password to "12" 
######################################################################
tp6a()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "START $tet_thistest"

	user1="testusrg"
	user1pw1="1" # pw 
	user1pw2="2" 
	user1pw3="12" 

	eval_vars M1
	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minclasses 0"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlength 20"
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlength 1"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

#    1. user can change its password to "2"

	# Kinit as that user, ensure that it worked
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Determine if that worked
	rm -f $TET_TMP_DIR/KinitAsFirst-out.txt
	scp root@$FULLHOSTNAME:/tmp/KinitAsFirst-out.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it kinited fine.
	grep 'error' $TET_TMP_DIR/KinitAsFirst-out.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - KinitAsFirst didn't seem to work."
		echo "Test - $tet_thistest"
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt are:"
		cat $TET_TMP_DIR/KinitAsFirst-out.txt
		echo "contents of $TET_TMP_DIR/KinitAsFirst-out.txt complete:"
		tet_result FAIL
	fi

#    2. user can change its password to "2"

	# set that users password to a pw that should work
	SetUserPassword M1 $user1 $user1pw3
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME";
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	# Ensure that works
	rm -f $TET_TMP_DIR/SetUserPassword-output.txt
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi
	# Now, parse the output of the last SetUserPassword to ensure that it failed properly.
	grep 'error' $TET_TMP_DIR/SetUserPassword-output.txt
	if [ $? -eq 0 ]; then
		echo "ERROR - set password $user1pw2 for user $user1 failed"
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
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
		echo "Test - $tet_thistest"
		tet_result FAIL
	fi

	SyncDate
	eval_vars M1

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
