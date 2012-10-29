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
# MASTER_env1 ; REPLICA_env1 ; CLIENT1: first host in queue CLIENT_env1; CLIENT2 : second host in uque of CLIENT_env1

MASTER="$MASTER_env1"
Master_hostname=`echo $MASTER | cut -d'.' -f1`

REPLICA="$REPLICA_env1"
Replica_hostname=`echo $REPLICA | cut -d'.' -f1`

NFS=`echo $CLIENT_env1 | cut -d' ' -f1`
Nfs_hostname=`echo $NFS | cut -d'.' -f1`

CLIENT=`echo $CLIENT_env1 | cut -d' ' -f2`
Client_hostname=`echo $CLIENT | cut -d'.' -f1`

CURRENT_HOST=$(hostname)
Current_hostname=`echo $CURRENT_HOST | cut -d'.' -f1`
case $Current_hostname in
    "$Master_hostname")    MYROLE="MASTER"  ;;
    "$Replica_hostname")  MYROLE="REPLICA" ;;
    "$Nfs_hostname")       MYROLE="NFS"     ;;
    "$Client_hostname")    MYROLE="CLIENT"  ;;
    *)                     MYROLE="UNKNOWN" ;;
esac

export MASTER_IP=$(dig +short $MASTER)
if [ -z "$MASTER_IP" ]; then
	export MASTER_IP=$(getent ahostsv4 $MASTER | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export REPLICA_IP=$(dig +short $REPLICA)
if [ -z "$REPLICA_IP" ]; then
	export REPLICA_IP=$(getent ahostsv4 $REPLICA | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export CLIENT_IP=$(dig +short $CLIENT)
if [ -z "$CLIENT_IP" ]; then
	export CLIENT_IP=$(getent ahostsv4 $CLIENT | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

export NFS_IP=$(dig +short $NFS)
if [ -z "$NFS_IP" ]; then
	export NFS_IP=$(getent ahostsv4 $NFS | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
fi

ipaServerMaster="$MASTER_IP"
ipaServerReplica="$REPLICA_IP"
dnsServer="$MASTER_IP"
nfsServer="$NFS_IP"

currentLocation=$automountLocationA
currentIPAServer=$ipaServerMaster
currentDNSServer=$dnsServer
currentNFSServer=$nfsServer

rlLog_hostnames()
{
    rlLog "--------- test host used ----------------"
    rlLog " current host [$CURRENT_HOST], role [$MYROLE]"
    rlLog " MASTER : [$MASTER] [$Master_hostname] [$MASTER_IP]"
    rlLog " REPLICA: [$REPLICA] [$Replica_hostname] [$REPLICA_IP]"
    rlLog " NFS    : [$NFS] [$Nfs_hostname] [$NFS_IP]"
    rlLog " CLIENT : [$CLIENT] [$Client_hostname] [$CLIENT_IP]"
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
        rlLog "kinit as admin"
        KinitAsAdmin
    rlPhaseEnd

    # test_starts
    case "$MYROLE" in
    "MASTER" )
        rlPhaseStartTest "Setup Master [$MASTER]"
            rlLog "Current host [$CURRENT_HOST], role [$MYROLE]"
            rlRun "service iptables stop" 0 "stop friewall"
            configurate_dns_server
            KinitAsAdmin
            ipa user-find
            rlPass "Master setup [$MASTER], no action necessary"
            rhts-sync-set -s 'master done'
        rlPhaseEnd 
        ;;
    "REPLICA" ) 
        rlPhaseStartTest "Setup Replica [$REPLICA]"
            rlLog "Current host [$CURRENT_HOST], role [$MYROLE]"
            rlRun "service iptables stop" 0 "stop friewall"
            configurate_dns_server
            KinitAsAdmin
            ipa user-find
            rlPass "Replica setup [$REPLICA], no action necessary"
            rhts-sync-block -s 'master done' $MASTER # wait for signal "set up master done"
            rhts-sync-set -s 'replica done'
        rlPhaseEnd 
        ;;
    "NFS" )
        rlPhaseStartTest "Setup NFS [$NFS]"
            rlLog "Current host [$CURRENT_HOST], role [$MYROLE]"
            rlLog "NFS setup [$NFS]"
            rlRun "service iptables stop" 0 "stop friewall"
            configurate_dns_server
            KinitAsAdmin
            ipa user-find
            rhts-sync-block -s "master done" $MASTER
            rhts-sync-block -s "replica done" $REPLICA
            #setup_secure_NFS_Server #next step
            configurate_non_secure_NFS_Server
            rhts-sync-set -s "nfs done"
        rlPhaseEnd
        ;;
    "CLIENT" )
        rlLog "doing some job on client [$CLIENT]"
        rhts-sync-block -s "master done" $MASTER
        rhts-sync-block -s "replica done" $REPLICA
        rhts-sync-block -s "nfs done" $NFS
        rlRun "service iptables stop" 0 "stop friewall"
        configurate_dns_server
        KinitAsAdmin
        ipa user-find
        ipaclientautomount
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

