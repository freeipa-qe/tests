#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-replica-manage
#   Description: IPA ipa-replica-manage Acceptance Test Suite
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : May 23, 2012
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
### NOTE: Must use tree2 topology from quickinstall to setup before 
### running this
######################################################################

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh
. /opt/rhqa_ipa/ipa-install.sh

# Include test case files
for file in $(ls tests.d/t.*.sh); do
	. ./$file
done

IRMVERSION="3."
TESTCOUNT=0
CFG=/opt/rhqa_ipa/env.sh

echo "export MASTER=$(eval echo \$MASTER_env${MYENV})" >> $CFG
echo "export REPLICA1=$(eval echo \$REPLICA1_env${MYENV})" >> $CFG
echo "export REPLICA2=$(eval echo \$REPLICA2_env${MYENV})" >> $CFG
echo "export REPLICA3=$(eval echo \$REPLICA3_env${MYENV})" >> $CFG
echo "export REPLICA4=$(eval echo \$REPLICA4_env${MYENV})" >> $CFG

echo "export MY_BM=$(eval echo \$BEAKERMASTER_env${MYENV})" >> $CFG
echo "export MY_BR1=$(eval echo \$BEAKERREPLICA1_env${MYENV})" >> $CFG
echo "export MY_BR2=$(eval echo \$BEAKERREPLICA2_env${MYENV})" >> $CFG
echo "export MY_BR3=$(eval echo \$BEAKERREPLICA3_env${MYENV})" >> $CFG
echo "export MY_BR4=$(eval echo \$BEAKERREPLICA4_env${MYENV})" >> $CFG

. $CFG

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-replica-manage startup: Check for ipa-server package"
		rlRun "env|sort"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        if [ $(echo "$USEPWOPT"|grep -i "yes"|wc -l) -gt 0 ]; then
            rlLog "Setting PWOPT and running kdestroy to ensure password is used"
            rlRun "kdestroy"
            PWOPT="-p $ADMINPW"
        else
            rlLog "Zeroing PWOPT and running kinit to ensure password is not used"
            PWOPT=""
        fi
        rlRun "AddToKnownHosts $MY_BM"
        rlRun "AddToKnownHosts $MY_BR1"
        rlRun "AddToKnownHosts $MY_BR2"
        rlRun "AddToKnownHosts $MY_BR3"
        rlRun "AddToKnownHosts $MY_BR4"
    rlPhaseEnd

	irm_run

    rlPhaseStartCleanup "ipa-replica-manage cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd

# manifest:

