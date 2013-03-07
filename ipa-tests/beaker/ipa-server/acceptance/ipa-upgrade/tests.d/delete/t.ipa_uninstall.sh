#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_uninstall.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA multihost uninstall scripts
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
ipa_uninstall_master()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_uninstall_master: Uninstall IPA Master software"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        ipa_quick_uninstall
        [ -n $MYBEAKERMASTER ] && MASTER=$(dig +short -x $MYBEAKERMASTER|sed 's/\.$//g')
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
    
    if [ -f /tmp/ipa.master.is.2.2.0 ]; then
        rm /tmp/ipa.master.is.2.2.0
    fi
}

ipa_uninstall_slave()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_uninstall_slave: Uninstall IPA Replica/Slave Software"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        if [ "x$USEDNS" = "xyes" ]; then
            rlRun "ipa-replica-manage -p $ADMINPW del $REPLICA_S.$DOMAIN -f"
        else
            rlRun "ipa-replica-manage -p $ADMINPW del $REPLICA -f"
        fi
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        ipa_quick_uninstall
        [ -n $MYBEAKERREPLICA1 ] && REPLICA=$(dig +short -x $MYBEAKERREPLICA1|sed 's/\.$//g')
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    
    if [ -f /tmp/ipa.slave.is.2.2.0 ]; then
        rm /tmp/ipa.slave.is.2.2.0
    fi
}

ipa_uninstall_client()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_uninstall_client: Uninstall IPA Client Software"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERCLIENT"
        if [ "x$USEDNS" = "xyes" ]; then
            rlRun "ipa host-del $CLIENT_S.$DOMAIN" # --updatedns"
            if [ $(ipa dnsrecord-find $DOMAIN | grep $CLIENT_S|wc -l) -gt 0 ]; then
                rlRun "ipa dnsrecord-del $DOMAIN $CLIENT_S --del-all" 
            fi
        else
            [ -n $MYBEAKERCLIENT ] && CLIENT=$(dig +short -x $MYBEAKERCLIENT|sed 's/\.$//g')
            rlRun "ipa host-del $CLIENT"
        fi
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERCLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        KinitAsAdmin
        kdestroy
        ipa_quick_uninstall
        rlRun "yum -y remove http*"
        [ -n $MYBEAKERCLIENT ] && CLIENT=$(dig +short -x $MYBEAKERCLIENT|sed 's/\.$//g')
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERCLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}
