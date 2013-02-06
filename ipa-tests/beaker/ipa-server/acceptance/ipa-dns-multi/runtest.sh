#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-dns
#   Description: IPA DNS acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#   Date  : Jan 21, 2011
#
#   Author: Gowrishankar Rajaiyan <grajaiya@redhat.com>
#   Date  : Feb 14, 2012
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#   Date:   April 25, 2012 
#   Re-organization of tests
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

##########################################
#   test main 
#########################################


rlJournalStart

  rlPhaseStartSetup "DNS SETUP"
        rlDistroDiff ipa_pkg_check
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	yum -y install wget rpcbind
  rlPhaseEnd

  # run tests
  dnsacceptance  
  dnspkey
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
