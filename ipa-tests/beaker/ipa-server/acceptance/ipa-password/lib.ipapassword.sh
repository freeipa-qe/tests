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
    now=`date "+%s"`
    desiredtime=`echo "$now $offset" | bc`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $desiredtime"`"
    after=`date`
    echo "[set system time] before set systime [$before]"
    echo "[set system time] after  set systime [$after]"
    echo "[set system time] offset [$offset] seconds"
} # set_systime

restore_systime()
{
#restore system time by sync with ntp server
#    rlRun "service ntpd stop" 0 "Stopping local ntpd service to sync with external source"
    ntpdate $NTPSERVER
#    rlRun "service ntpd start" 0 "Starting local ntpd service again"
} # restore_systime

restart_ipa_passwd()
{
# restart ipa passwd to adopt the system time setting
    rlRun "service ipa_kpasswd restart" 0 "restart ipa_kpasswd"
} # restart_ipa_passwd

read_pwpolicy()
{
#read password policy setting
    local attr=$1
    local pwpolicy=$2
    local out=$TmpDir/read.passwordpolicy.$RANDOM.out
    local result=""
    if [ $attr = "history" ];then
        keyword="History size"
    elif [ $attr = "length" ];then
        keyword="Min length"
    elif [ $attr = "maxlife" ];then
        keyword="Max lifetime"
    elif [ $attr = "minlife" ];then
        keyword="Min lifetime"
    elif [ $attr = "classes" ];then
        keyword="Character classes"
    else
        keyword="$attr"
    fi
    Local_KinitAsAdmin 2>&1 >/dev/null
    ipa pwpolicy-show $pwpolicy > $out
    result=`grep -i "$keyword" $out | cut -d":" -f2 | xargs echo`
    rm $out
    rlRun $kdestroy 2>&1 >/dev/null
    echo $result
} # read_pwpolicy

read_default_policy_setting()
{
    Local_KinitAsAdmin
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
    echo "reset password policy"
    echo "maxlife [$globalpw_maxlife] days , minlife [$globalpw_minlife] hours"
    echo "history [$globalpw_history], classes [$globalpw_classes], length [$globalpw_length]"
    Local_KinitAsAdmin 
    echo "set global password policy back to default"
    ipa pwpolicy-mod --maxlife=$globalpw_maxlife \
                     --minlife=$globalpw_minlife \
                     --history=$globalpw_history \
                     --minclasses=$globalpw_classes \
                     --minlength=$globalpw_length 
    echo "reset finished"
    rlRun "$kdestroy"
} #reset_pwpolicy_to_default

reset_group_pwpolicy()
{
    local out=$TmpDir/setgrouppwpolicy.$RANDOM.out
    echo "set group password policy"
    echo "maxlife [$grouppw_maxlife] days, minlife [$grouppw_minlife] hours history [$grouppw_history]" 
    echo "classes [$grouppw_classes], length [$grouppw_length] priority [$grouppw_priority]"
    grppw_exist $testgrp
    if [ $? = 0 ];then
        del_grppw $testgrp
    fi
    Local_KinitAsAdmin 
    ipa pwpolicy-add $testgrp \
                     --maxlife=$grouppw_maxlife\
                     --minlife=$grouppw_minlife \
                     --history=$grouppw_history \
                     --minclasses=$grouppw_classes \
                     --minlength=$grouppw_length \
                     --priority=$grouppw_priority
    ipa pwpolicy-show $testgrp > $out
    maxlife=`grep "Max lifetime" $out | cut -d ":" -f2| xargs echo`
    minlife=`grep "Min lifetime" $out | cut -d ":" -f2| xargs echo`
    history=`grep "History size" $out | cut -d ":" -f2| xargs echo`
    classes=`grep "classes" $out | cut -d ":" -f2| xargs echo`
    length=`grep "Min length" $out | cut -d ":" -f2| xargs echo`
    priority=`grep "Priority" $out | cut -d ":" -f2| xargs echo`
    if [ $maxlife = $grouppw_maxlife ] && [ $minlife = $grouppw_minlife ] \
      && [ $history = $grouppw_history ] && [ $classes = $grouppw_classes ] \
      && [ $length = $grouppw_length ] && [ $priority = $grouppw_priority ]
    then
        rlPass "group pwpolicy has been set"
    else
        rlFail "group pwpolicy set failed"
        echo "------------------------------"
        cat $out
        echo "------------------------------"
    fi
    rlRun "$kdestroy"
} # reset_group_pwpolicy

reset_nestedgroup_pwpolicy()
{
    local out=$TmpDir/setgrouppwpolicy.$RANDOM.out
    echo "set group password policy"
    echo "maxlife [$nestedpw_maxlife] days, minlife [$nestedpw_minlife] hours history [$nestedpw_history]" 
    echo "classes [$nestedpw_classes], length [$nestedpw_length] priority [$nestedpw_priority]"
    grppw_exist $nestedgrp
    if [ $? = 0 ];then
        del_grppw $nestedgrp 
    fi
    Local_KinitAsAdmin 
    ipa pwpolicy-add $nestedgrp\
                     --maxlife=$nestedpw_maxlife\
                     --minlife=$nestedpw_minlife \
                     --history=$nestedpw_history \
                     --minclasses=$nestedpw_classes \
                     --minlength=$nestedpw_length \
                     --priority=$nestedpw_priority
    ipa pwpolicy-show $nestedgrp > $out
    maxlife=`grep "Max lifetime" $out | cut -d ":" -f2| xargs echo`
    minlife=`grep "Min lifetime" $out | cut -d ":" -f2| xargs echo`
    history=`grep "History size" $out | cut -d ":" -f2| xargs echo`
    classes=`grep "classes" $out | cut -d ":" -f2| xargs echo`
    length=`grep "Min length" $out | cut -d ":" -f2| xargs echo`
    priority=`grep "Priority" $out | cut -d ":" -f2| xargs echo`
    if [ $maxlife = $nestedpw_maxlife ] && [ $minlife = $nestedpw_minlife ] \
      && [ $history = $nestedpw_history ] && [ $classes = $nestedpw_classes ] \
      && [ $length = $nestedpw_length ] && [ $priority = $nestedpw_priority ]
    then
        rlPass "group pwpolicy has been set"
    else
        rlFail "group pwpolicy set failed"
        echo "------------------------------"
        cat $out
        echo "------------------------------"
    fi
    rlRun "$kdestroy"
    rm $out
} # reset_group_pwpolicy


util_pwpolicy_createnew()
{ #FIXME: not sure whether i need this one, just add it here for now
    local out=$TmpDir/util.pwpolicy.createnew.$RANDOM.out
    local argstring=""
    #build arguments
    local policyname=$1
    shift
    for arg in "$@";do
        thisarg="--${arg}"
        argstring="$argstring $thisarg"
    done
    Local_KinitAsAdmin
    rlRun "ipa pwpolicy-add $policyname $argstring" \
          0 "create password policy: [$policyname]"
    rm $out
} #util_pwpolicy_createnew

del_grppw()
{
    local grp=$1
    local out=$TmpDir/grpwpexist.$RANDOM.out
    Local_KinitAsAdmin
    if ipa pwpolicy-find | grep -i $grp  2>&1 >/dev/null
    then
        rlRun "ipa pwpolicy-del $grp " 0 "delete pwpolicy [$grp]"
    else
        echo "not found group password policy: [$grppw], do nothing"
    fi
    rlRun "$kdestroy"
    rm $out
} #del_grppw

grppw_exist()
{
# return 0 if group pw policy exist
# return 1 if group pw policy NOT exist
    local grp=$1
    local out=$TmpDir/grpwpexist.$RANDOM.out
    Local_KinitAsAdmin
    if ipa pwpolicy-find | grep -i $grp  2>&1 >/dev/null
    then
        echo "found group password policy: [$grp]"
        rlRun "$kdestroy"
        return 0
    else
        echo "not found group password policy: [$grp]"
        rlRun "$kdestroy"
        return 1
    fi
    rm $out
} #grppw_exist

add_test_ac()
{
    user_exist $testac
    if [ $? = 0 ]
    then
        del_test_ac 
    fi
    rlRun "$kdestroy"
    Local_KinitAsAdmin
    echo "[add_test_ac] set up test account with inital pw: [$initialpw]"
    echo $initialpw |\
           ipa user-add $testac\
                        --first $testacFirst\
                        --last  $testacLast\
                        --password 
    rc=$?    
    # set test account password 
    echo "[add_test_ac] change initialpw to [$testacPW], by calling FirstKinitAs"
    FirstKinitAs $testac $initialpw $testacPW
    rlRun "$kdestroy"
    return $rc
} # add_test_ac

del_test_ac()
{
#    user_exist $testac
#    if [ $? = 0 ]
#    then
#        echo "test account found, now delete it"
        Local_KinitAsAdmin
        ipa user-del $testac
#	rc=$?
#        rlRun "$kdestroy"
#    else
#        echo "test account does not exist, do nothing"
#    fi
#
#    return $rc

} # del_test_ac

user_exist()
{
# return 0 if user exist
# return 1 if user account does NOT exist
    local userlogin=$1
    local out=$TmpDir/userexist.$RANDOM.out
    if [ ! -z "$userlogin" ]
    then
        Local_KinitAsAdmin
        ipa user-find $userlogin > $out
        rlRun "$kdestroy"
        if grep -i "User login: $userlogin$" $out 2>&1 >/dev/null
        then
            echo "find [$userlogin] in ipa server"
            rm $out
            return 0
        else
            echo "didn't find [$userlogin]"
            rm $out
            return 1
        fi
    else
        return 1 # when login value not given, return not found
    fi
    rm $out
} #user_exist

add_test_grp()
{
    grp_exist $testgrp
    if [ $? = 0 ]
    then
        del_test_grp 
    fi
    add_grp "$testgrp" "test group for group pwpolicy"
} #add_test_grp

del_test_grp()
{
    grp_exist $testgrp
    if [ $? = 0 ]
    then
        echo "test group [$testgrp] exist, now delete it"
        del_grp "$testgrp"
    else
        echo "test group [$testgrp] does not exist, do nothing"
    fi
} #del_test_grp

add_test_nestgrp()
{
    grp_exist $nestedgrp
    if [ $? = 0 ]
    then
        del_grp $nestedgrp
    fi
    add_grp "$nestedgrp" "nested test group for group pwpplicy"
} #add_test_nestedgrp

add_grp(){
    local grpname=$1
    local desc=$2
    if [ ! -z "$grpname" ];then
        Local_KinitAsAdmin
        rlRun "ipa group-add $grpname --desc \"$desc\"" 0 "create group [$grpname]"
        rlRun "$kdestroy"
    else
        rlFail "no group name is given, fail to create group"
    fi
} # add_grp

del_grp(){
    local grpname=$1
    if [ ! -z "$grpname" ];then
        Local_KinitAsAdmin
        rlRun "ipa group-del $grpname" 0 "delete group: [$grpname]"
        rlRun "$kdestroy"
    else
        rlFail "no group name is given, fail to delete group"
    fi
} #del_grp

grp_exist()
{
    local grp=$1
    local out=$TmpDir/grpexist.$RANDOM.out
    if [ ! -z "$grp" ]
    then
        Local_KinitAsAdmin
        ipa group-find $grp > $out
        rlRun "$kdestroy"
        if grep -i "Group name: $grp$" $out 2>&1 >/dev/null
        then
            echo "group [$grp] found"
            rm $out
            return 0
        else
            echo "group [$grp] not found"
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
    Local_KinitAsAdmin
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

append_test_grp()
{
    local out=$TmpDir/appendgrouptogroup.$RANDOM.out
    Local_KinitAsAdmin
    ipa group-show $testgrp > $out
    if grep "Member groups" $out | grep -i $nestedgrp 2>&1 > /dev/null
    then
        rlPass "group [$nestedgrp] already member of [$testgrp]"
    else
        rlRun "ipa group-add-member --groups=$nestedgrp $testgrp"\
              0 "add group [$nestedgrp] as member of [$testgrp]"
        rlRun "$kdestroy"
    fi
    rm $out
} # append_test_grp

append_test_nested_ac()
{
    local out=$TmpDir/appendnestedac.$RANDOM.out
    Local_KinitAsAdmin

    # test account should not be member of top group
    ipa group-show $testgrp > $out
    if grep "Member users" $out | grep -i $testac 2>&1 > /dev/null
    then
        # remove the membership if it is
        rlRun "ipa group-remove-member $testgrp --users=$testac" \
              0 "remove [$testac] from [$testgrp]"
    fi
    
    # test account should be member of nested group
    ipa group-show $nestedgrp > $out
    if grep "Member users" $out | grep -i $testac 2>&1 > /dev/null
    then
        rlPass "[$testac] already member of [$nestedgrp]"
    else
        # if not, add it 
        rlRun "ipa group-add-member $nestedgrp --users=$testac"\
              0 "add [$testac] as member of [$nestedgrp]"
    fi
    rlRun "$kdestroy"
    rm $out
} #append_test_nested_ac

remove_test_member()
{
    local out=$TmpDir/removetestmember.$RANDOM.out
    Local_KinitAsAdmin
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
    echo "set timeout 10" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .01}" >> $exp
    echo "spawn kinit -V $username" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "*: "' >> $exp
    #echo 'sleep .5' >> $exp
    echo "send -s -- \"$pw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    #echo 'sleep .5' >> $exp
    echo 'expect "Password expired. You must change it now."' >> $exp
    echo 'expect "Enter new password: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    #echo 'sleep .5' >> $exp
    echo 'expect "Enter it again: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect eof ' >> $exp
    rlRun "$kdestroy"

    echo "====== [kinit_aftermaxlife] exp file ========="
    cat $exp
    echo "----------- ipactl status -------------------"
    ipactl status
    echo "=============================================="
    rlRun "/usr/bin/expect $exp " 0 "[kinit_aftermaxlife] ipa server should prompt for password change when system is after maxlife"
    rlRun "$kdestroy"

    echo "====== [kinit_aftermaxlife] ipactl status after run exp file ========="
    ipactl status
    echo "=============================================="

    rlRun "echo $newpw | kinit $username" 0 "[kinit_aftermaxlife] after password change prompt, try with the new password [$newpw]"
    # clean up
    rm $exp
} #kinit_aftermaxlife

Local_KinitAsAdmin()
{
    #local pw=$adminpassword
    local pw=$ADMINPW #use the password in env.sh file
    local out=$TmpDir/kinitasadmin.$RANDOM.txt
    local exp
    local temppw
    echo "[Local_KinitAsAdmin] kinit with password: [$pw]"
    echo $pw | kinit $ADMINID 2>&1 > $out
    if [ $? = 0 ];then
        rlPass "[Local_KinitAsAdmin] kinit as admin with [$pw] success"
    elif [ $? = 1 ];then
        echo "[Local_KinitAsAdmin] kinit as admin with [$pw] failed"
        echo "[Local_KinitAsAdmin] check ipactl status"
        ipactl status
        if echo $pw | kinit $ADMINID | grep -i "kinit: Generic error (see e-text) while getting initial credentials"
        then
            echo "[Local_KinitAsAdmin] got kinit: Generic error, restart ipa and try same password again"
            ipactl restart
            rlRun "$kdestroy"
            echo $pw | kinit $ADMINID 2>&1 > $out
            if [ $? = 0 ];then
                rlPass "[Local_KinitAsAdmin] kinit as admin with [$pw] success at second attemp -- after restart ipa"
                return
            fi
        fi        
            
        echo "========================================="
        echo "[Local_KinitAsAdmin] password [$pw] failed, check whether it is because password expired"
        echo "============ output of [echo $pw | kinit $ADMIN] ============="
        cat $out
        echo "============================================================"
        if grep "Password expired" $out 2>&1 >/dev/null
        then
            echo "admin password exipred, do reset process"
            exp=$TmpDir/resetadminpassword.$RANDOM.exp
            temppw="New_$pw"
            kinit_aftermaxlife "$ADMINID" "$ADMINPW" $temppw
            # set password policy to allow admin change password right away
            min=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2`
            min=`echo $min`
            history=`ipa pwpolicy-show | grep "History size" | cut -d":" -f2`
            history=`echo $history`
            classses=`ipa pwpolicy-show | grep "classes" | cut -d":" -f2`
            classes=`echo $classes`
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=0 --history=0 --minclasses=0
            # now set admin password back to original password
            echo "set timeout 10" > $exp
            echo "set force_conservative 0" >> $exp
            echo "set send_slow {1 .01}" >> $exp
            echo "spawn ipa passwd admin" >> $exp
            echo 'match_max 100000' >> $exp
            echo 'expect "Current Password: "' >> $exp
            echo "send -s -- \"$temppw\"" >> $exp
            echo 'send -s -- "\r"' >> $exp
            echo 'expect "New Password: "' >> $exp
            echo "send -s -- \"$pw\"" >> $exp
            echo 'send -s -- "\r"' >> $exp
            echo 'expect "Enter New Password again to verify: "' >> $exp
            echo "send -s -- \"$pw\"" >> $exp
            echo 'send -s -- "\r"' >> $exp
            echo 'expect eof ' >> $exp
            /usr/bin/expect $exp 
            cat $exp
            rm $exp
            # after reset password, test the new password
            $kdestroy
            echo $pw | kinit $ADMINID
            if [ $? = 1 ];then
                rlFail "[Local_KinitAsAdmin] reset password back to original [$pw] failed"
            fi
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=$min --history=$history --minclasses=$classes           
            rlPass "[Local_KinitAsAdmin] set admin password back to [$pw] success -- after set to temp"
        elif grep "Password incorrect while getting initial credentials" $out 2>&1 >/dev/null
        then
            rlFail "[Local_KinitAsAdmin] admin password wrong? [$pw]"
        else
            echo "[Local_KinitAsAdmin] unhandled error"
        fi
    else
        rlFail "[Local_KinitAsAdmin] unknow error, return code [$?] not recoginzed"
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
    echo "[change_password] change password for [$userlogin] from [$currentpw] to [$newpw]"
    #rlRun "echo \"$currentpw\" | kinit $userlogin" \
    #      0 "current pw [$currentpw] has to work before we continue"
    if klist | grep -i "Default principal: $userlogin" 2>&1 >/dev/null
    then
        echo "found kerberos for user [$userlogin], test continue"
    else
        rlFail "no kerberos found for [$userlogin], test can not continue"
        return 1
    fi
    echo "set timeout 10" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .01}" >> $exp
    echo "spawn ipa passwd $userlogin" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "Current Password: "' >> $exp
    echo "send -s -- \"$currentpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect "New Password: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect "Enter New Password again to verify: "' >> $exp
    echo "send -s -- \"$newpw\"" >> $exp
    echo 'send -s -- "\r"' >> $exp
    echo 'expect eof ' >> $exp
    /usr/bin/expect $exp  > $out
#    if grep "Constraint violation:Password Fails to meet minimum strength criteria" $out  2>&1 >/dev/null|| grep "ipa: ERROR" $out 2>&1 >/dev/null
#    then
#        ret=1
#    else
#        ret=0
#    fi
    if grep "Changed password "  $out  2>&1 >/dev/null
    then
        ret=0
    else
        ret=1
    fi
    echo "===============output of change_password==============="
    cat $exp
    echo "------------- [Above: exp ] [ below: output ] --------"
    cat $out
    echo "======================================================="

    rm $out
    rm $exp
    return $ret
} #change_password

random_password()
{
    local classes=5
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
    local pwoutfile=$TmpDir/generatepassword.$RANDOM.out
    local randompw=""
    local allclasses="lowerl upperl digit special eightbits"
    local selectedclasses=""
    local i=0

    # example assume classes=3, lenght=5
    if [ $classes = 0 ];then
        classes=1 # there is no such password that has no class at all
    fi
    if [ $classes = 1 ];then
        selectedclasses="lowerl"
    elif [ $classes = 2 ];then
        selectedclasses="lowerl upperl"
    elif [ $classes = 3 ];then
        selectedclasses="lowerl upperl digit"
    elif [ $classes = 4 ];then
        selectedclasses="lowerl upperl digit special"
    else 
        selectedclasses="lowerl upperl digit special eightbits"
    fi
        
#    while [ $i -lt $classes ]
#    do
#        number=$RANDOM
#        let "number %= 5"
#        number=$((number+1)) #get random number in [1,2,3,4,5]
#        field=`echo $allclasses | cut -d" " -f$number`
#        #echo "num[$number],field=[$field]"
#        if  echo $selectedclasses| grep $field 2>&1 >/dev/null
#        then
#            continue
#        else
#            selectedclasses="$selectedclasses $field"
#            i=$((i+1))
#        fi
#    done
    # up to here, we might have: selectedclasses= lowerl upperl special
    i=$classes
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
    #echo "selectedclasses=[$selectedclasses]"
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
    finalpw=`cat $pwoutfile`
    rm $pwoutfile
    echo $finalpw
    #echo "generated password : [$randompw] classes=[$classes] length=[$length]"
} #generate_password

get_random()
{
    local class=$1
    local outf=$2
    local lowerl="a b c d e f g h i j k l m n o p q r s t u v w x y z"
    local upperl="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    local digit="0 1 2 3 4 5 6 7 8 9"
    local special="= + . , / ~ # % ^"
    local eightbits="ò ð đ đ № π נ ğ ð ๐ š ŵ ð đ è č è č ш و"
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
        len=9 #full length should be 27
    fi
    if [ $class = "eightbits" ];then
        str="$eightbits"
        len=20 #full length should be 27
    fi

    index=$RANDOM
    let "index %= $len"
    index=$((index+1))
    l=`echo $str | cut -d" " -f$index`
    #echo "this letter: [${l}], index=[$index]"
    echo -n "${l}" >> $outf 
} #get_random

#####################################################################
#####################################################################
#####################################################################
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
    Local_KinitAsAdmin
    echo "check global pw policy"
    echo "------------------------------------------"
    ipa pwpolicy-show
    echo "------------------------------------------"
    echo "set all other password constrains to 0"
    ipa pwpolicy-mod $grp --maxlife=$grouppw_maxlife --history=0 --minlength=0 --minclasses=1 
    ipa pwpolicy-show  $grp > $out
    history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
    length=`grep "length:" $out | cut -d":" -f2|xargs echo`
    classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
    echo "set precondition: history=[$history] minlength=[$length] classes=[$classes]"
    if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
    then
        life=2 #set minlife to 2 hours

        ipa pwpolicy-mod $grp --minlife=$life
        life=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2 |xargs echo` # confirm the minlife setting
        echo "minlife has been setting to [$life] hours"
        echo "set system time 2 minute before minlife"
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
        echo "The lower bound of minlife time is [$lowbound] for group pw [$grp]"
        Local_KinitAsAdmin
        echo "set all other password constrains to 0"
        ipa pwpolicy-mod $grp --maxlife=$globalpw_maxlife --history=0 --minlength=0 --minclasses=1 
        ipa pwpolicy-show  $grp > $out
        history=`grep "History size:" $out | cut -d":" -f2|xargs echo`
        length=`grep "length:" $out | cut -d":" -f2|xargs echo`
        classes=`grep "classes:" $out | cut -d":" -f2|xargs echo`
        echo "set precondition: history=[$history] minlength=[$length] classes=[$classes]"
        if [ $history = 0 ] && [ $length = 0 ] && [ $classes = 1 ]
        then
            rlRun "ipa pwpolicy-mod $grp --minlife=$lowbound" 0 "set to lowbound should success"
            echo "minlife has been setting to [$lowbound] hours"
            echo "after set minlife to 0, we should be able to change password anytime we wont"
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

prepare_nestedgrp_testenv()
{
    add_test_grp
    add_test_nestgrp
    add_test_ac
    append_test_grp
    append_test_nested_ac
    reset_group_pwpolicy
    reset_nestedgroup_pwpolicy
} # prepare_nestedgrptestenv

cleanup_nestedgrp_testenv()
{
    del_test_ac
    util_pwpolicy_removeall
    del_grp $nestedgrp
    del_grp $testgrp
} #cleanup_nestedgrp_testenv

util_pwpolicy_removeall()
{
    local out=$TmpDir/uitl.pwpolicy.removeall.out
    local i=0
    local list
    Local_KinitAsAdmin
    ipa pwpolicy-find | grep -i "group" | grep -v -i "GLOBAL" > $out
    for line in `cat $out`; do
        pwpolicy=`echo $line | cut -d":" -f2 | xargs echo`
        if [ ! -z "$pwpolicy" ];then
            rlLogDebug "remove password policy: [$pwpolicy]"
            list="$list $pwpolicy"
            rlRun "ipa pwpolicy-del $pwpolicy 2>&1 >/dev/null" 
            i=$((i+1))
        fi
    done
    total=`wc -l $out | cut -d" " -f1`
    if [ $total = $i ];then
        rlPass "all password policy [$i:$list] have been deleted"
    else
        rlFail "expect [$total] password policy, deleted [$i]"
    fi
    rlRun "$kdestroy"
    rm $out
    unset i
    unset list
    unset out
} # util_pwpolicy_removeall

getrandomstring()
{
    local len=$1
    local i=0
    local string=""
    if [ -z $len ];then
        len=`getrandomint 1 15`
    fi
    local chars="a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
   while [ $i -lt $len ]; do
       index=`getrandomint 1 52`
       char=`echo $chars | cut -d" " -f$index`
       string="${string}${char}" 
       i=$((i+1))
   done
   echo $string
} #getrandomstring

getrandomint()
{
#usage: getrandomint <INT> to get random int between [0,INT]
#       getrandomint <INT INT> to get random int between [INT,INT]

    local i=0
    local seed=0
    local seed2=0
    local first=0
    local second=0
    local ceiling=0
    local floor=0
    local final=0
    for arg in $@;do
        i=$((i+1))
    done
    if [ $i -eq 0 ];then
        echo $RANDOM
        return
    elif [ $i -eq 1 ];then
        ceiling=$1
        floor=0
    else
        first=$1
        second=$2
        if [ $first -gt $second ];then
            ceiling=$first
            floor=$second
        else
            ceiling=$second
            floor=$first
        fi
    fi

    #echo "between: [$floor, $ceiling]"
    if [ $floor -eq $ceiling ];then
        final=$floor
        echo "$final"
        return
    fi
    diff=`echo "$ceiling - $floor + 1" | bc`
    seed=$RANDOM
    let "seed %= $ceiling"
    if [ $seed -lt $floor ];then
        seed2=$RANDOM
        let "seed2 = $seed2 % $diff "
        final=`echo "$floor + $seed2" | bc`
    else
        final=$seed
    fi
    echo $final
    return
    #echo "seed=$seed diff=$diff seed2=$seed2 final = [$final]"
} #getrandomint


