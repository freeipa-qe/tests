
######################
# test suite         #
######################
ipaconfig()
{
    ipaconfig_envsetup
#    ipaconfig_show
    ipaconfig_mod
#    ipaconfig_searchlimit
#    ipaconfig_server
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
        rlPass "no special env cleanup required"
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
        KinitAsAdmin
        definedlength=`getrandomint 1 255`
        rlRun "ipa config-mod --maxusername=$definedlength" 0 "set maxusername to [$definedlength]"
        clear_kticket

        curlen=1 
        #when current username<defined, test should pass
        expected=0
        while [ "$curlen" -le "$definedlength" ];do
            username=`dataGenerator "username" $curlen`
            lastname=`dataGenerator "lastname" $curlen`
            firstname=`dataGenerator "firstname" $curlen`
            password=`dataGenerator "password" 8`
            rlLog "test: len=[$curlen], username=[$username], expect success"
            create_ipauser $expected $username $firstname $lastname $password
            delete_ipauser "$username"
            curlen=$((curlen+1))
        done

        #when current username>defined, test should fail 
        offset=`getrandomint 20 100`
        upperedge=$((definedlength + offset))
        loweredge=$((definedlength + 1))
        expected=1
        i=0
        totaltest=5 #lets just test 5 times
        while [ "$i" -lt "$totaltest" ];do
            newlen=`getrandomint $loweredge $upperedge`
            username=`dataGenerator "username" $newlen`
            lastname=`dataGenerator "lastname" $newlen`
            firstname=`dataGenerator "firstname" $newlen`
            password=`dataGenerator "password" 8`
            rlLog "test: len=[$newlen], username=[$username], expect fail"
            create_ipauser $expected $username $firstname $lastname $password
            i=$((i+1))
        done
        clear_kticket
    rlPhaseEnd
} #ipaconfig_mod_maxusername_default

ipaconfig_mod_maxusername_default_logic()
{
    # accept parameters: length 
    # test logic starts
        local expected=$1
        local length=$2
        local username=$3
        local lastname=$4
        local firstname=$5
        local password=$6
        local out=$TmpDir/config.maxusername.default.$RANDOM.out

        create_ipauser $expected $username $firstname $lastname $password
        rm $out
    # test logic ends
} # ipaconfig_mod_maxusername_default_logic 

ipaconfig_mod_maxusername_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_maxusername_negative"
        rlLog "negative test case for maxusername"
        ipaconfig_mod_maxusername_negative_logic
    rlPhaseEnd
} #ipaconfig_mod_maxusername_negative

ipaconfig_mod_maxusername_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_maxusername_negative_logic 

ipaconfig_mod_homedirectory_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_homedirectory_default"
        rlLog "this is to test for default behave"
        ipaconfig_mod_homedirectory_default_logic
    rlPhaseEnd
} #ipaconfig_mod_homedirectory_default

ipaconfig_mod_homedirectory_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_homedirectory_default_logic 

ipaconfig_mod_homedirectory_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_homedirectory_negative"
        rlLog "negative test case for homedirectory"
        ipaconfig_mod_homedirectory_negative_logic
    rlPhaseEnd
} #ipaconfig_mod_homedirectory_negative

ipaconfig_mod_homedirectory_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_homedirectory_negative_logic 

ipaconfig_mod_defaultshell_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultshell_default"
        rlLog "this is to test for default behave"
        ipaconfig_mod_defaultshell_default_logic
    rlPhaseEnd
} #ipaconfig_mod_defaultshell_default

ipaconfig_mod_defaultshell_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_defaultshell_default_logic 

ipaconfig_mod_defaultshell_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultshell_negative"
        rlLog "negative test case for defaultshell"
        ipaconfig_mod_defaultshell_negative_logic
    rlPhaseEnd
} #ipaconfig_mod_defaultshell_negative

ipaconfig_mod_defaultshell_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_defaultshell_negative_logic 

ipaconfig_mod_defaultgroup_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_defaultgroup_default"
        rlLog "this is to test for default behave"
        ipaconfig_mod_defaultgroup_default_logic
    rlPhaseEnd
} #ipaconfig_mod_defaultgroup_default

ipaconfig_mod_defaultgroup_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
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
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_mod_defaultgroup_negative_logic 

ipaconfig_mod_emaildomain_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_emaildomain_default"
        rlLog "this is to test for default behave"
        ipaconfig_mod_emaildomain_default_logic
    rlPhaseEnd
} #ipaconfig_mod_emaildomain_default

ipaconfig_mod_emaildomain_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
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
        ipaconfig_server_enablemigration_logic
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
        ipaconfig_server_enablemigration_negative_logic
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
        ipaconfig_server_subject_logic
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
        ipaconfig_server_subject_negative_logic
    rlPhaseEnd
} #ipaconfig_server_subject_negative

ipaconfig_server_subject_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_server_subject_negative_logic 
