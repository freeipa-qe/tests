#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-host-cli
#   Description: IPA host CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  host-add                  Add a new host.
#  host-del                  Delete an existing host.
#  host-find                 Search the hosts.
#  host-mod                  Edit an existing host.
#  host-show                 Examine an existing host.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
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
. /usr/lib/beakerlib/beakerlib.sh
. /dev/shm/ipa-host-cli-lib.sh
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
    rlPhaseStartSetup "ipa-host-cli-startup: Check for admintools package and Kinit"
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPWD" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-001: Add lower case host"
        rlRun "addHost $host1 force" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host1" 0 "Verifying host was added with ipa host-find lower case."
        rlRun "findHost $host2" 0 "Verifying host was added with ipa host-find upper case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-02: Add upper case host"
        rlRun "addHost $host3 force" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host3" 0 "Verifying host was added with ipa host-find lower case."
        rlRun "findHost $host4" 0 "Verifying host was added with ipa host-find upper case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-03: Add host with dashes in hostname"
        rlRun "addHost $host5 force" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host5" 0 "Verifying host was added with ipa host-find lower case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-04: Modify host location"
	for item in $host1 $host3 $host5 ; do
		attr="location"
		value='IDM Westford lab 3'
        	rlRun "modifyHost $item $attr \"${value}\"" 0 "Modifying host $item $attr."
        	rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-05: Modify host platform"
        for item in $host1 $host3 $host5 ; do
		attr="platform"
                value='x86_64'
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-06: Modify host os"
        for item in $host1 $host3 $host5 ; do
		attr="os"
                value="Fedora 11"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-07: Modify host description"
        for item in $host1 $host3 $host5 ; do
		attr="desc"
                value="interesting description"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-08: Modify host locality"
        for item in $host1 $host3 $host5 ; do
                attr="locality"
                value="Mountain View, CA"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-09: Show Host Objectclasses"
	tmpfile=/tmp/showall.out
	ipa host-show --all $host1 > /tmp/showall.out
	classes=(ipaobject ipaservice nshost ipahost pkiuser krbprincipalaux krbprincipal top);
	len=${#classes[*]};
	i=0
	while [ $i -le $len ] ; do
		cat $tmpfile | grep "${classes[$i]}"
		rc=$?
		rlAssert0 "Verifying objectclass \"${classes[$i]}\" with host-show --all" $rc
		((i=$i+1))
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-10: Disable Host - Remove Keytab"
	# first get a keytab and verify it exists
	for item in $host1 $host4 $host5 ; do
		rlRun "ipa-getkeytab -s `hostname` -p host/$item -k /tmp/host.$item.keytab"
		rlRun "verifyHostAttr $item Keytab True" 0 "Check if keytab exists"
		rlRun "disableHost $item" 0 "Disable host which should remove keytab"
		rlRun "verifyHostAttr $item Keytab False" 0 "Check if keytab was removed."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-11: Regression test for bug 499016"
	for item in $host1 $host3 $host5 ; do
        	attr="desc"
        	value="this is a very interesting description"
		os="Fedora 11"
        	rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
        	rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
		rlRun "verifyHostAttr $item os \"$os\"" 0 "Verifying host OS was not modified."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-12: Negative - add duplicate host"
	command="ipa host-add $host1"
	expmsg="ipa: ERROR: This entry already exists"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-13: Negative - Delete host that doesn't exist"
        command="ipa host-del ghost.$DOMAIN"
        expmsg="ipa: ERROR: ghost.$DOMAIN: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-14: Negative - setattr and addattr on fqdn"
        command="ipa host-mod --setattr fqdn=newfqdn $host1"
        expmsg="ipa: ERROR: Operation not allowed on RDN:"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	command="ipa host-mod --addattr fqdn=newfqdn $host1"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-15: Negative - setattr and addattr on ipaUniqueID"
        command="ipa host-mod --setattr ipaUniqueID=127863947-84375973-gq9587 $host1"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr ipaUniqueID=127863947-84375973-gq9587 $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-16: Negative - setattr and addattr on krbPrincipalName"
        command="ipa host-mod --setattr krbPrincipalName=host/$host2@BOS.REDHAT.COM $host1"
        expmsg="ipa: ERROR: Insufficient access: Principal name already set, it is unchangeable."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr krbPrincipalName=host/$host2@BOS.REDHAT.COM $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-17: Negative - setattr and addattr on serverHostName"
        command="ipa host-mod --setattr serverHostName=$host2 $host1"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr serverHostName=$host2 $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-18: setattr and addattr on nsHostLocation"
	attr="nsHostLocation"
	rlRun "setAttribute host $attr mars $host1" 0 "Setting attribute $attr to value of mars."
	rlRun "verifyHostAttr $host1 location \"$value\"" 0 "Verifying host $attr was modified."
	# shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr nsHostLocation=jupiter $host1"
	expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-19: setattr and addattr on l - locality"
	attr="l"
	rlRun "setAttribute host $attr sunnyside $host1" 0 "Setting attribute $attr to value of mars."
	rlRun "verifyHostAttr $host1 locality sunnyside" 0 "Verifying host $attr was modified."
	# shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr l=moonside $host1"
	expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-20: setattr and addattr on nsOsVersion"
        attr="nsOsVersion"
        rlRun "setAttribute host $attr RHEL6 $host1" 0 "Setting attribute $attr to value of RHEL6."
        rlRun "verifyHostAttr $host1 os RHEL6" 0 "Verifying host $attr was modified."
	# shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr nsOsVersion=RHEL5 $host1"
	expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-21:  Negative - setattr and addattr on enrolledBy"
        command="ipa host-mod --setattr enrolledBy=\"uid=user,cn=users,cn=accounts,dc=bos,dc=redhat,dc=com\" $host1"
        expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr enrolledBy=\"uid=user,cn=users,cn=accounts,dc=bos,dc=redhat,dc=com\" $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-22:  Negative - setattr and addattr on enrolledBy - invalid syntax"
        command="ipa host-mod --setattr enrolledBy=me $host1"
        expmsg="ipa: ERROR: Invalid syntax:enrolledBy: value #0 invalid per syntax"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr enrolledBy=you $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-23: setattr and addattr on description"
        attr="description"
        rlRun "setAttribute host $attr new $host1" 0 "Setting attribute $attr to value of new."
        rlRun "verifyHostAttr $host1 desc RHEL6" 0 "Verifying host $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr description=newer $host1"
	expmsg="ipa: ERROR: no modifications to be performed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-24: Delete Hosts"
        for item in $host1 $host3 $host5 ; do
                rlRun "deleteHost $item" 0 "Delete host $item."
                rlRun "findHost $item" 1 "Verifying host $item was deleted."
        done
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-25: Modify Host that doesn't Exist"
        command="ipa host-mod --location=mars $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-26: Find Host that doesn't Exist"
        command="ipa host-show $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-27: Show Host that doesn't Exist"
        command="ipa host-show $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-28: Disable Host that doesn't Exist"
        command="ipa host-disable $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-29: Add Host without force or add DNS record options"
        command="ipa host-add $host1"
        expmsg="ipa: ERROR: Host does not have corresponding DNS A record"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

    rlPhaseStartCleanup "ipa-host-cli-cleanup: Destroying admin credentials."
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd
