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
ipa_default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
ipa_default_selinuxuser_verif="unconfined_u:.*s0-s0:c0.c1023"
t1_ipa_selinuxuser="staff_u:s0-s0:c0.c1023"
t1_ipa_selinuxuser_verif="staff_u:.*s0-s0:c0.c1023"
t2_ipa_selinuxuser="user_u:s0-s0:c0.c102"
t2_ipa_selinuxuser_verif="user_u:.*s0-s0:c0.c102"
t3_ipa_selinuxuser="xguest_u:s0"
t3_ipa_selinuxuser_verif="xguest_u:.*s0"

selinuxusermapsvc_master_001() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-001: user1 part of selinuxusermap1 is allowed to access $CLIENT from $CLIENT with given selinuxpolicy - SSHD Service"

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
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
		rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
                rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"

		rlRun "rlDistroDiff keyctl" 
		rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"       
                rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT has selinux policy $ipa_default_selinuxuser"

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
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_001() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-001: user1 accessing $CLIENT from $CLIENT2 using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
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

		rlRun "ipa selinuxusermap-add selinuxusermaprule2 --selinuxuser=$t1_ipa_selinuxuser" 0 "Add a selinuxusermap rule."
		rlRun "ipa selinuxusermap-add-user selinuxusermaprule2 --users=$user1"
		rlRun "ipa selinuxusermap-add-host selinuxusermaprule2 --hosts=$MASTER"
		rlRun "ipa selinuxusermap-show selinuxusermaprule2 --all"

	# ipa selinuxusermaptest:

		rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
                rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
		rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
                rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"
                rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
                rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"

                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
                rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $MASTER does not have selinux policy $t1_ipa_selinuxuser "
                rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $MASTER has selinux policy $ipa_default_selinuxuser"
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
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd

}

selinuxusermapsvc_client2_002() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-002: user1 accessing $MASTER from $CLIENT2 using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                rlRun "getent -s sss passwd user2"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user2 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
        rlPhaseEnd
}


selinuxusermapsvc_master_003() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-003: $user1 part of hbac rule rule1 is allowed to access $CLIENT from $CLIENT with given selinux policy - SSHD Service"

	userpw="testpw123@ipa.com"

        # kinit as admin and creating users
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {1..3}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done
	
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ssh_auth_success $user1 testpw123@ipa.com $MASTER"
	rlRun "ssh_auth_success $user3 testpw123@ipa.com $MASTER"
	rlRun "ipa hbacrule-add admin_allow_all --hostcat=all --srchostcat=all --servicecat=all"
	rlRun "ipa hbacrule-add-user admin_allow_all --groups=admins"
        rlRun "ipa hbacrule-disable allow_all"

        # hbac rule specific user to specific host
	rlRun "ipa hbacrule-add rule1"
	rlRun "ipa hbacrule-add-user rule1 --users=$user1"
	rlRun "ipa hbacrule-add-host rule1 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-service rule1 --selinuxusermapsvcs=sshd"
	rlRun "ipa hbacrule-show rule1 --all"

        rlRun "ipa selinuxusermap-add selinuxusermaprule1 --selinuxuser=$t1_ipa_selinuxuser --hbacrule=rule1"
        rlRun "ipa selinuxusermap-show selinuxusermaprule1 --all"

	# ipa selinuxusermaptest:
	rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
  rlPhaseEnd
}

selinuxusermapsvc_master_003_cleanup() {
        # Cleanup
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	for i in {1..3}; do
		rlRun "ipa user-del user$i"
        done
	rlRun "rm -fr /tmp/krb5cc_*_*"
	rlRun "ipa selinuxusermap-del selinuxusermaprule1"	
	rlRun "ipa hbacrule-del rule1"
	rlRun "ipa hbacrule-del admin_allow_all"
	rlRun "ipa hbacrule-enable allow_all"
}

selinuxusermapsvc_client_003() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-003: $user1 accessing $CLIENT from $CLIENT with selinuxusermap -- using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "ssh_auth_failure $user2 testpw123@ipa.com $CLIENT"
        rlPhaseEnd
}

selinuxusermapsvc_client2_003() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-003: $user1 accessing $CLIENT from $CLIENT2 with selinuxusermap -- using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
		sleep 5
                rlRun "ssh_auth_failure $user1 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd
}

selinuxusermapsvc_master_004() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-004: $user1 associated with different selinuxusermap to access $CLIENT - evaluating rules applies correctly."

       	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        for i in {1..2}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

       	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa hbacrule-add admin_allow_all --hostcat=all --srchostcat=all --servicecat=all"
	rlRun "ipa hbacrule-add-user admin_allow_all --groups=admins"
        rlRun "ipa hbacrule-disable allow_all"

	# Selinuxusermap0 - all users access all services from all hosts
	rlRun "ipa selinuxusermap-add selinuxusermap0 --selinuxuser=t3_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap0 --hbacrule=allow_all"

	# HBAC rule for $user1 to access all hosts from all services.
	rlRun "ipa hbacrule-add rule1  --srchostcat=all --servicecat=all --hostcat=all" 
	rlRun "ipa hbacrule-add-user rule1 --users=$user1" 

	# Selinuxusermap1 - with rule1
	rlRun "ipa selinuxusermap-add selinuxusermap1 --selinuxuser=t2_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap1 --hbacrule=rule1"

	# HBAC rule for $user1 to access specific host.
	rlRun "ipa hbacrule-add rule2"
	rlRun "ipa hbacrule-add-user rule2 --users=$user1"
	rlRun "ipa hbacrule-add-host rule2 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-service rule2 --selinuxusermapsvcs=sshd"
	rlRun "ipa hbacrule-show rule2 --all"
	
	# Selinuxusermap2 - with rule2
	rlRun "ipa selinuxusermap-add selinuxusermaprule2 --selinuxuser=t1_ipa_selinuxuser --hbacrule=rule2"
        rlRun "ipa selinuxusermap-show selinuxusermaprule2 --all"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t2_ipa_selinuxuser"

        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}

selinuxusermapsvc_client_004() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004: $user1 accessing $CLIENT -sshed service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
	rlPhaseEnd
}

selinuxusermapsvc_client2_004() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004: $user1 accessing $MASTER from $CLIENT2 using FTP service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "ftp_auth_success $user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd

}

selinuxusermapsvc_master_004_2() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-004-2: $user1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap2 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa selinuxusermap-del selinuxusermaprule2"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t2_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd
}

selinuxusermapsvc_client_004_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004-2: $user1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd
}

selinuxusermapsvc_client2_004_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004-2: $user1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "ftp_auth_success $user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd

}

selinuxusermapsvc_master_004_3() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-004-3: $user1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap1 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa selinuxusermap-del selinuxusermaprule1"
	rlRun "ipa hbacrule-enable allow_all"

	 # ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t2_ipa_selinuxuser "

	rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $t3_ipa_selinuxuser"

        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t3_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"

        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t2_ipa_selinuxuser "
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

}

selinuxusermapsvc_client_004_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004-3: $user1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_004_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004-3: $user1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_master_004_4() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-004-4: $user1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap0 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa selinuxusermap-del selinuxusermaprule0"

         # ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"

        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $ipa_default_selinuxuser"

        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"

        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT has selinux policy $ipa_default_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $MASTER has selinux policy $ipa_default_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd
}

selinuxusermapsvc_master_004_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {1..2}; do
                rlRun "ipa user-del user$i"
        done
        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "ipa hbacrule-del rule1"
        rlRun "ipa hbacrule-del rule2"
        rlRun "ipa hbacrule-del admin_allow_all"
}

selinuxusermapsvc_client_004_4() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004-4: $user1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_004_4() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004-4: $user1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}


selinuxusermapsvc_master_005() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-005: user1 part of user group associated with different selinuxusermap to access $CLIENT - evaluating rules applies correctly."

       	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa group-add --desc="selinuxusermap test group" group1"
        rlRun "export group1=group1"
        for i in {1..2}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done
	rlRun "ipa group-add-member --users=$user1 $group1
		
	rlRun "ipa hbacrule-add admin_allow_all --hostcat=all --srchostcat=all --servicecat=all"
	rlRun "ipa hbacrule-add-user admin_allow_all --groups=admins"
        rlRun "ipa hbacrule-disable allow_all"

	# Selinuxusermap0 - all user groups access all services from all hosts
	rlRun "ipa selinuxusermap-add selinuxusermap0 --selinuxuser=t3_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap0 --hbacrule=allow_all"

	# HBAC rule for $group1 to access all hosts from all services.
	rlRun "ipa hbacrule-add rule1  --srchostcat=all --servicecat=all --hostcat=all" 
	rlRun "ipa hbacrule-add-user rule1 --groups=$group1" 

	# Selinuxusermap1 - with rule1
	rlRun "ipa selinuxusermap-add selinuxusermap1 --selinuxuser=t2_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap1 --hbacrule=rule1"

	# HBAC rule for $group1 to access specific host.
	rlRun "ipa hbacrule-add rule2"
	rlRun "ipa hbacrule-add-user rule2 --groups=$group1"
	rlRun "ipa hbacrule-add-host rule2 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-service rule2 --selinuxusermapsvcs=sshd"
	rlRun "ipa hbacrule-show rule2 --all"
	
	# Selinuxusermap2 - with rule2
	rlRun "ipa selinuxusermap-add selinuxusermaprule2 --selinuxuser=t1_ipa_selinuxuser --hbacrule=rule2"
        rlRun "ipa selinuxusermap-show selinuxusermaprule2 --all"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t2_ipa_selinuxuser"

        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}

selinuxusermapsvc_client_005() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005: $user1 part of $group1 accessing $CLIENT -sshed service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
	rlPhaseEnd
}

selinuxusermapsvc_client2_005() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005: $user1 part of $group1 accessing $MASTER from $CLIENT2 using FTP service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd

}

selinuxusermapsvc_master_005_2() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-005-2: $user1 part of $group1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap2 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa selinuxusermap-del selinuxusermaprule2"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_auth_success_selinuxuser_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t2_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
	rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd
}

selinuxusermapsvc_client_005_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005-2: $user1 part of $group1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd
}

selinuxusermapsvc_client2_005_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005-2: $user1 part of $group1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "ftp_auth_success $user2 testpw123@ipa.com $CLIENT"
                rlRun "ftp_auth_success $user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd

}

selinuxusermapsvc_master_005_3() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-005-3: $user1 part of $group1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap1 from the prev test"
        rlRun "ipa selinuxusermap-del selinuxusermaprule1"
	rlRun "ipa hbacrule-enable allow_all"

	 # ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t2_ipa_selinuxuser "

	rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $t3_ipa_selinuxuser"

        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_auth_failure_selinuxuser_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t3_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"

        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t2_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $MASTER $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $MASTER has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT2 $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT2 has selinux policy $t3_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

}

selinuxusermapsvc_client_005_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005-3: $user1 part of $group1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_005_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005-3: $user1 part of $group1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
	rlPhaseEnd
}

selinuxusermapsvc_master_005_4() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-005-4: $user1 part of $group1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap0 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa selinuxusermap-del selinuxusermaprule0"

         # ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"

        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $ipa_default_selinuxuser"

        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"

        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT has selinux policy $ipa_default_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $MASTER has selinux policy $ipa_default_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd
}

selinuxusermapsvc_master_005_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {1..2}; do
                rlRun "ipa user-del user$i"
        done
        rlRun "ipa group-del group1"
        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "ipa hbacrule-del rule1"
        rlRun "ipa hbacrule-del rule2"
        rlRun "ipa hbacrule-del admin_allow_all"
}

selinuxusermapsvc_client_005_4() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005-4: $user1 part of $group1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_005_4() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005-4: $user1 part of $group1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}


