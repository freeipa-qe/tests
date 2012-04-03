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
   rlPhaseStartTest "kinit as Admin"
	rlRun "kinitAs $ADMINID $ADMINPW"
   rlPhaseEnd
}

ipaconfig_addattr_positive()
{
   # ipaconfigstring is the only attribute that can be multi-valued and is optional.  However the only allowed values are AllowNThash (default) and AllowLMHash
   # see ipa help config-mod

   rlPhaseStartTest "Add additional allowed config string for Password plugin feature"
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

   rlPhaseStartTest "Add additional allowed user object class"
        rlRun "ipa config-mod --addattr=ipauserobjectclasses=sambasamaccount" 0 "Add additional allowed objectclass"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Default user objectclasses: top, person, organizationalperson, inetorgperson, inetuser, posixaccount, krbprincipalaux, krbticketpolicyaux, ipaobject, ipasshuser, sambasamaccount"
        if [ $? -eq 0 ] ; then
                rlPass "Additional user objectclass successfully added."
        else
                rlFail "User object classes not as expected."
        fi

 	# remove objectclass added
        rlRun "ipa config-mod --delattr=ipauserobjectclasses=sambasamaccount" 0
   rlPhaseEnd

   rlPhaseStartTest "Add additional allowed group object class"
        rlRun "ipa config-mod --addattr=ipagroupobjectclasses=posixgroup" 0 "Add additional allowed objectclass"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Default group objectclasses: top, groupofnames, nestedgroup, ipausergroup, ipaobject, posixgroup"
        if [ $? -eq 0 ] ; then
                rlPass "Additional group objectclass successfully added."
        else
                rlFail "Group objectclasses not as expected."
        fi

	# remove objectclass added
        rlRun "ipa config-mod --delattr=ipagroupobjectclasses=posixgroup" 0
   rlPhaseEnd 
}

ipaconfig_addattr_negative()
{
  rlPhaseStartTest "ipaconfig_addaddtr negative test -ipamaxusernamelength - only one allowed"
	command="ipa config-mod --addattr=ipamaxusernamelength=33"
	expmsg="ipa: ERROR: ipamaxusernamelength: Only one value allowed."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipahomesrootdir - only one allowed"
        command="ipa config-mod --addattr=ipahomesrootdir=/mnt/home"
        expmsg="ipa: ERROR: ipahomesrootdir: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipadefaultloginshell - only one allowed"
        command="ipa config-mod --addattr=ipadefaultloginshell=/bin/csh"
        expmsg="ipa: ERROR: ipadefaultloginshell: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipadefaultprimarygroup - only one allowed"
        command="ipa config-mod --addattr=ipadefaultprimarygroup=\"cn=mygroup,cn=groups,cn=accounts,$BASEDN\""
        expmsg="ipa: ERROR: invalid 'cn': Only one value is allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipadefaultemaildomain - only one allowed"
        command="ipa config-mod --addattr=ipadefaultemaildomain=domain.com"
        expmsg="ipa: ERROR: ipadefaultemaildomain: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipasearchtimelimit - only one allowed"
        command="ipa config-mod --addattr=ipasearchtimelimit=20"
        expmsg="ipa: ERROR: ipasearchtimelimit: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipasearchrecordslimit - only one allowed"
        command="ipa config-mod --addattr=ipasearchrecordslimit=200"
        expmsg="ipa: ERROR: ipasearchrecordslimit: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipagroupsearchfields - only one allowed"
        command="ipa config-mod --addattr=ipagroupsearchfields=newattr"
        expmsg="ipa: ERROR: ipagroupsearchfields: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794746"
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipausersearchfields only one allowed"
        command="ipa config-mod --addattr=ipausersearchfields=newattr"
        expmsg="ipa: ERROR: ipausersearchfields: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794746"
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipacertificatesubjectbase only one allowed"
        command="ipa config-mod --addattr=ipacertificatesubjectbase=O=DOMAIN.COM"
        expmsg="ipa: ERROR: ipacertificatesubjectbase: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=807018"
  rlPhaseEnd

  rlPhaseStartTest "ipaconfig_addaddtr negative test - ipapwdexpadvnotify - only one allowed"
        command="ipa config-mod --addattr=ipapwdexpadvnotify=7"
        expmsg="ipa: ERROR: ipapwdexpadvnotify: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
  rlPhaseEnd

}

ipaconfig_delattr_positive()
{
   rlPhaseStartTest "ipaconfig delattr ipaconfigstring"
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
}

ipaconfig_delattr_negative()
{

    rlPhaseStartTest "ipaconfig_delattr invalid attribute negative test"
	command="ipa config-mod --delattr=ipaCustomFields=FALSE"
	expmsg="ipa: ERROR: ipacustomfields does not exist"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipahomesrootdir negative test"
	command="ipa config-mod --delattr=ipahomesrootdir=/home/"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipamaxusernamelength negative test"
        command="ipa config-mod --delattr=ipamaxusernamelength=32"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipadefaultloginshell negative test"
        command="ipa config-mod --delattr=ipadefaultloginshell=/bin/bash"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipadefaultprimarygroup negative test"
        command="ipa config-mod --delattr=ipadefaultprimarygroup=\"cn=ipausers,cn=accounts,cn=$BASEDN\""
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipadefaultemaildomain negative test"
        command="ipa config-mod --delattr=ipadefaultemaildomain=$DOMAIN"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipasearchtimelimit negative test"
        command="ipa config-mod --delattr=ipasearchtimelimit=2"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipasearchrecordslimit negative test"
        command="ipa config-mod --delattr=ipasearchrecordslimit=100"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipagroupsearchfields negative test"
        command="ipa config-mod --delattr=ipagroupsearchfields="
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipausersearchfields negative test"
        command="ipa config-mod --delattr=ipausersearchfields="
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipacertificatesubjectbase negative test"
        command="ipa config-mod --delattr=ipacertificatesubjectbase=O=$RELM"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_delattr ipapwdexpadvnotify negative test"
        command="ipa config-mod --delattr=ipapwdexpadvnotify=4"
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=794804"
    rlPhaseEnd

}

ipaconfig_setattr_positive()
{
   rlPhaseStartTest "ipaconfig-mod_setattr ipahomesrootdir positive"
	rlRun "ipa config-mod --setattr=ipahomesrootdir=/mnt/home" 0 "Set ipahomesrootdir to /mnt/home"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Home directory base: /mnt/home"
        if [ $? -eq 0 ] ; then
                rlPass "ipahomesrootdir successfully changed."
        else
                rlFail "ipahomesrootdir not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipamaxusernamelength positive"
        rlRun "ipa config-mod --setattr=ipamaxusernamelength=99" 0 "Set ipamaxusernamelength to 99"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Maximum username length: 99"
        if [ $? -eq 0 ] ; then
                rlPass "ipamaxusernamelength successfully changed."
        else
                rlFail "ipamaxusernamelength not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipadefaultprimarygroup positive"
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

   rlPhaseStartTest "ipaconfig-mod_setattr ipasearchtimelimit positive"
        rlRun "ipa config-mod --setattr=ipasearchtimelimit=5" 0 "Set ipasearchtimelimit to 5"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Search time limit: 5"
        if [ $? -eq 0 ] ; then
                rlPass "ipasearchtimelimit successfully changed."
        else
                rlFail "ipasearchtimelimit not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipasearchrecordslimit positive"
        rlRun "ipa config-mod --setattr=ipasearchrecordslimit=99" 0 "Set ipasearchrecordslimit to 99"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Search size limit: 99"
        if [ $? -eq 0 ] ; then
                rlPass "ipasearchrecordslimit successfully changed."
        else
                rlFail "ipasearchrecordslimit not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipagroupsearchfields positive"
        rlRun "ipa config-mod --setattr=ipagroupsearchfields=\"cn,member\"" 0 "Set ipagroupsearchfields to cn,member"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "Group search fields: cn,member"
        if [ $? -eq 0 ] ; then
                rlPass "ipagroupsearchfields successfully changed."
        else
                rlFail "ipagroupsearchfields not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipausersearchfields positive"
        rlRun "ipa config-mod --setattr=ipausersearchfields=\"uid,memberof\"" 0 "Set ipausersearchfields to uid,memberof"
        ipa config-show --all > /tmp/configshowadd.out
        cat /tmp/configshowadd.out | grep "User search fields: uid,memberof"
        if [ $? -eq 0 ] ; then
                rlPass "ipausersearchfields successfully changed."
        else
                rlFail "ipausersearchfields not as expected"
        fi
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipacertificatesubjectbase positive"
        command="ipa config-mod --setattr=ipacertificatesubjectbase=\"OU=Bogus\""
        expmsg="ipa: ERROR: Action not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlLog "Verifies bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=807018"
   rlPhaseEnd

   rlPhaseStartTest "ipaconfig-mod_setattr ipapwdexpadvnotify positive"
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
   rlPhaseStartTest "Cleanup"
	rlRun "ipa config-mod --setattr=ipacertificatesubjectbase=\"O=$RELM\""	
	rlRun "restore_ipaconfig" 0 "Restore default configuration"
	rlRun "ipa group-del mygroup"
   rlPhaseEnd
}
