#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-show
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-show      Display the properties of a SELinux User Map rule. 
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
selinuxusermap5="testselinuxusermap5"
selinuxusermap6="testselinuxusermap6"
selinuxusermap7="testselinuxusermap7"

default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"
servicegroup="remote_access"

########################################################################

run_selinuxusermap_show_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-show-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-show-configtest: ipa help selinuxusermap-show"
	rlRun "ipa help selinuxusermap-show > $TmpDir/selinuxusermap-show_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "Purpose: Display the properties of a SELinux User Map rule." "$TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-show NAME \[options\]" "$TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "Positional arguments:
  NAME        Rule name" "$TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "\--rights    Display the access rights of this entry (requires --all). See
              ipa man page for details." "$TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "\--all       Retrieve and print all attributes from the server. Affects
              command output." "$TmpDir/selinuxusermap-show_cfg.out"
	rlAssertGrep "\--raw       Print entries as stored on the server. Only affects output
              format." "$TmpDir/selinuxusermap-show_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-show-001: Show selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "ipa selinuxusermap-show $selinuxusermap1 > $TmpDir/selinuxusermap-show_test1.out" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-show"
	rlRun "cat $TmpDir/selinuxusermap-show_test1.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-show_test1.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-show-002: Show selinuxusermap that doesn't exist"
	command="ipa selinuxusermap-show  doesntexist"
        expmsg="ipa: ERROR: doesntexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that doesn't exist" 
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-show-003: Show selinuxuser map when a  hbacrule associated" 
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxuserma2" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap2" 0 "Add a selinuxusermap with hbacrule"
        rlRun "ipa selinuxusermap-show $selinuxusermap2 > $TmpDir/selinuxusermap-show_test3.out" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-show"
	rlRun "cat $TmpDir/selinuxusermap-show_test3.out"
	rlAssertGrep "Rule name: $selinuxusermap2" "$TmpDir/selinuxusermap-show_test3.out"
	rlAssertGrep "HBAC Rule: testHbacRule" "$TmpDir/selinuxusermap-show_test3.out"
    rlPhaseEnd

   rlPhaseStartTest "ipa-selinuxusermap-show-004: Show selinuxuser map with --rights and --all option"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" --hbacrule=allow_all  --desc=\"some description\" $selinuxusermap3"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" --hbacrule=allow_all --desc=\"some description\" $selinuxusermap3" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-show --rights --all $selinuxusermap3 > $TmpDir/selinuxusermap-show_test4.out" 0 "Show selinuxusermap with  --rights --all $selinuxusermap3"
        rlRun "cat $TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "SELinux User: guest_u:s0" "$TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "Description: some description" "$TmpDir/selinuxusermap-show_test4.out"
        rlAssertGrep "attributelevelrights: {'cn': u'rscwo', 'description': u'rscwo', 'usercategory': u'rscwo', 'aci': u'rscwo', 'accesstime': u'rscwo', 'memberuser': u'rscwo', 'ipaselinuxuser': u'rscwo', 'hostcategory': u'rscwo', 'ipauniqueid': u'rsc', 'ipaenabledflag': u'rscwo', 'memberhost': u'rscwo', 'nsaccountlock': u'rscwo', 'seealso': u'rscwo'}" "$TmpDir/selinuxusermap-show_test4.out"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-show-005: Show selinuxuser map with --rights, no --all option"
        rlRun "ipa selinuxusermap-show --rights $selinuxusermap3 > $TmpDir/selinuxusermap-show_test5.out" 0 "Show selinuxusermap with  --rights $selinuxusermap3"
        rlRun "cat $TmpDir/selinuxusermap-show_test5.out"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-show_test5.out"
        rlAssertGrep "SELinux User: guest_u:s0" "$TmpDir/selinuxusermap-show_test5.out"
        rlAssertGrep "Enabled: TRUE" "$TmpDir/selinuxusermap-show_test5.out"
        rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-show_test5.out"
        rlAssertGrep "Description: some description" "$TmpDir/selinuxusermap-show_test5.out"
        rlAssertNotGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-show_test5.out"
        rlAssertNotGrep "attributelevelrights: {'cn': u'rscwo', 'description': u'rscwo', 'usercategory': u'rscwo', 'aci': u'rscwo', 'accesstime': u'rscwo', 'memberuser': u'rscwo', 'ipaselinuxuser': u'rscwo', 'hostcategory': u'rscwo', 'ipauniqueid': u'rsc', 'ipaenabledflag': u'rscwo', 'memberhost': u'rscwo', 'nsaccountlock': u'rscwo', 'seealso': u'rscwo'}" "$TmpDir/selinuxusermap-show_test5.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-show-006: Show selinuxuser map with --all option"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" --hbacrule=allow_all --desc=\"some description\" $selinuxusermap4" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" --hbacrule=allow_all --desc=\"some description\" $selinuxusermap4" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-show --all $selinuxusermap4 > $TmpDir/selinuxusermap-show_test6.out" 0 "Show selinuxusermap with --all $selinuxusermap4"
        rlRun "cat $TmpDir/selinuxusermap-show_test6.out"
	rlAssertGrep "Rule name: $selinuxusermap4" "$TmpDir/selinuxusermap-show_test6.out"
	rlAssertGrep "SELinux User: guest_u:s0" "$TmpDir/selinuxusermap-show_test6.out"
	rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-show_test6.out"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/selinuxusermap-show_test6.out"
	rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-show_test6.out"
	rlAssertGrep "Description: some description" "$TmpDir/selinuxusermap-show_test6.out"
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-selinuxusermap-show-007: Show selinuxusermap --all with not an existing selinuxusermap"
	command="ipa selinuxusermap-show --all donotexist"
        expmsg="ipa: ERROR: donotexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that doesn't exist" 
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-selinuxusermap-show-008: Show selinuxuser map with --raw option"
        rlRun "ipa selinuxusermap-show --raw $selinuxusermap4 > $TmpDir/selinuxusermap-show_test8.out" 0 "Show selinuxusermap with --raw $selinuxusermap4"
        rlRun "cat $TmpDir/selinuxusermap-show_test8.out"
        rlAssertGrep "cn: $selinuxusermap4" "$TmpDir/selinuxusermap-show_test8.out"
        rlAssertGrep "ipaselinuxuser: guest_u:s0" "$TmpDir/selinuxusermap-show_test8.out"
        rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/selinuxusermap-show_test8.out"
        rlAssertGrep "description: some description" "$TmpDir/selinuxusermap-show_test8.out"

	rlRun "ipa selinuxusermap-show --raw --all $selinuxusermap4 > $TmpDir/selinuxusermap-show_test8_raw_all.out" 0 "Find selinuxusermap with --all --raw $selinuxusermap4"
        rlRun "cat $TmpDir/selinuxusermap-show_test8_raw_all.out"
        rlAssertGrep "cn: $selinuxusermap4" "$TmpDir/selinuxusermap-show_test8_raw_all.out"
        rlAssertGrep "ipaselinuxuser: guest_u:s0" "$TmpDir/selinuxusermap-show_test8_raw_all.out"
        rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/selinuxusermap-show_test8_raw_all.out"
        rlAssertGrep "description: some description" "$TmpDir/selinuxusermap-show_test8_raw_all.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-show_test8_raw_all.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-show_test8_raw_all.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-show-009: Show selinuxusermap --raw with not an existing selinuxusermap"
	command="ipa selinuxusermap-show --raw donotexist"
        expmsg="ipa: ERROR: donotexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that doesn't exist" 
	command="ipa selinuxusermap-show --raw --all donotexist"
        expmsg="ipa: ERROR: donotexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that doesn't exist" 
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-show-cleanup: Destroying admin credentials."
	# delete all selinux user
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
