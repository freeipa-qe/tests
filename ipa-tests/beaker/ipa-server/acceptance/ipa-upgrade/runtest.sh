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
. ./ipa-install.sh
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
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        ipa_install_set_vars
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

        rlRun "yum -y install strace"
    rlPhaseEnd
    
    # Main test functions in tests.d/t.tests.sh:

    # First run the incremental upgrade tests:
    ipa_upgrade_master_replica_client_inc_setup
    if rlIsRHEL "<6.3"; then
        ipa_upgrade_master_replica_client_inc_63
    fi
    if rlIsRHEL "6.3"; then
        ipa_upgrade_master_replica_client_inc_64
    fi
    #if rlIsRHEL "6.4"; then
    #    ipa_upgrade_master_replica_client_inc_65
    #fi
    #if rlIsRHEL "6.5"; then
    #    ipa_upgrade_master_replica_client_inc_66
    #fi
    #if rlIsRHEL "6.6"; then
    #    ipa_upgrade_master_replica_client_inc_67
    #fi
    #if rlIsRHEL "6.7"; then
    #    ipa_upgrade_master_replica_client_inc_68
    #fi
    #if rlIsRHEL "6.8"; then
    #    ipa_upgrade_master_replica_client_inc_69
    #fi
    ipa_upgrade_master_replica_client_inc_cleanup

    ipa_upgrade_master_replica_parallel
    ipa_upgrade_master_slave_client_all
    #upgrade_test_client_slave_master_all
    #upgrade_test_master_slave_client_nodns
    #upgrade_test_master_slave_client_dirsrv_off
    #upgrade_test_master_bz_866977
    #upgrade_test_master_bz_tests
    #upgrade_test_master_slave_client_all_final

    rlPhaseStartCleanup "ipa-upgrade cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd
