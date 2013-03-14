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
#  hostgroup-find           using --in-hbacrules
#  hostgroup-find           using --not-in-hbacrules
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
. /opt/rhqa_ipa/ipa-host-cli-lib.sh
. /opt/rhqa_ipa/ipa-hostgroup-cli-lib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

########################################################################
# Test Suite Globals
########################################################################

HOSTGRPDN="cn=hostgroups,cn=accounts,"
HOSTGRPRDN="$HOSTGRPDN$BASEDN"
HOSTDN="cn=computers,cn=accounts,"
HOSTRDN="$HOSTDN$BASEDN"

rlLog "HOSTDN is $HOSTRDN"
rlLog "HOSTGRPDN is $HOSTGRPRDN"
rlLog "Server is $MASTER"

host1="nightcrawler.$DOMAIN"
host2="ivanova.$DOMAIN"
host3="samwise.$DOMAIN"
host4="shadowfall.$DOMAIN"
host5="qe-blade-23.$DOMAIN"

group1="hostgrp1"
group2="host.group.2"
group3="host-group_3"
group4="parent"
group5="child"

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
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	# add hosts to test host members
	for item in $host1 $host2 $host3 $host4 $host5 ; do
		rlRun "addHost $item" 0 "Adding host $item"
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-01 Add Host Groups"
	rlRun "addHostGroup \"$group1\" \"$group1\"" 0 "Adding host group \"$group1\""
	rlRun "addHostGroup \"$group2\" \"$group2\"" 0 "Adding host group \"$group2\""
	rlRun "addHostGroup \"$group3\" \"$group3\"" 0 "Adding host group \"$group3\""
	rlRun "addHostGroup \"$group4\" \"$group4\"" 0 "Adding host group \"$group4\""
	rlRun "addHostGroup \"$group5\" \"$group5\"" 0 "Adding host group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-02 Find Host Groups"
        rlRun "findHostGroup \"$group1\" \"$group1\"" 0 "Verifying find host group \"$group1\""
        rlRun "findHostGroup \"$group2\" \"$group2\"" 0 "Verifying find host group \"$group2\""
        rlRun "findHostGroup \"$group3\" \"$group3\"" 0 "Verifying find host group \"$group3\""
        rlRun "findHostGroup \"$group4\" \"$group4\"" 0 "Verifying find host group \"$group4\""
        rlRun "findHostGroup \"$group5\" \"$group5\"" 0 "Verifying find host group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-03 Show Host Groups"
        rlRun "showHostGroup \"$group1\"" 0 "Verifying show host group \"$group1\""
        rlRun "showHostGroup \"$group2\"" 0 "Verifying show host group \"$group2\""
        rlRun "showHostGroup \"$group3\"" 0 "Verifying show host group \"$group3\""
        rlRun "showHostGroup \"$group4\"" 0 "Verifying show host group \"$group4\""
        rlRun "showHostGroup \"$group5\"" 0 "Verifying show group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-04 Modify Host Groups Description"
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

    rlPhaseStartTest "ipa-hostgroup-cli-05 Host group 1 memberships - one host" 
	rlRun "addHostGroupMembers hosts $host1 \"$group1\"" 0 "Adding host $host1 to host group \"$group1\""
	rlRun "verifyHostGroupMember $host1 host \"$group1\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-06 Hostgroup 2 memberships - two hosts"
	rlRun "addHostGroupMembers hosts \"$host1,$host2\" \"$group2\"" 0 "Adding host $host1 and $host2 to host group \"$group2\""
	rlRun "verifyHostGroupMember $host1 host \"$group2\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host2 host \"$group2\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-07 Host group 3 memberships - three hosts"
	rlRun "addHostGroupMembers hosts \"$host2,$host3,$host4\" \"$group3\"" 0 "Adding host $host2, $host3 and $host4 to host group \"$group3\""
	rlRun "verifyHostGroupMember $host2 host \"$group3\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host3 host \"$group3\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host4 host \"$group3\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-08 Host group 4 memberships - one host"
	rlRun "addHostGroupMembers hosts $host5 \"$group4\"" 0 "Adding host $host5 to host group \"$group4\""
	rlRun "verifyHostGroupMember $host5 host \"$group4\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-09 Host group 5 memberships - all hosts"
	rlRun "addHostGroupMembers hosts \"$host1,$host2,$host3,$host4,$host5\" \"$group5\"" 0 "Adding host $host1, $host2, $host3, $host4 and $host5 to host group \"$group5\""
	rlRun "verifyHostGroupMember $host1 host \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host2 host \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host3 host \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host4 host \"$group5\"" 0 "Verify member"
	rlRun "verifyHostGroupMember $host5 host \"$group5\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-10 Nested Host Groups"
	rlRun "addHostGroupMembers hostgroups \"$group5\" \"$group4\"" 0 "Adding host group \"$group5\" to host group \"$group4\""
	rlRun "verifyHostGroupMember \"$group5\" hostgroup \"$group4\"" 0 "Verify member"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-11 Remove host member"
        rlRun "removeHostGroupMembers hosts \"$host1\" \"$group1\"" 0 "Removing host \"$host1\" from host group \"$group1\""
        rlRun "verifyHostGroupMember \"$host1\" host \"$group1\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-12 Remove host group member"
        rlRun "removeHostGroupMembers hostgroups \"$group5\" \"$group4\"" 0 "Removing host group \"$group4\" from host group \"$group5\""
        rlRun "verifyHostGroupMember \"$group4\" hostgroup \"$group5\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-13 Delete Host that is member of multiple host groups"
	rlRun "deleteHost $host2" 0 "Deleting host $host2"
	rlRun "verifyHostGroupMember \"$host2\" host \"$group2\"" 4 "Verify member was removed"
	rlRun "verifyHostGroupMember \"$host2\" host \"$group3\"" 4 "Verify member was removed"
	rlRun "verifyHostGroupMember \"$host2\" host \"$group5\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-14 Delete Host Group that has multiple members"
        rlRun "deleteHostGroup \"$group3\"" 0 "Deleting host group \"$group3\""
        rlRun "verifyHostGroupMember \"$host3\" host \"$group3\"" 4 "Verify member was removed"
        rlRun "verifyHostGroupMember \"$host4\" host \"$group3\"" 4 "Verify member was removed"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-15 find hostgroup doesn't exist"
        ipa hostgroup-find  \"$group3\" > /tmp/error.out
        cat /tmp/error.out | grep "0 hostgroups matched"
        rc=$?
        rlAssert0 "0 hostgroups matched" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-16 show hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": host group not found"
        command="ipa hostgroup-show \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-17 modify hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": host group not found"
        command="ipa hostgroup-mod --desc=test \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-18 delete host group doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": host group not found"
        command="ipa hostgroup-del \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-19 add host member hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": host group not found"
        command="ipa hostgroup-add-member --hosts=$host1 \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-20 remove host member hostgroup doesn't exist"
        expmsg="ipa: ERROR: \"$group3\": host group not found"
        command="ipa hostgroup-remove-member --hosts=$host1  \"$group3\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-21 add host that doesn't exist to hostgroup"
        ipa hostgroup-add-member --hosts="$host2" $group1 > /tmp/error.out
        cat /tmp/error.out | grep "Number of members added 0"
        rc=$?
        rlAssert0 "Number of members added 0" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-22 remove host that doesn't exist from hostgroup"
        ipa hostgroup-remove-member --hosts="$host2" $group1 > /tmp/error.out
        cat /tmp/error.out | grep "Number of members removed 0"
        rc=$?
        rlAssert0 "Number of members removed 0" $rc
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-23 Add duplicate host group"
        expmsg="ipa: ERROR: host group with name $group1 already exists"
        command="ipa hostgroup-add --desc=test \"$group1\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
    rlPhaseEnd

   rlPhaseStartTest "ipa-hostgroup-cli-24 Negative - setattr and addattr on dn"
        command="ipa hostgroup-mod --setattr dn=\"cn=mynewDN,cn=hostgroups,cn=accounts,dc=testrelm,dc=com\" $group1"
        expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr dn=\"cn=anothernewDN,cn=hostgroups,cn=accounts,dc=testrelm,dc=com\" $group1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-25 Negative - setattr and addattr on cn"
        command="ipa hostgroup-mod --setattr cn=\"cn=new,cn=groups,$BASEDN\" $group1"
        expmsg="ipa: ERROR: modifying primary key is not allowed"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr cn=\"cn=new,cn=groups,$BASEDN\" $group1"
	expmsg="ipa: ERROR: cn: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-26 setattr and addattr on description"
        attr="description"
        rlRun "setAttribute hostgroup $attr new $group1" 0 "Setting attribute $attr to value of new."
        rlRun "verifyHostGroupAttr $group1 desc new" 0 "Verifying host group $attr was modified."
        # shouldn't be multivalue - additional add should fail
        command="ipa hostgroup-mod --addattr description=newer $group1"
        expmsg="ipa: ERROR: description: Only one value allowed."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-27 setattr and addattr on member"
        attr="member"
	member1short="new.$DOMAIN"
	member2short="new2.$DOMAIN"
	ipa host-add --force $member1short
	ipa host-add --force $member2short
        member1="fqdn=new.$DOMAIN,$HOSTRDN"
        member2="fqdn=new2.$DOMAIN,$HOSTRDN"
        rlRun "setAttribute hostgroup member \"$member1\" $group1" 0 "Setting member attribute"
	rlRun "verifyHostGroupMember \"$member1short\" host \"$group1\"" 0 "Verify member was added"
	rlRun "addAttribute hostgroup member \"$member2\" $group1" 0 "Adding additional member attribute"
	rlRun "verifyHostGroupMember \"$member2short\" host \"$group1\"" 0 "Verify member was added"
	ipa host-del new.$DOMAIN
	ipa host-del new2.$DOMAIN
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-28 setattr and addattr on memberOf"
        attr="memberOf"
        member1="cn=bogus,$HOSTGRPRDN"
        member2="cn=bogus2,$HOSTGRPRDN"
        command="ipa hostgroup-mod --setattr $attr=\"$member1\" \"$group1\""
        expmsg="ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry 'cn=hostgrp1,cn=hostgroups,cn=accounts,$BASEDN'."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr $attr=\"$member2\" \"$group1\""
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-29 Negative - setattr and addattr on ipauniqueid"
        command="ipa hostgroup-mod --setattr ipauniqueid=mynew-unique-id $group1"
        expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        command="ipa hostgroup-mod --addattr ipauniqueid=another-new-unique-id $group1"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-30 Negative - Add self as group member"
        ipa hostgroup-add-member --hostgroups="$group1" "$group1" > /tmp/error.out
        cat /tmp/error.out | grep "Number of members added 0"
        rc=$?
        rlAssert0 "Number of members added 0" $rc
	rlRun "ipa hostgroup-add-member --hostgroups=\"$group1\" \"$group1\"" 1 "Check return code is non zero."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-31 Delete Host Groups"
	rlRun "deleteHostGroup \"$group1\"" 0 "Deleting host group \"$group1\""
	rlRun "deleteHostGroup \"$group2\"" 0 "Deleting host group \"$group2\""
	rlRun "deleteHostGroup \"$group4\"" 0 "Deleting host group \"$group4\""
	rlRun "deleteHostGroup \"$group5\"" 0 "Deleting host group \"$group5\""
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-32 Add 10 host groups and test find returns limit of 5"
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

    rlPhaseStartTest "ipa-hostgroup-cli-33 find 0 host groups"
        ipa hostgroup-find --sizelimit=0 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 10 ] ; then
                rlPass "All host groups returned as expected with size limit of 0"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-34 find 10 host groups"
        ipa hostgroup-find --sizelimit=10 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 10 ] ; then
                rlPass "10 host groups returned as expected with size limit of 10"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 10"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-35 find 7 host groups"
        ipa hostgroup-find --sizelimit=7 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 7 ] ; then
                rlPass "7 host groups returned as expected with size limit of 7"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 7"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-36 find host groups - size limit not an integer"
        expmsg="ipa: ERROR: invalid 'sizelimit': must be an integer"
        command="ipa hostgroup-find --sizelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa hostgroup-find --sizelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-37 find host groups - time limit 0"
        ipa hostgroup-find --timelimit=0 > /tmp/hostgroupfind.out
        result=`cat /tmp/hostgroupfind.out | grep "Number of entries returned"`
        number=`echo $result | cut -d " " -f 5`
        if [ $number -eq 5 ] ; then
                rlPass "Limit of 5 host groups returned as expected with time limit of 0"
        else
                rlFail "Number of host groups returned is not as expected.  GOT: $number EXP: 5"
        fi
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-38 find host groups - time limit not an integer"
        expmsg="ipa: ERROR: invalid 'timelimit': must be an integer"
        command="ipa hostgroup-find --timelimit=abvd"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - alpha characters."
        command="ipa hostgroup-find --timelimit=#*"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - special characters."
	rlRun "ipa config-mod --searchrecordslimit=-1" 0 "re-setting search records limit to unlimited"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-39 add host group as member to itself - bugzilla 501377"
	rlRun "ipa hostgroup-add --desc=test testgrp" 0 "Adding test host group"
        rlRun "ipa hostgroup-add-member --hostgroups=testgrp testgrp > /tmp/hostgroup39.out 2>&1" 1 
	rlAssertGrep "    member host group: testgrp: A group may not be added as a member of itself" "/tmp/hostgroup39.out"
	rlRun "ipa hostgroup-del testgrp" 0 "Delete test group"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-40 invalid characters for hostgroup names"
	expmsg="ipa: ERROR: invalid 'hostgroup_name': may only include letters, numbers, _, -, and ."
	for value in my*group my:group ; do
		command="ipa hostgroup-add --desc=test \"$value\""
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message - invalid character: $value"
	done
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-41 invalid spaces in hostgroup names"
        expmsg="ipa: ERROR: invalid 'hostgroup_name': may only include letters, numbers, _, -, and ."
        ipa hostgroup-add --desc=test "my group" > /tmp/hostgroup41.out 2<&1
	rlAssertGrep "$expmsg" "/tmp/hostgroup41.out"
    rlPhaseEnd

    hb=hbruleh
    group1=hbgta
    group2=hbgtb
    rlPhaseStartTest "ipa-hostgroup-cli-42 Positive hostgroup-find test using --in-hbacrules"
	rlRun "addHostGroup \"$group1\" \"$group1\"" 0 "Adding host group \"$group1\""
	rlRun "addHostGroup \"$group2\" \"$group2\"" 0 "Adding host group \"$group2\""
	rlRun "ipa hbacrule-add $hb" 0 "Adding hbac rule for testing with user-find"
	rlRun "ipa hbacrule-add-host --hostgroups=$group1 $hb" 0 "adding hostgroup $group2 to hbacrule $hb"
	# should be hostgroup-find instead of host-fin
	rlRun "ipa hostgroup-find --in-hbacrules=$hb | grep $group1" 0 "making sure group1 is returned when searching hostgroups using --in-hbacrules"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-43 Negative host-find test using --in-hbacrules"
	rlRun "ipa hostgroup-find --in-hbacrules=$hb | grep $group2" 1 "making sure group2 is not returned when searching hostgroups using --in-hbacrules"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-44 Positive host-find test using --not-in-hbacrules"
	rlRun "ipa hostgroup-find --not-in-hbacrules=$hb | grep $group2" 0 "making sure group2 is returned when searching hostgroups using --not-in-hbacrules"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-45 Negative host-find test using --not-in-hbacrules"
	rlRun "ipa host-find --not-in-hbacrules=$hb | grep $group1" 1 "making sure group1 is not returned when searching hostgroups using --not-in-hbacrules"
	rlRun "ipa hbacrule-del $hb" 0 "Deleting hbac rule use in previous tests"
    rlPhaseEnd

    sru=sruleta
    rlPhaseStartTest "ipa-hostgroup-cli-46 Positive test of search of hostgroup in a sudorules"
	rlRun "ipa sudorule-add $sru" 0 "Adding sudorule to test with"
	rlRun "ipa sudorule-add-host --hostgroups=$group1 $sru" 0 "adding testtype $group1 to sudorule sru"
	rlRun "ipa hostgroup-find --in-sudorule=$sru | grep $group1" 0 "ensuring that hostgroup $group1 is returned when searching for hostgroup in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-47 Negative test of search of hostgroup in a sudorule"
	rlRun "ipa hostgroup-find --in-sudorule=$sru | grep $group2" 1 "ensuring that hostgroup $group2 is notreturned when searching for hostgroup in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-48 Positive test of search of hostgroup not in a sudorule"
	rlRun "ipa hostgroup-find --not-in-sudorule=$sru | grep $group2" 0 "ensuring that hostgroup $group2 is returned when searching for hostgroup not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-49 Negative test of search of hostgroup not in a sudorule"
	rlRun "ipa hostgroup-find --not-in-sudorule=$sru | grep $group1" 1 "ensuring that hostgroup $group1 is notreturned when searching for hostgroup not in a given sudorule"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-50 Positive test of search of hostgroup after it has been removed from the sudorule"
	rlRun "ipa sudorule-remove-host --hostgroups=$group1 $sru" 0 "Remove $group1 from sudorule $sru"
	rlRun "ipa hostgroup-find --not-in-sudorule=$sru | grep $group1" 0 "ensure that $group1 comes back from a search excluding sudorule $sru"
    rlPhaseEnd

    rlPhaseStartTest "ipa-hostgroup-cli-51 Negative test of search of hostgroup after it has been removed from the sudorule"
	rlRun "ipa hostgroup-find --in-sudorule=$sru | grep $group1" 1 "ensure that $group1 does not come back from a search in sudorule $sru"
	ipa hostgroup-del $group1
	ipa hostgroup-del $group2
	rlRun "ipa sudorule-del $sru" 0 "cleaning up the sudorule used in these tests"
    rlPhaseEnd


netgroup_bz_815481()
    {
        # Test for https://bugzilla.redhat.com/show_bug.cgi?id=815481
        # 815481 -  hostgroup and netgroup names with one letter not allowed
        rlPhaseStartTest "ipa-hostgroup-bz-815481-1 Add hostgroup named A"
                hgname=A
                rlRun "ipa hostgroup-add --desc=desc $hgname" 0 "Attempt adding hostgroup named $hgname BZ 815481"
                rlRun "ipa hostgroup-find $hgname" 0 "Ensure that hostgroup $hgname exists BZ 815481"
                ipa hostgroup-del $hgname
        rlPhaseEnd

        rlPhaseStartTest "ipa-hostgroup-bz-815481-2 Add hostgroup named a"
                hgname=a
                rlRun "ipa hostgroup-add --desc=desc $hgname" 0 "Attempt adding hostgroup named $hgname BZ 815481"
                rlRun "ipa hostgroup-find $hgname" 0 "Ensure that hostgroup $hgname exists BZ 815481"
                ipa hostgroup-del $hgname
        rlPhaseEnd

        rlPhaseStartTest "ipa-hostgroup-bz-815481-3 Add hostgroup named z"
                hgname=z
                rlRun "ipa hostgroup-add --desc=desc $hgname" 0 "Attempt adding hostgroup named $hgname BZ 815481"
                rlRun "ipa hostgroup-find $hgname" 0 "Ensure that hostgroup $hgname exists BZ 815481"
                ipa hostgroup-del $hgname
        rlPhaseEnd

    }

    netgroup_bz_815481

    rlPhaseStartCleanup
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
