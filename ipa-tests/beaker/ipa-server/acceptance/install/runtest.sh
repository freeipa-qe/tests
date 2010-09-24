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

PACKAGE="ipa-server"
HOSTSFILE="/etc/hosts"
SERVICE="ipa_kpasswd"

rlJournalStart
	rlPhaseStartSetup
		env
		rlRun "ls /dev/shm/ipa-server-shared.sh"
		if [ ! -f /dev/shm/ipa-server-shared.sh ]; then
			echo "ERROR - /dev/shm/ipa-server-shared.sh does not exist, did the shared libs get installed?"
		fi
		rlRun "rm -f /etc/yum.repos.d/ipa*"
		rlRun "cd /etc/yum.repos.d;wget http://jdennis.fedorapeople.org/ipa-devel/ipa-devel-fedora.repo"
		#rlRun "cd /etc/yum.repos.d;wget http://apoc.dsdev.sjc.redhat.com/tet/ipa-fedora.repo"
		rlRun "rm -f /dev/shm/set*.exp"
		rlRun "cd /dev/shm;wget http://apoc.dsdev.sjc.redhat.com/tet/sssd/tests/ipa-server/acceptance/install/set-root-pw.exp"
#		rlRun "expect /dev/shm/set-root-pw.exp"
#		rlRun "yum clean"
		# Run yum install 3 times because the repos are flaky
		packages="ipa-server ipa-client ipa-admintools bind caching-nameserver expect krb5-workstation bind-dyndb-ldap"
		yum -y install $packages
		if [ $? -ne 0 ]; then
			sleep 200
			yum -y install $packages
			if [ $? -ne 0 ]; then
				sleep 200
				yum clean all
				yum -y install $packages
				if [ $? -ne 0 ]; then
					sleep 200
					yum clean all
					yum -y install $packages
				fi
			fi
		fi
		rlRun "rpm -qa ipa-server" 
		rlAssertRpm $PACKAGE
		# Back up the local hosts file 
#		rlFileBackup $HOSTSFILE
		rlRun "rm -f $HOSTSFILE.ipabackup"
		rlRun "cp -af $HOSTSFILE $HOSTSFILE.ipabackup"
		# figure out what my active eth is from the machine's route
		currenteth=$(route | grep ^default | awk '{print $8}')
		# get the ip address of that interface
		ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
		echo "Ip address is $ipaddr"
		# Now, fix the hosts file to work with IPA.
		cat /etc/hosts | grep -v ^$ipaddr > /dev/shm/hosts	
		hostname=$(hostname)
		hostname_s=$(hostname -s)
		sed -i s/$hostname//g /dev/shm/hosts
		sed -i s/$hostname_s//g /dev/shm/hosts
		echo "$ipaddr $hostname" >> /dev/shm/hosts
		cat /dev/shm/hosts > /etc/hosts
		echo "hosts file contains"
		cat /etc/hosts
		rlRun "ls /root"
		# install IPA only if the is the master server
		if [ "$MASTER" = "$HOSTNAME" ]; then 
			# This is the master server, set up ipa-server
			echo "ipa-server-install --setup-dns --forwarder=10.14.63.12 --hostname=$hostname -r testrelm -n testdomain -p Secret123 -P Secret123 -a Secret123 -u admin -U" > /dev/shm/installipa.bash
			setenforce 0
			/bin/bash /dev/shm/installipa.bash
		else
			sleep 500
		fi
		rlRun "cat /etc/krb5.conf"
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
		if [ "$MASTER" = "$HOSTNAME" ]; then 
			# This is the master server, make sure kinit works.
			expect /dev/shm/kinit-admin.exp
			rlRun "klist"
		fi

		# setup ssh key files
		for s in $CLIENT; do
			if [ "$s" != "" ]; then
				AddToKnownHosts $s
			fi
		done
		for s in $MASTER; do
			if [ "$s" != "" ]; then
				AddToKnownHosts $s
			fi
		done
		for s in $SLAVE; do
			if [ "$s" != "" ]; then
				AddToKnownHosts $s
			fi
		done

		# Set up ipa server clone files 
		if [ "$MASTER" = "$HOSTNAME" ]; then 
			# This is the master server, create the replictation certs
			for s in $SLAVE; do
				if [ "$s" != "" ]; then
					ipa-replica-prepare -p Secret123 $s
					# Copy the replica info to the slave
					rlRun "scp /var/lib/ipa/replica-info-$s.gpg root@$s:/dev/shm/."
				fi
			done
		fi

		rlRun "cat /dev/shm/kinit-admin.exp"
		rlRun "kdestroy"

	rlPhaseEnd

	rlPhaseStartTest "IPA start test section"
		rlServiceStop $SERVICE

		rlServiceRestore $SERVICE
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
