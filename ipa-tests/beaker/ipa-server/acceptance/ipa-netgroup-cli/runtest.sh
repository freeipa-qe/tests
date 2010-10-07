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

ngroup1=testg1
ngroup2=testgaga2
user1=usrjjk1r
user2=userl33t
user3=usern00b
user4=lopcr4k
group1=grpddee
group2=grplloo
group3=grpmmpp
group4=grpeeww
hgroup1=hg144335566
hgroup2=hg2
hgroup3=hg3afdsk

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
	ipa group-add --desc=testtest $group1
	ipa group-add --desc=testtest $group2
	ipa group-add --desc=testtest $group3
	ipa group-add --desc=testtest $group4
	ipa hostgroup-add --desc=$hgroup1 $hgroup1
	ipa hostgroup-add --desc=$hgroup2 $hgroup2
	ipa hostgroup-add --desc=$hgroup3 $hgroup3
    rlPhaseEnd

    # r2d2_test_starts
    rlPhaseStartTest "run the netgroup cli tests"
        rlAssertRpm $PACKAGE
	echo "Add netgroup ngroup1"
        rlRun "addNetgroup $ngroup1 test-group-1" 0 "adding first netgroup"
	echo "Add netgroup ngroup2"
        rlRun "addNetgroup $ngroup2 test-group-1" 0 "adding second netgroup"
	# Verify if it exists
	rlRun "ipa netgroup-find $ngroup1 | grep $ngroup1" 0 "checking to ensure netgroup was created"
	# Adding users to group1
	rlRun "ipa netgroup-add-member --users=$user1,$user2 $ngroup1" 0 "Adding user1 and user2 to group1"
	rlRun "ipa netgroup-add-member --users=$user3 $ngroup1" 0 "Adding user3 to group1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1|grep $user1" 0 "Verifying that user1 is in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $user2" 0 "Verifying that user2 is in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $user3" 0 "Verifying that user3 is in ngroup1"

	# Adding users to group1
	rlRun "ipa netgroup-add-member --groups=$group1,$group2 $ngroup1" 0 "Adding user1 and user2 to group1"
	rlRun "ipa netgroup-add-member --groups=$group3 $ngroup1" 0 "Adding user3 to group1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1|grep $group1" 0 "Verifying that group1 is in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $group2" 0 "Verifying that group2 is in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $group3" 0 "Verifying that group3 is in ngroup1"
	
	# Checking to ensure that addign a host to a netgroup works
	rlRun "ipa netgroup-add-member --hosts=$HOSTNAME $ngroup1" 0 "Adding local hostname to ngroup1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 0 "Verifying that HOSNAME is in ngroup1"

	# Adding a hostgroup to a netgroup
	rlRun "ipa netgroup-add-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "adding hostgroup 1 and 2 to ngroup1"
	rlRun "ipa netgroup-add-member --hostgroups=$hgroup3 $ngroup1" 0 "adding hostgroup 3 to ngroup1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 0 "Verifying that hgroup1 is in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 0 "Verifying that hgroup1 is in ngroup2"
	rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 0 "Verifying that hgroup1 is in ngroup3"

	# Removing users from ngroup1
	rlRun "ipa netgroup-remove-member --users=$user1,$user2 $ngroup1" 0 "Removing user1 and user2 from ngroup1"
	rlRun "ipa netgroup-remove-member --users=$user3 $ngroup1" 0 "Removing user3 from ngroup1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1|grep $user1" 1 "Verifying that user1 is not in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $user2" 1 "Verifying that user2 is not in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $user3" 1 "Verifying that user3 is not in ngroup1"

	# Removing groups from ngroup1
	rlRun "ipa netgroup-remove-member --groups=$group1,$group2 $ngroup1" 0 "Removing group1 and group2 from ngroup1"
	rlRun "ipa netgroup-remove-member --groups=$group3 $ngroup1" 0 "Removing group3 from ngroup1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1|grep $group1" 1 "Verifying that group1 is not in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $group2" 1 "Verifying that group2 is not in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $group3" 1 "Verifying that group3 is not in ngroup1"

	# Removing hostgroups from ngroup1
	rlRun "ipa netgroup-remove-member --groups=$hgroup1,$hgroup2 $ngroup1" 0 "Removing hgroup1 and hgroup2 from ngroup1"
	rlRun "ipa netgroup-remove-member --groups=$hgroup3 $ngroup1" 0 "Removing hgroup3 from ngroup1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1|grep $hgroup1" 1 "Verifying that hgroup1 is not in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $hgroup2" 1 "Verifying that hgroup2 is not in ngroup1"
	rlRun "ipa netgroup-show --all $ngroup1|grep $hgroup3" 1 "Verifying that hgroup3 is not in ngroup1"

	# Removing a host from ngroup1
	rlRun "ipa netgroup-remove-member --hosts=$HOSTNAME $ngroup1" 0 "Removing local hostname from ngroup1"
	# Checking to ensure that it happened.
	rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 1 "Verifying that HOSNAME is not in ngroup1"

	# checking description hostgroup-mod
	rlRun "ipa netgroup-mod --desc=testdesc11 $ngroup1" 0 "change the description on ngroup1"
	# Verify
	rlRun "ipa netgroup-show --all $ngroup1 | grep testdesc11" 0 "Verifying that the description changed on ngroup1"

	# checking setaddr hostgroup-mod
	rlRun "ipa netgroup-mod --addattr=testattr=yes $ngroup1" 0 "add custom attribute on ngroup1"
	# Verify
	rlRun "ipa netgroup-show --all $ngroup1 | grep testattr" 0 "Verifying that the attr added to ngroup1"

	# checking setaddr hostgroup-mod
	rlRun "ipa netgroup-mod --addattr=setattr=no $ngroup1" 0 "setting custom attribute on ngroup1"
	# Verify
	rlRun "ipa netgroup-show --all $ngroup1 | grep testattr | grep no" 0 "Verifying that the attr changed on ngroup1"

	# verifying hostgroup-del
	rlRun "ipa netgroup-del $ngroup3" 0 "Deleting ngroup3"
	# Verify
	rlRun "ipa netgroup-show $ngroup3 | grep $ngroup3" 1 "Verifying that ngroup3 doesn't exist"
    rlPhaseEnd

    
    # r2d2_test_ends

    rlPhaseStartCleanup "ipa-netgroup cleanup"
	# Delete netgroup group1
	rlRun "delNetgroup $ngroup1" 0 "deleting first netgroup"
	# Verify if it exists
	rlRun "ipa netgroup-find $ngroup1 | grep $ngroup1" 1 "checking to ensure netgroup was deleted"

	# Cleaning up users
	ipa user-del $user1
	ipa user-del $user2
	ipa user-del $user3
	ipa user-del $user4
	ipa group-del $group1
	ipa group-del $group2
	ipa group-del $group3
	ipa group-del $group4
	ipa hostgroup-del $hgroup1
	ipa hostgorup-del $hgroup2 
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
