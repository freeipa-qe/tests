#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbacrule-cli
#   Description: IPA Host Based Access Control (HBAC) CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  hbacrule-add                Create a new HBAC rule.
#  hbacrule-add-accesstime     Add an access time to an HBAC rule.
#  hbacrule-add-host           Add target hosts and hostgroups to an HBAC rule
#  hbacrule-add-service        Add services to an HBAC rule.
#  hbacrule-add-sourcehost     Add source hosts and hostgroups from a HBAC rule. #commenting this as this option has been removed
#  hbacrule-add-user           Add users and groups to an HBAC rule.
#  hbacrule-del                Delete an HBAC rule.
#  hbacrule-disable            Disable an HBAC rule.
#  hbacrule-enable             Enable an HBAC rule.
#  hbacrule-find               Search for HBAC rules.
#  hbacrule-mod                Modify an HBAC rule.
#  hbacrule-remove-accesstime  Remove access time to HBAC rule.
#  hbacrule-remove-host        Remove target hosts and hostgroups from a HBAC rule.
#  hbacrule-remove-service     Remove source hosts and hostgroups from an HBAC rule.
#  hbacrule-remove-sourcehost  Remove source hosts and hostgroups from an HBAC rule. #commenting this as this option has been removed
#  hbacrule-remove-user        Remove users and groups from an HBAC rule.
#  hbacrule-show               Display the properties of an HBAC rule.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
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
. ./t.hbac_cli_bz_tests.sh

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

    # hbacrule-add negative testing 

    # DISABLING TEST --type no longer an option after deny rule deprecation only type left is allow
    #rlPhaseStartTest "ipa-hbacrule-cli-001: Rule Type Required - send empty string"
    #    command="ipa hbacrule-add --type=\"\" test"
    #    expmsg="ipa: ERROR: 'type' is required"
    #    rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty Rule Type"
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-002: Rule type option removed"
	rlRun "ipa hbacrule-add --type=deny testrule > /tmp/error_hbac_002.out 2>&1" 2
	rlAssertGrep "ipa: error: no such option: --type" "/tmp/error_hbac_002.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-003: User Category - unknown"
        command="ipa hbacrule-add --usercat=bad test"
        expmsg="ipa: ERROR: invalid 'usercat': must be 'all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown user category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-004: Service Category - unknown"
        command="ipa hbacrule-add --servicecat=bad test"
        expmsg="ipa: ERROR: invalid 'servicecat': must be 'all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown service category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-005: Host Category - unknown"
        command="ipa hbacrule-add --hostcat=bad test"
        expmsg="ipa: ERROR: invalid 'hostcat': must be 'all'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown host category"
    rlPhaseEnd
    
    #Commenting because of https://fedorahosted.org/sssd/ticket/1078
    #rlPhaseStartTest "ipa-hbacrule-cli-006: Source Host Category - unknown"
    #    command="ipa hbacrule-add --srchostcat=bad test"
    #    expmsg="ipa: ERROR: invalid 'srchostcat': must be 'all'"
    #    rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for Unknown source host category"
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-007: Add Duplicate Rule"
        #command="ipa hbacrule-add --srchostcat=all test"
        command="ipa hbacrule-add --hostcat=all test"
        expmsg="ipa: ERROR: HBAC rule with name test already exists"
	rlRun "addHBACRule all all all test" 0 "Adding HBAC test rule."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for adding duplicate rule"
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-hbacrule-cli-008: Negative - setattr and addattr on dn"
        command="ipa hbacrule-mod --setattr \"ipaUniqueID=blah,cn=hbac,$BASEDN\" test"
	expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hbacrule-mod --addattr \"ipaUniqueID=blah,cn=hbac,$BASEDN\" test"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-009: setattr and addattr on cn"
        rlRun "ipa hbacrule-mod --setattr cn=test2 test" 0 "Modify hbac rule's cn with setattr"
        expmsg="ipa: ERROR: cn: Only one value allowed."
        command="ipa hbacrule-mod --addattr cn=\"test3\" test2"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	# change the cn back
	rlRun "ipa hbacrule-mod --setattr cn=test test2" 0 "Modify hbac rule's cn with setattr"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-010: setattr and addattr on description"
        rlRun "ipa hbacrule-mod --setattr description=newdescription test" 0 "Modify hbac rule's description with setattr"
        expmsg="ipa: ERROR: description: Only one value allowed."
        command="ipa hbacrule-mod --addattr description=newdescription2 test"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-011: Negative - setattr and addattr on ipauniqueid"
        command="ipa hbacrule-mod --setattr ipauniqueid=mynew-unique-id test"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hbacrule-mod --addattr ipauniqueid=another-new-unique-id test"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-012: Negative - setattr and addattr on invalid attribute"
        command="ipa hbacrule-mod --setattr badattr=test test"
        expmsg="ipa: ERROR: attribute \"badattr\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hbacrule-mod --addattr badattr=test test"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-013: Negative - setattr and addattr on Categories"
	for item in hostcat usercat servicecat srchostcat ; do
        	command="ipa hbacrule-mod --setattr $item=fake test"
        	expmsg="ipa: ERROR: attribute $item not allowed"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr on $item."
        	command="ipa hbacrule-mod --addattr $item=all test"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr on $item."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-014: Negative - setattr and addattr accessRuleType"
        command="ipa hbacrule-mod --setattr accessruletype=bad test"
	expmsg="ipa: ERROR: invalid 'accessruletype': must be one of 'allow', 'deny'"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	expmsg="ipa: ERROR: accessruletype: Only one value allowed."
        command="ipa hbacrule-mod --addattr accessruletype=bad test"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	command="ipa hbacrule-mod --addattr accessruletype=allow test"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-015: Negative - setattr and addattr on ipaEnabledFlag"
        command="ipa hbacrule-mod --setattr ipaenabledflag=test test"
        expmsg="ipa: ERROR: invalid 'ipaenabledflag': must be True or False"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr on ipaEnabledFlag."
        rlRun "ipa hbacrule-mod --setattr ipaenabledflag=FALSE test" 0 "Disable rule using setattr modification."
        # verify disabled
	rlRun "verifyHBACStatus test FALSE" 0 "Verify rule is now disabled"
	command="ipa hbacrule-mod --addattr ipaenabledflag=TRUE test"
	expmsg="ipa: ERROR: ipaenabledflag: Only one value allowed."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr on ipaEnabledFlag."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-016: Negative - Rule Does Not Exist - delete, disable, enable and show"
	for item in hbacrule-del hbacrule-disable hbacrule-enable hbacrule-show ; do
        	command="ipa $item doesntexist"
        	expmsg="ipa: ERROR: doesntexist: HBAC rule not found"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for $item rule doesn't exist"
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-017: Negative - Rule Does Not Exist - modify"
	 command="ipa hbacrule-mod --usercat=all doesntexist"
	 expmsg="ipa: ERROR: doesntexist: HBAC rule not found"
	 rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for hbacrule-mod rule doesn't exist"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-018: Negative - Add Host and Host Group When Host Category is all"
         command="ipa hbacrule-add-host --hosts=$host1 test"
         expmsg="ipa: ERROR: hosts cannot be added when host category='all'"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
         command="ipa hbacrule-add-host --hostgroups=$hostgroup1 test"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-019: Negative - Add User and group When User Category is all"
         command="ipa hbacrule-add-user --users=$user1 test"
         expmsg="ipa: ERROR: users cannot be added when user category='all'"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
         command="ipa hbacrule-add-user --groups=$usergroup1 test"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-020: Negative - Add Service and Service Group When Service Category is all"
         command="ipa hbacrule-add-service --hbacsvcs=sshd test"
         expmsg="ipa: ERROR: services cannot be added when service category='all'"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
         command="ipa hbacrule-add-service --hbacsvcgroups=$servicegroup test"
         rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    #Commenting because of https://fedorahosted.org/sssd/ticket/1078
    #rlPhaseStartTest "ipa-hbacrule-cli-021: Negative - Add Host and Host Group When Source Host Category is all"
    #     command="ipa hbacrule-add-sourcehost --hosts=$host1 test"
    #     expmsg="ipa: ERROR: source hosts cannot be added when sourcehost category='all'"
    #     rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    #     command="ipa hbacrule-add-sourcehost --hostgroups=$hostgroup1 test"
    #     rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-022: Disable Rule"
        rlRun "disableHBACRule test" 0 "Disabling test rule."
        rlRun "verifyHBACStatus test FALSE" 0 "Verify enabled status is FALSE"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-023: Enable Rule"
        rlRun "enableHBACRule test" 0 "Enablinging test rule."
        rlRun "verifyHBACStatus test TRUE" 0 "Verify enabled status is TRUE"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-024: Delete Rule"
	rlRun "deleteHBACRule test" 0 "Deleting test rule"
	command="ipa hbacrule-show test"
	expmsg="ipa: ERROR: test: HBAC rule not found"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify test rule was deleted"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-025: Add host to Rule"
	rlRun "addHBACRule \" \" \" \" \" \" Engineering" 0 "Adding HBAC rule."
	rlRun "addToHBAC Engineering host hosts $host1" 0 "Adding host $host1 to Engineering rule."
	rlRun "verifyHBACAssoc Engineering Hosts $host1" 0 "Verifying host $host1 is associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-026: Remove host from Rule"
        rlRun "removeFromHBAC Engineering host hosts $host1" 0 "Removing host $host1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering Hosts $host1" 1 "Verifying host $host1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-027: Add host group to Rule"
        rlRun "addToHBAC Engineering host hostgroups $hostgroup1" 0 "Adding host group $hostgroup1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 0 "Verifying host group $hostgroup1 is associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-028: Remove host group from Rule"
        rlRun "removeFromHBAC Engineering host hostgroups $hostgroup1" 0 "Removing host group $hostgroup1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 1 "Verifying host group $hostgroup1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-029: Add user to Rule"
        rlRun "addToHBAC Engineering user users $user1" 0 "Adding user $user1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Users\" $user1" 0 "Verifying user $user1 is associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-030: Remove user from Rule"
        rlRun "removeFromHBAC Engineering user users $user1" 0 "Removing user $user1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Users\" $user1" 1 "Verifying user $user1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-031: Add user group to Rule"
        rlRun "addToHBAC Engineering user groups $usergroup1" 0 "Adding user group $usergroup1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Groups\" $usergroup1" 0 "Verifying user group $usergroup1 is associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-032: Remove user group from Rule"
        rlRun "removeFromHBAC Engineering user groups $usergroup1" 0 "Removing user group $usergroup1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Groups\" $usergroup1" 1 "Verifying user group $usergroup1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-033: Add service to Rule"
        rlRun "addToHBAC Engineering service hbacsvcs sshd" 0 "Adding service sshd to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Services\" sshd" 0 "Verifying service sshd is associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-034: Remove service from Rule"
        rlRun "removeFromHBAC Engineering service hbacsvcs sshd" 0 "Removing service sshd to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Services\" sshd" 1 "Verifying service sshd is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-035: Add service group to Rule"
        rlRun "addToHBAC Engineering service hbacsvcgroups $servicegroup" 0 "Adding service group $servicegroup to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Service Groups\" $servicegroup" 0 "Verifying service group $servicegroup is associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-036: Remove service group from Rule"
        rlRun "removeFromHBAC Engineering service hbacsvcgroups $servicegroup" 0 "Removing service group $servicegroup to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Service Groups\" $servicegroup" 1 "Verifying service group $servicegroup is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-037: Modify Description"
	rlRun "modifyHBACRule Engineering desc \"My New Description\"" 0 "Modifying Engineering Rule's Description"
	rlRun "verifyHBACAssoc Engineering Description \"My New Description\"" 0 "Verifying Description"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-038: Modify User Category"
        rlRun "modifyHBACRule Engineering usercat all" 0 "Modifying Engineering Rule's User Category"
        rlRun "verifyHBACAssoc Engineering \"User category\" all" 0 "Verifying User Category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-039: Modify Host Category"
        rlRun "modifyHBACRule Engineering hostcat all" 0 "Modifying Engineering Rule's Host Category"
        rlRun "verifyHBACAssoc Engineering \"Host category\" all" 0 "Verifying Host Category"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-040: Modify Service Category"
        rlRun "modifyHBACRule Engineering servicecat all" 0 "Modifying Engineering Rule's Service Category"
        rlRun "verifyHBACAssoc Engineering \"Service category\" all" 0 "Verifying Service Category"
    rlPhaseEnd

    #Commenting because of https://fedorahosted.org/sssd/ticket/1078
    #rlPhaseStartTest "ipa-hbacrule-cli-041: Modify Source Host Category"
    #    rlRun "modifyHBACRule Engineering srchostcat all" 0 "Modifying Engineering Rule's Source Host Category"
    #    rlRun "verifyHBACAssoc Engineering \"Source host category\" all" 0 "Verifying Source Host Category"
    #rlPhaseEnd

    # disabling test .. --type has now been removed
    #rlPhaseStartTest "ipa-hbacrule-cli-042: Deprecation of deny rule"
    #	rlRun "ipa hbacrule-add --type=deny --usercat=all newtest > /tmp/error_hbac_042.out 2>&1" 2
    #    rlAssertGrep "ipa: ERROR: invalid 'type': The deny type has been deprecated." "/tmp/error_hbac_042.out"
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-043: Delete User Associated with a Rule"
	rlRun "modifyHBACRule Engineering usercat \"\" " 0 "Modifying Engineering Rule's User Category"
	rlRun "addToHBAC Engineering user users $user1" 0 "Adding user $user1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Users\" $user1" 0 "Verifying user $user1 is associated with the Engineering rule."
	rlRun "ipa user-del $user1" 0 "Deleting User associated with rule."
	rlRun "verifyHBACAssoc Engineering \"Users\" $user1" 1 "Verifying user $user1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-044: Delete Group Associated with a Rule"
	rlRun "addToHBAC Engineering user groups $usergroup1" 0 "Adding user group $usergroup1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Groups\" $usergroup1" 0 "Verifying user group $usergroup1 is associated with the Engineering rule."
	rlRun "deleteGroup $usergroup1" 0 "Deleting User Group associated with rule."
	rlRun "verifyHBACAssoc Engineering \"Groups\" $usergroup1" 1 "Verifying user group $usergroup1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-045: Delete Host Associated with a Rule"
	rlRun "modifyHBACRule Engineering hostcat \"\" " 0 "Modifying Engineering Rule's Host Category"
        rlRun "addToHBAC Engineering host hosts $host1" 0 "Adding host $host1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering Hosts $host1" 0 "Verifying host $host1 is associated with the Engineering rule."
        rlRun "deleteHost $host1" 0 "Deleting Host associated with rule."
        rlRun "verifyHBACAssoc Engineering Hosts $host1" 1 "Verifying host $host1 is no longer associated with the Engineering rule."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-046: Delete Host Group Associated with a Rule"
	#rlRun "modifyHBACRule Engineering srchostcat \"\" " 0 "Modifying Engineering Rule's Source Host Category"
	rlRun "addToHBAC Engineering host hostgroups $hostgroup1" 0 "Adding host group $hostgroup1 to Engineering rule."
        rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 0 "Verifying host group $hostgroup1 is associated with the Engineering rule."
	rlRun "deleteHostGroup $hostgroup1" 0 "Deleting Host Group associated with rule."
	rlRun "verifyHBACAssoc Engineering \"Host Groups\" $hostgroup1" 1 "Verifying host group $hostgroup1 is no longer associated with the Engineering rule."
	rlRun "deleteHBACRule Engineering" 0 "CLEANUP: Deleting Rule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-047: Find Rules by name"
	rlRun "addHBACRule \" \" \" \" \" \" test1" 0 "Adding HBAC rule."
	rlRun "addHBACRule all all all test2" 0 "Adding HBAC rule."
	rlRun "addHBACRule all all all test3" 0 "Adding HBAC rule."
	rlRun "addHBACRule \" \" \" \" \" \" test4" 0 "Adding HBAC rule."

	for item in test1 test2 test3 test4 ; do
		rlRun "findHBACRuleByOption name $item $item" 0 "Finding rule $item by name"	
	done
    rlPhaseEnd

    # now that deny rule is deprecated : finding by type doesn't make sense - only one type "allow"

    #rlPhaseStartTest "ipa-hbacrule-cli-047: Find Rules by type"
    #	rlRun "findHBACRuleByOption type allow \"allow_all test1 test3\"" 0 "Finding rule by type"
    #	rlRun "findHBACRuleByOption type allow \"test2 test4\"" 1 "Finding rule by type"
    #	rlRun "findHBACRuleByOption type deny \"test2 test4\"" 0 "Finding rule by type"
    #	rlRun "findHBACRuleByOption type deny \"allow_all test1 test3\"" 1 "Finding rule by type"
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-048: Find Rules by user category"
	rlRun "findHBACRuleByOption usercat all \"allow_all test2 test3\"" 0 "Finding rules by user category all"
	rlRun "findHBACRuleByOption usercat all \"test1\"" 1 "Finding rules by user category all"
	rlRun "findHBACRuleByOption usercat all \"test4\"" 1 "Finding rules by user category all"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-049: Find Rules by host category"
        rlRun "findHBACRuleByOption hostcat all \"allow_all test2 test3\"" 0 "Finding rules by host category all"
        rlRun "findHBACRuleByOption hostcat all \"test1 test4\"" 1 "Finding rules by host category none"
    rlPhaseEnd

    #Commenting because of https://fedorahosted.org/sssd/ticket/1078
    #rlPhaseStartTest "ipa-hbacrule-cli-050: Find Rules by source host category"
    #    rlRun "findHBACRuleByOption srchostcat all \"allow_all test2 test3\"" 0 "Finding rules by source host category all"
    #    rlRun "findHBACRuleByOption srchostcat all \"test1 test4\"" 1 "Finding rules by source host category none"
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacrule-cli-051: Find Rules by service category"
        rlRun "findHBACRuleByOption servicecat all \"allow_all test2 test3\"" 0 "Finding rules by service category all"
        rlRun "findHBACRuleByOption servicecat all \"test1 test4\"" 1 "Finding rules by service category none"
	# cleanup
	for item in test1 test2 test3 test4 ; do
		rlRun "deleteHBACRule $item" 0 "CLEANUP: Deleting Rule $item"
	done
    rlPhaseEnd


# Bugzilla automation starts here ... 
bug783286
bug947900

    rlPhaseStartCleanup "ipa-hbacrule-cli-cleanup: Destroying admin credentials."
	# delete service group
	rlRun "ipa hbacsvcgroup-del $servicegroup" 0 "CLEANUP: Deleting service group $servicegroup"

	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd

