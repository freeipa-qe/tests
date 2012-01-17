#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-cmd.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
#   Description: IPA delegation cli command acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa delegation cli commands need to be tested:
#   delegation-add [positive]: 
#     add with no permissions 
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS 
#     add with permissions write
#       NAME2 --membergroup=GROUP21 --group=GROUP22 --attrs=ATTRS --permissions=write
#     add with --all
#       NAME3 --membergroup=GROUP31 --group=GROUP32 --attrs=ATTRS --all
#     add with --raw
#       NAME4 --membergroup=GROUP41 --group=GROUP42 --attrs=ATTRS --raw
#     add with --all --raw
#       NAME5 --membergroup=GROUP51 --group=GROUP52 --attrs=ATTRS --all --raw
#
#   delegation-add [negative]:
#     add with existing name
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
#     add with empty name
#       "" --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
#     add with space for name
#       " " --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
#
#     add with empty membergroup
#       NAME1 --membergroup="" --group=GROUP12 --attrs=ATTRS
#     add with space for membergroup
#       NAME1 --membergroup=" " --group=GROUP12 --attrs=ATTRS
#     add with missing membergroup
#       NAME1 --membergroup=badgroup --group=GROUP12 --attrs=ATTRS
#
#     add with empty group
#       NAME1 --membergroup=GROUP11 --group="" --attrs=ATTRS
#     add with space for group
#       NAME1 --membergroup=GROUP11 --group=" " --attrs=ATTRS
#     add with missing group
#       NAME1 --membergroup=GROUP11 --group=badgroup --attrs=ATTRS
#
#     add with empty attrs
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=""
#     add with space for attrs
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=" "
#     add with space comma for attrs
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=" ,"
#     add with only bad attr
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=badattr
#     add with one bad attr
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=badattr,ATTRS
#
#     add with empty permissions
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=""
#     add with space for permissions
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=" "
#     add with space for permissions
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=" ,"
#     add with only invalid permissions
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=badperm
#     add with one invalid permission
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=badperm,write
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
ipa_delegation_cli_cmd()
{
	ipa_delegation_cli_cmd_envsetup
	ipa_delegation_cli_cmd_test
	ipa_delegation_cli_cmd_envcleanup
}

######################################################################
# SETUP
######################################################################
ipa_delegation_cli_cmd_envsetup()
{
	rlPhaseStartTest "ipa-delegation-cli-cmd-envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
ipa_delegation_cli_cmd_envcleanup()
{
	rlPhaseStartTest "ipa-delegation-cli-cmd-envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

######################################################################
# delegation cli tests...
######################################################################
ipa_delegation_cli_cmd_test()
{
	rlPhaseStartTest "ipa-delegation-cli-cmd-test: delegation cli command test"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
