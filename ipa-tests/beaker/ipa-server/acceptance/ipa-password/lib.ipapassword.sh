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
    local before=`date`
    local now
    local desiredtime
    local after
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
    KinitAsAdmin
    local out=$TmpDir/defaultvalues.$RANDOM.txt
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
    KinitAsAdmin 
    rlLog "set global password policy back to default"
    ipa pwpolicy-mod --maxlife=$default_maxlife \
                     --minlife=$default_minlife \
                     --history=$default_history \
                     --minclasses=$default_classes \
                     --minlength=$default_length 
    rlLog "reset finished"
} #reset_pwpolicy_to_default

add_test_ac()
{
    userlogin_exist $testacLogin
    if [ $? = 0 ]
    then
        delete_test_ac $testacLogin
    fi
    rlRun "$kdestroy"
    KinitAsAdmin
    rlRun "echo $initialpw |\
           ipa user-add $testacLogin\
                        --first $testacFirst\
                        --last  $testacLast\
                        --password " \
          0 "add test user account"
    # set test account password 
    FirstKinitAs $testacLogin $initialpw $testacPW
    rlRun "$kdestroy"
} # add_test_ac_

delete_test_ac()
{
    userlogin_exist $testacLogin
    if [ $? = 0 ]
    then
        rlLog "test account exist, now delete it"
        rlRun "$kdestroy"
        KinitAsAdmin
        rlRun "ipa user-del $testacLogin" 0 "delete test account [$testacLogin]"
        rlRun "$kdestroy"
    else
        rlLog "test account does not exist"
        rlPass "no need to delete"
    fi
} # delete_test_ac

userlogin_exist()
{
# return 0 if user exist
# return 1 if user account does NOT exist
    local userlogin=$1
    local out=$TmpDir/userexist.$RANDOM.out
    if [ ! -z "$userlogin" ]
    then
        KinitAsAdmin
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
    local exp=$TmpDir/kinitaftermaxlife.$RANDOM.exp
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
    local pw=$adminpassword
    local out=$TmpDir/kinitasadmin.$RANDOM.txt
    local exp
    local temppw
    echo $pw | kinit admin > $out
    if [ $? = 0 ];then
        rlPass "kinit as admin with $pw success"
    elif [ $? = 1 ];then
        if grep "Password expired" $out
        then
            rlLog "admin password exipred, do reset process"
            exp=$TmpDir/resetadminpassword.$RANDOM.exp
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
            #cat $exp
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
    rm $out
} #KinitAsAdmin

change_password()
{ # change password between min and max life os password 
  # return 0  when password change success
  # return 1  when password change failed
    local userlogin=$1
    local currentpw=$2
    local newpw=$3
    local out=$TmpDir/changepassword.$RANDOM.out
    local exp=$TmpDir/changepassword.$RANDOM.exp
    local ret
    rlLog "change password for [$userlogin] from [$currentpw] to [$newpw]"
    rlRun "echo \"$currentpw\" | kinit $userlogin" \
          0 "current pw [$currentpw] has to work before we continue"
    echo "set timeout 5" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .1}" >> $exp
    echo "spawn ipa passwd $userlogin" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "*: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect "*: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect eof ' >> $exp
    /usr/bin/expect $exp  > $out
    if grep "Constraint violation:Password Fails to meet minimum strength criteria" $out
    then
        ret=1
    else
        ret=0
    fi
    rm $out
    rm $exp
    return $ret
} #change_password

generate_password()
{
    local classes=$1
    local length=$2
    local pwoutfile=$3
    local randompw=""
    local allclasses="lowerl upperl digit special"
    local selectedclasses=""
    local i=0

    # example assume classes=3, lenght=5
    if [ $classes = 0 ];then
        classes=1 # there is no such password that has no class at all
    fi
    while [ $i -lt $classes ]
    do
        number=$RANDOM
        let "number %= 4"
        number=$((number+1)) #get random number in [1,2,3,4]
        field=`echo $allclasses | cut -d" " -f$number`
        #rlLog "num[$number],field=[$field]"
        if  echo $selectedclasses| grep $field 2>&1 >/dev/null
        then
            continue
        else
            selectedclasses="$selectedclasses $field"
            i=$((i+1))
        fi
    done
    # up to here, we might have: selectedclasses= lowerl upperl special
    #i=$classes
    field="" #this is just a symble reuse, it has no relation with previous value
    while [ $i -lt $length ]
    do
        let "index = $i % $classes"
        index=$((index+1))
        field=`echo $selectedclasses | cut -d" " -f$index`
        selectedclasses="$selectedclasses $field"
        i=$((i+1))
    done
    # up to here, we might have: selectedclasses= lowerl upperl special lowerl upperl
    #rlLog "selectedclasses=[$selectedclasses]"
    for class in $selectedclasses
    do
        get_random $class $pwoutfile
    done
    # if you want to debug, uncomment the next 2 lines
    #randompw=`cat $pwoutfile`
    #rlLog "generated password : [$randompw] classes=[$classes] length=[$length]"
} #generate_password
get_random()
{
    local class=$1
    local outf=$2
    local lowerl="a b c d e f g h i j k l m n o p q r s t u v w x y z"
    local upperl="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    local digit="0 1 2 3 4 5 6 7 8 9"
    local special="= + . , ? ! < > / ~ @ # % ^ ;"
    #local special=". , ? < > / ( ) ~ ! @ # $ % ^ & * - + = _ { } [ ] ;"
    # FIXME: the special char: $ ( ) { } [ ] _ + - & * has special meaning in shell
    # this is due to 2 cause: 1. shell treats $? $! $@ differently
    #                         2. password will be fed into expect program, 
    #                            and ()[]{} are not welcomed
    local str=""
    local len=0
    local l
    if [ $class = "lowerl" ];then
        str="$lowerl"
        len=26
    fi
    if [ $class = "upperl" ];then
        str="$upperl"
        len=26
    fi
    if [ $class = "digit" ];then
        str="$digit"
        len=10
    fi
    if [ $class = "special" ];then
        str="$special"
        len=15 #full length should be 27
    fi
    index=$RANDOM
    let "index %= $len"
    index=$((index+1))
    l=`echo $str | cut -d" " -f$index`
    #rlLog "this letter: [${l}], index=[$index]"
    echo -n "${l}" >> $outf 
} #get_random

makereport()
{
    # capture the result and make a simple report
    total=`rlJournalPrintText | grep "RESULT" | wc -l`
    pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
    fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
    abort=`rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]" | wc -l`
    report=$TmpDir/rhts.report.$RANDOM.txt
    echo "================ final pass/fail report =================" > $report
    echo "   Test Date: `date` " >> $report
    echo "   Total : [$total] "  >> $report
    echo "   Passed: [$pass] "   >> $report
    echo "   Failed: [$fail] "   >> $report
    echo "   Abort : [$abort]"   >> $report
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
