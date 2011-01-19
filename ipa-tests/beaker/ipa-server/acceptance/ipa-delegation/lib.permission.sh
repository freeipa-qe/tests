#!/bin/sh
# lib used for ipa permission test

#global variables
testGroup="permissiongroup$RANDOM"
testCN="cn=$testGroup"
testDC="dc=sjc,dc=redhat,dc=com"

#end of global variables

addipauser()
{
    local username=$1
    local firstname=$2
    local lastname=$3
    local userpw=$4
    rlRun "echo $userpw | ipa user-add $username --first=$firstname --last=$lastname --password 2>&1 >/dev/null " 0 "add ipa user [$username]"
} #addipauser

createPermissionTestGroup()
{
# create a ipa test group, and add 3 random user to just make it not empty
    local groupname="$1"
    local groupdesc="$2"
    KinitAsAdmin
    rlRun "ipa group-add $groupname --desc \"$groupdesc\" 2>&1 >/dev/null" 0 "create ipa group: [$groupname]";
    n=0
    while [ $n -lt 3 ];do
        id=$RANDOM
        username="${groupname}.u${id}"
        firstname="$id"
        lastname="$groupname"
        userpw="PassworD@$id"
        addipauser $username $firstname $lastname $userpw
        n=$((n+1))
        rlRun "ipa group-add-member --users=$username $groupname 2>&1 >/dev/null"
    done
    Kcleanup
} #createPermissionTestGroup

deletePermissionTestGroup()
{
    local groupname="$1"
    local groupdesc="$2"
    local tmp=$TmpDir/deletePermissionTestGroup.$RANDOM.out
    KinitAsAdmin
    rlRun "ipa group-del $groupname " 0 "delete ipa group: [$groupname]";
    ipa user-find $groupname | grep -i "user login" | grep -v "admin" | grep -i "${groupname}.u"| cut -d":" -f2 | sort | uniq > $tmp
    for ipausername in `cat $tmp`;do
        rlRun "ipa user-del \"$ipausername\" "
    done
    rm $tmp
    Kcleanup
} #deletePermissionTestGroup

deletePermission()
{
    local permissionName=$1
    if [ -n "$permissionName" ];then
        rlRun "ipa permission-del $permissionName" 0 "delete permission :[$permissionName]"
    else
        rlLog "permissionName is empty, doing nothing";
    fi
} #deletePermission

qaRun()
{
    local cmd="$1"
    local out="$2"
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local debug=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 2>$out
    actualCode=$?
    if [ "$actualCode" = "$expectCode" ];then
        rlLog "return code matches, now check the message"
        if grep -i "$expectMsg" $out 2>&1 >/dev/null
        then 
            rlPass "expected return code and msg matches"
        else
            rlFail "return code matches,but message does not match expection";
            debug="debug"
        fi
    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug="debug"
    fi
    # if debug is defined
    if [ "$debug" = "debug" ];then
        echo "--------- expected msg ---------"
        echo "[$expectMsg]"
        echo "========== execution output ==============="
        cat $out
        echo "============== end of output =============="
    fi
} #checkErrorMsg
