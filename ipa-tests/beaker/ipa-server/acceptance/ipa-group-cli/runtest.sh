#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-group-cli
#   Description: IPA group CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  group-add            Create a new group.
#  group-add-member     Add members to a group.
#  group-del            Delete group.
#  group-detach         Detach a managed group from a user
#  group-find           Search for groups.
#  group-mod            Modify a group.
#  group-remove-member  Remove members from a group.
#  group-show           Display information about a named group.
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
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-server-shared.sh

########################################################################
# Test Suite Globals
########################################################################
ADMINID="admin"
ADMINPWD="Admin123"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-group-cli-startup: Check for admintools package and Kinit"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-01: Attempted to delete managed private group"
        rlRun "ipa user-add --first Jenny --last Galipeau jennyg" 0 "Adding Test User"
        rlRun "verifyGroupClasses \"jennyg\" yes" 0 "Verifying user's private group."
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-02: Add user and check for Private Group Creation"
        command="ipa group-del jennyg"
        expmsg="ipa: ERROR: Deleting a managed group is not allowed. It must be detached first."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verifying error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-group-cli-03: Delete user and check for Private Group Removal"
	rlRun "ipa user-del jennyg" 0 "Deleting Test User"
	rlRun "verifyGroupClasses jennyg yes" 2 "Verify user's private group was removed."
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-group-cli-cleanup: Destroying admin credentials."
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd
