#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-hbacrule-func
#   Description: IPA Host Based Access Control (HBAC) Func acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <grajaiya@redhat.com>
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


# HACKING env.sh FOR HBAC AUTOMATION
ENV_DOMAIN=`cat /dev/shm/env.sh | grep ^"DOMAIN=" | cut -d = -f 2`
SHORT_HOST1=`cat /dev/shm/env.sh | grep BEAKERCLIENT |  cut -d "=" -f 2 | cut -d " " -f 1 | cut -d . -f 1`
LONG_HOST1=`cat /dev/shm/env.sh | grep BEAKERCLIENT | awk '{print $2}' | cut -d = -f 2`
echo "export CLIENT1=$SHORT_HOST1.$ENV_DOMAIN" >> /dev/shm/env.sh
echo "export BEAKERCLIENT1=$LONG_HOST1"

SHORT_HOST2=`cat /dev/shm/env.sh | grep BEAKERCLIENT | cut -d " " -f 3 | cut -d . -f 1`
LONG_HOST2=`cat /tmp/env.sh | grep BEAKERCLIENT | awk '{print $3}'`
echo "export CLIENT2=$SHORT_HOST2.$ENV_DOMAIN" >> /dev/shm/env.sh
echo "export BEAKERCLIENT2=$LONG_HOST2"

sed -e 's/export BEAKERCLIENT=/#export BEAKERCLIENT=/' /dev/shm/env.sh > /dev/shm/env.sh.new
sed -e 's/export CLIENT=/#export CLIENT=/' /dev/shm/env.sh.new > /dev/shm/env.sh


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

########################################################################

#Checking hostnames of all hosts
echo "The hostname of IPA Server is $MASTER"
echo "The hostname of IPA Client 1 is $CLIENT1"
echo "The hostname of IPA Client 2 is $CLIENT2"

echo "The beaker hostname of IPA Server is $BEAKERMASTER"
echo "The beaker hostname of IPA Client 1 is $BEAKERCLIENT1"
echo "The beaker hostname of IPA Client 2 is $BEAKERCLIENT2"

cat /dev/shm/env.sh #TODO
########################################################################



PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"

rlJournalStart
        #####################################################################
        #               IS THIS MACHINE A CLIENT1?                          #
        #####################################################################
        rc=0

	# Checking if CLIENT1 and CLIENT2 can be identified
#	SHORT_HOST1=`cat /dev/shm/env.sh | grep BEAKERCLIENT |  cut -d "=" -f 2 | cut -d " " -f 1 | cut -d . -f 1`
#	CLIENT1=$SHORT_HOST1.$DOMAIN

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of client is $CLIENT1"

        echo $CLIENT1 | grep $HOSTNAME
        if [ $? -eq 0 ] ; then

	rlPhaseStartSetup "ipa-hbacsvc-func: Checking client"
                rlLog "Machine in recipe is CLIENT1"
                rlRun "service iptables stop" 0 "Stop the firewall on the client"

		rlRun "rhts-sync-block -s ONLINE $BEAKERMASTER"
		rlRun "service sssd restart"
		hbacsvc_client1
                rlRun "rhts-sync-set -s DONE -m $BEAKERCLIENT1"
		#rlRun "rhts-sync-block -s HBACSVC_SETUP $MASTER"
		#rlRun "rhts-sync-set -s HBACSVC_DONE"
	rlPhaseEnd

        else

                rlLog "Machine in recipe in not a CLIENT1"

        fi

        #####################################################################

        #####################################################################
        #               IS THIS MACHINE A CLIENT2?                          #
        #####################################################################
        rc=0

        # Checking if CLIENT1 and CLIENT2 can be identified 
#        SHORT_HOST2=`cat /dev/shm/env.sh | grep BEAKERCLIENT | cut -d " " -f 3 | cut -d . -f 1`
#        CLIENT2=$SHORT_HOST2.$DOMAIN

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of client2 is $CLIENT2"

        echo $CLIENT2 | grep $HOSTNAME
        if [ $? -eq 0 ] ; then

	rlPhaseStartSetup "ipa-hbacsvc-func: Checking client"
                rlLog "Machine in recipe is CLIENT2"
                rlRun "service iptables stop" 0 "Stop the firewall on the client"

		rlRun "rhts-sync-block -s ONLINE $BEAKERMASTER"
		rlRun "service sssd restart"
		hbacsvc_client2
                rlRun "rhts-sync-set -s DONE -m $BEAKERCLIENT2"
		#rlRun "rhts-sync-block -s HBACSVC_SETUP $MASTER"
		#rlRun "rhts-sync-set -s HBACSVC_DONE"
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
        #echo $MASTER | grep `hostname -s`
        if [ $? -eq 0 ] ; then
                rlLog "Machine in recipe is MASTER"

	rlPhaseStartSetup "ipa-hbacsvc-func: Setup of users"

                rlRun "service iptables stop" 0 "Stop the firewall on the client"
        	rlRun "cat /dev/shm/env.sh"
	        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        	rlRun "pushd $TmpDir"
	        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

	        # add host for testing
	        #rlRun "addHost $CLIENT1" 0 "SETUP: Adding host $CLIENT1 for testing."
	        #rlRun "addHost $CLIENT2" 0 "SETUP: Adding host $CLIENT2 for testing."

        	# kinit as admin and creating users
	        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	        rlRun "create_ipauser $user1 $user1 $user1 $userpw"
	        sleep 5
	        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	        rlRun "create_ipauser $user2 $user2 $user2 $userpw"
	        sleep 5
	        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	        rlRun "create_ipauser $user3 $user3 $user3 $userpw"

		hbacsvc_setup
		rlRun "rhts-sync-set -s ONLINE -m $BEAKERMASTER"
                rlRun "rhts-sync-block -s DONE -s DONE $BEAKERCLIENT1 $BEAKERCLIENT2"
		#rlRun "rhts-sync-set -s HBACSVC_SETUP"
               	#rlRun "rhts-sync-block -s HBACSVC_DONE -s HBACSVC_DONE $CLIENT1 $CLIENT2"
	rlPhaseEnd

	rlPhaseStartCleanup "ipa-hbacrule-func-cleanup: Destroying admin credentials."
        	# delete hbac service 
	        rlRun "ipa hbacrule-del rule1" 0 "CLEANUP: Deleting rule rule1"

	        rlRun "kdestroy" 0 "Destroying admin credentials."
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
