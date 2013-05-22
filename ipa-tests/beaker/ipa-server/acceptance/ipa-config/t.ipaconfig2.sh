######################
# Expected defaults  #
######################
default_config_usernamelength="32"
default_config_homebase="/home"
default_config_shell="/bin/sh"
default_config_emaildomain="$DOMAIN"
default_config_usergroup="ipausers"
default_config_timelimit="2"
default_config_sizelimit="100"
default_config_usersearchfields="uid,givenname,sn,telephonenumber,ou,title"
default_config_groupsearchfields="cn,description"
default_config_migrationmode="FALSE"
default_config_ipaconfigstring="AllowNThash"
######################
# test suite         #
######################
ipaconfig2()
{
   setup
   ipaconfig_mod_addattr 
   ipaconfig_mod_delattr
   ipaconfig_setattr
   cleanup
} 

######################
# test set           #
######################
ipaconfig_mod_addattr()
{
    ipaconfig_addattr_positive
    ipaconfig_addattr_negative
} 

ipaconfig_mod_delattr()
{
    ipaconfig_delattr_positive
    ipaconfig_delattr_negative
} 

ipaconfig_setattr()
{
   ipaconfig_setattr_positive
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

ipaconfig_addattr_positive()
{
   # ipaconfigstring is the only attribute that can be multi-valued and is optional.  However the only allowed values are AllowNThash (default) and AllowLMHash
   # see ipa help config-mod

   rlPhaseStartTest "ipa-config-addattr-001: Add additional allowed config string for Password plugin feature"
	rlRun "ipa config-mod --addattr=ipaconfigstring=AllowLMhash" 0 "Add additional string allowed value"
	ipa config-show --all > /tmp/configshowadd.out
	cat /tmp/configshowadd.out | grep "Password plugin features: AllowNThash, AllowLMhash"
	if [ $? -eq 0 ] ; then
		rlPass "Additional config string successfully added."
	else
		rlFail "Password plugin features not as expected: GOT: $value"
	fi

        # set back to default
	rlRun "ipa config-mod --setattr=ipaconfigstring=AllowNThash" 0 "Setting back to default value"
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-addattr-002: Add additional allowed user object class"
        rlRun "ipa config-mod --addattr=ipauserobjectclasses=sambasamaccount" 0 "Add additional allowed objectclass"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Default user objectclasses: top, person, organizationalperson, inetorgperson, inetuser, posixaccount, krbprincipalaux, krbticketpolicyaux, ipaobject, ipasshuser, sambasamaccount"
        if [ $? -eq 0 ] ; then
                rlPass "Additional user objectclass successfully added."
        else
                rlFail "User object classes not as expected."
		rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817885"
        fi

 	# remove objectclass added
        rlRun "ipa config-mod --delattr=ipauserobjectclasses=sambasamaccount" 0
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-addattr-003: Add additional allowed group object class"
        rlRun "ipa config-mod --addattr=ipagroupobjectclasses=posixgroup" 0 "Add additional allowed objectclass"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Default group objectclasses: top, groupofnames, nestedgroup, ipausergroup, ipaobject, posixgroup"
        if [ $? -eq 0 ] ; then
                rlPass "Additional group objectclass successfully added."
        else
                rlFail "Group objectclasses not as expected."
		rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817885"
        fi

	# remove objectclass added
        rlRun "ipa config-mod --delattr=ipagroupobjectclasses=posixgroup" 0
   rlPhaseEnd 
}

ipaconfig_addattr_negative()
{
  rlPhaseStartTest "ipa-config-addattr-004: ipamaxusernamelength - only one allowed"
	command="ipa config-mod --addattr=ipamaxusernamelength=33"
	expmsg="ipa: ERROR: ipamaxusernamelength: Only one value allowed."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-005: ipahomesrootdir - only one allowed"
        command="ipa config-mod --addattr=ipahomesrootdir=/mnt/home"
        expmsg="ipa: ERROR: ipahomesrootdir: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-006: ipadefaultloginshell - only one allowed"
        command="ipa config-mod --addattr=ipadefaultloginshell=/bin/csh"
        expmsg="ipa: ERROR: ipadefaultloginshell: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-007: ipadefaultprimarygroup - only one allowed"
        command="ipa config-mod --addattr=ipadefaultprimarygroup=\"cn=mygroup,cn=groups,cn=accounts,$BASEDN\""
        expmsg="ipa: ERROR: ipadefaultprimarygroup: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-008: ipadefaultemaildomain - only one allowed"
        command="ipa config-mod --addattr=ipadefaultemaildomain=domain.com"
        expmsg="ipa: ERROR: ipadefaultemaildomain: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-009: ipasearchtimelimit - only one allowed"
        command="ipa config-mod --addattr=ipasearchtimelimit=20"
        expmsg="ipa: ERROR: ipasearchtimelimit: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-010: ipasearchrecordslimit - only one allowed"
        command="ipa config-mod --addattr=ipasearchrecordslimit=200"
        expmsg="ipa: ERROR: ipasearchrecordslimit: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-011: ipagroupsearchfields - only one allowed"
        command="ipa config-mod --addattr=ipagroupsearchfields=newattr"
        expmsg="ipa: ERROR: ipagroupsearchfields: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794746"
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-012: ipausersearchfields only one allowed"
        command="ipa config-mod --addattr=ipausersearchfields=newattr"
        expmsg="ipa: ERROR: ipausersearchfields: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794746"
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-013: ipacertificatesubjectbase only one allowed"
        command="ipa config-mod --addattr=ipacertificatesubjectbase=O=DOMAIN.COM"
        #expmsg="ipa: ERROR: ipacertificatesubjectbase: Only one value allowed."
        expmsg="ipa: ERROR: invalid 'ipacertificatesubjectbase': attribute is not configurable"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=807018"
  rlPhaseEnd

  rlPhaseStartTest "ipa-config-addattr-014: ipapwdexpadvnotify - only one allowed"
        command="ipa config-mod --addattr=ipapwdexpadvnotify=7"
        expmsg="ipa: ERROR: ipapwdexpadvnotify: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd
}

ipaconfig_delattr_positive()
{
   rlPhaseStartTest "ipa-config-delattr-001: ipaconfigstring"
        rlRun "ipa config-mod --delattr=ipaconfigstring=AllowNThash" 0 "delete ipa config string attribute"
        ipa config-show --all > /tmp/configshowdel.out
        cat /tmp/configshowdel.out | grep "Password plugin features:"
        if [ $? -ne 0 ] ; then
                rlPass "Config string successfully deleted."
        else
                rlFail "Password plugin features not as expected"
        fi

        # set back to default
        rlRun "ipa config-mod --setattr=ipaconfigstring=AllowNThash" 0 "Setting back to default value"
   rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-002: ipadefaultemaildomain"
        rlRun "ipa config-mod --delattr=ipadefaultemaildomain=$DOMAIN" 0 "Delete default email domain."
        ipa config-show --all > /tmp/configshowdel.out
        cat /tmp/configshowdel.out | grep " Default e-mail domain:"
        if [ $? -ne 0 ] ; then
                rlPass "Config string successfully deleted."
        else
                rlFail "Default Email Domain not as expected"
        fi
	
	sleep 2
	rlRun "ipa config-mod --emaildomain=$DOMAIN" 0 "Set email domain back to default."
    rlPhaseEnd

}

ipaconfig_delattr_negative()
{

    rlPhaseStartTest "ipa-config-delattr-003: invalid attribute negative test"
	command="ipa config-mod --delattr=ipaCustomFields=FALSE"
	#expmsg="ipa: ERROR: 'ipacustomfields' does not exist"
	expmsg="ipa: ERROR: invalid 'ipacustomfields': No such attribute on this entry"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817821"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-004: ipahomesrootdir negative test"
	command="ipa config-mod --delattr=ipahomesrootdir=/home/"
        #expmsg="ipa: ERROR: 'ipahomesrootdir' is required"
        expmsg="ipa: ERROR: ipahomesrootdir does not contain '/home/'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817821"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-005: ipamaxusernamelength negative test"
        command="ipa config-mod --delattr=ipamaxusernamelength=32"
        expmsg="ipa: ERROR: 'ipamaxusernamelength' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-006: ipadefaultloginshell negative test"
        command="ipa config-mod --delattr=ipadefaultloginshell=/bin/bash"
        expmsg="ipa: ERROR: ipadefaultloginshell does not contain '/bin/bash'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817821"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-007: ipadefaultprimarygroup negative test"
        command="ipa config-mod --delattr=ipadefaultprimarygroup=\"cn=ipausers,cn=accounts,cn=$BASEDN\""
        #expmsg="ipa: ERROR: 'ipadefaultprimarygroup' is required"
        expmsg="ipa: ERROR: ipadefaultprimarygroup does not contain 'cn=ipausers,cn=accounts,cn=dc=testrelm,dc=com'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817821"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-008: ipasearchtimelimit negative test"
        command="ipa config-mod --delattr=ipasearchtimelimit=2"
        expmsg="ipa: ERROR: 'ipasearchtimelimit' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-009: ipasearchrecordslimit negative test"
        command="ipa config-mod --delattr=ipasearchrecordslimit=100"
        expmsg="ipa: ERROR: 'ipasearchrecordslimit' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-010: ipagroupsearchfields negative test"
        ipa config-show --all | grep "Group search fields" > /tmp/groupsearch.out
        groupsearchfields=`cat /tmp/groupsearch.out | awk '{print $4}'`
        command="ipa config-mod --delattr=ipagroupsearchfields=\"$groupsearchfields\""
        expmsg="ipa: ERROR: 'ipagroupsearchfields' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817831"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-011: ipausersearchfields negative test"
        ipa config-show --all | grep "User search fields" > /tmp/usersearch.out
        usersearchfields=`cat /tmp/usersearch.out | awk '{print $4}'`
        command="ipa config-mod --delattr=ipausersearchfields=\"$usersearchfields\""
        expmsg="ipa: ERROR: 'ipausersearchfields' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=817831"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-012: ipacertificatesubjectbase negative test"
        command="ipa config-mod --delattr=ipacertificatesubjectbase=O=$RELM"
        #expmsg="ipa: ERROR: 'ipacertificatesubjectbase' is required"
        expmsg="ipa: ERROR: invalid 'ipacertificatesubjectbase': attribute is not configurable"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=807018"
    rlPhaseEnd

    rlPhaseStartTest "ipa-config-delattr-013: ipapwdexpadvnotify negative test"
        command="ipa config-mod --delattr=ipapwdexpadvnotify=4"
        expmsg="ipa: ERROR: 'ipapwdexpadvnotify' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

}

ipaconfig_setattr_positive()
{
   rlPhaseStartTest "ipa-config-setattr-001: ipahomesrootdir positive"
	rlRun "ipa config-mod --setattr=ipahomesrootdir=/mnt/home" 0 "Set ipahomesrootdir to /mnt/home"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Home directory base: /mnt/home"
        if [ $? -eq 0 ] ; then
                rlPass "ipahomesrootdir successfully changed."
        else
                rlFail "ipahomesrootdir not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-002: ipamaxusernamelength positive"
        rlRun "ipa config-mod --setattr=ipamaxusernamelength=99" 0 "Set ipamaxusernamelength to 99"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Maximum username length: 99"
        if [ $? -eq 0 ] ; then
                rlPass "ipamaxusernamelength successfully changed."
        else
                rlFail "ipamaxusernamelength not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-003: ipadefaultprimarygroup positive"
	ipa group-add --desc=mygroup mygroup
        rlRun "ipa config-mod --setattr=ipadefaultprimarygroup=mygroup" 0 "Set ipadefaultprimarygroup to mygroup"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Default users group: mygroup"
        if [ $? -eq 0 ] ; then
                rlPass "ipadefaultprimarygroup successfully changed."
        else
                rlFail "ipadefaultprimarygroup not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-004: ipasearchtimelimit positive"
        rlRun "ipa config-mod --setattr=ipasearchtimelimit=5" 0 "Set ipasearchtimelimit to 5"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Search time limit: 5"
        if [ $? -eq 0 ] ; then
                rlPass "ipasearchtimelimit successfully changed."
        else
                rlFail "ipasearchtimelimit not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-005: ipasearchrecordslimit positive"
        rlRun "ipa config-mod --setattr=ipasearchrecordslimit=99" 0 "Set ipasearchrecordslimit to 99"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Search size limit: 99"
        if [ $? -eq 0 ] ; then
                rlPass "ipasearchrecordslimit successfully changed."
        else
                rlFail "ipasearchrecordslimit not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-006: ipagroupsearchfields positive"
        rlRun "ipa config-mod --setattr=ipagroupsearchfields=\"cn,member\"" 0 "Set ipagroupsearchfields to cn,member"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Group search fields: cn,member"
        if [ $? -eq 0 ] ; then
                rlPass "ipagroupsearchfields successfully changed."
        else
                rlFail "ipagroupsearchfields not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-007: ipausersearchfields positive"
        rlRun "ipa config-mod --setattr=ipausersearchfields=\"uid,memberof\"" 0 "Set ipausersearchfields to uid,memberof"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "User search fields: uid,memberof"
        if [ $? -eq 0 ] ; then
                rlPass "ipausersearchfields successfully changed."
        else
                rlFail "ipausersearchfields not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-008: ipacertificatesubjectbase negative"
        command="ipa config-mod --setattr=ipacertificatesubjectbase=\"OU=Bogus\""
        #expmsg="ipa: ERROR: Action not allowed"
        expmsg="ipa: ERROR: invalid 'ipacertificatesubjectbase': attribute is not configurable"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=807018"
   rlPhaseEnd

   rlPhaseStartTest "ipa-config-setattr-009: ipapwdexpadvnotify positive"
        rlRun "ipa config-mod --setattr=ipapwdexpadvnotify=7" 0 "Set ipapwdexpadvnotify to 7"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Search size limit: 99"
        if [ $? -eq 0 ] ; then
                rlPass "ipapwdexpadvnotify successfully changed."
        else
                rlFail "ipapwdexpadvnotify not as expected"
        fi
   rlPhaseEnd

}

cleanup()
{
   rlPhaseStartCleanup "Cleanup"
	# Commenting the following case since ipacertificatesubjectbase is no longer a configurable attribute.
	# rlRun "ipa config-mod --setattr=ipacertificatesubjectbase=\"O=$RELM\""	
	rlRun "ipa config-show"
	rlRun "restore_ipaconfig" 0 "Restore default configuration"
	rlRun "ipa group-del mygroup"
   rlPhaseEnd
}
