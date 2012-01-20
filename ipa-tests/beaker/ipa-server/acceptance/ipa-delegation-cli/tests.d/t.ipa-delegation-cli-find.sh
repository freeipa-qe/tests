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


######################################################################
#   delegation-find [negative]:
######################################################################
delegation_find_negative()
{
	delegation_find_negative_envsetup
	delegation_find_negative_1001
	delegation_find_negative_envcleanup
}


delegation_find_negative_envsetup()
{
	rlPhaseStartTest "delegation_find_negative_envsetup: "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_find_negative_envcleanup()
{
	rlPhaseStartTest "delegation_find_negative_envcleanup: "
		KinitAsAdmin
	rlPhaseEnd
}

delegation_find_negative_1001()
{
	rlPhaseStartTest "delegation_find_negative_1001: fail to delete non-existent delegation"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
#       badname
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}


# ipa delegation-find " "
# ipa delegation-find BADNAME
# 
# ipa delegation-find --name=
# ipa delegation-find --name=""
# ipa delegation-find --name=" "
# ipa delegation-find --name=BADNAME
# 
# ipa delegation-find --membergroup=
# ipa delegation-find --membergroup=""
# ipa delegation-find --membergroup=" "
# ipa delegation-find --membergroup=BADMEMBERGROUP
# 
# ipa delegation-find --group=
# ipa delegation-find --group=""
# ipa delegation-find --group=" "
# ipa delegation-find --group=BADGROUP
# 
# ipa delegation-find --permissions=
# ipa delegation-find --permissions=""
# ipa delegation-find --permissions=" "
# ipa delegation-find --permissions=BADPERM
# ipa delegation-find --permissions=BADPERM,write
# 
# ipa delegation-find --attrs=
# ipa delegation-find --attrs=""
# ipa delegation-find --attrs=" "
# ipa delegation-find --attrs=BADATTR
# ipa delegation-find --attrs=BADATTR,mobile
# 
# ipa delegation-find --membergroup=BADMG --group=GR 
# ipa delegation-find --membergroup=MG --group=BADGR 
# 
# ipa delegation-find --membergroup=BADMG --group=GR --attrs=ATTRS 
# ipa delegation-find --membergroup=MG --group=BADGR --attrs=ATTRS 
# ipa delegation-find --membergroup=MG --group=GR --attrs=BADATTRS 
# 
# ipa delegation-find --membergroup=BADMG --group=GR --attrs=ATTRS --permissions=write
# ipa delegation-find --membergroup=MG --group=BADGR --attrs=ATTRS --permissions=write
# ipa delegation-find --membergroup=MG --group=GR --attrs=BADATTRS --permissions=write
# ipa delegation-find --membergroup=MG --group=GR --attrs=ATTRS --permissions=BADwrite
# 
