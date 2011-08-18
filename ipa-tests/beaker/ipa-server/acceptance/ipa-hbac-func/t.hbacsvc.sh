#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbacfunc
#   Description: Functional test cases for ipa hbca
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date   : August 11, 2011
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


hbacsvc_setup() {

	rlPhaseStartTest "ipa-hbacsvc-001: Setup IPA Server HBAC - SSHD Service"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "ipa hbacrule-add rule1"
		rlRun "ipa hbacrule-add-user rule1 --users=$user1"
		rlRun "ipa hbacrule-add-host rule1 --hosts=$CLIENT1"
		rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$CLIENT1"
		rlRun "ipa hbacrule-add-service rule1 --hbacsvcs=sshd"
		rlRun "ipa hbacrule-show rule1 --all"

	# ipa hbactest:
		
		rlRun "ipa hbactest --user=$user1 --srchost=$CLEINT1 --host=$CLIENT1 --service=sshd | grep -E '(Access granted: True|matched: rule1)'"
		rlRun "ipa hbactest --user=$user2 --srchost=$CLEINT1 --host=$CLIENT1 --service=sshd | grep -i \"Access granted: False\"" 
		rlRun "ipa hbactest --user=$user1 --srchost=$CLEINT2 --host=$CLIENT1 --service=sshd | grep -i \"Access granted: False\"" 
		rlRun "ipa hbactest --user=$user1 --srchost=$CLEINT1 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\"" 

		rlRun "ipa hbactest --user=$user1 --srchost=$CLEINT1 --host=$CLIENT1 --service=sshd --rule=rule1 | grep -E '(Access granted: True|matched: rule1)'"
		rlRun "ipa hbactest --user=$user1 --srchost=$CLEINT1 --host=$CLIENT1 --service=sshd --rule=rule2 | grep -E '(Access granted: True|notmatched: rule2)'"
		rlRun "ipa hbactest --user=$user2 --srchost=$CLEINT1 --host=$CLIENT1 --service=sshd --rule=rule1 | grep -E '(Access granted: False|notmatched: rule1)'"
		rlRun "ipa hbactest --srchost=$CLIENT1 --host=$CLIENT1 --service=sshd  --user=$user1 --rule=rule1 --nodetail | grep -i \"Access granted: True\""
		rlRun "ipa hbactest --srchost=$CLIENT1 --host=$CLIENT1 --service=sshd  --user=$user1 --rule=rule1 --nodetail | grep -i \"matched: rule1\"" 1

	rlPhaseEnd
}


hbacsvc_client1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-001: $user1 accessing $CLIENT1 from $CLIENT1 using SSHD service."

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd $user1"
                rlRun "ssh_auth_success $user1 testpw123@ipa.com $CLIENT1"
	rlPhaseEnd
}


hbacsvc_client2() {

        rlPhaseStartTest "ipa-hbacsvc-client2-001: $user1 accessing $CLIENT1 from $CLIENT2 using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd $user1"

                rlRun "ssh_auth_failure $user1 testpw123@ipa.com $CLIENT2"
	rlPhaseEnd
}


