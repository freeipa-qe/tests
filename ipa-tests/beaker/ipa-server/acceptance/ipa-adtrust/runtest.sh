#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-adtrust
#   Description: Adtrust test cases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <sgoveas@redhat.com>
#   Date  : August 13, 2012
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

# Install samba-common package if not already installed
cat /etc/redhat-release | grep "Red Hat"
if [ $? -eq 0 ]; then
  rpm1="ipa-server-trust-ad"
else
  rpm1="freeipa-server-trust-ad"
fi

rpm2="expect"
rpm3="telnet"
rpm4="coreutils"
rpm5="glibc-common"
rpm6="openssh-clients"
rpm7="samba4-common"

rlJournalStart

   rlCheckRpm "$rpm1"
	if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm1"
        fi

   rlCheckRpm "$rpm2"
        if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm2"
        fi
   
   rlCheckRpm "$rpm3"
	if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm3"
        fi

   rlCheckRpm "$rpm4"
	if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm4"
        fi

   rlCheckRpm "$rpm5"
	if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm5"
        fi

   rlCheckRpm "$rpm6"
        if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm6"
        fi

   rlCheckRpm "$rpm7"
        if [ $? -ne 0 ]; then
           rlRun "yum install -y $rpm7"
        fi

# Include test case file
. ./t.ipa-adtrust.sh

#PACKAGE="ipa-server"
##########################################
#   Sanity Tests
#########################################

	adtrust_connect() {
		"adtrust_test_0001"
		"adtrust_test_0002"
		"adtrust_test_0003"
		"adtrust_test_0004"
		"adtrust_test_0005"
		"adtrust_test_0006"
		"adtrust_test_0007"
		"adtrust_test_0008"
#		"adtrust_test_0009"
	}


    rlPhaseStartSetup "ipa-adtrust-startup: Check for admintools package, setup certificates."
		rlRun "setup"
    rlPhaseEnd

	# tests start...
adtrust_connect
	# tests end...

    rlPhaseStartCleanup "ipa-adtrust-cleanup: Destroying admin credentials & removing certificates."
		rlRun "cleanup"
    rlPhaseEnd


rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
