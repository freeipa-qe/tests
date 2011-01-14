#!/bin/sh
# lib used for ipa permission test

#global variables
permissionTestGroup="permissionGroup$RANDOM"
testCN="cn=$permissionTestGroup"

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
} #createPermissionTestGroup

deletePermissionTestGroup()
{
    local groupname="$1"
    local groupdesc="$2"
    local tmp=$TmpDir/deletePermissionTestGroup.$RANDOM.out
    rlRun "ipa group-del $groupname " 0 "delete ipa group: [$groupname]";
    ipa user-find $groupname | grep -i "user login" | grep -v "admin" | grep -i "${groupname}.u"| cut -d":" -f2 | sort | uniq > $tmp
    for ipausername in `cat $tmp`;do
        rlRun "ipa user-del \"$ipausername\" "
    done
    rm $tmp
} #deletePermissionTestGroup
