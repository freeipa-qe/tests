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
#   Authors: 
#	     Gowrishankar Rajaiyan <gsr@redhat.com>
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
. /opt/rhqa_ipa/ipa-server-shared.sh

hbacsvc_master_001() {

	rlPhaseStartTest "ipa-hbacsvc-001: $user1 part of rule1 is allowed to access $CLIENT from $CLIENT - SSHD Service"

                # kinit as admin and creating users
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser $user1 $user1 $user1 $userpw"
		rlRun "ssh_auth_success $user1 testpw123@ipa.com $MASTER"
        for i in {1..3}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done


                kdestroy
		rlRun "ssh_auth_success $user1 testpw123@ipa.com $MASTER"
		rlRun "ssh_auth_success $user3 testpw123@ipa.com $MASTER"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-add admin_allow_all --hostcat=all --srchostcat=all --servicecat=all"
		rlRun "ipa hbacrule-add-user admin_allow_all --groups=admins"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hbacrule-add rule1"
		rlRun "ipa hbacrule-add-user rule1 --users=$user1"
		rlRun "ipa hbacrule-add-host rule1 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-sourcehost rule1 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-service rule1 --hbacsvcs=sshd"
		rlRun "ipa hbacrule-show rule1 --all"

	# ipa hbactest:
		
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule1)'"
		rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\"" 
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\"" 
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\"" 

		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule1 | grep -Ex '(Access granted: True|  matched: rule1)'"
		rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule2 | grep -Ex '(Unresolved rules in --rules|error: rule2)'" 
		rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule1 | grep -Ex '(Access granted: False|  notmatched: rule1)'"
		rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user1 --rule=rule1 --nodetail | grep -i \"Access granted: True\""
		rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user1 --rule=rule1 --nodetail | grep -i \"matched: rule1\"" 1

	rlPhaseEnd
}

hbacsvc_master_001_cleanup() {
        # Cleanup
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	for i in {1..3}; do
		rlRun "ipa user-del user$i"
    done
	rlRun "rm -fr /tmp/krb5cc_*_*"
	rlRun "ipa hbacrule-del rule1"
	rlRun "ipa hbacrule-del admin_allow_all"
}

hbacsvc_client_001() {

        rlPhaseStartTest "ipa-hbacsvc-client1-001: $user1 accessing $CLIENT from $CLIENT using SSHD service."

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
		sleep 5
                 kinitAs $ADMINID $ADMINPW
                ipa hbacrule-find
		rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule1 | grep -Ex '(Access granted: False|  notmatched: rule1)'"
                kdestroy
                rlRun "ssh_auth_success $user1 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure $user2 testpw123@ipa.com $CLIENT"
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd
}

hbacsvc_client2_001() {

        rlPhaseStartTest "ipa-hbacsvc-client2-001: $user1 accessing $CLIENT from $CLIENT2 using SSHD service."

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                kdestroy
                rlRun "ssh_auth_failure $user1 testpw123@ipa.com $CLIENT2"
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd
}

hbacsvc_master_002() {
	rlPhaseStartTest "ipa-hbacsvc-002: $user1 part of rule1 is allowed to access $MASTER from $CLIENT2 - FTP Service"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        for i in {1..3}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "yum install ftp vsftpd -y"
		rlRun "service vsftpd start"
		rlRun "setsebool -P ftp_home_dir on"

        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-add rule2"
		rlRun "ipa hbacrule-add-user rule2 --users=$user1"
		rlRun "ipa hbacrule-add-host rule2 --hosts=$MASTER"
		rlRun "ipa hbacrule-add-sourcehost rule2 --hosts=$CLIENT2"
		rlRun "ipa hbacrule-add-service rule2 --hbacsvcs=vsftpd"
		rlRun "ipa hbacrule-show rule2 --all"

	# ipa hbactest:

                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -Ex '(Access granted: True|  matched: rule2)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$CLIENT --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT2 --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule2 | grep -Ex '(Access granted: True|  matched: rule2)'"
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=vsftpd --rule=rule1 | grep -i \"Non-existent or invalid rules: rule1\""
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule1 | grep -i \"Non-existent or invalid rules: rule1\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user1 --rule=rule2 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user1 --rule=rule2 --nodetail | grep -i \"matched: rule2\"" 1

	rlPhaseEnd
}

hbacsvc_master_002_cleanup() {
	# Cleanup
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	for i in {1..3}; do
		rlRun "ipa user-del user$i"
    done
	rlRun "rm -fr /tmp/krb5cc_*_*"
	rlRun "ipa hbacrule-del rule2"
}

hbacsvc_client_002() {

	rlPhaseStartTest "ipa-hbacsvc-client1-002: $user1 accessing $MASTER from $CLIENT2 using FTP service"

		#rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                kdestroy
		# Source host validation has been depricated which caused the following test to fail, hence updating accordingly.
		rlRun "ftp_auth_success $user1 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
		rlRun "rm -fr /tmp/krb5cc_*_*"

	rlPhaseEnd
}

hbacsvc_client2_002() {

	rlPhaseStartTest "ipa-hbacsvc-client2-002: $user1 accessing $MASTER from $CLIENT2 using FTP service"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "getent -s sss passwd $user2"
		sleep 5
               kdestroy
                rlRun "ftp_auth_success $user1 testpw123@ipa.com $MASTER"
		rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
		rlRun "rm -fr /tmp/krb5cc_*_*"
#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	rlPhaseEnd

}


hbacsvc_master_002_1() {
        rlPhaseStartTest "ipa-hbacsvc-002_1: vsftpd service removed from rule1 which was allowed to access $MASTER from $CLIENT2 - FTP Service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacsvc-del vsftpd"
                rlRun "ipa hbacrule-show rule2 --all"

        # ipa hbactest:
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$CLIENT --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$CLIENT2 --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule2 | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=vsftpd --rule=rule1 | grep -i \"Non-existent or invalid rules: rule1\""
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule1 | grep -i \"Non-existent or invalid rules: rule1\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user1 --rule=rule1 --nodetail | grep -i \"Access granted: True\"" 1
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user1 --rule=rule1 --nodetail | grep -i \"matched: rule2\"" 1
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd
}

hbacsvc_client_002_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-002_1: vsftpd service removed from rule1 which was allowed to access $MASTER from $CLIENT2 - FTP Service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "ftp_auth_failure $user1 testpw123@ipa.com $MASTER"
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd
}

hbacsvc_client2_002_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-002_1: vsftpd service removed from rule1 which was allowed to access $MASTER from $CLIENT2 - FTP Service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user1"
                rlRun "ftp_auth_failure $user1 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd

}



hbacsvc_master_003() {
        rlPhaseStartTest "ipa-hbacsvc-003: $user3 part of rule3 with default ftp svcgrp is allowed to access $MASTER from $CLIENT2"

		rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=732996"

        for i in {1..3}; do
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "yum install ftp vsftpd -y"
                rlRun "setsebool -P ftp_home_dir on"
                rlRun "service vsftpd restart"

                rlRun "ipa hbacrule-add rule3"

		rlRun "ipa hbacsvc-add vsftpd"
		rlRun "ipa hbacsvcgroup-add-member ftp --hbacsvcs=vsftpd"

                rlRun "ipa hbacrule-add-service rule3 --hbacsvcgroups=ftp"
                rlRun "ipa hbacrule-add-user rule3 --users=$user3"
                rlRun "ipa hbacrule-add-host rule3 --hosts=$MASTER"
                rlRun "ipa hbacrule-add-sourcehost rule3 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-show rule3 --all"

        # ipa hbactest:
		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=746227"
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -Ex '(Access granted: True|  matched: rule3)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT --host=$MASTER --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$CLIENT --service=vsftpd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT --host=$CLIENT2 --service=vsftpd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule3 | grep -Ex '(Access granted: True|  matched: rule3)'"
		# ftp service is a part of ftp service group, hence the following rule should match.
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT2 --host=$MASTER --service=ftp --rule=rule3 | grep -Ex '(Access granted: True|  matched: rule3)'"
                rlRun "ipa hbactest --user=$user3 --srchost=$CLIENT --host=$MASTER --service=vsftpd --rule=rule2 | grep -i \"Non-existent or invalid rules: rule2\""
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$MASTER --service=vsftpd --rule=rule2 | grep -i \"Non-existent or invalid rules: rule2\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user3 --rule=rule3 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$MASTER --service=vsftpd  --user=$user3 --rule=rule3 --nodetail | grep -i \"matched: rule3\"" 1

        rlPhaseEnd
}

hbacsvc_master_003_cleanup() {
	# Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {1..3}; do
                rlRun "ipa user-del user$i"
        done
		rlRun "rm -fr /tmp/krb5cc_*_*"
		rlRun "ipa hbacrule-del rule3"
		rlRun "ipa hbacsvc-del vsftpd"
}

hbacsvc_client_003() {

        rlPhaseStartTest "ipa-hbacsvc-client1-003: $user3 accessing $MASTER from $CLIENT2 using default FTP service group"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user3"
                kdestroy
                rlRun "ftp_auth_failure $user2 testpw123@ipa.com $MASTER"
                rlRun "ftp_auth_success $user3 testpw123@ipa.com $MASTER"
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd
}

hbacsvc_client2_003() {

        rlPhaseStartTest "ipa-hbacsvc-client2-003: $user3 accessing $MASTER from $CLIENT2 using default FTP service group"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user3"
		sleep 5
                kdestroy
                rlRun "ftp_auth_success $user3 testpw123@ipa.com $MASTER"
                rlRun "rm -fr /tmp/krb5cc_*_*"

        rlPhaseEnd

}

hbacsvc_master_004() {
        rlPhaseStartTest "ipa-hbacsvc-004: $user4 part of rule4 is allowed to access hostgroup from $CLIENT"

        for i in 4; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done


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

                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule4)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user4 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule4 | grep -Ex '(Access granted: True|  matched: rule4)'"
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule4 | grep -Ex '(Access granted: False|  notmatched: rule4)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule4 | grep -Ex '(Access granted: False|  notmatched: rule4)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=hostgrp1 --service=sshd  --user=$user4 --rule=rule4 --nodetail | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT2 --service=sshd  --user=$user4 --rule=rule4 --nodetail | grep -i \"matched: rule4\"" 1

        rlPhaseEnd
}

hbacsvc_master_004_cleanup() {
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	# Cleanup
		rlRun "ipa hbacrule-del rule4"
		rlRun "ipa hostgroup-del hostgrp1"
}

hbacsvc_client_004() {

        rlPhaseStartTest "ipa-hbacsvc-client1-004: user4 accessing hostgroup from $CLIENT2"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user4"
                kdestroy
                rlRun "ssh_auth_success user4 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_004() {

        rlPhaseStartTest "ipa-hbacsvc-client2-004: user4 accessing hostgroup from $CLIENT"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user4"
                kdestroy
                rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd

}


hbacsvc_master_005() {
        rlPhaseStartTest "ipa-hbacsvc-005: $user5 part of rule5 is allowed to access $CLIENT from hostgroup"

        for i in 5; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done


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

                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule5)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule5 | grep -Ex '(Access granted: True|  matched: rule5)'"
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule5 | grep -Ex '(Access granted: False|  notmatched: rule5)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule5 | grep -Ex '(Access granted: False|  notmatched: rule5)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=hostgrp5 --service=sshd  --user=$user5 --rule=rule5 --nodetail | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user5 --rule=rule5 --nodetail | grep -i \"matched: rule5\"" 1

        rlPhaseEnd
}

hbacsvc_master_005_cleanup() {
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	# Cleanup
		rlRun "ipa hbacrule-del rule5"
		rlRun "ipa hostgroup-del hostgrp5"
}

hbacsvc_client_005() {

        rlPhaseStartTest "ipa-hbacsvc-client1-005: user5 accessing $CLIENT from hostgroup"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user5"
		sleep 5
                kdestroy
                rlRun "ssh_auth_success user5 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_005() {

        rlPhaseStartTest "ipa-hbacsvc-client2-005: user5 accessing $CLIENT from hostgroup"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user5"
                kdestroy
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}


hbacsvc_master_005_1() {
        rlPhaseStartTest "ipa-hbacsvc-005_1: $user5 is removed from rule5"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-remove-user rule5 --users=$user5"
                rlRun "ipa hbacrule-show rule5 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule5)'" 1
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user5 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule5 | grep -Ex '(Access granted: True|  matched: rule5)'" 1
                rlRun "ipa hbactest --user=$user1 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule5 | grep -Ex '(Access granted: False|  notmatched: rule5)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule5 | grep -Ex '(Access granted: False|  notmatched: rule5)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=hostgrp5 --service=sshd  --user=$user5 --rule=rule5 --nodetail | grep -i \"Access granted: True\"" 1
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user5 --rule=rule5 --nodetail | grep -i \"matched: rule5\"" 1

        rlPhaseEnd
}

hbacsvc_client_005_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-005_1: user5 is removed from rule5"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user5"
                kdestroy
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_005_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-005_1: user5 is removed from rule5"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user5"
                kdestroy
                rlRun "ssh_auth_failure user5 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}



hbacsvc_master_006() {
        rlPhaseStartTest "ipa-hbacsvc-006: $user6 part of rule6 is allowed to access hostgroup from hostgroup2"

        for i in 6; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hostgroup-add hostgrp6-1 --desc=hostgrp6-1"
		rlRun "ipa hostgroup-add-member hostgrp6-1 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgrp6-2 --desc=hostgrp6-2"
		rlRun "ipa hostgroup-add-member hostgrp6-2 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule6"
                rlRun "ipa hbacrule-add-service rule6 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-user rule6 --users=$user6"
                rlRun "ipa hbacrule-add-host rule6 --hostgroups=hostgrp6-1"
                rlRun "ipa hbacrule-add-sourcehost rule6 --hostgroups=hostgrp6-2"
                rlRun "ipa hbacrule-show rule6 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user6 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule6)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user6 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user6 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user6 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule6 | grep -Ex '(Access granted: True|  matched: rule6)'"
                rlRun "ipa hbactest --user=$user6 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule6 | grep -Ex '(Access granted: False|  notmatched: rule6)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule6 | grep -Ex '(Access granted: False|  notmatched: rule6)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT --service=sshd  --user=$user6 --rule=rule6 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT --service=sshd  --user=$user6 --rule=rule6 --nodetail | grep -i \"matched: rule6\"" 1

        rlPhaseEnd
}

hbacsvc_client_006() {

        rlPhaseStartTest "ipa-hbacsvc-client1-006: user6 accessing hostgroup2 from hostgroup"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
                kdestroy
                rlRun "ssh_auth_failure user6 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_006() {

        rlPhaseStartTest "ipa-hbacsvc-client2-006: user6 accessing hostgroup2 from hostgroup"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user6"
		sleep 5
                kdestroy
                rlRun "ssh_auth_success user6 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}

hbacsvc_master_007() {
        rlPhaseStartTest "ipa-hbacsvc-007: $user7 part of rule7 is allowed to access hostgroup from hostgroup2 with hbacsvcgrp"

        for i in 2 7; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hostgroup-add hostgrp7 --desc=hostgrp7"
		rlRun "ipa hostgroup-add-member hostgrp7 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgrp7-2 --desc=hostgrp7-2"
		rlRun "ipa hostgroup-add-member hostgrp7-2 --hosts=$CLIENT2"


                rlRun "ipa hbacrule-add rule7"
                rlRun "ipa hbacrule-add-user rule7 --users=$user7"
                rlRun "ipa hbacrule-add-host rule7 --hostgroups=hostgrp7"
                rlRun "ipa hbacrule-add-sourcehost rule7 --hostgroups=hostgrp7-2"
		rlRun "ipa hbacrule-add-service rule7 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule7 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule7)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                #rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule7 | grep -Ex '(Access granted: True|  matched: rule7)'"
                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule7 | grep -Ex '(Access granted: False|  notmatched: rule7)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule7 | grep -Ex '(Access granted: False|  notmatched: rule7)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT --service=sshd  --user=$user7 --rule=rule7 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user7 --rule=rule7 --nodetail | grep -i \"matched: rule7\"" 1

        rlPhaseEnd
}

hbacsvc_client_007() {

	rlPhaseStartTest "ipa-hbacsvc-client1-007: user7 accessing hostgroup2 from hostgroup - hbacsvcgrp"

		#rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user7"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
                kdestroy
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user7 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user7 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_007() {

        rlPhaseStartTest "ipa-hbacsvc-client2-007: user7 accessing hostgroup2 from hostgroup - hbacsvcgrp (BZ 830347)"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ssh root@$CLIENT 'getent -s sss passwd user7'"
		sleep 5
                kdestroy
                rlRun "ssh_auth_success user7 testpw123@ipa.com $CLIENT"
				rlRun "ssh root@$CLIENT 'tail -20 /var/log/secure'"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi
		sleep 5
                rlRun "ssh_auth_success user7 testpw123@ipa.com $CLIENT"
				rlRun "ssh root@$CLIENT 'tail -20 /var/log/secure'"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi

        rlPhaseEnd

}


hbacsvc_master_007_1() {
        rlPhaseStartTest "ipa-hbacsvc-007_1: $user7 is removed from rule7 which was allowed to access hostgroup from hostgroup2 with hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-remove-user rule7 --users=$user7"
                rlRun "ipa hbacrule-show rule7 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule7)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user7 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user7 --srchost=hostgrp7-2 --host=hostgrp7 --service=sshd --rule=rule7 | grep -Ex '(Access granted: True|  matched: rule7)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user7 --srchost=hostgrp7-2 --host=$MASTER --service=sshd --rule=rule7 | grep -Ex '(Access granted: False|  notmatched: rule7)'"
                rlRun "ipa hbactest --user=$user2 --srchost=hostgrp7-2 --host=hostgrp7 --service=sshd --rule=rule7 | grep -Ex '(Access granted: False|  notmatched: rule7)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=hostgrp7-2 --service=sshd  --user=$user7 --rule=rule7 --nodetail | grep -i \"Access granted: True\"" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=hostgrp7-2 --service=sshd  --user=$user7 --rule=rule7 --nodetail | grep -i \"matched: rule7\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}


hbacsvc_client_007_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-007_1: user7 accessing hostgroup2 from hostgroup - hbacsvcgrp"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user7"
                kdestroy
                rlRun "ssh_auth_failure user7 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_007_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-007_1: user7 accessing hostgroup2 from hostgroup - hbacsvcgrp"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user7"
                kdestroy
                rlRun "ssh_auth_failure user7 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}

hbacsvc_master_008() {
        rlPhaseStartTest "ipa-hbacsvc-008: user8 from grp8 part of rule8 is allowed to access $CLIENT2 from $CLIENT"

        for i in 8; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa group-add group8 --desc=group8"
		rlRun "ipa group-add-member group8 --users=$user8"

                rlRun "ipa hbacrule-add rule8"
                rlRun "ipa hbacrule-add-user rule8 --groups=group8"
                rlRun "ipa hbacrule-add-host rule8 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-sourcehost rule8 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-service rule8 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule8 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule8)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                # rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 | grep -Ex '(Access granted: True|  matched: rule8)'"
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule8 | grep -Ex '(Access granted: False|  notmatched: rule8)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 | grep -Ex '(Access granted: False|  notmatched: rule8)'"
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 --nodetail | grep -i \"matched: rule8\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_008() {

        rlPhaseStartTest "ipa-hbacsvc-client1-008: user8 from grp8 part of rule8 is allowed to access $CLIENT2 from $CLIENT"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
		sleep 5
                kdestroy
                rlRun "ssh_auth_success user8 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_008() {

	rlPhaseStartTest "ipa-hbacsvc-client2-008: user8 from grp8 part of rule8 is allowed to access $CLIENT2 from $CLIENT"

#		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user8"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
                kdestroy
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT2"
		else
			rlRun "ssh_auth_success user8 testpw123@ipa.com $CLIENT2"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT2"

	rlPhaseEnd

}


hbacsvc_master_008_1() {
        rlPhaseStartTest "ipa-hbacsvc-008_1: grp8 removed from rule8 which was allowed to access $CLIENT2 from $CLIENT"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-remove-user rule8 --groups=group8"
                rlRun "ipa hbacrule-show rule8 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule8)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 | grep -Ex '(Access granted: True|  matched: rule8)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule8 | grep -Ex '(Access granted: False|  notmatched: rule8)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 | grep -Ex '(Access granted: False|  notmatched: rule8)'"
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 --nodetail | grep -i \"Access granted: True\"" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user8 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule8 --nodetail | grep -i \"matched: rule8\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_008_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-008_1: user8 from grp8 part of rule8 is allowed to access $CLIENT2 from $CLIENT"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
                kdestroy
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_008_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-008_1: user8 from grp8 part of rule8 is allowed to access $CLIENT2 from $CLIENT"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user8"
                kdestroy
                rlRun "ssh_auth_failure user8 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd

}



hbacsvc_master_009() {
        rlPhaseStartTest "ipa-hbacsvc-009: $user9 from grp9 part of rule9 is allowed to access $CLIENT2 from $CLIENT - hbacsvcgrp"

        for i in 9; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group9 --desc=group9"
                rlRun "ipa group-add-member group9 --users=$user9"

                rlRun "ipa hbacrule-add rule9"
                rlRun "ipa hbacrule-add-user rule9 --groups=group9"
                rlRun "ipa hbacrule-add-host rule9 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-sourcehost rule9 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-service rule9 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule9 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule9)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 | grep -Ex '(Access granted: True|  matched: rule9)'"
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule9 | grep -Ex '(Access granted: False|  notmatched: rule9)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 | grep -Ex '(Access granted: False|  notmatched: rule9)'"
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 --nodetail | grep -i \"matched: rule9\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_009() {

        rlPhaseStartTest "ipa-hbacsvc-client1-009: user9 from grp9 part of rule9 is allowed to access $CLIENT2 from $CLIENT"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user9"
		sleep 5
                kdestroy
                rlRun "ssh_auth_success user9 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_009() {

	rlPhaseStartTest "ipa-hbacsvc-client2-009: user9 from grp9 part of rule9 is allowed to access $CLIENT2 from $CLIENT"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user9"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT2"
		else
			rlRun "ssh_auth_success user9 testpw123@ipa.com $CLIENT2"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT2"

	rlPhaseEnd

}

hbacsvc_master_009_1() {
        rlPhaseStartTest "ipa-hbacsvc-009_1: grp9 removed from rule9 which was allowed to access $CLIENT2 from $CLIENT - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		# Already this has been added as member in hbacsvc_master_009
                # rlRun "ipa hbacrule-add-user rule9 --groups=group9"
                rlRun "ipa hbacrule-show rule9 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule9)'" 
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 | grep -Ex '(Access granted: True|  matched: rule9)'" 
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule9 | grep -Ex '(Access granted: False|  notmatched: rule9)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 | grep -Ex '(Access granted: False|  notmatched: rule9)'"
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 --nodetail | grep -i \"Access granted: True\"" 
                rlRun "ipa hbactest --user=$user9 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule9 --nodetail | grep -i \"matched: rule9\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_009_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-009_1: grp9 removed from rule9 which was allowed to access $CLIENT2 from $CLIENT"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user9"
                rlRun "ssh_auth_success user9 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_009_1() {

	rlPhaseStartTest "ipa-hbacsvc-client2-009_1: grp9 removed from rule9 which was allowed to access $CLIENT2 from $CLIENT"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user9"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user9 testpw123@ipa.com $CLIENT2"
		else
			rlRun "ssh_auth_success user9 testpw123@ipa.com $CLIENT2"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT2"

	rlPhaseEnd

}


hbacsvc_master_010() {
        rlPhaseStartTest "ipa-hbacsvc-010: $user10 from grp10 part of rule10 is allowed to access hostgrp from $CLIENT"

        for i in 10; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group10 --desc=group10"
                rlRun "ipa group-add-member group10 --users=$user10"
		rlRun "ipa hostgroup-add hostgroup10 --desc=hostgroup10"
		rlRun "ipa hostgroup-add-member hostgroup10 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule10"
                rlRun "ipa hbacrule-add-user rule10 --groups=group10"
                rlRun "ipa hbacrule-add-host rule10 --hostgroups=hostgroup10"
                rlRun "ipa hbacrule-add-sourcehost rule10 --hosts=$CLIENT"
		rlRun "ipa hbacrule-add-service rule10 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule10 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule10)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule10 | grep -Ex '(Access granted: True|  matched: rule10)'"
                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule10 | grep -Ex '(Access granted: False|  notmatched: rule10)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule10 | grep -Ex '(Access granted: False|  notmatched: rule10)'"
                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule10 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user10 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule10 --nodetail | grep -i \"matched: rule10\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_010() {

        rlPhaseStartTest "ipa-hbacsvc-client1-010: user10 from grp10 part of rule10 is allowed to access hostgrp from $CLIENT"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user10"
                rlRun "ssh_auth_success user10 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_010() {

	rlPhaseStartTest "ipa-hbacsvc-client2-010: user10 from grp10 part of rule10 is allowed to access hostgrp from $CLIENT"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user10"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user10 testpw123@ipa.com $CLIENT2"
		else
			rlRun "ssh_auth_success user10 testpw123@ipa.com $CLIENT2"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT2"

	rlPhaseEnd

}

hbacsvc_master_011() {
        rlPhaseStartTest "ipa-hbacsvc-011: $user11 from grp11 part of rule11 is allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

        for i in 11; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group11 --desc=group11"
                rlRun "ipa group-add-member group11 --users=$user11"
		rlRun "ipa hostgroup-add hostgroup11 --desc=hostgroup11"
		rlRun "ipa hostgroup-add-member hostgroup11 --hosts=$CLIENT"

                rlRun "ipa hbacrule-add rule11"
                rlRun "ipa hbacrule-add-user rule11 --groups=group11"
                rlRun "ipa hbacrule-add-host rule11 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-sourcehost rule11 --hostgroups=hostgroup11"
		rlRun "ipa hbacrule-add-service rule11 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule11 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule11)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule11 | grep -Ex '(Access granted: True|  matched: rule11)'"
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule11 | grep -Ex '(Access granted: False|  notmatched: rule11)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule11 | grep -Ex '(Access granted: False|  notmatched: rule11)'"
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule11 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule11 --nodetail | grep -i \"matched: rule11\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_011() {

        rlPhaseStartTest "ipa-hbacsvc-client1-011: user11 from grp11 part of rule11 is allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user11"
                rlRun "ssh_auth_success user11 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_011() {

	rlPhaseStartTest "ipa-hbacsvc-client2-011: user11 from grp11 part of rule11 is allowed to access hostgrp from $CLIENT"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user11"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user11 testpw123@ipa.com $CLIENT2"
		else
			rlRun "ssh_auth_success user11 testpw123@ipa.com $CLIENT2"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT2"

	rlPhaseEnd

}


hbacsvc_master_011_1() {
        rlPhaseStartTest "ipa-hbacsvc-011_1: sshd service group removed from rule11 which was allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-remove-service rule11 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule11 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule11)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule11 | grep -Ex '(Access granted: True|  matched: rule11)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule11 | grep -Ex '(Access granted: False|  notmatched: rule11)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule11 | grep -Ex '(Access granted: False|  notmatched: rule11)'"
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule11 --nodetail | grep -i \"Access granted: True\"" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user11 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule11 --nodetail | grep -i \"matched: rule11\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_011_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-011_1: sshd service group removed from rule11 which was allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user11"
                rlRun "ssh_auth_failure user11 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_011_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-011_1: sshd service group removed from rule11 which was allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user11"
                rlRun "ssh_auth_failure user11 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd

}


hbacsvc_master_012() {
        rlPhaseStartTest "ipa-hbacsvc-012: $user12 from grp12 part of rule12 is allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

        for i in 12; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group12 --desc=group12"
                rlRun "ipa group-add-member group12 --users=$user12"
		rlRun "ipa hostgroup-add hostgroup12 --desc=hostgroup12"
		rlRun "ipa hostgroup-add-member hostgroup12 --hosts=$CLIENT"

                rlRun "ipa hbacrule-add rule12"
                rlRun "ipa hbacrule-add-user rule12 --groups=group12"
                rlRun "ipa hbacrule-add-host rule12 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-sourcehost rule12 --hostgroups=hostgroup12"
		rlRun "ipa hbacsvcgroup-add sshd --desc=sshdgrp"
		rlRun "ipa hbacsvcgroup-add-member sshd --hbacsvc=sshd"
		rlRun "ipa hbacrule-add-service rule12 --hbacsvcgroup=sshd"
                rlRun "ipa hbacrule-show rule12 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule12)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule12 | grep -Ex '(Access granted: True|  matched: rule12)'"
                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule12 | grep -Ex '(Access granted: False|  notmatched: rule12)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule12 | grep -Ex '(Access granted: False|  notmatched: rule12)'"
                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule12 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user12 --srchost=$CLIENT --host=$CLIENT2 --service=sshd --rule=rule12 --nodetail | grep -i \"matched: rule12\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_012() {

        rlPhaseStartTest "ipa-hbacsvc-client1-012: user12 from grp12 part of rule12 is allowed to access $CLIENT2 from hostgrp - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user12"
                rlRun "ssh_auth_failure user12 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_success user12 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_012() {

        rlPhaseStartTest "ipa-hbacsvc-client2-012: user12 from grp12 part of rule12 is allowed to access hostgrp from $CLIENT"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user12"
                rlRun "ssh_auth_failure user12 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}


hbacsvc_master_013() {
        rlPhaseStartTest "ipa-hbacsvc-013: $user13 from grp13 part of rule13 is allowed to access hostgrp from hostgrp2"

        for i in 13; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group13 --desc=group13"
                rlRun "ipa group-add-member group13 --users=$user13"
		rlRun "ipa hostgroup-add hostgroup13 --desc=hostgroup13"
		rlRun "ipa hostgroup-add-member hostgroup13 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgroup13-2 --desc=hostgroup13-2"
		rlRun "ipa hostgroup-add-member hostgroup13-2 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule13"
                rlRun "ipa hbacrule-add-user rule13 --groups=group13"
                rlRun "ipa hbacrule-add-host rule13 --hostgroups=hostgroup13"
                rlRun "ipa hbacrule-add-sourcehost rule13 --hostgroups=hostgroup13-2"
		rlRun "ipa hbacrule-add-service rule13 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule13 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule13)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                # rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                # rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule13 | grep -Ex '(Access granted: True|  matched: rule13)'"
                rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule13 | grep -Ex '(Access granted: False|  notmatched: rule13)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule13 | grep -Ex '(Access granted: False|  notmatched: rule13)'"
                rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule13 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user13 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule13 --nodetail | grep -i \"matched: rule13\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_013() {

        rlPhaseStartTest "ipa-hbacsvc-client1-013: user13 from grp13 part of rule13 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user13"
                rlRun "ssh_auth_failure user13 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_013() {

        rlPhaseStartTest "ipa-hbacsvc-client2-013: user13 from grp13 part of rule13 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "ssh root@$CLIENT 'getent -s sss passwd user13'"
                rlRun "ssh_auth_success user13 testpw123@ipa.com $CLIENT"
				rlRun "tail -20 /var/log/secure"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi
		sleep 5
                rlRun "ssh_auth_success user13 testpw123@ipa.com $CLIENT"
				rlRun "tail -20 /var/log/secure"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi

        rlPhaseEnd

}



hbacsvc_master_014() {
        rlPhaseStartTest "ipa-hbacsvc-014: $user14 from grp14 part of rule14 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

        for i in 14; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group14 --desc=group14"
                rlRun "ipa group-add-member group14 --users=$user14"
		rlRun "ipa hostgroup-add hostgroup14 --desc=hostgroup14"
		rlRun "ipa hostgroup-add-member hostgroup14 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgroup14-2 --desc=hostgroup14-2"
		rlRun "ipa hostgroup-add-member hostgroup14-2 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule14"
                rlRun "ipa hbacrule-add-user rule14 --groups=group14"
                rlRun "ipa hbacrule-add-host rule14 --hostgroups=hostgroup14"
                rlRun "ipa hbacrule-add-sourcehost rule14 --hostgroups=hostgroup14-2"
		rlRun "ipa hbacrule-add-service rule14 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule14 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule14)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                # rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule14 | grep -Ex '(Access granted: True|  matched: rule14)'"
                rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule14 | grep -Ex '(Access granted: False|  notmatched: rule14)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule14 | grep -Ex '(Access granted: False|  notmatched: rule14)'"
                rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule14 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user14 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule14 --nodetail | grep -i \"matched: rule14\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_014() {

        rlPhaseStartTest "ipa-hbacsvc-client1-014: user14 from grp14 part of rule14 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user14"
                rlRun "ssh_auth_failure user14 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_014() {

        rlPhaseStartTest "ipa-hbacsvc-client2-014: user14 from grp14 part of rule14 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "ssh root@$CLIENT 'getent -s sss passwd user14'"
                rlRun "ssh_auth_success user14 testpw123@ipa.com $CLIENT"
				rlRun "ssh root@$CLIENT 'tail -20 /var/log/secure'"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi
		sleep 5
                rlRun "ssh_auth_success user14 testpw123@ipa.com $CLIENT"
				rlRun "ssh root@$CLIENT 'tail -20 /var/log/secure'"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi

        rlPhaseEnd

}


hbacsvc_master_015() {

	rlPhaseStartTest "ipa-hbacsvc-015: $user15 from nestgrp15 part of rule15 is allowed to access $CLIENT from $CLIENT2"

        for i in 15; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group15 --desc=group15"
                rlRun "ipa group-add group15-2 --desc=group15-2"
                rlRun "ipa group-add-member group15-2 --users=$user15"
		rlRun "ipa group-add-member group15 --groups=group15-2"

                rlRun "ipa hbacrule-add rule15"
                rlRun "ipa hbacrule-add-user rule15 --groups=group15"
                rlRun "ipa hbacrule-add-host rule15 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule15 --hosts=$CLIENT2"
		rlRun "ipa hbacrule-add-service rule15 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule15 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule15)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule15 | grep -Ex '(Access granted: True|  matched: rule15)'"
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule15 | grep -Ex '(Access granted: False|  notmatched: rule15)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd --rule=rule15 | grep -Ex '(Access granted: False|  notmatched: rule15)'"
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule15 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule15 --nodetail | grep -i \"matched: rule15\"" 1

        rlPhaseEnd
}

hbacsvc_client_015() {

	rlPhaseStartTest "ipa-hbacsvc-client1-015: user15 from grp15 part of rule15 is allowed to access hostgrp from hostgrp2"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user15"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user15 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user15 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_015() {

        rlPhaseStartTest "ipa-hbacsvc-client2-015: user15 from grp15 part of rule15 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user15"
                rlRun "ssh_auth_success user15 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}


hbacsvc_master_015_1() {

        rlPhaseStartTest "ipa-hbacsvc-015_1: $user15 removed from rule15 which was allowed to access $CLIENT from $CLIENT2"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-remove-user rule15 --groups=group15"
                rlRun "ipa hbacrule-show rule15 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule15)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule15 | grep -Ex '(Access granted: True|  matched: rule15)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule15 | grep -Ex '(Access granted: False|  notmatched: rule15)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd --rule=rule15 | grep -Ex '(Access granted: False|  notmatched: rule15)'"
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule15 --nodetail | grep -i \"Access granted: True\"" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user15 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule15 --nodetail | grep -i \"matched: rule15\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_015_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-015_1: user15 removed from rule15 which was allowed to access $CLIENT from $CLIENT2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user15"
                rlRun "ssh_auth_failure user15 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_015_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-015_1: user15 removed from rule15 which was allowed to access $CLIENT from $CLIENT2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user15"
                rlRun "ssh_auth_failure user15 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}



hbacsvc_master_016() {

	rlPhaseStartTest "ipa-hbacsvc-016: $user16 from nestgrp16 part of rule16 is allowed to access $CLIENT from $CLIENT2 - hbacsvcgroup"

        for i in 16; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group16 --desc=group16"
                rlRun "ipa group-add group16-2 --desc=group16-2"
                rlRun "ipa group-add-member group16-2 --users=$user16"
		rlRun "ipa group-add-member group16 --groups=group16-2"

                rlRun "ipa hbacrule-add rule16"
                rlRun "ipa hbacrule-add-user rule16 --groups=group16"
                rlRun "ipa hbacrule-add-host rule16 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule16 --hosts=$CLIENT2"
		rlRun "ipa hbacrule-add-service rule16 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule16 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule16)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule16 | grep -Ex '(Access granted: True|  matched: rule16)'"
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule16 | grep -Ex '(Access granted: False|  notmatched: rule16)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd --rule=rule16 | grep -Ex '(Access granted: False|  notmatched: rule16)'"
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule16 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule16 --nodetail | grep -i \"matched: rule16\"" 1

        rlPhaseEnd
}

hbacsvc_client_016() {

	rlPhaseStartTest "ipa-hbacsvc-client1-016: user16 from grp16 part of rule16 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "getent -s sss passwd user16"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user16 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user16 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_016() {

        rlPhaseStartTest "ipa-hbacsvc-client2-016: user16 from grp16 part of rule16 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user16"
                rlRun "ssh_auth_success user16 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}


hbacsvc_master_016_1() {

        rlPhaseStartTest "ipa-hbacsvc-016_1: $user16 removed from rule16 which was allowed to access $CLIENT from $CLIENT2 - hbacsvcgroup"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-remove-user rule16 --groups=group16"
                rlRun "ipa hbacrule-show rule16 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule16)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule16 | grep -Ex '(Access granted: True|  matched: rule16)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule16 | grep -Ex '(Access granted: False|  notmatched: rule16)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd --rule=rule16 | grep -Ex '(Access granted: False|  notmatched: rule16)'"
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule16 --nodetail | grep -i \"Access granted: True\"" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user16 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule16 --nodetail | grep -i \"matched: rule16\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_016_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-016_1: user16 removed from rule16 which was allowed to access $CLIENT from $CLIENT2 - hbacsvcgroup"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user16"
                rlRun "ssh_auth_failure user16 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_016_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-016_1: user16 removed from rule16 which was allowed to access $CLIENT from $CLIENT2 - hbacsvcgroup"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user16"
                rlRun "ssh_auth_failure user16 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}


hbacsvc_master_017() {

	rlPhaseStartTest "ipa-hbacsvc-017: $user17 from nestgrp17 part of rule17 is allowed to access host from hostgrp2"

        for i in 17; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group17 --desc=group17"
                rlRun "ipa group-add group17-2 --desc=group17-2"
                rlRun "ipa group-add-member group17-2 --users=$user17"
		rlRun "ipa group-add-member group17 --groups=group17-2"

		rlRun "ipa hostgroup-add hostgroup17 --desc=hostgroup17"
		rlRun "ipa hostgroup-add-member hostgroup17 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule17"
                rlRun "ipa hbacrule-add-user rule17 --groups=group17"
                rlRun "ipa hbacrule-add-host rule17 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule17 --hostgroups=hostgroup17"
		rlRun "ipa hbacrule-add-service rule17 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule17 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule17)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule17 | grep -Ex '(Access granted: True|  matched: rule17)'"
                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule17 | grep -Ex '(Access granted: False|  notmatched: rule17)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd --rule=rule17 | grep -Ex '(Access granted: False|  notmatched: rule17)'"
                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule17 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user17 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule17 --nodetail | grep -i \"matched: rule17\"" 1

        rlPhaseEnd
}

hbacsvc_client_017() {

        rlPhaseStartTest "ipa-hbacsvc-client1-017: user17 from grp17 part of rule17 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user17"
                rlRun "ssh_auth_failure user17 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_017() {

        rlPhaseStartTest "ipa-hbacsvc-client2-017: user17 from grp17 part of rule17 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user17"
                rlRun "ssh_auth_failure user17 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user17 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}


hbacsvc_master_018() {

	rlPhaseStartTest "ipa-hbacsvc-018: $user18 from nestgrp18 part of rule18 is allowed to access host from hostgrp2 - hbacsvcgrp"

        for i in 18; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group18 --desc=group18"
                rlRun "ipa group-add group18-2 --desc=group18-2"
                rlRun "ipa group-add-member group18-2 --users=$user18"
		rlRun "ipa group-add-member group18 --groups=group18-2"

		rlRun "ipa hostgroup-add hostgroup18 --desc=hostgroup18"
		rlRun "ipa hostgroup-add-member hostgroup18 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule18"
                rlRun "ipa hbacrule-add-user rule18 --groups=group18"
                rlRun "ipa hbacrule-add-host rule18 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule18 --hostgroups=hostgroup18"
		rlRun "ipa hbacrule-add-service rule18 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule18 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule18)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule18 | grep -Ex '(Access granted: True|  matched: rule18)'"
                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule18 | grep -Ex '(Access granted: False|  notmatched: rule18)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd --rule=rule18 | grep -Ex '(Access granted: False|  notmatched: rule18)'"
                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule18 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user18 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule18 --nodetail | grep -i \"matched: rule18\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_018() {

        rlPhaseStartTest "ipa-hbacsvc-client1-018: user18 from grp18 part of rule18 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user18"
                rlRun "ssh_auth_failure user18 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_018() {

        rlPhaseStartTest "ipa-hbacsvc-client2-018: user18 from grp18 part of rule18 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user18"
                rlRun "ssh_auth_failure user18 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user18 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}


hbacsvc_master_019() {

	rlPhaseStartTest "ipa-hbacsvc-019: $user19 from nestgrp19 part of rule19 is allowed to access hostgrp from hostgrp2"

        for i in 19; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group19 --desc=group19"
                rlRun "ipa group-add group19-2 --desc=group19-2"
                rlRun "ipa group-add-member group19-2 --users=$user19"
		rlRun "ipa group-add-member group19 --groups=group19-2"

		rlRun "ipa hostgroup-add hostgroup19 --desc=hostgroup19"
		rlRun "ipa hostgroup-add-member hostgroup19 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgroup19-2 --desc=hostgroup19-2"
		rlRun "ipa hostgroup-add-member hostgroup19-2 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule19"
                rlRun "ipa hbacrule-add-user rule19 --groups=group19-2"
                rlRun "ipa hbacrule-add-host rule19 --hostgroups=hostgroup19"
                rlRun "ipa hbacrule-add-sourcehost rule19 --hostgroups=hostgroup19-2"
		rlRun "ipa hbacrule-add-service rule19 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule19 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule19)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                # rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule19 | grep -Ex '(Access granted: True|  matched: rule19)'"
                rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule19 | grep -Ex '(Access granted: False|  notmatched: rule19)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule19 | grep -Ex '(Access granted: False|  notmatched: rule19)'"
                rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule19 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user19 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule19 --nodetail | grep -i \"matched: rule19\"" 1

        rlPhaseEnd
}

hbacsvc_client_019() {

        rlPhaseStartTest "ipa-hbacsvc-client1-019: user19 from grp19 part of rule19 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user19"
                rlRun "ssh_auth_failure user19 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_019() {

        rlPhaseStartTest "ipa-hbacsvc-client2-019: user19 from grp19 part of rule19 is allowed to access hostgrp from hostgrp2"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user19"
                rlRun "ssh_auth_failure user19 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user19 testpw123@ipa.com $CLIENT"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi

        rlPhaseEnd

}



hbacsvc_master_020() {

	rlPhaseStartTest "ipa-hbacsvc-020: $user20 from nestgrp20 part of rule20 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

        for i in 20; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group20 --desc=group20"
                rlRun "ipa group-add group20-2 --desc=group20-2"
                rlRun "ipa group-add-member group20-2 --users=$user20"
		rlRun "ipa group-add-member group20 --groups=group20-2"

		rlRun "ipa hostgroup-add hostgroup20 --desc=hostgroup20"
		rlRun "ipa hostgroup-add-member hostgroup20 --hosts=$CLIENT"
		rlRun "ipa hostgroup-add hostgroup20-2 --desc=hostgroup20-2"
		rlRun "ipa hostgroup-add-member hostgroup20-2 --hosts=$CLIENT2"

                rlRun "ipa hbacrule-add rule20"
                rlRun "ipa hbacrule-add-user rule20 --groups=group20-2"
                rlRun "ipa hbacrule-add-host rule20 --hostgroups=hostgroup20"
                rlRun "ipa hbacrule-add-sourcehost rule20 --hostgroups=hostgroup20-2"
		rlRun "ipa hbacrule-add-service rule20 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule20 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule20)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                # rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule20 | grep -Ex '(Access granted: True|  matched: rule20)'"
                rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule20 | grep -Ex '(Access granted: False|  notmatched: rule20)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule20 | grep -Ex '(Access granted: False|  notmatched: rule20)'"
                rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule20 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user20 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule20 --nodetail | grep -i \"matched: rule20\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_020() {

        rlPhaseStartTest "ipa-hbacsvc-client1-020: user20 from grp20 part of rule20 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user20"
                rlRun "ssh_auth_failure user20 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_020() {

        rlPhaseStartTest "ipa-hbacsvc-client2-020: user20 from grp20 part of rule20 is allowed to access hostgrp from hostgrp2 - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user20"
                rlRun "ssh_auth_failure user20 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user20 testpw123@ipa.com $CLIENT"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi

        rlPhaseEnd

}


hbacsvc_master_020_1() {

        rlPhaseStartTest "ipa-hbacsvc-020_1: hbac rule20 is removed."
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-del rule20"
                rlRun "ipa hbacrule-show rule20 --all" 2

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user20 --srchost=hostgroup20-2 --host=hostgroup20 --service=sshd | grep -Ex '(Access granted: True|  matched: rule20)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user20 --srchost=hostgroup20-2 --host=hostgroup20 --service=sshd --rule=rule20 | grep -Ex '(Access granted: True|  matched: rule20)'" 1 "hbactest fails with error code 1"
                rlRun "ipa hbactest --user=$user20 --srchost=hostgroup20-2 --host=hostgroup20 --service=sshd --rule=rule20 --nodetail | grep -i \"Access granted: True\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_020_1() {

        rlPhaseStartTest "ipa-hbacsvc-client1-020_1: hbac rule20 is removed."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user20"
                rlRun "ssh_auth_failure user20 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_client2_020_1() {

        rlPhaseStartTest "ipa-hbacsvc-client2-020_1: hbac rule20 is removed."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user20"
                rlRun "ssh_auth_failure user20 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd

}

hbacsvc_master_021() {

	rlPhaseStartTest "ipa-hbacsvc-021: $user21 part of rule21 is allowed to access $CLIENT from EXT_HOST"

        for i in 21; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add rule21"
                rlRun "ipa hbacrule-add-user rule21 --users=$user21"
                rlRun "ipa hbacrule-add-host rule21 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule21 --hosts=externalhost.randomhost.com"
		rlRun "ipa hbacrule-add-service rule21 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule21 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user21 --srchost=externalhost.randomhost.com --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule21)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost.randomhost.com --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user21 --srchost=externalhost.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user21 --srchost=$CLIENT --host=externalhost.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user21 --srchost=externalhost.randomhost.com --host=$CLIENT --service=sshd --rule=rule21 | grep -Ex '(Access granted: True|  matched: rule21)'"
                rlRun "ipa hbactest --user=$user21 --srchost=externalhost.randomhost.com --host=$MASTER --service=sshd --rule=rule21 | grep -Ex '(Access granted: False|  notmatched: rule21)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule21 | grep -Ex '(Access granted: False|  notmatched: rule21)'"
                rlRun "ipa hbactest --user=$user21 --srchost=externalhost.randomhost.com --host=$CLIENT --service=sshd --rule=rule21 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user21 --srchost=externalhost.randomhost.com --host=$CLIENT --service=sshd --rule=rule21 --nodetail | grep -i \"matched: rule21\"" 1

        rlPhaseEnd
}

hbacsvc_master_022() {

	rlPhaseStartTest "ipa-hbacsvc-022: $user22 part of rule22 is allowed to access EXT_HOST from EXT_HOST2 - hbacsvcgroup"

        for i in 22; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add rule22"
                rlRun "ipa hbacrule-add-user rule22 --users=$user22"
                rlRun "ipa hbacrule-add-host rule22 --hosts=externalhost.randomhost.com"
                rlRun "ipa hbacrule-add-sourcehost rule22 --hosts=externalhost2.randomhost.com"
		rlRun "ipa hbacrule-add-service rule22 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule22 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user22 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -Ex '(Access granted: True|  matched: rule22)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user22 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user22 --srchost=externalhost.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user22 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule22 | grep -Ex '(Access granted: True|  matched: rule22)'"
                rlRun "ipa hbactest --user=$user22 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule22 | grep -Ex '(Access granted: False|  notmatched: rule22)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd --rule=rule22 | grep -Ex '(Access granted: False|  notmatched: rule22)'"
                rlRun "ipa hbactest --user=$user22 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule22 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user22 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule22 --nodetail | grep -i \"matched: rule22\"" 1

        rlPhaseEnd
}


hbacsvc_master_023() {

	rlPhaseStartTest "ipa-hbacsvc-023: $user23 part of group23 is allowed to access $CLIENT2 from EXT_HOST2"

        for i in 23; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group23 --desc=group23"
                rlRun "ipa group-add-member group23 --users=$user23"

                rlRun "ipa hbacrule-add rule23"
                rlRun "ipa hbacrule-add-user rule23 --users=$user23"
                rlRun "ipa hbacrule-add-host rule23 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-sourcehost rule23 --hosts=externalhost2.randomhost.com"
		rlRun "ipa hbacrule-add-service rule23 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule23 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user23 --srchost=externalhost2.randomhost.com --host=$CLIENT2 --service=sshd | grep -Ex '(Access granted: True|  matched: rule23)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user23 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user23 --srchost=$CLIENT2 --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user23 --srchost=externalhost2.randomhost.com --host=$CLIENT2 --service=sshd --rule=rule23 | grep -Ex '(Access granted: True|  matched: rule23)'"
                rlRun "ipa hbactest --user=$user23 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule23 | grep -Ex '(Access granted: False|  notmatched: rule23)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd --rule=rule23 | grep -Ex '(Access granted: False|  notmatched: rule23)'"
                rlRun "ipa hbactest --user=$user23 --srchost=externalhost2.randomhost.com --host=$CLIENT2 --service=sshd --rule=rule23 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user23 --srchost=externalhost2.randomhost.com --host=$CLIENT2 --service=sshd --rule=rule23 --nodetail | grep -i \"matched: rule23\"" 1

        rlPhaseEnd
}


hbacsvc_master_024() {
	
	rlPhaseStartTest "ipa-hbacsvc-024: $user24 part of group24 is allowed to access EXT_HOST from EXT_HOST2 - hbacsvcgroup"

        for i in 24; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group24 --desc=group24"
                rlRun "ipa group-add-member group24 --users=$user24"

                rlRun "ipa hbacrule-add rule24"
                rlRun "ipa hbacrule-add-user rule24 --users=$user24"
                rlRun "ipa hbacrule-add-host rule24 --hosts=externalhost.randomhost.com"
                rlRun "ipa hbacrule-add-sourcehost rule24 --hosts=externalhost2.randomhost.com"
		rlRun "ipa hbacrule-add-service rule24 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule24 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user24 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -Ex '(Access granted: True|  matched: rule24)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user24 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user24 --srchost=externalhost.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user24 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule24 | grep -Ex '(Access granted: True|  matched: rule24)'"
                rlRun "ipa hbactest --user=$user24 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule24 | grep -Ex '(Access granted: False|  notmatched: rule24)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd --rule=rule24 | grep -Ex '(Access granted: False|  notmatched: rule24)'"
                rlRun "ipa hbactest --user=$user24 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule24 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user24 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule24 --nodetail | grep -i \"matched: rule24\"" 1

        rlPhaseEnd
}


hbacsvc_master_025() {

	rlPhaseStartTest "ipa-hbacsvc-025: $user25 part of group25 is allowed to access $CLIENT from EXT_HOST2"

        for i in 25; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group25 --desc=group25"
                rlRun "ipa group-add group25-2 --desc=group25-2"
                rlRun "ipa group-add-member group25 --users=user25"
                rlRun "ipa group-add-member group25-2 --groups=group25"

                rlRun "ipa hbacrule-add rule25"
                rlRun "ipa hbacrule-add-user rule25 --users=user25"
                rlRun "ipa hbacrule-add-host rule25 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule25 --hosts=externalhost2.randomhost.com"
		rlRun "ipa hbacrule-add-service rule25 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule25 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user25 --srchost=externalhost2.randomhost.com --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule25)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user25 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user25 --srchost=$CLIENT --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user25 --srchost=externalhost2.randomhost.com --host=$CLIENT --service=sshd --rule=rule25 | grep -Ex '(Access granted: True|  matched: rule25)'"
                rlRun "ipa hbactest --user=$user25 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule25 | grep -Ex '(Access granted: False|  notmatched: rule25)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd --rule=rule25 | grep -Ex '(Access granted: False|  notmatched: rule25)'"
                rlRun "ipa hbactest --user=$user25 --srchost=externalhost2.randomhost.com --host=$CLIENT --service=sshd --rule=rule25 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user25 --srchost=externalhost2.randomhost.com --host=$CLIENT --service=sshd --rule=rule25 --nodetail | grep -i \"matched: rule25\"" 1

        rlPhaseEnd
}


hbacsvc_master_026() {

	rlPhaseStartTest "ipa-hbacsvc-026: $user26 part of group26 is allowed to access EXT_HOST from EXT_HOST2 - hbacsvcgroup"

        for i in 26; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa group-add group26 --desc=group26"
                rlRun "ipa group-add group26-2 --desc=group26-2"
                rlRun "ipa group-add-member group26 --user=user26"
                rlRun "ipa group-add-member group26-2 --groups=group26"

                rlRun "ipa hbacrule-add rule26"
                rlRun "ipa hbacrule-add-user rule26 --users=$user26"
                rlRun "ipa hbacrule-add-host rule26 --hosts=externalhost.randomhost.com"
                rlRun "ipa hbacrule-add-sourcehost rule26 --hosts=externalhost2.randomhost.com"
		rlRun "ipa hbacrule-add-service rule26 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule26 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user26 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -Ex '(Access granted: True|  matched: rule26)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user26 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user26 --srchost=externalhost.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user26 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule26 | grep -Ex '(Access granted: True|  matched: rule26)'"
                rlRun "ipa hbactest --user=$user26 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule26 | grep -Ex '(Access granted: False|  notmatched: rule26)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost2.randomhost.com --host=externalhost2.randomhost.com --service=sshd --rule=rule26 | grep -Ex '(Access granted: False|  notmatched: rule26)'"
                rlRun "ipa hbactest --user=$user26 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule26 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user26 --srchost=externalhost2.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule26 --nodetail | grep -i \"matched: rule26\"" 1

        rlPhaseEnd
}


hbacsvc_master_027() {
        rlPhaseStartTest "ipa-hbacsvc-027: $user27 part of rule27 is allowed to access $CLIENT from $CLIENT2 with empty hbacsvcgrp"

        for i in 27; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hbacsvcgroup-add empty --desc=empty"
                rlRun "ipa hbacrule-add rule27"
                rlRun "ipa hbacrule-add-user rule27 --users=$user27"
                rlRun "ipa hbacrule-add-host rule27 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule27 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-service rule27 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-service rule27 --hbacsvcgroup=empty"
                rlRun "ipa hbacrule-show rule27 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user27 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule27)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user27 --srchost=hostgrp6-1 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user27 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user27 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule27 | grep -Ex '(Access granted: True|  matched: rule27)'"
                rlRun "ipa hbactest --user=$user27 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule27 | grep -Ex '(Access granted: False|  notmatched: rule27)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule27 | grep -Ex '(Access granted: False|  notmatched: rule27)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user27 --rule=rule27 --nodetail | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user27 --rule=rule27 --nodetail | grep -i \"matched: rule27\"" 1

        rlPhaseEnd
}

hbacsvc_client_027() {

	rlPhaseStartTest "ipa-hbacsvc-client1-027: user27 accessing hostgroup2 from hostgroup - hbacsvcgrp"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
		rlRun "getent -s sss passwd user27"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user27 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user27 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_027() {

        rlPhaseStartTest "ipa-hbacsvc-client2-027: user27 accessing hostgroup2 from hostgroup - hbacsvcgrp"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user27"
                rlRun "ssh_auth_success user27 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}

hbacsvc_master_028() {
        rlPhaseStartTest "ipa-hbacsvc-028: $user28 part of rule28 is allowed to access $CLIENT from $CLIENT2 with incorrect hbacsvc"

        for i in 28; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hbacsvc-add sshdtest"
                rlRun "ipa hbacrule-add rule28"
                rlRun "ipa hbacrule-add-user rule28 --users=$user28"
                rlRun "ipa hbacrule-add-host rule28 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule28 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-service rule28 --hbacsvcs=sshdtest"
                rlRun "ipa hbacrule-add-service rule28 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule28 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user28 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule28)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user28 --srchost=hostgrp6-1 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user28 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user28 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule28 | grep -Ex '(Access granted: True|  matched: rule28)'"
                rlRun "ipa hbactest --user=$user28 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule28 | grep -Ex '(Access granted: False|  notmatched: rule28)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule28 | grep -Ex '(Access granted: False|  notmatched: rule28)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user28 --rule=rule28 --nodetail | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user28 --rule=rule28 --nodetail | grep -i \"matched: rule28\"" 1

        rlPhaseEnd
}

hbacsvc_client_028() {

	rlPhaseStartTest "ipa-hbacsvc-client1-028: user28 part of rule28 is allowed to access $CLIENT from $CLIENT2 with incorrect hbacsvc"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
		rlRun "getent -s sss passwd user28"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user28 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user28 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_028() {

        rlPhaseStartTest "ipa-hbacsvc-client2-028: user28 part of rule28 is allowed to access $CLIENT from $CLIENT2 with incorrect hbacsvc"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "ssh root@$CLIENT 'getent -s sss passwd user28'"
                rlRun "ssh_auth_success user28 testpw123@ipa.com $CLIENT"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi
		sleep 5
                rlRun "ssh_auth_success user28 testpw123@ipa.com $CLIENT"
				if [ $? -gt 0 ]; then
					DATE=$(date +%Y%m%d-%H%M%S)
					sftp root@$CLIENT:/var/log/sssd/sssd_$DOMAIN.log /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					rhts-submit-log -l /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE
					if [ $(grep "Paged Results Search already in progress on this connection" /var/tmp/sssd_$DOMAIN.log.$CLIENT.$DATE |wc -l) -gt 0 ]; then
						rlFail "Found BZ 830347...389 DS does not support multiple paging controls on a single connection"
					fi
				fi

        rlPhaseEnd

}


hbacsvc_master_029() {
        rlPhaseStartTest "ipa-hbacsvc-029: $user29 part of rule29 is allowed to access $CLIENT from $CLIENT2 with empty group"

        for i in 29; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		ipa hbacsvcgroup-show empty
		if [ $? -eq 0 ] ; then
			rlRun "ipa hbacsvcgroup-del empty"
		fi
		rlRun "ipa group-add emptygroup --desc=emptygroup"
		rlRun "ipa hbacsvcgroup-add empty --desc=emptygroup"
                rlRun "ipa hbacrule-add rule29"
                rlRun "ipa hbacrule-add-user rule29 --users=$user29"
                rlRun "ipa hbacrule-add-user rule29 --groups=emptygroup"
                rlRun "ipa hbacrule-add-host rule29 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost rule29 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-service rule29 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-service rule29 --hbacsvcgroup=empty"
                rlRun "ipa hbacrule-show rule29 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user29 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule29)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user29 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user29 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user29 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule29 | grep -Ex '(Access granted: True|  matched: rule29)'"
                rlRun "ipa hbactest --user=$user29 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule29 | grep -Ex '(Access granted: False|  notmatched: rule29)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule29 | grep -Ex '(Access granted: False|  notmatched: rule29)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user29 --rule=rule29 --nodetail | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user29 --rule=rule29 --nodetail | grep -i \"matched: rule29\"" 1 "hbactest fails with error code 1"

        rlPhaseEnd
}

hbacsvc_client_029() {

	rlPhaseStartTest "ipa-hbacsvc-client1-029: user29 part of rule29 is allowed to access $CLIENT from $CLIENT2 with empty group"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
		rlRun "getent -s sss passwd user29"
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user29 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user29 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_029() {

        rlPhaseStartTest "ipa-hbacsvc-client2-029: user29 part of rule29 is allowed to access $CLIENT from $CLIENT2 with empty group"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user29"
                rlRun "ssh_auth_success user29 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}

hbacsvc_master_030() {
        rlPhaseStartTest "ipa-hbacsvc-030: $user30 part of rule30 is allowed to access $CLIENT from $CLIENT2 with empty netgroup"

        for i in 30; do
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "create_ipauser user$i user$i user$i $userpw"
                sleep 5
                rlRun "export user$i=user$i"
        done

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

		rlRun "ipa hostgroup-add emptyhostgroup --desc=emptyhostgroup"
		ipa group-show emptygroup
		if [ $? -eq 0 ] ; then
			rlRun "ipa group-del emptygroup"
		fi
		rlRun "ipa group-add emptygroup --desc=emptygroup"
		ipa hbacsvcgroup-show empty
		if [ $? -eq 0 ] ; then
			rlRun "ipa hbacsvcgroup-del empty"
		fi
		rlRun "ipa hbacsvcgroup-add empty --desc=emptygroup"
                rlRun "ipa hbacrule-add rule30"
                rlRun "ipa hbacrule-add-user rule30 --users=$user30"
                rlRun "ipa hbacrule-add-user rule30 --groups=emptygroup"
                rlRun "ipa hbacrule-add-host rule30 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-host rule30 --hostgroups=emptyhostgroup"
                rlRun "ipa hbacrule-add-sourcehost rule30 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-service rule30 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-add-service rule30 --hbacsvcgroup=empty"
                rlRun "ipa hbacrule-show rule30 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user30 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: rule30)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user30 --srchost=hostgrp6-1 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user30 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user30 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule30 | grep -Ex '(Access granted: True|  matched: rule30)'"
                rlRun "ipa hbactest --user=$user30 --srchost=$CLIENT2 --host=$MASTER --service=sshd --rule=rule30 | grep -Ex '(Access granted: False|  notmatched: rule30)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT2 --host=$CLIENT --service=sshd --rule=rule30 | grep -Ex '(Access granted: False|  notmatched: rule30)'"
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user30 --rule=rule30 --nodetail | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --srchost=$CLIENT2 --host=$CLIENT2 --service=sshd  --user=$user30 --rule=rule30 --nodetail | grep -i \"notmatched: rule30\"" 1

        rlPhaseEnd
}

hbacsvc_client_030() {

	rlPhaseStartTest "ipa-hbacsvc-client1-030: user30 part of rule30 is allowed to access $CLIENT from $CLIENT2 with empty netgroup"

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
		rlRun "getent -s sss passwd user30"
		# Source host validation has been depricated which caused the following test to fail, hence updating
		# This if-statement accounts for lack of source host validation in RHEL6.3 and later.  
		# RHEL5 though still appears to have source host validation and needs the failure check here.
		# RHEL5.9 is getting source host validation disabled also so changing the test
		SRCHOSTENABLED=$(man sssd-ipa|cat|col -bx | grep "ipa_hbac_support_srchost.*(boolean)"|wc -l)
		if [ $SRCHOSTENABLED -eq 0 ]; then
			rlRun "ssh_auth_failure user30 testpw123@ipa.com $CLIENT"
		else
			rlRun "ssh_auth_success user30 testpw123@ipa.com $CLIENT"
		fi
		rlRun "ssh_auth_failure user2 testpw123@ipa.com $CLIENT"

	rlPhaseEnd
}

hbacsvc_client2_030() {

        rlPhaseStartTest "ipa-hbacsvc-client2-030: user30 part of rule30 is allowed to access $CLIENT from $CLIENT2 with empty netgroup"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user30"
                rlRun "ssh_auth_success user30 testpw123@ipa.com $CLIENT"

        rlPhaseEnd

}

hbacsvc_master_031() {

                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user31 user31 user31 $userpw
                sleep 5
                export user31=user31

        rlPhaseStartTest "ipa-hbacsvc-031: $user31 part of ÃŒ (UTF-8) is allowed to access $CLIENT from $CLIENT - SSHD Service"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-enable allow_all"
                kdestroy
                rlRun "ssh_auth_success $user31 testpw123@ipa.com $MASTER"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add ÃŒ"
                rlRun "ipa hbacrule-add-user ÃŒ --users=$user31"
                rlRun "ipa hbacrule-add-host ÃŒ --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost ÃŒ --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-service ÃŒ --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show ÃŒ --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user31 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: ÃŒ)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
		# Source host validation has been depricated which caused the following test to fail, hence commenting it out.
                # rlRun "ipa hbactest --user=$user31 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user31 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user31 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=ÃŒ | grep -Ex '(Access granted: True|  matched: ÃŒ)'"
		# output has changed, tested manually. Hence update the following as appropriate.
                rlRun "ipa hbactest --user=$user31 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule2 | grep -i \"Unresolved rules in --rules\""
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=ÃŒ | grep -Ex '(Access granted: False|  notmatched: rule1)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user31 --rule=ÃŒ --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user31 --rule=ÃŒ --nodetail | grep -i \"matched: ÃŒ\"" 1

        rlPhaseEnd
}


hbacsvc_client_031() {

        rlPhaseStartTest "ipa-hbacsvc-client1-031: $user31 accessing $CLIENT from $CLIENT using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user31"
                sleep 5
                rlRun "ssh_auth_success user31 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_031() {

        rlPhaseStartTest "ipa-hbacsvc-client2-031: $user31 accessing $CLIENT from $CLIENT2 using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user31"
                rlRun "ssh_auth_failure user31 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}


hbacsvc_master_032() {

# Unable to add UTF-8 user, hence commenting this test in runtest.sh
#[root@bumblebee ~]# ipa user-add userÃŒ
#First name: userÃŒ
#Last name: userÃŒ
#ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $


                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser userÃŒ userÃŒ userÃŒ $userpw
                sleep 5
                export user32=userÃŒ

        rlPhaseStartTest "ipa-hbacsvc-032: $user32 part of ÃŒÃŒ (UTF-8) is allowed to access $CLIENT from $CLIENT - SSHD Service"

                kdestroy
                rlRun "ssh_auth_success $user32 testpw123@ipa.com $MASTER"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add ÃŒÃŒ"
                rlRun "ipa hbacrule-add-user ÃŒÃŒ --users=$user32"
                rlRun "ipa hbacrule-add-host ÃŒÃŒ --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-sourcehost ÃŒÃŒ --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-service ÃŒÃŒ --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show ÃŒÃŒ --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user32 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -Ex '(Access granted: True|  matched: ÃŒÃŒ)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user32 --srchost=$CLIENT2 --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user32 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user32 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=ÃŒÃŒ | grep -Ex '(Access granted: True|  matched: ÃŒÃŒ)'"
                rlRun "ipa hbactest --user=$user32 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=rule2 | grep -Ex '(Unresolved rules in --rules|error: rule2)'"
                rlRun "ipa hbactest --user=$user2 --srchost=$CLIENT --host=$CLIENT --service=sshd --rule=ÃŒÃŒ | grep -Ex '(Access granted: False|  notmatched: rule1)'"
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user32 --rule=ÃŒÃŒ --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --srchost=$CLIENT --host=$CLIENT --service=sshd  --user=$user32 --rule=ÃŒÃŒ --nodetail | grep -i \"matched: ÃŒÃŒ\"" 1

	# Cleanup
		rlRun "ipa hbacrule-del ÃŒÃŒ"
        rlPhaseEnd
}


hbacsvc_client_032() {

        rlPhaseStartTest "ipa-hbacsvc-client1-032: $user32 accessing $CLIENT from $CLIENT using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user32"
                sleep 5
                rlRun "ssh_auth_success $user32 testpw123@ipa.com $CLIENT"

        rlPhaseEnd
}

hbacsvc_client2_032() {

        rlPhaseStartTest "ipa-hbacsvc-client2-032: $user32 accessing $CLIENT from $CLIENT2 using SSHD service."

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd $user32"
                rlRun "ssh_auth_failure $user32 testpw123@ipa.com $CLIENT2"

        rlPhaseEnd
}

hbacsvc_master_033() {

               # Cleanup
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		for i in {6..19}; do
			rlRun "ipa hbacrule-del rule$i"
	        done
		for i in {27..30}; do
			rlRun "ipa hbacrule-del rule$i"
	        done
        	rlRun "ipa hbacrule-del rule21"
        	rlRun "ipa hbacrule-del rule23"
        	rlRun "ipa hbacrule-del rule25"
        	rlRun "ipa hbacrule-del ÃŒ"

                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user33 user33 user33 $userpw
                create_ipauser user34 user34 user34 $userpw
                sleep 5
                export user33=user33
                export user34=user34

        rlPhaseStartTest "ipa-hbacsvc-033: Offline client caching for enabled default HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-enable allow_all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user33 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user34 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user33 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user34 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user33 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user34 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: True\""
        rlPhaseEnd
}

hbacsvc_master_033_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {33..34}; do
                rlRun "ipa user-del user$i"
        done
}

hbacsvc_client_033() {

        rlPhaseStartTest "ipa-hbacsvc-client1-033: Offline client caching for enabled default HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user33"
                rlRun "getent -s sss passwd user34"
                sleep 5
                rlRun "ssh_auth_success user33 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $MASTER"

                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
                sleep 10

                rlRun "ssh_auth_success user33 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_success user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $MASTER"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

hbacsvc_client2_033() {

        rlPhaseStartTest "ipa-hbacsvc-client2-033: Offline client caching for enabled default HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user33"
                rlRun "getent -s sss passwd user34"
                sleep 5
                rlRun "ssh_auth_success user33 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_success user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $MASTER"

                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
                sleep 10

                rlRun "ssh_auth_success user33 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_success user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_success user34 testpw123@ipa.com $MASTER"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

hbacsvc_master_034() {

                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user33 user33 user33 $userpw
                create_ipauser user34 user34 user34 $userpw
                sleep 5
                export user33=user33
                export user34=user34

        rlPhaseStartTest "ipa-hbacsvc-034: Offline client caching for disabled default HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-disable allow_all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user33 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user34 --srchost=$CLIENT --host=$CLIENT --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user33 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user34 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user33 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user34 --srchost=$CLIENT --host=$MASTER --service=sshd | grep -i \"Access granted: False\""

        rlPhaseEnd
}

hbacsvc_master_034_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {33..34}; do
                rlRun "ipa user-del user$i"
        done
	rlRun "ipa hbacrule-enable allow_all"
}

hbacsvc_client_034() {

        rlPhaseStartTest "ipa-hbacsvc-client1-034: Offline client caching for disabled default HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user33"
                rlRun "getent -s sss passwd user34"
                sleep 5
                rlRun "ssh_auth_failure user33 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $MASTER"

                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
                sleep 10

                rlRun "ssh_auth_failure user33 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $MASTER"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

hbacsvc_client2_034() {

        rlPhaseStartTest "ipa-hbacsvc-client2-034: Offline client caching for disabled default HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user33"
                rlRun "getent -s sss passwd user34"
                sleep 5
                rlRun "ssh_auth_failure user33 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $MASTER"

                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
                sleep 10

                rlRun "ssh_auth_failure user33 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $CLIENT"
                rlRun "ssh_auth_failure user33 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_failure user34 testpw123@ipa.com $MASTER"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

hbacsvc_master_035() {

                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user35 user35 user35 $userpw
                create_ipauser user36 user36 user36 $userpw
                sleep 5
                export user35=user35
                export user36=user36

        rlPhaseStartTest "ipa-hbacsvc-035: Offline client caching for custom HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add rule35"
                rlRun "ipa hbacrule-add-user rule35 --users=$user35"
                rlRun "ipa hbacrule-add-host rule35 --hosts=$CLIENT2"
                rlRun "ipa hbacrule-add-service rule35 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule35 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user35 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user36 --srchost=$CLIENT --host=$CLIENT2 --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user35 --srchost=$CLIENT --host=$CLIENT2 --service=vsftpd | grep -i \"Access granted: False\""
        rlPhaseEnd
}

hbacsvc_master_035_cleanup() {
        # Cleanup
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        for i in {35..36}; do
                rlRun "ipa user-del user$i"
        done

        rlRun "ipa hbacrule-del rule35"
	rlRun "ipa hbacrule-enable allow_all"
}

hbacsvc_client_035() {

        rlPhaseStartTest "ipa-hbacsvc-client1-035: Offline client caching for custom HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user35"
                rlRun "getent -s sss passwd user36"
                sleep 5
                rlRun "ssh_auth_success user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user36 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user35 testpw123@ipa.com $MASTER"


                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
                sleep 10

                rlRun "ssh_auth_success user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user36 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user35 testpw123@ipa.com $MASTER"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

hbacsvc_client2_035() {

        rlPhaseStartTest "ipa-hbacsvc-client2-035: Offline client caching for custom HBAC rule"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                rlRun "getent -s sss passwd user35"
                rlRun "getent -s sss passwd user36"
                sleep 5

                rlRun "ssh_auth_success user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user36 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user35 testpw123@ipa.com $MASTER"

                #Stoping ipa sevice on $MASTER
                rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
                sleep 10

                rlRun "ssh_auth_success user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user36 testpw123@ipa.com $CLIENT2"
                rlRun "ftp_auth_failure $user35 testpw123@ipa.com $CLIENT2"
                rlRun "ssh_auth_failure user35 testpw123@ipa.com $MASTER"

                #Starting ipa sevice on $MASTER
                rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
                rlRun "chmod +x $TmpDir/local.sh"
                rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"

        rlPhaseEnd
}

hbacsvc_master_bug736314() {

        rlPhaseStartTest "ipa-hbacsvc-bug736314: user736314 part of rule736314 is allowed to access $MASTER from $CLIENT"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		user736314="user736314"
		rlRun "create_ipauser $user736314 $user736314 $user736314 $userpw"
                sleep 5
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add rule736314"
                rlRun "ipa hbacrule-add-user rule736314 --users=$user736314"
                rlRun "ipa hbacrule-add-host rule736314 --hosts=$MASTER"
                rlRun "ipa hbacrule-add-sourcehost rule736314 --hosts=$CLIENT,externalhost.randomhost.com,externalhost2.randomhost.com"
                rlRun "ipa hbacrule-add-service rule736314 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule736314 --all"

        # ipa hbactest:

                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost.randomhost.com --host=$MASTER --service=sshd | grep -Ex '(Access granted: True|  matched: rule736314)'"
                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd | grep -Ex '(Access granted: True|  matched: rule736314)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost.randomhost.com --host=$MASTER --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost.randomhost.com --host=externalhost2.randomhost.com --service=sshd | grep -i \"Access granted: False\""
                rlRun "ipa hbactest --user=$user736314 --srchost=$CLIENT --host=externalhost.randomhost.com --service=sshd | grep -i \"Access granted: False\""

                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost.randomhost.com --host=$MASTER --service=sshd --rule=rule736314 | grep -Ex '(Access granted: True|  matched: rule736314)'"
                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule736314 | grep -Ex '(Access granted: True|  matched: rule736314)'"
                rlRun "ipa hbactest --user=$user2 --srchost=externalhost.randomhost.com --host=externalhost.randomhost.com --service=sshd --rule=rule736314 | grep -Ex '(Access granted: False|  notmatched: rule736314)'"
                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost.randomhost.com --host=$MASTER --service=sshd --rule=rule736314 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost2.randomhost.com --host=$MASTER --service=sshd --rule=rule736314 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user736314 --srchost=$CLIENT --host=$MASTER --service=sshd --rule=rule736314 --nodetail | grep -i \"Access granted: True\""
                rlRun "ipa hbactest --user=$user736314 --srchost=externalhost.randomhost.com --host=$MASTER --service=sshd --rule=rule736314 --nodetail | grep -i \"matched: rule736314\"" 1


        rlPhaseEnd
}


hbacsvc_master_bug736314_cleanup() {
        # Cleanup
		rlRun "ipa hbacrule-del rule736314"
}


hbacsvc_client_bug736314() {

        rlPhaseStartTest "ipa-hbacsvc-client1-bug736314: user736314 part of rule736314 is allowed to access $MASTER from $CLIENT"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user736314"
                kdestroy
                rlRun "ssh_auth_success user736314 testpw123@ipa.com $MASTER"

        rlPhaseEnd
}

hbacsvc_client2_bug736314() {

        rlPhaseStartTest "ipa-hbacsvc-client2-bug736314: user736314 part of rule736314 is allowed to access $MASTER from $CLIENT"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		sleep 5
                rlRun "getent -s sss passwd user736314"
                kdestroy
                rlRun "ssh_auth_success user736314 testpw123@ipa.com $MASTER"
                rlRun "ssh_auth_failure user2 testpw123@ipa.com $MASTER"

        rlPhaseEnd

}


hbacsvc_master_bug782927() {

                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user782927 user782927 user782927 $userpw
                sleep 5
                export user782927=user782927

        rlPhaseStartTest "ipa-hbacsvc-782927: Test --sizelimit option to hbactest"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		for i in {1000..1010}; do ipa hbacrule-add $i; done
		rlRun "ipa config-mod --searchrecordslimit=5"
		rlRun "ipa config-show"
        
		rlLog "################## No Limit :: use global setting ##############" 
		ipa hbacrule-find > /tmp/rulefind.out
        	result=`cat /tmp/rulefind.out | grep "Number of entries returned"`
        	number=`echo $result | cut -d " " -f 5`
        	if [ $number -eq 5 ] ; then
                	rlPass "5 hbac rules returned as expected with global size limit of 5"
        	else
                	rlFail "Number of hbac rules returned is not as expected.  GOT: $number EXP: 5"
        	fi

		rlLog "#################  Set size limit to 7 #########################"
		ipa hbacrule-find --sizelimit=7 > /tmp/rulefind.out
                result=`cat /tmp/rulefind.out | grep "Number of entries returned"`
                number=`echo $result | cut -d " " -f 5`
                if [ $number -eq 7 ] ; then
                        rlPass "7 hbac rules returned as expected with size limit of 7"
                else
                        rlFail "Number of hbac rules returned is not as expected.  GOT: $number EXP: 7"
                fi

		# restoring ipa config
		rlRun "ipa config-mod --searchrecordslimit=100"
		rlRun "ipa config-show"
	
		# cleaning up created rules
		for i in {1000..1010}; do ipa hbacrule-del $i; done
        rlPhaseEnd
}

hbacsvc_master_bug772852() {

		# kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user772852 user772852 user772852 $userpw
		sleep 5
		export user772852=user772852

        rlPhaseStartTest "ipa-hbacsvc-772852: \"Unresolved rules in --rules\" error message is displayed even if the hbacrule is specified using the --rules option."

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

                for i in {1000..1010}; do ipa hbacrule-add $i; done
                rlRun "ipa config-show"
                rlRun "ipa config-mod --searchrecordslimit=5"
                rlRun "ipa config-show"

                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add 772852"
                rlRun "ipa hbacrule-find"

		rlRun "ipa hbacrule-add-user 772852 --users=$user772852"
		rlRun "ipa hbacrule-add-host 772852 --hosts=$MASTER"
                rlRun "ipa hbacrule-add-sourcehost 772852 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-service 772852  --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show 772852 --all"

        # ipa hbactest:

		rlRun "ipa hbactest --user=$user772852 --srchost=$CLIENT --host=$MASTER --service=sshd --rules=772852 | grep -Ex '(Access granted: True|  matched: 772852)'"
		rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=772852"
		rlRun "ipa hbactest --user=$user772852 --srchost=$CLIENT --host=$MASTER --service=sshd --rules=772852 | grep \"Unresolved rules\"" 1

        # restoring ipa config
                rlRun "ipa config-mod --searchrecordslimit=100"
                rlRun "ipa config-show"

	# cleaning up created rules
		for i in {1000..1010}; do ipa hbacrule-del $i; done
		rlRun "ipa hbacrule-del 772852"

        rlPhaseEnd
}


hbacsvc_master_bug766876() {

        rlPhaseStartTest "ipa-hbacsvc-bug766876: [RFE] Make HBAC srchost processing optional - Case 1"
	
		rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=766876"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                user766876="user766876"
                rlRun "create_ipauser $user766876 $user766876 $user766876 $userpw"
                sleep 5
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

                rlRun "ipa hbacrule-disable allow_all"

                rlRun "ipa hbacrule-add rule766876"
                rlRun "ipa hbacrule-add-user rule766876 --users=$user766876"
                rlRun "ipa hbacrule-add-host rule766876 --hosts=$MASTER"
                rlRun "ipa hbacrule-add-sourcehost rule766876 --hosts=$CLIENT"
                rlRun "ipa hbacrule-add-service rule766876 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show rule766876 --all"

        rlPhaseEnd
}

hbacsvc_client_bug766876() {

        rlPhaseStartTest "ipa-hbacsvc-client-bug766876: ipa_hbac_support_srchost is set to false - Case 1"

                #rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                sleep 5
                rlRun "getent -s sss passwd user766876"
                kdestroy
                rlRun "ssh_auth_success user766876 testpw123@ipa.com $MASTER"

        rlPhaseEnd

}

hbacsvc_client2_bug766876() {

        rlPhaseStartTest "ipa-hbacsvc-client2-bug766876: ipa_hbac_support_srchost is set to false - Case 1"

#                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                sleep 5
                rlRun "getent -s sss passwd user766876"
                kdestroy
                rlRun "ssh_auth_success user766876 testpw123@ipa.com $MASTER"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        rlPhaseEnd

}

hbacsvc_master_bug766876_2() {

        rlPhaseStartTest "ipa-hbacsvc-bug766876: [RFE] Make HBAC srchost processing optional - Case 2"

                rlLog "Verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=766876"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
                user766876="user766876"
		# user766876 is already created as part of hbacsvc_master_bug766876
                # rlRun "create_ipauser $user766876 $user766876 $user766876 $userpw"
                # sleep 5

                rlRun "cat /etc/sssd/sssd.conf"
                sed -i '6iipa_hbac_support_srchost = true' /etc/sssd/sssd.conf
                rlRun "cat /etc/sssd/sssd.conf"
                rlRun "rm -fr /var/lib/sss/db/cache_*" 0 "Clearing cache"
                rlRun "service sssd restart"

		sleep 10

        rlPhaseEnd
}


hbacsvc_client_bug766876_2() {

        rlPhaseStartTest "ipa-hbacsvc-client-bug766876_2: ipa_hbac_support_srchost is set to true - Case 2"


		rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=798317"
		sleep 10
                rlRun "ssh_auth_success user766876 testpw123@ipa.com $MASTER"

        rlPhaseEnd

}

hbacsvc_client2_bug766876_2() {

        rlPhaseStartTest "ipa-hbacsvc-client2-bug766876_2: ipa_hbac_support_srchost is set to true - Case 2"

		sleep 10
                rlRun "ssh_auth_failure user766876 testpw123@ipa.com $MASTER"

        rlPhaseEnd

}

hbacsvc_master_bug801769() {

                # kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user801769 user801769 user801769 $userpw
                sleep 5
                export user801769=user801769

        rlPhaseStartTest "ipa-hbacsvc-801769: Bug 801769 - hbactest returns failure when hostgroups are chained"

		rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=801769"
		rlLog "Closes https://engineering.redhat.com/trac/ipa-tests/ticket/394"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		HOSTGROUP801769="hostgroup801769"

                rlRun "ipa hbacrule-disable allow_all"
		rlRun "ipa hostgroup-add $HOSTGROUP801769 --desc=\"Master group\""
		rlRun "ipa hostgroup-add-member $HOSTGROUP801769 --hosts=$MASTER"

                rlRun "ipa hbacrule-add 801769"
                rlRun "ipa hbacrule-show 801769 --all"

                rlRun "ipa hbacrule-add-user 801769 --users=$user801769"
                rlRun "ipa hbacrule-add-host 801769 --hostgroups=$HOSTGROUP801769"
                rlRun "ipa hbacrule-add-service 801769 --hbacsvcs=sshd"
                rlRun "ipa hbacrule-show 801769 --all"

        # ipa hbactest:
                rlRun "ipa hbactest --user=$user801769 --host=$MASTER --service=sshd --rules=801769 | grep -Ex '(Access granted: True|  matched: 801769)'" 

                HOSTGROUP801769_2="hostgroup801769_2"

		rlRun "ipa hostgroup-add $HOSTGROUP801769_2 --desc=\"Master group2\""
                rlRun "ipa hostgroup-add-member $HOSTGROUP801769_2 --hostgroups=$HOSTGROUP801769"

        # ipa hbactest:
                rlRun "ipa hbactest --user=$user801769 --host=$MASTER --service=sshd --rules=801769 | grep -Ex '(Access granted: True|  matched: 801769)'" 


        rlPhaseEnd
}


hbacsvc_master_bug771706() {

	# kinit as admin and creating users
                kinitAs $ADMINID $ADMINPW
                create_ipauser user771706 user771706 user771706 $userpw
		sleep 5
		export user771706=user771706	
                export userpw=testpw123@ipa.com

        rlPhaseStartTest "ipa-hbacsvc-771706: Bug 771706 - sssd_be crashes during auth when there exists empty service group or hostgroup in an hbacrule."

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=771706"
		rlLog "closed https://engineering.redhat.com/trac/ipa-tests/ticket/284"

                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

                rlRun "ipa hbacrule-disable allow_all"
		rlRun "ipa hbacrule-find"

		rlRun "ipa hbacrule-add --hostcat=all --srchostcat=all rule771706"
		rlRun "ipa hbacrule-add-user rule771706 --users=$user771706"
		rlRun "ipa hbacsvcgroup-add svcgroup1 --desc=svcgroup1"
		rlRun "ipa hbacrule-add-service rule771706 --hbacsvcgroups=svcgroup1"

                kdestroy
		rlRun "ssh_auth_failure user771706 $userpw $MASTER"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "ipa hbacrule-del rule771706"

		rlRun "ipa hostgroup-add --desc=\"test host group 1\" testhostgroup1"
		rlRun "ipa hostgroup-add-member testhostgroup1 --hosts=$MASTER"
		rlRun "ipa hbacrule-add rule771706"
		rlRun "ipa hbacrule-add-user rule771706 --users=$user771706"
		rlRun "ipa hbacrule-add-service rule771706 --hbacsvcs=sshd"
		rlRun "ipa hbacrule-add-host rule771706 --hosts=$MASTER"
		rlRun "ipa hbacrule-add-sourcehost rule771706 --hostgroups=testhostgroup1"

                kdestroy
		rlRun "ssh_auth_success user771706 $userpw $MASTER"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa hostgroup-del testhostgroup1"
		rlRun "ipa hbacrule-add-sourcehost rule771706 --hosts=$MASTER"
                kdestroy
		rlRun "ssh_auth_success user771706 $userpw $MASTER"

        rlPhaseEnd
}

