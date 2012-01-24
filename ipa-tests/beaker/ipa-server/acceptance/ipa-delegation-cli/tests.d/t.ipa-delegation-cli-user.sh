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
#
#  Negative: As man0001 fail to change all user attrs
#  Positive: Add managers_change_employees_address delegation
# ipa delegation-add managers_change_employees_address --membergroup=managers --group=employees --attrs=street,l,st,postalcode
#  Positive: As man0001 change all address attrs for emp0001
#  Positive: Su to man0002 and change address attrs for emp0002
#  Positive: Add employees_change_managers_phone delegation
# ipa delegation-add employees_change_managers_phone --membergroup=employees --group=managers --attrs=telephonenumber,mobile,pager,facsimiletelephonenumber
#  Positive: As emp0001 change all phone numbers for man0001
#  Positive: Su to emp0002 and change phone attrs for man0002
#  Negative: As man0001 fail to change phone numbers for emp0001
#  Negative: As emp0001 fail to change address attrs for emp0002
#  Negative: As man0001 fail to change rest of user attrs which should be disallowed
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
	ipa_delegation_cli_user_1001
	ipa_delegation_cli_user_1002
	ipa_delegation_cli_user_1003
	ipa_delegation_cli_user_1004
	ipa_delegation_cli_user_1005
	ipa_delegation_cli_user_1006
	ipa_delegation_cli_user_1007
	ipa_delegation_cli_user_1008
	ipa_delegation_cli_user_1009
	ipa_delegation_cli_user_1010
	ipa_delegation_cli_user_envcleanup
}

######################################################################
# SETUP
######################################################################
ipa_delegation_cli_user_envsetup()
{
	rlPhaseStartTest "ipa_delegation_cli_user_envsetup: "
		KinitAsAdmin
		create_ipauser man0001 Manager 0001 passw0rd1
		create_ipauser man0002 Manager 0002 passw0rd2
		create_ipauser emp0001 Employee 0001 passw0rd1
		create_ipauser emp0002 Employee 0002 passw0rd2
		ipa group-add --desc=managers managers
		ipa group-add --desc=employees employees
		ipa group-add-member managers --users=man0001,man0002
		ipa group-add-member employees --users=emp0001,emp0002
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
ipa_delegation_cli_user_envcleanup()
{
	rlPhaseStartTest "ipa_delegation_cli_user_envcleanup: "
		KinitAsAdmin
		ipa user-del man0001
		ipa user-del man0002
		ipa user-del emp0001
		ipa user-del emp0002
		ipa group-del managers
		ipa group-del employees
	rlPhaseEnd
}

######################################################################
# delegation user tests...
######################################################################
ipa_delegation_cli_user_1001()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1001: Fail to change attrs with no delegations for user"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Negative: As man0001 fail to change all user attrs
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1002()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1002: Add delegation for managers to change employees address attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: Add managers_change_employees_address delegation
		# ipa delegation-add managers_change_employees_address --membergroup=managers --group=employees --attrs=street,l,st,postalcode
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1003()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1003: Kinit as manager and change address attrs of employee"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: As man0001 change all address attrs for emp0001
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1004()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1004: Su to manager and change address attrs of employee"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: Su to man0002 and change address attrs for emp0002
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1005()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1005: Add delegation for employees to change managers phone attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: Add employees_change_managers_phone delegation
		# ipa delegation-add employees_change_managers_phone --membergroup=employees --group=managers --attrs=telephonenumber,mobile,pager,facsimiletelephonenumber
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1006()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1006: Kinit as employee and change phone attrs of manager"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: As emp0001 change all phone numbers for man0001
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1007()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1007: Su to employee and change phone attrs of manager"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: Su to emp0002 and change phone attrs for man0002
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1008()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1008: Kinit as manager and fail to change phone attrs for employee"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Negative: As man0001 fail to change all user attrs
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1009()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1009: Kinit as employee and fail to change address attrs for employee"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Negative: As man0001 fail to change all user attrs
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_user_1010()
{
	rlPhaseStartTest "ipa_delegation_cli_user_1010: Kinit as manager and fail to change other attrs for employee"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Negative: As man0001 fail to change rest of user attrs which should be disallowed
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

