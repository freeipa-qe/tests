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
ipa_delegation_cli_cmd_show_positive()
{
	ipa_delegation_cli_cmd_show_positive_envsetup
	ipa_delegation_cli_cmd_show_positive_1001
	ipa_delegation_cli_cmd_show_positive_envcleanup
}

ipa_delegation_cli_cmd_show_positive_envsetup()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_show_positive_envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

ipa_delegation_cli_cmd_show_positive_envcleanup()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_show_positive_envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

ipa_delegation_cli_cmd_show_positive_1001()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_show_positive_1001: delete existing delegation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######################################################################
#   delegation-show [negative]:
######################################################################
ipa_delegation_cli_cmd_show_negative()
{
	ipa_delegation_cli_cmd_show_negative_envsetup
	ipa_delegation_cli_cmd_show_negative_1001
	ipa_delegation_cli_cmd_show_negative_envcleanup
}


ipa_delegation_cli_cmd_show_negative_envsetup()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_show_negative_envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

ipa_delegation_cli_cmd_show_negative_envcleanup()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_show_negative_envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

ipa_delegation_cli_cmd_show_negative_1001()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_show_negative_1001: fail to delete non-existent delegation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       badname
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
