#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.test-template.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional.sh
#   Description: IPA Host Mod SSH Key tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### host-mod positive:
# Mod host with empty key field
# Mod host with blank key field
# Mod host with one valid key
# Mod host with two valid keys
# Mod host with many valid keys -- how many should I test?
# Mod host with blank key field to delete keys
# Mod host with space in key field
#
### host-mod negative:
# Fail to mod host with Missing equal signs at end of Key field
# Fail to mod host with Invalid Key Only
# Fail to mod host with Invalid Key First of two
# Fail to mod host with Invalid Key First of N # how many to test?
# Fail to mod host with Invalid Key Second of two
# Fail to mod host with Invalid Key in Middle (Second of three)
# Fail to mod host with Invalid Key Last (Third of three)
# Fail to mod host with SAME Valid Key 
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
ipa_host_mod_ssh_run()
{
	ipa_host_mod_ssh_envsetup
	
	ipa_host_mod_ssh_positive_0001 # Mod host with empty key field
	ipa_host_mod_ssh_positive_0002 # Mod host with blank key field
	ipa_host_mod_ssh_positive_0003 # Mod host with one valid key
	ipa_host_mod_ssh_positive_0004 # Mod host with two valid keys
	ipa_host_mod_ssh_positive_0005 # Mod host with many (15) valid keys 
	ipa_host_mod_ssh_positive_0006 # Mod host with blank key field to delete keys
	ipa_host_mod_ssh_positive_0007 # Mod host with space in key field

	ipa_host_mod_ssh_negative_0001 # Fail to mod host with Missing equal signs at end of Key field
	ipa_host_mod_ssh_negative_0002 # Fail to mod host with Invalid Key Only
	ipa_host_mod_ssh_negative_0003 # Fail to mod host with Invalid Key First of two
	ipa_host_mod_ssh_negative_0004 # Fail to mod host with Invalid Key First of N # how many to test?
	ipa_host_mod_ssh_negative_0005 # Fail to mod host with Invalid Key Second of two
	ipa_host_mod_ssh_negative_0006 # Fail to mod host with Invalid Key in Middle (Second of three)
	ipa_host_mod_ssh_negative_0007 # Fail to mod host with Invalid Key Last (Third of three)
	ipa_host_mod_ssh_negative_0008 # Fail to mod host with SAME Valid Key 

	ipa_host_mod_ssh_envcleanup
}

ipa_host_mod_ssh_envsetup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	rlPhaseStartSetup "ipa_host_mod_ssh_envsetup - Setup environment for IPA host-mod sshpubkey Tests"
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
			rlRun "rm -f /tmp/ssh_*host*"
			rlRun "ipa dnszone-add 2.2.2.in-addr.arpa. --name-server=$MYBM1. --admin-email=ipaqar.redhat.com"
			rlRun "ipa dnszone-add 4.2.2.in-addr.arpa. --name-server=$MYBM1. --admin-email=ipaqar.redhat.com"
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

		#rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME' "
	rlPhaseEnd
}

# Mod host with empty key field
ipa_host_mod_ssh_positive_0001()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/'|sed 's/^[0]*//')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_positive_0001: Mod host with empty key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "ipa host-add host${NUMBER}.${DOMAIN} --ip-address=2.2.2.${SMALLNUMBER} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\""
		rlRun "ipa host-mod host${NUMBER}.${DOMAIN} --sshpubkey="
		if [ $(ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp|wc -l) -eq 0 ]; then
			rlPass "IPA host has no key, as expected"
		else 
			rlPass "IPA host has a key when it should not"
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

# Mod host with blank key field
ipa_host_mod_ssh_positive_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_positive_0002: Mod host with blank key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "ipa host-add host${NUMBER}.${DOMAIN} --ip-address=2.2.2.${SMALLNUMBER} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\""
		rlRun "ipa host-mod host${NUMBER}.${DOMAIN} --sshpubkey=''"
		if [ $(ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp|wc -l) -eq 0 ]; then
			rlPass "IPA host has no key, as expected"
		else 
			rlPass "IPA host has a key when it should not"
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

# Mod host with one valid key
ipa_host_mod_ssh_positive_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_positive_0003: Mod host with one valid key"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "ipa host-add host${NUMBER}.${DOMAIN} --ip-address=2.2.2.${SMALLNUMBER}"
		rlRun "ipa host-mod host${NUMBER}.${DOMAIN} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\""
		KEY="$(ssh-keygen -l -f /tmp/ssh_host${NUMBER}_rsa.pub|awk '{print $2}')"
		if [ $(ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp|grep -i "$KEY"|wc -l) -gt 0 ]; then
			rlPass "IPA host has expected ssh key fingerprint: $KEY"
		else 
			rlFail "IPA host does not have expected ssh key fingerprint: $KEY"
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

# Mod host with two valid keys
ipa_host_mod_ssh_positive_0004()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_positive_0004: Mod host with two valid keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_dsa*"
		rlRun "ssh-keygen -q -t dsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_dsa"
		rlRun "ipa host-add host${NUMBER}.${DOMAIN} --ip-address=2.2.2.${SMALLNUMBER}"
		rlRun "ipa host-mod host${NUMBER}.${DOMAIN} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\" --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_dsa.pub)\""
		KEY="$(ssh-keygen -l -f /tmp/ssh_host${NUMBER}_rsa.pub|awk '{print $2}')"
		if [ $(ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp|grep -i "$KEY"|wc -l) -gt 0 ]; then
			rlPass "IPA host has expected ssh key fingerprint: $KEY"
		else 
			rlFail "IPA host does not have expected ssh key fingerprint: $KEY"
		fi
		KEY="$(ssh-keygen -l -f /tmp/ssh_host${NUMBER}_dsa.pub|awk '{print $2}')"
		if [ $(ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp|grep -i "$KEY"|wc -l) -gt 0 ]; then
			rlPass "IPA host has expected ssh key fingerprint: $KEY"
		else 
			rlFail "IPA host does not have expected ssh key fingerprint: $KEY"
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

# Mod host with many (15) valid keys 
ipa_host_mod_ssh_positive_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_positive_0005: Mod host with many (15) valid keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		KEYS=""
		for i in $(seq 1 15); do
			rlRun "rm -f /tmp/ssh_host${NUMBER}_${i}_rsa*"
			rlRun "ssh-keygen -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_${i}_rsa"
			KEYS="$KEYS --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_${i}_rsa.pub)\""
		done
		rlRun "ipa host-add host${NUMBER}.${DOMAIN} --ip-address=2.2.2.${SMALLNUMBER}"
		rlRun "ipa host-mod host${NUMBER}.${DOMAIN} $KEYS"
		rlRun "ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp > $tmpout 2>&1"
		for i in $(seq 1 15); do
			KEY="$(ssh-keygen -l -f /tmp/ssh_host${NUMBER}_${i}_rsa.pub | awk '{print $2}')"
			if [ $(cat $tmpout|grep -i "$KEY"|wc -l) -gt 0 ];  then
				rlPass "IPA host has expected ssh key: $KEY"
			else
				rlFail "IPA host does not have expected ssh key: $KEY"
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

# Mod host with space in key field
ipa_host_mod_ssh_positive_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_positive_0006: Mod host with space in key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "ipa host-add host${NUMBER}.${DOMAIN} --ip-address=2.2.2.${SMALLNUMBER} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\""
		rlRun "ipa host-mod host${NUMBER}.${DOMAIN} --sshpubkey=' '"
		if [ $(ipa host-show host${NUMBER}.${DOMAIN} --raw|grep sshpubkeyfp|wc -l) -eq 0 ]; then
			rlPass "IPA host has no key, as expected"
		else 
			rlPass "IPA host has a key when it should not"
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

# Fail to mod host with Missing equal signs at end of Key field
ipa_host_mod_ssh_negative_0001()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0001: Fail to mod host with Missing equal signs at end of Key field"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		BADKEY="AAAAB3NzaC1yc2EAAAABIwAAAQEA2Vq7ocM+3CIgE9EpR61Yli0ayiw+BdzF3eKq3F44+mFj3gKBBpIIQY9SI74HUpaeahgC6pTsdGdxvqFwCQ5UMnn79YIw+rnkgfzTrD5p4BPxq6IadayMJaKZkhJR4+GGY99Wqp2cfIwWDnfY9QPOTCgOt2SsCZh/SefqXUjy+5O21gtged+59H/qyXeFMrqEhC+dNR2V2Y0l/k8TkNJKdbyVq5LCk3S9wJ5IlCBW8/hF3Nkus7WyLadqfVPoNWdOwfy8BPF4L+iU0AWIWTmGyXtMdwg5cKjWF1fwoh3T5DewQzIX1/2aGiHRueFCvyZU2u+4jI+wDa5HJRwTf9L+Ww"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\""
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"$BADKEY\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
		rlRun "ipa host-show --all badhost${NUMBER}.${DOMAIN} > $tmpout 2>&1" 
		rlLog "Make sure IPA still shows original key"
		rlAssertGrep "$(awk '{print $2}' /tmp/ssh_host${NUMBER}_rsa.pub)" $tmpout
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

# Fail to mod host with Invalid Key Only
ipa_host_mod_ssh_negative_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0002: Fail to mod host with Invalid Key Only"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_host${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_host${NUMBER}_rsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER} --sshpubkey=\"$(cat /tmp/ssh_host${NUMBER}_rsa.pub)\""
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"badkey\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
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

# Fail to mod host with Invalid Key First of two
ipa_host_mod_ssh_negative_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0003: Fail to mod host with Invalid Key First of two"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_rsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER}"
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"badkey,$(cat /tmp/ssh_badhost${NUMBER}_rsa.pub)\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
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

# Fail to mod host with Invalid Key First of N # how many to test?
ipa_host_mod_ssh_negative_0004()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0004: Fail to mod host with Invalid Key First of N"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		KEYS="--sshpubkey=\"badkey\""
		for i in $(seq 1 15); do
			rlRun "rm -f /tmp/ssh_badhost${NUMBER}_${i}_rsa*"
			rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_${i}_rsa"
			KEYS="$KEYS --sshpubkey=\"$(cat /tmp/ssh_badhost${NUMBER}_${i}_rsa.pub)\""
		done
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER}"
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} $KEYS > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
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

# Fail to mod host with Invalid Key Second of two
ipa_host_mod_ssh_negative_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0005: Fail to mod host with Invalid Key Second of two"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_rsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER}"
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"$(cat /tmp/ssh_badhost${NUMBER}_rsa.pub),badkey\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
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

# Fail to mod host with Invalid Key in Middle (Second of three)
ipa_host_mod_ssh_negative_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0006: Fail to mod host with Invalid Key in Middle (Second of three)"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_rsa"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_dsa*"
		rlRun "ssh-keygen -q -t dsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_dsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER}"
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"$(cat /tmp/ssh_badhost${NUMBER}_rsa.pub),badkey,$(cat /tmp/ssh_badhost${NUMBER}_dsa.pub)\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
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

# Fail to mod host with Invalid Key Last (Third of three)
ipa_host_mod_ssh_negative_0007()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0007: Fail to mod host with Invalid Key Last (Third of three)"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_rsa"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_dsa*"
		rlRun "ssh-keygen -q -t dsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_dsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER}"
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"$(cat /tmp/ssh_badhost${NUMBER}_rsa.pub),$(cat /tmp/ssh_badhost${NUMBER}_dsa.pub),badkey\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sshpubkey': invalid SSH public key" $tmpout
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

# Fail to mod host with SAME Valid Key 
ipa_host_mod_ssh_negative_0008()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	SMALLNUMBER=$(echo ${NUMBER}|sed 's/^[0]*//')
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartTest "ipa_host_mod_ssh_negative_0008: Fail to mod host with SAME Valid Key"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rm -f /tmp/ssh_badhost${NUMBER}_rsa*"
		rlRun "ssh-keygen -q -t rsa -N '' -C '' -f /tmp/ssh_badhost${NUMBER}_rsa"
		rlRun "ipa host-add badhost${NUMBER}.${DOMAIN} --ip-address=2.2.4.${SMALLNUMBER} --sshpubkey=\"$(cat /tmp/ssh_badhost${NUMBER}_rsa.pub)\"" 0
		rlRun "ipa host-mod badhost${NUMBER}.${DOMAIN} --sshpubkey=\"$(cat /tmp/ssh_badhost${NUMBER}_rsa.pub)\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
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


ipa_host_mod_ssh_envcleanup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	BKRRUNHOST=$(eval echo \$BEAKERMASTER_env${MYENV})
	rlPhaseStartCleanup "ipa_host_mod_ssh_envcleanup - clean up test environment"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER ($MASTER)"
		for h in $(ipa host-find host --pkey-only --raw|grep fqdn:.*host|awk '{print $2}'); do
			rlRun "ipa host-del $h --updatedns"
		done
		rlRun "rm -f /tmp/ssh_*host*"
		rlRun "ipa dnszone-del 2.2.2.in-addr.arpa."
		rlRun "ipa dnszone-del 4.2.2.in-addr.arpa."
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $BKRRUNHOST"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BKRRUNHOST"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
