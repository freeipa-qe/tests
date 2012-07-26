#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.test-template.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional.sh
#   Description: IPA User Add SSH Key tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### user-add positive:
# Add user with empty key field
# Add user with blank key field
# Add user with one valid key
# Add user with two valid keys
# Add user with many valid keys -- how many should I test?
#
### user-add negative:
# Fail to add user with Invalid Space in Key field
# Fail to add user with Missing equal signs at end of Key field
# Fail to add user with Invalid Key Only
# Fail to add user with Invalid Key First of two
# Fail to add user with Invalid Key First of N # how many to test?
# Fail to add user with Invalid Key Second of two
# Fail to add user with Invalid Key in Middle (Second of three)
# Fail to add user with Invalid Key Last (Third of three)
# Fail to add user with SAME Valid Key 
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
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

######################################################################
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
ipa_user_add_ssh_run()
{
	ipa_user_add_ssh_envsetup
	
	ipa_user_add_ssh_positive_0001 # Add user with empty key field
	ipa_user_add_ssh_positive_0002 # Add user with blank key field
	ipa_user_add_ssh_positive_0003 # Add user with one valid key
	ipa_user_add_ssh_positive_0004 # Add user with two valid keys
	ipa_user_add_ssh_positive_0005 # Add user with many keys -- 20 for now

	ipa_user_add_ssh_negative_0001 # Fail to add user with Invalid Space in Key field
	ipa_user_add_ssh_negative_0002 # Fail to add user with Missing equal signs at end of Key field
	ipa_user_add_ssh_negative_0003 # Fail to add user with Invalid Key Only
	ipa_user_add_ssh_negative_0004 # Fail to add user with Invalid Key First of two
	ipa_user_add_ssh_negative_0005 # Fail to add user with Invalid Key First of three
	ipa_user_add_ssh_negative_0006 # Fail to add user with Invalid Key Second of two
	ipa_user_add_ssh_negative_0007 # Fail to add user with Invalid Key in Middle (Second of three)
	ipa_user_add_ssh_negative_0008 # Fail to add user with Invalid Key Last (Third of three)
	ipa_user_add_ssh_negative_0009 # Fail to add user with SAME Valid Key

	ipa_user_add_ssh_envcleanup
}

ipa_user_add_ssh_envsetup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_user_add_ssh_envsetup - Setup environment for IPA user-add sshpubkey Tests"
		if [ -z "$MYENV" ]; then
			MYENV=1
		fi
		hostname_s=$(hostname -s)

		# Use BEAKERMASTER if BEAKERMASTER_env${MYENV} not set
		MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV}) 
		MYBM1=${MYBM1:-$BEAKERMASTER} 
		
		# User BEAKERSLAVE if BEAKERSLAVE_env${MYENV} not set
		MYBRS=$(eval echo \$BEAKERREPLICA_env${MYENV})
		MYBRS=${MYBRS:-$BEAKERSLAVE}
		COUNT=0
		for MYBR in $MYBRS; do
			COUNT=$(( COUNT+=1 ))
			eval export MYBR$COUNT=$MYBR
		done
		
		# User BEAKERCLIENT if BEAKERCLIENT_env${MYENV} not set
		MYBCS=$(eval echo \$BEAKERCLIENT_env${MYENV})
		MYBCS=${MYBCS:-$BEAKERCLIENT}
		COUNT=0
		for MYBC in $MYBCS; do
			COUNT=$(( COUNT+=1 ))
			eval export MYBC$COUNT=$MYBC
		done

		rlRun "rhts-sync-block -s '$TESTORDER.$FUNCNAME' "
	rlPhaseEnd
}

ipa_user_add_ssh_positive_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "test_run - run test"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "hostname"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "hostname"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "hostname"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

test_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "test_envcleanup - clean up test environment"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "hostname"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "hostname"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "hostname"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
