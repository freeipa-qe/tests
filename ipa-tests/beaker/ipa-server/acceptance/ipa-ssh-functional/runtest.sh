#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-ssh-functional
#   Description: IPA ipa-test-template acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Jul 26, 2012
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case files
for file in $(ls tests.d/t.*.sh); do
	. ./$file
done

PACKAGE="ipa-admin"

startDate=`date "+%F %r"`
satrtEpoch=`date "+%s"`

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
##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-ssh-functional startup - setup tempdir to run from"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

	ipa_user_add_ssh_run
	ipa_user_mod_ssh_run
	ipa_selfservice_ssh_run
	ipa_delegation_ssh_run

	ipa_host_add_ssh_run
	ipa_host_mod_ssh_run

	ipa_ssh_user_func_run
	ipa_ssh_host_func_run

	ipa_ssh_bug_run

    rlPhaseStartCleanup "ipa-test-template cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd

# manifest:


