#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-show.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
#   Description: IPA delegation cli command acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa delegation cli commands need to be tested:
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

######################################################################
#   delegation-show [positive]:
######################################################################
delegation_show_positive()
{
	delegation_show_positive_envsetup
	delegation_show_positive_1001
	delegation_show_positive_1002
	delegation_show_positive_1003
	delegation_show_positive_1004
	delegation_show_positive_envcleanup
}

delegation_show_positive_envsetup()
{
	rlPhaseStartSetup "delegation_show_positive_envsetup "
		KinitAsAdmin
		ipa group-add mg1000 --desc=mg1000
		ipa group-add gr1000 --desc=gr1000
		ipa delegation-add delegation_show_positive_1000 --membergroup=mg1000 --group=gr1000 --attrs=mobile 
	rlPhaseEnd
}

delegation_show_positive_envcleanup()
{
	rlPhaseStartCleanup "delegation_show_positive_envcleanup "
		KinitAsAdmin
		ipa delegation-del delegation_show_positive_1000
		ipa group-del mg1000
		ipa group-del gr1000
	rlPhaseEnd
}

delegation_show_positive_1001()
{
	rlPhaseStartTest "ipa-delegation-show-positive-1001: show by name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show delegation_show_positive_1000 > $tmpout 2>&1" 
		rlAssertGrep "Delegation name: delegation_show_positive_1000" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_show_positive_1002()
{
	rlPhaseStartTest "ipa-delegation-show-positive-1002: show by name with --all"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show delegation_show_positive_1000 --all > $tmpout 2>&1" 
		rlAssertGrep "Delegation name: delegation_show_positive_1000" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_show_positive_1003()
{
	rlPhaseStartTest "ipa-delegation-show-positive-1003: show by name with --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show delegation_show_positive_1000 --raw > $tmpout 2>&1" 
		rlAssertGrep "delegation:delegation_show_positive_1000" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_show_positive_1004()
{
	rlPhaseStartTest "ipa-delegation-show-positive-1004: show by name with --all --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show delegation_show_positive_1000 --all --raw > $tmpout 2>&1" 
		rlAssertGrep "delegation:delegation_show_positive_1000" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

######################################################################
#   delegation-show [negative]:
######################################################################
delegation_show_negative()
{
	delegation_show_negative_envsetup
	delegation_show_negative_1001
	delegation_show_negative_1002
	delegation_show_negative_1003
	delegation_show_negative_1004
	delegation_show_negative_envcleanup
}

delegation_show_negative_envsetup()
{
	rlPhaseStartSetup "delegation_show_negative_envsetup "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_show_negative_envcleanup()
{
	rlPhaseStartCleanup "delegation_show_negative_envcleanup "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_show_negative_1001()
{
	rlPhaseStartTest "ipa-delegation-show-negative-1001: show by name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show baddelegation > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: ACI with name \"baddelegation\" not found" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_show_negative_1002()
{
	rlPhaseStartTest "ipa-delegation-show-negative-1002: show by name with --all"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show baddelegation --all > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: ACI with name \"baddelegation\" not found" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_show_negative_1003()
{
	rlPhaseStartTest "ipa-delegation-show-negative-1003: show by name with --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show baddelegation --raw > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: ACI with name \"baddelegation\" not found" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_show_negative_1004()
{
	rlPhaseStartTest "ipa-delegation-show-negative-1004: show by name with --all --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-show baddelegation --all --raw > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: ACI with name \"baddelegation\" not found" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

