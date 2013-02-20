#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipajoin
#   Description: IPA ipajoin acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Yi Zhang <yzhang@redhat.com>
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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test case file
. ./lib.ipajoin.sh
. ./t.ipajoin.sh
. ./t.ipaotp.sh

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`
TmpDir=`mktemp -d`
##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartTest "Machine Check and execution"
        myhostname=`hostname`
        rlLog "hostname command: $myhostname"
        rlLog "HOSTNAME: $HOSTNAME"
        rlLog "MASTER: $MASTER"
        rlLog "SLAVE: $SLAVE"
        rlLog "CLIENT: $CLIENT"
        rlLog "BEAKERMASTER: $BEAKERMASTER"
        rlLog "BEAKERSLAVE: $BEAKERSLAVE"
        rlLog "BEAKERCLIENT: $BEAKERCLIENT"
   
        #echo "export BEAKERMASTER=$MASTER" >> /dev/shm/env.sh
        #echo "export BEAKERSLAVE=$SLAVE" >> /dev/shm/env.sh

        #####################################################################
        #               IS THIS MACHINE A CLIENT?                           #
        #####################################################################
        rc=0
        echo $CLIENT | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
            if [ $rc -eq 0 ] ; then
                ipajoin
                rhts-sync-set -s DONE
            fi
        else
            rlLog "Machine in recipe in not a CLIENT"
        fi


        #####################################################################
        # 		IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0
        echo $MASTER | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
            rhts-sync-block -s DONE $BEAKERCLIENT
        else
            rlLog "Machine in recipe in not a MASTER"
        fi

        #####################################################################
        # 		IS THIS MACHINE A SLAVE?                            #
        #####################################################################
        rc=0
        echo $SLAVE | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
            rhts-sync-block -s DONE $BEAKERCLIENT
        else
            rlLog "Machine in recipe in not a SLAVE"
        fi
    rlPhaseEnd

    rlJournalPrintText
    report=/tmp/rhts.report.$RANDOM.txt
    makereport $report
    rhts-submit-log -l $report
rlJournalEnd

# manifest:
