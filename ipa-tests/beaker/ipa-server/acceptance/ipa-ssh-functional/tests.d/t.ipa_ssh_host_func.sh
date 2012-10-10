#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_ssh_host_func.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional
#   Description: IPA Functional SSH Host Key tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#
### host key functional test
# New client added and host keys uploaded automatically to DNS
# User ssh to client and sees valid keys match from DNS.
        # ATM this will still prompt until DNSSEC support added???
# Admin revokes/removes host keys
# User does not see key match from DNS
# Admin re-adds keys
# Host replaces keys
# User gets error/warning about key mismatch?
# host-mod add keys after host-disable
# ssh to/from host after host-disable
# host-mod add keys after host-del?
# ssh to/from host after host-del?
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
ipa_ssh_host_func_run()
{
	#ipa_ssh_host_func_envsetup

	ipa_ssh_host_func_0001 # New client added and host keys uploaded automatically to DNS
	#ipa_ssh_host_func_0002 # User ssh to client and sees valid keys match from DNS.
        # ATM this will still prompt until DNSSEC support added???
	#ipa_ssh_host_func_0003 # Admin revokes/removes host keys
	#ipa_ssh_host_func_0004 # User does not see key match from DNS
	#ipa_ssh_host_func_0005 # Admin re-adds keys
	#ipa_ssh_host_func_0006 # Host replaces keys
	#ipa_ssh_host_func_0007 # User gets error/warning about key mismatch?
	#ipa_ssh_host_func_0008 # host-mod add keys after host-disable
	#ipa_ssh_host_func_0009 # ssh to/from host after host-disable
	#ipa_ssh_host_func_0010 # host-mod add keys after host-del?
	#ipa_ssh_host_func_0011 # ssh to/from host after host-del?

	#ipa_ssh_host_func_envcleanup
}

ipa_ssh_host_func_envsetup()
{
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	TESTUSER="sshuser1"
	TESTUSERPW="passw0rd1"
	rlPhaseStartTest "ipa_ssh_host_func_envsetup - Setup environment for IPA User Functional tests"
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
			rlRun "create_ipauser sshuser ssh user Passw0rd1"
			rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
			;;
		SLAVE*|REPLICA*)
			rlLog "Machine in recipe is SLAVE ($SLAVE)"
			rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
			;;
		CLIENT*)
			rlLog "Machine in recipe is CLIENT ($CLIENT)"
			rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
			;;
		*)
			rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
			;;
		esac
	rlPhaseEnd
}

# New client added and host keys uploaded automatically to DNS
ipa_ssh_host_func_0001()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0001 - New client added and host keys uploaded automatically to DNS"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BEAKERCLIENT_env${MYENV}"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BEAKERCLIENT_env${MYENV}"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "KinitAsAdmin"
	
		RSAKEYFP=$(ssh-keygen -r $(hostname) -f /etc/ssh/ssh_host_rsa_key.pub|awk '{print $6}')
		RSADNSFP=$(dig +short $(hostname) sshfp|grep "^1 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$RSAKEYFP" -o -z "$RSADNSFP" ]; then
			rlFail "RSA Key FP on host or in DNS is empty"
		elif [ "$RSAKEYFP" = "$RSADNSFP" ]; then
			rlPass "RSA Key FP on host matches FP in DNS"
		else
			rlFail "RSA Key FP on host does not match FP in DNS"
		fi

		DSAKEYFP=$(ssh-keygen -r $(hostname) -f /etc/ssh/ssh_host_dsa_key.pub|awk '{print $6}')
		DSADNSFP=$(dig +short $(hostname) sshfp|grep "^2 1" |awk '{print $3}'|tr '[:upper:]' '[:lower:]')
		if [ -z "$DSAKEYFP" -o -z "$DSADNSFP" ]; then
			rlFail "DSA Key FP on host or in DNS is empty"
		elif [ "$DSAKEYFP" = "$DSADNSFP" ]; then
			rlPass "DSA Key FP on host matches FP in DNS"
		else
			rlFail "DSA Key FP on host does not match FP in DNS"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT'"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $BEAKERCLIENT_env${MYENV}"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# User ssh to client and sees valid keys match from DNS.
ipa_ssh_host_func_0002()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0002 - User ssh to client and sees valid keys match from DNS"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# Admin revokes/removes host keys
ipa_ssh_host_func_0003()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0003 - Admin revokes/removes host keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# User does not see key match from DNS
ipa_ssh_host_func_0004()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0004 - User does not see key match from DNS"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# Admin re-adds keys
ipa_ssh_host_func_0005()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0005 - Admin re-adds keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# Host replaces keys
ipa_ssh_host_func_0006()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0006 - Host replaces keys"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# User gets error/warning about key mismatch
ipa_ssh_host_func_0007()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0007 - User gets error/warning about key mismatch"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# host-mod add keys after host-disable
ipa_ssh_host_func_0008()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0008 - host-mod add keys after host-disable"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# ssh to/from host after host-disable
ipa_ssh_host_func_0009()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0009 - ssh to/from host after host-disable"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# host-mod add keys after host-del
ipa_ssh_host_func_0010()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0010 - host-mod add keys after host-del"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# ssh to/from host after host-del
ipa_ssh_host_func_0011()
{
	tmpout=/tmp/tmpout.$FUNCNAME
	TESTCOUNT=$(( TESTCOUNT += 1 ))
	NUMBER=$(echo $FUNCNAME|sed 's/[a-Z_]*\([0-9]*$\)/\1/')
	rlPhaseStartTest "ipa_ssh_host_func_0011 - ssh to/from host after host-del"
	case "$MYROLE" in
	MASTER*)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MASTER_IP"
		;;
	SLAVE*|REPLICA*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	CLIENT*)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
