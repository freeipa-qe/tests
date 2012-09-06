######################
# test suite         #
######################
ipapassword2()
{
    ipapassword2_setup
    ipapassword2_negative
    ipapassword2_positive
    ipapassword2_cleanup
} 

#######################
#  SETUP	      #
#######################

ipapassword2_setup()
{
   rlPhaseStartTest "Setup - add users and groups"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
   	# add three users
  	rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user1"
	#rlRun "create_ipauser user2 user2 user2 Secret123" 0 "Creating a test user2"
	#rlRun "create_ipauser user1 user1 user1 Secret123" 0 "Creating a test user3"
        # kinit as admin
        #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	# add two groups
 	#rlRun "ipa group-add --desc=blah group1" 0 "Creating a test group1"
	#rlRun "ipa group-add --desc=blahblah group2" 0 "Creating a test group2"
   	# put a user in each one of the groups
	#rlRun "ipa group-member-add --users=user1 group1" 0 "Put user1 in group1"
	#rlRun "ipa group-member-add --users=user2 group2" 0 "Put user2 in group2"
}

#######################
# test sets           #
#######################
ipapassword2_negative()
{
  ipapassword2_maxfail_negative
  ipapassword2_failinterval_negative
  ipapassword2_lockouttime_negative
}

ipapassword2_positive()
{
  ipapassword2_maxfail_positive
}

###########################
# MAX FAIL NEGATIVE TESTS #
###########################
ipapassword2_maxfail_negative()
{
    attr="krbpwdmaxfailure"
    flag="maxfail"
    tmpfile=/tmp/errout_$flag

    rlPhaseStartTest "Max Failures Negative Test - Negative Numbers"
        Local_KinitAsAdmin
	expmsg="ipa: ERROR: invalid '$flag': must be at least 0"        

        for value in -2 -1 -100000000
        do
	    command="ipa pwpolicy-mod --$flag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $flag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Invalid Characters"
	# https://bugzilla.redhat.com/show_bug.cgi?id=718015
	expmsg="ipa: ERROR: invalid '$flag': must be an integer"       
        for value in jwy t _
        do
            command="ipa pwpolicy-mod --$flag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $flag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - setattr - Negative Numbers"
        expmsg="ipa: ERROR: invalid '$flag': must be at least 0"
        for value in -3 -25 -93796296
        do
            command="ipa pwpolicy-mod --setattr=$attr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $attr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - setattr - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$attr': must be an integer"       
        for value in kihhw y +
        do
            command="ipa pwpolicy-mod --setattr=$attr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $attr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - addattr - Only One Value Allowed"
        expmsg="ipa: ERROR: $attr: Only one value allowed."
        command="ipa pwpolicy-mod --addattr=$attr=1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add additional $attr attribute"
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Integer to large"
	expmsg="ipa: ERROR: invalid '$flag': can be at most 2147483647"
	command="ipa pwpolicy-mod --$flag=2147483648"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add $attr attribute with integer too large"
    rlPhaseEnd

}

################################
# FAIL INTERVAL NEGATIVE TESTS #
################################
ipapassword2_failinterval_negative()
{
    attr="krbpwdfailurecountinterval"
    flag="failinterval"
    tmpfile=/tmp/errout_$flag

    rlPhaseStartTest "Failure Interval Negative Test - Negative Numbers"
        Local_KinitAsAdmin
        expmsg="ipa: ERROR: invalid '$flag': must be at least 0"

        for value in -19 -8 -9075020
        do
            command="ipa pwpolicy-mod --$flag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $flag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - Invalid Characters"
	# https://bugzilla.redhat.com/show_bug.cgi?id=718015
        expmsg="ipa: ERROR: invalid '$flag': must be an integer"
        for value in 1avc jsdljo97 B
        do
            command="ipa pwpolicy-mod --$flag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $flag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - setattr - Negative Numbers"
        expmsg="ipa: ERROR: invalid '$flag': must be at least 0"
        for value in -333 -6 -937962967347
        do
            command="ipa pwpolicy-mod --setattr=$attr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $attr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - setattr - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$attr': must be an integer"
        for value in joeioi Q -
        do
            command="ipa pwpolicy-mod --setattr=$attr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $attr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Failure Interval Negative Test - addattr - Only One Value Allowed"
        expmsg="ipa: ERROR: $attr: Only one value allowed."
        command="ipa pwpolicy-mod --addattr=$attr=1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add additional $attr attribute"
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Integer to large"
        expmsg="ipa: ERROR: invalid '$flag': can be at most 2147483647"
        command="ipa pwpolicy-mod --$flag=992747483648"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add $attr attribute with integer too large"
    rlPhaseEnd
}

################################
# LOCK OUT TIME NEGATIVE TESTS #
################################
ipapassword2_lockouttime_negative()
{
    attr="krbpwdlockoutduration"
    flag="lockouttime"
    tmpfile=/tmp/errout_$flag

    rlPhaseStartTest "Lock Out Time Negative Test - Negative Numbers"
        Local_KinitAsAdmin
        expmsg="ipa: ERROR: invalid '$flag': must be at least 0"

        for value in -22 -4 -9861755555
        do
            command="ipa pwpolicy-mod --$flag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $flag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - Invalid Characters"
	# https://bugzilla.redhat.com/show_bug.cgi?id=718015
        expmsg="ipa: ERROR: invalid '$flag': must be an integer"
        for value in T pdsw oiwiouuiy9869
        do
            command="ipa pwpolicy-mod --$flag=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $flag set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - setattr - Negative Numbers"
        expmsg="ipa: ERROR: invalid '$flag': must be at least 0"
        for value in -33 -7 -379346296734
        do
            command="ipa pwpolicy-mod --setattr=$attr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $attr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - setattr - Invalid Characters"
        expmsg="ipa: ERROR: invalid '$attr': must be an integer"
        for value in Y kdihe :
        do
            command="ipa pwpolicy-mod --setattr=$attr=$value"
            rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure with $attr set to [$value]"
        done
    rlPhaseEnd

    rlPhaseStartTest "Lock Out Time Negative Test - addattr - Only One Value Allowed"
        expmsg="ipa: ERROR: $attr: Only one value allowed."
        command="ipa pwpolicy-mod --addattr=$attr=1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add additional $attr attribute"
    rlPhaseEnd

    rlPhaseStartTest "Max Failures Negative Test - Integer to large"
        expmsg="ipa: ERROR: invalid '$flag': can be at most 2147483647"
        command="ipa pwpolicy-mod --$flag=2147483648342"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Expect failure trying to add $attr attribute with integer too large"
    rlPhaseEnd
}

###########################
# MAX FAIL POSITIVE TESTS #
###########################
ipapassword2_maxfail_positive()
{

   rlPhaseStartTest "Verify Valid Max Failures Values"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	flag=maxfail
	label="Max failures"
        for value in 3 7 15 33 100 500 6
        do
            rlRun "ipa pwpolicy-mod --$flag=$value" 0 "Setting $flag to value of [$value]"
	    actual=`ipa pwpolicy-show | grep "$label" | cut -d ':' -f 2`
	    actual=`echo $actual`
	    if [ $actual -eq $value ] ; then
		rlPass "Max failures correct [$actual]"
	    else
		rlFail "FAIL - Max failures not as expected.  Got: [$actual] Expected: [$value]"
	    fi
        done
   rlPhaseEnd

   rlPhaseStartTest "Verify Failure Counter Iteration"
	for value in 1 2 3 4 5  
	do
 		rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
  		count=`ipa user-show --all user1 | grep krbloginfailedcount: | cut -d ':' -f 2` 
  		count=`echo $count`
		if [ $count -eq $value ] ; then
			rlPass "User's failed counter is as expected: [$count]"
		else
			rlFail "FAIL - User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
		fi
	done

   rlPhaseEnd

   rlPhaseStartTest "Verify Failure Counter Reset with Correct Password"    
	rlRun "kinitAs user1 Secret123" 0 "Kinit as user with valid password"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
        count=`ipa user-show --all user1 | grep krbloginfailedcount: | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq 0 ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
        else
        	rlFail "FAIL - User's failed counter is NOT as expected.  Got: [$count] Expected: [$value]"
        fi
   rlPhaseEnd

   rlPhaseStartTest "Verify Failure Counter Reset with Password Reset"
	rlRun "kinitAs user1 BADPWD" 1 "Kinit as user with invalid password"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
        count=`ipa user-show --all user1 | grep krbloginfailedcount: | cut -d ':' -f 2`
        count=`echo $count`
        if [ $count -eq 1 ] ; then
        	rlPass "User's failed counter is as expected: [$count]"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
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
		count=`ipa user-show --all user1 | grep krbloginfailedcount: | cut -d ':' -f 2`
		count=`echo $count`
		if [ $count -eq 0 ] ; then
			rlPass "User's failed counter is as expected: [$count]"
		else
			rlFail "FAIL - User's failed counter is NOT as expected.  Got: [$count] Expected: [0]"	
		fi
        else
        	rlFail "FAIL - User's failed counter is NOT as expected.  Got: [$count] Expected: [1]"
		rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=718062"
        fi
   rlPhaseEnd

   #rlPhaseStartTest "Verify Failure Counter Doesn't Iterate with Max Failures Value of 0 "
   #     rlPass "TO DO"
   #rlPhaseEnd
}

################################
# FAIL INTERVAL POSITIVE TESTS #
################################
#ipapassword2_failinterval_positive()
#{
#  rlLog "TODO"
#}

################################
# LOCK OUT TIME POSITIVE TESTS #
################################
#ipapassword2_failinterval_positive()
#{
#  rlLog "TODO"
#}

#########################
#  CLEANUP              #
#########################

ipapassword2_cleanup()
{
   rlPhaseStartTest "Delete Users and Groups added"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
        rlRun "ipa user-del user1" 0 "Deleting test user1"
	#rlRun "ipa user-del user2" 0 "Deleting test user2"
	#rlRun "ipa user-del user3" 0 "Deleting test user3"
	#rlRun "ipa group-del group1" 0 "Deleting test group1"
	#rlRun "ipa group-del group2" 0 "Deleting test group2"
}

