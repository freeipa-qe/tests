
######################
# test suite         #
######################
ipakrbtpolicy()
{
    ipakrbt_envsetup
    ipakrbt_show
    ipakrbt_functional
#    ipakrbt_mod
    ipakrbt_reset
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
    ipakrbt_show
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
	create_ipauser $username $first $last $password
	create_ipauser $gusername $first $last $password
        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_envsetup

ipakrbt_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_envcleanup"
        #environment cleanup starts here
        KinitAsAdmin	
	delete_user $username
	delete_user $gusername
	KinitAsAdmin
        rlRun "ipa krbtpolicy-reset" 0 "reset krbtpolicy to default - just in case!"
	ipactl restart
        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_envcleanup

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

ipakrbt_show()
{
    rlPhaseStartTest "ipakrbt_show_global"
	local glifecurrent=`read_maxlife`
	if [ $glifecurrent -eq $default_maxlife ] ; then
		rlPass "krbtpolicy-show: global default max ticket life as expect: $glifecurrent"
	else
		rlFail "krbtpolicy-show: global default max ticket like not as expected.  GOT: $glifecurrent EXPECTED: $default_maxlife"
	fi

        local grenewcurrent=`read_renew`
        if [ $grenewcurrent -eq $default_renew ] ; then
                rlPass "krbtpolicy-show: global default max renew life as expect: $grenewcurrent"
        else
                rlFail "krbtpolicy-show: global default max renew life not as expected.  GOT: $grenewcurrent EXPECTED: $default_renew"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipakrbt_show_user"
        local ulifecurrent=`read_maxlife $username`
        if [ $ulifecurrent -eq $default_maxlife ] ; then
                rlPass "krbtpolicy-show: user [$username] default max ticket life as expect: $ulifecurrent"
        else
                rlFail "krbtpolicy-show: user [$username] default max ticket like not as expected.  GOT: $ulifecurrent EXPECTED: $default_maxlife"
        fi

        local urenewcurrent=`read_renew $username`
        if [ $urenewcurrent -eq $default_renew ] ; then
                rlPass "krbtpolicy-show: user [$username] default max renew life as expect: $urenewcurrent"
        else
                rlFail "krbtpolicy-show: user [$username] default max renew life not as expected.  GOT: $urenewcurrent EXPECTED: $default_renew"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipakrbt_show_all_global - supported encryption"
        local out="/tmp/globalkrbt_showall.out"
	KinitAsAdmin
        rlRun "ipa krbtpolicy-show --all 2>&1 >$out" 0 "Show all for global krbt policy"
        for item in $supported_enc ; do
                cat $out | grep $item
                if [ $? -eq 0 ] ; then
                        rlPass "Supported encryption type found: $item"
                else
                        rlFail "ERROR: Did not find supported encryption type: $item"
                fi
        done
    rlPhaseEnd
} #ipakrbt_show

ipakrbt_functional_envsetup()
{
    rlPhaseStartSetup "ipakrbt_functional_envsetup"
        #environment setup starts here
	rlPass "No special setup required"
        #environment setup ends   here
    rlPhaseEnd
}

ipakrbt_functional_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_functional_envcleanup"
        #environment cleanup starts here
        rlPass "No special cleanup required"
        #environment cleanup ends   here
    rlPhaseEnd
}

ipakrbt_functional_maxlife()
{
    rlPhaseStartTest "ipakrbt_functional_maxlife_user"
        local delay=60 # set user maxlife of kerberos ticket life to 1 minute for test account
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod $username --maxlife=$delay" 0 "set user maxlife to $delay second"
	Kcleanup
        rlRun "echo $password | kinit $username" 0 "kinit as [$username] and expect ticket expire in $delay seconds"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep $delay
	sleep 1
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$delay] seconds"
        Kcleanup 
    rlPhaseEnd

rlPhaseStartTest "ipakrbt_functional_maxlife_global"
        local delay=30 # set maxlife of kerberos ticket life to 1 minute for test account
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod --maxlife=$delay" 0 "set global maxlife to $delay second"
	ipactl restart
        Kcleanup
        rlRun "echo $password | kinit $gusername" 0 "kinit as [$gusername] and expect ticket expire in $delay seconds"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep $delay
        rlRun "ipa user-find $gusername 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$delay] seconds"
        Kcleanup
    rlPhaseEnd
} #ipakrbt_functional_maxlife

ipakrbt_functional_maxrenew()
{
    rlPhaseStartTest "ipakrbt_functional_maxrenew_user"
        local maxlife=60
        local renew=90
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife --maxrenew=$renew" 0 "set maxlife:[$maxlife], renew=[$renew]"
        Kcleanup

        #step 1: normal kinit should success and allow ipa user to do user-find
        rlRun "echo $password | kinit -r 90 $username" 0 "kinit as [$username] and expect ticket expire in $maxlife seconds"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep 30

        #step 2: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R $username" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after kinit -R and 30 seconds, user-find should success"
	sleep 30

        #step 3: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R $username" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after kinit -R and 30 seconds, user-find should success"
	sleep 30

        #step 4: after renew time limit reaches its limit, kinit -R no longer work
        rlRun "kinit -R $username 2>&1 | grep -i 'Ticket expired while renewing credentials' " 0 "when renew time expires, kinit -R should fail"
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$maxlife] seconds"
        Kcleanup
    rlPhaseEnd

    rlPhaseStartTest "ipakrbt_functional_maxrenew_global"
        local maxlife=30
        local renew=60
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife --maxrenew=$renew" 0 "set maxlife:[$maxlife], renew=[$renew]"
	ipactl restart
        Kcleanup
        
        #step 1: normal kinit should success and allow ipa user to do user-find
        rlRun "echo $password | kinit -r 60 $gusername" 0 "kinit as [$gusername] and expect ticket expire in $maxlife seconds"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep 15

        #step 2: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R $gusername" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after kinit -R and 15 seconds, user-find should success"
	sleep 15

        #step 3: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R $gusername" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after kinit -R and 15 seconds, user-find should success"
        sleep 30

        #step 4: after renew time limit reaches its limit, kinit -R no longer work
        rlRun "kinit -R $gusername 2>&1 | grep -i 'Ticket expired while renewing credentials' " 0 "when renew time expires, kinit -R should fail"
        rlRun "ipa user-find $gusername 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$maxlife] seconds"
        Kcleanup
     rlPhaseEnd
} #ipakrbt_functional_maxrenew

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

ipakrbt_reset_envsetup()
{
    rlPhaseStartSetup "ipakrbt_reset_envsetup"
        #environment setup starts here
	rlPass "No special setup required"
        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_reset_envsetup

ipakrbt_reset_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_reset_envcleanup"
        #environment cleanup starts here
	rlPass "No special cleanup required"
        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_reset_envcleanup

ipakrbt_reset_default()
{

    rlPhaseStartTest "restore the global krbtpolicy"
        KinitAsAdmin
        maxlife=$RANDOM
        renew=$RANDOM
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife --maxrenew=$renew" 0 "randomly set maxlife=[$maxlife], renew=[$renew]"
        ipactl restart
        actualMaxlife=`read_maxlife`
        actualRenew=`read_renew`
        if [ $actualMaxlife -eq $default_maxlife ] ; then
                rlFail "Test setup to change global max ticket life was NOT successful."
        else
                rlPass "Test setup to change global max ticket life was successful. Current global max ticket life is: $actualMaxlife"
        fi
        if [ $actualRenew -eq $default_renew ] ; then
                rlFail "Test setup to change max renew life was NOT successful."
        else
                rlPass "Test setup to change max renew life for user was successful. Current user max renew life is: $actualRenew"
        fi

        KinitAsAdmin
        rlRun "ipa krbtpolicy-reset " 0 "reset global krbt policy"
        ipactl restart
        actualMaxlife=`read_maxlife `
        actualRenew=`read_renew `
        if [ $actualMaxlife -eq $default_maxlife ] ; then
            rlPass "global max ticket life value has been reset to default [$actualMaxlife]"
        else
            rlFail "global max ticket life value reset failed, GOT: [$actualMaxlife] EXPECTED: [$default_maxlife]"
        fi

        if [ $actualRenew -eq $default_renew ] ; then
            rlPass "global max renew life value has been reset to default [$actualMaxlife]"
        else
            rlFail "global renew life reset failed. GOT: [$actualRenew] EXPECTED: [$default_renew]"
        fi
    rlPhaseEnd
    
    rlPhaseStartTest "restore krbtpolicy for given user"
        KinitAsAdmin
        maxlife=$RANDOM
        renew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife --maxrenew=$renew" 0 "randomly set maxlife=[$maxlife], renew=[$renew]"
	actualMaxlife=`read_maxlife $username`
	actualRenew=`read_renew $username`
	if [ $actualMaxlife -eq $default_maxlife ] ; then
		rlFail "Test setup to change maxlife was NOT successful."
	else
		rlPass "Test setup to change maxlife for user was successful. Current user max ticket life is: $actualMaxlife"
	fi
        if [ $actualRenew -eq $default_renew ] ; then
                rlFail "Test setup to change max renew life was NOT successful."
        else
                rlPass "Test setup to change max renew life for user was successful. Current user max renew life is: $actualRenew"
        fi

	KinitAsAdmin
        rlRun "ipa krbtpolicy-reset $username" 0 "reset the user's krbt policy"
        actualMaxlife=`read_maxlife $useranme`
        actualRenew=`read_renew $username`
        if [ $actualMaxlife -eq $default_maxlife ];then
            rlPass "max life value for [$username] has been reset to default [$default_maxlife]"
        else
            rlFail "max life value reset failed.  GOT: [$actualMaxlife] EXPECTED: [$default_maxlife]"
        fi

        if [ "$actualRenew" = "$default_renew" ];then
            rlPass "max renew value for [$username] has been reset to default [$default_renew]"
        else
            rlFail "renew reset failed. GOT: [$actualRenew] EXPECTED: [$actualRenew]"
        fi
    rlPhaseEnd
} # ipakrbt_reset_default


