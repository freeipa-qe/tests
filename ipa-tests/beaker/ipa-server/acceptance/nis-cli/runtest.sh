#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/nis-cli
#   Description: IPA nis-cli acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#   Date  : Sept 10, 2010
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
. /opt/rhqa_ipa/ipa-netgroup-cli-lib.sh
. /opt/rhqa_ipa/nis.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./t.nistests.sh

rlJournalStart
	HOSTNAME=$(hostname -s)
        myhostname=`hostname`
        rlLog "hostname command: $myhostname"
        rlLog "HOSTNAME: $HOSTNAME"
        rlLog "MASTER: $MASTER"
        rlLog "SLAVE: $SLAVE"
        rlLog "CLIENT: $CLIENT"

        #####################################################################
        #               IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0
        echo $MASTER | grep $HOSTNAME
        rc=$?
        if [ $rc -eq 0 ] ; then
		pwdfile=/opt/rhqa_ipa/password.txt
		echo $ADMINPW > $pwdfile
		yum -y install yptools rpcbind ypbind ypserv yp-tools
        	ipa-compat-manage -y $pwdfile enable
        	rlRun "ipa-nis-manage -y $pwdfile enable" 0 "Enable the NIS plugin"
	#	NIS server setup moved to Client
		setup-nis-server
        	/etc/init.d/rpcbind restart
        	/etc/init.d/dirsrv restart
		setup
        	runtests
        	cleanup
        else
                rlLog "Machine in recipe is not the MASTER - not running setup"
        fi

	rhts-sync-set -s READY

        #####################################################################
        #               IS THIS MACHINE A SLAVE?                           #
        #####################################################################
        rc=0
        echo $SLAVE | grep $HOSTNAME
        rc=$?
        if [ $rc -eq 0 ] ; then
		rhts-sync-block -s READY $MASTER
	        rlPhaseStartTest "ipa-nis-cli-slave-bogus-01: A no op test to make sure things are working"
        	        rlRun "/opt/rhqa_ipa/nis.sh" 0 "Check to see that the nis lib is there"
	        rlPhaseEnd

		rhts-sync-set -s READY
	fi

        #####################################################################
        #               IS THIS MACHINE A CLIENT?                           #
        #####################################################################
        rc=0
        echo $CLIENT | grep $HOSTNAME
        rc=$?
        if [ $rc -eq 0 ] ; then
		setup-nis-server
        	/etc/init.d/rpcbind restart
		/etc/init.d/ypbind restart
        fi

   rlJournalPrintText
   report=/tmp/rhts.report.$RANDOM.txt
   makereport $report
   rhts-submit-log -l $report
rlJournalEnd

