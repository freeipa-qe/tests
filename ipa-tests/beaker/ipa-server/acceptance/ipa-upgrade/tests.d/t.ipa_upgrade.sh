#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.upgrade.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA multihost upgrade script
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

reset_repos()
{
    unset ${!myrepo*}
    myrepo1=$latestrepo1
    myrepo2=$latestrepo2
    myrepo3=$latestrepo3

    if [ -n "$MYNEWREPO1" ]; then
        myrepo1="$MYNEWREPO1"
    fi
    if [ -n "$MYNEWREPO2" ]; then
        myrepo2="$MYNEWREPO2"
    fi
    if [ -n "$MYNEWREPO3" ]; then
        myrepo3="$MYNEWREPO3"
    fi
    if [ -n "$MYNEWREPO4" ]; then
        myrepo4="$MYNEWREPO4"
    fi
    if [ -n "$MYNEWREPO5" ]; then
        myrepo5="$MYNEWREPO5"
    fi
}

ipa_yum_repo_setup()
{
    rlLog "ipa_yum_repo_setup: Setup Yum Repos"
    for repoi in $(seq 1 10); do
        url=$(echo $(eval echo \$myrepo$repoi))
        if [ -n "$url" ]; then
            unindent > /etc/yum.repos.d/mytestrepo$repoi.repo <<<"\
            [mytestrepo$repoi]
            name=mytestrepo$repoi
            baseurl=$url
            enabled=1
            gpgcheck=0
            skip_if_unavailable=1"
            rlRun "cat /etc/yum.repos.d/mytestrepo$repoi.repo"
        fi
    done
}

upgrade_master()
{
    local repoi=0
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "upgrade_master: upgrade ipa master"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rpm -q $PKG-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"

        ipa_yum_repo_setup

        rlRun "yum clean all"
        rlRun "yum -y update 'ipa*'"    
        rlRun "yum -y update redhat-release"
        rlRun "ipactl status"
        rlRun "service sssd status"
        rlRun "service sssd restart"
        rlRun "rpm -q $PKG-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"
        export OSVER=$(sed 's/^.* \([0-9]\)\.\([0-9]\) .*$/\1\2/' /etc/redhat-release)

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

upgrade_master_replica()
{
    local repoi=0
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "upgrade_master_replica: upgrade ipa master and replica"
    case "$MYROLE" in
    MASTER*|REPLICA*)
        rlLog "Machine in recipe is $MYROLE"
        rlRun "rpm -q $PKG-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"

        ipa_yum_repo_setup
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.start'"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.start' $MYBEAKERMASTER $MYBEAKERREPLICA1"

        rlRun "yum clean all"
        rlRun "yum -y update 'ipa*'"    
        rlRun "yum -y update redhat-release"
        rlRun "ipactl restart"
        rlRun "ipactl status"
        rlRun "service sssd status"
        rlRun "service sssd restart"
        rlRun "rpm -q $PKG-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"
        export OSVER=$(sed 's/^.* \([0-9]\)\.\([0-9]\) .*$/\1\2/' /etc/redhat-release)

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

upgrade_replica()
{
    local repoi=0
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "upgrade_replica: upgrade ipa replica"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rpm -q $PKG-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"

        ipa_yum_repo_setup

        DDATE=$(date +%Y%m%d%H%M%S)
        rlRun "tar zcvf /tmp/sssd_cache.$DDATE.pre-upgrade.tgz /var/lib/sss"
        rlRun "rhts-submit-log -l /tmp/sssd_cache.$DDATE.pre-upgrade.tgz"

        rlRun "yum clean all"
        rlRun "yum -y update 'ipa*'"    
        rlRun "yum -y update redhat-release"
        rlRun "ipactl status"

        #if [ ! -f /etc/sssd/sssd.conf.getent ]; then
        #    rlRun "yum -y install strace"
        #    rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.getent"
        #    rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 9/' /etc/sssd/sssd.conf"
        #    sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
        #    rlRun "cat /etc/sssd/sssd.conf"
        #fi

        rlRun "service sssd status"
        rlRun "service sssd restart"
        rlRun "rpm -q $PKG-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"
        export OSVER=$(sed 's/^.* \([0-9]\)\.\([0-9]\) .*$/\1\2/' /etc/redhat-release)

        
        rlRun "tar zcvf /tmp/sssd_cache.$DDATE.post-upgrade.tgz /var/lib/sss"
        rlRun "rhts-submit-log -l /tmp/sssd_cache.$DDATE.post-upgrade.tgz"

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
    
    touch /tmp/ipa.replica.is.2.2.0
}

upgrade_client()
{
    local repoi=0
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "upgrade_client: upgrade ipa client"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERCLIENT"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERCLIENT"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"

        rlRun "rpm -q $PKG-client sssd selinux-policy"
        rlLog "backing up REPLICA log files before uninstall"

        ipa_yum_repo_setup

        rlRun "yum clean all"
        rlRun "yum -y update '*ipa*'"    
        rlRun "yum -y update redhat-release"
        rlRun "rpm -q $PKG-client sssd"
        export OSVER=$(sed 's/^.* \([0-9]\)\.\([0-9]\) .*$/\1\2/' /etc/redhat-release)

        #if [ ! -f /etc/sssd/sssd.conf.bak1 ]; then
        #    rlRun "yum -y install strace"
        #    rlRun "cp -f /etc/sssd/sssd.conf /etc/sssd/sssd.conf.bak1"
        #    rlLog "Running: sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 9/' /etc/sssd/sssd.conf"
        #    sed -i 's/\(\[domain.*\]\)$/\1\ndebug_level = 6/' /etc/sssd/sssd.conf
        #    rlRun "cat /etc/sssd/sssd.conf"
        #fi

        rlRun "service sssd status"
        rlRun "service sssd restart"
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERCLIENT"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
}
