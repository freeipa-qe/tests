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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_bug_831661 - ipa-replica-manage re-initialize update failed due to named ldap timeout"
		OUTPUTCHK=$(grep "reports: Update failed! Status.*System error" $tmpout|wc -l)
		SYSLOGCHK=$(grep "named.*LDAP query timed out. Try to adjust.*timeout" /var/log/messages|wc -l)
		if [ $OUTPUTCHK -gt 0 -a $SYSLOGCHK -gt 0 ]; then
			rlFail "BZ 831661 found...ipa-replica-manage re-initialize update failed due to named ldap timeout"
		else
			rlPass "BZ 831661 not found."
		fi
	rlPhaseEnd
}	
