#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-idrange-cli
#   Description: IPA idrange cli test cases
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
. ./t.ipa-idrange-cli.sh
. ./t.ipa-idrange-cli.bug.sh
#PACKAGE="ipa-server"
##########################################
#   Sanity Tests
#########################################

	idrange_connect() {
		"idrange_test_0001"
		"idrange_test_0002"
		"idrange_test_0003"
		"idrange_test_0004"
		"idrange_test_0005"
		"idrange_test_0006"
		"idrange_test_0007"
		"idrange_test_0008"
		"idrange_test_0009"
		"idrange_test_0010"
		"idrange_test_0011"
		"idrange_test_0012"
		"idrange_test_0013"
		"idrange_test_0014"
		"idrange_test_0015"
		"idrange_test_0016"
		"idrange_test_0017"
		"idrange_test_0018"
		"idrange_test_0019"
		"idrange_test_0020"
		"idrange_test_0021"
		"idrange_test_0022"
		"idrange_test_0023"
		"idrange_test_0024"
		"idrange_test_0025"
		"idrange_test_0026"
		"idrange_test_0027"
		"idrange_test_0028"
		"idrange_test_0029"
		"idrange_test_0030"
		"idrange_test_0031"
		"idrange_test_0032"
		"idrange_test_0033"
		"idrange_test_0034"
		"idrange_test_0035"
		"idrange_test_0036"
		"idrange_test_0037"
		"idrange_test_0038"
		"idrange_test_0039"
	}

#	idrange_bug() {
#		"bz_867442"
#		"bz_869741"
#	}

    # Setup
#	setup

    # tests start...
	idrange_connect
#	idrange_bug
    # tests end...

    # Cleanup
	cleanup


rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
