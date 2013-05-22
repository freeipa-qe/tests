#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-server/acceptance/managed-entry
#   Description: IPA Services Functional tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   HTTP and HTTPS will be the services used to test the functionality
#   of kerberizing a service and testing access
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <mgregg@redhat.com>
#   Date  : February 7, 2012
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

# Include test case file
. ./t.ipamanagedentryfunctionaltests.sh
. ./t.ipamanagedentry.sh

PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"


##########################################
#   test main 
#########################################
rlJournalStart

	echo $MASTER | grep $HOSTNAME
       	if [ $? -eq 0 ] ; then
	ipa-managedentrycli
	ipa-managedentryfunctionaltestssetup
	ipa-managedentryfunctionaltests
	rlPass "Executed tests on MASTER"
	else
		rlPass "Machine is not a MASTER"
	fi 
    
 rlJournalPrintText
 report=/tmp/rhts.report.$RANDOM.txt
 makereport $report
 rhts-submit-log -l $report
rlJournalEnd
