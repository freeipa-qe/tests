#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-dns-multi
#   Description: IPA DNS acceptance tests to be run on a instance with 
#    multiple, independant masters.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#   Date  : Feb 28, 2013
#
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

# Include test scripts
. ./t.dns_bz.sh
. ./t.dns_pkey.sh
. ./t.dns.sh

# Include alt sync lib
. ./lib.ipa-rhts.sh

##########################################
#   test main 
#########################################


rlJournalStart

  rlPhaseStartSetup "DNS MUlTI HOST SETUP"
        rlDistroDiff ipa_pkg_check
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	yum -y install wget rpcbind
  rlPhaseEnd

# If you change the style of setting MYROLE, remember
# that $SLAVE could be a space delimited list of replicas
env | grep "MASTER_env1" | grep $(hostname -s )
if [ $? -eq 0 ]; then
	rlLog "Role is Master 1"
	MYROLE=MASTER1
else
	rlLog "Role is Master 2"
	MYROLE=MASTER2
fi

echo MASTER=$(hostname)
echo MASTER_IP=$(hostname -i)

# Setup RTHS sync section of Apache
setup_iparhts_sync

if [ "$MYROLE" == "MASTER1" ]; then
	iparhts-sync-set -s READY_REPLICA1 -m $MASTER_env1
	rlLog "ready_replica1 set"
	rlLog "blocking master, waiting for slave"
	iparhts-sync-block -s DONE_REPLICA2 $MASTER_env2
	rlLog "test complete"
else
	rlLog "blocking for master 1"
	iparhts-sync-block -s READY_REPLICA1 $MASTER_env1
	iparhts-sync-set -s DONE_REPLICA2 -m $MASTER_env1 
	rlLog "test complete"
fi
  # run tests
#  dnsacceptance  
  dnsbugs

  rlPhaseStartCleanup "DNS CLEANUP"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
  rlPhaseEnd
  	
  rlJournalPrintText
  report=/tmp/rhts.report.$RANDOM.txt
  makereport $report
  rhts-submit-log -l $report

rlJournalEnd
