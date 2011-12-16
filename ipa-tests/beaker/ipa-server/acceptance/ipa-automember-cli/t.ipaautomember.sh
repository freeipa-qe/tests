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

	ipaautomember_cleanup
}

######################################################################
# SETUP
######################################################################
ipaautomember_setup()
{
	rlPhaseStartTest "ipa-automember-cli-0000: initial setup, kinit, group/hostgroup adds, etc."
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
		
		rlRun "addGroup \"Developers\" \"devel\""
		rlRun "addHostGroup \"Web Servers\" \"webservers\""
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
	rlPhaseStartTest "ipa-automember-cli-1001: $desc"
		rlRun "addAutomember group devel" 0 "Verifying error code for $desc"
	rlPhaseEnd

	desc="create rule for hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1002: $desc"
		rlRun "addAutomember hostgroup webservers" 0 "Verifying error code for $desc"
	rlPhaseEnd
}

######################################################################
# addAutomember negative tests
######################################################################
ipaautomember_addAutomember_negative()
{
	desc="create rule for non-existent group"
	rlPhaseStartTest "ipa-automember-cli-1101: $desc"
		rlRun "addAutomember group eng" 2 "Verify error code for $desc"
		command="ipa automember-add --type=group eng"
		expmsg="ipa: ERROR: Group: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message for $desc"
	rlPhaseEnd

	desc="create rule for non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1102: $desc"
		rlRun "addAutomember hostgroup engservers" 2 "Verify error code for $desc"
		command="ipa automember-add --type=hostgroup engservers"
		expmsg="ipa: ERROR: Group: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message for $desc"
	rlPhaseEnd

	desc="create rule for invalid type"
	rlPhaseStartTest "ipa-automember-cli-1103: $desc"
		rlRun "addAutomember badtype devel" 1 "Verify error code for $desc"
		command="ipa automember-add --type=badtype devel"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="create rule for group that already exists "
	rlPhaseStartTest "ipa-automember-cli-1104: $desc"
		rlRun "addAutomember group devel" 1 "Verifying error code for $desc"
		command="ipa automember-add --type=group devel"
		expmsg="ipa: ERROR: auto_member_rule with name \"\" already exists"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="create rule for hostgroup that already exists"
	rlPhaseStartTest "ipa-automember-cli-1105: $desc"
		rlRun "addAutomember hostgroup webservers" 1 "Verifying error code for $desc"
		command="ipa automember-add --type=hostgroup webservers"
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
	rlPhaseStartTest "ipa-automember-cli-1201: $desc"
		rlRun "addAutomemberCondition group devel manager inclusive ^uid=mscott" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="add exclusive regex to group"
	rlPhaseStartTest "ipa-automember-cli-1202: $desc"
		rlRun "addAutomemberCondition group devel manager exclusive ^uid=mjohn" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="add inclusive regex to hostgroup"
	rlPhaseStartTest "ipa-automembet-cli-1203: $desc"
		rlRun "addAutomemberCondition hostgroup webservers fqdn inclusive ^web[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="add exclusive regex to hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1204: $desc"
		rlRun "addAutomemberCondition hostgroup webservers fqdn exclusive ^eng[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# addAutomemberCondition negative tests for non-existent group
######################################################################
ipaautomember_addAutomemberCondition_negative_badgroup()
{
	desc="add inclusive regex to non-existent group"
	rlPhaseStartTest "ipa-automember-cli-1301: $desc"
		rlRun "addAutomemberCondition group eng manager inclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group eng --key=manager --inclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to non-existent group"
	rlPhaseStartTest "ipa-automember-cli-1302: $desc"
		rlRun "addAutomemberCondition group eng manager exclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group eng --key=manager --exclusive-regex=^uid=mscott"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add inclusive regex to non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1303: $desc"
		rlRun "addAutomemberCondition hostgroup engservers fqdn inclusive ^eng[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup engservers --key=fqdn --inclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: Auto member rule: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1304: $desc"
		rlRun "addAutomemberCondition hostgroup engservers fqdn exclusive ^web[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup engservers --key=fqdn --exclusive-regex=^web[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-1401: $desc"
		rlRun "addAutomemberCondition badtype devel manager inclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype devel --key=manager --inclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1402: $desc"
		rlRun "addAutomemberCondition badtype devel manager exclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype devel --key=manager --exclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add inclusive regex to hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1403: $desc"
		rlRun "addAutomemberCondition badtype webservers fqdn inclusive ^web[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype webservers --key=fqdn --inclusive-regex=^web[0-9]+.example.com"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1404: $desc"
		rlRun "addAutomemberCondition badtype webservers fqdn exclusive ^eng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=badtype webservers --key=fqdn --exclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# addAutomemberCondition negative tests for invalid key
######################################################################
ipaautomember_addAutomemberCondition_negative_badkey()
{
	desc="add inclusive regex to group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1501: $desc"
		rlRun "addAutomemberCondition group devel badkey inclusive ^uid=mscott" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group devel --key=badkey --inclusive-regex=^uid=mscott"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1502: $desc"
		rlRun "addAutomemberCondition group devel badkey exclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group devel --key=badkey --exclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add inclusive regex to hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1503: $desc"
		rlRun "addAutomemberCondition hostgroup webservers badkey inclusive ^web[0-9]+\.example\.com" 2 \
			"Verify error code for add inclusive regex to hostgroup with invalid key"
		command="ipa automember-add-condition --type=hostgroup webservers --key=badkey --inclusive-regex=^web[0-9]+.example.com"
		expmsg="ipa: ERROR: badkey is not a valid attribute."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="add exclusive regex to hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-1504: $desc"
		rlRun "addAutomemberCondition hostgroup webservers badkey exclusive ^eng[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup webservers --key=badkey --exclusive-regex=^eng[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-1601: $desc"
		rlRun "addAutomemberCondition group devel manager badregextype ^uid=mscott" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=group devel --key=manager --badregextype-regex=^uid=mscott"
		expmsg="ipa: error: no such option: --badregextype-regex"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregextype 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregextype"
	rlPhaseEnd

	desc="add regex to hostgroup with invalid regextype"
	rlPhaseStartTest "ipa-automember-cli-1602: $desc"
		rlRun "addAutomemberCondition hostgroup webservers fqdn badregextype ^web[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-add-condition --type=hostgroup webservers --key=fqdn --badregextype-regex=^web[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-1701: $desc"
		rlRun "findAutomember group devel" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="find existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-1702: $desc"
		rlRun "findAutomember hostgroup webservers" 0 "Verify return code for $desc"
	rlPhaseEnd

}

######################################################################
# findAutomember negative tests for non-existent group
######################################################################
ipaautomember_findAutomember_negative_badgroup()
{
	desc="find non-existent group rule"
	rlPhaseStartTest "ipa-automember-cli-1801: $desc"
		rlRun "findAutomember group eng" 1 "Verify error code for $desc"
		command="ipa automember-find --type=group eng"
		expmsg="0 rules matched"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badgroup 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badgroup"
	rlPhaseEnd

	desc="find non-existent hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-1802: $desc"
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
	rlPhaseStartTest "ipa-automember-cli-1901: $desc"
		rlRun "findAutomember group eng" 1 "Verify error code for $desc"
		command="ipa automember-find --type=badtype devel"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="find existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-1902: $desc"
		rlRun "findAutomember hostgroup engservers" 1 "Verify error code for $desc"
		command="ipa automember-find --type=badtype engservers"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomember positive tests
######################################################################
ipaautomember_showAutomember_positive()
{
	desc="show existing group rule"
	rlPhaseStartTest "ipa-automember-cli-2001: $desc"
		rlRun "showAutomember group devel" 0 "Verify return code for $desc"
	rlPhaseEnd
	
	desc="show existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2002: $desc"
		rlRun "showAutomember hostgroup webservers" 0 "Verify return code for $desc"
	rlPhaseEnd
	
}

######################################################################
# showAutomember negative tests for non-existent group
######################################################################
ipaautomember_showAutomember_negative_badgroup()
{
	desc="show non-existent group rule"
	rlPhaseStartTest "ipa-automember-cli-2101: $desc"
		rlRun "showAutomember group eng" 2 "Verify error code for $desc"
		command="ipa automember-show --type=group eng"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="show non-existent hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2102: $desc"
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
	rlPhaseStartTest "ipa-automember-cli-2201: $desc"
		rlRun "showAutomember badtype devel" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype devel"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="show existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-2202: $desc"
		rlRun "showAutomember badtype engservers" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype webservers"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember positive tests
######################################################################
ipaautomember_modifyAutomember_positive()
{
	desc="modify existing group rule"
	rlPhaseStartTest "ipa-automember-cli-2301: $desc"
		rlRun "modifyAutomember group devel desc \"DEV_USERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
	
	desc="modify existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2302: $desc"
		rlRun "modifyAutomember hostgroup webservers desc \"WEB_SERVERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember negative tests for same value
######################################################################
ipaautomember_modifyAutomember_negative_sameval()
{
	desc="modify existing group rule with same value"
	rlPhaseStartTest "ipa-automember-cli-2401: $desc"
		rlRun "modifyAutomember group devel desc \"DEV_USERS\"" 1 "Verify return code for $desc"
		command="ipa automember-mod --type=group devel --desc=\"DEV_USERS\""
		expmsg="ipa: ERROR: no modifications to be performed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="modify existing hostgroup rule with same value"
	rlPhaseStartTest "ipa-automember-cli-2402: $desc"
		rlRun "modifyAutomember hostgroup webservers desc \"WEB_SERVERS\"" 1 "Verify return code for $desc"
		command="ipa automember-mod --type=hostgroup webservers --desc=\"WEB_SERVERS\""
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
	rlPhaseStartTest "ipa-automember-cli-2501: $desc"
		rlRun "modifyAutomember group eng desc \"ENG_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=group eng --desc=\"ENG_USERS\""
		expmsg="ipa: ERROR: : auto_member_rule not found"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badgroup 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badgroup"
	rlPhaseEnd

	desc="modify existing hostgroup rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2502: $desc"
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
	rlPhaseStartTest "ipa-automember-cli-2601: $desc"
		rlRun "modifyAutomember badtype devel desc \"DEV_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=badtype devel --desc=\"DEV_USERS\""
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="modify existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-2602: $desc"
		rlRun "modifyAutomember badtype webservers desc \"WEB_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-mod --type=badtype webservers --desc=\"WEB_SERVERS\""
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# modifyAutomember negative tests for invalid attribute
######################################################################
ipaautomember_modifyAutomember_negative_badattr()
{
	desc="modify existing group rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-2701: $desc"
		rlRun "modifyAutomember group devel name \"DEV_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --type=group devel --name=\"DEV_USERS\""
		expmsg="ipa: error: no such option: --name"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badattr 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badattr"
	rlPhaseEnd

	desc="modify existing hostgroup rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-2702: $desc"
		rlRun "modifyAutomember hostgroup webservers name \"WEB_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --type=hostgroup webservers --name=\"WEB_SERVERS\""
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
	rlPhaseStartTest "ipa-automember-cli-2801: $desc"
		rlRun "verifyAutomemberAttr group devel Description \"DEV_USERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
	
	desc="verify existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-2802: $desc"
		rlRun "verifyAutomemberAttr hostgroup webservers Description \"WEB_SERVERS\"" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# verifyAutomember negative tests for non-existent group
######################################################################
ipaautomember_verifyAutomemberAttr_negative_badgroup()
{
	desc="verify existing group rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2901: $desc"
		rlRun "verifyAutomemberAttr group eng Description ENG_USERS" 2 "Verify error code for $desc"
		command="ipa automember-show --type=group eng"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="verify existing hostgroup rule with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-2902: $desc"
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
	rlPhaseStartTest "ipa-automember-cli-3001: $desc"
		rlRun "verifyAutomemberAttr badtype devel desc DEV_USERS" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype devel"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="verify existing hostgroup rule with invalid type"
	rlPhaseStartTest "ipa-automember-cli-3002: $desc"
		rlRun "verifyAutomemberAttr badtype webservers desc WEB_SERVERS" 1 "Verify error code for $desc"
		command="ipa automember-show --type=badtype webservers"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# verifyAutomemberAttr negative tests for invalid attribute
######################################################################
ipaautomember_verifyAutomemberAttr_negative_badattr()
{
	desc="verify existing group rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-3101: $desc"
		rlRun "verifyAutomemberAttr group devel badattr \"DEV_USERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=group devel" 
		expmsg="badattr"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badattr 2>&1" 0 "Verify error message for $desc"
		rlAssertNotGrep "$expmsg" "/tmp/ipaam_badattr"
	rlPhaseEnd

	desc="verify existing hostgroup rule with invalid attribute"
	rlPhaseStartTest "ipa-automember-cli-3102: $desc"
		rlRun "verifyAutomemberAttr hostgroup webservers badattr \"WEB_SERVERS\"" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=hostgroup webservers" 
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
	rlPhaseStartTest "ipa-automember-cli-3201: $desc"
		rlRun "verifyAutomemberAttr group devel \"Automember Rule\" badval" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=group devel" 
		expmsg="Automember Rule: badval"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badval 2>&1" 0 "Verify error message for $desc"
		rlAssertNotGrep "$expmsg" "/tmp/ipaam_badval"
	rlPhaseEnd

	desc="verify existing hostgroup rule with incorrect value"
	rlPhaseStartTest "ipa-automember-cli-3202: $desc"
		rlRun "verifyAutomemberAttr hostgroup webservers \"Automember Rule\" badval" 1 "Verify error code for $desc"
		command="ipa automember-show --all --type=hostgroup webservers"
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
	rlPhaseStartTest "ipa-automember-cli-3301: $desc"
		rlRun "setAutomemberDefaultGroup group defgroup" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="set default hostgroup"
	rlPhaseStartTest "ipa-automember-cli-3302: $desc"
		rlRun "setAutomemberDefaultGroup hostgroup defhostgroup" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# setAutomemberDefaultGroup negative tests for same value
######################################################################
ipaautomember_setAutomemberDefaultGroup_negative_sameval()
{
	desc="set default group with same value"
	rlPhaseStartTest "ipa-automember-cli-3401: $desc"
		rlRun "setAutomemberDefaultGroup group defgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=group --default-group=defgroup"
		expmsg="ipa: ERROR: no modifications to be performed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="set default hostgroup with same value"
	rlPhaseStartTest "ipa-automember-cli-3402: $desc"
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
	rlPhaseStartTest "ipa-automember-cli-3501: $desc"
		rlRun "setAutomemberDefaultGroup group badgroup" 2 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=group --default-group=badgroup"
		expmsg="ipa: ERROR: Group: badgroup not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="set default hostgroup with non-existent group"
	rlPhaseStartTest "ipa-automember-cli-3501: $desc"
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
	rlPhaseStartTest "ipa-automember-cli-3601: $desc"
		rlRun "setAutomemberDefaultGroup badtype defgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=badtype --default-group=defgroup"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="set default hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-3601: $desc"
		rlRun "setAutomemberDefaultGroup badtype defhostgroup" 1 "Verify error code for $desc"
		command="ipa automember-default-group-set --type=badtype --default-group=defhostgroup"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomemberDefaultGroup positive tests
######################################################################
ipaautomember_showAutomemberDefaultGroup_positive()
{
	desc="show default group"
	rlPhaseStartTest "ipa-automember-cli-3701: $desc"
		rlRun "showAutomemberDefaultGroup group" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="show default hostgroup"
	rlPhaseStartTest "ipa-automember-cli-3702: $desc"
		rlRun "showAutomemberDefaultGroup hostgroup" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# showAutomemberDefaultGroup negative tests for invalid type
######################################################################
ipaautomember_showAutomemberDefaultGroup_negative_badtype()
{
	desc="show default group for invalid type"
	rlPhaseStartTest "ipa-automember-cli-3801: $desc"
		rlRun "showAutomemberDefaultGroup badtype" 1 "Verify error code for $desc"
		command="ipa automember-default-group-show --type=badtype"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberDefaultGroup positive tests
######################################################################
ipaautomember_removeAutomemberDefaultGroup_positive()
{
	desc="remove default group"
	rlPhaseStartTest "ipa-automember-cli-3901: $desc"
		rlRun "removeAutomemberDefaultGroup group" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="remove default hostgroup"
	rlPhaseStartTest "ipa-automember-cli-3902: $desc"
		rlRun "removeAutomemberDefaultGroup hostgroup" 0 "Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberDefaultGroup negative tests for invalid type
######################################################################
ipaautomember_removeAutomemberDefaultGroup_negative_badtype()
{
	desc="remove default group for invalid type"
	rlPhaseStartTest "ipa-automember-cli-4001: $desc"
		rlRun "removeAutomemberDefaultGroup badtype" 1 "Verify error code for $desc"
		command="ipa automember-default-group-remove --type=badtype"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberDefaultGroup negative tests for no default group
######################################################################
ipaautomember_removeAutomemberDefaultGroup_negative_nodefault()
{
	desc="remove default group for no default"
	rlPhaseStartTest "ipa-automember-cli-4101: $desc"
		rlRun "removeAutomemberDefaultGroup group" 2 "Verify return code for $desc"
		command="ipa automember-default-group-remove --type=group"
		expmsg="ipa: ERROR: No default group set"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove default hostgroup for no default"
	rlPhaseStartTest "ipa-automember-cli-4102: $desc"
		rlRun "removeAutomemberDefaultGroup hostgroup" 2 "Verify return code for $desc"
		command="ipa automember-default-group-remove --type=hostgroup"
		expmsg="ipa: ERROR: No default group set"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}	

######################################################################
# showAutomemberDefaultGroup negative tests Part 2 for no default group
######################################################################
ipaautomember_showAutomemberDefaultGroup_negative_nodefault()
{
	desc="show default group for no default"
	rlPhaseStartTest "ipa-automember-cli-4201: $desc"
		rlRun "showAutomemberDefaultGroup group" 0 "Verify return code for $desc"
		command="ipa automember-default-group-show --type=group"
		expmsg="  Default Group: No default group set"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_nodefault 2>&1" 0 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_nodefault"
	rlPhaseEnd

	desc="show default hostgroup for no default"
	rlPhaseStartTest "ipa-automember-cli-4202: $desc"
		rlRun "showAutomemberDefaultGroup hostgroup" 0 "Verify return code for $desc"
		command="ipa automember-default-group-show --type=hostgroup"
		expmsg="  Default Group: No default group set"
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
	rlPhaseStartTest "ipa-automember-cli-4301: $desc"
		rlRun "removeAutomemberCondition group devel manager inclusive ^uid=mscott" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="remove group exclusive regex"
	rlPhaseStartTest "ipa-automember-cli-4302: $desc"
		rlRun "removeAutomemberCondition group devel manager exclusive ^uid=mjohn" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="remove hostgroup inclusive regex"
	rlPhaseStartTest "ipa-automembet-cli-4303: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers fqdn inclusive ^web[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd

	desc="remove hostgroup exclusive regex"
	rlPhaseStartTest "ipa-automember-cli-4304: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers fqdn exclusive ^eng[0-9]+\.example\.com" 0 \
			"Verify return code for $desc"
	rlPhaseEnd
}

######################################################################
# removeAutomemberCondition negative tests for non-existent group
######################################################################
ipaautomember_removeAutomemberCondition_negative_badgroup()
{
	desc="remove inclusive regex for non-existent group"
	rlPhaseStartTest "ipa-automember-cli-4401: $desc"
		rlRun "removeAutomemberCondition group eng manager inclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group eng --key=manager --inclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex for non-existent group"
	rlPhaseStartTest "ipa-automember-cli-4402: $desc"
		rlRun "removeAutomemberCondition group eng manager exclusive ^uid=mjohn" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group eng --key=manager --exclusive-regex=^uid=mscott"
		expmsg="ipa: ERROR: Auto member rule: eng not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove inclusive regex for non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-4403: $desc"
		rlRun "removeAutomemberCondition hostgroup engservers fqdn inclusive ^eng[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup engservers --key=fqdn --inclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: Auto member rule: engservers not found!"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex for non-existent hostgroup"
	rlPhaseStartTest "ipa-automember-cli-4404: $desc"
		rlRun "removeAutomemberCondition hostgroup engservers fqdn exclusive ^web[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup engservers --key=fqdn --exclusive-regex=^web[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-4501: $desc"
		rlRun "removeAutomemberCondition badtype devel manager inclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype devel --key=manager --inclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex from group with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4502: $desc"
		rlRun "removeAutomemberCondition badtype devel manager exclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype devel --key=manager --exclusive-regex=^uid=mjohn"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove inclusive regex from hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4503: $desc"
		rlRun "removeAutomemberCondition badtype webservers fqdn inclusive ^web[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype webservers --key=fqdn --inclusive-regex=^web[0-9]+.example.com"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	desc="remove exclusive regex from hostgroup with invalid type"
	rlPhaseStartTest "ipa-automember-cli-4504: $desc"
		rlRun "removeAutomemberCondition badtype webservers fqdn exclusive ^eng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=badtype webservers --key=fqdn --exclusive-regex=^eng[0-9]+.example.com"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}

######################################################################
# removeAutomemberCondition negative tests for invalid key
######################################################################
ipaautomember_removeAutomemberCondition_negative_badkey()
{
	desc="remove inclusive regex from group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4601: $desc"
		rlRun "removeAutomemberCondition group devel badkey inclusive ^uid=mscott" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=badkey --inclusive-regex=^uid=mscott"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd

	desc="remove exclusive regex from group with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4602: $desc"
		rlRun "removeAutomemberCondition group devel badkey exclusive ^uid=mjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=badkey --exclusive-regex=^uid=mjohn"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd

	desc="remove inclusive regex from hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4603: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers badkey inclusive ^web[0-9]+\.example\.com" 1 \
			"Verify error code for remove inclusive regex to hostgroup with invalid key"
		command="ipa automember-remove-condition --type=hostgroup webservers --key=badkey --inclusive-regex=^web[0-9]+.example.com"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badkey 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badkey"
	rlPhaseEnd

	desc="remove exclusive regex from hostgroup with invalid key"
	rlPhaseStartTest "ipa-automember-cli-4604: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers badkey exclusive ^eng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup webservers --key=badkey --exclusive-regex=^eng[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-4701: $desc"
		rlRun "removeAutomemberCondition group devel manager badregextype ^uid=mscott" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=manager --badregextype-regex=^uid=mscott"
		expmsg="ipa: error: no such option: --badregextype-regex"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregextype 2>&1" 2 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregextype"
	rlPhaseEnd

	desc="remove regex from hostgroup with invalid regextype"
	rlPhaseStartTest "ipa-automember-cli-4702: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers fqdn badregextype ^web[0-9]+\.example\.com" 2 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup webservers --key=fqdn --badregextype-regex=^web[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-4801: $desc"
		rlRun "removeAutomemberCondition group devel manager inclusive ^uid=badmscott" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=manager --inclusive-regex=^uid=badmscott"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd

	desc="remove group exclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4802: $desc"
		rlRun "removeAutomemberCondition group devel manager exclusive ^uid=badmjohn" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=group devel --key=manager --exclusive-regex=^uid=badmjohn"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd

	desc="remove hostgroup inclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4803: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers fqdn inclusive ^badweb[0-9]+\.example\.com" 1 \
			"Verify error code for remove inclusive regex to hostgroup with invalid key"
		command="ipa automember-remove-condition --type=hostgroup webservers --key=fqdn --inclusive-regex=^badweb[0-9]+.example.com"
		expmsg="Number of conditions removed 0"
		#rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
		rlRun "$command > /tmp/ipaam_badregex 2>&1" 1 "Verify error message for $desc"
		rlAssertGrep "$expmsg" "/tmp/ipaam_badregex"
	rlPhaseEnd

	desc="remove hostgroup exclusive regex for non-existent regex"
	rlPhaseStartTest "ipa-automember-cli-4804: $desc"
		rlRun "removeAutomemberCondition hostgroup webservers fqdn exclusive ^badeng[0-9]+\.example\.com" 1 \
			"Verify error code for $desc"
		command="ipa automember-remove-condition --type=hostgroup webservers --key=fqdn --exclusive-regex=^badeng[0-9]+.example.com"
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
	rlPhaseStartTest "ipa-automember-cli-4901: $desc"
		rlRun "deleteAutomember group devel" 0 "Verify return code for $desc"
	rlPhaseEnd

	desc="delete existing hostgroup rule"
	rlPhaseStartTest "ipa-automember-cli-4902: $desc"
		rlRun "deleteAutomember hostgroup webservers" 0 "Verify return code for $desc"
	rlPhaseEnd
}


######################################################################
# deleteAutomember negative tests for non-existent group rule
######################################################################
ipaautomember_deleteAutomember_negative_badgroup()
{
	rlPhaseStartTest "ipa-automember-cli-5001: $desc"
		rlRun "deleteAutomember group devel" 2 "Verify return code for $desc"
		command="ipa automember-del --type=group devel"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-5002: $desc"
		rlRun "deleteAutomember hostgroup webservers" 2 "Verify return code for $desc"
		command="ipa automember-del --type=group devel"
		expmsg="ipa: ERROR: : auto_member_rule not found"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd

}
	
######################################################################
# deleteAutomember negative tests for invalid type
######################################################################
ipaautomember_deleteAutomember_negative_badtype()
{
	rlPhaseStartTest "ipa-automember-cli-5101: $desc"
		rlRun "deleteAutomember badtype devel" 1 "Verify return code for $desc"
		command="ipa automember-del --type=badtype devel"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify error message for $desc"
	rlPhaseEnd
}
######################################################################
# CLEANUP
######################################################################
ipaautomember_cleanup()
{
	rlPhaseStartCleanup "ipa-automember-cli-cleanup: Delete remaining automember rules and Destroying admin credentials"
		rlRun "deleteGroup devel" 0 "Deleting group devel"
		rlRun "deleteHostGroup webservers" 0 "Deleting hostgroup webservers"
		rlRun "deleteGroup defgroup" 0 "Deleting group defgroup"
		rlRun "deleteHostGroup defhostgroup" 0 "Deleting hostgroup defhostgroup"
		rlRun "ipa user-del mscott"
		rlRun "ipa user-del mjohn"
		rlRun "kdestroy" 0 "Destroying admin credentials"
	rlPhaseEnd
}
