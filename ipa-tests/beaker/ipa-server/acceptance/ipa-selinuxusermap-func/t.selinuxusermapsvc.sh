#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-func
#   Description: Functional test cases for ipa selinuxusermap
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: 
#	   Asha Akkianagdy <aakkiang@redhat.com>
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh

# Test Suite Globals
t1_ipa_selinuxuser="staff_u:s0-s0:c0.c1023"
t1_ipa_selinuxuser_verif="staff_u:.*s0-s0:c0.c1023"
t1_ipa_default_selinuxuser="guest_u:s0"
t1_ipa_default_selinuxuser_verif="guest_u:.*s0"

selinuxusermapsvc_master_001() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-001: user1 part of selinuxusermap1 is allowed to access $CLIENT from $CLIENT - SSHD Service"

                # kinit as admin and creating users
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        	for i in {1..3}; do
                	rlRun "create_ipauser user$i user$i user$i $userpw"
                	sleep 5
                	rlRun "export user$i=user$i"
	        done

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ssh_auth_success $user1 testpw123@ipa.com $MASTER"
		rlRun "ssh_auth_success $user2 testpw123@ipa.com $MASTER"
		rlRun "ssh_auth_success $user3 testpw123@ipa.com $MASTER"
		userpw="testpw123@ipa.com"

		rlRun "ipa selinuxusermap-add selinuxusermaprule1 --selinuxuser=$t1_ipa_selinuxuser"
		rlRun "ipa selinuxusermap-add-user selinuxusermaprule1 --users=$user1"
		rlRun "ipa selinuxusermap-add-host selinuxusermaprule1 --hosts=$CLIENT"
		rlRun "ipa selinuxusermap-show selinuxusermaprule1 --all"

		# ipa selinuxusermap test:
		rlRun "rlDistroDiff keyctl" 
		rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"	
		rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
		rlRun "rlDistroDiff keyctl" 
		rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"       
                rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
		rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user2 $CLIENT $t1_ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_default_selinuxuser"
                rlRun "rlDistroDiff keyctl"
		rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
                rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
		rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_default_selinuxuser"
                rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}

selinuxusermapsvc_master_001_cleanup() {
        # Cleanup
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	for i in {1..3}; do
		rlRun "ipa user-del user$i"
        done
	rlRun "rm -fr /tmp/krb5cc_*_*"
	rlRun "ipa selinuxusermap-del selinuxusermaprule1"
}

selinuxusermapsvc_client_001() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-001: user1 accessing $CLIENT from $CLIENT using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user2 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t1_ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_001() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-001: user1 accessing $CLIENT from $CLIENT2 using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t1_ipa_default_selinuxuser_verif"
        rlPhaseEnd
}


selinuxusermapsvc_master_002() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-002: user1 part of selinuxusermap2 is allowed to access $MASTER - SSHD Service"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        for i in {1..3}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done
		userpw="testpw123@ipa.com"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "ipa selinuxusermap-add selinuxusermaprule2 --selinuxuser=$t1_ipa_selinuxuser"
		rlRun "ipa selinuxusermaprule-add-user selinuxusermaprule2 --users=$user1"
		rlRun "ipa selinuxusermaprule-add-host selinuxusermaprule2 --hosts=$MASTER"
		rlRun "ipa selinuxusermaprule-show selinuxusermaprule2 --all"

	# ipa selinuxusermaptest:

		rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
                rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
                rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user2 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
                rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user2 $MASTER $t1_ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_default_selinuxuser"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
                rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
                rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $CLIENT $t1_ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_default_selinuxuser"
                rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
                rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t1_ipa_default_selinuxuser"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}
selinuxusermapsvc_master_002_cleanup() {
	# Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {1..3}; do
                rlRun "ipa user-del user$i"
        done
        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "ipa selinuxusermap-del selinuxusermaprule2"

}
selinuxusermapsvc_client_002() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-client1-002: user1 accessing $MASTER from $CLIENT using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user2 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t1_ipa_default_selinuxuser_verif"
        rlPhaseEnd

}
selinuxusermapsvc_client2_002() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-002: user1 accessing $MASTER from $CLIENT2 using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $MASTER $t1_ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user2 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
        rlPhaseEnd
}
