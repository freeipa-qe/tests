#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/install
#   Description: LSB Compliance testing of sssd initscripts
#   Author: Michael Gregg <mgregg@redhat.com>
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
. /usr/lib/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

PACKAGE="ipa-server"
SERVICE="ipa_kpasswd"

rlJournalStart
	rlPhaseStartSetup
		env
		/etc/init.d/ntpd stop
		ntpdate $NTPSERVER
		# Backing up resolv.conf
		rlRun "rm -f /dev/shm/resolv.conf.ipabackup" 0 "Backing up resolv.conf"
		rlRun "fixResolv" 0 "fixing the reoslv.conf to contain the correct nameserver lines"
	
		rlRun "ls /dev/shm/ipa-server-shared.sh" 0 "Checking for existance of shared libs"
		if [ ! -f /dev/shm/ipa-server-shared.sh ]; then
			echo "ERROR - /dev/shm/ipa-server-shared.sh does not exist, did the shared libs get installed?"
		fi
		hostname_s=$(hostname -s)
		echo "$SLAVE" | grep "$HOSTNAME"
		if [ $? -eq 0 ]; then
			echo "this is a slave, wait for the replica file"
			if [ ! -f /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg ]; then
				echo "waiting for replica file"
				sleep 300
				if [ ! -f /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg ]; then
					echo "waiting for replica file"
					sleep 300
					if [ ! -f /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg ]; then
						echo "ERROR - replica file not found, did the master install work properly?"
						rlRun "ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Checking for existance of replica gpg file"
					fi
				fi
			fi
			rlRun "ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Checking for existance of replica gpg file"
		else
			echo "This is the master, sleeping for 1.5 minutes"
			echo "SLAVE list is $SLAVE, MASTER list is $MASTER, CLIENT list is $CLIENT"
			sleep 90
		fi
	rlPhaseEnd

	rlPhaseStartTest "IPA start test section"
		echo "$SLAVE" | grep "$HOSTNAME"
		if [ $? -eq 0 ]; then
			# This machine is a slave
			echo "I am a slave/replica"
			rlRun "ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Checking for existance of replica gpg file"
			echo "ipa-replica-install -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
			chmod 755 /dev/shm/replica-install.bash
			bash /dev/shm/replica-install.bash
		else
			echo "not a slave, SLAVE is $SLAVE"
		fi

		# Create expect file to kinit with
		echo '#!/usr/bin/expect -f
set force_conservative 0  ;# set to 1 to force conservative mode even if
                          ;# script was not run conservatively originally
if {$force_conservative} {
        set send_slow {1 .1}
        proc send {ignore arg} {
                sleep .1
                exp_send -s -- $arg
        }
}
set timeout 50
spawn kinit admin
match_max 100000
#send -- "passwd root\r"
expect ": "
send -- "Secret123\r"
expect eof' > /dev/shm/kinit-admin.exp
		rlRun "cat /dev/shm/kinit-admin.exp"
		rlRun "kdestroy"
	rlPhaseEnd

	rlPhaseStartTest "Verify that krb5.conf was set up properly"
		rlRun  "grep $DOMAIN /etc/krb5.conf" 0 "Checking to ensure that krb5.conf was set up correctly"
		echo " " 
		echo " " 
		echo " " 
		echo "Contents of krb5.conf:"
		cat /etc/krb5.conf
		echo " " 
		echo " " 
		echo " " 
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "ls /tmp"
		rlRun "ls /root"
		rlRun "ls /etc/yum.repos.d"
		if [ -f /var/log/ipaserver-install.log ]; then
			rhts-submit-log -l /var/log/ipaserver-install.log
		fi
	rlPhaseEnd

rlJournalPrintText
rlJournalEnd 
