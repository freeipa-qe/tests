#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-permission
#   Description: IPA permission CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands  will be tested:
#  permission-add	   Add a new permission. 
#  permission-del	   Delete a permission. 
#  permission-find         Search for permissions. 
#  permission-mod	   Modify a permission. 
#  permission-show	   Display information about a permission. 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Namita Krishnan <nsoman@redhat.com>
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/env.sh
. /opt/rhqa_ipa/ipa-rbac-cli-lib.sh
. /opt/rhqa_ipa/lib.user-cli.sh
. /opt/rhqa_ipa/ipa-group-cli-lib.sh
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh

# Include test case file
. ./lib.iparbac.sh
. ./lib.privilege.sh
. ./lib.role.sh
. ./t.ipapermission.sh
. ./t.ipaprivilege.sh
. ./t.iparole.sh
. ./t.ipaRBACFunctionalTests.sh

PACKAGE="ipa-server"

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa rbac startup: Check for ipa-server package"
	# The following check is not required as this is run post quickinstall.
        # rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

      ipapermissionTests
      ipaprivilegeTests
      iparoleTests
      ipaRBACFunctionalTests

    rlPhaseStartCleanup "ipa rbac cleanup"
       rlRun "popd"
#       rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd


rlJournalPrintText
	report=/tmp/rhts.report.$RANDOM.txt
	makereport $report
	rhts-submit-log -l $report
rlJournalEnd 
