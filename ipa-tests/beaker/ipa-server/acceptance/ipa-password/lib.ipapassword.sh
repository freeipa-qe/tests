#######################################
# lib.ipapassword test
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
    globalpw_maxlife=`grep "Max lifetime" $out | cut -d":" -f2` # unit is in day
    globalpw_minlife=`grep "Min lifetime" $out | cut -d":" -f2` # unit is in hour
    globalpw_history=`grep "History size" $out | cut -d":" -f2`
    globalpw_classes=`grep "Character classes" $out | cut -d":" -f2`
    globalpw_length=`grep "Min length" $out | cut -d":" -f2`
    globalpw_history=`echo $globalpw_history`
    globalpw_classes=`echo $globalpw_classes`
    globalpw_length=`echo $globalpw_length`
    export globalpw_maxlife globalpw_minlife globalpw_history globalpw_classes globalpw_length
    rm $out
} # read_default_policy_setting

reset_global_pwpolicy()
{
    rlLog "reset password policy"
    rlLog "maxlife [$globalpw_maxlife] days , minlife [$globalpw_minlife] hours"
    rlLog "history [$globalpw_history], classes [$globalpw_classes], length [$globalpw_length]"
    KinitAsAdmin 
    rlLog "set global password policy back to default"
    ipa pwpolicy-mod --maxlife=$globalpw_maxlife \
                     --minlife=$globalpw_minlife \
                     --history=$globalpw_history \
                     --minclasses=$globalpw_classes \
                     --minlength=$globalpw_length 
    rlLog "reset finished"
    rlRun "$kdestroy"
} #reset_pwpolicy_to_default

reset_group_pwpolicy()
{
    local out=$TmpDir/setgrouppwpolicy.$RANDOM.out
    rlLog "set group password policy"
    rlLog "maxlife [$group_maxlife] days, minlife [$group_minlife] hours history [$group_history]" 
    rlLog "classes [$group_classes], length [$group_length] priority [$group_priority]"
    grppw_exist $testgrp
    if [ $? = 0 ];then
        del_grppw $testgrp
    fi
    KinitAsAdmin 
    ipa pwpolicy-add $testgrp \
                     --maxlife=$group_maxlife\
                     --minlife=$group_minlife \
                     --history=$group_history \
                     --minclasses=$group_classes \
                     --minlength=$group_length \
                     --priority=$group_priority
    ipa pwpolicy-show $testgrp > $out
    maxlife=`grep "Max lifetime" $out | cut -d ":" -f2| xargs echo`
    minlife=`grep "Min lifetime" $out | cut -d ":" -f2| xargs echo`
    history=`grep "History size" $out | cut -d ":" -f2| xargs echo`
    classes=`grep "classes" $out | cut -d ":" -f2| xargs echo`
    length=`grep "Min length" $out | cut -d ":" -f2| xargs echo`
    priority=`grep "Priority" $out | cut -d ":" -f2| xargs echo`
    if [ $maxlife = $group_maxlife ] && [ $minlife = $group_minlife ] \
      && [ $history = $group_history ] && [ $classes = $group_classes ] \
      && [ $length = $group_length ] && [ $priority = $group_priority ]
    then
        rlPass "group pwpolicy has been set"
    else
        rlFail "group pwpolicy set failed"
        echo "------------------------------"
        cat $out
        echo "------------------------------"
    fi
    rlRun "$kdestroy"
} # set_group_pwpolicy

del_grppw()
{
    local grp=$1
    local out=$TmpDir/grpwpexist.$RANDOM.out
    KinitAsAdmin
    if ipa pwpolicy-find | grep -i $grp  2>&1 >/dev/null
    then
        rlRun "ipa pwpolicy-del $grp " 0 "delete pwpolicy [$grp]"
    else
        rlLog "not found group password policy: [$grppw], do nothing"
    fi
    rlRun "$kdestroy"
} #del_grppw

grppw_exist()
{
# return 0 if group pw policy exist
# return 1 if group pw policy NOT exist
    local grp=$1
    local out=$TmpDir/grpwpexist.$RANDOM.out
    KinitAsAdmin
    if ipa pwpolicy-find | grep -i $grp  2>&1 >/dev/null
    then
        rlLog "found group password policy: [$grp]"
        rlRun "$kdestroy"
        return 0
    else
        rlLog "not found group password policy: [$grp]"
        rlRun "$kdestroy"
        return 1
    fi
} #grppw_exist

add_test_ac()
{
    user_exist $testac
    if [ $? = 0 ]
    then
        del_test_ac 
    fi
    rlRun "$kdestroy"
    KinitAsAdmin
    rlRun "echo $initialpw |\
           ipa user-add $testac\
                        --first $testacFirst\
                        --last  $testacLast\
                        --password " \
          0 "add test user account"
    # set test account password 
    FirstKinitAs $testac $initialpw $testacPW
    rlRun "$kdestroy"
} # add_test_ac

del_test_ac()
{
    user_exist $testac
    if [ $? = 0 ]
    then
        rlLog "test account found, now delete it"
        KinitAsAdmin
        rlRun "ipa user-del $testac" 0 "delete test account [$testac]"
        rlRun "$kdestroy"
    else
        rlLog "test account does not exist, do nothing"
    fi
} # del_test_ac

user_exist()
{
# return 0 if user exist
# return 1 if user account does NOT exist
    local userlogin=$1
    local out=$TmpDir/userexist.$RANDOM.out
    if [ ! -z "$userlogin" ]
    then
        KinitAsAdmin
        rlRun "ipa user-find $userlogin > $out" 0 "user [$userlogin] found"
        rlRun "$kdestroy"
        if grep -i "User login: $userlogin$" $out 2>&1 >/dev/null
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

add_test_grp()
{
    grp_exist $testgrp
    if [ $? = 0 ]
    then
        del_test_grp 
    fi
    KinitAsAdmin
    rlRun "ipa group-add $testgrp\
        --desc \"test group for group pwpolicy\" " \
          0 "add test group [$testgrp]"
    rlRun "$kdestroy"
} #add_test_grp

del_test_grp()
{
    grp_exist $testgrp
    if [ $? = 0 ]
    then
        rlLog "test group [$testgrp] exist, now delete it"
        KinitAsAdmin
        rlRun "ipa group-del $testgrp" 0 "delete test group [$testgrp]"
        rlRun "$kdestroy"
    else
        rlLog "test group [$testgrp] does not exist, do nothing"
    fi
} #del_test_grp

grp_exist()
{
    local grp=$1
    local out=$TmpDir/grpexist.$RANDOM.out
    if [ ! -z "$grp" ]
    then
        KinitAsAdmin
        rlRun "ipa group-find $grp > $out" 0 "group [$grp] found"
        rlRun "$kdestroy"
        if grep -i "Group name: $grp$" $out 2>&1 >/dev/null
        then
            rlLog "group [$grp] found"
            rm $out
            return 0
        else
            rlLog "group [$grp] not found"
            rm $out
            return 1
        fi
    else
        return 1 # when grp name is not given, return not found
    fi
} #grp_exist

append_test_member()
{
    local out=$TmpDir/appendtestmember.$RANDOM.out
    KinitAsAdmin
    ipa group-show $testgrp > $out
    if grep "Member users" $out | grep -i "$testac" $out 2>&1 > /dev/null
    then
        rlPass "user [$testac] is already member of [$testgrp]"
    else
        rlRun "ipa group-add-member $testgrp --users=$testac" 0 "add user [$testac] to group [$testgrp]"
    fi
    rlRun "$kdestroy"
    rm $out
} # add_test_member

remove_test_member()
{
    local out=$TmpDir/removetestmember.$RANDOM.out
    KinitAsAdmin
    ipa group-show $testgrp > $out
    if grep "Member users" $out | grep -i "$testac" $out 2>&1 > /dev/null
    then
        rlRun "ipa group-remove-member $testgrp --users=$testac" 0 "remove user [$testac] from group [$testgrp]"
    else
        rlPass "user [$testac] is not member of [$testgrp],do nothing"
    fi
    rlRun "$kdestroy"
    rm $out
} # remove_test_member

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
        if grep "Password expired" $out 2>&1 >/dev/null
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
        elif grep "Password incorrect while getting initial credentials" $out 2>&1 >/dev/null
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
    #rlRun "echo \"$currentpw\" | kinit $userlogin" \
    #      0 "current pw [$currentpw] has to work before we continue"
    if klist | grep -i "Default principal: $userlogin" 2>&1 >/dev/null
    then
        rlLog "found kerberos for user [$userlogin], test continue"
    else
        rlFail "no kerberos found for [$userlogin], test can not continue"
        return 1
    fi
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
    echo "===============output of change_password==============="
    cat $out
    echo "======================================================="
    if grep "Constraint violation:Password Fails to meet minimum strength criteria" $out  2>&1 >/dev/null|| grep "ipa: ERROR" $out 2>&1 >/dev/null
    then
        ret=1
    else
        ret=0
    fi
    rm $out
    rm $exp
    return $ret
} #change_password

random_password()
{
    local classes=4
    local length=8
    local outfile=$TmpDir/ramdompassword.$RANDOM.out
    generate_password $classes $length $outfile
    cat $outfile
    rm $outfile
} #ramdom_password

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
    # it is possible length<class, in this case we have to fulfill length requirement
    i=0
    for class in $selectedclasses
    do
        if [ $i -lt $length ] ;then
            get_random $class $pwoutfile
            i=$((i+1))
        fi
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
    local special="= + . , ? ! / ~ @ # % ^"
    #local special=". , ? < > / ( ) ~ ! @ # $ % ^ & * - + = _ { } [ ] ;"
    # FIXME: the special char: $ ( ) { } [ ] _ + - & * ; has special meaning in shell
    # this is due to 3 cause: 1. shell treats $? $! $@ differently
    #                         2. password will be fed into expect program, 
    #                            and ()[]{} are not welcomed
    #                         3. beaker doesn't like '<' and '>'
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
        len=12 #full length should be 27
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

#####################################################################
#####################################################################
#####################################################################

maxlife_default()
{
    local maxlife=$1
    local minlife=$2
    local midpoint=`echo "($minlife + $maxlife)/2" |bc` 
    rlLog "mid point: [$midpoint]"
    set_systime "+ $midpoint"
    rlRun "echo $testacPW | kinit $testac" 0 "kinit as same password between minlife and max life should success"

    # when system time > maxlife, ipa server should prompt for password change
    set_systime "+ $midpoint + 60"  # set system time after the max life
    rlRun "$kdestroy"
    kinit_aftermaxlife $testac $testacPW $testacNEWPW
} #maxlife_default

minlife_default()
{
    local maxlife=$1
    local minlife=$2
    local grp=$3
    local life
    local history
    local length
    local classes
    local out=$TmpDir/minlifedefault.$RANDOM.out
    KinitAsAdmin
    rlLog "check global pw policy"
    echo "------------------------------------------"
    ipa pwpolicy-show
    echo "------------------------------------------"
    rlLog "set all other password constrains to 0"
    ipa pwpolicy-mod $grp --maxlife=$group_maxlife --history=0 --minlength=0 --minclasses=1 
    ipa pwpolicy-show  $grp > $out
    history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
    length=`grep "length:" $out | cut -d":" -f2|xargs echo`
    classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
    rlLog "set preconditoin: history=[$history] minlength=[$length] classes=[$classes]"
    if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
    then
        life=2 #set minlife to 2 hours

        ipa pwpolicy-mod $grp --minlife=$life
        life=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2 |xargs echo` # confirm the minlife setting
        rlLog "minlife has been setting to [$life] hours"
        rlLog "set system time 2 minute before minlife"
        set_systime "+ 2*60*60 - 2*60"
        # before minlife, change password should fail
        rlRun "echo $testacPW | kinit $testac" 0 "make sure currentPW work [$testacPW]"
        change_password $testac $testacPW "dummy123"
        if [ $? = 0 ];then
            rlFail "password change success, this is not expected"
            currentPW="dummy123"
        else 
            rlPass "password change failed as expected"
            currentPW=$testacPW
        fi

        # after minlife, change passwod should success
        set_systime "+ 2*60"  # setsystime 2 minutes after
        rlRun "echo $currentPW | kinit $testac" 0 "make sure currentPW work [$currentPW]"
        newpw=`random_password`
        change_password $testac $currentPW "$newpw"
        if [ $? = 0 ];then
            rlPass "password change success, this is expected"
        else
            rlFail "password change failed is not expected"
        fi
    else
        rlFail "can not set pre-condition"
    fi
} #minlife_default


minlife_lowerbound()
{
    # accept parameters: NONE
    # test logic starts
        local grp=$1
        local lowbound=0
        local out=$TmpDir/minlifelowbound.$RANDOM.out
        rlLog "The lower bound of minlife time is [$lowbound] for group pw [$grp]"
        KinitAsAdmin
        rlLog "set all other password constrains to 0"
        ipa pwpolicy-mod $grp --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show  $grp > $out
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        rlLog "set preconditoin: history=[$history] minlength=[$length] classes=[$classes]"
        if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            rlRun "ipa pwpolicy-mod $grp --minlife=$lowbound" 0 "set to lowbound should success"
            rlLog "minlife has been setting to [$lowbound] hours"
            rlLog "after set minlife to 0, we should be able to change password anytime we wont"
            oldpw=$testacPW
            newpw="dummy123"
            #FIXME: I should have more test data right here
            # be aware that after this loop the system time is actually being
            # pushed back total: 0+1+2+4+8+16+32=63 seconds
            echo "====== global pwpolicy ======"
            ipa pwpolicy-show
            echo "============================="
            echo ""
            echo "====== group pwpolicy ======"
            ipa pwpolicy-show $grp
            echo "============================="
            for offset in 0 1 2 4 8 16 32
            do
                set_systime "+ $offset"
                rlRun "echo $oldpw | kinit $testac" 0 "make sure currentPW work [$oldpw]"
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
} # minlife_lowerbound


