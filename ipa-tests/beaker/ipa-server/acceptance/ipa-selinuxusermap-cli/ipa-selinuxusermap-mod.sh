#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-mod
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-mod     Modify a SELinux User Map  
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
selinuxusermap8="testselinuxusermap8"
selinuxusermap9="testselinuxusermap9"
selinuxusermap10="testselinuxusermap10"
selinuxusermap11="testselinuxusermap11"
selinuxusermap12="testselinuxusermap12"
selinuxusermap13="testselinuxusermap13"
selinuxusermap14="testselinuxusermap14"

default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"
servicegroup="remote_access"

########################################################################

run_selinuxusermap_mod_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-mod-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-mod-configtest: ipa help selinuxusermap-mod"
	rlRun "ipa help selinuxusermap-mod > $TmpDir/selinuxusermap-mod_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "Purpose: Modify a SELinux User Map." "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-mod NAME \[options\]" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "NAME               Rule name" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\-h, \--help         show this help message and exit" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--selinuxuser=STR  SELinux User" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--hbacrule=STR     HBAC Rule that defines the users, groups and hostgroups" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--usercat=\['all'\]  User category the rule applies to" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--hostcat=\['all'\]  Host category the rule applies to" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--desc=STR         Description" "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--setattr=STR      Set an attribute to a name/value pair. Format is
                     attr=value. For multi-valued attributes, the command
                     replaces the values already present." "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--addattr=STR      Add an attribute/value pair. Format is attr=value. The
                     attribute must be part of the schema." "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--delattr=STR      Delete an attribute/value pair. The option will be
                     evaluated last, after all sets and adds.
  --rights           Display the access rights of this entry (requires --all)." "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--rights           Display the access rights of this entry (requires --all).
                     See ipa man page for details." "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--all              Retrieve and print all attributes from the server.
                     Affects command output." "$TmpDir/selinuxusermap-mod_cfg.out"
	rlAssertGrep "\--raw              Print entries as stored on the server. Only affects
                     output format." "$TmpDir/selinuxusermap-mod_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-mod-001: Modify a selinuxuser"
        rlRun "addSelinuxusermap $default_selinuxuser $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "ipa selinuxusermap-find --name=$selinuxusermap1" 0 "Verifying selinuxusermap was added."
	rlRun "ipa selinuxusermap-mod --selinuxuser=guest_u:s0 $selinuxusermap1 > $TmpDir/selinuxusermap-mod_test1.out" 0 "Modify selinuxusermap with --selinuxuser=guest_u:s0"
	rlRun "cat $TmpDir/selinuxusermap-mod_test1.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-mod_test1.out"
	rlRun "ipa selinuxusermap-find --selinuxuser=guest_u:s0 $selinuxusermap1" 0 "Verifying selinuxusermap was added with selinuxuser guest_u:s0"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-002: Modify with a selinuxuser that does not exist"
	command="ipa selinuxusermap-mod --selinuxuser=doesntexist $selinuxusermap1"
        expmsg="ipa: ERROR: invalid 'selinuxuser': Invalid MLS value, must match s[0-15](-s[0-15])"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxuser type that does not exist"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-003: Modify with a selinuxuser with a empty selinuxuser"
        command="ipa selinuxusermap-mod --selinuxuser=\"\" $selinuxusermap1"
        expmsg="ipa: ERROR: 'selinuxuser' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for a empty selinuxuser string"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-004: Modify selinuxusermap that doesn't exist"
	command="ipa selinuxusermap-mod  --selinuxuser=unconfined_u:s0-s0:c0.c1023 doesntexist"
        expmsg="ipa: ERROR: doesntexist: SELinux User Map rule not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap that does not exist"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-005: Modify selinuxuser map with User Category 'all'"
	rlRun "ipa selinuxusermap-mod --usercat=all $selinuxusermap1 > $TmpDir/selinuxusermap-mod_test5.out" 0 "Modify selinuxusermap with --usercat='all'"
	rlRun "cat $TmpDir/selinuxusermap-mod_test5.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-mod_test5.out"
	rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-mod_test5.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-006: Modify selinuxusermap with unknown User Category"
        command="ipa selinuxusermap-mod --usercat=deny $selinuxusermap1"
        expmsg="ipa: ERROR: invalid 'usercat': must be 'all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown User Category"
	rlRun "ipa selinuxusermap-find --usercat=all $selinuxusermap1" 0 "Verifying selinuxusermap with --usercat=all is not modifed."
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-mod-007: Modify selinuxuser map with empty User Category"
        rlRun "ipa selinuxusermap-mod --usercat=\"\" $selinuxusermap1 > $TmpDir/selinuxusermap-mod_test7.out" 0 "Modify selinuxusermap with --usercat=\"\""
        rlRun "cat $TmpDir/selinuxusermap-mod_test7.out"
        rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-mod_test7.out"
        rlAssertNotGrep "User category: all" "$TmpDir/selinuxusermap-mod_test7.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-008: Modify selinuxuser map with Host Category 'all'"
	rlRun "ipa selinuxusermap-mod --hostcat=all $selinuxusermap1 > $TmpDir/selinuxusermap-mod_test8.out" 0 "Modify selinuxusermap with --hostcat='all'"
	rlRun "cat $TmpDir/selinuxusermap-mod_test8.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-mod_test8.out"
	rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test8.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-009: Modify selinuxusermap with unknown Host Category"
        command="ipa selinuxusermap-mod --hostcat=deny $selinuxusermap1"
        expmsg="ipa: ERROR: invalid 'hostcat': must be 'all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
	rlRun "ipa selinuxusermap-find --hostcat=all $selinuxusermap1" 0 "Verifying selinuxusermap with --hostcat=all is not modifed."
    rlPhaseEnd

   rlPhaseStartTest "ipa-selinuxusermap-mod-010: Modify selinuxuser map with empty Host Category"
        rlRun "ipa selinuxusermap-mod --hostcat=\"\" $selinuxusermap1 > $TmpDir/selinuxusermap-mod_test10.out" 0 "Modify selinuxusermap with --hostcat=\"\""
        rlRun "cat $TmpDir/selinuxusermap-mod_test10.out"
        rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-mod_test10.out"
        rlAssertNotGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test10.out"
    rlPhaseEnd 

    rlPhaseStartTest "ipa-selinuxusermap-mod-011: Modify selinuxusermap with hbacrule" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap2 --desc=\"some description\"" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
	rlRun "ipa selinuxusermap-mod --hbacrule=testHbacRule $selinuxusermap2 > $TmpDir/selinuxusermap-mod_test11.out" 0 "Modify selinuxusermap with \--hbacrule=testHbacRule"
	rlRun "cat $TmpDir/selinuxusermap-mod_test11.out"
	rlAssertGrep "Rule name: $selinuxusermap2" "$TmpDir/selinuxusermap-mod_test11.out"
	rlAssertGrep "HBAC Rule: testHbacRule" "$TmpDir/selinuxusermap-mod_test11.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-012: Modify selinuxusermap with hbacrule when user and host categories set"
	#usercat=all
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap3 --usercat=all --desc=\"selinuxusermap with usercat set\"" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "addHBACRule all all all all testHbacRule2" 0 "Adding HBAC rule."
        rlRun "findHBACRuleByOption name testHbacRule2 testHbacRule2" 0 "Finding rule testHbacRule2 by name"
        command="ipa selinuxusermap-mod --hbacrule=testHbacRule2 $selinuxusermap3"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"

	#hostcat=all
	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap4 --hostcat=all --desc=\"selinuxusermap with hostcat set\"" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        command="ipa selinuxusermap-mod --hbacrule=testHbacRule2 $selinuxusermap4"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
	
	#usercat=all and hostcat=all
	rlRun "ipa selinuxusermap-mod --hostcat=all --usercat=all $selinuxusermap1 > $TmpDir/selinuxusermap-mod_test12.out" 0 "Modify selinuxusermap with --hostcat='all' and usercat='all'"
	rlRun "cat $TmpDir/selinuxusermap-mod_test12.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-mod_test12.out"
	rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test12.out"
	rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-mod_test12.out"
	command="ipa selinuxusermap-mod --hbacrule=testHbacRule2 $selinuxusermap1"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-013: Modify selinuxusermap with --usercat=all when hbacrule is set"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=allow_all --desc=\"Selinuxusermap with habc rule\" $selinuxusermap5" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap5" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	command="ipa selinuxusermap-mod --usercat=all $selinuxusermap5"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
#        rlRun "ipa selinuxusermap-mod --usercat=all $selinuxusermap5 > $TmpDir/selinuxusermap-mod_test13.out" 0 "Modify selinuxusermap with \--usercat=all"
#        rlRun "cat $TmpDir/selinuxusermap-mod_test13.out"
#       rlAssertGrep "Rule name: $selinuxusermap5" "$TmpDir/selinuxusermap-mod_test13.out"
#      rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-mod_test13.out"
#      rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-mod_test13.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-014: Modify selinuxusermap with --hostcat=all when hbacrule is set"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=allow_all --desc=\"Selinuxusermap with habc rule\" $selinuxusermap6" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap6" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        command="ipa selinuxusermap-mod --hostcat=all $selinuxusermap6"
        expmsg="ipa: ERROR: HBAC rule and local members cannot both be set"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
#Waiting for rcrit - to decide the expected behavior
#        rlRun "ipa selinuxusermap-mod --usercat=all $selinuxusermap6 > $TmpDir/selinuxusermap-mod_test14.out" 0 "Modify selinuxusermap with \--usercat=all"
#        rlRun "cat $TmpDir/selinuxusermap-mod_test14.out"
#       rlAssertGrep "Rule name: $selinuxusermap6" "$TmpDir/selinuxusermap-mod_test14.out"
#      rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-mod_test14.out"
#      rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test14.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-015: Modify selinuxuser map with --desc option"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap7" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap7" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap7" 0 "Add host $host1 to selinuxusermap"
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap7" 0 "Add user $user1 to selinuxusermap"
	rlRun "ipa selinuxusermap-mod --desc=\"new description\" $selinuxusermap7 > $TmpDir/selinuxusermap-mod_test15.out" 0 "Modify selinuxusermap with \--desc=new description"
	rlRun "cat $TmpDir/selinuxusermap-mod_test15.out"
	rlAssertGrep "Rule name: $selinuxusermap7" "$TmpDir/selinuxusermap-mod_test15.out"
	rlAssertGrep "Description: new description" "$TmpDir/selinuxusermap-mod_test15.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-016: Modify selinuxuser map with --desc option, replace the existing value"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --desc=\"some description\" $selinuxusermap8" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap8" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "ipa selinuxusermap-mod --desc=\"new description\" $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test16.out" 0 "Modify selinuxusermap with \--desc=new description"
        rlRun "cat $TmpDir/selinuxusermap-mod_test16.out"
        rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test16.out"
        rlAssertGrep "Description: new description" "$TmpDir/selinuxusermap-mod_test16.out"
        rlAssertNotGrep "Description: some description" "$TmpDir/selinuxusermap-mod_test16.out"
    rlPhaseEnd

    
     rlPhaseStartTest "ipa-selinuxusermap-mod-017: Modify selinuxuser map with --setattr option on attr not in schema"
 	command="ipa selinuxusermap-mod --setattr=newattr=deny $selinuxusermap8"
         expmsg="ipa: ERROR: attribute "newattr" not allowed"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
         rlRun "ipa selinuxusermap-find $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test17.out" 0 "Find selinuxuser map"
         rlRun "cat $TmpDir/selinuxusermap-mod_test17.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test17.out"
         rlAssertGrep "Description: new description" "$TmpDir/selinuxusermap-mod_test17.out"
     rlPhaseEnd
 
     rlPhaseStartTest "ipa-selinuxusermap-mod-018: Modify with  --setattr - on attribute that's in schema [BZ 895256]"
         rlRun "ipa selinuxusermap-mod --setattr=description=newselinuxdescription $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test18.out" 0 "Modify selinuxuser map with --setattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test18.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test18.out"
         rlAssertGrep "Description: newselinuxdescription" "$TmpDir/selinuxusermap-mod_test18.out"
 	
 	 rlRun "ipa selinuxusermap-mod --setattr=usercategory=all $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test18_2.out" 0 "Modify selinuxuser map with --setattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test18_2.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test18_2.out"
         rlAssertGrep "Description: newselinuxdescription" "$TmpDir/selinuxusermap-mod_test18_2.out"
 	 rlAssertNotGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test18_2.out"
 	 rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-mod_test18_2.out"
 
 	 rlRun "ipa selinuxusermap-mod --setattr=hostcategory=all $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test18_3.out" 0 "Modify selinuxuser map with --setattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test18_3.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test18_3.out"
         rlAssertGrep "Description: newselinuxdescription" "$TmpDir/selinuxusermap-mod_test18_3.out"
         rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test18_3.out"
         rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-mod_test18_3.out"
 
 	#Question for rcrit for the behavior - shouldn't seealso accept user friendly names instead of DN
         rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --desc=\"some description\" $selinuxusermap9" 0 "Add a selinuxusermap"
 	#get hbacrule DN for hbacrule allow_all
 	#rlRun "ipa hbacrule-show --all allow_all > $TmpDir/selinuxusermap-mod_test18_4.out" 0 "hbacrule show for allow_all"
 	#hbacrule_dn_allow_all=`cat $TmpDir/selinuxusermap-mod_test18_4.out | grep dn:`
	#hbacrule_dn=`echo $hbacrule_dn_allow_all | cut -d " " -f 3`
	rlRun "ipa hbacrule-show --all allow_all" 0 "hbacrule show for allow_all"
	hbacrule_dn=$(ipa hbacrule-find allow_all --all --raw|grep "dn:"|awk '{print $2}')
	rlLog "hbacrule DN: $hbacrule_dn"
 	rlRun "ipa selinuxusermap-mod --setattr=seealso=$hbacrule_dn $selinuxusermap9 > $TmpDir/selinuxusermap-mod_test18_5.out 2>&1" 0 "Modify selinuxuser map with --setattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test18_5.out"
         rlAssertGrep "Rule name: $selinuxusermap9" "$TmpDir/selinuxusermap-mod_test18_5.out"
         rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-mod_test18_5.out"

		tmpout=$TmpDir/selinuxusermap-mod_test18_5.out
		rlAssertNotGrep "ipa: ERROR: invalid 'seealso': must be Unicode text" $tmpout
		if [ $? -eq 1 ]; then
			rlFail "BZ 895256 found...ipa selinuxusermap-mod seealso must be unicode error"
		else
			rlPass "BZ 895256 not found"
		fi
 
 	rlRun "ipa selinuxusermap-mod --setattr=ipaenabledflag=false $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test18_6.out" 0 "Modify selinuxuser map with --setattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test18_6.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test18_6.out"
         rlAssertGrep "Enabled: FALSE" "$TmpDir/selinuxusermap-mod_test18_6.out"
     rlPhaseEnd
 
     rlPhaseStartTest "ipa-selinuxusermap-mod-019: Modify with --setattr - on a attribute that's already set"
 	rlRun "ipa selinuxusermap-mod --setattr=ipaselinuxuser=guest_u:s0 $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test19.out" 0 "Modify with --setattr - on a attribute that's already set"
         rlRun "cat $TmpDir/selinuxusermap-mod_test19.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test19.out"
         rlAssertGrep "SELinux User: guest_u:s0" "$TmpDir/selinuxusermap-mod_test19.out"	
     rlPhaseEnd
 
     rlPhaseStartTest "ipa-selinuxusermap-mod-020: Modify with --setattr - use non existing ipaselinuxuser"
 	expmsg="ipa: ERROR: invalid 'ipaselinuxuser': Invalid MLS value, must match s[0-15](-s[0-15])"
         command="ipa selinuxusermap-mod --setattr=ipaselinuxuser=deny $selinuxusermap8"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
         rlRun "ipa selinuxusermap-find $selinuxusermap8 > $TmpDir/selinuxusermap-mod_test20.out" 0 "find selinuxuser"
         rlRun "cat $TmpDir/selinuxusermap-mod_test20.out"
         rlAssertGrep "Rule name: $selinuxusermap8" "$TmpDir/selinuxusermap-mod_test20.out"
         rlAssertGrep "SELinux User: guest_u:s0" "$TmpDir/selinuxusermap-mod_test20.out"
     rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-021: Modify with --addattr on attr that's not set"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap10" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap10" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
 	rlRun "ipa selinuxusermap-mod --addattr=description=newselinuxusermapdescription  $selinuxusermap10 > $TmpDir/selinuxusermap-mod_test21.out" 0 "Modify with --addattr"
        rlRun "cat $TmpDir/selinuxusermap-mod_test21.out"
        rlAssertGrep "Rule name: $selinuxusermap10" "$TmpDir/selinuxusermap-mod_test21.out"
        rlAssertGrep "Description: newselinuxusermapdescription" "$TmpDir/selinuxusermap-mod_test21.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-022: Modify with --setattr and --addattr on description [BZ 895256]"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap11" 0 "Add selinuxuser rule"
 	rlRun "ipa selinuxusermap-mod --setattr=description=selinuxusermapdescription  $selinuxusermap11" 0 "Modify with --setattr"
        expmsg="ipa: ERROR: description: Only one value allowed."
        command="ipa selinuxusermap-mod --addattr=description=newselinuxusermapdescription  $selinuxusermap11"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."

	#rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=newHbacRule $selinuxusermap12" 0 "Add selinuxuser rule"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap12" 0 "Add selinuxuser rule"

        #get hbacrule DN for hbacrule allow_all
        #rlRun "ipa hbacrule-show --all allow_all > $TmpDir/selinuxusermap-mod_test22_2.out" 0 "hbacrule show for allow_all"
        #hbacrule_dn_allow_all=`cat $TmpDir/selinuxusermap-mod_test22_2.out | grep dn:`
        #hbacrule_dn=`echo $hbacrule_dn_allow_all | cut -d " " -f 3`
        rlRun "ipa hbacrule-show --all allow_all" 0 "hbacrule show for allow_all"
        hbacrule_dn=$(ipa hbacrule-find allow_all --all --raw|grep "dn:"|awk '{print $2}')
        rlLog "hbacrule DN: $hbacrule_dn"

        expmsg="ipa: ERROR: seealso: Only one value allowed."
        command="ipa selinuxusermap-mod --addattr=seealso=$hbacrule_dn $selinuxusermap12"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
		tmpout=/tmp/errormsg.out
		rlAssertNotGrep "ipa: ERROR: invalid 'seealso': must be Unicode text" $tmpout
		if [ $? -eq 1 ]; then
			rlFail "BZ 895256 found...ipa selinuxusermap-mod seealso must be unicode error"
		else
			rlPass "BZ 895256 not found"
		fi
		
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-mod-023: Negative: Modify with --addattr on attribute outside schema"
        expmsg="ipa: ERROR: attribute notinschema not allowed"
        command="ipa selinuxusermap-mod --addattr=notinschema=abcdef  $selinuxusermap11"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-mod-024: Modify with --addattr - use non existing ipaselinuxuser"
        expmsg="ipa: ERROR: ipaselinuxuser: Only one value allowed."
        command="ipa selinuxusermap-mod --addattr=ipaselinuxuser=deny $selinuxusermap11"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
         rlRun "ipa selinuxusermap-find $selinuxusermap11 > $TmpDir/selinuxusermap-mod_test24.out" 0 "find selinuxuser"
         rlRun "cat $TmpDir/selinuxusermap-mod_test24.out"
         rlAssertGrep "Rule name: $selinuxusermap11" "$TmpDir/selinuxusermap-mod_test24.out"
         rlAssertGrep "SELinux User: unconfined_u:s0-s0:c0.c1023" "$TmpDir/selinuxusermap-mod_test24.out"
     rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-mod-025: Modify selinuxuser map with --delattr option on attr not in schema"
         command="ipa selinuxusermap-mod --delattr=newattr=deny $selinuxusermap11"
         expmsg="ipa: ERROR: invalid 'newattr': No such attribute on this entry"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-mod-026: Modify with --delattr - on attribute that's in schema [BZ 895256]"
  	 rlRun "ipa selinuxusermap-mod --setattr=description=selinuxusermapdescription $selinuxusermap12" 0 "Modify selinuxuser map with --setattr option"
         rlRun "ipa selinuxusermap-mod --delattr=description=selinuxusermapdescription $selinuxusermap12 > $TmpDir/selinuxusermap-mod_test26.out" 0 "Modify selinuxuser map with --delattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test26.out"
         rlAssertGrep "Rule name: $selinuxusermap12" "$TmpDir/selinuxusermap-mod_test26.out"
         rlAssertNotGrep "Description: selinuxusermapdescription" "$TmpDir/selinuxusermap-mod_test26.out"

         rlRun "ipa selinuxusermap-mod --setattr=usercategory=all $selinuxusermap12" 0 "Modify selinuxuser map with --setattr option"
         rlRun "ipa selinuxusermap-mod --delattr=usercategory=all $selinuxusermap12 > $TmpDir/selinuxusermap-mod_test26_2.out" 0 "Modify selinuxuser map with --delattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test26_2.out"
         rlAssertGrep "Rule name: $selinuxusermap12" "$TmpDir/selinuxusermap-mod_test26_2.out"
         rlAssertNotGrep "User category: all" "$TmpDir/selinuxusermap-mod_test26_2.out"

         rlRun "ipa selinuxusermap-mod --setattr=hostcategory=all $selinuxusermap12" 0 "Modify selinuxuser map with --setattr option"
         rlRun "ipa selinuxusermap-mod --delattr=hostcategory=all $selinuxusermap12 > $TmpDir/selinuxusermap-mod_test26_3.out" 0 "Modify selinuxuser map with --delattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test26_3.out"
         rlAssertGrep "Rule name: $selinuxusermap12" "$TmpDir/selinuxusermap-mod_test26_3.out"
         rlAssertNotGrep "Host category: all" "$TmpDir/selinuxusermap-mod_test26_3.out"

         #get hbacrule DN for hbacrule allow_all
         #rlRun "ipa hbacrule-show --all allow_all > $TmpDir/selinuxusermap-mod_test26_4.out" 0 "hbacrule show for allow_all"
         #hbacrule_dn_allow_all=`cat $TmpDir/selinuxusermap-mod_test26_4.out | grep dn:`
         #hbacrule_dn=`echo $hbacrule_dn_allow_all | cut -d " " -f 3`
         rlRun "ipa hbacrule-show --all allow_all" 0 "hbacrule show for allow_all"
         hbacrule_dn=$(ipa hbacrule-find allow_all --all --raw|grep "dn:"|awk '{print $2}')
         rlRun "ipa selinuxusermap-mod --setattr=seealso=$hbacrule_dn $selinuxusermap12 > $TmpDir/selinuxusermap-mod_test26_5.out 2>&1" 0 "Modify selinuxuser map with --setattr option"

		tmpout=$TmpDir/selinuxusermap-mod_test26_5.out
		rlAssertNotGrep "ipa: ERROR: invalid 'seealso': must be Unicode text" $tmpout
		if [ $? -eq 1 ]; then
			rlFail "BZ 895256 found...ipa selinuxusermap-mod seealso must be unicode error"
		else
			rlPass "BZ 895256 not found"
		fi


         rlRun "ipa selinuxusermap-mod --delattr=seealso=$hbacrule_dn $selinuxusermap12 > $TmpDir/selinuxusermap-mod_test26_5.out" 0 "Modify selinuxuser map with --delattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test26_5.out"
         rlAssertGrep "Rule name: $selinuxusermap12" "$TmpDir/selinuxusermap-mod_test26_5.out"
         rlAssertNotGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-mod_test26_5.out"


         rlRun "ipa selinuxusermap-mod --delattr=ipaenabledflag=TRUE $selinuxusermap12 > $TmpDir/selinuxusermap-mod_test26_6.out" 0 "Modify selinuxuser map with --delattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test26_6.out"
         rlAssertGrep "Rule name: $selinuxusermap12" "$TmpDir/selinuxusermap-mod_test26_6.out"
         rlAssertNotGrep "Enabled: TRUE" "$TmpDir/selinuxusermap-mod_test26_6.out"

	 rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --desc=selinuxusermapdescription $selinuxusermap13" 0 "Add selinuxuser rule"
	 rlRun "ipa selinuxusermap-mod --delattr=description=selinuxusermapdescription $selinuxusermap13 > $TmpDir/selinuxusermap-mod_test26_7.out" 0 "Modify selinuxuser map with --delattr option"
         rlRun "cat $TmpDir/selinuxusermap-mod_test26_7.out"
         rlAssertGrep "Rule name: $selinuxusermap13" "$TmpDir/selinuxusermap-mod_test26_7.out"
         rlAssertNotGrep "Description: selinuxusermapdescription" "$TmpDir/selinuxusermap-mod_test26_7.out"
     rlPhaseEnd 
 
     rlPhaseStartTest "ipa-selinuxusermap-mod-027: Modify selinuxuser map with --delattr on attr that's not set"
         command="ipa selinuxusermap-mod --delattr=usercategory=all $selinuxusermap13"
         expmsg="ipa: ERROR: invalid 'usercategory': No such attribute on this entry"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-mod-028: Modify selinuxuser map with --delattr on attr value does not match"
  	 rlRun "ipa selinuxusermap-mod --setattr=description=selinuxusermapdescription $selinuxusermap13" 0 "Modify selinuxuser map with --setattr option"
         command="ipa selinuxusermap-mod --delattr=description=nodescription $selinuxusermap13"
         expmsg="ipa: ERROR: description does not contain 'nodescription'"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd 

     rlPhaseStartTest "ipa-selinuxusermap-mod-029: Modify selinuxuser map with --delattr on attr value not given"
         command="ipa selinuxusermap-mod --delattr=description=  $selinuxusermap13"
         expmsg="ipa: ERROR: description does not contain 'None'"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd
     
     rlPhaseStartTest "ipa-selinuxusermap-mod-030: Modify selinuxuser map with --all option"
         rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" --hbacrule=allow_all --usercat=all --hostcat=all --desc=\"some description\" $selinuxusermap14" 
         rlRun "ipa selinuxusermap-add --selinuxuser=\"guest_u:s0\" --hbacrule=allow_all --desc=\"some description\" $selinuxusermap14" 0 "Add a selinuxusermap"
         rlRun "ipa selinuxusermap-mod --all --hbacrule=testHbacRule $selinuxusermap14 > $TmpDir/selinuxusermap-find_test30.out" 0 "Modify selinuxusermap with --all"
   	 rlRun "cat $TmpDir/selinuxusermap-find_test30.out"
 	 rlAssertGrep "Rule name: $selinuxusermap14" "$TmpDir/selinuxusermap-find_test30.out"
 	 rlAssertGrep "SELinux User: guest_u:s0" "$TmpDir/selinuxusermap-find_test30.out"
 	 rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-find_test30.out"
 	 rlAssertGrep "Enabled: TRUE" "$TmpDir/selinuxusermap-find_test30.out"
 	 rlAssertGrep "HBAC Rule: testHbacRule" "$TmpDir/selinuxusermap-find_test30.out"
 	 rlAssertGrep "Description: some description" "$TmpDir/selinuxusermap-find_test30.out"
     rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-mod-031: Modify selinuxuser map with --all - no attributes modified"
         command="ipa selinuxusermap-mod --all $selinuxusermap14"
         expmsg="ipa: ERROR: no modifications to be performed"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd
 	
     rlPhaseStartTest "ipa-selinuxusermap-mod-032: Modify selinuxusermap --all with not an existing selinuxusermap"
         command="ipa selinuxusermap-mod --all donotexist"
         expmsg="ipa: ERROR: donotexist: SELinux User Map rule not found"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd
 	
     rlPhaseStartTest "ipa-selinuxusermap-mod-033: Modify selinuxuser map with --raw option"
	 #get hbacrule DN for hbacrule allow_all
         rlRun "ipa hbacrule-show --all allow_all > $TmpDir/selinuxusermap-mod_test22_2.out" 0 "hbacrule show for allow_all"
         hbacrule_dn_allow_all=`cat $TmpDir/selinuxusermap-mod_test22_2.out | grep dn:`
         hbacrule_dn=`echo $hbacrule_dn_allow_all | cut -d " " -f 3`

         rlRun "ipa selinuxusermap-mod --raw --hbacrule=allow_all $selinuxusermap14 > $TmpDir/selinuxusermap-mod_test33.out" 0 "Modify selinuxusermap with --raw $selinuxusermap14"
         rlRun "cat $TmpDir/selinuxusermap-mod_test33.out"
         rlAssertGrep "cn: $selinuxusermap14" "$TmpDir/selinuxusermap-mod_test33.out"
         rlAssertGrep "ipaselinuxuser: guest_u:s0" "$TmpDir/selinuxusermap-mod_test33.out"
         rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/selinuxusermap-mod_test33.out"
 	 rlAssertGrep "seealso: $hbacrule_dn" "$TmpDir/selinuxusermap-mod_test33.out"
         rlAssertGrep "description: some description" "$TmpDir/selinuxusermap-mod_test33.out"
 
 	 rlRun "ipa selinuxusermap-mod --raw --all --usercat=all $selinuxusermap13 > $TmpDir/selinuxusermap-mod_test33_raw_all.out" 0 "Modify selinuxusermap with --all --raw $selinuxusermap13"
         rlRun "cat $TmpDir/selinuxusermap-mod_test33_raw_all.out"
         rlAssertGrep "cn: $selinuxusermap13" "$TmpDir/selinuxusermap-mod_test33_raw_all.out"
         rlAssertGrep "ipaselinuxuser: unconfined_u:s0-s0:c0.c1023" "$TmpDir/selinuxusermap-mod_test33_raw_all.out"
         rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/selinuxusermap-mod_test33_raw_all.out"
         rlAssertGrep "usercategory: all" "$TmpDir/selinuxusermap-mod_test33_raw_all.out"
         rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-mod_test33_raw_all.out"
         rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-mod_test33_raw_all.out"
     rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-mod-034: Modify selinuxuser map with --raw - no attributes modified"
         command="ipa selinuxusermap-mod --raw $selinuxusermap14"
         expmsg="ipa: ERROR: no modifications to be performed"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd
     
     rlPhaseStartTest "ipa-selinuxusermap-mod-035: Modify selinuxusermap --raw with not an existing selinuxusermap"
         command="ipa selinuxusermap-mod --raw --usercat=all donotexist"
         expmsg="ipa: ERROR: donotexist: SELinux User Map rule not found"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
         command="ipa selinuxusermap-mod --raw --all --usercat=all donotexist"
         expmsg="ipa: ERROR: donotexist: SELinux User Map rule not found"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for selinuxusermap with unknown Host Category"
     rlPhaseEnd

	rlPhaseStartTest "ipa-selinuxusermap-mod-036: Modify selinuxusermap --addattr and --setattr with attr value empty [BZ 895247]"
		tmpout=/tmp/ipa-selinuxusermap-mod-036.out
		rlRun "ipa selinuxusermap-mod $selinuxusermap14 --hbacrule=allow_all" 0,1
		rlRun "ipa selinuxusermap-mod $selinuxusermap14 --addattr=seealso= > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 895247 found...ipa selinuxusermap-mod returns internal error when setting seealso empty"
		else
			rlPass "BZ 895247 not found"
		fi

		rlRun "ipa selinuxusermap-mod $selinuxusermap14 --hbacrule=allow_all" 0,1
		rlRun "ipa selinuxusermap-mod $selinuxusermap14 --setattr=seealso= > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 895247 found...ipa selinuxusermap-mod returns internal error when setting seealso empty"
		else
			rlPass "BZ 895247 not found"
		fi
	rlPhaseEnd
 
     rlPhaseStartCleanup "ipa-selinuxusermap-mod-cleanup: Destroying admin credentials."
 	# delete selinux user
         for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 $selinuxusermap5 $selinuxusermap6 $selinuxusermap7 $selinuxusermap8 $selinuxusermap9 $selinuxusermap10 $selinuxusermap11 $selinuxusermap12 $selinuxusermap13 $selinuxusermap14 ; do
                 rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
         done
 	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "ipa user-del $user1" 0 "Delete user $user1."
	rlRun "deleteHBACRule testHbacRule" 0 "Deleting testHbacRule rule"
	rlRun "deleteHBACRule testHbacRule2" 0 "Deleting testHbacRule2 rule"
	# delete service group
	rlRun "ipa hbacsvcgroup-del $servicegroup" 0 "CLEANUP: Deleting service group $servicegroup"
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
