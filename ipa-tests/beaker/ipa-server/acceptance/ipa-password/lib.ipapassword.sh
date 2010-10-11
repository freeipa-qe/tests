#######################################
# lib.ipapassword.sh
#######################################

# functions used in password test
set_systime_to_testtime()
{
# set system time to a desired test time
    testtime="$testmonth$testday$testhour$testmin$testsec"
    set_systime $testtime
} #set_systime_to_testtime

set_systime()
{
#set system time with given string
# expected input: + 86400 <== set system time to one day later
#                 - 86400 <== set system time to one day before
    local offset=$1
    before=`date`
    rlLog "before set systime [$before]"
    rlLog "offset [$offset] seconds"
    now=`date "+%s"`
    desiredtime=`echo "$now $offset" | bc`
    sudo date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $desiredtime"`"
    after=`date`
    rlLog "after set systime [$after]"
} # set_systime

restore_systime()
{
#restore system time by sync with ntp server
    rlRun "ntpdate $ntpserver" 0 "restore system by sync with ntp server"
} # restore_systime

restart_ipa_passwd()
{
# restart ipa passwd to adopt the system time setting
    rlRun "service ipa_kpasswd restart" 0 "restart ipa_kpasswd"
} # restart_ipa_passwd

read_default_policy_setting()
{
    KinitAsAdmin $adminpassword
    local out=$tmpdir/defaultvalues.$RANDOM.txt
    rlRun "ipa pwpolicy-show > $out" 0 "read global password policy"
    default_maxlife=`grep "Max lifetime" $out | cut -d":" -f2` # unit is in day
    default_minlife=`grep "Min lifetime" $out | cut -d":" -f2` # unit is in hour
    default_history=`grep "History size" $out | cut -d":" -f2`
    default_classes=`grep "Character classes" $out | cut -d":" -f2`
    default_length=`grep "Min length" $out | cut -d":" -f2`
    default_history=`echo $default_history`
    default_classes=`echo $default_classes`
    default_length=`echo $default_length`
    export default_maxlife default_minlife default_history default_classes default_length
    rm $out
} # read_default_policy_setting

reset_global_pwpolicy()
{
    rlLog "reset password policy"
    rlLog "maxlife [$default_maxlife] days , minlife [$default_minlife] hours"
    rlLog "history [$default_history], classes [$default_classes], length [$default_length]"
    KinitAsAdmin $adminpassword
    rlLog "set global password policy back to default"
    ipa pwpolicy-mod --maxlife=$default_maxlife \
                     --minlife=$default_minlife \
                     --history=$default_history \
                     --minclasses=$default_classes \
                     --minlength=$default_length 
    rlLog "reset finished"
} #reset_pwpolicy_to_default

add_test_user_account()
{
    userlogin_exist $testacLogin
    if [ $? = 0 ]
    then
        delete_test_user_account $testacLogin
    fi
    rlRun "echo $initialpw |\
           ipa user-add $testacLogin\
                        --first $testacFirst\
                        --last  $testacLast\
                        --password " \
          0 "add test user account"
    # set test account password 
    FirstKinitAs $testacLogin $initialpw $testacPW
} # add_test_user_account

delete_test_user_account()
{
    userlogin_exist $testacLogin
    if [ $? = 0 ]
    then
        rlLog "test account exist, now delete it"
        rlRun "$kdestroy"
        KinitAsAdmin $adminpassword
        rlRun "ipa user-del $testacLogin" 0 "delete test account [$testacLogin]"
    else
        rlLog "test account does not exist"
        rlPass "no need to delete"
    fi
} # delete_test_user_account

userlogin_exist()
{
# return 0 if user exist
# return 1 if user account does NOT exist
    local userlogin=$1
    local out=$tmpdir/userexist.txt
    if [ ! -z "$userlogin" ]
    then
        KinitAsAdmin $adminpassword
        rlRun "ipa user-find $userlogin > $out" 0 "find this user account"
        rlLog "parsing the user-find output to veirfy the account"
        if grep -i "User login: $userlogin$" $out
        then
            rlLog "find [$userlogin] in ipa server"
            rm $out
            return 0
        else
            rlLog "didn't find [$userlogin]"
            rm $out
            return 1
        fi
    else
        return 1 # when login value not given, return not found
    fi
} #user_exist

kinit_aftermaxlife()
{
    local username=$1
    local pw=$2
    local newpw=$3
    local exp=$tmpdir/kinitaftermaxlife.$RANDOM.exp
    echo "set timeout 30" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .1}" >> $exp
    echo "spawn /usr/kerberos/bin/kinit -V $username" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "*: "' >> $exp
    echo 'sleep .5' >> $exp
    echo "send -s -- \"$pw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'sleep .5' >> $exp
    echo 'expect "Password expired*"' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'sleep .5' >> $exp
    echo 'expect "*: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect eof ' >> $exp
    rlRun "$kdestroy"
    rlRun "/usr/bin/expect $exp " 0 "ipa server should prompt for password change when system is after maxlife"
    rlRun "$kdestroy"
    rlRun "echo $newpw | kinit $username" 0 "after password change prompt, try with the new password [$newpw]"
    # clean up
    rm $exp
} #kinit_aftermaxlife

KinitAsAdmin()
{
    pw=$1
    out=$tmpdir/kinitasadmin.$RANDOM.txt
    echo $pw | kinit admin > $out
    if [ $? = 0 ];then
        rlPass "kinit as admin with $pw success"
    elif [ $? = 1 ];then
        if grep "Password expired" $out
        then
            rlLog "admin password exipred, do reset process"
            exp=$tmpdir/resetadminpassword.$RANDOM.exp
            temppw="New_$pw"
            kinit_aftermaxlife "admin" $adminpassword $temppw
            # set password policy to allow admin change password right away
            min=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2`
            min=`echo $min`
            history=`ipa pwpolicy-show | grep "History size" | cut -d":" -f2`
            history=`echo $history`
            classses=`ipa pwpolicy-show | grep "classes" | cut -d":" -f2`
            classes=`echo $classes`
            ipa pwpolicy-mod --minlife=0 --history=0 --minclasses=0
            # now set admin password back to original password
            echo "set timeout 30" > $exp
            echo "set force_conservative 0" >> $exp
            echo "set send_slow {1 .1}" >> $exp
            echo "spawn ipa passwd admin" >> $exp
            echo 'match_max 100000' >> $exp
            echo 'expect "*: "' >> $exp
            echo "send -s -- \"$pw\"" >> $exp
            echo 'send -s -- "\r"' >> $exp
            echo 'expect "*: "' >> $exp
            echo "send -s -- \"$pw\"" >> $exp
            echo 'send -s -- "\r"' >> $exp
            echo 'expect eof ' >> $exp
            /usr/bin/expect $exp 
            cat $exp
            rm $exp
            # after reset password, test the new password
            $kdestroy
            echo $pw | kinit admin
            if [ $? = 1 ];then
                rlFail "reset password back to original [$pw] failed"
            fi
            ipa pwpolicy-mod --minlife=$min --history=$history --minclasses=$classes           
            rlPass "set admin password back to [$pw] success -- after set to temp"
        elif grep "Password incorrect while getting initial credentials" $out
        then
            rlFail "admin password wrong? [$pw]"
        else
            rlLog "unhandled error"
        fi
    else
        rlFail "unknow error, return code [$?] not recoginzed"
    fi
} #KinitAsAdmin

#############################################################
# This function populates the current date into the hour, min, sec, month, day and year vars
get_time()
{
	export month=$(date +%m)
	export day=$(date +%d)
	export year=$(date +%Y)
	export hour=$(date +%H)
	export min=$(date +%M)
	export sec=$(date +%S)
}

SyncDate()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"
		fi
	done
}

SyncKpasswd()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER;/etc/init.d/ipa_kpasswd restart"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"
		fi
	done
}

ResetKinit()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        # Kinit everywhere
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER;/etc/init.d/ipa_kpasswd restart"
                        message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
                        KinitAs $s $DS_USER $DM_ADMIN_PASS
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
				message "Test - $tet_thistest - ResetKinit"
				return 1
                        fi
                fi
        done
        for s in $CLIENTS; do
                if [ "$s" != "" ]; then
                        message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
                        KinitAs $s $DS_USER $DM_ADMIN_PASS
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
				message "Test - $tet_thistest - ResetKinit"
				return 1
                        fi
                fi
        done
	return 0
}

makereport()
{
    # capture the result and make a simple report
    total=`rlJournalPrintText | grep "RESULT" | wc -l`
    pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
    fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
    abort=`rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]" | wc -l`
    report=$tmpdir/rhts.report.$RANDOM.txt
    echo "================ final pass/fail report =================" > $report
    echo "   Test Date: `date` " >> $report
    echo "   Total: [$total] passed: [$pass] failed: [$fail] abort: [$abort]" >> $report
    echo "---------------------------------------------------------" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "=========================================================" >> $report
    echo "report saved as: $report"
    cat $report
}
