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
		ipa config-mod --groupsearch= > /tmp/bz782974.txt 2>&1
		cat /tmp/bz782974.txt | grep "ipa: ERROR: an internal error has occurred"
		if [ $? -eq 0 ] ; then
			rlFail "https://bugzilla.redhat.com/show_bug.cgi?id=782974"
		else
			rlPass "Internal Error and tracebact bz782974 fixed."
		fi
	rlPhaseEnd

	rlPhaseStartTest "bz742601 ipa config-mod: update description for --emaildomain"
		rlRun "ipa help config-mod > /tmp/bz742601.out 2>&1" 0
        	rlAssertGrep "\--emaildomain=STR     Default e-mail domain" "/tmp/bz742601.out"
		rlAssertNotGrep "\--emaildomain=STR     Default e-mail domain for new users" "/tmp/bz742601.out"
	rlPhaseEnd

	rlPhaseStartTest "bz744205 ipa config-mod user search field blank - an internal error has occurred"
		rlRun "ipa config-mod --usersearch= > /tmp/bz744205.out 2>&1" 0
		rlAssertNotGroup "ipa: ERROR: an internal error has occurred" "/tmp/bz744205.out"
 	rlPhaseEnd
}

