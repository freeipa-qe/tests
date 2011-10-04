
######################
# test suite         #
######################
ipapassword()
{
    ipapassword_envsetup
    ipapassword_globalpolicy
    ipapassword_grouppolicy
    ipapassword_nestedgroup
    ipapassword_attr
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
    ipapassword_globalpolicy_minlifetime_greater_maxlife_negative
    ipapassword_globalpolicy_history_default
    ipapassword_globalpolicy_history_lowerbound
    ipapassword_globalpolicy_history_upperbound
    ipapassword_globalpolicy_history_negative
    ipapassword_globalpolicy_classes_default
    ipapassword_globalpolicy_classes_lowerbound
    ipapassword_globalpolicy_classes_upperbound
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
    ipapassword_grouppolicy_classes_upperbound
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

ipapassword_attr()
{
    ipapassword_attr_envsetup
    ipapassword_attr_set
    ipapassword_attr_add
    ipapassword_attr_envcleanup
} #ipapassword_attr

######################
# test cases         #
######################
ipapassword_envsetup()
{
    rlPhaseStartSetup "ipapassword_envsetup"
        #environment setup starts here
        echo "Stop local ntpd service to sync with external source"
        service ntpd stop
        restore_systime  # sync system time with ntp server
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_envsetup

ipapassword_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_envcleanup"
        #environment cleanup starts here
        restore_systime
        Kcleanup
        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_envcleanup

ipapassword_globalpolicy_envsetup()
{
    rlPhaseStartSetup "ipapassword_globalpolicy_envsetup"
        #environment setup starts here
        rlRun "ipactl restart" 0 "restart all ipa related service to force sync time between kerberos server and other components, specially DS instance"
        Local_KinitAsAdmin
        reset_global_pwpolicy   # ensure we have defaul setting when we leave
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_globalpolicy_envsetup

ipapassword_globalpolicy_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_globalpolicy_envcleanup"
        #environment cleanup starts here
        reset_global_pwpolicy
        Kcleanup
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
        echo "[papassword_globalpolicy_maxlifetime_default] secnario 1: when minlife < system time < maxlife, user kinit should success, no prompt for password change"
        maxlife=`echo "$globalpw_maxlife * 24 * 60 * 60 " |bc `
        minlife=`echo "$globalpw_minlife * 60 * 60 " |bc`
        midpoint=`echo "($minlife + $maxlife)/2" |bc` 
        rlLog "mid point: [$midpoint]"
        set_systime "+ $midpoint"
        rlRun "$kdestroy"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "kinit as same password between minlife and max life should success"

        echo "[papassword_globalpolicy_maxlifetime_default] scenario 2: when system time > maxlife, ipa server should prompt for password change"
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
        Local_KinitAsAdmin
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
        Local_KinitAsAdmin
        for max_value in 100 99999
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
        Local_KinitAsAdmin 
        rlRun "ipa pwpolicy-mod --minlife=0" 0 "set minlife to 0"
        for maxlife_value in -2 abc
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "set precondition: history=[$history] minlength=[$length] classes=[$classes]"
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
            change_password $testac $testacPW "Dummyž@123"
            if [ $? = 0 ];then
                rlFail "password change success, this is not expected"
            else 
                rlPass "password change failed as expected"
            fi

            # after minlife, change passwod should success
            set_systime "+ 2*60"  # setsystime 2 minutes after
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "make sure currentPW work [$testacPW]"
            change_password $testac $testacPW "Dummyž@123"
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "set precondition: history=[$history] minlength=[$length] classes=[$classes]"
        if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            rlRun "ipa pwpolicy-mod --minlife=$lowbound" 0 "set to lowbound should success"
            rlLog "minlife has been setting to [$lowbound] hours"
            add_test_ac
            rlLog "after set minlife to 0, we should be able to change password anytime we wont"
            oldpw=$testacPW
            newpw="Dummyž@123"
            # be aware that after this loop the system time is actually being
            # pushed back total: 0+1+2+4+8+16+32=63 seconds
            #for offset in 0 1 2 4 8 16 32
            for offset in 0 2 8 32
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
    rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_upperbound_logic"
    # accept parameters: NONE
    # test logic starts
        rlLog "reset global pwpolicy"
        reset_global_pwpolicy
        maxlife=`echo "$globalpw_maxlife * 24 " | bc`
        counter=0
        previousvalue=$globalpw_minlife
        Local_KinitAsAdmin
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
    rlPhaseEnd
    # test logic ends
} # ipapassword_globalpolicy_minlifetime_upperbound_logic 

# Added by mgregg 5-5-11
# This is a test to ensure that bug https://bugzilla.redhat.com/show_bug.cgi?id=461325 and
# https://bugzilla.redhat.com/show_bug.cgi?id=461332 are closed
ipapassword_globalpolicy_minlifetime_greater_maxlife_negative()
{
	rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_greater_maxlife_negative"
                Local_KinitAsAdmin
		rlLog "attempt to set minlife greater than maxlife"
		rlRun "ipa pwpolicy-mod --maxlife=5" 0 "set pw maxlife to 5 days"
		rlRun "ipa pwpolicy-show | grep Max\ life | grep 5" 0 "ensure that the maxlife seems to be 5 days"
		rlRun "ipa pwpolicy-mod --minlife=150" 1 "ensure that we are unable to set the minlife to a value over 5 days"
		rlRun "ipa pwpolicy-mod --minlife=200" 1 "ensure that we are unable to set the minlife to a value over 5 days"
		rlRun "ipa pwpolicy-mod --minlife=300" 1 "ensure that we are unable to set the minlife to a value over 5 days"
		rlLog "reset global pwpolicy"
        	reset_global_pwpolicy
	rlPhaseEnd
}

ipapassword_globalpolicy_minlifetime_negative()
{
# looped data   :
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_minlifetime_negative"
        rlLog "minlife should only accept integer >=0"
        Local_KinitAsAdmin
        reset_global_pwpolicy
        for minlife_value in -2 a
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] classes=[$classes]"
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
        #number=$RANDOM
        #let "number %= 20"
        #N=`echo "$number + 2" | bc` # set N >= 2
        N=3
        pws="$testacPW"
        counter=1 #reset counter
        Local_KinitAsAdmin 
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] classes=[$classes] history=[$history]"
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
        #number=$RANDOM
        #let "number %= 10"
        #N=`echo "$number + 2" | bc` # set N >= 2
        N=4
        counter=0
        currentPW=$testacPW
        newPW="Dummyž@123"
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
        max=2 #test 2 times
        i=0
        Local_KinitAsAdmin 
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
        rlRun "ipa pwpolicy-mod --history=$v" 0 "set password history to integer [$v] should success"
    # test logic ends
} # ipapassword_globalpolicy_history_upperbound_logic 

ipapassword_globalpolicy_history_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_globalpolicy_history_negative"
        rlLog "negaive integer and letters are not acceptable for history size"
        testdata="-2 -1 a abc"
        Local_KinitAsAdmin 
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
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
            Local_KinitAsAdmin
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
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
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
        local pw
        for classLevel in 0 1
        do
            rlLog "test classLevel=[$classLevel]"
            Local_KinitAsAdmin
            ipa pwpolicy-mod --minclasses=$classLevel
            ipa pwpolicy-show > $out
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            temp=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            if [ $temp = $classLevel ];then
                add_test_ac
                rlLog "set classes to [$temp] success, test continue"
                # run same test 2 times, to ensure all password classes covered
                i=0
                currentPW=$testacPW
                num_of_test=2
                while [ $i -lt $num_of_test ]
                do
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
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
        for n in 5
        do
            Local_KinitAsAdmin
            ipa pwpolicy-mod --minclasses=$n
            ipa pwpolicy-show > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "get kerberos ticket for current user, prepare for password change"

                echo "[ipapassword_globalpolicy_classes_upperbound] scenario 1: when new password classes less than $n, password change should fail"
                minclasses=1 # when classes = 0 it has same effect as 1, 
                             #      we will test this in lowerbound test
                maxclasses=8 # when classes > 5, it has same effect as 4, 
                             #      we will test this in upperbound test
                classLevel=$minclasses
                while [ $classLevel -lt $n ]
                do
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
                echo "[ipapassword_globalpolicy_classes_upperbound] scenario 2: when new password classes equal or greater than $n, password change should sucess"
                currentPW=$testacPW
                while [ $classLevel -lt $maxclasses ]
                do  
                    #classesLevel will grow from n to 4
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
        for class_value in -1 abc
        do
            Local_KinitAsAdmin
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
        rlLog "disable other password policy constrains"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "precondition: minlife=[$minlife] minclasses=[$classes] history=[$history]"
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
            #let "number %= 4"
            #classLevel=$((number+1)) #classLevel rotate between 1-4
            classLevel=5
            rlLog "minlength=[$globalpw_length], current len [$length],class=[$classLevel] number=[$number]"
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
            #number=$RANDOM
            #let "number %= 4"
            #classLevel=$((number+1)) #classLevel rotate between 1-4
            classLevel=5
            rlLog "minlength=[$globalpw_length], current len [$length],class=[$classLevel] number=[$number]"
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
        rlLog "disable other password policy constrains"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 --minlength=0
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "precondition: minlife=[$minlife] minclasses=[$classes] history=[$history] minlength=[$length]"
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
        rlLog "disable other password policy constrains"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "precondition: minlife=[$minlife] minclasses=[$classes] history=[$history]"
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
        for edge in 10 100
        do
            #set minlength=edge
            Local_KinitAsAdmin
            ipa pwpolicy-mod --minlength=$edge > $out
            rlRun "$kdestroy"
            len=`grep "length" $out | cut -d":" -f2| xargs echo`
            if [ $len = $edge ];then
                rlLog "minlength=[$len], now continue test"
                ##############################################################
                # if password length < edge, password changing should fail
                ##############################################################
                below=$((edge-1))
                #number=$RANDOM
                #let "number %= 4"
                #classLevel=$((number+1)) #classLevel rotate between 1-4
                classLevel=5
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
                rlRun "$kdestroy"
                ##############################################################
                # if password length = edge, password changing should success
                ##############################################################
                #number=$RANDOM
                #let "number %= 4"
                #classLevel=$((number+1)) #classLevel rotate between 1-4
                classLevel=5
                rlLog "minlength=[$edge], current len [$edge],class=[$classLevel] number=[$number]"
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
                rlRun "$kdestroy"
                ##############################################################
                # if password length > edge, password changing should success
                ##############################################################
                upper=$((edge+1))
                #number=$RANDOM
                #let "number %= 4"
                #classLevel=$((number+1)) #classLevel rotate between 1-4
                classLevel=5
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
                rlRun "$kdestroy"
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
        Local_KinitAsAdmin
        for length_value in -2 a
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
        rlRun "ipactl restart" 0 "restart all ipa related service to force sync time between kerberos server and other components, specially DS instance"
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
        echo "password will not expire before maxlife of group pwpolicy"
        local maxlife=`echo "$grouppw_maxlife * 24 * 60 * 60 " |bc `
        local minlife=`echo "$grouppw_minlife * 60 * 60 " |bc`
        local midpoint=`echo "($minlife + $maxlife)/2" |bc` 
        echo "mid point: [$midpoint]"
        set_systime "+ $midpoint"
        rlRun "$kdestroy"
        rlRun "echo $testacPW | kinit $testac" 0 "kinit use same password between minlife and max life should success"
        rlRun "$kdestroy"

        rlLog "when system time > maxlife, ipa server should prompt for password change"
        set_systime "+ $midpoint + $midpoint + $midpoint"  # set system time after the max life
        kinit_aftermaxlife $testac $testacPW $testacNEWPW

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
        Local_KinitAsAdmin
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
        Local_KinitAsAdmin
        for max_value in 100 99999
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
        Local_KinitAsAdmin 
        rlRun "ipa pwpolicy-mod $testgrp --minlife=0" 0 "set minlife to 0"
        for maxlife_value in -1 abc
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

        Local_KinitAsAdmin
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
        Local_KinitAsAdmin
        for life in -1 abc ;do
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] classes=[$classes]"
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
        #number=$RANDOM
        #let "number %= 20"
        #N=`echo "$number + 2" | bc` # set N >= 2
        N=3
        pws="$testacPW"
        counter=1 #reset counter
        Local_KinitAsAdmin 
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
        local lowbound=0
        add_test_ac
        add_test_grp
        append_test_member
        reset_group_pwpolicy
        rlLog "lowerbound of password history is $lowbound"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        #history=`read_pwpolicy "history" $testgrp`
        echo "====================================history=[$history]"
        rlLog "precondition: minlife=[$minlife] minlength=[$length] classes=[$classes] history=[$history]"
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
        #number=$RANDOM
        #let "number %= 10"
        #N=`echo "$number + 2" | bc` # set N >= 2
        N=3
        counter=0
        currentPW=$testacPW
        newPW="Dummyž@123"
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
        local lastvalue=$RANDOM
        local max=2 #test 2 times
        local i=0
        Local_KinitAsAdmin 
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
        rlRun "ipa pwpolicy-mod $testgrp --history=$v" 0 "set password history to integer [$v] should success"
    # test logic ends
} # ipapassword_grouppolicy_history_upperbound_logic 

ipapassword_grouppolicy_history_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_grouppolicy_history_negative"
        rlLog "negaive integer and letters are not acceptable for history size"
        local testdata="-2 -1 a abc"
        Local_KinitAsAdmin 
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_default_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
        rm $out
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
            Local_KinitAsAdmin
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
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_lowerbound_logic
        else
            rlFail "can not set precondition for minclasses test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_grouppolicy_classes_lowerbound

ipapassword_grouppolicy_classes_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local classLevel
        local temp
        local out=$TmpDir/classeslowerbound.$RANDOM.out
        local pw
        for classLevel in 0 1
        do
            rlLog "test classLevel=[$classLevel]"
            Local_KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minclasses=$classLevel
            ipa pwpolicy-show $testgrp > $out
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            temp=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            if [ $temp = $classLevel ];then
                add_test_ac
                append_test_member
                rlLog "set classes to [$temp] success, test continue"
                # run same test 2 times, to ensure all password classes covered
                i=0
                currentPW=$testacPW
                num_of_test=2
                while [ $i -lt $num_of_test ]
                do
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
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        add_test_grp
        reset_group_pwpolicy
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
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
        for n in 5
        do
            Local_KinitAsAdmin
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
        for class_value in -1 abc
        do
            Local_KinitAsAdmin
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
        rlLog "disable other password policy constrains"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "precondition: minlife=[$minlife] minclasses=[$classes] history=[$history]"
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
        local currentPW=""
        # scenario 1: password change should fail when length < $globalpw_length
        add_test_ac
        append_test_member
        currentPW=$testacPW
        while [ $length -lt $grouppw_length ]
        do
            #number=$RANDOM
            #let "number %= 4"
            #classLevel=$((number+1)) #classLevel rotate between 1-4
            classLevel=5
            rlLog "minlength=[$grouppw_length], current len [$length],class=[$classLevel] number=[$number]"
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$grouppw_length], current len [$length],next password=[$pw]"
            rlRun "echo $currentPW| kinit $testac 2>&1 >/dev/null" 0 "validating current password [$currentPW]"
            change_password $testac $testacPW $pw    
            if [ $? = 0 ];then
                rlFail "password change success is not expected"
                currentPW=$pw
            else
                rlPass "password change failed, this is expected"
            fi
            length=$((length+1))
            rlRun "$kdestroy"
        done

        # scenario 2: password change should success when length < $globalpw_length
        while [ $length -lt $maxlength ]
        do
            #number=$RANDOM
            #let "number %= 4"
            #classLevel=$((number+1)) #classLevel rotate between 1-4
            classLevel=5
            rlLog "minlength=[$grouppw_length], current len [$length],class=[$classLevel] number=[$number]"
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$grouppw_length], current len [$length],next password=[$pw]"
            rlRun "echo \"$currentPW\" | kinit $testac 2>&1 >/dev/null" 0 "validating current password [$currentPW]"
            change_password $testac $currentPW $pw    
            if [ $? = 0 ];then
                rlPass "password change success is expected"
                currentPW=$pw
            else
                rlFail "password change failed, this is NOT expected"
            fi
            length=$((length+1))
            rlRun "$kdestroy"
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
        rlLog "disable other password policy constrains"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minclasses=0 --history=0 --minlength=0
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "precondition: minlife=[$minlife] minclasses=[$classes] history=[$history] minlength=[$length]"
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
        rlLog "disable other password policy constrains"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxlife=$grouppw_maxlife --minlife=0 --minclasses=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rm $out
        rlRun "$kdestroy"
        rlLog "precondition: minlife=[$minlife] minclasses=[$classes] history=[$history]"
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
        for edge in 20 100
        do
            #set minlength=edge
            Local_KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minlength=$edge > $out
            echo "============= [$testgrp] pwpolicy =========="
            cat $out
            echo "============================================"
            rlRun "$kdestroy"
            len=`grep "length" $out | cut -d":" -f2| xargs echo`
            rlLog "len=[$len] edge=[$edge]"
            if [ $len = $edge ];then
                rlLog "minlength=[$len], now continue test"
                ##############################################################
                # if password length < edge, password changing should fail
                ##############################################################
                below=$((edge-1))
                #number=$RANDOM
                #let "number %= 4"
                #classLevel=$((number+1)) #classLevel rotate between 1-4
                classLevel=5
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
                #number=$RANDOM
                #let "number %= 4"
                #classLevel=$((number+1)) #classLevel rotate between 1-4
                classLevel=5
                rlLog "minlength=[$edge], current len [$edge],class=[$classLevel] number=[$number]"
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
                #number=$RANDOM
                #let "number %= 4"
                #classLevel=$((number+1)) #classLevel rotate between 1-4
                classLevel=5
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
        Local_KinitAsAdmin
        for length_value in -1 abc
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
        rlRun "ipactl restart" 0 "restart all ipa related service to force sync time between kerberos server and other components, specially DS instance"
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
        Local_KinitAsAdmin
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
        Local_KinitAsAdmin
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
        Local_KinitAsAdmin
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
        change_password $testac $currentPW "Dummyž@123"
        if [ $? -eq 0 ];then
            rlFail "change password success is not expected"
            currentPW="Dummyž@123"
        else
            rlPass "change password failed is expected"
        fi 
        set_systime "+ 3 * 60 " # set system one minutes after minlife
        rlRun "echo $currentPW | kinit $testac 2>&1 > /dev/null" 0  "check password before test"
        change_password $testac $currentPW "again_Dummyž@123"
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
        Local_KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp \
                --maxlife=100 --minlife=0 --minclasses=0 --minlength=0"\
              0 "set other password constrains to 0 for [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp\
                --maxlife=100 --minlife=0 --minclasses=0 --minlength=0"\
              0 "set other password constrains to 0 for [$nestedgrp]"
        history=`getrandomint 2 20` 
        below=$((history - 1))
        above=$((history + 1))
        rlRun "ipa pwpolicy-mod --history=$history $testgrp"  0 "set history to [$history] for [$testgrp]"
        rlRun "ipa pwpolicy-mod --history=$below $nestedgrp"  0 "set history to [$below] for [$nestedgrp]"
        rlRun "$kdestroy"

        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_history_conflict_logic $history

        # change the history size of nestedgrp pwpolicy to above, and the actual effected historysize should
        # be the same as above
        Local_KinitAsAdmin
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
            newPW=`generate_password 4 10`
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
        newPW=`generate_password 4 10` 
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
        Local_KinitAsAdmin
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
        Local_KinitAsAdmin
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
            while [ $j -lt 6 ];do  #try 6 password to cover more class type
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
        Local_KinitAsAdmin
        rlRun "ipa pwpolicy-mod $testgrp \
                --maxlife=100 --minlife=0 --minclasses=0 --history=0"\
              0 "set other password constrains to 0 for [$testgrp]"
        rlRun "ipa pwpolicy-mod $nestedgrp\
                --maxlife=100 --minlife=0 --minclasses=0 --history=0"\
              0 "set other password constrains to 0 for [$nestedgrp]"
        #length=`getrandomint 2 20` 
        length=10
        below=$((length - 1))
        above=$((length + 1))
        rlRun "ipa pwpolicy-mod --minlength=$length $testgrp"  0 "set minlength to [$length] for [$testgrp]"
        rlRun "ipa pwpolicy-mod --minlength=$below $nestedgrp"  0 "set minlength to [$below] for [$nestedgrp]"
        rlRun "$kdestroy"

        add_test_ac
        append_test_nested_ac
        ipapassword_nestedgrouppw_length_conflict_logic $length

        # change the history size of nestedgrp pwpolicy to above, and the actual effected historysize should
        # be the same as above
        Local_KinitAsAdmin
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

        i=$((length-1)) 
        classes=3
        badPW=`generate_password $classes $i`
        badPasswordPool="$badPW"
        classes=5
        badPW=`generate_password $classes $i`
        badPasswordPool="$badPasswordPool $badPW"

        i=$((length+1))
        classes=3
        goodPW=`generate_password $classes $i`
        goodPasswordPool="$goodPW"
        classes=5
        goodPW=`generate_password $classes $i`
        goodPasswordPool="$goodPasswordPool $goodPW"

#        while [ $i -lt $length ];do
#            while [ $j -lt 4 ];do  #try 4 password to cover more class type
#                classes=`getrandomint 1 4`
#                badPW=`generate_password $classes $i`
#                badPasswordPool="$badPasswordPool $badPW"
#                j=$((j+1))
#            done
#            i=$((i+1))
#        done
#        # after this loop, i==$length
#        j=0
#        while [ $j -lt 4 ];do  #try 4 password to cover more class type
#            classes=`getrandomint 1 4`
#            goodPW=`generate_password $classes $i`
#            goodPasswordPool="$goodPasswordPool $goodPW"
#            j=$((j+1))
#        done

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

ipapassword_attr_envsetup()
{
    rlPhaseStartSetup "ipapassword_attr_envsetup"
        #environment setup starts here
        # objectclasses: ( 2.16.840.1.113719.1.301.6.14.1 
        #   NAME 'krbPwdPolicy' SUP top 
        #   STRUCTURAL MUST cn 
        #   MAY ( krbMaxPwdLife $ krbMinPwdLife $ krbPwdMinDiffChars 
        #               $ krbPwdMinLength $ krbPwdHistoryLength ) )
        rlRun "ipactl restart" 0 "restart all ipa related service to force sync time between kerberos server and other components, specially DS instance"
        add_test_grp
        reset_group_pwpolicy
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_attr_envsetup


ipapassword_attr_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_attr_envcleanup"
        #environment cleanup starts here
        del_test_grp
        #environment cleanup ends   here
    rlPhaseEnd
} #ipapassword_attr_envcleanup

ipapassword_attr_set()
{
    ipapassword_attr_set_krbMaxPwdLife
    ipapassword_attr_set_krbMaxPwdLife_negative
    ipapassword_attr_set_krbMinPwdLife
    ipapassword_attr_set_krbMinPwdLife_negative
    ipapassword_attr_set_krbPwdMinDiffChars
    ipapassword_attr_set_krbPwdMinDiffChars_negative
    ipapassword_attr_set_krbPwdMinLength
    ipapassword_attr_set_krbPwdMinLength_negative
    ipapassword_attr_set_krbPwdHistoryLength
    ipapassword_attr_set_krbPwdHistoryLength_negative
} #ipapassword_attr_set

ipapassword_attr_set_krbMaxPwdLife()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_attr_set_krbMaxPwdLife"
        local attr=krbMaxPwdLife
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 0 ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_set_krbMaxPwdLife

ipapassword_attr_set_krbMaxPwdLife_negative()
{
    rlPhaseStartTest "ipapassword_attr_set_krbMaxPwdLife_negative"
        local attr=krbMaxPwdLife
        local value=`getrandomstring`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_set_krbMaxPwdLife_negative

ipapassword_attr_set_krbMinPwdLife()
{
    rlPhaseStartTest "ipapassword_attr_set_krbMinPwdLife"
        local attr=krbMinPwdLife
        local value=`getrandomint`
        Local_KinitAsAdmin
        maxlife=`ipa pwpolicy-show $testgrp --all | grep -i "max lifetime" | cut -d":" -f2 | xargs echo`
        max=`echo "$maxlife * 24" | bc`
        minvalue=`getrandomint $max `
        ipapassword_attr_set_logic $attr "$minvalue" 0 ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_set_krbMinPwdLife

ipapassword_attr_set_krbMinPwdLife_negative()
{
    rlPhaseStartTest "ipapassword_attr_set_krbMinPwdLife_negative"
        local attr=krbMinPwdLife
        local value=`getrandomstring`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 1 "ipa: ERROR: invalid 'krbminpwdlife': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbMinPwdLife_negative

ipapassword_attr_set_krbPwdMinDiffChars()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdMinDiffChars"
        local attr=krbPwdMinDiffChars
        Local_KinitAsAdmin
        for value in 5 4 3 2 1
        do
            rlLog "set minimum classes to [$value]"
            ipapassword_attr_set_logic $attr $value 0 ""
        done
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdMinDiffChars

ipapassword_attr_set_krbPwdMinDiffChars_negative()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdMinDiffChars_negative"
        local attr=krbPwdMinDiffChars
        local value=`getrandomint 6 50000`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 1 "ipa: ERROR: invalid 'minclasses': can be at most 5"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdMinDiffChars_negative

ipapassword_attr_set_krbPwdMinLength()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdMinLength"
        local attr=krbPwdMinLength
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 0 ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdMinLength

ipapassword_attr_set_krbPwdMinLength_negative()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdMinLength_negative"
        local attr=krbPwdMinLength
        local value=`getrandomstring`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr "-$value" 1 "ipa: ERROR: invalid 'krbpwdminlength': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdMinLength_negative

ipapassword_attr_set_krbPwdHistoryLength()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdHistoryLength"
        local attr=krbPwdHistoryLength
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 0 ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdHistoryLength

ipapassword_attr_set_krbPwdHistoryLength_negative()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdHistoryLength_negative"
        local attr=krbPwdHistoryLength
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr "-$value" 1 "ipa: ERROR: invalid 'history': must be at least 0"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdHistoryLength_negative

ipapassword_attr_set_logic()
{
    # accept parameters: attribute name , attribute value, expected result, error message
        local attr=$1
        local value=$2
        local expected=$3
        local errmsg=$4
        local out=$TmpDir/attrsetlogic.$RANDOM.out
        rlLog "set [$attr] to [$value], expect [$expected], errmsg=[$errmsg]"
        ipa pwpolicy-mod $testgrp --setattr="$attr"="$value" 2>$out
        local ret=$?
        if [ "$ret" = "$expected" ];then
            rlPass "expect result [$expected] matches"
        else
            rlFail "expected [$expected], actual [$ret]";
        fi
        if [ "$expected" = "1" ] || [ "$ret" = "1" ] || [ ! -z "$errmsg" ];then
            if grep -i "$errmsg" $out 2>&1 >/dev/null
            then
                rlPass "error msg matches with output"
            else
                rlFail "error msg not found in output file"
                echo "============== output ====================="
                cat $out
                echo "==========================================="
            fi
        fi
        rm $out
} #ipapassword_attr_set_logic

ipapassword_attr_add()
{
    ipapassword_attr_add_krbMaxPwdLife
    ipapassword_attr_add_krbMaxPwdLife_negative
    ipapassword_attr_add_krbMinPwdLife
    ipapassword_attr_add_krbMinPwdLife_negative
    ipapassword_attr_add_krbPwdMinDiffChars
    ipapassword_attr_add_krbPwdMinDiffChars_negative
    ipapassword_attr_add_krbPwdMinLength
    ipapassword_attr_add_krbPwdMinLength_negative
    ipapassword_attr_add_krbPwdHistoryLength
    ipapassword_attr_add_krbPwdHistoryLength_negative
} #ipapassword_attr_add

ipapassword_attr_add_krbMaxPwdLife()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_attr_add"
        for attr in $pwpolicyattrs; do
            Local_KinitAsAdmin
            ipapassword_attr_add_logic $attr
            rlRun "$kdestroy"
        done
    rlPhaseEnd
} #ipapassword_attr_add_krbMaxPwdLife

ipapassword_attr_add_krbMaxPwdLife()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_attr_add_krbMaxPwdLife"
        local attr=krbMaxPwdLife
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMaxPwdLife

ipapassword_attr_add_krbMaxPwdLife_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbMaxPwdLife_negative"
        local attr=krbMaxPwdLife
        local value=`getrandomstring`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMaxPwdLife_negative

ipapassword_attr_add_krbMinPwdLife()
{
    rlPhaseStartTest "ipapassword_attr_add_krbMinPwdLife"
        local attr=krbMinPwdLife
        local value=`getrandomint`
        Local_KinitAsAdmin
        maxlife=`ipa pwpolicy-show $testgrp --all | grep -i "max lifetime" | cut -d":" -f2 | xargs echo`
        max=`echo "$maxlife * 24" | bc`
        minvalue=`getrandomint $max `
        ipapassword_attr_add_logic $attr "$minvalue" 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMinPwdLife

ipapassword_attr_add_krbMinPwdLife_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbMinPwdLife_negative"
        local attr=krbMinPwdLife
        local value=`getrandomstring`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 "ipa: ERROR: invalid 'krbminpwdlife': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMinPwdLife_negative

ipapassword_attr_add_krbPwdMinDiffChars()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinDiffChars"
        local attr=krbPwdMinDiffChars
        local value=`getrandomint 1 5`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinDiffChars

ipapassword_attr_add_krbPwdMinDiffChars_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinDiffChars_negative"
        local attr=krbPwdMinDiffChars
        local value=`getrandomint 6 50000`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 "ipa: ERROR: invalid 'minclasses': can be at most 5"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinDiffChars_negative

ipapassword_attr_add_krbPwdMinLength()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinLength"
        local attr=krbPwdMinLength
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinLength

ipapassword_attr_add_krbPwdMinLength_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinLength_negative"
        local attr=krbPwdMinLength
        local value=`getrandomstring`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr "-$value" 1 "ipa: ERROR: invalid 'krbpwdminlength': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinLength_negative

ipapassword_attr_add_krbPwdHistoryLength()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdHistoryLength"
        local attr=krbPwdHistoryLength
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value 1 ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdHistoryLength

ipapassword_attr_add_krbPwdHistoryLength_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdHistoryLength_negative"
        local attr=krbPwdHistoryLength
        local value=`getrandomint`
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr "-$value" 1 "ipa: ERROR: invalid 'history': must be at least 0"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdHistoryLength_negative

ipapassword_attr_add_logic()
{
    # accept parameters: attribute name , attribute value, expected result, error message
        local attr=$1
        local value=$2
        local expected=$3
        local errmsg=$4
        local out=$TmpDir/attrsetlogic.$RANDOM.out
        rlLog "add value [$value] to attr:[$attr], expect [$expected], errmsg=[$errmsg]"
        ipa pwpolicy-mod $testgrp --addattr "$attr"="$value" 2>$out
        local ret=$?
        if [ "$ret" = "$expected" ];then
            rlPass "addattr result matches expection [$expected]"
        else
            rlFail "addattr expect: [$expected], actual [$ret]"
        fi
        if [ "$ret" = "1" ] || [ "$expected" = "1" ] || [ ! -z "$errmsg" ];then
            if grep -i "$errmsg" $out 2>&1 >/dev/null
            then
                rlPass "error msg matches with output"
            else
                rlFail "error msg not found in output file"
                echo "============== output ====================="
                cat $out
                echo "==========================================="
            fi
        fi
        rm $out
} #ipapassword_attr_add_logic

