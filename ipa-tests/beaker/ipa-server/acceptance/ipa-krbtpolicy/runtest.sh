#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipakrbtpolicy
#   Description: IPA ipakrbtpolicy acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
# ipa krbtpolicy-show
# ipa krbtpolicy-mod --maxlife --maxrenew
# ipa krbtpolicy-reset 
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
. ./data.ipakrbtpolicy.acceptance
. ./lib.ipakrbtpolicy.sh
. ./t.ipakrbtpolicy.sh

PACKAGE="ipa-admintools"

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipakrbtpolicy startup: Check for ipa-server package"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # r2d2_test_starts
    ipakrbtpolicy
    # r2d2_test_ends

    rlJournalPrintText
    report=$TmpDir/rhts.report.$RANDOM.txt
    makereport $report
    rhts-submit-log -l $report

    rlPhaseStartCleanup "ipakrbtpolicy cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

rlJournalEnd


 
# manifest:
# teststuie   : ipakrbt
    ## testset: _show
        ### testcase: _rights
            #### comment : ipa krbtpolicy-show --rights
        ### testcase: _all
            #### comment : ipa krbtpolicy-show --all
        ### testcase: _raw
            #### comment : ipa krbtpolicy-show --raw
    ## testset: _reset
        ### testcase: _default
            #### comment: restore krbtpolicy back to default for a given user
    ## testset: _mod
        ### testcase: _maxlife
            #### comment: set the maxlife of kerberos ticket
        ### testcase: _maxrenew
            #### comment: set max renew life of kerberos ticket
        ### testcase: _setattr
            #### comment: setattr
        ### testcase: _addattr
            #### comment: addattr
