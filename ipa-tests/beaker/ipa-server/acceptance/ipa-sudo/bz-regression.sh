#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-sudo
#   Description: sudo test cases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date  : May 23, 2011
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
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################
user1="user1"
user2="user2"
userpw="Secret123"

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
basedn=`getBaseDN`


bug769491() {


rlPhaseStartTest "bug769491: Unable to add certain sudo commands to groups."

	rlLog "https://bugzilla.redhat.com/show_bug.cgi?id=769491"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlRun "ipa sudocmd-add \"/bin/chown -R apache:developers /var/www/*/shared/log\" > $TmpDir/bug769491.txt 2>&1"
        rlAssertGrep "Added Sudo Command" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"

	rlRun "ipa sudocmdgroup-add sudogrp1 --desc=sudogrp1"
	rlRun "ipa sudocmdgroup-add-member sudogrp1 --sudocmds=\"/bin/chown -R apache:developers /var/www/*/shared/log\" > $TmpDir/bug769491.txt 2>&1"
	rlAssertGrep "Member Sudo commands: /bin/chown -r apache:developers /var/www/\*/shared/log" "$TmpDir/bug769491.txt"
	rlAssertGrep "Numer of members added 1" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"

	rlRun "ipa sudocmdgroup-show sudogrp1 > $TmpDir/bug769491.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/bug769491.txt"
	rlAssertGrep "Member Sudo commands: /bin/chown -r apache:developers /var/www/\*/shared/log" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"
	
	rlRun "ipa sudocmdgroup-remove-member sudogrp1 --sudocmds=\"/bin/chown -R apache:developers /var/www/*/shared/log\" > $TmpDir/bug769491.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/bug769491.txt"
        rlAssertNotGrep "Member Sudo commands: /bin/chown -r apache:developers /var/www/\*/shared/log" "$TmpDir/bug769491.txt"
	rlAssertGrep "Numer of members removed 1" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"

	# clean up
	rlRun "ipa sudocmd-del \"/bin/chown -R apache:developers /var/www/*/shared/log\""
	rlRun "ipa sudocmdgroup-del sudogrp1"

rlPhaseEnd

}

bug741604() {

rlPhaseStartTest "bug741604: misleading error when adding duplicate external members to sudo rule"

	rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=741604"

	rlRun "ipa sudorule-add 741604rule"
	rlRun "ipa sudorule-add-user --users=user1,unknown 741604rule > $TmpDir/bug741604.txt 2>&1"
	rlRun "cat $TmpDir/bug764604.txt"

	rlRun "ipa sudorule-add-user --users=user1,unknown 741604rule > $TmpDir/bug741604.txt 2>&1"
	rlAssertGrep "member user: user1: This entry is already a member" "$TmpDir/bug741604.txt"
	rlAssertGrep "member user: unknown: This entry is already a member" "$TmpDir/bug741604.txt"
	rlAssertNotGrep "member user: unknown: no such entry" "$TmpDir/bug741604.txt"

	rlRun "cat $TmpDir/bug741604.txt"

	# clean up
	rlRun "ipa sudorule-del 741604rule"

rlPhaseEnd

}

