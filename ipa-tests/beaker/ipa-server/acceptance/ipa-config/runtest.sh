#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipaconfig
#   Description: IPA ipaconfig acceptance tests
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

# Include test case file
. ./data.ipaconfig.acceptance
. ./lib.ipaconfig.sh
. ./lib.dataGenerator.sh
. ./t.ipaconfig.sh

PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipaconfig startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # r2d2_test_starts
    ipaconfig
    # r2d2_test_ends

    makereport

    rlPhaseStartCleanup "ipaconfig cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

rlJournalEnd


 
# manifest:
# teststuie   : ipaconfig
    ## testset: _show
        ### testcase: _default
            #### comment: this is to test for defult behave
            #### data-loop:
            #### data-no-loop:
        ### testcase: _negative
            #### comment: this is to test for defult behave
            #### data-loop:
            #### data-no-loop:

    ## testset: _mod
        ### testcase: _maxusername_default
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _maxusername_negative
            #### comment : negative test case for maxusername
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _homedirectory_default
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _homedirectory_negative
            #### comment : negative test case for homedirectory
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _defaultshell_default
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _defaultshell_negative
            #### comment : negative test case for defaultshell
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _defaultgroup_default
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _defaultgroup_negative
            #### comment : negative test case for defaultgroup
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _emaildomain_default
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _emaildomain_negative
            #### comment : negative test case for emaildomain
            #### data-loop : 
            #### data-no-loop : 

    ## testset: _searchtimelimit
        ### testcase: _timelimie_default
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _timelimie_negative
            #### comment : negative test case
            #### data-loop : 
            #### data-no-loop : 

    ## testset: _server
        ### testcase: _enablemigration
            #### comment : this is to test for default behave
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _enablemigration_negative
            #### comment : negative test case
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _subject
            #### comment : this is to test for default behave 
            #### data-loop : 
            #### data-no-loop : 
        ### testcase: _subject_negative
            #### comment : negative test case
            #### data-loop : 
            #### data-no-loop : 

