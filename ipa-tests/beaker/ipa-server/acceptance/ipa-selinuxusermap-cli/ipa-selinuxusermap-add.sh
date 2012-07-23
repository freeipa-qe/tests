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
default_selinuxuser="guest_u:s0"
default_selinuxusermap_order_config="\"guest_u:s0$xguest_u:s0$user_u:s0-s0:c0.c1023$staff_u:s0-s0:c0.c1023$unconfined_u:s0-s0:c0.c1023\""
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

    rlPhaseStartTest "ipa-selinuxusermap-cli-003: Add a new selinux user type to existing selinuxusermap"
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
        rlRun "findSelinuxusermapByOption usercat all $selinuxusermap2" 0 "Verifying selinuxusermap was added with host category all"
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
  
    rlPhaseStartTest "ipa-hbacrule-cli-014: setattr on description"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --setattr description=newdescription $selinuxusermap5" 0 "Add selinuxuser rule's description with setattr"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-hbacrule-cli-015: addattr on description"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\"  --addattr description=newdescription $selinuxusermap6" 0 "Add selinuxuser rule's description with addattr"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-hbacrule-cli-016: setattr and addattr on description"
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --setattr description=newdescription $selinuxusermap7" 0 "Add selinuxuser rule's description with setattr"
        expmsg="ipa: ERROR: description: Only one value allowed."
        command="ipa selinuxusermap-mod --addattr description=newdescription2 $selinuxusermap7"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd 

    rlPhaseStartTest "ipa-selinuxusermap-cli-017: Add a selinuxuser map with hbacrule"
  	rlRun "addHBACRule all all all all testHbacRule" 0 "Adding HBAC rule."
	rlRun "findHBACRuleByOption name testHbacRule testHbacRule" 0 "Finding rule testHbacRule by name"
        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap8" 
        rlRun "ipa selinuxusermap-add --selinuxuser=\"unconfined_u:s0-s0:c0.c1023\" --hbacrule=testHbacRule $selinuxusermap8" 0 "Add a selinuxusermap with hbacrule"
        rlRun "findSelinuxusermap $selinuxusermap8" 0 "Verifying selinuxusermap was added with ipa selinuxusermap-find"
        rlRun "findSelinuxusermapByOption selinuxuser \"unconfined_u:s0-s0:c0.c1023\" $selinuxusermap8" 0 "Verifying selinuxusermap was added with given selinuxuser"
        rlRun "findSelinuxusermapByOption hbacrule "testHbacRule" $selinuxusermap8" 0 "Verifying selinuxusermap was added with given HbacRule"
    rlPhaseEnd
 
    rlPhaseStartCleanup "ipa-selinuxusermap-cli-cleanup: Destroying admin credentials."
	# delete selinux user 
	for item in $selinuxusermap1 $selinuxusermap2 $selinuxusermap3 $selinuxusermap4 $selinuxusermap5 $selinuxusermap6 $selinuxusermap7 $selinuxusermap8; do
		rlRun "ipa selinuxusermap-del $item" 0 "CLEANUP: Deleting selinuxuser $item"
	done
	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "ipa user-del $user1" 0 "Delete user $user1."
	rlRun "deleteHBACRule testHbacRule" 0 "Deleting testHbacRule rule"
	rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing temp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd
}
