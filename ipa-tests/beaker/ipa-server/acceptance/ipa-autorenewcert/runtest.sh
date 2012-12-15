#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-autorenewcert
#   Description: IPA ipa-autorenewcert acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Yi Zhang <yzhang@redhat.com>
#   Date  : Aug. 07, 2010
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

# Include test case file
. ./t.autorenewcert.sh

PACKAGELIST="ipa-server perl-TimeDate perl-LDAP"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`
##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "autorenewcert startup: Check for ipa-server package"
        #rlAssertRpm $PACKAGELIST
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlLog "temp directory = [$TmpDir]"
        if [ "$TmpDir" = "" ];then
            TmpDir="/tmp"
        fi

        if ! rlCheckRpm expect; then
            yum install expect
            rlAssertRpm expect
        fi
        if ! rlCheckRpm perl-TimeDate; then
            yum install perl-TimeDate
            rlAssertRpm perl-TimeDate
        fi

        if ! rlCheckRpm perl-LDAP; then
            yum install perl-LDAP
            rlAssertRpm perl-LDAP
        fi
        #rlRun "pushd $TmpDir"
    rlPhaseEnd

    # r2d2_test_starts
    main_autorenewcert_test
    # r2d2_test_ends

    rlPhaseStartCleanup "autorenewcert cleanup"
        #rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory: [$TmpDir]"
    rlPhaseEnd

    makereport
rlJournalEnd


 
