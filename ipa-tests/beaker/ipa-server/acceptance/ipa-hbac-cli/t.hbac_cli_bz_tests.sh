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
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh
. /opt/rhqa_ipa/ipa-hbac-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

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

bug783286() {
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
}

