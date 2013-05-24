#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_delegation_ssh.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional
#   Description: IPA Delegation SSH Key tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### delegation tests needed? 
# add delegation for user to modify ipasshpubkey
# user upload keys for other user
# user fail to upload keys when doesn't have permission
# delete delegation for user to modify ipasshpubkey
# user can no longer upload keys for other user after delete
# admin forbid a user from uploading keys (even with selfservice in place)
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
ipa_delegation_ssh_run()
{
	ipa_delegation_ssh_envsetup
	
	ipa_delegation_ssh_0001 # add delegation for user to modify ipasshpubkey
	ipa_delegation_ssh_0002 # user upload keys for other user
	ipa_delegation_ssh_0003 # user fail to upload keys when doesn't have permission
	ipa_delegation_ssh_0004 # delete delegation for user to modify ipasshpubkey
	ipa_delegation_ssh_0005 # user can no longer upload keys for other user after delete
	ipa_delegation_ssh_0006 # admin forbid a user from uploading keys (even with selfservice in place)

	ipa_delegation_ssh_envcleanup
}

ipa_delegation_ssh_envsetup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	TESTUSER1="delegatuser1"
	TESTUSER2="delegatuser2"
	TESTGROUP1="delegatgroup1"
	TESTGROUP2="delegatgroup2"
	TESTUSERPW="passw0rd1"
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartSetup "ipa_delegation_ssh_envsetup - Setup environment for IPA delegation sshpubkey tests"
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
			rlRun "create_ipauser $TESTUSER1 first last $TESTUSERPW"
			rlRun "create_ipauser $TESTUSER2 first last $TESTUSERPW"
			rlRun "KinitAsAdmin"
			rlRun "ipa group-add --desc=desc $TESTGROUP1"
			rlRun "ipa group-add-member $TESTGROUP1 --users=$TESTUSER1"
			rlRun "ipa group-add --desc=desc $TESTGROUP2"
			rlRun "ipa group-add-member $TESTGROUP2 --users=$TESTUSER2"
			rlRun "mkdir /home/$TESTUSER1"
			rlRun "chown $TESTUSER1:$TESTUSER1 /home/$TESTUSER1"
			rlRun "mkdir /home/$TESTUSER2"
			rlRun "chown $TESTUSER2:$TESTUSER2 /home/$TESTUSER2"
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

# add delegation for user to modify ipasshpubkey
ipa_delegation_ssh_0001()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0001: add delegation for user to modify ipasshpubkey"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa delegation-add sshkey_test_delegation --group=$TESTGROUP1 --membergroup=$TESTGROUP2 --attrs=ipasshpubkey > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "Delegation name: sshkey_test_delegation" $tmpout
		rlAssertGrep "Attributes: ipasshpubkey" $tmpout
		rlAssertGrep "Member user group: $TESTGROUP2" $tmpout
		rlAssertGrep "User group: $TESTGROUP1" $tmpout
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

# user upload keys for other user
ipa_delegation_ssh_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0002: user upload keys for other user"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_rsa_${TESTUSER2}*"
		rlRun "su - $TESTUSER1 -c \"ssh-keygen -t rsa -N '' -C $TESTUSER2@$DOMAIN -f /tmp/ssh_rsa_${TESTUSER2}\""
		rlRun "su - $TESTUSER1 -c \"echo $TESTUSERPW|kinit $TESTUSER1; ipa user-mod $TESTUSER2 --sshpubkey='$(cat /tmp/ssh_rsa_${TESTUSER2}.pub)'\" > $tmpout 2>&1"
		KEYCHK=$(ipa user-show $TESTUSER2 --raw --all|grep "ipasshpubkey.*$(awk '{print $2}' /tmp/ssh_rsa_${TESTUSER2}.pub)"|wc -l)
		if [ $KEYCHK -gt 0 ]; then
			rlPass "Expected SSH Pub Key found for user delegation test"
		else
			rlFail "Expected SSH Pub Key NOT found for user delegation test"
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

# user delete keys for other user
ipa_delegation_ssh_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0003: user delete keys for other user"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_rsa_${TESTUSER2}*"
		rlRun "su - $TESTUSER1 -c \"echo $TESTUSERPW|kinit $TESTUSER1; ipa user-mod $TESTUSER2 --sshpubkey=''\" > $tmpout 2>&1"
		rlRun "cat $tmpout"
		KEYCHK=$(ipa user-show $TESTUSER2 --raw|grep sshpubkeyfp|wc -l)
		if [ $KEYCHK -eq 0 ]; then
			rlPass "IPA user has no key, as expected"
		else
			rlFail "IPA user has a key when it should not"
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
# user fail to upload keys when doesn't have permission
ipa_delegation_ssh_0004()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0004: user fail to upload keys when doesn't have permission"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_rsa_${TESTUSER1}*"
		rlRun "su - $TESTUSER2 -c \"ssh-keygen -t rsa -N '' -C $TESTUSER1@$DOMAIN -f /tmp/ssh_rsa_${TESTUSER1}\""
		rlRun "su - $TESTUSER2 -c \"echo $TESTUSERPW|kinit $TESTUSER2; ipa user-mod $TESTUSER1 --sshpubkey='$(cat /tmp/ssh_rsa_${TESTUSER1}.pub)'\" > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'ipaSshPubKey' attribute" $tmpout
		KEYCHK=$(ipa user-show $TESTUSER1 --raw|grep sshpubkeyfp|wc -l)
		if [ $KEYCHK -eq 0 ]; then
			rlPass "IPA user has no key, as expected"
		else
			rlFail "IPA user has a key when it should not"
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

# delete delegation for user to modify ipasshpubkey
ipa_delegation_ssh_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0005: delete delegation for user to modify ipasshpubkey"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa delegation-del sshkey_test_delegation >$tmpout 2>&1"
		rlAssertGrep "Deleted delegation \"sshkey_test_delegation\"" $tmpout
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

# user can no longer upload keys for other user after delete
ipa_delegation_ssh_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0006: user can no longer upload keys for other user after delete"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_rsa_${TESTUSER2}*"
		rlRun "su - $TESTUSER1 -c \"ssh-keygen -t rsa -N '' -C $TESTUSER2@$DOMAIN -f /tmp/ssh_rsa_${TESTUSER2}\""
		rlRun "su - $TESTUSER1 -c \"echo $TESTUSERPW|kinit $TESTUSER1; ipa user-mod $TESTUSER2 --sshpubkey='$(cat /tmp/ssh_rsa_${TESTUSER2}.pub)'\" > $tmpout 2>&1" 1
		KEYCHK=$(ipa user-show $TESTUSER2 --raw|grep "ipasshpubkey.*$(awk '{print $2}' /tmp/ssh_rsa_${TESTUSER2}.pub)"|wc -l)
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'ipaSshPubKey' attribute" $tmpout
		KEYCHK=$(ipa user-show $TESTUSER2 --raw|grep sshpubkeyfp|wc -l)
		if [ $KEYCHK -eq 0 ]; then
			rlPass "IPA user has no key, as expected"
		else
			rlFail "IPA user has a key when it should not"
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

# admin forbid a user from uploading keys (even with selfservice in place)
ipa_delegation_ssh_0007()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_delegation_ssh_0007: admin forbid a user from uploading keys (even with selfservice in place)"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
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

