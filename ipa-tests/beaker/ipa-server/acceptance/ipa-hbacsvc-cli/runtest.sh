#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbacsvr-cli
#   Description: IPA Host Based Access Control (HBAC) Services CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  hbacsvc-add   Add a new HBAC service.
#  hbacsvc-del   Delete an existing HBAC service.
#  hbacsvc-find  Search for HBAC services.
#  hbacsvc-mod   Modify an HBAC service.
#  hbacsvc-show  Display information about an HBAC service.
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
. /usr/lib/beakerlib/beakerlib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

service1="http"
service2="https"

servicegroup1="http_group"
servicegroup2="remote_access"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-hbac-cli-startup: Check for admintools package and Kinit"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-001: Negative - Add HBAC Service that already exists"
        command="ipa hbacsvc-add sshd"
        expmsg="ipa: ERROR: HBAC service with name sshd already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty Rule Type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-002: Negative - HBAC Service doesn't exists"
        command="ipa hbacsvc-mod --desc=doesntexist doesntexist"
        expmsg="ipa: ERROR: doesntexist: hbacsvc not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
	command="ipa hbacsvc-show --all doesntexist"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
	command="ipa hbacsvc-del doesntexist"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-003: Add HBAC Service"
        rlRun "addHBACService $service1 $service1" 0 "Adding HBAC service $service1."
	rlRun "findHBACService $service1" 0 "Verifying HBAC service $service1 is found."
	rlRun "verifyHBACService $service1 \"Service name\" $service1" 0 "Verify New Service name"
	rlRun "verifyHBACService $service1 \"Description\" $service1" 0 "Verify New Service Description"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-004: Negative - Service - setattr and addattr on cn"
        command="ipa hbacsvc-mod --setattr cn=newcn $service1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr cn=newcn $service1"
	expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-005: Negative - Service - setattr and addattr on dn"
        command="ipa hbacsvc-mod --setattr dn=newcn $service1"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr dn=newcn $service1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-006: Negative - Service - setattr and addattr on ipaUniqueID"
        command="ipa hbacsvc-mod --setattr ipaUniqueID=newid $service1"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr ipaUniqueID=newid $service1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-007: Negative - Service - setattr and addattr on memberOf"
        command="ipa hbacsvc-mod --setattr memberOf=SUDO $service1"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'cn=$service1,cn=hbacservices,cn=accounts,dc=$RELM'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr memberOf=SUDO $service1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-008: Service - setattr and addattr on Description"
	rlRun "ipa hbacsvc-mod --setattr description=\"My New Description\" $service1" 0 "Modify with setattr service description"
	rlRun "verifyHBACService $service1 Description \"My New Description\"" 0 "Verify New Service Description"
        command="ipa hbacsvc-mod --addattr description=newdescription $service1"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-009: Service - Modify Description with --desc"
	rlRun "modifyHBACService $service1 desc \"Newer Description\"" 0 "Modify with --desc service description"
	rlRun "verifyHBACService $service1 Description \"Newer Description\"" 0 "Verify New Service Description"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-010: Negative - Add HBAC Service Group that already exists"
        command="ipa hbacsvcgroup-add --desc=test SUDO"
        expmsg="ipa: ERROR: HBAC service group with name SUDO already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty Rule Type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-011: Negative - HBAC Service Group doesn't exists"
        command="ipa hbacsvcgroup-mod --desc=doesntexist doesntexist"
        expmsg="ipa: ERROR: doesntexist: hbacsvcgroup not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-show --all doesntexist"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-del doesntexist"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-012: Add HBAC Service Group"
        rlRun "addHBACServiceGroup $servicegroup1 $servicegroup1" 0 "Adding HBAC service Group $servicegroup1."
        rlRun "findHBACServiceGroup $servicegroup1" 0 "Verifying HBAC service group $servicegroup1 is found."
        rlRun "verifyHBACServiceGroup $servicegroup1 \"Service group name\" $servicegroup1" 0 "Verify New Service Group name"
        rlRun "verifyHBACServiceGroup $servicegroup1 \"Description\" $servicegroup1" 0 "Verify New Service Group Description"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-013: Negative - Service Group - setattr and addattr on cn"
        command="ipa hbacsvcgroup-mod --setattr cn=newcn $servicegroup1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-mod --addattr cn=newcn $servicegroup1"
        expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-014: Negative - Service Group - setattr and addattr on cn"
        command="ipa hbacsvcgroup-mod --setattr cn=newcn $servicegroup1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-mod --addattr cn=newcn $servicegroup1"
        expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-015: Negative - Service Group - setattr and addattr on dn"
        command="ipa hbacsvcgroup-mod --setattr dn=newcn $servicegroup1"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-mod --addattr dn=newcn $servicegroup1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-016: Negative - Service Group - setattr and addattr on ipaUniqueID"
        command="ipa hbacsvcgroup-mod --setattr ipaUniqueID=newid $servicegroup1"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-mod --addattr ipaUniqueID=newid $servicegroup1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-017: Service Group- setattr and addattr on Description"
        rlRun "ipa hbacsvcgroup-mod --setattr description=\"My New Description\" $servicegroup1" 0 "Modify with setattr service group description"
        rlRun "verifyHBACServiceGroup $servicegroup1 Description \"My New Description\"" 0 "Verify New Service Description"
        command="ipa hbacsvcgroup-mod --addattr description=newdescription $servicegroup1"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-018: Service Group - Modify Description with --desc"
        rlRun "modifyHBACServiceGroup $servicegroup1 desc \"Newer Description\"" 0 "Modify with --desc service group description"
        rlRun "verifyHBACServiceGroup $servicegroup1 Description \"Newer Description\"" 0 "Verify New Service group Description"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-hbac-cli-cleanup: Destroying admin credentials."
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"

	# delete service groups
	rlRun "deleteHBACService $service1" 0 "CLEANUP: Deleting service $service1"
	rlRun "deleteHBACServiceGroup \"$servicegroup1\"" 0 "CLEANUP: Deleting service group $servicegroup1"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd
