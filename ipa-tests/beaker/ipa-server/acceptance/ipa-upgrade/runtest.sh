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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test case files
for file in $(ls tests.d/t.*.sh); do
	. ./$file
done

# Include data-driven test data file:
. ./ipa-upgrade.data

# other variables 
startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`

[ -n "$MASTER" ] && export MASTER_IP=$(dig +short $MASTER) MASTER_S=$(echo $MASTER|cut -f1 -d.)
[ -n "$SLAVE" ]  && export SLAVE_IP=$(dig +short $SLAVE)   SLAVE_S=$(echo  $SLAVE |cut -f1 -d.)
[ -n "$CLIENT" ] && export CLIENT_IP=$(dig +short $CLIENT) CLIENT_S=$(echo $CLIENT|cut -f1 -d.)

case $(hostname) in
"$MASTER")  MYROLE="MASTER"    ;;
"$SLAVE")   MYROLE="SLAVE"     ;;
"$CLIENT")  MYROLE="CLIENT"    ;;
*)          MYROLE="UNKNOWN"   ;;
esac

##########################################
#   test main 
##########################################

### Test upgrades for Master, then Slave, then Client for all services
rlJournalStart
	rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
	rlPhaseEnd
	
	# Main test functions in tests.d/t.tests.sh:
	upgrade_test_master_slave_client_all

	rlPhaseStartCleanup "ipa-upgrade cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd

### Test upgrades for Client (Negative), then Slave, then Master for all services
rlJournalStart
	rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
	rlPhaseEnd
	
	# Main test functions in tests.d/t.tests.sh:
	upgrade_test_client_slave_master_all

	rlPhaseStartCleanup "ipa-upgrade cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd

### Test upgrades for Master, then Slave, then Client with NO DNS service
rlJournalStart
	rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
	rlPhaseEnd
	
	# Main test functions in tests.d/t.tests.sh:
	upgrade_test_master_slave_client_nodns

	rlPhaseStartCleanup "ipa-upgrade cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd

### Test upgrades for Master, then Slave, then Client with dirsrv off on servers
rlJournalStart
	rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
	rlPhaseEnd
	
	# Main test functions in tests.d/t.tests.sh:
	upgrade_test_master_slave_client_dirsrv_off

	rlPhaseStartCleanup "ipa-upgrade cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd

### Test upgrades for Master with bug checks
rlJournalStart
	rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
	rlPhaseEnd
	
	# Main test functions in tests.d/t.tests.sh:
	upgrade_test_master_bz_tests

	rlPhaseStartCleanup "ipa-upgrade cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd

### Run a final upgrade to leave Master/Slave/Client upgraded for outside tests
rlJournalStart
	rlPhaseStartSetup "ipa-upgrade startup: Initial upgrade setup and pre-checks"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
	rlPhaseEnd
	
	# Main test functions in tests.d/t.tests.sh:
	upgrade_test_master_slave_client_all_final

	rlPhaseStartCleanup "ipa-upgrade cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd

# manifest:
