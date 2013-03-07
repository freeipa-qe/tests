#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.data_add.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA Upgade pre-load test data script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
# 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2013 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

######################################################################
# Source in other needed files:
######################################################################
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh

######################################################################
# If needed override variables here:
######################################################################

######################################################################
# user 
######################################################################
function ipa_quicktest_user_add()
{
    ipa user-show ${user1} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "echo ${passwd2}|ipa user-add ${user1} --first=First --last=one --password"
        rlRun "echo -e \"${passwd2}\n${passwd1}\n${passwd1}\"|kinit ${user1}"
        KinitAsAdmin
    else
        rlLog "User ${user1} already exists"
    fi

    ipa user-show ${user2} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "echo ${passwd1}|ipa user-add ${user2} --first=First --last=two --password"
        rlRun "echo -e \"${passwd1}\n${passwd2}\n${passwd2}\"|kinit ${user2}"
        KinitAsAdmin
    else
        rlLog "User ${user2} already exists"
    fi
}

function ipa_quicktest_user_check()
{
    rlRun "ipa user-find"
    rlRun "ipa user-show ${user1}" 
    rlRun "ipa user-show ${user2}" 
    rlRun "id ${user1}"
    rlRun "id ${user2}"
}

function ipa_quicktest_user_del()
{
    rlRun "ipa user-del ${user1}" 
    rlRun "ipa user-del ${user2}" 
}

######################################################################
# group
######################################################################
function ipa_quicktest_group_add()
{
    ipa group-show ${group1} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa group-add ${group1} --desc=GROUP_${group1}"
    else
        rlLog "Group ${group1} already exists"
    fi

    ipa group-show ${group2} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa group-add ${group2} --desc=GROUP_${group2}"
    else
        rlLog "Group ${group2} already exists"
    fi
}

function ipa_quicktest_group_check()
{
    rlRun "ipa group-show ${group1}"
    rlRun "ipa group-show ${group2}"
    rlRun "getent group ${group1}"
    rlRun "getent group ${group2}"
}

function ipa_quicktest_group_del()
{
    rlRun "ipa group-del ${group1}"
    rlRun "ipa group-del ${group2}"
}

######################################################################
# dnszone
######################################################################
function ipa_quicktest_dnszone_add()
{
    ipa dnszone-show ${dnsptr1} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa dnszone-add ${dnsptr1} --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
    else
        rlLog "DNS Zone ${dnsptr1} already exists"
    fi

    ipa dnszone-show ${dnsptr2} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa dnszone-add ${dnsptr2} --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
    else
        rlLog "DNS Zone ${dnsptr2} already exists"
    fi
}

function ipa_quicktest_dnszone_check()
{
    rlRun "ipa dnszone-show ${dnsptr1}"
    rlRun "ipa dnszone-show ${dnsptr2}"
    rlRun "dig +short ${dnsptr1} ns > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "$MASTER_S.$DOMAIN" $tmpout
    rlRun "dig +short ${dnsptr2} ns > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "$MASTER_S.$DOMAIN" $tmpout
}

function ipa_quicktest_dnszone_del()
{
    rlRun "ipa dnszone-del ${dnsptr1}"
    rlRun "ipa dnszone-del ${dnsptr2}"
}

######################################################################
# host
######################################################################
function ipa_quicktest_host_add()
{
    ipa host-show ${host1} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa host-add ${host1} --ip-address=${ipv41}"
    else
        rlLog "Host ${host1} already exists"
    fi

    ipa host-show ${host2} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa host-add ${host2} --ip-address=${ipv42}"
    else
        rlLog "Host ${host2} already exists"
    fi
}

function ipa_quicktest_host_check()
{
    rlRun "ipa host-show ${host1}"
    rlRun "ipa host-show ${host2}"
}

function ipa_quicktest_host_dns_check()
{
    rlRun "dig +short ${host1} a > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "${ipv41}" $tmpout
    rlRun "dig +short ${host2} a > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "${ipv42}" $tmpout
}

function ipa_quicktest_host_del()
{
    rlRun "ipa host-del ${host1} --updatedns"
    rlRun "ipa host-del ${host2} --updatedns"
}

######################################################################
# hostgroup
######################################################################
function ipa_quicktest_hostgroup_add()
{
    ipa hostgroup-show ${hostgroup1} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa hostgroup-add ${hostgroup1} --desc=hostgroupdesc"
        rlRun "ipa hostgroup-add-member ${hostgroup1} --hosts=${host1}"
    else
        rlLog "Hostgroup ${hostgroup1} already exists"
    fi

    ipa hostgroup-show ${hostgroup2} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa hostgroup-add ${hostgroup2} --desc=hostgroupdesc"
        rlRun "ipa hostgroup-add-member ${hostgroup2} --hosts=${host2}"
    else
        rlLog "Hostgroup ${hostgroup2} already exists"
    fi
}

function ipa_quicktest_hostgroup_check()
{
    rlRun "ipa hostgroup-show ${hostgroup1}"
    rlRun "ipa hostgroup-show ${hostgroup2}"
    rlRun "getent -s sss netgroup ${hostgroup1}"
    rlRun "getent -s sss netgroup ${hostgroup2}"
}

function ipa_quicktest_hostgroup_del()
{
    rlRun "ipa hostgroup-del ${hostgroup1}"
    rlRun "ipa hostgroup-del ${hostgroup2}"
}

######################################################################
# netgroup
######################################################################
function ipa_quicktest_netgroup_add()
{
    ipa netgroup-show ${netgroup1} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa netgroup-add ${netgroup1} --desc=netgroupdesc"
        rlRun "ipa netgroup-add-member ${netgroup1} --hosts=${host1} --users=${user1}"
    else
        rlLog "Netgroup ${netgroup1} already exists"
    fi

    ipa netgroup-show ${netgroup2} > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa netgroup-add ${netgroup2} --desc=netgroupdesc"
        rlRun "ipa netgroup-add-member ${netgroup2} --hosts=${host2} --users=${user2}"
    else
        rlLog "Netgroup ${netgroup2} already exists"
    fi
}
    
function ipa_quicktest_netgroup_check()
{
    rlRun "ipa netgroup-show ${netgroup1}"
    rlRun "ipa netgroup-show ${netgroup2}"
    rlRun "getent -s sss netgroup ${netgroup1}"
    rlRun "getent -s sss netgroup ${netgroup2}"
}

function ipa_quicktest_netgroup_del()
{
    rlRun "ipa netgroup-del ${netgroup1}"
    rlRun "ipa netgroup-del ${netgroup2}"
}

######################################################################
# automount
######################################################################

function ipa_quicktest_automount_add()
{
    ipa automountlocation-show testloc > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa automountlocation-add testloc"
        rlRun "ipa automountmap-add testloc ${automountmap2}"
        rlRun "ipa automountmap-add testloc ${automountmap3}"
        for i in $(seq 1 3); do
            ORIGIFS="$IFS"
            IFS=$'\n'
            for line in $(echo "${automountkey[$i]}"); do
                IFS="$ORIGIFS"
                key=$(echo  "$line" | awk '{print $1}')
                info=$(echo "$line" | sed -e "s#^$key[ \t]*##")
                rlRun "ipa automountkey-add testloc ${automountmap[$i]} --key=\"$key\" --info=\"$info\""
            done
        done
    else
        rlLog "Automount location testloc already exists"
    fi
}

function ipa_quicktest_automount_check()
{
    rlRun "ipa automountlocation-show testloc"
    rlRun "ipa automountmap-show testloc ${automountmap1}"
    rlRun "ipa automountmap-show testloc ${automountmap2}"
    rlRun "ipa automountmap-show testloc ${automountmap3}"
    for i in $(seq 1 3); do
        ORIGIFS="$IFS"
        IFS=$'\n'
        for line in $(echo "${automountkey[$i]}"); do
            IFS="$ORIGIFS"
            key=$(echo  "$line" | awk '{print $1}')
            info=$(echo "$line" | sed -e "s#^$key[ \t]*##")
            rlRun "ipa automountkey-show testloc ${automountmap[$i]} --key=\"$key\""
        done
    done
}

function ipa_quicktest_automount_del()
{
    rlRun "ipa automountlocation-del testloc"
}

######################################################################
# delegation
######################################################################
function ipa_quicktest_delegation_add()
{
    ipa delegation-show delegation_open_gecos > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa delegation-add delegation_open_gecos --group=ipausers --membergroup=ipausers --attrs=gecos"
        rlRun "ipa user-mod ${user2} --gecos=TEST${user1}"
    else
        rlLog "Delegation delegation_open_gecos already exists"
    fi
}

function ipa_quicktest_delegation_check()
{
    rlRun "ipa delegation-show delegation_open_gecos"
    rlRun "getent -s sss passwd ${user2}|grep ${user1}"
}

function ipa_quicktest_delegation_del()
{
    rlRun "ipa delegation-del delegation_open_gecos"
}

######################################################################
# selfservice
######################################################################
function ipa_quicktest_selfservice_add()
{
    ipa selfservice-show selfservice_update_gecos > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa selfservice-add selfservice_update_gecos --attrs=gecos"
        rlRun "ipa user-mod ${user1} --gecos=TEST${user1}"
    else
        rlLog "Selfservice selfservice_update_gecos already exists"
    fi
}

function ipa_quicktest_selfservice_check()
{
    rlRun "ipa selfservice-show selfservice_update_gecos"
    rlRun "getent -s sss passwd ${user1}|grep ${user1}"
}

function ipa_quicktest_selfservice_del()
{
    rlRun "ipa selfservice-del selfservice_update_gecos"
}

######################################################################
# automember
######################################################################

function ipa_quicktest_automember_add()
{
    ipa automember-show ${amgroup1} --type=group > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "ipa group-add ${amgroup1} --desc=desc"
        rlRun "ipa hostgroup-add ${amhostgroup1} --desc=desc"
        rlRun "ipa automember-add ${amgroup1} --type=group"
        rlRun "ipa automember-add ${amhostgroup1} --type=hostgroup"
        rlRun "ipa automember-add-condition ${amgroup1} --type=group --key=sn --inclusive=one"
        rlRun "ipa automember-add-condition ${amhostgroup1} --type=hostgroup --key=fqdn --exclusive-regex=^${host2}"
        rlRun "ipa automember-add-condition ${amhostgroup1} --type=hostgroup --key=fqdn --inclusive-regex=^.*\.${DOMAIN}"
        rlRun "ipa user-add ${amuser1} --first=First --last=one"
        rlRun "ipa user-add ${amuser2} --first=First --last=two"
        rlRun "ipa host-add ${amhost1} --force"
        rlRun "ipa host-add ${amhost2} --force"
    else
        rlLog "Automember ${amgroup1} already exists"
    fi
}

function ipa_quicktest_automember_check()
{
    local runtype=${1:-new} 
    local tmpout=$TmpDir/tmpout.$FUNCNAME.out
    rlLog "data_check_automember: check automember data"
    KinitAsAdmin

    if [ "$runtype" = "new" ]; then
        rlLog "Find automember group rule"
        rlRun "ipa automember-find --type=group > $tmpout 2>&1" 
        rlRun "cat $tmpout"
        rlAssertGrep "${amgroup1}" $tmpout
        rlAssertGrep "Inclusive Regex: sn=one" $tmpout
    else
        rlLog "automember-find should fail for old version"
        rlRun "ipa automember-find --type=group > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "unknown command" $tmpout
    fi
    
    if [ "$runtype" = "new" ]; then
        rlLog "Show automember hostgroup rule"
        rlRun "ipa automember-show --type=hostgroup ${amhostgroup1} > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "${amhostgroup1}" $tmpout
        rlAssertGrep "Inclusive Regex: fqdn=^.*\.${DOMAIN}" $tmpout
        rlAssertGrep "Exclusive Regex: fqdn=^${host2}" $tmpout
    else
        rlLog "automember-show should fail for old version"
        rlRun "ipa automember-show --type=hostgroup ${amhostgroup1} > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "unknown command" $tmpout
    fi

    rlLog "Confirm user added to group ${amgroup1}"
    rlRun "ipa user-show ${amuser1} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of groups.*${amgroup1}" $tmpout
    rlRun "getent -s sss group ${amgroup1}|grep ${amuser1}"

    rlLog "Confirm host added as member of ${amhostgroup1}"
    rlRun "ipa host-show ${amhost1} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of host-groups.*${amhostgroup1}" $tmpout

    rlLog "Confirm host added as member of ${amhostgroup1}"
    rlRun "ipa host-show ${amhost2} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of host-groups.*${amhostgroup1}" $tmpout
    rlRun "getent -s sss netgroup ${amhostgroup1}|grep ${amhost1}"

    rlLog "Confirming host not a member of excluded hostgroup"
    rlRun "ipa host-show ${host2} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertNotGrep "Member of host-groups.*${amhostgroup1}" $tmpout
}

function ipa_quicktest_automember_del()
{
    KinitAsAdmin
    rlLog "data_del_automember: delete automember data"
    rlRun "ipa user-del ${amuser1}"
    rlRun "ipa user-del ${amuser2}"
    rlRun "ipa group-del ${amgroup1}"
    rlRun "ipa hostgroup-del ${amhostgroup1}"
    rlRun "ipa host-del ${amhost1}"
    rlRun "ipa host-del ${amhost2}"
}

######################################################################
# THE END.
######################################################################
