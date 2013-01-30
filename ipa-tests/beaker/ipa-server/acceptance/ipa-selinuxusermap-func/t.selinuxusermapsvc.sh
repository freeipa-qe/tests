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
. /dev/shm/ipa-selinuxusermap-cli-lib.sh

# Test Suite Globals
ipa_default_selinuxuser="unconfined_u:s0-s0:c0.c1023"
ipa_default_selinuxuser_verif="unconfined_u:.*s0-s0:c0.c1023"
t1_ipa_selinuxuser="staff_u:s0-s0:c0.c1023"
t1_ipa_selinuxuser_verif="staff_u:.*s0-s0:c0.c1023"
t2_ipa_selinuxuser="user_u:s0"
t2_ipa_selinuxuser_verif="user_u:.*s0"
t3_ipa_selinuxuser="xguest_u:s0"
t3_ipa_selinuxuser_verif="xguest_u:.*s0"
userpw="testpw123@ipa.com"

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
                rlRun "getent -s sss passwd user2"
		sleep 5
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
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_failure_selinuxuser user2 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd

}

selinuxusermapsvc_client2_002() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-002: user1 accessing $MASTER from $CLIENT2 using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
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
	#rlRun "ipa hbacrule-add admin_allow_all --hostcat=all --srchostcat=all --servicecat=all"
	#rlRun "ipa hbacrule-add-user admin_allow_all --groups=admins"
        #rlRun "ipa hbacrule-disable allow_all"

        # hbac rule specific user to specific host
	rlRun "ipa hbacrule-add rule1"
	rlRun "ipa hbacrule-add-user rule1 --users=$user1"
	rlRun "ipa hbacrule-add-host rule1 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-service rule1 --hbacsvcs=sshd"
	rlRun "ipa hbacrule-show rule1 --all"

        rlRun "ipa selinuxusermap-add selinuxusermaprule1 --selinuxuser=$t1_ipa_selinuxuser --hbacrule=rule1"
        rlRun "ipa selinuxusermap-show selinuxusermaprule1 --all"

	# ipa selinuxusermaptest:
	rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser "
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser"
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

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-003: user1 accessing $CLIENT from $CLIENT with selinuxusermap -- using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user2 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                #rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"
        rlPhaseEnd
}

selinuxusermapsvc_client2_003() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-003: user1 accessing $CLIENT from $CLIENT2 with selinuxusermap -- using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                #rlRun "ssh_auth_failure user1 testpw123@ipa.com $CLIENT2"
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
	rlRun "ipa selinuxusermap-add selinuxusermap0 --selinuxuser=$t3_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap0 --hbacrule=allow_all"

	# HBAC rule for $user1 to access all hosts from all services.
	rlRun "ipa hbacrule-add rule1  --srchostcat=all --servicecat=all --hostcat=all" 
	rlRun "ipa hbacrule-add-user rule1 --users=$user1" 

	# Selinuxusermap1 - with rule1
	rlRun "ipa selinuxusermap-add selinuxusermap1 --selinuxuser=$t2_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap1 --hbacrule=rule1"

	# HBAC rule for $user1 to access specific host.
	rlRun "ipa hbacrule-add rule2"
	rlRun "ipa hbacrule-add-user rule2 --users=$user1"
	rlRun "ipa hbacrule-add-host rule2 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-service rule2 --hbacsvcs=sshd"
	rlRun "ipa hbacrule-show rule2 --all"
	
	# Selinuxusermap2 - with rule2
	rlRun "ipa selinuxusermap-add selinuxusermaprule2 --selinuxuser=$t1_ipa_selinuxuser --hbacrule=rule2"
        rlRun "ipa selinuxusermap-show selinuxusermaprule2 --all"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
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

	rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004: $user1 accessing $CLIENT -sshd service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
		sleep 5
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
	rlPhaseEnd
}

selinuxusermapsvc_client2_004() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004: $user1 accessing $MASTER from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
		sleep 5
                #rlRun "ftp_auth_success user2 testpw123@ipa.com $MASTER" #Need_revisit
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
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
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
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

selinuxusermapsvc_client_004_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004-2: $user1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd
}

selinuxusermapsvc_client2_004_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004-2: $user1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                #rlRun "ftp_auth_success user2 testpw123@ipa.com $MASTER" #Need_revisit
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd

}

selinuxusermapsvc_master_004_3() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-004-3: $user1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap1 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa selinuxusermap-del selinuxusermap1"
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

        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t2_ipa_selinuxuser"
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

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-004-3: user1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_004_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004-3: $user1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_master_004_4() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-004-4: $user1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap0 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa selinuxusermap-del selinuxusermap0"

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
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_004_4() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-004-4: $user1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_master_005() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-005: user1 part of user group associated with different selinuxusermap to access $CLIENT - evaluating rules applies correctly."

       	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlRun "ipa group-add --desc=\"selinuxusermap test group\" group1"
        rlRun "export group1=group1"
        for i in {1..2}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done
       	
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa group-add-member --users=$user1 $group1"
		
	rlRun "ipa hbacrule-add admin_allow_all --hostcat=all --srchostcat=all --servicecat=all"
	rlRun "ipa hbacrule-add-user admin_allow_all --groups=admins"
        rlRun "ipa hbacrule-disable allow_all"

	# Selinuxusermap0 - all user groups access all services from all hosts
	rlRun "ipa selinuxusermap-add selinuxusermap0 --selinuxuser=$t3_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap0 --hbacrule=allow_all"

	# HBAC rule for $group1 to access all hosts from all services.
	rlRun "ipa hbacrule-add rule1  --srchostcat=all --servicecat=all --hostcat=all" 
	rlRun "ipa hbacrule-add-user rule1 --groups=$group1" 

	# Selinuxusermap1 - with rule1
	rlRun "ipa selinuxusermap-add selinuxusermap1 --selinuxuser=$t2_ipa_selinuxuser"
	rlRun "ipa selinuxusermap-mod selinuxusermap1 --hbacrule=rule1"

	# HBAC rule for $group1 to access specific host.
	rlRun "ipa hbacrule-add rule2"
	rlRun "ipa hbacrule-add-user rule2 --groups=$group1"
	rlRun "ipa hbacrule-add-host rule2 --hosts=$CLIENT"
	rlRun "ipa hbacrule-add-service rule2 --hbacsvcs=sshd"
	rlRun "ipa hbacrule-show rule2 --all"
	
	# Selinuxusermap2 - with rule2
	rlRun "ipa selinuxusermap-add selinuxusermaprule2 --selinuxuser=$t1_ipa_selinuxuser --hbacrule=rule2"
        rlRun "ipa selinuxusermap-show selinuxusermaprule2 --all"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $MASTER $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
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

	rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005: $user1 part of $group1 accessing $CLIENT -sshd service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
		sleep 5
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT"
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
	rlPhaseEnd
}

selinuxusermapsvc_client2_005() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005: $user1 part of $group1 accessing $MASTER from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
		sleep 5
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT"
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
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
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
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

selinuxusermapsvc_client_005_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005-2: $user1 part of $group1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT"
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd
}

selinuxusermapsvc_client2_005_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005-2: $user1 part of $group1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t2_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                #rlRun "ftp_auth_success user2 testpw123@ipa.com $CLIENT" #Need_revisit
                #rlRun "ftp_auth_success user2 testpw123@ipa.com $MASTER" #Need_revisit
                rlRun "ftp_auth_failure user2 testpw123@ipa.com $CLIENT2"
        rlPhaseEnd

}

selinuxusermapsvc_master_005_3() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-005-3: $user1 part of $group1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap1 from the prev test"
        rlRun "ipa selinuxusermap-del selinuxusermap1"
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

        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user1 $CLIENT2 $t2_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $t3_ipa_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $t3_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"

        rlRun "kinitAs $user2 $userpw" 0 "Kinit as $user2"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t1_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user2 $CLIENT $t2_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT does not have selinux policy $t2_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $MASTER $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $MASTER has selinux policy $t3_ipa_selinuxuser"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user2 $CLIENT2 $t3_ipa_selinuxuser_verif" 0 "Authentication of $user2 to $CLIENT2 has selinux policy $t3_ipa_selinuxuser"
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

}

selinuxusermapsvc_client_005_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-005-3: $user1 part of $group1 accessing $CLIENT - SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_005_3() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005-3: $user1 part of $group1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT $t2_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $t3_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $t3_ipa_selinuxuser_verif"
	rlPhaseEnd
}

selinuxusermapsvc_master_005_4() {
    rlPhaseStartTest "ipa-selinuxusermapsvc-005-4: $user1 part of $group1 associated with different selinuxusermap to access $CLIENT - delete selinuxusermap0 from the prev test"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa selinuxusermap-del selinuxusermap0"

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
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_005_4() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-005-4: $user1 part of $group1 accessing $MASTER from $CLIENT2 using SSHD service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}


selinuxusermapsvc_master_006() {
        rlPhaseStartTest "ipa-selinuxusermapsvc-006: $user6 associated with selinuxusermap --hostgroup access $CLIENT2 - sshd service"

		userpw="testpw123@ipa.com"
		for i in {5..6}; do
                	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	                rlRun "create_ipauser user$i user$i user$i $userpw"
        	        sleep 5
                	rlRun "export user$i=user$i"
        	done


                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ssh_auth_success $user5 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success $user6 testpw123@ipa.com $MASTER"

		rlRun "ipa hostgroup-add hostgrp1 --desc=hostgrp1"
		rlRun "ipa hostgroup-add-member hostgrp1 --hosts=$CLIENT2"

		rlRun "ipa selinuxusermap-add test_user_specific_hostgroup --selinuxuser=$t1_ipa_selinuxuser"
		rlRun "ipa selinuxusermap-add-host test_user_specific_hostgroup --hostgroups=hostgrp1"
		rlRun "ipa selinuxusermap-add-user test_user_specific_hostgroup --users=$user6"
	        rlRun "ipa selinuxusermap-show test_user_specific_hostgroup --all"

	 # ipa selinuxusermaptest:
        	rlRun "rlDistroDiff keyctl"
	        rlRun "kinitAs $user6 $userpw" 0 "Kinit as $user6"
        	rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user6 to $CLIENT2 has selinux policy $t1_ipa_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user6 to $CLIENT has selinux policy $ipa_default_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user6 to $MASTER has selinux policy $ipa_default_selinuxuser"
	        rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $user5 $userpw" 0 "Kinit as $user5"
		rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user5 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user5 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user5 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user5 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user5 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user5 to $CLIENT has selinux policy $ipa_default_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user5 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user5 to $MASTER has selinux policy $ipa_default_selinuxuser"
	        rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}

selinuxusermapsvc_client_006() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-006: $user6 accessing $CLIENT2 - sshd service"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_failure_selinuxuser user6 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_failure_selinuxuser user6 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user5"
                sleep 5
		rlRun "verify_ssh_auth_failure_selinuxuser user5 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
	rlPhaseEnd
}

selinuxusermapsvc_client2_006() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-006: $user6 accessing hostgroup from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_failure_selinuxuser user6 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_failure_selinuxuser user6 testpw123@ipa.com $MASTER $t1_ipa_selinuxuser_verif"
                rlRun "getent -s sss passwd user5"
                sleep 5
		rlRun "verify_ssh_auth_failure_selinuxuser user5 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd

}

selinuxusermapsvc_master_006_2() {
        rlPhaseStartTest "ipa-selinuxusermapsvc-006_2: $user6 removed from selinuxusermap"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa selinuxusermap-remove-user test_user_specific_hostgroup --users=$user6"
                rlRun "ipa selinuxusermap-show test_user_specific_hostgroup --all"
	# ipa selinuxusermaptest:
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user6 $userpw" 0 "Kinit as $user6"
		rlRun "verify_ssh_selinuxuser_failure_with_krbcred $user6 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user6 to $CLIENT2 does not have selinux policy $t1_ipa_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user6 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user6 to $CLIENT has selinux policy $ipa_default_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user6 to $MASTER has selinux policy $ipa_default_selinuxuser"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user5 $userpw" 0 "Kinit as $user5"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user5 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user5 to $CLIENT2 has selinux policy $ipa_default_selinuxuser"
		rlRun "verify_ssh_selinuxuser_success_with_krbcred $user5 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user5 to $CLIENT has selinux policy $ipa_default_selinuxuser"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"	
rlPhaseEnd

}

selinuxusermapsvc_master_006_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {5..6}; do
                rlRun "ipa user-del user$i"
        done
        rlRun "ipa hostgroup-del hostgrp1"
        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "ipa selinuxusermap-del test_user_specific_hostgroup"
}

selinuxusermapsvc_client_006_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-006_2: user6 accessing $CLIENT2 - sshd service"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
		rlRun "verify_ssh_auth_failure_selinuxuser user6 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user5"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_client2_006_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-006_2: user6 accessing hostgroup from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
		rlRun "verify_ssh_auth_failure_selinuxuser user6 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user5"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user5 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
        rlPhaseEnd

}

selinuxusermapsvc_master_007() {
        rlPhaseStartTest "ipa-selinuxusermapsvc-007: $user6 part of hbacrule rule6 is allowed to access hostgroup from $CLIENT with correct selinuxusermap."

		userpw="testpw123@ipa.com"
		for i in {5..6}; do
                	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	                rlRun "create_ipauser user$i user$i user$i $userpw"
        	        sleep 5
                	rlRun "export user$i=user$i"
        	done


                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ssh_auth_success $user5 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success $user6 testpw123@ipa.com $MASTER"

                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hostgroup-add hostgrp1 --desc=hostgrp1"
		rlRun "ipa hostgroup-add-member hostgrp1 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule6"
                rlRun "ipa hbacrule-add-service rule6 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-user rule6 --users=$user6"
                rlRun "ipa hbacrule-add-host rule6 --hostgroups=hostgrp1"
                rlRun "ipa hbacrule-add-sourcehost rule6 --hosts=$CLIENT"
                rlRun "ipa hbacrule-show rule6 --all"

		rlRun "ipa selinuxusermap-add test_user_specific_hostgroup --selinuxuser=$t1_ipa_selinuxuser --hbacrule=rule6"
	        rlRun "ipa selinuxusermap-show test_user_specific_hostgroup --all"
	 # ipa selinuxusermaptest:
        	rlRun "rlDistroDiff keyctl"
	        rlRun "kinitAs $user6 $userpw" 0 "Kinit as $user6"
        	rlRun "verify_ssh_selinuxuser_success_with_krbcred $user6 $CLIENT2 $t1_ipa_selinuxuser_verif" 0 "Authentication of $user6 to $CLIENT2 has selinux policy $t1_ipa_selinuxuser"
                rlRun "ftp_auth_failure $user6 testpw123@ipa.com $CLIENT"
	        rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $user5 $userpw" 0 "Kinit as $user5"
                rlRun "ftp_auth_failure $user5 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user5 testpw123@ipa.com $CLIENT"
	        rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}

selinuxusermapsvc_client_007() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-007: user6 accessing $CLIENT2 - sshd service"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user5"
                sleep 5
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $MASTER"
	rlPhaseEnd
}

selinuxusermapsvc_client2_007() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-007: user6 accessing hostgroup from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user6 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                #rlRun "ssh_auth_failure user6 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user5"
                sleep 5
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $MASTER"
        rlPhaseEnd

}

selinuxusermapsvc_master_007_2() {
        rlPhaseStartTest "ipa-selinuxusermapsvc-007_2: $user6 removed from rule6"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-remove-user rule6 --users=$user6"
                rlRun "ipa hbacrule-show rule6 --all"
	# ipa selinuxusermaptest:
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user6 $userpw" 0 "Kinit as $user6"
                rlRun "ftp_auth_failure $user6 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user6 testpw123@ipa.com $CLIENT"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user5 $userpw" 0 "Kinit as $user5"
                rlRun "ftp_auth_failure $user5 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user5 testpw123@ipa.com $CLIENT"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"	
rlPhaseEnd

}

selinuxusermapsvc_master_007_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {5..6}; do
                rlRun "ipa user-del user$i"
        done
        rlRun "ipa hostgroup-del hostgrp1"
        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "ipa selinuxusermap-del test_user_specific_hostgroup"
        rlRun "ipa hbacrule-del rule6"
        rlRun "ipa hbacrule-enable allow_all"
}

selinuxusermapsvc_client_007_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-007_2: user6 accessing $CLIENT2 - sshd service"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user5"
                sleep 5
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $MASTER"
        rlPhaseEnd
}

selinuxusermapsvc_client2_007_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-007_2: user6 accessing hostgroup from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                sleep 5
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user5"
                sleep 5
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $MASTER"
        rlPhaseEnd

}


selinuxusermapsvc_master_008() {
        rlPhaseStartTest "ipa-selinuxusermapsvc-008: $user8 part of hbacrule rule8 is allowed to access hostgroup from hostgroup2 with correct selinuxusermap."

		userpw="testpw123@ipa.com"
		for i in {8..9}; do
                	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	                rlRun "create_ipauser user$i user$i user$i $userpw"
        	        sleep 5
                	rlRun "export user$i=user$i"
        	done


                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ssh_auth_success $user8 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success $user9 testpw123@ipa.com $MASTER"

                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hostgroup-add hostgrp8-1 --desc=hostgrp8-1"
		rlRun "ipa hostgroup-add-member hostgrp8-1 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgrp8-2 --desc=hostgrp8-2"
		rlRun "ipa hostgroup-add-member hostgrp8-2 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule8"
                rlRun "ipa hbacrule-add-service rule8 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-user rule8 --users=$user8"
                rlRun "ipa hbacrule-add-host rule8 --hostgroups=hostgrp8-1"
                rlRun "ipa hbacrule-add-sourcehost rule8 --hostgroups=hostgrp8-2"
                rlRun "ipa hbacrule-show rule8 --all"

		rlRun "ipa selinuxusermap-add test_user_specific_hostgroup_from_hostgroup --selinuxuser=$t1_ipa_selinuxuser --hbacrule=rule8"
	        rlRun "ipa selinuxusermap-show test_user_specific_hostgroup_from_hostgroup --all"

	 # ipa selinuxusermaptest:
        	rlRun "rlDistroDiff keyctl"
	        rlRun "kinitAs $user8 $userpw" 0 "Kinit as $user8"
        	rlRun "verify_ssh_selinuxuser_success_with_krbcred $user8 $CLIENT $t1_ipa_selinuxuser_verif" 0 "Authentication of $user8 to $CLIENT has selinux policy $t1_ipa_selinuxuser"
                rlRun "ftp_auth_failure $user8 testpw123@ipa.com $CLIENT2"
	        rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $user9 $userpw" 0 "Kinit as $user9"
                rlRun "ftp_auth_failure $user9 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user9 testpw123@ipa.com $CLIENT"
	        rlRun "rlDistroDiff keyctl"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlPhaseEnd
}

selinuxusermapsvc_client_008() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-008: user8 accessing hostgroup2 from hostgroup - sshd service"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
                sleep 5
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT2"
                rlRun "verify_ssh_auth_success_selinuxuser user8 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user9"
                sleep 5
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $MASTER"
	rlPhaseEnd
}

selinuxusermapsvc_client2_008() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-008: user8 accessing hostgroup from hostgroup2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
                sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user8 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user9"
                sleep 5
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $MASTER"
        rlPhaseEnd

}

selinuxusermapsvc_master_008_2() {
        rlPhaseStartTest "ipa-selinuxusermapsvc-008_2: $user8 removed from rule8 which was allowed to access hostgroup from hostgroup2"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-remove-user rule8 --users=$user8"
                rlRun "ipa hbacrule-show rule8 --all"
	# ipa selinuxusermaptest:
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user8 $userpw" 0 "Kinit as $user8"
                rlRun "ftp_auth_failure $user8 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user8 testpw123@ipa.com $CLIENT"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $user9 $userpw" 0 "Kinit as $user9"
                rlRun "ftp_auth_failure $user9 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user9 testpw123@ipa.com $CLIENT"
                rlRun "rlDistroDiff keyctl"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"	
rlPhaseEnd

}

selinuxusermapsvc_master_008_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {8..9}; do
                rlRun "ipa user-del user$i"
        done
        rlRun "ipa hostgroup-del hostgrp8-1"
        rlRun "ipa hostgroup-del hostgrp8-2"
        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "ipa selinuxusermap-del test_user_specific_hostgroup_from_hostgroup"
        rlRun "ipa hbacrule-del rule8"
        rlRun "ipa hbacrule-enable allow_all"
}

selinuxusermapsvc_client_008_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-008_2: user8 accessing hostgroup from hostgroup2 - sshd service"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
                sleep 5
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user9"
                sleep 5
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $MASTER"
        rlPhaseEnd
}

selinuxusermapsvc_client2_008_2() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-008_2: user8 accessing hostgroup from hostgroup2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
                sleep 5
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $MASTER"
                rlRun "getent -s sss passwd user9"
                sleep 5
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user9 testpw123@ipa.com $MASTER"
        rlPhaseEnd
}
selinuxusermapsvc_master_009() {
	rlPhaseStartTest "ipa-selinuxusermapsvc-009: $user1 associated with empty selinuxusermap on $MASTER"

        tmpout=/tmp/tmpout.txt
       	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

                rlRun "create_ipauser user1 user1 user1 $userpw"
                sleep 5
                rlRun "export user1=user1"

       	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
 
        rlRun "ipa config-mod --ipaselinuxusermapdefault= > $tmpout 2>&1" 0 "Default selinux user is set to empty"
        rlRun "ipa config-show"
        rlAssertNotGrep "Default SELinux user" "$tmpout"

	# ipa selinuxusermaptest:
        rlRun "rlDistroDiff keyctl"
        rlRun "kinitAs $user1 $userpw" 0 "Kinit as $user1"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT has selinux policy $ipa_default_selinuxuser_verif"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $MASTER $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $MASTER has selinux policy $ipa_default_selinuxuser_verif"
        rlRun "verify_ssh_selinuxuser_success_with_krbcred $user1 $CLIENT2 $ipa_default_selinuxuser_verif" 0 "Authentication of $user1 to $CLIENT2 has selinux policy $ipa_default_selinuxuser_verif"

}

selinuxusermapsvc_client_009() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client1-009: user1 accessing $CLIENT -sshd service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
	rlPhaseEnd
}

selinuxusermapsvc_client2_009() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-client2-009: user1 accessing $MASTER from $CLIENT2 using sshd service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
		rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
        rlPhaseEnd
}

selinuxusermapsvc_master_009_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa user-del user1"
        rlRun "ipa config-mod --ipaselinuxusermapdefault=unconfined_u:s0-s0:c0.c1023" 0 "Default selinuxusermap is being setup"

        rlRun "rm -fr /tmp/krb5cc_*_*"
        rlRun "rm /tmp/tmpout.txt"
}

selinuxusermapsvc_master_010() {

	rlPhaseStartTest "ipa-selinuxusermapsvc-010: Cached selinuxusermap data is used if IPA Server not reachable"

                # kinit as admin and creating users
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        	for i in {1..2}; do
                	rlRun "create_ipauser user$i user$i user$i $userpw"
                	sleep 5
                	rlRun "export user$i=user$i"
	        done

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ssh_auth_success $user1 testpw123@ipa.com $MASTER"
		rlRun "ssh_auth_success $user2 testpw123@ipa.com $MASTER"
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

selinuxusermapsvc_master_010_cleanup() {
        # Cleanup
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	for i in {1..2}; do
		rlRun "ipa user-del user$i"
        done
	rlRun "rm -fr /tmp/krb5cc_*_*"
	rlRun "ipa selinuxusermap-del selinuxusermaprule1"
}

selinuxusermapsvc_client_010() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client1-010: user1 accessing $CLIENT from $CLIENT using SSHD service."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
		sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
		sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
 
                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
		sleep 10
                 
                rlRun "getent -s sss passwd user1"
		sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                rlRun "getent -s sss passwd user2"
		sleep 5
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user2 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"
                #Starting ipa sevice on $MASTER

                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"
                rlRun "rm -rf $TmpDir"

        rlPhaseEnd
}

selinuxusermapsvc_client2_010() {

        rlPhaseStartTest "ipa-selinuxusermapsvc-client2-010: user1 accessing $CLIENT from $CLIENT2 using SSHD service."
                sleep 35
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user1"
                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"

                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
		sleep 10

                rlRun "verify_ssh_auth_failure_selinuxuser user1 testpw123@ipa.com $CLIENT2 $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT2 $ipa_default_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $CLIENT $t1_ipa_selinuxuser_verif"
                rlRun "verify_ssh_auth_success_selinuxuser user1 testpw123@ipa.com $MASTER $ipa_default_selinuxuser_verif"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

