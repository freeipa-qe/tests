######################
#  variables  	     #
######################
revokedmsg="Clients credentials have been revoked while getting initial credentials"
maxattr="krbpwdmaxfailure"
maxflag="maxfail"
maxlabel="Max failures"
intervalattr="krbpwdfailurecountinterval"
intervalflag="failinterval"
intervallabel="Failure reset interval"
locktimeattr="krbpwdlockoutduration"
locktimeflag="lockouttime"
locktimelabel="Lockout duration"
usercountattr="krbloginfailedcount"
######################
# test suite         #
######################
ipakrblockout()
{
    ipakrblockout_setup
    ipakrblockout_negative
    ipakrblockout_positive
    bz822429
    bz759501
    ipakrblockout_cleanup
} 

#######################
#  SETUP	      #
#######################

ipakrblockout_setup()
{
   rlPhaseStartTest "Setup - add users and groups"
	rlRun "kinitAs $ADMINID $ADMINPW"
  	rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"
	rlRun "create_ipauser grpuser grpuser grpuser Secret123" 0 "Creating a test user2"
        rlRun "kinitAs $ADMINID $ADMINPW"
	# add a group
 	rlRun "ipa group-add --desc=blah mygroup" 0 "Creating a test group mygroup"
   	# put  grpuser in the group
	rlRun "ipa group-add-member --users=grpuser mygroup" 0 "Put grpuser in group mygroup"
   rlPhaseEnd
}

#######################
# test sets           #
#######################
ipakrblockout_negative()
{
  ipakrblockout_maxfail_negative
  ipakrblockout_failinterval_negative
  ipakrblockout_lockouttime_negative
}

ipakrblockout_positive()
{
  ipakrblockout_maxfail_positive
  ipakrblockout_failinterval_positive
  ipakrblockout_lockoutduration_positive
  ipakrblockout_grouppolicy
}

###########################
# MAX FAIL NEGATIVE TESTS #
###########################
ipakrblockout_maxfail_negative()
{
    rlPhaseStartTest "Max Failures Negative Test - Negative Numbers"
        rlRun "kinitAs $ADMINID $ADMINPW"
	expmsg="ipa: ERROR: invalid '$maxflag': must be at least 0"        

        for value in -2 -1 -100000000
        do
	    command="ipa pwpolicy-mod --$maxflag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $maxflag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Invalid Characters"
	expmsg="ipa: ERROR: invalid '$maxflag': must be an integer"       
        for value in jwy t _
        do
            command="ipa pwpolicy-mod --$maxflag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $maxflag set to [$value]"
	    rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=718015"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - setattr - Negative Numbers"
        expmsg="ipa: ERROR: invalid '$maxattr': must be at least 0"
        for value in -3 -25 -93796296
        do
            command="ipa pwpolicy-mod --setattr=$maxattr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $maxattr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - setattr - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$maxattr': must be an integer"       
        for value in kihhw y +
        do
            command="ipa pwpolicy-mod --setattr=$maxattr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $maxattr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - addattr - Only One Value Allowed"
        expmsg="ipa: ERROR: $maxattr: Only one value allowed."
        command="ipa pwpolicy-mod --addattr=$maxattr=1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add additional $maxattr attribute"
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Integer to large"
	expmsg="ipa: ERROR: invalid '$maxflag': can be at most 2147483647"
	command="ipa pwpolicy-mod --$maxflag=2147483648"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to set Max Failures to integer too large"
    rlPhaseEnd

}

################################
# FAIL INTERVAL NEGATIVE TESTS #
################################
ipakrblockout_failinterval_negative()
{
    rlPhaseStartTest "Failure Interval Negative Test - Negative Numbers"
        Local_KinitAsAdmin
        expmsg="ipa: ERROR: invalid '$intervalflag': must be at least 0"

        for value in -19 -8 -9075020
        do
            command="ipa pwpolicy-mod --$intervalflag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $intervalflag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$intervalflag': must be an integer"
        for value in 1avc jsdljo97 B
        do
            command="ipa pwpolicy-mod --$intervalflag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $intervalflag set to [$value]"
	    rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=718015"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - setattr - Negative Numbers"
        expmsg="ipa: ERROR: invalid '$intervalattr': must be at least 0"
        for value in -333 -6 -937962967347
        do
            command="ipa pwpolicy-mod --setattr=$intervalattr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $ntervalattr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - setattr - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$intervalattr': must be an integer"
        for value in joeioi Q -
        do
            command="ipa pwpolicy-mod --setattr=$intervalattr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $intervalattr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - addattr - Only One Value Allowed"
        expmsg="ipa: ERROR: $intervalattr: Only one value allowed."
        command="ipa pwpolicy-mod --addattr=$intervalattr=1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add additional $attr attribute"
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - Integer to large"
        expmsg="ipa: ERROR: invalid '$intervalflag': can be at most 2147483647"
        command="ipa pwpolicy-mod --$intervalflag=992747483648"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to set Failure Interval to integer too large"
    rlPhaseEnd
}

################################
# LOCK OUT TIME NEGATIVE TESTS #
################################
ipakrblockout_lockouttime_negative()
{
    rlPhaseStartTest "Lock Out Time Negative Test - Negative Numbers"
        Local_KinitAsAdmin
        expmsg="ipa: ERROR: invalid '$locktimeflag': must be at least 0"

        for value in -22 -4 -9861755555
        do
            command="ipa pwpolicy-mod --$locktimeflag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $locktimeflag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$locktimeflag': must be an integer"
        for value in T pdsw oiwiouuiy9869
        do
            command="ipa pwpolicy-mod --$locktimeflag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $locktimeflag set to [$value]"
	    rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=718015"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - setattr - Negative Numbers"
        expmsg="ipa: ERROR: invalid '$locktimeattr': must be at least 0"
        for value in -33 -7 -379346296734
        do
            command="ipa pwpolicy-mod --setattr=$locktimeattr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $locktimeattr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - setattr - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$locktimeattr': must be an integer"
        for value in Y kdihe :
        do
            command="ipa pwpolicy-mod --setattr=$locktimeattr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $locktimeattr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - addattr - Only One Value Allowed"
        expmsg="ipa: ERROR: $locktimeattr: Only one value allowed."
        command="ipa pwpolicy-mod --addattr=$locktimeattr=1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add additional $locktimeattr attribute"
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Integer to large"
        expmsg="ipa: ERROR: invalid '$locktimeflag': can be at most 2147483647"
        command="ipa pwpolicy-mod --$locktimeflag=2147483648342"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add $locktimeattr attribute with integer too large"
    rlPhaseEnd
}

###########################
# MAX FAIL POSITIVE TESTS #
###########################
ipakrblockout_maxfail_positive()
{

   rlPhaseStartTest "Verify Valid Max Failures Values"
        rlRun "kinitAs $ADMINID $ADMINPW"
        for value in 3 7 15 33 100 500 6
        do
            rlRun "ipa pwpolicy-mod --$maxflag=$value" 0 "Setting $maxflag to value of [$value]"
	    actual=`ipa pwpolicy-show | grep "$maxlabel" | cut -d ':' -f 2`
	    actual=`echo $actual`
	    if [ $actual -eq $value ] ; then
		rlPass "Max failures correct [$actual]"
	    else
		rlFail "Max failures not as expected.  Got: [$actual] Expected: [$value]"
	    fi
        done
   rlPhaseEnd

   rlPhaseStartTest "Verify Failure Counter Iteration"
	for value in 1 2 3 4 5  
	do
 		rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password"
		rlRun "kinitAs $ADMINID $ADMINPW"
  		count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2` 
  		count=`echo $count`
		if [ $count -eq $value ] ; then
			rlPass "User's failed counter is as expected: [$count]"
		else
			rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
		fi
	done

   rlPhaseEnd

   rlPhaseStartTest "Verify Failure Counter Reset with Correct Password"    
	rlRun "kinitAs user1 Secret123" 0 "Kinit as user with valid password"
        rlRun "kinitAs $ADMINID $ADMINPW"
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq 0 ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
        else
        	rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
        fi
   rlPhaseEnd

   rlPhaseStartTest "Verify Failure Counter Reset with Admin Password Reset"
	rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password"
	rlRun "kinitAs $ADMINID $ADMINPW"
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq 1 ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
		rlRun "kinitAs $ADMINID $ADMINPW"
		# change the user's password
		exp=/tmp/changepwd.exp
		out=/tmp/changepwd.out
    		echo "set timeout 5" > $exp
    		echo "set force_conservative 0" >> $exp
    		echo "set send_slow {1 .1}" >> $exp
    		echo "spawn ipa passwd user1" >> $exp
    		echo 'match_max 100000' >> $exp
    		echo 'expect "*: "' >> $exp
    		echo "send -s -- \"ChangeMe2\"" >> $exp
    		echo 'send -s -- "\r"' >> $exp
    		echo 'expect "*: "' >> $exp
    		echo "send -s -- \"ChangeMe2\"" >> $exp
    		echo 'send -s -- "\r"' >> $exp
    		echo 'expect eof ' >> $exp
    		/usr/bin/expect $exp  > $out

		rlRun "cat $out | grep \"Changed password\"" 0 "Verify Password Change was successful."
		count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
		count=`echo $count`
		if [ $count -eq 0 ] ; then
			rlPass "User's failed counter is as expected: [$count]"
		else
			rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [0]"	
			rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=718062"
		fi
        else
        	rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [1]"
        fi
   rlPhaseEnd

   rlPhaseStartTest "Max Failures 0 - ten bad attempts followed by success"
	rlRun "kinitAs $ADMINID $ADMINPW"
	rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"
        # set Max Failures to 0
	rlRun "kinitAs $ADMINID $ADMINPW"
        value=0
        rlRun "ipa pwpolicy-mod --$maxflag=$value" 0 "Setting $maxflag to value of [$value]"
        actual=`ipa pwpolicy-show | grep "$maxlabel" | cut -d ':' -f 2`
        actual=`echo $actual`
        if [ $actual -eq $value ] ; then
        	rlPass "Max failures correct [$actual]"
        else
        	rlFail "Max failures not as expected.  Got: [$actual] Expected: [$value]"
        fi

	# increasing reset interval in case attempts take longer than 60 secs
	rlRun "ipa pwpolicy-mod --$intervalflag=120" 0 "Setting $intervalflag to value of [120]"

	# verify counter iteration
        for value in 1 2 3 4 5 6 7 8 9 10
        do
                rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password.  Attempt [$value]"
                rlRun "kinitAs $ADMINID $ADMINPW"
                count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
                count=`echo $count`
                if [ $count -eq $value ] ; then
                        rlPass "User's failed counter is as expected: [$count]"
                else
                        rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
                fi
        done

	# verify counter reset
	rlRun "kinitAs user1 Secret123" 0 "Kinit as user with valid password"
        rlRun "kinitAs $ADMINID $ADMINPW"
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq 0 ] ; then
		rlPass "User's failed counter is as expected: [$count]"
        else
                rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [0]"
        fi

	# set reset value back to default
	rlRun "ipa pwpolicy-mod --$intervalflag=60" 0 "Setting $intervalflag to value of [60"
   rlPhaseEnd

   rlPhaseStartTest "Max Failures reached and users credentials revoked"
	rlRun "kinitAs $ADMINID $ADMINPW"
        mvalue=3
        rlRun "ipa pwpolicy-mod --$maxflag=$mvalue" 0 "Setting $maxflag to value of [$mvalue]"
	ivalue=120
	rlRun "ipa pwpolicy-mod --$intervalflag=$ivalue" 0 "Setting $intervalflag to value of [$ivalue]"
        actual=`ipa pwpolicy-show | grep "$maxlabel" | cut -d ':' -f 2`
        actual=`echo $actual`
        if [ $actual -eq $mvalue ] ; then
                rlPass "Max failures correct [$actual]"
        else
                rlFail "Max failures not as expected.  Got: [$actual] Expected: [$mvalue]"
        fi

	for value in 1 2 3
        do
                rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password.  Attempt [$value]"
        done
	rlRun "kinitAs $ADMINID $ADMINPW"
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq $value ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
        else
        	rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
        fi

	# attempt log in with correct password
	rlRun "kinitAs user1 Secret123 > /tmp/kinitrevoked.txt 2>&1" 1 "Kinit as user with valid password. Max failures reached"
	rlAssertGrep "$revokedmsg" "/tmp/kinitrevoked.txt"
   rlPhaseEnd
}

################################
# FAIL INTERVAL POSITIVE TESTS #
################################
ipakrblockout_failinterval_positive()
{
    rlPhaseStartTest "Verify Valid Failure Interval Values"
	rlRun "kinitAs $ADMINID $ADMINPW"
	for value in 99 2 800 2000 360 30
        do
            rlRun "ipa pwpolicy-mod --$intervalflag=$value" 0 "Setting $intervalflag to value of [$value]"
            actual=`ipa pwpolicy-show | grep "$intervallabel" | cut -d ':' -f 2`
            actual=`echo $actual`
            if [ $actual -eq $value ] ; then
                rlPass "Interval value correct [$actual]"
            else
                rlFail "Interval value NOT as expected.  Got: [$actual] Expected: [$value]"
            fi
        done
    rlPhaseEnd

    rlPhaseStartTest "Failue Interval - before and after interval expiration - 10 second interval - 1 bad attempt"
	rlRun "kinitAs $ADMINID $ADMINPW"
        rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"
	# set interval to 10
	value=10
	rlRun "kinitAs $ADMINID $ADMINPW"
        rlRun "ipa pwpolicy-mod --$intervalflag=$value" 0 "Setting $intervalflag to value of [$value]"
        actual=`ipa pwpolicy-show | grep "$intervallabel" | cut -d ':' -f 2`
        actual=`echo $actual`
        if [ $actual -eq $value ] ; then
                rlPass "Interval value correct [$actual]"
        else
                rlFail "Interval value NOT as expected.  Got: [$actual] Expected: [$value]"
        fi

	# attempt log in with correct password before interval expiration
        rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with valid password. Max failures reached - interval not expired"

        # now expect failure counter to be 1 since interval expired
        rlRun "kinitAs $ADMINID $ADMINPW"
        value=1
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq $value ] ; then
                rlPass "User's failed counter is as expected: [$count]"
        else
                rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
        fi

	# wait for interval expiration
	rlLog "Sleeping for 10 seconds"
	sleep 10

	# attempt log in with correct password after interval expiration - duration not met for lockout
        rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with valid password. Max failures reached - interval expired"

	# now expect failure counter to be 1 since interval expired
	rlRun "kinitAs $ADMINID $ADMINPW"
	value=1
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq $value ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
        else
        	rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
		rlLog "May be regression bug :: https://bugzilla.redhat.com/show_bug.cgi?id=804096"
        fi

    rlPhaseEnd

    rlPhaseStartTest "Failure Interval - before and after interval expiration - 30 second interval - 2 bad attempts"
	# make sure user's counter is 0 to start
	rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"
        rlRun "kinitAs $ADMINID $ADMINPW"
        # set interval to 30
        value=30
        rlRun "ipa pwpolicy-mod --$intervalflag=$value" 0 "Setting $intervalflag to value of [$value]"
        actual=`ipa pwpolicy-show | grep "$intervallabel" | cut -d ':' -f 2`
        actual=`echo $actual`
        if [ $actual -eq $value ] ; then
                rlPass "Interval value correct [$actual]"
        else
                rlFail "Interval value NOT as expected.  Got: [$actual] Expected: [$value]"
        fi

	for value in 1 2
	do
		# attempt log in with correct password before interval expiration
        	rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with valid password. Max failures reached - lockout duration not expired. Attempt [$value]"

        	# now expect failure counter to be 1 since interval expired
        	rlRun "kinitAs $ADMINID $ADMINPW" 0
        	count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        	count=`echo $count`
        	if [ $count -eq $value ] ; then
                	rlPass "User's failed counter is as expected: [$count]"
        	else
                	rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
        	fi
	done

	rlLog "Sleeping for 45 seconds"
	sleep 45

        # attempt log in with correct password after interval expiration - duration not met for lockout
        rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with valid password. Max failures reached - lockout duration met"

        # now expect failure counter to be 1 since interval expired
        rlRun "kinitAs $ADMINID $ADMINPW"
        value=1
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq $value ] ; then
                rlPass "User's failed counter is as expected: [$count]"
        else
                rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
		rlLog "May be regression bug :: https://bugzilla.redhat.com/show_bug.cgi?id=804096"
        fi

    rlPhaseEnd
}

################################
# LOCK OUT TIME POSITIVE TESTS #
################################
ipakrblockout_lockoutduration_positive()
{
    rlPhaseStartTest "Verify Valid Lockout Duration Values"
        rlRun "kinitAs $ADMINID $ADMINPW"
        for value in 4899236 8 360 45 99999 30
        do
            rlRun "ipa pwpolicy-mod --$locktimeflag=$value" 0 "Setting $locktimeflag to value of [$value]"
            actual=`ipa pwpolicy-show | grep "$locktimelabel" | cut -d ':' -f 2`
            actual=`echo $actual`
            if [ $actual -eq $value ] ; then
                rlPass "Lock Out Duration value correct [$actual]"
            else
                rlFail "Lock Out Duration NOT as expected.  Got: [$actual] Expected: [$value]"
            fi
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Duration - 10 second interval - max failures 3"
        rlRun "kinitAs $ADMINID $ADMINPW"
        rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"
        # set interval to 10
        value=10
        rlRun "kinitAs $ADMINID $ADMINPW"
        rlRun "ipa pwpolicy-mod --$locktimeflag=$value" 0 "Setting $locktimeflag to value of [$value]"
        actual=`ipa pwpolicy-show | grep "$locktimelabel" | cut -d ':' -f 2`
        actual=`echo $actual`
        if [ $actual -eq $value ] ; then
                rlPass "Lock Out Duration value correct [$actual]"
        else
                rlFail "Lock Out Dureation value NOT as expected.  Got: [$actual] Expected: [$value]"
        fi

        for value in 1 2 3
        do
                rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password.  Attempt [$value]"
                rlRun "kinitAs $ADMINID $ADMINPW"
                count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
                count=`echo $count`
                if [ $count -eq $value ] ; then
                        rlPass "User's failed counter is as expected: [$count]"
                else
                        rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
                fi
        done

	# attempt log in with correct password - account should be locked
        rlRun "kinitAs user1 Secret123 > /tmp/kinitrevoked.txt 2>&1" 1 "Kinit as user with valid password. Max failures reached"
        rlAssertGrep "$revokedmsg" "/tmp/kinitrevoked.txt"

	rlLog "Sleeping lock out duration time of 10 seconds."
	sleep 10

	# attempt to log in with correct password - lock out duration expired
	rlRun "kinitAs user1 Secret123" 0 "Lock out duration expired - kinit should be successful"

	# now expect failure counter to be 0 again
        rlRun "kinitAs $ADMINID $ADMINPW"
        value=0
        count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq $value ] ; then
                rlPass "User's failed counter is as expected: [$count]"
        else
                rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
        fi
    rlPhaseEnd
}

################################
# LOCK OUT TIME POSITIVE TESTS #
################################
ipakrblockout_grouppolicy()
{
    rlPhaseStartTest "Set up Group policy and verify member's effective policy"
	rlRun "kinitAs $ADMINID $ADMINPW"
	# reset global policy
	ipa pwpolicy-mod --$maxflag=6 --$locktimeflag=600  --$intervalflag=60
	# add group policy
	rlRun "ipa pwpolicy-add --$maxflag=3 --$locktimeflag=120 --$intervalflag=30 --priority=1 mygroup" 0 "Adding group policy"
	# verify member users effective policy
	ipa pwpolicy-show --user=grpuser  > /tmp/effectivegrppolicy.txt 2>&1
	rlAssertGrep "$maxlabel: 3" "/tmp/effectivegrppolicy.txt"
	rlAssertGrep "$locktimelabel: 120" "/tmp/effectivegrppolicy.txt"
	rlAssertGrep "$intervallabel: 30" "/tmp/effectivegrppolicy.txt"
	# verify the user not in a group's effective policy
	ipa pwpolicy-show --user=user1  > /tmp/effectivegblpolicy.txt 2>&1
        rlAssertGrep "$maxlabel: 6" "/tmp/effectivegblpolicy.txt"
        rlAssertGrep "$locktimelabel: 600" "/tmp/effectivegblpolicy.txt"
        rlAssertGrep "$intervallabel: 60" "/tmp/effectivegblpolicy.txt"
    rlPhaseEnd

    rlPhaseStartTest "Group Failures Policy Enforcement - Lock Out"
        for value in 1 2 3 
        do
                rlRun "kinitAs grpuser BADPWD" 1 "Kinit as group policy user with invalid password"
                rlRun "kinitAs $ADMINID $ADMINPW"
                count=`ipa user-show --all grpuser | grep $usercountattr | cut -d ':' -f 2` 
                count=`echo $count`
                if [ $count -eq $value ] ; then
                        rlPass "User's failed counter is as expected: [$count]"
                else
                        rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
                fi
        done

	# attempt log in with correct password - account should be locked
        rlRun "kinitAs grpuser Secret123 > /tmp/kinitrevoked.txt 2>&1" 1 "Kinit as user with valid password. Max failures reached"
        rlAssertGrep "$revokedmsg" "/tmp/kinitrevoked.txt"

	rlLog "Sleep for lock out duration"
	sleep 120

	# account should be successful
	rlRun "kinitAs grpuser Secret123" 0 "Lock out period over - kinit should be successful"
    rlPhaseEnd

    rlPhaseStartTest "Group Failures Policy Enforcement - Failure Interval"
        for value in 1 2
        do
                rlRun "kinitAs grpuser BADPWD" 1 "Kinit as group policy user with invalid password"
                rlRun "kinitAs $ADMINID $ADMINPW"
                count=`ipa user-show --all grpuser | grep $usercountattr | cut -d ':' -f 2`
                count=`echo $count`
                if [ $count -eq $value ] ; then
                        rlPass "User's failed counter is as expected: [$count]"
                else
                        rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
                fi
        done

        rlLog "Sleep for interval duration"
        sleep 30

	rlRun "kinitAs grpuser BADPWD" 1 "Kinit as group policy user with invalid password"

	rlRun "kinitAs $ADMINID $ADMINPW"
	value=1
	count=`ipa user-show --all grpuser | grep $usercountattr | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq $value ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
        else
        	rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
		rlLog "May be regression bug :: https://bugzilla.redhat.com/show_bug.cgi?id=804096"
        fi

    rlPhaseEnd
}

##################################################
#  BUGZILLAS
##################################################
bz822429()
{
    rlPhaseStartTest "bz822429 Failed login count is stuck at 1"
	# set policy to max failures of 3
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit As Admin"
	rlRun "ipa pwpolicy-mod --$maxflag=3" 0 "Set max failures to 3"

	# create test user and set password
	rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"

	for value in 1 2 3
           do
                rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password - attemp $value"
                rlRun "kinitAs $ADMINID $ADMINPW"
                count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
                count=`echo $count`
                if [ $count -eq $value ] ; then
                        rlPass "User's failed counter is as expected: [$count]"
                else
                        rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
                fi
           done

        # attempt log in with correct password - account should be locked
        rlRun "kinitAs user1 Secret123 > /tmp/kinitrevoked.txt 2>&1" 1 "Kinit as user with valid password. Max failures reached"
        rlAssertGrep "$revokedmsg" "/tmp/kinitrevoked.txt"

	# admin unlock user
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit As Admin"
	rlRun "ipa user-unlock user1" 0 "Unlock user"

	# try to lock user again
        for value in 1 2 3
           do
                rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password - attemp $value"
                rlRun "kinitAs $ADMINID $ADMINPW"
                count=`ipa user-show --all user1 | grep $usercountattr | cut -d ':' -f 2`
                count=`echo $count`
                if [ $count -eq $value ] ; then
                        rlPass "User's failed counter is as expected: [$count]"
                else
                        rlFail "User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
                fi
           done

        # attempt log in with correct password - account should be locked
        rlRun "kinitAs user1 Secret123 > /tmp/kinitrevoked.txt 2>&1" 1 "Kinit as user with valid password. Max failures reached"
        rlAssertGrep "$revokedmsg" "/tmp/kinitrevoked.txt"

        # set policy to max failures of 6 -default
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit As Admin"
        rlRun "ipa pwpolicy-mod --$maxflag=6" 0 "Set max failures back to default"
    rlPhaseEnd
}

bz759501()
{
    rlPhaseStartTest "Bug 759501 user interface does not reflect account inactivation properly."
	# Reguarding: http://bugzilla.redhat.com/show_bug.cgi?id=759501
	# Current test plan:
	# 1. create user1
	# 2. kinit several times as user1 with valid credentials.
	# 3. Kinit as admin
	# 4. ensure that ipa user-status shows no failed logins for user1
	# 5. kdestroy
	# 6. kinit as user1 with several bad passwords (max failed logins + 1)
	# 7. ensure that ipa user-status shows correct number of failed logins for user1.
	# 8. ensure that user-status shows user1 as disabled.
	# 9. attempt valid login as user1. It should fail.
	# 10. kinit as admin
	# 11. re-enable user1
	# 12. kdestroy
	# 13. kinit as user1 twice with bad passwords.
	# 14. Make sure that user1 can still kinit with good credentials.
	# 15. kinit as admin
	# 16. remove user1. 
	# Gather lockout duration for use at cleanup
	lockoutduration=$(ipa pwpolicy-show | grep Lockout\ duration | sed s/\ //g | cut -d: -f2)
	ipa pwpolicy-mod --lockouttime=60
	# 1. create user1
	kdestroy
	kinitAs $ADMINID $ADMINPW
	user="759501ur"
	firstpass="pass1"
	pass="5ts7x6#nsh"
        rlRun "ipa user-add --first=firstname --last=nlast $user"
	echo $firstpass | ipa passwd $user
	# 2. kinit several times as user1 with valid credentials.
	FirstKinitAs $user $firstpass $pass
	kdestroy
	kinitAs $ADMINID $ADMINPW
	kdestroy
	kinitAs $user $pass
	kdestroy
	kinitAs $ADMINID $ADMINPW
	kdestroy
	kinitAs $user $pass
	kdestroy
	# 3. Kinit as admin
	kinitAs $ADMINID $ADMINPW
	# 4. ensure that ipa user-status shows no failed logins for user1
	failed=$(ipa user-status $user | grep Failed\ logins: | cut -d\  -f5)
	if [ "$failed" != "0" ]; then
		rlFail "ERROR - ipa user status for user $user shows more than 0 failed logins, it shows $failed"
	else 
		rlPass "PASS - ipa user status for user $user shows 0 failed logins"
	fi
	# 5. kdestroy
	kdestroy
	# 6. kinit as user1 with several bad passwords (max failed logins + 1)
	kinitAs $ADMINID $ADMINPW
	AttemptsToMake=$(ipa pwpolicy-show | grep Max\ failures | cut -d\  -f5)
	let AttemptsToMake=$AttemptsToMake+2
	kdestroy
	doneAttempts=0
	badpass=bpass
	while [ $doneAttempts -lt $AttemptsToMake ]; do
		bpass="$doneAttempts$badpass"
		echo $bpass | kinit $user
		let doneAttempts=$doneAttempts+1
	done
	# 7. ensure that ipa user-status shows correct number of failed logins for user1.
	kinitAs $ADMINID $ADMINPW
	AttemptsToMake=$(ipa pwpolicy-show | grep Max\ failures | cut -d\  -f5)
	failed=$(ipa user-status $user | grep Failed\ logins: | cut -d\  -f5)
	if [ $failed -ne $AttemptsToMake ]; then
		rlFail "ERROR - ipa user status for user $user shows incorrect number of Failed logins. $failed shown. It should be $AttemptsToMake"
	else 
		rlPass "PASS - ipa user status for user $user shows $AttemptsToMake failed logins"
	fi
	# 8. ensure that user-status shows user1 as disabled.
	userattempts=$(ipa user-show $user --all | grep krbloginfailedcount | sed s/\ //g | cut -d: -f2)
	if [ $userattepts -ne $AttemptsToMake ]; then
		rlFail "ERROR - ipa user status for user $user shows incorrect number of Failed logins. $userattempts shown. It should be $AttemptsToMake"
	else 
		rlPass "PASS - ipa user status for user $user shows $AttemptsToMake failed logins"
	fi
	# 9. attempt valid login as user1. It should fail.
	kdestroy
	echo $pass | kinit $user &> /dev/null
	if [ $? -eq 0 ]; then
		rlFail "ERROR - login as $user1 failed. The user should be locked"
	else
		rlPass "PASS - Could not log in as locked user"
	fi
	# 10. kinit as admin
	kinitAs $ADMINID $ADMINPW
	# 11. re-enable user1
	ipa user-unlock ua1
	# 12. kdestroy
	kdestroy
	# 13. kinit as user1 twice with bad passwords.
	echo bpass1 | kinit $user
	echo 8t6778g6uyg | kinit $user
	# 14. Make sure that user1 can still kinit with good credentials.
	echo "Sleeping for 60 seconds to wait for user to unlock"
	sleep 60 # Sleep to wait for the acount to activate again
	echo $pass | kinit $user
	princ=$(klist | grep Default\ principal | sed s/\ //g | cut -d\  -f2)
	echo $princ | grep $user@$RELM 
	if [ $? -ne 0 ]; then
		rlFail "ERROR - $user@$RELM does not appear to exist in the klist output. The output appears to be $princ"
		klist
	else 
		rlPass "PASS - able to login as user after unlocking the user"
	fi
	# 15. kinit as admin
	kdestroy
	kinitAs $ADMINID $ADMINPW
	# 16. remove user1. 
	ipa user-del $user
	ipa pwpolicy-mod --lockouttime=$lockoutduration
	
    rlPhaseEnd

}

#########################
#  CLEANUP              #
#########################

ipakrblockout_cleanup()
{
   rlPhaseStartTest "Delete Users and Groups added"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
        rlRun "ipa user-del user1" 0 "Deleting test user1"
	rlRun "ipa user-del grpuser" 0 "Deleting test grpuser"
	rlRun "ipa group-del mygroup" 0 "Deleting test mygroup"
   rlPhaseEnd
}

