#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-add          Create a new SELinux User Map.
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
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-selinuxusermap-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

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
selinuxusermap_all="testselinuxusermap_all"
selinuxusermap_raw="testselinuxusermap_raw"
selinuxusermap_raw_noall="testselinuxusermap_raw_noall"

default_selinuxuser="guest_u:s0"
host1="devhost."$DOMAIN
user1="dev"
usergroup1="dev_ugrp"
hostgroup1="dev_hosts"
servicegroup="remote_access"

########################################################################

run_selinuxusermap_add_tests(){

    rlPhaseStartSetup "ipa-selinuxusermap-cli-startup: Create temp directory and Kinit"
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

    rlPhaseStartTest "ipa-selinuxusermap-cli-configtest: ipa help selinuxusermap-add"
	rlRun "ipa help selinuxusermap-add > $TmpDir/selinuxusermap-add_cfg.out"
	rlRun "cat $TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "Purpose: Create a new SELinux User Map." "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "Usage: ipa \[global-options\] selinuxusermap-add NAME \[options\]" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\-h, \--help         show this help message and exit" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--selinuxuser=STR  SELinux User" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--hbacrule=STR     HBAC Rule that defines the users, groups and hostgroups" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--usercat=\['all'\]  User category the rule applies to" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--hostcat=\['all'\]  Host category the rule applies to" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--desc=STR         Description" "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--setattr=STR      Set an attribute to a name/value pair. Format is
                     attr=value. For multi-valued attributes, the command
                     replaces the values already present." "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--addattr=STR      Add an attribute/value pair. Format is attr=value. The
                     attribute must be part of the schema." "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--all              Retrieve and print all attributes from the server.
                     Affects command output." "$TmpDir/selinuxusermap-add_cfg.out"
	rlAssertGrep "\--raw              Print entries as stored on the server. Only affects
                     output format." "$TmpDir/selinuxusermap-add_cfg.out"
    rlPhaseEnd


    rlPhaseStartTest "ipa-selinuxusermap-cli-001: Add a selinuxuser map"
        rlRun "addSelinuxusermap \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Add a selinuxusermap"
	rlRun "findSelinuxusermap $selinuxusermap1" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1" 0 "Verifying selinuxusermap was added with given selinuxuser"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-002: Add a duplicate selinuxusermap"
        command="ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap1"
        expmsg="ipa: ERROR: SELinux User Map rule with name $selinuxusermap1 already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for duplicate selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-003: Add a new selinuxuser rule to existing selinuxusermap"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser $selinuxusermap1"
        expmsg="ipa: ERROR: SELinux User Map rule with name $selinuxusermap1 already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for new selinux user type with existing selinuxusermap"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-004: selinuxuser type Required - give empty string"
        command="ipa selinuxusermap-add --selinuxuser=\"\" $selinuxusermap2"
        expmsg="ipa: ERROR: 'selinuxuser' is required"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty selinuxuser type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-005: selinuxuser option - unknown"
	command="ipa selinuxusermap-add --selinuxuser=unknown $selinuxusermap2"
        expmsg="ipa: ERROR: SELinux user unknown not found in ordering list (in config)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for unknown selinuxuser type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-006: Add a selinuxuser map with User Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=all $selinuxusermap2 > $TmpDir/selinuxusermap_usercat_all.out" 0 "Add a selinuxusermap with User Category all"
        rlRun "findSelinuxusermap $selinuxusermap2" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlAssertGrep "User category: all" "$TmpDir/selinuxusermap_usercat_all.out"
        rlRun "findSelinuxusermapByOption usercat all $selinuxusermap2" 0 "Verifying selinuxusermap was added with user category all"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-007: Users and user group cannot be added when user category='all' "
        command="ipa selinuxusermap-add-user --user=$user1 $selinuxusermap2"
        expmsg="ipa: ERROR: users cannot be added when user category='all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding users to selinuxusermap  when user category='all'"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-008: User Groups cannot be added when user category='all' "
        command="ipa selinuxusermap-add-user --groups=$usergroup1 $selinuxusermap2"
        expmsg="ipa: ERROR: users cannot be added when user category='all'"
        
rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding groups to selinuxusermap when user category='all'"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-009: Add a  selinuxuser map with User Category 'all' while there are allowed users"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap3" 0 "Add a selinuxusermap with allowed user"
	rlRun "ipa selinuxusermap-add-user --user=$user1 $selinuxusermap3 > $TmpDir/selinuxusermap_user.out"
        rlRun "findSelinuxusermap $selinuxusermap3" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
	rlAssertGrep "Users: $user1" "$TmpDir/selinuxusermap_user.out"
        rlRun "ipa selinuxusermap-mod --usercat=all $selinuxusermap3 > $TmpDir/selinuxusermap_modify_usercat_all.out" 0 "Modify selinuxusermap with User Category 'all'"
	rlAssertGrep "User category: all" "$TmpDir/selinuxusermap_modify_usercat_all.out"
        rlRun "findSelinuxusermapByOption usercat all $selinuxusermap3" 0 "Verifying selinuxusermap was added with user category all"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-010: selinuxuser User Category - unknown"
        command="ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --usercat=unknown $selinuxusermap4"
        expmsg="ipa: ERROR: invalid 'usercat': must be one of (u'all',)"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for unknown user category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-011: Add a selinuxuser map with Host Category 'all'"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hostcat=all $selinuxusermap4 > $TmpDir/selinuxusermap_hostcat_all.out" 0 "Add a selinuxusermap with Host Category all"
        rlRun "findSelinuxusermap $selinuxusermap4" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlAssertGrep "Host category: all" "$TmpDir/selinuxusermap_hostcat_all.out"
        rlRun "findSelinuxusermapByOption hostcat all $selinuxusermap4" 0 "Verifying selinuxusermap was added with host category all"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-012: Hosts cannot be added when host category='all' "
        command="ipa selinuxusermap-add-host --hosts=$host1 $selinuxusermap4"
        expmsg="ipa: ERROR: hosts cannot be added when host category='all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding hosts to selinuxusermap  when hosts category='all'"
    rlPhaseEnd
    
    rlPhaseStartTest "ipa-selinuxusermap-cli-013: Host groups cannot be added when host category='all' "
        command="ipa selinuxusermap-add-host --hostgroups=$hostgroup1 $selinuxusermap4"
        expmsg="ipa: ERROR: hosts cannot be added when host category='all'"

rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding groups to selinuxusermap when user category='all'"
    rlPhaseEnd
  
    rlPhaseStartTest "ipa-selinuxusermap-cli-014: setattr on description"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --setattr=description=newdescription $selinuxusermap5" 0 "Add selinuxuser rule's description with setattr"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-cli-015: addattr on description"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\"  --addattr=description=newdescription $selinuxusermap6" 0 "Add selinuxuser rule's description with addattr"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-cli-016: setattr and addattr on description"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --setattr=description=newdescription $selinuxusermap7" 0 "Add selinuxuser rule's description with setattr"
        expmsg="ipa: ERROR: description: Only one value allowed."
        command="ipa selinuxusermap-mod --addattr=description=newdescription2 $selinuxusermap7"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd 

    rlPhaseStartTest "ipa-selinuxusermap-cli-017: Negative: setattr on attribute outside schema"
        expmsg="ipa: ERROR: attribute notinschema not allowed"
        command="ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --setattr=notinschema=abcdef  $selinuxusermap8"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-018: Negative: addattr on attribute outside schema"
        expmsg="ipa: ERROR: attribute notinschema not allowed"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --addattr=notinschema=abcdef  $selinuxusermap8"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-019: Add a selinuxuser map with hbacrule"
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap8" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap8" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap8" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap8" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "testHbacRule" $selinuxusermap8" 0 "Verifying selinuxusermap was added with given HbacRule"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-selinuxusermap-cli-020: Negative: Add a selinuxuser map with non existing hbacrule"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=denytest $selinuxusermap9"
	command="ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=denytest $selinuxusermap9"
        expmsg="ipa: ERROR: HBAC rule denytest not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding selinuxuser map with non existing hbacrule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-021: Add a selinuxuser map with hbacrule with host,user and service associated with it"
	rlRun "addHBACRule \" \" \" \" \" \" \" \" newHbacRule" 0 "Adding HBAC rule."
	rlRun "addToHBAC newHbacRule host hosts $host1" 0 "Adding host $host1 to newHbacRule rule."
	rlRun "addToHBAC newHbacRule user users $user1" 0 "Adding user $user1 to newHbacRule rule."
	rlRun "addToHBAC newHbacRule service hbacsvcs sshd" 0 "Adding service sshd to newHbacRulerule."
	rlRun "verifyHBACAssoc newHbacRule Hosts $host1" 0 "Verifying host $host1 is associated with the newHbacRule rule."
        rlRun "verifyHBACAssoc newHbacRule \"Users\" $user1" 0 "Verifying user $user1 is associated with the newHbacRule rule."
	rlRun "verifyHBACAssoc newHbacRule \"Services\" sshd" 0 "Verifying service sshd is associated with the newHbacRule rule."
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=newHbacRule $selinuxusermap9"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=newHbacRule $selinuxusermap9" 0 "Add a selinuxusermap with hbacrule having host and user associated"
        rlRun "findSelinuxusermap $selinuxusermap9" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap9" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "newHbacRule" $selinuxusermap9" 0 "Verifying selinuxusermap was added with given HbacRule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-022: Add a selinuxuser map with default hbacrule allow_all"
        rlRun "findHBACRuleByOption name allow_all allow_all" 0 "Finding rule allow_all by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=allow_all $selinuxusermap10"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=allow_all $selinuxusermap10" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap10" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap10" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "allow_all" $selinuxusermap10" 0 "Verifying selinuxusermap was added with given HbacRule"
    rlPhaseEnd
     
    rlPhaseStartTest "ipa-selinuxusermap-cli-023: Add a selinuxuser map with all the options set"
	rlRun "ipa selinuxusermap-add --selinuxuser=guest_u:s0 --hbacrule=allow_all --usercat=all --hostcat=all --desc='selinuxuser map with all options set' $selinuxusermap11 > $TmpDir/selinuxusermap11.out"
        rlRun "findSelinuxusermap $selinuxusermap11" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser guest_u:s0 $selinuxusermap11" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "allow_all" $selinuxusermap11" 0 "Verifying selinuxusermap was added with given HbacRule"
        rlRun "findSelinuxusermapByOption usercat all $selinuxusermap11" 0 "Verifying selinuxusermap was added with usercat all"
        rlRun "findSelinuxusermapByOption hostcat all $selinuxusermap11" 0 "Verifying selinuxusermap was added with hostcat all"
	rlAssertGrep "Description: selinuxuser map with all options set" "$TmpDir/selinuxusermap11.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-024: Add a selinuxuser map with --all option"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --all $selinuxusermap_all"
        rlRun "ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --all $selinuxusermap_all" 0 "Add a selinuxusermap with --all option"
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-selinuxusermap-cli-025: Add a selinuxuser map with --all --raw option"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --all --raw $selinuxusermap_raw"
        rlRun "ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --all $selinuxusermap_raw" 0 "Add a selinuxusermap with --all --raw option"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-026: Add a selinuxuser map with --raw option without --all"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --raw $selinuxusermap_raw_noall"
        rlRun "ipa selinuxusermap-add --selinuxuser=$default_selinuxuser --all $selinuxusermap_raw_noall" 0 "Add a selinuxusermap with --raw option without --all"
    rlPhaseEnd

rlPhaseStartTest "ipa-selinuxusermap-cli-027: Add a selinuxuser map with invalid character - #"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=$default_selinuxuser abcd#"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser abcd#"
        expmsg="ipa: ERROR: invalid 'selinuxusermap': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2985"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-028: Add a selinuxuser map with invalid character - @"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser abcd@"
        expmsg="ipa: ERROR: invalid 'selinuxusermap': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2985"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-029: Add a selinuxuser map with invalid character - *"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser abcd*"
        expmsg="ipa: ERROR: invalid 'selinuxusermap': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2985"
    rlPhaseEnd

    rlPhaseStartTest "ipa-selinuxusermap-cli-030: Add a selinuxuser map with invalid character - ?"
        command="ipa selinuxusermap-add --selinuxuser=$default_selinuxuser abcd?"
        expmsg="ipa: ERROR: invalid 'selinuxusermap': may only include letters, numbers, _, -, . and $"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlLog "Failing due to Bug https://fedorahosted.org/freeipa/ticket/2985"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-selinuxusermap-cli-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 $selinuxusermap5 $selinuxusermap6 $selinuxusermap7 $selinuxusermap8 $selinuxusermap9 $selinuxusermap10 $selinuxusermap11 $selinuxusermap_all $selinuxusermap_raw $selinuxusermap_raw_noall ; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done

	#This clean-up is required since selinuxusermap takes garbage input
	for item in  abcd?  abcd* abcd@ abcd#; do
                rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
        done
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
