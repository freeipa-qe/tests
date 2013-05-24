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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./t.ipa-client-automount.sh

PACKAGE="ipa-client"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`

#########################################
# topology veriables
#########################################
# roles in this multi-host test:
# MASTER_env1 ; REPLICA_env1 ; CLIENT1: first host in queue CLIENT_env1; CLIENT2 : second host in quque of CLIENT_env1
parse_test_roles_from_beaker_job_xml_file
map_hostname_with_role
print_hostname_role_mapping

# test host based on role settings
ipaServerMaster="$MASTER_IPA"
ipaServerReplica="$REPLICA_IPA"
dnsServer="$MASTER_IPA"
nfsServer="$NFS_IPA"

currentLocation=$automountLocationA
currentIPAServer=$ipaServerMaster
currentDNSServer=$dnsServer
currentNFSServer=$nfsServer

#########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-client-automount startup: Check for package: $PACKAGE"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        rlLog "kinit as admin, this is required for other ipa operations"
        echo $ADMINPW | $KINITEXEC $ADMINID
        rlRun "service iptables stop" 0 "stop friewall, this is required for rest of test"
        rlLog "Current host [$CURRENT_HOST], role [$MYROLE]"
    rlPhaseEnd

    # test_starts
    case "$MYROLE" in
    "MASTER" )
        rlPhaseStartSetup "Setup Master [$MASTER] [$MASTER_IPA]"
            rlPass "Master setup [$MASTER], no action necessary"
            rlLog "create automount locations for test use"
            MYHOSTNAME="$MASTER_IPA"
            rlLog "MYHOSTNAME=[$MYHOSTNAME]"
            configurate_non_secure_NFS_Server
            rhts-sync-set -s 'master done'
            rlLog "master setup done"
        rlPhaseEnd 
        ;;
    "REPLICA" ) 
        rlPhaseStartSetup "Setup Replica [$REPLICA] [$REPLICA_IPA]"
            rlLog "waiting for master ..."
            rhts-sync-block -s 'master done' $MASTER # wait for signal "set up master done"
            rlLog "master is done, continue"
            MYHOSTNAME="$ipaServerReplica"
            rlLog "MYHOSTNAME=[$MYHOSTNAME]"
            rlPass "Replica setup [$REPLICA], no action necessary"
            configurate_kerberized_nfs_server #next step #to make nfs kerberized, we need configurate non secure nfs first
            rhts-sync-set -s 'replica done'
            rlLog "replica setup done"
        rlPhaseEnd 
        ;;
    "NFS" )
        rlPhaseStartSetup "Setup NFS [$NFS] [$NFS_IPA]"
            rlLog "waiting for masetr and replica ..."
            rhts-sync-block -s "master done" $MASTER
            rhts-sync-block -s "replica done" $REPLICA
            MYHOSTNAME="$nfsServer"
            rlLog "MYHOSTNAME=[$MYHOSTNAME]"
            rlLog "master and replica are both done, continue for NFS setup"
            configurate_non_secure_nfs_server
            #configurate_kerberized_nfs_server #next step #to make nfs kerberized, we need configurate non secure nfs first
            rhts-sync-set -s "nfs done"
            rlLog "nfs configuration done"
        rlPhaseEnd
        ;;
    "CLIENT" )
        rlPhaseStartSetup "Setup CLIENT [$CLIENT] [$CLIENT_IPA]"
            rlLog "Current host [$CURRENT_HOST], role [$MYROLE]"
            rlLog "waiting for master, replica and nfs server finishing their job"
            rhts-sync-block -s "master done" $MASTER
            rhts-sync-block -s "replica done" $REPLICA
            rhts-sync-block -s "nfs done" $NFS
            rlLog "master, replica and nfs are ready, continue testing"
            MYHOSTNAME="$CLIENT_IPA"
            rlLog "MYHOSTNAME=[$MYHOSTNAME]"
            KinitAsAdmin
            rlRun "ipa host-find" 0 "print out all ipa host before test, this is just to show test environment"
        rlPhaseEnd

        ##############################################
        # actual ipa-client-automount test goes here #
        ##############################################
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

