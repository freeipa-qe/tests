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
		if [ ! -f /usr/bin/wget ]; then
			# wget doesn't appear to be installed. Installing now.
			echo ""
			echo "wget doesn't appear to be on this system. Installing it now."
			echo ""
			sleep 2
			yum -y install wget 
		fi
		grep Fedora /etc/redhat-release
		if [ $? -eq 0 ]; then
			rlRun "cd /etc/yum.repos.d;wget http://jdennis.fedorapeople.org/ipa-devel/ipa-devel-fedora.repo" 0 "downloading ipa repo"
		else
			# This is rhel
			grep release\ 5 /etc/redhat-release
			if [ $? -eq 0 ]; then
				# This is RHEL 5
				rlRun "cd /etc/yum.repos.d;wget http://jdennis.fedorapeople.org/ipa-devel/ipa-devel-rhel.repo" 0 "downloading ipa repo"
				rlRun "cd /etc/yum.repos.d;wget http://apoc.dsdev.sjc.redhat.com/tet/beakerlib-fc14/fedora-beaker.repo" 0 "downloading fedora beakerlib repo"
			else
				# This is likley rhel6
				rlRun "cd /etc/yum.repos.d;wget http://apoc.dsdev.sjc.redhat.com/tet/ipa2/ipa-tests/beaker/ipa-server/shared/ipa-rhel6-mickey.repo" 0 " deleting any previously existing beta2 rep"
				rlRun "rm -f /etc/yum/repos.d/rhel6-beta2.repo" 0 " deleting any previously existing beta2 rep"
				rlRun "cp /dev/shm/rhel6-beta2.repo /etc/yum.repos.d/." 0 "copying the rhel6 beta2 repo to the repos.d dir. It should be coming from the shated lib"
			fi
		fi
	
		#rlRun "cd /etc/yum.repos.d;wget http://apoc.dsdev.sjc.redhat.com/tet/ipa-fedora.repo"
		rlRun "rm -f /dev/shm/set*.exp" 0 "removing all old expect scripts"
		rlRun "cd /dev/shm;wget http://apoc.dsdev.sjc.redhat.com/tet/sssd/tests/ipa-server/acceptance/install/set-root-pw.exp" 0 "getting root password reset script"
#		rlRun "expect /dev/shm/set-root-pw.exp"
#		rlRun "yum clean"
		# Run yum install 3 times because the repos are flaky
		packages="ipa-server ipa-client ipa-admintools bind caching-nameserver expect krb5-workstation bind-dyndb-ldap ntpdate krb5-pkinit-openssl rhts-test-env beaker-client beaker-redhat" 
		yum -y install $packages
		if [ $? -ne 0 ]; then
			sleep 100
			yum -y install $packages
			if [ $? -ne 0 ]; then
				sleep 100
				yum clean all
				yum -y install $packages
				if [ $? -ne 0 ]; then
					sleep 100
					yum clean all
					yum -y install $packages
				fi
			fi
		fi
		# Because I want to. 
		yum -y install vim-enhanced&
		/etc/init.d/ntpd stop
		ntpdate $NTPSERVER
		rlRun "rpm -qa | grep ipa-server" 0 "checking for ipa server package installation" 
		#rlAssertRpm $PACKAGE
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
		hostname=$(hostname)
		hostname_s=$(hostname -s)
		cat /etc/hosts | grep -v ^$ipaddr > /dev/shm/hosts	
		# Remove any existing hostname entries from the hosts file
		sed -i s/$hostname//g /dev/shm/hosts
		sed -i s/$hostname_s//g /dev/shm/hosts
		echo "$ipaddr $hostname_s.$DOMAIN $hostname $hostname_s" >> /dev/shm/hosts
		cat /dev/shm/hosts > /etc/hosts
		echo "hosts file contains"
		cat /etc/hosts
		# Fix hostname
		rlRun "hostname $hostname_s.$DOMAIN"
		hostname $hostname_s.$DOMAIN
		cat /etc/sysconfig/network | grep -v $hostname_s > /dev/shm/network
		echo "HOSTNAME=$hostname_s.$DOMAIN" >> /dev/shm/network
		mv /etc/sysconfig/network /etc/sysconfig/network-ipabackup
		cat /dev/shm/network > /etc/sysconfig/network
		echo "/etc/sysconfig/network contains"
		cat /etc/sysconfig/network
		# Fix ntpd.conf, this will likley be temporary
		echo 'OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid -g"' > /etc/sysconfig/ntpd
		# install IPA only if the is the master server
		echo "MASTER is $MASTER, HOSTNAME is $HOSTNAME"
		echo $MASTER | grep $HOSTNAME
		if [ $? -eq 0 ]; then 
			# This is the master server, set up ipa-server
			grep release\ 5 /etc/redhat-release
			if [ $? -eq 0 ]; then
				# This is RHEL 5
			echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /dev/shm/installipa.bash
			else
				# This is likley rhel6
			echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /dev/shm/installipa.bash
			fi

			setenforce 0
			/bin/bash /dev/shm/installipa.bash
		else
			echo "not a master, sleeping for 500 sec"
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
					# Determine the IP of the slave to be used when creating the replica file.
					ipofs=$(dig +noquestion $s  | grep $s | grep IN | awk '{print $5}')
					# put the short form of the hostname for server $s into s_short
					s_short=$(echo $s | cut -d. -f1)
					echo "IP of server $s is resolving as $ipofs, using short hostname of $s_short" 
					ipa-replica-prepare -p $ADMINPW --ip-address=$ipofs $s_short.$DOMAIN
					# Copy the replica info to the slave
					rlRun "scp /var/lib/ipa/replica-info-$s_short.$DOMAIN.gpg root@$s:/dev/shm/."
				fi
			done
		fi

		# Adding MASTER and SLAVE bits to env.sh
		echo "export MASTER=$MASTER" >> /dev/shm/env.sh
		echo "export SLAVE=$SLAVE" >> /dev/shm/env.sh
		echo "export CLIENT=$CLIENT" >> /dev/shm/env.sh
		echo "Contents of env.sh are"
		cat /dev/shm/env.sh
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
