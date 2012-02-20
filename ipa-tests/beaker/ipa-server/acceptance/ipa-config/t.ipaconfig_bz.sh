######################
ipaconfig_bz()
{
   setup
   bugzillas
} 

######################
# test set           #
######################

bugzillas()
{
   ipaconfig_bugzillas
}

######################
# test cases         #
######################

setup()
{
   rlPhaseStartTest "kinit as Admin"
	rlRun "kinitAs $ADMINID $ADMINPW"
   rlPhaseEnd
}

ipaconfig_bugzillas()
{
	# Testcase covering https://fedorahosted.org/freeipa/ticket/2159 - bugzilla 782974
	rlPhaseStartTest "bz782974 Trace back with empty groupsearch config-mod"
		ipa config-mod --groupsearch= &> /dev/shm/2159out.txt
		rlRun "grep Traceback  /dev/shm/2159out.txt" 1 "Making sure that running a empty groupsearch did not return a exception"
	rlPhaseEnd

	rlPhaseStartTest "bz742601 ipa config-mod: update description for --emaildomain"
		rlRun "ipa help config-mod > /tmp/bz742601.out 2>&1"
        	rlAssertGrep "\--emaildomain=STR     Default e-mail domain" "/tmp/bz742601.out"
		rlAssertNotGrep "\--emaildomain=STR     Default e-mail domain for new users" "/tmp/bz742601.out"
	rlPhaseEnd

	rlPhaseStartTest "bz744205 ipa config-mod user search field blank - an internal error has occurred"
		rlRun "ipa config-mod --usersearc= > /tmp/bz744205.out > 2>&1"
		rlAssertNotGroup "ipa: ERROR: an internal error has occurred" "/tmp/bz744205.out"
 	rlPhaseEnd
}

