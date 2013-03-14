#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.test-template.bug.sh of /CoreOS/ipa-tests/acceptance/ipa-test-template
#   Description: IPA multihost Bug test script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
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
test_bug_000000()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "test_bug_000000 - Setup environment for test template"
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

irm_bugcheck_831661()
{
	tmpout=$1
	logserver=$2
	#TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_bug_831661 - ipa-replica-manage re-initialize update failed due to named ldap timeout"
		OUTPUTCHK=$(grep "reports: Update failed! Status.*System error" $tmpout|wc -l)
		
		sftp root@$logserver:/var/log/messages /opt/rhqa_ipa/messages.$logserver
		SYSLOGCHK=$(grep "named.*LDAP query timed out. Try to adjust.*timeout" /opt/rhqa_ipa/messages.$logserver|wc -l)
		if [ $OUTPUTCHK -gt 0 -a $SYSLOGCHK -gt 0 ]; then
			rlFail "BZ 831661 found...ipa-replica-manage re-initialize update failed due to named ldap timeout"
		else
			rlPass "BZ 831661 not found."
		fi
	rlPhaseEnd
}	

irm_bugcheck_839638()
{
	tmpout=$1
	#TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_bugcheck_839638 - ipa-replica-manage allows disconnect of last connection for a single replica"
		OUTPUTCHK1=$(grep "Deleted replication agreement" $tmpout|wc -l)
		OUTPUTCHK2=$(grep "Cannot remove the last replication link" $tmpout | wc -l)
		if [ $OUTPUTCHK1 -gt 0 -a $OUTPUTCHK2 -eq 0 ]; then
			rlFail "BZ 839638 found...ipa-replica-manage allows disconnect of last connection for a single replica"
		else
			rlPass "BZ 839638 not found."
		fi
	rlPhaseEnd
}

irm_bugcheck_826677()
{
	tmpout=$1
	#TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_bugcheck_826677 - IPA cannot remove disconnected replica data to reconnect"
		OUTPUTCHK1=$(grep "Deleting this server will orphan" $tmpout|wc -l)
		OUTPUTCHK2=$(grep "You will need to reconfigure your replication topology to delete this server." $tmpout|wc -l)
		if [ $OUTPUTCHK1 -gt 0 -a $OUTPUTCHK2 -gt 0 ]; then
			rlPass "BZ 826677 not found"
			rlPass "IPA now prevents orphaning replicas"
		else
			rlFail "BZ 826677 found...IPA cannot remove disconnected replica data to reconnect"	
			rlFail "IPA should no longer allow orphaning replicas"
		fi
	rlPhaseEnd
}

irm_bugcheck_754539()
{
	tmpout=$1
	#TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_bugcheck_754539 - Connect after del using ipa-replica-manage fails"
		OUTPUTCHK1=$(grep "You cannot connect to a previously deleted master" $tmpout|wc -l)
		if [ $OUTPUTCHK1 -gt 0 ]; then
			rlPass "BZ 754539 not found."
		else
			rlFail "BZ 754539 found...Connect after del using ipa-replica-manage fails"
		fi
	rlPhaseEnd
}

irm_bugcheck_823657()
{
	tmpout=$1
	#TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_bugcheck_823657 - ipa-replica-manage connect fails with GSSAPI error after delete if using previous kerberos ticket"
		OUTPUTCHK1=$(grep "SASL(-1): generic failure: GSSAPI Error: Unspecified GSS failure" $tmpout|wc -l)
		OUTPUTCHK2=$(grep "You cannot connect to a previously deleted master" $tmpout|wc -l)
		if [ $OUTPUTCHK1 -gt 0 -a $OUTPUTCHK2 -eq 0 ]; then
			rlFail "BZ 823657 found...ipa-replica-manage connect fails with GSSAPI error after delete if using previous kerberos ticket"
		else
			rlPass "BZ 823657 not found."
		fi
	rlPhaseEnd
}
