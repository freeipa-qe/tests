#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-disable
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-disable       Disable an SELinux User Map rule.
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

run_selinuxusermap_disable_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-disable-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-disable-configtest: ipa help selinuxusermap-disable"
	rlRun "ipa help selinuxusermap-disable > $TmpDir/selinuxusermap-disable_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-disable_cfg.out"
	rlAssertGrep "Purpose: Disable an SELinux User Map rule." "$TmpDir/selinuxusermap-disable_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-disable NAME \[options\]" "$TmpDir/selinuxusermap-disable_cfg.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/selinuxusermap-disable_cfg.out"
	rlAssertGrep "NAME        Rule name" "$TmpDir/selinuxusermap-disable_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-disable-001: Disable a selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "findSelinuxusermap $selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap1" 0 "Add host $host1 to selinuxusermap"
        rlRun "ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap1" 0 "Add host group $hostgroup1 to selinuxusermap"
        rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap1" 0 "Add user $user1 to selinuxusermap"
        rlRun "ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap1" 0 "Add user group $usergroup1 to selinuxusermap"
        rlRun "disableSelinuxusermap $selinuxusermap1" 0 "Disable selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 >  $TmpDir/selinuxusermap_disable_test1.out" 0 "Selinuxusermap show"
	rlRun "cat $TmpDir/selinuxusermap_disable_test1.out"
	rlAssertGrep "Enabled: FALSE" "$TmpDir/selinuxusermap_disable_test1.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-disable-002: Disable selinuxusermap that doesn't exist"
        command="ipa selinuxusermap-disable doesnotexist"
        expmsg="ipa: ERROR: doesnotexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that doesn't exist"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-disable-003: Disable selinuxusermap that's already disabled"
        command="ipa selinuxusermap-disable $selinuxusermap1"
        expmsg="ipa: ERROR: This entry is already disabled"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for duplicate selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-disable-004: Disable selinuxuser map when User Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=all $selinuxusermap2 > $TmpDir/selinuxusermap_usercat_all.out" 0 "Add a selinuxusermap with User Category all"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlAssertGrep "User category: all" "$TmpDir/selinuxusermap_usercat_all.out"
	rlRun "disableSelinuxusermap $selinuxusermap2" 0 "Disable selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap2 >  $TmpDir/selinuxusermap_disable_test3.out" 0 "Selinuxusermap show"
        rlRun "cat $TmpDir/selinuxusermap_disable_test3.out"
         rlAssertGrep "Enabled: FALSE" "$TmpDir/selinuxusermap_disable_test3.out"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-disable-005: Disable a selinuxuser map when Host Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap3 > $TmpDir/selinuxusermap_hostcat_all.out" 0 "Add a selinuxusermap with Host Category all"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap_hostcat_all.out"
	rlRun "disableSelinuxusermap $selinuxusermap3" 0 "Disable selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap3 >  $TmpDir/selinuxusermap_disable_test4.out" 0 "Selinuxusermap show"
        rlRun "cat $TmpDir/selinuxusermap_disable_test4.out"
        rlAssertGrep "Enabled: FALSE" "$TmpDir/selinuxusermap_disable_test4.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-disable-006: Disable selinuxuser map when a hbacrule associated - hbacrule is not disabled" 
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap4" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap4" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap4" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "testHbacRule" $selinuxusermap4" 0 "Verifying selinuxusermap was added with given HbacRule"
	rlRun "disableSelinuxusermap $selinuxusermap4" 0 "Disable selinuxusermap"
        rlRun "ipa selinuxusermap-show $selinuxusermap4 >  $TmpDir/selinuxusermap_disable_test5.out" 0 "Selinuxusermap show"
        rlRun "cat $TmpDir/selinuxusermap_disable_test5.out"
        rlAssertGrep "Enabled: FALSE" "$TmpDir/selinuxusermap_disable_test5.out"
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
	# verify hbac rule is not disabled
        rlRun "verifyHBACStatus testHbacRule TRUE" 0 "Verify rule is not disabled"
	rlLog "Clean-up: ipa selinuxusermap-enable $selinuxusermap4"
        rlRun "ipa selinuxusermap-enable $selinuxusermap4"
    rlPhaseEnd

#    rlPhaseStartTest "ipa-selinuxusermap-disable-007: Disable hbacrule rule when selinux mapping rule pointing to hbacrule - both hbacrule and selinuxmap is disabled "
#	rlRun "ipa hbacrule-disable testHbacRule"
 #       rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        # verify hbac rule is disabled
  #      rlRun "verifyHBACStatus testHbacRule FALSE" 0 "Verify rule is disabled"
  #      rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap exists using ipa selinuxusermap-find"
  #      rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap4" 0 "Verifying selinuxusermap selinuxuser"
  #      rlRun "findSelinuxusermapByOption hbacrule "testHbacRule" $selinuxusermap4" 0 "Verifying selinuxusermap has pointer to HbacRule"
  #      rlRun "findSelinuxusermapByOption enabled FALSE  $selinuxusermap4" 0 "Verifying $selinuxusermap4 enabled FALSE"
  #      rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2731"
 #rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-disable-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 ; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done
	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "ipa user-del $user1" 0 "Delete user $user1."
	rlRun "deleteHBACRule testHbacRule" 0 "Deleting testHbacRule rule"
	# delete service group
	rlRun "ipa hbacsvcgroup-del $servicegroup" 0 "CLEANUP: Deleting service group $servicegroup"
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
