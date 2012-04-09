#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbacrule-cli
#   Description: IPA Host Based Access Control (HBAC) CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Author: Gowrishankar Rajaiyan <grajaiya@redhat.com>
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
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"
servicegroup="remote_access"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-hbacrule-cli-startup: Check for admintools package and Kinit"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

    rlPhaseEnd


    rlPhaseStartTest "ipa bug 783286 - Setting HBAC/SUDO category to Anyone doesn't remove users/groups"

        rlRun "echo Secret123 | ipa user-add $user1 --first=$user1 --last=r --password"
        rlRun "ipa group-add group1 --desc=group1"

        rlRun "ipa hbacrule-add bug783286 --usercat=all > $TmpDir/bug783286.txt 2>&1"
        rlAssertGrep "User category: all" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"
        rlRun "ipa hbacrule-add-host bug783286 --hosts=$HOSTNAME"

        rlRun "ipa hbacrule-add-user bug783286 --users=$user1 > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: users cannot be added when user category='all'" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"

        rlRun "ipa hbacrule-add-user bug783286 --groups=group1 > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: users cannot be added when user category='all'" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"

        rlRun "ipa hbacrule-del bug783286"

        rlRun "ipa hbacrule-add bug783286"
        rlRun "ipa hbacrule-add-user bug783286 --users=$user1"
        rlRun "ipa hbacrule-mod bug783286 --usercat=all > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: user category cannot be set to 'all' while there are allowed users" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"

        rlRun "ipa hbacrule-del bug783286"

        rlRun "ipa hbacrule-add bug783286"
        rlRun "ipa hbacrule-add-user bug783286 --groups=group1"
        rlRun "ipa hbacrule-mod bug783286 --usercat=all > $TmpDir/bug783286.txt 2>&1" 1
        rlAssertGrep "ipa: ERROR: user category cannot be set to 'all' while there are allowed users" "$TmpDir/bug783286.txt"
        rlRun "cat $TmpDir/bug783286.txt"

        # clean up
        rlRun "ipa group-del group1"
        rlRun "ipa hbacrule-del bug783286"
        rlRun "ipa user-del $user1"

    rlPhaseEnd


	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
