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
	ipaautomember_cleanup
}

######################################################################
# SETUP
######################################################################
ipaautomember_setup()
{
	rlPhaseStartTest "ipa-automember-cli-00: initial setup, kinit, group/hostgroup adds, etc."
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
		rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
		rlRun "pushd $TmpDir"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as $ADMINID user"
		
		rlRun "addGroup \"Developers\" \"devel\""
		rlRun "addHostGroup \"Web Servers\" \"webservers\""
	rlPhaseEnd
}

######################################################################
# addAutomember positive tests
######################################################################
ipaautomember_addAutomember_positive()
{
	rlPhaseStartTest "ipa-automember-cli-01: create rule for existing group"
		rlRun "addAutomember group devel" 0 "Adding automember rule for group devel"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-02: create rule for existing hostgroup"
		rlRun "addAutomember hostgroup webservers" 0 "Adding automember rule for hostgroup webservers"
	rlPhaseEnd
}

######################################################################
# addAutomember negative tests
######################################################################
ipaautomember_addAutomember_negative()
{
	rlPhaseStartTest "ipa-automember-cli-03: create rule for non-existent group"
		rlRun "addAutomember group eng" 2 "Adding automember rule for non-existent group eng"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-04: create rule for non-existent hostgroup"
		rlRun "addAutomember hostgroup engservers" 2 "Adding automember rule for non-existent hostgroup engservers"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-05: create rule for invalid type"
		rlRun "addAutomember badtype devel" 1 "Adding automember rule for invalid type=badtype"
		expmsg="ipa: ERROR: invalid 'type': must be one of (u'group', u'hostgroup')"
		command="ipa automember-add --type=badtype devel"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error for invalid type"
	rlPhaseEnd
}

######################################################################
# addAutomemberCondition positive tests
######################################################################
ipaautomember_addAutomemberCondition_positive()
{
	rlPhaseStartTest "ipa-automember-cli-06: add group inclusive condition to existing group rule"
		rlRun "addAutomemberCondition group devel manager inclusive ^uid=mscott" 0 \
			"add group inclusive condition to existing group rule"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automembet-cli-07: add group exclusive condition to existing group rule"
		rlRun "addAutomemberCondition group devel manager exclusive ^uid=mjohn" 0 \
			"add group exclusive condition to existing group rule"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automembet-cli-08: add hostgroup inclusive condition to existing hostgroup rule"
		rlRun "addAutomemberCondition hostgroup webservers fqdn inclusive ^web[0-9]+\.example\.com" 0 \
			"add hostgroup inclusive condition to existing hostgroup rule"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-09: add hostgroup exclusive condition to existing hostgroup rule"
		rlRun "addAutomemberCondition hostgroup webservers fqdn exclusive ^eng[0-9]+\.example\.com" 0 \
			"add hostgroup exclusive condition to existing hostgroup rule"
	rlPhaseEnd
}

######################################################################
# addAutomemberCondition negative tests for non-existent group
######################################################################
ipaautomember_addAutomemberCondition_negative_badgroup()
{
	rlPhaseStartTest "ipa-automember-cli-10: add group inclusive condition to non-existent group rule"
		rlRun "addAutomemberCondition group eng manager inclusive ^uid=mjohn" 0 \
			"add group inclusive condition to non-existent group rule"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-11: add group exclusive condition to non-existent group rule"
		rlRun "addAutomemberCondition group eng manager exclusive ^uid=mjohn" 0 \
			"add group exclusive condition to non-existent group rule"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-12: add hostgroup inclusive condition to non-existent hostgroup rule"
		rlRun "addAutomemberCondition hostgroup engservers fqdn inclusive ^eng[0-9]+\.example\.com" 0 \
			"add hostgroup inclusive condition to non-existent hostgroup rule"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-13: add hostgroup exclusive condition to non-existent hostgroup rule"
		rlRun "addAutomemberCondition hostgroup engservers fqdn exclusive ^web[0-9]+\.example\.com" 0 \
			"add hostgroup exclusive condition to non-existent hostgroup rule"
	rlPhaseEnd

}

######################################################################
# addAutomemberCondition negative tests for invalid type
######################################################################
ipaautomember_addAutomemberCondition_negative_badtype()
{
	rlPhaseStartTest "ipa-automember-cli-14: add badtype inclusive condition to existing group rule with invalid type"
		rlRun "addAutomemberCondition badtype devel manager inclusive ^uid=mjohn" 0 \
			"add badtype inclusive condition to existing group rule with invalid type"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-15: add badtype exclusive condition to existing group rule with invalid type"
		rlRun "addAutomemberCondition badtype devel manager exclusive ^uid=mjohn" 0 \
			"add badtype exclusive condition to existing group rule with invalid type"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-16: add badtype inclusive condition to existing hostgroup rule with invalid type"
		rlRun "addAutomemberCondition badtype webservers fqdn inclusive ^web[0-9]+\.example\.com" 0 \
			"add badtype inclusive condition to existing hostgroup rule with invalid type"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-17: add badtype exclusive condition to existing hostgroup rule with invalid type"
		rlRun "addAutomemberCondition badtype webservers fqdn exclusive ^eng[0-9]+\.example\.com" 0 \
			"add badtype exclusive condition to existing hostgroup rule with invalid type"
	rlPhaseEnd

}

ipaautomember_addAutomemberCondition_negative_badkey()
{
	rlPhaseStartTest "ipa-automember-cli-18: add group inclusive condition to existing group rule with invalid key"
		rlRun "addAutomemberCondition group devel badkey inclusive ^uid=mscott" 0 \
			"add group inclusive condition to existing group rule with invalid key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-19: add group exclusive condition to existing group rule with invalid key"
		rlRun "addAutomemberCondition group devel badkey exclusive ^uid=mjohn" 0 \
			"add group exclusive condition to existing group rule with invalid key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-20: add hostgroup inclusive condition to existing hostgroup rule with invalid key"
		rlRun "addAutomemberCondition hostgroup webservers badkey inclusive ^web[0-9]+\.example\.com" 0 \
			"add hostgroup inclusive condition to existing hostgroup rule with invalid key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-21: add hostgroup exclusive condition to existing hostgroup rule with invalid key"
		rlRun "addAutomemberCondition hostgroup webservers badkey exclusive ^eng[0-9]+\.example\.com" 0 \
			"add hostgroup exclusive condition to existing hostgroup rule with invalid key"
	rlPhaseEnd
}

ipaautomember_addAutomemberCondition_negative_badregextype()
{
	rlPhaseStartTest "ipa-automember-cli-22: add group badregextype condition to existing group rule with invalid regextype"
		rlRun "addAutomemberCondition group devel manager badregextype ^uid=mscott" 0 \
			"add group badregextype condition to existing group rule with invalid regextype"
	rlPhaseEnd

	rlPhaseStartTest "ipa-automember-cli-23: add hostgroup badregextype condition to existing hostgroup rule with invalid regextype"
		rlRun "addAutomemberCondition hostgroup webservers fqdn badregextype ^web[0-9]+\.example\.com" 0 \
			"add hostgroup badregextype condition to existing hostgroup rule with invalid regextype"
	rlPhaseEnd
}


######################################################################
# CLEANUP
######################################################################
ipaautomember_cleanup()
{
	rlPhaseStartCleanup "ipa-automember-cli-cleanup: Delete remaining automember rules and Destroying admin credentials"
		rlRun "deleteAutomember group devel" 0 "Deleting automember group rule for devel"
		rlRun "deleteAutomember hostgroup webservers" 0 "Deleting automember hostgroup rule for webservers"
		rlRun "deleteGroup devel" 0 "Deleting group devel"
		rlRun "deleteHostGroup webservers" 0 "Deleting hostgroup webservers"
		rlRun "kdestroy" 0 "Destroying admin credentials"
	rlPhaseEnd
}
