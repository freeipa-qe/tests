#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-user.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
#   Description: IPA delegation cli command acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa delegation cli user/functional testing needed:
# create_ipauser man0001 Manager 0001 passw0rd1
# create_ipauser man0002 Manager 0002 passw0rd2
# create_ipauser emp0001 Employee 0001 passw0rd1
# create_ipauser emp0002 Employee 0002 passw0rd2
# ipa group-add --desc=managers managers
# ipa group-add --desc=employees employees
# ipa group-add-member managers --users=man0001,man0002
# ipa group-add-member employees --users=emp0001,emp0002
# ipa delegation-add managers_change_employees_address --membergroup=managers --group=employees --attrs=street,l,st,postalcode
# ipa delegation-add employees_change_managers_phone --membergroup=employees --group=managers --attrs=telephonenumber,mobile,pager,facsimiletelephonenumber
#
# 
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
ipa_delegation_cli_user()
{
	ipa_delegation_cli_user_envsetup
	ipa_delegation_cli_user_test
	ipa_delegation_cli_user_envcleanup
}

######################################################################
# SETUP
######################################################################
ipa_delegation_cli_user_envsetup()
{
	rlPhaseStartTest "ipa_delegation_cli_user_envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
ipa_delegation_cli_user_envcleanup()
{
	rlPhaseStartTest "ipa_delegation_cli_user_envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# delegation cli tests...
######################################################################
ipa_delegation_cli_user_test()
{
	rlPhaseStartTest "ipa_delegation_cli_user_test: delegation cli command test"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
