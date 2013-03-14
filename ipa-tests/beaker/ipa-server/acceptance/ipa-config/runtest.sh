#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipac-onfig
#   Description: IPA ipaconfig acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#  -h, --help            show this help message and exit
#  --maxusername=INT     Max username length
#  --homedirectory=STR   Default location of home directories
#  --defaultshell=STR    Default shell for new users
#  --defaultgroup=STR    Default group for new users
#  --emaildomain=STR     Default e-mail domain new users
#  --searchtimelimit=INT
#
#  Max. amount of time (sec.) for a search (-1 is
#  unlimited)
#  --searchrecordslimit=INT
#  Max. number of records to search (-1 is unlimited)
#  --usersearch=STR      A comma-separated list of fields to search when
#  searching for users
#  --groupsearch=STR     A comma-separated list of fields to search when searching for groups
#  --enable-migration=BOOL   Enable migration mode
#
#  --subject=STR         Base for certificate subjects (OU=Test,O=Example)
#  --addattr=STR         Add an attribute/value pair. Format is attr=value
#  --setattr=STR         Set an attribute to an name/value pair. Format is attr=value
#  --all                 retrieve all attributes
#  --raw                 print entries as stored on the server
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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./data.ipaconfig.acceptance
. ./lib.ipaconfig.sh
. ./lib.dataGenerator.sh
. ./t.ipaconfig.sh
. ./t.ipaconfig2.sh
. ./t.ipaconfig_bz.sh

PACKAGE="ipa-admintools"

##########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipaconfig startup: Check for ipa-server package"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # Run test scripts
    ipaconfig
    ipaconfig2
    ipaconfig_bz

    rlPhaseStartCleanup "ipaconfig cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    rlJournalPrintText
    report=/tmp/rhts.report.$RANDOM.txt
    makereport $report
    rhts-submit-log -l $report
rlJournalEnd
