#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_install.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA 
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

ipa_upgrade_install_master()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_upgrade_install_master: Install and configure IPA Master for Upgrade tests"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        ipa_install_master

        rlLog "Enable LDAP Replication Debugging"
        LLOG=/tmp/ldap.enable.errlog
        unindent > $LLOG <<<"\
        dn: cn=config
        changetype: modify
        replace: nsslapd-errorlog-level
        nsslapd-errorlog-level: 8192"
        rlRun "ldapmodify -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $LLOG"

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

ipa_upgrade_install_replica()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_upgrade_install_replica: Install and configure IPA Replica for Upgrade tests"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        ipa_install_replica $MASTER

        rlLog "Enable LDAP Replication Debugging"
        LLOG=/tmp/ldap.enable.errlog
        unindent > $LLOG <<<"\
        dn: cn=config
        changetype: modify
        replace: nsslapd-errorlog-level
        nsslapd-errorlog-level: 8192"
        rlRun "ldapmodify -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f $LLOG"

        #if [ ! -f /etc/sssd/sssd.conf.backup.getent ]; then
        #    rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.backup.getent"
        #    rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf"
        #    sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
        #    rlRun "cat /etc/sssd/sssd.conf"
        #    rlRun "service sssd restart"
        #    rlRun "sleep 5"
        #fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERREPLICA1"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}

ipa_upgrade_install_client()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "ipa_upgrade_install_client: Install and configure IPA Client for Upgrade tests"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERCLIENT"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT'  $MYBEAKERCLIENT"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        ipa_install_client $MASTER

        #if [ ! -f /etc/sssd/sssd.conf.backup.getent ]; then
        #    rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.backup.getent"
        #    rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf"
        #    sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
        #    rlRun "cat /etc/sssd/sssd.conf"
        #    rlRun "service sssd restart"
        #    rlRun "sleep 5"
        #fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERCLIENT"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}
