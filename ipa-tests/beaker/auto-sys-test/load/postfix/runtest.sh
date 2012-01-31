#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/automation-and-system-test/load/postfix-setup
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
. /dev/shm/env.sh
. /dev/shm/ipa-server-shared.sh

# Include test case file
. ./t.postfix-setup.sh

rlJournalStart
	HOSTNAME=$(hostname -s)
        myhostname=`hostname`
        rlLog "hostname command: $myhostname"
        rlLog "HOSTNAME: $HOSTNAME"
        rlLog "MASTER: $MASTER"
        rlLog "SLAVE: $SLAVE"
        rlLog "CLIENT: $CLIENT"

	rlPhaseStartTest "make sure files exist"
		rlRun "ls /dev/shm/ipa-server-shared.sh" 0 "Checking to make sure /CoreOS/ipa-server/shared package is installed"
		rlRun "ls /dev/shm/main.cf" 0 "Checking to make sure that /CoreOS/automation-and-system-test/shared is installed"
	rlPhaseEnd
	
        #####################################################################
        #               IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0
        echo $MASTER | grep $HOSTNAME
        rc=$?
        if [ $rc -eq 0 ] ; then
		pwdfile=/dev/shm/password.txt
		echo $ADMINPW > $pwdfile
		setenforce 0
		yum -y install postfix cyrus-imapd-utils cyrus-imapd cyrus-sasl-ldap
		/etc/init.d/sendmail stop
		/sbin/chkconfig --levels 2345 sendmail off
		/sbin/chkconfig --levels 2345 postfix on
		/sbin/chkconfig --levels 2345 cyrus-imapd on
		setup-dns
		setup-postfix
		setup-cyrus
		setenforce 1
        else
                rlLog "Machine in recipe is not the MASTER - not running setup"
        fi

	rhts-sync-set -s READY

   rlJournalPrintText
   report=/tmp/rhts.report.$RANDOM.txt
   makereport $report
   rhts-submit-log -l $report
rlJournalEnd

