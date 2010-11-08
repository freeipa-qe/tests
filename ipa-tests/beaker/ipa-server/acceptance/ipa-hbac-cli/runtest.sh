#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbac-cli
#   Description: IPA Host Based Access Control (HBAC) CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  hbac-add                Create a new HBAC rule.
#  hbac-add-accesstime     Add an access time to an HBAC rule.
#  hbac-add-host           Add target hosts and hostgroups to an HBAC rule
#  hbac-add-service        Add services to an HBAC rule.
#  hbac-add-sourcehost     Add source hosts and hostgroups from a HBAC rule.
#  hbac-add-user           Add users and groups to an HBAC rule.
#  hbac-del                Delete an HBAC rule.
#  hbac-disable            Disable an HBAC rule.
#  hbac-enable             Enable an HBAC rule.
#  hbac-find               Search for HBAC rules.
#  hbac-mod                Modify an HBAC rule.
#  hbac-remove-accesstime  Remove access time to HBAC rule.
#  hbac-remove-host        Remove target hosts and hostgroups from a HBAC rule.
#  hbac-remove-service     Remove source hosts and hostgroups from an HBAC rule.
#  hbac-remove-sourcehost  Remove source hosts and hostgroups from an HBAC rule.
#  hbac-remove-user        Remove users and groups from an HBAC rule.
#  hbac-show               Display the properties of an HBAC rule.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

host1="dev_host."$DOMAIN
host2="qe_host."$DOMAIN
host3="common_host."$DOMAIN
host4="sales_host."$DOMAIN

user1="dev"
user2="qe"
user3="manager"
user4="sales"

usergroup1="dev_ugrp"
usergroup2="qe_ugrp"

hostgroup1="dev_hosts"
hostgroup2="qe_hosts"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-hbac-cli-startup: Check for admintools package and Kinit"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	# add hosts for testing

	# add hostgroups testing

	# set up host memberships

	# add users for testing

	# add groups for testing

	# set up user memberships

    rlPhaseEnd

    # hbac-add negative testing 
    rlPhaseStartTest "ipa-hbac-cli-001: Rule Type Required - send empty string"
        command="ipa hbac-add --type=\"\" test"
        expmsg="ipa: ERROR: 'type' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty Rule Type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-002: Rule Type Required - unknown type"
        command="ipa hbac-add --type=\"bad\" test"
        expmsg="ipa: ERROR: invalid 'accessruletype': must be one of (u'allow', u'deny')"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown Rule Type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-003: User Category - unknown"
        command="ipa hbac-add --type=deny --usercat=bad test"
        expmsg="ipa: ERROR: invalid 'usercategory': must be one of (u'all',)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown user category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-004: Service Category - unknown"
        command="ipa hbac-add --type=deny --servicecat=bad test"
        expmsg="ipa: ERROR: invalid 'servicecategory': must be one of (u'all',)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown service category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-005: Host Category - unknown"
        command="ipa hbac-add --type=deny --hostcat=bad test"
        expmsg="ipa: ERROR: invalid 'hostcategory': must be one of (u'all',)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown host category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-006: Source Host Category - unknown"
        command="ipa hbac-add --type=deny --srchostcat=bad test"
        expmsg="ipa: ERROR: invalid 'sourcehostcategory': must be one of (u'all',)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown source host category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-007: Add Duplicate Rule"
	rlRun "addHBACRule deny all all all all test" 0 "Adding HBAC test rule."
        command="ipa hbac-add --type=allow --srchostcat=all test"
        expmsg="ipa: ERROR: HBAC rule with name test already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding duplicate rule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-008: Negative - setattr and addattr on dn"
        command="ipa hbac-mod --setattr dn=mynewDN test"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hbac-mod --addattr dn=anothernewDN test"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-009: Negative - setattr and addattr on cn"
        rlRun "ipa hbac-mod --setattr cn=test2 test" 0 "Modify hbac rule's cn with setattr"
        expmsg="ipa: ERROR: cn: Only one value allowed."
        command="ipa hbac-mod --addattr cn=\"test3\" test2"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbac-cli-010: Negative - setattr and addattr on ipauniqueid"
        command="ipa hbac-mod --setattr ipauniqueid=mynew-unique-id test2"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hbac-mod --addattr ipauniqueid=another-new-unique-id test2"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-hbac-cli-cleanup: Destroying admin credentials."
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "deleteHBACRule test2" 0 "Deleting the test rule."
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd
