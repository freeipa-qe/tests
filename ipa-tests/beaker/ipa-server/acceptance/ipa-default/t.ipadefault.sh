
######################
# test suite         #
######################
ipadefault()
{
    ipadefault_envsetup
    ipadefault_pwpolicy
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
# test cases         #
######################
ipadefault_envsetup()
{
    rlPhaseStartSetup "ipadefault_envsetup"
        #environment setup starts here
#        if [ ! -d $tmpdir ];then
#            rlPass "mkdir -p $tmpdir" 0 "create tmp dir"
#        else
#            rlPass "tmpdir=[$tmpdir] no other special environment setup required, use all default setting"
#        fi
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
    rlPhaseStartTest "ipadefault_pwpolicy_all"
        rlLog "check the default settings for global password policy"
        ipadefault_pwpolicy_all_logic
    rlPhaseEnd
} #ipadefault_pwpolicy_all

ipadefault_pwpolicy_all_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/defaultvalues.$RANDOM.txt
        kinitAs $admin $adminpassword
        rlRun "ipa pwpolicy-show > $out" 0 "read global password policy"
        maxlife=`grep "Max lifetime" $out | cut -d":" -f2 | xargs echo` # unit is in day
        minlife=`grep "Min lifetime" $out | cut -d":" -f2 | xargs echo` # unit is in hour
        history=`grep "History size" $out | cut -d":" -f2 | xargs echo`
        classes=`grep "Character classes" $out | cut -d":" -f2 | xargs echo`
        length=`grep "Min length" $out | cut -d":" -f2 | xargs echo`
        if [ $maxlife = $default_pw_maxlife ];then
            rlPass "password policy maxlife maches [$maxlife]"
        else
            rlFail "password policy maxlife does not match, expect [$default_pw_maxlife], actual [$maxlife]"
        fi

        if [ $minlife = $default_pw_minlife ];then
            rlPass "password policy minlife maches [$minlife]"
        else
            rlFail "password policy minlife does not match, expect [$default_pw_minlife], actual [$minlife]"
        fi

        if [ $history = $default_pw_history ];then
            rlPass "password policy history maches [$history]"
        else
            rlFail "password policy history does not match, expect [$default_pw_history], actual [$history]"
        fi

        if [ $classes = $default_pw_classes ];then
            rlPass "password policy min classes maches [$classes]"
        else
            rlFail "password policy min classes does not match, expect [$default_pw_classes], actual [$classes]"
        fi

        if [ $length = $default_pw_length ];then
            rlPass "password policy min length maches [$length]"
        else
            rlFail "password policy min length does not match, expect [$default_pw_length], actual [$length]"
        fi

        rm $out
    # test logic ends
} # ipadefault_pwpolicy_all_logic 
