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
# Add user with many (15) valid keys 
# Add user with space in key field
#
### user-add negative:
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
	ipa_user_add_ssh_positive_0006 # Add user with space in key field

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
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	rlPhaseStartSetup "ipa_user_add_ssh_envsetup - Setup environment for IPA user-add sshpubkey Tests"
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

		rlLog "===================================================================="
		rlRun "env|sort"
		rlLog "===================================================================="
		#rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME' "
	rlPhaseEnd
}

ipa_user_add_ssh_envcleanup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartCleanup "ipa_user_add_ssh_envcleanup - Clean up environment after IPA user-add sshpubkey Tests"
		case "$MYROLE" in
		MASTER*)
			rlLog "Machine in recipe is MASTER ($MASTER)"
			for u in $(ipa user-find --raw|grep uid:|awk '{print $2}'|egrep "^user[0-9]|^baduser[0-9]"); do
				rlRun "ipa user-del $u"
			done
			rlRun "rm -f /tmp/ssh_user*"
			rlRun "rm -f /tmp/ssh_baduser*"
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

# Add user with empty key field
ipa_user_add_ssh_positive_0001()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_positive_0001: Add user with empty key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa user-add user$NUMBER --first=f --last=l --sshpubkey="
		if [ $(ipa user-show user$NUMBER --raw|grep sshpubkeyfp|wc -l) -eq 0 ]; then
			rlPass "IPA user has no key, as expected"
		else 
			rlFail "IPA user has a key when it should not"
		fi
		rlLog "RUNNING: rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
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

# Add user with blank key field
ipa_user_add_ssh_positive_0002()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_positive_0002: Add user with blank key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa user-add user$NUMBER --first=f --last=l --sshpubkey=''"
		if [ $(ipa user-show user$NUMBER --raw|grep sshpubkeyfp|wc -l) -eq 0 ]; then
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

# Add user with one valid key
ipa_user_add_ssh_positive_0003()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_positive_0003: Add user with one valid key"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_user${NUMBER}_rsa"
		rlRun "ipa user-add user${NUMBER} --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_user${NUMBER}_rsa.pub)\""
		#ipa_user_ssh_key_check user${NUMBER} /tmp/ssh_user${NUMBER}_rsa.pub
		KEY="$(ssh-keygen -l -f /tmp/ssh_user${NUMBER}_rsa.pub | awk '{print $2}')"
		if [ $(ipa user-show user${NUMBER} --raw|grep sshpubkeyfp|grep -i "$KEY"|wc -l) -gt 0 ];  then
			rlPass "IPA User has expected ssh key: $KEY"
		else
			rlFail "IPA User does not have expected ssh key: $KEY"
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

# Add user with two valid keys
ipa_user_add_ssh_positive_0004()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_positive_0004: Add user with two valid keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_user${NUMBER}_rsa"
		rlRun "ssh-keygen -t dsa -N '' -C 'user$NUMBER' -f /tmp/ssh_user${NUMBER}_dsa"
		rlRun "ipa user-add user$NUMBER --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_user${NUMBER}_rsa.pub)\" --sshpubkey=\"$(cat /tmp/ssh_user${NUMBER}_dsa.pub)\""
		
		KEY="$(ssh-keygen -l -f /tmp/ssh_user${NUMBER}_rsa.pub | awk '{print $2}')"
		if [ $(ipa user-show user${NUMBER} --raw|grep sshpubkeyfp|grep -i "$KEY"|wc -l) -gt 0 ];  then
			rlPass "IPA User has expected ssh key: $KEY"
		else
			rlFail "IPA User does not have expected ssh key: $KEY"
		fi
		
		KEY="$(ssh-keygen -l -f /tmp/ssh_user${NUMBER}_dsa.pub | awk '{print $2}')"
		if [ $(ipa user-show user${NUMBER} --raw|grep sshpubkeyfp|grep -i "$KEY"|wc -l) -gt 0 ];  then
			rlPass "IPA User has expected ssh key: $KEY"
		else
			rlFail "IPA User does not have expected ssh key: $KEY"
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

# Add user with many valid keys -- how many should I test? 15 for now
ipa_user_add_ssh_positive_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_positive_0005: Add user with many valid keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		KEYS=""
		for i in $(seq 1 15); do
			ssh-keygen -t rsa -N "" -C "user${NUMBER}_${i}" -f /tmp/ssh_user${NUMBER}_${i}_rsa
			KEYS="$KEYS --sshpubkey=\"$(cat /tmp/ssh_user${NUMBER}_${i}_rsa.pub)\""
		done
		rlRun "ipa user-add user${NUMBER} --first=f --last=l $KEYS"
		rlRun "ipa user-show user${NUMBER} --raw|grep sshpubkeyfp > $tmpout 2>&1"
		for i in $(seq 1 15); do
			KEY="$(ssh-keygen -l -f /tmp/ssh_user${NUMBER}_${i}_rsa.pub | awk '{print $2}')"
			if [ $(cat $tmpout|grep -i "$KEY"|wc -l) -gt 0 ];  then
				rlPass "IPA User has expected ssh key: $KEY"
			else
				rlFail "IPA User does not have expected ssh key: $KEY"
			fi
		done
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

# Fail to add user with Invalid Space in Key field
ipa_user_add_ssh_positive_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_positive_0006: Add user with Space in Key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa user-add user$NUMBER --first=f --last=l --sshpubkey=' '"
		if [ $(ipa user-show user$NUMBER --raw|grep sshpubkeyfp|wc -l) -eq 0 ]; then
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

# Fail to add user with Missing equal signs at end of Key field
ipa_user_add_ssh_negative_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0002: Fail to add user with Missing equal signs at end of Key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		BADKEY="AAAAB3NzaC1yc2EAAAABIwAAAQEA2Vq7ocM+3CIgE9EpR61Yli0ayiw+BdzF3eKq3F44+mFj3gKBBpIIQY9SI74HUpaeahgC6pTsdGdxvqFwCQ5UMnn79YIw+rnkgfzTrD5p4BPxq6IadayMJaKZkhJR4+GGY99Wqp2cfIwWDnfY9QPOTCgOt2SsCZh/SefqXUjy+5O21gtged+59H/qyXeFMrqEhC+dNR2V2Y0l/k8TkNJKdbyVq5LCk3S9wJ5IlCBW8/hF3Nkus7WyLadqfVPoNWdOwfy8BPF4L+iU0AWIWTmGyXtMdwg5cKjWF1fwoh3T5DewQzIX1/2aGiHRueFCvyZU2u+4jI+wDa5HJRwTf9L+Ww"
		rlRun "ipa user-add	baduser --first=f --last=l --sshpubkey=\"$BADKEY\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with Invalid Key Only
ipa_user_add_ssh_negative_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0003: Fail to add user with Invalid Key Only"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ipa user-add baduser --first=f --last=l --sshpubkey=\"badkey\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with Invalid Key First of two
ipa_user_add_ssh_negative_0004()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0004: Fail to add user with Invalid Key First of two"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_rsa"
		rlRun "ipa user-add baduser --first=f --last=l --sshpubkey=\"badkey,$(cat /tmp/ssh_baduser${NUMBER}_rsa.pub)\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with Invalid Key First of N # how many to test?
ipa_user_add_ssh_negative_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0005: Fail to add user with Invalid Key First of N"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		KEYS="--sshpubkey=\"badkey\""
		for i in $(seq 1 15); do
			ssh-keygen -t rsa -N "" -C "baduser${NUMBER}_${i}" -f /tmp/ssh_baduser${NUMBER}_${i}_rsa
			KEYS="$KEYS --sshpubkey=\"$(cat /tmp/ssh_baduser${NUMBER}_${i}_rsa.pub)\""
		done
		rlRun "ipa user-add baduser${NUMBER} --first=f --last=l $KEYS > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with Invalid Key Second of two
ipa_user_add_ssh_negative_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0006: Fail to add user with Invalid Key Second of two"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_rsa"
		rlRun "ipa user-add baduser --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_baduser${NUMBER}_rsa.pub),badkey\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with Invalid Key in Middle (Second of three)
ipa_user_add_ssh_negative_0007()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0007: Fail to add user with Invalid Key in Middle (Second of three)"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_rsa"
		rlRun "ssh-keygen -t dsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_dsa"
		rlRun "ipa user-add baduser --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_baduser${NUMBER}_rsa.pub),badkey,$(cat /tmp/ssh_baduser${NUMBER}_dsa.pub)\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with Invalid Key Last (Third of three)
ipa_user_add_ssh_negative_0008()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0008: Fail to add user with Invalid Key Last (Third of three)"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_rsa"
		rlRun "ssh-keygen -t dsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_dsa"
		rlRun "ipa user-add baduser --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_baduser${NUMBER}_rsa.pub),$(cat /tmp/ssh_baduser${NUMBER}_dsa.pub),badkey\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa user-show baduser > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: baduser: user not found" $tmpout
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

# Fail to add user with SAME Valid Key 
ipa_user_add_ssh_negative_0009()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_user_add_ssh_negative_0009: Fail to add user with SAME Valid Key"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "ssh-keygen -t rsa -N '' -C 'user$NUMBER' -f /tmp/ssh_baduser${NUMBER}_rsa"
		rlRun "ipa user-add baduser${NUMBER} --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_baduser${NUMBER}_rsa.pub)\""
		rlRun "ipa user-add baduser${NUMBER} --first=f --last=l --sshpubkey=\"$(cat /tmp/ssh_baduser${NUMBER}_rsa.pub)\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: user with name \"baduser${NUMBER}\" already exists" $tmpout
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
