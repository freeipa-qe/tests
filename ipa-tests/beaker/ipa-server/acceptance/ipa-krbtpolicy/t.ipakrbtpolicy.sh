
######################
# test suite         #
######################
ipakrbtpolicy()
{
    ipakrbt_envsetup
    ipakrbt_show
    ipakrbt_functional
    ipakrbt_mod
    ipakrbt_reset
    ipakrbt_envcleanup
} 

######################
# test sets          #
######################

ipakrbt_show()
{
    ipakrbt_show
} 

ipakrbt_functional()
{
    ipakrbt_functional_maxlife
    ipakrbt_functional_maxrenew
}

ipakrbt_mod()
{
    ipakrbt_mod_maxlife
    ipakrbt_mod_maxlife_negative
    ipakrbt_mod_maxrenew
    ipakrbt_mod_maxrenew_negative
    ipakrbt_mod_setattr
    ipakrbt_mod_setattr_negative
    ipakrbt_mod_addattr_negative
} 

ipakrbt_reset()
{
    ipakrbt_reset_default
}

######################
# test cases         #
######################
ipakrbt_envsetup()
{
    rlPhaseStartSetup "ipakrbt_envsetup"
        rlRun "rlDistroDiff keyctl"
        KinitAsAdmin	
        rlRun "ipa krbtpolicy-reset" 0 "reset krbtpolicy to default - just in case!"
	create_ipauser $username $first $last $password
	create_ipauser $gusername $first $last $password
    rlPhaseEnd
} 

ipakrbt_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_envcleanup"
	ipactl restart
        rlRun "rlDistroDiff keyctl"
        KinitAsAdmin	
	delete_user $username
	delete_user $gusername
        rlRun "rlDistroDiff keyctl"
	KinitAsAdmin
        rlRun "ipa krbtpolicy-reset" 0 "reset krbtpolicy to default - just in case!"
    rlPhaseEnd
} 

##################################################################################
#  show tests
##################################################################################

ipakrbt_show()
{
    rlPhaseStartTest "ipa-krbtpolicy-001: ipakrbt_show_global"
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

    rlPhaseStartTest "ipa-krbtpolicy-002: ipakrbt_show_user"
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

    rlPhaseStartTest "ipa-krbtpolicy-003: ipakrbt_show_all_global - supported encryption"
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
} 

##########################################################################################################
#  Functional Tests
##########################################################################################################

ipakrbt_functional_maxlife()
{
    rlPhaseStartTest "ipa-krbtpolicy-004: ipakrbt_functional_maxlife_user"
        local delay=60 # set user maxlife of kerberos ticket life to 1 minute for test account
        rlRun "rlDistroDiff keyctl"
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod $username --maxlife=$delay" 0 "set user maxlife to $delay second"
	Kcleanup
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $password | kinit $username" 0 "kinit as [$username] and expect ticket expire in $delay seconds"
        rlRun "ipa user-find $username 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep $delay
	sleep 1
        rlRun "ipa user-find $username 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$delay] seconds"
        Kcleanup 
    rlPhaseEnd

rlPhaseStartTest "ipa-krbtpolicy-005: ipakrbt_functional_maxlife_global"
        local delay=30 # set maxlife of kerberos ticket life to 30 for test account
        rlRun "rlDistroDiff keyctl"
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod --maxlife=$delay" 0 "set global maxlife to $delay second"
	ipactl restart
        Kcleanup
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $password | kinit $gusername" 0 "kinit as [$gusername] and expect ticket expire in $delay seconds"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep $delay
        rlRun "ipa user-find $gusername 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$delay] seconds"
	ipactl restart
        KinitAsAdmin
        rlRun "ipa krbtpolicy-reset" 0 "reset krbtpolicy to default - just in case!"
        Kcleanup
    rlPhaseEnd
} 

ipakrbt_functional_maxrenew()
{
    rlPhaseStartTest "ipa-krbtpolicy-006: ipakrbt_functional_maxrenew_user"
	ipactl restart
        local maxlife=60
        local renew=90
        rlRun "rlDistroDiff keyctl"
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife --maxrenew=$renew" 0 "set maxlife:[$maxlife], renew=[$renew]"
        Kcleanup

        #step 1: normal kinit should success and allow ipa user to do user-find
        rlRun "rlDistroDiff keyctl"
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

    rlPhaseStartTest "ipa-krbtpolicy-007: ipakrbt_functional_maxrenew_global"
        local maxlife=30
        local renew=60
        rlRun "rlDistroDiff keyctl"
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife --maxrenew=$renew" 0 "set maxlife:[$maxlife], renew=[$renew]"
	ipactl restart
        Kcleanup
        
        #step 1: normal kinit should success and allow ipa user to do user-find
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $password | kinit -r 60 $gusername" 0 "kinit as [$gusername] and expect ticket expire in $maxlife seconds"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after grant kerberos ticket, user-find should success"
        sleep 13

        #step 2: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R $gusername" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after kinit -R and 13 seconds, user-find should success"
	sleep 11

        #step 3: run kinit -R should give [maxlife] seonds of new life to user's kerberos ticket
        rlRun "kinit -R $gusername" 0 "when user kerberos ticket expired but still within renew time, kinit -R should give user new life"
        rlRun "ipa user-find $gusername 2>&1 >/dev/null" 0 "after kinit -R and 11 seconds, user-find should success"
        sleep 36

        #step 4: after renew time limit reaches its limit, kinit -R no longer work
        rlRun "kinit -R $gusername 2>&1 | grep -i 'Ticket expired while renewing credentials' " 0 "when renew time expires, kinit -R should fail"
        rlRun "ipa user-find $gusername 2>&1 | grep -i 'Ticket expired' " 0 "expect 'user-find' to fail for 'Ticket expired' after [$maxlife] seconds"
	ipactl restart
        KinitAsAdmin
        rlRun "ipa krbtpolicy-reset" 0 "reset krbtpolicy to default - just in case!"
        Kcleanup
     rlPhaseEnd
}

################################################################################################
#  Modify tests
################################################################################################

ipakrbt_mod_maxlife()
{
    rlPhaseStartTest "ipa-krbtpolicy-008: ipakrbt_mod_maxlife_user"
        KinitAsAdmin
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxlife=$maxlife" 0 "set maxlife=[$maxlife] for [$username]"
        actualMaxlife=`read_maxlife $username`
        if [ $actualMaxlife -eq $maxlife ] ; then
            rlPass "user [$username] max ticket life value modified to [$maxlife] success"
        else
            rlFail "user [$username] max ticket life value modify failed, GOT: [$actualMaxlife] EXPECTED: [$maxlife]"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-009: ipakrbt_mod_maxlife_global"
        maxlife=$RANDOM
	KinitAsAdmin
        rlRun "ipa krbtpolicy-mod --maxlife=$maxlife" 0 "set maxlife=[$maxlife] for global policy"
        actualMaxlife=`read_maxlife`
        if [ $actualMaxlife -eq $maxlife ] ; then
            rlPass "global max ticket life value modified to [$maxlife] success"
        else
            rlFail "global [$username] max ticket life value modify failed, GOT: [$actualMaxlife] EXPECTED: [$maxlife]"
        fi
    rlPhaseEnd
} 

ipakrbt_mod_maxlife_negative()
{
    rlPhaseStartTest "ipa-krbtpolicy-010: ipakrbt_mod_maxlife_negative"
        rlLog "set the maxlife of kerberos ticket"
        KinitAsAdmin
        for value in -1 a ab abc
        do
        	rlRun "ipa krbtpolicy-mod $username --maxlife=$value" 1 "set maxlife=[$value] for [$username] expect to fail"
        	rlRun "ipa krbtpolicy-mod --maxlife=$value" 1 "set maxlife=[$value] for global policy expect to fail"
        done
    rlPhaseEnd
} 

ipakrbt_mod_maxrenew()
{
    rlPhaseStartTest "ipa-krbtpolicy-011: ipakrbt_mod_maxrenew_user"
        KinitAsAdmin
        maxrenew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --maxrenew=$maxrenew" 0 "set maxrenew=[$maxrenew] for [$username]"
        actualRenew=`read_renew $username`
        if [ $actualRenew -eq $maxrenew ] ; then
            rlPass "user [$username] max ticket renew life value modified to [$maxrenew] success"
        else
            rlFail "user [$username] max ticket renew life value modify failed, GOT: [$actualRenew] EXPECTED: [$maxrenew]"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-012: ipakrbt_mod_maxrenew_global"
        maxrenew=$RANDOM
        KinitAsAdmin
        rlRun "ipa krbtpolicy-mod --maxrenew=$maxrenew" 0 "set maxrenew=[$maxrenew] for global policy"
        actualRenew=`read_renew`
        if [ $actualRenew -eq $maxrenew ] ; then
            rlPass "global max ticket renew life value modified to [$maxrenew] success"
        else
            rlFail "global max ticket renrew life value modify failed, GOT: [$actualRenew] EXPECTED: [$maxrenew]"
        fi
    rlPhaseEnd
}

ipakrbt_mod_maxrenew_negative()
{
    rlPhaseStartTest "ipa-krbtpolicy-013: ipakrbt_mod_maxrenew_negative"
        rlLog "set max renew life of kerberos ticket negative test case"
        KinitAsAdmin
        for value in -1 a ab abc
        do
        	rlRun "ipa krbtpolicy-mod $username --maxrenew=$value" 1 "set maxrenew=[$value] for [$username]"
        	rlRun "ipa krbtpolicy-mod --maxrenew=$value" 1 "set maxlife=[$value] for global policy"
        done
    rlPhaseEnd
} 

########################################################################################################
#  setattr and addattr tests
########################################################################################################

ipakrbt_mod_setattr()
{
    rlPhaseStartTest "ipa-krbtpolicy-014: ipakrbt_setattr_maxlife_user"
        KinitAsAdmin
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --setattr=$maxlifeattr=$maxlife" 0 "set setattr [$maxlifeattr] to [$maxlife] for [$username]"
        actualMaxlife=`read_maxlife $username`
        if [ $actualMaxlife -eq $maxlife ] ; then
            rlPass "user [$username] max ticket life value setattr $maxlifeattr to [$maxlife] success"
        else
            rlFail "user [$username] max ticket life value setattr $maxlifeattr failed, GOT: [$actualMaxlife] EXPECTED: [$maxlife]"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-015: ipakrbt_setattr_maxlife_global"
        KinitAsAdmin 
        maxlife=$RANDOM
        rlRun "ipa krbtpolicy-mod --setattr=$maxlifeattr=$maxlife" 0 "set setattr [$maxlifeattr] to [$maxlife] for [$username]"
	ipactl restart
        actualMaxlife=`read_maxlife`
        if [ $actualMaxlife -eq $maxlife ] ; then
            rlPass "global max ticket life value setattr $maxlifeattr to [$maxlife] success"
        else
            rlFail "global max ticket life value setattr $maxlifeattr failed, GOT: [$actualMaxlife] EXPECTED: [$maxlife]"
        fi  
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-016: ipakrbt_setattr_maxrenew_user"
        KinitAsAdmin
        maxrenew=$RANDOM
        rlRun "ipa krbtpolicy-mod $username --setattr=$maxrenewattr=$maxrenew" 0 "set setattr [$maxrenewattr] to [$maxrenew] for [$username]"
        actualMaxRenew=`read_renew $username`
        if [ $actualMaxRenew -eq $maxrenew ] ; then
            rlPass "user [$username] max ticket renew life value setattr $maxrenewattr to [$maxrenew] success"
        else
            rlFail "user [$username] max ticket renew life value setattr $maxrenewattr failed, GOT: [$actualMaxRenew] EXPECTED: [$maxrenew]"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-017: ipakrbt_setattr_maxrenew_global"
        KinitAsAdmin
        maxrenew=$RANDOM
        rlRun "ipa krbtpolicy-mod --setattr=$maxrenewattr=$maxrenew" 0 "set setattr [$maxrenewattr] to [$maxrenew] for [$username]"
	ipactl restart
        actualMaxRenew=`read_renew`
        if [ $actualMaxRenew -eq $maxrenew ] ; then
            rlPass "global max ticket renew life value setattr $maxreneweattr to [$maxrenew] success"
        else
            rlFail "global max ticket renew life value setattr $maxrenewattr failed, GOT: [$actualRenew] EXPECTED: [$maxrenew]"
        fi
    rlPhaseEnd

}

ipakrbt_mod_setattr_negative()
{
    rlPhaseStartTest "ipa-krbtpolicy-018: ipakrbt_mod_setattr_negative"
        KinitAsAdmin
        for value in -1 a ab abc
        do
                rlRun "ipa krbtpolicy-mod $username --setattr=$maxlifeattr=$value" 1 "set maxlife=[$value] for [$username] expect to fail"
                rlRun "ipa krbtpolicy-mod --setattr=$maxlifeattr=$value" 1 "set maxlife=[$value] for global policy expect to fail"
        done
        Kcleanup
    rlPhaseEnd
} 

ipakrbt_mod_addattr_negative()
{
    rlPhaseStartTest "ipa-krbtpolicy-019: ipakrbt_mod_addattr_maxlife_user_negative"
        KinitAsAdmin
	expmsg="krbmaxticketlife: Only one value allowed"
	rlRun "ipa krbtpolicy-mod $username --addattr=$maxlifeattr=100 2>&1 | grep -i '$expmsg' " 0 "addattr for user attribute [$maxlifeattr] should fail with message: \"$expmsg\""
    rlPhaseEnd

    rlPhaseStartTest "ipakrbt_mod_addattr_maxlife_global_negative"
        KinitAsAdmin
        expmsg="$maxlifeattr: Only one value allowed"
        rlRun "ipa krbtpolicy-mod --addattr=$maxlifeattr=100 2>&1 | grep -i '$expmsg' " 0 "addattr for global policy attribute [$maxlifeattr] should fail with message: \"$expmsg\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-020: ipakrbt_mod_addattr_maxrenew_user_negative"
        KinitAsAdmin
        expmsg="$maxrenewattr: Only one value allowed"
        rlRun "ipa krbtpolicy-mod $username --addattr=$maxrenewattr=100 2>&1 | grep -i '$expmsg' " 0 "addattr for user attribute [$maxlifeattr] should fail with message: \"$expmsg\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-krbtpolicy-021: ipakrbt_mod_addattr_maxrenew_global_negative"
        KinitAsAdmin
        expmsg="$maxrenewattr: Only one value allowed"
        rlRun "ipa krbtpolicy-mod --addattr=$maxrenewattr=100 2>&1 | grep -i '$expmsg' " 0 "addattr for global policy attribute [$maxrenewattr] should fail with message: \"$expmsg\""
    rlPhaseEnd
}

###############################################################################################
#  reset tests
###############################################################################################
ipakrbt_reset_default()
{
    rlPhaseStartTest "ipa-krbtpolicy-022: restore the global krbtpolicy"
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
    
    rlPhaseStartTest "ipa-krbtpolicy-023: restore krbtpolicy for given user"
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
}


