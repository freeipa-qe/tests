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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################
user1="user1"
user2="user2"
userpw="Secret123"

TMP_KEYTAB="/opt/krb5.keytab"
SERVICE=vpn

TESTHOST=dummy.$DOMAIN

setup() {
rlPhaseStartSetup "Setup for ipa service tests"
        rlDistroDiff ipa_pkg_check
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user" 
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
rlPhaseEnd
}	

service_add_001() {
	# ipa service-add : add service for $SERVICE
rlPhaseStartTest "service_add_001: ipa service-add : add service for $SERVICE"
	rlRun "ipa -v service-add $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_add_001.out 2>&1"
	rlAssertGrep "Added service \"$SERVICE\/$HOSTNAME@$RELM\"" "$TmpDir/service_add_001.out"
	rlRun "cat $TmpDir/service_add_001.out"

	# Deleting this service for future test cases
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd
}

service_add_002() {
	# ipa service-add : add service for $SERVICE with all option
rlPhaseStartTest "service_add_002: ipa service-add : add service for $SERVICE with all option"

	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM --all > $TmpDir/service_add_002.out 2>&1"
	rlAssertGrep "Added service \"$SERVICE\/$HOSTNAME@$RELM\"" "$TmpDir/service_add_002.out"
	rlAssertGrep "Principal: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_add_002.out"
	rlAssertGrep "Managed by: $HOSTNAME" "$TmpDir/service_add_002.out"
	rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, ipakrbprincipal, top" "$TmpDir/service_add_002.out"

	rlRun "cat $TmpDir/service_add_002.out"

	# Deleting this service for future test cases
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd

}

service_add_003() {
	# ipa service-add : add service for vpn with cert bytes
rlPhaseStartTest "service_add_003: ipa service-add : add service for $SERVICE with cert bytes"

	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM --certificate=wrong > $TmpDir/service_add_003A.out 2>&1" 1
	#rlAssertGrep "ipa: ERROR: invalid 'certificate': must be binary data" "$TmpDir/service_add_003A.out"
	rlAssertGrep "ipa: ERROR: Base64 decoding failed: Incorrect padding" "$TmpDir/service_add_003A.out"
	rlRun "cat $TmpDir/service_add_003A.out"

	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM --certificate=MIIC9jCCAd6gAwIBAgIBCTANBgkqhkiG9w0BAQ0FADA5MRIwEAYDVQQKEwlzaWxlbnRkb20xIzAhBgNVBAMTGkNlcnRpZmljYXRlIEF1dGhvcml0eWNhLXQxMB4XDTExMDExOTEyMjc1M1oXDTEzMDEwODEyMjc1M1owJjERMA8GA1UEAxMIYWNjb3VudHMxETAPBgNVBAMTCHNlcnZpY2VzMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbcRxo0/tfpoJEzCLmfTDy9AYQIyubgwo2ErV+6unEKY2OW3YHIBW6Th6xg62tMzqQatIqqJKse9AnVoObWAiqhpjPdr2FuL6LiyRb1Aez9E5MVndfbsto0F7OYSs6y1yICSBAfA1CFAdRm+WOnBDI1e3hcg3UHXUukifKg4XaLQIDAQABo4GfMIGcMB8GA1UdIwQYMBaAFEoAQIQqOuqP8Ilyez9pzQCblEmWMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL2JldGEuZHNkZXYuc2pjLnJlZGhhdC5jb206NDgxODAvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA0GCSqGSIb3DQEBDQUAA4IBAQCWk7YuyH6NTqILzmGK3qjIkreCpXnbNE99yrc7UQka9btrq2FWoFSxteU2JFD3+EGG8tXuDyDuWlgs8F3X/CBB4N+ZV4fAzHpIp2aIRQMapLKvu/mEiGPjFWFYJqk/HiNSQk8qefI6XqLvWIVY4LxMn4m1ZsQ/XXBzNbWsf9W3jnwCY0cLygJIgZZt2uQH/KxoQ3/oE0gp1wYITeKAKvaQrwUc4YgshlxMZAN4z5FuXdtDQqAIrJYcg9q+j6zYHNtXTcLuCFO0CcFto8CaUGXUJ0B5IrV2xsnRegHRxBy+C+3lfYiW2DelWI3exiYgdlU5wJSlkX37HQxA9cP+/kIib > $TmpDir/service_add_003B.out 2>&1" 1

	#rlAssertGrep "ipa: ERROR: invalid 'certificate': must be binary data" "$TmpDir/service_add_003B.out"
	rlAssertGrep "ipa: ERROR: Base64 decoding failed: Incorrect padding" "$TmpDir/service_add_003B.out"
	rlRun "cat $TmpDir/service_add_003B.out"

	ipa service-del $SERVICE/$HOSTNAME@$RELM > /tmp/certerr.out 2>&1
	cat /tmp/certerr.out | grep "ipa: ERROR: Certificate operation cannot be completed"
	if [ $? -eq 0 ] ; then
		ipa service-mod --certificate="" $SERVICE/$HOSTNAME@$RELM
		ipa service-del $SERVICE/$HOSTNAME@$RELM
	fi

	# lets make sure service is deleted here because of above work around for bug 691488
	rlRun "ipa service-show $SERVICE/$HOSTNAME@$RELM" 2 "Checking to make sure service is deleted"
	
rlPhaseEnd
}

service_add_004() {
	# ipa service-add : add service for vpn with force option

rlPhaseStartTest "service_add_004: ipa service-add : add service for $SERVICE with cert bytes and --force option"
	rlRun "ipa host-add --force $TESTHOST" 0 "Adding dummy host with no DNS records"
        rlRun "ipa service-add $SERVICE/$TESTHOST@$RELM --force --certificate=wrong > $TmpDir/service_add_004A.out 2>&1" 1
        #rlAssertGrep "ipa: ERROR: invalid 'certificate': must be binary data" "$TmpDir/service_add_004A.out"
	rlAssertGrep "ipa: ERROR: Base64 decoding failed: Incorrect padding" "$TmpDir/service_add_004A.out"
        rlRun "cat $TmpDir/service_add_004A.out"
        rlRun "ipa service-add $SERVICE/$TESTHOST@$RELM --force --certificate=MIIC9jCCAd6gAwIBAgIBCTANBgkqhkiG9w0BAQ0FADA5MRIwEAYDVQQKEwlzaWxlbnRkb20xIzAhBgNVBAMTGkNlcnRpZmljYXRlIEF1dGhvcml0eWNhLXQxMB4XDTExMDExOTEyMjc1M1oXDTEzMDEwODEyMjc1M1owJjERMA8GA1UEAxMIYWNjb3VudHMxETAPBgNVBAMTCHNlcnZpY2VzMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbcRxo0/tfpoJEzCLmfTDy9AYQIyubgwo2ErV+6unEKY2OW3YHIBW6Th6xg62tMzqQatIqqJKse9AnVoObWAiqhpjPdr2FuL6LiyRb1Aez9E5MVndfbsto0F7OYSs6y1yICSBAfA1CFAdRm+WOnBDI1e3hcg3UHXUukifKg4XaLQIDAQABo4GfMIGcMB8GA1UdIwQYMBaAFEoAQIQqOuqP8Ilyez9pzQCblEmWMEoGCCsGAQUFBwEBBD4wPDA6BggrBgEFBQcwAYYuaHR0cDovL2JldGEuZHNkZXYuc2pjLnJlZGhhdC5jb206NDgxODAvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMA0GCSqGSIb3DQEBDQUAA4IBAQCWk7YuyH6NTqILzmGK3qjIkreCpXnbNE99yrc7UQka9btrq2FWoFSxteU2JFD3+EGG8tXuDyDuWlgs8F3X/CBB4N+ZV4fAzHpIp2aIRQMapLKvu/mEiGPjFWFYJqk/HiNSQk8qefI6XqLvWIVY4LxMn4m1ZsQ/XXBzNbWsf9W3jnwCY0cLygJIgZZt2uQH/KxoQ3/oE0gp1wYITeKAKvaQrwUc4YgshlxMZAN4z5FuXdtDQqAIrJYcg9q+j6zYHNtXTcLuCFO0CcFto8CaUGXUJ0B5IrV2xsnRegHRxBy+C+3lfYiW2DelWI3exiYgdlU5wJSlkX37HQxA9cP+/kIb > $TmpDir/service_add_004B.out 2>&1" 1

	rlAssertGrep "ipa: ERROR: Certificate operation cannot be completed: Issuer \"CN=Certificate Authorityca-t1,O=silentdom\" does not match the expected issuer" "$TmpDir/service_add_004B.out"
        rlRun "cat $TmpDir/service_add_004B.out"

	#deleting for the added service for the next test case
	ipa service-del $SERVICE/$TESTHOST@$RELM > /tmp/certerr.out 2>&1
        cat /tmp/certerr.out | grep "ipa: ERROR: Certificate operation cannot be completed"
        if [ $? -eq 0 ] ; then
                ipa service-mod --certificate="" $SERVICE/$TESTHOST@$RELM
                ipa service-del $SERVICE/$TESTHOST@$RELM
        fi

        # lets make sure service is deleted here because of above work around for bug 691488
        rlRun "ipa service-show $SERVICE/$TESTHOST@$RELM" 2 "Checking to make sure service is deleted"
	rlRun "ipa host-del $TESTHOST" 0 "Deleting dummy host"

rlPhaseEnd

}

service_add_005() {
	# ipa service-add : add service for vpn with raw option

rlPhaseStartTest "service_add_005: ipa service-add : add service for $SERVICE with --raw option"

        rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM --raw > $TmpDir/service_add_005.out 2>&1"
        rlAssertGrep "Added service \"$SERVICE/$HOSTNAME@$RELM\"" "$TmpDir/service_add_005.out"
	rlAssertGrep "krbprincipalname: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_add_005.out"
        rlRun "cat $TmpDir/service_add_005.out"

	#deleting for the added service for the next test case
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd

}

service_add_006() {

rlPhaseStartTest "service_add_006: ipa service-add: verifying the help message"
	# ipa service-add : check add help
	rlRun "ipa help service-add > $TmpDir/service_add_006.out 2>&1"
	rlAssertGrep "Purpose: Add a new IPA new service." "$TmpDir/service_add_006.out"
	rlAssertGrep "Usage: ipa \[global-options\] service-add PRINCIPAL" "$TmpDir/service_add_006.out"
	rlAssertGrep "\-h, --help            show this help message and exit" "$TmpDir/service_add_006.out"
	rlAssertGrep "\--certificate=BYTES   Base-64 encoded server certificate" "$TmpDir/service_add_006.out"
	rlAssertGrep "\--pac-type=\['MS-PAC', 'PAD', 'NONE'\]" "$TmpDir/service_add_006.out"
	rlAssertGrep "Override default list of supported PAC types." "$TmpDir/service_add_006.out"
	rlAssertGrep "\--setattr=STR         Set an attribute to a name/value pair." "$TmpDir/service_add_006.out"
	rlAssertGrep "\--addattr=STR         Add an attribute/value pair. Format is attr=value." "$TmpDir/service_add_006.out"
	rlAssertGrep "\--force               force principal name even if not in DNS" "$TmpDir/service_add_006.out"
	rlAssertGrep "\--all                 Retrieve and print all attributes from the server." "$TmpDir/service_add_006.out"
	rlAssertGrep "\--raw                 Print entries as stored on the server." "$TmpDir/service_add_006.out"
	rlRun "cat $TmpDir/service_add_006.out"
rlPhaseEnd
}

service_add_007() {

	# ipa service-add : re-add service for vpn
rlPhaseStartTest "service_add_007: ipa service-add: re-add service for $SERVICE"
	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_add_007.out 2>&1" 1
	rlAssertGrep "ipa: ERROR: service with name \"$SERVICE/$HOSTNAME@$RELM\" already exists" "$TmpDir/service_add_007.out"
	rlRun "cat $TmpDir/service_add_007.out"

	#deleting for the added service for the next test case
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd

}

service_add_008() {
	# service_add_008: ipa service-add : invalid principal

rlPhaseStartTest "service_add_008: ipa service-add : invalid principal"
        rlRun "ipa service-add $SERVICE/random.ipaserver@$RELM > $TmpDir/service_add_008.out 2>&1" 2
        rlAssertGrep "ipa: ERROR: The host 'random.ipaserver' does not exist to add a service to." "$TmpDir/service_add_008.out"
        rlRun "cat $TmpDir/service_add_008.out"

rlPhaseEnd

}

service_add_009() {
	# service_add_009: Adding service with missing service name.

rlPhaseStartTest "service_add_009: ipa service-add: Adding service with missing service name."
        rlRun "ipa service-add $HOSTNAME@$RELM > $TmpDir/service_add_009.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: Service principal is not of the form: service\/fully-qualified host name: missing service" "$TmpDir/service_add_009.out"
        rlRun "cat $TmpDir/service_add_009.out"
rlPhaseEnd

}

service_add_010() {
	# service_add_010: Adding service with missing host domain

rlPhaseStartTest "service_add_010: ipa service-add: Adding service with missing fqdn."
	rlRun "ipa -v service-add $SERVICE/$HOSTNAME > $TmpDir/service_add_010.out 2>&1"
        rlAssertGrep "Added service \"$SERVICE\/$HOSTNAME@$RELM\"" "$TmpDir/service_add_010.out"
        rlRun "cat $TmpDir/service_add_010.out"

        # Deleting this service for future test cases
        rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd
}

service_add_011() {
rlPhaseStartTest "service_add_011: ipa service-add: Adding service with missing hostname in fqdn"
	rlRun "ipa service-add $SERVICE/@$RELM > $TmpDir/service_add_011.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: 'fqdn' is required" "$TmpDir/service_add_011.out"
        rlRun "cat $TmpDir/service_add_011.out"
rlPhaseEnd

}

service_add_host_001() {
        # ipa service-add-host : add host to manage service for vpn - host does not exist.
rlPhaseStartTest "service_add_host_001: ipa service-add-host : add host to manage service for HTTP/$SERVICE - host does not exist."
        rlRun "ipa service-add-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_add_host_001.out 2>&1" 2
        rlRun "cat $TmpDir/service_add_host_001.out"
        rlAssertNotGrep "Number of members added 0" "$TmpDir/service_add_host_001.out"
rlPhaseEnd
}

service_add_host_002() {
rlPhaseStartTest "service_add_host_002: ipa service-add-host: add host to manage service - host does exist."
        # adding host for further test
        rlRun "ipa host-add $TESTHOST --force"
	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
        # ipa service-add-host : add host to manage service for vpn - host exists
        rlRun "ipa service-add-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_add_host_002.out 2>&1"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_002.out"

        rlRun "ipa service-remove-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM" 0 "Removing the managed host for further testing"
rlPhaseEnd
}

service_add_host_003() {
        # ipa service-add-host : add host to manage service for vpn with all option
	
rlPhaseStartTest "service_add_host_003: ipa service-add-host : add host to manage service with all option."
        rlRun "ipa service-add-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM --all > $TmpDir/service_add_host_003.out 2>&1"
        rlAssertGrep "Managed by: $HOSTNAME, $TESTHOST" "$TmpDir/service_add_host_003.out"
        rlAssertGrep "ipauniqueid:" "$TmpDir/service_add_host_003.out"
        rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, ipakrbprincipal, top" "$TmpDir/service_add_host_003.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_003.out"
        rlRun "cat $TmpDir/service_add_host_003.out"

        rlRun "ipa service-remove-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM" 0 "Removing the managed host for further testing"
rlPhaseEnd
}

service_add_host_004() {
        # ipa service-add-host : add host to manage service for $SERVICE with raw option
rlPhaseStartTest "service_add_host_004: ipa service-add-host : add host to manage service with raw option."
        rlRun "ipa service-add-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM --raw > $TmpDir/service_add_host_004.out 2>&1"
        rlAssertGrep "krbprincipalname: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_add_host_004.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_004.out"
        rlRun "cat $TmpDir/service_add_host_004.out"

        rlRun "ipa service-remove-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM" 0 "Removing the managed host for further testing"
rlPhaseEnd
}

service_add_host_005() {
        # ipa service-add-host : add host to manage service for HTTP/$SERVICE with raw and all options
rlPhaseStartTest "service_add_host_005: ipa service-add-host : add host to manage service with raw and all options"
        rlRun "ipa service-add-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM --raw --all > $TmpDir/service_add_host_005.out 2>&1"
        rlAssertGrep "krbprincipalname: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_add_host_005.out"
        rlRun "grep -i \"managedby: fqdn=$TESTHOST,cn=computers,cn=accounts,$BASEDN\" $TmpDir/service_add_host_005.out"
        rlAssertGrep "objectclass: krbticketpolicyaux" "$TmpDir/service_add_host_005.out"
        rlAssertGrep "objectclass: krbprincipalaux" "$TmpDir/service_add_host_005.out"
        rlAssertGrep "objectclass: ipaservice" "$TmpDir/service_add_host_005.out"
        rlAssertGrep "Number of members added 1" "$TmpDir/service_add_host_005.out"
        rlRun "cat $TmpDir/service_add_host_005.out"

        rlRun "ipa service-remove-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM" 0 "Removing the managed host for further testing"
        rlRun "ipa host-del $TESTHOST" 0 "removing host test.example.com for further tests"
rlPhaseEnd
}

service_add_host_006() {
        # ipa service-add-host : add host with caps/dash to manage service for $SERVICE
CAPSHOST="CAPS.$RELM"
DASHHOST="test1-test.$DOMAIN"
LCAPSHOST=`echo $CAPSHOST | tr "[A-Z]" "[a-z]"`

rlPhaseStartTest "service_add_host_006: ipa service-add-host : add host with caps/dash to manage service."
        rlRun "ipa host-add $CAPSHOST --force"
	rlRun "ipa host-add --force $DASHHOST"
        rlRun "ipa service-add-host --hosts=$CAPSHOST,$DASHHOST $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_add_host_006.out 2>&1"
        rlAssertGrep "Number of members added 2" "$TmpDir/service_add_host_006.out"
	rlAssertGrep "Managed by: $HOSTNAME, $LCAPSHOST, $DASHHOST" "$TmpDir/service_add_host_006.out"
        rlRun "ipa service-remove-host --hosts=$CAPSHOST,$DASHHOST $SERVICE/$HOSTNAME@$RELM" 0 "Removing the managed host for further testing"
        rlRun "ipa host-del $CAPSHOST" 0 "removing the first host added"
	rlRun "ipa host-del $DASHHOST" 0 "removing the second host added"
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd
}

service_add_host_007() {
        # ipa service-add-host : add host, with multiple hosts to manage service 
HOST1="test.$DOMAIN"
HOST2="test2.$DOMAIN"

rlPhaseStartTest "service_add_host_007: ipa service-add-host : with multiple hosts to manage service."

	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
	rlRun "ipa host-add $HOST1 --force"
	rlRun "ipa host-add $HOST2 --force"
        rlRun "ipa service-add-host --hosts=$HOST2,$HOST1 $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_add_host_007.out 2>&1"
        rlAssertGrep "Number of members added 2" "$TmpDir/service_add_host_007.out"
        rlRun "cat $TmpDir/service_add_host_007.out"

        rlRun "ipa host-del $HOST1" 0 "removing the added host $HOST1"
        rlRun "ipa host-del $HOST2" 0 "removing the added host $HOST2"
        rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM" 

rlPhaseEnd
}

service_add_host_008() {
        # ipa service-add-host : check help
rlPhaseStartTest "service_add_host_008: ipa service-add-host : check help"
        rlRun "ipa help service-add-host > $TmpDir/service_add_host_008.out 2>&1"
        rlAssertGrep "Purpose: Add hosts that can manage this service." "$TmpDir/service_add_host_008.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-add-host PRINCIPAL" "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\-h, --help   show this help message and exit" "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\--all        Retrieve and print all attributes from the server." "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\--raw        Print entries as stored on the server." "$TmpDir/service_add_host_008.out"
        rlAssertGrep "\--hosts=STR  comma-separated list of hosts to add" "$TmpDir/service_add_host_008.out"
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
        # ipa service-del: del service for vpn 

rlPhaseStartTest "service_del_002: delete service"
	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
        rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_del_002.out"
        rlRun "cat $TmpDir/service_del_002.out"
        rlAssertGrep "Deleted service \"$SERVICE/$HOSTNAME@$RELM\"" "$TmpDir/service_del_002.out"
rlPhaseEnd
}

service_del_003() {
        # ipa service-del: re-delete the same or unknown service

rlPhaseStartTest "service_del_003: re-delete the same or unknown service."
        rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_del_003.out 2>&1" 2
        #rlAssertGrep "ipa: ERROR: no such entry" "$TmpDir/service_del_003.out"
        rlRun "cat $TmpDir/service_del_003.out"
	#rlAssertGrep "ipa: ERROR: vpn/qe-blade-11.testrelm.com@TESTRELM.COM: service not found" "$TmpDir/service_del_003.out"
	rlAssertGrep "ipa: ERROR: $SERVICE/$HOSTNAME@$RELM: service not found" "$TmpDir/service_del_003.out"
rlPhaseEnd
}

service_del_004() {
        # ipa service-del: with --continue option
rlPhaseStartTest "service_del_004: ipa service-del: with --continue option."
        # Adding service for this test
        rlRun "ipa service-add IMAP/$HOSTNAME@$RELM"
	rlRun "ipa service-add VM/$HOSTNAME@$RELM"

        rlRun "ipa service-del VM/$HOSTNAME@$RELM unknown/$HOSTNAME@$RELM IMAP/$HOSTNAME@$RELM" 2
        rlRun "ipa service-show VM/$HOSTNAME@$RELM" 2 "Service should have been deleted because first in list without --continue"
	rlRun "ipa service-show IMAP/$HOSTNAME@$RELM" 0 "Service should not have been deleted without --continue"

        # re-adding VM service for --continue option test
        rlRun "ipa service-add VM/$HOSTNAME@$RELM"
        rlRun "ipa service-del unknown/$HOSTNAME@$RELM VM/$HOSTNAME@$RELM IMAP/$HOSTNAME@$RELM --continue > $TmpDir/service_del_004.out 2>&1"
        rlAssertGrep "Deleted service \"VM/$HOSTNAME@$RELM,IMAP/$HOSTNAME@$RELM\"" "$TmpDir/service_del_004.out"
        rlAssertGrep "Failed to remove: unknown/$HOSTNAME@$RELM" "$TmpDir/service_del_004.out"
	rlRun "cat $TmpDir/service_del_004.out"

        rlRun "ipa service-show IMAP/$HOSTNAME@$RELM" 2
        rlRun "ipa service-show VM/$HOSTNAME@$RELM" 2
rlPhaseEnd
}

service_disable_001() {
        # ipa service-disable: help
rlPhaseStartTest "service_disable_001: ipa service-disable: help"
        rlRun "ipa help service-disable > $TmpDir/service_disable_001.out 2>&1"
        rlAssertGrep "Purpose: Disable the Kerberos key and SSL certificate of a service." "$TmpDir/service_disable_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-disable PRINCIPAL" "$TmpDir/service_disable_001.out"
        rlAssertGrep "\-h, \--help  show this help message and exit" "$TmpDir/service_disable_001.out"
rlPhaseEnd
}


service_disable_002() {
        # ipa service-disable: Disabling service vpn. 
rlPhaseStartTest "service_disable_002: ipa service-disable: Disabling service."
        rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
        rlRun "ipa-getkeytab --server $MASTER --principal $SERVICE/$HOSTNAME@$RELM --keytab /opt/$SERVICE.$HOSTNAME.$RELM.keytab"
        rlRun "ipa service-disable $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_disable_002.out 2>&1"
	rlAssertGrep "Disabled service \"vpn/$HOSTNAME@$RELM\"" "$TmpDir/service_disable_002.out"
        rlRun "ipa service-find $SERVICE/$HOSTNAME@$RELM >> $TmpDir/service_disable_002.out"
	rlAssertGrep "Keytab: False" "$TmpDir/service_disable_002.out"
rlPhaseEnd
}

service_disable_003() {
        # ipa service-disable: Disabling an already disabled service
rlPhaseStartTest "service_disable_003: ipa service-disable: Disabling an already disabled service."
        rlRun "ipa service-disable $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_disable_003.out 2>&1" 1
        rlAssertGrep "ipa: ERROR: This entry is already disabled" "$TmpDir/service_disable_003.out"

	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
rlPhaseEnd
}

service_find_001() {

        # ipa service-find help 
rlPhaseStartTest "service_find_001: ipa service-find help"
        rlRun "ipa help service-find > $TmpDir/service_find_001.out 2>&1"
        rlAssertGrep "Purpose: Search for IPA services." "$TmpDir/service_find_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-find \[CRITERIA\]" "$TmpDir/service_find_001.out"
        rlAssertGrep "\-h, --help            show this help message and exit" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--principal=STR       Service principal" "$TmpDir/service_find_001.out"
        rlAssertNotGrep "\--certificate=BYTES  Base-64 encoded server certificate" "$TmpDir/service_find_001.out"
	rlLog "\--certificate option is removed, ref https://bugzilla.redhat.com/show_bug.cgi?id=674736"
        rlAssertGrep "\--timelimit=INT       Time limit of search in seconds" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--sizelimit=INT       Maximum number of entries returned" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--all                 Retrieve and print all attributes from the server." "$TmpDir/service_find_001.out"
        rlAssertGrep "\--pkey-only           Results should contain primary key attribute only" "$TmpDir/service_find_001.out"
        rlAssertGrep "\--raw                 Print entries as stored on the server." "$TmpDir/service_find_001.out"
        rlAssertGrep "\--man-by-hosts=STR    Search for services with these managed by hosts." "$TmpDir/service_find_001.out"
        rlAssertGrep "\--not-man-by-hosts=STR" "$TmpDir/service_find_001.out"
	rlAssertGrep "Search for services without these managed by hosts." "$TmpDir/service_find_001.out"

	rlRun "cat $TmpDir/service_find_001.out"
rlPhaseEnd
}

service_find_002() {
        # ipa service-find with --principal option
rlPhaseStartTest "service_find_002: ipa service-find with --principal option"

	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"

        rlRun "ipa service-find --principal=$SERVICE/$HOSTNAME@$RELM > $TmpDir/service_find_002.out 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/service_find_002.out"
        rlAssertGrep "Principal: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_find_002.out"
        rlRun "cat $TmpDir/service_find_002.out"
rlPhaseEnd
}

service_find_003() {
        # ipa service-find with --principal and --all options
rlPhaseStartTest "service_find_003: ipa service-find with --principal and --all options."
        rlRun "ipa service-find --principal=$SERVICE/$HOSTNAME@$RELM --all > $TmpDir/service_find_003.out 2>&1"
        rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, ipakrbprincipal, top" "$TmpDir/service_find_003.out"
        rlAssertGrep "ipauniqueid:" "$TmpDir/service_find_003.out"
        rlAssertGrep "Keytab:" "$TmpDir/service_find_003.out"
        rlRun "cat $TmpDir/service_find_003.out"
rlPhaseEnd
}

service_find_004() {

        # ipa service-find with --not-man-by-hosts option

rlPhaseStartTest "service_find_004: ipa service-find with --not-man-by-host option"
        rlRun "ipa host-add $TESTHOST --force"
        rlRun "ipa service-add-host --hosts=$TESTHOST $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_find_004.out 2>&1"
        rlRun "ipa service-find --not-man-by-hosts=$TESTHOST > $TmpDir/service_find_004.out 2>&1"
        rlRun "cat $TmpDir/service_find_004.out"
if [ -f /etc/fedora-release ] ; then
	rlAssertGrep "Number of entries returned 3" "$TmpDir/service_find_004.out"
else
	if [[ "$SLAVE" = "" ]] ; then
        	rlAssertGrep "Number of entries returned 4" "$TmpDir/service_find_004.out"
	else
                rlRun "cat $TmpDir/service_find_004.out"
                grep -e "Principal: dogtagldap/$HOSTNAME@$RELM" $TmpDir/service_find_004.out
                if [ $? -eq 0 ] ; then
		  rlAssertGrep "Number of entries returned 8" "$TmpDir/service_find_004.out"
                else
		  rlAssertGrep "Number of entries returned 7" "$TmpDir/service_find_004.out"
                fi
	fi
fi
rlPhaseEnd
}

service_find_005() {

        # ipa service-find with --man-by-hosts option 

rlPhaseStartTest "service_find_005: ipa service-find with --man-by-host option"

	rlRun "ipa service-find --man-by-hosts=$TESTHOST > $TmpDir/service_find_005.out 2>&1"
        rlRun "cat $TmpDir/service_find_005.out"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/service_find_005.out"
rlPhaseEnd
}

service_find_006() {

        # ipa service-find with --sizelimit option

rlPhaseStartTest "service_find_006: ipa service-find with --sizelimit option"

        rlRun "ipa service-find --sizelimit=1 > $TmpDir/service_find_006.out 2>&1"
        rlAssertGrep "Number of entries returned 1" "$TmpDir/service_find_006.out"
        rlRun "cat $TmpDir/service_find_006.out"
rlPhaseEnd
}

service_find_007() {

rlPhaseStartTest "service_find_007: ipa service-find with --timelimit option"
        # ipa service-find with --timelimit option 
        # If timelimit comes in as 0 we set it to -1, unlimited, internally. 
        rlRun "ipa service-find --timelimit=0 > $TmpDir/service_find_007.out 2>&1"
        result=`cat $TmpDir/service_find_007.out | grep "Number of entries returned"`
        rlRun "cat $TmpDir/service_find_007.out"
        number=`echo $result | cut -d " " -f 5`
	if [[ "$SLAVE" = "" ]] ; then

		if [ -f /etc/fedora-release ] ; then
			if [ $number -eq 4 ] ; then
				rlPass "Number of 4 services returned as expected with time limit of 0"
			else
				rlFail "Number of services returned is not as expected.  GOT: $number EXP: 4"
			fi
		else
	        	if [ $number -eq 5 ] ; then
        	        	rlPass "Number of 5 services returned as expected with time limit of 0"
        		else
                		rlFail "Number of services returned is not as expected.  GOT: $number EXP: 5"
	        	fi
		fi
	else 

                rlRun "cat $TmpDir/service_find_007.out"
                grep -e "Principal: dogtagldap/$HOSTNAME@$RELM" $TmpDir/service_find_004.out
                if [ $? -eq 0 ] ; then
                  rlAssertGrep "Number of entries returned $number" "$TmpDir/service_find_007.out"
                else
                  rlAssertGrep "Number of entries returned $number" "$TmpDir/service_find_007.out"
                fi
            
                #if [ $number -eq 9 ] ; then
                #        rlPass "Number of 9 services returned as expected with time limit of 0"
                #else
                #        rlFail "Number of services returned is not as expected.  GOT: $number EXP: 9"
                #fi
	fi
rlPhaseEnd
}

service_find_008() {

        # ipa service-find with --timelimit option with invalid values
rlPhaseStartTest "service_find_008: ipa service-find with --timelimit option with invalid values"

        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa service-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa service-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."

rlPhaseEnd
}

service_find_009() {

rlPhaseStartTest "service_find_009: --pkey-only test of service"
	ipa_command_to_test="service"
	pkey_addstringa=""
	pkey_addstringb=""
	pkeyobja="tservice1/$HOSTNAME@$RELM"
	pkeyobjb="tservice2/$HOSTNAME@$RELM"
	grep_string='Principal:'
	general_search_string=tservice
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in service-find"

	#Cleaning up for service-find test cases
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
	rlRun "ipa host-del $TESTHOST"
rlPhaseEnd
}

service_mod_001() {

	# ipa service-mod check help
rlPhaseStartTest "service_mod_001: ipa service-mod check help"

	rlRun "ipa help service-mod > $TmpDir/service_mod_001.out 2>&1"
	rlRun "cat $TmpDir/service_mod_001.out"
	rlAssertGrep "Purpose: Modify an existing IPA service." "$TmpDir/service_mod_001.out"
	rlAssertGrep "Usage: ipa \[global-options\] service-mod PRINCIPAL \[options\]" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\-h, --help            show this help message and exit" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--certificate=BYTES   Base-64 encoded server certificate" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--pac-type=\['MS-PAC', 'PAD', 'NONE'\]" "$TmpDir/service_mod_001.out"
	rlAssertGrep "Override default list of supported PAC types." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--addattr=STR         Add an attribute/value pair. Format is attr=value." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--setattr=STR         Set an attribute to a name/value pair." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--rights              Display the access rights of this entry" "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--all                 Retrieve and print all attributes from the server." "$TmpDir/service_mod_001.out"
	rlAssertGrep "\--raw                 Print entries as stored on the server." "$TmpDir/service_mod_001.out"
rlPhaseEnd
}

service_mod_002() {

	# ipa service-mod --rights, to display the rights while modifying a service
rlPhaseStartTest "service_mod_002: ipa service-mod --rights, to display the rights while modifying a service."
	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM" 0 "Creating a service for this test"

       rlRun "ipa service-mod $SERVICE/$HOSTNAME@$RELM --certificate=MIIDmDCCAoCgAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKEwxURVNUUkVMTS5DT00xHjAcBgNVBAMTFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xMjAyMDIxNTQzMjJaFw0yMDAyMDIxNTQzMjJaMDcxFTATBgNVBAoTDFRFU1RSRUxNLkNPTTEeMBwGA1UEAxMVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAox29UcpdSpeCQuthJ/IAA5V59xRUcY3Oio3JYxgC5D/fUIMKV/Qwmd0EvaMNZXncfmcUsX5YrfAUSiKb2rfaSOLluR5NJ3QcNVVyw0O0hYbwWILjnMTUYilYeA7HsuVYigLxw0uHf23b49IuUDPCb13tot8m0wboN0XX+TiUsvchtRuKzlB2xr1Ix0apevs2pTeZkTmV1aUMcM6GfgkVKLpoX2OeIQMFUCgdeoca9Yjo8fUDjhQ+LrpC0UWUp4jRyjmCKCQ/m9+bUIpQBFXcW3z+CixyybBkOkWuLkXNYI2iWXajkVwSqBw86d3vXQZXfQYtsdwYpKl79leaRh9mawIDAQABo4GuMIGrMB8GA1UdIwQYMBaAFL5+6T4HKYVSPkm5zfIANFd5JvHdMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBS+fuk+BymFUj5Juc3yADRXeSbx3TBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAGGLGh0dHA6Ly9yaGVsNjItc2VydmVyLnRlc3RyZWxtLmNvbTo4MC9jYS9vY3NwMA0GCSqGSIb3DQEBCwUAA4IBAQBDXwR7r4jH79fIUtqChyDCrqMfAt1qVGQweKhF8Mcm7W1WotbUvYXG3O7Xq5nlwUHKrYRhpqOAKshLQ/O8eSY+BOzoYYqT40zgxNodKXFpmj0IdQ5Bk0D/kergRX69V1ZEEsyeKqEQqC8V2f40+vUvp2QLjJZmMVXT5i/AB+7wDvCgdzKfmb8iUqfVayRtIWcMkcHU8XnV/D1HTuAgAmfkFApxXShGFaINXJ5jrCj+QzQWPp+DvazpJVdstYWjj4TbCxIfDVbSx79xdogquLA1ja3M6+psyOx6fIqM6NMuUYau8hFTi6GwIIcCZNgh1jph8GrQyC8qwnicgGaDTreb --rights --all > $TmpDir/service_mod_002.out"
	rlRun "cat $TmpDir/service_mod_002.out"
	rlAssertGrep "Modified service \"$SERVICE/$HOSTNAME@$RELM\"" "$TmpDir/service_mod_002.out"
	rlAssertGrep "attributelevelrights: {'krbextradata': u'rsc', 'krbcanonicalname': u'rsc', 'usercertificate': u'rscwo', 'krbupenabled': u'rsc', 'krbticketflags': u'rsc', 'krbprincipalexpiration': u'rsc', 'krbobjectreferences': u'rscwo', 'krbmaxrenewableage': u'rscwo', 'nsaccountlock': u'rscwo', 'managedby': u'rscwo', 'krblastsuccessfulauth': u'rsc', 'krbprincipaltype': u'rsc', 'ipakrbprincipalalias': u'rscwo', 'krbprincipalkey': u'swo', 'ipakrbauthzdata': u'rscwo', 'memberof': u'rsc', 'krbmaxticketlife': u'rscwo', 'krbpwdpolicyreference': u'rsc', 'krbprincipalname': u'rsc', 'krbticketpolicyreference': u'rsc', 'krblastadminunlock': u'rscwo', 'krbpasswordexpiration': u'rsc', 'krblastfailedauth': u'rsc', 'objectclass': u'rscwo', 'aci': u'rscwo', 'krbpwdhistory': u'rsc', 'krbprincipalaliases': u'rsc', 'krbloginfailedcount': u'rsc', 'krblastpwdchange': u'rscwo', 'ipauniqueid': u'rsc'}" "$TmpDir/service_mod_002.out"
	rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, ipakrbprincipal, top" "$TmpDir/service_mod_002.out"

	#deleting for the added service for the next test case
        ipa service-del $SERVICE/$HOSTNAME@$RELM > /tmp/certerr.out 2>&1
        cat /tmp/certerr.out | grep "ipa: ERROR: Certificate operation cannot be completed"
        if [ $? -eq 0 ] ; then
                ipa service-mod --certificate="" $SERVICE/$HOSTNAME@$RELM
                ipa service-del $SERVICE/$HOSTNAME@$RELM
        fi

        # lets make sure service is deleted here because of above work around for bug 691488
        rlRun "ipa service-show $SERVICE/$HOSTNAME@$RELM" 2 "Checking to make sure service is deleted"

rlPhaseEnd
}

service_mod_003() {

	# ipa service-mod --certificate, adding certificate to an existing service.
rlPhaseStartTest "service_mod_003: ipa service-mod --certificate, adding certificate to an existing service."

        rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM" 0 "Creating a service for this test"

       rlRun "ipa service-mod $SERVICE/$HOSTNAME@$RELM --certificate=MIIDmDCCAoCgAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKEwxURVNUUkVMTS5DT00xHjAcBgNVBAMTFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xMjAyMDIxNTQzMjJaFw0yMDAyMDIxNTQzMjJaMDcxFTATBgNVBAoTDFRFU1RSRUxNLkNPTTEeMBwGA1UEAxMVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAox29UcpdSpeCQuthJ/IAA5V59xRUcY3Oio3JYxgC5D/fUIMKV/Qwmd0EvaMNZXncfmcUsX5YrfAUSiKb2rfaSOLluR5NJ3QcNVVyw0O0hYbwWILjnMTUYilYeA7HsuVYigLxw0uHf23b49IuUDPCb13tot8m0wboN0XX+TiUsvchtRuKzlB2xr1Ix0apevs2pTeZkTmV1aUMcM6GfgkVKLpoX2OeIQMFUCgdeoca9Yjo8fUDjhQ+LrpC0UWUp4jRyjmCKCQ/m9+bUIpQBFXcW3z+CixyybBkOkWuLkXNYI2iWXajkVwSqBw86d3vXQZXfQYtsdwYpKl79leaRh9mawIDAQABo4GuMIGrMB8GA1UdIwQYMBaAFL5+6T4HKYVSPkm5zfIANFd5JvHdMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBS+fuk+BymFUj5Juc3yADRXeSbx3TBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAGGLGh0dHA6Ly9yaGVsNjItc2VydmVyLnRlc3RyZWxtLmNvbTo4MC9jYS9vY3NwMA0GCSqGSIb3DQEBCwUAA4IBAQBDXwR7r4jH79fIUtqChyDCrqMfAt1qVGQweKhF8Mcm7W1WotbUvYXG3O7Xq5nlwUHKrYRhpqOAKshLQ/O8eSY+BOzoYYqT40zgxNodKXFpmj0IdQ5Bk0D/kergRX69V1ZEEsyeKqEQqC8V2f40+vUvp2QLjJZmMVXT5i/AB+7wDvCgdzKfmb8iUqfVayRtIWcMkcHU8XnV/D1HTuAgAmfkFApxXShGFaINXJ5jrCj+QzQWPp+DvazpJVdstYWjj4TbCxIfDVbSx79xdogquLA1ja3M6+psyOx6fIqM6NMuUYau8hFTi6GwIIcCZNgh1jph8GrQyC8qwnicgGaDTreb --rights --all > $TmpDir/service_mod_003.out 2>&1"
	rlRun "cat $TmpDir/service_mod_003.out"
	rlAssertGrep "Modified service \"$SERVICE/$HOSTNAME@$RELM\"" "$TmpDir/service_mod_003.out"
       rlAssertGrep "Certificate: MIIDmDCCAoCgAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKEwxURVNUUkVMTS5DT00xHjAcBgNVBAMTFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xMjAyMDIxNTQzMjJaFw0yMDAyMDIxNTQzMjJaMDcxFTATBgNVBAoTDFRFU1RSRUxNLkNPTTEeMBwGA1UEAxMVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAox29UcpdSpeCQuthJ/IAA5V59xRUcY3Oio3JYxgC5D/fUIMKV/Qwmd0EvaMNZXncfmcUsX5YrfAUSiKb2rfaSOLluR5NJ3QcNVVyw0O0hYbwWILjnMTUYilYeA7HsuVYigLxw0uHf23b49IuUDPCb13tot8m0wboN0XX+TiUsvchtRuKzlB2xr1Ix0apevs2pTeZkTmV1aUMcM6GfgkVKLpoX2OeIQMFUCgdeoca9Yjo8fUDjhQ+LrpC0UWUp4jRyjmCKCQ/m9+bUIpQBFXcW3z+CixyybBkOkWuLkXNYI2iWXajkVwSqBw86d3vXQZXfQYtsdwYpKl79leaRh9mawIDAQABo4GuMIGrMB8GA1UdIwQYMBaAFL5+6T4HKYVSPkm5zfIANFd5JvHdMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBS+fuk+BymFUj5Juc3yADRXeSbx3TBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAGGLGh0dHA6Ly9yaGVsNjItc2VydmVyLnRlc3RyZWxtLmNvbTo4MC9jYS9vY3NwMA0GCSqGSIb3DQEBCwUAA4IBAQBDXwR7r4jH79fIUtqChyDCrqMfAt1qVGQweKhF8Mcm7W1WotbUvYXG3O7Xq5nlwUHKrYRhpqOAKshLQ/O8eSY+BOzoYYqT40zgxNodKXFpmj0IdQ5Bk0D/kergRX69V1ZEEsyeKqEQqC8V2f40+vUvp2QLjJZmMVXT5i/AB+7wDvCgdzKfmb8iUqfVayRtIWcMkcHU8XnV/D1HTuAgAmfkFApxXShGFaINXJ5jrCj+QzQWPp+DvazpJVdstYWjj4TbCxIfDVbSx79xdogquLA1ja3M6+psyOx6fIqM6NMuUYau8hFTi6GwIIcCZNgh1jph8GrQyC8qwnicgGaDTreb" "$TmpDir/service_mod_003.out"
	rlAssertGrep "Fingerprint (MD5):" "$TmpDir/service_mod_003.out"
	rlAssertGrep "Fingerprint (SHA1):" "$TmpDir/service_mod_003.out"


	rlRun "ipa service-show $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_mod_003.out 2>&1"
	rlRun "cat $TmpDir/service_mod_003.out"
	rlAssertGrep "Certificate: MIIDmDCCAoCgAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKEwxURVNUUkVMTS5DT00xHjAcBgNVBAMTFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xMjAyMDIxNTQzMjJaFw0yMDAyMDIxNTQzMjJaMDcxFTATBgNVBAoTDFRFU1RSRUxNLkNPTTEeMBwGA1UEAxMVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAox29UcpdSpeCQuthJ/IAA5V59xRUcY3Oio3JYxgC5D/fUIMKV/Qwmd0EvaMNZXncfmcUsX5YrfAUSiKb2rfaSOLluR5NJ3QcNVVyw0O0hYbwWILjnMTUYilYeA7HsuVYigLxw0uHf23b49IuUDPCb13tot8m0wboN0XX+TiUsvchtRuKzlB2xr1Ix0apevs2pTeZkTmV1aUMcM6GfgkVKLpoX2OeIQMFUCgdeoca9Yjo8fUDjhQ+LrpC0UWUp4jRyjmCKCQ/m9+bUIpQBFXcW3z+CixyybBkOkWuLkXNYI2iWXajkVwSqBw86d3vXQZXfQYtsdwYpKl79leaRh9mawIDAQABo4GuMIGrMB8GA1UdIwQYMBaAFL5+6T4HKYVSPkm5zfIANFd5JvHdMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBS+fuk+BymFUj5Juc3yADRXeSbx3TBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAGGLGh0dHA6Ly9yaGVsNjItc2VydmVyLnRlc3RyZWxtLmNvbTo4MC9jYS9vY3NwMA0GCSqGSIb3DQEBCwUAA4IBAQBDXwR7r4jH79fIUtqChyDCrqMfAt1qVGQweKhF8Mcm7W1WotbUvYXG3O7Xq5nlwUHKrYRhpqOAKshLQ/O8eSY+BOzoYYqT40zgxNodKXFpmj0IdQ5Bk0D/kergRX69V1ZEEsyeKqEQqC8V2f40+vUvp2QLjJZmMVXT5i/AB+7wDvCgdzKfmb8iUqfVayRtIWcMkcHU8XnV/D1HTuAgAmfkFApxXShGFaINXJ5jrCj+QzQWPp+DvazpJVdstYWjj4TbCxIfDVbSx79xdogquLA1ja3M6+psyOx6fIqM6NMuUYau8hFTi6GwIIcCZNgh1jph8GrQyC8qwnicgGaDTreb" "$TmpDir/service_mod_003.out"

rlPhaseEnd
}

service_mod_004() {

	# ipa service-mod: updating service with a non-standard certificate format.
rlPhaseStartTest "service_mod_004: ipa service-mod: updating service with a non-standard certificate format."
	rlRun "ipa service-mod $SERVICE/$HOSTNAME@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr > $TmpDir/service_mod_004.out 2>&1" 1
	rlRun "cat $TmpDir/service_mod_004.out"
	#rlAssertGrep "ipa: ERROR: invalid 'certificate': must be binary data" "$TmpDir/service_mod_004.out"
	rlAssertGrep "ipa: ERROR: Base64 decoding failed: Incorrect padding" "$TmpDir/service_mod_004.out"

        #deleting for the added service for the next test case
        ipa service-del $SERVICE/$HOSTNAME@$RELM > /tmp/certerr.out 2>&1
        cat /tmp/certerr.out | grep "ipa: ERROR: Certificate operation cannot be completed"
        if [ $? -eq 0 ] ; then
                ipa service-mod --certificate="" $SERVICE/$HOSTNAME@$RELM
                ipa service-del $SERVICE/$HOSTNAME@$RELM
        fi

        # lets make sure service is deleted here because of above work around for bug 691488
        rlRun "ipa service-show $SERVICE/$HOSTNAME@$RELM" 2 "Checking to make sure service is deleted"
rlPhaseEnd
}

service_mod_005() {

	# ipa service-mod: modifying the service with --raw option
rlPhaseStartTest "service_mod_005: ipa service-mod: modifying the service with --raw option"
        rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM" 0 "Creating a service for this test"

#        rlRun "ipa service-mod $SERVICE/$HOSTNAME@$RELM --certificate=MIICdzCCAeCgAwIBAgICA+4wDQYJKoZIhvcNAQEFBQAwKTEnMCUGA1UEAxMeVEVTVFJFTE0gQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTExMDIwOTA5MzE1M1oXDTIxMDIwOTA5MzE1M1owMTERMA8GA1UEChMIVEVTVFJFTE0xHDAaBgNVBAMTE2dzcmYxNGlwYXMudGVzdHJlbG0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDiHg3uWywDB1BWm7dy005eQGPecuOcpjp1ZX7Bc7FHxarF03IIsBT4DWvZlp1TbCDuHESBgTWExvr+xeeVfh+foMdUe2UuJJ+DdWsJ1JZMBRKyTDmdd90nuXWWROYwgyrmwAf+3CFHmB5QaVnbAEyD8Hf3sC8k1VLkJACtxSLWx/5WMGzFJV30Xok82KrfPml4z4i6kelnz6KNWfgcM0yQkoohhbLmPqwnj2C4LpwM3QgeUltDCpEwCQCMXeTMDm8Kr6tFtjGmGjW5ncNhk7QLZDVwB++CGbERSCPRBqWSNtZ4yO2P+AOTjPreX6/XQOSMrAe+810YilJbTwx3vZBbAgMBAAGjIjAgMBEGCWCGSAGG+EIBAQQEAwIGQDALBgNVHQ8EBAMCBSAwDQYJKoZIhvcNAQEFBQADgYEAdK33A68CrIfM/BmH8MYGDrdGLK7x54Kkez+nlz9WAv6KEIDiWJXw4HY3iIPkJoYIvOhYT4lIdYiOlDgd3yABjGb0g/iglZ4u2qRDQc9nAYul9o5X8/Mlv38d+0QO5NxOtwk6Cvnt4UTtqoRUeZ8244inmPSBdZr6XHUVlePCNiw= --raw > $TmpDir/service_mod_005.out 2>&1"
       rlRun "ipa service-mod $SERVICE/$HOSTNAME@$RELM --certificate=MIIDmDCCAoCgAwIBAgIBATANBgkqhkiG9w0BAQsFADA3MRUwEwYDVQQKEwxURVNUUkVMTS5DT00xHjAcBgNVBAMTFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0xMjAyMDIxNTQzMjJaFw0yMDAyMDIxNTQzMjJaMDcxFTATBgNVBAoTDFRFU1RSRUxNLkNPTTEeMBwGA1UEAxMVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAox29UcpdSpeCQuthJ/IAA5V59xRUcY3Oio3JYxgC5D/fUIMKV/Qwmd0EvaMNZXncfmcUsX5YrfAUSiKb2rfaSOLluR5NJ3QcNVVyw0O0hYbwWILjnMTUYilYeA7HsuVYigLxw0uHf23b49IuUDPCb13tot8m0wboN0XX+TiUsvchtRuKzlB2xr1Ix0apevs2pTeZkTmV1aUMcM6GfgkVKLpoX2OeIQMFUCgdeoca9Yjo8fUDjhQ+LrpC0UWUp4jRyjmCKCQ/m9+bUIpQBFXcW3z+CixyybBkOkWuLkXNYI2iWXajkVwSqBw86d3vXQZXfQYtsdwYpKl79leaRh9mawIDAQABo4GuMIGrMB8GA1UdIwQYMBaAFL5+6T4HKYVSPkm5zfIANFd5JvHdMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBS+fuk+BymFUj5Juc3yADRXeSbx3TBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAGGLGh0dHA6Ly9yaGVsNjItc2VydmVyLnRlc3RyZWxtLmNvbTo4MC9jYS9vY3NwMA0GCSqGSIb3DQEBCwUAA4IBAQBDXwR7r4jH79fIUtqChyDCrqMfAt1qVGQweKhF8Mcm7W1WotbUvYXG3O7Xq5nlwUHKrYRhpqOAKshLQ/O8eSY+BOzoYYqT40zgxNodKXFpmj0IdQ5Bk0D/kergRX69V1ZEEsyeKqEQqC8V2f40+vUvp2QLjJZmMVXT5i/AB+7wDvCgdzKfmb8iUqfVayRtIWcMkcHU8XnV/D1HTuAgAmfkFApxXShGFaINXJ5jrCj+QzQWPp+DvazpJVdstYWjj4TbCxIfDVbSx79xdogquLA1ja3M6+psyOx6fIqM6NMuUYau8hFTi6GwIIcCZNgh1jph8GrQyC8qwnicgGaDTreb --raw > $TmpDir/service_mod_005.out 2>&1"
        rlRun "cat $TmpDir/service_mod_005.out"
	rlAssertGrep "serial_number: 1" "$TmpDir/service_mod_005.out"
	rlAssertGrep "md5_fingerprint:" "$TmpDir/service_mod_005.out"
	rlAssertGrep "sha1_fingerprint:" "$TmpDir/service_mod_005.out"
	rlAssertGrep "valid_not_before:" "$TmpDir/service_mod_005.out"
	rlAssertGrep "valid_not_after:" "$TmpDir/service_mod_005.out"

	ipa service-del $SERVICE/$HOSTNAME@$RELM > /tmp/certerr.out 2>&1
        cat /tmp/certerr.out | grep "ipa: ERROR: Certificate operation cannot be completed"
        if [ $? -eq 0 ] ; then
                ipa service-mod --certificate="" $SERVICE/$HOSTNAME@$RELM
                ipa service-del $SERVICE/$HOSTNAME@$RELM
        fi

        # lets make sure service is deleted here because of above work around for bug 691488
        rlRun "ipa service-show $SERVICE/$HOSTNAME@$RELM" 2 "Checking to make sure service is deleted"
rlPhaseEnd
}

service_mod_006() {

	# ipa service-mod: modifying the service with --setattr option

rlPhaseStartTest "service_mod_006: ipa service-mod: modifying the service with --addattr on managedBy"
	ipa host-add --force $TESTHOST
	hostmanagedn="fqdn=$TESTHOST,cn=computers,cn=accounts,$BASEDN"

	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
	rlRun "ipa service-mod --addattr=managedBy=\"$hostmanagedn\" $SERVICE/$HOSTNAME@$RELM"

	rlRun "ipa service-show --all $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_mod_006.out 2>&1"
        #rlAssertGrep "managedby_host: $HOSTNAME, $TESTHOST" "$TmpDir/service_mod_006.out"
        rlAssertGrep "Managed by: $HOSTNAME, $TESTHOST" "$TmpDir/service_mod_006.out"
rlPhaseEnd
}

service_mod_007() {
rlPhaseStartTest "service_mod_007: ipa service-mod: modifying the service with --setattr on managedBy"
	selfmanagedn="fqdn=$HOSTNAME,cn=computers,cn=accounts,$BASEDN"
	rlRun "ipa service-mod --setattr=managedBy=\"$selfmanagedn\" $SERVICE/$HOSTNAME@$RELM"

	rlRun "ipa service-show --all $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_mod_007.out 2>&1"
	#rlAssertGrep "managedby_host: $HOSTNAME" "$TmpDir/service_mod_007.out"
	rlAssertGrep "Managed by: $HOSTNAME" "$TmpDir/service_mod_007.out"

        rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
	ipa host-del $TESTHOST
rlPhaseEnd
}

service_remove_host_001() {
        # ipa service-remove-host: check help
rlPhaseStartTest "service_remove_host_001: ipa service-remove-host: check help"
        rlRun "ipa help service-remove-host > $TmpDir/service_remove_host_001.out 2>&1"
        rlAssertGrep "Purpose: Remove hosts that can manage this service." "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "Usage: ipa \[global-options\] service-remove-host PRINCIPAL" "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\-h, --help   show this help message and exit" "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\--all        Retrieve and print all attributes from the server." "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\--raw        Print entries as stored on the server." "$TmpDir/service_remove_host_001.out"
        rlAssertGrep "\--hosts=STR  comma-separated list of hosts to remove" "$TmpDir/service_remove_host_001.out"

	rlRun "cat $TmpDir/service_remove_host_001.out"
rlPhaseEnd
}


service_remove_host_002() {
        # ipa service-remove-host for services
rlPhaseStartTest "service_remove_host_002: ipa service-remove-host for services"
        rlRun "ipa host-add test.example.com --force" 0 "adding host for service_remove_host test cases"
	rlRun "ipa service-add $SERVICE/$HOSTNAME@$RELM"
        rlRun "ipa service-add-host --hosts=test.example.com $SERVICE/$HOSTNAME@$RELM"

        rlRun "ipa service-remove-host --hosts=test.example.com $SERVICE/$HOSTNAME@$RELM > $TmpDir/service_remove_host_002.out 2>&1"
        rlAssertGrep "Principal: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_remove_host_002.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/service_remove_host_002.out"
        rlRun "cat $TmpDir/service_remove_host_002.out"
rlPhaseEnd
}


service_remove_host_003() {

        # ipa service-remove-host for services with --all option
rlPhaseStartTest "service_remove_host_003: ipa service-remove-host for services with --all option"

        rlRun "ipa service-add-host --hosts=test.example.com $SERVICE/$HOSTNAME@$RELM"

        rlRun "ipa service-remove-host --hosts=test.example.com $SERVICE/$HOSTNAME@$RELM --all > $TmpDir/service_remove_host_003.out 2>&1"
        rlAssertGrep "Principal: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_remove_host_003.out"
        rlAssertGrep "ipauniqueid:" "$TmpDir/service_remove_host_003.out"
        rlAssertGrep "objectclass: krbprincipal, krbprincipalaux, krbticketpolicyaux, ipaobject, ipaservice, pkiuser, ipakrbprincipal, top" "$TmpDir/service_remove_host_003.out"
        rlAssertGrep "Number of members removed 1" "$TmpDir/service_remove_host_003.out"
        rlRun "cat $TmpDir/service_remove_host_003.out"
rlPhaseEnd
}


service_remove_host_004() {

        # ipa service-remove-host for services with --all and --raw options
rlPhaseStartTest "service_remove_host_004: ipa service-remove-host for services with --all and --raw options"

        rlRun "ipa service-add-host --hosts=test.example.com $SERVICE/$HOSTNAME@$RELM"

        rlRun "ipa service-remove-host --hosts=test.example.com $SERVICE/$HOSTNAME@$RELM --all --raw > $TmpDir/service_remove_host_004.out 2>&1"
        rlAssertGrep "krbprincipalname: $SERVICE/$HOSTNAME@$RELM" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "managedby: fqdn=$HOSTNAME,cn=computers,cn=accounts,$BASEDN" "$TmpDir/service_remove_host_004.out" -i
        rlAssertGrep "objectclass: ipaobject" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: top" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: ipaservice" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: pkiuser" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: krbprincipal" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: krbprincipalaux" "$TmpDir/service_remove_host_004.out"
        rlAssertGrep "objectclass: krbTicketPolicyAux" "$TmpDir/service_remove_host_004.out" -i

        rlRun "cat $TmpDir/service_remove_host_004.out"
	# Cleaning up hosts and services
	rlRun "ipa service-del $SERVICE/$HOSTNAME@$RELM"
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
        rlAssertGrep "\--out=STR   file to store certificate in" "$TmpDir/service_show_001.out"
        rlAssertGrep "\--all       Retrieve and print all attributes from the server." "$TmpDir/service_show_001.out"
        rlAssertGrep "\--raw       Print entries as stored on the server." "$TmpDir/service_show_001.out"
        rlRun "cat $TmpDir/service_show_001.out"
rlPhaseEnd
}


service_show_002() {

        # ipa service-show with --all option
rlPhaseStartTest "service_show_002: ipa service-show with --all option"
        rlRun "ipa service-show http/$MASTER@$RELM  --all > $TmpDir/service_show_002.out 2>&1"
        rlAssertGrep "Principal: http/$MASTER@$RELM" "$TmpDir/service_show_002.out" -i 
        rlAssertGrep "Keytab: True" "$TmpDir/service_show_002.out"
        rlAssertGrep "objectclass: ipaobject, top, ipaservice, pkiuser, ipakrbprincipal, krbprincipal, krbprincipalaux, krbTicketPolicyAux" "$TmpDir/service_show_002.out"
        #rlAssertGrep "valid_not_after:" "$TmpDir/service_show_002.out"
        #rlAssertGrep "valid_not_before:" "$TmpDir/service_show_002.out"
        rlAssertGrep "Not Before:" "$TmpDir/service_show_002.out"
        rlAssertGrep "Not After:" "$TmpDir/service_show_002.out"
        rlAssertGrep "Certificate:" "$TmpDir/service_show_002.out"
        rlRun "cat $TmpDir/service_show_002.out"
rlPhaseEnd
}

service_show_003() {

        # ipa service-show with --out option
rlPhaseStartTest "service_show_003: ipa service-show with --out option"
        rlRun "ipa service-show http/$MASTER@$RELM --out=$TmpDir/service_show_003.out"
        rlAssertFile "$TmpDir/service_show_003.out"
        rlAssertGrep "\-----BEGIN CERTIFICATE-----" "$TmpDir/service_show_003.out"
        rlAssertGrep "\-----END CERTIFICATE-----" "$TmpDir/service_show_003.out"
        rlRun "cat $TmpDir/service_show_003.out"
rlPhaseEnd
}

service_show_004() {

        # ipa service-show with --raw option
rlPhaseStartTest "service_show_004: ipa service-show with --raw option"
        rlRun "ipa service-show http/$MASTER@$RELM --raw  > $TmpDir/service_show_004.out 2>&1"
        rlAssertGrep "krbprincipalname: http/$MASTER@$RELM" "$TmpDir/service_show_004.out" -i
        rlAssertGrep "usercertificate:" "$TmpDir/service_show_004.out"
        rlRun "cat $TmpDir/service_show_004.out"

rlPhaseEnd
}


service_show_005() {

        # ipa service-show with --rights options (requires --all)
rlPhaseStartTest "service_show_005: ipa service-show with --rights options (requires --all)"
        rlRun "ipa service-show http/$MASTER@$RELM --rights --all > $TmpDir/service_show_005.out 2>&1"
        rlAssertGrep "attributelevelrights: {'krbextradata': u'rsc', 'krbcanonicalname': u'rsc', 'usercertificate': u'rscwo', 'krbupenabled': u'rsc', 'krbticketflags': u'rsc', 'krbprincipalexpiration': u'rsc', 'krbobjectreferences': u'rscwo', 'krbmaxrenewableage': u'rscwo', 'nsaccountlock': u'rscwo', 'managedby': u'rscwo', 'krblastsuccessfulauth': u'rsc', 'krbprincipaltype': u'rsc', 'ipakrbprincipalalias': u'rscwo', 'krbprincipalkey': u'swo', 'ipakrbauthzdata': u'rscwo', 'memberof': u'rsc', 'ipauniqueid': u'rsc', 'krbpwdpolicyreference': u'rsc', 'krbprincipalname': u'rsc', 'krbticketpolicyreference': u'rsc', 'krblastadminunlock': u'rscwo', 'krbpasswordexpiration': u'rsc', 'krblastfailedauth': u'rsc', 'objectclass': u'rscwo', 'aci': u'rscwo', 'krbpwdhistory': u'rsc', 'krbprincipalaliases': u'rsc', 'krbloginfailedcount': u'rsc', 'krblastpwdchange': u'rscwo', 'krbmaxticketlife': u'rscwo'}" "$TmpDir/service_show_005.out"
        rlRun "cat $TmpDir/service_show_005.out"
rlPhaseEnd
}



cleanup() {
rlPhaseStartCleanup "Clean up for ipa services tests"
	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "kdestroy" 0 "Destroying admin credentials."

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
rlPhaseEnd
}
