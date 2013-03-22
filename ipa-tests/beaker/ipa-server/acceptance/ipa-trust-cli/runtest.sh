#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-trust-cli
#   Description: IPA trust cli test cases
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <sgoveas@redhat.com>
#   Date  : March 07, 2013
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
. /opt/rhqa_ipa/env.sh

# Install samba-common package if not already installed
cat /etc/redhat-release | grep "Red Hat"
if [ $? -eq 0 ]; then
  rpm1="ipa-server-trust-ad"
  rpm5="samba4-common"
else
  rpm1="freeipa-server-trust-ad"
  rpm5="samba-common"
fi

rpm2="expect"
rpm3="coreutils"
rpm4="glibc-common"
rpm6="telnet"

rlJournalStart
  rlPhaseStartSetup "Check for essential RPM packages"

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
  rlPhaseEnd

# Include test case file
. ./t.ipa-trust-cli.sh

#PACKAGE="ipa-server"
##########################################
#   Sanity Tests
#########################################

	trust_connect() {
		"trust_test_0001"
		"trust_test_0002"
		"trust_test_0003"
		"trust_test_0004"
		"trust_test_0005"
		"trust_test_0006"
		"trust_test_0007"
		"trust_test_0008"
		"trust_test_0009"
		"trust_test_0010"
		"trust_test_0011"
		"trust_test_0012"
		"trust_test_0013"
		"trust_test_0014"
		"trust_test_0015"
		"trust_test_0016"
		"trust_test_0017"
		"trust_test_0018"
		"trust_test_0019"
		"trust_test_0020"
		"trust_test_0021"
		"trust_test_0022"
		"trust_test_0023"
		"trust_test_0024"
		"trust_test_0025"
		"trust_test_0026"
		"trust_test_0027"
		"trust_test_0028"
		"trust_test_0029"
		"trust_test_0030"
		"trust_test_0031"
	}

    # Setup
	setup

    # tests start...
	trust_connect
    # tests end...

    # Cleanup
	cleanup


rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
