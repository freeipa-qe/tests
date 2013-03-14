#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-enable
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-enable       Enable an SELinux User Map rule.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Asha Akkiangady <aakkiang@redhat.com>
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
. /opt/rhqa_ipa/ipa-selinuxusermap-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

selinuxusermap1="testselinuxusermap1"

default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"

########################################################################

run_selinuxusermap_enable_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-enable-startup: Create temp directory and Kinit"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	# add host for testing
        rlRun "addHost $host1" 0 "SETUP: Adding host $host1 for testing."
        # add host group for testing
        rlRun "addHostGroup $hostgroup1 $hostgroup1" 0 "SETUP: Adding host group $hostgroup1 for testing."
        # add user for testing
        rlRun "ipa user-add --first=$user1 --last=$user1 $user1" 0 "SETUP: Adding user $user1."
        # add group for testing
        rlRun "addGroup $usergroup1 $usergroup1" 0 "SETUP: Adding user $usergroup1."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-enable-configtest: ipa help selinuxusermap-enable"
	rlRun "ipa help selinuxusermap-enable > $TmpDir/selinuxusermap-enable_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-enable_cfg.out"
	rlAssertGrep "Purpose: Enable an SELinux User Map rule." "$TmpDir/selinuxusermap-enable_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-enable NAME \[options\]" "$TmpDir/selinuxusermap-enable_cfg.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/selinuxusermap-enable_cfg.out"
	rlAssertGrep "NAME        Rule name" "$TmpDir/selinuxusermap-enable_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-enable-001: Enable a selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "findSelinuxusermap $selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap1" 0 "Add host $host1 to selinuxusermap"
	rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap1" 0 "Add host group $hostgroup1 to selinuxusermap"
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap1" 0 "Add user $user1 to selinuxusermap"
	rlRun "ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap1" 0 "Add user group $usergroup1 to selinuxusermap"
        rlRun "disableSelinuxusermap $selinuxusermap1" 0 "Disable selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 >  $TmpDir/selinuxusermap_enable_test1.out" 0 "Selinuxusermap show"
	rlAssertGrep "Enabled: FALSE" "$TmpDir/selinuxusermap_enable_test1.out"
        rlRun "enableSelinuxusermap $selinuxusermap1" 0 "enable selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 >  $TmpDir/selinuxusermap_enable_test1_2.out" 0 "Selinuxusermap show"
	rlRun "cat $TmpDir/selinuxusermap_enable_test1_2.out"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/selinuxusermap_enable_test1_2.out"
	
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-enable-002: Disable selinuxusermap that doesn't exist"
        command="ipa selinuxusermap-enable doesnotexist"
        expmsg="ipa: ERROR: doesnotexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for duplicate selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-enable-003: Enable selinuxusermap that's already enabled"
        command="ipa selinuxusermap-enable $selinuxusermap1"
        expmsg="ipa: ERROR: This entry is already enabled"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for enabled selinuxusermap"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-enable-cleanup: Destroying admin credentials."
	# delete selinux user 
	rlRun "ipa selinuxusermap-del $selinuxusermap1" 0 "CLEANUP: Deleting selinuxuser $selinuxusermap1"
	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "ipa user-del $user1" 0 "Delete user $user1."
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
