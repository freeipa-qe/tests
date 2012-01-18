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
	ipa_delegation_cli_cmd_add_positive
	ipa_delegation_cli_cmd_add_negative

	ipa_delegation_cli_cmd_del_positive
	ipa_delegation_cli_cmd_del_negative

	ipa_delegation_cli_cmd_find_positive
	ipa_delegation_cli_cmd_find_negative

	ipa_delegation_cli_cmd_mod_positive
	ipa_delegation_cli_cmd_mod_negative

	ipa_delegation_cli_cmd_show_positive
	ipa_delegation_cli_cmd_show_negative
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

######################################################################
#   delegation-add [positive]: 
######################################################################
ipa_delegation_cli_cmd_add_positive()
{
	ipa_delegation_cli_cmd_add_positive_envsetup
	ipa_delegation_cli_cmd_add_positive_1001
	ipa_delegation_cli_cmd_add_positive_1002
	ipa_delegation_cli_cmd_add_positive_1003
	ipa_delegation_cli_cmd_add_positive_1004
	ipa_delegation_cli_cmd_add_positive_1005
	ipa_delegation_cli_cmd_add_positive_envcleanup
}

ipa_delegation_cli_cmd_add_positive_envsetup()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_positive_1001()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_1001: add with no permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS 
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_positive_1002()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_1002: add with permissions write"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME2 --membergroup=GROUP21 --group=GROUP22 --attrs=ATTRS --permissions=write
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_positive_1003()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_1003: add with --all"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME3 --membergroup=GROUP31 --group=GROUP32 --attrs=ATTRS --all
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_positive_1004()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_1004: add with --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME4 --membergroup=GROUP41 --group=GROUP42 --attrs=ATTRS --raw
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_positive_1005()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_1005: add with --all --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME5 --membergroup=GROUP51 --group=GROUP52 --attrs=ATTRS --all --raw
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_positive_envcleanup()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_positive_envcleanup: Cleanup add positive test settings"
		KinitAsAdmin
	rlPhaseEnd
}


######################################################################
#   delegation-add [negative]:
######################################################################
ipa_delegation_cli_cmd_add_negative()
{
	ipa_delegation_cli_cmd_add_negative_envsetup
	ipa_delegation_cli_cmd_add_negative_1001
	ipa_delegation_cli_cmd_add_negative_1002
	ipa_delegation_cli_cmd_add_negative_1003
	ipa_delegation_cli_cmd_add_negative_1004
	ipa_delegation_cli_cmd_add_negative_1005
	ipa_delegation_cli_cmd_add_negative_1006
	ipa_delegation_cli_cmd_add_negative_1007
	ipa_delegation_cli_cmd_add_negative_1008
	ipa_delegation_cli_cmd_add_negative_1009
	ipa_delegation_cli_cmd_add_negative_1010
	ipa_delegation_cli_cmd_add_negative_1011
	ipa_delegation_cli_cmd_add_negative_1012
	ipa_delegation_cli_cmd_add_negative_1013
	ipa_delegation_cli_cmd_add_negative_1014
	ipa_delegation_cli_cmd_add_negative_1015
	ipa_delegation_cli_cmd_add_negative_1016
	ipa_delegation_cli_cmd_add_negative_1017
	ipa_delegation_cli_cmd_add_negative_1018
	ipa_delegation_cli_cmd_add_negative_1019
	ipa_delegation_cli_cmd_add_negative_envcleanup
}

######## delegation-add negative membergroup tests
ipa_delegation_cli_cmd_add_negative_1001()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1001: add with existing name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1002()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1002: add with empty name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       "" --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1003()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1003: add with space for name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       " " --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative membergroup tests
ipa_delegation_cli_cmd_add_negative_1004()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1004: add with empty membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup="" --group=GROUP12 --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1005()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1005: add with space for membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=" " --group=GROUP12 --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1006()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1006: add with missing membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=badgroup --group=GROUP12 --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative group tests
ipa_delegation_cli_cmd_add_negative_1007()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1007: add with empty group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group="" --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1008()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1008: add with space for group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=" " --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1009()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1009: add with missing group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=badgroup --attrs=ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative attrs tests
ipa_delegation_cli_cmd_add_negative_1010()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1010: add with empty attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=""
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1011()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1011: add with space for attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=" "
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1012()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1012: add with space comma for attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=" ,"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1013()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1013: add with only bad attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=badattr
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1014()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1014: add with one bad attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=badattr,ATTRS
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative permissions tests
ipa_delegation_cli_cmd_add_negative_1015()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1015: add with empty permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=""
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1016()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1016: add with space for permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=" "
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1017()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1017: add with space for permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=" ,"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1018()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1018: add with only invalid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=badperm
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

ipa_delegation_cli_cmd_add_negative_1019()
{
	rlPhaseStartTest "ipa_delegation_cli_cmd_add_negative_1019: add with one invalid permission"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       NAME1 --membergroup=GROUP11 --group=GROUP12 --attrs=ATTRS --permissions=badperm,write
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######################################################################
#   delegation-del [positive]:
######################################################################
ipa_delegation_cli_cmd_del_positive()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-del [negative]:
######################################################################
ipa_delegation_cli_cmd_del_negative()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-find [positive]:
######################################################################
ipa_delegation_cli_cmd_find_positive()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-find [negative]:
######################################################################
ipa_delegation_cli_cmd_find_negative()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-mod [positive]:
######################################################################
ipa_delegation_cli_cmd_mod_positive()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-mod [negative]:
######################################################################
ipa_delegation_cli_cmd_mod_negative()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-show [positive]:
######################################################################
ipa_delegation_cli_cmd_show_positive()
{
	echo $FUNCNAME
}

######################################################################
#   delegation-show [negative]:
######################################################################
ipa_delegation_cli_cmd_show_negative()
{
	echo $FUNCNAME
}

