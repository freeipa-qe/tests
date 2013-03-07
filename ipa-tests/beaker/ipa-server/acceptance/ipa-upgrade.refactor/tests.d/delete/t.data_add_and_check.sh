#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.data_add.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA Upgade pre-load test data script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
# 
# automember
# selfservice
# delegation
# privilege
# permission
# 
# sudo
# hbac
# service
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
data_add()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        KinitAsAdmin

        # Add users
        rlRun "echo ${passwd2}|ipa user-add ${user1} --first=First --last=one --password"
        rlRun "echo ${passwd1}|ipa user-add ${user2} --first=First --last=two --password"
        rlRun "echo -e \"${passwd2}\n${passwd1}\n${passwd1}\"|kinit ${user1}"
        KinitAsAdmin
        rlRun "echo -e \"${passwd1}\n${passwd2}\n${passwd2}\"|kinit ${user2}"
        KinitAsAdmin

        # Add groups
        rlRun "ipa group-add ${group1} --desc=GROUP_${group1}"
        rlRun "ipa group-add ${group2} --desc=GROUP_${group2}"

        if [ "x$USEDNS" = "xyes" ]; then
            # Add DNS Records (PTR)
            rlRun "ipa dnszone-add ${dnsptr1} --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
            rlRun "ipa dnszone-add ${dnsptr2} --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
        fi

        # Add hosts
        rlRun "ipa host-add ${host1} --ip-address=${ipv41}"
        rlRun "ipa host-add ${host2} --ip-address=${ipv42}"

        # Add hostgroups
        rlRun "ipa hostgroup-add ${hostgroup1} --desc=hostgroupdesc"
        rlRun "ipa hostgroup-add ${hostgroup2} --desc=hostgroupdesc"
        rlRun "ipa hostgroup-add-member ${hostgroup1} --hosts=${host1}"
        rlRun "ipa hostgroup-add-member ${hostgroup2} --hosts=${host2}"

        # Add netgroups
        rlRun "ipa netgroup-add ${netgroup1} --desc=netgroupdesc"
        rlRun "ipa netgroup-add ${netgroup2} --desc=netgroupdesc"
        rlRun "ipa netgroup-add-member ${netgroup1} --hosts=${host1} --users=${user1}"
        rlRun "ipa netgroup-add-member ${netgroup2} --hosts=${host2} --users=${user2}"
        
        # Add automount
        rlRun "ipa automountlocation-add testloc"
        #rlRun "ipa automountmap-add testloc ${automountmap1}" auto.master is a default
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

        # Add Delegations
        rlRun "ipa delegation-add delegation_open_gecos --group=ipausers --membergroup=ipausers --attrs=gecos"
        KinitAsUser ${user1} ${passwd1}
        rlRun "ipa user-mod ${user2} --gecos=TEST${user1}"
        KinitAsAdmin
        
        # Add Selfservice 
        rlRun "ipa selfservice-add selfservice_update_gecos --attrs=gecos"
        KinitAsUser ${user1} ${passwd1}
        rlRun "ipa user-mod ${user1} --gecos=TEST${user1}"
        KinitAsAdmin

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}

data_add_2()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        KinitAsAdmin
        data_add_automember

        # Add data for ssh?
        
        # Add data for selinux?

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}


data_add_automember()
{
    rlLog "data_add_automember: add automember data"
    KinitAsAdmin

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
}

#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.data_check.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA Upgade test data check script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
# user
# group
# dns record
# host
# 
# hostgroup
# netgroup
# automount
# 
# automember
# selfservice
# delegation
# privilege
# permission
# 
# sudo
# hbac
# service
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
data_check()
{
    local runhost=$1
    local tmpout=/tmp/errormsg.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    if [ "$(hostname -s)" != $(echo $runhost|cut -f1 -d.) ]; then
        rlLog "data_check_other: checking test data on another server right now"
        rlLog "Machine in recipe is $MYROLE ($HOSTNAME)"
        rlLog "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        return 0
    fi

    rlLog "data_check: check test data"

    rlLog "Machine in recipe is $MYROLE ($HOSTNAME)"
    rlRun "KinitAsAdmin"
    
    sleep 10 # delay before starting tests...

    # check replica update schedule 
    rlLog "CHECKING: ldapsearch -x -h $MYBEAKERMASTER -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -b \"cn=mapping tree,cn=config\"|grep 'nsDS5ReplicaUpdateSchedule'"
    ldapsearch -x -h $MYBEAKERMASTER -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=mapping tree,cn=config"|grep 'nsDS5ReplicaUpdateSchedule' > /tmp/tmprus.out 2>&1
    rlRun "cat /tmp/tmprus.out"

    KinitAsAdmin
    data_check_users
    data_check_groups
    data_check_dns_ptr
    data_check_hosts
    data_check_hostgroups
    data_check_netgroups
    data_check_automount
    data_check_delegations
    data_check_selfservice

    rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $runhost"
}

data_check_63()
{
    local runhost=$1
    local tmpout=/tmp/errormsg.out
    local currenteth=$(route | grep ^default | awk '{print $8}')
    local ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
    TESTCOUNT=$(( TESTCOUNT += 1 ))

    if [ "$runhost" != "$ipaddr" ]; then
        rlLog "data_check_other: checking test data on another server right now"
        rlLog "Machine in recipe is $MYROLE ($HOSTNAME)"
        rlLog "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        return 0
    fi

    rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $runhost"
}

data_check_users()
{
    # check  users
    rlRun "ipa user-find"
    rlRun "ipa user-show ${user1}" 
    rlRun "ipa user-show ${user2}" 
    rlRun "id ${user1}"
    rlRun "id ${user2}"
}

data_check_groups()
{
    # check  groups
    rlRun "ipa group-show ${group1}"
    rlRun "ipa group-show ${group2}"
    rlRun "getent group ${group1}"
    rlRun "getent group ${group2}"
}

data_check_dns_ptr()
{
    # check  DNS Records (PTR)
    if [ "x$USEDNS" = "xyes" ]; then
        rlRun "ipa dnszone-show ${dnsptr1}"
        rlRun "ipa dnszone-show ${dnsptr2}"
        rlRun "dig +short ${dnsptr1} ns > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER_S.$DOMAIN" $tmpout
        rlRun "dig +short ${dnsptr2} ns > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER_S.$DOMAIN" $tmpout
    fi
}

data_check_hosts()
{
    # check  hosts
    rlRun "ipa host-show ${host1}"
    rlRun "ipa host-show ${host2}"
    if [ "x$USEDNS" = "xyes" ]; then
        rlRun "dig +short ${host1} a > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "${ipv41}" $tmpout
        rlRun "dig +short ${host2} a > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "${ipv42}" $tmpout
    fi
}

data_check_hostgroups()
{
    # check  hostgroups
    rlRun "ipa hostgroup-show ${hostgroup1}"
    rlRun "ipa hostgroup-show ${hostgroup2}"
    rlRun "getent -s sss netgroup ${hostgroup1}"
    rlRun "getent -s sss netgroup ${hostgroup2}"
}

data_check_netgroups()
{
    # check  netgroups
    rlRun "ipa netgroup-show ${netgroup1}"
    rlRun "ipa netgroup-show ${netgroup2}"
    rlRun "getent -s sss netgroup ${netgroup1}"
    rlRun "getent -s sss netgroup ${netgroup2}"
}

data_check_automount()
{
    # check  automount
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

data_check_delegations()
{
    # check delegations
    rlRun "ipa delegation-show delegation_open_gecos"
    rlRun "getent -s sss passwd ${user2}|grep ${user1}"
}

data_check_selfservice()
{
    # check selfservice
    rlLog "Check Selfservice"
    rlRun "ipa selfservice-show selfservice_update_gecos"
    rlRun "getent -s sss passwd ${user1}|grep ${user1}"
}

data_check_automember()
{
    tmpout=$TmpDir/tmpout.$FUNCNAME.out
    rlLog "data_check_automember: check automember data"
    KinitAsAdmin

    rlLog "Find automember group rule"
    rlRun "ipa automember-find --type=group > $tmpout 2>&1" 
    rlRun "cat $tmpout"
    rlAssertGrep "${amgroup1}" $tmpout
    rlAssertGrep "Inclusive Regex: sn=one" $tmpout
    
    rlLog "Show automember hostgroup rule"
    rlRun "ipa automember-show --type=hostgroup ${amhostgroup1} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "${amhostgroup1}" $tmpout
    rlAssertGrep "Inclusive Regex: fqdn=^.*\.${DOMAIN}" $tmpout
    rlAssertGrep "Exclusive Regex: fqdn=^${host2}" $tmpout

    rlLog "Confirm user added to group ${amgroup1}"
    rlRun "ipa user-show ${amuser1} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of groups.*${amgroup1}" $tmpout

    rlLog "Confirm host added as member of ${amhostgroup1}"
    rlRun "ipa host-show ${amhost1} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of host-groups.*${amhostgroup1}" $tmpout

    rlLog "Confirm host added as member of ${amhostgroup1}"
    rlRun "ipa host-show ${amhost2} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertGrep "Member of host-groups.*${amhostgroup1}" $tmpout

    rlLog "Confirming host not a member of excluded hostgroup"
    rlRun "ipa host-show ${host2} > $tmpout 2>&1"
    rlRun "cat $tmpout"
    rlAssertNotGrep "Member of host-groups.*${amhostgroup1}" $tmpout

    rlLog "data_check_2: check set 2 for IPA data...automember"
    # check automembers
    if [ $(ipa help|grep automember|wc -l) -gt 0 ]; then
        rlRun "ipa automember-show --type=group ${amgroup1}"
        rlRun "ipa automember-show --type=hostgroup ${amhostgroup1}"
        rlRun "ipa group-find ${amgroup1} --users=${amuser1}"
        rlRun "ipa group-find ${amgroup1} --users=${amuser2}" 1 
        rlRun "ipa hostgroup-find ${amhostgroup1} --hosts=${amhost1}"
        rlRun "ipa hostgroup-find ${amhostgroup1} --hosts=${amhost2}" 0
        rlRun "getent -s sss group ${amgroup1}|grep ${amuser1}"
        rlRun "getent -s sss netgroup ${amhostgroup1}|grep ${amhost1}"
    fi
}
