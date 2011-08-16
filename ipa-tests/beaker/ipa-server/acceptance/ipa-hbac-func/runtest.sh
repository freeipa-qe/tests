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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-server-shared.sh

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

cat /dev/shm/env.sh #TODO
########################################################################



PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"


        #####################################################################
        #               IS THIS MACHINE A CLIENT1?                          #
        #####################################################################
        rc=0

	# Checking if CLIENT1 and CLIENT2 can be identified #TODO	
	SHORT_HOST1=`cat /dev/shm/env.sh | grep BEAKERCLIENT |  cut -d "=" -f 2 | cut -d " " -f 1 | cut -d . -f 1`
	CLIENT1=$SHORT_HOST1.$DOMAIN

	echo $HOSTNAME
	echo $CLIENT1
        echo $CLIENT1 | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                rlLog "Machine in recipe is CLIENT1"
                rlRun "service iptables stop" 0 "Stop the firewall on the client"
                rhts-sync-set -s DONE
		rhts-sync-block -s HBACSVC_SETUP $MASTER 
		hbacsvc_client1
		rhts-sync-set -s HBACSVC_DONE
        else
                rlLog "Machine in recipe in not a CLIENT1"
        fi

        #####################################################################

        #####################################################################
        #               IS THIS MACHINE A CLIENT2?                          #
        #####################################################################
        rc=0

        # Checking if CLIENT1 and CLIENT2 can be identified #TODO       
        SHORT_HOST2=`cat /dev/shm/env.sh | grep BEAKERCLIENT | cut -d " " -f 3 | cut -d . -f 1`
        CLIENT2=$SHORT_HOST2.$DOMAIN

	echo $HOSTNAME
	echo $CLIENT2
        echo $CLIENT2 | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                rlLog "Machine in recipe is CLIENT2"
                rlRun "service iptables stop" 0 "Stop the firewall on the client"
                rhts-sync-set -s DONE
		rhts-sync-block -s HBACSVC_SETUP $MASTER 
		hbacsvc_client2
		rhts-sync-set -s HBACSVC_DONE
        else
                rlLog "Machine in recipe in not a CLIENT2"
        fi

        #####################################################################

        #####################################################################
        #               IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0
	echo $HOSTNAME
	echo $MASTER
        echo $MASTER | grep `hostname -s`
        if [ $? -eq 0 ] ; then
                rlLog "Machine in recipe is MASTER"

	rlPhaseStartSetup "ipa-hbacsvc-func: Setup of users"

        	rlRun "cat /dev/shm/env.sh" #TODO
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


                rhts-sync-block -s DONE -s DONE $CLIENT1 $CLIENT2
		hbacsvc_setup
		rhts-sync-set -s HBACSVC_SETUP
               	rhts-sync-block -s HBACSVC_DONE -s HBACSVC_DONE $CLIENT1 $CLIENT2

	rlPhaseStartCleanup "ipa-hbacrule-func-cleanup: Destroying admin credentials."
        	# delete service group
	        rlRun "ipa hbacsvcgroup-del $servicegroup" 0 "CLEANUP: Deleting service group $servicegroup"

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
