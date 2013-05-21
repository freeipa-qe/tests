#######################################
# lib.ipapassword test
offset_system_time_()
{
#offset system time with given string
# expected input: + 86400 <== offset system time to one day later
#                 - 86400 <== offset system time to one day before
    local offset=$1
    local before=`date`
    local now
    local desiredtime
    local after
    now=`date "+%s"`
    desiredtime=`echo "$now $offset" | bc`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $desiredtime"`"
    after=`date`
    echo "[offset system time] before set systime [$before]"
    echo "[offset system time] after  set systime [$after]"
    echo "[offset system time] offset [$offset] seconds"
	echo "[offset system time] sleep 3 seconds"
	sleep 3
} # offset_system_time_

reset_global_pwpolicy()
{
    echo "reset password policy"
    echo "maxlife [$globalpw_maxlife] days , minlife [$globalpw_minlife] hours"
    echo "history [$globalpw_history], classes [$globalpw_classes], length [$globalpw_length]"
    rlRun "rlDistroDiff keyctl"
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
    del_group_pwpolicy $testgrp
    rlRun "rlDistroDiff keyctl"
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
        rlFail "FAIL - group pwpolicy set failed"
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
    del_group_pwpolicy $nestedgrp 
    rlRun "rlDistroDiff keyctl"
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
        rlFail "FAIL - group pwpolicy set failed"
        echo "------------------------------"
        cat $out
        echo "------------------------------"
    fi
    rlRun "$kdestroy"
} # reset_group_pwpolicy

del_group_pwpolicy()
{
    local grp=$1
    local out=$TmpDir/grpwpexist.$RANDOM.out
    rlRun "rlDistroDiff keyctl"
    Local_KinitAsAdmin
    if ipa pwpolicy-find | grep -i $grp  2>&1 >/dev/null
    then
        rlLog "found password policy for group [$grp], now delete it"
        ipa pwpolicy-del $grp 
    else
        rlLog "group password policy: [$grp] not found, do nothing"
    fi
    $kdestroy
} #del_group_pwpolicy

add_test_user()
{
    local password=$1
    if [ "$password" = "" ]
    then
        password=$testacPW
        echo "[add_test_user] use default user test account password [$password]"
    else
        echo "[add_test_user] set account password to [$password]"
    fi
    
    Local_KinitAsAdmin
    ipa user-del $testac
    echo "[add_test_user] set up test account with inital pw: [$initialpw]"
	ipa user-add $testac\
    	--first $testacFirst\
        --last  $testacLast\
    # set test account password 
    echo "[add_test_user] set initialpw [$initialpw] then change to [$password], by calling FirstKinitAs"
    rlRun "rlDistroDiff keyctl"
    Local_FirstKinitAs $testac $initialpw $password
    rc=$?    
    rlRun "$kdestroy"
    return $rc
} # add_test_user

del_test_user()
{
    echo "[del_test_user] delete user: [$testac]"
    rlRun "rlDistroDiff keyctl"
    Local_KinitAsAdmin
    ipa user-del $testac
    $kdestroy
} # del_test_user

add_test_group()
{
    del_test_group 
    create_brand_new_group "$testgrp" "test group for group pwpolicy"
} #add_test_group

del_test_group()
{
    del_group "$testgrp"
} #del_test_group

add_nested_test_group()
{
    del_group $nestedgrp # regardless if group exist, just try delete it
    create_brand_new_group "$nestedgrp" "nested test group for group pwpplicy"
} #add_test_nestedgrp

create_brand_new_group(){
    local grpname=$1
    local desc=$2
    if [ ! -z "$grpname" ];then
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlRun "ipa group-add $grpname --desc \"$desc\"" 0 "create group [$grpname], desc=[$desc]"
        rlRun "$kdestroy"
    else
        rlFail "FAIL - no group name is given, fail to create group"
    fi
} # create_brand_new_group

del_group(){
    local grpname=$1
    if [ ! -z "$grpname" ];then
        rlRun "rlDistroDiff keyctl"
        Local_KinitAsAdmin
        rlLog "delete group [$grpname]"
        ipa group-del $grpname
        $kdestroy
    fi
} #del_group

append_test_user_to_tesst_group()
{
    local out=$TmpDir/appendtestmember.$RANDOM.out
    rlRun "rlDistroDiff keyctl"
    Local_KinitAsAdmin
    ipa group-show $testgrp > $out
    if grep "Member users" $out | grep -i "$testac" $out 2>&1 > /dev/null
    then
        rlPass "user [$testac] is already member of [$testgrp]"
    else
        rlLog "add user [$user] as member of grouup [$testgrp]: ipa group-add-member $testgrp --users=$testac"
        rlRun "ipa group-add-member $testgrp --users=$testac"
    fi
    rlRun "$kdestroy"
} # add_test_member

append_nested_test_group_to_test_group()
{
    local out=$TmpDir/appendgrouptogroup.$RANDOM.out
    rlRun "rlDistroDiff keyctl"
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
} # append_nested_test_group_to_test_group

append_test_user_to_nested_test_group()
{
    local out=$TmpDir/appendnestedac.$RANDOM.out
    rlRun "rlDistroDiff keyctl"
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
} #append_test_user_to_nested_test_group

remove_test_member()
{
    local out=$TmpDir/removetestmember.$RANDOM.out
    rlRun "rlDistroDiff keyctl"
    Local_KinitAsAdmin
    ipa group-show $testgrp > $out
    if grep "Member users" $out | grep -i "$testac" $out 2>&1 > /dev/null
    then
        rlRun "ipa group-remove-member $testgrp --users=$testac" 0 "remove user [$testac] from group [$testgrp]"
    else
        rlPass "user [$testac] is not member of [$testgrp],do nothing"
    fi
    rlRun "$kdestroy"
} # remove_test_member

kinit_aftermaxlife()
{
    local username=$1
    local pw=$2
    local newpw=$3
    local exp=$TmpDir/kinitaftermaxlife.$RANDOM.exp
    rlRun "rlDistroDiff keyctl"
    echo "set timeout 10" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {2 .5}" >> $exp
    echo "spawn kinit -V $username" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "*: "' >> $exp
    echo "send -s -- $pw\r" >> $exp
    echo 'expect "Password expired. You must change it now."' >> $exp
    echo 'expect "Enter new password: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect "Enter it again: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect eof' >> $exp
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

    rlRun "rlDistroDiff keyctl"
    rlRun "echo $newpw | kinit $username" 0 "[kinit_aftermaxlife] after password change prompt, try with the new password [$newpw]"
} #kinit_aftermaxlife

Local_KinitAsAdmin()
{
    #local pw=$adminpassword
    local pw=$ADMINPW #use the password in env.sh file
    local out=$TmpDir/kinitasadmin.$RANDOM.txt
    local exp
    local temppw
    rlRun "rlDistroDiff keyctl"
    echo "[Local_KinitAsAdmin] kinit with password: [$pw]"
    echo $pw | kinit $ADMINID 2>&1 > $out
    if [ $? = 0 ];then
        rlPass "[Local_KinitAsAdmin] kinit as admin with [$pw] success"
    elif [ $? = 1 ];then
        echo "[Local_KinitAsAdmin] kinit as admin with [$pw] failed"
        echo "[Local_KinitAsAdmin] check ipactl status"
        ipactl status
        rlRun "rlDistroDiff keyctl"
        if echo $pw | kinit $ADMINID | grep -i "kinit: Generic error (see e-text) while getting initial credentials"
        then
            echo "[Local_KinitAsAdmin] got kinit: Generic error, restart ipa and try same password again"
            ipactl restart
            rlRun "$kdestroy"
            rlRun "rlDistroDiff keyctl"
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
            rlRun "rlDistroDiff keyctl"
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
            echo "set send_slow {2 .5}" >> $exp
            echo "spawn ipa passwd admin" >> $exp
            echo 'expect "Current Password: "' >> $exp
            echo "send -s -- $temppw\r" >> $exp
            echo 'expect "New Password: "' >> $exp
            echo "send -s -- $pw\r" >> $exp
            echo 'expect "Enter New Password again to verify: "' >> $exp
            echo "send -s -- $pw\r" >> $exp
            echo 'expect eof' >> $exp
            /usr/bin/expect $exp 
            cat $exp
            # after reset password, test the new password
            $kdestroy
            rlRun "rlDistroDiff keyctl"
            echo $pw | kinit $ADMINID
            if [ $? = 1 ];then
                rlFail "FAIL - [Local_KinitAsAdmin] reset password back to original [$pw] failed"
            fi
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=$min --history=$history --minclasses=$classes           
            rlPass "[Local_KinitAsAdmin] set admin password back to [$pw] success -- after set to temp"
        elif grep "Password incorrect while getting initial credentials" $out 2>&1 >/dev/null
        then
            rlFail "FAIL - [Local_KinitAsAdmin] admin password wrong? [$pw]"
        else
            echo "[Local_KinitAsAdmin] unhandled error"
        fi
    else
        rlFail "FAIL - [Local_KinitAsAdmin] unknow error, return code [$?] not recoginzed"
    fi
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
    echo "[change_password] change password for user: [$userlogin] [$currentpw] --> [$newpw]"
    #rlRun "echo \"$currentpw\" | kinit $userlogin" \
    #      0 "current pw [$currentpw] has to work before we continue"
    if klist | grep -i "Default principal: $userlogin" 2>&1 >/dev/null
    then
        echo "[change_password] found kerberos for user [$userlogin], test continue"
    else
        rlRun "rlDistroDiff keyctl"
        Local_kinit $userlogin $currentpw
        if klist | grep -i "Default principal: $userlogin" 2>&1 >/dev/null
        then
            echo "[change_password] [$userlogin] kinit as current pw [$currentpw] success, test continue"
        else
            rlFail "FAIL - [change_password] no kerberos found for [$userlogin], test can not continue"
            return 1
        fi
    fi
    echo "set timeout 5" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {2 .5}" >> $exp
    echo "spawn ipa passwd $userlogin" >> $exp
    echo 'expect "Current Password: "' >> $exp
    echo "send -s -- $currentpw\r" >> $exp
    echo 'expect "New Password: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect "Enter New Password again to verify: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect eof' >> $exp
    /usr/bin/expect $exp  > $out

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

    return $ret
} #change_password

random_password()
{
    local classes=5
    local length=8
    local outfile=$TmpDir/ramdompassword.$RANDOM.out
    generate_password $classes $length $outfile
    cat $outfile
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
    rlRun "rlDistroDiff keyctl"
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
        echo "offset system time 2 minute before minlife"
        offset_system_time_ "+ 2*60*60 - 2*60"
        # before minlife, change password should fail
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $testacPW | kinit $testac" 0 "make sure currentPW work [$testacPW]"
        change_password $testac $testacPW "dummy123"
        if [ $? = 0 ];then
            rlFail "FAIL - password change success, this is not expected"
            currentPW="dummy123"
        else 
            rlPass "password change failed as expected"
            currentPW=$testacPW
        fi

        # after minlife, change passwod should success
        offset_system_time_ "+ 2*60"  # setsystime 2 minutes after
        rlRun "rlDistroDiff keyctl"
        rlRun "echo $currentPW | kinit $testac" 0 "make sure currentPW work [$currentPW]"
        newpw=`random_password`
        change_password $testac $currentPW "$newpw"
        if [ $? = 0 ];then
            rlPass "password change success, this is expected"
        else
            rlFail "FAIL - password change failed is not expected"
        fi
    else
        rlFail "FAIL - can not set pre-condition"
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
        rlRun "rlDistroDiff keyctl"
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
                offset_system_time_ "+ $offset"
                rlRun "rlDistroDiff keyctl"
                rlRun "echo $oldpw | kinit $testac" 0 "make sure currentPW work [$oldpw]"
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
            del_test_user
        else
            rlFail "FAIL - can not set pre-condition for minlife lowbound test"
        fi
    # test logic ends
} # minlife_lowerbound

prepare_nestedgrp_testenv()
{
    add_test_group
    add_nested_test_group
    add_test_user
    append_nested_test_group_to_test_group
    append_test_user_to_nested_test_group
    reset_group_pwpolicy
    reset_nestedgroup_pwpolicy
} # prepare_nestedgrptestenv

cleanup_nestedgrp_testenv()
{
    del_test_user
    delete_all_but_global_pwpolicy
    del_group $nestedgrp
    del_group $testgrp
} #cleanup_nestedgrp_testenv

delete_all_but_global_pwpolicy()
{
    local out=$TmpDir/uitl.pwpolicy.removeall.out
    local i=0
    local list=""
    rlRun "rlDistroDiff keyctl"
    Local_KinitAsAdmin
    #ipa pwpolicy-find | grep -i "group" | grep -v -i "GLOBAL" > $out <<< might trigger error
    ipa pwpolicy-find | grep -i "group" | grep -v -i "global_policy" > $out
    echo "---- debug: output of pwpolicy-find ------"
    cat $out
    echo "------ file [$out]----------"
    for line in `cat $out`; do
        pwpolicy=`echo $line | cut -d":" -f2 | xargs echo`
        echo "line=[$line], pwpolicy=(($pwpolicy))"
        if echo $line | grep "1034h"
        then
            echo "here it comes line=[$line]"
            echo "cmd: ((ipa pwpolicy-del $pwpolicy 2>&1 >/dev/null))"
            #rlRun "ipa pwpolicy-del $pwpolicy 2>&1 >/dev/null" 
        elif [ "$pwpolicy" != "" ];then
            rlLog "remove password policy: [$pwpolicy]"
            list="$list $pwpolicy"
    echo "cmd: ((ipa pwpolicy-del $pwpolicy 2>&1 >/dev/null))"
            rlRun "ipa pwpolicy-del $pwpolicy 2>&1 >/dev/null" 
            i=$((i+1))
        fi
    done
    total=`wc -l $out | cut -d" " -f1`
    if [ $total = $i ];then
        rlPass "all password policy [$i:$list] have been deleted"
    else
        rlFail "FAIL - expect [$total] password policy, deleted [$i]"
    fi
    rlRun "$kdestroy"
} # delete_all_but_global_pwpolicy

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

check_log_error(){
    local serial=$1
    local logfile=$2
    local msg=$3
    echo "****** check log error #$serial **********"
    #if sudo tail -n3 /var/log/dirsrv/slapd-YZHANG-REDHAT-COM/errors | grep "file ipapwd_common.c" 
    if sudo tail -n30 $logfile | grep "$msg"
    then
        echo "*  logfile: [$logfile]"
        echo "*  message: [$msg]"
        echo "[$serial] error found, exit test"
        exit
    fi
}

Local_FirstKinitAs()
{
	echo "calling Local_FirstKinitAs"
    local username=$1
    local password=$2
    local newpassword=$3
    local rc=0
    local outfile=/tmp/kinitAs.out
    echo "Local_FirstKinitAs:user [$username], initial pw [$password], setting password [$newpassword]"
	###### assign initial password #####
    local expfile=/tmp/kinit${RANDOM}.exp
    echo "set timeout 5" > $expfile
    echo "set send_slow {2 .5}" >> $expfile
	echo "spawn ipa passwd $username" >> $expfile
	echo "expect \"New Password: \"" >> $expfile
	echo "send -s -- $password\r">> $expfile
	echo "expect \"Enter New Password again to verify: \"" >> $expfile
	echo "send -s -- $password\r" >> $expfile
	echo "expect eof" >> $expfile
        rlRun "rlDistroDiff keyctl"
	Local_KinitAsAdmin
    echo ""
	echo "---- assign initial password [$password] to [$username] as admin -------"
	cat $expfile
	echo "------------------------------------------------------------------------"
    /usr/bin/expect $expfile
	###### kinit as user, use initial password, then change password to desired one
    expfile=/tmp/kinit${RANDOM}.exp
    echo "set timeout 10" > $expfile
    echo "set send_slow {2 .5}" >> $expfile
    echo "spawn $KINITEXEC $username" >> $expfile
    echo "expect \"Password for *\"" >> $expfile
    echo "send -s -- $password\r" >> $expfile
    echo "expect \"Enter new password: \"" >> $expfile
    echo "send -s -- $newpassword\r" >> $expfile
    echo "expect \"Enter it again: \"" >> $expfile
    echo "send -s -- $newpassword\r" >> $expfile
    echo "expect eof" >> $expfile
    echo ""
	echo "---- kinit as user [$username], then change [$password] to [$newpassword] -------"
	cat $expfile
	echo "------------------------------------------------------------------------"
    kdestroy
    rlRun "rlDistroDiff keyctl"
    /usr/bin/expect $expfile
    # verify credentials
    klist > $outfile
    grep $username $outfile
    if [ $? -ne 0 ] ; then
        rlLog "ERROR: kinit as $username with new password $newpassword failed."
        rc=1
    else
        rlLog "kinit as $username with new password $newpassword was successful."
    fi
    return $rc

} #Local_FirstKinitAs

Local_kinit()
{
    local user=$1
    local password=$2
    local expfile=$tmpdir/local_kinit.${RANDOM}.exp
    local out=${expfile}.out
    local ret=9
    local msg=""
    echo "set timeout 3" > $expfile
    echo "set send_slow {2 .5}" >> $expfile
    echo "spawn $KINITEXEC $user" >> $expfile
    echo "expect \"Password for *\"" >> $expfile
    echo "send -s -- $password\r" >> $expfile
    echo "expect eof" >> $expfile
    $kdestroy 2>&1 > /dev/null
    rlRun "rlDistroDiff keyctl"
    /usr/bin/expect $expfile 2>&1 > $out
    if klist | grep "Default principal: $user"
    then
        ret=$success
        msg="success"
    else
        ret=$fail
        msg="fail"
    fi
    
    rlLog "[Local kinit: `date`] $msg : user [$user] password [$password]"
	echo "------exp source file [$expfile]------------"
	cat $expfile
	echo "------exp execution output [$out]------------"
    cat $out
    echo "------------------------------------------------------"
    return $ret
}
