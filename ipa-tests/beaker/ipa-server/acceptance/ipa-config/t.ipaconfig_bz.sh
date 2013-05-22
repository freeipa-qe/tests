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
   rlPhaseStartSetup "kinit as Admin"
	rlRun "kinitAs $ADMINID $ADMINPW"
   rlPhaseEnd
}

ipaconfig_bugzillas()
{
	# Testcase covering https://fedorahosted.org/freeipa/ticket/2159 - bugzilla 782974
	rlPhaseStartTest "ipa-config-bugzilla-001: bz782974 Trace back with empty groupsearch config-mod"
		ipa config-mod --groupsearch= > /tmp/bz782974.txt 2>&1
		cat /tmp/bz782974.txt | grep "ipa: ERROR: an internal error has occurred"
		if [ $? -eq 0 ] ; then
			rlFail "https://bugzilla.redhat.com/show_bug.cgi?id=782974"
		else
			rlPass "Internal Error and traceback bz782974 fixed."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-config-bugzilla-002: bz742601 ipa config-mod update description for --emaildomain"
		rlRun "ipa help config-mod > /tmp/bz742601.out 2>&1" 0
        	rlAssertGrep "\--emaildomain=STR     Default e-mail domain" "/tmp/bz742601.out"
		rlAssertNotGrep "\--emaildomain=STR     Default e-mail domain for new users" "/tmp/bz742601.out"
	rlPhaseEnd

	rlPhaseStartTest "ipa-config-bugzilla-003: bz744205 ipa config-mod user search field blank - an internal error has occurred"
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

	rlPhaseStartTest "ipa-config-bugzilla-004: bz803836 IPA needs to set the nsslapd-minssf-exclude-rootdse option by default"
		minssfcfg=`ldapsearch -x -D "cn=Directory Manager" -w $ADMINPW -b "cn=config" | grep minssf-exclude-rootdse | awk '{print $2}'`
		if [ "$minssfcfg" != "on" ] ; then
			rlFail "nsslapd-minssf-exclude-rootdse not as expected.  GOT: $minssfcfg EXPECTED: on"
		else
			rlPass "nsslapd-minssf-exclude-rootdse as expected '$minssfcfg'"
		fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-config-bugzilla-005: bz782921 Add central configuration for size and look through limits"
                rlRun "ldapsearch -x -D \"cn=Directory Manager\" -w $ADMINPW -b \"cn=anonymous-limits,cn=etc,$BASEDN\"" 0 "Check for centralized look through limits configuration"
		nslimits=`ldapsearch -x -D "cn=Directory Manager" -w $ADMINPW -b "cn=config,cn=ldbm database,cn=plugins,cn=config" | grep nsslapd-idlistscanlimit | awk '{print $2}'`
                if [ "$nslimits" -ne 100000 ] ; then
                        rlFail "nsslapd-idlistscanlimit not as expected.  GOT: $nslimits EXPECTED: 100000"
                else
                        rlPass "nsslapd-idlistscanlimit as expected '$nslimits'"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-config-bugzilla-006: bz797569 embedded carriage returns in a CSV not handled"
		tmpout=/tmp/errormsg.out
		cat > /tmp/ipa-config-mod-with-newlines.sh <<-EOF
		ipa config-mod --userobjectclasses="top, person, organizationalperson,
		inetorgperson, inetuser, posixaccount, krbprincipalaux, krbticketpolicyaux,
		ipaobject, ipasshuser, sambasamaccount"
		EOF

		rlLog "Running ipa config-mod with quoted multiline entry"
		rlLog "ipa config-mod --userobjectclasses=\"top, person, organizationalperson,"
		rlLog "inetorgperson, inetuser, posixaccount, krbprincipalaux, krbticketpolicyaux,"
		rlLog "ipaobject, ipasshuser, sambasamaccount\""
		rlRun "chmod 755 /tmp/ipa-config-mod-with-newlines.sh"
		rlRun "/tmp/ipa-config-mod-with-newlines.sh > $tmpout 2>&1" 0 "Running script with multiline command"
		if [ $(grep "ipa: ERROR: unhandled exception: Error: new-line character seen in unquoted field" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797569 found...embedded carriage returns in a CSV not handled"
			rlFail "ipa config-mod with multiple lines quoted and separated by newline failed"
		else
			rlRun "ipa config-show --all|grep \"top, person, organizationalperson, inetorgperson, inetuser, posixaccount, krbprincipalaux, krbticketpolicyaux, ipaobject, ipasshuser, sambasamaccount\""
			rlPass "BZ 797569 not found"
			rlPass "ipa config-mod with multiple lines quoted and separated by newline passed"
		fi
		if [ -f $tmpout ]; then 
			rm -f $tmpout
		fi
	rlPhaseEnd

}
