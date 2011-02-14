#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-group-cli
#   Description: IPA group CLI acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa cli commands needs to be tested:
#  hostgroup-add            Create a new group.
#  hostgroup-add-member     Add members to a group.
#  hostgroup-del            Delete group.
#  hostgroup-find           Search for groups.
#  hostgroup-mod            Modify a group.
#  hostgroup-remove-member  Remove members from a group.
#  hostgroup-show           Display information about a named group.
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
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-host-cli-lib.sh
. /dev/shm/ipa-hostgroup-cli-lib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

########################################################################
# Test Suite Globals
########################################################################

BASEDN="dc=$RELM"
HOSTGRPDN="cn=hostgroups,cn=accounts,"
HOSTGRPRDN="$HOSTGRPDN$BASEDN"
HOSTDN="cn=computers,cn=accounts,"
HOSTRDN="$HOSTDN$BASEDN"

rlLog "HOSTDN is $HOSTRDN"
rlLog "HOSTGRPDN is $HOSTGRPRDN"
rlLog "Server is $MASTER"

host1="nightcrawler."$DOMAIN
host2="ivanova."$DOMAIN
host3="samwise."$DOMAIN
host4="shadowfall."$DOMAIN
host5="qe-blade-01."$DOMAIN

group1="hostgrp1"
group2="host group 2"
group3="host-group_3"
group4="parent"
group5="child"

########################################################################

PACKAGE="ipa-admintools"

rlJournalStart
    rlPhaseStartSetup "ipa-hostgroup-cli-startup: Check for admintools package, Kinit and hosts and user groups"
	rpm -qa | grep $PACKAGE
        if [ $? -eq 0 ] ; then
                rlPass "ipa-admintools package is installed"
        else
                rlFail "ipa-admintools package NOT found!"
        fi
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	# add hosts to test host members
	for item in $host1 $host2 $host3 $host4 $host5 ; do
		rlRun "addHost $item" 0 "Adding host $item"
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-01: Add Host Groups"
	rlRun "addHostGroup \"$group1\" \"$group1\"" 0 "Adding host group \"$group1\""
	rlRun "addHostGroup \"$group2\" \"$group2\"" 0 "Adding host group \"$group2\""
	rlRun "addHostGroup \"$group3\" \"$group3\"" 0 "Adding host group \"$group3\""
	rlRun "addHostGroup \"$group4\" \"$group4\"" 0 "Adding host group \"$group4\""
	rlRun "addHostGroup \"$group5\" \"$group5\"" 0 "Adding host group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-02: Find Host Groups"
        rlRun "findHostGroup \"$group1\" \"$group1\"" 0 "Verifying find host group \"$group1\""
        rlRun "findHostGroup \"$group2\" \"$group2\"" 0 "Verifying find host group \"$group2\""
        rlRun "findHostGroup \"$group3\" \"$group3\"" 0 "Verifying find host group \"$group3\""
        rlRun "findHostGroup \"$group4\" \"$group4\"" 0 "Verifying find host group \"$group4\""
        rlRun "findHostGroup \"$group5\" \"$group5\"" 0 "Verifying find host group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-03: Show Host Groups"
        rlRun "showHostGroup \"$group1\"" 0 "Verifying show host group \"$group1\""
        rlRun "showHostGroup \"$group2\"" 0 "Verifying show host group \"$group2\""
        rlRun "showHostGroup \"$group3\"" 0 "Verifying show host group \"$group3\""
        rlRun "showHostGroup \"$group4\"" 0 "Verifying show host group \"$group4\""
        rlRun "showHostGroup \"$group5\"" 0 "Verifying show group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-04: Modify Host Groups Description"
	description="My new host group description for group: $group1"
	rlRun "modifyHostGroup \"$group1\" desc \"$description\"" 0 "Changing host group $group1's description"
	rlRun "verifyHostGroupAttr \"$group1\" desc \"$description\"" 0 "Verifying description modification"
    rlPhaseEnd

########################################################################################################################
# MEMBERSHIPS
# group1 - host1
# group2 - host1 host2
# group3 - host2 host3 host4
# group4 - no hosts
# group5 - all hosts
#######################################################################################################################

    rlPhaseStartTest "ipa-hostgroup-cli-05: Host group 1 memberships - one host" 
	rlRun "addHostGroupMembers hosts $host1 \"$group1\"" 0 "Adding host $host1 to host group \"$group1\""
	rlRun "verifyHostGroupMember $host1 host  \"$group1\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-06: Hostgroup 2 memberships - two hosts"
	rlRun "addHostGroupMembers hosts \"$host1,$host2\" \"$group2\"" 0 "Adding host $host1 and $host2 to host group \"$group2\""
	rlRun "verifyHostGroupMember $host1 host  \"$group2\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host2 host  \"$group2\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-07: Host group 3 memberships - three hosts"
	rlRun "addHostGroupMembers hosts \"$host2,$host3,$host4\" \"$group3\"" 0 "Adding host $host2, $host3 and $host4 to host group \"$group3\""
	rlRun "verifyHostGroupMember $host2 host  \"$group3\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host3 host  \"$group3\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host4 host  \"$group3\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-08: Host group 4 memberships - one host"
	rlRun "addHostGroupMembers hosts $host5 \"$group4\"" 0 "Adding host $host5 to host group \"$group4\""
	rlRun "verifyHostGroupMember $host5 host  \"$group4\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-09: Host group 5 memberships - all hosts"
	rlRun "addHostGroupMembers hosts \"$host1,$host2,$host3,$host4,$host5\" \"$group5\"" 0 "Adding host $host1, $host2, $host3, $host4 and $host5 to host group \"$group5\""
	rlRun "verifyHostGroupMember $host1 host  \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host2 host  \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host3 host  \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host4 host  \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host5 host  \"$group5\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-10: Nested Host Groups"
	rlRun "addHostGroupMembers hostgroups \"$group5\" \"$group4\"" 0 "Adding host group \"$group5\" to host group \"$group4\""
	rlRun "verifyHostGroupMember \"$group5\" hostgroup \"$group4\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-11: Remove host member"
        rlRun "removeHostGroupMembers hosts \"$host1\" \"$group1\"" 0 "Removing host \"$host1\" from host group \"$group1\""
        rlRun "verifyHostGroupMember \"$host1\" host \"$group1\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-12: Remove host group member"
        rlRun "removeHostGroupMembers hostgroups \"$group5\" \"$group4\"" 0 "Removing host group \"$group4\" from host group \"$group5\""
        rlRun "verifyHostGroupMember \"$group4\" hostgroup \"$group5\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-13: Delete Host that is member of multiple host groups"
	rlRun "deleteHost $host2" 0 "Deleting host $host2"
	rlRun "verifyHostGroupMember \"$host2\" host  \"$group2\"" 4 "Verify member was removed"
	rlRun "verifyHostGroupMember \"$host2\" host  \"$group3\"" 4 "Verify member was removed"
	rlRun "verifyHostGroupMember \"$host2\" host  \"$group5\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-14: Delete Host Group that has multiple members"
        rlRun "deleteHostGroup \"$group3\"" 0 "Deleting host group \"$group3\""
        rlRun "verifyHostGroupMember \"$host3\" host  \"$group3\"" 4 "Verify member was removed"
        rlRun "verifyHostGroupMember \"$host4\" host  \"$group3\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-15: find hostgroup doesn't exist"
        ipa hostgroup-find  \"$group3\" > /tmp/error.out
        cat /tmp/error.out | grep "0 hostgroups matched"
        rc=$?
        rlAssert0 "0 hostgroups matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-16: show hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": hostgroup not found"
        command="ipa hostgroup-show \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-17: modify hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": hostgroup not found"
        command="ipa hostgroup-mod --desc=test \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-18: delete hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": hostgroup not found"
        command="ipa hostgroup-del \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-19: add host member hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": hostgroup not found"
        command="ipa hostgroup-add-member --hosts=$host1 \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-20: remove host member hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": hostgroup not found"
        command="ipa hostgroup-remove-member --hosts=$host1  \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-21: add host that doesn't exist to hostgroup"
        ipa hostgroup-add-member --hosts="$host2" $group1 > /tmp/error.out
        cat /tmp/error.out | grep "Number of members added 0"
        rc=$?
        rlAssert0 "Number of members added 0" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-22: remove host that doesn't exist from hostgroup"
        ipa hostgroup-remove-member --hosts="$host2" $group1 > /tmp/error.out
        cat /tmp/error.out | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "Number of members removed 0" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-23: Add duplicate host group"
        expmsg="ipa: ERROR: hostgroup with name $group1 already exists"
        command="ipa hostgroup-add --desc=test \"$group1\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

   rlPhaseStartTest "ipa-hostgroup-cli-24: Negative - setattr and addattr on dn"
        command="ipa hostgroup-mod --setattr dn=mynewDN $group1"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr dn=anothernewDN $group1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-25: Negative - setattr and addattr on cn"
        command="ipa hostgroup-mod --setattr cn=\"cn=new,cn=groups,dc=$RELM\" $group1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr cn=\"cn=new,cn=groups,dc=$RELM\" $group1"
	expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-26: setattr and addattr on description"
        attr="description"
        rlRun "setAttribute hostgroup $attr new $group1" 0 "Setting attribute $attr to value of new."
        rlRun "verifyHostGroupAttr $group1 desc new" 0 "Verifying host group $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa hostgroup-mod --addattr description=newer $group1"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-27: setattr and addattr on member"
        attr="member"
	member1short="new.testrelm"
	member2short="new2.testrelm"
	ipa host-add --force $member1short
	ipa host-add --force $member2short
        member1="fqdn=new.testrelm,$HOSTRDN"
        member2="fqdn=new2.testrelm,$HOSTRDN"
        rlRun "setAttribute hostgroup member \"$member1\" $group1" 0 "Setting member attribute"
	rlRun "verifyHostGroupMember \"$member1short\" host \"$group1\"" 0 "Verify member was added"
	rlRun "addAttribute hostgroup member \"$member2\" $group1" 0 "Adding additional member attribute"
	rlRun "verifyHostGroupMember \"$member2short\" host \"$group1\"" 0 "Verify member was added"
	ipa host-del new.testrelm
	ipa host-del new2.testrelm
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-28: setattr and addattr on memberOf"
        attr="memberOf"
        member1="cn=bogus,$HOSTGRPRDN"
        member2="cn=bogus2,$HOSTGRPRDN"
        command="ipa hostgroup-mod --setattr $attr=\"$member1\" \"$group1\""
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'cn=hostgrp1,cn=hostgroups,cn=accounts,dc=testrelm'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr $attr=\"$member2\" \"$group1\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-29: Negative - setattr and addattr on ipauniqueid"
        command="ipa hostgroup-mod --setattr ipauniqueid=mynew-unique-id $group1"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr ipauniqueid=another-new-unique-id $group1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-30: Negative - Add self as group member"
        ipa hostgroup-add-member --hostgroups="$group1" "$group1" > /tmp/error.out
        cat /tmp/error.out | grep "Number of members added 0"
        rc=$?
        rlAssert0 "Number of members added 0" $rc
	rlRun "ipa hostgroup-add-member --hostgroups=\"$group1\" \"$group1\"" 1 "Check return code is non zero."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-31: Delete Host Groups"
	rlRun "deleteHostGroup \"$group1\"" 0 "Deleting host group \"$group1\""
	rlRun "deleteHostGroup \"$group2\"" 0 "Deleting host group \"$group2\""
	rlRun "deleteHostGroup \"$group4\"" 0 "Deleting host group \"$group4\""
	rlRun "deleteHostGroup \"$group5\"" 0 "Deleting host group \"$group5\""
    rlPhaseEnd

 rlPhaseStartTest "ipa-hostgroup-cli-32: Add 10 host groups and test find returns limit of 5"
	rlRun "ipa config-mod --searchrecordslimit=5" 0 "setting search records limit to 5"
        i=1
        while [ $i -le 10 ] ; do
                addHostGroup Group$i Group$i
                let i=$i+1
        done
        ipa hostgroup-find > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Limit of 5 host groups returned as expected"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-33: find 0 host groups"
        ipa hostgroup-find --sizelimit=0 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 10 ] ; then
                rlPass "All host groups returned as expected with size limit of 0"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-34: find 10 host groups"
        ipa hostgroup-find --sizelimit=10 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 10 ] ; then
                rlPass "10 host groups returned as expected with size limit of 10"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-35: find 7 host groups"
        ipa hostgroup-find --sizelimit=7 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 7 ] ; then
                rlPass "7 host groups returned as expected with size limit of 7"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 7"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-36: find host groups - size limit not an integer"
        expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa hostgroup-find --sizelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa hostgroup-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-37: find host groups - time limit 0"
        ipa hostgroup-find --timelimit=0 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Limit of 5 host groups returned as expected with time limit of 0"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-38: find host groups - time limit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa hostgroup-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa hostgroup-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartCleanup "ipa-hostgroup-cli-cleanup: Delete remaining hosts and Destroying admin credentials"
	rlRun "ipa config-mod --searchrecordslimit=100" 0 "setting search records limit back to default"
        # delete remaining hosts added to test host members
        for item in $host1 $host3 $host4 $host5 ; do
                rlRun "deleteHost $item" 0 "Deleting host $item"
        done

        i=1
        while [ $i -le 10 ] ; do
                deleteHostGroup Group$i
                let i=$i+1
        done

	rlRun "kdestroy" 0 "Destroying admin credentials."
    rlPhaseEnd

rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
