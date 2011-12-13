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
	ipaautomember_cleanup
}

######################################################################
# variables
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
# variables
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
# CLEANUP
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
# CLEANUP
######################################################################
ipaautomember_cleanup()
{
	rlPhaseStartCleanup "ipa-automember-cli-cleanup: Delete remaining automember ruls and Destroying admin credentials"
		rlRun "deleteAutomember group devel" 0 "Deleting automember group rule for devel"
		rlRun "deleteAutomember hostgroup webservers" 0 "Deleting automember hostgroup rule for webservers"
		rlRun "deleteGroup devel" 0 "Deleting group devel"
		rlRun "deleteHostGroup webservers" 0 "Deleting hostgroup webservers"
		rlRun "kdestroy" 0 "Destroying admin credentials"
	rlPhaseEnd
}
