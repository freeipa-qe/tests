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
			rlPass "Internal Error and traceback bz782974 fixed."
		fi
	rlPhaseEnd

	rlPhaseStartTest "bz742601 ipa config-mod: update description for --emaildomain"
		rlRun "ipa help config-mod > /tmp/bz742601.out 2>&1" 0
        	rlAssertGrep "\--emaildomain=STR     Default e-mail domain" "/tmp/bz742601.out"
		rlAssertNotGrep "\--emaildomain=STR     Default e-mail domain for new users" "/tmp/bz742601.out"
	rlPhaseEnd

	rlPhaseStartTest "bz744205 ipa config-mod user search field blank - an internal error has occurred"
		ipa config-mod --usersearch= > /tmp/bz744205.out 2>&1
		cat /tmp/bz744205.txt | grep "ipa: ERROR: an internal error has occurred"
                if [ $? -eq 0 ] ; then
                        rlFail "https://bugzilla.redhat.com/show_bug.cgi?id=744205"
                else
                        rlPass "Internal Error and traceback bz744205 fixed."
		fi
        	command="ipa config-mod --usersearch="
        	expmsg="ipa: ERROR: 'usersearch' is required"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
 	rlPhaseEnd

	rlPhaseStartTest "bz803836 IPA needs to set the nsslapd-minssf-exclude-rootdse option by default"
		minssfcfg=`ldapsearch -x -D "cn=Directory Manager" -w Secret123 -b "cn=config" | grep minssf-exclude-rootdse | awk '{print $2}'`
		if [ "$minssfcfg" != "on" ] ; then
			rlFail "nsslapd-minssf-exclude-rootdse not as expected.  GOT: $minssfcfg EXPECTED: on"
		else
			rlPass "nsslapd-minssf-exclude-rootdse as expected '$minssfcfg'"
		fi
        rlPhaseEnd
}

