#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-replica-install
#   Description: IPA Replica install tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
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
ZONE1=4.2.2.in-addr.arpa.
ZONE2=3.2.2.in-addr.arpa.

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include tests file
. ./t.replica-install.sh
. ./t.replica-install.bug.sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

########################################################################

# Checking hostnames of all hosts
echo "The hostname of IPA Server is $MASTER"
echo "The beaker hostname of IPA Server is $BEAKERMASTER"

cat /dev/shm/env.sh
########################################################################

# If you change the style of setting MYROLE, remember
# that $SLAVE could be a space delimited list of replicas
if   [ $(echo "$MASTER" | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=MASTER
elif [ $(echo "$SLAVE"  | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=SLAVE
elif [ $(echo "$CLIENT" | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=CLIENT
else
	MYROLE=UNKNOWN
fi

PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"

rlJournalStart

	#####################################################################

	#####################################################################
	#               IS THIS MACHINE A MASTER?                           #
	#####################################################################
	rc=0

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of master is $MASTER"

	myhostname=`hostname`
	rlLog "hostname command: $myhostname"
	rlLog "HOSTNAME: $HOSTNAME"
	rlLog "MASTER: $MASTER"
	rlLog "SLAVE: $SLAVE"
	rlLog "CLIENT: $CLIENT"
	rlLog "CLIENT2: $CLIENT2"

	eval "echo \"export BEAKERMASTER=$MASTER\" >> /dev/shm/env.sh"
	eval "echo \"export BEAKERSLAVE=$SLAVE\" >> /dev/shm/env.sh"
	eval "echo \"export BEAKERCLIENT=$CLIENT\" >> /dev/shm/env.sh"
	eval "echo \"export BEAKERCLIENT2=$CLIENT2\" >> /dev/shm/env.sh"
	MASTER_S=`echo $MASTER | cut -d . -f 1`
	eval "echo \"export MASTER=$MASTER_S.$DOMAIN\" >> /dev/shm/env.sh"
	SLAVE_S=`echo $SLAVE | cut -d . -f 1`
	eval "echo \"export SLAVE=$SLAVE_S.$DOMAIN\" >> /dev/shm/env.sh"

	. /dev/shm/env.sh

	ipofm=`dig +short $BEAKERMASTER`
	ipofs=`dig +short $BEAKERSLAVE`

	eval "echo \"export MASTERIP=$ipofm\" >> /dev/shm/env.sh"
	eval "echo \"export SLAVEIP=$ipofs\" >> /dev/shm/env.sh"

	. /dev/shm/env.sh
	cat /dev/shm/env.sh

	echo $BEAKERMASTER | grep $HOSTNAME
	if [ $? -eq 0 ] ; then
		rlLog "Machine in recipe is MASTER"

		rlPhaseStartSetup "ipa-install: ipa-server installation"

			rlRun "service iptables stop" 0 "Stop the firewall on the MASTER"
			rlRun "service ip6tables stop" 0 "Stop the ipv6 firewall on the MASTER"
			rlRun "cat /dev/shm/env.sh"
			rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
			rlRun "pushd $TmpDir"

		rlPhaseEnd

		rlPhaseStartTest "MASTER tests start"
			installMaster
			createReplica1

			rhts-sync-set -s READY_REPLICA1 $BEAKERMASTER
			rhts-sync-block -s DONE_REPLICA1 $BEAKERSLAVE

			createReplica3

			rhts-sync-set -s READY_REPLICA3 $BEAKERMASTER
			rhts-sync-block -s DONE_REPLICA3 $BEAKERSLAVE

			createReplica4

			rhts-sync-set -s READY_REPLICA4 $BEAKERMASTER
			rhts-sync-block -s DONE_REPLICA4 $BEAKERSLAVE

			createReplica2

			rhts-sync-set -s READY_REPLICA2 $BEAKERMASTER
			rhts-sync-block -s DONE_REPLICA2 $BEAKERSLAVE
	
			replicaBugCheck_bz769545

		rlPhaseEnd

		rlPhaseStartCleanup "ipa-ca-install: ipa-server clean up."
			# dummy section
			rlLog "dummy section"
		rlPhaseEnd


	else
		rlLog "Machine in recipe in not a MASTER"
	fi

	#####################################################################


	#####################################################################
	#               IS THIS MACHINE A SLAVE?                            #
	#####################################################################
	rc=0
	echo $BEAKERSLAVE | grep $HOSTNAME
	if [ $? -eq 0 ] ; then

		rlPhaseStartSetup "ipa slave install: ipa-server slave installation"

			rlRun "service iptables stop" 0 "Stop the firewall on the MASTER"
			rlRun "service ip6tables stop" 0 "Stop the ipv6 firewall on the MASTER"
			rlRun "cat /dev/shm/env.sh"
			rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
			rlRun "pushd $TmpDir"

		rlPhaseEnd

		rlPhaseStartTest "SLAVE tests start"

			rlLog "Setting up Authorized keys"
			rlLog "Setting up known hosts file"
			SetUpAuthKeys
			SetUpKnownHosts

			rhts-sync-block -s READY_REPLICA1 $BEAKERMASTER
			installSlave
			installCA
			replicaBugCheck_bz784696
			replicaBugCheck_bz845405
			uninstall

			diableIpv6
			installBug_bz839004
			uninstall
			enableIpv6

			installSlave_nr1
			uninstall
			rhts-sync-set -s DONE_REPLICA1 $BEAKERSLAVE

			# Installing slave with --no-forwarders
			rhts-sync-block -s READY_REPLICA3 $BEAKERMASTER
			installSlave_nf
			uninstall
			rhts-sync-set -s DONE_REPLICA3 $BEAKERSLAVE
			
			rhts-sync-block -s READY_REPLICA4 $BEAKERMASTER
			# Installing slave with --no-reverse
			installSlave_nr2
			uninstall

			installSlave_nr3
			uninstall
			rhts-sync-set -s DONE_REPLICA4 $BEAKERSLAVE

			rhts-sync-block -s READY_REPLICA2 $BEAKERMASTER
			# Installing with --ssh-trust-dns
			installSlave_sshtrustdns
			uninstall

			# Installing with --configure-sshd
			installSlave_configuresshd
			uninstall

			# Installing with --no-dns-sshfp
			installSlave_nodnssshfp
			uninstall

			# Installing slave with --no-host-dns
			installSlave_nhostdns
			uninstall

			# Installing slave with --no-ui-redirect
			installSlave_nouiredirect
			uninstall

			# Install slave with negative tests for blocked ports
			installSlave_negative1

			# Installing slave with --setup-ca
			installSlave_ca
				
			# Test other bugs not covered directly in above tests

			rhts-sync-set -s DONE_REPLICA2 $BEAKERSLAVE
		rlPhaseEnd

		rlPhaseStartCleanup "ipa-ca-install: ipa-server clean up."
			# dummy section
			rlLog "dummy section"
		rlPhaseEnd

	else
		rlLog "Machine in recipe in not a SLAVE"
	fi

	rlJournalPrintText
	report=$TmpDir/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report
rlJournalEnd
