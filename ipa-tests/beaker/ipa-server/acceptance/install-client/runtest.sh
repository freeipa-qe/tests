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
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

PACKAGE="ipa-client"
SERVICE="ipa_kpasswd"

rlJournalStart
	rlPhaseStartSetup
		env
		rlRun "ls /dev/shm/ipa-server-shared.sh"
		if [ ! -f /dev/shm/ipa-server-shared.sh ]; then
			echo "ERROR - /dev/shm/ipa-server-shared.sh does not exist, did the shared libs get installed?"
		fi
		echo "$CLIENT" | grep "$HOSTNAME"
		if [ $? -eq 0 ]; then
			echo "this is a client, wait for the ldap port to be open on the master"
			nmap -p 389 $MASTER | grep 389
			if [ $? -ne 0 ]; then
				echo "ldap not open on master yet"
				sleep 300
				nmap -p 389 $MASTER | grep 389
				if [ $? -ne 0 ]; then
				echo "ldap not open on master yet"
					sleep 300
					nmap -p 389 $MASTER | grep 389
					if [ $? -ne 0 ]; then
						echo "ERROR - ldap not open on master. Is everything alright?"
						# This next line will produyce a error
						rlRun "ls /dev/shm/replica-info-$HOSTNAME.gpg"
					fi
				fi
			fi
		fi
		sleep 10
		echo "Fixing resolv.con to point to master"
		sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
		echo "nameserver $MASTER" >> /etc/resolv.conf
	rlPhaseEnd

	rlPhaseStartTest "IPA start test section"
		echo "$CLIENT" | grep "$HOSTNAME"
		if [ $? -eq 0 ]; then
			# This machine is a client
			rlLog "I am a client"
			rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring"
			rlLog "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER"
			#chmod 755 /dev/shm/client-install.bash
			#bash /dev/shm/client-install.bash
		else
			echo "not a client, CLIENT is $CLIENT"
			echo "SLAVE list is $SLAVE, MASTER list is $MASTER, CLIENT list is $CLIENT"
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
		rlRun  "grep $RELM /etc/krb5.conf" 0 "Checking to ensure that krb5.conf was set up correctly"
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
