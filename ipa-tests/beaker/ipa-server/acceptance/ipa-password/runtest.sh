#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-user-cli
#   Description: IPA user cli acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#   user-add     Add a new user.
#   user-del     Delete a user.
#   user-find    Search for users.
#   user-lock    Lock a user account.
#   user-mod     Modify a user.
#   user-show    Display information about a user.
#   user-unlock  Unlock a user account.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Yi Zhang <yzhang@redhat.com>
#   Date  : Sept 21, 2010
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
. ./data.password.acceptance
. ./data.password.functional

# Include rhts environment
#. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
#. /dev/shm/ipa-user-cli-lib.sh
#. /dev/shm/ipa-server-shared.sh

. /iparhts/shared/ipa-server-shared.sh

# Include local help file
. ./lib.password.sh
# Include test case file
. ./t.password.sh

PACKAGE="ipa-server"
type=$1
if [ -z "$type" ] || [ "$type" = "acceptance" ] ;then
    echo "run default test: acceptance"
    echo "use acceptance data file"
    data=./data.user-cli.acceptance
    . ./data.user-cli.acceptance
elif [ "$type" = "functional" ];then
    echo "run functional test"
    echo "use functional data file"
    data=./data.user-cli.functional
    . ./data.user-cli.functional
else
    echo "whatelse"
    return
fi

##########################################
#   test group
##########################################
password_life()
{
    t_password_envsetup
    t_minlife_somelimit
    t_minlife_nolimit
    t_minlife_negative
    t_maxlife_verify
    t_maxlife_lessthan_minlife
    t_password_envcleanup
} #password_life

password_history()
{
    t_password_envsetup
    t_password_history
    t_password_history_lowbound
    t_password_history_negative
    t_password_envcleanup
} #password_history

classes()
{
    t_password_envsetup
    t_classes_min
    t_classes_lowerbound
    t_password_envcleanup
} #password_classes

length()
{
    t_password_envsetup
    t_length_min
    t_length_min_lowerbound
    t_password_envcleanup
} #password_length

#########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-password-startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # test starts
    password_life
    password_history
    password_classes
    password_length
    # test ends

    rlPhaseStartCleanup "ipa-password-cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd
