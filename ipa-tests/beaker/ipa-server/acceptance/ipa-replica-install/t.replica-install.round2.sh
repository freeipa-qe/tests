#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-replica-install
#   Description: IPA Replica install tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: 
#	     Gowrishankar Rajaiyan <gsr@redhat.com>
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. ./install-lib.sh
. ./t.replica-install.bug.sh
. ./t.replica-install.sh

uninstallSlave()
{
	TESTORDER=$(( TESTORDER += 1 ))

	rlPhaseStartTest "uninstallSlave - quick and simple uninstall for SLAVE"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER | grep $SLAVE|wc -l) -gt 0 ]; then
			rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE -f"
		fi
		if [ -f /var/lib/ipa/replica-info-$SLAVE.gpg ]; then
			rlRun "rm -f /var/lib/ipa/replica-info-$SLAVE.gpg"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		if [ $(ipactl status 2>&1|grep "IPA is not configured"|wc -l) -eq 0 ]; then
			rlRun "ipa-server-install --uninstall -U"
		fi
		if [ $(ps -ef|grep "[s]ssd.*$DOMAIN"|wc -l) -gt 0 ]; then
			rlRun "service sssd stop"
		fi
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "rm -f /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi
		if [ -f /opt/rhqa_ipa/replica-info-$SLAVE.gpg ]; then
			rlRun "rm -f /opt/rhqa_ipa/replica-info-$SLAVE.gpg"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

installSlave_nr_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	SLAVE_S=$(echo $SLAVE|cut -f1 -d.)
	MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	ZONE1=4.2.2.in-addr.arpa.
	ZONE2=3.2.2.in-addr.arpa.
	rlPhaseStartTest "installSlave_nr_0001 - check that zones are created as expected on replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		[ $(ipa dnszone-find|grep $SLAVEZONE|wc -l) -eq 0 ] && \
			rlRun "ipa dnszone-add $SLAVEZONE --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
		[ $(ipa dnszone-find|grep $ZONE1|wc -l) -eq 0 ] && \
			rlRun "ipa dnszone-add $ZONE1 --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
		[ $(grep $(echo $SLAVE|cut -f1 -d.) /etc/hosts|wc -l) -eq 0 ] && \
			rlRun "echo '$SLAVEIP $SLAVE $SLAVE_S' >> /etc/hosts"

		rlRun "ipa-replica-prepare -p $ADMINPW $SLAVE"

		[ $(ipa dnszone-find|grep $ZONE2|wc -l) -eq 0 ] && \
			rlRun "ipa dnszone-add $ZONE2 --name-server=$MASTER. --admin-email=ipaqar.redhat.com"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		[ $(grep $(echo $SLAVE|cut -f1 -d.) /etc/hosts|wc -l) -eq 0 ] && \
			rlRun "echo '$SLAVEIP $SLAVE $SLAVE_S' >> /etc/hosts"
		
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$SLAVE.gpg /opt/rhqa_ipa"
		rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --no-reverse -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg"

		rlRun "ipa dnszone-show $SLAVEZONE" 
		rlRun "ipa dnszone-show $ZONE1"
		rlRun "ipa dnszone-show $ZONE2"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

installSlave_nr_0001_cleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	SLAVE_S=$(echo $SLAVE|cut -f1 -d.)
	MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	ZONE1=4.2.2.in-addr.arpa.
	ZONE2=3.2.2.in-addr.arpa.
	rlPhaseStartTest "installSlave_nr_0001 - check that zones are created as expected on replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		[ $(ipa dnszone-find|grep $SLAVEZONE|wc -l) -gt 0 ] && \
			rlRun "ipa dnszone-del $SLAVEZONE"
		[ $(ipa dnszone-find|grep $ZONE1|wc -l) -gt 0 ] && \
			rlRun "ipa dnszone-del $ZONE1"
		[ $(ipa dnszone-find|grep $ZONE2|wc -l) -gt 0 ] && \
			rlRun "ipa dnszone-del $ZONE2"
		[ $(grep $(echo $SLAVE|cut -f1 -d.) /etc/hosts|wc -l) -gt 0 ] && \
			rlRun "sed -i '/$SLAVEIP/d' /etc/hosts"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		[ -f /opt/rhqa_ipa/replica-info-$SLAVE.gpg ] && \
			rlRun "rm -f /opt/rhqa_ipa/replica-info-$SLAVE.gpg"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

installSlave_nr_0002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	SLAVE_S=$(echo $SLAVE|cut -f1 -d.)
	MASTER_S=$(echo $MASTER|cut -f1 -d.)
	MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
	ZONE1=4.2.2.in-addr.arpa.
	ZONE2=3.2.2.in-addr.arpa.
	rlPhaseStartTest "installSlave_nr_0002 - check that zones are created as expected on replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		[ $(grep $(echo $SLAVE|cut -f1 -d.) /etc/hosts|wc -l) -eq 0 ] && \
			rlRun "echo '$SLAVEIP $SLAVE $SLAVE_S' >> /etc/hosts"

		rlRun "ipa-replica-prepare -p $ADMINPW $SLAVE"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		[ $(grep $(echo $SLAVE|cut -f1 -d.) /etc/hosts|wc -l) -eq 0 ] && \
			rlRun "echo '$SLAVEIP $SLAVE $SLAVE_S' >> /etc/hosts"
		[ $(grep $(echo $MASTER|cut -f1 -d.) /etc/hosts|wc -l) -eq 0 ] && \
			rlRun "echo '$MASTERIP $MASTER $MASTER_S' >> /etc/hosts"
		
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$SLAVE.gpg /opt/rhqa_ipa"
		rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg"

		rlRun "ipa dnszone-show $SLAVEZONE" 
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
