
######################
# test suite         #
######################
ipapassword()
{
    ipapassword_envsetup
    ipapassword_globalpolicy
#    ipapassword_grouppolicy
#    ipapassword_globalandgroup
#    ipapassword_nestedgroup
    ipapassword_envcleanup
} # ipapassword

######################
# test set           #
######################
ipapassword_globalpolicy()
{
    ipapassword_globalpolicy_envsetup
#    ipapassword_globalpolicy_maxlifetime_default
#    ipapassword_globalpolicy_maxlifetime_lowerbound
#    ipapassword_globalpolicy_maxlifetime_upperbound
#    ipapassword_globalpolicy_maxlifetime_negative
#    ipapassword_globalpolicy_minlifetime_default
#    ipapassword_globalpolicy_minlifetime_lowerbound
#    ipapassword_globalpolicy_minlifetime_upperbound
#    ipapassword_globalpolicy_minlifetime_negative
    ipapassword_globalpolicy_history_default
    ipapassword_globalpolicy_history_lowerbound
    ipapassword_globalpolicy_history_upperbound
    ipapassword_globalpolicy_history_negative
#    ipapassword_globalpolicy_classes_default
#    ipapassword_globalpolicy_classes_lowerbound
#    ipapassword_globalpolicy_classes_upperbound
#    ipapassword_globalpolicy_classes_negative
#    ipapassword_globalpolicy_length_default
#    ipapassword_globalpolicy_length_lowerbound
#    ipapassword_globalpolicy_length_upperbound
#    ipapassword_globalpolicy_length_negative
    ipapassword_globalpolicy_envcleanup
} #ipapassword_globalpolicy

ipapassword_grouppolicy()
{
    ipapassword_grouppolicy_envsetup
    ipapassword_grouppolicy_maxlifetime_default
    ipapassword_grouppolicy_maxlifetime_lowerbound
    ipapassword_grouppolicy_maxlifetime_upperbound
    ipapassword_grouppolicy_maxlifetime_negative
    ipapassword_grouppolicy_minlifetime_default
    ipapassword_grouppolicy_minlifetime_lowerbound
    ipapassword_grouppolicy_minlifetime_upperbound
    ipapassword_grouppolicy_minlifetime_negative
    ipapassword_grouppolicy_history_default
    ipapassword_grouppolicy_history_lowerbound
    ipapassword_grouppolicy_history_upperbound
    ipapassword_grouppolicy_history_negative
    ipapassword_grouppolicy_classes_default
    ipapassword_grouppolicy_classes_lowerbound
    ipapassword_grouppolicy_classes_upperbound
    ipapassword_grouppolicy_classes_negative
    ipapassword_grouppolicy_length_default
    ipapassword_grouppolicy_length_lowerbound
    ipapassword_grouppolicy_length_upperbound
    ipapassword_grouppolicy_length_negative
    ipapassword_grouppolicy_envcleanup
} #ipapassword_grouppolicy

ipapassword_globalandgroup()
{
    ipapassword_globalandgroup_envsetup
    ipapassword_globalandgroup_maxlife_conflict
    ipapassword_globalandgroup_minlife_conflict
    ipapassword_globalandgroup_history_conflict
    ipapassword_globalandgroup_classes_conflict
    ipapassword_globalandgroup_length_conflict
    ipapassword_globalandgroup_envcleanup
} #ipapassword_globalandgroup

ipapassword_nestedgroup()
{
    ipapassword_nestedgroup_envsetup
    ipapassword_nestedgroup_maxlife_conflict
    ipapassword_nestedgroup_minlife_conflict
    ipapassword_nestedgroup_history_conflict
    ipapassword_nestedgroup_classes_conflict
    ipapassword_nestedgroup_length_conflict
    ipapassword_nestedgroup_envcleanup
} #ipapassword_nestedgroup

######################
# test cases         #
######################
ipapassword_envsetup()
{
    rlPhaseStartSetup "ipapassword_envsetup"
        #environment setup starts here
        restore_systime  # sync system time with ntp server
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_envsetup

ipapassword_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_envcleanup"
        #environment cleanup starts here
        restore_systime
        restart_ipa_passwd
        rlRun "$kdestroy" 0 "clean all possible kerberos ticket"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_envcleanup

ipapassword_globalpolicy_envsetup()
{
    rlPhaseStartSetup "ipapassword_globalpolicy_envsetup"
        #environment setup starts here
        restore_systime
        reset_global_pwpolicy   # ensure we have defaul setting when we leave
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_globalpolicy_envsetup

ipapassword_globalpolicy_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_globalpolicy_envcleanup"
        #environment cleanup starts here
        restore_systime
        restart_ipa_passwd
        reset_global_pwpolicy
        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_globalpolicy_envcleanup

ipapassword_globalpolicy_maxlifetime_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_maxlifetime_default"
        add_test_ac
        rlLog "default maxlife : [$default_maxlife]"        
        rlLog "default minlife : [$default_minlife]"        
        rlLog "maxlife: when reached, ipa shold prompt for password change"
        ipapassword_globalpolicy_maxlifetime_default_logic
        delete_test_ac
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_default

ipapassword_globalpolicy_maxlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        # when minlife < system time < maxlife, user kinit should success, no prompt for password change
        maxlife=`echo "$default_maxlife * 24 * 60 * 60 " |bc `
        minlife=`echo "$default_minlife * 60 * 60 " |bc`
        midpoint=`echo "($minlife + $maxlife)/2" |bc` 
        rlLog "mid point: [$midpoint]"
        set_systime "+ $midpoint"
        rlRun "$kdestroy"
        rlRun "echo $testacPW | kinit $testacLogin" 0 "kinit as same password between minlife and max life should success"

        # when system time > maxlife, ipa server should prompt for password change
        set_systime "+ $midpoint + 60"  # set system time after the max life
        rlRun "$kdestroy"
        kinit_aftermaxlife $testacLogin $testacPW $testacNEWPW

    # test logic ends
} # ipapassword_globalpolicy_maxlifetime_default_logic 

ipapassword_globalpolicy_maxlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_maxlifetime_lowerbound"
        add_test_ac
        rlLog "lowerbound of maxlife is the minlife"
        ipapassword_globalpolicy_maxlifetime_lowerbound_logic
        delete_test_ac
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_lowerbound

ipapassword_globalpolicy_maxlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        # since maxlife use day as unit, then we need set minlife to 2 days to test maxlife's lowerbound
        out=$TmpDir/maxlifelowerbound.$RANDOM.out
        KinitAsAdmin

        rlRun "ipa pwpolicy-mod --minlife=48" #set minlife to 2 days (48 hours)
        rlRun "ipa pwpolicy-mod --maxlife=1" 1 "expect to fail since maxlife has to >= minlife"
        rlRun "ipa pwpolicy-mod --maxlife=2" 0 "expect to success since maxlife could = minlife"
    # test logic ends
} # ipapassword_globalpolicy_maxlifetime_lowerbound_logic 

ipapassword_globalpolicy_maxlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_maxlifetime_upperbound"
        add_test_ac
        ipapassword_globalpolicy_maxlifetime_upperbound_logic
        delete_test_ac
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_upperbound

ipapassword_globalpolicy_maxlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "the upper bound of maxlife is the max int it can takes"
        KinitAsAdmin
        for v in 100 1000 9999 99999
        do
            rlRun "ipa pwpolicy-mod --maxlife=$v" \
                   0 "set value to [$v], expect to pass"
        done

    # test logic ends
} # ipapassword_globalpolicy_maxlifetime_upperbound_logic 

ipapassword_globalpolicy_maxlifetime_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_maxlifetime_negative"
        rlLog "maxlife can not be non-interget value"
        KinitAsAdmin 
        rlRun "ipa pwpolicy-mod --minlife=0" 0 "set minlife to 0"
        for maxlife_value in -2 -1 a abc
        do
            ipapassword_globalpolicy_maxlifetime_negative_logic $maxlife_value
        done
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_negative

ipapassword_globalpolicy_maxlifetime_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlRun "ipa pwpolicy-mod --maxlife=$1" 1 "expect to fail for maxlife=[$1]"
    # test logic ends
} # ipapassword_globalpolicy_maxlifetime_negative_logic 

ipapassword_globalpolicy_minlifetime_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_default"
        rlLog "default maxlife : [$default_maxlife]"        
        rlLog "default minlife : [$default_minlife]"        
        rlLog "minlife: when not reached, user can not change password"
        ipapassword_globalpolicy_minlifetime_default_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_minlifetime_default

ipapassword_globalpolicy_minlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$default_maxlife --history=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "set preconditoin: history=[$history] minlength=[$length] classes=[$classes]"
        if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            life=2 #set minlife to 2 hours
            ipa pwpolicy-mod --minlife=$life
            life=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2 |xargs echo` # confirm the minlife setting
            rlLog "minlife has been setting to [$life] hours"
            add_test_ac
            rlLog "set system time 2 minute before minlife"
            set_systime "+ 2*60*60 - 2*60"
            # before minlife, change password should fail
            rlRun "echo $testacPW | kinit $testacLogin" 0 "kinit should success and ipa will NOT prompt for password change"
            change_password $testacLogin $testacPW "dummy123"
            if [ $? = 0 ];then
                rlFail "password change success, this is not expected"
            else 
                rlPass "password change failed as expected"
            fi

            # after minlife, change passwod should success
            set_systime "+ 2*60"  # setsystime 2 minutes after
            change_password $testacLogin $testacPW "dummy123"
            if [ $? = 0 ];then
                rlPass "password change success, this is expected"
            else
                rlFail "password change failed is not expected"
            fi
            delete_test_ac
        else
            rlFail "can not set pre-condition"
        fi
    # test logic ends
} # ipapassword_globalpolicy_minlifetime_default_logic 

ipapassword_globalpolicy_minlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_lowerbound"
        ipapassword_globalpolicy_minlifetime_lowerbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_minlifetime_lowerbound

ipapassword_globalpolicy_minlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local lowbound=0
        local out=$TmpDir/minlifelowbound.$RANDOM.out
        rlLog "The lower bound of minlife time is [$lowbound]"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$default_maxlife --history=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "set preconditoin: history=[$history] minlength=[$length] classes=[$classes]"
        if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            rlRun "ipa pwpolicy-mod --minlife=$lowbound" 0 "set to lowbound should success"
            rlLog "minlife has been setting to [$lowbound] hours"
            add_test_ac
            rlLog "after set minlife to 0, we should be able to change password anytime we wont"
            oldpw=$testacPW
            newpw="dummy123"
            #FIXME: I should have more test data right here
            # be aware that after this loop the system time is actually being
            # pushed back total: 0+1+2+4+8+16+32=63 seconds
            for offset in 0 1 2 4 8 16 32
            do
                set_systime "+ $offset"
                change_password $testacLogin $oldpw $newpw
                if [ $? = 0 ];then
                    rlPass "password change success, this is expected"
                    #swap the password
                    tmp=$oldpw
                    oldpw=$newpw
                    newpw=$tmp 
                else
                    rlFail "password change failed is not expected"
                fi
            done
            delete_test_ac
        else
            rlFail "can not set pre-condition for minlife lowbound test"
        fi
        rm $out
    # test logic ends
} # ipapassword_globalpolicy_minlifetime_lowerbound_logic 

ipapassword_globalpolicy_minlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_upperbound"
        rlLog "upper bound of minlife is maxlife, we have tested already"
        rlLog "default maxlife : [$default_maxlife]"        
        rlLog "default minlife : [$default_minlife]"        
        ipapassword_globalpolicy_minlifetime_upperbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_minlifetime_upperbound

ipapassword_globalpolicy_minlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "reset global pwpolicy"
        reset_global_pwpolicy
        maxlife=`echo "$default_maxlife * 24 " | bc`
        counter=0
        previousvalue=$default_minlife
        while [ $counter -lt 10 ]
        do
            number=$RANDOM
            let "number %= $maxlife"
            #minlife=`echo "$number / 60 / 60" | bc` # convert to hours
            minlife=$number
            if [ $minlife -ne $previousvalue ]
            then
                rlRun "ipa pwpolicy-mod --minlife=$minlife" \
                0 "test:[$counter] set min to [$minlife] (hours) while maxlife =[$default_maxlife] (days)is allowed"
                counter=$((counter+1))
                previousvalue=$minlife
            fi
        done
    # test logic ends
} # ipapassword_globalpolicy_minlifetime_upperbound_logic 

ipapassword_globalpolicy_minlifetime_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_negative"
        rlLog "minlife should only accept integer >=0"
        KinitAsAdmin
        reset_global_pwpolicy
        for minlife_value in -2 -1 a abc 
        do
            ipapassword_globalpolicy_minlifetime_negative_logic $minlife_value
        done
    rlPhaseEnd
} #ipapassword_globalpolicy_minlifetime_negative

ipapassword_globalpolicy_minlifetime_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local minvalue=$1
        rlRun "ipa pwpolicy-mod --minlife=$minvalue" \
              1 "set minlife to [$minvalue] should fail"
    # test logic ends
} # ipapassword_globalpolicy_minlifetime_negative_logic 

ipapassword_globalpolicy_history_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_history_default"
        rlLog "default behave of history setting test"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$default_maxlife --minlife=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] classes=[$classes]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            add_test_ac
            ipapassword_globalpolicy_history_default_logic
            delete_test_ac
        else
            rlFail "can not set precondition for history test"
        fi

    rlPhaseEnd
} #ipapassword_globalpolicy_history_default

ipapassword_globalpolicy_history_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        # set history to N, then N history password can not be used
        number=$RANDOM
        let "number %= 20"
        N=`echo "$number + 2" | bc` # set N >= 2
        pws="$testacPW"
        counter=1 #reset counter
        KinitAsAdmin 
        rlRun "ipa pwpolicy-mod --history=$N" 0 "set password history to [$N]"
        while [ $counter -lt $N ]
        do
            pw="${counter}_${testacPW}"
            pws="$pws $pw"
            counter=$((counter+1))
        done
        rlLog "password pool: [$pws]"
        # now we start to change password, the all expected to fail
        rlRun "$kdestroy"
        kinitAs $testacLogin $testacPW
        counter=1 #reset counter
        while [ $counter -lt $N ]
        do
            next=$((counter+1))
            currentPW=`echo $pws | cut -d" " -f$counter`
            nextPW=`echo $pws |cut -d" " -f$next`
            rlLog "counter=[$counter] currentpw[$currentPW], nextpw[$nextPW]"
            change_password $testacLogin $currentPW $nextPW
            if [ $? = 0 ];then
                rlPass "password change success, current working password [$nextPW]"
            else
                rlFail "set password to [$nextPW] failed isnot expected"
                break
            fi
            counter=$((counter+1))
        done
        # since we just build a history of password, new try to reuse passwod
        # at this point, the current pw is nextPW in last loop
        currentPW=$nextPW
        rlLog "current working pw [$currentPW] password pool: [$pws]"
        for p in $pws
        do
            rlLog "testpw=[$p]"
            change_password $testacLogin $currentPW $p
            if [ $? = 0 ];then
                rlFail "password [$p] reuse success is not expected"
            else
                rlPass "password [$p] reuse failed is expected"
            fi
        done
    # test logic ends
} # ipapassword_globalpolicy_history_default_logic 

ipapassword_globalpolicy_history_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_history_lowerbound"
        lowbound=0
        rlLog "lowerbound of password history is $lowbound"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$default_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] classes=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ] \
            && [ $history = 0 ]
        then
            add_test_ac
            ipapassword_globalpolicy_history_lowerbound_logic
            delete_test_ac
        else
            rlFail "can not set precondition for history test"
        fi

    rlPhaseEnd
} #ipapassword_globalpolicy_history_lowerbound

ipapassword_globalpolicy_history_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        # when history=0, user can reuse their password as many as they want
        # please note that change password to current working password
        # does not allowed by the nature of kerberos. so history=0 means
        # you can actually switch between 2 passwords
        rlRun "$kdestroy"
        kinitAs $testacLogin $testacPW
        number=$RANDOM
        let "number %= 10"
        N=`echo "$number + 2" | bc` # set N >= 2
        counter=0
        currentpw=$testacPW
        newpw="dummy123"
        rlLog "keep change password [$N] times with two password:[$currentpw] & [$newpw]"
        while [ $counter -lt $N ] #password is $oldpw when out of this loop
        do
            change_password $testacLogin $currentpw $newpw
            if [ $? = 0 ];then
                rlPass "[$counter] change success, current password [$newpw]"
                #swap the password
                tmp=$currentpw
                currentpw=$newpw
                newpw=$tmp 
            else
                rlFail "[$counter] password change failed"
            fi
            counter=$((counter+1))
        done
    # test logic ends
} # ipapassword_globalpolicy_history_lowerbound_logic 

ipapassword_globalpolicy_history_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_history_upperbound"
        rlLog "there is no real upperbound, just try some randam integers"
        lastvalue=$RANDOM
        max=20 #test 20 times
        i=0
        KinitAsAdmin 
        while [ $i -lt $max ]
        do 
            size=$RANDOM
            if [ $size -ne $lastvalue ]; then
                ipapassword_globalpolicy_history_upperbound_logic $size
            fi
            lastvalue=$size
            i=$((i+1))
        done
    rlPhaseEnd
} #ipapassword_globalpolicy_history_upperbound

ipapassword_globalpolicy_history_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod --history=$v" 0 "set password history to integer [$v] shoul success"
    # test logic ends
} # ipapassword_globalpolicy_history_upperbound_logic 

ipapassword_globalpolicy_history_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_history_negative"
        rlLog "negaive integer and letters are not acceptable for history size"
        testdata="-2 -1 a abc"
        KinitAsAdmin 
        for value in $testdata
        do
            ipapassword_globalpolicy_history_negative_logic $value
        done
    rlPhaseEnd
} #ipapassword_globalpolicy_history_negative

ipapassword_globalpolicy_history_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod --history=$v" 1 "set password history to negative integer or letters [$v] should fail"
    # test logic ends
} # ipapassword_globalpolicy_history_negative_logic 

ipapassword_globalpolicy_classes_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_default"
        rlLog "check minimum classes"
        ipapassword_globalpolicy_classes_default_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_default

ipapassword_globalpolicy_classes_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_classes_default_logic 

ipapassword_globalpolicy_classes_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_lowerbound"
        rlLog "check minimum classes lowbound"
        ipapassword_globalpolicy_classes_lowerbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_lowerbound

ipapassword_globalpolicy_classes_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_classes_lowerbound_logic 

ipapassword_globalpolicy_classes_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_upperbound"
        rlLog "check minimum classes upperbound"
        ipapassword_globalpolicy_classes_upperbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_upperbound

ipapassword_globalpolicy_classes_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_classes_upperbound_logic 

ipapassword_globalpolicy_classes_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_negative"
        rlLog ""
        ipapassword_globalpolicy_classes_negative_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_negative

ipapassword_globalpolicy_classes_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_classes_negative_logic 

ipapassword_globalpolicy_length_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_default"
        rlLog "check minimum length"
        ipapassword_globalpolicy_length_default_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_length_default

ipapassword_globalpolicy_length_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_length_default_logic 

ipapassword_globalpolicy_length_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_lowerbound"
        rlLog "check minimum length"
        ipapassword_globalpolicy_length_lowerbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_length_lowerbound

ipapassword_globalpolicy_length_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_length_lowerbound_logic 

ipapassword_globalpolicy_length_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_upperbound"
        rlLog "check minimum length"
        ipapassword_globalpolicy_length_upperbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_length_upperbound

ipapassword_globalpolicy_length_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_length_upperbound_logic 

ipapassword_globalpolicy_length_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_negative"
        rlLog "check minimum length"
        ipapassword_globalpolicy_length_negative_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_length_negative

ipapassword_globalpolicy_length_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalpolicy_length_negative_logic 

ipapassword_grouppolicy_envsetup()
{
    rlPhaseStartSetup "ipapassword_grouppolicy_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_grouppolicy_envsetup

ipapassword_grouppolicy_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_grouppolicy_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_grouppolicy_envcleanup

ipapassword_grouppolicy_maxlifetime_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_default"
        ipapassword_grouppolicy_maxlifetime_default_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_default

ipapassword_grouppolicy_maxlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_default_logic 

ipapassword_grouppolicy_maxlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_lowerbound"
        ipapassword_grouppolicy_maxlifetime_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_lowerbound

ipapassword_grouppolicy_maxlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_lowerbound_logic 

ipapassword_grouppolicy_maxlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_upperbound"
        rlLog ""
        ipapassword_grouppolicy_maxlifetime_upperbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_upperbound

ipapassword_grouppolicy_maxlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_upperbound_logic 

ipapassword_grouppolicy_maxlifetime_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_negative"
        rlLog ""
        ipapassword_grouppolicy_maxlifetime_negative_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_negative

ipapassword_grouppolicy_maxlifetime_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_negative_logic 

ipapassword_grouppolicy_minlifetime_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_default"
        rlLog ""
        ipapassword_grouppolicy_minlifetime_default_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_default

ipapassword_grouppolicy_minlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_default_logic 

ipapassword_grouppolicy_minlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_lowerbound"
        rlLog ""
        ipapassword_grouppolicy_minlifetime_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_lowerbound

ipapassword_grouppolicy_minlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_lowerbound_logic 

ipapassword_grouppolicy_minlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_upperbound"
        rlLog ""
        ipapassword_grouppolicy_minlifetime_upperbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_upperbound

ipapassword_grouppolicy_minlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_upperbound_logic 

ipapassword_grouppolicy_minlifetime_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_negative"
        rlLog ""
        ipapassword_grouppolicy_minlifetime_negative_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_negative

ipapassword_grouppolicy_minlifetime_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_negative_logic 

ipapassword_grouppolicy_history_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_default"
        rlLog ""
        ipapassword_grouppolicy_history_default_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_history_default

ipapassword_grouppolicy_history_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_history_default_logic 

ipapassword_grouppolicy_history_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_lowerbound"
        rlLog ""
        ipapassword_grouppolicy_history_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_history_lowerbound

ipapassword_grouppolicy_history_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_history_lowerbound_logic 

ipapassword_grouppolicy_history_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_upperbound"
        rlLog ""
        ipapassword_grouppolicy_history_upperbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_history_upperbound

ipapassword_grouppolicy_history_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_history_upperbound_logic 

ipapassword_grouppolicy_history_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_negative"
        rlLog ""
        ipapassword_grouppolicy_history_negative_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_history_negative

ipapassword_grouppolicy_history_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_history_negative_logic 

ipapassword_grouppolicy_classes_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_default"
        rlLog "check minimum classes"
        ipapassword_grouppolicy_classes_default_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_default

ipapassword_grouppolicy_classes_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_classes_default_logic 

ipapassword_grouppolicy_classes_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_lowerbound"
        rlLog "check minimum classes lowbound"
        ipapassword_grouppolicy_classes_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_lowerbound

ipapassword_grouppolicy_classes_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_classes_lowerbound_logic 

ipapassword_grouppolicy_classes_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_upperbound"
        rlLog "check minimum classes upperbound"
        ipapassword_grouppolicy_classes_upperbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_upperbound

ipapassword_grouppolicy_classes_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_classes_upperbound_logic 

ipapassword_grouppolicy_classes_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_negative"
        rlLog ""
        ipapassword_grouppolicy_classes_negative_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_negative

ipapassword_grouppolicy_classes_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_classes_negative_logic 

ipapassword_grouppolicy_length_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_default"
        rlLog "check minimum length"
        ipapassword_grouppolicy_length_default_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_length_default

ipapassword_grouppolicy_length_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_length_default_logic 

ipapassword_grouppolicy_length_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_lowerbound"
        rlLog "check minimum length"
        ipapassword_grouppolicy_length_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_length_lowerbound

ipapassword_grouppolicy_length_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_length_lowerbound_logic 

ipapassword_grouppolicy_length_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_upperbound"
        rlLog "check minimum length"
        ipapassword_grouppolicy_length_upperbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_length_upperbound

ipapassword_grouppolicy_length_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_length_upperbound_logic 

ipapassword_grouppolicy_length_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_negative"
        rlLog "check minimum length"
        ipapassword_grouppolicy_length_negative_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_length_negative

ipapassword_grouppolicy_length_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_grouppolicy_length_negative_logic 

ipapassword_globalandgroup_envsetup()
{
    rlPhaseStartSetup "ipapassword_globalandgroup_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_globalandgroup_envsetup

ipapassword_globalandgroup_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_globalandgroup_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_globalandgroup_envcleanup

ipapassword_globalandgroup_maxlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalandgroup_maxlife_conflict"
        rlLog ""
        ipapassword_globalandgroup_maxlife_conflict_logic
    rlPhaseEnd
} #ipapassword_globalandgroup_maxlife_conflict

ipapassword_globalandgroup_maxlife_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalandgroup_maxlife_conflict_logic 

ipapassword_globalandgroup_minlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalandgroup_minlife_conflict"
        rlLog "when group setting for minlife < global minlife setting"
        ipapassword_globalandgroup_minlife_conflict_logic
    rlPhaseEnd
} #ipapassword_globalandgroup_minlife_conflict

ipapassword_globalandgroup_minlife_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalandgroup_minlife_conflict_logic 

ipapassword_globalandgroup_history_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalandgroup_history_conflict"
        rlLog ""
        ipapassword_globalandgroup_history_conflict_logic
    rlPhaseEnd
} #ipapassword_globalandgroup_history_conflict

ipapassword_globalandgroup_history_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalandgroup_history_conflict_logic 

ipapassword_globalandgroup_classes_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalandgroup_classes_conflict"
        rlLog "when group classes > global classes"
        ipapassword_globalandgroup_classes_conflict_logic
    rlPhaseEnd
} #ipapassword_globalandgroup_classes_conflict

ipapassword_globalandgroup_classes_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalandgroup_classes_conflict_logic 

ipapassword_globalandgroup_length_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalandgroup_length_conflict"
        rlLog "when group length > global length"
        ipapassword_globalandgroup_length_conflict_logic
    rlPhaseEnd
} #ipapassword_globalandgroup_length_conflict

ipapassword_globalandgroup_length_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_globalandgroup_length_conflict_logic 

ipapassword_nestedgroup_envsetup()
{
    rlPhaseStartSetup "ipapassword_nestedgroup_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_nestedgroup_envsetup

ipapassword_nestedgroup_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_nestedgroup_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_nestedgroup_envcleanup

ipapassword_nestedgroup_maxlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgroup_maxlife_conflict"
        rlLog ""
        ipapassword_nestedgroup_maxlife_conflict_logic
    rlPhaseEnd
} #ipapassword_nestedgroup_maxlife_conflict

ipapassword_nestedgroup_maxlife_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_nestedgroup_maxlife_conflict_logic 

ipapassword_nestedgroup_minlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgroup_minlife_conflict"
        rlLog "when group setting for minlife < global minlife setting"
        ipapassword_nestedgroup_minlife_conflict_logic
    rlPhaseEnd
} #ipapassword_nestedgroup_minlife_conflict

ipapassword_nestedgroup_minlife_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_nestedgroup_minlife_conflict_logic 

ipapassword_nestedgroup_history_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgroup_history_conflict"
        rlLog ""
        ipapassword_nestedgroup_history_conflict_logic
    rlPhaseEnd
} #ipapassword_nestedgroup_history_conflict

ipapassword_nestedgroup_history_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_nestedgroup_history_conflict_logic 

ipapassword_nestedgroup_classes_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgroup_classes_conflict"
        rlLog "when group classes > global classes"
        ipapassword_nestedgroup_classes_conflict_logic
    rlPhaseEnd
} #ipapassword_nestedgroup_classes_conflict

ipapassword_nestedgroup_classes_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_nestedgroup_classes_conflict_logic 

ipapassword_nestedgroup_length_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgroup_length_conflict"
        rlLog "when group length > global length"
        ipapassword_nestedgroup_length_conflict_logic
    rlPhaseEnd
} #ipapassword_nestedgroup_length_conflict

ipapassword_nestedgroup_length_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipapassword_nestedgroup_length_conflict_logic 
