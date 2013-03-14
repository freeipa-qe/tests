#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-i18n
#   Description: IPA ipa-i18n acceptance tests
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./t.ipa-i18n.sh
. ./testenv.sh
. ./cns-tests.sh
. ./rejection-tests.sh
. ./firstname-tests.sh

PACKAGE="ipa-admintools"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-i18n startup: Check for ipa-server package"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

# Add all of the users to be used in this test
rlPhaseStartTest "ipa-i18n-1: Adding usernames"
#	echo running "ipa user-add --first='$name1f' --last='$name1l' $uname1"
	rlRun "ipa user-add --first='$name1f' --last='$name1l' $uname1" 0 "Adding username $uname1 with full name $name1"
	rlRun "ipa user-add --first='$name2f' --last='$name2l' $uname2" 0 "Adding username $uname2 with full name $name2"
	rlRun "ipa user-add --first='$name3f' --last='$name3l' $uname3" 0 "Adding username $uname3 with full name $name3"
	rlRun "ipa user-add --first='$name4f' --last='$name4l' $uname4" 0 "Adding username $uname4 with full name $name4"
rlPhaseEnd

rlPhaseStartTest "ipa-i18n-2:checking to ensuer that $uname1 was added correctly"
#	echo "running ipa user-find $uname1 | grep '$name1'"
	rlRun "ipa user-find --all $uname1 | grep '$name1'" 0 "Checking to ensure that $uname1 has the full name of $name1"
	rlRun "ipa user-find --all $uname2 | grep '$name2'" 0 "Checking to ensure that $uname2 has the full name of $name2"
	rlRun "ipa user-find --all $uname3 | grep '$name3'" 0 "Checking to ensure that $uname3 has the full name of $name3"
	rlRun "ipa user-find --all $uname4 | grep '$name4'" 0 "Checking to ensure that $uname4 has the full name of $name4"
rlPhaseEnd

    # r2d2_test_starts
#    ipa-i18n
	run_cns_tests
	run_rejection_tests
	run_firstname_tests
    # r2d2_test_ends

    rlPhaseStartCleanup "ipa-i18n cleanup"
	rlRun "ipa user-del $uname1" 0 "Removing $uname1" 
	rlRun "ipa user-del $uname2" 0 "Removing $uname2" 
	rlRun "ipa user-del $uname3" 0 "Removing $uname3" 
	rlRun "ipa user-del $uname4" 0 "Removing $uname4" 
	rlRun "ipa user-find $uname1 | grep $uname1" 1 "Confirming remove of $uname1" 
	rlRun "ipa user-find $uname2 | grep $uname2" 1 "Confirming remove of $uname2" 
	rlRun "ipa user-find $uname3 | grep $uname3" 1 "Confirming remove of $uname3" 
	rlRun "ipa user-find $uname4 | grep $uname4" 1 "Confirming remove of $uname4" 
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
