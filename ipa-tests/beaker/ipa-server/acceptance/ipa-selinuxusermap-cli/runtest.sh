#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-selinuxusermap-cli
#   Description: selinuxusermap CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  selinuxusermap-add          Create a new SELinux User Map.
#  selinuxusermap-add-host     Add target hosts and hostgroups to an SELinux User Map rule.
#  selinuxusermap-add-user     Add users and groups to an SELinux User Map rule.
#  selinuxusermap-del          Delete a SELinux User Map.
#  selinuxusermap-disable      Disable an SELinux User Map rule.
#  selinuxusermap-enable       Enable an SELinux User Map rule.
#  selinuxusermap-find         Search for SELinux User Maps.
#  selinuxusermap-mod          Modify a SELinux User Map.
#  selinuxusermap-remove-host  Remove target hosts and hostgroups from an SELinux User Map rule.
#  selinuxusermap-remove-user  Remove users and groups from an SELinux User Map rule.
#  selinuxusermap-show         Display the properties of a SELinux User Map rule.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Asha Akkiangady <aakkiang@redhat.com>
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
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-group-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-hbac-cli-lib.sh
. /dev/shm/ipa-selinuxusermap-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test case file
. ./ipa-selinuxusermap-config.sh
. ./ipa-selinuxusermap-add.sh
. ./ipa-selinuxusermap-add-host.sh
. ./ipa-selinuxusermap-add-user.sh
########################################################################

PACKAGE="ipa-admintools"

rlJournalStart

    rlPhaseStartSetup "ipa-selinuxusermap-cli-startup: Check for admintools package"
        rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
    rlPhaseEnd


# Execute ipa config tests for SELinux user map
#  run_selinuxusermap_config_tests
# Execute SELinux user map add tests
#  run_selinuxusermap_add_tests
# Execute SELinux user map add-host tests
#  run_selinuxusermap_add_host_tests
# Execute SELinux user map add-user tests
  run_selinuxusermap_add_user_tests

# Execute add target hosts and hostgroups to an SELinux user map rule tests
#  run_selinuxusermap_add_host_tests

    rlPhaseStartCleanup "ipa-selinuxusermap-cli-cleanup: Clean-up."
        rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd


rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
