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

	rlPhaseEnd
}

hbacsvc_client_001() {

        rlPhaseStartTest "ipa-hbacsvc-client1-001: $user1 accessing $CLIENT from $CLIENT using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "ssh_auth_success $user1 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure $user2 testpw123@ipa.com $CLIENT"
        rlPhaseEnd
}

hbacsvc_client2_001() {

        rlPhaseStartTest "ipa-hbacsvc-client2-001: $user1 accessing $CLIENT from $CLIENT2 using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "ssh_auth_failure $user1 testpw123@ipa.com $CLIENT2"

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

	rlPhaseEnd
}

hbacsvc_client_002() {

	rlPhaseStartTest "ipa-hbacsvc-client1-002: $user1 accessing $MASTER from $CLIENT2 using FTP service"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
		rlRun "ftp_auth_failure $user1 testpw123@ipa.com $MASTER"

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

hbacsvc_master_003() {
        rlPhaseStartTest "ipa-hbacsvc-003: $user3 part of rule3 with default ftp svcgrp is allowed to access $MASTER from $CLIENT2"

		rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=732996"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "yum install ftp vsftpd -y"
                rlRun "setsebool -P ftp_home_dir on"
                rlRun "service vsftpd restart"

                rlRun "ipa hbacrule-add rule3"
                rlRun "ipa hbacsvcgroup-add rule3 ftp --desc=\"ftp\""
                rlRun "ipa hbacrule-add-user rule3 --users=$user3"
                rlRun "ipa hbacrule-add-host rule3 --hosts=$MASTER"
                rlRun "ipa hbacrule-add-sourcehost rule3 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-show rule3 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$MASTER --service=ftp | grep -E '(Access granted: True|matched: rule3)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=ftp | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT --host=$MASTER --service=ftp | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$CLIENT --service=ftp | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT --host=$CLIENT2 --service=ftp | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$MASTER --service=ftp --rule=rule3 | grep -E '(Access granted: True|matched: rule3)'"
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT --host=$MASTER --service=ftp --rule=rule2 | grep -E '(Access granted: False|notmatched: rule2)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=ftp --rule=rule2 | grep -E '(Access granted: False|notmatched: rule2)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=ftp  --user=$user3 --rule=rule3 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=ftp  --user=$user3 --rule=rule3 --nodetail | grep -i \"matched: rule3\"" 1

        rlPhaseEnd
}

hbacsvc_client_003() {

        rlPhaseStartTest "ipa-hbacsvc-client1-003: $user3 accessing $MASTER from $CLIENT2 using default FTP service group"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user3"
                rlRun "ftp_auth_failure $user3 testpw123@ipa.com $MASTER"

        rlPhaseEnd
}

hbacsvc_client2_003() {

        rlPhaseStartTest "ipa-hbacsvc-client2-003: $user3 accessing $MASTER from $CLIENT2 using default FTP service group"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user3"
                rlRun "ftp_auth_success $user3 testpw123@ipa.com $MASTER"

        rlPhaseEnd

}

hbacsvc_master_004() {
        rlPhaseStartTest "ipa-hbacsvc-004: $user4 part of rule4 is allowed to access hostgroup from $CLIENT"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"
		rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=733663"

		rlRun "ipa hostgroup-add hostgrp1 --desc=hostgrp1"
		rlRun "ipa hostgroup-add-member hostgrp1 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule4"
                rlRun "ipa hbacrule-add-service rule4 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-user rule4 --users=$user4"
                rlRun "ipa hbacrule-add-host rule4 --hostgroups=hostgrp1"
                rlRun "ipa hbacrule-add-sourcehost rule4 --hosts=$CLIENT"
                rlRun "ipa hbacrule-show rule4 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -E '(Access granted: True|matched: rule4)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule4 | grep -E '(Access granted: True|matched: rule4)'"
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule4 | grep -E '(Access granted: False|notmatched: rule4)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule4 | grep -E '(Access granted: False|notmatched: rule4)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=hostgrp1 --service=sshd  --user=$user4 --rule=rule4 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT2 --service=sshd  --user=$user4 --rule=rule4 --nodetail | grep -i \"matched: rule4\"" 1

        rlPhaseEnd
}

hbacsvc_client_004() {

        rlPhaseStartTest "ipa-hbacsvc-client1-004: $user4 accessing hostgroup from $CLIENT2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user4"
                rlRun "ssh_auth_success $user4 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_004() {

        rlPhaseStartTest "ipa-hbacsvc-client2-004: $user4 accessing hostgroup from $CLIENT"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user4"
                rlRun "ssh_auth_failure $user4 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd

}


hbacsvc_master_005() {
        rlPhaseStartTest "ipa-hbacsvc-005: $user5 part of rule5 is allowed to access $CLIENT from hostgroup"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hostgroup-add hostgrp5 --desc=hostgrp5"
		rlRun "ipa hostgroup-add-member hostgrp5 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule5"
                rlRun "ipa hbacrule-add-service rule5 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-user rule5 --users=$user5"
                rlRun "ipa hbacrule-add-host rule5 --hostgroups=hostgrp5"
                rlRun "ipa hbacrule-add-sourcehost rule5 --hosts=$CLIENT"
                rlRun "ipa hbacrule-show rule5 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -E '(Access granted: True|matched: rule5)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule5 | grep -E '(Access granted: True|matched: rule5)'"
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule5 | grep -E '(Access granted: False|notmatched: rule5)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule5 | grep -E '(Access granted: False|notmatched: rule5)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=hostgrp5 --service=sshd  --user=$user5 --rule=rule5 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user5 --rule=rule5 --nodetail | grep -i \"matched: rule5\"" 1

        rlPhaseEnd
}

hbacsvc_client_005() {

        rlPhaseStartTest "ipa-hbacsvc-client1-005: $user5 accessing $CLIENT from hostgroup"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user5"
                rlRun "ssh_auth_success $user5 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_005() {

        rlPhaseStartTest "ipa-hbacsvc-client2-005: $user5 accessing $CLIENT from hostgroup"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user5"
                rlRun "ssh_auth_failure $user5 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}


