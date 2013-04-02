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
  rlPhaseEnd

# Include test case file
. ./t.ipa-adtrust.sh
. ./t.ipa-adtrust.bug.sh
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
		"adtrust_test_0009"
		"adtrust_test_0010"
		"adtrust_test_0011"
		"adtrust_test_0012"
		"adtrust_test_0013"
		"adtrust_test_0014"
		"adtrust_test_0015"
		"adtrust_test_0016"
		"adtrust_test_0017"
		"adtrust_test_0018"
		"adtrust_test_0019"
		"adtrust_test_0020"
		"adtrust_test_0021"
		"adtrust_test_0022"
		"adtrust_test_0023"
		"adtrust_test_0024"
		"adtrust_test_0025"
		"adtrust_test_0026"
		"adtrust_test_0027"
		"adtrust_test_0028"
		"adtrust_test_0029"
		"adtrust_test_0030"
		"adtrust_test_0031"
		"adtrust_test_0032"
		"adtrust_test_0033"
		"adtrust_test_0034"
        }
	
	adtrust_bug() {
		"bz_866966"
		"bz_924079"	
	}	

    # Setup
	setup

    # tests start...
	adtrust_connect
        adtrust_bug
    # tests end...

    # Cleanup
	cleanup


rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
