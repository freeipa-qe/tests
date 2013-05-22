#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-mod.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
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
#   delegation-mod [positive]:
######################################################################
delegation_mod_positive()
{
	delegation_mod_positive_envsetup
	delegation_mod_positive_1001
	delegation_mod_positive_1002
	delegation_mod_positive_1003
	delegation_mod_positive_1004
	delegation_mod_positive_1005
	delegation_mod_positive_1006
	delegation_mod_positive_1007
	delegation_mod_positive_1008
	delegation_mod_positive_1009
	delegation_mod_positive_1010
	delegation_mod_positive_envcleanup
}

delegation_mod_positive_envsetup()
{
	rlPhaseStartSetup "delegation_mod_positive_envsetup "
		KinitAsAdmin
		ipa group-add mg1000 --desc=mg1000
		ipa group-add gr1000 --desc=gr1000
		ipa group-add mg1001 --desc=mg1001
		ipa group-add gr1001 --desc=gr1001
		ipa delegation-add delegation_mod_positive_1000 --membergroup=mg1000 --group=gr1000 --attrs=mobile 
	rlPhaseEnd
}

delegation_mod_positive_envcleanup()
{
	rlPhaseStartCleanup "delegation_mod_positive_envcleanup "
		KinitAsAdmin
		ipa delegation-del delegation_mod_positive_1000
		ipa group-del mg1000
		ipa group-del gr1000
		ipa group-del mg1001
		ipa group-del gr1001
	rlPhaseEnd
}

delegation_mod_positive_1001()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1001: modify with existing membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --membergroup=mg1001 > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1002()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1002: modify with existing group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --group=gr1001 > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1003()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1003: modify with valid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --attrs=l > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1004()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1004: modify with valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --permissions=read > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1005()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1005: modify with existing membergroup and existing group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --membergroup=mg1000 --group=gr1000 > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1006()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1006: modify with existing membergroup, existing group, and valid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --membergroup=mg1001 --group=gr1001 --attrs=mobile  > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1007()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1007: modify with existing membergroup, existing group, valid attrs, and valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --membergroup=mg1000 --group=gr1000 --attrs=l --permission=write > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1008()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1008: modify with valid attrs and --all"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --attrs=mobile --all > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1009()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1009: modify with valid attrs and --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --attrs=l --raw > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_positive_1010()
{
	rlPhaseStartTest "ipa-delegation-mod-positive-1010: modify with valid attrs and --all --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_positive_1000 --attrs=mobile --all --raw > $tmpout 2>&1"
		rlAssertGrep "Modified delegation \"delegation_mod_positive_1000\"" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}



######################################################################
#   delegation-mod [negative]:
######################################################################
delegation_mod_negative()
{
	delegation_mod_negative_envsetup
	delegation_mod_negative_1001
	delegation_mod_negative_1002
	delegation_mod_negative_1003
	delegation_mod_negative_1004
	delegation_mod_negative_1005
	delegation_mod_negative_1006
	delegation_mod_negative_1007
	delegation_mod_negative_1008
	delegation_mod_negative_1009
	delegation_mod_negative_1010
	delegation_mod_negative_1011
	delegation_mod_negative_1012
	delegation_mod_negative_1013
	delegation_mod_negative_1014
	delegation_mod_negative_1015
	delegation_mod_negative_1016
	delegation_mod_negative_1017
	delegation_mod_negative_1018
	delegation_mod_negative_1019
	delegation_mod_negative_1020
	delegation_mod_negative_1021
	delegation_mod_negative_1022
	delegation_mod_negative_1023
	delegation_mod_negative_1024
	delegation_mod_negative_1025
	delegation_mod_negative_envcleanup
}


delegation_mod_negative_envsetup()
{
	rlPhaseStartSetup "delegation_mod_negative_envsetup "
		KinitAsAdmin
		ipa group-add mg1000 --desc=mg1000
		ipa group-add gr1000 --desc=gr1000
		ipa group-add mg1001 --desc=mg1001
		ipa group-add gr1001 --desc=gr1001
		ipa delegation-add delegation_mod_negative_1000 --membergroup=mg1000 --group=gr1000 --attrs=mobile 
	rlPhaseEnd
}

delegation_mod_negative_envcleanup()
{
	rlPhaseStartCleanup "delegation_mod_negative_envcleanup "
		KinitAsAdmin
		ipa delegation-del delegation_mod_negative_1000
		ipa group-del mg1000
		ipa group-del gr1000
		ipa group-del mg1001
		ipa group-del gr1001
	rlPhaseEnd
}

# BZ 783543 -- ipa delegation-mod --membergroup= returns internal error
delegation_mod_negative_1001()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1001: fail to modify with no value for membergroup bz783543"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup= > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'membergroup' is required" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783543 -- ipa delegation-mod --membergroup= returns internal error"
		fi

		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

# BZ 783543 -- ipa delegation-mod --membergroup= returns internal error
delegation_mod_negative_1002()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1002: fail to modify with empty membergroup bz783543"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'membergroup' is required" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783543 -- ipa delegation-mod --membergroup= returns internal error"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1003()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1003: fail to modify with space membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'membergroup': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

# BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist
delegation_mod_negative_1004()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1004: fail to modify with non-existent membergroup bz783548"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=badmemembergroup > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: badmemembergroup: group not found" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}


delegation_mod_negative_1005()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1005: fail to modify with no value for group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --group= > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'group' is required" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1006()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1006: fail to modify with empty group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --group=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'group' is required" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1007()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1007: fail to modify with space group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --group=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'group': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1008()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1008: fail to modify with non-existent group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --group=badgroup > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: Group 'badgroup' does not exist" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

# BZ 783554 -- ipa delegation-mod --attrs= removes Attributes from delegation instead of failing
delegation_mod_negative_1009()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1009: fail to modify with no value for attrs bz783554"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs= > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'attrs' is required" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783554 -- ipa delegation-mod --attrs= removes Attributes from delegation instead of failing"
			rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs=mobile" 0 "putting attrs back after BZ failure"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

# BZ 783554 -- ipa delegation-mod --attrs= removes Attributes from delegation instead of failing
delegation_mod_negative_1010()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1010: fail to modify with empty attrs bz783554"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'attrs' is required" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783554 -- ipa delegation-mod --attrs= removes Attributes from delegation instead of failing"
			rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs=mobile" 0 "putting attrs back after BZ failure"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

# BZ 783554 -- ipa delegation-mod --attrs= removes Attributes from delegation instead of failing
delegation_mod_negative_1011()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1011: fail to modify with space for attrs bz783554"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'attrs' is required" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783554 -- ipa delegation-mod --attrs= removes Attributes from delegation instead of failing"
			rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs=mobile" 0 "putting attrs back after BZ failure"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1012()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1012: fail to modify with invalid attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --attrs=badattr > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: targetattr \"badattr\" does not exist in schema." $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}


delegation_mod_negative_1013()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1013: fail to modify with no value for permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --permissions= > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'permissions' is required" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1014()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1014: fail to modify with empty permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --permissions=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'permissions' is required" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1015()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1015: fail to modify with space for permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --permissions=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'permissions' is required" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1016()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1016: fail to modify with invalid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --permissions=badperm > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'permissions': \"badperm\" is not a valid permission" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}



# BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist
delegation_mod_negative_1017()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1017: fail to modify with non-existent membergroup and existing group bz783548"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=badmemembergroup1017 --group=gr1001 > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: badmemembergroup1017: group not found" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1018()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1018: fail to modify with existing membergroup and non-existant group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=mg1001 --group=badgroup > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: Group 'badgroup' does not exist" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}


# BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist
delegation_mod_negative_1019()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1019: fail to modify with non-existent membergroup, existing group, and valid attrs bz783548"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=badmemembergroup1019 --group=gr1001 --attrs=l > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: badmemembergroup1019: group not found" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1020()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1020: fail to modify with existing membergroup, non-existant group, and valid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=mg1001 --group=badgroup --attrs=l > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: Group 'badgroup' does not exist" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1021()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1021: fail to modify with existing membergroup, existing group, and invalid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=mg1001 --group=gr1001 --attrs=badattr > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: targetattr \"badattr\" does not exist in schema." $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}


# BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist
delegation_mod_negative_1022()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1022: fail to modify with non-existent membergroup, existing group, valid attrs, and valid permissions bz783548"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=badmemembergroup1022 --group=gr1001 --attrs=l --permissions=read > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: badmemembergroup1022: group not found" $tmpout
		if [ $(egrep "Modified delegation \"delegation_mod_negative_1000\"" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783548 -- ipa delegation-mod is not failing when membergroup does not exist"
		fi
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1023()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1023: fail to modify with existing membergroup, non-existant group, valid attrs, and valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=mg1001 --group=badgroup --attrs=l --permissions=read > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: Group 'badgroup' does not exist" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1024()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1024: fail to modify with existing membergroup, existing group, invalid attrs, and valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=mg1001 --group=gr1001 --attrs=badattr --permissions=read > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: targetattr \"badattr\" does not exist in schema." $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

delegation_mod_negative_1025()
{
	rlPhaseStartTest "ipa-delegation-mod-negative-1025: fail to modify with existing membergroup, existing group, valid attrs, and invalid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-mod delegation_mod_negative_1000 --membergroup=mg1001 --group=gr1001 --attrs=l --permissions=badperm > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'permissions': \"badperm\" is not a valid permission" $tmpout
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}


