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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

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
	TmpDir=`mktemp -d`
	pushd $TmpDir

        rlRun "ipa sudocmd-add \"/bin/chown -R apache:developers /var/www/*/shared/log\" > $TmpDir/bug769491.txt 2>&1"
        rlAssertGrep "Added Sudo Command" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"

	rlRun "ipa sudocmdgroup-add sudogrp1 --desc=sudogrp1"
	rlRun "ipa sudocmdgroup-add-member sudogrp1 --sudocmds=\"/bin/chown -R apache:developers /var/www/*/shared/log\" > $TmpDir/bug769491.txt 2>&1"
	rlAssertGrep "Member Sudo commands: /bin/chown -R apache:developers /var/www/\*/shared/log" "$TmpDir/bug769491.txt"
	rlAssertGrep "Number of members added 1" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"

	rlRun "ipa sudocmdgroup-show sudogrp1 > $TmpDir/bug769491.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/bug769491.txt"
	rlAssertGrep "Member Sudo commands: /bin/chown -R apache:developers /var/www/\*/shared/log" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"
	
	rlRun "ipa sudocmdgroup-remove-member sudogrp1 --sudocmds=\"/bin/chown -R apache:developers /var/www/*/shared/log\" > $TmpDir/bug769491.txt 2>&1"
	rlAssertGrep "Sudo Command Group: sudogrp1" "$TmpDir/bug769491.txt"
        rlAssertNotGrep "Member Sudo commands: /bin/chown -R apache:developers /var/www/\*/shared/log" "$TmpDir/bug769491.txt"
	rlAssertGrep "Number of members removed 1" "$TmpDir/bug769491.txt"
        rlRun "cat $TmpDir/bug769491.txt"

	# clean up
	rlRun "ipa sudocmd-del \"/bin/chown -R apache:developers /var/www/*/shared/log\""
	rlRun "ipa sudocmdgroup-del sudogrp1"

rlPhaseEnd

}

bug741604() {

rlPhaseStartTest "bug741604: misleading error when adding duplicate external members to sudo rule"

	rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=741604"

        TmpDir=`mktemp -d`
        pushd $TmpDir
	rlRun "ipa sudorule-add 741604rule"

	rlRun "ipa sudorule-add-user --users=user1,unknown 741604rule > $TmpDir/bug741604.txt 2>&1"
	rlRun "cat $TmpDir/bug741604.txt"

	rlRun "ipa sudorule-add-user --users=user1,unknown 741604rule > $TmpDir/bug741604.txt 2>&1" 1
	rlAssertGrep "member user: user1: This entry is already a member" "$TmpDir/bug741604.txt"
	rlAssertGrep "member user: unknown: This entry is already a member" "$TmpDir/bug741604.txt"
	rlAssertNotGrep "member user: unknown: no such entry" "$TmpDir/bug741604.txt"

	rlRun "cat $TmpDir/bug741604.txt"

	# clean up
	rlRun "ipa sudorule-del 741604rule"

rlPhaseEnd

}


bug782976() {

rlPhaseStartTest "bug782976: SUDO: --users and --groups should detect values such as \"ALL\" and error appropriately"

	rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=782976"

        TmpDir=`mktemp -d`
        pushd $TmpDir

	rlRun "ipa sudorule-add bug782976 --usercat=all > $TmpDir/bug782976.txt 2>&1"
	rlAssertGrep "User category: all" "$TmpDir/bug782976.txt"
	rlRun "cat $TmpDir/bug782976.txt"

	rlRun "ipa sudorule-add-user bug782976 --users=shanks > $TmpDir/bug782976.txt 2>&1" 1 
	rlAssertGrep "ipa: ERROR: users cannot be added when user category='all'" "$TmpDir/bug782976.txt"
	rlRun "cat $TmpDir/bug782976.txt"

	rlRun "ipa group-add group1 --desc=group1"
        rlRun "ipa sudorule-add-user bug782976 --groups=group1 > $TmpDir/bug782976.txt 2>&1" 1
	rlAssertGrep "ipa: ERROR: users cannot be added when user category='all'" "$TmpDir/bug782976.txt"
	rlRun "cat $TmpDir/bug782976.txt"

	rlRun "ipa sudorule-del bug782976"

	rlRun "ipa sudorule-add bug782976"
	rlRun "ipa sudorule-add-user bug782976 --users=user1"
	rlRun "ipa sudorule-mod bug782976 --usercat=all > $TmpDir/bug782976.txt 2>&1" 1
	rlAssertGrep "ipa: ERROR: user category cannot be set to 'all' while there are allowed users" "$TmpDir/bug782976.txt"
	rlRun "cat $TmpDir/bug782976.txt"

	rlRun "ipa sudorule-del bug782976"

	rlRun "ipa sudorule-add bug782976"
        rlRun "ipa sudorule-add-user bug782976 --groups=group1"
        rlRun "ipa sudorule-mod bug782976 --usercat=all > $TmpDir/bug782976.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: user category cannot be set to 'all' while there are allowed users" "$TmpDir/bug782976.txt"

	# clean up
	rlRun "ipa group-del group1"
	rlRun "ipa sudorule-del bug782976"

rlPhaseEnd
}


bug783286() {

rlPhaseStartTest "bug783286: Setting HBAC/SUDO category to Anyone doesn't remove users/groups"

        rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=783286"

        TmpDir=`mktemp -d`
        pushd $TmpDir

	rlRun "echo Secret123 | ipa user-add shanks --first=shanks --last=r --password"
	rlRun "ipa group-add group1 --desc=group1"
	rlRun "ipa sudocmd-add /bin/ls"

        rlRun "ipa sudorule-add bug783286 --usercat=all > $TmpDir/bug783286.txt 2>&1"
        rlAssertGrep "User category: all" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"
	rlRun "ipa sudorule-add-host bug783286 --hosts=$HOSTNAME"

        rlRun "ipa sudorule-add-user bug783286 --users=shanks > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: users cannot be added when user category='all'" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"

        rlRun "ipa sudorule-add-user bug783286 --groups=group1 > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: users cannot be added when user category='all'" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"

        rlRun "ipa sudorule-del bug783286"

        rlRun "ipa sudorule-add bug783286"
        rlRun "ipa sudorule-add-user bug783286 --users=shanks"
        rlRun "ipa sudorule-mod bug783286 --usercat=all > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: user category cannot be set to 'all' while there are allowed users" "$TmpDir/bug783286.txt"

        rlRun "ipa sudorule-del bug783286"

        rlRun "ipa sudorule-add bug783286"
        rlRun "ipa sudorule-add-user bug783286 --groups=group1"
        rlRun "ipa sudorule-mod bug783286 --usercat=all > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: user category cannot be set to 'all' while there are allowed users" "$TmpDir/bug783286.txt"

        # clean up
        rlRun "ipa group-del group1"
	rlRun "ipa user-del shanks"
	rlRun "ipa sudocmd-del /bin/ls"
        rlRun "ipa sudorule-del bug783286"

}

bug800537() {

rlPhaseStartTest "bug800537: Sudo commands with special characters cannot be removed from command groups"

        rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=800537"

        TmpDir=`mktemp -d`
        pushd $TmpDir

        rlRun "ipa sudocmd-add \"/bin/ls /lost+found\""
        rlRun "ipa sudocmd-add \"/bin/cp\""
        rlRun "ipa sudocmdgroup-add a-group --desc=g1"
        rlRun "ipa sudocmdgroup-add-member a-group --sudocmds=\"/bin/ls /lost+found\""
        rlRun "ipa sudocmdgroup-remove-member a-group --sudocmds=\"/bin/ls /lost+found\""
        rlRun "ipa sudocmdgroup-del a-group"

        rlRun "ipa sudocmd-add \"/bin/ls /tmp/test\ dir\""
        rlRun "ipa sudocmdgroup-add b-group --desc=g2"
        rlRun "ipa sudocmdgroup-add-member b-group --sudocmds=\"/bin/ls /tmp/test\ dir\""
        rlRun "ipa sudocmdgroup-remove-member b-group --sudocmds=\"/bin/ls /tmp/test\ dir\""
        rlRun "ipa sudocmdgroup-del b-group"

        rlRun "ipa sudocmd-add \"/bin/ls\""
        rlRun "ipa sudocmdgroup-add c-group --desc=g3"
	rlRun "ipa sudocmdgroup-add-member c-group --sudocmds=\"/bin/ls, /bin/cp\""
	rlRun "ipa sudocmdgroup-remove-member c-group --sudocmds=\"/bin/ls, /bin/cp\""
	rlRun "ipa sudocmdgroup-del c-group"

	rlRun "ipa sudocmd-del \"/bin/ls\""
	rlRun "ipa sudocmd-del \"/bin/cp\""
	rlRun "ipa sudocmd-del \"/bin/ls /tmp/test\ dir\""
	rlRun "ipa sudocmd-del \"/bin/ls /lost+found\""
	
rlPhaseEnd
}

bug800544() {

rlPhaseStartTest "Bug 800544 - Sudo commands are case-insensitive"

	rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=800544"

	rlRun "ipa sudocmd-add /usr/bin/X"
	rlRun "ipa sudocmd-add /usr/bin/x"

	rlRun "ipa sudocmdgroup-add group800544 --desc=blabla"
	rlRun "ipa sudocmdgroup-add-member group800544 --sudocmds=/usr/bin/X"
	rlRun "ipa sudocmdgroup-add-member group800544 --sudocmds=/usr/bin/x"

	rlRun "ipa sudocmdgroup-remove-member group800544 --sudocmds=/usr/bin/X"
	rlRun "ipa sudocmdgroup-remove-member group800544 --sudocmds=/usr/bin/x"

	rlRun "ipa sudocmd-del /usr/bin/x"
	rlRun "ipa sudocmd-del /usr/bin/X"

	rlRun "ipa sudocmdgroup-del group800544"

rlPhaseEnd
}
