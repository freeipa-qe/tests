
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
    ipapassword_bugzillas
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
    ipapassword_globalpolicy_classes_upperbound
    ipapassword_globalpolicy_classes_negative
    ipapassword_globalpolicy_length_default
    ipapassword_globalpolicy_length_lowerbound
    ipapassword_globalpolicy_length_upperbound
    ipapassword_globalpolicy_length_negative
    ipapassword_globalpolicy_pkey_only
    ipapassword_globalpolicy_envcleanup
} #ipapassword_globalpolicy

ipapassword_grouppolicy()
{
    ipapassword_grouppolicy_envsetup
    ipapassword_grouppolicy_maxlifetime_default # this one always failed, i couldn't figure it out why
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

ipapassword_bugzillas()
{
    bz_818836
    bz_461332 # original ipapassword_globalpolicy_minlifetime_greater_maxlife_negative
} # Tests for pwpolicy bugzillas

######################
# test cases         #
######################
ipapassword_envsetup()
{
    rlPhaseStartSetup "ipapassword_envsetup"
        #environment setup starts here
        rlPass "no environment setup for password suite"
        #environment setup ends   here
    rlPhaseEnd
} #ipapassword_envsetup

ipapassword_envcleanup()
{
    rlPhaseStartCleanup "ipapassword_envcleanup"
        #environment cleanup starts here
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
        echo "---- ipactl report before [kinit $testac]---"
        ipactl status
        echo "----------------------"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "kinit as same password between minlife and max life should success"
        echo "---- ipactl report after [kinit $testac]---"
        ipactl status
        echo "----------------------"

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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
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
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$testacPW] for user [$testac]"
            change_password $testac $testacPW $dummyPW
            if [ $? = 0 ];then
                rlFail "FAIL - password change success, this is not expected"
            else 
                rlPass "password change failed as expected"
            fi

            # after minlife, change passwod should success
            set_systime "+ 2*60"  # setsystime 2 minutes after
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$testacPW] for user [$testac]"
            change_password $testac $testacPW $dummyPW
            if [ $? = 0 ];then
                rlPass "password change success, this is expected"
            else
                rlFail "FAIL - password change failed is not expected"
            fi
            del_test_ac
        else
            rlFail "FAIL - can not set pre-condition"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
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
            newpw=$dummyPW
            # be aware that after this loop the system time is actually being
            # pushed back total: 0+1+2+4+8+16+32=63 seconds
            for offset in 0 2 8 32
            do
                set_systime "+ $offset"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $oldpw | kinit $testac 2>&1 >/dev/null" 0 "verify password [$oldpw] for user [$testac]"
                change_password $testac $oldpw $newpw
                if [ $? = 0 ];then
                    rlPass "password change success, this is expected"
                    #swap the password
                    tmp=$oldpw
                    oldpw=$newpw
                    newpw=$tmp 
                else
                    rlFail "FAIL - password change failed is not expected"
                fi
            done
            del_test_ac
        else
            rlFail "FAIL - can not set pre-condition for minlife lowbound test"
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
        rlRun "rlDistroDiff keyctl"
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
bz_461332()
{
	rlPhaseStartTest "bug: 461332 ipapassword_globalpolicy_minlifetime_greater_maxlife_negative"
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --minclasses=1 
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
            rlFail "FAIL - can not set precondition for history test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_globalpolicy_history_default

ipapassword_globalpolicy_history_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        # set history to N, then N history password can not be used
        local N=3
        local pws="$testacPW"
        local counter=1 #reset counter
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        kinitAs $testac $testacPW
        counter=1 #reset counter
		# changing to -le to force all to be added to history since first was missing
        while [ $counter -le $N ]
        do
            next=$((counter+1))
			[ $next -gt $N ] && next=1 # Start over if beyond end of list
            currentPW=`echo $pws | cut -d" " -f$counter`
            nextPW=`echo $pws |cut -d" " -f$next`
            rlLog "counter=[$counter] currentpw[$currentPW], nextpw[$nextPW]"
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
            change_password $testac $currentPW $nextPW
            if [ $? = 0 ];then
                rlPass "password change success, current working password [$nextPW]"
            else
                rlFail "FAIL - set password to [$nextPW] failed isnot expected"
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
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
            change_password $testac $currentPW $p
            if [ $? = 0 ];then
                rlFail "FAIL - password [$p] reuse success is not expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
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
            rlFail "FAIL - can not set precondition for history test"
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
        rlRun "rlDistroDiff keyctl"
        kinitAs $testac $testacPW
        N=4
        counter=0
        currentPW=$testacPW
        newPW=$dummyPW
        rlLog "keep change password [$N] times with two password:[$currentPW] & [$newPW]"
        while [ $counter -lt $N ] #password is $oldpw when out of this loop
        do
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
            change_password $testac $currentPW $newPW
            if [ $? = 0 ];then
                rlPass "[$counter] change success, current password [$newPW]"
                #swap the password
                tmp=$currentPW
                currentPW=$newPW
                newPW=$tmp 
            else
                rlFail "FAIL - [$counter] password change failed"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_globalpolicy_classes_default_logic
        else
            rlFail "FAIL - can not set precondition for minclasses test"
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
            rlRun "rlDistroDiff keyctl"
            Local_KinitAsAdmin
            ipa pwpolicy-mod --minclasses=$n
            ipa pwpolicy-show > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "rlDistroDiff keyctl"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$testacPW] for user [$testac]"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "FAIL - password change success is not expected"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "FAIL - password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
                del_test_ac
            else
                rlFail "FAIL - set minclasses to [$n] failed"
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
        rlRun "rlDistroDiff keyctl"
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
            rlFail "FAIL - can not set precondition for minclasses test"
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
            rlRun "rlDistroDiff keyctl"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
                    change_password $testac $currentPW $pw
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW=$pw
                    else
                        rlFail "FAIL - password change failed, this is not expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_globalpolicy_classes_upperbound_logic
        else
            rlFail "FAIL - can not set precondition for minclasses test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_globalpolicy_classes_upperbound

ipapassword_globalpolicy_classes_upperbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        local out=$TmpDir/classesupperbound.$RANDOM.out
        local class5=5
        local class4=4
        local testid=$RANDOM
        local pw5Class="5Class_ž${testid}"
        local pw4Class="4Class_${testid}"
        local pw3Class="3CLASS_${testid}"
        # test scenario one: set minclasses to 5, then create user, 
        #                    user kinit first time with 5 classes password should pass
        #                    as of June 5, 2012, it failes due to bug: 828569
        rlRun "rlDistroDiff keyctl"
        add_test_ac $pw5Class
        if [ $? = 0 ];then
            rlPass "first time kinit with class 5 password success"
        else
            rlFail "FAIL - first time kinit with class 5 password failed, bug id=828569"
        fi

        # test scenario two: after first kinit, change minclasses=5, after this change
        #                    user can only change password to the one that has 5 classes
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --minclasses=$class4 --minlife=0 --history=0 --minlength=1
        add_test_ac $pw4Class

        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --minclasses=$class5

        # change to class 3 passwrod should fail
        currentPW=$pw4Class
        rlRun "rlDistroDiff keyctl"
        Local_kinit $testac $currentPW
        change_password $testac $currentPW $pw3Class
        if [ $? = 0 ];then
            rlFail "FAIL - password change to class 3 success is not expected"
            currentPW=$pw3Class
        else
            rlPass "password change to class 3 failed, this is expected"
        fi

        # change to class 5 passwrod should success 
        rlRun "rlDistroDiff keyctl"
        Local_kinit $testac $currentPW
        change_password $testac $currentPW $pw5Class
        if [ $? = 0 ];then
            rlPass "password change to class 5 success is expected"
        else
            rlFail "FAIL - password change to class 5 failed, this is NOT expected"
        fi
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
            rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
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
            rlFail "FAIL - can not set precondition for password length test"
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
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
            change_password $testac $testacPW $pw    
            if [ $? = 0 ];then
                rlFail "FAIL - password change success is not expected"
            else
                rlPass "password change failed, this is expected"
            fi
            length=$((length+1))
        done

        # scenario 2: password change should success when length < $globalpw_length
        currentPW=$testacPW
        while [ $length -lt $maxlength ]
        do
            classLevel=5
            rlLog "minlength=[$globalpw_length], current len [$length],class=[$classLevel] number=[$number]"
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$globalpw_length], current len [$length],password=[$pw]"
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
            change_password $testac $currentPW $pw    
            if [ $? = 0 ];then
                rlPass "password change success is expected"
                currentPW=$pw
            else
                rlFail "FAIL - password change failed, this is NOT expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 --minlength=0
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
            rlFail "FAIL - can not set precondition for password length test"
        fi
    rlPhaseEnd
} #ipapassword_globalpolicy_length_lowerbound

ipapassword_globalpolicy_length_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "there is only one password has length 0: empty string"
        rlRun "rlDistroDiff keyctl"
        kinitAs $testac $testacPW
        nullpassword=""
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
        change_password $testac $testacPW "$nullpassword"
        if [ $? = 0 ];then
            rlFail "FAIL - password change success is not expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
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
            rlFail "FAIL - can not set precondition for password length upper bound test"
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
            rlRun "rlDistroDiff keyctl"
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
                classLevel=5
                pw=`generate_password $classLevel $below`
                rlLog "minlength=[$edge], current len [$below],password=[$pw]"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlFail "FAIL - password change success is NOT expected"
                    currentPW=$pw
                else
                    rlPass "password change failed, this is expected"
                fi               
                rlRun "$kdestroy"
                ##############################################################
                # if password length = edge, password changing should success
                ##############################################################
                classLevel=5
                rlLog "minlength=[$edge], current len [$edge],class=[$classLevel] number=[$number]"
                pw=`generate_password $classLevel $edge`
                rlLog "minlength=[$edge], current len [$edge],password=[$pw]"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "FAIL - password change failed, this is NOT expected"
                fi               
                rlRun "$kdestroy"
                ##############################################################
                # if password length > edge, password changing should success
                ##############################################################
                upper=$((edge+1))
                classLevel=5
                pw=`generate_password $classLevel $upper`
                rlLog "minlength=[$edge], current len [$upper],password=[$pw]"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "FAIL - password change failed, this is NOT expected"
                fi               
                rlRun "$kdestroy"
            else
                rlFail "FAIL - can not set minlength to [$edge]"
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

ipapassword_globalpolicy_pkey_only()
{
    rlPhaseStartTest "ipapassword_globalpolicy_pkey_only: --pkey-only test of pwpolicy"
   rlRun "rlDistroDiff keyctl"
    Local_KinitAsAdmin
	ipa group-add --desc=kljh pwpolicyg
	ipa group-add --desc=kljh pwpolicygb
	ipa_command_to_test="pwpolicy"
	pkey_addstringa="--priority=20"
	pkey_addstringb="--priority=21"
	pkeyobja="pwpolicyg"
	pkeyobjb="pwpolicygb"
	grep_string='Group'
	general_search_string=pwpolicy
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in pwpolicy-find"
	ipa group-del pwpolicyg 
	ipa group-del pwpolicygb 
    rlPhaseEnd
}

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
        local maxlife_in_second=`echo "$grouppw_maxlife * 24 * 60 * 60 " |bc `
        local minlife_in_second=`echo "$grouppw_minlife * 60 * 60 " |bc`
        local midpoint_in_second=`echo "($minlife_in_second + $maxlife_in_second)/2" |bc` 

        rlLog "reset user password to trigger password policy maxlife constrains"
        set_systime "+ $minlife_in_second"
        change_password $testac $testacPW $testacNEWPW
        currentPW=$testacNEWPW
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac" 0 "ensure the current password [$currentPW]"

        rlLog "password will not expire before maxlife of group pwpolicy"
        rlLog "maxlife [$grouppw_maxlife] days, minlife [$grouppw_minlife] hours mid point: [$midpoint_in_second] seconds"
        set_systime "+ $midpoint_in_second"
        rlRun "$kdestroy"
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac" 0 "kinit use same password between minlife and max life should success"
        rlRun "$kdestroy"

        rlLog "when system time > maxlife, ipa server should prompt for password change"
        set_systime "+ $maxlife_in_second - $midpoint_in_second + 60"  # set system time after the max life
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac" 1 "kinit after maxlife should fail"
        #kinit_aftermaxlife $testac $testacPW $testacNEWPW

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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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

        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
    # notes; bug: 810900 , if bug fixed, this test case will report "pass"
    rlPhaseStartTest "ipapassword_grouppolicy_history_default"
        local out=$TmpdIR/globalpolicyhistorydefault.$RANDOM.out
        rlLog "default behave of history setting test"
        add_test_ac
        add_test_grp
        append_test_member
        reset_group_pwpolicy
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] classes=[$classes]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            ipapassword_grouppolicy_history_default_logic
        else
            rlFail "FAIL - can not set precondition for history test"
        fi
        rm $out
    rlPhaseEnd
} #ipapassword_grouppolicy_history_default

ipapassword_grouppolicy_history_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        # yi's notes: about history size (May 24, 2012)
        #       one thing I confirmed is: current working password is included in history count
        #       for example: when history size = 2, current working password is "pw2", 
        #                                           last password used is "pw1", 
        #                                           and the one before is "pw0",
        #                    then (1) ipa's history pool has only "pw1" and "pw2". (2) use "pw0" is allowed
        historySize=4
        poolSize=$((historySize-1))
        historyPool=""
        pws=""
        counter=1 #reset counter
        rlLog "[stage 1] set history size"
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin 
        rlRun "ipa pwpolicy-mod $testgrp --history=$historySize" 0 "set password history to [$historySize] for grp [$testgrp]"
        rlLog "[stage 2] build password pool"
        while [ $counter -lt $historySize ]
        do
            pw="${testacPW}*${counter}"
            pws="$pws $pw"
            counter=$((counter+1))
        done
        rlLog "password pool: [$pws], current [$testacPW]"

        # now we start to change password, all changes should success
        rlLog "[stage 3] build up password history pool by changing password, the password will pick up from password pool. If password change success, the password will save to history pool for future use, current history pool [$historyPool]"
        counter=1 #reset counter
		currentPW=$testacPW
        while [ $counter -lt $historySize ]
        do
            nextPW=`echo $pws | cut -d" " -f$counter`
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
            change_password $testac $currentPW $nextPW
            if [ $? = 0 ];then
                rlPass "[$currentPW]-->[$nextPW] password change success"
                historyPool="$currentPW $historyPool"
				currentPW=$nextPW
            	counter=$((counter+1))
                rlLog "pw change counter:[$counter] history  pool [$historyPool] current [$currentPW]"
                rlLog "pw change counter:[$counter] password pool [$pws]"
            else
                rlFail "FAIL - [$currentPW]-->[$nextPW] password change failed is NOT expected, test can not continue"
                break
            fi
        done
        # by yi zhang Nov. 27, 2012
        #   the following two lines (modification to historyPool) is a must
        #   please check https://bugzilla.redhat.com/show_bug.cgi?id=827539 for details
        historyPool=`echo $historyPool | cut -d" " -f1-2`
        historyPool="$currentPW $historyPool"
        rlLog "after while loop: pw change counter:[$counter] current password [$currentPW], history size [$historySize]"
        rlLog "final history  pool [$historyPool], current password [$currentPW]"
        rlLog "final password pool [$pws]"
        rlLog "double confirm history size"
        rlLog "===== ipa pwpolicy-show $testgrp ====="
        ipa pwpolicy-show $testgrp
        rlLog "======================================"
        rlLog "===== ipa pwpolicy-show (global)====="
        ipa pwpolicy-show 
        rlLog "======================================"

        rlLog "[stage 4] change password by using passwords in history pool, all changes suppose to fail"
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
        for p in $historyPool
        do
            rlLog "reuse [$p] in history pool: [$historyPool]"
            rlLog "Test: [$currentPW]-->[$p]"
            change_password $testac $currentPW $p
            if [ $? = 0 ];then
                rlFail "FAIL - password [$p] reuse success is not expected"
                echo "--------- verify [$p] for user [$testac]------------------------"
                rlRun "rlDistroDiff keyctl"
                echo $p | kinit $testac
                klist
                echo "----------------------------------------------------------------"
                break
            else
                rlPass "password [$p] reuse failed is expected"
            fi
        done
        rlLog "test finished"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --minclasses=1 --history=$lowbound
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        #history=`read_pwpolicy "history" $testgrp`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] classes=[$classes] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $classes = 1 ] \
            && [ $history = 0 ]
        then
            ipapassword_grouppolicy_history_lowerbound_logic
        else
            rlFail "FAIL - can not set precondition for history test"
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
        rlRun "rlDistroDiff keyctl"
        kinitAs $testac $testacPW
        N=3
        counter=0
        currentPW=$testacPW
        newPW=$dummyPW
        rlLog "keep change password [$N] times with two password:[$currentPW] & [$newPW]"
        while [ $counter -lt $N ] #password is $oldpw when out of this loop
        do
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
            change_password $testac $currentPW $newPW
            if [ $? = 0 ];then
                rlPass "[$counter] change success, current password [$newPW]"
                #swap the password
                tmp=$currentPW
                currentPW=$newPW
                newPW=$tmp 
            else
                rlFail "FAIL - [$counter] password change failed"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$grouppw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_default_logic
        else
            rlFail "FAIL - can not set precondition for minclasses test"
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
            rlRun "rlDistroDiff keyctl"
            Local_KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minclasses=$n
            ipa pwpolicy-show $testgrp > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                append_test_member
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "rlDistroDiff keyctl"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "verify password [$testacPW] for user [$testac]"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "FAIL - password change success is not expected"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "FAIL - password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
            else
                rlFail "FAIL - set minclasses to [$n] failed"
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
        rlRun "rlDistroDiff keyctl"
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
            rlFail "FAIL - can not set precondition for minclasses test"
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
            rlRun "rlDistroDiff keyctl"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
                    change_password $testac $currentPW $pw
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW=$pw
                    else
                        rlFail "FAIL - password change failed, this is not expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "disable other password policy constrains"
        add_test_grp
        reset_group_pwpolicy
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minlength=0 --history=0 
        ipa pwpolicy-show $testgrp > $out
        minlife=`grep "Min lifetime" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        rlLog "precondition: minlife=[$minlife] minlength=[$length] history=[$history]"
        if [ $minlife = 0 ] && [ $length = 0 ] && [ $history = 0 ]
        then
            ipapassword_grouppolicy_classes_upperbound_logic
        else
            rlFail "FAIL - can not set precondition for minclasses test"
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
            rlRun "rlDistroDiff keyctl"
            Local_KinitAsAdmin
            ipa pwpolicy-mod $testgrp --minclasses=$n
            ipa pwpolicy-show $testgrp > $out
            classes=`grep "classes:" $out | cut -d":" -f2| xargs echo`
            rlRun "$kdestroy" 0 "clear all kerberos tickets"
            if [ $classes -eq $n ];then
                add_test_ac
                append_test_member
                rlLog "Set minclasses to [$n] success, now continue test"
                rlRun "rlDistroDiff keyctl"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo \"$testacPW\"| kinit $testac 2>&1 >/dev/null" 0 "verify password [$testacPW] for user [$testac]"
                    change_password $testac $testacPW $pw
                    if [ $? = 0 ];then
                        rlFail "FAIL - password change success is not expected"
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
                    rlRun "rlDistroDiff keyctl"
                    rlRun "echo \"$currentPW\"| kinit $testac 2>&1 >/dev/null" 0 "verify password [$currentPW] for user [$testac]"
                    change_password $testac "$currentPW" "$pw"
                    if [ $? = 0 ];then
                        rlPass "password change success is expected"
                        currentPW="$pw"
                    else
                        rlFail "FAIL - password change failed, this is NOT expected"
                    fi
                    classLevel=$((classLevel+1))
                done
            else
                rlFail "FAIL - set minclasses to [$n] failed"
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
            rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$globalpw_maxlife --minlife=0 --minclasses=0 --history=0 
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
            rlFail "FAIL - can not set precondition for password length test"
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
            classLevel=5
            rlLog "minlength=[$grouppw_length], current len [$length],class=[$classLevel] number=[$number]"
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$grouppw_length], current len [$length],next password=[$pw]"
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW| kinit $testac 2>&1 >/dev/null" 0 "validating current password [$currentPW]"
            change_password $testac $testacPW $pw    
            if [ $? = 0 ];then
                rlFail "FAIL - password change success is not expected"
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
            classLevel=5
            rlLog "minlength=[$grouppw_length], current len [$length],class=[$classLevel] number=[$number]"
            pw=`generate_password $classLevel $length`
            rlLog "minlength=[$grouppw_length], current len [$length],next password=[$pw]"
            rlRun "rlDistroDiff keyctl"
            rlRun "echo \"$currentPW\" | kinit $testac 2>&1 >/dev/null" 0 "validating current password [$currentPW]"
            change_password $testac $currentPW $pw    
            if [ $? = 0 ];then
                rlPass "password change success is expected"
                currentPW=$pw
            else
                rlFail "FAIL - password change failed, this is NOT expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$grouppw_maxlife --minlife=0 --minclasses=0 --history=0 --minlength=0
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
            rlFail "FAIL - can not set precondition for password length test"
        fi
    rlPhaseEnd
} #ipapassword_grouppolicy_length_lowerbound

ipapassword_grouppolicy_length_lowerbound_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "there is only one password has length 0: empty string"
        rlRun "rlDistroDiff keyctl"
        kinitAs $testac $testacPW
        nullpassword=""
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $testacPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
        change_password $testac $testacPW "$nullpassword"
        if [ $? = 0 ];then
            rlFail "FAIL - password change success is not expected"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipa pwpolicy-mod $testgrp --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=$grouppw_maxlife --minlife=0 --minclasses=0 --history=0 
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
            rlFail "FAIL - can not set precondition for password length upper bound test"
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
            rlRun "rlDistroDiff keyctl"
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
                classLevel=5
                pw=`generate_password $classLevel $below`
                rlLog "minlength=[$edge], current len [$below],password=[$pw]"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlFail "FAIL - password change success is NOT expected"
                    currentPW=$pw
                else
                    rlPass "password change failed, this is expected"
                fi               

                ##############################################################
                # if password length = edge, password changing should success
                ##############################################################
                classLevel=5
                rlLog "minlength=[$edge], current len [$edge],class=[$classLevel] number=[$number]"
                pw=`generate_password $classLevel $edge`
                rlLog "minlength=[$edge], current len [$edge],password=[$pw]"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "FAIL - password change failed, this is NOT expected"
                fi               

                ##############################################################
                # if password length > edge, password changing should success
                ##############################################################
                upper=$((edge+1))
                classLevel=5
                pw=`generate_password $classLevel $upper`
                rlLog "minlength=[$edge], current len [$upper],password=[$pw]"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null" 0 "validating current password"
                change_password $testac $currentPW $pw    
                if [ $? = 0 ];then
                    rlPass "password change success is expected"
                    currentPW=$pw
                else
                    rlFail "FAIL - password change failed, this is NOT expected"
                fi               
            else
                rlFail "FAIL - can not set minlength to [$edge]"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        #maxlife=`getrandomint 4 10` # in days
        maxlife=4 # in days
        below=$((maxlife - 2 ))     # also in days
        above=$((maxlife + 2 ))     # also in days
        rlLog "test scenario 1: make make nestedgrp [$nestedgrp] has maxlife below [$below] group [$testgrp]'s maxlife [$maxlife]"
        rlRun "ipa pwpolicy-mod $testgrp --maxlife=$maxlife" \
              0 "set maxlife for [$testgrp] to [$maxlife]"
        rlRun "ipa pwpolicy-mod $nestedgrp --maxlife=$below" \
              0 "set maxlife for [$nestedgrp] to below: [$below]"
        rlRun "$kdestroy"
        change_password $testac $testacPW $testacNEWPW  # trigger the password
        currentPW=$testacNEWPW

        rlLog "set system one minute after $below, same password should work withoud password change prompt"
        set_systime "+ $below * 24 * 60 * 60 + 1 * 60" #  if group password is effective policy here, then when below < system time < maxlife : no password prompt
        rlRun "rlDistroDiff keyctl"
        if Local_kinit $testac $currentPW
        then
            rlPass "test before maxlife: no password change prompt"
        else
            rlFail "FAIL - test before maxlife: password change prompted is not expected"
        fi

        rlLog "set clock after maxlife:[$maxlife] system will prompt for password change"
        set_systime "+ 2 * 24 * 60 * 60 "             # set system time = maxlife + 1 minutes
        rlRun "rlDistroDiff keyctl"
        if Local_kinit $testac $currentPW
        then
            rlFail "FAIL - test 2 minutes after maxlife: no password change prompt is NOT expected"
        else
            rlPass "test 2 minutes after maxlife: password change prompted is expected"
        fi
        ##################
        ##################
        rlLog "test scenario 2: make nestedgrp [$nestedgrp] has maxlife above [$above] group [$testgrp]'s maxlife:[$maxlife]"
        rlLog "                 behave will not change, since the effective pwpolicy is group [$testgrp]'s policy"
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlRun "ipa pwpolicy-mod $nestedgrp --maxlife=$above" \
              0 "set maxlife for [$nestedgrp] to [$above]"
        rlRun "$kdestroy"

        rlLog "reset the test account"
        add_test_ac
        append_test_nested_ac
        change_password $testac $testacPW $testacNEWPW  # trigger the password policy 
        currentPW=$testacNEWPW

        rlLog "set system one minute before maxlife:[$maxlife], same password should work withoud password change prompt"
        set_systime "+ $maxlife * 24 * 60 * 60 - 1 * 60"
        rlRun "rlDistroDiff keyctl"
        if Local_kinit $testac $currentPW
        then
            rlPass "before maxlife: password still works, no password change prompt"
        else
            rlFail "FAIL - before maxlife: password does not work is NOT expected"
        fi

        rlLog "set system time 1 minutes AFTER maxlife"
        set_systime "+ 2*60"
        rlRun "rlDistroDiff keyctl"
        if Local_kinit $testac $currentPW
        then
            rlFail "FAIL - after maxlife: password still works, no password change prompt, this is NOI expected"
        else
            rlPass "after maxlife: password does not work is expected"
        fi

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
       rlLog "empty function, this is intentional" 
    # test logic ends
} # ipapassword_nestedgrouppw_maxlife_conflict_logic 

ipapassword_nestedgrouppw_minlife_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_minlife_conflict"
        rlLog "when group setting for minlife < global minlife setting"
        rlRun "rlDistroDiff keyctl"
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
        change_password $testac $currentPW $dummyPW
        if [ $? -eq 0 ];then
            rlFail "FAIL - change password success is not expected"
            currentPW=$dummyPW
        else
            rlPass "change password failed is expected"
        fi 
        set_systime "+ 3 * 60 " # set system one minutes after minlife
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac 2>&1 > /dev/null" 0  "check password before test"
        change_password $testac $currentPW "again_Dummy@123"
        if [ $? -eq 0 ];then
            rlPass "change password success is expected"
        else
            rlFail "FAIL - change password failed is NOT expected"
        fi
    rlPhaseEnd
} #ipapassword_nestedgrouppw_minlife_conflict

ipapassword_nestedgrouppw_minlife_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        echo "empty function, this is intentional"
    # test logic ends
} # ipapassword_nestedgrouppw_minlife_conflict_logic 

ipapassword_nestedgrouppw_history_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_history_conflict"
        rlLog "when group setting for history size < global history size setting"
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlRun "ipa pwpolicy-mod --history=$above $nestedgrp"  0 "set history to [$above] for [$nestedgrp]"
        rlRun "$kdestroy"
        add_test_ac
        append_test_nested_ac
    check_log_error "1998-1" /var/log/httpd/error_log "Exception occurred processing WSGI script"
        ipapassword_nestedgrouppw_history_conflict_logic $history

    check_log_error "1998-2" /var/log/httpd/error_log "Exception occurred processing WSGI script"
     rlPhaseEnd
} #ipapassword_nestedgrouppw_history_conflict

ipapassword_nestedgrouppw_history_conflict_logic()
{
    # accept parameters: NONE
    # test logic starts
        local history=$1
        local currentPW=$testacPW
        local counter=1
        local passwordPool=""
        local passwordPoolSize=$((history-1))
        local failedPool=""
        local newPW=""

        while [ $counter -lt $passwordPoolSize ];do
            newPW=`generate_password 4 10`
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW "$newPW"
            if [ $? -eq 0 ];then
                passwordPool="$passwordPool $newPW"
                currentPW=$newPW
            else
                rlFail "FAIL - change password failed is NOT expected"
            fi
            counter=$((counter+1))
        done
		rlLog "password pool:[$passwordPool]"
        # all password in password pool should not be reused
        for pw in $passwordPool
        do
            if [ $currentPW != $pw ];then
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
                change_password $testac $currentPW "$pw"
                if [ $? -eq 0 ];then
                    rlFail "FAIL - password reuse [$pw] is NOT expected"
                    currentPW=$pw
                else
                    failedPool="$failedPool $pw"
                    rlPass "password reuse failed is expected"
                fi           
            fi
        done 
        # once we out of above loop, we should be able to change password
        newPW=`generate_password 4 10` 
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
        change_password $testac $currentPW "$newPW"
        if [ $? -eq 0 ];then
            rlPass "password change after [$history] times is expected"
        else
            rlFail "FAIL - password change failed is NOT expected"
        fi
        rlLog "history size=[$history]"
        rlLog "passwordPoolSize=[$passwordPoolSize]"
        rlLog "passwordPool=[$passwordPool]"
        rlLog "failedPool =[$failedPool]"

    # test logic ends
} # ipapassword_nestedgrouppw_history_conflict_logic 

ipapassword_nestedgrouppw_classes_conflict()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipapassword_nestedgrouppw_classes_conflict"
        rlLog "when group classes > global classes"
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlFail "FAIL - when class=[$classes]: password change to [$pw] is NOT expected"
                currentPW=$pw
            else
                rlPass "when class=[$classes]: password change to [$pw] failed is expected"
            fi
        done
        for pw in $goodPasswordPool;do
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlPass "when class=[$classes]: password change to [$pw] is expected"
                currentPW=$pw
            else
                rlFail "FAIL - when class=[$classes]: password change to [$pw] failed is NOT expected"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlFail "FAIL - when length=[$length]: password change to [$pw] is NOT expected"
                currentPW=$pw
            else
                rlPass "when length=[$length]: password change to [$pw] failed is expected"
            fi
        done
        for pw in $goodPasswordPool;do
            rlRun "rlDistroDiff keyctl"
            rlRun "echo $currentPW | kinit $testac 2>&1 >/dev/null"
            change_password $testac $currentPW $pw
            if [ $? -eq 0 ];then
                rlPass "when length=[$length]: password change to [$pw] is expected"
                currentPW=$pw
            else
                rlFail "FAIL - when length=[$length]: password change to [$pw] failed is NOT expected"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 1 "ipa: ERROR: invalid 'krbminpwdlife': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbMinPwdLife_negative

ipapassword_attr_set_krbPwdMinDiffChars()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdMinDiffChars"
        local attr=krbPwdMinDiffChars
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr $value 1 "ipa: ERROR: invalid 'krbpwdmindiffchars': can be at most 5"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_set_krbPwdMinDiffChars_negative

ipapassword_attr_set_krbPwdMinLength()
{
    rlPhaseStartTest "ipapassword_attr_set_krbPwdMinLength"
        local attr=krbPwdMinLength
        local value=`getrandomint`
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
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
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_set_logic $attr "-$value" 1 "ipa: ERROR: invalid 'krbpwdhistorylength': must be at least 0"
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
            rlFail "FAIL - expected [$expected], actual [$ret]";
        fi
        if [ "$expected" = "1" ] || [ "$ret" = "1" ] || [ ! -z "$errmsg" ];then
            if grep -i "$errmsg" $out 2>&1 >/dev/null
            then
                rlPass "error msg matches with output"
            else
                rlFail "FAIL - error msg not found in output file"
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
    rlPhaseStartTest "ipapassword_attr_add_krbMaxPwdLife"
        local attr=krbMaxPwdLife
        local value=`getrandomint`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $success ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMaxPwdLife

ipapassword_attr_add_krbMaxPwdLife_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbMaxPwdLife_negative"
        local attr=krbMaxPwdLife
        local value=`getrandomstring`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $fail ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMaxPwdLife_negative

ipapassword_attr_add_krbMinPwdLife()
{
    rlPhaseStartTest "ipapassword_attr_add_krbMinPwdLife"
        local attr=krbMinPwdLife
        local value=`getrandomint`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        maxlife=`ipa pwpolicy-show $testgrp --all | grep -i "max lifetime" | cut -d":" -f2 | xargs echo`
        max=`echo "$maxlife * 24" | bc`
        minvalue=`getrandomint $max `
        ipapassword_attr_add_logic $attr "$minvalue" $success ""
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMinPwdLife

ipapassword_attr_add_krbMinPwdLife_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbMinPwdLife_negative"
        local attr=krbMinPwdLife
        local value=`getrandomstring`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $fail "ipa: ERROR: invalid 'krbminpwdlife': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd
} #ipapassword_attr_add_krbMinPwdLife_negative

ipapassword_attr_add_krbPwdMinDiffChars()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinDiffChars"
        local attr=krbPwdMinDiffChars
        local value=`getrandomint 1 5`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $success ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinDiffChars

ipapassword_attr_add_krbPwdMinDiffChars_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinDiffChars_negative"
        local attr=krbPwdMinDiffChars
        local value=`getrandomint 6 50000`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $fail "ipa: ERROR: invalid 'krbpwdmindiffchars': can be at most 5"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinDiffChars_negative

ipapassword_attr_add_krbPwdMinLength()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinLength"
        local attr=krbPwdMinLength
        local value=`getrandomint`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $success ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinLength

ipapassword_attr_add_krbPwdMinLength_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdMinLength_negative"
        local attr=krbPwdMinLength
        local value=`getrandomstring`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr "-$value" $fail "ipa: ERROR: invalid 'krbpwdminlength': must be an integer"
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdMinLength_negative

ipapassword_attr_add_krbPwdHistoryLength()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdHistoryLength"
        local attr=krbPwdHistoryLength
        local value=`getrandomint`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr $value $success ""
        rlRun "$kdestroy"
    rlPhaseEnd

} #ipapassword_attr_add_krbPwdHistoryLength

ipapassword_attr_add_krbPwdHistoryLength_negative()
{
    rlPhaseStartTest "ipapassword_attr_add_krbPwdHistoryLength_negative"
        local attr=krbPwdHistoryLength
        local value=`getrandomint`
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        ipapassword_attr_add_logic $attr "-$value" $fail "ipa: ERROR: invalid 'krbpwdhistorylength': must be at least 0"
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
        rlLog "test group:[$testgrp] add value [$value] to attr:[$attr], expect [$expected], errmsg=[$errmsg]"
        rlLog "delete password policy for [$testgrp]"
        ipa pwpolicy-del $testgrp
        ipa pwpolicy-add $testgrp --addattr "$attr"="$value" --priority=99 2>$out
        local ret=$?
        if [ "$ret" = "$expected" ];then
            rlPass "addattr result matches expection [$expected]"
        else
            rlFail "FAIL - addattr expect: [$expected], actual [$ret]"
        fi
        if [ "$ret" = "1" ] || [ "$expected" = "1" ] || [ ! -z "$errmsg" ];then
            if grep -i "$errmsg" $out 2>&1 >/dev/null
            then
                rlPass "error msg matches with output"
            else
                rlFail "FAIL - error msg not found in output file"
                echo "============== output ====================="
                cat $out
                echo "==========================================="
            fi
        fi
        rm $out
} #ipapassword_attr_add_logic

bz_818836()
{
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=818836
	rlPhaseStartTest "Bug 818836 - ipa pwpolicy-find displays incorrect max and min lifetime."
        Local_KinitAsAdmin
		# Add a group to test on
		grp="tgroup1"
		ipa group-add --desc=desc $grp
		# Set the password max lifetime to something, then make sure it outputs properly.
		maxlife=99
		ipa pwpolicy-add $grp --priority=10 --maxlife=$maxlife
		rlRun "ipa pwpolicy-find $grp | grep Max\ lifetime | grep $maxlife" 0 "Make sure that the specified max lifetime applies to group $grp"
		# Set the password max lifetime to something, then make sure it outputs properly.
		maxlife=12
		ipa pwpolicy-mod $grp --maxlife=$maxlife
		rlRun "ipa pwpolicy-find $grp | grep Max\ lifetime | grep $maxlife" 0 "Make sure that the specified max lifetime applies to group $grp"
		# Set the password max lifetime to something, then make sure it outputs properly.
		maxlife=40
		ipa pwpolicy-mod $grp --maxlife=$maxlife
		rlRun "ipa pwpolicy-find $grp | grep Max\ lifetime | grep $maxlife" 0 "Make sure that the specified max lifetime applies to group $grp"
		# Cleanup	
		ipa group-del $grp
	rlPhaseEnd
} #bz_818836

