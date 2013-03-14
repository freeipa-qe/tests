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
######################
# test suite         #
######################
ipaconfig()
{
    ipaconfig_envsetup
    ipaconfig_show
    ipaconfig_mod
    ipaconfig_searchlimit
    ipaconfig_searchfields
    ipaconfig_server
    ipaconfig_envcleanup
} # ipaconfig

######################
# test set           #
######################
ipaconfig_show()
{
    ipaconfig_show_envsetup
    ipaconfig_show_default
    ipaconfig_show_negative
    ipaconfig_show_envcleanup
} #ipaconfig_show

ipaconfig_mod()
{
    ipaconfig_mod_envsetup
    ipaconfig_mod_maxusername_default
    ipaconfig_mod_maxusername_negative
    ipaconfig_mod_homedirectory_default
    ipaconfig_mod_homedirectory_negative
    ipaconfig_mod_defaultshell_default
    ipaconfig_mod_defaultshell_negative
    ipaconfig_mod_defaultgroup_default
    ipaconfig_mod_defaultgroup_negative
    ipaconfig_mod_emaildomain_default
    ipaconfig_mod_emaildomain_negative
    ipaconfig_mod_pwdexpiration
    ipaconfig_mod_envcleanup
} #ipaconfig_mod

ipaconfig_searchlimit()
{
    ipaconfig_searchlimit_envsetup
    ipaconfig_searchlimit_timelimit_default
    ipaconfig_searchlimit_timelimit_negative
    ipaconfig_searchlimit_recordslimit_default
    ipaconfig_searchlimit_recordslimit_negative
    ipaconfig_searchlimit_envcleanup
} #ipaconfig_searchlimit

ipaconfig_searchfields()
{
    ipaconfig_searchfields_envsetup
    ipaconfig_searchfields_userfields_default
    ipaconfig_searchfields_userfields_negative
    ipaconfig_searchfields_groupfields_default
    ipaconfig_searchfields_groupfields_negative
    ipaconfig_searchfields_envcleanup
} #ipaconfig_searchfields

ipaconfig_server()
{
    ipaconfig_server_envsetup
    ipaconfig_server_enablemigration
    ipaconfig_server_enablemigration_negative
    # Test for BZ 807018 ipa config-mod should not be allowed to modify certificate subject base
    # tests no longer valid  - option to modify --subject has been removed
    # ipaconfig_server_subject
    # ipaconfig_server_subject_negative
    ipaconfig_server_envcleanup
} #ipaconfig_server

######################
# test cases         #
######################
ipaconfig_envsetup()
{
    rlPhaseStartSetup "ipaconfig_envsetup"
        #environment setup starts here
        rlPass "no special env setup required for ipa config"
        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_envsetup

ipaconfig_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_envcleanup"
        #environment cleanup starts here
	rlPass "Should be no cleanup as each section sets the value back to default"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_envcleanup

ipaconfig_show_envsetup()
{
    rlPhaseStartSetup "ipaconfig_show_envsetup"
        #environment setup starts here
        rlPass "no special env setup required for ipa config"
        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_show_envsetup

ipaconfig_show_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_show_envcleanup"
        #environment cleanup starts here
        rlPass "no special env cleanup required"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_show_envcleanup

ipaconfig_show_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_show_default"
        rlLog "this is to test for defult behavior"
        ipaconfig_show_default_logic
    rlPhaseEnd
} #ipaconfig_show_default

ipaconfig_show_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "test for --all option"
        local out=$TmpDir/ipaconfig.show.all.$RANDOM.out
        kinitAs $ADMINID $ADMINPW 
        rlRun "ipa config-show --all > $out" 0 "save show --all in [$out]"
        string_exist_infile "Maximum username length:" $out
        string_exist_infile "Home directory base:" $out
        string_exist_infile "Default shell:" $out
        string_exist_infile "Default users group:" $out
        string_exist_infile "Default e-mail domain:" $out
        string_exist_infile "Search time limit:" $out
        string_exist_infile "Search size limit:" $out
        string_exist_infile "User search fields:" $out
        string_exist_infile "Group search fields:" $out
        string_exist_infile "Enable migration mode:" $out
        string_exist_infile "Certificate Subject base:" $out
        string_exist_infile "Password plugin features:" $out
        string_exist_infile "Password Expiration Notification (days):" $out
        rm $out; 

        rlLog "test for --raw option"
        local out=$TmpDir/ipaconfig.show.raw.$RANDOM.out
        rlRun "ipa config-show --raw > $out" 0 "save show --raw in [$out]" 
        string_exist_infile "ipamaxusernamelength:" $out
        string_exist_infile "ipahomesrootdir:" $out
        string_exist_infile "ipadefaultloginshell:" $out
        string_exist_infile "ipadefaultprimarygroup:" $out
        string_exist_infile "ipasearchtimelimit:" $out
        string_exist_infile "ipasearchrecordslimit:" $out
        string_exist_infile "ipausersearchfields:" $out
        string_exist_infile "ipagroupsearchfields:" $out
        string_exist_infile "ipamigrationenabled:" $out
        string_exist_infile "ipacertificatesubjectbase:" $out

        clear_kticket
        rm $out; 
    # test logic ends
} # ipaconfig_show_default_logic 

ipaconfig_show_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_show_negative"
        rlLog "this is to test for defult behavior"
        ipaconfig_show_negative_logic
    rlPhaseEnd
} #ipaconfig_show_negative

ipaconfig_show_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        clear_kticket
        rlRun "ipa config-show" 1 "only ipa user can do config-show"
    # test logic ends
} # ipaconfig_show_negative_logic 

ipaconfig_mod_envsetup()
{
    rlPhaseStartSetup "ipaconfig_mod_envsetup"
        #environment setup starts here
        rlPass "no special env setup for config-mod"
        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_mod_envsetup


ipaconfig_mod_pwdexpiration()
{
    rlPhaseStartTest "ipaconfig_mod_pwdexpiration - positive"
        for item in 3 12 54 0 47 4 ; do
            KinitAsAdmin
            rlRun "ipa config-mod --pwdexpnotify=$item" 0 "set password notify option to [$item]"
            sleep 2
            value=`ipa config-show | grep "Password Expiration Notification" | cut -d ":" -f 2`
	    # trim white space
	    value=`echo $value`
	    if [ $value -ne $item ] ; then
		rlFail "Password Exipration Notification not as expected.  GOT: $value  Expected: $item"
	    else
		rlPass "Password Exipration Notification as expected: $value"
	    fi
        done
    rlPhaseEnd

    rlPhaseStartTest "ipaconfig_mod_pwdexpiration - negative"
	expmsg="ipa: ERROR: invalid 'pwdexpnotify': must be an integer"
	for item in a * GH blaH ; do
		rlRun "verifyErrorMsg \"ipa config-mod --pwdexpnotify=$item\" \"$expmsg\"" 0 "Verify expected error message."
	done
    rlPhaseEnd

}

ipaconfig_mod_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_mod_envcleanup"
        #environment cleanup starts here
        rlPass "no special env cleanup for config-mod"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_mod_envcleanup

ipaconfig_mod_maxusername_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_maxusername_default"
        rlLog "this is to test for default behavior"
        # only do spot check for username length setting
        # assuming spot is randomly selected at 21
        # we will then check: 1, 20,21,22,255
        # so "spot" range would be : 3-255
        local max=$((config_username_maxlength - 2))
        #local spot=`getrandomint 3 $max`
        local spot=`getrandomint 3 31`
        #for len in 1 $spot $config_username_maxlength
        #for len in 1 $spot 
	for len in 1 12 54 47 ; do
            #set the maxusername via ipa config-mod
            KinitAsAdmin
            rlRun "ipa config-mod --maxusername=$len" 0 "set maxusername to [$len]"
	    sleep 2
            ipaconfig_mod_maxusername_default_logic $len
        done

	rlRun "ipa config-mod --maxusername=$default_config_usernamelength" 0 "set maxusername=[$default_config_usernamelength] - back to default"
    rlPhaseEnd
} #ipaconfig_mod_maxusername_default

ipaconfig_mod_maxusername_default_logic()
{
    # accept parameters: length 
    # test logic starts
        local length=$1
        # when user name < defined max length, we should be able to create user 
        # we still do spot check here:
        # example: if passin length = 10, we then define
        # pass case: 1, 6 , 10 --> whee "6" is randomm spot we picked
        # fail case: 11, 255 (current max)

        local spot=`getrandomint 2 $length` 
        local username_length="1 $spot $length"
        #when current username < definedLength, test should pass
        #for curlen in $username_length ; do
	    expected=0
            username=`dataGenerator "username" $length`
            rlLog "test: len=[$length], username=[$username], expect success"
            create_ipauser $expected $username 
	    KinitAsAdmin
            rlRun "ipa user-del $username" 0 "Cleanup"

            local longer=$(($length + 5))
            local username_length="$longer $config_username_maxlength"
            #when current username>defined, test should fail 
            expected=1
            username=`dataGenerator "username" $longer`
            rlLog "test: len=[$longer], username=[$username], expect fail"
            rlRun "ipa user-add --first=$username --last=$username $username" 1 "This should fail - too long"

	    # just in case user gets added - data generater does not always work and generates a length that is 1 less than requested
	    ipa user-find $username
	    if [ $? -eq 0 ] ; then
		ipa user-del $username
	    fi

	    unset length
	    unset username
	    unset longer
    # test logic ends
} # ipaconfig_mod_maxusername_default_logic 

ipaconfig_mod_maxusername_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_maxusername_negative"
        rlLog "negative test case for maxusername"
        for len in 0 -1 a abc
        do
            ipaconfig_mod_maxusername_negative_logic $len
        done
    rlPhaseEnd
} #ipaconfig_mod_maxusername_negative

ipaconfig_mod_maxusername_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local  len=$1
        KinitAsAdmin
        rlRun "ipa config-mod --maxusername=$len" 1 "expect to fail: maxusername=[$len]"
    # test logic ends
} # ipaconfig_mod_maxusername_negative_logic 

ipaconfig_mod_homedirectory_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_homedirectory_default"
        rlLog "this is to test for default behavior"
        KinitAsAdmin
        local testdir=`GenerateHomeDirectoryName`
        rlRun "ipa config-mod --homedirectory=$testdir" 0 "set homedirectory=[$testdir]"
        ipaconfig_mod_homedirectory_default_logic "$testdir"
    rlPhaseEnd
} #ipaconfig_mod_homedirectory_default

ipaconfig_mod_homedirectory_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local basedir=$1
        local out=$TmpDir/config.homedirectory.$RANDOM.out
        username=`dataGenerator "username" 8` # FIXME: not sure length 8 is right to use -- since we changed maxusernamelength to something we don't know when we hit this test case
        create_ipauser 0 $username
        KinitAsAdmin
        ipa user-find $username > $out
        actualdir=`grep "Home directory" $out | cut -d":" -f2 | xargs echo`
        if echo $actualdir | grep -i "^$basedir" 2>&1 >/dev/null
        then
            rlPass "found [$basedir] in actual:[$actualdir]"
        else
            rlFail "actual [$actualdir], expect [$basedir]"
        fi
        rm $out

	rlRun "ipa config-mod --homedirectory=$default_config_homebase" 0 "set homedirectory=[$default_config_homebase] - back to default"
	rlRun "ipa user-del $username" 0 "Cleanup"
    # test logic ends
} # ipaconfig_mod_homedirectory_default_logic 

ipaconfig_mod_homedirectory_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_homedirectory_negative"
        KinitAsAdmin
        local dirs="ť úů ý0ž aábč" # 8bit string now allowed in homedir
        for testdir in $dirs; do
            rlRun "ipa config-mod --homedirectory=$testdir" 1 "set homedirectory=[$testdir]" 0 "8bit char should no accepted "
        done
    rlPhaseEnd
} #ipaconfig_mod_homedirectory_negative

ipaconfig_mod_homedirectory_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "this is blank function"
    # test logic ends
} # ipaconfig_mod_homedirectory_negative_logic 

ipaconfig_mod_defaultshell_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultshell_default"
        rlLog "this is to test for default behavior"
        KinitAsAdmin
        local testshell=`GenerateShellName`
        rlRun "ipa config-mod --defaultshell=$testshell" 0 "set defaultshell=[$testshell]"
        ipaconfig_mod_defaultshell_default_logic "$testshell"
    rlPhaseEnd
} #ipaconfig_mod_defaultshell_default

ipaconfig_mod_defaultshell_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local baseshell=$1
        local out=$TmpDir/config.defaultshell.$RANDOM.out
        username=`dataGenerator "username" 8` # FIXME: not sure length 8 is right to use -- since we changed maxusernamelength to something we don't know when we hit this test case
        create_ipauser 0 $username
        KinitAsAdmin
        ipa user-find $username > $out
        actualshell=`grep "Login shell" $out | cut -d":" -f2 | xargs echo`
        if echo $actualshell | grep -i "^$baseshell" 2>&1 >/dev/null
        then
            rlPass "found [$baseshell] in actual:[$actualshell]"
        else
            rlFail "actual [$actualshell], expect [$baseshell]"
        fi
	rlRun "ipa config-mod --defaultshell=$default_config_shell" 0 "set defaultshell=[$default_config_shell] - back to default"
        rlRun "ipa user-del $username" 0 "Cleanup"
        rm $out
    # test logic ends
} # ipaconfig_mod_defaultshell_default_logic 

ipaconfig_mod_defaultshell_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultshell_negative"
        rlLog "negative test case for defaultshell"
        KinitAsAdmin
        local shells="ťt̬ ðʒʊʊɔɒɪɪ ɝɛɜɚəə ú ů ý0ž aábč" # 8bit string now allowed in homedir
        for testshell in $shells; do
            rlRun "ipa config-mod --defaultshell=$testshell" 1 "set defaultshell=[$testshell]" 1 "8bit char should no accepted "
        done
    rlPhaseEnd
} #ipaconfig_mod_defaultshell_negative

ipaconfig_mod_defaultshell_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_mod_defaultshell_negative_logic 

ipaconfig_mod_defaultgroup_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultgroup_default"
        rlLog "this is to test for default behavior"
        KinitAsAdmin
        local testgroup=`GenerateGroupName`
	rlRun "ipa group-add --desc=\"$testgroup\" \"$testgroup\"" 0 "Add test group"
        rlRun "ipa config-mod --defaultgroup=\"$testgroup\" " 0 "set defaultgroup=[$testgroup]"
        ipaconfig_mod_defaultgroup_default_logic "$testgroup"
        rlRun "ipa config-mod --defaultgroup=$default_config_usergroup" 0 "set homedirectory=[$default_config_usergroup] - back to default"
	rlRun "ipa group-del \"$testgroup\"" 0 "Delete test group"
    rlPhaseEnd
} #ipaconfig_mod_defaultgroup_default

ipaconfig_mod_defaultgroup_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local basegroup=$1
        local out=$TmpDir/config.defaultgroup.$RANDOM.out
        username=`dataGenerator "username" 8` # FIXME: not sure length 8 is right to use -- since we changed maxusernamelength to something we don't know when we hit this test case
        create_ipauser 0 $username
        KinitAsAdmin
        ipa user-show $username > $out
        actualgroup=`grep "groups" $out | cut -d":" -f2 | xargs echo`
        if echo $actualgroup | grep -i "^$basegroup" 2>&1 >/dev/null
        then
            rlPass "found [$basegroup] in actual:[$actualgroup]"
        else
            rlFail "actual [$actualgroup], expect [$basegroup]"
        fi
        rm $out

	rlRun "ipa user-del $username" 0 "Cleanup"
    # test logic ends
} # ipaconfig_mod_defaultgroup_default_logic 

ipaconfig_mod_defaultgroup_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultgroup_negative"
        rlLog "negative test case for defaultgroup"
	rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=752686"
        ipaconfig_mod_defaultgroup_negative_logic
    rlPhaseEnd
} #ipaconfig_mod_defaultgroup_negative

ipaconfig_mod_defaultgroup_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlRun "ipa config-mod --defaultgroup=doesntexist" 2 "set defaultgroup=[doesntexist]"
    # test logic ends
} # ipaconfig_mod_defaultgroup_negative_logic 

ipaconfig_mod_emaildomain_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_emaildomain_default"
        rlLog "this is to test for default behavior"
        KinitAsAdmin
        local testdomain=`GenerateDomainName`
        rlRun "ipa config-mod --emaildomain=$testdomain" 0 "set emaildomain=[$testdomain]"
        ipaconfig_mod_emaildomain_default_logic "$testdomain"

	rlRun "ipa config-mod --emaildomain=$default_config_emaildomain" 0 "set default emaildomain=[$default_config_emaildomain] - back to default"
    rlPhaseEnd
} #ipaconfig_mod_emaildomain_default

ipaconfig_mod_emaildomain_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local testdomain=$1
        local out=$TmpDir/config.defaultdomain.$RANDOM.out
        username=`dataGenerator "username" 8` # FIXME: not sure length 8 is right to use -- since we changed maxusernamelength to something we don't know when we hit this test case
        create_ipauser 0 $username "" "" "" "--email=${username}"
        KinitAsAdmin
        ipa user-find $username --raw --all > $out
        actualdomain=`grep "mail" $out | cut -d":" -f2 | xargs echo`
        if echo $actualdomain | grep -i "$username@$testdomain" 2>&1 >/dev/null
        then
            rlPass "email as expected [$actualdomain]"
        else
            echo "============ out ============"
            cat $out
            echo "============================="
            rlFail "actual [$actualdomain], expected [$username@$testdomain]"
        fi

        rlRun "ipa user-mod --email=${username}@mydomain.com ${username}" 0 "Modify user email address adding non default domain"
        ipa user-find $username --raw --all > $out
        actualdomain=`grep "mail" $out | cut -d":" -f2 | xargs echo`
        if echo $actualdomain | grep -i "$testdomain" 2>&1 >/dev/null
        then
            rlFail "found [$actualdomain] expected:[$username@mydomain.com]"
        else
            echo "============ out ============"
            cat $out
            echo "============================="
            rlPass "email as expected [$actualdomain]"
        fi

	rlRun "ipa user-del $username" 0 "Cleanup"
        rm $out
    # test logic ends
} # ipaconfig_mod_emaildomain_default_logic 

ipaconfig_mod_emaildomain_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_emaildomain_negative"
        rlLog "negative test case for emaildomain"
        ipaconfig_mod_emaildomain_negative_logic
    rlPhaseEnd
} #ipaconfig_mod_emaildomain_negative

ipaconfig_mod_emaildomain_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_mod_emaildomain_negative_logic 

ipaconfig_searchlimit_envsetup()
{
    rlPhaseStartSetup "ipaconfig_searchlimit_envsetup"
        #environment setup starts here
        rlPass "no special env setup required"
        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_searchlimit_envsetup

ipaconfig_searchlimit_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_searchlimit_envcleanup"
        #environment cleanup starts here
        rlPass "no special env cleanup required"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_searchlimit_envcleanup

ipaconfig_searchlimit_timelimit_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_timelimit_default"
        rlLog "this is to test for default behavior"
        out=$TmpDir/ipaconfig.searchtimelimit.$RANDOM.out
        KinitAsAdmin
	ipaconfig_searchlimit_timelimit_default_logic
        for value in -1 10 55 100 10000 2
        do
            ipa config-mod --searchtimelimit=$value 2>&1 >/dev/null
            ipa config-show > $out
            if grep -i "Search time limit: $value" $out 2>&1 >/dev/null 
            then
                rlPass "set search time limit to $value success"
            else
                rlFail "set search time limit to $value failed"
            fi
        done
        rm $out
    rlPhaseEnd
} #ipaconfig_searchlimit_timelimit_default

ipaconfig_searchlimit_timelimit_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO TESTS"
    # test logic ends
} # ipaconfig_searchlimit_timelimit_default_logic 

ipaconfig_searchlimit_timelimit_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_timelimit_negative"
        rlLog "negative test case"
        out=$TmpDir/ipaconfig.searchtimelimit.$RANDOM.out
        KinitAsAdmin
        for value in -10 0 a abc
        do
            ipa config-mod --searchtimelimit=$value 2>&1 >/dev/null
            ipa config-show > $out
            if grep -i "Search time limit: $value" $out 2>&1 >/dev/null 
            then
                rlFail "set search time limit to $value success is not expected"
            else
                rlPass "set search time limit to $value failed is expected"
            fi
        done
        rm $out

    rlPhaseEnd
} #ipaconfig_searchlimit_timelimit_negative

ipaconfig_searchlimit_timelimit_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_searchlimit_timelimit_negative_logic 

ipaconfig_searchlimit_recordslimit_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_recordslimit_default"
        rlLog "this is to test for default behavior"
        KinitAsAdmin
        for value in 0 10 97 10000 100
        do
            ipa config-mod --searchrecordslimit=$value 2>&1 >/dev/null
            ipa config-show > $out
            if grep -i "Search size limit: $value" $out 2>&1 >/dev/null 
            then
                rlPass "set search record limit to $value success "
            else
                rlFail "set search record limit to $value failed"
            fi
        done

	ipaconfig_searchlimit_recordslimit_default_logic

    rlPhaseEnd
} #ipaconfig_searchlimit_recordslimit_default

ipaconfig_searchlimit_recordslimit_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        totalEntries=`ipa user-find | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        username=`dataGenerator "username" 8`
        create_ipauser 0 $username
        
	KinitAsAdmin
        ipa config-mod --searchrecordslimit=1 2>&1 >/dev/null
        totalEntries=`ipa user-find | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        rlLog "found [$totalEntries]"
        if [ $totalEntries -eq 1 ]; then
            rlPass "recordslimit sets to 1, and user-find return 1"
        else
            rlFail "recordslimit sets to 1, but returned [$totalEntries] entries"
        fi
        # set limit to 2, and test again
        ipa config-mod --searchrecordslimit=2 2>&1 >/dev/null
        totalEntries=`ipa user-find | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        rlLog "found [$totalEntries]"
        if [ $totalEntries -eq 2 ];then
            rlPass "recordslimit sets to 2, and user-find return 2"
        else
            rlFail "recordslimit sets to 2, but returned [$totalEntries] entries"
        fi
        rlRun "ipa user-del $username" 0 "Cleanup"
	sleep 1
	rlRun "ipa config-mod --searchrecordslimit=$default_config_sizelimit" 0 "set searchrecordslimit=[$default_config_sizelimit] - back to default"
    # test logic ends
} # ipaconfig_searchlimit_recordsimie_default_logic 

ipaconfig_searchlimit_recordslimit_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_recordslimit_negative"
        rlLog "negative test case"
        out=$TmpDir/ipaconfig.searchrecordlimit.$RANDOM.out
        KinitAsAdmin
        for value in -2 -10 a abc 
        do
            ipa config-mod --searchrecordslimit=$value 2>&1 >/dev/null
            ipa config-show > $out
            if grep -i "Search size limit: $value" $out 2>&1 >/dev/null 
            then
                rlFail "set search record limit to $value success is not expected "
            else
                rlPass "set search record limit to $value failed is expected"
            fi
        done
        rm $out
    rlPhaseEnd
} #ipaconfig_searchlimit_recordslimit_negative

ipaconfig_searchlimit_recordslimit_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_searchlimit_recordslimit_negative_logic 

ipaconfig_searchfields_envsetup()
{
    rlPhaseStartSetup "ipaconfig_searchfields_envsetup"
        #environment setup starts here
        rlPass "no special env setup required"
        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_searchfields_envsetup

ipaconfig_ticket_2159()
{
	# Testcase covering https://fedorahosted.org/freeipa/ticket/2159
	rlPhaseStartTest "Testcase covering ticket 2159"
		ipa config-mod --groupsearch= &> /opt/rhqa_ipa/2159out.txt
		rlRun "grep Traceback  /opt/rhqa_ipa/2159out.txt" 1 "Making sure that running a empty groupsearch did not return a exception"
	rlPhaseEnd
}

ipaconfig_searchfields_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_searchfields_envcleanup"
        #environment cleanup starts here
        rlPass "no special env cleanup required"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_searchfields_envcleanup

ipaconfig_searchfields_userfields_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchfields_userfields_default"
        rlLog "this is to test for default behavior"
        local out=$TmpDir/searchfields.userfields.$RANDOM.out
        # setup special account for this test
        specialvalue=999999999999
        username=`dataGenerator "username" 8`

        create_ipauser 0 $username
        KinitAsAdmin
        ipa user-mod --mobile=${specialvalue} ${username}
        totalEntries=`ipa user-find $specialvalue | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        if [ "$totalEntries" = "0" ];then
            rlPass "special value for moblie, user not found when default search does not include the field mobile"
        else
            rlFail "User found with mobile $specialvalue: mobile not in default search"
        fi

        # start configuration change
	rlLog "Add mobile to default search fields"
        value="uid,givenname,sn,ou,title,telephonenumber,mobile"
        ipa config-mod --usersearch=$value 2>&1 >/dev/null
        ipa config-show > $out
        if grep -i "User search fields: $value" $out 2>&1 >/dev/null 
        then
            rlPass "set user search fields to [$value] success "
        else
            rlFail "set user search fields to [$value] failed"
        fi

        # we should be able to find this user after user search fields search
        totalEntries=`ipa user-find $specialvalue | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        rlLog "found [$totalEntries]"
        if [ "$totalEntries" = "1" ];then
            rlPass "user-find return 1"
        else
            rlFail "returned [$returnedNumEntry] entries when 1 is expected"
        fi
        rm $out

	# cleanup and set value back to default
	rlRun "ipa user-del ${username}" 0 "Cleanup - delete user added"
	rlRun "ipa config-mod --usersearch=\"${default_config_usersearchfields}\"" 0 "set usersearch=[$default_config_usersearchfields] - back to default"
    rlPhaseEnd
} #ipaconfig_searchfields_userfields_default

ipaconfig_searchfields_userfields_negative()
{
    # accept parameters: NONE
    # test logic starts
    rlPhaseStartTest "ipaconfig_searchfields_userfields_negative"
    # add invalid search field to default user search fields
	rlLog "Add field bogus to user search fields"
 	ipa config-mod --usersearch="${default_config_usersearchfields},bogus"
	if [ $? -eq 0 ] ; then
		rlFail "Attempt to add invalid field to user default search fields was successful."
		rlRun "ipa config-mod --usersearch=\"${default_config_usersearchfields}\"" 0 "set usersearch=[$default_config_usersearchfields] - back to default"
	else
		rlPass "Attempt failed as expected"
	fi
    rlPhaseEnd
    # test logic ends
} # ipaconfig_searchfields_userfields_negative


ipaconfig_searchfields_groupfields_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchfields_groupfields_default"
        rlLog "this is to test for default behavior"
        local out=$TmpDir/searchfields.groupfields.$RANDOM.out
        # setup special account for this test
        specialvalue="blahblahblah"
        groupname=`dataGenerator "username" 8`
	KinitAsAdmin
        ipa group-add --desc="${specialvalue}" mygroup
        totalEntries=`ipa group-find $specialvalue | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        if [ "$totalEntries" = "1" ];then
            rlPass "special value found when default search should look for group desc with $specialvalue"
        else
            rlFail "special value NOT found when default search should look for group desc with $specialvalue"
        fi

        # start configuration change
        value="cn"
        ipa config-mod --groupsearch=$value 2>&1 >/dev/null
        ipa config-show > $out
        if grep -i "Group search fields: $value" $out 2>&1 >/dev/null 
        then
            rlPass "set group search fields to [$value] success "
        else
            rlFail "set group search fields to [$value] failed"
        fi

        # we should be able to not find this group after group search fields search
	rlLog "Remove description from group search fields"
        totalEntries=`ipa group-find $specialvalue | grep "Number of entries returned" | cut -d" " -f5| xargs echo`
        rlLog "found [$totalEntries]"
        if [ "$totalEntries" = "0" ];then
            rlPass "group-find return 0"
        else
            rlFail "returned [$returnedNumEntry] entries when 0 is expected"
        fi
        rm $out

	# set value back to default
	rlRun "ipa group-del mygroup" 0 "Cleanup - delete group added."
        rlRun "ipa config-mod --groupsearch=\"${default_config_groupsearchfields}\"" 0 ""set groupsearch=[$default_config_groupsearchfields] - back to default
    rlPhaseEnd
} #ipaconfig_searchfields_groupfields_default

ipaconfig_searchfields_groupfields_negative()
{
    # accept parameters: NONE
    # test logic starts
    rlPhaseStartTest "ipaconfig_searchfields_groupfields_negative"
    # add invalid search field to default group search fields
        rlLog "Add field bogus to group search fields"
        ipa config-mod --groupsearch="${default_config_groupsearchfields},bogus"
        if [ $? -eq 0 ] ; then
		rlFail "Attempt to add invalid field to group default search fields was successful."             
		rlRun "ipa config-mod --groupsearch=\"${default_config_groupsearchfields}\"" 0 "set groupsearch=[$default_config_groupsearchfields] - back to default"
                rlPass "Attempt failed as expected"
        else
		rlPass "Attempt failed as expected"
        fi
    rlPhaseEnd
    # test logic ends
} # ipaconfig_searchfields_userfields_negative

ipaconfig_server_envsetup()
{
    rlPhaseStartSetup "ipaconfig_server_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_server_envsetup

ipaconfig_server_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_server_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_server_envcleanup

ipaconfig_server_enablemigration()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_server_enablemigration"
        rlLog "this is to test for default behavior"
        out=$TmpDir/ipaconfig.enablemigration.$RANDOM.out
        KinitAsAdmin
        for value in TRUE FALSE True False true false
        do
            ipa config-mod --enable-migration=$value 2>&1 >/dev/null
            ipa config-show > $out
            if grep -i "Migration mode: $value" $out 2>&1 >/dev/null 
            then
                rlPass "set migration mode to $value success"
            else
                rlFail "set to migration mode to $value failed"
            fi
        done
        for value in 0 1
        do
            ipa config-mod --enable-migration=$value 2>&1 >/dev/null
            ipa config-show > $out
            if [ $value -eq 0 ];then
               valueToCheck="FALSE"
            fi
            if [ $value -eq 1 ];then
               valueToCheck="TRUE"
            fi
     

            if grep -i "Migration mode: $valueToCheck" $out 2>&1 >/dev/null 
            then
                rlPass "set migration mode to $valueToCheck success"
            else
                rlFail "set to migration mode to $valueToCheck failed"
            fi
        done
        rm $out
    rlPhaseEnd
} #ipaconfig_server_enablemigration

ipaconfig_server_enablemigration_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO TESTS"
    # test logic ends
} # ipaconfig_server_enablemigration_logic 

ipaconfig_server_enablemigration_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_server_enablemigration_negative"
        rlLog "negative test case"
        for value in T F a -1 
        do
            rlRun "ipa config-mod --enable-migration=$value" 1 "set migration mode to [$value] should fail"
        done
    rlPhaseEnd
} #ipaconfig_server_enablemigration_negative

ipaconfig_server_enablemigration_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_server_enablemigration_negative_logic 

ipaconfig_server_subject()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_server_subject"
        rlLog "this is to test for default behavior"
        out=$TmpDir/ipaconfig.subject.$RANDOM.out
        KinitAsAdmin
        value="o=ipatest"
        ipa config-mod --subject=$value 2>&1 >/dev/null
        ipa config-show > $out
        if grep -i "Certificate Subject base: $value" $out 2>&1 >/dev/null 
        then
            rlPass "set subject to $value success"
        else
            rlFail "set subject to $value failed"
        fi
        rm $out
    rlPhaseEnd
} #ipaconfig_server_subject

ipaconfig_server_subject_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_server_subject_logic 

ipaconfig_server_subject_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_server_subject_negative"
        rlLog "negative test case"
        out=$TmpDir/ipaconfig.subject.negative.$RANDOM.out
        KinitAsAdmin
        value="ťúůýžáčďéěíňóřš"
        ipa config-mod --subject=$value 2>&1 >/dev/null
        ipa config-show > $out
        if grep -i "Certificate Subject base: $value" $out 2>&1 >/dev/null 
        then
            rlFail "set subject to $value should fail but not"
        else
            rlPass "set subject to $value failed as expected"
        fi
        rm $out
    rlPhaseEnd
} #ipaconfig_server_subject_negative

ipaconfig_server_subject_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "NO NEGATIVE TESTS"
    # test logic ends
} # ipaconfig_server_subject_negative_logic 
