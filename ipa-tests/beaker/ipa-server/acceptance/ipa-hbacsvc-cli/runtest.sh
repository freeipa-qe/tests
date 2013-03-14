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
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-hbac-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

service1="http"
service2="https"
service3="rlogin"

servicegroup1="remote"
servicegroup2="web"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-hbacsvc-cli-startup: Check for admintools package and Kinit"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
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
        expmsg="ipa: ERROR: doesntexist: HBAC service not found"
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
        command="ipa hbacsvc-mod --setattr \"cn=newcn,cn=hbacservices,cn=hbac,$BASEDN\" $service1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr \"cn=newcn,cn=hbacservices,cn=hbac,$BASEDN\" $service1"
	expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-006: Negative - Service - setattr and addattr on ipaUniqueID"
        command="ipa hbacsvc-mod --setattr \"ipaUniqueID=newid,cn=hbacservices,cn=hbac,$BASEDN\" $service1"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr \"ipaUniqueID=newid,cn=hbacservices,cn=hbac,$BASEDN\" $service1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-007: Negative - Service - setattr and addattr on memberOf"
        command="ipa hbacsvc-mod --setattr \"memberof=cn=sudo,cn=hbacservicegroups,cn=hbac,$BASEDN\" $service1"
	expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'cn=$service1,cn=hbacservices,cn=hbac,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvc-mod --addattr \"memberof=cn=sudo,cn=hbacservicegroups,cn=hbac,$BASEDN\" $service1"
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
        expmsg="ipa: ERROR: HBAC service group with name sudo already exists"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for empty Rule Type"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-011: Negative - HBAC Service Group doesn't exists"
        command="ipa hbacsvcgroup-mod --desc=doesntexist doesntexist"
        expmsg="ipa: ERROR: doesntexist: HBAC service group not found"
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
        command="ipa hbacsvcgroup-mod --setattr \"dn=cn=newcn,cn=hbacservicegroup,cn=hbac,$BASEDN\" $servicegroup1"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message"
        command="ipa hbacsvcgroup-mod --addattr \"dn=cn=newcn,cn=hbacservicegroup,cn=hbac,$BASEDN\" $servicegroup1"
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

    # Disabling test case - development can't decide on all upper case all lower case or a mixture for the sudo Group name
    # right now it is a mixture and causes some of the verifications to fail
    #rlPhaseStartTest "ipa-hbacsvc-cli-019: Verify Default SUDO Service Members"
	#rlRun "verifyHBACGroupMember sudo Sudo" 0 "Verifying service group member."
	#rlRun "verifyHBACGroupMember sudo-i Sudo" 0 "Verifying service group member."
    #rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-020: Verify Add Existing Services to New Service Group"
	rlRun "addHBACServiceGroup $servicegroup2 $servicegroup2" 0 "Adding HBAC service Group $servicegroup2."
	rlRun "addServiceGroupMembers \"sshd,ftp\" $servicegroup2" 0 "Adding service members to service group."
        rlRun "verifyHBACGroupMember sshd $servicegroup2" 0 "Verifying service group member was added."
        rlRun "verifyHBACGroupMember ftp $servicegroup2" 0 "Verifying service group member was added."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-021: Verify Remove Existing Services to New Service Group"
        rlRun "removeServiceGroupMembers \"sshd,ftp\" $servicegroup2" 0 "Removing service members to service group."
        rlRun "verifyHBACGroupMember sshd $servicegroup2" 4 "Verifying service group member was removed."
        rlRun "verifyHBACGroupMember ftp $servicegroup2" 4 "Verifying service group member was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacsvc-cli-022: Delete service that is a Member of two service groups"
 	for item in $service2 $service3 ; do
    		rlRun "addHBACService $item \"$item service\"" 0 "Adding new service $item."
	done
    	rlRun "addServiceGroupMembers \"sshd,ftp,rlogin\" $servicegroup1" 0 "Adding service members to service group."
    	rlRun "addServiceGroupMembers \"http,https,rlogin\" $servicegroup2" 0 "Adding service members to service group."
    	rlRun "verifyHBACGroupMember rlogin $servicegroup1" 0 "Verifying service group member was added."
	rlRun "verifyHBACGroupMember rlogin $servicegroup2" 0 "Verifying service group member was added."
	rlRun "deleteHBACService $service3" 0 "Deleting service that is member of 2 service groups."
        rlRun "verifyHBACGroupMember rlogin $servicegroup1" 4 "Verifying service group member was removed."
        rlRun "verifyHBACGroupMember rlogin $servicegroup2" 4 "Verifying service group member was removed."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hbacscc-cli-023: Delete service group with service members."
	rlRun "deleteHBACServiceGroup $servicegroup2" 0 "Deleting service group $servicegroup2"
	rlRun "verifyHBACService http memberof \"cn=$servicegroup2,cn=hbacservicegroups,cn=accounts,$BASEDN\"" 1 "Verifying service exists but membership was removed."
        rlRun "verifyHBACService https memberof \"cn=$servicegroup2,cn=hbacservicegroups,cn=accounts,$BASEDN\"" 1 "Verifying service exists but membership was removed."
    rlPhaseEnd

    # The following test will nor pass until https://bugzilla.redhat.com/show_bug.cgi?id=801235 is resolved
    hbacrule="svhbac"
    rlPhaseStartTest "ipa-hbacsvc-cli-023: Positive test of hbacsvc-find using --in-hbacrule"
	rlRun "ipa hbacrule-add $hbacrule" 0 "Adding hbac rule for testing with user-find"
	rlRun "ipa hbacrule-add-service --hbacsvcs=$service1 $hbacrule" 0 "Adding service service1 to hbacrule"
	rlRun "ipa hbacsvc-find --in-hbacrule=$hbacrule | grep $service1" 0 "making sure that service 1 is returned when searching for services in the hbacrule"
    rlPhaseEnd

    # The following test will nor pass until https://bugzilla.redhat.com/show_bug.cgi?id=801235 is resolved
    rlPhaseStartTest "ipa-hbacsvc-cli-024: Negative test of hbacsvc-find using --in-hbacrule"
	rlRun "ipa hbacsvc-find --in-hbacrule=$hbacrule | grep $service2" 1 "making sure that service 2 is not returned when searching for services in the hbacrule"
    rlPhaseEnd

    # The following test will nor pass until https://bugzilla.redhat.com/show_bug.cgi?id=801235 is resolved
    rlPhaseStartTest "ipa-hbacsvc-cli-025: Positive test of hbacsvc-find using --not-in-hbacrule"
	rlRun "ipa hbacsvc-find --not-in-hbacrule=$hbacrule | grep $service2" 0 "making sure that service 2 is returned when searching for services not in the hbacrule"
    rlPhaseEnd

    # The following test will nor pass until https://bugzilla.redhat.com/show_bug.cgi?id=801235 is resolved
    rlPhaseStartTest "ipa-hbacsvc-cli-026: Positive test of hbacsvc-find using --not-in-hbacrule"
	rlRun "ipa hbacsvc-find --not-in-hbacrule=$hbacrule | grep $service1" 1 "making sure that service 1 is not returned when searching for services not in the hbacrule"
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-hbacsvc-cli-cleanup: Destroying admin credentials."
	# delete service groups
	rlRun "deleteHBACService $service1" 0 "CLEANUP: Deleting service $service1"
	rlRun "deleteHBACService $service2" 0 "CLEANUP: Deleting service $service2"
	rlRun "deleteHBACServiceGroup \"$servicegroup1\"" 0 "CLEANUP: Deleting service group $servicegroup1"
	rlRun "ipa hbacrule-del $hbacrule" 0 "cleaning up the hbac rule used in tests 23 through 26"
	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
