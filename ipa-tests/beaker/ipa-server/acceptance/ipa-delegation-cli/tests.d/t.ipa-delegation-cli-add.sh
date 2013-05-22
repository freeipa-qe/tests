#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-add.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
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
#   delegation-add [positive]: 
######################################################################
delegation_add_positive()
{
	delegation_add_positive_envsetup
	delegation_add_positive_1001
	delegation_add_positive_1002
	delegation_add_positive_1003
	delegation_add_positive_1004
	delegation_add_positive_1005
	delegation_add_positive_envcleanup
}

delegation_add_positive_envsetup()
{
	rlPhaseStartSetup "delegation_add_positive_envsetup "
		KinitAsAdmin
		for i in $(seq 1001 1005); do
			rlRun "ipa group-add mg$i --desc=mg$i"
			rlRun "ipa group-add gr$i --desc=gr$i"
		done
	rlPhaseEnd
}

delegation_add_positive_envcleanup()
{
	rlPhaseStartCleanup "delegation_add_positive_envcleanup Cleanup add positive test settings"
		KinitAsAdmin
		for i in $(seq 1001 1005); do
			rlRun "ipa group-del mg$i"
			rlRun "ipa group-del gr$i"
			rlRun "ipa delegation-del delegation_add_positive_$i"
		done
	rlPhaseEnd
}

delegation_add_positive_1001()
{
	rlPhaseStartTest "ipa-delegation-add-positive-1001: add with no permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1001 --group=gr1001 --attrs=mobile"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_positive_1002()
{
	rlPhaseStartTest "ipa-delegation-add-positive-1002: add with permissions write"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1002 --group=gr1002 --attrs=mobile --permissions=write"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_positive_1003()
{
	rlPhaseStartTest "ipa-delegation-add-positive-1003: add with --all"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1003 --group=gr1003 --attrs=mobile --all"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_positive_1004()
{
	rlPhaseStartTest "ipa-delegation-add-positive-1004: add with --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1004 --group=gr1004 --attrs=mobile --raw"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_positive_1005()
{
	rlPhaseStartTest "ipa-delegation-add-positive-1005: add with --all --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1005 --group=gr1005 --attrs=mobile --all --raw"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


######################################################################
#   delegation-add [negative]:
######################################################################
delegation_add_negative()
{
	delegation_add_negative_envsetup
	delegation_add_negative_1001
	delegation_add_negative_1002
	delegation_add_negative_1003
	delegation_add_negative_1004
	delegation_add_negative_1005
	delegation_add_negative_1006
	delegation_add_negative_1007
	delegation_add_negative_1008
	delegation_add_negative_1009
	delegation_add_negative_1010
	delegation_add_negative_1011
	delegation_add_negative_1012
	delegation_add_negative_1013
	delegation_add_negative_1014
	delegation_add_negative_1015
	delegation_add_negative_1016
	delegation_add_negative_1017
	delegation_add_negative_1018
	delegation_add_negative_1019
	delegation_add_negative_envcleanup
}

delegation_add_negative_envsetup()
{
	rlPhaseStartSetup "delegation_add_negative_envsetup Setup add positive test dependencies"
		KinitAsAdmin
		for i in $(seq 1001 1019); do
			rlRun "ipa group-add mg$i --desc=mg$i"
			rlRun "ipa group-add gr$i --desc=gr$i"
		done
	rlPhaseEnd
}

delegation_add_negative_envcleanup()
{
	rlPhaseStartCleanup "delegation_add_negative_envcleanup Cleanup add negative test settings"
		KinitAsAdmin
		for i in $(seq 1001 1019); do
			rlRun "ipa group-del mg$i"
			rlRun "ipa group-del gr$i"
		done
		for i in $(ipa delegation-find|grep delegation_add_negative_ |awk '{print $3}'); do
			rlRun "ipa delegation-del $i"
		done
	rlPhaseEnd
}

######## delegation-add negative membergroup tests
delegation_add_negative_1001()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1001: fail on add with existing name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1001 --group=gr1001 --attrs=mobile"
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1001 --group=gr1001 --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: This entry already exists" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1002()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1002: add with empty name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add \"\" --membergroup=mg1002 --group=gr1002 --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'name' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1003()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1003: add with space for name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add \" \" --membergroup=mg1003 --group=gr1003 --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'name': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative membergroup tests
delegation_add_negative_1004()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1004: add with empty membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=\"\" --group=gr1004 --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'membergroup' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1005()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1005: add with space for membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=\" \" --group=gr1005 --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'membergroup': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1006() #BZ 783307 -- ipa delegation-add is not failing when membergroup does not exist
{
	rlPhaseStartTest "ipa-delegation-add-negative-1006: add with missing membergroup bz783307"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=badgroup --group=gr1006 --attrs=mobile > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: badgroup: group not found" $tmpout
		if [ $(egrep "Added delegation \"$FUNCNAME\"|badgroup" $tmpout|wc -l) -eq 2 ]; then	
			rlFail "BZ 783307 -- ipa delegation-add is not failing when membergroup does not exist"
			cat $tmpout
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative group tests
delegation_add_negative_1007()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1007: add with empty group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1007 --group=\"\" --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'group' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1008()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1008: add with space for group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1008 --group=\" \" --attrs=mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'group': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1009()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1009: add with missing group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1009 --group=badgroup --attrs=mobile > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: Group 'badgroup' does not exist" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative attrs tests
delegation_add_negative_1010()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1010: add with empty attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1010 --group=gr1010 --attrs=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'attrs' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1011()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1011: add with space for attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1011 --group=gr1011 --attrs=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'attrs' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1012()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1012: add with space comma for attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1012 --group=gr1012 --attrs=\" ,\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'attrs' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1013()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1013: add with only bad attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1013 --group=gr1013 --attrs=badattr > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: targetattr \"badattr\" does not exist in schema." $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1014()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1014: add with one bad attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1014 --group=gr1014 --attrs=badattr,mobile > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: targetattr \"badattr\" does not exist in schema." $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

######## delegation-add negative permissions tests
delegation_add_negative_1015()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1015: add with empty permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1015 --group=gr1015 --attrs=mobile --permissions=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'permissions' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1016()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1016: add with space for permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1016 --group=gr1016 --attrs=mobile --permissions=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'permissions' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1017()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1017: add with space comma for permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1017 --group=gr1017 --attrs=mobile --permissions=\" ,\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'permissions' is required" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1018()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1018: add with only invalid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1018 --group=gr1018 --attrs=mobile --permissions=badperm > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'permissions': \"badperm\" is not a valid permission" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_add_negative_1019()
{
	rlPhaseStartTest "ipa-delegation-add-negative-1019: add with one invalid permission"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add $FUNCNAME --membergroup=mg1019 --group=gr1019 --attrs=mobile --permissions=badperm,write > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'permissions': \"badperm\" is not a valid permission" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
