#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipapassword
#   Description: IPA ipapassword acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Yi Zhang <Yi Zhangemail>
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

# Include test case file
. ./lib.ipapassword.sh
. ./t.ipapassword.sh

# Include test data file
. ./data.ipapassword.acceptance

# Test environment setup
if [ ! -d $tmpdir ];then
    mkdir -p $tmpdir
fi

PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipapassword startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # r2d2_test_starts
    ipapassword
    # r2d2_test_ends

    makereport
    rlPhaseStartCleanup "ipapassword cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd
rlJournalEnd


 
# manifest:

#testsuite: ipapassword
    ## testset: _globalpolicy
        ### testcase: _maxlifetime_default
            #### comment : 
            #### data-loop:
            #### data-no-loop:
        ### testcase: _maxlifetime_lowerbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _maxlifetime_upperbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _maxlifetime_negative
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_default
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_lowerbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_upperbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_negative
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _history_default
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _history_lowerbound
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _history_upperbound
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _history_negative
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _classes_default
            #### comment: check minimum classes
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_lowerbound
            #### comment: check minimum classes lowbound
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_upperbound
            #### comment: check minimum classes upperbound
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_negative
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _length_default
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_lowerbound
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_upperbound
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_negative
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
    ## testset: _grouppolicy
        ### testcase: _maxlifetime_default
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _maxlifetime_lowerbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _maxlifetime_upperbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _maxlifetime_negative
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_default
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_lowerbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_upperbound
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlifetime_negative
            #### comment :
            #### data-loop:
            #### data-no-loop:
        ### testcase: _history_default
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _history_lowerbound
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _history_upperbound
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _history_negative
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _classes_default
            #### comment: check minimum classes
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_lowerbound
            #### comment: check minimum classes lowbound
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_upperbound
            #### comment: check minimum classes upperbound
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_negative
            #### comment: 
            #### data-loop: 
            #### data-no-loop: 
        ### testcase: _length_default
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_lowerbound
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_upperbound
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_negative
            #### comment: check minimum length
            #### data-loop:
            #### data-no-loop:
    ## testset: _globalandgroup
        ### testcase: _maxlife_conflict
            #### commnet: when group setting for maxlife > global maxlife setting
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlife_conflict
            #### comment: when group setting for minlife < global minlife setting
            #### data-loop:
            #### data-no-loop:
        ### testcase: _history_conflict
            #### commnet: when group setting for history size > global history size setting
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_conflict
            #### comment: when group classes > global classes
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_conflict
            #### comment: when group length > global length
            #### data-loop:
            #### data-no-loop:
    ## testset: _nestedgroup
        ### testcase: _maxlife_conflict
            #### commnet: when group setting for maxlife > global maxlife setting
            #### data-loop:
            #### data-no-loop:
        ### testcase: _minlife_conflict
            #### comment: when group setting for minlife < global minlife setting
            #### data-loop:
            #### data-no-loop:
        ### testcase: _history_conflict
            #### commnet: when group setting for history size > global history size setting
            #### data-loop:
            #### data-no-loop:
        ### testcase: _classes_conflict
            #### comment: when group classes > global classes
            #### data-loop:
            #### data-no-loop:
        ### testcase: _length_conflict
            #### comment: when group length > global length
            #### data-loop:
            #### data-no-loop:
