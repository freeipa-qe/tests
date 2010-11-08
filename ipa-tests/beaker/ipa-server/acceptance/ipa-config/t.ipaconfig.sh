
######################
# test suite         #
######################
ipaconfig()
{
    ipaconfig_envsetup
    ipaconfig_show
    ipaconfig_mod
    ipaconfig_searchtimelimit
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
    ipaconfig_mod_envcleanup
} #ipaconfig_mod

ipaconfig_searchtimelimit()
{
    ipaconfig_searchtimelimit_envsetup
    ipaconfig_searchtimelimit_timelimie_default
    ipaconfig_searchtimelimit_timelimie_negative
    ipaconfig_searchtimelimit_envcleanup
} #ipaconfig_searchtimelimit

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

        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_envsetup

ipaconfig_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_envcleanup

ipaconfig_show_envsetup()
{
    rlPhaseStartSetup "ipaconfig_show_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_show_envsetup

ipaconfig_show_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_show_envcleanup"
        #environment cleanup starts here

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
        rlFail "EMPTY LOGIC"
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
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_show_negative_logic 

ipaconfig_mod_envsetup()
{
    rlPhaseStartSetup "ipaconfig_mod_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_mod_envsetup

ipaconfig_mod_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_mod_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_mod_envcleanup

ipaconfig_mod_maxusername_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_mod_maxusername_default"
        rlLog "this is to test for default behave"
        ipaconfig_mod_maxusername_default_logic
    rlPhaseEnd
} #ipaconfig_mod_maxusername_default

ipaconfig_mod_maxusername_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
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

ipaconfig_searchtimelimit_envsetup()
{
    rlPhaseStartSetup "ipaconfig_searchtimelimit_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipaconfig_searchtimelimit_envsetup

ipaconfig_searchtimelimit_envcleanup()
{
    rlPhaseStartCleanup "ipaconfig_searchtimelimit_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipaconfig_searchtimelimit_envcleanup

ipaconfig_searchtimelimit_timelimie_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchtimelimit_timelimie_default"
        rlLog "this is to test for default behave"
        ipaconfig_searchtimelimit_timelimie_default_logic
    rlPhaseEnd
} #ipaconfig_searchtimelimit_timelimie_default

ipaconfig_searchtimelimit_timelimie_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_searchtimelimit_timelimie_default_logic 

ipaconfig_searchtimelimit_timelimie_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipaconfig_searchtimelimit_timelimie_negative"
        rlLog "negative test case"
        ipaconfig_searchtimelimit_timelimie_negative_logic
    rlPhaseEnd
} #ipaconfig_searchtimelimit_timelimie_negative

ipaconfig_searchtimelimit_timelimie_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipaconfig_searchtimelimit_timelimie_negative_logic 

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
