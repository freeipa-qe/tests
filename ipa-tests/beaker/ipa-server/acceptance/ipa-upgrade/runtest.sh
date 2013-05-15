#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA ipa-upgrade acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Nar 12, 2012
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

# Include rhts environment

. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. ./ipa-server-shared.sh
. /opt/rhqa_ipa/ipa-install.sh
. ./lib.ipa-quicktest.sh
. /opt/rhqa_ipa/env.sh

# Include test case files
for file in $(ls tests.d/t.*.sh); do
    . ./$file
done


# Include data-driven test data file:
. ./data.ipa-upgrade

##########################################
#   test main 
##########################################

rlJournalStart
    rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
        ipa_install_set_vars
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        export MASTER_S=$(echo $MASTER|cut -f1 -d.)
        export MASTER_IP=$(dig +short $(eval echo \$BEAKERMASTER_env${MYENV}) A)
        export MYBEAKERMASTER=$(eval echo \$BEAKERMASTER_env${MYENV})
        export REPLICA1_S=$(eval echo \$REPLICA1_env${MYENV}|cut -f1 -d.)
        export REPLICA1_IP=$(dig +short $(eval echo \$BEAKERREPLICA1_env${MYENV}) A)
        export MYBEAKERREPLICA1=$(eval echo \$BEAKERREPLICA1_env${MYENV})
        export CLIENT_S=$(echo $CLIENT|cut -f1 -d.)
        export CLIENT_IP=$(dig +short $(eval echo \$BEAKERCLIENT1_env${MYENV}) A)
        export MYBEAKERCLIENT=$(eval echo \$BEAKERCLIENT1_env${MYENV})
        export OSVER=$(sed 's/^.* \([0-9]\)\.\([0-9]\) .*$/\1\2/' /etc/redhat-release)

        CFG=/opt/rhqa_ipa/env.sh
        echo "export MASTER_S=$MASTER_S" >> $CFG
        echo "export MASTER_IP=$MASTER_IP" >> $CFG
        echo "export MYBEAKERMASTER=$MYBEAKERMASTER" >> $CFG
        echo "export REPLICA1_S=$REPLICA1_S" >> $CFG
        echo "export REPLICA1_IP=$REPLICA1_IP" >> $CFG
        echo "export MYBEAKERREPLICA1=$MYBEAKERREPLICA1" >> $CFG
        echo "export CLIENT_S=$CLIENT_S" >> $CFG
        echo "export CLIENT_IP=$CLIENT_IP" >> $CFG
        echo "export MYBEAKERCLIENT=$MYBEAKERCLIENT" >> $CFG

        rlRun "yum -y install strace"
    rlPhaseEnd
    
    # Main test functions in tests.d/t.tests.sh:

    if [ "$TESTTYPE" = "incremental" -o -z "$TESTTYPE" ]; then
        ipa_upgrade_master_replica_client_inc
    fi
    if [ "$TESTTYPE" = "parallel" -o -z "$TESTTYPE" ]; then
        ipa_upgrade_master_replica_parallel
    fi
    if [ "$TESTTYPE" = "normal" -o -z "$TESTTYPE" ]; then
        ipa_upgrade_master_replica_client_all
    fi
    if [ "$TESTTYPE" = "reverse" -o -z "$TESTTYPE" ]; then
        ipa_upgrade_client_replica_master_all
    fi
    if [ "$TESTTYPE" = "nodns" -o -z "$TESTTYPE" ]; then
        ipa_upgrade_master_replica_client_nodns 
    fi

#    ipa_upgrade_master_replica_client_dirsrv_off
    #upgrade_test_master_bz_866977
    #upgrade_test_master_bz_tests
    #upgrade_test_master_replica_client_all_final

    rlPhaseStartCleanup "ipa-upgrade cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd
