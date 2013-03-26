#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/install-client-cli
#   Description: IPA Client Install and Uninstall tests
#   Author: Namita Krishnan <namita.krishnan@redhat.com>
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include the data file to verify tests
. ./data.ipaclientinstall.acceptance

# Include test case file
. ./t.ipa-client-install.sh
. ./t.client-install-primary-server.sh
. ./lib.ipaclientverify.sh
. ./t.ipa-client-install.bug.sh
#. ../quickinstall/install-lib.sh
. ../quickinstall/ipa-install.sh
. /opt/rhqa_ipa/lib.ipa-rhts.sh


PACKAGE="ipa-client"
SERVICE="ipa_kpasswd"
HOSTNAME=$(hostname)

##########################################
#   test main
#########################################

rlJournalStart
   rlPhaseStartTest "Environment Check"
        rlLog "Creating tmp directory"
        TmpDir=`mktemp -d`
        pushd $TmpDir
	setup_iparhts_sync
        slave_count=$(echo $SLAVE | wc -w)
        echo "Slave count is $slave_count"
        #####################################################################
        #               IS THIS MACHINE A CLIENT?                           #
        #####################################################################

	echo "$CLIENT" | grep "$HOSTNAME"
	if [ $? -eq 0 ]; then
           # This machine is a client
	   rlLog "I am a client"
	   rlLog "syncing date"
           ntpdate $NTPSERVER
           export currenthour=$(date +%H) # Get the current hours to be used in a later test
           #date --set='-2 hours' # Set the date on this machine back two hours for ipa-client-install to fix later
           rlLog "Current date is $(date)"
          if [ $slave_count -eq 3 ];then
           rlLog "Executing test cases with 1 Master and 3 Replicas"
           ipaclientinstall
           clientinstall_primary_server
           ipa_bug_verification
          else
           rlLog "Executing test cases with 1 Master and 1 Replica"
           ipaclientinstall
           ipa_bug_verification
          fi
           uninstall_fornexttest # Ensure cleanup
	   rlRun "iparhts-sync-set -s DONE"
	  if [ $slave_count -eq 1 ];then
           dynamic_update_client # run client tests covering the dynamic update feature
	  fi
	else
	   rlLog "Not a client, CLIENT is $CLIENT - not running tests"
	fi

        #####################################################################
        #               IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0
        echo $MASTER | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
		ipamastersetup
                rlRun "iparhts-sync-block -s DONE $BEAKERCLIENT"
		if [ $slave_count -eq 1 ];then
			dynamic_update_master # Run portion of tests covering the dynamic update feature
		fi
		ipamastercleanup
                rlPass
        else
                rlLog "Machine in recipe in not a MASTER"
        fi

        #####################################################################
        #               IS THIS MACHINE A SLAVE?                            #
        #####################################################################
        rc=0
        for R in $(eval echo $SLAVE); do
         echo $R | grep $HOSTNAME
          if [ $? -eq 0 ] ; then
                rlRun "iparhts-sync-block -s DONE $BEAKERCLIENT"
                rlPass
          else
                rlLog "Machine in recipe in not a SLAVE"
          fi
        done


   rlPhaseEnd


rlPhaseStartCleanup "install-client-cli cleanup"
     rlRun "popd"
#     rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
rlPhaseEnd
        
rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report
        save_logs
rlJournalEnd 
