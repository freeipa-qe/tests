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
ipa_upgrade_data_add()
{
    local runhost=$1
    local runver=${2:-62} 
    local tmpout=/tmp/errormsg.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "Machine in recipe is $MYROLE ($HOSTNAME)"
    if [ -z "$runhost" ]; then
        rlFail "$FUNCNAME: requires paramater to determine host to run on"
        return 0
    fi
    if [ "$(hostname -s)" != $(echo $runhost|cut -f1 -d.) ]; then
        rlLog "data_check_other: checking test data on another server right now"
        rlLog "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        return 0
    fi

    rlRun "cat /etc/resolv.conf"
    rlRun "dig +short $(hostname)"
    rlRun "KinitAsAdmin"

    if [ $runver -ge 62 ]; then
        ipa_quicktest_user_add
        ipa_quicktest_group_add
        if [ "$USEDNS" != "no" ]; then
            ipa_quicktest_dnszone_add
        else
            rlLog "Skipping DNS zone add because we do not run DNS"
        fi
        ipa_quicktest_host_add
        ipa_quicktest_hostgroup_add
        ipa_quicktest_netgroup_add
        ipa_quicktest_automount_add
        ipa_quicktest_delegation_add
        ipa_quicktest_selfservice_add
    fi

    if [ $runver -ge 63 ]; then
        ipa_quicktest_automember_add
    fi

    if [ $runver -ge 64 ]; then
        ipa_quicktest_ssh_add $runtype
        ipa_quicktest_selinuxusermap_add $runtype
    fi
    rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $runhost"
}

ipa_upgrade_data_check()
{
    local runhost=$1
    local runver=${2:-62} 
    local runtype=${3:-new}

    local tmpout=/tmp/errormsg.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "Machine in recipe is $MYROLE ($HOSTNAME)"
    if [ -z "$runhost" ]; then
        rlFail "$FUNCNAME: requires paramater to determine host to run on"
        return 0
    fi
    if [ "$(hostname -s)" != $(echo $runhost|cut -f1 -d.) ]; then
        rlLog "data_check_other: checking test data on another server right now"
        rlLog "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        return 0
    fi

    rlRun "KinitAsAdmin"
    rlRun "sleep 10" # delay before starting tests...
    if [ "$runtype" = "old" ]; then
        rlLog "Debugging possible sssd issues when not yet upgraded"
        rlRun "ps -ef|grep sssd"
        rlRun "service sssd status"
    fi

    # check replica update schedule 
    rlLog "CHECKING: ldapsearch -x -h $MYBEAKERMASTER -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -b \"cn=mapping tree,cn=config\"|grep 'nsDS5ReplicaUpdateSchedule'"
    ldapsearch -x -h $MYBEAKERMASTER -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=mapping tree,cn=config"|grep 'nsDS5ReplicaUpdateSchedule' > /tmp/tmprus.out 2>&1
    rlRun "cat /tmp/tmprus.out"

    if [ $runver -ge 60 ]; then
        ipa_quicktest_user_check
        ipa_quicktest_group_check
        if [ "$USEDNS" != "no" ]; then
            ipa_quicktest_dnszone_check
        else
            rlLog "Skipping DNS zone check because we do not run DNS"
        fi
        ipa_quicktest_host_check
        ipa_quicktest_hostgroup_check
        ipa_quicktest_netgroup_check
        ipa_quicktest_automount_check
        ipa_quicktest_delegation_check
        ipa_quicktest_selfservice_check
    fi

    if [ $runver -ge 63 -a $runtype = "new" ]; then
        #rlRun "sleep 600"
        ipa_quicktest_automember_check $runtype
    fi

    if [ $runver -ge 64 -a $runtype = "new" ]; then
        ipa_quicktest_ssh_check $runtype
        ipa_quicktest_selinuxusermap_check $runtype
    fi

    rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $runhost"
}

ipa_upgrade_data_del()
{
    local runhost=$1
    local runver=${2:-62} 
    local tmpout=/tmp/errormsg.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "Machine in recipe is $MYROLE ($HOSTNAME)"
    if [ -z "$runhost" ]; then
        rlFail "$FUNCNAME: requires paramater to determine host to run on"
        return 0
    fi
    if [ "$(hostname -s)" != $(echo $runhost|cut -f1 -d.) ]; then
        rlLog "data_check_other: checking test data on another server right now"
        rlLog "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $runhost"
        return 0
    fi

    rlRun "KinitAsAdmin"
    
    if [ $runver -ge 60 ]; then
        ipa_quicktest_selfservice_del
        ipa_quicktest_delegation_del
        ipa_quicktest_automount_del
        ipa_quicktest_netgroup_del
        ipa_quicktest_hostgroup_del
        ipa_quicktest_host_del
        ipa_quicktest_dnszone_del
        ipa_quicktest_group_del
        ipa_quicktest_user_del
    fi

    if [ $runver -ge 63 ]; then
        ipa_quicktest_automember_del
    fi

    rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $runhost"
}
