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
. /dev/shm/env.sh


hbacsvc_setup() {


rlPhaseStartSetup "ipa-hbacsvc-func: Setup of users"

        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        # add host for testing
        rlRun "addHost $CLIENT1" 0 "SETUP: Adding host $CLIENT1 for testing."
        rlRun "addHost $CLIENT2" 0 "SETUP: Adding host $CLIENT2 for testing."

        # kinit as admin and creating users
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user1 $user1 $user1 $userpw"
        sleep 5
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user2 $user2 $user2 $userpw"
        sleep 5
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user3 $user3 $user3 $userpw"

rlPhaseEnd


	rlPhaseStartTest "ipa-hbacsvc-001: Setup IPA Server HBAC - SSHD Service"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "ipa hbacrule-add rule1"
		rlRun "ipa hbacrule-add-user rule1 --users=$user1"
		rlRun "ipa hbacrule-add-host rule1 --hosts=$CLIENT1"
		rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$CLIENT1"
		rlRun "ipa hbacrule-add-service rule1 --hbacsvcs=sshd"
		rlRun "ipa hbacrule-show rule1 --all"
	rlPhaseEnd


    rlPhaseStartCleanup "ipa-hbacrule-func-cleanup: Destroying admin credentials."
        # delete service group
        rlRun "ipa hbacsvcgroup-del $servicegroup" 0 "CLEANUP: Deleting service group $servicegroup"

        rlRun "kdestroy" 0 "Destroying admin credentials."
        rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd


}



hbac_client1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-001: $user1 accessing $CLIENT1 from $CLIENT1 using SSHD service."

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

auth_success()
   {
        {
		expect -f - <<-EOF | grep -C 77 '^login successful'
                	spawn ssh -q -l "$1" $CLIENT1 echo 'login successful'
                        expect {
                        	"Are you sure you want to continue connecting (yes/no)? " {
                                send -- "yes\r"
                                exp_continue
                                	}
                                "*assword: " {
                                send -- "$2\r"
                                	     }
                                }
                                expect eof
EOF
                                if [ $? = 0 ]; then
                                        rlPass "Authentication successful, as expected"
                                else
                                        rlFail "ERROR: Authentication failed."
                                fi
        }
   }

                rlRun "auth_success $user1 testpw123@ipa.com"

}


hbac_client2() {

        rlPhaseStartTest "ipa-hbacsvc-client2-001: $user1 accessing $CLIENT1 from $CLIENT2 using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

auth_failure()
   {
        {
                        expect -f - <<-EOF | grep -C 77 '^login successful'
                                spawn ssh -q -l "$1" $CLIENT1 echo 'login successful'
                                expect {
                                "Are you sure you want to continue connecting (yes/no)? " {
                                send -- "yes\r"
                                exp_continue
                                }
                                "*assword: " {
                                send -- "$2\r"
                                }
                                }
                                expect eof
EOF
                                if [ $? = 0 ]; then
                                        rlFail "ERROR: Authentication success."
                                else
                                        rlPass "Authentication failed, as expected"
                                fi
        }
   }

                rlRun "auth_failure $user1 testpw123@ipa.com"

}


