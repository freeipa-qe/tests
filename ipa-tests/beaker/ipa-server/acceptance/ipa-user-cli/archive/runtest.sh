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
. ./data.user-cli.acceptance
. ./data.user-cli.functional

# Include rhts environment
#. /usr/bin/rhts-environment.sh
#. /usr/share/beakerlib/beakerlib.sh
#. /opt/rhqa_ipa/ipa-user-cli-lib.sh
#. /opt/rhqa_ipa/ipa-server-shared.sh

. /iparhts/shared/ipa-server-shared.sh
. /usr/share/beakerlib/beakerlib.sh

# Include local help file
. ./lib.user-cli.sh
# Include test case file
. ./t.user-cli.sh

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
addusertest()
{
    t_addusertest_envsetup
    t_addusersetup
    t_adduserverify
    t_userfind
    t_negative_adduser
    t_addlockuser
    t_lockuser
    t_unlockuser
    t_addusertest_envcleanup
} #addusertest

modusertest()
{
    t_moduser_envsetup
    t_modfirstname
    t_modlastname
    t_modemail
    t_modprinc
    t_modhome
    t_modgecos
    t_moduid
    t_modstreet
    t_modshell
    t_moduser_envcleanup
} #modusertest

showusertest()
{
    t_showusertest_envsetup
    t_showall
    t_showraw
    t_showusertest_envcleanup
} #showusertest

delusertest()
{
    t_deluser
} #delusertest

attrtest()
{
    t_setattr
    t_addattr
}
#########################################
#   test main 
#########################################

rlJournalStart
    rlPhaseStartSetup "ipa-user-cli-startup: Check for ipa-server package"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
    rlPhaseEnd

    # test starts
    addusertest
    modusertest
    showusertest
    delusertest        
    attrtest
    # test ends

    rlPhaseStartCleanup "ipa-user-cli-cleanup"
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd

    makereport
rlJournalEnd
