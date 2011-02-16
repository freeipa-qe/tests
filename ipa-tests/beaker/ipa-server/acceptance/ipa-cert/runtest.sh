#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipacert
#   Description: IPA ipacert acceptance tests
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
. ./t.ipacert.sh

########### temp fix ########
bugfix()
{
    local file=/var/lib/pki-ca/profiles/ca/caIPAserviceCert.cfg
    rlLog "fix bug: file: $file"
    rlRun "ls -l $file" 0 "before fix"
    chown pkiuser.pkiuser $file
    rlRun "ls -l $file" 0 "after fix"
    rlRun "ipactl restart" 0 "check the file and restart ipa"
} # bigfix
##############################

PACKAGE="freeipa-server"
startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`
##########################################
#   test main 
#########################################

bugfix #this is a temp fix, once bug-fix officially checked in, i should remove this one

rlJournalStart
    rlPhaseStartSetup "ipacert startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # r2d2_test_starts
    ipacert
    # r2d2_test_ends

    rlPhaseStartCleanup "ipacert cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd

 
# manifest:
