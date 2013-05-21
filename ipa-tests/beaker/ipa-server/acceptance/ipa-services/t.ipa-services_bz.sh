######################
# test set           #
######################

service_bugs()
{
   srvsbugsetup
   bz800119
}

######################
# test cases         #
######################

srvsbugsetup()
{
   rlPhaseStartSetup "kinit as Admin"
	rlRun "kinitAs $ADMINID $ADMINPW"
   rlPhaseEnd
}

bz800119()
{
    rlPhaseStartTest "ipa-service-bugzilla-001: bz800119 Should not be allowed to run host-disable on an IPA Server or service-disable on an IPA Server service"
	expmsg="ipa: ERROR: invalid 'principal': This principal is required by the IPA master"
	for service in ldap dogtagldap HTTP DNS ; do
		thisservice="$service/$MASTER@$DOMAIN"
		rlRun "ipa service-disable $thisservice" 1 "Checking return code attempting to disable $thisservice"
		command="ipa service-disable $thisservice"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	done
    rlPhaseEnd
}

