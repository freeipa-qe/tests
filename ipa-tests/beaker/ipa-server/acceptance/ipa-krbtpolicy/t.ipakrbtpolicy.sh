
######################
# test suite         #
######################
ipakrbtpolicy()
{
    ipakrbt_envsetup
    ipakrbt_functional
#    ipakrbt_show
#    ipakrbt_reset
#    ipakrbt_mod
    ipakrbt_envcleanup
} # ipakrbt

######################
# test set           #
######################
ipakrbt_functional()
{
    ipakrbt_functional_envsetup
    ipakrbt_functional_maxlife
    ipakrbt_functional_maxrenew
    ipakrbt_functional_envcleanup
}

ipakrbt_show()
{
    ipakrbt_show_envsetup
    ipakrbt_show_rights
    ipakrbt_show_all
    ipakrbt_show_raw
    ipakrbt_show_envcleanup
} #ipakrbt_show

ipakrbt_reset()
{
    ipakrbt_reset_envsetup
    ipakrbt_reset_default
    ipakrbt_reset_envcleanup
} #ipakrbt_reset

ipakrbt_mod()
{
    ipakrbt_mod_envsetup
    ipakrbt_mod_maxlife
    ipakrbt_mod_maxlife_negative
    ipakrbt_mod_maxrenew
    ipakrbt_mod_maxrenew_negative
    ipakrbt_mod_setattr
    ipakrbt_mod_setattr_negative
    ipakrbt_mod_addattr
    ipakrbt_mod_addattr_negative
    ipakrbt_mod_envcleanup
} #ipakrbt_mod

######################
# test cases         #
######################
ipakrbt_envsetup()
{
    rlPhaseStartSetup "ipakrbt_envsetup"
        #environment setup starts here
        rlPass "no special env setup required"
        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_envsetup

ipakrbt_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin
        rlRun "ipa krbtpolicy-reset" 0 "reset krbtpolicy to default"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_envcleanup

ipakrbt_functional_envsetup()
{
    rlPhaseStartSetup "ipakrbt_functional_envsetup"
        #environment setup starts here
        create_ipauser $username $first $last $password
        #environment setup ends   here
    rlPhaseEnd
}

ipakrbt_functional_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_functional_envcleanup"
        #environment cleanup starts here
        delete_user $username
        #environment cleanup ends   here
    rlPhaseEnd
}

ipakrbt_functional_maxlife()
{
    rlPhaseStartTest "ipakrbt_functional_maxlife"
        local delay=60 # set maxlife of kerberos ticket life to 1 minute for test account
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod $username --maxlife=$delay" 0 "set maxlife to $delay second"
        clear_kticket

        rlRun "echo $password | kinit $username" 0 "kinit as [$username] and expect ticket expire in 60 seconds"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep $delay
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$delay] seconds"
        clear_kticket
    rlPhaseEnd
} #ipakrbt_functional_maxlife

ipakrbt_functional_maxrenew()
{
    rlPhaseStartTest "ipakrbt_functional_maxrenew"
        local maxlife=60
        local renew=`echo "$maxlife *2" | bc` # set renew life as double of maxlife
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife --maxrenew=$renew" 0 "set maxlife:[$maxlife], renew=[$renew]"
        clear_kticket

        #step 1: normal kinit should success and allow ipa user to do user-find
        rlRun "echo $password | kinit $username" 0 "kinit as [$username] and expect ticket expire in 60 seconds"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"

        #step 2: after kerberos ticket life time (defined by maxlife), ticket should expire, and user-find should fail
        sleep $maxlife
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$maxlife] seconds"

        #step 3: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after kinit -R , user-find should success"

        #step 4: after renew time limit reaches its limit, kinit -R no longer work
        sleep $maxlife  # sleep again
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$delay] seconds"
        rlRun "kinit -R" 1 "when user kerberos ticket expired and also out renew time, kinit -R should fail"
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$maxlife] seconds"
        clear_kticket

    rlPhaseEnd
} #ipakrbt_functional_maxrenew

ipakrbt_show_envsetup()
{
    rlPhaseStartSetup "ipakrbt_show_envsetup"
        #environment setup starts here
        rlPass "no special env setup required"
        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_show_envsetup

ipakrbt_show_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_show_envcleanup"
        #environment cleanup starts here
        rlPass "no special env clean up required"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_show_envcleanup

ipakrbt_show_rights()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_show_rights"
        rlLog "ipa krbtpolicy-show --rights"
        ipakrbt_show_rights_logic
    rlPhaseEnd
} #ipakrbt_show_rights

ipakrbt_show_rights_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "ipa krbtpolicy-mod will cover this test"
    # test logic ends
} # ipakrbt_show_rights_logic 

ipakrbt_show_all()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_show_all"
        rlLog "ipa krbtpolicy-show --all"
        #ipakrbt_show_all_logic
    rlPhaseEnd
} #ipakrbt_show_all

ipakrbt_show_all_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "this test moved to ipa-default"
    # test logic ends
} # ipakrbt_show_all_logic 

ipakrbt_show_raw()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_show_raw"
        rlLog "ipa krbtpolicy-show --raw"
        ipakrbt_show_raw_logic
    rlPhaseEnd
} #ipakrbt_show_raw

ipakrbt_show_raw_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlPass "this test moved to ipa-default"
    # test logic ends
} # ipakrbt_show_raw_logic 

ipakrbt_reset_envsetup()
{
    rlPhaseStartSetup "ipakrbt_reset_envsetup"
        #environment setup starts here
        create_user
        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_reset_envsetup

ipakrbt_reset_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_reset_envcleanup"
        #environment cleanup starts here
        delete_user
        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_reset_envcleanup

ipakrbt_reset_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_reset_default"
        rlLog "restore krbtpolicy back to default for a given user"
        ipakrbt_reset_default_logic
    rlPhaseEnd
} #ipakrbt_reset_default

ipakrbt_reset_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "restore krbtpolicy for given user"
        KinitAsAdmin
        echo "default logic"
        maxlife=$RANDOM
        renew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife --maxrenew=$renew" 0 "randomly set maxlife=[$maxlife], renew=[$renew]"
        rlRun "ipa krbtpolicy-reset $username" 0 "reset the user's krbt policy"
        actualMaxlife=`read_maxlife $useranme`
        actualRenew=`read_renew $username`
        if [ "$actualMaxlife" =  "$default_maxlife" ];then
            rlPass "max life value for [$username] has been reset to default [$default_maxlife]"
        else
            rlFail "max life value reset failed, expect [$default_maxlife] actual [$actualMaxlife]"
        fi

        if [ "$actualRenew" = "$default_renew" ];then
            rlPass "max renew value for [$username] has been reset to default [$default_renew"
        else
            rlFail "renew reset failed, expect [$default_renew], actual [$actualRenew]"
        fi

        rlLog "restore the global krbtpolicy"
        KinitAsAdmin
        maxlife=$RANDOM
        renew=$RANDOM
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife --maxrenew=$renew" 0 "randomly set maxlife=[$maxlife], renew=[$renew]"
        rlRun "ipa krbtpolicy-reset " 0 "reset global krbt policy"
        actualMaxlife=`read_maxlife `
        actualRenew=`read_renew `
        if [ "$actualMaxlife" =  "$default_maxlife" ];then
            rlPass "global max life value has been reset to default [$default_maxlife]"
        else
            rlFail "global max life value reset failed, expect [$default_maxlife] actual [$actualMaxlife]"
        fi

        if [ "$actualRenew" = "$default_renew" ];then
            rlPass "global max renew value has been reset to default [$default_renew"
        else
            rlFail "renew reset failed, expect [$default_renew], actual [$actualRenew]"
        fi

    # test logic ends
} # ipakrbt_reset_default_logic 

ipakrbt_mod_envsetup()
{
    rlPhaseStartSetup "ipakrbt_mod_envsetup"
        #environment setup starts here
        create_user    
        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_mod_envsetup

ipakrbt_mod_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_mod_envcleanup"
        #environment cleanup starts here
        delete_user
        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_mod_envcleanup

ipakrbt_mod_maxlife()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxlife"
        rlLog "set the maxlife of kerberos ticket"
        ipakrbt_mod_maxlife_logic
    rlPhaseEnd
} #ipakrbt_mod_maxlife

ipakrbt_mod_maxlife_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "modify maxlife for given user"
        KinitAsAdmin
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife" 0 "set maxlife=[$maxlife] for [$username]"
        if ipa krbtpolicy-show $username | grep "Max life: $maxlife$" 2>&1 >/dev/null
        then
            rlPass "value setting for [$username] success"
        else
            rlFail "set maxlife to [$maxlife] for [$username] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works

        rlLog "modify global krbtpolicy: maxlife "
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife" 0 "set maxlife=[$maxlife] for [$username]"
        if ipa krbtpolicy-show | grep "Max life: $maxlife$" 2>&1 >/dev/null
        then
            rlPass "value setting for global krbtpolicy success"
        else
            rlFail "set global krbtpolicy : maxlife to [$maxlife] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works

    # test logic ends
} # ipakrbt_mod_maxlife_logic 

ipakrbt_mod_maxlife_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxlife_negative"
        rlLog "set the maxlife of kerberos ticket"
        KinitAsAdmin
        for value in -1 a ab abc
        do
            ipakrbt_mod_maxlife_negative_logic $value
        done
    rlPhaseEnd
} #ipakrbt_mod_maxlife

ipakrbt_mod_maxlife_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "modify maxlife for given user negative test case"
        local maxlife=$1
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife" 1 "set maxlife=[$maxlife] for [$username] expect to fail"
        rlLog "modify global maxlife - negative test case"
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife" 1 "set maxlife=[$maxlife] for [$username] expect to fail"
    # test logic ends
} # ipakrbt_mod_maxlife_negative_logic 

ipakrbt_mod_maxrenew()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxrenew"
        rlLog "set max renew life of kerberos ticket"
        ipakrbt_mod_maxrenew_logic
    rlPhaseEnd
} #ipakrbt_mod_maxrenew

ipakrbt_mod_maxrenew_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "modify renew for given user"
        KinitAsAdmin
        maxrenew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxrenew=$maxrenew" 0 "set maxrenew=[$maxrenew] for [$username]"
        if ipa krbtpolicy-show $username | grep "Max renew: $maxrenew$" 2>&1 >/dev/null
        then
            rlPass "value setting for [$username] success"
        else
            rlFail "set maxrenew to [$maxrenew] for [$username] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works

        rlLog "modify global krbtpolicy: maxlife "
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod --maxrenew=$maxrenew" 0 "set maxlife=[$maxrenew] for [$username]"
        if ipa krbtpolicy-show | grep "Max renew: $maxrenew$" 2>&1 >/dev/null
        then
            rlPass "value setting for global krbtpolicy success"
        else
            rlFail "set global krbtpolicy : maxrenew to [$maxrenew] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works


    # test logic ends
} # ipakrbt_mod_maxrenew_logic 

ipakrbt_mod_maxrenew_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxrenew_negative"
        rlLog "set max renew life of kerberos ticket negative test case"
        KinitAsAdmin
        for value in -1 a ab abc
        do
            ipakrbt_mod_maxrenew_negative_logic $value
        done
        clear_kticket
    rlPhaseEnd
} #ipakrbt_mod_maxrenew

ipakrbt_mod_maxrenew__negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "modify renew for given user"
        maxrenew=$1
        rlRun "ipa krbtpolicy-mod $username --maxrenew=$maxrenew" 1 "set maxrenew=[$maxrenew] for [$username]"
        rlLog "modify renew for global policy"
        rlRun "ipa krbtpolicy-mod --maxrenew=$maxrenew" 1 "set maxlife=[$maxrenew] for [$username]"
    # test logic ends
} # ipakrbt_mod_maxrenew_negative_logic 

ipakrbt_mod_maxrenew()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxrenew"
        rlLog "set max renew life of kerberos ticket"
        ipakrbt_mod_maxrenew_logic
    rlPhaseEnd
} #ipakrbt_mod_maxrenew

ipakrbt_mod_maxrenew_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "modify renew for given user"
        KinitAsAdmin
        maxrenew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxrenew=$maxrenew" 0 "set maxrenew=[$maxrenew] for [$username]"
        if ipa krbtpolicy-show $username | grep "Max renew: $maxrenew$" 2>&1 >/dev/null
        then
            rlPass "value setting for [$username] success"
        else
            rlFail "set maxrenew to [$maxrenew] for [$username] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works

        rlLog "modify global krbtpolicy: maxlife "
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod --maxrenew=$maxrenew" 0 "set maxlife=[$maxrenew] for [$username]"
        if ipa krbtpolicy-show | grep "Max renew: $maxrenew$" 2>&1 >/dev/null
        then
            rlPass "value setting for global krbtpolicy success"
        else
            rlFail "set global krbtpolicy : maxrenew to [$maxrenew] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works


    # test logic ends
} # ipakrbt_mod_maxrenew_logic 

ipakrbt_mod_maxrenew()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxrenew"
        rlLog "set max renew life of kerberos ticket"
        ipakrbt_mod_maxrenew_logic
    rlPhaseEnd
} #ipakrbt_mod_maxrenew

ipakrbt_mod_maxrenew_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlLog "modify renew for given user"
        KinitAsAdmin
        maxrenew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxrenew=$maxrenew" 0 "set maxrenew=[$maxrenew] for [$username]"
        if ipa krbtpolicy-show $username | grep "Max renew: $maxrenew$" 2>&1 >/dev/null
        then
            rlPass "value setting for [$username] success"
        else
            rlFail "set maxrenew to [$maxrenew] for [$username] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works

        rlLog "modify global krbtpolicy: maxlife "
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod --maxrenew=$maxrenew" 0 "set maxlife=[$maxrenew] for [$username]"
        if ipa krbtpolicy-show | grep "Max renew: $maxrenew$" 2>&1 >/dev/null
        then
            rlPass "value setting for global krbtpolicy success"
        else
            rlFail "set global krbtpolicy : maxrenew to [$maxrenew] failed"
        fi
        # FIXME;I need test the bahave of this policy to ensure it really works


    # test logic ends
} # ipakrbt_mod_maxrenew_logic 

ipakrbt_mod_setattr()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_setattr"
        rlLog "setattr"
        ipakrbt_mod_setattr_logic
    rlPhaseEnd
} #ipakrbt_mod_setattr

ipakrbt_mod_setattr_logic()
{
    # accept parameters: NONE
    # test logic starts
        attrs="krbmaxticketlife krbmaxrenewableage"
        KinitAsAdmin
        for attr in $attrs
        do
            rlLog "setattr for given user"
            value=$RANDOM
            rlRun "ipa krbtpolicy-mod $username --setattr=$attr=$value" 0 "setattr: $attr=$value"
            if ipa krbtpolicy-show --raw --all | grep "$attr" | grep "$value"
            then
                rlPass "set $attr=$value success"
            else
                rlFail "set $attr=$value failed"
            fi
            rlLOg "setattr for global policy"
            value=$RANDOM
            rlRun "ipa krbtpolicy-mod --setattr=$attr=$value" 0 "setattr: $attr=$value"
            if ipa krbtpolicy-show --raw --all | grep "$attr" | grep "$value"
            then
                rlPass "set $attr=$value success"
            else
                rlFail "set $attr=$value failed"
            fi
        done
        clear_kticket
    # test logic ends
} # ipakrbt_mod_setattr_logic 

ipakrbt_mod_setattr_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_setattr_negative"
        rlLog "setattr"
        KinitAsAdmin
        for value in -1 a ab abc
        do
            ipakrbt_mod_setattr_negative_logic $value
        done
        clear_kticket
    rlPhaseEnd
} #ipakrbt_mod_setattr_negative

ipakrbt_mod_setattr_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        local value=$1
        attrs="krbmaxticketlife krbmaxrenewableage"
        for attr in $attrs
        do
            rlRun "ipa krbtpolicy-mod $username --setattr=$attr=$value" 1 "setattr: $attr=$value expect to fail"
            rlRun "ipa krbtpolicy-mod --setattr=$attr=$value" 1 "setattr: $attr=$value expect to fail"
        done
    # test logic ends
} # ipakrbt_mod_setattr_negative_logic 

ipakrbt_mod_addattr()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_addattr"
        rlLog "addattr"
        ipakrbt_mod_addattr_logic
    rlPhaseEnd
} #ipakrbt_mod_addattr

ipakrbt_mod_addattr_logic()
{
    # accept parameters: NONE
    # test logic starts
        # addattr only success for multi-value attribute, krbmaxticketlife and krbmaxrenewableage are single-value attributes
        attrs="krbmaxticketlife krbmaxrenewableage"
        KinitAsAdmin
        for attr in $attrs
        do
            rlLog "addattr for given user"
            value=$RANDOM
            rlRun "ipa krbtpolicy-mod $username --addattr=$attr=$value" 1 "addattr: $attr=$value"
            if ipa krbtpolicy-show $username --raw --all | grep "$attr" | grep "$value"
            then
                rlFail "add $attr=$value success for single-value attribute is not expected"
            else
                rlPass "add $attr=$value failed for single-value attribute is expected"
            fi

            rlLog "addattr for global policy"
            value=$RANDOM
            rlRun "ipa krbtpolicy-mod --addattr=$attr=$value" 1 "addattr: $attr=$value"
            if ipa krbtpolicy-show --raw --all | grep "$attr" | grep "$value"
            then
                rlFail "add $attr=$value success for single-value attribute is not expected"
            else
                rlPass "add $attr=$value failed for single-value attribute is expected"
            fi
        done
        clear_kticket
    # test logic ends
} # ipakrbt_mod_addattr_logic 

ipakrbt_mod_addattr_negative()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_addattr_negative"
        rlLog "addattr"
        KinitAsAdmin
        for value in -1 a ab abc
        do
            ipakrbt_mod_addattr_negative_logic $value
        done
        clear_kticket
    rlPhaseEnd
} #ipakrbt_mod_addattr_negative

ipakrbt_mod_addattr_negative_logic()
{
    # accept parameters: NONE
    # test logic starts
        # addattr only success for multi-value attribute, krbmaxticketlife and krbmaxrenewableage are single-value attributes
        local value=$1
        attrs="krbmaxticketlife krbmaxrenewableage"
        for attr in $attrs
        do
            rlRun "ipa krbtpolicy-mod $username --addattr=$attr=$value" 1 "addattr: $attr=$value"
            rlRun "ipa krbtpolicy-mod --addattr=$attr=$value" 1 "addattr: $attr=$value"
        done
        clear_kticket
    # test logic ends
} # ipakrbt_mod_addattr_negative_logic

