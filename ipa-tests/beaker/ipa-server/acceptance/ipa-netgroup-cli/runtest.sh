#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-netgroup
#   Description: IPA ipa-netgroup acceptance tests
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
. /dev/shm/ipa-netgroup-cli-lib.sh
. /dev/shm/env.sh

# Include test case file
. ./t.ipa-netgroup.sh

PACKAGE=ipa-server

group1=testg1
user1=usrjjk1r
user2=userl33t
user3=usern00b
user4=lopcr4k

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-netgroup startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	kdestroy
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "kiniting as admin"
	# Adding users for use later
	ipa user-add --first=aa --last=bb $user1
	ipa user-add --first=aa --last=bb $user2
	ipa user-add --first=aa --last=bb $user3
	ipa user-add --first=aa --last=bb $user4
    rlPhaseEnd

    # r2d2_test_starts
    rlPhaseStartTest "run the netgroup cli tests"
        rlAssertRpm $PACKAGE
	# Add netgroup group1
        rlRun "addNetgroup $group1 test-group-1" 0 "adding first netgroup"
	# Verify if it exists
	rlRun "ipa netgroup-find $group1 | grep $group1" 0 "checking to ensure netgroup was created"
	# Adding users to group1
	rlRun "ipa netgroup-add-member --users=$user1,$user2 $group1" 0 "Adding user1 and user2 to group1"
	rlRun "ipa netgroup-add-member --users=$user3 $group1" 0 "Adding user3 to group1"
	# Checking to ensure that it happened.
	#rlRun "ipa 
	# <How do I do this?>

	# Removing users from group1
	rlRun "ipa netgroup-remove-member --users=$user1,$user2 $group1" 0 "Adding user1 and user2 to group1"
	rlRun "ipa netgroup-remove-member --users=$user3 $group1" 0 "Adding user3 to group1"
	# Checking to ensure that it happened.
	#rlRun "ipa 
	# <How do I do this?>

    rlPhaseEnd

    
    # r2d2_test_ends

    rlPhaseStartCleanup "ipa-netgroup cleanup"
	# Delete netgroup group1
	rlRun "delNetgroup $group1" 0 "deleting first netgroup"
	# Verify if it exists
	rlRun "ipa netgroup-find $group1 | grep $group1" 1 "checking to ensure netgroup was deleted"

	# Cleaning up users
	ipa user-del $user1
	ipa user-del $user2
	ipa user-del $user3
	ipa user-del $user4
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
        ### testcase: _evnsetup
            #### comment: set up the environment for password history test
            #### data-loop: historysize 
            #### data-no-loop:  admin adminpassword
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
        ### testcase: _envcleanup 
            #### comment: clean up environment setting, back to default
            #### data-loop: size day expired newpw junkpw
            #### data-no-loop: admin adminpassword
