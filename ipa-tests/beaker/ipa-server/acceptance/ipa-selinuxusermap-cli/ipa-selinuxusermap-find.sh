#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-find
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-find      Search for SELinux User Maps. 
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

run_selinuxusermap_find_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-find-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-find-configtest: ipa help selinuxusermap-find"
	rlRun "ipa help selinuxusermap-find > $TmpDir/selinuxusermap-find_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "Purpose: Search for SELinux User Maps." "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-find \[CRITERIA\] \[options\]" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "CRITERIA           A string searched in all relevant object attributes" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\-h, \--help         show this help message and exit" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--name=STR         Rule name" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\ --selinuxuser=STR  SELinux User" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--hbacrule=STR     HBAC Rule that defines the users, groups and hostgroups" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--usercat=\['all'\]  User category the rule applies to" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--hostcat=\['all'\]  Host category the rule applies to" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--desc=STR         Description" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--timelimit=INT    Time limit of search in seconds" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--sizelimit=INT    Maximum number of entries returned" "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--all              Retrieve and print all attributes from the server.
                     Affects command output." "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--raw              Print entries as stored on the server. Only affects
                     output format." "$TmpDir/selinuxusermap-find_cfg.out"
	rlAssertGrep "\--pkey-only        Results should contain primary key attribute only
                     ("name")" "$TmpDir/selinuxusermap-find_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-find-001:  Find a selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "ipa selinuxusermap-find --name=$selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-002:  Find a selinuxuser map for a given selinuxuser"
        rlRun "ipa selinuxusermap-find --selinuxuser=unconfined_u:s0-s0:c0.c1023 > $TmpDir/selinuxusermap-find_test2.out" 0 "Find selinuxusermap that has --selinuxuser=unconfined_u:s0-s0:c0.c1023"
	rlRun "cat $TmpDir/selinuxusermap-find_test2.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-find_test2.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-003: Find selinuxusermap that doesn't exist"
        rlRun "ipa selinuxusermap-find  --name=doesntexist > $TmpDir/selinuxusermap-find_test3.out" 1 "Find selinuxusermap that doesn't exist"
	rlRun "cat $TmpDir/selinuxusermap-find_test3.out"
	rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test3.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-004: Find selinuxuser map when User Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=all $selinuxusermap2 > $TmpDir/selinuxusermap_usercat_all.out" 0 "Add a selinuxusermap with User Category all"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-find --usercat=all > $TmpDir/selinuxusermap-find_test4.out" 0 "Find selinuxusermap that has --usercat='all'"
	rlRun "cat $TmpDir/selinuxusermap-find_test4.out"
	rlAssertGrep "Rule name: $selinuxusermap2" "$TmpDir/selinuxusermap-find_test4.out"
	rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-find_test4.out"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-find-005: Find a selinuxuser map when Host Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap3 > $TmpDir/selinuxusermap_hostcat_all.out" 0 "Add a selinuxusermap with Host Category all"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap_hostcat_all.out"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-find --hostcat=all > $TmpDir/selinuxusermap-find_test5.out" 0 "Find selinuxusermap that has --hostcat='all'"
	rlRun "cat $TmpDir/selinuxusermap-find_test5.out"
	rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-find_test5.out"
	rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap-find_test5.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-006: Find selinuxuser map when a  hbacrule associated" 
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap4" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap4" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-find --hbacrule=testHbacRule > $TmpDir/selinuxusermap-find_test6.out" 0 "Find selinuxusermap that has \--hbacrule=testHbacRule"
	rlRun "cat $TmpDir/selinuxusermap-find_test6.out"
	rlAssertGrep "Rule name: $selinuxusermap4" "$TmpDir/selinuxusermap-find_test6.out"
	rlAssertGrep "HBAC Rule: testHbacRule" "$TmpDir/selinuxusermap-find_test6.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-007: Find selinuxuser map with --desc option"
	rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --desc=\"some description\" $selinuxusermap5" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap5" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap5" 0 "Add host $host1 to selinuxusermap"
	rlRun "ipa selinuxusermap-add-user --users=$user1 $selinuxusermap5" 0 "Add user $user1 to selinuxusermap"
	rlRun "ipa selinuxusermap-find --desc=\"some description\" > $TmpDir/selinuxusermap-find_test7.out" 0 "Find selinuxusermap that has \--desc=some description"
	rlRun "cat $TmpDir/selinuxusermap-find_test7.out"
	rlAssertGrep "Rule name: $selinuxusermap5" "$TmpDir/selinuxusermap-find_test7.out"
	rlAssertGrep "Description: some description" "$TmpDir/selinuxusermap-find_test7.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-008: Find selinuxuser map with --sizelimit option"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --desc=\"some description\" $selinuxusermap6" 0 "Add a selinuxusermap"
        rlRun "findSelinuxusermap $selinuxusermap6" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "ipa selinuxusermap-find > $TmpDir/selinuxusermap-find_test8_all.out" 0 "Find selinuxusermap"
        rlRun "cat $TmpDir/selinuxusermap-find_test8_all.out"
        rlRun "ipa selinuxusermap-find --sizelimit=5 > $TmpDir/selinuxusermap-find_test8.out" 0 "Find selinuxusermap that has \--sizelimit=5 "
        rlRun "cat $TmpDir/selinuxusermap-find_test8.out"
	result=`cat $TmpDir/selinuxusermap-find_test8.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Number of selinuxusermap returned as expected with size limit of 5"
        else
                rlFail "Number of selinuxusermap returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-009: Find selinuxusermap with --sizelimit 0"
        rlRun "ipa selinuxusermap-find --sizelimit=0 > $TmpDir/selinuxusermap-find_test9.out" 0 "Find selinuxusermap that has \--sizelimit=0"
        rlRun "cat $TmpDir/selinuxusermap-find_test9.out"
	result=`cat $TmpDir/selinuxusermap-find_test9.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -ge 6 ] ; then
                rlPass "Number of selinuxusermap returned as expected with size limit of >= 6"
        else
                rlFail "Number of selinuxusermap returned is not as expected.  GOT: $number EXP: >=6"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-010: Find more selinuxusermap than exist --sizelimit 20"
        rlRun "ipa selinuxusermap-find --sizelimit=20 > $TmpDir/selinuxusermap-find_test10.out" 0 "Find selinuxusermap with \--sizelimit=20"
        rlRun "cat $TmpDir/selinuxusermap-find_test10.out"
        result=`cat $TmpDir/selinuxusermap-find_test10.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -lt 10 ] ; then
                rlPass "Number of selinuxusermap returned as expected with size limit of < 10"
        else
                rlFail "Number of selinuxusermap returned is not as expected.  GOT: $number EXP: < 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-011: Find selinuxusermap --sizelimit not an integer"
	expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa selinuxusermap-find --sizelimit=abcde"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa selinuxusermap-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-012: Find selinuxusermap with --timelimit 0, unlimited, internally."
        rlRun "ipa selinuxusermap-find --timelimit=0 > $TmpDir/selinuxusermap-find_test12.out" 0 "Find selinuxusermap that has \--timelimit=0"
        rlRun "cat $TmpDir/selinuxusermap-find_test12.out"
        result=`cat $TmpDir/selinuxusermap-find_test12.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -ge 6 ] ; then
                rlPass "Number of selinuxusermap returned as expected with timelimit=0"
        else
                rlFail "Number of selinuxusermap returned is not as expected.  GOT: $number EXP: >=6"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-013: Find selinuxusermap --timelimit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa selinuxusermap-find --timelimit=abcde"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa selinuxusermap-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-014: Find selinuxuser map with --all option"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=allow_all --desc=\"some description\" $selinuxusermap7" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=allow_all --desc=\"some description\" $selinuxusermap7" 0 "Add a selinuxusermap"
        rlRun "ipa selinuxusermap-find --all > $TmpDir/selinuxusermap-find_test14_all.out" 0 "Find selinuxusermap with --all"
	rlRun "cat $TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap6" "$TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap5" "$TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap4" "$TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap2" "$TmpDir/selinuxusermap-find_test14_all.out"
	rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-find_test14_all.out"
        rlRun "ipa selinuxusermap-find --all $selinuxusermap7 > $TmpDir/selinuxusermap-find_test14.out" 0 "Find selinuxusermap with --all $selinuxusermap7"
        rlRun "cat $TmpDir/selinuxusermap-find_test14.out"
	rlAssertGrep "Rule name: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test14.out"
	rlAssertGrep "SELinux User: unconfined_u:s0-s0:c0.c1023" "$TmpDir/selinuxusermap-find_test14.out"
	rlAssertGrep "objectclass: ipaassociation, ipaselinuxusermap" "$TmpDir/selinuxusermap-find_test14.out"
	rlAssertGrep "Enabled: TRUE" "$TmpDir/selinuxusermap-find_test14.out"
	#rlAssertGrep "User category: all" "$TmpDir/selinuxusermap-find_test14.out"
	#rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap-find_test14.out"
	rlAssertGrep "HBAC Rule: allow_all" "$TmpDir/selinuxusermap-find_test14.out"
	rlAssertGrep "Description: some description" "$TmpDir/selinuxusermap-find_test14.out"
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-selinuxusermap-find-015: Find selinuxusermap --all with not an existing selinuxusermap"
        rlRun "ipa selinuxusermap-find --all donotexist > $TmpDir/selinuxusermap-find_test15.out" 1 "Find selinuxusermap with --all donotexist"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test15.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test15.out"
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-selinuxusermap-find-016: Find selinuxuser map with --raw option"
        rlRun "ipa selinuxusermap-find --raw > $TmpDir/selinuxusermap-find_test16_all.out" 0 "Find selinuxusermap with --raw"
        rlRun "cat $TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap6" "$TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap5" "$TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap4" "$TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap3" "$TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap2" "$TmpDir/selinuxusermap-find_test16_all.out"
        rlAssertGrep "cn: $selinuxusermap1" "$TmpDir/selinuxusermap-find_test16_all.out"

        rlRun "ipa selinuxusermap-find --raw $selinuxusermap7 > $TmpDir/selinuxusermap-find_test16.out" 0 "Find selinuxusermap with --raw $selinuxusermap7"
        rlRun "cat $TmpDir/selinuxusermap-find_test16.out"
        rlAssertGrep "cn: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test16.out"
        rlAssertGrep "ipaselinuxuser: unconfined_u:s0-s0:c0.c1023" "$TmpDir/selinuxusermap-find_test16.out"
        rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/selinuxusermap-find_test16.out"
        #rlAssertGrep "usercategory: all" "$TmpDir/selinuxusermap-find_test16.out"
        #rlAssertGrep "hostcategory: all" "$TmpDir/selinuxusermap-find_test16.out"
        rlAssertGrep "description: some description" "$TmpDir/selinuxusermap-find_test16.out"

	rlRun "ipa selinuxusermap-find --raw --all $selinuxusermap7 > $TmpDir/selinuxusermap-find_test16_raw_all.out" 0 "Find selinuxusermap with --all --raw $selinuxusermap7"
        rlRun "cat $TmpDir/selinuxusermap-find_test16_raw_all.out"
        rlAssertGrep "cn: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        rlAssertGrep "ipaselinuxuser: unconfined_u:s0-s0:c0.c1023" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        rlAssertGrep "ipaenabledflag: TRUE" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        #rlAssertGrep "usercategory: all" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        #rlAssertGrep "hostcategory: all" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        rlAssertGrep "description: some description" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        rlAssertGrep "objectclass: ipaassociation" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
        rlAssertGrep "objectclass: ipaselinuxusermap" "$TmpDir/selinuxusermap-find_test16_raw_all.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-017: Find selinuxusermap --raw with not an existing selinuxusermap"
        rlRun "ipa selinuxusermap-find --raw donotexist > $TmpDir/selinuxusermap-find_test17.out" 1 "Find selinuxusermap with --raw donotexist"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test17.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test17.out"
	rlRun "ipa selinuxusermap-find --raw --all donotexist > $TmpDir/selinuxusermap-find_test17_raw_all.out" 1 "Find selinuxusermap with --all --raw donotexist"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test17_raw_all.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test17_raw_all.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-018: Find selinuxuser map with --pkey-only option"
        rlRun "ipa selinuxusermap-find --pkey-only > $TmpDir/selinuxusermap-find_test18_all.out" 0 "Find selinuxusermap with --pkey-only"
        rlRun "cat $TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap6" "$TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap5" "$TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap4" "$TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap3" "$TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap2" "$TmpDir/selinuxusermap-find_test18_all.out"
        rlAssertGrep "Rule name: $selinuxusermap1" "$TmpDir/selinuxusermap-find_test18_all.out"

        rlRun "ipa selinuxusermap-find --pkey-only $selinuxusermap7 > $TmpDir/selinuxusermap-find_test18.out" 0 "Find selinuxusermap with --pkey-only $selinuxusermap7"
        rlRun "cat $TmpDir/selinuxusermap-find_test18.out"
        rlAssertGrep "Rule name: $selinuxusermap7" "$TmpDir/selinuxusermap-find_test18.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-019: Find selinuxusermap --pkey-only with not an existing selinuxusermap"
        rlRun "ipa selinuxusermap-find --pkey-only donotexist > $TmpDir/selinuxusermap-find_test19.out" 1 "Find selinuxusermap with --pkey-only donotexist"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test19.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test19.out"
	# delete selinux user
        for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 $selinuxusermap5 $selinuxusermap6 $selinuxusermap7 ; do
                rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
        done
    rlPhaseEnd
     
    rlPhaseStartTest "ipa-selinuxusermap-find-020: Find selinuxusermap --all when there is no selinuxusermap"
        rlRun "ipa selinuxusermap-find --all > $TmpDir/selinuxusermap-find_test20.out" 1 "Find selinuxusermap with --all"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test20.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test20.out"
    rlPhaseEnd

     rlPhaseStartTest "ipa-selinuxusermap-find-021: Find selinuxusermap --raw when there is no selinuxusermap"
        rlRun "ipa selinuxusermap-find --raw  > $TmpDir/selinuxusermap-find_test21.out" 1 "Find selinuxusermap with --raw"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test21.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test21.out"

        rlRun "ipa selinuxusermap-find --raw --all > $TmpDir/selinuxusermap-find_test21_raw_all.out" 1 "Find selinuxusermap with --all --raw"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test21_raw_all.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test21_raw_all.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-find-022: Find selinuxusermap --pkey-only when there is no selinuxusermap"
        rlRun "ipa selinuxusermap-find --pkey-only > $TmpDir/selinuxusermap-find_test22.out" 1 "Find selinuxusermap with --pkey-only"
        rlAssertGrep "0 SELinux User Maps matched" "$TmpDir/selinuxusermap-find_test22.out"
        rlAssertGrep "Number of entries returned 0" "$TmpDir/selinuxusermap-find_test22.out"
    rlPhaseEnd 

    rlPhaseStartCleanup "ipa-selinuxusermap-find-cleanup: Destroying admin credentials."
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
