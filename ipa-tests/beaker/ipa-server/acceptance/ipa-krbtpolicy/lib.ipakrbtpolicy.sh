#!/bin/sh
# lib for ipa krbtpolicy test

create_user()
{
    local login=$1
    local f=$2
    local l=$3
    # use default if not given
    if [ -z $login ];then
        login="$username"
    fi
    if [ -z $f ];then
        f="$first"
    fi
    if [ -z $l ];then
        l="$last"
    fi
    KinitAsAdmin
    if ipa user-find $login | grep -i "login: $login$" $out
    then
        rlRun "ipa user-del $login " 0 "remove existing user [$login]"
    fi
    rlRun "ipa user-add $login --first=$f --last=$l" 0 "create ipa user [$login]"
    clear_kticket    
} #create_user

delete_user()
{
    local login=$1
    # use default if not given
    if [ -z $login ];then
        login="$username"
    fi
    KinitAsAdmin
    rlRun "ipa user-del \"$login\" 2>&1 >/dev/null" 0 "delete test account [$login]"
    clear_kticket
} # delete_ipauser

KinitAsAdmin()
{
    # simple kinit function
    echo $adminpassword | /usr/kerberos/bin/kinit $admin 2>&1 >/dev/null
    #rlRun "echo $adminpassword | kinit $admin"
} #KinitAsAdmin

clear_kticket()
{
    /usr/kerberos/bin/kdestroy 2>&1 >/dev/null
} #clear_kticket

read_maxlife()
{
    local login=$1 #if no username given, then global max life returned
    local maxlife
    KinitAsAdmin
    maxlife=`ipa krbtpolicy-show $login | grep "Max life"| cut -d":" -f2 | xargs echo`
    clear_kticket
    echo $maxlife
} #read_maxlife

read_renew()
{
    local login=$1 #if no username given, then global max renew returned
    local renew
    KinitAsAdmin
    renew=`ipa krbtpolicy-show $login | grep "Max renew"| cut -d":" -f2 | xargs echo`
    clear_kticket
    echo $renew
} #read_renew


