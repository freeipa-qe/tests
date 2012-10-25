#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-client-automount
#   Description: IPA ipa-client-automount acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Yi Zhang <yzhang@redhat.com>
#   Date  : Sept 10, 2010
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test case file
. ./t.ipa-client-automount.sh

PACKAGE="ipa-client"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`

#########################################
# topology veriables
#########################################
# roles in this multi-host test:
# MASTER_env1 ; REPLICA_env1 ; CLIENT_env1 ; CLIENT_env2

export MASTER_IP=$(dig +short $MASTER)
if [ -z "$MASTER_IP" ]; then
	export MASTER_IP=$(getent ahostsv4 $MASTER_env1 | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export REPLICA_IP=$(dig +short $REPLICA_env1)
if [ -z "$REPLICA_IP" ]; then
	export REPLICA_IP=$(getent ahostsv4 $REPLICA_env1 | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export CLIENT1_IP=$(dig +short $CLIENT1_env1)
if [ -z "$CLIENT1_IP" ]; then
	export CLIENT1_IP=$(getent ahostsv4 $CLIENT1_IP| grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export CLIENT2_IP=$(dig +short $CLIENT2_env1)
if [ -z "$CLIENT2_IP" ]; then
	export CLIENT2_IP=$(getent ahostsv4 $CLIENT2_IP| grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi


HOSTNAME=$(hostname)
case $HOSTNAME in
"$MASTER_env1")    MYROLE="MASTER"  ;;
"$REPLICA_env1")   MYROLE="REPLICA" ;;
"$CLIENT1_env1")   MYROLE="CLIENT1" ;;
"$CLIENT2_env1")   MYROLE="CLIENT2" ;;
*)                 MYROLE="UNKNOWN" ;;
esac

rlLog_hostnames()
{
    local currentHost=`hostname`
    rlLog "--------- test host used ----------------"
    rlLog " current host [$currentHost]"
    rlLog " MASTER:  [$MASTER_env1]"
    rlLog " REPLICA: [$REPLICA_env1]"
    rlLog " CLIENT1: [$CLIENT_env1]"
    rlLog " CLIENT2: [$CLIENT_env2]"
    rlLog "-----------------------------------------"
}



#########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-client-automount startup: Check for package: $PACKAGE"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        rlLog_hostnames
    rlPhaseEnd

    # test_starts
    rlPhaseStartTest "role setup for ipa-client-automount testing"
    case "$MYROLE" in
    "MASTER" )
        rlLog "Master setup [$MASTER]"
        rlLog "if ipa-server setup is automatic in beaker job xml file, then do nothing"
        rhts-sync-set -s 'master done'
        rlPass "master done setup"
        ;;
    "REPLICA" ) 
        rlLog "Replica setup [$REPLICA]"
        rlts-sync-block -s 'master done' $MASTER # wait for signal "set up master done"
        rlLog "install replica, this is also should be done"
        rhts-sync-set -s "replica done" 
        rlPass "replica done setup"
        ;;
    "CLIENT1" )
        rlLog "doing some job on client 1 [$CLIENT1]"
        rhts-sync-block -s "master done" $MASTER
        rhts-sync-block -s "replica done" $REPLICA
        ipaclientautomount
        ;;
    "CLEINT2" )
        rlLog "doing some job on client 1 [$CLIENT1]"
        rhts-sync-block -s "master done" $MASTER
        rhts-sync-block -s "replica done" $REPLICA
        rlPass "I am just a bystander, doing nothing"
        ;;
    *)
        rlFail "UNKNOW ROLE [$MYROLE]"
        ;;
    esac
    # test_ends

    rlPhaseStartCleanup "ipa-client-automount cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd

