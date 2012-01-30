#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-find.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
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
#   delegation-find [positive]:
######################################################################
delegation_find_positive()
{
	delegation_find_positive_envsetup
	delegation_find_positive_1001
	delegation_find_positive_1002
	delegation_find_positive_1003
	delegation_find_positive_1004
	delegation_find_positive_1005
	delegation_find_positive_1006
	delegation_find_positive_1007
	delegation_find_positive_1008
	delegation_find_positive_1009
	delegation_find_positive_1010
	delegation_find_positive_1011
	delegation_find_positive_envcleanup
}

delegation_find_positive_envsetup()
{
	rlPhaseStartTest "delegation_find_positive_envsetup: "
		KinitAsAdmin
		ipa group-add mg1000 --desc=mg1000
		ipa group-add gr1000 --desc=gr1000
		ipa delegation-add delegation_find_positive_1000 --membergroup=mg1000 --group=gr1000 --attrs=mobile 
	rlPhaseEnd
}

delegation_find_positive_envcleanup()
{
	rlPhaseStartTest "delegation_find_positive_envcleanup: "
		KinitAsAdmin
		ipa delegation-del delegation_find_positive_1000 
		ipa group-del mg1000
		ipa group-del gr1000
	rlPhaseEnd
}

delegation_find_positive_1001()
{
	rlPhaseStartTest "delegation_find_positive_1001: find all with no criteria"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1002()
{
	rlPhaseStartTest "delegation_find_positive_1002: find by name criteria"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find delegation_find_positive_1000 > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1003()
{
	rlPhaseStartTest "delegation_find_positive_1003: find by partial name criteria"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find delegation_find > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1004()
{
	rlPhaseStartTest "delegation_find_positive_1004: find by name option"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --name=delegation_find_positive_1000 > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1005()
{
	rlPhaseStartTest "delegation_find_positive_1005: find by membergroup option"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1006()
{
	rlPhaseStartTest "delegation_find_positive_1006: find by group option"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --group=gr1000 > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1007()
{
	rlPhaseStartTest "delegation_find_positive_1007: find by permissions option"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --permissions=write > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1008()
{
	rlPhaseStartTest "delegation_find_positive_1008: find by attrs option"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --attrs=mobile > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1009()
{
	rlPhaseStartTest "delegation_find_positive_1009: find by membergroup and group options"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=gr1000  > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1010()
{
	rlPhaseStartTest "delegation_find_positive_1010: find by membergroup, group, and attrs options"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=gr1000 --attrs=mobile  > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1011()
{
	rlPhaseStartTest "delegation_find_positive_1011: find by membergroup, group, attrs, and permissions options"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=gr1000 --attrs=mobile --permissions=write > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1012()
{
	rlPhaseStartTest "delegation_find_positive_1012: find all with no criteria and --all"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --all > $tmpout 2>&1"
		rlAssertGrep "Delegation name:" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1013()
{
	rlPhaseStartTest "delegation_find_positive_1013: find all with no criteria and --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --raw > $tmpout 2>&1"
		rlAssertGrep "^1 delegation matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_positive_1014()
{
	rlPhaseStartTest "delegation_find_positive_1014: find all with no criteria and --all --raw"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --all --raw > $tmpout 2>&1"
		rlAssertGrep "aci.*delegation:delegation_find_positive_1000.*ldap" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


######################################################################
#   delegation-find [negative]:
######################################################################
delegation_find_negative()
{
	delegation_find_negative_envsetup
	delegation_find_negative_1001
	delegation_find_negative_1002
	delegation_find_negative_1003
	delegation_find_negative_1004
	delegation_find_negative_1005
	delegation_find_negative_1006
	delegation_find_negative_1007
	delegation_find_negative_1008
	delegation_find_negative_1009
	delegation_find_negative_1010
	delegation_find_negative_1011
	delegation_find_negative_1012
	delegation_find_negative_1013
	delegation_find_negative_1014
	delegation_find_negative_1015
	delegation_find_negative_1016
	delegation_find_negative_1017
	delegation_find_negative_1018
	delegation_find_negative_1019
	delegation_find_negative_1020
	delegation_find_negative_1021
	delegation_find_negative_1022
	delegation_find_negative_1023
	delegation_find_negative_1024
	delegation_find_negative_1025
	delegation_find_negative_1026
	delegation_find_negative_1027
	delegation_find_negative_1028
	delegation_find_negative_1029
	delegation_find_negative_1030
	delegation_find_negative_1031
	delegation_find_negative_1032
	delegation_find_negative_1033
	delegation_find_negative_envcleanup
}


delegation_find_negative_envsetup()
{
	rlPhaseStartTest "delegation_find_negative_envsetup: "
		KinitAsAdmin
		ipa group-add mg1000 --desc=mg1000
		ipa group-add gr1000 --desc=gr1000
		ipa delegation-add delegation_find_negative_1000 --membergroup=mg1000 --group=gr1000 --attrs=mobile 
	rlPhaseEnd
}

delegation_find_negative_envcleanup()
{
	rlPhaseStartTest "delegation_find_negative_envcleanup: "
		KinitAsAdmin
		ipa delegation-del delegation_find_negative_1000 
		ipa group-del mg1000
		ipa group-del gr1000
	rlPhaseEnd
}

delegation_find_negative_1001()
{
	rlPhaseStartTest "delegation_find_negative_1001: fail on find with space criteria"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find \" \" > $tmpout 2>&1 " 1
		rlAssertGrep "ipa: ERROR: invalid 'criteria': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1002()
{
	rlPhaseStartTest "delegation_find_negative_1002: fail on find with invalid name criteria"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find badname > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1003()
{
	rlPhaseStartTest "delegation_find_negative_1003: fail to find with no value for name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find '--name=' > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		ipa delegation-find --name= 
		echo "ERRORCODE RETURNED: $?"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1004()
{
	rlPhaseStartTest "delegation_find_negative_1004: fail to find with empty name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --name=\"\" > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout 
		ipa delegation-find --name="" 
		echo "ERRORCODE RETURNED: $?"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1005()
{
	rlPhaseStartTest "delegation_find_negative_1005: fail to find with space for name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --name=\" \" > $tmpout 2>&1 " 1
		rlAssertGrep "ipa: ERROR: invalid 'name': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1006()
{
	rlPhaseStartTest "delegation_find_negative_1006: fail to find with non-existent name"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --name=badname > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout 
	rlPhaseEnd
}


delegation_find_negative_1007() # BZ 783473 -- ipa delegation-find --membergroup= with no value returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1007: fail to find with no value for membergroup (BZ 783473)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup= > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783473 -- ipa delegation-find --membergroup= with no value returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1008() # BZ 783475 -- ipa delegation-find --membergroup="" returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1008: fail to find with empty membergroup (BZ 783475)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=\"\" > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783475 -- ipa delegation-find --membergroup=\"\" returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1009()
{
	rlPhaseStartTest "delegation_find_negative_1009: fail to find with space for membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=\" \" > $tmpout 2>&1 " 1
		rlAssertGrep "ipa: ERROR: invalid 'membergroup': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1010()
{
	rlPhaseStartTest "delegation_find_negative_1010: fail to find with non-existent membergroup"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		# COMMAND TO TEST
		rlRun "ipa delegation-find --membergroup=badmembergroup > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1011()
{
	rlPhaseStartTest "delegation_find_negative_1011: fail to find with no value for group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --group= > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1012()
{
	rlPhaseStartTest "delegation_find_negative_1012: fail to find with empty group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --group=\"\" > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1013()
{
	rlPhaseStartTest "delegation_find_negative_1013: fail to find with space for group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --group=\" \" > $tmpout 2>&1 " 1
		rlAssertGrep "ipa: ERROR: invalid 'group': Leading and trailing spaces are not allowed" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1014()
{
	rlPhaseStartTest "delegation_find_negative_1014: fail to find with non-existent group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --group=badgroup > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1015() # BZ 783489 -- ipa delegation-find --permissions= returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1015: fail to find with no value for permissions (BZ 783489)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --permissions= > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783489 -- ipa delegation-find --permissions= returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1016() # BZ 783489 -- ipa delegation-find --permissions= returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1016: fail to find with empty permissions (BZ 783489)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --permissions=\"\" > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783489 -- ipa delegation-find --permissions= returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1017() # BZ 783489 -- ipa delegation-find --permissions= returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1017: fail to find with space for permissions (BZ 783489)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --permissions=\" \" > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783489 -- ipa delegation-find --permissions= returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1018()
{
	rlPhaseStartTest "delegation_find_negative_1018: fail to find with only invalid permission"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --permissions=badperm > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1019()
{
	rlPhaseStartTest "delegation_find_negative_1019: fail to find with one invalid permission"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --permissions=badperm,write > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1020() # BZ 783501 -- ipa delegation-find --attrs= returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1020: fail to find with no value for attrs (BZ 783501)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --attrs= > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783501 -- ipa delegation-find --attrs= returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1021() # BZ 783501 -- ipa delegation-find --attrs= returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1021: fail to find with empty for attrs (BZ 783501)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --attrs=\"\" > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783501 -- ipa delegation-find --attrs= returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1022() # BZ 783501 -- ipa delegation-find --attrs= returns internal error
{
	rlPhaseStartTest "delegation_find_negative_1022: fail to find with space for attrs (BZ 783501)"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --attrs=\" \" > $tmpout 2>&1 " 1
		rlAssertGrep "NEEDERROR" $tmpout
		if [ $(egrep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 783501 -- ipa delegation-find --attrs= returns internal error"
		fi
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1023()
{
	rlPhaseStartTest "delegation_find_negative_1023: fail to find with only invalid attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --attrs=badattr > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1024()
{
	rlPhaseStartTest "delegation_find_negative_1024: fail to find with one invalid attr"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --attrs=badattr,mobile > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1025()
{
	rlPhaseStartTest "delegation_find_negative_1025: fail to find with non-existent membergroup and existing group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=badmg --group=gr1000  > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1026()
{
	rlPhaseStartTest "delegation_find_negative_1026: fail to find with existing membergroup and non-existent group"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=badgr  > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1027()
{
	rlPhaseStartTest "delegation_find_negative_1027: fail to find with non-existent membergroup, existing group, and valid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=badmg --group=gr1000 --attrs=mobile  > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1028()
{
	rlPhaseStartTest "delegation_find_negative_1028: fail to find with existing membergroup, non-existent group, and valid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=badgr --attrs=mobile  > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1029()
{
	rlPhaseStartTest "delegation_find_negative_1029: fail to find with existing membergroup, existing group, and invalid attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=gr1000 --attrs=badattr  > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


delegation_find_negative_1030()
{
	rlPhaseStartTest "delegation_find_negative_1030: fail to find with non-existent membergroup, existing group, valid attrs, and valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=badmg --group=gr1000 --attrs=mobile --permissions=write > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1031()
{
	rlPhaseStartTest "delegation_find_negative_1031: fail to find with existing membergroup, non-existent group, valid attrs, and valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=badgr --attrs=mobile --permissions=write > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1032()
{
	rlPhaseStartTest "delegation_find_negative_1032: fail to find with existing membergroup, existing group, invalid attrs, and valid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-find --membergroup=mg1000 --group=gr1000 --attrs=badattr --permissions=write > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_find_negative_1033()
{
	rlPhaseStartTest "delegation_find_negative_1033: fail to find with existing membergroup, existing group, valid attrs, and invalid permissions"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		# COMMAND TO TEST
		rlRun "ipa delegation-find --membergroup=mg1000 --group=gr1000 --attrs=mobile --permissions=badperm > $tmpout 2>&1 " 1
		rlAssertGrep "^0 delegations matched" $tmpout
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}
