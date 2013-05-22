#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/install-client-cli
#   Description: IPA Client Install and Uninstall tests
#   Author: Namita Krishnan <namita.krishnan@redhat.com>
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include the data file to verify tests
. ./data.ipaserverinstall.acceptance

# Include test case file
. ./t.ipa-server-install.sh
. ./lib.ipaserververify.sh
#. ../quickinstall/install-lib.sh
. /opt/rhqa_ipa/install-lib.sh

##########################################
#   test main
#########################################

rlJournalStart
   rlPhaseStartSetup "Environment Check"
        rlLog "Creating tmp directory"
        TmpDir=`mktemp -d`
        pushd $TmpDir
   rlPhaseEnd

	echo "$MASTER" | grep "$HOSTNAME"
	if [ $? -eq 0 ]; then
           # This machine is a master
	   rlLog "I am a master"
           ipaserverinstall
	else
	   rlLog "Not a master, MASTER is $MASTER - not running tests"
	fi

rlPhaseStartCleanup "install-server-cli cleanup"
     rlRun "popd"
     rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
rlPhaseEnd
        
rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report
rlJournalEnd 
