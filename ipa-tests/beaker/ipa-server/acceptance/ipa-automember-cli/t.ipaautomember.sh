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
	#ipaautomember_addAutomember_negative
	#ipaautomember_addAutomemberCondition_positive
	#ipaautomember_addAutomemberCondition_negative_badgroup
	#ipaautomember_addAutomemberCondition_negative_badtype
	#ipaautomember_addAutomemberCondition_negative_badkey
	#ipaautomember_addAutomemberCondition_negative_badregextype
	#ipaautomember_findAutomember_positive
	#ipaautomember_findAutomember_negative_badgroup
	#ipaautomember_findAutomember_negative_badtype
	#ipaautomember_showAutomember_positive
	#ipaautomember_showAutomember_negative_badgroup
	#ipaautomember_showAutomember_negative_badtype
	ipaautomember_modifyAutomember_positive
	ipaautomember_modifyAutomember_negative_sameval
	ipaautomember_modifyAutomember_negative_badgroup
	ipaautomember_modifyAutomember_negative_badtype
	ipaautomember_modifyAutomember_negative_badattr
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
		rlRun "addAutomember group devel" 0 "$desc"
	rlPhaseEnd

	desc="create rule for hostgroup"
	rlPhaseStartTest "ipa-automember-cli-1002: $desc"
		rlRun "addAutomember hostgroup webservers" 0 "$desc"
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
# CLEANUP
######################################################################
ipaautomember_cleanup()
{
	rlPhaseStartCleanup "ipa-automember-cli-cleanup: Delete remaining automember rules and Destroying admin credentials"
		rlRun "deleteAutomember group devel" 0 "Deleting automember group for devel"
		rlRun "deleteAutomember hostgroup webservers" 0 "Deleting automember hostgroup for webservers"
		rlRun "deleteGroup devel" 0 "Deleting group devel"
		rlRun "deleteHostGroup webservers" 0 "Deleting hostgroup webservers"
		rlRun "ipa user-del mscott"
		rlRun "ipa user-del mjohn"
		rlRun "kdestroy" 0 "Destroying admin credentials"
	rlPhaseEnd
}
