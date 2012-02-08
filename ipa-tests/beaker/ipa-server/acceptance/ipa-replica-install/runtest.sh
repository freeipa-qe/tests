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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include tests file
. ./t.replica-install.sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

########################################################################

# Checking hostnames of all hosts
echo "The hostname of IPA Server is $MASTER"
echo "The beaker hostname of IPA Server is $BEAKERMASTER"

cat /dev/shm/env.sh
########################################################################



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



        echo $MASTER | grep $HOSTNAME
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
		createReplica2
		createReplica3

                rhts-sync-set -s READY $BEAKERMASTER
		rhts-sync-block -s DONE $BEAKERSLAVE

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
        echo $SLAVE | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                yum clean all

                if [ $rc -eq 0 ] ; then
                        rhts-sync-block -s READY $BEAKERMASTER
                        installSlave
			installCA
                        rhts-sync-set -s DONE $BEAKERSLAVE
                        rlLog "Setting up Authorized keys"
                        SetUpAuthKeys
                        rlLog "Setting up known hosts file"
                        SetUpKnownHosts
                fi
        else
                rlLog "Machine in recipe in not a SLAVE"
	fi


rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
