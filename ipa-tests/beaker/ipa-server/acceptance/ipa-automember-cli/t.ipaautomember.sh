#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipaautomember.sh of /CoreOS/ipa-tests/acceptance/ipa-automember-cli
#   Description: IPA automember CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  automember-add                   Add an automember rule.
#  automember-add-condition         Add conditions to an automember rule.
#  automember-default-group-remove  Remove default group for all unmatched entries.
#  automember-default-group-set     Set default group for all unmatched entries.
#  automember-default-group-show    Display information about the default automember groups.
#  automember-del                   Delete an automember rule.
#  automember-find                  Search for automember rules.
#  automember-mod                   Modify an automember rule.
#  automember-remove-condition      Remove conditions from an automember rule.
#  automember-show                  Display information about an automember rule.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following are the lib functions to use for testing: 
#       addAutomember                 <type> <name>
#       deleteAutomember              <type> <name>
#       findAutomember                <type> <name>
#       modifyAutomember              <type> <name> <attribute> <value>
#       verifyAutomemberAttr          <type> <name> <attribute> <value>
#       showAutomember                <type> <name>
#       addAutomemberCondition        <type> <name> <key> <regextype> <regex>
#       removeAutomemberCondition     <type> <name> <key> <regextype> <regex>
#       setAutomemberDefaultGroup     <type> <name>
#       removeAutomemberDefaultGroup  <type>
#       showAutomemberDefaultGroup    <type>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2011 Red Hat, Inc. All rights reserved.
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
ipaautomember()
{
	ipaautomember_setup

	ipaautomember_addAutomember_positive
	ipaautomember_addAutomember_negative

	ipaautomember_addAutomemberCondition_positive
	ipaautomember_addAutomemberCondition_negative_badgroup
	ipaautomember_addAutomemberCondition_negative_badtype
	ipaautomember_addAutomemberCondition_negative_badkey
	ipaautomember_addAutomemberCondition_negative_badregextype

	ipaautomember_findAutomember_positive
	ipaautomember_findAutomember_negative_badgroup
	ipaautomember_findAutomember_negative_badtype

	ipaautomember_showAutomember_positive
	ipaautomember_showAutomember_negative_badgroup
	ipaautomember_showAutomember_negative_badtype

	ipaautomember_modifyAutomember_positive
	ipaautomember_modifyAutomember_negative_sameval
	ipaautomember_modifyAutomember_negative_badgroup
	ipaautomember_modifyAutomember_negative_badtype
	ipaautomember_modifyAutomember_negative_badattr

	ipaautomember_verifyAutomemberAttr_positive
	ipaautomember_verifyAutomemberAttr_negative_badgroup
	ipaautomember_verifyAutomemberAttr_negative_badtype
	ipaautomember_verifyAutomemberAttr_negative_badattr
	ipaautomember_verifyAutomemberAttr_negative_badval

	ipaautomember_setAutomemberDefaultGroup_positive
	ipaautomember_setAutomemberDefaultGroup_negative_sameval
	ipaautomember_setAutomemberDefaultGroup_negative_badgroup
	ipaautomember_setAutomemberDefaultGroup_negative_badtype

	ipaautomember_showAutomemberDefaultGroup_positive
	ipaautomember_showAutomemberDefaultGroup_negative_badtype

	ipaautomember_removeAutomemberDefaultGroup_positive
	ipaautomember_removeAutomemberDefaultGroup_negative_badtype
	ipaautomember_removeAutomemberDefaultGroup_negative_nodefault

	ipaautomember_showAutomemberDefaultGroup_negative_nodefault

	ipaautomember_removeAutomemberCondition_negative_badregex
	ipaautomember_removeAutomemberCondition_positive
	ipaautomember_removeAutomemberCondition_negative_badgroup
	ipaautomember_removeAutomemberCondition_negative_badtype
	ipaautomember_removeAutomemberCondition_negative_badkey
	ipaautomember_removeAutomemberCondition_negative_badregextype

	ipaautomember_deleteAutomember_positive
	ipaautomember_deleteAutomember_negative_badgroup
	ipaautomember_deleteAutomember_negative_badtype

	ipaautomember_usertest_setup
	ipaautomember_usertest_positive_inclusive
	ipaautomember_usertest_cleanup

	ipaautomember_hosttest_setup
	ipaautomember_hosttest_positive_inclusive
	ipaautomember_hosttest_cleanup

	ipaautomember_cleanup
}

######################################################################
# SETUP
######################################################################
ipaautomember_setup()
{
	rlPhaseStartSetup 
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
		
		rlRun "addGroup \"Developers\" \"devel\""
		rlRun "addHostGroup \"QA Servers\" \"qaservers\""
		rlRun "addGroup \"Default Group\" \"defgroup\""
		rlRun "addHostGroup \"Default HostGroup\" \"defhostgroup\""
		
		rlRun "ipa user-add --first=Manager --last=John mjohn"
		rlRun "ipa user-add --first=Manager --last=Scott mscott"
	rlPhaseEnd
}

######################################################################
# addAutomember positive tests
######################################################################
ipaautomember_addAutomember_positive()
{
	desc="create rule for group"
	rlPhaseStartTest "ipa-automember-cli-1001: create rule for group"
		rlRun "addAutomember group devel" 0 "Verifying error code for $desc"
	rlPhaseEnd

	desc="create rule for hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1002: create rule for hostgroup"
		rlRun "addAutomember hostgroup qaservers" 0 "Verifying error code for $desc"
	rlPhaseEnd
}

######################################################################
# addAutomember negative tests
######################################################################
ipaautomember_addAutomember_negative()
{
	desc="create rule for non-existent group"
	rlPhaseStartTest "ipa-automember-cli-1101: create rule for non-existent group"
		rlRun "addAutomember group eng" 2 "Verify error code for $desc"
		command="ipa automember-add --type=group eng"
		expmsg="ipa: ERROR: Group: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message for $desc"
	rlPhaseEnd

	desc="create rule for non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1102: create rule for non-existent hostgroup"
		rlRun "addAutomember hostgroup engservers" 2 "Verify error code for $desc"
		command="ipa automember-add --type=hostgroup engservers"
		expmsg="ipa: ERROR: Group: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message for $desc"
	rlPhaseEnd

	desc="create rule for invalid type"
	rlPhaseStartTest "ipa-automember-cli-1103: create rule for invalid type"
		rlRun "addAutomember badtype devel" 1 "Verify error code for $desc"
		command="ipa automember-add --type=badtype devel"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="create rule for group that already exists "
	rlPhaseStartTest "ipa-automember-cli-1104: create rule for group that already exists "
		rlRun "addAutomember group devel" 1 "Verifying error code for $desc"
		command="ipa automember-add --type=group devel"
		expmsg="ipa: ERROR: auto_member_rule with name \"\" already exists"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="create rule for hostgroup that already exists"
	rlPhaseStartTest "ipa-automember-cli-1105: create rule for hostgroup that already exists"
		rlRun "addAutomember hostgroup qaservers" 1 "Verifying error code for $desc"
		command="ipa automember-add --type=hostgroup qaservers"
		expmsg="ipa: ERROR: auto_member_rule with name \"\" already exists"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# addAutomemberCondition positive tests
######################################################################
ipaautomember_addAutomemberCondition_positive()
{
	desc="add inclusive regex to group"
	rlPhaseStartTest "ipa-automember-cli-1201: add inclusive regex to group"
		rlRun "addAutomemberCondition group devel manager inclusive ^uid=mscott" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="add exclusive regex to group"
	rlPhaseStartTest "ipa-automember-cli-1202: add exclusive regex to group"
		rlRun "addAutomemberCondition group devel manager exclusive ^uid=mjohn" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="add inclusive regex to hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1203: add inclusive regex to hostgroup"
		rlRun "addAutomemberCondition hostgroup qaservers fqdn inclusive ^qa[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="add exclusive regex to hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1204: add exclusive regex to hostgroup"
		rlRun "addAutomemberCondition hostgroup qaservers fqdn exclusive ^eng[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# addAutomemberCondition negative tests for non-existent group
######################################################################
ipaautomember_addAutomemberCondition_negative_badgroup()
{
	desc="add inclusive regex to non-existent group"
	rlPhaseStartTest "ipa-automember-cli-1301: add inclusive regex to non-existent group"
		rlRun "addAutomemberCondition group eng manager inclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group eng --key=manager --inclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to non-existent group"
	rlPhaseStartTest "ipa-automember-cli-1302: add exclusive regex to non-existent group"
		rlRun "addAutomemberCondition group eng manager exclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group eng --key=manager --exclusive-regex=^uid=mscott"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add inclusive regex to non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1303: add inclusive regex to non-existent hostgroup"
		rlRun "addAutomemberCondition hostgroup engservers fqdn inclusive ^eng[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup engservers --key=fqdn --inclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: Auto member rule: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1304: add exclusive regex to non-existent hostgroup"
		rlRun "addAutomemberCondition hostgroup engservers fqdn exclusive ^qa[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup engservers --key=fqdn --exclusive-regex=^qa[0-9]+.example.com"
		expmsg="ipa: ERROR: Auto member rule: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# addAutomemberCondition negative tests for invalid type
######################################################################
ipaautomember_addAutomemberCondition_negative_badtype()
{
	desc="add inclusive regex to group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1401: add inclusive regex to group with invalid type"
		rlRun "addAutomemberCondition badtype devel manager inclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype devel --key=manager --inclusive-regex=^uid=mjohn"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1402: add exclusive regex to group with invalid type"
		rlRun "addAutomemberCondition badtype devel manager exclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype devel --key=manager --exclusive-regex=^uid=mjohn"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add inclusive regex to hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1403: add inclusive regex to hostgroup with invalid type"
		rlRun "addAutomemberCondition badtype qaservers fqdn inclusive ^qa[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype qaservers --key=fqdn --inclusive-regex=^qa[0-9]+.example.com"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1404: add exclusive regex to hostgroup with invalid type"
		rlRun "addAutomemberCondition badtype qaservers fqdn exclusive ^eng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype qaservers --key=fqdn --exclusive-regex=^eng[0-9]+.example.com"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# addAutomemberCondition negative tests for invalid key
######################################################################
ipaautomember_addAutomemberCondition_negative_badkey()
{
	desc="add inclusive regex to group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1501: add inclusive regex to group with invalid key"
		rlRun "addAutomemberCondition group devel badkey inclusive ^uid=mscott" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group devel --key=badkey --inclusive-regex=^uid=mscott"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1502: add exclusive regex to group with invalid key"
		rlRun "addAutomemberCondition group devel badkey exclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group devel --key=badkey --exclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add inclusive regex to hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1503: add inclusive regex to hostgroup with invalid key"
		rlRun "addAutomemberCondition hostgroup qaservers badkey inclusive ^qa[0-9]+\.example\.com" 2 \
			"Verify error code for add inclusive regex to hostgroup with invalid key"
		command="ipa automember-add-condition --type=hostgroup qaservers --key=badkey --inclusive-regex=^qa[0-9]+.example.com"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1504: add exclusive regex to hostgroup with invalid key"
		rlRun "addAutomemberCondition hostgroup qaservers badkey exclusive ^eng[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup qaservers --key=badkey --exclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# addAutomemberCondition negative tests for invalid regex type
######################################################################
ipaautomember_addAutomemberCondition_negative_badregextype()
{
	desc="add regex to group with invalid regextype"
	rlPhaseStartTest "ipa-automember-cli-1601: add regex to group with invalid regextype"
		rlRun "addAutomemberCondition group devel manager badregextype ^uid=mscott" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group devel --key=manager --badregextype-regex=^uid=mscott"
		expmsg="ipa: error: no such option: --badregextype-regex"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregextype 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregextype"
	rlPhaseEnd

	desc="add regex to hostgroup with invalid regextype"
	rlPhaseStartTest "ipa-automember-cli-1602: add regex to hostgroup with invalid regextype"
		rlRun "addAutomemberCondition hostgroup qaservers fqdn badregextype ^qa[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup qaservers --key=fqdn --badregextype-regex=^qa[0-9]+.example.com"
		expmsg="ipa: error: no such option: --badregextype-regex"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregextype 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregextype"
	rlPhaseEnd
}

######################################################################
# findAutomember positive tests
######################################################################
ipaautomember_findAutomember_positive()
{
	desc="find existing group rule"
	rlPhaseStartTest "ipa-automember-cli-1701: find existing group rule"
		rlRun "findAutomember group devel" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="find existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-1702: find existing hostgroup rule"
		rlRun "findAutomember hostgroup qaservers" 0 "Verify return code for $desc"
	rlPhaseEnd

}

######################################################################
# findAutomember negative tests for non-existent group
######################################################################
ipaautomember_findAutomember_negative_badgroup()
{
	desc="find non-existent group rule"
	rlPhaseStartTest "ipa-automember-cli-1801: find non-existent group rule"
		rlRun "findAutomember group eng" 1 "Verify error code for $desc"
		command="ipa automember-find --type=group eng"
		expmsg="0 rules matched"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badgroup 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badgroup"
	rlPhaseEnd

	desc="find non-existent hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-1802: find non-existent hostgroup rule"
		rlRun "findAutomember hostgroup engservers" 1 "Verify error code for $desc"
		command="ipa automember-find --type=hostgroup engservers"
		expmsg="0 rules matched"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badgroup 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badgroup"
	rlPhaseEnd
}

######################################################################
# findAutomember negative tests for invalid type
######################################################################
ipaautomember_findAutomember_negative_badtype()
{
	desc="find existing group rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1901: find existing group rule with invalid type"
		rlRun "findAutomember group eng" 1 "Verify error code for $desc"
		command="ipa automember-find --type=badtype devel"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="find existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1902: find existing hostgroup rule with invalid type"
		rlRun "findAutomember hostgroup engservers" 1 "Verify error code for $desc"
		command="ipa automember-find --type=badtype engservers"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomember positive tests
######################################################################
ipaautomember_showAutomember_positive()
{
	desc="show existing group rule"
	rlPhaseStartTest "ipa-automember-cli-2001: show existing group rule"
		rlRun "showAutomember group devel" 0 "Verify return code for $desc"
	rlPhaseEnd
	
	desc="show existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2002: show existing hostgroup rule"
		rlRun "showAutomember hostgroup qaservers" 0 "Verify return code for $desc"
	rlPhaseEnd
	
}

######################################################################
# showAutomember negative tests for non-existent group
######################################################################
ipaautomember_showAutomember_negative_badgroup()
{
	desc="show non-existent group rule"
	rlPhaseStartTest "ipa-automember-cli-2101: show non-existent group rule"
		rlRun "showAutomember group eng" 2 "Verify error code for $desc"
		command="ipa automember-show --type=group eng"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="show non-existent hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2102: show non-existent hostgroup rule"
		rlRun "showAutomember hostgroup engservers" 2 "Verify error code for $desc"
		command="ipa automember-show --type=hostgroup engservers"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomember negative tests for invalid type
######################################################################
ipaautomember_showAutomember_negative_badtype()
{
	desc="show existing group rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-2201: show existing group rule with invalid type"
		rlRun "showAutomember badtype devel" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype devel"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="show existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-2202: show existing hostgroup rule with invalid type"
		rlRun "showAutomember badtype engservers" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype qaservers"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember positive tests
######################################################################
ipaautomember_modifyAutomember_positive()
{
	desc="modify existing group rule"
	rlPhaseStartTest "ipa-automember-cli-2301: modify existing group rule"
		rlRun "modifyAutomember group devel desc \"DEV_USERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
	
	desc="modify existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2302: modify existing hostgroup rule"
		rlRun "modifyAutomember hostgroup qaservers desc \"WEB_SERVERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember negative tests for same value
######################################################################
ipaautomember_modifyAutomember_negative_sameval()
{
	desc="modify existing group rule with same value"
	rlPhaseStartTest "ipa-automember-cli-2401: modify existing group rule with same value"
		rlRun "modifyAutomember group devel desc \"DEV_USERS\"" 1 "Verify return code for $desc"
		command="ipa automember-mod --type=group devel --desc=\"DEV_USERS\""
		expmsg="ipa: ERROR: no modifications to be performed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="modify existing hostgroup rule with same value"
	rlPhaseStartTest "ipa-automember-cli-2402: modify existing hostgroup rule with same value"
		rlRun "modifyAutomember hostgroup qaservers desc \"WEB_SERVERS\"" 1 "Verify return code for $desc"
		command="ipa automember-mod --type=hostgroup qaservers --desc=\"WEB_SERVERS\""
		expmsg="ipa: ERROR: no modifications to be performed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember negative tests for non-existent group
######################################################################
ipaautomember_modifyAutomember_negative_badgroup()
{
	desc="modify existing group rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2501: modify existing group rule with non-existent group"
		rlRun "modifyAutomember group eng desc \"ENG_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=group eng --desc=\"ENG_USERS\""
		expmsg="ipa: ERROR: : auto_member_rule not found"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badgroup 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badgroup"
	rlPhaseEnd

	desc="modify existing hostgroup rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2502: modify existing hostgroup rule with non-existent group"
		rlRun "modifyAutomember hostgroup engservers desc \"ENG_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=hostgroup engservers --desc=\"ENG_SERVERS\""
		expmsg="ipa: ERROR: : auto_member_rule not found"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badgroup 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badgroup"
	rlPhaseEnd
}

######################################################################
# modifyAutomember negative tests for invalid type
######################################################################
ipaautomember_modifyAutomember_negative_badtype()
{
	desc="modify existing group rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-2601: modify existing group rule with invalid type"
		rlRun "modifyAutomember badtype devel desc \"DEV_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=badtype devel --desc=\"DEV_USERS\""
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="modify existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-2602: modify existing hostgroup rule with invalid type"
		rlRun "modifyAutomember badtype qaservers desc \"WEB_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=badtype qaservers --desc=\"WEB_SERVERS\""
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember negative tests for invalid attribute
######################################################################
ipaautomember_modifyAutomember_negative_badattr()
{
	desc="modify existing group rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-2701: modify existing group rule with invalid attribute"
		rlRun "modifyAutomember group devel name \"DEV_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --type=group devel --name=\"DEV_USERS\""
		expmsg="ipa: error: no such option: --name"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badattr 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badattr"
	rlPhaseEnd

	desc="modify existing hostgroup rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-2702: modify existing hostgroup rule with invalid attribute"
		rlRun "modifyAutomember hostgroup qaservers name \"WEB_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --type=hostgroup qaservers --name=\"WEB_SERVERS\""
		expmsg="ipa: error: no such option: --name"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badattr 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badattr"
	rlPhaseEnd
}

######################################################################
# verifyAutomemberAttr positive tests
######################################################################
ipaautomember_verifyAutomemberAttr_positive()
{
	desc="verify existing group rule"
	rlPhaseStartTest "ipa-automember-cli-2801: verify existing group rule"
		rlRun "verifyAutomemberAttr group devel Description \"DEV_USERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
	
	desc="verify existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2802: verify existing hostgroup rule"
		rlRun "verifyAutomemberAttr hostgroup qaservers Description \"WEB_SERVERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# verifyAutomember negative tests for non-existent group
######################################################################
ipaautomember_verifyAutomemberAttr_negative_badgroup()
{
	desc="verify existing group rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2901: verify existing group rule with non-existent group"
		rlRun "verifyAutomemberAttr group eng Description ENG_USERS" 2 "Verify error code for $desc"
		command="ipa automember-show --type=group eng"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="verify existing hostgroup rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2902: verify existing hostgroup rule with non-existent group"
		rlRun "verifyAutomemberAttr hostgroup engservers Description ENG_SERVERS" 2 "Verify error code for $desc"
		command="ipa automember-show --type=hostgroup engservers"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# verifyAutomemberAttr negative tests for invalid type
######################################################################
ipaautomember_verifyAutomemberAttr_negative_badtype()
{
	desc="verify existing group rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-3001: verify existing group rule with invalid type"
		rlRun "verifyAutomemberAttr badtype devel desc DEV_USERS" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype devel"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="verify existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-3002: verify existing hostgroup rule with invalid type"
		rlRun "verifyAutomemberAttr badtype qaservers desc WEB_SERVERS" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype qaservers"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# verifyAutomemberAttr negative tests for invalid attribute
######################################################################
ipaautomember_verifyAutomemberAttr_negative_badattr()
{
	desc="verify existing group rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-3101: verify existing group rule with invalid attribute"
		rlRun "verifyAutomemberAttr group devel badattr \"DEV_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=group devel" 
		expmsg="badattr"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badattr 2>&1" 0 "Verify error message for $desc"
		rlAssertNotGrep "$expmsg" "/tmp/ipaam_badattr"
	rlPhaseEnd

	desc="verify existing hostgroup rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-3102: verify existing hostgroup rule with invalid attribute"
		rlRun "verifyAutomemberAttr hostgroup qaservers badattr \"WEB_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=hostgroup qaservers" 
		expmsg="badattr"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badattr 2>&1" 0 "Verify error message for $desc"
		rlAssertNotGrep "$expmsg" "/tmp/ipaam_badattr"
	rlPhaseEnd
}

######################################################################
# verifyAutomemberAttr negative tests for incorrect value
######################################################################
ipaautomember_verifyAutomemberAttr_negative_badval()
{
	desc="verify existing group rule with incorrect value"
	rlPhaseStartTest "ipa-automember-cli-3201: verify existing group rule with incorrect value"
		rlRun "verifyAutomemberAttr group devel \"Automember Rule\" badval" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=group devel" 
		expmsg="Automember Rule: badval"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badval 2>&1" 0 "Verify error message for $desc"
		rlAssertNotGrep "$expmsg" "/tmp/ipaam_badval"
	rlPhaseEnd

	desc="verify existing hostgroup rule with incorrect value"
	rlPhaseStartTest "ipa-automember-cli-3202: verify existing hostgroup rule with incorrect value"
		rlRun "verifyAutomemberAttr hostgroup qaservers \"Automember Rule\" badval" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=hostgroup qaservers"
		expmsg="Automember Rule: badval"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badval 2>&1" 0 "Verify error message for $desc"
		rlAssertNotGrep "$expmsg" "/tmp/ipaam_badval"
	rlPhaseEnd
}

######################################################################
# setAutomemberDefaultGroup positive tests
######################################################################
ipaautomember_setAutomemberDefaultGroup_positive()
{
	desc="set default group"
	rlPhaseStartTest "ipa-automember-cli-3301: set default group"
		rlRun "setAutomemberDefaultGroup group defgroup" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="set default hostgroup"
	rlPhaseStartTest "ipa-automember-cli-3302: set default hostgroup"
		rlRun "setAutomemberDefaultGroup hostgroup defhostgroup" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# setAutomemberDefaultGroup negative tests for same value
######################################################################
ipaautomember_setAutomemberDefaultGroup_negative_sameval()
{
	desc="set default group with same value"
	rlPhaseStartTest "ipa-automember-cli-3401: set default group with same value"
		rlRun "setAutomemberDefaultGroup group defgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=group --default-group=defgroup"
		expmsg="ipa: ERROR: no modifications to be performed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="set default hostgroup with same value"
	rlPhaseStartTest "ipa-automember-cli-3402: set default hostgroup with same value"
		rlRun "setAutomemberDefaultGroup hostgroup defhostgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=hostgroup --default-group=defhostgroup"
		expmsg="ipa: ERROR: no modifications to be performed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# setAutomemberDefaultGroup negative tests for non-existant group
######################################################################
ipaautomember_setAutomemberDefaultGroup_negative_badgroup()
{
	desc="set default group with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-3501: set default group with non-existent group"
		rlRun "setAutomemberDefaultGroup group badgroup" 2 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=group --default-group=badgroup"
		expmsg="ipa: ERROR: Group: badgroup not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="set default hostgroup with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-3502: set default hostgroup with non-existent group"
		rlRun "setAutomemberDefaultGroup hostgroup badhostgroup" 2 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=hostgroup --default-group=badhostgroup"
		expmsg="ipa: ERROR: Group: badhostgroup not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# setAutomemberDefaultGroup negative tests for invalid type
######################################################################
ipaautomember_setAutomemberDefaultGroup_negative_badtype()
{
	desc="set default group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-3601: set default group with invalid type"
		rlRun "setAutomemberDefaultGroup badtype defgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=badtype --default-group=defgroup"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="set default hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-3602: set default hostgroup with invalid type"
		rlRun "setAutomemberDefaultGroup badtype defhostgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=badtype --default-group=defhostgroup"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomemberDefaultGroup positive tests
######################################################################
ipaautomember_showAutomemberDefaultGroup_positive()
{
	desc="show default group"
	rlPhaseStartTest "ipa-automember-cli-3701: show default group"
		rlRun "showAutomemberDefaultGroup group" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="show default hostgroup"
	rlPhaseStartTest "ipa-automember-cli-3702: show default hostgroup"
		rlRun "showAutomemberDefaultGroup hostgroup" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomemberDefaultGroup negative tests for invalid type
######################################################################
ipaautomember_showAutomemberDefaultGroup_negative_badtype()
{
	desc="show default group for invalid type"
	rlPhaseStartTest "ipa-automember-cli-3801: show default group for invalid type"
		rlRun "showAutomemberDefaultGroup badtype" 1 "Verify error code for $desc"
		command="ipa automember-default-group-show --type=badtype"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberDefaultGroup positive tests
######################################################################
ipaautomember_removeAutomemberDefaultGroup_positive()
{
	desc="remove default group"
	rlPhaseStartTest "ipa-automember-cli-3901: remove default group"
		rlRun "removeAutomemberDefaultGroup group" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="remove default hostgroup"
	rlPhaseStartTest "ipa-automember-cli-3902: remove default hostgroup"
		rlRun "removeAutomemberDefaultGroup hostgroup" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberDefaultGroup negative tests for invalid type
######################################################################
ipaautomember_removeAutomemberDefaultGroup_negative_badtype()
{
	desc="remove default group for invalid type"
	rlPhaseStartTest "ipa-automember-cli-4001: remove default group for invalid type"
		rlRun "removeAutomemberDefaultGroup badtype" 1 "Verify error code for $desc"
		command="ipa automember-default-group-remove --type=badtype"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberDefaultGroup negative tests for no default group
######################################################################
ipaautomember_removeAutomemberDefaultGroup_negative_nodefault()
{
        expmsg="ipa: ERROR: No default (fallback) group set"
	desc="remove default group for no default"
	rlPhaseStartTest "ipa-automember-cli-4101: remove default group for no default"
		rlRun "removeAutomemberDefaultGroup group" 2 "Verify return code for $desc"
		command="ipa automember-default-group-remove --type=group"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove default hostgroup for no default"
	rlPhaseStartTest "ipa-automember-cli-4102: remove default hostgroup for no default"
		rlRun "removeAutomemberDefaultGroup hostgroup" 2 "Verify return code for $desc"
		command="ipa automember-default-group-remove --type=hostgroup"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}	

######################################################################
# showAutomemberDefaultGroup negative tests Part 2 for no default group
######################################################################
ipaautomember_showAutomemberDefaultGroup_negative_nodefault()
{
        expmsg="  Default (fallback) Group: No default (fallback) group set"
	desc="show default group for no default"
	rlPhaseStartTest "ipa-automember-cli-4201: show default group for no default"
		rlRun "showAutomemberDefaultGroup group" 0 "Verify return code for $desc"
		command="ipa automember-default-group-show --type=group"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_nodefault 2>&1" 0 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_nodefault"
	rlPhaseEnd

	desc="show default hostgroup for no default"
	rlPhaseStartTest "ipa-automember-cli-4202: show default hostgroup for no default"
		rlRun "showAutomemberDefaultGroup hostgroup" 0 "Verify return code for $desc"
		command="ipa automember-default-group-show --type=hostgroup"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_nodefault 2>&1" 0 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_nodefault"
	rlPhaseEnd
}	

######################################################################
# removeAutomemberCondition positive
######################################################################
ipaautomember_removeAutomemberCondition_positive()
{
	desc="remove group inclusive regex"
	rlPhaseStartTest "ipa-automember-cli-4301: remove group inclusive regex"
		rlRun "removeAutomemberCondition group devel manager inclusive ^uid=mscott" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="remove group exclusive regex"
	rlPhaseStartTest "ipa-automember-cli-4302: remove group exclusive regex"
		rlRun "removeAutomemberCondition group devel manager exclusive ^uid=mjohn" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="remove hostgroup inclusive regex"
	rlPhaseStartTest "ipa-automember-cli-4303: remove hostgroup inclusive regex"
		rlRun "removeAutomemberCondition hostgroup qaservers fqdn inclusive ^qa[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="remove hostgroup exclusive regex"
	rlPhaseStartTest "ipa-automember-cli-4304: remove hostgroup exclusive regex"
		rlRun "removeAutomemberCondition hostgroup qaservers fqdn exclusive ^eng[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberCondition negative tests for non-existent group
######################################################################
ipaautomember_removeAutomemberCondition_negative_badgroup()
{
	desc="remove inclusive regex for non-existent group"
	rlPhaseStartTest "ipa-automember-cli-4401: remove inclusive regex for non-existent group"
		rlRun "removeAutomemberCondition group eng manager inclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group eng --key=manager --inclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex for non-existent group"
	rlPhaseStartTest "ipa-automember-cli-4402: remove exclusive regex for non-existent group"
		rlRun "removeAutomemberCondition group eng manager exclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group eng --key=manager --exclusive-regex=^uid=mscott"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove inclusive regex for non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-4403: remove inclusive regex for non-existent hostgroup"
		rlRun "removeAutomemberCondition hostgroup engservers fqdn inclusive ^eng[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup engservers --key=fqdn --inclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: Auto member rule: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex for non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-4404: remove exclusive regex for non-existent hostgroup"
		rlRun "removeAutomemberCondition hostgroup engservers fqdn exclusive ^qa[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup engservers --key=fqdn --exclusive-regex=^qa[0-9]+.example.com"
		expmsg="ipa: ERROR: Auto member rule: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# removeAutomemberCondition negative tests for invalid type
######################################################################
ipaautomember_removeAutomemberCondition_negative_badtype()
{
	desc="remove inclusive regex from group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4501: remove inclusive regex from group with invalid type"
		rlRun "removeAutomemberCondition badtype devel manager inclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype devel --key=manager --inclusive-regex=^uid=mjohn"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex from group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4502: remove exclusive regex from group with invalid type"
		rlRun "removeAutomemberCondition badtype devel manager exclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype devel --key=manager --exclusive-regex=^uid=mjohn"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove inclusive regex from hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4503: remove inclusive regex from hostgroup with invalid type"
		rlRun "removeAutomemberCondition badtype qaservers fqdn inclusive ^qa[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype qaservers --key=fqdn --inclusive-regex=^qa[0-9]+.example.com"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex from hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4504: remove exclusive regex from hostgroup with invalid type"
		rlRun "removeAutomemberCondition badtype qaservers fqdn exclusive ^eng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype qaservers --key=fqdn --exclusive-regex=^eng[0-9]+.example.com"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# removeAutomemberCondition negative tests for invalid key
######################################################################
ipaautomember_removeAutomemberCondition_negative_badkey()
{
	desc="remove inclusive regex from group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4601: remove inclusive regex from group with invalid key"
		rlRun "removeAutomemberCondition group devel badkey inclusive ^uid=mscott" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=badkey --inclusive-regex=^uid=mscott"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd

	desc="remove exclusive regex from group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4602: remove exclusive regex from group with invalid key"
		rlRun "removeAutomemberCondition group devel badkey exclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=badkey --exclusive-regex=^uid=mjohn"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd

	desc="remove inclusive regex from hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4603: remove inclusive regex from hostgroup with invalid key"
		rlRun "removeAutomemberCondition hostgroup qaservers badkey inclusive ^qa[0-9]+\.example\.com" 1 \
			"Verify error code for remove inclusive regex to hostgroup with invalid key"
		command="ipa automember-remove-condition --type=hostgroup qaservers --key=badkey --inclusive-regex=^qa[0-9]+.example.com"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd

	desc="remove exclusive regex from hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4604: remove exclusive regex from hostgroup with invalid key"
		rlRun "removeAutomemberCondition hostgroup qaservers badkey exclusive ^eng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup qaservers --key=badkey --exclusive-regex=^eng[0-9]+.example.com"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd
}

######################################################################
# removeAutomemberCondition negative tests for invalid regex type
######################################################################
ipaautomember_removeAutomemberCondition_negative_badregextype()
{
	desc="remove regex from group with invalid regextype"
	rlPhaseStartTest "ipa-automember-cli-4701: remove regex from group with invalid regextype"
		rlRun "removeAutomemberCondition group devel manager badregextype ^uid=mscott" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=manager --badregextype-regex=^uid=mscott"
		expmsg="ipa: error: no such option: --badregextype-regex"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregextype 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregextype"
	rlPhaseEnd

	desc="remove regex from hostgroup with invalid regextype"
	rlPhaseStartTest "ipa-automember-cli-4702: remove regex from hostgroup with invalid regextype"
		rlRun "removeAutomemberCondition hostgroup qaservers fqdn badregextype ^qa[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup qaservers --key=fqdn --badregextype-regex=^qa[0-9]+.example.com"
		expmsg="ipa: error: no such option: --badregextype-regex"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregextype 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregextype"
	rlPhaseEnd
}

######################################################################
# removeAutomemberCondition negative tests for non-existent regex
######################################################################
ipaautomember_removeAutomemberCondition_negative_badregex()
{
	desc="remove group inclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4801: remove group inclusive regex for non-existent regex"
		rlRun "removeAutomemberCondition group devel manager inclusive ^uid=badmscott" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=manager --inclusive-regex=^uid=badmscott"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd

	desc="remove group exclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4802: remove group exclusive regex for non-existent regex"
		rlRun "removeAutomemberCondition group devel manager exclusive ^uid=badmjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=manager --exclusive-regex=^uid=badmjohn"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd

	desc="remove hostgroup inclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4803: remove hostgroup inclusive regex for non-existent regex"
		rlRun "removeAutomemberCondition hostgroup qaservers fqdn inclusive ^badqa[0-9]+\.example\.com" 1 \
			"Verify error code for remove inclusive regex to hostgroup with invalid key"
		command="ipa automember-remove-condition --type=hostgroup qaservers --key=fqdn --inclusive-regex=^badqa[0-9]+.example.com"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd

	desc="remove hostgroup exclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4804: remove hostgroup exclusive regex for non-existent regex"
		rlRun "removeAutomemberCondition hostgroup qaservers fqdn exclusive ^badeng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup qaservers --key=fqdn --exclusive-regex=^badeng[0-9]+.example.com"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd
}
	
######################################################################
# deleteAutomember positive tests
######################################################################
ipaautomember_deleteAutomember_positive()
{
	desc="delete existing group rule"
	rlPhaseStartTest "ipa-automember-cli-4901: delete existing group rule"
		rlRun "deleteAutomember group devel" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="delete existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-4902: delete existing hostgroup rule"
		rlRun "deleteAutomember hostgroup qaservers" 0 "Verify return code for $desc"
	rlPhaseEnd
}


######################################################################
# deleteAutomember negative tests for non-existent group rule
######################################################################
ipaautomember_deleteAutomember_negative_badgroup()
{
	rlPhaseStartTest "ipa-automember-cli-5001: delete existing hostgroup rule"
		rlRun "deleteAutomember group devel" 2 "Verify return code for $desc"
		command="ipa automember-del --type=group devel"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-5002: delete existing hostgroup rule"
		rlRun "deleteAutomember hostgroup qaservers" 2 "Verify return code for $desc"
		command="ipa automember-del --type=group qaservers"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# deleteAutomember negative tests for invalid type
######################################################################
ipaautomember_deleteAutomember_negative_badtype()
{
	desc="delete existing group rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-5101: delete existing group rule with invalid type"
		rlRun "deleteAutomember badtype devel" 1 "Verify return code for $desc"
		command="ipa automember-del --type=badtype devel"
		#expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		expmsg="ipa: ERROR: invalid 'type': must be one of 'group', 'hostgroup'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}


######################################################################
# user test setup
######################################################################
ipaautomember_usertest_setup()
{
	desc="Setup users/groups/rules for user tests"
	rlPhaseStartSetup "ipa-automember-usertest-1000: Setup users/groups/rules for user tests"
		rlRun "ipa group-add --desc=Developers dev"
		rlRun "ipa group-add --desc=Engineers  eng"
		rlRun "ipa group-add --desc=WebAdmins  web"
		rlRun "ipa group-add --desc=DBAdmins   db"

		rlRun "ipa group-add --desc=CorpGroup  corpgroup"

		rlRun "ipa user-add --first=Manager --last=Devel mdev"
		rlRun "ipa user-add --first=Manager --last=Eng   meng"
		rlRun "ipa user-add --first=Manager --last=Web   mweb"
		rlRun "ipa user-add --first=Manager --last=DB    mdb"

		rlRun "ipa automember-add --type=group --desc=Developers_AM_Rule dev"
		rlRun "ipa automember-add --type=group --desc=Engineers_AM_Rule  eng"
		rlRun "ipa automember-add --type=group --desc=WebAdmins_AM_Rule  web"
		rlRun "ipa automember-add --type=group --desc=DBAdmins_AM_Rule   db"

		rlRun "ipa automember-add-condition --type=group dev --key=manager --inclusive-regex=^uid=mdev"
		rlRun "ipa automember-add-condition --type=group dev --key=title --inclusive-regex=^tdev"
		rlRun "ipa automember-add-condition --type=group dev --key=manager --exclusive-regex=^uid=meng"
		rlRun "ipa automember-add-condition --type=group dev --key=title --exclusive-regex=^teng"

		rlRun "ipa automember-add-condition --type=group eng --key=manager --inclusive-regex=^uid=meng"
		rlRun "ipa automember-add-condition --type=group eng --key=title --inclusive-regex=^teng"
		rlRun "ipa automember-add-condition --type=group eng --key=manager --exclusive-regex=^uid=mweb"
		rlRun "ipa automember-add-condition --type=group eng --key=title --exclusive-regex=^tweb"

		rlRun "ipa automember-add-condition --type=group web --key=manager --inclusive-regex=^uid=mweb"
		rlRun "ipa automember-add-condition --type=group web --key=title --inclusive-regex=^tweb"
		rlRun "ipa automember-add-condition --type=group web --key=manager --exclusive-regex=^uid=mdb"
		rlRun "ipa automember-add-condition --type=group web --key=title --exclusive-regex=^tdb"

		rlRun "ipa automember-add-condition --type=group db --key=manager --inclusive-regex=^uid=mdb"
		rlRun "ipa automember-add-condition --type=group db --key=title --inclusive-regex=^tdb"
		rlRun "ipa automember-add-condition --type=group db --key=manager --exclusive-regex=^uid=mdev"
		rlRun "ipa automember-add-condition --type=group db --key=title --exclusive-regex=^tdev"

		rlRun "ipa automember-default-group-set --type=group --default-group=corpgroup"
	rlPhaseEnd
}


######################################################################
# user test quick function
######################################################################
userAddQuickTest() {
	name=$1
	manager=$2
	title=$3
	groups=$4
	realname="--first=Test --last=User"
	options=""

	if [ -n "$manager" -a "$manager" != "nomanager" ]; then	
		options="$options --manager=$manager"
	fi

	if [ -n "$title" -a "$title" != "notitle" ]; then
		options="$options --title=$title"
	fi

	rlRun "ipa user-add $realname $options $name >/dev/null 2>&1" 0 "adding $name with $options"
	for group in $(echo $groups|sed 's/,/ /'); do
		rlRun "ipa user-find --in-groups=$group $name >/dev/null 2>&1" 0 "verifying $name in $group"
	done
}

######################################################################
# user test positive inclusive tests
######################################################################
ipaautomember_usertest_positive_inclusive()
{
	desc="add tests match manager"
	rlPhaseStartTest "ipa-automember-usertest-1101: add tests match manager"
		userAddQuickTest user0001 mdev   notitle dev
		userAddQuickTest user0002 meng   notitle eng
		userAddQuickTest user0003 mweb   notitle web
		userAddQuickTest user0004 mdb    notitle db
	rlPhaseEnd

	desc="user add tests match title"
	rlPhaseStartTest "ipa-automember-usertest-1102: user add tests match title"
		userAddQuickTest user0005 nomanager tdev   dev
		userAddQuickTest user0006 nomanager teng   eng
		userAddQuickTest user0007 nomanager tweb   web
		userAddQuickTest user0008 nomanager tdb    db
	rlPhaseEnd

 	desc="user add tests match manager and title"
	rlPhaseStartTest "ipa-automember-usertest-1103: user add tests match manager and title"
		userAddQuickTest user0009 mdev   tdev   dev
		userAddQuickTest user0010 mdev   teng   eng
		userAddQuickTest user0011 mdev   tweb   dev,web
		userAddQuickTest user0012 mdev   tdb    dev

		userAddQuickTest user0013 meng   tdev   eng
		userAddQuickTest user0014 meng   teng   eng
		userAddQuickTest user0015 meng   tweb   web
		userAddQuickTest user0016 meng   tdb    eng,db

		userAddQuickTest user0017 mweb   tdev   web,dev
		userAddQuickTest user0018 mweb   teng   web
		userAddQuickTest user0019 mweb   tweb   web
		userAddQuickTest user0020 mweb   tdb    db

		userAddQuickTest user0021 mdb    tdev   dev
		userAddQuickTest user0022 mdb    teng   db,eng
		userAddQuickTest user0023 mdb    tweb   db
		userAddQuickTest user0024 mdb    tdb    db
	rlPhaseEnd
}

######################################################################
# user test cleanup
######################################################################
ipaautomember_usertest_cleanup()
{
	rlPhaseStartCleanup "ipa-automember-usertest-cleanup delete groups, users, rules"
		rlRun "ipa group-del dev"
		rlRun "ipa group-del eng"
		rlRun "ipa group-del web"
		rlRun "ipa group-del db"

		rlRun "ipa group-del corpgroup"

		for i in $(seq 1 24); do
			user=$(printf "user%.4d" $i)
			rlRun "ipa user-del $user"
		done

		rlRun "ipa user-del mdev"
		rlRun "ipa user-del meng"
		rlRun "ipa user-del mweb"
		rlRun "ipa user-del mdb"

		rlRun "ipa automember-del --type=group dev"
		rlRun "ipa automember-del --type=group eng"
		rlRun "ipa automember-del --type=group web"
		rlRun "ipa automember-del --type=group db"
	rlPhaseEnd
}

######################################################################
# host test setup
######################################################################
ipaautomember_hosttest_setup()
{
	desc="Setup hostgroups/rules for user tests"
	rlPhaseStartSetup "ipa-automember-hosttest-1000 Setup hostgroups/rules for user tests"
		rlRun "ipa hostgroup-add --desc=DevServers devservers"
		rlRun "ipa hostgroup-add --desc=EngServers engservers"
		rlRun "ipa hostgroup-add --desc=WebServers webservers"
		rlRun "ipa hostgroup-add --desc=DBAServers dbaservers"

		rlRun "ipa hostgroup-add --desc=CorpHostGroup corphostgroup"

		rlRun "ipa automember-add --type=hostgroup devservers"
		rlRun "ipa automember-add --type=hostgroup engservers"
		rlRun "ipa automember-add --type=hostgroup webservers"
		rlRun "ipa automember-add --type=hostgroup dbaservers"

		rlRun "ipa automember-add-condition --type=hostgroup devservers --key=description --inclusive-regex=dev"
		rlRun "ipa automember-add-condition --type=hostgroup devservers --key=fqdn        --inclusive-regex=^dev[0-9]+.testrelm"
		rlRun "ipa automember-add-condition --type=hostgroup devservers --key=description --exclusive-regex=eng"
		rlRun "ipa automember-add-condition --type=hostgroup devservers --key=fqdn        --exclusive-regex=^eng[0-9]+.testrelm"

		rlRun "ipa automember-add-condition --type=hostgroup engservers --key=description --inclusive-regex=eng"
		rlRun "ipa automember-add-condition --type=hostgroup engservers --key=fqdn        --inclusive-regex=^eng[0-9]+.testrelm"
		rlRun "ipa automember-add-condition --type=hostgroup engservers --key=description --exclusive-regex=web"
		rlRun "ipa automember-add-condition --type=hostgroup engservers --key=fqdn        --exclusive-regex=^web[0-9]+.testrelm"

		rlRun "ipa automember-add-condition --type=hostgroup webservers --key=description --inclusive-regex=web"
		rlRun "ipa automember-add-condition --type=hostgroup webservers --key=fqdn        --inclusive-regex=^web[0-9]+.testrelm"
		rlRun "ipa automember-add-condition --type=hostgroup webservers --key=description --exclusive-regex=dba"
		rlRun "ipa automember-add-condition --type=hostgroup webservers --key=fqdn        --exclusive-regex=^dba[0-9]+.testrelm"

		rlRun "ipa automember-add-condition --type=hostgroup dbaservers --key=description --inclusive-regex=dba"
		rlRun "ipa automember-add-condition --type=hostgroup dbaservers --key=fqdn        --inclusive-regex=^dba[0-9]+.testrelm"
		rlRun "ipa automember-add-condition --type=hostgroup dbaservers --key=description --exclusive-regex=dev"
		rlRun "ipa automember-add-condition --type=hostgroup dbaservers --key=fqdn        --exclusive-regex=^dev[0-9]+.testrelm"

		rlRun "ipa automember-default-group-set --type=hostgroup --default-group=corphostgroup"
	rlPhaseEnd
}

######################################################################
# host test quick function
######################################################################
hostAddQuickTest() {
	name=$1
	description="$2"
	hostgroups=$3
	options="--force"

	if [ -n "$description" -a "$description" != "nodescription" ]; then	
		options="$options --desc=\"$description\""
	fi

	rlRun "ipa host-add $options $name >/dev/null 2>&1" 0 "adding $name with $options"
	#rlRun "ipa host-add $options $name" 0 "adding $name with $options"
	for hostgroup in $(echo $hostgroups|sed 's/,/ /g'); do
		rlRun "ipa host-find --in-hostgroups=$hostgroup $name >/dev/null 2>&1" 0 "verifying $name in $hostgroup"
		#rlRun "ipa host-find --in-hostgroups=$hostgroup $name" 0 "verifying $name in $group"
	done
}

######################################################################
# host test positive inclusive tests
######################################################################
ipaautomember_hosttest_positive_inclusive()
{
	desc="add tests match description"
	rlPhaseStartTest "ipa-automember-hosttest-1101: add tests match description"
		hostAddQuickTest srv0001.testrelm dev devservers
		hostAddQuickTest srv0002.testrelm eng engservers
		hostAddQuickTest srv0003.testrelm web webservers
		hostAddQuickTest srv0004.testrelm dba dbaservers
	rlPhaseEnd

	desc="add tests match fqdn"
	rlPhaseStartTest "ipa-automember-hosttest-1102: add tests match fqdn"
		hostAddQuickTest dev0000.testrelm srv devservers
		hostAddQuickTest eng0000.testrelm srv engservers
		hostAddQuickTest web0000.testrelm srv webservers
		hostAddQuickTest dba0000.testrelm srv dbaservers
	rlPhaseEnd

	desc="host add tests match description and fqdn"
	rlPhaseStartTest "ipa-automember-hosttest-1103: host add tests match description and fqdn"
		hostAddQuickTest dev0001.testrelm dev devservers
		hostAddQuickTest dev0002.testrelm eng engservers
		hostAddQuickTest dev0003.testrelm web devservers,webservers
		hostAddQuickTest dev0004.testrelm dba devservers

		hostAddQuickTest eng0001.testrelm dev engservers
		hostAddQuickTest eng0002.testrelm eng engservers
		hostAddQuickTest eng0003.testrelm web webservers
		hostAddQuickTest eng0004.testrelm dba engservers,dbaservers

		hostAddQuickTest web0001.testrelm dev webservers,devservers
		hostAddQuickTest web0002.testrelm eng webservers
		hostAddQuickTest web0003.testrelm web webservers
		hostAddQuickTest web0004.testrelm dba dbaservers

		hostAddQuickTest dba0001.testrelm dev devservers
		hostAddQuickTest dba0002.testrelm eng dbaservers,engservers
		hostAddQuickTest dba0003.testrelm web dbaservers
		hostAddQuickTest dba0004.testrelm dba dbaservers
	rlPhaseEnd

}

######################################################################
# host test cleanup
######################################################################
ipaautomember_hosttest_cleanup()
{
	rlPhaseStartCleanup "ipa-automember-hostest-cleanup delete hosts, hostgroups, rules"

		for i in srv0001 srv0002 srv0003 srv0004; do
			rlRun "ipa host-del $i.testrelm"
		done

		for i in dev eng web dba; do
			for j in 0000 0001 0002 0003 0004; do
				rlRun "ipa host-del $i$j"
			done
		done

		rlRun "ipa automember-del --type=hostgroup devservers"
		rlRun "ipa automember-del --type=hostgroup engservers"
		rlRun "ipa automember-del --type=hostgroup webservers"
		rlRun "ipa automember-del --type=hostgroup dbaservers"

		rlRun "ipa hostgroup-del devservers"
		rlRun "ipa hostgroup-del engservers"
		rlRun "ipa hostgroup-del webservers"
		rlRun "ipa hostgroup-del dbaservers"
	
		rlRun "ipa hostgroup-del corphostgroup"
	
	rlPhaseEnd
}

######################################################################
# CLEANUP
######################################################################
ipaautomember_cleanup()
{
	rlPhaseStartCleanup 
		rlRun "deleteGroup devel" 0 "Deleting group devel"
		rlRun "deleteHostGroup qaservers" 0 "Deleting hostgroup webservers"
		rlRun "deleteGroup defgroup" 0 "Deleting group defgroup"
		rlRun "deleteHostGroup defhostgroup" 0 "Deleting hostgroup defhostgroup"
		rlRun "ipa user-del mscott"
		rlRun "ipa user-del mjohn"
		rlRun "kdestroy" 0 "Destroying admin credentials"
	rlPhaseEnd
}
