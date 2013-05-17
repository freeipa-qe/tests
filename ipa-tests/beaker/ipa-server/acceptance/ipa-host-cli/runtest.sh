#/bin/bash
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
#  host-fine  using --pkey-only
#  host-find  using --in-hbacrules
#  host-find  using --not-in-hbacrules
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Jenny Galipeau <jgalipea@redhat.com>
#
#   Additional tests by <aakkiang@redhat.com>
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
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

# Include test case file
. ./ipa-host-cli-ipv6.sh
. ./ipa-host-cli-macaddress.sh
. ./ipa-host-cli-bugzillas.sh

########################################################################
# Test Suite Globals
########################################################################

host1="nightcrawler."$DOMAIN
host2="NIGHTCRAWLER."$DOMAIN
host3="SHADOWFALL."$DOMAIN
host4="shadowfall."$DOMAIN
host5="qe-blade-23."$DOMAIN

########################################################################

PACKAGE="ipa-admintools"
rlJournalStart
    rlPhaseStartSetup 
	rpm -qa | grep $PACKAGE
	if [ $? -eq 0 ] ; then
		rlPass "ipa-admintools package is installed"
	else
		rlFail "ipa-admintools package NOT found!"
	fi
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-001: Add lower case host"
        rlRun "addHost $host1 force" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host1" 0 "Verifying host was added with ipa host-find lower case."
        rlRun "findHost $host2" 0 "Verifying host was added with ipa host-find upper case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-002: Add upper case host"
        rlRun "addHost $host3 force" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host3" 0 "Verifying host was added with ipa host-find lower case."
        rlRun "findHost $host4" 0 "Verifying host was added with ipa host-find upper case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-003: Add host with dashes in hostname"
        rlRun "addHost $host5 force" 0 "Adding new host with ipa host-add."
        rlRun "findHost $host5" 0 "Verifying host was added with ipa host-find lower case."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-004: Modify host location"
	for item in $host1 $host3 $host5 ; do
		attr="location"
		value='IDM Westford lab 3'
        	rlRun "modifyHost $item $attr \"${value}\"" 0 "Modifying host $item $attr."
        	rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-005: Modify host platform"
        for item in $host1 $host3 $host5 ; do
		attr="platform"
                value='x86_64'
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-006: Modify host os"
        for item in $host1 $host3 $host5 ; do
		attrToModify="os"
		attrToVerify="\"Operating system\""
                value="Fedora 11"
                rlRun "modifyHost $item $attrToModify \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attrToVerify \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-007: Modify host description"
        for item in $host1 $host3 $host5 ; do
		attrToModify="desc"
		attrToVerify="Description"
                value="interesting description"
                rlRun "modifyHost $item $attrToModify \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attrToVerify \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-008: Modify host locality"
        for item in $host1 $host3 $host5 ; do
                attr="locality"
                value="Mountain View, CA"
                rlRun "modifyHost $item $attr \"$value\"" 0 "Modifying host $item $attr."
                rlRun "verifyHostAttr $item $attr \"$value\"" 0 "Verifying host $attr was modified."
        done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-009: Show Host Objectclasses"
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

    rlPhaseStartTest "ipa-host-cli-010: Disable Host - Remove Keytab"
	# first get a keytab and verify it exists
	for item in $host1 $host4 $host5 ; do
		rlRun "ipa-getkeytab -s `hostname` -p host/$item -k /tmp/host.$item.keytab"
		rlRun "verifyHostAttr $item Keytab True" 0 "Check if keytab exists"
		rlRun "disableHost $item" 0 "Disable host which should remove keytab"
		rlRun "verifyHostAttr $item Keytab False" 0 "Check if keytab was removed."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-011: ipa host-mod modifying platform modifies os bz499016"
	for item in $host1 $host3 $host5 ; do
		attrToModify="desc"
		attrToVerify1="Description"
                attrToVerify2="\"Operating system\""
        	value="this is a very interesting description"
		os="Fedora 11"
        	rlRun "modifyHost $item $attrToModify \"$value\"" 0 "Modifying host $item $attr."
        	rlRun "verifyHostAttr $item $attrToVerify1 \"$value\"" 0 "Verifying host $attr was modified."
		rlRun "verifyHostAttr $item $attrToVerify2 \"$os\"" 0 "Verifying host OS was not modified."
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-012: Negative - add duplicate host"
	command="ipa host-add $host1 --force"
	expmsg="ipa: ERROR: host with name nightcrawler.$DOMAIN already exists"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-013: Negative - Delete host that doesn't exist"
        command="ipa host-del ghost.$DOMAIN"
        expmsg="ipa: ERROR: ghost.$DOMAIN: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-014: Negative - setattr and addattr on fqdn"
        command="ipa host-mod --setattr fqdn=newfqdn $host1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	expmsg="ipa: ERROR: fqdn: Only one value allowed."
	command="ipa host-mod --addattr fqdn=newfqdn $host1"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-015: Negative - setattr and addattr on ipaUniqueID"
        command="ipa host-mod --setattr ipaUniqueID=127863947-84375973-gq9587 $host1"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr ipaUniqueID=127863947-84375973-gq9587 $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-016: Negative - setattr and addattr on krbPrincipalName"
        command="ipa host-mod --setattr krbPrincipalName=host/$host2@BOS.REDHAT.COM $host1"
        expmsg="ipa: ERROR: Insufficient access: Principal name already set, it is unchangeable."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr krbPrincipalName=host/$host2@BOS.REDHAT.COM $host1"
	expmsg="ipa: ERROR: krbprincipalname: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-017: Negative - setattr and addattr on serverHostName"
        command="ipa host-mod --setattr serverHostName=$host2 $host1"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'serverHostName' attribute of entry 'fqdn=$host1,cn=computers,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr serverHostName=$host2 $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-018: setattr and addattr on nsHostLocation"
	attr="nsHostLocation"
	rlRun "setAttribute host $attr mars $host1" 0 "Setting attribute $attr to value of mars."
	rlRun "verifyHostAttr $host1 Location mars" 0 "Verifying host $attr was modified."
	# shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr nsHostLocation=jupiter $host1"
	expmsg="ipa: ERROR: nshostlocation: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-019: setattr and addattr on l - locality"
	attr="l"
	rlRun "setAttribute host $attr sunnyside $host1" 0 "Setting attribute $attr to value of mars."
	rlRun "verifyHostAttr $host1 locality sunnyside" 0 "Verifying host $attr was modified."
	# shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr l=moonside $host1"
	expmsg="ipa: ERROR: l: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-020: setattr and addattr on nsOsVersion"
        attr="nsOsVersion"
        attrToVerify="\"Operating system\""
        rlRun "setAttribute host $attr RHEL6 $host1" 0 "Setting attribute $attr to value of RHEL6."
        rlRun "verifyHostAttr $host1 $attrToVerify RHEL6" 0 "Verifying host $attr was modified."
	# shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr nsOsVersion=RHEL5 $host1"
	expmsg="ipa: ERROR: nsosversion: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-021: Negative - setattr and addattr on enrolledBy"
        command="ipa host-mod --setattr enrolledBy=\"uid=user,cn=users,cn=accounts,$BASEDN\" $host1"
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'enrolledBy' attribute of entry 'fqdn=$host1,cn=computers,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr enrolledBy=\"uid=user,cn=users,cn=accounts,$BASEDN\" $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-022: Negative - setattr and addattr on enrolledBy - invalid syntax"
        command="ipa host-mod --setattr enrolledBy=me $host1"
        expmsg="ipa: ERROR: enrolledby: Invalid syntax."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr enrolledBy=you $host1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for invalid enrolledby syntax"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-023: setattr and addattr on description"
        attr="description"
        rlRun "setAttribute host $attr new $host1" 0 "Setting attribute $attr to value of new."
        rlRun "verifyHostAttr $host1 Description new" 0 "Verifying host $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa host-mod --addattr description=newer $host1"
	expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-024: Delete Hosts"
        for item in $host1 $host3 $host5 ; do
                rlRun "deleteHost $item" 0 "Delete host $item."
                rlRun "findHost $item" 1 "Verifying host $item was deleted."
        done
     rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-025: Negative - add host not fully qualified DN"
        command="ipa host-add myhost --force"
        expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: not fully qualified"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-026: Modify Host that doesn't Exist"
        command="ipa host-mod --location=mars $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-027: Find Host that doesn't Exist"
        command="ipa host-show $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-028: Show Host that doesn't Exist"
        command="ipa host-show $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-029: Disable Host that doesn't Exist"
        command="ipa host-disable $host1"
        expmsg="ipa: ERROR: $host1: host not found"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

     rlPhaseStartTest "ipa-host-cli-030: Add Host without force or add DNS record options"
        command="ipa host-add $host1"
        expmsg="ipa: ERROR: Host does not have corresponding DNS A record"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
     rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-031: Negative - setattr and addattr on dn"
        myhost="mytest.$DOMAIN"
        addHost $myhost
        command="ipa host-mod --setattr dn=\"cn=mynewDN,cn=computers,cn=accounts,$BASEDN\" $myhost"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr dn=\"cn=anothernewDN,cn=computers,cn=accounts,$BASEDN\" $myhost"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        deleteHost $myhost
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-032: Negative - setattr and addattr on cn"
        myhost="mytest.$DOMAIN"
        addHost $myhost
        expmsg="ipa: ERROR: Insufficient access: cn is immutable"
        command="ipa host-mod --setattr cn=mytest2.$DOMAIN $myhost"
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
	expmsg="ipa: ERROR: Insufficient access: cn is immutable"
        command="ipa host-mod --addattr cn=mytest3.$DOMAIN $myhost"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	deleteHost $myhost
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-033: Negative - setattr and addattr on keytab"
	myhost="mytest.$DOMAIN"
        addHost $myhost
        command="ipa host-mod --setattr \"keytab=true\" $myhost"
        expmsg="ipa: ERROR: attribute keytab not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa host-mod --addattr keytab=false $myhost"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	deleteHost $myhost
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-034: Add 10 hosts and test find returns search limit"
	rlRun "ipa config-mod --searchrecordslimit=5" 0 "Set search records limit to 5"
        i=1
        while [ $i -le 10 ] ; do
                addHost host$i.$DOMAIN
                let i=$i+1
        done
        number=`getNumberOfHosts`
	if [ $number -ne 5 ] ; then
		rlFail "Number of hosts returned is not as expected.  GOT: $number EXP: 5"
	else
		rlPass "Number of hosts returned is as expected"
	fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-035: find 0 hosts"
        ipa host-find --sizelimit=0 > /tmp/hostfind.out
        result=`cat /tmp/hostfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 11 ] ; then
                rlPass "All hosts returned as expected with size limit of 0"
        else
                rlFail "Number of hosts returned is not as expected.  GOT: $number EXP: 11"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-036: find 7 hosts"
        ipa host-find --sizelimit=7 > /tmp/hostfind.out
        result=`cat /tmp/hostfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 7 ] ; then
                rlPass "Number of hosts returned as expected with size limit of 7"
        else
                rlFail "Number of hosts returned is not as expected.  GOT: $number EXP: 7"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-037: find 9 hosts"
        ipa host-find --sizelimit=9 > /tmp/hostfind.out
        result=`cat /tmp/hostfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 9 ] ; then
                rlPass "Number of hosts returned as expected with size limit of 9"
        else
                rlFail "Number of hosts returned is not as expected.  GOT: $number EXP: 9"
        fi
    rlPhaseEnd

rlPhaseStartTest "ipa-host-cli-038: find more hosts than exist"
        ipa host-find --sizelimit=30 > /tmp/hostfind.out
        result=`cat /tmp/hostfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 11 ] ; then
                rlPass "All hosts returned as expected with size limit of 11"
        else
                rlFail "Number of hosts returned is not as expected.  GOT: $number EXP: 11"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-039: find hosts - size limit not an integer"
        expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa host-find --sizelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa host-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-040: find hosts - time limit 0"
        ipa host-find --timelimit=0 > /tmp/hostfind.out
        result=`cat /tmp/hostfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "5 hosts returned as expected with time limit of 0"
        else
                rlFail "Number of hosts returned is not as expected.  GOT: $number EXP: 5"
        fi
	rlRun "ipa config-mod --searchrecordslimit=100" 0 "set search records limit back to default"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-041: find hosts - time limit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa host-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa host-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-042: add Managed By Host"
	myhost1=mytesthost1.$DOMAIN
	myhost2=mytesthost2.$DOMAIN
	addHost $myhost1
	addHost $myhost2
	rlRun "addHostManagedBy $myhost2 $myhost1" 0 "Adding Managed By Host"
	rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-043: removed Managed By Host"
        rlRun "removeHostManagedBy $myhost2 $myhost1" 0 "Removing Managed By Host"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-044: add Multiple Managed By Host"
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
	myhost3=mytesthost3.$DOMAIN
	addHost $myhost3
        rlRun "addHostManagedBy \"$myhost2, $myhost3\" $myhost1" 0 "Adding Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-045: removed Multiple Managed By Hosts"
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
	myhost3=mytesthost3.$DOMAIN
        rlRun "removeHostManagedBy \"$myhost2, $myhost3\" $myhost1" 0 "Removing Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
        deleteHost $myhost1
        deleteHost $myhost2
	deleteHost $myhost3
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-046: Add host with DNS Record"
	short=myhost
	myhost=$short.$DOMAIN
	rzone=`getReverseZone`
	rlLog "Reverse Zone: $rzone"
	if [ $rzone ] ; then
		oct=`echo $rzone | cut -d "i" -f 1`
		oct1=`echo $oct | cut -d "." -f 3`
		oct2=`echo $oct | cut -d "." -f 2`
		oct3=`echo $oct | cut -d "." -f 1`
		ipaddr=$oct1.$oct2.$oct3.99
		export ipaddr
		rlLog "EXECUTING: ipa host-add --ip-address=$ipaddr $myhost"
		rlRun "ipa host-add --ip-address=$ipaddr $myhost" 0 "Adding host with IP Address $ipaddr"
		rlRun "findHost $myhost" 0 "Verifying host was added with IP Address."
		rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
		rlRun "ipa dnsrecord-find $rzone 99" 0 "Checking for reverse DNS entry"
	else
		rlFail "Reverse DNS zone not found."
	fi	
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-047: Delete host without deleting DNS Record"
	short=myhost
        myhost=$short.$DOMAIN
	rlRun "deleteHost $myhost" 0 "Deleting host without deleting DNS entries"
	rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
	rlRun "ipa dnsrecord-find $rzone 99" 0 "Checking for reverse DNS entry"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-048: Add host without force option - DNS Record Exists"
	short=myhost
        myhost=$short.$DOMAIN
	rlLog "EXECUTING: ipa host-add $myhost"
	rlRun "ipa host-add $myhost" 0 "Add host DNS entries exist"
	rlRun "findHost $myhost" 0 "Verifying host was added when DNS records exist."
	rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
        rlRun "ipa dnsrecord-find $rzone 99" 0 "Checking for reverse DNS entry"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-049: Delete Host and Update DNS"
	short=myhost
        myhost=$short.$DOMAIN
	ipa host-add --force $myhost
	rlRun "ipa host-del --updatedns $myhost" 0 "Delete host and update DNS"
	rlRun "findHost $myhost" 1 "Verifying host was deleted."
	rlRun "ipa dnsrecord-show $DOMAIN $ipaddr" 2 "Checking for forward DNS entry"
        rlRun "ipa dnsrecord-show $rzone 99" 2 "Checking for reverse DNS entry"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-050: Delete Host and Update DNS when DNS entries do not exist"
	short=myhost
        myhost=$short.$DOMAIN
        ipa host-add --force $myhost
        rlRun "ipa host-del --updatedns $myhost" 0 "Delete host and update DNS"
	rlRun "findHost $myhost" 1 "Verifying host was deleted."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-051: Add host with DNS Record --no-reverse"
        short=myhost
        myhost=$short.$DOMAIN
        rzone=`getReverseZone`
        rlLog "Reverse Zone: $rzone"
        if [ $rzone ] ; then
                oct=`echo $rzone | cut -d "i" -f 1`
                oct1=`echo $oct | cut -d "." -f 3`
                oct2=`echo $oct | cut -d "." -f 2`
                oct3=`echo $oct | cut -d "." -f 1`
                ipaddr=$oct1.$oct2.$oct3.99
                export ipaddr
                rlRun "ipa host-add --ip-address=$ipaddr --no-reverse $myhost" 0 "Adding host with IP Address $ipaddr and no reverse entry"
                rlRun "findHost $myhost" 0 "Verifying host was added with IP Address."
                rlRun "ipa dnsrecord-find $DOMAIN $short" 0 "Checking for forward DNS entry"
                rlRun "ipa dnsrecord-find $rzone 99" 1 "Checking for reverse DNS entry"
		rlRun "ipa host-del --updatedns $myhost" 0 "cleanup - delete $myhost"
        else
                rlFail "Reverse DNS zone not found."
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-052: host name ending in . "
	myhost="myhost.$DOMAIN"
	rlLog "EXECUTING : ipa host-add --force $myhost."
	rlRun "ipa host-add --force $myhost." 0 "Add host with trailing . - dot should be ignored"
	rlRun "ipa host-show $myhost > /tmp/host52.out 2>&1" 0 
	cat /tmp/host52.out | grep "Host name" | grep "$myhost."
	if [ $? -eq 0 ] ; then
		rlFail "https://bugzilla.redhat.com/show_bug.cgi?id=797562"
	else
		cat /tmp/host52.out | grep "Host name" | grep "$myhost"	
		if [ $? -eq 0 ] ; then
			rlPass "Host with trailing dot added and dot was ignored"
		else
			rlFail "Host with trailing dot was not added."
		fi
	fi
	rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-053: Negative - add host with _"
        command="ipa host-add host_underscore.$RELM --force"
		# scott 05/01/2012 - changing expected message since error changed (at least 2.2.0-12):
        #expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. - must not be the DNS label character"
		expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. DNS label may not start or end with -"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-054: Negative - add host with ~"
        command="ipa host-add host~tilda.$RELM --force"
		# scott 05/01/2012 - changing expected message since error changed (at least 2.2.0-12):
        #expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. - must not be the DNS label character"
		expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. DNS label may not start or end with -"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-055: Negative - add host with +"
        command="ipa host-add host+plus.$RELM --force"
		# scott 05/01/2012 - changing expected message since error changed (at least 2.2.0-12):
        #expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. - must not be the DNS label character"
		expmsg="ipa: ERROR: invalid 'hostname': invalid domain-name: only letters, numbers, and - are allowed. DNS label may not start or end with -"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-056: search with man-hosts when Managed By a Host"
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        addHost $myhost1
        addHost $myhost2
        rlRun "addHostManagedBy $myhost2 $myhost1" 0 "Adding Managed By Host"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2\""
	rlRun "ipa host-find --man-hosts=$myhost1 > /tmp/manbyhosts_find.out"
	rlAssertGrep "Number of entries returned 2" "/tmp/manbyhosts_find.out"
	rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_find.out"
	rlAssertGrep "Host name: $myhost1" "/tmp/manbyhosts_find.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-057: search a host when Managed By Host is removed"
        rlRun "removeHostManagedBy $myhost2 $myhost1" 0 "Removing Managed By Host"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
	rlRun "ipa host-find --man-hosts=$myhost1 > /tmp/manbyhosts_removed.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_removed.out"
	rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_removed.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-058: search a host when Managed by multiple Hosts"
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        myhost3=mytesthost3.$DOMAIN
        myhost4=mytesthost4.$DOMAIN
        addHost $myhost3
        addHost $myhost4
        rlRun "addHostManagedBy \"$myhost2, $myhost3, $myhost4\" $myhost1" 0 "Adding Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2, $myhost3, $myhost4\""
	rlRun "ipa host-find --man-hosts=$myhost1 > /tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Number of entries returned 4" "/tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Host name: $myhost4" "/tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Host name: $myhost3" "/tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Host name: $myhost1" "/tmp/manbyhosts_$myhost1.out"

	rlRun "ipa host-find --man-hosts=$myhost2 > /tmp/manbyhosts_$myhost2.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost2.out"

	rlRun "ipa host-find --man-hosts=$myhost3 > /tmp/manbyhosts_$myhost3.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost3.out"

	rlAssertGrep "Host name: $myhost3" "/tmp/manbyhosts_$myhost3.out"

	rlRun "ipa host-find --man-hosts=$myhost4 > /tmp/manbyhosts_$myhost4.out"

	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost4.out"
	rlAssertGrep "Host name: $myhost4" "/tmp/manbyhosts_$myhost4.out"

	host_list="$myhost1, $myhost2"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost12.out"
        rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_myhost12.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost12.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost12.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost12.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost12.out"

	host_list="$myhost1, $myhost3"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost13.out"
        rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_myhost13.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost13.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost13.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost13.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost13.out"

	host_list="$myhost1, $myhost4"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost14.out"
        rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_myhost14.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost14.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost14.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost14.out"
        rlAssertGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost14.out"	

	host_list="$myhost1, $myhost2, $myhost3"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost123.out" 1 "Verifying --man-hosts does not list any hosts"
        rlAssertGrep "Number of entries returned 0" "/tmp/manbyhosts_myhost123.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost123.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost123.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost123.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost123.out"

	host_list="$myhost1, $myhost2, $myhost4"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost124.out" 1 "Verifying --man-hosts does not list any hosts" 
        rlAssertGrep "Number of entries returned 0" "/tmp/manbyhosts_myhost124.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost124.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost124.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost124.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost124.out"

	host_list="$myhost1, $myhost3, $myhost4"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost134.out" 1 "Verifying --man-hosts does not list any hosts"
        rlAssertGrep "Number of entries returned 0" "/tmp/manbyhosts_myhost134.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost134.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost134.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost134.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost134.out"

	host_list="$myhost2, $myhost3"
	rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost23.out" 1 "Verifying --man-hosts does not list any hosts"
        rlAssertGrep "Number of entries returned 0" "/tmp/manbyhosts_myhost23.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost23.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost23.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost23.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost23.out"

	host_list="$myhost2, $myhost3, $myhost4"
	rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost234.out" 1 "Verifying --man-hosts does not list any hosts"
        rlAssertGrep "Number of entries returned 0" "/tmp/manbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost234.out"

	host_list="$myhost1, $myhost2, $myhost3, $myhost4"
        rlRun "ipa host-find --man-hosts=\"$host_list\" > /tmp/manbyhosts_myhost1234.out" 1 "Verifying --man-hosts does not list any hosts"
        rlAssertGrep "Number of entries returned 0" "/tmp/manbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_myhost1234.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-059: search a host when Multiple Managed By Hosts removed"
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        myhost3=mytesthost3.$DOMAIN
        myhost4=mytesthost4.$DOMAIN
        rlRun "removeHostManagedBy \"$myhost2, $myhost3, $myhost4\" $myhost1" 0 "Removing Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
	rlRun "ipa host-find --man-hosts=$myhost1 > /tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost1.out"
	rlAssertGrep "Host name: $myhost1" "/tmp/manbyhosts_$myhost1.out"
	rlAssertNotGrep "Host name: $myhost2" "/tmp/manbyhosts_$myhost1.out"
	rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_$myhost1.out"
	rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_$myhost1.out"

	rlRun "ipa host-find --man-hosts=$myhost2 > /tmp/manbyhosts_$myhost2.out"
        rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost2.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_$myhost2.out"

        rlRun "ipa host-find --man-hosts=$myhost3 > /tmp/manbyhosts_$myhost3.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost3.out"
	rlAssertGrep "Host name: $myhost3" "/tmp/manbyhosts_$myhost3.out"

        rlRun "ipa host-find --man-hosts=$myhost4 > /tmp/manbyhosts_$myhost4.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_$myhost4.out"
	rlAssertGrep "Host name: $myhost4" "/tmp/manbyhosts_$myhost4.out"
        deleteHost $myhost1
        deleteHost $myhost2
        deleteHost $myhost3
        deleteHost $myhost4
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-060: search a host when Manages multiple Hosts"
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        myhost3=mytesthost3.$DOMAIN
        myhost4=mytesthost4.$DOMAIN
        addHost $myhost1
        addHost $myhost2
        addHost $myhost3
        addHost $myhost4
        rlRun "addHostManagedBy \"$myhost2\" $myhost1" 0 "Adding Managed By Hosts"
        rlRun "addHostManagedBy \"$myhost2\" $myhost3" 0 "Adding Managed By Hosts"
        rlRun "addHostManagedBy \"$myhost2\" $myhost4" 0 "Adding Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2\""
        rlRun "verifyHostAttr $myhost3 \"Managed by\" \"$myhost3, $myhost2\""
        rlRun "verifyHostAttr $myhost4 \"Managed by\" \"$myhost4, $myhost2\""
	rlRun "ipa host-find --man-hosts=$myhost1 > /tmp/manbyhosts_multi_1.out"
        rlAssertGrep "Number of entries returned 2" "/tmp/manbyhosts_multi_1.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_multi_1.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_multi_1.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_multi_1.out"
        rlAssertGrep "Host name: $myhost1" "/tmp/manbyhosts_multi_1.out"

        rlRun "ipa host-find --man-hosts=$myhost2 > /tmp/manbyhosts_multi_2.out"
	rlAssertGrep "Number of entries returned 1" "/tmp/manbyhosts_multi_2.out"
	rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_multi_2.out"
	rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_multi_2.out"
	rlAssertNotGrep "Host name: $myhost1" "/tmp/manbyhosts_multi_2.out"
	rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_multi_2.out"

	rlRun "ipa host-find --man-hosts=$myhost3 > /tmp/manbyhosts_multi_3.out"
        rlAssertGrep "Number of entries returned 2" "/tmp/manbyhosts_multi_3.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/manbyhosts_multi_3.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/manbyhosts_multi_3.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_multi_3.out"
        rlAsserNotGrep "Host name: $myhost1" "/tmp/manbyhosts_multi_3.out"

	rlRun "ipa host-find --man-hosts=$myhost4 > /tmp/manbyhosts_multi_4.out"
        rlAssertGrep "Number of entries returned 2" "/tmp/manbyhosts_multi_4.out"
        rlAssertGrep "Host name: $myhost4" "/tmp/manbyhosts_multi_4.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/manbyhosts_multi_4.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/manbyhosts_multi_4.out"
        rlAsserNotGrep "Host name: $myhost1" "/tmp/manbyhosts_multi_4.out"

        rlRun "removeHostManagedBy $myhost2 $myhost1" 0 "Removing Managed By Host"
        rlRun "removeHostManagedBy $myhost2 $myhost3" 0 "Removing Managed By Host"
        rlRun "removeHostManagedBy $myhost2 $myhost4" 0 "Removing Managed By Host"
	deleteHost $myhost1
        deleteHost $myhost2
        deleteHost $myhost3
        deleteHost $myhost4
   rlPhaseEnd
	
   rlPhaseStartTest "ipa-host-cli-061: Negative - search with man-hosts when host does not exist"
        myhost1=mytesthost1.$DOMAIN
	expmsg="ipa: ERROR: $myhost1: host not found"
        command="ipa host-find --man-hosts=$myhost1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - man-hosts when host does not exist."
   rlPhaseEnd

   rlPhaseStartTest "ipa-host-cli-062: search with not-man-hosts when Managed By a Host"
        myhost1=nmanbyhost1.$DOMAIN
        myhost2=nmanbyhost2.$DOMAIN
        myhost3=nmanbyhost3.$DOMAIN
        addHost $myhost1
        addHost $myhost2
        addHost $myhost3
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
        rlRun "verifyHostAttr $myhost2 \"Managed by\" $myhost2"
        rlRun "verifyHostAttr $myhost3 \"Managed by\" $myhost3"
        rlRun "addHostManagedBy $myhost2 $myhost1" 0 "Adding Managed By Host"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2\""
        rlRun "ipa host-find --not-man-hosts=$myhost1 > /tmp/notmanbyhosts_find.out"
	result=`cat /tmp/notmanbyhosts_find.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 1" "$number" "1"
	rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_find.out" 
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_find.out" 
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_find.out"

	rlRun "ipa host-find --not-man-hosts=$myhost2 > /tmp/notmanbyhosts_find_2.out"
        result=`cat /tmp/notmanbyhosts_find_2.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 2" "$number" "2"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_find_2.out"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_find_2.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_find_2.out"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-host-cli-063: search a host when Managed By Host is removed"
        rlRun "removeHostManagedBy $myhost2 $myhost1" 0 "Removing Managed By Host"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
        rlRun "ipa host-find --not-man-hosts=$myhost1 > /tmp/notmanbyhosts_removed.out"
	result=`cat /tmp/notmanbyhosts_removed.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 2" "$number" "2"
	rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_removed.out" 
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_removed.out" 
        rlAssertGrep "Host name: $myhost2" "/tmp/notmanbyhosts_removed.out" 
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-host-cli-064: search with not-man-hosts when host is Managed by multiple Hosts"
        myhost1=nmanbyhost1.$DOMAIN
        myhost2=nmanbyhost2.$DOMAIN
        myhost3=nmanbyhost3.$DOMAIN
        myhost4=nmanbyhost4.$DOMAIN
        addHost $myhost4
        rlRun "addHostManagedBy \"$myhost2, $myhost3, $myhost4\" $myhost1" 0 "Adding Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2, $myhost3, $myhost4\""
	rlRun "ipa host-find --not-man-hosts=\"$myhost1\" > /tmp/notmanbyhosts_$myhost1.out"
        result=`cat /tmp/notmanbyhosts_$myhost1.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 0" "$number" "0"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost1.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost1.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost1.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost1.out"

	rlRun "ipa host-find --not-man-hosts=\"$myhost2\" > /tmp/notmanbyhosts_$myhost2.out"
	result=`cat /tmp/notmanbyhosts_$myhost2.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost2.out" 
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost2.out" 
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost2.out" 
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost2.out" 
	
	ipa host-find --not-man-hosts=$myhost3 > /tmp/notmanbyhosts_$myhost3.out
	result=`cat /tmp/notmanbyhosts_$myhost3.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost3.out"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost3.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost3.out"
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost3.out"

        ipa host-find --not-man-hosts=$myhost4 > /tmp/notmanbyhosts_$myhost4.out
	result=`cat /tmp/notmanbyhosts_$myhost4.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost4.out"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost4.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost4.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost4.out"

	rlRun "ipa host-find --not-man-hosts=\"$myhost1, $myhost2\" > /tmp/notmanbyhosts_myhost12.out"
        result=`cat /tmp/notmanbyhosts_myhost12.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 0" "$number" "0"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_myhost12.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_myhost12.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_myhost12.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_myhost12.out"
	
	rlRun "ipa host-find --not-man-hosts=\"$myhost1, $myhost3\" > /tmp/notmanbyhosts_myhost13.out"
        result=`cat /tmp/notmanbyhosts_myhost13.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 0" "$number" "0"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_myhost13.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_myhost13.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_myhost13.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_myhost13.out"
	
	host_list="$myhost2, $myhost3"
        rlRun "ipa host-find --not-man-hosts=\"$host_list\" > /tmp/notmanbyhosts_myhost23.out"
	result=`cat /tmp/notmanbyhosts_myhost23.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 2" "$number" "2"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_myhost23.out" 
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_myhost23.out" 
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_myhost23.out" 
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_myhost23.out" 
	
	
	host_list="$myhost2, $myhost3, $myhost4"
        rlRun "ipa host-find --not-man-hosts=\"$host_list\" > /tmp/notmanbyhosts_myhost234.out"
	result=`cat /tmp/notmanbyhosts_myhost234.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 1" "$number" "1"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_myhost234.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_myhost234.out" 

	host_list="$myhost1, $myhost2, $myhost3, $myhost4"
        rlRun "ipa host-find --not-man-hosts=\"$host_list\" > /tmp/notmanbyhosts_myhost1234.out"
        result=`cat /tmp/notmanbyhosts_myhost1234.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 0" "$number" "0"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_myhost1234.out"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_myhost1234.out"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-065: search with not-man-by-host when Multiple Managed By Hosts removed"
        myhost1=nmanbyhost1.$DOMAIN
        myhost2=nmanbyhost2.$DOMAIN
        myhost3=nmanbyhost3.$DOMAIN
        myhost4=nmanbyhost4.$DOMAIN
        rlRun "removeHostManagedBy \"$myhost2, $myhost3, $myhost4\" $myhost1" 0 "Removing Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
	rlRun "ipa host-find --not-man-hosts=$myhost1 > /tmp/notmanbyhosts_$myhost1.out"
        result=`cat /tmp/notmanbyhosts_$myhost1.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost1.out"
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost1.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost1.out"
        rlAssertGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost1.out"

        rlRun "ipa host-find --not-man-hosts=$myhost2 > /tmp/notmanbyhosts_$myhost2.out"
	result=`cat /tmp/notmanbyhosts_$myhost2.out | grep "Number of entries returned"`
	number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost2.out" 
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost2.out" 
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost2.out" 
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost2.out" 

        rlRun "ipa host-find --not-man-hosts=$myhost3 > /tmp/notmanbyhosts_$myhost3.out"
	result=`cat /tmp/notmanbyhosts_$myhost3.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost3.out" 
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost3.out" 
        rlAssertGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost3.out" 
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost3.out" 

        rlRun "ipa host-find --not-man-hosts=$myhost4 > /tmp/notmanbyhosts_$myhost4.out"
	result=`cat /tmp/notmanbyhosts_$myhost4.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertNotGrep "Host name: $myhost4" "/tmp/notmanbyhosts_$myhost4.out" 
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_$myhost4.out" 
        rlAssertGrep "Host name: $myhost2" "/tmp/notmanbyhosts_$myhost4.out" 
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_$myhost4.out" 
        deleteHost $myhost1
        deleteHost $myhost2
        deleteHost $myhost3
        deleteHost $myhost4
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-066: search with not-man-hosts when Manages multiple Hosts"
        myhost1=nmanbyhost1.$DOMAIN
        myhost2=nmanbyhost2.$DOMAIN
        myhost3=nmanbyhost3.$DOMAIN
        myhost4=nmanbyhost4.$DOMAIN
        addHost $myhost1
        addHost $myhost2
        addHost $myhost3
        addHost $myhost4
        rlRun "addHostManagedBy \"$myhost2\" $myhost1" 0 "Adding Managed By Hosts"
        rlRun "addHostManagedBy \"$myhost2\" $myhost3" 0 "Adding Managed By Hosts"
        rlRun "addHostManagedBy \"$myhost2\" $myhost4" 0 "Adding Managed By Hosts"
        rlRun "verifyHostAttr $myhost1 \"Managed by\" \"$myhost1, $myhost2\""
        rlRun "verifyHostAttr $myhost3 \"Managed by\" \"$myhost3, $myhost2\""
        rlRun "verifyHostAttr $myhost4 \"Managed by\" \"$myhost4, $myhost2\""
	rlRun "ipa host-find --not-man-hosts=$myhost1 > /tmp/notmanbyhosts_multi_1.out"
        result=`cat /tmp/notmanbyhosts_multi_1.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 2" "$number" "2"
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_multi_1.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_multi_1.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_multi_1.out"
        rlAssertNotGrep "Host name: $myhost1" "/tmp/notmanbyhosts_multi_1.out"

        rlRun "ipa host-find --not-man-hosts=$myhost2 > /tmp/notmanbyhosts_multi_2.out"
	result=`cat /tmp/notmanbyhosts_multi_2.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 3" "$number" "3"
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_multi_2.out"
        rlAssertGrep "Host name: $myhost3" "/tmp/notmanbyhosts_multi_2.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_multi_2.out"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_multi_2.out"

	rlRun "ipa host-find --not-man-hosts=$myhost3 > /tmp/notmanbyhosts_multi_3.out"
        result=`cat /tmp/notmanbyhosts_multi_3.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        rlAssertGreaterOrEqual "Number of entries returned is >= 2" "$number" "2"
        rlAssertGrep "Host name: $myhost4" "/tmp/notmanbyhosts_multi_3.out"
        rlAssertNotGrep "Host name: $myhost3" "/tmp/notmanbyhosts_multi_3.out"
        rlAssertNotGrep "Host name: $myhost2" "/tmp/notmanbyhosts_multi_3.out"
        rlAssertGrep "Host name: $myhost1" "/tmp/notmanbyhosts_multi_3.out"

        rlRun "removeHostManagedBy $myhost2 $myhost1" 0 "Removing Managed By Host"
        rlRun "removeHostManagedBy $myhost2 $myhost3" 0 "Removing Managed By Host"
        rlRun "removeHostManagedBy $myhost2 $myhost4" 0 "Removing Managed By Host"
        deleteHost $myhost1
        deleteHost $myhost2
        deleteHost $myhost3
        deleteHost $myhost4
   rlPhaseEnd

   rlPhaseStartTest "ipa-host-cli-067: Negative - search with not-man-hosts when host does not exist"
	myhost1=notahost
	expmsg="ipa: ERROR: $myhost1: host not found"
        command="ipa host-find --man-hosts=$myhost1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - not-man-hosts when host does not exist."
   rlPhaseEnd

   rlPhaseStartTest "ipa-host-cli-068: --pkey-only test of ipa host-find"
	ipa_command_to_test="host"
	pkey_addstringa="--ip-address=10.14.2.3"
	pkey_addstringb="--ip-address=10.14.2.4"
	pkeyobja="pkeyhost1.$DOMAIN"
	pkeyobjb="pkeyhost2.$DOMAIN"
	grep_string='Host\ name'
	general_search_string=pkeyhost
	rlRun "pkey_return_check" 0 "running checks of --pkey-only in sudorule-find"
	# deleting of the hosts is not cleaning up the dns records that got added, easiest to just add them back and delete with --updatedns
	ipa host-add $pkeyobja --force
	ipa host-add $pkeyobja --force
	ipa host-del $pkeyobja --updatedns
	ipa host-del $pkeyobjb --updatedns
    rlPhaseEnd
	
    rlPhaseStartTest "ipa-host-cli-069: Negative - host name ending in . - a host without trailing . already exist"
        myhost="myhost.$DOMAIN"
	expmsg="ipa: ERROR: host with name $myhost already exists"
        command="ipa host-add --force $myhost."
        rlLog "EXECUTING : ipa host-add --force $myhost. when a host without trailing . already exist"
        rlRun "ipa host-add --force $myhost" 0 "Add host without a trailing ."
	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - add a host when a host without trailing . exist."
        rlRun "ipa host-show $myhost > /tmp/host69.out 2>&1" 0
        cat /tmp/host69.out | grep "Host name" | grep "$myhost"
        if [ $? -eq 0 ] ; then
               rlPass "Host without trailing dot is not added and existing host is not altered."
        else
               rlFail "Existing host without a . has been removed."
        fi
        rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
    rlPhaseEnd

	
    rlPhaseStartTest "ipa-host-cli-070: delete a host name ending in . "
        myhost="myhost.$DOMAIN"
        rlLog "EXECUTING : ipa host-del $myhost."
        rlRun "ipa host-add --force $myhost." 0 "Add host with trailing . - dot should be ignored"
        rlRun "ipa host-show $myhost > /tmp/host70.out 2>&1" 0
        cat /tmp/host70.out | grep "Host name" | grep "$myhost"
        if [ $? -eq 0 ] ; then
            rlPass "Host with trailing dot added and dot was ignored"
        else
            rlFail "Host with trailing dot was not added."
        fi
        rlRun "ipa host-del $myhost." 0 "Delete a host with trailing . - dot should be ignored"
	rlRun "findHost $myhost" 1 "Verifying host $myhost was deleted."
    rlPhaseEnd

  rlPhaseStartTest "ipa-host-cli-071: host-show when the name ending in . "
        myhost="myhost.$DOMAIN"
        rlLog "EXECUTING : ipa host-show $myhost."
        rlRun "ipa host-add --force $myhost." 0 "Add host with trailing . - dot should be ignored"
        rlRun "ipa host-show $myhost. > /tmp/host71.out 2>&1" 0
        cat /tmp/host71.out | grep "Host name" | grep "$myhost"
        if [ $? -eq 0 ] ; then
             rlPass "host-show ignores the ending . in the hostname"
        else
             rlFail "host-show does not ignore the ending . in the hostname"
        fi
        rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-072: host-add-managedby when the name ending in . "
	myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        rlLog "EXECUTING : ipa host-add-managedby --hosts=\"$myhost2\" \"$myhost1.\""
        addHost $myhost1
        addHost $myhost2
        rlRun "ipa host-add-managedby --hosts=\"$myhost2\" \"$myhost1.\"" 0 "Add mangedby host with trailing . - dot should be ignored" 
        rlRun "ipa host-show \"$myhost1.\" > /tmp/host72.out 2>&1" 0
        cat /tmp/host72.out | grep "Host name" | grep "$myhost1"
        if [ $? -eq 0 ] ; then
		myval=`cat /tmp/host72.out | grep -i "Managed by: $myhost1, $myhost2" | xargs echo`
		cat /tmp/host72.out | grep -i "Managed by: $myhost1, $myhost2"
   		if [ $? -ne 0 ] ; then
        		rlFail "$myhost1 verification failed: Value of \"Managed by\" - GOT: $myval EXPECTED: \"$myhost1, $myhost2\""
   		else
			rlPass "Value of \"Managed by\" for $myhost1 is as expected - $myval"
   		fi
	else
		rlFail "$myhost1 is not added."	
	fi
        rlRun "ipa host-del $myhost1" 0 "Cleanup delete test host 1"
        rlRun "ipa host-del $myhost2" 0 "Cleanup delete test host 2"
    rlPhaseEnd
 
    rlPhaseStartTest "ipa-host-cli-073: host-remove-managedby when the name ending in . "
        myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        rlLog "EXECUTING : ipa host-remove-managedby --hosts=\"$myhost2\" \"$myhost1.\""
        addHost $myhost1
        addHost $myhost2
        rlRun "ipa host-add-managedby --hosts=\"$myhost2\" \"$myhost1.\"" 0 "Add mangedby host with trailing ." 
        rlRun "ipa host-show \"$myhost1.\" > /tmp/host73.out 2>&1" 0
        myval=`cat /tmp/host73.out | grep -i "Managed by: $myhost1, $myhost2" | xargs echo`
        cat /tmp/host73.out | grep -i "Managed by: $myhost1, $myhost2"
        if [ $? -ne 0 ] ; then
             rlFail "$myhost1 verification failed: Value of \"Managed by\" - GOT: $myval EXPECTED: \"$myhost1, $myhost2\""
        else
             rlPass "Value of \"Managed by\" for $myhost1 is as expected - $myval"
        fi
	rlRun "ipa host-remove-managedby --hosts=\"$myhost2\" \"$myhost1.\"" 0 "Remove mangedby host with trailing . - dot should be ignored"
	rlRun "verifyHostAttr $myhost1 \"Managed by\" $myhost1"
        rlRun "ipa host-del $myhost1" 0 "Cleanup delete test host 1"
        rlRun "ipa host-del $myhost2" 0 "Cleanup delete test host 2"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-074: host-mod when the name ending in . "
        myhost1=mytesthost1.$DOMAIN
        addHost $myhost1
	attrToModify="desc"
        attrToVerify1="Description"
        value="this is a brand new description"
        rlLog "EXECUTING : ipa host-mod --$attrToModify=\"$value\"  \"$myhost1.\""
	rlRun "ipa host-mod --$attrToModify=\"$value\" \"$myhost1.\"" 0 "Modify a host with trailing ."
        rlRun "verifyHostAttr $myhost1 $attrToVerify1 \"$value\"" 0 "Verifying host $attrToVerify1 was modified."
        rlRun "ipa host-del $myhost1" 0 "Cleanup delete test host"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-075: host-find when the name ending in . "
        myhost=mytesthost.$DOMAIN
        rlLog "EXECUTING : ipa host-find $myhost."
	rlRun "ipa host-add --force $myhost." 0 "Add host with trailing . - dot should be ignored"
        rlRun "ipa host-show $myhost > /tmp/host75.out 2>&1" 0
        cat /tmp/host75.out | grep "Host name" | grep "$myhost"
        if [ $? -eq 0 ] ; then
            rlPass "Host with trailing dot added and dot was ignored"
        else
            rlFail "Host with trailing dot was not added."
        fi
        rlRun "ipa host-find \"$myhost.\" > /tmp/host75_2.out 2>&1" 1 
        cat /tmp/host75_2.out | grep "Host name" | grep "$myhost"
        if [ $? -eq 0 ] ; then
		rlFail "host-find ignored the trailing dot."
	else
		cat /tmp/host75_2.out | grep "Number of entries returned 0" 
		if [ $? -eq 0 ] ; then
			rlPass "host-find with a trailing dot in the name - dot was not ignored"
		else
			rlFail "host-find with a trailing dot in the name - ending dot is ignored, EXP: ending dot should not be ignored."
		fi
	fi
        rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-076: host-disable when the name ending in . "
        myhost=mytesthost.$DOMAIN
        rlLog "EXECUTING : ipa host-disable $myhost."
        rlRun "ipa host-add --force $myhost." 0 "Add host with trailing . - dot should be ignored"
        rlRun "ipa host-show $myhost > /tmp/host76.out 2>&1" 0
        cat /tmp/host76.out | grep "Host name" | grep "$myhost"
        if [ $? -eq 0 ] ; then
            rlPass "Host with trailing dot added and dot was ignored"
        else
            rlFail "Host with trailing dot was not added."
        fi
	rlRun "ipa-getkeytab -s `hostname` -p host/$myhost -k /tmp/host.$myhost.keytab"
	rlRun "verifyHostAttr $myhost Keytab True" 0 "Check if keytab exists"
        rlRun "ipa host-disable \"$myhost.\" > /tmp/host76_2.out 2>&1" 0
        if [ $? -ne 0 ] ; then
                rlFail "host-disable with a trailing dot in the name - did not ignore the trailing dot."
        else
		cat /tmp/host76_2.out | grep "Disabled host \"$myhost\"" 
		if [ $? -eq 0 ] ; then
                	rlPass "host-disable with a trailing dot in the name - dot is ignored."
			rlRun "verifyHostAttr $myhost Keytab False" 0 "Check if keytab was removed."
        	else
            		rlFail "Host with trailing dot . is not disabled."
        	fi
        fi
        rlRun "ipa host-del $myhost" 0 "Cleanup delete test host"
    rlPhaseEnd

    hb=hbruleh
    rlPhaseStartTest "ipa-host-cli-077: Positive host-find test using --in-hbacrules"
	myhost1=mytesthost1.$DOMAIN
        myhost2=mytesthost2.$DOMAIN
        addHost $myhost1
        addHost $myhost2
	rlRun "ipa hbacrule-add $hb" 0 "Adding hbac rule for testing with user-find"
	rlRun "ipa hbacrule-add-host --hosts=$myhost1 $hb" 0 "adding host $myhost1 to hostgroup $hb"
	rlRun "ipa host-find --in-hbacrules=$hb | grep $myhost1" 0 "making sure host1 is returned when searching hosts using --in-hbacrules"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-078: Negative host-find test using --in-hbacrules"
	rlRun "ipa host-find --in-hbacrules=$hb | grep $myhost2" 1 "making sure host2 is not returned when searching hosts using --in-hbacrules"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-079: Positive host-find test using --not-in-hbacrules"
	rlRun "ipa host-find --not-in-hbacrules=$hb | grep $myhost2" 0 "making sure host2 is returned when searching hosts using --not-in-hbacrules"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-080: Negative host-find test using --not-in-hbacrules"
	rlRun "ipa host-find --not-in-hbacrules=$hb | grep $myhost1" 1 "making sure host1 is not returned when searching hosts using --not-in-hbacrules"
	rlRun "ipa hbacrule-del $hb" 0 "Deleting hbac rule use in previous tests"
    rlPhaseEnd

    sru=sruleta
    rlPhaseStartTest "ipa-host-cli-081: Positive test of search of hosts in a sudorules"
	rlRun "ipa sudorule-add $sru" 0 "Adding sudorule to test with"
	rlRun "ipa sudorule-add-host --hosts=$myhost1 $sru" 0 "adding host myhost1 to sudorule sru"
	rlRun "ipa host-find --in-sudorule=$sru | grep $myhost1" 0 "ensuring that host myhost1 is returned when searching for hosts in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-082: Negative test of search of hosts in a sudorule"
	rlRun "ipa host-find --in-sudorule=$sru | grep $myhost2" 1 "ensuring that host myhost2 is notreturned when searching for hosts in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-083: Positive test of search of hosts not in a sudorule"
	rlRun "ipa host-find --not-in-sudorule=$sru | grep $myhost2" 0 "ensuring that host mtyhost2 is returned when searching for hosts not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-084: Negative test of search of hosts not in a sudorule"
	rlRun "ipa host-find --not-in-sudorule=$sru | grep $myhost1" 1 "ensuring that host myhost1 is notreturned when searching for hosts not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-085: Positive test of search of host after it has been removed from the sudorule"
	rlRun "ipa sudorule-remove-host --hosts=$myhost1 $sru" 0 "Remove $myhost1 from sudorule $sru"
	rlRun "ipa host-find --not-in-sudorule=$sru | grep $myhost1" 0 "ensure that $myhost1 comes back from a search excluding sudorule $sru"
    rlPhaseEnd

    rlPhaseStartTest "ipa-host-cli-086: Negative test of search of host after it has been removed from the sudorule"
	rlRun "ipa host-find --in-sudorule=$sru | grep $myhost1" 1 "ensure that $myhost1 does not come back from a search in sudorule $sru"
        deleteHost $myhost1
        deleteHost $myhost2
	rlRun "ipa sudorule-del $sru" 0 "cleaning up the sudorule used in these tests"
    rlPhaseEnd

# Execute host-add with ipv6 address tests
# Following line is commented since ipv6 address tests not to be run on beaker.
#  run_host_add_ipv6_tests

# Execute host-add with macaddress tests
  run_host_add_macaddress_tests

# Execute bugzilla tests
  bugzillas

    rlPhaseStartCleanup 
        i=1
        while [ $i -le 10 ] ; do
                deleteHost host$i.$DOMAIN
                let i=$i+1
        done

	rlRun "kdestroy" 0 "Destroying admin credentials."
	rhts-submit-log -l /var/log/httpd/error_log
    rlPhaseEnd

rlJournalPrintText
report=/tmp/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
