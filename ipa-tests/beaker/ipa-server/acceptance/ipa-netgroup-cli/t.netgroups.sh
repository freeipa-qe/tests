#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#######################################################################
# VARIABLES
#######################################################################
ngroup1=testg1
ngroup2=testgaga2
ngroup3=mynewng3
user1=usrjjk1r
user2=userl33t
user3=usern00b
user4=lopcr4k
group1=grpddee
group2=grplloo
group3=grpmmpp
group4=grpeeww
host1=memberhost1.$DOMAIN
host2=memberhost2.$DOMAIN
ehost1=externalhost1.$DOMAIN
ehost2=externalhost2.$DOMAIN
hgroup1=hg144335566
hgroup2=hg2
hgroup3=hg3afdsk

NETGRPDN="cn=ng,cn=alt,$BASEDN"
ENTRY="NGP Definition"

#########################################################################
# TEST SECTIONS TO RUN
#########################################################################
netgroups()
{
	setup
	add_netgroups
	member_netgroups
	mod_netgroups
	attr_netgroups
	del_netgroups
	manage_netgroups
	cleanup
}

########################################################################
#  TEST SECTION BREAKDOWN
########################################################################
# Test suite sections
setup()
{
	rlPhaseStartSetup "ipa-netgroup setup: Add users, groups, hosts and hostgroups for testing"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "kiniting as admin"
		# Adding users for use later
		ipa user-add --first=aa --last=bb $user1
		ipa user-add --first=aa --last=bb $user2
		ipa user-add --first=aa --last=bb $user3
		ipa user-add --first=aa --last=bb $user4
		ipa group-add --desc=testtest $group1
		ipa group-add --desc=testtest $group2
		ipa group-add --desc=testtest $group3
		ipa group-add --desc=testtest $group4
		ipa hostgroup-add --desc=$hgroup1 $hgroup1
		ipa hostgroup-add --desc=$hgroup2 $hgroup2
		ipa hostgroup-add --desc=$hgroup3 $hgroup3

		# let's make sure ipa-host-net-manage is disable for the first serious of tests
		echo $CLIENT | grep $HOSTNAME
		if [ $? -eq 0 ] ; then
			rlLog "This is a CLIENT"
			ssh root@$MASTER "echo $ADMINPW | ipa-managed-entries --entry=\"$ENTRY\" disable" 
			ssh root@$MASTER "echo $ADMINPW | ipa-managed-entries --entry=\"$ENTRY\" status" > /tmp/plugin.out
			cat /tmp/plugin.out | grep "Plugin Disabled"
			if [ $? -eq 0 ] ; then
				rlPass "Host Net Manager Plugin is disabled"
			else
				rlFail "Host Net Manage Plugin is NOT disabled, this may cause test failures."
			fi

		else
			rlLog "This is an IPA server"
			execManageNGPPlugin disable
			status=`execManageNGPPlugin status`
			echo $status | grep "Plugin Disabled"
			if [ $? -eq 0 ] ; then
				rlPass "Host Net Manage Plugin is disabled"
			else
				rlFail "Host Net Manage Plugin is NOT disabled, this may cause test failures."
			fi
		fi
	rlPhaseEnd
}

add_netgroups()
{
	netgroup_add_positive
	netgroup_add_negative
}

member_netgroups()
{
	netgroup_add_member_positive
	netgroup_remove_member_positive

	netgroup_add_member_negative
	netgroup_remove_member_negative
}

mod_netgroups()
{
	netgroup_mod_positive
	mod_netgroups_negative
}

attr_netgroups()
{
	attr_netgroups_positive
	attr_netgroups_negative
}

del_netgroups()
{
	del_netgroups_positive
	del_netgroups_negative
}

manage_netgroups()
{
	manage_netgroups_positive
	manage_netgroups_negative
}

cleanup()
{
	rlPhaseStartCleanup "ipa-netgroup cleanup"
		# Cleaning up users
		ipa user-del $user1
		ipa user-del $user2
		ipa user-del $user3
		ipa user-del $user4
		ipa group-del $group1
		ipa group-del $group2
		ipa group-del $group3
		ipa group-del $group4
		ipa hostgroup-del $hgroup1
		ipa hostgroup-del $hgroup2
		ipa hostgroup-del $hgroup3

		# disable the plugin
		echo $CLIENT | grep $HOSTNAME
		if [ $? -eq 0 ] ; then
			rlLog "This is a CLIENT"
			ssh root@$MASTER "echo $ADMINPW | ipa-managed-entries --entry=\"${ENTRY}\" disable" 
			ssh root@$MASTER "echo $ADMINPW | ipa-managed-entries --entry=\"${ENTRY}\" status" > /tmp/plugin.out
			cat /tmp/plugin.out | grep "Plugin Disabled"
			if [ $? -eq 0 ] ; then
				rlPass "Host Net Manager Plugin is disabled"
			else
				rlFail "Host Net Manage Plugin is NOT disabled, this may cause test failures."
			fi

		else
			rlLog "This is an IPA server"
			execManageNGPPlugin disable
			status=`execManageNGPPlugin status`
			echo $status | grep "Plugin Disabled"
			if [ $? -eq 0 ] ; then
				rlPass "Host Net Manage Plugin is disabled"
			else
				rlFail "Host Net Manage Plugin is NOT disabled, this may cause test failures."
			fi
		fi
	rlPhaseEnd
}

##########################################################################
#  ADD NETGROUPS
#########################################################################
# positive tests
netgroup_add_positive()
{
	rlPhaseStartTest "ipa-netgroup-001-0: add netgroups"
		echo "Add netgroup $ngroup1"
        	rlRun "addNetgroup $ngroup1 test-group-1" 0 "adding first netgroup"
		echo "Add netgroup $ngroup2"
        	rlRun "addNetgroup $ngroup2 test-group-2" 0 "adding second netgroup"
		# Verify if it exists
		rlRun "ipa netgroup-find $ngroup1 | grep $ngroup1" 0 "checking to ensure first netgroup was created"
		rlRun "ipa netgroup-find $ngroup2 | grep $ngroup2" 0 "checking to ensure second netgroup was created"
	rlPhaseEnd 

	rlPhaseStartTest "ipa-netgroup-001-1: add netgroup positive with nisdomain"
		rlRun "ipa netgroup-add ng-001-1 --desc=ng-001-1 --nisdomain=testnis.dom"
		rlRun "ipa netgroup-show ng-001-1"
		rlRun "ipa netgroup-del ng-001-1"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-2: add netgroup positive with nisdomain, usercat=all"
		rlRun "ipa netgroup-add ng-001-2 --desc=ng-001-2 --nisdomain=testnis.dom --usercat=all"
		rlRun "ipa netgroup-show ng-001-2"
		rlRun "ipa netgroup-del ng-001-2"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-3: add netgroup positive with nisdomain, hostcat=all"
		rlRun "ipa netgroup-add ng-001-3 --desc=ng-001-3 --nisdomain=testnis.dom --hostcat=all"
		rlRun "ipa netgroup-show ng-001-3"
		rlRun "ipa netgroup-del ng-001-3"
	rlPhaseEnd
		
	rlPhaseStartTest "ipa-netgroup-001-4: add netgroup positive with nisdomain, usercat=all, hostcat=all"
		rlRun "ipa netgroup-add ng-001-4 --desc=ng-001-4 --nisdomain=testnis.dom --usercat=all --hostcat=all"
		rlRun "ipa netgroup-show ng-001-4"
		rlRun "ipa netgroup-del ng-001-4"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-5: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr"
		rlRun "ipa netgroup-add ng-001-5 --desc=ng-001-5 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost"
		rlRun "ipa netgroup-find ng-001-5 --desc=ng-001-5 --nisdomain=testnis.dom --usercat=all --hostcat=all | grep 'External host: ipaqatesthost'"
		rlRun "ipa netgroup-del ng-001-5"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-6: add netgroup positive with nisdomain, usercat=all, hostcat=all, setattr"
		rlRun "ipa netgroup-add ng-001-6 --desc=ng-001-5 --nisdomain=testnis.dom --usercat=all --hostcat=all --setattr=externalHost=ipaqatesthost"
		rlRun "ipa netgroup-find ng-001-6 --desc=ng-001-6 --nisdomain=testnis.dom --usercat=all --hostcat=all | grep 'External host: ipaqatesthost'"
		rlRun "ipa netgroup-del ng-001-6"
	rlPhaseEnd
		
	rlPhaseStartTest "ipa-netgroup-001-7: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr"
		rlRun "ipa netgroup-add ng-001-7 --desc=ng-001-7 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2"
		rlRun "ipa netgroup-find ng-001-7 --desc=ng-001-7 --nisdomain=testnis.dom --usercat=all --hostcat=all | grep 'External host: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-7"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-8: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr, all"
		rlRun "ipa netgroup-add ng-001-8 --desc=ng-001-8 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2 --all"
		rlRun "ipa netgroup-find ng-001-8 --desc=ng-001-8 --nisdomain=testnis.dom --usercat=all --hostcat=all --all| grep 'External host: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-8"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-9: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr, raw"
		rlRun "ipa netgroup-add ng-001-9 --desc=ng-001-9 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2 --raw"
		rlRun "ipa netgroup-find ng-001-9 --desc=ng-001-9 --nisdomain=testnis.dom --usercat=all --hostcat=all --raw| grep 'externalhost: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-9"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-001-10: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr, all, raw"
		rlRun "ipa netgroup-add ng-001-10 --desc=ng-001-10 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2 --all --raw"
		rlRun "ipa netgroup-find ng-001-10 --desc=ng-001-10 --nisdomain=testnis.dom --usercat=all --hostcat=all --all --raw| grep 'externalhost: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-10"
	rlPhaseEnd
}

# negative add netgroups tests
netgroup_add_negative()
{
	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "ipa-netgroup-002-0: Add duplicate netgroup"
		command="addNetgroup $ngroup1 test-group-1"
		expmsg="ipa: ERROR: netgroup with name $ngroup1 already exists"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-1: Verify fail on netgroup-add with empty desc" 
		rlRun "ipa netgroup-add testng-002 --desc=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'desc' is required"  $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-2: Verify fail on netgroup-add with space for desc"
		rlRun "ipa netgroup-add testng-002 --desc=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'desc': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-3: Verify fail on netgroup-add with space for nisdomain"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'nisdomain': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-4: Verify fail on netgroup-add with invalid usercat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --usercat=badcat > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'usercat': must be one of (u'all',)" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-5: Verify fail on netgroup-add with space for usercat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --usercat=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'usercat': must be one of (u'all',)" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-6: Verify fail on netgroup-add with invalid hostcat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --hostcat=badcat > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'hostcat': must be one of (u'all',)" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-7: Verify fail on netgroup-add with space for hostcat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --hostcat=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'hostcat': must be one of (u'all',)" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-8: Verify fail on netgroup-add with invalid usercat and valid hostcat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --usercat=badcat --hostcat=all > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'usercat': must be one of (u'all',)" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-9: Verify fail on netgroup-add with invalid setattr value"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberHost=badvalue > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberHost: value #0 invalid per syntax: Invalid syntax." $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-10: Verify fail on netgroup-add with invalid setattr attr"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=badattr=fqdn=hostname.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: attribute \"badattr\" not allowed" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-11: Verify fail on netgroup-add with invalid addattr value"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --addattr=memberHost=badvalue > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberHost: value #0 invalid per syntax: Invalid syntax." $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-002-12: Verify fail on netgroup-add with invalid addattr attr"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --addattr=badattr=fqdn=hostname.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: attribute \"badattr\" not allowed" $tmpout
	rlPhaseEnd
	
	## NEED A BZ HERE 
	rlPhaseStartTest "ipa-netgroup-002-13: Verify fail on netgroup-add with both desc and --addattr desription (BZ 796390)"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --addattr=description=DESCRIPTION > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: description: Only one value allowed." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-14: Verify fail on netgroup-add with setattr desc and invalid aaddattr attr"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=description=desc2 --addattr=badattr=fqdn=hostname.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: attribute \"badattr\" not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-15: Verify fail on netgroup-add with setattr invalid value, valid addattr and all"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberHost=badvalue --addattr=memberHost=fqdn=hostname.$DOMAIN --all > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberHost: value #0 invalid per syntax: Invalid syntax." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-16: Verify fail on netgroup-add with valid setattr, invalid addattr value, and raw"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberHost=fqdn=hostname.$DOMAIN --addattr=memberHost=badvalue --raw > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberHost: value #1 invalid per syntax: Invalid syntax." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-002-17: Verify fail on netgroup-add with valid setattr, invalid addat
tr value, all and raw"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberHost=fqdn=hostname.$DOMAIN --addattr=memberHost=badvalue --all --raw > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberHost: value #1 invalid per syntax: Invalid syntax." $tmpout
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

##########################################################################
# NETGROUP MEMBERS
##########################################################################
# positive member netgroups tests

netgroup_add_member_positive()
{
	rlPhaseStartTest  "ipa-netgroup-003: Add users to netgroup"
		# Adding users to group1
		rlRun "ipa netgroup-add-member --users=$user1,$user2 $ngroup1" 0 "Adding $user1 and $user2 to $ngroup1"
		rlRun "ipa netgroup-add-member --users=$user3 $ngroup1" 0 "Adding $user3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1|grep $user1" 0 "Verifying that $user1 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep $user2" 0 "Verifying that $user2 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep $user3" 0 "Verifying that $user3 is in $ngroup1"
		rlRun "ipa user-show $user1 | grep netgroup | grep $ngroup1" 0 "Verify that netgroup enrollment with user-show for $user1"
		rlRun "ipa user-show $user2 | grep netgroup | grep $ngroup1" 0 "Verify that netgroup enrollment with user-show for $user2"
		rlRun "ipa user-show $user3 | grep netgroup | grep $ngroup1" 0 "Verify that netgroup enrollment with user-show for $user3"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-004: Add groups to netgroup"
		# Adding users to group1
		rlRun "ipa netgroup-add-member --groups=$group1,$group2 $ngroup1" 0 "Adding $group1 and $group2 to $ngroup1"
		rlRun "ipa netgroup-add-member --groups=$group3 $ngroup1" 0 "Adding $group3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1|grep $group1" 0 "Verifying that $group1 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep $group2" 0 "Verifying that $group2 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep $group3" 0 "Verifying that $group3 is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-005: Add hosts to netgroup"
		# Checking to ensure that addign a host to a netgroup works
		rlRun "ipa netgroup-add-member --hosts=$HOSTNAME $ngroup1" 0 "Adding local $HOSTNAME to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 0 "Verifying that $HOSTNAME is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-006: Add hostgroups to netgroup"
		# Adding a hostgroup to a netgroup
		rlRun "ipa netgroup-add-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "adding $hgroup1 and $hgroup2 to $ngroup1"
		rlRun "ipa netgroup-add-member --hostgroups=$hgroup3 $ngroup1" 0 "adding $hgroup3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 0 "Verifying that $hgroup1 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 0 "Verifying that $hgroup2 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 0 "Verifying that $hgroup1 is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-006-2: Add netgroups to netgroup"
		# Adding a netgroup to a netgroup
		rlRun "ipa netgroup-add $ngroup3 --desc=$ngroup3" 0 "adding $ngroup3 netgroup for test"
		rlRun "ipa netgroup-add-member --netgroups=$ngroup1,$ngroup2 $ngroup3" 0 "adding $ngroup1 and $ngroup2 to $ngroup3"
		rlRun "ipa netgroup-add-member --netgroups=$ngroup3 $ngroup1" 0 "adding $ngroup3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup1" 0 "Verifying that $ngroup1 is in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup2" 0 "Verifying that $ngroup2 is in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $ngroup3" 0 "Verifying that $hgroup1 is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-007: Add external host to netgroup"
		# Add an external host to ngroup1
		rlRun "ipa netgroup-add-member --hosts=dummy.myrelm $ngroup1" 0 "Add external host dummy.myrelm to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep dummy.myrelm" 0 "Verifying that dummy.myrelm is an External host $ngroup1"
	rlPhaseEnd
}

netgroup_remove_member_positive()
{
	rlPhaseStartTest  "ipa-netgroup-008: Remove users from netgroup"
		# Removing users from ngroup1
		rlRun "ipa netgroup-remove-member --users=$user1,$user2 $ngroup1" 0 "Removing $user1 and $user2 from $ngroup1"
		rlRun "ipa netgroup-remove-member --users=$user3 $ngroup1" 0 "Removing $user3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $user1" 1 "Verifying that $user1 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $user2" 1 "Verifying that $user2 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $user3" 1 "Verifying that $user3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-009: Remove groups from netgroup"
		# Removing groups from ngroup1
		rlRun "ipa netgroup-remove-member --groups=$group1,$group2 $ngroup1" 0 "Removing $group1 and $group2 from $ngroup1"
		rlRun "ipa netgroup-remove-member --groups=$group3 $ngroup1" 0 "Removing $group3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $group1" 1 "Verifying that $group1 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $group2" 1 "Verifying that $group2 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $group3" 1 "Verifying that $group3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-010: Remove hostgroups from netgroup"
		# Removing hostgroups from ngroup1
		rlRun "ipa netgroup-remove-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "Removing $hgroup1 and $hgroup2 from $ngroup1"
		rlRun "ipa netgroup-remove-member --hostgroups=$hgroup3 $ngroup1" 0 "Removing $hgroup3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 1 "Verifying that $hgroup1 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 1 "Verifying that $hgroup2 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 1 "Verifying that $hgroup3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-010-2: Remove netgroups from netgroup"
		# Removing netgroups from ngroup3
		rlRun "ipa netgroup-remove-member --netgroups=$ngroup1,$ngroup2 $ngroup3" 0 "Removing $ngroup1 and $ngroup2 from $ngroup3"
		rlRun "ipa netgroup-remove-member --netgroups=$ngroup3 $ngroup1" 0 "Removing $ngroup3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup1" 1 "Verifying that $ngroup1 is not in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup2" 1 "Verifying that $ngroup2 is not in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $ngroup3" 1 "Verifying that $ngroup3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-011: Remove host from netgroup"
		# Removing a host from ngroup1
		rlRun "ipa netgroup-remove-member --hosts=$HOSTNAME $ngroup1" 0 "Removing $HOSTNAME from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 1 "Verifying that $HOSTNAME is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-012: Remove externalhost from netgroup"
		# Removing an external host from ngroup1
		rlRun "ipa netgroup-remove-member --hosts=dummy.myrelm $ngroup1" 0 "Removing external host dummy.myrelm from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep dummy.myrelm" 1 "Verifying that external host dummy.myrelm is not in $ngroup1"
	rlPhaseEnd

}

# negative member netgroups tests
netgroup_add_member_negative()
{
	local tmpout=/tmp/members.out
	rlPhaseStartTest "ipa-netgroup-013-0: Add user to non-existent netgroup"
		rlRun "ipa netgroup-add-member nonetgroup --users=$user1 > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: nonetgroup: netgroup not found" $tmpout
	rlPhaseEnd
		
	rlPhaseStartTest "ipa-netgroup-013-1: Add user member that doesn't exist"
		rlRun "ipa netgroup-add-member --users=dummy $ngroup1 > $tmpout" 1 "Add user member that doesn't exist"
		cat /tmp/members.out | grep "dummy: no such entry"
		if [ $? -eq 0 ] ; then
			rlPass "Message returned as expected."
		else
			rlFail "ERROR: Message returned NOT as expected."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-014: Add group member that doesn't exist"
		rlRun "ipa netgroup-add-member --groups=dummy $ngroup1 > $tmpout" 1 "Add group member that doesn't exist"
		cat /tmp/members.out | grep "dummy: no such entry"
		if [ $? -eq 0 ] ; then
			rlPass "Message returned as expected."
		else
			rlFail "ERROR: Message returned NOT as expected."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-0: Add hostgroup member that doesn't exist"
		rlRun "ipa netgroup-add-member --hostgroups=dummy $ngroup1 > $tmpout" 1 "Add host group member that doesn't exist"
		cat /tmp/members.out | grep "dummy: no such entry"
		if [ $? -eq 0 ] ; then
			rlPass "Message returned as expected."
		else
			rlFail "ERROR: Message returned NOT as expected."
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-1: Add netgroup member that doesn't exist"
		rlRun "ipa netgroup-add-member $ngroup1 --netgroups=badnetgroup > $tmpout 2>&1" 1
		rlAssertGrep "member netgroup: badnetgroup: no such entry" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-2: Add host with invalid characters"
		rlRun "ipa netgroup-add-member $ngroup1 --hosts=badhost? > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "NEED Error message here...should not work" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-3: Add user of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --users=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-4: Add group of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --groups=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-5: Add host of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --hosts=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-6: Add hostgroup of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --hostgroups=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-015-7: Add netgroup of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --netgroups=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	[ -f $tmpout ] && rm -f $tmpout
}

netgroup_remove_member_negative()
{
	local tmpout=/tmp/members.out
	rlPhaseStartTest "ipa-netgroup-015-8: Fail to remove non-existent user from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --users=baduser > $tmpout 2>&1" 1
		rlAssertGrep "member user: baduser: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-015-9: Fail to remove non-existent group from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --groups=badgroup > $tmpout 2>&1" 1
		rlAssertGrep "member group: badgroup: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-015-10: Fail to remove non-existent host from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --hosts=badhost > $tmpout 2>&1" 1
		rlAssertGrep "member host: badhost: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-015-11: Fail to remove non-existent hostgroup from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --hostgroups=badhostgroup > $tmpout 2>&1" 1
		rlAssertGrep "member host group: badhostgroup: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-015-12: Fail to remove non-existent netgroup from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --netgroups=badnetgroup > $tmpout 2>&1" 1
		rlAssertGrep "member netgroup: badnetgroup: This entry is not a member" $tmpout
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

##########################################################################
# MODIFY NETGROUPS
##########################################################################
# positive modify netgroups tests
netgroup_mod_positive()
{
	rlPhaseStartTest  "ipa-netgroup-016: Modify description of netgroup"
		rlRun "ipa netgroup-mod --desc=testdesc11 $ngroup1" 0 "modify description for $ngroup1"
		# Verify
		rlRun "ipa netgroup-show --all $ngroup1 | grep testdesc11" 0 "Verifying description for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-017: Modify user catagory of netgroup"
		rlRun "ipa netgroup-mod --usercat=all $ngroup1" 0 "modify user catagory on $ngroup1"
		# Verify
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"User category\" | grep all" 0 "Verifying user catagory for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-018: Modify host catagory of netgroup"
		rlRun "ipa netgroup-mod --hostcat=all $ngroup1" 0 "modify host catagory on $ngroup1"
		# Verify
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Host category\" | grep all" 0 "Verifying host catagory for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-019: Modify remove user catagory of netgroup"
		rlRun "ipa netgroup-mod --usercat="" $ngroup1" 0 "remove user catagory on $ngroup1"
		# Verify
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"User category\"" 1 "Verifying user catagory was removed for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-020-0: Modify remove host catagory of netgroup"
		rlRun "ipa netgroup-mod --hostcat="" $ngroup1" 0 "remove host catagory on $ngroup1"
		# Verify
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Host category\"" 1 "Verifying host catagory was removed for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-1: Modify nisdomain of netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --nisdomain=newnisdom1" 0 "Modify nidomain for $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep 'NIS domain name: newnisdom'" 0 "Verifying NIS Domain changed"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-2: Display rights of netgroup during description change"
		rlRun "ipa netgroup-mod $ngroup1 --desc=rightstest --rights --all | grep 'attributelevelrights:'" 0 "Display rights during description change"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-3: Modify netgroup description with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=description=setattrd1" 0 "Change netgroup description for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep setattrd1" 0 "Verify netgroup description changed"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-4: Modify netgroup nisdomainname with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=nisdomainname=setattrnisdom" 0 "Change netgroup nisdomainname for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep setattrnisdom" 0 "Verify netgroup nisdomainame changed"
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-020-5: Modify netgroup user category with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=usercategory=all" 0 "Change netgroup user category for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep 'User category: all'" 0 "Verify netgroup user category changed"
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-020-6: Modify netgroup host category with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=hostcategory=all" 0 "Change netgroup host category for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep 'Host category: all'" 0 "Verify netgroup host category changed"
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-020-7: Modify netgroup to set initial user with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberuser=uid=$user3,cn=users,cn=accounts,$BASEDN" 0 "Set initial user to $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member User: $user3\"" 0 "Verify user added"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-8: Modify netgroup to set initial host with setattr"
		rlRun "ipa host-add $host1 --force" 0 "Add host for memberhost test"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberhost=fqdn=$host1,cn=computers,cn=accounts,$BASEDN" 0 "Set initial memberhost for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member Host: $host1\"" 0 "Verify memberhost added to netgroup"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-9: Modify netgroup to set initial external host with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=externalhost=$ehost1" 0 "Set initial external host for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"External host: $ehost1\"" 0 "Verify external host set for netgroup"
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-netgroup-020-10: Modify netgroup to set initial member hostgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberhost=cn=$hgroup1,cn=hostgroups,cn=accounts,$BASEDN" 0 "Set initial memberhost to hostgroup for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member Hostgroup: $hgroup1\"" 0 "Verify hostgroup set for initial member host"
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-020-11: Modify netgroup to set netgroup for initial member"
		ngroup3id=$(ipa netgroup-show $ngroup3 --all --raw|grep ipauniqueid:|awk '{print $2}')
		rlRun "ipa netgroup-mod $ngroup1 --setattr=member=ipauniqueid=$ngroup3id,cn=ng,cn=alt,$BASEDN" 0 "Modify netgroup to set initial member to netgroup"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member netgroups: $ngroup3\"" 0 "Verify netgroup set for initial member host"
	rlPhaseEnd
		
}

# negative modify netgroups tests
mod_netgroups_negative()
{
        rlPhaseStartTest "ipa-netgroup-021: Invalid User Catagory"
                command="ipa netgroup-mod --usercat=dummy $ngroup1"
                expmsg="ipa: ERROR: invalid 'usercat': must be one of (u'all',)"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlPhaseEnd

        rlPhaseStartTest "ipa-netgroup-022: Invalid Host Catagory"
                command="ipa netgroup-mod --hostcat=dummy $ngroup1"
                expmsg="ipa: ERROR: invalid 'hostcat': must be one of (u'all',)"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlPhaseEnd
}


##########################################################################
# SETATTR AND ADDATTR NETGROUP
##########################################################################
# positive attr netgroups tests
attr_netgroups_positive()
{
        rlPhaseStartTest  "ipa-netgroup-023: Add externalHost attribute to netgroup"
                # checking setaddr hostgroup-mod
               rlRun "ipa netgroup-mod --addattr=externalHost=ipaqatesthost $ngroup1" 0 "add externalHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep ipaqatesthost" 0 "Verifying the externalHost added to $ngroup1"
        rlPhaseEnd

        rlPhaseStartTest  "ipa-netgroup-024: Set externalHost attribute on netgroup"
                # checking setaddr hostgroup-mod --setattr
                rlRun "ipa netgroup-mod --setattr=externalHost=althost $ngroup1" 0 "setting externalHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep althost" 0 "Verifying the externalHost changed on $ngroup1"
        rlPhaseEnd

        rlPhaseStartTest  "ipa-netgroup-025: Add additional externalHost attribute on netgroup"
                # checking setaddr hostgroup-mod --setattr
                rlRun "ipa netgroup-mod --addattr=externalHost=ipaqatesthost $ngroup1" 0 "setting additional externalHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep \"althost, ipaqatesthost\"" 0 "Verifying the additional externalHost was added on $ngroup1"
        rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-026: Remove externalHost attributes with setattr on netgroup"
                # checking setaddr hostgroup-mod --setattr
                rlRun "ipa netgroup-mod --setattr=externalHost=\"\" $ngroup1" 0 "removing externalHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\"" 1 "Verifying setattr removed all externalHosts on $ngroup1"
        rlPhaseEnd

   	rlPhaseStartTest "ipa-netgroup-027: setattr on description"
        	rlRun "setAttribute netgroup description newdescription $ngroup1" 0 "Setting description attribute to value of newdescription."
        	rlRun "ipa netgroup-show --all $ngroup1 | grep Description | grep newdescription" 0 "Verifying netgroup Description was modified."
    	rlPhaseEnd

        rlPhaseStartTest "ipa-netgroup-028: setattr on nisDomainName"
                rlRun "setAttribute netgroup nisDomainName newNisDomain $ngroup1" 0 "Setting nisDomainName attribute to value of newNisDomain."
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"NIS domain name\" | grep newNisDomain" 0 "Verifying netgroup nisDomainName was modified."
        rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-029: Set memberUser attribute on netgroup"
		member1="uid=$user1,cn=users,cn=accounts,$BASEDN"
		rlLog "Settting first memberUser attribute to \"$member1\""
                rlRun "ipa netgroup-mod --setattr=memberUser=\"$member1\" $ngroup1" 0 "setting memberUser attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\" | grep $user1" 0 "Verifying the memberuser attribute changed on $ngroup1"
        rlPhaseEnd

        rlPhaseStartTest  "ipa-netgroup-030: Add additional memberUser attribute on netgroup"
		member2="uid=$user2,cn=users,cn=accounts,$BASEDN"
                rlLog "Settting second memberUser attribute to \"$member2\""
                rlRun "ipa netgroup-mod --addattr=memberUser=\"$member2\" $ngroup1" 0 "setting additional memberUser attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\" | grep \"$user1, $user2\"" 0 "Verifying the additional memberUser was added on $ngroup1"
        rlPhaseEnd

        rlPhaseStartTest  "ipa-netgroup-031: Remove memberUser attributes with setattr on netgroup"
                rlRun "ipa netgroup-mod --setattr=memberUser=\"\" $ngroup1" 0 "removing memberUser attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\"" 1 "Verifying setattr removed all member users on $ngroup1"
        rlPhaseEnd

	rlPhaseStartTest  "ipa-netgroup-032: Set memberHost attribute on netgroup"
		host1="host1.testrelm"
                member1="fqdn=$host1,cn=computers,cn=accounts,$BASEDN"
                rlLog "Settting first memberHost attribute to \"$member1\""
                rlRun "ipa netgroup-mod --setattr=memberHost=\"$member1\" $ngroup1" 0 "setting memberHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member Host\" | grep $host1" 0 "Verifying the membergroup attribute changed on $ngroup1"
        rlPhaseEnd
                
        rlPhaseStartTest  "ipa-netgroup-033: Add additional memberHost attribute on netgroup"
		host1="host1.testrelm"
		host2="host2.testrelm"
                member2="fqdn=$host2,cn=computers,cn=accounts,$BASEDN"
                rlRun "ipa netgroup-mod --addattr=memberHost=\"$member2\" $ngroup1" 0 "setting additional memberHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member Host\" | grep \"$host1, $host2\"" 0 "Verifying the additional memberHost was added on $ngroup1"
        rlPhaseEnd

        rlPhaseStartTest  "ipa-netgroup-034: Remove memberHost attributes with setattr on netgroup"
                rlRun "ipa netgroup-mod --setattr=memberHost=\"\" $ngroup1" 0 "removing memberHost attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member Host\"" 1 "Verifying setattr removed all member hosts on $ngroup1"
        rlPhaseEnd
}

# negative attr netgroups tests
attr_netgroups_negative()
{
	rlPhaseStartTest "ipa-netgroup-035: addattr on description"
	        # shouldn't be multivalue - additional add should fail
        	command="ipa netgroup-mod --addattr description=newer $ngroup1"
        	expmsg="ipa: ERROR: description: Only one value allowed."
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

   	rlPhaseStartTest "ipa-netgroup-036: setattr and addattr on ipauniqueid"
        	command="ipa netgroup-mod --setattr ipauniqueid=mynew-unique-id $ngroup1"
        	expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        	command="ipa netgroup-mod --addattr ipauniqueid=another-new-unique-id $ngroup1"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    	rlPhaseEnd

        rlPhaseStartTest "ipa-netgroup-037: addattr on nisDomainName"
                # shouldn't be multivalue - additional add should fail
                command="ipa netgroup-mod --addattr nisDomainName=secondDomain $ngroup1"
                expmsg="ipa: ERROR: nisdomainname: Only one value allowed."
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-038: setattr and addattr on dn"
        	command="ipa netgroup-mod --setattr dn=\"ipauniqueid=mynewDN,$NETGRPDN\" $ngroup1"
        	expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
        	command="ipa netgroup-mod --addattr dn=\"ipauniqueid=anothernewDN,$NETGRPDN\" $ngroup1"
        	rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
    	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-039: setattr and addattr on memberUser - Invalid Syntax"
                command="ipa netgroup-mod --setattr memberUser=$user1 $ngroup1"
                expmsg="ipa: ERROR: memberUser: value #0 invalid per syntax: Invalid syntax."
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
                command="ipa netgroup-mod --addattr memberUser=$user2 $ngroup1"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        rlPhaseEnd

        rlPhaseStartTest "ipa-netgroup-040: setattr and addattr on memberGroup"
                command="ipa netgroup-mod --setattr memberGroup=$group1 $ngroup1"
                expmsg="ipa: ERROR: attribute membergroup not allowed"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
                command="ipa netgroup-mod --addattr memberGroup=$group1 $ngroup1"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        rlPhaseEnd

        rlPhaseStartTest "ipa-netgroup-041: setattr and addattr on memberHost - Invalid Syntax"
		local HOSTNAME=`hostname`
                command="ipa netgroup-mod --setattr memberHost=$HOSTNAME $ngroup1"
                expmsg="ipa: ERROR: memberHost: value #0 invalid per syntax: Invalid syntax."
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
                command="ipa netgroup-mod --addattr memberHost=$HOSTNAME $ngroup1"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        rlPhaseEnd

        rlPhaseStartTest "ipa-netgroup-042: setattr and addattr on memberHostgroup"
                command="ipa netgroup-mod --setattr memberHostgroup=$hgroup1 $ngroup1"
                expmsg="ipa: ERROR: attribute memberhostgroup not allowed"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
                command="ipa netgroup-mod --addattr memberHostgroup=$hgroup1 $ngroup1"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
        rlPhaseEnd
}

#########################################################################
# DELETE NETGROUPS
##########################################################################
# positive show netgroups tests
del_netgroups_positive()
{
        rlPhaseStartTest  "ipa-netgroup-043: Delete Netgroups"
                # verifying hostgroup-del
		for item in $ngroup1 $ngroup2 ; do
                	rlRun "ipa netgroup-del $item" 0 "Deleting $item"
                	# Verify
                	rlRun "ipa netgroup-show $item" 2 "Verifying that $item doesn't deleted"
		done
        rlPhaseEnd
}

# negative show netgroups tests
del_netgroups_negative()
{
        rlPhaseStartTest "ipa-netgroup-044: Delete netgroup that doesn't exist"
                command="ipa netgroup-del ghost"
                expmsg="ipa: ERROR: ghost: netgroup not found"
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
        rlPhaseEnd
}

#########################################################################
# MANAGE NETGROUPS
##########################################################################
# manage netgroups tests
manage_netgroups_positive()
{
        rlPhaseStartTest "ipa-netgroup-045: Enable the manage net groups plugin"
		echo $CLIENT | grep $HOSTNAME
        	if [ $? -eq 0 ] ; then
                	rlLog "This is a CLIENT"
                	ssh root@$MASTER "echo $ADMINPW | ipa-managed-entries \"${ENTRY}\" enable" 
                	ssh root@$MASTER "echo $ADMINPW | ipa-managed-entries \"${ENTRY}\" status" > /tmp/plugin.out
                	cat /tmp/plugin.out | grep "Plugin Enabled"
                	if [ $? -eq 0 ] ; then
                        	rlPass "Host Net Manager Plugin is enabled"
                	else
                        	rlFail "Host Net Manage Plugin is NOT enabled, this may cause test failures."
                	fi
                        
        	else
                	rlLog "This is an IPA server"
                	execManageNGPPlugin enable
                	status=`execManageNGPPlugin status`
                	echo $status | grep "Plugin Enabled"
                	if [ $? -eq 0 ] ; then
                        	rlPass "Host Net Manage Plugin is enabled"
                	else
                        	rlFail "Host Net Manage Plugin is NOT enabled, this may cause test failures."
                	fi
        	fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-046: Add host group and verify net group"
		rlRun "ipa hostgroup-add --desc=mygroup mygroup" 0 "Adding host group with plugin enabled"
		rlRun "ipa netgroup-find --managed mygroup" 0 "Verify net group was added."
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-047: Delete host group and verify net group is deleted"
		rlRun "ipa hostgroup-del mygroup" 0 "Deleting host group with plugin disabled"
		rlRun "ipa netgroup-show --managed mygroup" 2 "Verify managed net group was deleted"
        rlPhaseEnd
}

manage_netgroups_negative()
{
        rlPhaseStartTest "ipa-netgroup-048: Attempt to deleted managed net group"
		# add a host group
		ipa hostgroup-add --desc=mygroup mygroup

		command="ipa netgroup-del mygroup"
                expmsg="ipa: ERROR: Server is unwilling to perform: Deleting a managed entry is not allowed. It needs to be manually unlinked first."
                rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."

		# clean up
		ipa hostgroup-del mygroup
	rlPhaseEnd

	rlPhaseStartTest "ipa-netgroup-049: manage netgroups: Incorrect directory manager password"
		rlRun "ssh root@$MASTER \"echo badpassword | ipa-managed-entries status\" > /tmp/pluginerr.out 2>&1" 1 "ipa manage net group status with incorrect directory manager password."
		cat /tmp/pluginerr.out | grep "Traceback"
		if [ $? -eq 0 ] ; then
			rlFail "ERROR: Traceback returned with bad directory manager password."
		else
			rlPass "No Traceback returned with incorrect directory manager password."
		fi
	rlPhaseEnd
}
