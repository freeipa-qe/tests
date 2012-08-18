#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-cert-cli
#   Description: IPA ipa-cert-cli acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
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
. ./t.ipa-cert-cli.sh

grep Fedora /etc/redhat-release
if [ $? -eq 0 ]; then
	# OS is Fedora
	PACKAGE="freeipa-server"
else
	# OS is probably RHEL
	PACKAGE="ipa-server"
fi

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`
##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-cert-cli startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # r2d2_test_starts
    ipa_cert_cli
    # r2d2_test_ends

    rlPhaseStartCleanup "ipa-cert-cli cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd


 
# manifest:
# teststuie   : ipasample
    ## testset: _lifetime
        ### testcase: minlife_nolimit 
            #### comment : this is to test for minimum of password history
            #### data-loop : minage
            #### data-no-loop : pwusername pwinintial_password
        ### testcase: _minlife_somelimit
            #### comment: set password life time to 0
            #### data-loop: 
            #### data-no-loop : pwusername pwinitial_password
        ### testcase: _minlife_negative
            #### comment: negative test case for minimum password life
            #### data-loop: minage
            #### data-no-loop : pwusername pwinitial_password
        ### testcase: _minlife_verify
            #### comment: verify the changes
            #### data-loop: minage
            #### data-no-loop : pwusername pwinitial_password
    ## testset: pwhistory
        ### testcase: _defaultvalue
            #### comment: verifyt the default value
            #### data-loop: size day 
            #### data-no-loop:  admin adminpassword
        ### testcase: _lowbound
            #### comment: check the lower bound of value range
            #### data-loop:  size day expired
            #### data-no-loop: 
        ### testcase: password_history_negative
            #### comment: do negative test on history of password
            #### data-loop:  size day expired newpw
            #### data-no-loop: admin adminpassword
