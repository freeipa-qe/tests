#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-del
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-del       Delete a SELinux User Map.
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
selinuxusermap2="testselinuxusermap2"
selinuxusermap3="testselinuxusermap3"
selinuxusermap4="testselinuxusermap4"

default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"
servicegroup="remote_access"

########################################################################

run_selinuxusermap_del_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-del-startup: Create temp directory and Kinit"
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
	# add service group
	rlRun "addHBACServiceGroup $servicegroup $servicegroup" 0 "SETUP: Adding service group $servicegroup"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-del-configtest: ipa help selinuxusermap-del"
	rlRun "ipa help selinuxusermap-del > $TmpDir/selinuxusermap-del_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-del_cfg.out"
	rlAssertGrep "Purpose: Delete a SELinux User Map." "$TmpDir/selinuxusermap-del_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-del NAME... \[options\]" "$TmpDir/selinuxusermap-del_cfg.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/selinuxusermap-del_cfg.out"
	rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/selinuxusermap-del_cfg.out"
	rlAssertGrep "NAME        Rule name" "$TmpDir/selinuxusermap-del_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-del-001: Delete a selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "findSelinuxusermap $selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "deleteSelinuxusermap $selinuxusermap1" 0 "Delete selinuxusermap"
	rlRun "findSelinuxusermap $selinuxusermap1" 1 "Verifying selinuxusermap was deleted successfully."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-del-002: Delete selinuxusermap that doesn't exist"
        command="ipa selinuxusermap-del $selinuxusermap1"
        expmsg="ipa: ERROR: $selinuxusermap1: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that doesn't exist"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-del-003: Delete selinuxuser map when User Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=all $selinuxusermap2 > $TmpDir/selinuxusermap_usercat_all.out" 0 "Add a selinuxusermap with User Category all"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlAssertGrep "User category: all" "$TmpDir/selinuxusermap_usercat_all.out"
	rlRun "deleteSelinuxusermap $selinuxusermap2" 0 "Delete selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap2" 1 "Verifying selinuxusermap was deleted successfully."
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-del-004: Delete a selinuxuser map when Host Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap3 > $TmpDir/selinuxusermap_hostcat_all.out" 0 "Add a selinuxusermap with Host Category all"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap_hostcat_all.out"
	rlRun "deleteSelinuxusermap $selinuxusermap3" 0 "Delete selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap3" 1 "Verifying selinuxusermap was deleted successfully."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-del-005: Delete selinuxuser map when a  hbacrule associated" 
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap4" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap4" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap4" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "testHbacRule" $selinuxusermap4" 0 "Verifying selinuxusermap was added with given HbacRule"
	rlRun "deleteSelinuxusermap $selinuxusermap4" 0 "Delete selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap4" 1 "Verifying selinuxusermap was deleted successfully."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-del-006: Delete selinuxuser map with --continue option"
	rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap1" 0 "Add host $host1 to selinuxusermap"
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap1" 0 "Add user $user1 to selinuxusermap"

	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=all $selinuxusermap2 > $TmpDir/selinuxusermap_usercat_all.out" 0 "Add a selinuxusermap with User Category all"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"

	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap3 > $TmpDir/selinuxusermap_hostcat_all.out" 0 "Add a selinuxusermap with Host Category all"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"

        rlRun "addHBACRule all all all all newHbacRule" 0 "Adding HBAC rule."
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=newHbacRule $selinuxusermap4"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=newHbacRule $selinuxusermap4" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "ipa selinuxusermap-del $selinuxusermap1 dummy1  $selinuxusermap2 $selinuxusermap3 dummy2 $selinuxusermap4 dummy3 --continue" 0 "Delete selinuxusermap with --continue option"
        rlRun "findSelinuxusermap $selinuxusermap1" 1 "Verifying selinuxusermap was deleted successfully."
        rlRun "findSelinuxusermap $selinuxusermap2" 1 "Verifying selinuxusermap was deleted successfully."
        rlRun "findSelinuxusermap $selinuxusermap3" 1 "Verifying selinuxusermap was deleted successfully."
        rlRun "findSelinuxusermap $selinuxusermap4" 1 "Verifying selinuxusermap was deleted successfully."
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-del-cleanup: Destroying admin credentials."
	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "ipa user-del $user1" 0 "Delete user $user1."
	rlRun "deleteHBACRule testHbacRule" 0 "Deleting testHbacRule rule"
	rlRun "deleteHBACRule newHbacRule" 0 "Deleting newHbacRule rule"
	# delete service group
	rlRun "ipa hbacsvcgroup-del $servicegroup" 0 "CLEANUP: Deleting service group $servicegroup"
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
