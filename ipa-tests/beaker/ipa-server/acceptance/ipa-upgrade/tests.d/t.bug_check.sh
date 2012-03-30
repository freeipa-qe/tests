#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.upgrade_bug_check.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA multihost upgrade bug check script
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
upgrade_bz_766096()
{
	TESTORDER=$(( TESTORDER += 1 ))
	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "upgrade_bz_766096: Handle schema upgrades from IPA v2 to v3"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		rlRun "ldapsearch -xLLL -D '$ROOTDN' -w '$ROOTDNPWD' -s base -b cn=schema '*' attributeTypes objectClasses | perl -p0e 's/\n //g' > $tmpout"
		rlRun "grep memberPrincipal $tmpout"       0 "Checking for memberPrincipal attribute added to schema"
		rlRun "grep ipaAllowToImpersonate $tmpout" 0 "Checking for ipaAllowToImpersonate attribute added to schema"
		rlRun "grep ipaAllowedTarget $tmpout"      0 "Checking for ipaAllowedTarget attribute added to schema"
		rlRun "grep groupOfPrincipals $tmpout"     0 "Checking for groupOfPrincipals attribute added to schema"
		rlRun "grep ipaKrb5DelegationACL $tmpout"  0 "Checking for ipaKrb5DelegationACL attribute added to schema"
		checkattrs=$(egrep "memberPrincipal|ipaAllowToImpersonate|ipaAllowedTarget|groupOfPrincipals|ipaKrb5DelegationACL" $tmpout|wc -l)

		if [ -f /usr/share/ipa/updates/10-60basev3.update -a $checkattrs -eq 5 ]; then
			rlPass "BZ 766096 not found....all v3 attributes found in schema"
		else
			rlFail "BZ 766096 found...Handle schema upgrades from IPA v2 to v3"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] rm -f $tmpout
}


upgrade_bz_746589()
{
	local tmpout=/tmp/$FUNCNAME.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "upgrade_bz_746589: automember functionality not available for upgraded IPA server"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		KinitAsAdmin
		rlLog "checking if upgrade"
		isUpgrade=$(yum history package  ipa-server|head -5|grep Update|wc -l)
		if [ $isUpgrade -eq 0 ]; then
			rlPass "IPA not an upgrade...skipping test"
		else
			rlRun "ipa group-add --desc=ipa-automember-bz-746589 ipa-automember-bz-746589"
			rlRun "ipa automember-add --type=group ipa-automember-bz-746589  > $tmpout 2>&1"
			if [ $? -eq 0 ]; then
				rlPass "BZ 746589 not found"
			elif [ $(grep "ipa: ERROR: Auto Membership is not configured" $tmpout|wc -l) -eq 1 ]; then
				rlFail "BZ 746589 found...automember functionality not available for upgraded IPA server"
			fi      
			ipa automember-del --type=group ipa-automember-bz-746589 > /dev/null
			ipa group-del ipa-automember-bz-746589 > /dev/null
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_782918()
{
	local tmpout=/tmp/$FUNCNAME.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "upgrade_bz_782918: Provide man page for ipa-upgradeconfig"
	case "$MYROLE" in
	"MASTER")
		rlRun "test -f /usr/share/man/man8/ipa-upgradeconfig.8.gz"
		if [ ! -f /usr/share/man/man8/ipa-upgradeconfig.8.gz ]; then
			rlLog "No man page for ipa-upgradeconfig found"
			rlFail "BZ 782918 found...Provide man page for ipa-upgradeconfig"
		else
			rlLog "Man page for ipa-upgradeconfig found"
			rlPass "BZ 782918 not found"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}
