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

hbacsvc_master_001() {

	rlPhaseStartTest "ipa-hbacsvc-001: $user1 part of rule1 is allowed to access $CLIENT from $CLIENT - SSHD Service"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hbacrule-add rule1"
		rlRun "ipa hbacrule-add-user rule1 --users=$user1"
		rlRun "ipa hbacrule-add-host rule1 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-service rule1 --hbacsvcs=sshd"
		rlRun "ipa hbacrule-show rule1 --all"

	# ipa hbactest:
		
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -E '(Access granted: True|matched: rule1)'"
		rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\"" 
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\"" 
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\"" 

		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule1 | grep -E '(Access granted: True|matched: rule1)'"
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule2 | grep -E '(Access granted: True|notmatched: rule2)'"
		rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule1 | grep -E '(Access granted: False|notmatched: rule1)'"
		rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user1 --rule=rule1 --nodetail | grep -i \"Access granted: True\""
		rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user1 --rule=rule1 --nodetail | grep -i \"matched: rule1\"" 1

                rlRun "ipa hbacrule-enable allow_all"

	rlPhaseEnd
}

hbacsvc_master_002() {
	rlPhaseStartTest "ipa-hbacsvc-002: $user1 part of rule1 is allowed to access $MASTER from $CLIENT2 - FTP Service"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "yum install ftp vsftpd -y"
		rlRun "setsebool -P ftp_home_dir on"
		rlRun "service vsftpd start"

		rlRun "ipa hbacrule-add rule2"
		rlRun "ipa hbacsvc-add vsftpd --desc=\"vsftpd\""
		rlRun "ipa hbacrule-add-user rule2 --users=$user1"
		rlRun "ipa hbacrule-add-host rule2 --hosts=$MASTER"
		rlRun "ipa hbacrule-add-sourcehost rule2 --hosts=$CLIENT2"
		rlRun "ipa hbacrule-add-service rule2 --hbacsvcs=vsftpd"
		rlRun "ipa hbacrule-show rule2 --all"

	# ipa hbactest:

                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -E '(Access granted: True|matched: rule2)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$CLIENT --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT2 --service=vsftpd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule2 | grep -E '(Access granted: True|matched: rule2)'"
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=vsftpd --rule=rule1 | grep -E '(Access granted: False|notmatched: rule1)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule1 | grep -E '(Access granted: False|notmatched: rule1)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user1 --rule=rule1 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user1 --rule=rule1 --nodetail | grep -i \"matched: rule2\"" 1

                rlRun "ipa hbacrule-enable allow_all"

	rlPhaseEnd
}


hbacsvc_client1_001() {

        rlPhaseStartTest "ipa-hbacsvc-client1-001: $user1 accessing $CLIENT from $CLIENT using SSHD service."

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd $user1"
                rlRun "ssh_auth_success $user1 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure $user2 testpw123@ipa.com $CLIENT"
	rlPhaseEnd
}

hbacsvc_client1_002() {

	rlPhaseStartTest "ipa-hbacsvc-client1-002: $user1 accessing $MASTER from $CLIENT2 using FTP service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
		rlRun "ftp_auth_failure $user1 testpw123@ipa.com $MASTER"

	rlPhaseEnd
}


hbacsvc_client2_001() {

        rlPhaseStartTest "ipa-hbacsvc-client2-001: $user1 accessing $CLIENT from $CLIENT2 using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd $user1"
                rlRun "ssh_auth_failure $user1 testpw123@ipa.com $CLIENT2"

	rlPhaseEnd
}

hbacsvc_client2_002() {

	rlPhaseStartTest "ipa-hbacsvc-client2-002: $user1 accessing $MASTER from $CLIENT2 using FTP service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "ftp_auth_success $user1 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"

        rlPhaseEnd

}


