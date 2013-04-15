#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/quickupgrade
#   Description: IPA quickupgrade acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : May 23, 2012
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

# Local variables
ISMASTER=$(echo "$MYROLE" |grep "MASTER"|wc -l)
ISREPLICA=$(echo "$MYROLE" |grep "REPLICA"|wc -l)
ISCLIENT=$(echo "$MYROLE" |grep "CLIENT"|wc -l)

##########################################
#   test main 
#########################################
rlJournalStart
    rlPhaseStartSetup "quickupgrade_setup: Check for ipa-server package"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

        for repoi in $(seq 1 10); do
            url=$(echo $(eval echo \$MYNEWREPO$repoi))
            if [ -n "$url" ]; then
                unindent > /etc/yum.repos.d/mytestrepo$repoi.repo <<<"\
                [mytestrepo$repoi]
                name=mytestrepo$repoi
                baseurl=$url
                enabled=1
                gpgcheck=0
                skip_if_unavailable=1"
                rlRun "cat /etc/yum.repos.d/mytestrepo$repoi.repo"
            fi
        done
    rlPhaseEnd

    rlPhaseStartTest "quickupgrade_test: Upgrade existing host"
        rlRun "yum clean all"
        rlRun "yum -y update 'ipa*' redhat-release"

        case "$MYROLE" in
        MASTER*)
            rlRun "ipactl restart"
            rlRun "service sssd restart"
            ;;
        REPLICA*)
            rlRun "ipactl restart"
            rlRun "service sssd restart"
            ;;
        CLIENT*)
            rlRun "service sssd restart"
            ;;
        *)
            rlLog "Machine in recipe is not a known ROLE"
            rlLog "set MYROLE var"
            ;;
        esac

    rlPhaseEnd

    rlPhaseStartCleanup "quickupgrade_cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd

# manifest:
