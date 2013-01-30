#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-func
#   Description: IPA Selinuxusermap Func acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Asha Akkiangady <aakkiang@redhat.com>
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
. /dev/shm/ipa-selinuxusermap-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include tests file
. ./t.selinuxusermapsvc.sh


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
########################################################################
# Test Suite Globals
########################################################################

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

user1="user1"
user2="user2"
user3="user3"

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

	rlPhaseStartSetup "ipa-selinuxusermapsvc-func: Checking client"
                rlLog "Machine in recipe is CLIENT"
                rlRun "service iptables stop" 0 "Stop the firewall on the client"
		rlRun "yum install -y ftp"
		rlRun "cat /etc/krb5.conf"
		rlRun "authconfig --enablemkhomedir --updateall"
		rlRun "service sssd restart"

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

	rlPhaseEnd

        rlPhaseStartTest "CLIENT1 tests start"
	# selinuxusermapsvc_client_001
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_001 $BEAKERMASTER"
                selinuxusermapsvc_client_001
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_001 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_002
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_002 $BEAKERMASTER"
                selinuxusermapsvc_client_002
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_002 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_003
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_003 $BEAKERMASTER"
                selinuxusermapsvc_client_003
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_003 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_004
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004 $BEAKERMASTER"
                selinuxusermapsvc_client_004
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_004 -m $BEAKERCLIENT"
		
		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004_2 $BEAKERMASTER"
                selinuxusermapsvc_client_004_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_004_2 -m $BEAKERCLIENT"

		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004_3 $BEAKERMASTER"
                selinuxusermapsvc_client_004_3
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_004_3 -m $BEAKERCLIENT"
		
		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004_4 $BEAKERMASTER"
                selinuxusermapsvc_client_004_4
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_004_4 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_005
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005 $BEAKERMASTER"
                selinuxusermapsvc_client_005
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_005 -m $BEAKERCLIENT"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005_2 $BEAKERMASTER"
                selinuxusermapsvc_client_005_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_005_2 -m $BEAKERCLIENT"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005_3 $BEAKERMASTER"
                selinuxusermapsvc_client_005_3
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_005_3 -m $BEAKERCLIENT"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005_4 $BEAKERMASTER"
                selinuxusermapsvc_client_005_4
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_005_4 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_006
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_006 $BEAKERMASTER"
                selinuxusermapsvc_client_006
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_006 -m $BEAKERCLIENT"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_006_2 $BEAKERMASTER"
                selinuxusermapsvc_client_006_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_006_2 -m $BEAKERCLIENT"
	rlPhaseEnd

	# selinuxusermapsvc_client_007
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_007 $BEAKERMASTER"
                selinuxusermapsvc_client_007
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_007 -m $BEAKERCLIENT"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_007_2 $BEAKERMASTER"
                selinuxusermapsvc_client_007_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_007_2 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_008
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_008 $BEAKERMASTER"
                selinuxusermapsvc_client_008
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_008 -m $BEAKERCLIENT"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_008_2 $BEAKERMASTER"
                selinuxusermapsvc_client_008_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_008_2 -m $BEAKERCLIENT"

	# selinuxusermapsvc_client_009
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_009 $BEAKERMASTER"
                selinuxusermapsvc_client_009
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_009 -m $BEAKERCLIENT"

        # selinuxusermapsvc_client_010
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_010 $BEAKERMASTER"
                selinuxusermapsvc_client_010
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client_010 -m $BEAKERCLIENT"

        rlPhaseStartCleanup "ipa-selinuxusermap-func-cleanup: Destroying admin credentials."
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

	rlPhaseStartSetup "ipa-selinuxusermapsvc-func: Checking client"
                rlLog "Machine in recipe is CLIENT2"
                rlRun "service iptables stop" 0 "Stop the firewall on the client"
		rlRun "yum install -y ftp"
		rlRun "cat /etc/krb5.conf"
		rlRun "authconfig --enablemkhomedir --updateall"
		rlRun "service sssd restart"

		rlRun "rhts-sync-block -s DONE_master_setup $BEAKERMASTER"
		rlRun "rhts-sync-set -s DONE_client2_setup -m $BEAKERCLIENT2"

		MASTER_IP=`nslookup $MASTER | grep Address | grep -v "#" | awk '{print $2}'`
                BEAKERCLIENT_IP=`nslookup $BEAKERCLIENT | grep Address | grep -v "#" | awk '{print $2}'`
                BEAKERCLIENT2_IP=`nslookup $BEAKERCLIENT2 | grep Address | grep -v "#" | awk '{print $2}'`

		echo $MASTER_IP	$MASTER >> /etc/hosts
		echo $BEAKERCLIENT_IP	$CLIENT >> /etc/hosts

		rlRun "cat /etc/hosts"
	rlPhaseEnd

        rlPhaseStartTest "CLIENT2 tests start"
	# selinuxusermapsvc_client2_001
		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_001 $BEAKERMASTER"
		selinuxusermapsvc_client2_001
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_001 -m $BEAKERCLIENT2"

	# selinuxusermapsvc_client2_002
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_002 $BEAKERMASTER"
                selinuxusermapsvc_client2_002
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_002 -m $BEAKERCLIENT2"

	# selinuxusermapsvc_client2_003
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_003 $BEAKERMASTER"
                selinuxusermapsvc_client2_003
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_003 -m $BEAKERCLIENT2"

	# selinuxusermapsvc_client2_004
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004 $BEAKERMASTER"
                selinuxusermapsvc_client2_004
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_004 -m $BEAKERCLIENT2"
		
		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004_2 $BEAKERMASTER"
                selinuxusermapsvc_client2_004_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_004_2 -m $BEAKERCLIENT2"
		
		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004_3 $BEAKERMASTER"
                selinuxusermapsvc_client2_004_3
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_004_3 -m $BEAKERCLIENT2"

		rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_004_4 $BEAKERMASTER"
                selinuxusermapsvc_client2_004_4
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_004_4 -m $BEAKERCLIENT2"

	# selinuxusermapsvc_client2_005
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005 $BEAKERMASTER"
                selinuxusermapsvc_client2_005
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_005 -m $BEAKERCLIENT2"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005_2 $BEAKERMASTER"
                selinuxusermapsvc_client2_005_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_005_2 -m $BEAKERCLIENT2"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005_3 $BEAKERMASTER"
                selinuxusermapsvc_client2_005_3
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_005_3 -m $BEAKERCLIENT2"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_005_4 $BEAKERMASTER"
                selinuxusermapsvc_client2_005_4
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_005_4 -m $BEAKERCLIENT2"

	 # selinuxusermapsvc_client2_006
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_006 $BEAKERMASTER"
                selinuxusermapsvc_client2_006
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_006 -m $BEAKERCLIENT2"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_006_2 $BEAKERMASTER"
                selinuxusermapsvc_client2_006_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_006_2 -m $BEAKERCLIENT2"
	
	# selinuxusermapsvc_client2_007
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_007 $BEAKERMASTER"
                selinuxusermapsvc_client2_007
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_007 -m $BEAKERCLIENT2"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_007_2 $BEAKERMASTER"
                selinuxusermapsvc_client2_007_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_007_2 -m $BEAKERCLIENT2"

	# selinuxusermapsvc_client2_008
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_008 $BEAKERMASTER"
                selinuxusermapsvc_client2_008
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_008 -m $BEAKERCLIENT2"

                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_008_2 $BEAKERMASTER"
                selinuxusermapsvc_client2_008_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_008_2 -m $BEAKERCLIENT2"

	# selinuxusermapsvc_client2_009
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_009 $BEAKERMASTER"
                selinuxusermapsvc_client2_009
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_009 -m $BEAKERCLIENT2"

        # selinuxusermapsvc_client2_010
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_master_010 -s DONE_selinuxusermapsvc_client_010 $BEAKERCLIENT $BEAKERMASTER"
                selinuxusermapsvc_client2_010
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_client2_010 -m $BEAKERCLIENT2"

        rlPhaseStartCleanup "ipa-selinuxusermap-func-cleanup: Destroying admin credentials."
                rlRun "kdestroy" 0 "Destroying admin credentials."
                rlRun "cat /var/log/secure | grep \"pam_sss(sshd:auth)\""
        rlPhaseEnd

        else

                rlLog "Machine in recipe is not a CLIENT2"

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

	rlPhaseStartSetup "ipa-selinuxusermapsvc-func: Setup of users"

                rlRun "service iptables stop" 0 "Stop the firewall on the client"
		rlRun "yum install -y vsftpd"
		rlRun "service vsftpd start" 0 "Start ftp service"
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

		rlRun "ipa dnszone-find > /tmp/rev.out 2>&1"
		REVERSE_ZONE=`cat /tmp/rev.out | grep -i "Zone name" | head -1 | awk '{print $3}'`
		rlRun "cat /tmp/rev.out"
		rlLog "REVERSE_ZONE now again is $REVERSE_ZONE"

		# Adding forward and reverse record.
		rlRun "ipa dnsrecord-add $REVERSE_ZONE $BEAKERCLIENT_PTR --ptr-rec=$CLIENT."

		rlRun "ipa dnsrecord-add $REVERSE_ZONE $BEAKERCLIENT2_PTR --ptr-rec=$CLIENT2."


		# adding additional sync-set and sync-block so that tests are not
		# executed before the clients are ready
		rlRun "rhts-sync-set -s DONE_master_setup -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s DONE_client1_setup -s DONE_client2_setup $BEAKERCLIENT $BEAKERCLIENT2"
	rlPhaseEnd

	rlPhaseStartTest "MASTER tests start"

	# selinuxusermapsvc_master_001
		selinuxusermapsvc_master_001
		rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_001 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_001 -s DONE_selinuxusermapsvc_client2_001 $BEAKERCLIENT $BEAKERCLIENT2"
		selinuxusermapsvc_master_001_cleanup

	# selinuxusermapsvc_master_002
                selinuxusermapsvc_master_002
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_002 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_002 -s DONE_selinuxusermapsvc_client2_002 $BEAKERCLIENT $BEAKERCLIENT2"
                selinuxusermapsvc_master_002_cleanup

	# selinuxusermapsvc_master_003
                selinuxusermapsvc_master_003
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_003 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_003 -s DONE_selinuxusermapsvc_client2_003 $BEAKERCLIENT $BEAKERCLIENT2"
                selinuxusermapsvc_master_003_cleanup

	# selinuxusermapsvc_master_004
                selinuxusermapsvc_master_004
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_004 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_004 -s DONE_selinuxusermapsvc_client2_004 $BEAKERCLIENT $BEAKERCLIENT2"

		selinuxusermapsvc_master_004_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_004_2 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_004_2 -s DONE_selinuxusermapsvc_client2_004_2 $BEAKERCLIENT $BEAKERCLIENT2"

		selinuxusermapsvc_master_004_3
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_004_3 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_004_3 -s DONE_selinuxusermapsvc_client2_004_3 $BEAKERCLIENT $BEAKERCLIENT2"

		selinuxusermapsvc_master_004_4
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_004_4 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_004_4 -s DONE_selinuxusermapsvc_client2_004_4 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_004_cleanup

	# selinuxusermapsvc_master_005
                selinuxusermapsvc_master_005
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_005 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_005 -s DONE_selinuxusermapsvc_client2_005 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_005_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_005_2 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_005_2 -s DONE_selinuxusermapsvc_client2_005_2 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_005_3
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_005_3 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_005_3 -s DONE_selinuxusermapsvc_client2_005_3 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_005_4
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_005_4 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_005_4 -s DONE_selinuxusermapsvc_client2_005_4 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_005_cleanup

	# selinuxusermapsvc_master_006
                selinuxusermapsvc_master_006
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_006 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_006 -s DONE_selinuxusermapsvc_client2_006 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_006_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_006_2 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_006_2 -s DONE_selinuxusermapsvc_client2_006_2 $BEAKERCLIENT $BEAKERCLIENT2"
		selinuxusermapsvc_master_006_cleanup

	# selinuxusermapsvc_master_007
                selinuxusermapsvc_master_007
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_007 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_007 -s DONE_selinuxusermapsvc_client2_007 $BEAKERCLIENT $BEAKERCLIENT2"
                
                selinuxusermapsvc_master_007_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_007_2 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_007_2 -s DONE_selinuxusermapsvc_client2_007_2 $BEAKERCLIENT $BEAKERCLIENT2"
                selinuxusermapsvc_master_007_cleanup

	# selinuxusermapsvc_master_008
                selinuxusermapsvc_master_008
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_008 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_008 -s DONE_selinuxusermapsvc_client2_008 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_008_2
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_008_2 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_008_2 -s DONE_selinuxusermapsvc_client2_008_2 $BEAKERCLIENT $BEAKERCLIENT2"
                selinuxusermapsvc_master_008_cleanup
	
      # selinuxusermapsvc_master_009
                selinuxusermapsvc_master_009
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_009 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_009 -s DONE_selinuxusermapsvc_client2_009 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_009_cleanup

      # selinuxusermapsvc_master_010
                selinuxusermapsvc_master_010
                rlRun "rhts-sync-set -s DONE_selinuxusermapsvc_master_010 -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE_selinuxusermapsvc_client_010 -s DONE_selinuxusermapsvc_client2_010 $BEAKERCLIENT $BEAKERCLIENT2"

                selinuxusermapsvc_master_010_cleanup
        rlPhaseEnd

	rlPhaseStartCleanup "ipa-selunxusermap-func-cleanup: Destroying admin credentials."

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

