#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-delegation-cli-user.sh of /CoreOS/ipa-tests/acceptance/ipa-delegation-cli
#   Description: IPA delegation cli command acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa delegation cli user/functional testing needed:
#  delegation_user_envsetup: 
#  delegation_user_envcleanup: 
#  delegation_user_1001: Fail to change attrs with no delegations for user
#  delegation_user_1002: Add delegation for managers to change employees address attrs
#  delegation_user_1003: Kinit as man0001 and change address attrs of emp0001
#  delegation_user_1004: Su to man0002 and change address attrs of emp0002
#  delegation_user_1005: Add delegation for employees to change managers phone attrs
#  delegation_user_1006: Kinit as employee and change phone attrs of manager
#  delegation_user_1007: Su to emp0002 and change phone attrs of man0002
#  delegation_user_1008: Check emp0001's attribute settings
#  delegation_user_1009: Check emp0002's attribute settings
#  delegation_user_1010: Check man0001's attribute settings
#  delegation_user_1011: Check man0002's attribute settings
#  delegation_user_1012: Kinit as manager and fail to change phone attrs for employee
#  delegation_user_1013: Kinit as employee and fail to change address attrs for employee
#  delegation_user_1014: Kinit as manager and fail to change other attrs for employee
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
delegation_user()
{
	delegation_user_envsetup
	delegation_user_1001
	delegation_user_1002
	delegation_user_1003
	delegation_user_1004
	delegation_user_1005
	delegation_user_1006
	delegation_user_1007
	delegation_user_1008
	delegation_user_1009
	delegation_user_1010
	delegation_user_1011
	delegation_user_1012
	delegation_user_1013
	delegation_user_1014
	delegation_user_envcleanup
}

######################################################################
# SETUP
######################################################################
delegation_user_envsetup()
{
	rlPhaseStartSetup "delegation_user_envsetup "
		KinitAsAdmin
		create_ipauser man0001 Manager 0001 passw0rd1
		create_ipauser man0002 Manager 0002 passw0rd2
		create_ipauser emp0001 Employee 0001 passw0rd1
		create_ipauser emp0002 Employee 0002 passw0rd2
		KinitAsAdmin
		ipa group-add --desc=managers managers
		ipa group-add --desc=employees employees
		ipa group-add-member managers --users=man0001,man0002
		ipa group-add-member employees --users=emp0001,emp0002
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
delegation_user_envcleanup()
{
	rlPhaseStartCleanup "delegation_user_envcleanup "
		KinitAsAdmin
		ipa user-del man0001
		ipa user-del man0002
		ipa user-del emp0001
		ipa user-del emp0002
		ipa group-del managers
		ipa group-del employees
		ipa delegation-del addr_change
		ipa delegation-del phone_change
	rlPhaseEnd
}

######################################################################
# delegation user tests...
######################################################################
delegation_user_1001()
{
	rlPhaseStartTest "ipa-delegation-user-1001: Fail to change attrs with no delegations for user"
		KinitAsUser man0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-mod emp0001  --first=Bad"                      1 "Should not be able to set first for another user"
		rlRun "ipa user-mod emp0001  --last=User"                      1 "Should not be able to set last for another user"
		rlRun "ipa user-mod emp0001  --cn=baduser"                     1 "Should not be able to set cn for another user"
		rlRun "ipa user-mod emp0001  --displayname=baduser"            1 "Should not be able to set displayname for another user"
		rlRun "ipa user-mod emp0001  --initials=GU"                    1 "Should not be able to set initials for another user"
		rlRun "ipa user-mod emp0001  --gecos=baduser@bad.testrelm.com" 1 "Should not be able to set gecos for another user"
		rlRun "ipa user-mod emp0001  --shell=/bin/bash"                1 "Should not be able to set shell for another user"
		rlRun "ipa user-mod emp0001  --street=Bad_Steet_Rd"            1 "Should not be able to set street for another user"
		rlRun "ipa user-mod emp0001  --city=Bad_City"                  1 "Should not be able to set city for another user"
		rlRun "ipa user-mod emp0001  --state=Badstate"                 1 "Should not be able to set state for another user"
		rlRun "ipa user-mod emp0001  --postalcode=99999"               1 "Should not be able to set postalcode for another user"
		rlRun "ipa user-mod emp0001  --phone=999-999-9999"             1 "Should not be able to set phone for another user"
		rlRun "ipa user-mod emp0001  --mobile=999-999-9999"            1 "Should not be able to set mobile for another user"
		rlRun "ipa user-mod emp0001  --pager=999-999-9999"             1 "Should not be able to set pager for another user"
		rlRun "ipa user-mod emp0001  --fax=999-999-9999"               1 "Should not be able to set fax for another user"
		rlRun "ipa user-mod emp0001  --orgunit=bad-org"                1 "Should not be able to set orgunit for another user"
		rlRun "ipa user-mod emp0001  --title=bad_admin"                1 "Should not be able to set title for another user"
		rlRun "ipa user-mod emp0001  --manager=man0002"                1 "Should not be able to set manager for another user"
		rlRun "ipa user-mod emp0001  --carlicense=bad-9999"            1 "Should not be able to set carlicense for another user"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1002()
{
	rlPhaseStartTest "ipa-delegation-user-1002: Add delegation for managers to change employees address attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add addr_change --group=managers --membergroup=employees --attrs=street,l,st,postalcode" \
			0 "Add delegation to allow changing address attrs"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1003()
{
	rlPhaseStartTest "ipa-delegation-user-1003: Kinit as man0001 and change address attrs of emp0001"
		KinitAsUser man0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-mod emp0001  --street=Good_Steet_Rd1"
		rlRun "ipa user-mod emp0001  --city=Good_City1"
		rlRun "ipa user-mod emp0001  --state=Goodstate1"
		rlRun "ipa user-mod emp0001  --postalcode=33333-1"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1004()
{
	rlPhaseStartTest "ipa-delegation-user-1004: Su to man0002 and change address attrs of emp0002"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		#  Positive: Su to man0002 and change address attrs for emp0002
		rlRun "su - man0002 -c \"echo passw0rd2|kinit man0002; ipa user-mod emp0002 --street=Good_Steet_Rd2 --city=Good_City2 --state=Goodstate2 --postalcode=33333-2\" > $tmpout 2>&1" \
			0 "As man0002, attempt to change emp0002 address attrs"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1005()
{
	rlPhaseStartTest "ipa-delegation-user-1005: Add delegation for employees to change managers phone attrs"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa delegation-add phone_change --group=employees --membergroup=managers --attrs=telephonenumber,mobile,pager,facsimiletelephonenumber" \
			0 "Add delegation to allow changing phone attrs"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1006()
{
	rlPhaseStartTest "ipa-delegation-user-1006: Kinit as employee and change phone attrs of manager"
		KinitAsUser emp0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-mod man0001  --phone=333-333-3331"
		rlRun "ipa user-mod man0001  --mobile=333-333-3331"
		rlRun "ipa user-mod man0001  --pager=333-333-3331"
		rlRun "ipa user-mod man0001  --fax=333-333-3331"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1007()
{
	rlPhaseStartTest "ipa-delegation-user-1007: Su to emp0002 and change phone attrs of man0002"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - emp0002 -c \"echo passw0rd2|kinit emp0002; ipa user-mod man0002 --phone=333-333-3332 --mobile=333-333-3332 --pager=333-333-3332 --fax=333-333-3332\" > $tmpout 2>&1" \
			0 "As emp0002, attempt to change man0002 address attrs"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1008()
{
	rlPhaseStartTest "ipa-delegation-user-1008: Check emp0001's attribute settings"
		KinitAsUser emp0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-find emp0001  --street=Good_Steet_Rd1"
		rlRun "ipa user-find emp0001  --city=Good_City1"
		rlRun "ipa user-find emp0001  --state=Goodstate1"
		rlRun "ipa user-find emp0001  --postalcode=33333-1"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1009()
{
	rlPhaseStartTest "ipa-delegation-user-1009: Check emp0002's attribute settings"
		KinitAsUser emp0002 passw0rd2
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-find emp0002  --street=Good_Steet_Rd2"
		rlRun "ipa user-find emp0002  --city=Good_City2"
		rlRun "ipa user-find emp0002  --state=Goodstate2"
		rlRun "ipa user-find emp0002  --postalcode=33333-2"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1010()
{
	rlPhaseStartTest "ipa-delegation-user-1010: Check man0001's attribute settings"
		KinitAsUser man0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-find man0001  --phone=333-333-3331"
		rlRun "ipa user-find man0001  --mobile=333-333-3331"
		rlRun "ipa user-find man0001  --pager=333-333-3331"
		rlRun "ipa user-find man0001  --fax=333-333-3331"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1011()
{
	rlPhaseStartTest "ipa-delegation-user-1011: Check man0002's attribute settings"
		KinitAsUser man0002 passw0rd2
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-find man0002  --phone=333-333-3332"
		rlRun "ipa user-find man0002  --mobile=333-333-3332"
		rlRun "ipa user-find man0002  --pager=333-333-3332"
		rlRun "ipa user-find man0002  --fax=333-333-3332"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1012()
{
	rlPhaseStartTest "ipa-delegation-user-1012: Kinit as manager and fail to change phone attrs for employee"
		KinitAsUser man0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-mod emp0001  --phone=999-999-9991"  1 "man0001 should not be able to change emp0001's --phone"
		rlRun "ipa user-mod emp0001  --mobile=999-999-9991"  1 "man0001 should not be able to change emp0001's --mobile"
		rlRun "ipa user-mod emp0001  --pager=999-999-9991"  1 "man0001 should not be able to change emp0001's --pager"
		rlRun "ipa user-mod emp0001  --fax=999-999-9991"  1 "man0001 should not be able to change emp0001's --fax"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1013()
{
	rlPhaseStartTest "ipa-delegation-user-1013: Kinit as employee and fail to change address attrs for employee"
		KinitAsUser emp0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-mod emp0002  --street=Bad_Steet_Rd2" 1 "emp0001 should not be able to change emp0002's --street"
		rlRun "ipa user-mod emp0002  --city=Bad_City2" 1 "emp0001 should not be able to change emp0002's --city"
		rlRun "ipa user-mod emp0002  --state=Badstate2" 1 "emp0001 should not be able to change emp0002's --state"
		rlRun "ipa user-mod emp0002  --postalcode=99999-2" 1 "emp0001 should not be able to change emp0002's --postalcode"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

delegation_user_1014()
{
	rlPhaseStartTest "ipa-delegation-user-1014: Kinit as manager and fail to change other attrs for employee"
		KinitAsUser man0001 passw0rd1
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-mod emp0001  --first=Bad"                      1 "should not be able to set first for emp001"
		rlRun "ipa user-mod emp0001  --last=User"                      1 "man0001 should not be able to set last for emp001"
		rlRun "ipa user-mod emp0001  --cn=baduser"                     1 "man0001 should not be able to set cn for emp001"
		rlRun "ipa user-mod emp0001  --displayname=baduser"            1 "man0001 should not be able to set displayname for emp001"
		rlRun "ipa user-mod emp0001  --initials=GU"                    1 "man0001 should not be able to set initials for emp001"
		rlRun "ipa user-mod emp0001  --gecos=baduser@bad.testrelm.com" 1 "man0001 should not be able to set gecos for emp001"
		rlRun "ipa user-mod emp0001  --shell=/bin/bash"                1 "man0001 should not be able to set shell for emp001"
		rlRun "ipa user-mod emp0001  --phone=999-999-9999"             1 "man0001 should not be able to set phone for emp001"
		rlRun "ipa user-mod emp0001  --mobile=999-999-9999"            1 "man0001 should not be able to set mobile for emp001"
		rlRun "ipa user-mod emp0001  --pager=999-999-9999"             1 "man0001 should not be able to set pager for emp001"
		rlRun "ipa user-mod emp0001  --fax=999-999-9999"               1 "man0001 should not be able to set fax for emp001"
		rlRun "ipa user-mod emp0001  --orgunit=bad-org"                1 "man0001 should not be able to set orgunit for emp001"
		rlRun "ipa user-mod emp0001  --title=bad_admin"                1 "man0001 should not be able to set title for emp001"
		rlRun "ipa user-mod emp0001  --manager=man0002"                1 "man0001 should not be able to set manager for emp001"
		rlRun "ipa user-mod emp0001  --carlicense=bad-9999"            1 "man0001 should not be able to set carlicense for emp001"
		[ -f $tmpout ] && rm $tmpout
	rlPhaseEnd
}

