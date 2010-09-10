#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-user-cli
#   Description: IPA host CLI acceptance tests
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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh
. /dev/shm/ipa-user-cli-lib.sh
. /dev/shm/ipa-server-shared.sh

########################################################################
# Test Suite Globals
########################################################################
ADMINID="admin"
ADMINPWD="Admin123"

REALM=`os_getdomainname | tr "[a-z]" "[A-Z]"`
DOMAIN=`os_getdomainname`

host1="nightcrawler."$DOMAIN
host2="NIGHTCRAWLER."$DOMAIN
host3="SHADOWFALL."$DOMAIN
host4="shadowfall."$DOMAIN
host5="qe-blade-01."$DOMAIN
########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-user-cli-startup: Check for admintools package and Kinit"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	#rlRun "mykinit $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-001: Add lower case host"
        rlRun "addHost $host1" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host1" 0 "Verifying host was added with ipa host-find lower case."
        rlRun "findHost $host2" 0 "Verifying host was added with ipa host-find upper case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-02: Add upper case host"
        rlRun "addHost $host3" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host3" 0 "Verifying host was added with ipa host-find lower case."
        rlRun "findHost $host4" 0 "Verifying host was added with ipa host-find upper case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-03: Add host with dashes in hostname"
        rlRun "addHost $host5" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host5" 0 "Verifying host was added with ipa host-find lower case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-04: Modify host location"
	for item in $host1 $host3 $host5 ; do
		attr="location"
		value='IDM Westford lab 3'
        	rlRun "modifyHost $item $attr \"${value}\"" 0 "Modifying host $item $attr."
        	rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-05: Modify host platform"
        for item in $host1 $host3 $host5 ; do
		attr="platform"
                value='x86_64'
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-06: Modify host os"
        for item in $host1 $host3 $host5 ; do
		attr="os"
                value="Fedora 11"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-07: Modify host description"
        for item in $host1 $host3 $host5 ; do
		attr="desc"
                value="interesting description"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-user-cli-08: Modify host locality"
        for item in $host1 $host3 $host5 ; do
                attr="locality"
                value="Mountain View, CA"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-user-cli-cleanup: Destroying admin credentials."
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "ipa host-del \"$host1\"" 0 "Deleting host added."
	rlRun "ipa host-del \"$host3\"" 0 "Deleting host added."
	rlRun "ipa host-del \"$host5\"" 0 "Deleting host added."
	#rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
