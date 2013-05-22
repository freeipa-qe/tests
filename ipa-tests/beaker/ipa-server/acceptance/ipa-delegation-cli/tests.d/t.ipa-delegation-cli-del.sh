#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-del.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
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
#   delegation-del [positive]:
######################################################################
delegation_del_positive()
{
	delegation_del_positive_envsetup
	delegation_del_positive_1001
	delegation_del_positive_envcleanup
}

delegation_del_positive_envsetup()
{
	rlPhaseStartSetup "delegation_del_positive_envsetup "
		KinitAsAdmin
		rlRun "ipa delegation-add delegation_del_positive_1001 --membergroup=admins --group=ipausers --attrs=mobile"
	rlPhaseEnd
}

delegation_del_positive_envcleanup()
{
	rlPhaseStartCleanup "delegation_del_positive_envcleanup "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_del_positive_1001()
{
	rlPhaseStartTest "ipa-delegation-del-positive-1001: delete existing delegation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1
		rlRun "ipa delegation-del $FUNCNAME" 
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######################################################################
#   delegation-del [negative]:
######################################################################
delegation_del_negative()
{
	delegation_del_negative_envsetup
	delegation_del_negative_1001
	delegation_del_negative_envcleanup
}


delegation_del_negative_envsetup()
{
	rlPhaseStartSetup "delegation_del_negative_envsetup "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_del_negative_envcleanup()
{
	rlPhaseStartCleanup "delegation_del_negative_envcleanup "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_del_negative_1001()
{
	rlPhaseStartTest "ipa-delegation-del-negative-1001: fail to delete non-existent delegation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       badname
		rlRun "ipa delegation-del badname > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: ACI with name \"badname\" not found" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
