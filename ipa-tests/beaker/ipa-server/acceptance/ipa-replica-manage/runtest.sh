#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-replica-manage
#   Description: IPA ipa-replica-manage Acceptance Test Suite
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : May 23, 2012
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test case files
for file in $(ls tests.d/t.*.sh); do
	. ./$file
done

IRMVERSION=2.1.90

PACKAGE="ipa-admintools"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`

# If you change the style of setting MYROLE, remember
# that $SLAVE could be a space delimited list of replicas
if   [ $(echo "$MASTER" | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=MASTER
elif [ $(echo "$SLAVE"  | awk '{print $1}' | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=SLAVE1
elif [ $(echo "$SLAVE"  | awk '{print $2}' | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=SLAVE2
elif [ $(echo "$SLAVE"  | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=SLAVE
elif [ $(echo "$CLIENT" | grep $(hostname -s)|wc -l) -gt 0 ]; then
	MYROLE=CLIENT
else
	MYROLE=UNKNOWN
fi

MASTER_IP=$(dig +short $MASTER)
SLAVE1=$(echo "$SLAVE"|awk '{print $1}'|cut -f1 -d.|sed s/$/.$DOMAIN/)
SLAVE1_IP=$(dig +short $SLAVE1)
SLAVE2=$(echo "$SLAVE"|awk '{print $2}'|cut -f1 -d.|sed s/$/.$DOMAIN/)
SLAVE2_IP=$(dig +short $SLAVE2)

echo "export SLAVE1=$SLAVE1" >> /dev/shm/env.sh
echo "export SLAVE1_IP=$SLAVE1_IP" >> /dev/shm/env.sh
echo "export SLAVE2=$SLAVE2" >> /dev/shm/env.sh
echo "export SLAVE2_IP=$SLAVE2_IP" >> /dev/shm/env.sh

echo "export BEAKERSLAVE1=${BEAKERREPLICA1_env1}" >> /dev/shm/env.sh
echo "export BEAKERSLAVE2=${BEAKERREPLICA2_env1}" >> /dev/shm/env.sh

if [ -z "$MYENV" ]; then
	MYENV=1
fi

BEAKERSLAVE1=$(eval echo \$BEAKERREPLICA1_env${MYENV})
BEAKERSLAVE2=$(eval echo \$BEAKERREPLICA2_env${MYENV})

TESTORDER=0

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-replica-manage startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
		rlRun "env|sort"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

	irm_envsetup
	irm_run
	irm_envcleanup

    rlPhaseStartCleanup "ipa-replica-manage cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd

# manifest:


