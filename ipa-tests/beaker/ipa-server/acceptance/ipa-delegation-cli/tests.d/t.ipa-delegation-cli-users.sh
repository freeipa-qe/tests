#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-users.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
#   Description: IPA delegation cli command acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa delegation cli user/functional testing needed:
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
# test suite
######################################################################
ipa_delegation_cli_users()
{
	ipa_delegation_cli_users_envsetup
	ipa_delegation_cli_users_test
	ipa_delegation_cli_users_envcleanup
}

######################################################################
# SETUP
######################################################################
ipa_delegation_cli_users_envsetup()
{
	rlPhaseStartTest "ipa-delegation-cli-users-envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
ipa_delegation_cli_users_envcleanup()
{
	rlPhaseStartTest "ipa-delegation-cli-users-envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# delegation cli tests...
######################################################################
ipa_delegation_cli_users_test()
{
	rlPhaseStartTest "ipa-delegation-cli-users-test: delegation cli command test"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
