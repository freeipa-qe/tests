#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbacrule-func
#   Description: IPA Host Based Access Control (HBAC) Func acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

##########################################################################

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include tests file
. ./t.hbacsvc.sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

user1="user1"
user2="user2"
user3="user3"

RHEL5=$(cat /etc/redhat-release|grep "5\.[0-9]"|wc -l)

########################################################################

#Checking hostnames of all hosts
echo "The hostname of IPA Server is $MASTER"
echo "The hostname of IPA Client 1 is $CLIENT"
echo "The hostname of IPA Client 2 is $CLIENT2"

echo "The beaker hostname of IPA Server is $BEAKERMASTER"
echo "The beaker hostname of IPA Client 1 is $BEAKERCLIENT"
echo "The beaker hostname of IPA Client 2 is $BEAKERCLIENT2"

cat /dev/shm/env.sh
########################################################################



PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"

rlJournalStart
        #####################################################################
        #               IS THIS MACHINE CLIENT1?                            #
        #####################################################################
        rc=0

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of client is $CLIENT"

        echo $CLIENT | grep $HOSTNAME
        if [ $? -eq 0 ] ; then

	rlPhaseStartSetup "ipa-hbacsvc-func: Checking client"
		rlLog "Machine in recipe is CLIENT"
		if [ $(cat /etc/redhat-release|grep "5\.[0-9]"|wc -l) -gt 0 ]; then
			service iptables stop
			if [ $? -eq 1 ]; then
				rlLog "[ FAIL ] BZ 845301 found -- service iptables stop returns 1 when already stopped"
				rlLog "This affects RHEL5 version of iptables service"
			else
				rlLog "[ PASS ] BZ 845301 not found -- service iptables stop succeeeded"
			fi
		else	
			rlRun "service iptables stop" 0 "Stop the firewall on the client"
		fi
		rlRun "yum install -y ftp"
		rlRun "cat /etc/krb5.conf"
		rlRun "authconfig --enablemkhomedir --updateall"

                rlRun "rhts-sync-block -s DONE_master_setup $BEAKERMASTER"
                rlRun "rhts-sync-set -s DONE_client1_setup -m $BEAKERCLIENT"

		# Adding the next lines because this test will stall forever if $BEAKERCLIENT or $BEAKERCLIENT2 are empty
		if [ -x $BEAKERCLIENT ]; then
			echo "ERROR - This test must be run on a config with \$BEAKERCLIENT defined"
			rlFail "ERROR - This test must be run on a config with \$BEAKERCLIENT defined"
			exit
		fi
		if [ -x $BEAKERCLIENT2 ]; then
			echo "ERROR - This test must be run on a config with \$BEAKERCLIENT2 defined"
			rlFail "ERROR - This test must be run on a config with \$BEAKERCLIENT2 defined"
			exit
		fi
		MASTER_IP=`nslookup $MASTER | grep Address | grep -v "#" | awk '{print $2}'`
		BEAKERCLIENT_IP=`nslookup $BEAKERCLIENT | grep Address | grep -v "#" | awk '{print $2}'`
		BEAKERCLIENT2_IP=`nslookup $BEAKERCLIENT2 | grep Address | grep -v "#" | awk '{print $2}'`

                echo $MASTER_IP        $MASTER >> /etc/hosts
                echo $BEAKERCLIENT2_IP  $CLIENT2 >> /etc/hosts

                rlRun "cat /etc/hosts"
	
		rlLog "setting debug_level in sssd.conf"
		sed -i "s/\(\[domain.$DOMAIN\]\)$/\1\ndebug_level = 9/" /etc/sssd/sssd.conf
		rlRun "service sssd restart"		

	rlPhaseEnd

        rlPhaseStartTest "CLIENT1 tests start"

	# hbacsvc_client_001
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_001 $BEAKERMASTER"
                hbacsvc_client_001
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_001 -m $BEAKERCLIENT"

        # hbacsvc_client_002
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_002 $BEAKERMASTER"
                hbacsvc_client_002
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_002 -m $BEAKERCLIENT"

	# hbacsvc_client_002_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_002_1 $BEAKERMASTER"
                hbacsvc_client_002_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_002_1 -m $BEAKERCLIENT"

	# hbacsvc_client_003
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_003 $BEAKERMASTER"
                hbacsvc_client_003
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_003 -m $BEAKERCLIENT"

	# hbacsvc_client_004
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_004 $BEAKERMASTER"
                hbacsvc_client_004
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_004 -m $BEAKERCLIENT"

	# hbacsvc_client_005
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_005 $BEAKERMASTER"
                hbacsvc_client_005
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_005 -m $BEAKERCLIENT"

	# hbacsvc_client_005_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_005_1 $BEAKERMASTER"
                hbacsvc_client_005_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_005_1 -m $BEAKERCLIENT"

	# hbacsvc_client_006
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_006 $BEAKERMASTER"
                hbacsvc_client_006
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_006 -m $BEAKERCLIENT"

	# hbacsvc_client_007
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_007 $BEAKERMASTER"
                hbacsvc_client_007
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_007 -m $BEAKERCLIENT"

	# hbacsvc_client_007_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_007_1 $BEAKERMASTER"
                hbacsvc_client_007_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_007_1 -m $BEAKERCLIENT"

	# hbacsvc_client_008
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_008 $BEAKERMASTER"
                hbacsvc_client_008
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_008 -m $BEAKERCLIENT"

	# hbacsvc_client_008_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_008_1 $BEAKERMASTER"
                hbacsvc_client_008_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_008_1 -m $BEAKERCLIENT"

	# hbacsvc_client_009
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_009 $BEAKERMASTER"
                hbacsvc_client_009
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_009 -m $BEAKERCLIENT"

	# hbacsvc_client_009_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_009_1 $BEAKERMASTER"
                hbacsvc_client_009_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_009_1 -m $BEAKERCLIENT"

	# hbacsvc_client_010
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_010 $BEAKERMASTER"
                hbacsvc_client_010
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_010 -m $BEAKERCLIENT"

	# hbacsvc_client_011
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_011 $BEAKERMASTER"
                hbacsvc_client_011
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_011 -m $BEAKERCLIENT"

	# hbacsvc_client_011_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_011_1 $BEAKERMASTER"
                hbacsvc_client_011_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_011_1 -m $BEAKERCLIENT"

	# hbacsvc_client_012
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_012 $BEAKERMASTER"
                hbacsvc_client_012
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_012 -m $BEAKERCLIENT"

	# hbacsvc_client_013
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_013 $BEAKERMASTER"
                hbacsvc_client_013
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_013 -m $BEAKERCLIENT"

	# hbacsvc_client_014
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_014 $BEAKERMASTER"
                hbacsvc_client_014
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_014 -m $BEAKERCLIENT"

	# hbacsvc_client_015
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_015 $BEAKERMASTER"
                hbacsvc_client_015
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_015 -m $BEAKERCLIENT"

	# hbacsvc_client_015_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_015_1 $BEAKERMASTER"
                hbacsvc_client_015_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_015_1 -m $BEAKERCLIENT"

	# hbacsvc_client_016
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_016 $BEAKERMASTER"
                hbacsvc_client_016
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_016 -m $BEAKERCLIENT"

	# hbacsvc_client_016_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_016_1 $BEAKERMASTER"
                hbacsvc_client_016_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_016_1 -m $BEAKERCLIENT"

	# hbacsvc_client_017
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_017 $BEAKERMASTER"
                hbacsvc_client_017
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_017 -m $BEAKERCLIENT"

	# hbacsvc_client_018
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_018 $BEAKERMASTER"
                hbacsvc_client_018
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_018 -m $BEAKERCLIENT"

	# hbacsvc_client_019
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_019 $BEAKERMASTER"
                hbacsvc_client_019
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_019 -m $BEAKERCLIENT"

	# hbacsvc_client_020
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_020 $BEAKERMASTER"
                hbacsvc_client_020
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_020 -m $BEAKERCLIENT"

	# hbacsvc_client_020_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_020_1 $BEAKERMASTER"
                hbacsvc_client_020_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_020_1 -m $BEAKERCLIENT"

	# hbacsvc_client_027
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_027 $BEAKERMASTER"
                hbacsvc_client_027
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_027 -m $BEAKERCLIENT"

        # hbacsvc_client_028
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_028 $BEAKERMASTER"
                hbacsvc_client_028
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_028 -m $BEAKERCLIENT"

	# hbacsvc_client_029
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_029 $BEAKERMASTER"
                hbacsvc_client_029
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_029 -m $BEAKERCLIENT"

	# hbacsvc_client_030
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_030 $BEAKERMASTER"
                hbacsvc_client_030
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_030 -m $BEAKERCLIENT"

	# hbacsvc_client_031
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_031 $BEAKERMASTER"
                hbacsvc_client_031
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_031 -m $BEAKERCLIENT"

	# hbacsvc_client_032
# Unable to add UTF-8 user. Hence commenting this case.
#[root@bumblebee ~]# ipa user-add userÃŒ
#First name: userÃŒ
#Last name: userÃŒ
#ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $

#                rlRun "rhts-sync-block -s DONE_hbacsvc_master_032 $BEAKERMASTER"
#                hbacsvc_client_032
#                rlRun "rhts-sync-set -s DONE_hbacsvc_client_032 -m $BEAKERCLIENT"

	# hbacsvc_client_bug736314
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_bug736314 $BEAKERMASTER"
                hbacsvc_client_bug736314
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_bug736314 -m $BEAKERCLIENT"

	# hbacsvc_client_bug766876
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_bug766876 $BEAKERMASTER"
                hbacsvc_client_bug766876
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_bug766876 -m $BEAKERCLIENT"

        # hbacsvc_client_bug766876_2
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_bug766876_2 $BEAKERMASTER"
                hbacsvc_client_bug766876_2
                rlRun "rhts-sync-set -s DONE_hbacsvc_client_bug766876_2 -m $BEAKERCLIENT"

	rlPhaseEnd

        rlPhaseStartCleanup "ipa-hbacrule-func-cleanup: Destroying admin credentials."
                rlRun "kdestroy" 0 "Destroying admin credentials."
                rlRun "cat /var/log/secure | grep \"pam_sss(sshd:auth)\""
        rlPhaseEnd

        else

                rlLog "Machine in recipe in not a CLIENT"

        fi

        #####################################################################

        #####################################################################
        #               IS THIS MACHINE CLIENT2?                            #
        #####################################################################
        rc=0

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of client2 is $CLIENT2"

        echo $CLIENT2 | grep $HOSTNAME
        if [ $? -eq 0 ] ; then

	rlPhaseStartSetup "ipa-hbacsvc-func: Checking client"
                rlLog "Machine in recipe is CLIENT2"
        #        rlRun "service iptables stop" 0 "Stop the firewall on the client"
		if [ $(cat /etc/redhat-release|grep "5\.[0-9]"|wc -l) -gt 0 ]; then
			service iptables stop
			if [ $? -eq 1 ]; then
				rlLog "[ FAIL ] BZ 845301 found -- service iptables stop returns 1 when already stopped"
				rlLog "This affects RHEL5 version of iptables service"
			else
				rlLog "[ PASS ] BZ 845301 not found -- service iptables stop succeeeded"
			fi
		else	
			rlRun "service iptables stop" 0 "Stop the firewall on the client"
		fi
		rlRun "yum install -y ftp"
		rlRun "cat /etc/krb5.conf"
		rlRun "authconfig --enablemkhomedir --updateall"

		rlRun "rhts-sync-block -s DONE_master_setup $BEAKERMASTER"
		rlRun "rhts-sync-set -s DONE_client2_setup -m $BEAKERCLIENT2"

		MASTER_IP=`nslookup $MASTER | grep Address | grep -v "#" | awk '{print $2}'`
                BEAKERCLIENT_IP=`nslookup $BEAKERCLIENT | grep Address | grep -v "#" | awk '{print $2}'`
                BEAKERCLIENT2_IP=`nslookup $BEAKERCLIENT2 | grep Address | grep -v "#" | awk '{print $2}'`

		echo $MASTER_IP	$MASTER >> /etc/hosts
		echo $BEAKERCLIENT_IP	$CLIENT >> /etc/hosts

		rlRun "cat /etc/hosts"

		rlLog "setting debug_level in sssd.conf"
		sed -i "s/\(\[domain.$DOMAIN\]\)$/\1\ndebug_level = 9/" /etc/sssd/sssd.conf
		rlRun "service sssd restart"		

	rlPhaseEnd

        rlPhaseStartTest "CLIENT2 tests start"

	# hbacsvc_client2_001
		rlRun "rhts-sync-block -s DONE_hbacsvc_master_001 $BEAKERMASTER"
		hbacsvc_client2_001
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_001 -m $BEAKERCLIENT2"

        # hbacsvc_client2_002
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_002 $BEAKERMASTER"
                hbacsvc_client2_002
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_002 -m $BEAKERCLIENT2"

	# hbacsvc_client2_002_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_002_1 $BEAKERMASTER"
                hbacsvc_client2_002_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_002_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_003
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_003 $BEAKERMASTER"
                hbacsvc_client2_003
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_003 -m $BEAKERCLIENT2"

	# hbacsvc_client2_004
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_004 $BEAKERMASTER"
                hbacsvc_client2_004
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_004 -m $BEAKERCLIENT2"

	# hbacsvc_client2_005
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_005 $BEAKERMASTER"
                hbacsvc_client2_005
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_005 -m $BEAKERCLIENT2"

	# hbacsvc_client2_005_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_005_1 $BEAKERMASTER"
                hbacsvc_client2_005_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_005_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_006
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_006 $BEAKERMASTER"
                hbacsvc_client2_006
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_006 -m $BEAKERCLIENT2"

	# hbacsvc_client2_007
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_007 $BEAKERMASTER"
                hbacsvc_client2_007
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_007 -m $BEAKERCLIENT2"

	# hbacsvc_client2_007_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_007_1 $BEAKERMASTER"
                hbacsvc_client2_007_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_007_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_008
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_008 $BEAKERMASTER"
                hbacsvc_client2_008
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_008 -m $BEAKERCLIENT2"

	# hbacsvc_client2_008_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_008_1 $BEAKERMASTER"
                hbacsvc_client2_008_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_008_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_009
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_009 $BEAKERMASTER"
                hbacsvc_client2_009
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_009 -m $BEAKERCLIENT2"

	# hbacsvc_client2_009_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_009_1 $BEAKERMASTER"
                hbacsvc_client2_009_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_009_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_010
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_010 $BEAKERMASTER"
                hbacsvc_client2_010
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_010 -m $BEAKERCLIENT2"

	# hbacsvc_client2_011
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_011 $BEAKERMASTER"
                hbacsvc_client2_011
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_011 -m $BEAKERCLIENT2"

	# hbacsvc_client2_011_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_011_1 $BEAKERMASTER"
                hbacsvc_client2_011_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_011_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_012
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_012 $BEAKERMASTER"
                hbacsvc_client2_012
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_012 -m $BEAKERCLIENT2"

	# hbacsvc_client2_013
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_013 $BEAKERMASTER"
                hbacsvc_client2_013
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_013 -m $BEAKERCLIENT2"

	# hbacsvc_client2_014
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_014 $BEAKERMASTER"
                hbacsvc_client2_014
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_014 -m $BEAKERCLIENT2"

	# hbacsvc_client2_015
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_015 $BEAKERMASTER"
                hbacsvc_client2_015
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_015 -m $BEAKERCLIENT2"

	# hbacsvc_client2_015_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_015_1 $BEAKERMASTER"
                hbacsvc_client2_015_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_015_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_016
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_016 $BEAKERMASTER"
                hbacsvc_client2_016
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_016 -m $BEAKERCLIENT2"

	# hbacsvc_client2_016_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_016_1 $BEAKERMASTER"
                hbacsvc_client2_016_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_016_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_017
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_017 $BEAKERMASTER"
                hbacsvc_client2_017
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_017 -m $BEAKERCLIENT2"

	# hbacsvc_client2_018
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_018 $BEAKERMASTER"
                hbacsvc_client2_018
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_018 -m $BEAKERCLIENT2"

	# hbacsvc_client2_019
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_019 $BEAKERMASTER"
                hbacsvc_client2_019
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_019 -m $BEAKERCLIENT2"

	# hbacsvc_client2_020
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_020 $BEAKERMASTER"
                hbacsvc_client2_020
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_020 -m $BEAKERCLIENT2"

	# hbacsvc_client2_020_1
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_020_1 $BEAKERMASTER"
                hbacsvc_client2_020_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_020_1 -m $BEAKERCLIENT2"

	# hbacsvc_client2_027
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_027 $BEAKERMASTER"
                hbacsvc_client2_027
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_027 -m $BEAKERCLIENT2"

        # hbacsvc_client2_028
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_028 $BEAKERMASTER"
                hbacsvc_client2_028
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_028 -m $BEAKERCLIENT2"

	# hbacsvc_client2_029
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_029 $BEAKERMASTER"
                hbacsvc_client2_029
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_029 -m $BEAKERCLIENT2"

	# hbacsvc_client2_030
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_030 $BEAKERMASTER"
                hbacsvc_client2_030
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_030 -m $BEAKERCLIENT2"

        # hbacsvc_client2_031
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_031 $BEAKERMASTER"
                hbacsvc_client2_031
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_031 -m $BEAKERCLIENT2"

        # hbacsvc_client2_032
# Unable to add UTF-8 user. Hence commenting this case.
#[root@bumblebee ~]# ipa user-add userÃŒ
#First name: userÃŒ
#Last name: userÃŒ
#ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $

#                rlRun "rhts-sync-block -s DONE_hbacsvc_master_032 $BEAKERMASTER"
#                hbacsvc_client2_032
#                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_032 -m $BEAKERCLIENT2"

	# hbacsvc_client2_bug736314
                rlRun "rhts-sync-block -s DONE_hbacsvc_master_bug736314 $BEAKERMASTER"
                hbacsvc_client2_bug736314
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_bug736314 -m $BEAKERCLIENT2"

	# hbacsvc_client2_bug766876
		rlRun "rhts-sync-block -s DONE_hbacsvc_master_bug766876 $BEAKERMASTER"
		hbacsvc_client2_bug766876
		rlRun "rhts-sync-set -s DONE_hbacsvc_client2_bug766876 -m $BEAKERCLIENT2"

        # hbacsvc_client2_bug766876_2
		rlRun "rhts-sync-block -s DONE_hbacsvc_master_bug766876_2 $BEAKERMASTER"
                hbacsvc_client2_bug766876_2
                rlRun "rhts-sync-set -s DONE_hbacsvc_client2_bug766876_2 -m $BEAKERCLIENT2"

	rlPhaseEnd

        rlPhaseStartCleanup "ipa-hbacrule-func-cleanup: Destroying admin credentials."
                rlRun "kdestroy" 0 "Destroying admin credentials."
                rlRun "cat /var/log/secure | grep \"pam_sss(sshd:auth)\""
        rlPhaseEnd

        else

                rlLog "Machine in recipe in not a CLIENT2"

        fi

        #####################################################################

        #####################################################################
        #               IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of master is $MASTER"

        echo $MASTER | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                rlLog "Machine in recipe is MASTER"

	rlPhaseStartSetup "ipa-hbacsvc-func: Setup of users"

                rlRun "service iptables stop" 0 "Stop the firewall on the client"
		rlRun "authconfig --enablemkhomedir --updateall"
        rlRun "service sssd restart"
        	rlRun "cat /dev/shm/env.sh"
	        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        	rlRun "pushd $TmpDir"
	        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		BEAKERCLIENT_IP=`nslookup $BEAKERCLIENT | grep Address | grep -v "#" | awk '{print $2}'`
		BEAKERCLIENT2_IP=`nslookup $BEAKERCLIENT2 | grep Address | grep -v "#" | awk '{print $2}'`
		BEAKERCLIENT_SH=`echo $BEAKERCLIENT | cut -d "." -f 1`
		BEAKERCLIENT2_SH=`echo $BEAKERCLIENT2 | cut -d "." -f 1`
		BEAKERCLIENT_PTR=`nslookup $BEAKERCLIENT | grep Address | grep -v "#" | awk '{print $2}' | cut -d "." -f 4`
		BEAKERCLIENT2_PTR=`nslookup $BEAKERCLIENT2 | grep Address | grep -v "#" | awk '{print $2}' | cut -d "." -f 4`

		echo $BEAKERCLIENT_IP	$CLIENT	>> /etc/hosts
		echo $BEAKERCLIENT2_IP	$CLIENT2 >> /etc/hosts

		rlRun "cat /etc/hosts"

		REVERSE_ZONE=`ipa dnszone-\find | grep -i "Zone name" | head -1 | awk '{print $4}'`
		rlLog "REVERSE_ZONE is $REVERSE_ZONE"

		ipa dnszone-find | grep -i "Zone name" | head -1 | awk '{print $4}' > /tmp/reverse_zone.out
		REVERSE_ZONE=`cat /tmp/reverse_zone.out`
		rlLog "REVERSE_ZONE now is $REVERSE_ZONE"

		#rlRun "ipa dnszone-find > /tmp/rev.out 2>&1"
		#REVERSE_ZONE=`cat /tmp/rev.out | grep -i "Zone name" | head -1 | awk '{print $3}'`
		#rlRun "cat /tmp/rev.out"
		#rlLog "REVERSE_ZONE now again is $REVERSE_ZONE"

		# Adding forward and reverse record.
		# rlRun "ipa dnsrecord-add $DOMAIN $BEAKERCLIENT_SH --a-rec=$BEAKERCLIENT_IP"
		CLIENT_REVZONE=$(echo $BEAKERCLIENT_IP|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		if [ $(ipa dnszone-show $CLIENT_REVZONE 2>/dev/null | wc -l) -eq 0 ]; then
			rlRun "ipa dnszone-add $CLIENT_REVZONE --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
		fi
		rlLog "Running: ipa dnsrecord-add $CLIENT_REVZONE $BEAKERCLIENT_PTR --ptr-rec=$CLIENT."
		rlRun "ipa dnsrecord-add $CLIENT_REVZONE $BEAKERCLIENT_PTR --ptr-rec=$CLIENT."

		# Adding forward and reverse record.
		# echo "ipa dnsrecord-add $DOMAIN $BEAKERCLIENT2_SH --a-rec=$BEAKERCLIENT2_IP"
		# echo "ipa dnsrecord-add $REVERSE_ZONE $BEAKERCLIENT2_PTR --ptr-rec=$CLIENT2."
		# rlRun "ipa dnsrecord-add $DOMAIN $BEAKERCLIENT2_SH --a-rec=$BEAKERCLIENT2_IP"
		CLIENT2_REVZONE=$(echo $BEAKERCLIENT2_IP|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		if [ $(ipa dnszone-show $CLIENT2_REVZONE 2>/dev/null | wc -l) -eq 0 ]; then
			rlRun "ipa dnszone-add $CLIENT2_REVZONE --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
		fi
		rlLog "Running: ipa dnsrecord-add $CLIENT2_REVZONE $BEAKERCLIENT2_PTR --ptr-rec=$CLIENT2."
		rlRun "ipa dnsrecord-add $CLIENT2_REVZONE $BEAKERCLIENT2_PTR --ptr-rec=$CLIENT2."


        	# kinit as admin and creating users
# Creating users in their respective tests, hence commenting from here.
#	for i in {1..40}; do
#	        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
#	        rlRun "create_ipauser user$i user$i user$i $userpw"
#	        sleep 5
#		rlRun "export user$i=user$i"
#	done
		# adding additional sync-set and sync-block so that tests are not
		# executed before the clients are ready
		rlRun "rhts-sync-set -s DONE_master_setup -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s DONE_client1_setup -s DONE_client2_setup $BEAKERCLIENT $BEAKERCLIENT2"
	rlPhaseEnd

	rlPhaseStartTest "MASTER tests start"

	# hbacsvc_master_001
		hbacsvc_master_001
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_001 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_001 -s DONE_hbacsvc_client2_001 $BEAKERCLIENT $BEAKERCLIENT2"
		hbacsvc_master_001_cleanup

	# hbacsvc_master_002
		hbacsvc_master_002
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_002 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_002 -s DONE_hbacsvc_client2_002 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_002_1
		hbacsvc_master_002_1
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_002_1 -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s DONE_hbacsvc_client_002_1 -s DONE_hbacsvc_client2_002_1 $BEAKERCLIENT $BEAKERCLIENT2"
		hbacsvc_master_002_cleanup

	# hbacsvc_master_003
		hbacsvc_master_003
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_003 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_003 -s DONE_hbacsvc_client2_003 $BEAKERCLIENT $BEAKERCLIENT2"
		hbacsvc_master_003_cleanup

	# hbacsvc_master_004
		hbacsvc_master_004
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_004 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_004 -s DONE_hbacsvc_client2_004 $BEAKERCLIENT $BEAKERCLIENT2"
		hbacsvc_master_004_cleanup

	# hbacsvc_master_005
		hbacsvc_master_005
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_005 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_005 -s DONE_hbacsvc_client2_005 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_005_1
		hbacsvc_master_005_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_005_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_005_1 -s DONE_hbacsvc_client2_005_1 $BEAKERCLIENT $BEAKERCLIENT2"
		hbacsvc_master_005_cleanup

	# hbacsvc_master_006
		hbacsvc_master_006
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_006 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_006 -s DONE_hbacsvc_client2_006 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_007
		hbacsvc_master_007
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_007 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_007 -s DONE_hbacsvc_client2_007 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_007_1
		hbacsvc_master_007_1
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_007_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_007_1 -s DONE_hbacsvc_client2_007_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_008
		hbacsvc_master_008
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_008 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_008 -s DONE_hbacsvc_client2_008 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_008_1
		hbacsvc_master_008_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_008_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_008_1 -s DONE_hbacsvc_client2_008_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_009
		hbacsvc_master_009
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_009 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_009 -s DONE_hbacsvc_client2_009 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_009_1
		hbacsvc_master_009_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_009_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_009_1 -s DONE_hbacsvc_client2_009_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_010
		hbacsvc_master_010
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_010 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_010 -s DONE_hbacsvc_client2_010 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_011
		hbacsvc_master_011
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_011 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_011 -s DONE_hbacsvc_client2_011 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_011_1
		hbacsvc_master_011_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_011_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_011_1 -s DONE_hbacsvc_client2_011_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_012
		hbacsvc_master_012
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_012 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_012 -s DONE_hbacsvc_client2_012 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_013
		hbacsvc_master_013
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_013 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_013 -s DONE_hbacsvc_client2_013 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_014
		hbacsvc_master_014
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_014 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_014 -s DONE_hbacsvc_client2_014 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_015
		hbacsvc_master_015
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_015 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_015 -s DONE_hbacsvc_client2_015 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_015_1
		hbacsvc_master_015_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_015_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_015_1 -s DONE_hbacsvc_client2_015_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_016
		hbacsvc_master_016
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_016 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_016 -s DONE_hbacsvc_client2_016 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_016_1
		hbacsvc_master_016_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_016_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_016_1 -s DONE_hbacsvc_client2_016_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_017
		hbacsvc_master_017
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_017 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_017 -s DONE_hbacsvc_client2_017 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_018
		hbacsvc_master_018
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_018 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_018 -s DONE_hbacsvc_client2_018 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_019
		hbacsvc_master_019
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_019 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_019 -s DONE_hbacsvc_client2_019 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_020
		hbacsvc_master_020
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_020 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_020 -s DONE_hbacsvc_client2_020 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_020_1
		hbacsvc_master_020_1
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_020_1 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_020_1 -s DONE_hbacsvc_client2_020_1 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_021
                hbacsvc_master_021

	# hbacsvc_master_022
	# As per design target host cannot be an external host. Hence commenting the following test.
        #       hbacsvc_master_022

	# hbacsvc_master_023
                hbacsvc_master_023

	# hbacsvc_master_024
	# As per design target host cannot be an external host. Hence commenting the following test.
        #       hbacsvc_master_024

	# hbacsvc_master_025
                hbacsvc_master_025

	# hbacsvc_master_026
	# As per design target host cannot be an external host. Hence commenting the following test.
        #       hbacsvc_master_026

	# hbacsvc_master_027
		hbacsvc_master_027
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_027 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_027 -s DONE_hbacsvc_client2_027 $BEAKERCLIENT $BEAKERCLIENT2"

        # hbacsvc_master_028
		hbacsvc_master_028
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_028 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_028 -s DONE_hbacsvc_client2_028 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_029
		hbacsvc_master_029
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_029 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_029 -s DONE_hbacsvc_client2_029 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_030
		hbacsvc_master_030
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_030 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_030 -s DONE_hbacsvc_client2_030 $BEAKERCLIENT $BEAKERCLIENT2"

        # hbacsvc_master_031
                hbacsvc_master_031
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_031 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_031 -s DONE_hbacsvc_client2_031 $BEAKERCLIENT $BEAKERCLIENT2"

        # hbacsvc_master_032
# Unable to add UTF-8 user. Hence commenting this case.
#[root@bumblebee ~]# ipa user-add userÃŒ
#First name: userÃŒ
#Last name: userÃŒ
#ipa: ERROR: invalid 'login': may only include letters, numbers, _, -, . and $

#                hbacsvc_master_032
#                rlRun "rhts-sync-set -s DONE_hbacsvc_master_032 -m $BEAKERMASTER"
#                rlRun "rhts-sync-block -s DONE_hbacsvc_client_032 -s DONE_hbacsvc_client2_032 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_bug736314
		hbacsvc_master_bug736314
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_bug736314 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_bug736314 -s DONE_hbacsvc_client2_bug736314 $BEAKERCLIENT $BEAKERCLIENT2"
		hbacsvc_master_bug736314_cleanup

	# hbacsvc_master_bug782927
		hbacsvc_master_bug782927

	# hbacsvc_master_bug772852
		hbacsvc_master_bug772852

	# hbacsvc_master_bug766876
		hbacsvc_master_bug766876
		rlRun "rhts-sync-set -s DONE_hbacsvc_master_bug766876 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_bug766876 -s DONE_hbacsvc_client2_bug766876 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_bug766876_2
		hbacsvc_master_bug766876_2
                rlRun "rhts-sync-set -s DONE_hbacsvc_master_bug766876_2 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_hbacsvc_client_bug766876_2 -s DONE_hbacsvc_client2_bug766876_2 $BEAKERCLIENT $BEAKERCLIENT2"

	# hbacsvc_master_bug801769
		hbacsvc_master_bug801769

	# hbac hbactest --sizemimit tests
		hbactest_master_sizelimit_1
		hbactest_master_sizelimit_2

	# hbacsvc_master_bug771706
		hbacsvc_master_bug771706

	rlPhaseEnd


	rlPhaseStartCleanup "ipa-hbacrule-func-cleanup: Destroying admin credentials."

        	# delete hbac service 
		# rule1 is being deleted as part of hbacsvc_master_001_cleanup, hence commenting the following
	        # rlRun "ipa hbacrule-del rule1" 0 "CLEANUP: Deleting rule rule1"

	        rlRun "kdestroy" 0 "Destroying admin credentials."
		rlRun "cat /var/log/secure | grep \"pam_sss(sshd:auth)\""
	rlPhaseEnd


        else
                rlLog "Machine in recipe in not a MASTER"
        fi

        #####################################################################



rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
