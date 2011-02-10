#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-services
#   Description: ipa-services acceptance tests
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  The following ipa cli commands needs to be tested:
#  service-add          Add a new IPA new service.
#  service-add-host     Add hosts that can manage this service.
#  service-del          Delete an IPA service.
#  service-disable      Disable the Kerberos key of a service.
#  service-find         Search for IPA services.
#  service-mod          Modify an existing IPA service.
#  service-remove-host  Remove hosts that can manage this service.
#  service-show         Display information about an IPA service.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################
user1="user1"
user2="user2"
userpw="Secret123"

PACKAGE1="freeipa-admintools"
PACKAGE2="freeipa-client"

TMP_KEYTAB="/opt/krb5.keytab"

setup() {
rlPhaseStartTest "Setup for ipa service tests"
        rlAssertRpm $PACKAGE1
        rlAssertRpm $PACKAGE2
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
#	rlRun "create_ipauser $user1 $user1 $user1 $userpw"
#	sleep 5
#	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
#	rlRun "create_ipauser $user2 $user2 $user2 $userpw"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
rlPhaseEnd
}

service_add_001() {
	# ipa service-add : add service for HTTP/VPN
for i in vpn; do
rlPhaseStartTest "service_add_001: ipa service-add : add service for $i"
	rlRun "ipa -v service-add $i/$MASTER@$RELM > $TmpDir/service_add_001.out 2>&1"
	rlAssertGrep "Added service \"$i\/$MASTER@$RELM\"" "$TmpDir/service_add_001.out"
	rlRun "cat $TmpDir/service_add_001.out"

	# Deleting this service for future test cases
	rlRun "ipa service-del $i/$MASTER@$RELM"
rlPhaseEnd
done
}

service_add_002() {
	# ipa service-add : add service for HTTP/VPN with all option
for i in vpn; do
rlPhaseStartTest "service_add_002: ipa service-add : add service for $i with all option"

	rlRun "ipa service-add $i/$MASTER@$RELM --all > $TmpDir/service_add_002.out 2>&1"
	rlAssertGrep "Added service \"$i\/$MASTER@$RELM\"" "$TmpDir/service_add_002.out"
	rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_add_002.out"
	rlAssertGrep "Managed by: $MASTER" "$TmpDir/service_add_002.out"
	rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, top" "$TmpDir/service_add_002.out"
	rlRun "cat $TmpDir/service_add_002.out"

	# Deleting this service for future test cases
	rlRun "ipa service-del $i/$MASTER@$RELM"
rlPhaseEnd
done
}

service_add_003() {
	# ipa service-add : add service for HTTP/VPN with cert bytes
for i in vpn; do
rlPhaseStartTest "service_add_003: ipa service-add : add service for $i with cert bytes"

	rlRun "ipa service-add $i/$MASTER@$RELM --certificate=wrong > $TmpDir/service_add_003.out 2>&1" 1
	rlAssertGrep "ipa: ERROR: Certificate format error: improperly formatted DER-encoded certificate" "$TmpDir/service_add_003.out"
	rlRun "cat $TmpDir/service_add_003.out"

	rlRun "ipa service-add $i/$MASTER@$RELM --certificate=MIIC9jCCAd6gAwIBAgIBCTANBgkqhkiG9w0BAQ0FADA5MRIwEAYDVQQKEwlzaWxlbnRkb20xIzAhBgNVBAMTGkNlcnRpZmljYXRlIEF1dGhvcml0eWNhLXQxMB4XDTExMDExOTEyMjc1M1oXDTEzMDEwODEyMjc1M1owJjERMA8GA1UEAxMIYWNjb3VudHMxETAPBgNVBAMTCHNlcnZpY2VzMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbcRxo0/tfpoJEzCLmfTDy9AYQIyubgwo2ErV+6unEKY2OW3YHIBW6Th6xg62tMzqQatIqqJKse9AnVoObWAiqhpjPdr2FuL6LiyRb1Aez9E5MVndfbsto0F7OYSs6y1yICSBAfA1CFAdRm+WOnBDI1e3hcg3UHXUukifKg4XaLQIDAQABo4GfMIGcMB8GA1UdIwQYMBaAFEoAQIQqOuqP8Ilyez9pzQCblEmWMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL2JldGEuZHNkZXYuc2pjLnJlZGhhdC5jb206NDgxODAvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA0GCSqGSIb3DQEBDQUAA4IBAQCWk7YuyH6NTqILzmGK3qjIkreCpXnbNE99yrc7UQka9btrq2FWoFSxteU2JFD3+EGG8tXuDyDuWlgs8F3X/CBB4N+ZV4fAzHpIp2aIRQMapLKvu/mEiGPjFWFYJqk/HiNSQk8qefI6XqLvWIVY4LxMn4m1ZsQ/XXBzNbWsf9W3jnwCY0cLygJIgZZt2uQH/KxoQ3/oE0gp1wYITeKAKvaQrwUc4YgshlxMZAN4z5FuXdtDQqAIrJYcg9q+j6zYHNtXTcLuCFO0CcFto8CaUGXUJ0B5IrV2xsnRegHRxBy+C+3lfYiW2DelWI3exiYgdlU5wJSlkX37HQxA9cP+/kIb > $TmpDir/service_add_003.out"  

	rlRun "cat $TmpDir/service_add_003.out"
	rlAssertGrep "Added service \"$i/$MASTER@$RELM\"" "$TmpDir/service_add_003.out"
	rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_add_003.out"
	rlAssertGrep "Certificate: MIIC9jCCAd6gAwIBAgIBCTANBgkqhkiG9w0BAQ0FADA5MRIwEAYDVQQKEwlzaWxlbnRkb20xIzAhBgNVBAMTGkNlcnRpZmljYXRlIEF1dGhvcml0eWNhLXQxMB4XDTExMDExOTEyMjc1M1oXDTEzMDEwODEyMjc1M1owJjERMA8GA1UEAxMIYWNjb3VudHMxETAPBgNVBAMTCHNlcnZpY2VzMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbcRxo0/tfpoJEzCLmfTDy9AYQIyubgwo2ErV+6unEKY2OW3YHIBW6Th6xg62tMzqQatIqqJKse9AnVoObWAiqhpjPdr2FuL6LiyRb1Aez9E5MVndfbsto0F7OYSs6y1yICSBAfA1CFAdRm+WOnBDI1e3hcg3UHXUukifKg4XaLQIDAQABo4GfMIGcMB8GA1UdIwQYMBaAFEoAQIQqOuqP8Ilyez9pzQCblEmWMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL2JldGEuZHNkZXYuc2pjLnJlZGhhdC5jb206NDgxODAvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA0GCSqGSIb3DQEBDQUAA4IBAQCWk7YuyH6NTqILzmGK3qjIkreCpXnbNE99yrc7UQka9btrq2FWoFSxteU2JFD3+EGG8tXuDyDuWlgs8F3X/CBB4N+ZV4fAzHpIp2aIRQMapLKvu/mEiGPjFWFYJqk/HiNSQk8qefI6XqLvWIVY4LxMn4m1ZsQ/XXBzNbWsf9W3jnwCY0cLygJIgZZt2uQH/KxoQ3/oE0gp1wYITeKAKvaQrwUc4YgshlxMZAN4z5FuXdtDQqAIrJYcg9q+j6zYHNtXTcLuCFO0CcFto8CaUGXUJ0B5IrV2xsnRegHRxBy+C+3lfYiW2DelWI3exiYgdlU5wJSlkX37HQxA9cP+/kIb" "$TmpDir/service_add_003.out"
	rlAssertGrep "Managed by: $MASTER" "$TmpDir/service_add_003.out"

	rlRun "ipa service-del $i/$MASTER@$RELM" 
rlPhaseEnd
done
}

service_add_004() {
	# ipa service-add : add service for HTTP/VPN with force option

for i in vpn; do
rlPhaseStartTest "service_add_004: ipa service-add : add service for $i with cert bytes and --force option"

        rlRun "ipa service-add $i/$MASTER@$RELM --certificate=wrong > $TmpDir/service_add_004.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: Certificate format error: improperly formatted DER-encoded certificate" "$TmpDir/service_add_004.out"
        rlRun "cat $TmpDir/service_add_004.out"
        rlRun "ipa service-add $i/$MASTER@$RELM --certificate=MIIC9jCCAd6gAwIBAgIBCTANBgkqhkiG9w0BAQ0FADA5MRIwEAYDVQQKEwlzaWxlbnRkb20xIzAhBgNVBAMTGkNlcnRpZmljYXRlIEF1dGhvcml0eWNhLXQxMB4XDTExMDExOTEyMjc1M1oXDTEzMDEwODEyMjc1M1owJjERMA8GA1UEAxMIYWNjb3VudHMxETAPBgNVBAMTCHNlcnZpY2VzMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbcRxo0/tfpoJEzCLmfTDy9AYQIyubgwo2ErV+6unEKY2OW3YHIBW6Th6xg62tMzqQatIqqJKse9AnVoObWAiqhpjPdr2FuL6LiyRb1Aez9E5MVndfbsto0F7OYSs6y1yICSBAfA1CFAdRm+WOnBDI1e3hcg3UHXUukifKg4XaLQIDAQABo4GfMIGcMB8GA1UdIwQYMBaAFEoAQIQqOuqP8Ilyez9pzQCblEmWMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL2JldGEuZHNkZXYuc2pjLnJlZGhhdC5jb206NDgxODAvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA0GCSqGSIb3DQEBDQUAA4IBAQCWk7YuyH6NTqILzmGK3qjIkreCpXnbNE99yrc7UQka9btrq2FWoFSxteU2JFD3+EGG8tXuDyDuWlgs8F3X/CBB4N+ZV4fAzHpIp2aIRQMapLKvu/mEiGPjFWFYJqk/HiNSQk8qefI6XqLvWIVY4LxMn4m1ZsQ/XXBzNbWsf9W3jnwCY0cLygJIgZZt2uQH/KxoQ3/oE0gp1wYITeKAKvaQrwUc4YgshlxMZAN4z5FuXdtDQqAIrJYcg9q+j6zYHNtXTcLuCFO0CcFto8CaUGXUJ0B5IrV2xsnRegHRxBy+C+3lfYiW2DelWI3exiYgdlU5wJSlkX37HQxA9cP+/kIb > $TmpDir/service_add_004.out 2>&1"

        rlRun "cat $TmpDir/service_add_004.out"
        rlAssertGrep "Added service \"$i/$MASTER@$RELM" "$TmpDir/service_add_004.out"
        rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_add_004.out"
        rlAssertGrep "Certificate: MIIC9jCCAd6gAwIBAgIBCTANBgkqhkiG9w0BAQ0FADA5MRIwEAYDVQQKEwlzaWxlbnRkb20xIzAhBgNVBAMTGkNlcnRpZmljYXRlIEF1dGhvcml0eWNhLXQxMB4XDTExMDExOTEyMjc1M1oXDTEzMDEwODEyMjc1M1owJjERMA8GA1UEAxMIYWNjb3VudHMxETAPBgNVBAMTCHNlcnZpY2VzMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbcRxo0/tfpoJEzCLmfTDy9AYQIyubgwo2ErV+6unEKY2OW3YHIBW6Th6xg62tMzqQatIqqJKse9AnVoObWAiqhpjPdr2FuL6LiyRb1Aez9E5MVndfbsto0F7OYSs6y1yICSBAfA1CFAdRm+WOnBDI1e3hcg3UHXUukifKg4XaLQIDAQABo4GfMIGcMB8GA1UdIwQYMBaAFEoAQIQqOuqP8Ilyez9pzQCblEmWMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL2JldGEuZHNkZXYuc2pjLnJlZGhhdC5jb206NDgxODAvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA0GCSqGSIb3DQEBDQUAA4IBAQCWk7YuyH6NTqILzmGK3qjIkreCpXnbNE99yrc7UQka9btrq2FWoFSxteU2JFD3+EGG8tXuDyDuWlgs8F3X/CBB4N+ZV4fAzHpIp2aIRQMapLKvu/mEiGPjFWFYJqk/HiNSQk8qefI6XqLvWIVY4LxMn4m1ZsQ/XXBzNbWsf9W3jnwCY0cLygJIgZZt2uQH/KxoQ3/oE0gp1wYITeKAKvaQrwUc4YgshlxMZAN4z5FuXdtDQqAIrJYcg9q+j6zYHNtXTcLuCFO0CcFto8CaUGXUJ0B5IrV2xsnRegHRxBy+C+3lfYiW2DelWI3exiYgdlU5wJSlkX37HQxA9cP+/kIb" "$TmpDir/service_add_004.out"
        rlAssertGrep "Managed by: $MASTER" "$TmpDir/service_add_004.out"

	#deleting for the added service for the next test case
	rlRun "ipa service-del $i/$MASTER@$RELM"

rlPhaseEnd
done
}

service_add_005() {
	# ipa service-add : add service for HTTP/VPN with raw option

for i in vpn; do
rlPhaseStartTest "service_add_005: ipa service-add : add service for $i with --raw option"

        rlRun "ipa service-add $i/$MASTER@$RELM --raw > $TmpDir/service_add_005.out 2>&1"
        rlAssertGrep "Added service \"$i/$MASTER@$RELM\"" "$TmpDir/service_add_005.out"
	rlAssertGrep "krbprincipalname: $i/$MASTER@$RELM" "$TmpDir/service_add_005.out"
        rlRun "cat $TmpDir/service_add_005.out"

	#deleting for the added service for the next test case
	rlRun "ipa service-del $i/$MASTER@$RELM"
rlPhaseEnd
done
}

service_add_006() {

rlPhaseStartTest "service_add_006: ipa service-add: verifying the help message"
	# ipa service-add : check add help
	rlRun "ipa help service-add > $TmpDir/service_add_006.out 2>&1"
	rlAssertGrep "Purpose: Add a new IPA new service." "$TmpDir/service_add_006.out"
	rlAssertGrep "Usage: ipa \[global-options\] service-add PRINCIPAL" "$TmpDir/service_add_006.out"
	rlAssertGrep "\-h, \--help           show this help message and exit" "$TmpDir/service_add_006.out"
	rlAssertGrep "\--certificate=BYTES  Base-64 encoded server certificate" "$TmpDir/service_add_006.out"
	rlAssertGrep "\--force              force principal name even if not in DNS" "$TmpDir/service_add_006.out"
	rlAssertGrep "\--all                retrieve and print all attributes from the server." "$TmpDir/service_add_006.out"
	rlAssertGrep "\--raw                print entries as stored on the server." "$TmpDir/service_add_006.out"
	rlRun "cat $TmpDir/service_add_006.out"
rlPhaseEnd
}

service_add_007() {
	# ipa service-add : re-add service for HTTP/VPN
for i in vpn; do
rlPhaseStartTest "service_add_007: ipa service-add: re-add service for $i"
	rlRun "ipa service-add $i/$MASTER@$RELM"
	rlRun "ipa service-add $i/$MASTER@$RELM > $TmpDir/service_add_007.out 2>&1" 1
	rlAssertGrep "ipa: ERROR: service with name \"$i/$MASTER@$RELM\" already exists" "$TmpDir/service_add_007.out"
	rlRun "cat $TmpDir/service_add_007.out"

	#deleting for the added service for the next test case
	rlRun "ipa service-del $i/$MASTER@$RELM"
rlPhaseEnd
done 
}

service_add_008() {
	# service_add_008: ipa service-add : incorrect service name
for i in vpn; do
rlPhaseStartTest "service_add_008: ipa service-add : incorrect service name"
        rlRun "ipa service-add $i/random.ipaserver@$RELM > $TmpDir/service_add_008.out 2>&1" 2
        rlAssertGrep "ipa: ERROR: The host 'random.ipaserver' does not exist to add a service to." "$TmpDir/service_add_008.out"
        rlRun "cat $TmpDir/service_add_008.out"

rlPhaseEnd
done
}

service_add_009() {
	# service_add_009: Adding service with missing service name.
for i in vpn; do
rlPhaseStartTest "service_add_009: ipa service-add: Adding service with missing service name."
        rlRun "ipa service-add $MASTER@$RELM > $TmpDir/service_add_009.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: Service principal is not of the form: service\/fully-qualified host name: missing service" "$TmpDir/service_add_009.out"
        rlRun "cat $TmpDir/service_add_009.out"

rlPhaseEnd
done
}

service_add_010() {
	# service_add_010: Adding service with missing fqdn
for i in vpn; do
rlPhaseStartTest "service_add_010: ipa service-add: Adding service with missing fqdn."
        rlRun "ipa service-add $i/@$RELM > $TmpDir/service_add_010.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: 'fqdn' is required" "$TmpDir/service_add_010.out"
        rlRun "cat $TmpDir/service_add_010.out"

rlPhaseEnd
done
}



service_add_host_001() {
        # ipa service-add-host : add host to manage service for HTTP/VPN - host does not exist.
rlPhaseStartTest "service_add_host_001: ipa service-add-host : add host to manage service for HTTP/VPN - host does not exist."
        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM > $TmpDir/service_add_host_001.out 2>&1" 2
        rlRun "cat $TmpDir/service_add_host_001.out"
        rlAssertNotGrep "Number of members added" "$TmpDir/service_add_host_001.out"
rlPhaseEnd
}

service_add_host_002() {
for i in vpn; do
rlPhaseStartTest "service_add_host_002: ipa service-add-host: add host to manage service - host does exist."
        # adding host for further test
        rlRun "ipa host-add test.example.com --force"
	rlRun "ipa service-add $i/$MASTER@$RELM"
        # ipa service-add-host : add host to manage service for HTTP/VPN - host exists
        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM > $TmpDir/service_add_host_002.out 2>&1"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_002.out"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM" 0 "Removing the managed host for further testing"
rlPhaseEnd
done
}

service_add_host_003() {
        # ipa service-add-host : add host to manage service for HTTP/VPN with all option
for i in vpn; do
rlPhaseStartTest "service_add_host_003: ipa service-add-host : add host to manage service with all option."
        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM --all > $TmpDir/service_add_host_003.out 2>&1"
        rlAssertGrep "Managed by: $HOSTNAME, test.example.com" "$TmpDir/service_add_host_003.out"
        rlAssertGrep "ipauniqueid:" "$TmpDir/service_add_host_003.out"
        rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, top" "$TmpDir/service_add_host_003.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_003.out"
        rlRun "cat $TmpDir/service_add_host_003.out"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM" 0 "Removing the managed host for further testing"
rlPhaseEnd
done
}

service_add_host_004() {
        # ipa service-add-host : add host to manage service for HTTP/VPN with raw option
for i in vpn; do
rlPhaseStartTest "service_add_host_004: ipa service-add-host : add host to manage service with raw option."
        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM --raw > $TmpDir/service_add_host_004.out 2>&1"
        rlAssertGrep "krbprincipalname: $i/$MASTER@$RELM" "$TmpDir/service_add_host_004.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_004.out"
        rlRun "cat $TmpDir/service_add_host_004.out"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM" 0 "Removing the managed host for further testing"
rlPhaseEnd
done
}


service_add_host_005() {
        # ipa service-add-host : add host to manage service for HTTP/VPN with raw and all options
for i in vpn; do
rlPhaseStartTest "service_add_host_005: ipa service-add-host : add host to manage service with raw and all options"
        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM --raw --all > $TmpDir/service_add_host_005.out 2>&1"
        rlAssertGrep "krbprincipalname: $i/$MASTER@$RELM" "$TmpDir/service_add_host_005.out"
        rlRun "grep -i \"managedby: fqdn=test.example.com,cn=computers,cn=accounts,dc=$RELM\" $TmpDir/service_add_host_005.out"
        rlAssertGrep "objectclass: krbticketpolicyaux" "$TmpDir/service_add_host_005.out"
        rlAssertGrep "objectclass: krbprincipalaux" "$TmpDir/service_add_host_005.out"
        rlAssertGrep "objectclass: ipaservice" "$TmpDir/service_add_host_005.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_005.out"
        rlRun "cat $TmpDir/service_add_host_005.out"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM" 0 "Removing the managed host for further testing"
        rlRun "ipa host-del test.example.com" 0 "removing host test.example.com for further tests"
rlPhaseEnd
done
}


service_add_host_006() {
        # ipa service-add-host : add host, with caps/dash to manage service for HTTP/VPN
CAPSHOST=`echo t.example.com | tr "[a-z]" "[A-Z]"`
DASHHOST=`echo test1-test.example.com`

rlPhaseStartTest "service_add_host_006: ipa service-add-host : add host with $i to manage service."
for i in "$CAPSHOST" "$DASHHOST"; do
        rlRun "ipa host-add $i --force"
        for t in vpn; do
                rlRun "ipa service-add-host --hosts=$i $t/$MASTER@$RELM > $TmpDir/service_add_host_006.out 2>&1"
                rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_006.out"
                rlRun "cat $TmpDir/service_add_host_006.out"
        done
        rlRun "ipa service-remove-host --hosts=$i $t/$MASTER@$RELM" 0 "Removing the managed host for further testing"
        rlRun "ipa host-del $i" 0 "removing the added host $i"
done
	rlRun "ipa service-del $t/$MASTER@$RELM"
rlPhaseEnd
}

service_add_host_007() {
        # ipa service-add-host : add host, with multiple hosts to manage service 
HOST="test.example.com"
HOST2="test2.example.com"

for i in vpn; do
rlPhaseStartTest "service_add_host_007: ipa service-add-host : with multiple hosts to manage service."

	rlRun "ipa service-add $i/$MASTER@$RELM"
	rlRun "ipa host-add $HOST --force"
	rlRun "ipa host-add $HOST2 --force"
        rlRun "ipa service-add-host --hosts=$HOST2,$HOST $t/$MASTER@$RELM > $TmpDir/service_add_host_007.out 2>&1"
        rlAssertGrep "Number of members added 2" "$TmpDir/service_add_host_007.out"
        rlRun "cat $TmpDir/service_add_host_007.out"

        rlRun "ipa host-del $HOST" 0 "removing the added host $i"
        rlRun "ipa host-del $HOST2" 0 "removing the added host $i"
        rlRun "ipa service-del $i/$MASTER@$RELM" 

rlPhaseEnd
done
}

service_add_host_008() {
        # ipa service-add-host : check help
rlPhaseStartTest "service_add_host_008: ipa service-add-host : check help"
        rlRun "ipa help service-add-host > $TmpDir/service_add_host_008.out 2>&1"
        rlAssertGrep "Purpose: Add hosts that can manage this service." "$TmpDir/service_add_host_008.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-add-host PRINCIPAL" "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\--all         retrieve and print all attributes from the server." "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\--raw         print entries as stored on the server." "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\--hosts=LIST  comma-separated list of hosts to add" "$TmpDir/service_add_host_008.out"
        rlRun "cat $TmpDir/service_add_host_008.out"
rlPhaseEnd
}


service_del_001() {
        # ipa service-del: Checking service-del help
rlPhaseStartTest "service_del_001: Checking service-del help"
        rlRun "ipa help service-del > $TmpDir/service_del_001.out 2>&1"
        rlAssertGrep "Purpose: Delete an IPA service." "$TmpDir/service_del_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-del PRINCIPAL." "$TmpDir/service_del_001.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/service_del_001.out"
        rlAssertGrep "\--continue  Continuous mode: Don't stop on errors." "$TmpDir/service_del_001.out"
        rlRun "cat $TmpDir/service_del_001.out"
rlPhaseEnd
}


service_del_002() {
        # ipa service-del: del service for HTTP/VPN

rlPhaseStartTest "service_del_002: del service"
for i in VPN; do
	rlRun "ipa service-add $i/$MASTER@$RELM"
        rlRun "ipa service-del $i/$MASTER@$RELM > $TmpDir/service_del_002.out"
        rlRun "cat $TmpDir/service_del_002.out"
        rlAssertGrep "Deleted service \"$i/$MASTER@$RELM\"" "$TmpDir/service_del_002.out"
done
rlPhaseEnd
}

service_del_003() {
        # ipa service-del: re-delete the same or unknown service

rlPhaseStartTest "service_del_003: re-delete the same or unknown service."
for i in VPN; do
        rlRun "ipa service-del $i/$MASTER@$RELM > $TmpDir/service_del_003.out 2>&1" 2
        rlAssertGrep "ipa: ERROR: no such entry" "$TmpDir/service_del_003.out"
        rlRun "cat $TmpDir/service_del_003.out"
done
rlPhaseEnd
}

service_del_004() {
        # ipa service-del: with --continue option
rlPhaseStartTest "service_del_004: ipa service-del: with --continue option."
        # Adding service for this test
for i in imap vm; do
        rlRun "ipa service-add $i/$MASTER@$RELM"
done

        rlRun "ipa service-del IMAP/$MASTER@$RELM unknown/$MASTER@$RELM VM/$MASTER@$RELM" 2
        rlRun "ipa service-show IMAP/$MASTER@$RELM" 2
        rlRun "ipa service-show VM/$MASTER@$RELM"

        # re-adding IMAP service for --continue option test
        rlRun "ipa service-add IMAP/$MASTER@$RELM"
        rlRun "ipa service-del IMAP/$MASTER@$RELM unknown/$MASTER@$RELM VM/$MASTER@$RELM --continue > $TmpDir/service_del_004.out 2>&1"
        rlAssertGrep "Deleted service \"IMAP/$MASTER@$RELM,VM/$MASTER@$RELM\"" "$TmpDir/service_del_004.out"
        rlAssertGrep "Failed to remove: unknown/$MASTER@$RELM" "$TmpDir/service_del_004.out"
	rlRun "cat $TmpDir/service_del_004.out"

        rlRun "ipa service-show IMAP/$MASTER@$RELM" 2
        rlRun "ipa service-show VM/$MASTER@$RELM" 2
rlPhaseEnd
}

service_disable_001() {
        # ipa service-disable: help
rlPhaseStartTest "service_disable_001: ipa service-disable: help"
        rlRun "ipa help service-disable > $TmpDir/service_disable_001.out 2>&1"
        rlAssertGrep "Purpose: Disable the Kerberos key of a service." "$TmpDir/service_disable_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-disable PRINCIPAL" "$TmpDir/service_disable_001.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/service_disable_001.out"
rlPhaseEnd
}


service_disable_002() {
        # ipa service-disable: Disabling service for HTTP and VPN. 
rlPhaseStartTest "service_disable_002: ipa service-disable: Disabling service."
for i in VPN; do
        rlRun "ipa service-add $i/$MASTER@$RELM"
        rlRun "ipa-getkeytab --server $MASTER --principal $i/$MASTER@$RELM --keytab /opt/$i.$MASTER.$RELM.keytab"
        rlRun "ipa service-disable $i/$MASTER@$RELM > $TmpDir/service_disable_002.out 2>&1"
        rlRun "cat $TmpDir/service_disable_002.out 2>&1"
        rlAssertGrep "Removed kerberos key from \"$i/$MASTER@$RELM\"" "$TmpDir/service_disable_002.out"
        rlRun "ipa service-find $i/$MASTER@$RELM > $TmpDir/service_disable_002.out 2>&1"
        rlRun "cat $TmpDir/service_disable_002.out 2>&1"
        rlAssertNotGrep "Certificate:" "$TmpDir/service_disable_002.out"
        rlAssertGrep "Keytab: False" "$TmpDir/service_disable_002.out"
done
rlPhaseEnd
}

service_disable_003() {
        # ipa service-disable: Disabling an already disabled service
rlPhaseStartTest "service_disable_003: ipa service-disable: Disabling an already disabled service."
for i in VPN; do
        rlRun "ipa service-disable $i/$MASTER@$RELM > $TmpDir/service_disable_003.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: This entry is already disabled" "$TmpDir/service_disable_003.out"

	rlRun "ipa service-del $i/$MASTER@$RELM"
done
rlPhaseEnd
}

service_disable_004() {
        # ipa service-disable: Disabling a service with certificate

rlPhaseStartTest "service_disable_004: ipa service-disable: Disabling a service with certificate."
        rlRun "ipa service-add TEST/$MASTER@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+owDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDEyNzA0NDE1MloXDTIxMDEyNzA0NDE1MlowMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD0CIgKH8fe3hhAlSW00PNxyqYu8vD78lWbbarlF8dkFDvfutomPsyfag+fY+fPZ6h0e9gTNEoeD9mdyOeahRh34nbQds1+/rO2aAMaeiHMj/XYVNH0KQbUhgvsukTJloM6saodSbz91kbPPSzqxcQhZvsaL3yU4JjV/pdXaoEtxjwVdVUn0ph0RJWusAynWrKMVlGpJt2pNyOoHwcw7TX2MLkDimsXYyZH7RbNPRn56MUnD2KFoWoMYnIeePYU61lrKGpqO0Z+kUf7JISTG+cxULrpun89R2t4J7kNDq8veNsiwXjUb/tbWzX44uN7kuVuKj147bV13wBJUQoYiAZdAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAmNHlwgkHf2wJsBiT7ATE49W1dF/EL7VA5pY1sPMqtZmKSeaBzUS5KfU6wR9Wt4/Ba1sBA/dktWkpLOhSMVpQYfrlpPb2cxHP7Js2YhzjfuLsutrSmqeMT3/iO2/Gh7P5RHZX8Dls9cnZKpZ5dOjhip+Amkt8VEx7VltpECPRXqY="
        rlRun "ipa service-show TEST/$MASTER@$RELM --all > $TmpDir/service_disable_004.out 2>&1"
        rlRun "cat $TmpDir/service_disable_004.out"
        rlAssertGrep "has_keytab: False" "$TmpDir/service_disable_004.out"
        rlRun "ipa service-disable TEST/$MASTER@$RELM > $TmpDir/service_disable_004.out 2>&1" 1
        rlRun "grep -i \"ipa: ERROR: This entry is already disabled\" $TmpDir/service_disable_004.out"
		if [ $? != 0 ]; then
			rlLog "Refer: https://bugzilla.redhat.com/show_bug.cgi?id=673487"
		fi
        rlRun "cat $TmpDir/service_disable_004.out"

	rlRun "ipa service-del TEST/$MASTER@$RELM"
rlPhaseEnd
}



service_find_001() {

        # ipa service-find help 
rlPhaseStartTest "service_find_001: ipa service-find help"
        rlRun "ipa help service-find > $TmpDir/service_find_001.out 2>&1"
        rlAssertGrep "Purpose: Search for IPA services." "$TmpDir/service_find_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-find \[CRITERIA\]" "$TmpDir/service_find_001.out"
        rlAssertGrep "\-h, \--help           show this help message and exit" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--principal=STR      Service principal" "$TmpDir/service_find_001.out"
        rlAssertNotGrep "\--certificate=BYTES  Base-64 encoded server certificate" "$TmpDir/service_find_001.out"
	rlLog "\--certificate option is removed, ref https://bugzilla.redhat.com/show_bug.cgi?id=674736"
        rlAssertGrep "\--timelimit=INT      Time limit of search in seconds" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--sizelimit=INT      Maximum number of entries returned" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--all                retrieve and print all attributes from the server." "$TmpDir/service_find_001.out"
        rlAssertGrep "\--raw                print entries as stored on the server." "$TmpDir/service_find_001.out"
        rlAssertGrep "\--hosts=LIST         only services with member hosts" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--no-hosts=LIST      only services with no member hosts" "$TmpDir/service_find_001.out"
rlPhaseEnd
}

service_find_002() {
        # ipa service-find with --principal option
rlPhaseStartTest "service_find_002: ipa service-find with --principal option"
for i in VPN; do

	rlRun "ipa service-add $i/$MASTER@$RELM"

        rlRun "ipa service-find --principal=$i/$MASTER@$RELM > $TmpDir/service_find_002.out 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/service_find_002.out"
        rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_find_002.out"
        rlRun "cat $TmpDir/service_find_002.out"
done
rlPhaseEnd
}

service_find_003() {
        # ipa service-find with --principal and --all options
rlPhaseStartTest "service_find_003: ipa service-find with --principal and --all options."
for i in VPN; do
        rlRun "ipa service-find --principal=$i/$MASTER@$RELM --all > $TmpDir/service_find_003.out 2>&1"
        rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, top" "$TmpDir/service_find_003.out"
        rlAssertGrep "ipauniqueid:" "$TmpDir/service_find_003.out"
        rlAssertGrep "Keytab:" "$TmpDir/service_find_003.out"
        rlRun "cat $TmpDir/service_find_003.out"
done
rlPhaseEnd
}

service_find_004() {

rlPhaseStartTest "service_find_004: ipa service-find with --certificate option"
        # ipa service-find with --certificate option
        rlLog "this test case was removed. https://bugzilla.redhat.com/show_bug.cgi?id=674736"
rlPhaseEnd
}


service_find_005() {

        # ipa service-find with --no-host option

rlPhaseStartTest "service_find_005: ipa service-find with --no-host option"

for i in VPN; do
        rlRun "ipa host-add test.testrelm --force"
        rlRun "ipa service-add-host --hosts=test.testrelm $i/$MASTER@$RELM > $TmpDir/service_find_005.out 2>&1"
        rlRun "ipa service-find --no-hosts=test.testrelm > $TmpDir/service_find_005.out 2>&1"
        rlRun "cat $TmpDir/service_find_005.out"
        rlAssertGrep "Number of entries returned 3" "$TmpDir/service_find_005.out"
done
rlPhaseEnd
}

service_find_006() {

        # ipa service-find with --host option 

rlPhaseStartTest "service_find_006: ipa service-find with --host option"

for i in VPN; do
	rlRun "ipa service-find --hosts=test.testrelm > $TmpDir/service_find_006.out 2>&1"
        rlRun "cat $TmpDir/service_find_006.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/service_find_006.out"
done
rlPhaseEnd
}


service_find_007() {

        # ipa service-find with --sizelimit option

rlPhaseStartTest "service_find_007: ipa service-find with --sizelimit option"

        rlRun "ipa service-find --sizelimit=1 > $TmpDir/service_find_007.out 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/service_find_007.out"
        rlRun "cat $TmpDir/service_find_007.out"
}

service_find_008() {

rlPhaseStartTest "service_find_008: ipa service-find with --timelimit option"
        # ipa service-find with --timelimit option 
        # If timelimit comes in as 0 we set it to -1, unlimited, internally. 
        rlRun "ipa service-find --timelimit=0 > $TmpDir/service_find_008.out 2>&1"
        result=`cat $TmpDir/service_find_008.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 4 ] ; then
                rlPass "Number of 4 services returned as expected with time limit of 0"
        else
                rlFail "Number of services returned is not as expected.  GOT: $number EXP: 4"
        fi
rlPhaseEnd
}

service_find_009() {

        # ipa service-find with --timelimit option with invalid values
rlPhaseStartTest "service_find_009: ipa service-find with --timelimit option with invalid values"

        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa service-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa service-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."

	#Cleaning up for service-find test cases
for i in VPN; do
	rlRun "ipa service-del $i/$MASTER@$RELM"
done
	rlRun "ipa host-del test.testrelm"
rlPhaseEnd
}

service_find_010() {

        # ipa service-find with --timelimit option set to 1 TODO
rlPhaseStartTest "service_find_010: ipa service-find with --timelimit option set to 1"

rlPhaseEnd
}


service_mod_001() {

	# ipa service-mod check help
rlPhaseStartTest "service_mod_001: ipa service-mod check help"

	rlRun "ipa help service-mod > $TmpDir/service_mod_001.out 2>&1"
	rlRun "cat $TmpDir/service_mod_001.out"
	rlAssertGrep "Purpose: Modify an existing IPA service." "$TmpDir/service_mod_001.out"
	rlAssertGrep "Usage: ipa \[global-options\] service-mod PRINCIPAL \[options\]" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\-h, \--help           show this help message and exit" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--certificate=BYTES  Base-64 encoded server certificate" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--addattr=STR        Add an attribute/value pair. Format is attr=value." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--setattr=STR        Set an attribute to an name/value pair." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--rights             Display the access rights to modify this entry" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--all                retrieve and print all attributes from the server." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--raw                print entries as stored on the server." "$TmpDir/service_mod_001.out"

rlPhaseEnd
}

service_mod_002() {

	# ipa service-mod --rights, to display the rights while modifying a service
rlPhaseStartTest "service_mod_002: ipa service-mod --rights, to display the rights while modifying a service."
for i in vpn; do
	rlRun "ipa service-add $i/$MASTER@$RELM" 0 "Creating a service for this test"

	rlRun "ipa service-mod $i/$MASTER@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr+xeeVfh+foMdUe2UuJJ+DdWsJ1JZMBRKyTDmdd90nuXWWROYwgyrmwAf+3CFHmB5QaVnbAEyD8Hf3sC8k1VLkJACtxSLWx/5WMGzFJV30Xok82KrfPml4z4i6kelnz6KNWfgcM0yQkoohhbLmPqwnj2C4LpwM3QgeUltDCpEwCQCMXeTMDm8Kr6tFtjGmGjW5ncNhk7QLZDVwB++CGbERSCPRBqWSNtZ4yO2P+AOTjPreX6/XQOSMrAe+810YilJbTwx3vZBbAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAdK33A68CrIfM/BmH8MYGDrdGLK7x54Kkez+nlz9WAv6KEIDiWJXw4HY3iIPkJoYIvOhYT4lIdYiOlDgd3yABjGb0g/iglZ4u2qRDQc9nAYul9o5X8/Mlv38d+0QO5NxOtwk6Cvnt4UTtqoRUeZ8244inmPSBdZr6XHUVlePCNiw= --rights --all > $TmpDir/service_mod_002.out"
	rlRun "cat $TmpDir/service_mod_002.out"
	rlAssertGrep "Modified service \"$i/$MASTER@$RELM\"" "$TmpDir/service_mod_002.out"
	rlAssertGrep "attributelevelrights: {'krbextradata': u'rsc', 'krbcanonicalname': u'rsc', 'usercertificate': u'rscwo', 'krbupenabled': u'rsc', 'krbticketflags': u'rsc', 'krbprincipalexpiration': u'rsc', 'krbobjectreferences': u'rscwo', 'krbmaxrenewableage': u'rscwo', 'nsaccountlock': u'rscwo', 'managedby': u'rscwo', 'krblastsuccessfulauth': u'rsc', 'krbprincipaltype': u'rsc', 'krbprincipalkey': u'wo', 'memberof': u'rsc', 'krbmaxticketlife': u'rscwo', 'krbpwdpolicyreference': u'rsc', 'krbprincipalname': u'rsc', 'krbticketpolicyreference': u'rsc', 'krblastadminunlock': u'rscwo', 'krbpasswordexpiration': u'rsc', 'krblastfailedauth': u'rsc', 'objectclass': u'rscwo', 'aci': u'rscwo', 'krbpwdhistory': u'rsc', 'krbprincipalaliases': u'rsc', 'krbloginfailedcount': u'rsc', 'krblastpwdchange': u'rscwo', 'ipauniqueid': u'rsc'}" "$TmpDir/service_mod_002.out"
	rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, top" "$TmpDir/service_mod_002.out"


	rlRun "ipa service-del $i/$MASTER@$RELM"
done
rlPhaseEnd
}

service_mod_003() {

	# ipa service-mod --certificate, adding certificate to an existing service.
rlPhaseStartTest "service_mod_003: ipa service-mod --certificate, adding certificate to an existing service."

for i in vpn; do
        rlRun "ipa service-add $i/$MASTER@$RELM" 0 "Creating a service for this test"

        rlRun "ipa service-mod $i/$MASTER@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr+xeeVfh+foMdUe2UuJJ+DdWsJ1JZMBRKyTDmdd90nuXWWROYwgyrmwAf+3CFHmB5QaVnbAEyD8Hf3sC8k1VLkJACtxSLWx/5WMGzFJV30Xok82KrfPml4z4i6kelnz6KNWfgcM0yQkoohhbLmPqwnj2C4LpwM3QgeUltDCpEwCQCMXeTMDm8Kr6tFtjGmGjW5ncNhk7QLZDVwB++CGbERSCPRBqWSNtZ4yO2P+AOTjPreX6/XQOSMrAe+810YilJbTwx3vZBbAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAdK33A68CrIfM/BmH8MYGDrdGLK7x54Kkez+nlz9WAv6KEIDiWJXw4HY3iIPkJoYIvOhYT4lIdYiOlDgd3yABjGb0g/iglZ4u2qRDQc9nAYul9o5X8/Mlv38d+0QO5NxOtwk6Cvnt4UTtqoRUeZ8244inmPSBdZr6XHUVlePCNiw= > $TmpDir/service_mod_003.out 2>&1"
	rlRun "cat $TmpDir/service_mod_003.out"
	rlAssertGrep "Modified service \"$i/$MASTER@$RELM\"" "$TmpDir/service_mod_003.out"
	rlAssertGrep "Certificate: MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr+xeeVfh+foMdUe2UuJJ+DdWsJ1JZMBRKyTDmdd90nuXWWROYwgyrmwAf+3CFHmB5QaVnbAEyD8Hf3sC8k1VLkJACtxSLWx/5WMGzFJV30Xok82KrfPml4z4i6kelnz6KNWfgcM0yQkoohhbLmPqwnj2C4LpwM3QgeUltDCpEwCQCMXeTMDm8Kr6tFtjGmGjW5ncNhk7QLZDVwB++CGbERSCPRBqWSNtZ4yO2P+AOTjPreX6/XQOSMrAe+810YilJbTwx3vZBbAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAdK33A68CrIfM/BmH8MYGDrdGLK7x54Kkez+nlz9WAv6KEIDiWJXw4HY3iIPkJoYIvOhYT4lIdYiOlDgd3yABjGb0g/iglZ4u2qRDQc9nAYul9o5X8/Mlv38d+0QO5NxOtwk6Cvnt4UTtqoRUeZ8244inmPSBdZr6XHUVlePCNiw=" "$TmpDir/service_mod_003.out"
	rlAssertGrep "Fingerprint (MD5):" "$TmpDir/service_mod_003.out"
	rlAssertGrep "Fingerprint (SHA1):" "$TmpDir/service_mod_003.out"


	rlRun "ipa service-show $i/$MASTER@$RELM > $TmpDir/service_mod_003.out 2>&1"
	rlRun "cat $TmpDir/service_mod_003.out"
	rlAssertGrep "Certificate: MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr+xeeVfh+foMdUe2UuJJ+DdWsJ1JZMBRKyTDmdd90nuXWWROYwgyrmwAf+3CFHmB5QaVnbAEyD8Hf3sC8k1VLkJACtxSLWx/5WMGzFJV30Xok82KrfPml4z4i6kelnz6KNWfgcM0yQkoohhbLmPqwnj2C4LpwM3QgeUltDCpEwCQCMXeTMDm8Kr6tFtjGmGjW5ncNhk7QLZDVwB++CGbERSCPRBqWSNtZ4yO2P+AOTjPreX6/XQOSMrAe+810YilJbTwx3vZBbAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAdK33A68CrIfM/BmH8MYGDrdGLK7x54Kkez+nlz9WAv6KEIDiWJXw4HY3iIPkJoYIvOhYT4lIdYiOlDgd3yABjGb0g/iglZ4u2qRDQc9nAYul9o5X8/Mlv38d+0QO5NxOtwk6Cvnt4UTtqoRUeZ8244inmPSBdZr6XHUVlePCNiw=" "$TmpDir/service_mod_003.out"

done
rlPhaseEnd
}

service_mod_004() {

	# ipa service-mod: updating service with a non-standard certificate format.
rlPhaseStartTest "service_mod_004: ipa service-mod: updating service with a non-standard certificate format."
for i in vpn; do
	rlRun "ipa service-mod $i/$MASTER@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr > $TmpDir/service_mod_004.out 2>&1" 1
	rlRun "cat $TmpDir/service_mod_004.out"
	rlAssertGrep "ipa: ERROR: Certificate format error: improperly formatted DER-encoded certificate" "$TmpDir/service_mod_004.out"

	rlRun "ipa service-del $i/$MASTER@$RELM"
done
rlPhaseEnd
}

service_mod_005() {

	# ipa service-mod: modifying the service with --raw option
rlPhaseStartTest "service_mod_005: ipa service-mod: modifying the service with --raw option"
for i in vpn; do
        rlRun "ipa service-add $i/$MASTER@$RELM" 0 "Creating a service for this test"

        rlRun "ipa service-mod $i/$MASTER@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr+xeeVfh+foMdUe2UuJJ+DdWsJ1JZMBRKyTDmdd90nuXWWROYwgyrmwAf+3CFHmB5QaVnbAEyD8Hf3sC8k1VLkJACtxSLWx/5WMGzFJV30Xok82KrfPml4z4i6kelnz6KNWfgcM0yQkoohhbLmPqwnj2C4LpwM3QgeUltDCpEwCQCMXeTMDm8Kr6tFtjGmGjW5ncNhk7QLZDVwB++CGbERSCPRBqWSNtZ4yO2P+AOTjPreX6/XQOSMrAe+810YilJbTwx3vZBbAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAdK33A68CrIfM/BmH8MYGDrdGLK7x54Kkez+nlz9WAv6KEIDiWJXw4HY3iIPkJoYIvOhYT4lIdYiOlDgd3yABjGb0g/iglZ4u2qRDQc9nAYul9o5X8/Mlv38d+0QO5NxOtwk6Cvnt4UTtqoRUeZ8244inmPSBdZr6XHUVlePCNiw= --raw > $TmpDir/service_mod_005.out 2>&1"
        rlRun "cat $TmpDir/service_mod_005.out"
	rlAssertGrep "serial_number: 1006" "$TmpDir/service_mod_005.out"
	rlAssertGrep "md5_fingerprint:" "$TmpDir/service_mod_005.out"
	rlAssertGrep "sha1_fingerprint:" "$TmpDir/service_mod_005.out"
	rlAssertGrep "valid_not_before:" "$TmpDir/service_mod_005.out"
	rlAssertGrep "valid_not_after:" "$TmpDir/service_mod_005.out"

	rlRun "ipa service-del $i/$MASTER@$RELM"
done
rlPhaseEnd
}

service_mod_006() {

	# ipa service-mod: modifying the service with --setattr option

rlPhaseStartTest "service_mod_006: ipa service-mod: modifying the service with --setattr option"

for i in vpn; do
	rlRun "ipa service-add $i/$MASTER@$RELM"
	rlRun "ipa service-mod $i/$MASTER@$RELM --addattr=objectclass=groupofnames --addattr=cn=$i"

	rlRun "ipa service-mod $i/$MASTER@$RELM --setattr=cn=test > $TmpDir/service_mod_006.out 2>&1"
        rlRun "cat $TmpDir/service_mod_006.out"
	rlAssertGrep "Modified service \"$i/$MASTER@$RELM\"" "$TmpDir/service_mod_006.out"

	rlRun "ipa service-show $i/$MASTER@$RELM --all > --raw > $TmpDir/service_mod_006.out 2>&1"
        rlRun "cat $TmpDir/service_mod_006.out"
	rlAssertGrep "cn: test" "$TmpDir/service_mod_006.out" -i

        rlRun "ipa service-del $i/$MASTER@$RELM"
done
rlPhaseEnd
}

service_remove_host_001() {
        # ipa service-remove-host: check help
rlPhaseStartTest "service_remove_host_001: ipa service-remove-host: check help"
        rlRun "ipa help service-remove-host > $TmpDir/service_remove_host_001.out 2>&1"
        rlAssertGrep "Purpose: Remove hosts that can manage this service." "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-remove-host PRINCIPAL" "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\-h, \--help    show this help message and exit" "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\--all         retrieve and print all attributes from the server." "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\--raw         print entries as stored on the server." "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\--hosts=LIST  comma-separated list of hosts to remove" "$TmpDir/service_remove_host_001.out"
rlPhaseEnd
}


service_remove_host_002() {
        # ipa service-remove-host for services
rlPhaseStartTest "service_remove_host_002: ipa service-remove-host for services"
for i in vpn; do
        rlRun "ipa host-add test.example.com --force" 0 "adding host for service_remove_host test cases"
	rlRun "ipa service-add $i/$MASTER@$RELM"
        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM > $TmpDir/service_remove_host_002.out 2>&1"
        rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_remove_host_002.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/service_remove_host_002.out"
        rlRun "cat $TmpDir/service_remove_host_002.out"
done
rlPhaseEnd
}


service_remove_host_003() {

        # ipa service-remove-host for services with --all option
rlPhaseStartTest "service_remove_host_003: ipa service-remove-host for services with --all option"
for i in vpn; do

        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM --all > $TmpDir/service_remove_host_003.out 2>&1"
        rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_remove_host_003.out"
        rlAssertGrep "ipauniqueid:" "$TmpDir/service_remove_host_003.out"
        rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, top" "$TmpDir/service_remove_host_003.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/service_remove_host_003.out"
        rlRun "cat $TmpDir/service_remove_host_003.out"
done
rlPhaseEnd
}


service_remove_host_004() {

        # ipa service-remove-host for services with --all and --raw options
rlPhaseStartTest "service_remove_host_004: ipa service-remove-host for services with --all and --raw options"
for i in vpn; do

        rlRun "ipa service-add-host --hosts=test.example.com $i/$MASTER@$RELM"

        rlRun "ipa service-remove-host --hosts=test.example.com $i/$MASTER@$RELM --all --raw > $TmpDir/service_remove_host_004.out 2>&1"
        rlAssertGrep "krbprincipalname: $i/$MASTER@$RELM" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "managedby: fqdn=$MASTER,cn=computers,cn=accounts,dc=testrelm" "$TmpDir/service_remove_host_004.out" -i
        rlAssertGrep "objectclass: ipaobject" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: ipaservice" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: pkiuser" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: krbprincipal" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: krbprincipalaux" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: krbTicketPolicyAux" "$TmpDir/service_remove_host_004.out" -i

        rlRun "cat $TmpDir/service_remove_host_004.out"
done
	# Cleaning up hosts and services
for i in vpn; do
	rlRun "ipa service-del $i/$MASTER@$RELM"
done
	rlRun "ipa host-del test.example.com"
rlPhaseEnd
}


service_show_001() {

        # ipa service-show help
rlPhaseStartTest "service_show_001: ipa service-show help"
        rlRun "ipa help service-show > $TmpDir/service_show_001.out 2>&1"
        rlAssertGrep "Purpose: Display information about an IPA service." "$TmpDir/service_show_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-show PRINCIPAL" "$TmpDir/service_show_001.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/service_show_001.out"
        rlAssertGrep "\--rights    Display the access rights to modify this entry (requires \--all)" "$TmpDir/service_show_001.out"
        rlAssertGrep "\--out=STR   file to store certificate in" "$TmpDir/service_show_001.out"
        rlAssertGrep "\--all       retrieve and print all attributes from the server." "$TmpDir/service_show_001.out"
        rlAssertGrep "\--raw       print entries as stored on the server." "$TmpDir/service_show_001.out"
        rlRun "cat $TmpDir/service_show_001.out"
rlPhaseEnd
}


service_show_002() {

        # ipa service-show with --all option
rlPhaseStartTest "service_show_002: ipa service-show with --all option"
for i in http; do
        rlRun "ipa service-show $i/$MASTER@$RELM  --all > $TmpDir/service_show_002.out 2>&1"
        rlAssertGrep "Principal: $i/$MASTER@$RELM" "$TmpDir/service_show_002.out" -i 
        rlAssertGrep "has_keytab: True" "$TmpDir/service_show_002.out"
        rlAssertGrep "objectclass: ipaobject, top, ipaservice, pkiuser, krbprincipal, krbprincipalaux, krbTicketPolicyAux" "$TmpDir/service_show_002.out"
        rlAssertGrep "valid_not_after:" "$TmpDir/service_show_002.out"
        rlAssertGrep "valid_not_before:" "$TmpDir/service_show_002.out"
        rlAssertGrep "Certificate:" "$TmpDir/service_show_002.out"
        rlRun "cat $TmpDir/service_show_002.out"
done
rlPhaseEnd
}

service_show_003() {

        # ipa service-show with --out option
rlPhaseStartTest "service_show_003: ipa service-show with --out option"
for i in http; do
        rlRun "ipa service-show $i/$MASTER@$RELM --out=$TmpDir/service_show_003.out"
        rlAssertFile "$TmpDir/service_show_003.out"
        rlAssertGrep "\-----BEGIN CERTIFICATE-----" "$TmpDir/service_show_003.out"
        rlAssertGrep "\-----END CERTIFICATE-----" "$TmpDir/service_show_003.out"
        rlRun "cat $TmpDir/service_show_003.out"
done
rlPhaseEnd
}

service_show_004() {

        # ipa service-show with --raw option
rlPhaseStartTest "service_show_004: ipa service-show with --raw option"
for i in http; do
        rlRun "ipa service-show $i/$MASTER@$RELM --raw  > $TmpDir/service_show_004.out 2>&1"
        rlAssertGrep "krbprincipalname: $i/$MASTER@$RELM" "$TmpDir/service_show_004.out" -i
        rlAssertGrep "usercertificate:" "$TmpDir/service_show_004.out"
        rlRun "cat $TmpDir/service_show_004.out"
done
rlPhaseEnd
}


service_show_005() {

        # ipa service-show with --rights options (requires --all)
rlPhaseStartTest "service_show_005: ipa service-show with --rights options (requires --all)"
for i in http; do
        rlRun "ipa service-show $i/$MASTER@$RELM --rights --all > $TmpDir/service_show_005.out 2>&1"
        rlAssertGrep "attributelevelrights: {'krbextradata': u'rsc', 'krbcanonicalname': u'rsc', 'usercertificate': u'rscwo', 'krbupenabled': u'rsc', 'krbticketflags': u'rsc', 'krbprincipalexpiration': u'rsc', 'krbobjectreferences': u'rscwo', 'krbmaxrenewableage': u'rscwo', 'nsaccountlock': u'rscwo', 'managedby': u'rscwo', 'krblastsuccessfulauth': u'rsc', 'krbprincipaltype': u'rsc', 'krbprincipalkey': u'wo', 'memberof': u'rsc', 'ipauniqueid': u'rsc', 'krbpwdpolicyreference': u'rsc', 'krbprincipalname': u'rsc', 'krbticketpolicyreference': u'rsc', 'krblastadminunlock': u'rscwo', 'krbpasswordexpiration': u'rsc', 'krblastfailedauth': u'rsc', 'objectclass': u'rscwo', 'aci': u'rscwo', 'krbpwdhistory': u'rsc', 'krbprincipalaliases': u'rsc', 'krbloginfailedcount': u'rsc', 'krblastpwdchange': u'rscwo', 'krbmaxticketlife': u'rscwo'}" "$TmpDir/service_show_005.out" -i
        rlRun "cat $TmpDir/service_show_005.out"
done
rlPhaseEnd
}



cleanup() {
rlPhaseStartTest "Clean up for ipa services tests"
	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "kdestroy" 0 "Destroying admin credentials."

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
rlPhaseEnd
}
