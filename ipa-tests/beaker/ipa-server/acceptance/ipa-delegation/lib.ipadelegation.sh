#!/bin/sh
# lib used for ipa permission test

#global variables for permission test
testGroup="permissiongroup$RANDOM"
testCN="cn=$testGroup"
#testDC="dc=sjc,dc=redhat,dc=com"  # for local test
testDC="dc=$RELM"                  # for beaker execution

# global for privilege test
testPrivilege="testPrivilege$RANDOM"
testPermission_addgrp="cn=addgroups,cn=permissions,cn=pbac,$testDC"
testPermission_removegrp="cn=removegroups,cn=permissions,cn=pbac,$testDC"
testPermission_modgrp="cn=modifygroups,cn=permissions,cn=pbac,$testDC"
testPermission_modmember="cn=modifygroupmembership,cn=permissions,cn=pbac,$testDC"

# global variables for role test

#end of global variables
testRole="testRole$RANDOM"
testRole_user="useradmin"
testRole_group="groupadmin"
testRole_host="hostadmin"
testUser001="roleuser$RANDOM" #member of testGroup
testUser002="roleuser$RANDOM" #member of testGroup
testUser003="roleuser$RANDOM" #not member of testGroup
testGroup="roleGroup$RANDOM"

addipauser()
{
    local username=$1
    local firstname=$2
    local lastname=$3
    local userpw=$4
    rlRun "echo $userpw | ipa user-add $username --first=$firstname --last=$lastname --password 2>&1 >/dev/null " 0 "add ipa user [$username]"
} #addipauser

addipagroup()
{
    local groupname=$1
    if [ -n $groupname ];then
        rlRun "ipa group-add $groupname --desc=4_$groupname" 0 "add group [$groupname]"
    fi
} #addipagroup

addOneMemberToGroup()
{
    local groupname=$1
    local username=$2
    if [ -n $groupname ] && [ -n $username ];then
        rlRun "ipa group-add-member $groupname --users=$username" 0 "add [$username] to [$groupname]"
    fi
} #addOneMemberToGroup

addRoleTestAccounts()
{
    local firstname="roleTest"
    local pw="whatever@IPA.com"
    addipauser $testUser001 $firstname $testUser001 $pw
    addipauser $testUser002 $firstname $testUser002 $pw
    addipauser $testUser003 $firstname $testUser003 $pw
    addipagroup $testGroup
    addOneMemberToGroup $testGroup $testUser001
    addOneMemberToGroup $testGroup $testUser002
} #addRoleTestAccounts

deleteRoleTestAccounts()
{
    rlRun "ipa user-del $testUser001 $testUser002 $testUser003" 0 "delete test user 001,002,003"
    rlRun "ipa group-del $testGroup" 0 "delete test group"
} #deleteRoleTestAccounts

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
        rlLog "permissionName is not given, doing nothing";
    fi
} #deletePermission

checkPermissionInfo()
{
    local permissionName=$1
    local attr=$2
    local attrValue=$3
    local debug=$4
    local tmpout=$TmpDir/checkPermissionInfo.$RANDOM.out
    ipa permission-find $permissionName --all >$tmpout
    local actualValue=`grep -i $attr $tmpout | cut -d':' -f2 | xargs echo`
    if [ "$attrValue" = "$actualValue" ];then
        rlPass "expected information matches [$actualValue]"
    else
        rlFail "expected infromation not found"
        debug=debug
    fi
    if [ "$debug" = "debug" ];then
        echo "expected:[$attrValue]"
        echo "actual  :[$actualValue]";
        echo "---------------- output -----------"
        cat $tmpout
        echo "============ end of output ========="
    fi
    rm $tmpout
} #checkPermissionInfo

createTestPrivilege()
{
    local name=$1
    if [ -n $name ];then
        KinitAsAdmin
        rlRun "ipa privilege-add $name --desc=4_$name"
        Kcleanup
    fi
} #createTestPrivilege

deleteTestPrivilege()
{
    local name=$1
    if [ -n "$name" ];then
        KinitAsAdmin 
        rlRun "ipa privilege-del $name"
        Kcleanup
    fi
} #deleteTestPrivilege

checkPrivilegeInfo()
{
    local privilegeName=$1
    local attr=$2
    local attrValue=$3
    local debug=$4
    local tmpout=$TmpDir/checkPrivilegeInfo.$RANDOM.out
    ipa privilege-find $privilegeName --all >$tmpout
    local actualValue=`grep -i $attr $tmpout | cut -d':' -f2 | xargs echo`
    if echo $actualValue | grep -i "$attrValue" 2>&1; then
        rlPass "expected information matches [$actualValue]"
    else
        rlFail "expected infromation not found"
        debug=debug
    fi
    if [ "$debug" = "debug" ];then
        echo "expected:[$attrValue]"
        echo "actual  :[$actualValue]";
        echo "---------------- output -----------"
        cat $tmpout
        echo "============ end of output ========="
    fi
    rm $tmpout
} #checkPrivilegeInfo

createTestRole()
{
    local name=$1
    local desc=4_$name
    rlRun "ipa role-add $name --desc=$desc" 0 "create test role: [$name]"
} #createTestRole

checkRoleInfo()
{
    local role=$1
    local attr=$2
    local value=$3
    local tmpout=$TmpDir/checkroleinfo.$RANDOM.out
    ipa role-find $role --all 2>&1 > $tmpout
    local actual=`grep -i $attr $tmpout | xargs echo`
    if echo "$actual" | grep -i "$value" 2>&1;then
        rlPass "found [$value] in actual [$actual]"
    else
         rlFail "actual [$actual] does not contain expected=[$value]"
         echo "-------- output ------------"
         cat $tmpout
         echo "============================"
    fi
    rm $tmpout
} #checkRoleInfo

deleteTestRole()
{
    local name=$1
    rlRun "ipa role-del $name" 0 "delete test role: [$name]"
} #deleteTestRole

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
