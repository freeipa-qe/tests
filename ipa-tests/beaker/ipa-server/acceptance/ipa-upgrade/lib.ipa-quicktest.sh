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
DLOGRUN=1

######################################################################
# user 
######################################################################
function dlog_start()
{
    rlLog
    rlLog
    rlLog "{{{{{{{{{{{{{{{{{{{ starting $1 }}}}}}}}}}}}}}}}}}}"
    rlLog
    rlLog
}

function dlog_end()
{
    rlLog
    rlLog
    rlLog "{{{{{{{{{{{{{{{{{{{ end $1 }}}}}}}}}}}}}}}}}}}"
    rlLog
    rlLog
}

function ipa_quicktest_user_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa user-find"
    rlRun "ipa user-show ${user1}" 
    rlRun "ipa user-show ${user2}" 
    rlRun "id ${user1}"
    rlRun "id ${user2}"
}

function ipa_quicktest_user_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa user-del ${user1}" 
    rlRun "ipa user-del ${user2}" 
}

######################################################################
# group
######################################################################
function ipa_quicktest_group_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa group-show ${group1}"
    rlRun "ipa group-show ${group2}"
    rlRun "getent group ${group1}"
    rlRun "getent group ${group2}"
}

function ipa_quicktest_group_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa group-del ${group1}"
    rlRun "ipa group-del ${group2}"
}

######################################################################
# dnszone
######################################################################
function ipa_quicktest_dnszone_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa dnszone-del ${dnsptr1}"
    rlRun "ipa dnszone-del ${dnsptr2}"
}

######################################################################
# host
######################################################################
function ipa_quicktest_host_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa host-show ${host1}"
    rlRun "ipa host-show ${host2}"
}

function ipa_quicktest_host_dns_check()
{
    dlog_start $FUNCNAME
    rlRun "dig +short ${host1} a > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "${ipv41}" $tmpout
    rlRun "dig +short ${host2} a > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "${ipv42}" $tmpout
}

function ipa_quicktest_host_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa host-del ${host1} --updatedns"
    rlRun "ipa host-del ${host2} --updatedns"
}

######################################################################
# hostgroup
######################################################################
function ipa_quicktest_hostgroup_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa hostgroup-show ${hostgroup1}"
    rlRun "ipa hostgroup-show ${hostgroup2}"
    rlRun "getent -s sss netgroup ${hostgroup1}"
    rlRun "getent -s sss netgroup ${hostgroup2}"
}

function ipa_quicktest_hostgroup_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa hostgroup-del ${hostgroup1}"
    rlRun "ipa hostgroup-del ${hostgroup2}"
}

######################################################################
# netgroup
######################################################################
function ipa_quicktest_netgroup_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa netgroup-show ${netgroup1}"
    rlRun "ipa netgroup-show ${netgroup2}"
    rlRun "getent -s sss netgroup ${netgroup1}"
    rlRun "getent -s sss netgroup ${netgroup2}"
}

function ipa_quicktest_netgroup_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa netgroup-del ${netgroup1}"
    rlRun "ipa netgroup-del ${netgroup2}"
}

######################################################################
# automount
######################################################################

function ipa_quicktest_automount_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa automountlocation-del testloc"
}

######################################################################
# delegation
######################################################################
function ipa_quicktest_delegation_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa delegation-show delegation_open_gecos"
    rlRun "getent -s sss passwd ${user2}|grep ${user1}"
}

function ipa_quicktest_delegation_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa delegation-del delegation_open_gecos"
}

######################################################################
# selfservice
######################################################################
function ipa_quicktest_selfservice_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    rlRun "ipa selfservice-show selfservice_update_gecos"
    rlRun "getent -s sss passwd ${user1}|grep ${user1}"
}

function ipa_quicktest_selfservice_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa selfservice-del selfservice_update_gecos"
}

######################################################################
# automember
######################################################################

function ipa_quicktest_automember_add()
{
    dlog_start $FUNCNAME
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
    dlog_start $FUNCNAME
    local runtype=${1:-new} 
    local tmpout=$TmpDir/tmpout.$FUNCNAME.out
    rlLog "data_check_automember: check automember data"
    KinitAsAdmin

    #if [ ! -f /etc/sssd/sssd.conf.$FUNCNAME.backup ]; then
    #    rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.$FUNCNAME.backup"
    #    rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 9/' /etc/sssd/sssd.conf"
    #    sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
    #    rlRun "cat /etc/sssd/sssd.conf"
    #    rlRun "service sssd restart"
    #    rlRun "sleep 5"
    #fi


    if [ "$runtype" = "new" -o $OSVER -ge 63 ]; then
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
    
    if [ "$runtype" = "new" -o $OSVER -ge 63 ]; then
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

    #DDATE=$(date +%Y%m%d%H%M%S)
    rlRun "cat /dev/null > /var/log/sssd/sssd_${DOMAIN}.log"
    rlLog "Confirm user added to group ${amgroup1}"
    rlRun "ipa user-show ${amuser1} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of groups.*${amgroup1}" $tmpout

    rlRun "getent -s sss group ${amgroup1}| grep ${amuser1}"
    if [ $? -ne 0 ]; then
        rlRun "tar zcvf /tmp/sssd_cache.$DDATE.getent-failure.tgz /var/lib/sss"
        rlRun "rhts-submit-log -l /tmp/sssd_cache.$DDATE.getent-failure.tgz"
        rlRun "rhts-submit-log -l /var/log/sssd/sssd_${DOMAIN}.log"
    fi


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
    dlog_start $FUNCNAME
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
# ssh
######################################################################
function ipa_quicktest_ssh_add()
{
    dlog_start $FUNCNAME
    if [ "$(hostname -s)" != "$MASTER_S" ]; then
        rlLog "$FUNCNAME must be run on MASTER ($MASTER)"
        return 0
    fi

    KinitAsAdmin

    grep "sss_ssh_knownhostsproxy" /etc/ssh/ssh_config >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        rlLog "Adding configs to ssh_config"
        rlRun "cp /etc/ssh/ssh_config /etc/ssh/ssh_config.ipa_quicktest"
        unindent >> /etc/ssh/ssh_config <<<"\
        GlobalKnownHostsFile /var/lib/sss/pubconf/known_hosts
        PubkeyAuthentication yes
        ProxyCommand /usr/bin/sss_ssh_knownhostsproxy -p %p %h"
        rlRun "cat /etc/ssh/ssh_config"
    fi

    grep "sss_ssh_authorizedkeys" /etc/ssh/sshd_config >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        rlLog "Adding configs to sshd_config"
        rlRun "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ipa_quicktest"
        unindent >> /etc/ssh/sshd_config <<<"\
        AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
        KerberosAuthentication no
        PubkeyAuthentication yes
        UsePAM yes
        GSSAPIAuthentication yes"
        rlRun "cat /etc/ssh/sshd_config"
    fi

    grep services.*ssh /etc/sssd/sssd.conf >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        rlLog "Adding SSH service for sssd.conf"
        rlRun "cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf.ipa_quicktest"
        rlRun "sed -i 's/\(services.*\)$/\1, ssh/' /etc/sssd/sssd.conf"
        rlRun "echo '[ssh]' >> /etc/sssd/sssd.conf"
    fi

    rlLog "restarting ssh and sssd to make sure all configs are supported"
    rlRun "service sshd restart"
    rlRun "service sssd restart"

    ipa user-show ${sshuser1} >/dev/null 2>&1
    if [ $? -eq 2 ]; then
        rlRun "create_ipauser ${sshuser1} f l ${sshpass1}"
        KinitAsAdmin
    else
        rlLog "User ${sshuser1} already exists"
    fi
    
    ipa user-show ${sshuser1} --raw|grep sshpubkeyfp >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        rlRun "ssh-keygen -q -t rsa -N '' -f /tmp/id_rsa_${sshuser1}"
        rlRun "chown ${sshuser1}:${sshuser1} /tmp/id_rsa_${sshuser1}"
        key1="$(cat /tmp/id_rsa_${sshuser1}.pub)"
        rlRun "ipa user-mod ${sshuser1} --sshpubkey=\"${key1}\""
    else
        rlLog "User ${sshuser1} already has ssh public key"
    fi

    ipa host-show $(hostname) --raw --all|grep ipasshpubkey >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        key2="$(cat /etc/ssh/ssh_host_dsa_key.pub)"
        key3="$(cat /etc/ssh/ssh_host_rsa_key.pub)"
        rlRun "ipa host-mod $(hostname) --sshpubkey=\"${key2}, ${key3}\""
    else
        rlLog "Host $(hostname) already has ssh public keys"
    fi
}

function ipa_quicktest_ssh_check()
{
    dlog_start $FUNCNAME
    local runtype=${1:-new} 
    local tmpout=$TmpDir/tmpout.$FUNCNAME.out
    local key1file="/tmp/id_rsa_${sshuser1}.pub"

    #rlRun "rm -f /tmp/id_rsa_${sshuser1}*"
    if [ "$(hostname -s)" != "$MASTER_S" ]; then
        rlRun "sftp -o StrictHostKeyChecking=no root@${MASTER}:/tmp/id_rsa_${sshuser1}* /tmp"
    fi
    key1fp=$(ssh-keygen -l -f ${key1file} | awk '{print $2}' |
        tr '[:lower:]' '[:upper:]')

    key2file="/tmp/ssh_host_dsa_key_${MASTER}.pub"
    rlRun "ssh-keyscan -t dsa ${MASTER} > ${key2file} 2>/dev/null"
    key2fp=$(ssh-keygen -l -f ${key2file} | awk '{print $2}' |
        tr '[:lower:]' '[:upper:]')

    key3file="/tmp/ssh_host_rsa_key_${MASTER}.pub"
    rlRun "ssh-keyscan -t rsa ${MASTER} > ${key3file} 2>/dev/null"
    key3fp=$(ssh-keygen -l -f ${key3file} | awk '{print $2}' |
        tr '[:lower:]' '[:upper:]')

    if [ "$runtype" = "new" ]; then
        rlLog "Checking for User SSH Public Key"
        rlRun "ipa user-show ${sshuser1} | grep ${key1fp}"

        rlLog "Checking for Host SSH Public DSA Key"
        rlRun "ipa host-show ${MASTER} | grep ${key2fp}"

        rlLog "Checking for Host SSH Public RSA Key"
        rlRun "ipa host-show ${MASTER} | grep ${key3fp}"
    else
        rlLog "ipa sshpubkey limited support on older versions"

        rlLog "Checking old version for some ssh key for ${sshuser1}"
        rlRun "ipa user-show ${sshuser1} --raw --all|grep ipasshpubkey"
        
        rlLog "Checking old version for some ssh key for host ${MASTER}" 
        rlRun "ipa host-show ${MASTER} --all --raw|grep ipasshpubkey"
    fi

    rlRun "ssh -o StrictHostKeyChecking=no -i /tmp/id_rsa_${sshuser1} ${sshuser1}@${MASTER} hostname"
}


function ipa_quicktest_ssh_del()
{
    dlog_start $FUNCNAME
    if [ "$(hostname -s)" != "$MASTER_S" ]; then
        rlLog "$FUNCNAME must be run on MASTER ($MASTER)"
        return 0
    fi

    KinitAsAdmin
    rlRun "ipa user-del ${sshuser1}"
    rlRun "ipa host-mod $(hostname) --sshpubkey=\"\""
}

######################################################################
# SELinuxUserMap
######################################################################

function ipa_quicktest_selinuxusermap_add()
{
    dlog_start $FUNCNAME
    KinitAsAdmin
    rlRun "create_ipauser ${seuser1} f l passw0rd1"
    KinitAsAdmin
    key1="$(cat /root/.ssh/id_rsa.pub)"
    rlRun "ipa user-mod ${seuser1} --sshpubkey=\"$key1\""

    rlRun "ipa selinuxusermap-add --hostcat=all --selinuxuser=${secontext} ${serule}"
    rlRun "ipa selinuxusermap-add-user --users=${seuser1} ${serule}"
}

function ipa_quicktest_selinuxusermap_check()
{
    dlog_start $FUNCNAME
    local runtype=${1:-new}
    local tmpout=$TmpDir/tmpout.$FUNCNAME.out

    KinitAsAdmin
    rlRun "ssh -o StrictHostKeyChecking=no ${seuser1}@${MASTER} \
        'id -Z'|grep ${secontextid}"

    if [ "$runtype" = "new" -o $OSVER -ge 63 ]; then
        rlRun "ipa selinuxusermap-find ${serule}"
        rlRun "ipa selinuxusermap-show ${serule}"
    else
        rlRun "ipa selinuxusermap-find ${serule} > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "unknown command" $tmpout
    fi
}

function ipa_quicktest_selinuxusermap_del()
{
    dlog_start $FUNCNAME
    rlRun "ipa selinuxusermap-del ${serule}"
    rlRun "ipa user-del ${seuser1}"
}

######################################################################
# THE END.
######################################################################
