#!/bin/bash

# by : yzhang@redhat.com
#    : June 1, 2012
#    : for bug: https://bugzilla.redhat.com/show_bug.cgi?id=810900


###############################
# global customized veriables #
###############################

adminPW="Secret123"

################################
history=5
serial=$RANDOM
user="user${serial}"
group="group${serial}"
initialPW="Initial@${serial}"
password="passworD*1*${serial}"
pwqueue="passworD*2*${serial} passworD*3*${serial} passworD*4*${serial} passworD*5*${serial}"

grouppw_maxlife=60
grouppw_minlife=2
grouppw_history=1
grouppw_classes=1
grouppw_length=10
grouppw_priority=$serial

#sudo ipactl restart
echo "================== test start ================="
echo "history [$history] group [$group] user [$user]"
echo "password pwqueue: [$pwqueue]"
echo "initialpw [$initialPW], password[$password]"

echo "######"
echo "# 1.1 # create new user [$user]"
echo "######"
#./new.user.sh $user $initialPW
echo $adminPW | kinit admin
echo $initialPW | ipa user-add $user --first test --last $serial --password

echo "######"
echo "# 1.2 # do kinit first time for [$user] will generate problem in /var/log/dirsrv/<slapd>/errors: "
echo "#######   ipapwd_setPasswordHistory - [file ipapwd_common.c, line 926]: failed to generate new password history!"
./first.kinit.as.exp  $user $initialPW $password

echo "#####"
echo "# 2 # create new group [$group]"
echo "#####"
#./new.group.sh $group
echo "create group [$group]"
echo $adminPW | kinit admin
num=`ipa group-find $group| grep "groups matched" | cut -d" " -f1 | xargs`
if [ "$num" = "0" ];then
    echo "create new group: [$group]"
    ipa group-add $group --desc "auto add new group $group" 
else
    echo "goup [$group] exist, delete it and recreate"
    ipa group-del $group
    ipa group-add $group --desc "auto add new group $group" 
fi
echo "verify the test group"
ipa group-find $group

echo "#####"
echo "# 3 # append [$user] to group [$group]"
echo "#####"
#./append.user.to.group.sh $user $group
ipa group-add-member $group --user=$user

echo "######"
echo "# 4.1 # set password policy to default for group [$group]"
echo "######"
#./set.pwpolicy.default.sh $group
ipa pwpolicy-add $group\
                 --maxlife=$grouppw_maxlife\
                 --minlife=$grouppw_minlife\
                 --history=$grouppw_history\
                 --minclasses=$grouppw_classes\
                 --minlength=$grouppw_length\
                 --priority=$grouppw_priority
echo "######"
echo "# 4.2 # modify password policy for group [$group]: set history=[$history], turn off other constrains "
echo "######"
#./set.pwpolicy.history.sh $history $group
    if ipa pwpolicy-show $group 2>&1 | grep "password policy not found"
    then
        echo "create new password policy [$group]"
        ipa pwpolicy-add $group --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=60 --minlife=0 --minlength=0 --history=$history --priority=$grouppw_priority
    else
        echo "modify existing pw policy [$group]"
        echo "---- before modify---- "
        ipa pwpolicy-show $group
        echo "---- after modify ---- "
        ipa pwpolicy-mod $group --maxfail=0 --failinterval=0 --lockouttime=0 --maxlife=60 --minlife=0 --minlength=0 --history=$history --minclasses=1
        #ipa pwpolicy-mod $group --history=$history
    fi
    echo "--------- pwpolicy --------"
    ipa pwpolicy-show $group
    echo "-------------------------------"

echo "#####"
echo "# 5 # change user password: build history pwqueue"
echo "#####"
current=$password
for newPassword in $pwqueue
do
    echo "change password: [$current]->[$newPassword], expect success"
    echo $current | kinit $user
    ./change.password.exp $user $current $newPassword
    current=$newPassword
    echo ""
done
echo "history pwqueue: [$password $pwqueue]"

echo "#######"
echo "# 8.1 # change user password: reuse password pwqueue [$pwqueue]"
echo "#######"
for newPassword in $pwqueue
do
    echo "change password: [$current]->[$newPassword], expect fail"
    ./change.password.exp $user $current $newPassword
    echo ""
done

echo "#######"
echo "# 8.2 # here comes the bug: change password to [$password] success is not expected"
echo "#######"
    ./change.password.exp $user $current $password
echo "echo $password | kinit $user"
echo $password | kinit $user
klist

echo "================== end of test ================="
