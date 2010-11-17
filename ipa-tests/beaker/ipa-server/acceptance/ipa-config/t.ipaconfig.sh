
######################
# test suite         #
######################
ipaconfig()
{
    ipaconfig_envsetup
#    ipaconfig_show
#    ipaconfig_mod
#    ipaconfig_searchlimit
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
#    ipaconfig_mod_maxusername_default
#    ipaconfig_mod_maxusername_negative
#    ipaconfig_mod_homedirectory_default
#    ipaconfig_mod_homedirectory_negative
#    ipaconfig_mod_defaultshell_default
#    ipaconfig_mod_defaultshell_negative
#    ipaconfig_mod_defaultgroup_default
#    ipaconfig_mod_defaultgroup_negative
    ipaconfig_mod_emaildomain_default
    ipaconfig_mod_emaildomain_negative
    ipaconfig_mod_envcleanup
} #ipaconfig_mod

ipaconfig_searchlimit()
{
    ipaconfig_searchlimit_envsetup
    ipaconfig_searchlimit_timelimie_default
    ipaconfig_searchlimit_timelimie_negative
    ipaconfig_searchlimit_recordsimie_default
    ipaconfig_searchlimit_recordslimie_negative
    ipaconfig_searchlimit_envcleanup
} #ipaconfig_searchlimit

ipaconfig_server()
{
    ipaconfig_server_envsetup
    ipaconfig_server_enablemigration
    ipaconfig_server_enablemigration_negative
    ipaconfig_server_subject
    ipaconfig_server_subject_negative
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
        restore_ipaconfig
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
        rlLog "this is to test for defult behave"
        ipaconfig_show_default_logic
    rlPhaseEnd
} #ipaconfig_show_default

ipaconfig_show_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "test for --all option"
        local out=$TmpDir/ipaconfig.show.all.$RANDOM.out
        kinitAs $admin $adminpassword
        rlRun "ipa config-show --all > $out" 0 "save show --all in [$out]"
        string_exist_infile "Max username length:" $out
        string_exist_infile "Home directory base:" $out
        string_exist_infile "Default shell:" $out
        string_exist_infile "Default users group:" $out
        string_exist_infile "Default e-mail domain:" $out
        string_exist_infile "Search time limit:" $out
        string_exist_infile "Search size limit:" $out
        string_exist_infile "User search fields:" $out
        string_exist_infile "Group search fields:" $out
        string_exist_infile "Migration mode:" $out
        string_exist_infile "Certificate Subject base:" $out
        string_exist_infile "aci:" $out
        string_exist_infile "ipapwdexpadvnotify:" $out
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
        rlLog "this is to test for defult behave"
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
        rlLog "this is to test for default behave"
        # only do spot check for username length setting
        # assuming spot is randomly selected at 21
        # we will then check: 1, 20,21,22,255
        # so "spot" range would be : 3-255
        local max=$((config_username_maxlength - 2))
        #local spot=`getrandomint 3 $max`
        local spot=`getrandomint 3 31`
        #for len in 1 $spot $config_username_maxlength
        for len in 1 $spot 
        do
            #set the maxusername via ipa config-mod
            KinitAsAdmin
            rlRun "ipa config-mod --maxusername=$len" 0 "set maxusername to [$len]"
            clear_kticket
            ipaconfig_mod_maxusername_default_logic $len
        done
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
        expected=0
        for curlen in $username_length ; do
            username=`dataGenerator "username" $curlen`
            rlLog "test: len=[$curlen], username=[$username], expect success"
            create_ipauser $expected $username 
            delete_ipauser "$username"
        done

        local longer=$((length + 1))
        local username_length="$longer $config_username_maxlength"
        #when current username>defined, test should fail 
        expected=1
        for curlen in $username_length ; do
            username=`dataGenerator "username" $curlen`
            rlLog "test: len=[$curlen], username=[$username], expect fail"
            create_ipauser $expected $username
        done
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
        clear_kticket
    # test logic ends
} # ipaconfig_mod_maxusername_negative_logic 

ipaconfig_mod_homedirectory_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_homedirectory_default"
        rlLog "this is to test for default behave"
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
        clear_kticket
        rm $out
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
        rlLog "this is to test for default behave"
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
        clear_kticket
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
        rlLog "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_defaultshell_negative_logic 

ipaconfig_mod_defaultgroup_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultgroup_default"
        rlLog "this is to test for default behave"
        KinitAsAdmin
        local testgroup=`GenerateGroupName`
        rlRun "ipa config-mod --defaultgroup=\"$testgroup\" " 0 "set defaultgroup=[$testgroup]"
        ipaconfig_mod_defaultgroup_default_logic "$testgroup"
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
        ipa user-find $username > $out
        actualgroup=`grep "Groups" $out | cut -d":" -f2 | xargs echo`
        if echo $actualgroup | grep -i "^$basegroup" 2>&1 >/dev/null
        then
            rlPass "found [$basegroup] in actual:[$actualgroup]"
        else
            rlFail "actual [$actualgroup], expect [$basegroup]"
        fi
        clear_kticket
        rm $out
    # test logic ends
} # ipaconfig_mod_defaultgroup_default_logic 

ipaconfig_mod_defaultgroup_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultgroup_negative"
        rlLog "negative test case for defaultgroup"
        ipaconfig_mod_defaultgroup_negative_logic
    rlPhaseEnd
} #ipaconfig_mod_defaultgroup_negative

ipaconfig_mod_defaultgroup_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "FIXME : I haven't find any negative case yet"
    # test logic ends
} # ipaconfig_mod_defaultgroup_negative_logic 

ipaconfig_mod_emaildomain_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_emaildomain_default"
        rlLog "this is to test for default behave"
        KinitAsAdmin
        local testdomain=`GenerateDomainName`
        rlRun "ipa config-mod --emaildomain=$testdomain" 0 "set emaildomain=[$testdomain]"
        ipaconfig_mod_emaildomain_default_logic "$testdomain"
    rlPhaseEnd
} #ipaconfig_mod_emaildomain_default

ipaconfig_mod_emaildomain_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local basedomain=$1
        local out=$TmpDir/config.defaultdomain.$RANDOM.out
        username=`dataGenerator "username" 8` # FIXME: not sure length 8 is right to use -- since we changed maxusernamelength to something we don't know when we hit this test case
        #create_ipauser 0 $username "" "" "" "--email=${username}@${basedomain}"  #this is right version
        create_ipauser 0 $username "" "" "" "--email=${username}"
        KinitAsAdmin
        ipa user-find $username --raw --all > $out
        actualdomain=`grep "mail" $out | cut -d":" -f2 | xargs echo`
        if echo $actualdomain | grep -i "$basedomain" 2>&1 >/dev/null
        then
            rlPass "found [$basedomain] in actual:[$actualdomain]"
        else
            echo "============ out ============"
            cat $out
            echo "============================="
            rlFail "actual [$actualdomain], expect [$basedomain]"
        fi
        clear_kticket
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
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_emaildomain_negative_logic 

ipaconfig_searchlimit_envsetup()
{
    rlPhaseStartSetup "ipaconfig_searchlimit_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_searchlimit_envsetup

ipaconfig_searchlimit_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_searchlimit_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_searchlimit_envcleanup

ipaconfig_searchlimit_timelimie_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_timelimie_default"
        rlLog "this is to test for default behave"
        ipaconfig_searchlimit_timelimie_default_logic
    rlPhaseEnd
} #ipaconfig_searchlimit_timelimie_default

ipaconfig_searchlimit_timelimie_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_searchlimit_timelimie_default_logic 

ipaconfig_searchlimit_timelimie_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_timelimie_negative"
        rlLog "negative test case"
        ipaconfig_searchlimit_timelimie_negative_logic
    rlPhaseEnd
} #ipaconfig_searchlimit_timelimie_negative

ipaconfig_searchlimit_timelimie_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_searchlimit_timelimie_negative_logic 

ipaconfig_searchlimit_recordsimie_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_recordsimie_default"
        rlLog "this is to test for default behave"
        ipaconfig_searchlimit_recordsimie_default_logic
    rlPhaseEnd
} #ipaconfig_searchlimit_recordsimie_default

ipaconfig_searchlimit_recordsimie_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_searchlimit_recordsimie_default_logic 

ipaconfig_searchlimit_recordslimie_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchlimit_recordslimie_negative"
        rlLog "negative test case"
        ipaconfig_searchlimit_recordslimie_negative_logic
    rlPhaseEnd
} #ipaconfig_searchlimit_recordslimie_negative

ipaconfig_searchlimit_recordslimie_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_searchlimit_recordslimie_negative_logic 

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
        rlLog "this is to test for default behave"
        out=$TmpDir/ipaconfig.enablemigration.$RANDOM.out
        KinitAsAdmin
        for value in FALSE True False True false true
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
        rm $out
    rlPhaseEnd
} #ipaconfig_server_enablemigration

ipaconfig_server_enablemigration_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_server_enablemigration_logic 

ipaconfig_server_enablemigration_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_server_enablemigration_negative"
        rlLog "negative test case"
        for value in T F a 0 -1 
        do
            rlRun "ipa config-mod --enable-migration=$value" 1 "set migration mode to [$value] should fail"
        done
    rlPhaseEnd
} #ipaconfig_server_enablemigration_negative

ipaconfig_server_enablemigration_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_server_enablemigration_negative_logic 

ipaconfig_server_subject()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_server_subject"
        rlLog "this is to test for default behave"
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
        rlFail "EMPTY LOGIC"
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
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_server_subject_negative_logic 
