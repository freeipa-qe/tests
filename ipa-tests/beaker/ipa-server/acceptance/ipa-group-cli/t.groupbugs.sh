########################################################################
# Test Sections
########################################################################
groupbugs()
{
  grpbugsetup
  grpbugzillas
  grpbugcleanup
}

########################################################################
#  Tests
########################################################################

grpbugsetup()
{

    rlPhaseStartSetup
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd
}

grpbugzillas()
{
    rlPhaseStartTest "ipa-group-bugzillas-001: bz786240 gid number 0 and negative number accepted"
	command="ipa group-add --desc=jennygn jennygn --gid=0"
	expmsg="ipa: ERROR: invalid 'gid': must be at least 1"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlRun "ipa group-add --desc=j-test jennygn" 0 "Adding Test Group"
	for value in 0 -0 -100 ; do
        	command="ipa group-mod --gid=$value jennygn"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	done
	# just in case
	ipa group-del jennygn
    rlPhaseEnd 

    rlPhaseStartTest "ipa-group-bugzillas-002: bz773488 Make ipausers a non-posix group on new installs"
        rlRun "verifyGroupClasses ipausers ipa" 0 "Verify ipauser group objectclasses."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-bugzillas-003 bz860683 group-mod should not be allowed to rename or modify admins account"
        command="ipa group-mod --rename=Administrators admins"
        expmsg="ipa: ERROR: group admins cannot be deleted/modified: Cannot be renamed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd
}

grpbugcleanup()
{
    rlPhaseStartCleanup
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd
}
