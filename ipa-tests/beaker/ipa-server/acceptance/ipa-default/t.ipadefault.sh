
######################
# test suite         #
######################
ipadefault()
{
    ipadefault_envsetup
    ipadefault_pwpolicy
    ipadefault_config
    ipadefault_krbtpolicy
    ipadefault_envcleanup
} # ipadefault

######################
# test set           #
######################
ipadefault_pwpolicy()
{
    ipadefault_pwpolicy_envsetup
    ipadefault_pwpolicy_all
    ipadefault_pwpolicy_envcleanup
} #ipadefault_pwpolicy

######################
# test set           #
######################
ipadefault_config()
{
    ipadefault_config_envsetup
    ipadefault_config_all
    ipadefault_config_envcleanup
} #ipadefault_config

######################
# test set           #
######################
ipadefault_krbtpolicy()
{
    ipadefault_krbt_envsetup
    ipadefault_krbt_all
    ipadefault_krbt_envcleanup
} #ipadefault_krbt

######################
# test cases         #
######################
ipadefault_envsetup()
{
    rlPhaseStartSetup "ipadefault_envsetup"
        #environment setup starts here
        rlPass "tmpdir=[$TmpDir] no other special environment setup required, use all default setting"
        #environment setup ends   here
    rlPhaseEnd
} #ipadefault_envsetup

ipadefault_envcleanup()
{
    rlPhaseStartCleanup "ipadefault_envcleanup"
        #environment cleanup starts here
        rlPass "no special environment cleanup required, use all default setting"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipadefault_envcleanup

ipadefault_pwpolicy_envsetup()
{
    rlPhaseStartSetup "ipadefault_pwpolicy_envsetup"
        #environment setup starts here
        rlPass "no special environment setup required, use all default setting"
        #environment setup ends   here
    rlPhaseEnd
} #ipadefault_pwpolicy_envsetup

ipadefault_pwpolicy_envcleanup()
{
    rlPhaseStartCleanup "ipadefault_pwpolicy_envcleanup"
        #environment cleanup starts here
        rlPass "no special environment cleanup required, use all default setting"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipadefault_pwpolicy_envcleanup

ipadefault_pwpolicy_all()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipa-config-default-001: Password Policy"
        rlLog "check the default settings for global password policy"
        ipadefault_pwpolicy_all_logic
    rlPhaseEnd
} #ipadefault_pwpolicy_all

ipadefault_pwpolicy_all_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/defaultvalues.$RANDOM.txt
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa pwpolicy-show > $out" 0 "read global password policy"
        maxlife=`grep "Max lifetime" $out | cut -d":" -f2 | xargs echo` # unit is in day
        minlife=`grep "Min lifetime" $out | cut -d":" -f2 | xargs echo` # unit is in hour
        history=`grep "History size" $out | cut -d":" -f2 | xargs echo`
        classes=`grep "Character classes" $out | cut -d":" -f2 | xargs echo`
        length=`grep "Min length" $out | cut -d":" -f2 | xargs echo`
	maxfail=`grep "Max failures" $out | cut -d":" -f2 | xargs echo`
	resetint=`grep "Failure reset interval" $out | cut -d":" -f2 | xargs echo`
	locktime=`grep "Lockout duration" $out | cut -d":" -f2 | xargs echo`

        if [ $maxlife = $default_pw_maxlife ];then
            rlPass "password policy maxlife matches [$maxlife]"
        else
            rlFail "password policy maxlife does not match, expect [$default_pw_maxlife], actual [$maxlife]"
        fi

        if [ $minlife = $default_pw_minlife ];then
            rlPass "password policy minlife matches [$minlife]"
        else
            rlFail "password policy minlife does not match, expect [$default_pw_minlife], actual [$minlife]"
        fi

        if [ $history = $default_pw_history ];then
            rlPass "password policy history matches [$history]"
        else
            rlFail "password policy history does not match, expect [$default_pw_history], actual [$history]"
        fi

        if [ $classes = $default_pw_classes ];then
            rlPass "password policy min classes matches [$classes]"
        else
            rlFail "password policy min classes does not match, expect [$default_pw_classes], actual [$classes]"
        fi

        if [ $length = $default_pw_length ];then
            rlPass "password policy min length matches [$length]"
        else
            rlFail "password policy min length does not match, expect [$default_pw_length], actual [$length]"
        fi

        if [ $maxfail = $default_max_fail ];then
            rlPass "password policy max failures matches [$maxfail]"
        else
            rlFail "password policy max failures does not match, expect [$default_max_fail], actual [$maxfail]"
        fi

        if [ $resetint = $default_reset_interval ];then
            rlPass "password policy failure reset interval matches [$resetint]"
        else
            rlFail "password policy failure reset interval does not match, expect [$default_reset_interval], actual [$resetint]"
        fi

        if [ $locktime = $default_lockout_time ];then
            rlPass "password policy lockout duration matches [$locktime]"
        else
            rlFail "password policy lockout does not match, expect [$default_lockout_time], actual [$locktime]"
        fi

        rm $out
    # test logic ends
} # ipadefault_pwpolicy_all_logic 

ipadefault_config_envsetup()
{
    rlPhaseStartSetup "ipadefault_config_envsetup"
        #environment setup starts here
        rlPass "no special environment setup required, use all default setting"
        #environment setup ends   here
    rlPhaseEnd
} #ipadefault_config_envsetup

ipadefault_config_envcleanup()
{
    rlPhaseStartCleanup "ipadefault_config_envcleanup"
        #environment cleanup starts here
        rlPass "no special environment cleanup required, use all default setting"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipadefault_config_envcleanup

ipadefault_config_all()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipa-config-default-002: General Server Configuration"
        rlLog "check the default settings for general ipa server configuration"
        ipadefault_config_all_logic
    rlPhaseEnd
} #ipadefault_config_all

ipadefault_config_all_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/defaultvalues.$RANDOM.txt
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa config-show > $out" 0 "store config-show in [$out]"
        usernamelength=`grep "Maximum username length" $out | cut -d":" -f2| xargs echo`
        ipacompare "default maximum user name length" "$default_config_usernamelength" "$usernamelength"

        homebase=`grep "Home directory base" $out | cut -d":" -f2| xargs echo`
        ipacompare "default home base" "$default_config_homebase" "$homebase"
       
        defaultshell=`grep "Default shell" $out | cut -d":" -f2| xargs echo`
        ipacompare "default shell" "$default_config_shell" "$defaultshell"

        usersgroup=`grep "Default users group" $out | cut -d":" -f2| xargs echo`
        ipacompare "Default users group" "$default_config_usergroup" "$usersgroup"

        searchtimelimit=`grep "Search time limit" $out | cut -d":" -f2| xargs echo`
        ipacompare "search time limit" "$default_config_timelimit" "$searchtimelimit"

        searchsizelimit=`grep "Search size limit" $out | cut -d":" -f2| xargs echo`
        ipacompare "search size limit" "$default_config_sizelimit" "$searchsizelimit"

        usersearchfields=`grep "User search fields" $out | cut -d":" -f2| xargs echo`
        ipacompare "user search fields" "$default_config_usersearchfields" "$usersearchfields"

        groupsearchfields=`grep "Group search fields" $out | cut -d":" -f2| xargs echo`
        ipacompare "group search fields" "$default_config_groupsearchfields" "$groupsearchfields"

        migrationmode=`grep "Enable migration mode"  $out | cut -d":" -f2| xargs echo`
        ipacompare "migration mode" "$default_config_migrationmode" "$migrationmode"

        certsubjectbase=`grep "Certificate Subject base" $out | cut -d":" -f2| xargs echo`
        ipacompare "cert subject base" "$default_config_certsubjectbase" "$certsubjectbase"

        selinuxmaporder=`grep "SELinux user map order" $out | cut -d" " -f7| xargs echo`
        ipacompare "selinux user map order" "$default_config_selinuxmaporder" "$selinuxmaporder"

        selinuxuser=`grep "Default SELinux user" $out | cut -d" " -f6| xargs echo`
        ipacompare "default selinux user context" "$default_config_selinuxuser" "$selinuxuser"

        pactype=`grep "Default PAC types" $out | cut -d":" -f2| xargs echo`
        ipacompare "pac type" "$default_config_pactype" "$pactype"

        rm $out
    # test logic ends
} # ipadefault_config_all_logic 

#######################################################################

ipadefault_krbt_envsetup()
{
    rlPhaseStartSetup "ipadefault_krbt_envsetup"
        #environment setup starts here
        rlPass "no special environment setup required, use all default setting"
        #environment setup ends   here
    rlPhaseEnd
} #ipadefault_krbt_envsetup

ipadefault_krbt_envcleanup()
{
    rlPhaseStartCleanup "ipadefault_krbt_envcleanup"
        #environment cleanup starts here
        rlPass "no special environment cleanup required, use all default setting"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipadefault_krbt_envcleanup

ipadefault_krbt_all()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipa-config-default-003: Keberos Ticket Policy"
        rlLog "check the default settings for general ipa server krbt policy setting"
        ipadefault_krbt_all_logic
    rlPhaseEnd
} #ipadefault_krbt_all

ipadefault_krbt_all_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/defaultvalues.$RANDOM.txt
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa krbtpolicy-show > $out" 0 "store krbtpolicy-show in [$out]"

        maxlife=`grep "Max life" $out | cut -d":" -f2| xargs echo`
        maxrenew=`grep "Max renew" $out | cut -d":" -f2 | xargs echo`

        ipacompare "max kerberos ticket life" "$default_krbtpolicy_maxlife" "$maxlife"
        ipacompare "max kerberos renew ticket life" "$default_krbtpolicy_maxrenew" "$maxrenew"
        rm $out
    # test logic ends
} # ipadefault_krbt_all_logic 
