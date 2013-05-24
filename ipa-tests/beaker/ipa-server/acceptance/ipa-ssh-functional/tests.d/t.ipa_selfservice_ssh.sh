#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_selfservice_ssh.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional
#   Description: IPA Selfservice SSH Key tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### selfservice tests needed? 
# confirm selfservice rule exists
# delete selfservice rule and confirm user cannot upload own keys
# re-add selfservice rule and confirm user can upload keys again
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
ipa_selfservice_ssh_run()
{
	ipa_selfservice_ssh_envsetup
	
	ipa_selfservice_ssh_0001 # confirm selfservice rule exists
	ipa_selfservice_ssh_0002 # delete selfservice rule and confirm user cannot upload own keys
	ipa_selfservice_ssh_0003 # re-add selfservice rule and confirm user can upload keys again

	ipa_selfservice_ssh_envcleanup
}

ipa_selfservice_ssh_envsetup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	TESTUSER="selfservuser1"
	TESTUSERPW="passw0rd1"
	rlPhaseStartSetup "ipa_selfservice_ssh_envsetup - Setup environment for IPA selfservice sshpubkey tests"
		if [ -z "$MYENV" ]; then
			MYENV=1
		fi
		hostname_s=$(hostname -s)

		# Use BEAKERMASTER if BEAKERMASTER_env${MYENV} not set
		MYBM1=$(eval echo \$BEAKERMASTER_env${MYENV}) 
		export MYBM1=${MYBM1:-$BEAKERMASTER} 
		if [ $(echo $MYBM1|grep $hostname_s|wc -l) -gt 0 ]; then
			MYROLE=MASTER
		fi
		
		# User BEAKERSLAVE if BEAKERSLAVE_env${MYENV} not set
		MYBRS=$(eval echo \$BEAKERREPLICA_env${MYENV})
		MYBRS=${MYBRS:-$BEAKERSLAVE}
		COUNT=0
		for MYBR in $MYBRS; do
			COUNT=$(( COUNT+=1 ))
			eval export MYBR$COUNT=$MYBR
			if [ $(echo $MYBR|grep $hostname_s|wc -l) -gt 0 ]; then
				MYROLE=REPLICA$COUNT
			fi
		done
		
		# User BEAKERCLIENT if BEAKERCLIENT_env${MYENV} not set
		MYBCS=$(eval echo \$BEAKERCLIENT_env${MYENV})
		MYBCS=${MYBCS:-$BEAKERCLIENT}
		COUNT=0
		for MYBC in $MYBCS; do
			COUNT=$(( COUNT+=1 ))
			eval export MYBC$COUNT=$MYBC
			if [ $(echo $MYBC|grep $hostname_s|wc -l) -gt 0 ]; then
				MYROLE=CLIENT$COUNT
			fi
		done

		case "$MYROLE" in
		MASTER*)
			rlLog "Machine in recipe is MASTER ($MASTER)"
			rlRun "KinitAsAdmin"
			rlRun "create_ipauser $TESTUSER first last $TESTUSERPW"
			rlRun "KinitAsAdmin"
			rlRun "mkdir /home/$TESTUSER"
			rlRun "chown $TESTUSER:$TESTUSER /home/$TESTUSER"
			rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
			;;
		SLAVE*|REPLICA*)
			rlLog "Machine in recipe is SLAVE ($SLAVE)"
			rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
			;;
		CLIENT*)
			rlLog "Machine in recipe is CLIENT ($CLIENT)"
			rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
			;;
		*)
			rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
			;;
		esac
	rlPhaseEnd
}

# confirm selfservice rule exists
ipa_selfservice_ssh_0001()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_selfservice_ssh_0001: confirm selfservice rule exists"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa selfservice-find \"Users can manage their own SSH public keys\" > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "Self-service name: Users can manage their own SSH public keys" $tmpout
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# delete selfservice rule and confirm user cannot upload own keys
ipa_selfservice_ssh_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_selfservice_ssh_0002: delete selfservice rule and confirm user cannot upload own keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa selfservice-del \"Users can manage their own SSH public keys\"" 
		rlRun "su - $TESTUSER -c \"ssh-keygen -t rsa -N '' -C $TESTUSER@$DOMAIN -f /tmp/ssh_user_key_${TESTUSER}_rsa\""
		rlRun "su - $TESTUSER -c \"echo $TESTUSERPW|kinit $TESTUSER; ipa user-mod $TESTUSER --sshpubkey='$(cat /tmp/ssh_user_key_${TESTUSER}_rsa.pub)'\" > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'ipaSshPubKey' attribute of entry" $tmpout
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# re-add selfservice rule and confirm user can upload keys again
ipa_selfservice_ssh_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_selfservice_ssh_0003: re-add selfservice rule and confirm user can upload keys again"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		KinitAsAdmin
		rlRun "ipa selfservice-add \"Users can manage their own SSH public keys\" --attrs=ipasshpubkey"
		rlRun "su - $TESTUSER -c \"ssh-keygen -t rsa -N '' -C $TESTUSER@$DOMAIN -f /tmp/ssh_user_key2_${TESTUSER}_rsa\""
		rlRun "su - $TESTUSER -c \"echo $TESTUSERPW|kinit $TESTUSER; ipa user-mod $TESTUSER --sshpubkey='$(cat /tmp/ssh_user_key2_${TESTUSER}_rsa.pub)'\" > $tmpout 2>&1"
		rlRun "cat $tmpout"
		KEYCHK=$(ipa user-show $TESTUSER --raw|grep "ipasshpubkey.*$(awk '{print $2}' /tmp/ssh_user_key2_selfservuser1_rsa.pub)"|wc -l)
		if [ $KEYCHK -gt 0 ]; then
			rlPass "Expected SSH Pub Key found for user selfservice test"
		else
			rlPass "Expected SSH Pub Key NOT found for user selfservice test"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
