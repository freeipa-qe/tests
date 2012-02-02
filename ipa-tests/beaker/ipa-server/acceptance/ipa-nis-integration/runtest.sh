#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA ipa-nis-integration acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Feb 01, 2012
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test case files
for file in $(ls tests.d/t.*.sh); do
	. ./$file
done

PACKAGE="ipa-server"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`
##########################################
#   test main 
#########################################

rlJournalStart
	rlPhaseStartSetup "ipa-nis-integration startup: Check for ipa-server package"
		#rlAssertRpm $PACKAGE
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
		HOSTNAME=$(hostname)
		myhostname=`hostname`
		rlLog "hostname command: $myhostname"
		rlLog "HOSTNAME: $HOSTNAME"
		rlLog "MASTER: $MASTER"
		rlLog "NISMASTER: $NISMASTER"
		rlLog "NISCLIENT: $NISCLIENT"
		rlLog "BEAKERMASTER: $BEAKERMASTER"
		rlLog "BEAKERNISMASTER: $BEAKERNISMASTER"
		rlLog "BEAKERNISCLIENT: $BEAKERNISCLIENT"
	rlPhaseEnd

	case $HOSTNAME in
	$MASTER)      echo "Match MASTER"; nisint_ipamaster ;; 
	$NISMASTER)   echo "Match NISMASTER"; nisint_nismaster ;; 
	$NISCLIENT)   echo "Match NISCLIENT"; nisint_nisclient ;;
	esac

	rlPhaseStartCleanup "ipa-nis-integration cleanup"
		rlRun "popd"
		rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlPhaseEnd

	makereport
rlJournalEnd


# manifest:
