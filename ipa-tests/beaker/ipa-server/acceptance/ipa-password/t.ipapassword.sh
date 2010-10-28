
######################
# test suite         #
######################
ipapassword()
{
    ipapassword_envsetup
#    ipapassword_globalpolicy
#    ipapassword_grouppolicy
    ipapassword_nestedgroup
    ipapassword_envcleanup
} # ipapassword

######################
# test set           #
######################
ipapassword_globalpolicy()
{
    ipapassword_globalpolicy_envsetup
    ipapassword_globalpolicy_maxlifetime_default
    ipapassword_globalpolicy_maxlifetime_lowerbound
    ipapassword_globalpolicy_maxlifetime_upperbound
    ipapassword_globalpolicy_maxlifetime_negative
    ipapassword_globalpolicy_minlifetime_default
    ipapassword_globalpolicy_minlifetime_lowerbound
    ipapassword_globalpolicy_minlifetime_upperbound
    ipapassword_globalpolicy_minlifetime_negative
    ipapassword_globalpolicy_history_default
    ipapassword_globalpolicy_history_lowerbound
    ipapassword_globalpolicy_history_upperbound
    ipapassword_globalpolicy_history_negative
    ipapassword_globalpolicy_classes_default
    ipapassword_globalpolicy_classes_lowerbound
#    ipapassword_globalpolicy_classes_upperbound
    ipapassword_globalpolicy_classes_negative
    ipapassword_globalpolicy_length_default
    ipapassword_globalpolicy_length_lowerbound
    ipapassword_globalpolicy_length_upperbound
    ipapassword_globalpolicy_length_negative
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
#    ipapassword_grouppolicy_classes_upperbound
    ipapassword_grouppolicy_classes_negative
    ipapassword_grouppolicy_length_default
    ipapassword_grouppolicy_length_lowerbound
    ipapassword_grouppolicy_length_upperbound
    ipapassword_grouppolicy_length_negative
    ipapassword_grouppolicy_envcleanup
} #ipapassword_grouppolicy

ipapassword_nestedgroup()
{
    ipapassword_nestedgroup_envsetup
    ipapassword_nestedgrouppw_maxlife_conflict
    ipapassword_nestedgrouppw_minlife_conflict
    ipapassword_nestedgrouppw_history_conflict
    ipapassword_nestedgrouppw_classes_conflict
    ipapassword_nestedgrouppw_length_conflict
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
        rlLog "default maxlife : [$globalpw_maxlife]" 
        rlLog "default minlife : [$globalpw_minlife]"
        rlLog "maxlife: when reached, ipa shold prompt for password change"
        ipapassword_globalpolicy_maxlifetime_default_logic
        del_test_ac
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_default

ipapassword_globalpolicy_maxlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        # when minlife < system time < maxlife, user kinit should success, no prompt for password change
        maxlife=`echo "$globalpw_maxlife * 24 * 60 * 60 " |bc `
        minlife=`echo "$globalpw_minlife * 60 * 60 " |bc`
        midpoint=`echo "($minlife + $maxlife)/2" |bc` 
        rlLog "mid point: [$midpoint]"
        set_systime "+ $midpoint"
        rlRun "$kdestroy"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "kinit as same password between minlife and max life should success"

        # when system time > maxlife, ipa server should prompt for password change
        set_systime "+ $midpoint + 60"  # set system time after the max life
        rlRun "$kdestroy"
        kinit_aftermaxlife $testac $testacPW $testacNEWPW

    # test logic ends
} # ipapassword_globalpolicy_maxlifetime_default_logic 

ipapassword_globalpolicy_maxlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_maxlifetime_lowerbound"
        rlLog "lowerbound of maxlife is the minlife"
        ipapassword_globalpolicy_maxlifetime_lowerbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_lowerbound

ipapassword_globalpolicy_maxlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        # since maxlife use day as unit, then we need set minlife to 2 days to test maxlife's lowerbound
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod --minlife=48" #set minlife to 2 days (48 hours)
        rlRun "ipa pwpolicy-mod --maxlife=1" \
                1 "expect to fail since maxlife has to >= minlife"
        rlRun "ipa pwpolicy-mod --maxlife=2" \
                0 "expect to success since maxlife could = minlife"
    # test logic ends
} # ipapassword_globalpolicy_maxlifetime_lowerbound_logic 

ipapassword_globalpolicy_maxlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_maxlifetime_upperbound"
        rlLog "the upper bound of maxlife is the max int it can takes"
        KinitAsAdmin
        for max_value in 100 1000 9999 99999
        do
            ipapassword_globalpolicy_maxlifetime_upperbound_logic $max_value
        done
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_globalpolicy_maxlifetime_upperbound

ipapassword_globalpolicy_maxlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod --maxlife=$v" \
              0 "set value to [$v], expect to pass"
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
        rlLog "default maxlife : [$globalpw_maxlife]"        
        rlLog "default minlife : [$globalpw_minlife]"        
        rlLog "minlife: when not reached, user can not change password"
        ipapassword_globalpolicy_minlifetime_default_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_minlifetime_default

ipapassword_globalpolicy_minlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/globalminlifedefault.$RANDOM.txt
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
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
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$testacPW]"
            change_password $testac $testacPW "dummy123"
            if [ $? = 0 ];then
                rlFail "password change success, this is not expected"
            else 
                rlPass "password change failed as expected"
            fi

            # after minlife, change passwod should success
            set_systime "+ 2*60"  # setsystime 2 minutes after
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$testacPW]"
            change_password $testac $testacPW "dummy123"
            if [ $? = 0 ];then
                rlPass "password change success, this is expected"
            else
                rlFail "password change failed is not expected"
            fi
            del_test_ac
        else
            rlFail "can not set pre-condition"
        fi
        rm $out
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
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
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
                rlRun "echo $oldpw | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$oldpw]"
                change_password $testac $oldpw $newpw
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
            del_test_ac
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
        rlLog "default maxlife : [$globalpw_maxlife]"        
        rlLog "default minlife : [$globalpw_minlife]"        
        ipapassword_globalpolicy_minlifetime_upperbound_logic
    rlPhaseEnd
} #ipapassword_globalpolicy_minlifetime_upperbound

ipapassword_globalpolicy_minlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "reset global pwpolicy"
        reset_global_pwpolicy
        maxlife=`echo "$globalpw_maxlife * 24 " | bc`
        counter=0
        previousvalue=$globalpw_minlife
        KinitAsAdmin
        while [ $counter -lt 10 ]
        do
            number=$RANDOM
            let "number %= $maxlife"
            #minlife=`echo "$number / 60 / 60" | bc` # convert to hours
            minlife=$number
            if [ $minlife -ne $previousvalue ]
            then
                rlRun "ipa pwpolicy-mod --minlife=$minlife" \
                0 "test:[$counter] set min to [$minlife] (hours) while maxlife =[$globalpw_maxlife] (days)is allowed"
                counter=$((counter+1))
                previousvalue=$minlife
            fi
        done
        rlRun "$kdestroy" 0 "clear all kerberos ticket"
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
        local out=$TmpdIR/globalpolicyhistorydefault.$RANDOM.out
        rlLog "default behave of history setting test"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] classes=[$classes]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            add_test_ac
            ipapassword_globalpolicy_history_default_logic
            del_test_ac
        else
            rlFail "can not set precondition for history test"
        fi
        rm $out
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
        kinitAs $testac $testacPW
        counter=1 #reset counter
        while [ $counter -lt $N ]
        do
            next=$((counter+1))
            currentPW=`echo $pws | cut -d" " -f$counter`
            nextPW=`echo $pws |cut -d" " -f$next`
            rlLog "counter=[$counter] currentpw[$currentPW], nextpw[$nextPW]"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$currentPW]"
            change_password $testac $currentPW $nextPW
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
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$currentPW]"
            change_password $testac $currentPW $p
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
        local out=$TmpDir/globalpolicyhistorylowbound.$RANDOM.out
        lowbound=0
        rlLog "lowerbound of password history is $lowbound"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
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
            del_test_ac
        else
            rlFail "can not set precondition for history test"
        fi
        rm $out
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
        kinitAs $testac $testacPW
        number=$RANDOM
        let "number %= 10"
        N=`echo "$number + 2" | bc` # set N >= 2
        counter=0
        currentPW=$testacPW
        newPW="dummy123"
        rlLog "keep change password [$N] times with two password:[$currentPW] & [$newPW]"
        while [ $counter -lt $N ] #password is $oldpw when out of this loop
        do
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$currentPW]"
            change_password $testac $currentPW $newPW
            if [ $? = 0 ];then
                rlPass "[$counter] change success, current password [$newPW]"
                #swap the password
                tmp=$currentPW
                currentPW=$newPW
                newPW=$tmp 
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
        local out=$TmpDir/globalpwclassesdefault.$RANDOM.out
        rlLog "check minimum classes default behave: when classes between [2-4]"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_globalpolicy_classes_default_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_default

ipapassword_globalpolicy_classes_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/pwclassesdefault.$RANDOM.out
        local n
        rlRun "$kdestroy" 0 "clear all kerberos"
        for n in 2 3 4
        do
            KinitAsAdmin
            ipa pwpolicy-mod --minclasses=$n
            ipa pwpolicy-show > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" \
                       0 "get kerberos ticket for current user, prepare for password change"

                # scenario 1: when new password classes less than $n, password change should fail
                minclasses=1 # when classes = 0 it has same effect as 1, 
                             #      we will test this in lowerbound test
                maxclasses=5 # when classes > 5, it has same effect as 4, 
                             #      we will test this in upperbound test
                classLevel=$minclasses
                while [ $classLevel -lt $n ]
                do
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #rlLog "password out file: [$pwout]"
                    #generate_password $classLevel $globalpw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "password change success is not expected"
                    else
                        rlPass "password change failed, this is expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                # scenario 2: when new password classes equal or greater than $n, password change should sucess
                currentPW=$testacPW
                while [ $classLevel -lt $maxclasses ]
                do  
                    #classesLevel will grow from n to 4
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #generate_password $classLevel $globalpw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                del_test_ac
            else
                rlFail "set minclasses to [$n] failed"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_globalpolicy_classes_default_logic 

ipapassword_globalpolicy_classes_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_lowerbound"
        local out=$TmpDir/classeslowerbound.$RANDOM.out
        rlLog "check minimum classes lowbound: 0"
        KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        unset out
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_globalpolicy_classes_lowerbound_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_lowerbound

ipapassword_globalpolicy_classes_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        # classLevel: 0 & 1 has same effect to password, they share same test logic
        local classLevel
        local temp
        local out=$TmpDir/classeslowerbound.$RANDOM.out
        local pwout
        local pw
        for classLevel in 0 1
        do
            rlLog "test classLevel=[$classLevel]"
            KinitAsAdmin
            ipa pwpolicy-mod --minclasses=$classLevel
            ipa pwpolicy-show > $out
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            temp=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            if [ $temp = $classLevel ];then
                add_test_ac
                rlLog "set classes to [$temp] success, test continue"
                # run same test 8 times, to ensure all password classes covered
                i=0
                currentPW=$testacPW
                num_of_test=8
                while [ $i -lt $num_of_test ]
                do
                    #pwout="$TmpDir/pwout.$RANDOM.out"
                    #generate_password $classLevel $globalpw_length "$pwout"
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "[test $i]: now change to new password [$pw]"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac $currentPW $pw
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW=$pw
                    else
                        rlFail "password change failed, this is not expected"
                    fi
                    i=$((i+1))
                done
                del_test_ac
            else
                rlLog "set classes to [$temp] failed, can not continue test"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_globalpolicy_classes_lowerbound_logic 

ipapassword_globalpolicy_classes_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_upperbound"
        local out=$TmpDir/pwclassesupperbound.$RANDOM.out
        rlLog "check minimum classes upperbound: >4, it should behave same as 4"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_globalpolicy_classes_upperbound_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_upperbound

ipapassword_globalpolicy_classes_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/classesupperbound.$RANDOM.out
        local n
        rlRun "$kdestroy" 0 "clear all kerberos"
        for n in 5 6 7 8
        do
            KinitAsAdmin
            ipa pwpolicy-mod --minclasses=$n
            ipa pwpolicy-show > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "get kerberos ticket for current user, prepare for password change"

                # scenario 1: when new password classes less than $n, password change should fail
                minclasses=1 # when classes = 0 it has same effect as 1, 
                             #      we will test this in lowerbound test
                maxclasses=8 # when classes > 5, it has same effect as 4, 
                             #      we will test this in upperbound test
                classLevel=$minclasses
                while [ $classLevel -lt $n ]
                do
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #rlLog "password out file: [$pwout]"
                    #generate_password $classLevel $globalpw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo \"$testacPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "password change success is not expected"
                    else
                        rlPass "password change failed, this is expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                # scenario 2: when new password classes equal or greater than $n, password change should sucess
                currentPW=$testacPW
                while [ $classLevel -lt $maxclasses ]
                do  
                    #classesLevel will grow from n to 4
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #generate_password $classLevel $globalpw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                del_test_ac
            else
                rlFail "set minclasses to [$n] failed"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_globalpolicy_classes_upperbound_logic 

ipapassword_globalpolicy_classes_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_classes_negative"
        local out=$TmpDir/classesnegative.$RANDOM.out
        rlLog "check minimum classes can not be set to negative integer and letters"
        reset_global_pwpolicy
        for class_value in -2 -1 a abc
        do
            KinitAsAdmin
            ipapassword_globalpolicy_classes_negative_logic $class_value
            rlRun "$kdestroy"
        done
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_negative

ipapassword_globalpolicy_classes_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod --minclasses=$v" 1 "set minclass to [$v] should fail"
        unset v
    # test logic ends
} # ipapassword_globalpolicy_classes_negative_logic 

ipapassword_globalpolicy_length_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_default"
        local out=$TmpDir/pwlengthdefault.$RANDOM.out
        rlLog "check minimum length default behave"
        reset_global_pwpolicy
        rlLog "set all other password constrains to 0"
        KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "preconditoin: minlife=[$minlife] minclasses=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $classes = 0 ] && [ $history = 0 ]
        then
            add_test_ac
            ipapassword_globalpolicy_length_default_logic
            del_test_ac
        else
            rlFail "can not set precondition for password length test"
        fi
    rlPhaseEnd
} #ipapassword_globalpolicy_length_default

ipapassword_globalpolicy_length_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/pwlength.$RANDOM.out
        local length=1 # length=0 will be tested in lowerbound test case
        local maxlength=15 # we only test upto 15, a resonable assumption
        local pw

        # scenario 1: password change should fail when length < $globalpw_length
        while [ $length -lt $globalpw_length ]
        do
            number=$RANDOM
            let "number %= 4"
            classLevel=$((number+1)) #classLevel rotate between 1-4
            #pwout=$TmpDir/pwout.$RANDOM.out
            rlLog "minlength=[$globalpw_length], current len [$length],class=[$classLevel] number=[$number]"
            #generate_password $classLevel $length $pwout
            #pw=`cat $pwout`
            #rm $pwout
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$globalpw_length], current len [$length],password=[$pw]"
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
            change_password $testac $testacPW $pw    
            if [ $? = 0 ];then
                rlFail "password change success is not expected"
            else
                rlPass "password change failed, this is expected"
            fi
            length=$((length+1))
        done

        # scenario 2: password change should success when length < $globalpw_length
        currentPW=$testacPW
        while [ $length -lt $maxlength ]
        do
            number=$RANDOM
            let "number %= 4"
            classLevel=$((number+1)) #classLevel rotate between 1-4
            #pwout=$TmpDir/pwout.$RANDOM.out
            rlLog "minlength=[$globalpw_length], current len [$length],class=[$classLevel] number=[$number]"
            #generate_password $classLevel $length $pwout
            #pw=`cat $pwout`
            #rm $pwout
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$globalpw_length], current len [$length],password=[$pw]"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
            change_password $testac $currentPW $pw    
            if [ $? = 0 ];then
                rlPass "password change success is expected"
                currentPW=$pw
            else
                rlFail "password change failed, this is NOT expected"
            fi
            length=$((length+1))
        done
    # test logic ends
} # ipapassword_globalpolicy_length_default_logic 

ipapassword_globalpolicy_length_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_lowerbound"
        local out=$TmpDir/pwlengthlowerbound.$RANDOM.out
        rlLog "minimum length = 0"
        rlLog "check minimum length lowerbound"
        reset_global_pwpolicy
        rlLog "set all other password constrains to 0"
        KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 --minlength=0
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "preconditoin: minlife=[$minlife] minclasses=[$classes] history=[$history] minlength=[$length]"
        if [ $minlife = 0 ] && [ $classes = 0 ] && [ $history = 0 ] && [ $length = 0 ]
        then
            add_test_ac
            ipapassword_globalpolicy_length_lowerbound_logic
            del_test_ac
        else
            rlFail "can not set precondition for password length test"
        fi
    rlPhaseEnd
} #ipapassword_globalpolicy_length_lowerbound

ipapassword_globalpolicy_length_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "there is only one password has length 0: empty string"
        kinitAs $testac $testacPW
        nullpassword=""
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
        change_password $testac $testacPW "$nullpassword"
        if [ $? = 0 ];then
            rlFail "password change success is not expected"
        else
            rlPass "password change failed, this is expected"
        fi
    # test logic ends
} # ipapassword_globalpolicy_length_lowerbound_logic 

ipapassword_globalpolicy_length_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_upperbound"
        local out=$TmpDir/pwlengthupperbounddefault.$RANDOM.out
        rlLog "check upper bound of length setting"
        reset_global_pwpolicy
        rlLog "set all other password constrains to 0"
        KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "preconditoin: minlife=[$minlife] minclasses=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $classes = 0 ] && [ $history = 0 ]
        then
            add_test_ac
            ipapassword_globalpolicy_length_upperbound_logic
            del_test_ac
        else
            rlFail "can not set precondition for password length upper bound test"
        fi

    rlPhaseEnd
} #ipapassword_globalpolicy_length_upperbound

ipapassword_globalpolicy_length_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/pwupperbound.$RANDOM.out
        local edge
        local currentPW=$testacPW
        rlLog "there is no real upper-bound of password length, I will try some bigger but resonable number here 10, 50, 100"
        for edge in 10 50 100
        do
            #set minlength=edge
            KinitAsAdmin
            ipa pwpolicy-mod --minlength=$edge > $out
            rlRun "$kdestroy"
            len=`grep "length" $out | cut -d":" -f2| xargs echo`
            if [ $len = $edge ];then
                rlLog "minlength=[$len], now continue test"
                ##############################################################
                # if password length < edge, password changing should fail
                ##############################################################
                below=$((edge-1))
                number=$RANDOM
                let "number %= 4"
                classLevel=$((number+1)) #classLevel rotate between 1-4
                #pwout=$TmpDir/pwout.$RANDOM.out
                #generate_password $classLevel $below $pwout
                #pw=`cat $pwout`
                #rm $pwout
                pw=`generate_password $classLevel $below`
                rlLog "minlength=[$edge], current len [$below],password=[$pw]"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlFail "password change success is NOT expected"
                    currentPW=$pw
                else
                    rlPass "password change failed, this is expected"
                fi               

                ##############################################################
                # if password length = edge, password changing should success
                ##############################################################
                number=$RANDOM
                let "number %= 4"
                classLevel=$((number+1)) #classLevel rotate between 1-4
                #pwout=$TmpDir/pwout.$RANDOM.out
                rlLog "minlength=[$edge], current len [$edge],class=[$classLevel] number=[$number]"
                #generate_password $classLevel $edge $pwout
                #pw=`cat $pwout`
                #rm $pwout
                pw=`generate_password $classLevel $edge`
                rlLog "minlength=[$edge], current len [$edge],password=[$pw]"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "password change failed, this is NOT expected"
                fi               

                ##############################################################
                # if password length > edge, password changing should success
                ##############################################################
                upper=$((edge+1))
                number=$RANDOM
                let "number %= 4"
                classLevel=$((number+1)) #classLevel rotate between 1-4
                #pwout=$TmpDir/pwout.$RANDOM.out
                #generate_password $classLevel $upper $pwout
                #pw=`cat $pwout`
                #rm $pwout
                pw=`generate_password $classLevel $upper`
                rlLog "minlength=[$edge], current len [$upper],password=[$pw]"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "password change failed, this is NOT expected"
                fi               
            else
                rlFail "can not set minlength to [$edge]"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_globalpolicy_length_upperbound_logic 

ipapassword_globalpolicy_length_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_length_negative"
        rlLog "set length to negative integer or letter should fail"
        KinitAsAdmin
        for length_value in -2 -1 a abc
        do
            ipapassword_globalpolicy_length_negative_logic $length_value
        done
    rlPhaseEnd
} #ipapassword_globalpolicy_length_negative

ipapassword_globalpolicy_length_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod --minlength=$v" 1 "expect to fail when minlength=[$v]"
    # test logic ends
} # ipapassword_globalpolicy_length_negative_logic 

ipapassword_grouppolicy_envsetup()
{
    rlPhaseStartSetup "ipapassword_grouppolicy_envsetup"
        #environment setup starts here
        reset_global_pwpolicy
        add_test_grp
        add_test_ac 
        append_test_member
        reset_group_pwpolicy
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_grouppolicy_envsetup

ipapassword_grouppolicy_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_grouppolicy_envcleanup"
        #environment cleanup starts here
        remove_test_member
        del_test_grp
        del_test_ac
        reset_global_pwpolicy
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
        # password will not expire before maxlife of group pwpolicy
        maxlife=`echo "$grouppw_maxlife * 24 * 60 * 60 " |bc `
        minlife=`echo "$grouppw_minlife * 60 * 60 " |bc`
        maxlife_default $maxlife $minlife
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_default_logic 

ipapassword_grouppolicy_maxlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_lowerbound"
        rlLog "lowerbound of group pwpolicy maxlife is minlife of same group pwpolicy"
        ipapassword_grouppolicy_maxlifetime_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_lowerbound

ipapassword_grouppolicy_maxlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp --minlife=48" #set minlife to 2 days (48 hours)
        rlRun "ipa pwpolicy-mod $testgrp --maxlife=1" \
                1 "expect to fail since maxlife has to >= minlife"
        rlRun "ipa pwpolicy-mod $testgrp --maxlife=2" \
                0 "expect to success since maxlife could = minlife"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_lowerbound_logic 

ipapassword_grouppolicy_maxlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_upperbound"
        local max_value
        rlLog "the upper bound of maxlife is the max int it can takes"
        KinitAsAdmin
        for max_value in 100 1000 9999 99999
        do
            ipapassword_grouppolicy_maxlifetime_upperbound_logic $max_value
        done
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_upperbound

ipapassword_grouppolicy_maxlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod $testgrp --maxlife=$v" \
              0 "set value to [$v], expect to pass"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_upperbound_logic 

ipapassword_grouppolicy_maxlifetime_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_maxlifetime_negative"
        rlLog "maxlife can not be non-interget value"
        KinitAsAdmin 
        rlRun "ipa pwpolicy-mod $testgrp --minlife=0" 0 "set minlife to 0"
        for maxlife_value in -2 -1 a abc
        do
            ipapassword_grouppolicy_maxlifetime_negative_logic $maxlife_value
        done
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_grouppolicy_maxlifetime_negative

ipapassword_grouppolicy_maxlifetime_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlRun "ipa pwpolicy-mod $testgrp --maxlife=$1" 1 "expect to fail for maxlife=[$1]"
    # test logic ends
} # ipapassword_grouppolicy_maxlifetime_negative_logic 

ipapassword_grouppolicy_minlifetime_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_default"
        rlLog "group maxlife : [$grouppw_maxlife]"        
        rlLog "group minlife : [$grouppw_minlife]"        
        rlLog "minlife: when not reached, user can not change password"
        # the test user account and grouop account is pretty much corrupted after previous test, reset account here
        add_test_grp
        add_test_ac 
        append_test_member
        reset_group_pwpolicy
        ipapassword_grouppolicy_minlifetime_default_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_default

ipapassword_grouppolicy_minlifetime_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        minlife_default $grouppw_maxlife $grouppw_minlife $testgrp 
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_default_logic 

ipapassword_grouppolicy_minlifetime_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_lowerbound"
        rlLog "the lowerbound of minlife is 0"
        rlLog "it means we can change password whenever we want"
        add_test_grp
        add_test_ac 
        append_test_member
        reset_group_pwpolicy
        ipapassword_grouppolicy_minlifetime_lowerbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_lowerbound

ipapassword_grouppolicy_minlifetime_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        minlife_lowerbound $testgrp
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_lowerbound_logic 

ipapassword_grouppolicy_minlifetime_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_minlifetime_upperbound"
        rlLog "the upper bound of minlife of group pwpolicy is maxlifetime"
        reset_group_pwpolicy
        ipapassword_grouppolicy_minlifetime_upperbound_logic
    rlPhaseEnd
} #ipapassword_grouppolicy_minlifetime_upperbound

ipapassword_grouppolicy_minlifetime_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/grouppolicyminlifeupperbound.$RANDOM.out

        KinitAsAdmin
        ipa pwpolicy-show  $testgrp > $out
        maxlife=`grep "Max lifetime" $out | cut -d":" -f2|xargs echo`
        rlLog "maxlife=[$maxlife] days"
        maxlife=`echo "$maxlife * 24"|bc`
        rlLog "maxlife=[$maxlife] hours"

        # set minlife < maxlife should success
        minlife=$((maxlife - 1))
        rlRun "ipa pwpolicy-mod $testgrp --minlife=$minlife" \
              0 "set minlife should success when minlife < maxlife"
        # setminlife = maxlife should success
        minlife=$maxlife
        rlRun "ipa pwpolicy-mod $testgrp --minlife=$minlife" \
              0 "set minlife should success when minlife = maxlife"
        # set minlife > maxlife should fail
        minlife=$((maxlife + 1))
        rlRun "ipa pwpolicy-mod $testgrp --minlife=$minlife" \
              1 "set minlife should fail when minlife > maxlife"
        rm $out
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
        KinitAsAdmin
        for life in -2 -1 a abc ;do
            rlRun "ipa pwpolicy-mod $testgrp --minlife=$minlife" \
              1 "set minlife should fail when minlife = [$life] "
        done
    # test logic ends
} # ipapassword_grouppolicy_minlifetime_negative_logic 

ipapassword_grouppolicy_history_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_default"
        local out=$TmpdIR/globalpolicyhistorydefault.$RANDOM.out
        rlLog "default behave of history setting test"
        add_test_ac
        add_test_grp
        append_test_member
        reset_group_pwpolicy
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] classes=[$classes]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            ipapassword_grouppolicy_history_default_logic
        else
            rlFail "can not set precondition for history test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_grouppolicy_history_default

ipapassword_grouppolicy_history_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        number=$RANDOM
        let "number %= 20"
        N=`echo "$number + 2" | bc` # set N >= 2
        pws="$testacPW"
        counter=1 #reset counter
        KinitAsAdmin 
        rlRun "ipa pwpolicy-mod $testgrp --history=$N" 0 "set password history to [$N] for grp [$testgrp]"
        while [ $counter -lt $N ]
        do
            pw="${counter}_${testacPW}"
            pws="$pws $pw"
            counter=$((counter+1))
        done
        rlLog "password pool: [$pws]"
        # now we start to change password, the all expected to fail
        rlRun "$kdestroy"
        kinitAs $testac $testacPW
        counter=1 #reset counter
        while [ $counter -lt $N ]
        do
            next=$((counter+1))
            currentPW=`echo $pws | cut -d" " -f$counter`
            nextPW=`echo $pws |cut -d" " -f$next`
            rlLog "counter=[$counter] currentpw[$currentPW], nextpw[$nextPW]"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$currentPW]"
            change_password $testac $currentPW $nextPW
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
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$currentPW]"
            change_password $testac $currentPW $p
            if [ $? = 0 ];then
                rlFail "password [$p] reuse success is not expected"
            else
                rlPass "password [$p] reuse failed is expected"
            fi
        done
    # test logic ends
} # ipapassword_grouppolicy_history_default_logic 

ipapassword_grouppolicy_history_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_lowerbound"
        local out=$TmpDir/grouppolicyhistorylowbound.$RANDOM.out
        add_test_ac
        add_test_grp
        append_test_member
        reset_group_pwpolicy
        lowbound=0
        rlLog "lowerbound of password history is $lowbound"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] classes=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ] \
            && [ $history = 0 ]
        then
            ipapassword_grouppolicy_history_lowerbound_logic
        else
            rlFail "can not set precondition for history test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_grouppolicy_history_lowerbound

ipapassword_grouppolicy_history_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        # when history=0, user can reuse their password as many as they want
        # please note that change password to current working password
        # does not allowed by the nature of kerberos. so history=0 means
        # you can actually switch between 2 passwords
        rlRun "$kdestroy"
        kinitAs $testac $testacPW
        number=$RANDOM
        let "number %= 10"
        N=`echo "$number + 2" | bc` # set N >= 2
        counter=0
        currentPW=$testacPW
        newPW="dummy123"
        rlLog "keep change password [$N] times with two password:[$currentPW] & [$newPW]"
        while [ $counter -lt $N ] #password is $oldpw when out of this loop
        do
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$currentPW]"
            change_password $testac $currentPW $newPW
            if [ $? = 0 ];then
                rlPass "[$counter] change success, current password [$newPW]"
                #swap the password
                tmp=$currentPW
                currentPW=$newPW
                newPW=$tmp 
            else
                rlFail "[$counter] password change failed"
            fi
            counter=$((counter+1))
        done
    # test logic ends
} # ipapassword_grouppolicy_history_lowerbound_logic 

ipapassword_grouppolicy_history_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_upperbound"
        rlLog "there is no real upperbound, just try some randam integers"
        lastvalue=$RANDOM
        max=20 #test 20 times
        i=0
        KinitAsAdmin 
        while [ $i -lt $max ]
        do 
            size=$RANDOM
            if [ $size -ne $lastvalue ]; then
                ipapassword_grouppolicy_history_upperbound_logic $size
            fi
            lastvalue=$size
            i=$((i+1))
        done
    rlPhaseEnd
} #ipapassword_grouppolicy_history_upperbound

ipapassword_grouppolicy_history_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod $testgrp --history=$v" 0 "set password history to integer [$v] shoul success"
    # test logic ends
} # ipapassword_grouppolicy_history_upperbound_logic 

ipapassword_grouppolicy_history_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_negative"
        rlLog "negaive integer and letters are not acceptable for history size"
        testdata="-2 -1 a abc"
        KinitAsAdmin 
        for value in $testdata
        do
            ipapassword_grouppolicy_history_negative_logic $value
        done
    rlPhaseEnd
} #ipapassword_grouppolicy_history_negative

ipapassword_grouppolicy_history_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod $testgrp --history=$v" 1 "set password history to negative integer or letters [$v] should fail"
    # test logic ends
} # ipapassword_grouppolicy_history_negative_logic 

ipapassword_grouppolicy_classes_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_default"
        local out=$TmpDir/grouppwclassesdefault.$RANDOM.out
        rlLog "check minimum classes default behave: when classes between [2-4]"
        add_test_ac
        add_test_grp
        append_test_member
        reset_group_pwpolicy
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_default_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_default

ipapassword_grouppolicy_classes_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/grouppwclassesdefault.$RANDOM.out
        local n
        rlRun "$kdestroy" 0 "clear all kerberos"
        for n in 2 3 4
        do
            KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minclasses=$n
            ipa pwpolicy-show $testgrp > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                append_test_member
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" \
                       0 "get kerberos ticket for current user, prepare for password change"

                # scenario 1: when new password classes less than $n, password change should fail
                minclasses=1 # when classes = 0 it has same effect as 1, 
                             #      we will test this in lowerbound test
                maxclasses=5 # when classes > 5, it has same effect as 4, 
                             #      we will test this in upperbound test
                classLevel=$minclasses
                while [ $classLevel -lt $n ]
                do
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #rlLog "password out file: [$pwout]"
                    #generate_password $classLevel $grouppw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $grouppw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "password change success is not expected"
                    else
                        rlPass "password change failed, this is expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                # scenario 2: when new password classes equal or greater than $n, password change should sucess
                currentPW=$testacPW
                while [ $classLevel -lt $maxclasses ]
                do  
                    #classesLevel will grow from n to 4
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #generate_password $classLevel $globalpw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
            else
                rlFail "set minclasses to [$n] failed"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_grouppolicy_classes_default_logic 

ipapassword_grouppolicy_classes_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_lowerbound"
        local out=$TmpDir/classeslowerbound.$RANDOM.out
        rlLog "check minimum classes lowbound: 0"
        add_test_grp
        reset_group_pwpolicy
        KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        unset out
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_lowerbound_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_lowerbound

ipapassword_grouppolicy_classes_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local classLevel
        local temp
        local out=$TmpDir/classeslowerbound.$RANDOM.out
        local pwout
        local pw
        for classLevel in 0 1
        do
            rlLog "test classLevel=[$classLevel]"
            KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minclasses=$classLevel
            ipa pwpolicy-show $testgrp > $out
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            temp=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            if [ $temp = $classLevel ];then
                add_test_ac
                append_test_member
                rlLog "set classes to [$temp] success, test continue"
                # run same test 8 times, to ensure all password classes covered
                i=0
                currentPW=$testacPW
                num_of_test=8
                while [ $i -lt $num_of_test ]
                do
                    #pwout="$TmpDir/pwout.$RANDOM.out"
                    #generate_password $classLevel $globalpw_length "$pwout"
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $globalpw_length`
                    rlLog "[test $i]: now change to new password [$pw]"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac $currentPW $pw
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW=$pw
                    else
                        rlFail "password change failed, this is not expected"
                    fi
                    i=$((i+1))
                done
            else
                rlLog "set classes to [$temp] failed, can not continue test"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_grouppolicy_classes_lowerbound_logic 

ipapassword_grouppolicy_classes_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_upperbound"
        rlLog "check minimum classes upperbound"
        local out=$TmpDir/pwclassesupperbound.$RANDOM.out
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        add_test_grp
        reset_group_pwpolicy
        ipa pwpolicy-mod $testgrp --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "preconditoin: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_upperbound_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_upperbound

ipapassword_grouppolicy_classes_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/classesupperbound.$RANDOM.out
        local n
        rlRun "$kdestroy" 0 "clear all kerberos"
        for n in 5 6 7 8
        do
            KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minclasses=$n
            ipa pwpolicy-show $testgrp > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                append_test_member
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "get kerberos ticket for current user, prepare for password change"

                # scenario 1: when new password classes less than $n, password change should fail
                minclasses=1 # when classes = 0 it has same effect as 1, 
                             #      we will test this in lowerbound test
                maxclasses=8 # when classes > 5, it has same effect as 4, 
                             #      we will test this in upperbound test
                classLevel=$minclasses
                while [ $classLevel -lt $n ]
                do
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #rlLog "password out file: [$pwout]"
                    #generate_password $classLevel $grouppw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $grouppw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo \"$testacPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "password change success is not expected"
                    else
                        rlPass "password change failed, this is expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                # scenario 2: when new password classes equal or greater than $n, password change should sucess
                currentPW=$testacPW
                while [ $classLevel -lt $maxclasses ]
                do  
                    #classesLevel will grow from n to 4
                    #pwout=$TmpDir/pwout.$RANDOM.out
                    #generate_password $classLevel $grouppw_length $pwout
                    #pw=`cat $pwout`
                    #rm $pwout
                    pw=`generate_password $classLevel $grouppw_length`
                    rlLog "generate password [$pw] with [$classLevel] classes"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
            else
                rlFail "set minclasses to [$n] failed"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_grouppolicy_classes_upperbound_logic 

ipapassword_grouppolicy_classes_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_classes_negative"
        local out=$TmpDir/classesnegative.$RANDOM.out
        rlLog "check minimum classes can not be set to negative integer and letters"
        add_test_grp
        reset_group_pwpolicy
        for class_value in -2 -1 a abc
        do
            KinitAsAdmin
            ipapassword_grouppolicy_classes_negative_logic $class_value
            rlRun "$kdestroy"
        done
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_negative

ipapassword_grouppolicy_classes_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod $testgrp --minclasses=$v" 1 "set minclass to [$v] should fail"
        unset v
    # test logic ends
} # ipapassword_grouppolicy_classes_negative_logic 

ipapassword_grouppolicy_length_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_default"
        local out=$TmpDir/pwlengthdefault.$RANDOM.out
        rlLog "check minimum length default behave"
        add_test_grp
        reset_group_pwpolicy
        rlLog "set all other password constrains to 0"
        KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "preconditoin: minlife=[$minlife] minclasses=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $classes = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_length_default_logic
        else
            rlFail "can not set precondition for password length test"
        fi
    rlPhaseEnd
} #ipapassword_grouppolicy_length_default

ipapassword_grouppolicy_length_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/pwlength.$RANDOM.out
        local length=1 # length=0 will be tested in lowerbound test case
        local maxlength=15 # we only test upto 15, a resonable assumption
        local pw

        # scenario 1: password change should fail when length < $globalpw_length
        add_test_ac
        append_test_member
        while [ $length -lt $grouppw_length ]
        do
            number=$RANDOM
            let "number %= 4"
            classLevel=$((number+1)) #classLevel rotate between 1-4
            #pwout=$TmpDir/pwout.$RANDOM.out
            rlLog "minlength=[$grouppw_length], current len [$length],class=[$classLevel] number=[$number]"
            #generate_password $classLevel $length $pwout
            #pw=`cat $pwout`
            #rm $pwout
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$grouppw_length], current len [$length],password=[$pw]"
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
            change_password $testac $testacPW $pw    
            if [ $? = 0 ];then
                rlFail "password change success is not expected"
            else
                rlPass "password change failed, this is expected"
            fi
            length=$((length+1))
        done

        # scenario 2: password change should success when length < $globalpw_length
        currentPW=$testacPW
        while [ $length -lt $maxlength ]
        do
            number=$RANDOM
            let "number %= 4"
            classLevel=$((number+1)) #classLevel rotate between 1-4
            #pwout=$TmpDir/pwout.$RANDOM.out
            rlLog "minlength=[$grouppw_length], current len [$length],class=[$classLevel] number=[$number]"
            #generate_password $classLevel $length $pwout
            #pw=`cat $pwout`
            #rm $pwout
            pw=`generate_password $classLevel`
            rlLog "minlength=[$grouppw_length], current len [$length],password=[$pw]"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
            change_password $testac $currentPW $pw    
            if [ $? = 0 ];then
                rlPass "password change success is expected"
                currentPW=$pw
            else
                rlFail "password change failed, this is NOT expected"
            fi
            length=$((length+1))
        done
    # test logic ends
} # ipapassword_grouppolicy_length_default_logic 

ipapassword_grouppolicy_length_lowerbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_lowerbound"
        local out=$TmpDir/pwlengthlowerbound.$RANDOM.out
        rlLog "minimum length = 0"
        rlLog "check minimum length lowerbound"
        add_test_ac
        add_test_grp
        append_test_member
        reset_group_pwpolicy
        rlLog "set all other password constrains to 0"
        KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minclasses=0 --history=0 --minlength=0
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "preconditoin: minlife=[$minlife] minclasses=[$classes] history=[$history] minlength=[$length]"
        if [ $minlife = 0 ] && [ $classes = 0 ] && [ $history = 0 ] && [ $length = 0 ]
        then
            ipapassword_grouppolicy_length_lowerbound_logic
        else
            rlFail "can not set precondition for password length test"
        fi
    rlPhaseEnd
} #ipapassword_grouppolicy_length_lowerbound

ipapassword_grouppolicy_length_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "there is only one password has length 0: empty string"
        kinitAs $testac $testacPW
        nullpassword=""
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
        change_password $testac $testacPW "$nullpassword"
        if [ $? = 0 ];then
            rlFail "password change success is not expected"
        else
            rlPass "password change failed, this is expected"
        fi
    # test logic ends
} # ipapassword_grouppolicy_length_lowerbound_logic 

ipapassword_grouppolicy_length_upperbound()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_upperbound"
        local out=$TmpDir/pwlengthupperbounddefault.$RANDOM.out
        rlLog "check upper bound of length setting"
        add_test_grp
        reset_group_pwpolicy
        rlLog "set all other password constrains to 0"
        KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "preconditoin: minlife=[$minlife] minclasses=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $classes = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_length_upperbound_logic
        else
            rlFail "can not set precondition for password length upper bound test"
        fi
    rlPhaseEnd
} #ipapassword_grouppolicy_length_upperbound

ipapassword_grouppolicy_length_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/grouppwupperbound.$RANDOM.out
        local edge
        local currentPW=$testacPW
        add_test_ac
        append_test_member
        rlLog "there is no real upper-bound of password length, I will try some bigger but resonable number here 10, 50, 100"
        for edge in 20 50 100
        do
            #set minlength=edge
            KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minlength=$edge > $out
            echo "============= [$testgrp] pwpolicy =========="
            cat $out
            echo "============================================"
            rlLog "len=[$len] edge=[$edge]"
            rlRun "$kdestroy"
            len=`grep "length" $out | cut -d":" -f2| xargs echo`
            if [ $len = $edge ];then
                rlLog "minlength=[$len], now continue test"
                ##############################################################
                # if password length < edge, password changing should fail
                ##############################################################
                below=$((edge-1))
                number=$RANDOM
                let "number %= 4"
                classLevel=$((number+1)) #classLevel rotate between 1-4
                #pwout=$TmpDir/pwout.$RANDOM.out
                #generate_password $classLevel $below $pwout
                #pw=`cat $pwout`
                #rm $pwout
                pw=`generate_password $classLevel $below`
                rlLog "minlength=[$edge], current len [$below],password=[$pw]"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlFail "password change success is NOT expected"
                    currentPW=$pw
                else
                    rlPass "password change failed, this is expected"
                fi               

                ##############################################################
                # if password length = edge, password changing should success
                ##############################################################
                number=$RANDOM
                let "number %= 4"
                classLevel=$((number+1)) #classLevel rotate between 1-4
                #pwout=$TmpDir/pwout.$RANDOM.out
                rlLog "minlength=[$edge], current len [$edge],class=[$classLevel] number=[$number]"
                #generate_password $classLevel $edge $pwout
                #pw=`cat $pwout`
                #rm $pwout
                pw=`generate_password $classLevel $edge`
                rlLog "minlength=[$edge], current len [$edge],password=[$pw]"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "password change failed, this is NOT expected"
                fi               

                ##############################################################
                # if password length > edge, password changing should success
                ##############################################################
                upper=$((edge+1))
                number=$RANDOM
                let "number %= 4"
                classLevel=$((number+1)) #classLevel rotate between 1-4
                #pwout=$TmpDir/pwout.$RANDOM.out
                #generate_password $classLevel $upper $pwout
                #pw=`cat $pwout`
                #rm $pwout
                pw=`generate_password $classLevel $upper`
                rlLog "minlength=[$edge], current len [$upper],password=[$pw]"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "password change failed, this is NOT expected"
                fi               
            else
                rlFail "can not set minlength to [$edge]"
            fi
        done
        rm $out
    # test logic ends
} # ipapassword_grouppolicy_length_upperbound_logic 

ipapassword_grouppolicy_length_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_length_negative"
        rlLog "set length to negative integer or letter should fail"
        add_test_grp
        reset_group_pwpolicy
        KinitAsAdmin
        for length_value in -2 -1 a abc
        do
            ipapassword_grouppolicy_length_negative_logic $length_value
        done
    rlPhaseEnd
} #ipapassword_grouppolicy_length_negative

ipapassword_grouppolicy_length_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local v=$1
        rlRun "ipa pwpolicy-mod $testgrp --minlength=$v" 1 "expect to fail when minlength=[$v]"
    # test logic ends
} # ipapassword_grouppolicy_length_negative_logic 

ipapassword_nestedgroup_envsetup()
{
    rlPhaseStartSetup "ipapassword_nestedgroup_envsetup"
        #environment setup starts here
        prepare_nestedgrp_testenv
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_nestedgroup_envsetup

ipapassword_nestedgroup_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_nestedgroup_envcleanup"
        #environment cleanup starts here
        cleanup_nestedgrp_testenv
        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_nestedgroup_envcleanup

ipapassword_nestedgrouppw_maxlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_maxlife_conflict"
        # set other password policy constrain to 0
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp  \
                   --minlife=0 --history=0 --minclasses=0 --minlength=0"\
               0 "setup pwpolicy [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp \
                   --minlife=0 --history=0 --minclasses=0 --minlength=0"\
               0 "setup pwpolicy [$nestedgrp]"
        # member testac belongs to nestedgrp, who is member of testgrp
        # testgrp group-pwpolicy has priority 6
        # nestedgrp group-pwpolicy has prioirty 7
        # therefore user "testac" should follow testgrp (the one has lower number)
#FIXME
        maxlife=`getrandomint 2 10` # in days
        below=$((maxlife - 1 ))
        above=$((maxlife + 1 ))
        rlRun "ipa pwpolicy-mod $testgrp --maxlife=$maxlife" \
              0 "set maxlife for [$testgrp] to [$maxlife]"
        rlRun "ipa pwpolicy-mod $nestedgrp --maxlife=$below" \
              0 "set maxlife for [$nestedgrp] to [$below]"
        rlRun "$kdestroy"

        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "check current password"
        rlRun "$kdestroy"
        # set system one minute before $below, same password should work withoud password change prompt
        set_systime "+ $below * 24 * 60 * 60 - 1 * 60"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "no password change prompt"
        set_systime "+ 1 * 24 * 60 * 60 "
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "no password change prompt"
        set_systime "+ 2*60"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 1 "password change prompt"

        # reset the test ac
        add_test_ac
        append_test_nested_ac
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $nestedgrp --maxlife=$above" \
              0 "set maxlife for [$nestedgrp] to [$above]"
        rlRun "$kdestroy"

        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "check current password"
        rlRun "$kdestroy"
        # set system one minute before $below, same password should work withoud password change prompt
        set_systime "+ $maxlife * 24 * 60 * 60 - 1 * 60"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "no password change prompt"
        set_systime "+ 1 * 24 * 60 * 60 "
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 1 "no password change prompt"
        set_systime "+ 2*60"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 1 "password change prompt"

    rlPhaseEnd
} #ipapassword_nestedgrouppw_maxlife_conflict

ipapassword_nestedgrouppw_maxlife_conflict_logic()
{
    # accept parameters: 
    #   $1= maxlife of testgrp`
    #   $2= maxlife of nestedgrp
    #   $3= expected result
    # test logic starts
       # black
       echo "empty function" 
    # test logic ends
} # ipapassword_nestedgrouppw_maxlife_conflict_logic 

ipapassword_nestedgrouppw_minlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_minlife_conflict"
        rlLog "when group setting for minlife < global minlife setting"
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp \
                --maxlife=100 --history=0 --minclasses=0 --minlength=0"\
              0 "set other password constrains to 0 for [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp\
                --maxlife=100 --history=0 --minclasses=0 --minlength=0"\
              0 "set other password constrains to 0 for [$nestedgrp]"
        minlife=`getrandomint 2 100` # in hours
        below=$((minlife - 1))
        above=$((minlife + 1))
        rlRun "ipa pwpolicy-mod --minlife=$minlife $testgrp"  0 "set minlife to [$minlife] for [$tesgrp]"
        rlRun "ipa pwpolicy-mod --minlife=$below $nestedgrp"  0 "set minlife to [$below] for [$nestedgrp]"
        rlRun "$kdestroy"

        add_test_ac
        append_test_nested_ac
        currentPW=$testacPW
        set_systime "+ $minlife * 60 * 60 - 2 * 60" # set system two minutes before minlife
        rlRun "echo $currentPW | kinit $testac 2>&1 > /dev/null" 0  "check password before test"
        change_password $testac $currentPW "dummy123"
        if [ $? -eq 0 ];then
            rlFail "change password success is not expected"
            currentPW="dummy123"
        else
            rlPass "change password failed is expected"
        fi 
        set_systime "+ 3 * 60 " # set system one minutes after minlife
        rlRun "echo $currentPW | kinit $testac 2>&1 > /dev/null" 0  "check password before test"
        change_password $testac $currentPW "again_dummy123"
        if [ $? -eq 0 ];then
            rlPass "change password success is expected"
        else
            rlFail "change password failed is NOT expected"
        fi
    rlPhaseEnd
} #ipapassword_nestedgrouppw_minlife_conflict

ipapassword_nestedgrouppw_minlife_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        echo "empty function"
    # test logic ends
} # ipapassword_nestedgrouppw_minlife_conflict_logic 

ipapassword_nestedgrouppw_history_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_history_conflict"
        rlLog "when group setting for minlife < global minlife setting"
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp \
                --maxlife=100 --minlife=0 --minclasses=0 --minlength=0"\
              0 "set other password constrains to 0 for [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp\
                --maxlife=100 --minlife=0 --minclasses=0 --minlength=0"\
              0 "set other password constrains to 0 for [$nestedgrp]"
        history=`getrandomint 2 20` 
        below=$((history - 1))
        above=$((history + 1))
        rlRun "ipa pwpolicy-mod --history=$history $testgrp"  0 "set history to [$history] for [$tesgrp]"
        rlRun "ipa pwpolicy-mod --history=$below $nestedgrp"  0 "set history to [$below] for [$nestedgrp]"
        rlRun "$kdestroy"

        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_history_conflict_logic $history

        # change the history size of nestedgrp pwpolicy to above, and the actual effected historysize should
        # be the same as above
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod --history=$above $nestedgrp"  0 "set history to [$above] for [$nestedgrp]"
        rlRun "$kdestroy"
        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_history_conflict_logic $history

     rlPhaseEnd
} #ipapassword_nestedgrouppw_history_conflict

ipapassword_nestedgrouppw_history_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        local history=$1
        local currentPW=$testacPW
        local counter=1
        local passwordPool=" $currentPW"
        local failedPool=""
        local newPW=""

        while [ $counter -lt $history ];do
            newPW=`generate_password 4 10` #FIXME
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW "$newPW"
            if [ $? -eq 0 ];then
                passwordPool="$passwordPool $newPW"
                currentPW=$newPW
            else
                rlFail "change password failed is NOT expected"
            fi
            counter=$((counter+1))
        done
        # all password in password pool should not be reused
        for pw in $passwordPool
        do
            if [ $currentPW != $pw ];then
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
                change_password $testac $currentPW "$pw"
                if [ $? -eq 0 ];then
                    rlFail "password reuse [$pw] is NOT expected"
                    currentPW=$pw
                else
                    failedPool="$failedPool $pw"
                    rlPass "password reuse failed is expected"
                fi           
            fi
        done 
        # once we out of above loop, we should be able to change password
        newPW=`generate_password 4 10` #FIXME
        rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
        change_password $testac $currentPW "$newPW"
        if [ $? -eq 0 ];then
            rlPass "password change after [$history] times is expected"
        else
            rlFail "password change failed is NOT expected"
        fi
        rlLog "history size=[$history]"
        rlLog "passwordPool=[$passwordPool]"
        rlLog "failedPool  =[$failedPool]"

    # test logic ends
} # ipapassword_nestedgrouppw_history_conflict_logic 

ipapassword_nestedgrouppw_classes_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_classes_conflict"
        rlLog "when group classes > global classes"
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp \
                --maxlife=100 --minlife=0 --history=0 --minlength=0"\
              0 "set other password constrains to 0 for [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp\
                --maxlife=100 --minlife=0 --history=0 --minlength=0"\
              0 "set other password constrains to 0 for [$nestedgrp]"
        classes=`getrandomint 2 3` 
        below=$((classes - 1))
        above=$((classes + 1))
        rlRun "ipa pwpolicy-mod --minclasses=$classes $testgrp"  0 "set minclasses to [$classes] for [$tesgrp]"
        rlRun "ipa pwpolicy-mod --minclasses=$below $nestedgrp"  0 "set minclasses to [$below] for [$nestedgrp]"
        rlRun "$kdestroy"

        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_classes_conflict_logic $classes

        # change the minclasses setting of nestedgrp pwpolicy to above, and the actual effected minclasses should
        # be the same as above
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod --minclasses=$above $nestedgrp"  0 "set classes to [$above] for [$nestedgrp]"
        rlRun "$kdestroy"
        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_classes_conflict_logic $classes

    rlPhaseEnd
} #ipapassword_nestedgrouppw_classes_conflict

ipapassword_nestedgrouppw_classes_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        local classes=$1
        local i=1
        local j=0
        local badPasswordPool=""
        local goodPasswordPool=""
        local currentPW=""

        while [ $i -lt $classes ];do
            while [ $j -lt 8 ];do  #try 8 password to cover more class type
                badPW=`generate_password $i 10`
                badPasswordPool="$badPasswordPool $badPW"
                j=$((j+1))
            done
            i=$((i+1))
        done
        # after this loop, i==$classes
        j=0
        while [ $j -lt 8 ];do  #try 8 password to cover more class type
            goodPW=`generate_password $i 10`
            goodPasswordPool="$goodPasswordPool $goodPW"
            j=$((j+1))
        done
        currentPW="$testacPW"
        for pw in $badPasswordPool;do
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlFail "when class=[$classes]: password change to [$pw] is NOT expected"
                currentPW=$pw
            else
                rlPass "when class=[$classes]: password change to [$pw] failed is expected"
            fi
        done
        for pw in $goodPasswordPool;do
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlPass "when class=[$classes]: password change to [$pw] is expected"
                currentPW=$pw
            else
                rlFail "when class=[$classes]: password change to [$pw] failed is NOT expected"
            fi
        done
        rlLog "classes=[$classes]"
        rlLog "bad passwords=[$badPasswordPool]"
        rlLog "good passwords=[$goodPasswordPool]"
    # test logic ends
} # ipapassword_nestedgrouppw_classes_conflict_logic 

ipapassword_nestedgrouppw_length_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_length_conflict"
        rlLog "when group length > global length"
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp \
                --maxlife=100 --minlife=0 --minclasses=0 --history=0"\
              0 "set other password constrains to 0 for [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp\
                --maxlife=100 --minlife=0 --minclasses=0 --history=0"\
              0 "set other password constrains to 0 for [$nestedgrp]"
        length=`getrandomint 2 20` 
        below=$((length - 1))
        above=$((length + 1))
        rlRun "ipa pwpolicy-mod --minlength=$length $testgrp"  0 "set minlength to [$length] for [$tesgrp]"
        rlRun "ipa pwpolicy-mod --minlength=$below $nestedgrp"  0 "set minlength to [$below] for [$nestedgrp]"
        rlRun "$kdestroy"

        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_length_conflict_logic $length

        # change the history size of nestedgrp pwpolicy to above, and the actual effected historysize should
        # be the same as above
        KinitAsAdmin
        rlRun "ipa pwpolicy-mod --minlength=$above $nestedgrp"  0 "set minlength to [$above] for [$nestedgrp]"
        rlRun "$kdestroy"
        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_length_conflict_logic $length

    rlPhaseEnd
} #ipapassword_nestedgrouppw_length_conflict

ipapassword_nestedgrouppw_length_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        local length=$1
        local i=1
        local j=0
        local classes=0
        local badPasswordPool=""
        local goodPasswordPool=""
        local currentPW=""

        while [ $i -lt $length ];do
            while [ $j -lt 4 ];do  #try 4 password to cover more class type
                classes=`getrandomint 1 4`
                badPW=`generate_password $classes $i`
                badPasswordPool="$badPasswordPool $badPW"
                j=$((j+1))
            done
            i=$((i+1))
        done
        # after this loop, i==$length
        j=0
        while [ $j -lt 4 ];do  #try 4 password to cover more class type
            classes=`getrandomint 1 4`
            goodPW=`generate_password $classes $i`
            goodPasswordPool="$goodPasswordPool $goodPW"
            j=$((j+1))
        done
        currentPW="$testacPW"
        for pw in $badPasswordPool;do
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlFail "when length=[$length]: password change to [$pw] is NOT expected"
                currentPW=$pw
            else
                rlPass "when length=[$length]: password change to [$pw] failed is expected"
            fi
        done
        for pw in $goodPasswordPool;do
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlPass "when length=[$length]: password change to [$pw] is expected"
                currentPW=$pw
            else
                rlFail "when length=[$length]: password change to [$pw] failed is NOT expected"
            fi
        done
        rlLog "length=[$length]"
        rlLog "bad passwords=[$badPasswordPool]"
        rlLog "good passwords=[$goodPasswordPool]"
    # test logic ends
} # ipapassword_nestedgrouppw_length_conflict_logic 
