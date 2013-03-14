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
	find_netgroups
	mod_netgroups
	show_netgroups
	#attr_netgroups
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
                rlRun "rlDistroDiff keyctl"
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

find_netgroups()
{
	netgroup_find_positive
	netgroup_find_negative
	netgroup_find_positive_other
	netgroup_find_negative_other
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
	netgroup_mod_negative
}

#attr_netgroups()
#{
	#attr_netgroups_positive
	#attr_netgroups_negative
#}

show_netgroups()
{
	netgroup_show_positive
	netgroup_show_negative
}

del_netgroups()
{
	netgroup_del_positive
	netgroup_del_negative
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
	rlPhaseStartTest "netgroup_add_positive_001: add netgroups"
		echo "Add netgroup $ngroup1"
        	rlRun "addNetgroup $ngroup1 test-group-1" 0 "adding first netgroup"
		echo "Add netgroup $ngroup2"
        	rlRun "addNetgroup $ngroup2 test-group-2" 0 "adding second netgroup"
		# Verify if it exists
		rlRun "ipa netgroup-find $ngroup1 | grep $ngroup1" 0 "checking to ensure first netgroup was created"
		rlRun "ipa netgroup-find $ngroup2 | grep $ngroup2" 0 "checking to ensure second netgroup was created"
	rlPhaseEnd 

	rlPhaseStartTest "netgroup_add_positive_002: add netgroup positive with nisdomain"
		rlRun "ipa netgroup-add ng-001-1 --desc=ng-001-1 --nisdomain=testnis.dom"
		rlRun "ipa netgroup-show ng-001-1"
		rlRun "ipa netgroup-del ng-001-1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_003: add netgroup positive with nisdomain, usercat=all"
		rlRun "ipa netgroup-add ng-001-2 --desc=ng-001-2 --nisdomain=testnis.dom --usercat=all"
		rlRun "ipa netgroup-show ng-001-2"
		rlRun "ipa netgroup-del ng-001-2"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_004: add netgroup positive with nisdomain, hostcat=all"
		rlRun "ipa netgroup-add ng-001-3 --desc=ng-001-3 --nisdomain=testnis.dom --hostcat=all"
		rlRun "ipa netgroup-show ng-001-3"
		rlRun "ipa netgroup-del ng-001-3"
	rlPhaseEnd
		
	rlPhaseStartTest "netgroup_add_positive_005: add netgroup positive with nisdomain, usercat=all, hostcat=all"
		rlRun "ipa netgroup-add ng-001-4 --desc=ng-001-4 --nisdomain=testnis.dom --usercat=all --hostcat=all"
		rlRun "ipa netgroup-show ng-001-4"
		rlRun "ipa netgroup-del ng-001-4"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_006: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr"
		rlRun "ipa netgroup-add ng-001-5 --desc=ng-001-5 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost"
		rlRun "ipa netgroup-find ng-001-5 --desc=ng-001-5 --nisdomain=testnis.dom --usercat=all --hostcat=all | grep 'External host: ipaqatesthost'"
		rlRun "ipa netgroup-del ng-001-5"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_007: add netgroup positive with nisdomain, usercat=all, hostcat=all, setattr"
		rlRun "ipa netgroup-add ng-001-6 --desc=ng-001-6 --nisdomain=testnis.dom --usercat=all --hostcat=all --setattr=externalHost=ipaqatesthost"
		rlRun "ipa netgroup-find ng-001-6 --desc=ng-001-6 --nisdomain=testnis.dom --usercat=all --hostcat=all | grep 'External host: ipaqatesthost'"
		rlRun "ipa netgroup-del ng-001-6"
	rlPhaseEnd
		
	rlPhaseStartTest "netgroup_add_positive_008: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr"
		rlRun "ipa netgroup-add ng-001-7 --desc=ng-001-7 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2"
		rlRun "ipa netgroup-find ng-001-7 --desc=ng-001-7 --nisdomain=testnis.dom --usercat=all --hostcat=all | grep 'External host: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-7"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_009: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr, all"
		rlRun "ipa netgroup-add ng-001-8 --desc=ng-001-8 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2 --all"
		rlRun "ipa netgroup-find ng-001-8 --desc=ng-001-8 --nisdomain=testnis.dom --usercat=all --hostcat=all --all| grep 'External host: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-8"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_010: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr, raw"
		rlRun "ipa netgroup-add ng-001-9 --desc=ng-001-9 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2 --raw"
		rlRun "ipa netgroup-find ng-001-9 --desc=ng-001-9 --nisdomain=testnis.dom --usercat=all --hostcat=all --raw| grep 'externalhost: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-9"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_positive_011: add netgroup positive with nisdomain, usercat=all, hostcat=all, addattr, setattr, all, raw"
		rlRun "ipa netgroup-add ng-001-10 --desc=ng-001-10 --nisdomain=testnis.dom --usercat=all --hostcat=all --addattr=externalHost=ipaqatesthost1 --setattr=externalHost=ipaqatesthost2 --all --raw"
		rlRun "ipa netgroup-find ng-001-10 --desc=ng-001-10 --nisdomain=testnis.dom --usercat=all --hostcat=all --all --raw| grep 'externalhost: ipaqatesthost[12]'"
		rlRun "ipa netgroup-del ng-001-10"
	rlPhaseEnd
}

# negative add netgroups tests
netgroup_add_negative()
{
	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "netgroup_add_negative_001: Add duplicate netgroup"
		command="addNetgroup $ngroup1 test-group-1"
		expmsg="ipa: ERROR: netgroup with name $ngroup1 already exists"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_002: Verify fail on netgroup-add with empty desc" 
		rlRun "ipa netgroup-add testng-002 --desc=\"\" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'desc' is required"  $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_003: Verify fail on netgroup-add with space for desc"
		rlRun "ipa netgroup-add testng-002 --desc=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'desc': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_004: Verify fail on netgroup-add with space for nisdomain"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'nisdomain': may only include letters, numbers, _, -, and ." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_005: Verify fail on netgroup-add with invalid usercat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --usercat=badcat > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'usercat': must be 'all'" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_006: Verify fail on netgroup-add with space for usercat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --usercat=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'usercat': must be 'all'" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_007: Verify fail on netgroup-add with invalid hostcat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --hostcat=badcat > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'hostcat': must be 'all'" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_008: Verify fail on netgroup-add with space for hostcat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --hostcat=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'hostcat': must be 'all'" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_009: Verify fail on netgroup-add with invalid usercat and valid hostcat"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --usercat=badcat --hostcat=all > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'usercat': must be 'all'" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_010: Verify fail on netgroup-add with invalid setattr value"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberhost=badvalue > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberhost: Invalid syntax." $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_011: Verify fail on netgroup-add with invalid setattr attr"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=badattr=fqdn=hostname.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: attribute \"badattr\" not allowed" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_012: Verify fail on netgroup-add with invalid addattr value"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --addattr=memberhost=badvalue > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberhost: Invalid syntax." $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_013: Verify fail on netgroup-add with invalid addattr attr"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --addattr=badattr=fqdn=hostname.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: attribute \"badattr\" not allowed" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_add_negative_014: Verify fail on netgroup-add with both desc and --addattr desription (BZ 796390)"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --addattr=description=DESCRIPTION > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: description: Only one value allowed." $tmpout
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 796390 found...ipa netgroup-add with both --desc and --addattr=description returns internal error"
		else
			rlPass "BZ 796390 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_015: Verify fail on netgroup-add with setattr desc and invalid aaddattr attr"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=description=desc2 --addattr=badattr=fqdn=hostname.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: attribute \"badattr\" not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_016: Verify fail on netgroup-add with setattr invalid value, valid addattr and all"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberhost=badvalue --addattr=memberhost=fqdn=hostname.$DOMAIN --all > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberhost: Invalid syntax." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_017: Verify fail on netgroup-add with valid setattr, invalid addattr value, and raw"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberhost=fqdn=hostname.$DOMAIN --addattr=memberhost=badvalue --raw > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberhost: Invalid syntax." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_negative_018: Verify fail on netgroup-add with valid setattr, invalid addattr value, all and raw"
		rlRun "ipa netgroup-add testng-002 --desc=testng-002 --nisdomain=mynisdom --setattr=memberhost=fqdn=hostname.$DOMAIN --addattr=memberhost=badvalue --all --raw > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: memberhost: Invalid syntax." $tmpout
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

##########################################################################
# NETGROUP MEMBERS
##########################################################################
# positive member netgroups tests

netgroup_add_member_positive()
{
	local HOSTNAME=`hostname`
	rlPhaseStartTest "netgroup_add_member_positive_001: users to netgroup"
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

	rlPhaseStartTest "netgroup_add_member_positive_002: Add groups to netgroup"
		# Adding users to group1
		rlRun "ipa netgroup-add-member --groups=$group1,$group2 $ngroup1" 0 "Adding $group1 and $group2 to $ngroup1"
		rlRun "ipa netgroup-add-member --groups=$group3 $ngroup1" 0 "Adding $group3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1|grep $group1" 0 "Verifying that $group1 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep $group2" 0 "Verifying that $group2 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep $group3" 0 "Verifying that $group3 is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_positive_003: Add hosts to netgroup"
		# Checking to ensure that addign a host to a netgroup works
		rlRun "ipa netgroup-add-member --hosts=$HOSTNAME $ngroup1" 0 "Adding local $HOSTNAME to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 0 "Verifying that $HOSTNAME is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_positive_004: Add hostgroups to netgroup"
		# Adding a hostgroup to a netgroup
		rlRun "ipa netgroup-add-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "adding $hgroup1 and $hgroup2 to $ngroup1"
		rlRun "ipa netgroup-add-member --hostgroups=$hgroup3 $ngroup1" 0 "adding $hgroup3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 0 "Verifying that $hgroup1 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 0 "Verifying that $hgroup2 is in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 0 "Verifying that $hgroup1 is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_positive_005: Add netgroups to netgroup"
		# Adding a netgroup to a netgroup
		rlRun "ipa netgroup-add $ngroup3 --desc=$ngroup3" 0 "adding $ngroup3 netgroup for test"
		rlRun "ipa netgroup-add-member --netgroups=$ngroup1,$ngroup2 $ngroup3" 0 "adding $ngroup1 and $ngroup2 to $ngroup3"
		rlRun "ipa netgroup-add-member --netgroups=$ngroup3 $ngroup1" 0 "adding $ngroup3 to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup1" 0 "Verifying that $ngroup1 is in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup2" 0 "Verifying that $ngroup2 is in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $ngroup3" 0 "Verifying that $hgroup1 is in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_positive_006: Add external host to netgroup"
		# Add an external host to ngroup1
		rlRun "ipa netgroup-add-member --hosts=dummy.myrelm $ngroup1" 0 "Add external host dummy.myrelm to $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep dummy.myrelm" 0 "Verifying that dummy.myrelm is an External host $ngroup1"
	rlPhaseEnd
}

netgroup_remove_member_positive()
{
	rlPhaseStartTest "netgroup_remove_member_positive_001: Remove users from netgroup"
		# Removing users from ngroup1
		rlRun "ipa netgroup-remove-member --users=$user1,$user2 $ngroup1" 0 "Removing $user1 and $user2 from $ngroup1"
		rlRun "ipa netgroup-remove-member --users=$user3 $ngroup1" 0 "Removing $user3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $user1" 1 "Verifying that $user1 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $user2" 1 "Verifying that $user2 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $user3" 1 "Verifying that $user3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_remove_member_positive_002: Remove groups from netgroup"
		# Removing groups from ngroup1
		rlRun "ipa netgroup-remove-member --groups=$group1,$group2 $ngroup1" 0 "Removing $group1 and $group2 from $ngroup1"
		rlRun "ipa netgroup-remove-member --groups=$group3 $ngroup1" 0 "Removing $group3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $group1" 1 "Verifying that $group1 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $group2" 1 "Verifying that $group2 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $group3" 1 "Verifying that $group3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_remove_member_positive_003: Remove hostgroups from netgroup"
		# Removing hostgroups from ngroup1
		rlRun "ipa netgroup-remove-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "Removing $hgroup1 and $hgroup2 from $ngroup1"
		rlRun "ipa netgroup-remove-member --hostgroups=$hgroup3 $ngroup1" 0 "Removing $hgroup3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 1 "Verifying that $hgroup1 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 1 "Verifying that $hgroup2 is not in $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 1 "Verifying that $hgroup3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_remove_member_positive_004: Remove netgroups from netgroup"
		# Removing netgroups from ngroup3
		rlRun "ipa netgroup-remove-member --netgroups=$ngroup1,$ngroup2 $ngroup3" 0 "Removing $ngroup1 and $ngroup2 from $ngroup3"
		rlRun "ipa netgroup-remove-member --netgroups=$ngroup3 $ngroup1" 0 "Removing $ngroup3 from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup1" 1 "Verifying that $ngroup1 is not in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup3 | grep $ngroup2" 1 "Verifying that $ngroup2 is not in $ngroup3"
		rlRun "ipa netgroup-show --all $ngroup1 | grep $ngroup3" 1 "Verifying that $ngroup3 is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_remove_member_positive_005: Remove host from netgroup"
		# Removing a host from ngroup1
		rlRun "ipa netgroup-remove-member --hosts=$HOSTNAME $ngroup1" 0 "Removing $HOSTNAME from $ngroup1"
		# Checking to ensure that it happened.
		rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 1 "Verifying that $HOSTNAME is not in $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_remove_member_positive_006: Remove externalhost from netgroup"
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
	rlPhaseStartTest "netgroup_add_member_negative_001: Add user to non-existent netgroup"
		rlRun "ipa netgroup-add-member nonetgroup --users=$user1 > $tmpout 2>&1" 2
		rlAssertGrep "ipa: ERROR: nonetgroup: netgroup not found" $tmpout
	rlPhaseEnd
		
	rlPhaseStartTest "netgroup_add_member_negative_002: Add user member that doesn't exist"
		rlRun "ipa netgroup-add-member --users=dummy $ngroup1 > $tmpout" 1 "Add user member that doesn't exist"
		cat /tmp/members.out | grep "dummy: no such entry"
		if [ $? -eq 0 ] ; then
			rlPass "Message returned as expected."
		else
			rlFail "ERROR: Message returned NOT as expected."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_003: Add group member that doesn't exist"
		rlRun "ipa netgroup-add-member --groups=dummy $ngroup1 > $tmpout" 1 "Add group member that doesn't exist"
		cat /tmp/members.out | grep "dummy: no such entry"
		if [ $? -eq 0 ] ; then
			rlPass "Message returned as expected."
		else
			rlFail "ERROR: Message returned NOT as expected."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_004: Add hostgroup member that doesn't exist"
		rlRun "ipa netgroup-add-member --hostgroups=dummy $ngroup1 > $tmpout" 1 "Add host group member that doesn't exist"
		cat /tmp/members.out | grep "dummy: no such entry"
		if [ $? -eq 0 ] ; then
			rlPass "Message returned as expected."
		else
			rlFail "ERROR: Message returned NOT as expected."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_005: Add netgroup member that doesn't exist"
		rlRun "ipa netgroup-add-member $ngroup1 --netgroups=badnetgroup > $tmpout 2>&1" 1
		rlAssertGrep "member netgroup: badnetgroup: no such entry" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_006: Add host with invalid characters (BZ 797256)"
		rlRun "ipa netgroup-add-member $ngroup1 --hosts=badhost? > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: invalid 'host': only letters, numbers, _, and - are allowed." $tmpout
		if [ $(grep "badhost\?" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797256 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
			rlLog  "deleting invalid entry"
			rlRun  "ipa netgroup-remove-member $ngroup1 --hosts=badhost?"
		fi

		rlRun "ipa netgroup-add-member $ngroup1 --hosts=anotherbadhost\!\@\#\$\%\^\&\*\\(\\) > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: invalid 'host': only letters, numbers, _, and - are allowed." $tmpout
		if [ $(grep "anotherbadhost\!\@\#\$\%\^\&\*\\(\\)" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797256 Found...ipa netgroup-add-member --hosts should not allow invalid characters"
			rlLog  "deleting invalid entry"
			rlRun  "ipa netgroup-remove-member $ngroup1 --hosts=anotherbadhost\!\@\#\$\%\^\&\*\\(\\)"
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_007: Add user of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --users=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_008: Add group of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --groups=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_009: Add host of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --hosts=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_010: Add hostgroup of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --hostgroups=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_011: Add netgroup of space should do nothing"
		rlRun "ipa netgroup-add-member $ngroup1 --netgroups=\" \" > $tmpout 2>&1" 0
		rlAssertGrep "Number of members added 0" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_012: Add netgroup with nisdomain containing commas (BZ 797237)"
		rlRun "ipa netgroup-add badng1 --desc=desc1 --nisdomain=test1,test2 > $tmpout 2>&1" 1
		rlAssertNotGrep "test1,test2" $tmpout
		if [ $(grep "test1,test2" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlLog "cleaning up incorrectly added netgroup"
			rlRun "ipa netgroup-del badng1"
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_add_member_negative_013: Add netgroup with nisdomain containing invalid characters (BZ 797237)"
		rlRun "ipa netgroup-add badng1 --desc=desc1 --nisdomain=test^\\|\\!\\@\\#\\$\\%\\&\\*\\)\\( > $tmpout 2>&1" 1
		rlAssertNotGrep "test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout
		if [ $(grep "test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout | wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlFail "This BZ also covers other invalid characters"
			rlLog "cleaning up incorrectly added netgroup"
			rlRun "ipa netgroup-del badng1"
		fi
	rlPhaseEnd

	[ -f $tmpout ] && rm -f $tmpout
}

netgroup_remove_member_negative()
{
	local tmpout=/tmp/members.out
	rlPhaseStartTest "netgroup_remove_member_negative_001: Fail to remove non-existent user from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --users=baduser > $tmpout 2>&1" 1
		rlAssertGrep "member user: baduser: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_remove_member_negative_002: Fail to remove non-existent group from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --groups=badgroup > $tmpout 2>&1" 1
		rlAssertGrep "member group: badgroup: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_remove_member_negative_003: Fail to remove non-existent host from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --hosts=badhost > $tmpout 2>&1" 1
		rlAssertGrep "member host: badhost: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_remove_member_negative_004: Fail to remove non-existent hostgroup from netgroup"
		rlRun "ipa netgroup-remove-member $ngroup1 --hostgroups=badhostgroup > $tmpout 2>&1" 1
		rlAssertGrep "member host group: badhostgroup: This entry is not a member" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_remove_member_negative_005: Fail to remove non-existent netgroup from netgroup"
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
	rlPhaseStartTest "netgroup_mod_positive_001: Modify description of netgroup"
		rlRun "ipa netgroup-mod --desc=testdesc11 $ngroup1" 0 "modify description for $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep testdesc11" 0 "Verifying description for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_002: Modify user catagory of netgroup"
		rlRun "ipa netgroup-mod --usercat=all $ngroup1" 0 "modify user catagory on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"User category\" | grep all" 0 "Verifying user catagory for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_003: Modify host catagory of netgroup"
		rlRun "ipa netgroup-mod --hostcat=all $ngroup1" 0 "modify host catagory on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Host category\" | grep all" 0 "Verifying host catagory for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_004: Modify remove user catagory of netgroup"
		rlRun "ipa netgroup-mod --usercat="" $ngroup1" 0 "remove user catagory on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"User category\"" 1 "Verifying user catagory was removed for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_005: Modify remove host catagory of netgroup"
		rlRun "ipa netgroup-mod --hostcat="" $ngroup1" 0 "remove host catagory on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Host category\"" 1 "Verifying host catagory was removed for $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_006: Modify nisdomain of netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --nisdomain=newnisdom1" 0 "Modify nidomain for $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1|grep 'NIS domain name: newnisdom'" 0 "Verifying NIS Domain changed"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_007: Display rights of netgroup during description change"
		rlRun "ipa netgroup-mod $ngroup1 --desc=rightstest --rights --all | grep 'attributelevelrights:'" 0 "Display rights during description change"
	rlPhaseEnd

#### externalhost attr
	rlPhaseStartTest "netgroup_mod_positive_008: Add externalHost attribute to netgroup"
		rlRun "ipa netgroup-mod --addattr=externalHost=ipaqatesthost $ngroup1" 0 "add externalHost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep ipaqatesthost" 0 "Verifying the externalHost added to $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_009: Set externalHost attribute on netgroup"
		rlRun "ipa netgroup-mod --setattr=externalHost=althost $ngroup1" 0 "setting externalHost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep althost" 0 "Verifying the externalHost changed on $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_010: Add additional externalHost attribute on netgroup"
		rlRun "ipa netgroup-mod --addattr=externalHost=ipaqatesthost $ngroup1" 0 "Setting additional externalHost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\" | grep \"althost, ipaqatesthost\"" 0 "Verifying the additional externalHost was added on $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_011: Delete one externalHost from netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --delattr=externalHost=althost" 0 "Deleting one externalhost from $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 | grep \"External host\"|grep -v althost" 0 "Verifying externalhost was deleted"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_012: Remove externalHost attributes with setattr on netgroup"
		rlRun "ipa netgroup-mod --setattr=externalHost=\"\" $ngroup1" 0 "removing externalHost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"External host\"" 1 "Verifying setattr removed all externalHosts on $ngroup1"
	rlPhaseEnd

#### description attr
	rlPhaseStartTest "netgroup_mod_positive_013: setattr on description"
		rlRun "setAttribute netgroup description newdescription $ngroup1" 0 "Setting description attribute to value of newdescription."
		rlRun "ipa netgroup-show --all $ngroup1 | grep Description | grep newdescription" 0 "Verifying netgroup Description was modified."
	rlPhaseEnd

#### nisdomainname attr
	rlPhaseStartTest "netgroup_mod_positive_014: setattr on nisDomainName"
		rlRun "setAttribute netgroup nisDomainName newNisDomain $ngroup1" 0 "Setting nisDomainName attribute to value of newNisDomain."
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"NIS domain name\" | grep newNisDomain" 0 "Verifying netgroup nisDomainName was modified."
	rlPhaseEnd

#### memberuser attr users
	rlPhaseStartTest "netgroup_mod_positive_015: Set memberuser attribute on netgroup"
		member1="uid=$user1,cn=users,cn=accounts,$BASEDN"
		rlLog "Setting first memberuser attribute to \"$member1\""
		rlRun "ipa netgroup-mod --setattr=memberuser=\"$member1\" $ngroup1" 0 "setting memberuser attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\" | grep $user1" 0 "Verifying the memberuser attribute changed on $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_016: Add additional memberuser attribute on netgroup"
		member2="uid=$user2,cn=users,cn=accounts,$BASEDN"
		rlLog "Setting second memberuser attribute to \"$member2\""
		rlRun "ipa netgroup-mod --addattr=memberuser=\"$member2\" $ngroup1" 0 "setting additional memberuser attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\" | grep \"$user1, $user2\"" 0 "Verifying the additional memberuser was added on $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_017: Delete one memberuser attribute from netgroup"
		member2="uid=$user2,cn=users,cn=accounts,$BASEDN"
		rlLog "Deleting one memberuser attribute entry for $user2"
		rlRun "ipa netgroup-mod $ngroup1 --delattr=memberuser=\"$member2\"" 0 "deleting one memberuser from $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 --all | grep \"Member Group:\" | grep \"$user2\"" 1 "Verifying memberuser deleted from $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_018: Remove memberuser attributes with setattr on netgroup [BZ 887015]"
		rlLog "Executing: ipa netgroup-mod --setattr=memberuser=\"\" $ngroup1"
		rlRun "ipa netgroup-mod --setattr=memberuser=\"\" $ngroup1" 0 "removing memberuser attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\"" 1 "Verifying setattr removed all member users on $ngroup1"
	rlPhaseEnd

#### memberuser attr groups
	rlPhaseStartTest "netgroup_mod_positive_019: Set group for memberuser attribute on netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberuser=cn=$group1,cn=groups,cn=accounts,$BASEDN" 0 "setting group for memberuser attribute on $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 --all| grep \"Member Group: $group1\"" 0 "Verifying group added to $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_020: Add additional group for memberuser attribute on netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberuser=cn=$group2,cn=groups,cn=accounts,$BASEDN" 0 "setting additional group for memberuser attribute on $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 --all|grep  \"Member Group: $group1, $group2\"" 0 "Verifying group added to $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_021: Delete one group from memberuser attribute for netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --delattr=memberuser=cn=$group2,cn=groups,cn=accounts,$BASEDN" 0 "deleting one group from memberuser attribute for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 --all | grep \"Member Group:\" | grep \"$group2\"" 1 "Verifying memberuser group deleted from $ngroup1"
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_mod_positive_022: Remove memberuser attributes with setattr on netgroup [BZ 887015]"
		rlLog "Exceuting: ipa netgroup-mod --setattr=memberuser=\"\" $ngroup1"
		rlRun "ipa netgroup-mod --setattr=memberuser=\"\" $ngroup1" 0 "removing memberuser attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member User\"" 1 "Verifying setattr removed all member users on $ngroup1"
	rlPhaseEnd

#### memberhost attr
	rlPhaseStartTest "netgroup_mod_positive_023: Set memberhost attribute on netgroup"
		host1="host1.$DOMAIN"
		member1="fqdn=$host1,cn=computers,cn=accounts,$BASEDN"
		rlLog "Setting first memberhost attribute to \"$member1\""
		rlRun "ipa netgroup-mod --setattr=memberhost=\"$member1\" $ngroup1" 0 "setting memberhost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member Host\" | grep $host1" 0 "Verifying the membergroup attribute changed on $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_024: Add additional memberhost attribute on netgroup"
		host1="host1.$DOMAIN"
		host2="host2.$DOMAIN"
		member2="fqdn=$host2,cn=computers,cn=accounts,$BASEDN"
		rlRun "ipa netgroup-mod --addattr=memberhost=\"$member2\" $ngroup1" 0 "setting additional memberhost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member Host\" | grep \"$host1, $host2\"" 0 "Verifying the additional memberhost was added on $ngroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_025: Delete one memberhost from netgroup"
		host2="host2.$DOMAIN"
		member2="fqdn=$host2,cn=computers,cn=accounts,$BASEDN"
		rlRun "ipa netgroup-mod $ngroup1 --delattr=memberhost=\"$member2\"" 0 "deleting one memberhost from $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 | grep \"Member Host\" | grep -v \"$host2\"" 0 "Verify memberhost was deleted"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_026: Remove memberhost attributes with setattr on netgroup [BZ 887015]"
		rlLog "Executing: ipa netgroup-mod --setattr=memberhost=\"\" $ngroup1"
		rlRun "ipa netgroup-mod --setattr=memberhost=\"\" $ngroup1" 0 "removing memberhost attribute on $ngroup1"
		rlRun "ipa netgroup-show --all $ngroup1 | grep \"Member Host\"" 1 "Verifying setattr removed all member hosts on $ngroup1"
	rlPhaseEnd

#### usercat attr
	rlPhaseStartTest "netgroup_mod_positive_027: Modify netgroup user category with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=usercategory=all" 0 "Change netgroup user category for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep 'User category: all'" 0 "Verify netgroup user category changed"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_028: Modify netgroup to clear user category with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=usercategory=\"\"" 0 "Change netgroup user category for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep -v 'User category:'" 0 "Verify netgroup user category changed"
	rlPhaseEnd

#### hostcat attr
	rlPhaseStartTest "netgroup_mod_positive_029: Modify netgroup host category with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=hostcategory=all" 0 "Change netgroup host category for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep 'Host category: all'" 0 "Verify netgroup host category changed"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_030: Modify netgroup to clear host category with setattr"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=hostcategory=\"\"" 0 "Change netgroup host category for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep -v 'Host category:'" 0 "Verify netgroup host category changed"
	rlPhaseEnd

#### hostgroup attr
	rlPhaseStartTest "netgroup_mod_positive_031: Modify netgroup to set initial member hostgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberhost=cn=$hgroup1,cn=hostgroups,cn=accounts,$BASEDN" 0 "Set initial memberhost to hostgroup for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member Hostgroup: $hgroup1\"" 0 "Verify hostgroup set for initial member host"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_032: Modify netgroup to add another member hostgroup"
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberhost=cn=$hgroup2,cn=hostgroups,cn=accounts,$BASEDN" 0 "Set initial memberhost to hostgroup for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member Hostgroup: $hgroup1, $hgroup2\"" 0 "Verify hostgroup set for initial member host"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_033: Modify netgroup to delete one member hostgroup"
		rlRun "ipa netgroup-mod $ngroup1 --delattr=memberhost=cn=$hgroup2,cn=hostgroups,cn=accounts,$BASEDN" 0 "Delete one hostgroup from $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member Hostgroup:\" | grep -v $hgroup2" 0 "Verifying one hostgroup deleted from netgroup"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_034: Modify netgroup to clear member hostgroup [BZ 887015]"
		rlLog "Executing: ipa netgroup-mod $ngroup1 --setattr=memberhost=\"\"" 
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberhost=\"\"" 0 "Set initial memberhost to hostgroup for $ngroup1"
		rlRun "ipa netgroup-show $ngroup1|grep -v \"Member Hostgroup:\"" 0 "Verify hostgroup set for initial member host"
	rlPhaseEnd

#### netgroup attr
	rlPhaseStartTest "netgroup_mod_positive_035: Modify netgroup to set initial member netgroup"
		ngroup2id=$(ipa netgroup-show $ngroup2 --all --raw|grep ipauniqueid:|awk '{print $2}')
		rlRun "ipa netgroup-mod $ngroup1 --setattr=member=ipauniqueid=$ngroup2id,cn=ng,cn=alt,$BASEDN" 0 "Modify netgroup to set initial member to netgroup"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member netgroups: $ngroup2\"" 0 "Verify netgroup set for initial member host"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_036: Modify netgroup to add another member netgroup"
		ngroup3id=$(ipa netgroup-show $ngroup3 --all --raw|grep ipauniqueid:|awk '{print $2}')
		rlRun "ipa netgroup-mod $ngroup1 --addattr=member=ipauniqueid=$ngroup3id,cn=ng,cn=alt,$BASEDN" 0 "Modify netgroup to set initial member to netgroup"
		rlRun "ipa netgroup-show $ngroup1|grep \"Member netgroups: $ngroup2, $ngroup3\"" 0 "Verify netgroup set for initial member host"
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_mod_positive_037: Modify netgroup to delete one member netgroup"
		ngroup3id=$(ipa netgroup-show $ngroup3 --all --raw|grep ipauniqueid:|awk '{print $2}')
		rlRun "ipa netgroup-mod $ngroup1 --delattr=member=ipauniqueid=$ngroup3id,cn=ng,cn=alt,$BASEDN" 0 "Delete member netgroup from $ngroup1"
		rlRun "ipa netgroup-show $ngroup1 | grep \"Member netgroups:\" | grep -v \"$ngroup3\"" 0 "Verifying member netgroup deleted from netgroup"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_positive_038: Modify netgroup to clear member netgroup [BZ 887015]"
		rlLog "Executing: ipa netgroup-mod $ngroup1 --setattr=member=\"\"" 
		rlRun "ipa netgroup-mod $ngroup1 --setattr=member=\"\"" 0 "Modify netgroup to set initial member to netgroup"
		rlRun "ipa netgroup-show $ngroup1|grep -v \"Member netgroups:\"" 0 "Verify netgroup set for initial member host"
	rlPhaseEnd
}

# negative modify netgroups tests
netgroup_mod_negative()
{
	local tmpout=/tmp/errormsg.out
#### usercat
	rlPhaseStartTest "netgroup_mod_negative_001: Invalid User Catagory"
		command="ipa netgroup-mod --usercat=dummy $ngroup1"
		expmsg="ipa: ERROR: invalid 'usercat': must be 'all'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlPhaseEnd

#### hostcat
	rlPhaseStartTest "netgroup_mod_negative_002: Invalid Host Catagory"
		command="ipa netgroup-mod --hostcat=dummy $ngroup1"
		expmsg="ipa: ERROR: invalid 'hostcat': must be 'all'"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."
	rlPhaseEnd

#### desc
	rlPhaseStartTest "netgroup_mod_negative_003: Invalid modify netgroup with more than one desc"
		rlRun "ipa netgroup-mod $ngroup1 --desc=desc1 --desc=desc2 > $tmpout 2>&1" 1 
		rlAssertGrep "ipa: ERROR: invalid 'description': Only one value is allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_004: Invalid modify netgroup with desc and setattr=description"
		rlRun "ipa netgroup-mod $ngroup1 --desc=desc1 --addattr=description=desc2 > $tmpout 2>&1" 1 
		rlAssertGrep "ipa: ERROR: description: Only one value allowed." $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_005: addattr on description"
		# shouldn't be multivalue - additional add should fail
		command="ipa netgroup-mod --addattr description=newer $ngroup1"
		expmsg="ipa: ERROR: description: Only one value allowed."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_006: Invalid modify to delete description"
		rlRun "ipa netgroup-mod $ngroup1 --desc=deldesctest"
		rlRun "ipa netgroup-mod $ngroup1 --delattr=description=deldesctest > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: 'description' is required" $tmpout
	rlPhaseEnd

#### ipauniqueid
	rlPhaseStartTest "netgroup_mod_negative_007: Invalid modify with setattr and addattr on ipauniqueid"
		command="ipa netgroup-mod --setattr ipauniqueid=mynew-unique-id $ngroup1"
		#expmsg="ipa: ERROR: Insufficient access: Only the Directory Manager can set arbitrary values for ipaUniqueID"
		expmsg="ipa: ERROR: invalid 'ipauniqueid': attribute is not configurable"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

		command="ipa netgroup-mod --addattr ipauniqueid=another-new-unique-id $ngroup1"
		#expmsg="ipa: ERROR: ipauniqueid: Only one value allowed."
		expmsg="ipa: ERROR: invalid 'ipauniqueid': attribute is not configurable"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

#### nisdomain
	rlPhaseStartTest "netgroup_mod_negative_008: Invalid modify with addattr on nisDomainName"
		# shouldn't be multivalue - additional add should fail
		command="ipa netgroup-mod --addattr nisDomainName=secondDomain $ngroup1"
		expmsg="ipa: ERROR: nisdomainname: Only one value allowed."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_009: Invalid modify with nisdomain containing commas (BZ 797237)"
		rlRun "ipa netgroup-mod $ngroup1 --nisdomain=test1,test2 > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'nisdomain': may only include letters, numbers, _, -, and ." $tmpout
		rlAssertNotGrep "test1,test2" $tmpout
		if [ $(grep "test1,test2" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlLog "cleanup nisdomain by putting it back to normal"
			rlRun "ipa netgroup-mod $ngroup1 --nisdomain=$DOMAIN"
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_010: Invalid modify with setattr for multiple nisdomains (BZ 797237)"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=nisdomainname=test1,test2 > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'nisdomainname': may only include letters, numbers, _, -, and ." $tmpout
		rlAssertNotGrep "test1,test2" $tmpout
		if [ $(grep "test1,test2" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlLog "cleanup nisdomain by putting it back to normal"
			rlRun "ipa netgroup-mod $ngroup1 --nisdomain=$DOMAIN"
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_011: Invalid modify with nisdomain containing invalid characters (BZ 797237)"
		rlRun "ipa netgroup-mod $ngroup1 --nisdomain=test^\|\!\@\#\$\%\&\*\\)\\( > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'nisdomain': may only include letters, numbers, _, -, and ." $tmpout
		rlAssertNotGrep "test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout
		if [ $(grep "test^\|\!\@\#\$\%\&\*\\\)\\\(" $tmpout | wc -l) -gt 0 ]; then
			rlFail "BZ 797237 found...ipa netgroup-add and netgroup-mod --nisdomain should not allow commas"
			rlFail "This BZ also covers other invalid characters"
			rlLog "cleanup nisdomain by putting it back to normal"
			rlRun "ipa netgroup-mod $ngroup1 --nisdomain=$DOMAIN"
		fi
	rlPhaseEnd

#### dn
	rlPhaseStartTest "netgroup_mod_negative_012: setattr and addattr on dn"
		command="ipa netgroup-mod --setattr dn=\"ipauniqueid=mynewDN,$NETGRPDN\" $ngroup1"
		expmsg="ipa: ERROR: attribute \"distinguishedName\" not allowed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

		command="ipa netgroup-mod --addattr dn=\"ipauniqueid=anothernewDN,$NETGRPDN\" $ngroup1"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

#### memberuser
	rlPhaseStartTest "netgroup_mod_negative_013: setattr and addattr on memberuser - Invalid Syntax"
		#### test1
		command="ipa netgroup-mod --setattr memberuser=$user1 $ngroup1"
		expmsg="ipa: ERROR: memberuser: Invalid syntax."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

		#### test2
		command="ipa netgroup-mod --addattr memberuser=$user2 $ngroup1"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_014: addattr for user already in netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberuser=uid=$user1,cn=users,cn=accounts,$BASEDN" 0,1
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberuser=uid=$user1,cn=users,cn=accounts,$BASEDN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
	rlPhaseEnd

#### membergroup
	rlPhaseStartTest "netgroup_mod_negative_015: setattr and addattr on membergroup - attribute not allowed"
		#### test1
		command="ipa netgroup-mod --setattr membergroup=$group1 $ngroup1"
		expmsg="ipa: ERROR: attribute membergroup not allowed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

		#### test2
		command="ipa netgroup-mod --addattr membergroup=$group1 $ngroup1"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_016: addattr for group already in netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberuser=cn=$group1,cn=groups,cn=accounts,$BASEDN" 0,1
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberuser=cn=$group1,cn=groups,cn=accounts,$BASEDN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
	rlPhaseEnd

#### memberhost
	rlPhaseStartTest "netgroup_mod_negative_017: setattr and addattr on memberhost - Invalid Syntax"
		local HOSTNAME=`hostname`
		#### test1 
		command="ipa netgroup-mod --setattr memberhost=$HOSTNAME $ngroup1"
		expmsg="ipa: ERROR: memberhost: Invalid syntax."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

		#### test2
		command="ipa netgroup-mod --addattr memberhost=$HOSTNAME $ngroup1"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_018: addattr for memberhost already in netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberhost=fqdn=$host1,cn=computers,cn=accounts,$BASEDN" 0,1
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberhost=fqdn=$host1,cn=computers,cn=accounts,$BASEDN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
	rlPhaseEnd

#### member hostgroup
	rlPhaseStartTest "netgroup_mod_negative_019: setattr and addattr on memberhostgroup"
		command="ipa netgroup-mod --setattr memberhostgroup=$hgroup1 $ngroup1"
		expmsg="ipa: ERROR: attribute memberhostgroup not allowed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."
		command="ipa netgroup-mod --addattr memberhostgroup=$hgroup1 $ngroup1"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_020: addattr for memberhost hostgroup already in netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberhost=cn=$hgroup1,cn=hostgroups,cn=accounts,$BASEDN"
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberhost=cn=$hgroup1,cn=hostgroups,cn=accounts,$BASEDN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
	rlPhaseEnd

#### member netgroup
	rlPhaseStartTest "netgroup_mod_negative_021: setattr and addattr on membernetgroup not allowed"
		#### test1
		command="ipa netgroup-mod $ngroup1 --setattr membernetgroup=$ngroup1"
		expmsg="ipa: ERROR: attribute membernetgroup not allowed"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --setattr."

		#### test2
		command="ipa netgroup-mod $ngroup1 --addattr membernetgroup=$ngroup1"
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for --addattr."
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_022: addattr for member netgroup already in netgroup"
		ngroup2id=$(ipa netgroup-show $ngroup2 --all --raw|grep ipauniqueid:|awk '{print $2}')
		NID="ipauniqueid=$ngroup2id,cn=ng,cn=alt,$BASEDN"
		if [ $(ipa netgroup-show $ngroup1 --all --raw|grep member|grep $NID|wc -l) -eq 0 ]; then
			rlRun "ipa netgroup-mod $ngroup1 --setattr=member=$NID"
		fi
		rlRun "ipa netgroup-mod $ngroup1 --setattr=member=$NID > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
	rlPhaseEnd

#### memberof
	rlPhaseStartTest "netgroup_mod_negative_023: Invalid addattr and setattr on memberof - Insufficient access"
		#### test1 
		ngroup2id=$(ipa netgroup-show $ngroup2 --all --raw|grep ipauniqueid:|awk '{print $2}')
		rlRun "ipa netgroup-mod $ngroup1 --setattr=memberof=ipauniqueid=$ngroup2id,cn=ng,cn=alt,$BASEDN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry" $tmpout
		
		#### test2
		rlRun "ipa netgroup-mod $ngroup1 --addattr=memberof=ipauniqueid=$ngroup2id,cn=ng,cn=alt,$BASEDN > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'memberOf' attribute of entry" $tmpout
	rlPhaseEnd
	
#### externalhost
	rlPhaseStartTest "netgroup_mod_negative_024: Invalid addattr for externalhost already in netgroup"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=externalhost=$host1"
		rlRun "ipa netgroup-mod $ngroup1 --addattr=externalhost=$host1 > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: no modifications to be performed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_mod_negative_025: Invalid setattr and addattr for externalhost with invalid characters (BZ 813325)"
		rlRun "ipa netgroup-mod $ngroup1 --setattr=externalhost=badhost? > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: invalid 'externalhost': only letters, numbers, _, and - are allowed. DNS label may not start or end with -" $tmpout
		if [ $(grep "badhost\?" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 813325 Found...ipa netgroup-mod addattr and setattr allow invalid characters for externalHost"
			rlLog  "deleting invalid entry"
			rlRun  "ipa netgroup-remove-member $ngroup1 --hosts=badhost?"
		fi

		rlRun "ipa netgroup-mod $ngroup1 --addattr=externalhost=anotherbadhost\!\@\#\$\%\^\&\*\\(\\) > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: invalid 'externalhost': only letters, numbers, _, and - are allowed. DNS label may not start or end with -" $tmpout
		if [ $(grep "anotherbadhost\!\@\#\$\%\^\&\*\\(\\)" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 813325 Found...ipa netgroup-mod addattr and setattr allow invalid characters for externalHost"
			rlLog  "deleting invalid entry"
			rlRun  "ipa netgroup-remove-member $ngroup1 --hosts=anotherbadhost\!\@\#\$\%\^\&\*\\(\\)"
		fi
	rlPhaseEnd
		
}

#########################################################################
# DELETE NETGROUPS
##########################################################################
# positive show netgroups tests
netgroup_del_positive()
{
	rlPhaseStartTest "netgroup_del_positive_001: Delete Netgroups"
		# verifying hostgroup-del
		for item in $ngroup1 $ngroup2 $ngroup3; do
			rlRun "ipa netgroup-del $item" 0 "Deleting $item"
			# Verify
			rlRun "ipa netgroup-show $item" 2 "Verifying that $item doesn't deleted"
		done
	rlPhaseEnd
}

# negative show netgroups tests
netgroup_del_negative()
{
        rlPhaseStartTest "netgroup_del_negative_001: Delete netgroup that doesn't exist"
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
        rlPhaseStartTest "manage_netgroups_positive_001: Enable the manage net groups plugin"
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

	rlPhaseStartTest "manage_netgroups_positive_002: Add host group and verify net group"
		rlRun "ipa hostgroup-add --desc=mygroup mygroup" 0 "Adding host group with plugin enabled"
		rlRun "ipa netgroup-find --managed mygroup" 0 "Verify net group was added."
	rlPhaseEnd

	rlPhaseStartTest "manage_netgroups_positive_003: Delete host group and verify net group is deleted"
		rlRun "ipa hostgroup-del mygroup" 0 "Deleting host group with plugin disabled"
		rlRun "ipa netgroup-show --managed mygroup" 2 "Verify managed net group was deleted"
	rlPhaseEnd
}

manage_netgroups_negative()
{
	rlPhaseStartTest "manage_netgroups_negative_001: Attempt to deleted managed net group"
		# add a host group
		ipa hostgroup-add --desc=mygroup mygroup

		command="ipa netgroup-del mygroup"
		expmsg="ipa: ERROR: Server is unwilling to perform: Deleting a managed entry is not allowed. It needs to be manually unlinked first."
		rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message."

		# clean up
		ipa hostgroup-del mygroup
	rlPhaseEnd

	rlPhaseStartTest "manage_netgroups_negative_002: manage netgroups: Incorrect directory manager password"
		rlRun "ssh root@$MASTER \"echo badpassword | ipa-managed-entries status\" > /tmp/pluginerr.out 2>&1" 1 "ipa manage net group status with incorrect directory manager password."
		cat /tmp/pluginerr.out | grep "Traceback"
		if [ $? -eq 0 ] ; then
			rlFail "ERROR: Traceback returned with bad directory manager password."
		else
			rlPass "No Traceback returned with incorrect directory manager password."
		fi
	rlPhaseEnd
}

netgroup_find_positive()
{

	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "netgroup_find_positive_000: Setup some default netgroups for find testing"
		rlRun "ipa user-add tnguser1 --first=first --last=last"
		rlRun "ipa user-add tnguser2 --first=first --last=last"
		rlRun "ipa group-add tnggroup1 --desc=tnggroup1"
		rlRun "ipa group-add tnggroup2 --desc=tnggroup2"
		rlRun "ipa group-add-member tnggroup1 --users=tnguser1"
		rlRun "ipa group-add-member tnggroup2 --users=tnguser2"
		rlRun "ipa host-add tnghost1.$DOMAIN --force"
		rlRun "ipa host-add tnghost2.$DOMAIN --force"
		rlRun "ipa hostgroup-add tnghostgroup1 --desc=tnghostgroup1"
		rlRun "ipa hostgroup-add tnghostgroup2 --desc=tnghostgroup2"
		rlRun "ipa hostgroup-add-member tnghostgroup1 --hosts=tnghost1.$DOMAIN"
		rlRun "ipa hostgroup-add-member tnghostgroup2 --hosts=tnghost2.$DOMAIN"
		rlRun "ipa netgroup-add ngname --desc=desc --nisdomain=domain --usercat=all --hostcat=all"
		rlRun "ipa netgroup-add tngname1 --desc=tngname1"
		rlRun "ipa netgroup-add tngname2 --desc=tngname2"
		rlRun "ipa netgroup-add tngname3 --desc=tngname3"
		rlRun "ipa netgroup-add tngname4 --desc=tngname4"
		rlRun "ipa netgroup-add tngname5 --desc=tngname5"
		rlRun "ipa netgroup-add tngname6 --desc=tngname6"
		rlRun "ipa netgroup-add-member ngname --users=tnguser1,tnguser2 --groups=tnggroup1,tnggroup2 --hosts=tnghost1.$DOMAIN,tnghost2.$DOMAIN --netgroups=tngname1"
		rlRun "ipa netgroup-add-member tngname1 --users=tnguser1 --hosts=tnghost1.$DOMAIN"
		rlRun "ipa netgroup-add-member tngname2 --users=tnguser2 --hosts=tnghost2.$DOMAIN"
		rlRun "ipa netgroup-add-member tngname3 --groups=tnggroup1 --hostgroups=tnghostgroup1"
		rlRun "ipa netgroup-add-member tngname4 --groups=tnggroup2 --hostgroups=tnghostgroup2"
		rlRun "ipa netgroup-add-member tngname5 --netgroups=tngname1"
		rlRun "ipa netgroup-add-member tngname6 --netgroups=tngname2"
	rlPhaseEnd
		
	rlPhaseStartTest "netgroup_find_positive_001: find all"
		rlRun "ipa netgroup-find"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_002: find by criteria name"
		rlRun "ipa netgroup-find ngname"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_003: find by criteria partial name"
		rlRun "ipa netgroup-find ngnam"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_004: find by name option"
		rlRun "ipa netgroup-find --name=ngname"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_005: find desc option"
		rlRun "ipa netgroup-find --desc=desc"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_006: find nisdomain"
		rlRun "ipa netgroup-find --nisdomain=domain"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_007: find by uuid/ipauniqueid"
		UUID=$(ipa netgroup-show ngname --all --raw | grep ipauniqueid: | awk '{print $2}')
		rlRun "ipa netgroup-find --uuid=$UUID"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_008: find by usercat=all"
		rlRun "ipa netgroup-find --usercat=all"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_009: find by hostcat=all"
		rlRun "ipa netgroup-find --hostcat=all"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_010: find with timelimit"
		rlRun "ipa netgroup-find --timelimit=1"
		# doesn't work?  have to use sizelimit but that overrides timelimit
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_011: find with sizelimit=0"
		rlRun "ipa netgroup-find --sizelimit=0"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_012: find with sizelimit=1"
		rlRun "ipa netgroup-find --sizelimit=1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_013: find with sizelimit=5"
		rlRun "ipa netgroup-find --sizelimit=5"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_014: find with sizelimit=5000"
		rlRun "ipa netgroup-find --sizelimit=5000" 
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_015: find managed netgroups"
		ngpenabled=$(ipa-managed-entries --entry="NGP Definition" status 2>&1 | grep "Plugin already Enabled"|wc -l)
		if [ $ngpenabled -eq 0 ]; then
			rlRun "ipa-managed-entries --entry=\"NGP Definition\" enable" 0,2 
		fi
		rlRun "ipa hostgroup-add findtest01 --desc=desc01"
		rlRun "ipa netgroup-find --managed findtest01"
		rlRun "ipa hostgroup-del findtest01"
		if [ $ngpenabled -eq 0 ]; then
			rlRun "ipa-managed-entries --entry=\"NGP Definition\" disable" 0,2
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_016: find by netgroups"
		rlRun "ipa netgroup-find --netgroups=tngname1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_017: find by no-netgroups"
		rlRun "ipa netgroup-find --no-netgroups=tngname1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_018: find by users"
		rlRun "ipa netgroup-find --users=tnguser1,tnguser2"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_019: find by no-users"
		rlRun "ipa netgroup-find --no-users=tngusers1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_020: find by groups"
		rlRun "ipa netgroup-find --groups=tnggroup1,tnggroup2"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_021: find by no-groups"
		rlRun "ipa netgroup-find --no-groups=tnggroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_022: find by hosts"
		rlRun "ipa netgroup-find --hosts=tnghost1.$DOMAIN"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_023: find by no-hosts"
		rlRun "ipa netgroup-find --no-hosts=tnghost1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_024: find by hostgroups"
		rlRun "ipa netgroup-find --hostgroups=tnghostgroup2"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_025: find by no-hostgroups"
		rlRun "ipa netgroup-find --no-hostgroups=tnghostgroup1"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_026: find by in-netgroups"
		rlRun "ipa netgroup-find --in-netgroups=ngname"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_027: find by not-in-netgroups"
		rlRun "ipa netgroup-find --not-in-netgroups=ngname"
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_028: find with netgroups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --netgroups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_029: find with no-netgroups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --no-netgroups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_030: find with users equal space (BZ 798792)"
		rlRun "ipa netgroup-find --users=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_031: find with no-users equal space (BZ 798792)"
		rlRun "ipa netgroup-find --no-users=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_032: find with groups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --groups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_033: find with no-groups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --no-groups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_034: find with hosts equal space (BZ 798792)"
		rlRun "ipa netgroup-find --hosts=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_035: find with no-hosts equal space (BZ 798792)"
		rlRun "ipa netgroup-find --no-hosts=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_036: find with hostgroups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --hostgroups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_037: find with no-hostgroups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --no-hostgroups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_038: find with in-netgroups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --in-netgroups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_positive_039: find with not-in-netgroups equal space (BZ 798792)"
		rlRun "ipa netgroup-find --not-in-netgroups=\" \" > $tmpout 2>&1"
		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
		else
			rlPass "BZ 798792 not found."
		fi
	rlPhaseEnd
		

	rlPhaseStartTest "netgroup_find_positive_cleanup: Cleanup after find positive testing"
		rlRun "ipa netgroup-del tngname1"
		rlRun "ipa netgroup-del tngname2"
		rlRun "ipa netgroup-del tngname3"
		rlRun "ipa netgroup-del tngname4"
		rlRun "ipa netgroup-del tngname5"
		rlRun "ipa netgroup-del tngname6"
		rlRun "ipa netgroup-del ngname"
		rlRun "ipa hostgroup-del tnghostgroup1"
		rlRun "ipa hostgroup-del tnghostgroup2"
		rlRun "ipa host-del tnghost1.$DOMAIN"
		rlRun "ipa host-del tnghost2.$DOMAIN"
		rlRun "ipa group-del tnggroup1"
		rlRun "ipa group-del tnggroup2"
		rlRun "ipa user-del tnguser1"
		rlRun "ipa user-del tnguser2"
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout


}

netgroup_find_positive_other()
{
	ng=netgpa
	ngb=netgpb
	ngc=netgpc
	ua=useruu
	ub=userub
	grpa=ngroupt
	grpb=ngroupb
	hosta=thosta
	hostb=thostb
	hgrpa=hostga
	hgrpb=hostgb
	tmpout=/opt/rhqa_ipa/netgroup-tempout.txt

	rlPhaseStartTest "ipa_netgroup_find_positive_other_01: Positive in-netgroup find user test."
		rlRun "ipa netgroup-add --desc=desc1 $ng" 0 "add netgroup for testing --in-netgroup with"
		rlRun "ipa user-add --first=ufirst --last=ulast $ua" 0 "adding user to test --in-netgroup with"
		rlRun "ipa user-add --first=ufirst --last=ulast $ub" 0 "adding user to test --in-netgroup with"
		rlRun "ipa netgroup-add-member --users=$ua,$ub $ng" 0 "adding user to netgroup $ng"
		rlRun "ipa user-find --in-netgroups=$ng > $tmpout 2>&1" 0
		rlAssertGrep "User login: $ua" $tmpout
		rlAssertGrep "User login: $ub" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_02: Positive in-netgroup find netgroup test."
		rlRun "ipa netgroup-add --desc=desc1 $ngb" 0 "add alternate netgroup for testing --in-netgroup with"
		rlRun "ipa netgroup-add --desc=desc1 $ngc" 0 "add alternate netgroup for testing --in-netgroup with"
		rlRun "ipa netgroup-add-member --netgroups=$ngb,$ngc $ng" 0 "adding netgroup to netgroup $ng"
		rlRun "ipa netgroup-find --in-netgroups=$ng > $tmpout 2>&1" 0
		rlAssertGrep "Netgroup name: $ngb" $tmpout
		rlAssertGrep "Netgroup name: $ngc" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_03: Positive in-netgroup find group test."
		rlRun "ipa group-add --desc=desc1 $grpa" 0 "add group for testing --in-netgroup with"
		rlRun "ipa group-add --desc=desc1 $grpb" 0 "add group for testing --in-netgroup with"
		rlRun "ipa netgroup-add-member --groups=$grpa,$grpb $ng" 0 "adding groups to netgroup $ng"
		rlRun "ipa group-find --in-netgroups=$ng > $tmpout 2>&1" 0
		rlAssertGrep "Group name: $grpa" $tmpout
		rlAssertGrep "Group name: $grpb" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_04: Positive in-netgroup find host test."
		# add hosts for testing
		ipa dnszone-add 2.2.4.in-addr.arpa. --name-server=$MASTER. --admin-email=ipaqar.redhat.com
		ipa host-add --force --ip-address=4.2.2.2 $hosta.$DOMAIN
		ipa host-add --force --ip-address=4.2.2.3 $hostb.$DOMAIN
		rlRun "ipa netgroup-add-member --hosts=$hosta.$DOMAIN,$hostb.$DOMAIN $ng" 0 "adding hosts to netgroup $ng"
		rlRun "ipa host-find --in-netgroups=$ng > $tmpout 2>&1" 0
		rlAssertGrep "Host name: $hosta.$DOMAIN" $tmpout
		rlAssertGrep "Host name: $hostb.$DOMAIN" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_05: Positive in-netgroup findhostgroup test."
		rlRun "ipa hostgroup-add --desc=desc1 $hgrpa" 0 "add group for testing --in-netgroup with"
		rlRun "ipa hostgroup-add --desc=desc1 $hgrpb" 0 "add group for testing --in-netgroup with"
		rlRun "ipa netgroup-add-member --hostgroups=$hgrpa,$hgrpb $ng" 0 "adding hostgroups to netgroup $ng"
		rlRun "ipa hostgroup-find --in-netgroups=$ng > $tmpout 2>&1" 0
		rlAssertGrep "Host-group: $hgrpa" $tmpout
		rlAssertGrep "Host-group: $hgrpb" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_06-prep: Remove some things from the hostgroup tp get ready for the next tests"
		rlRun "ipa netgroup-remove-member --hostgroups=$hgrpb $ng" 0 "Remove hostgroupb from netgroup $ng"
		rlRun "ipa netgroup-remove-member --hosts=$hostb.$DOMAIN $ng" 0 "Remove hostb from netgroup $ng"
		rlRun "ipa netgroup-remove-member --groups=$grpb $ng" 0 "Remove groupb from netgroup $ng"
		rlRun "ipa netgroup-remove-member --netgroups=$ngc $ng" 0 "Remove netgroupb from netgroup $ng"
		rlRun "ipa netgroup-remove-member --users=$ub $ng" 0 "Remove user from netgroup $ng"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_06: Positive not-in-netgroup hostgroup test."
		rlRun "ipa hostgroup-find --not-in-netgroups=$ng | grep $hgrpb" 0 "Make sure that a hostgroup is returned in a search that it should be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_07: Positive not-in-netgroup host test."
		rlRun "ipa host-find --not-in-netgroups=$ng | grep $hostb" 0 "Make sure that a host is returned in a search that it should be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_08: Positive not-in-netgroup group test."
		rlRun "ipa group-find --not-in-netgroups=$ng | grep $grpb" 0 "Make sure that a group is returned in a search that it should be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_09: Positive not-in-netgroup netgroup test."
		rlRun "ipa netgroup-find --not-in-netgroups=$ng | grep $ngc" 0 "Make sure that a netgroup is returned in a search that it should be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_positive_other_10: Positive not-in-netgroup user test."
		rlRun "ipa user-find --not-in-netgroups=$ng | grep $ub" 0 "Make sure that a user is returned in a search that it should be in"
	rlPhaseEnd

	netgroup_find_pkey      

	rlPhaseStartTest "ipa_netgroup_find_positive_other_cleanup: Cleanup after find positive testing"
		# Reset the netgroups state for the upcoming Negative tests
		rlRun "ipa netgroup-add-member --hostgroups=$hgrpb $ng" 
		rlRun "ipa netgroup-add-member --hosts=$hostb.$DOMAIN $ng" 
		rlRun "ipa netgroup-add-member --groups=$grpb $ng" 
		rlRun "ipa netgroup-add-member --netgroups=$ngc $ng" 
		rlRun "ipa netgroup-add-member --users=$ub $ng" 
	rlPhaseEnd
}

netgroup_find_negative()
{
	local tmpout=/tmp/errormsg.out
	rlPhaseStartTest "netgroup_find_negative_000: Set up pre-reqs for find negative testing"
		rlLog
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_001: Fail to find with invalid criteria name"
		rlRun "ipa netgroup-find badname > $tmpout 2>&1" 1
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_002: Fail to find with name option equal space"
		rlRun "ipa netgroup-find --name=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'name': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd
	
	rlPhaseStartTest "netgroup_find_negative_003: Fail to find with name option equal non-existent netgroup"
		rlRun "ipa netgroup-find --name=badname > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_004: Fail to find with desc equal space"
		rlRun "ipa netgroup-find --desc=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'desc': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_005: Fail to find with non-existent desc"
		rlRun "ipa netgroup-find --desc=baddesc > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_006: Fail to find with nisdomain equal space"
		rlRun "ipa netgroup-find --nisdomain=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'nisdomain': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_007: Fail to find with non-existent nisdomain"
		rlRun "ipa netgroup-find --nisdomain=baddomain > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_008: Fail to find with uuid equal space"
		rlRun "ipa netgroup-find --uuid=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'uuid': Leading and trailing spaces are not allowed" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_009: Fail to find with non-existent uuid"
		rlRun "ipa netgroup-find --uuid=00000000-0000-0000-0000-000000000000 > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_010: Fail to find with invalid uuid"
		rlRun "ipa netgroup-find --uuid=baduuid > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_011: Fail to find with invalid usercat"
		rlRun "ipa netgroup-find --usercat=badcat > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'usercat': must be one of (u'all',)" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_012: Fail to find with usercat equal space"
		rlRun "ipa netgroup-find --usercat=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'usercat': must be one of (u'all',)" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_013: Fail to find with invalid hostcat"
		rlRun "ipa netgroup-find --hostcat=badcat > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'hostcat': must be one of (u'all',)" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_014: Fail to find with hostcat equal space"
		rlRun "ipa netgroup-find --hostcat=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
		#rlAssertGrep "ipa: ERROR: invalid 'hostcat': must be one of (u'all',)" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_015: Fail to find with invalid timelimit"
		rlRun "ipa netgroup-find --timelimit=badtimelimit > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'timelimit': must be an integer" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_016: Fail to find with timelimit equal space"
		rlRun "ipa netgroup-find --timelimit=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'timelimit': must be an integer" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_017: Fail to find with invalid sizelimit"
		rlRun "ipa netgroup-find --sizelimit=badsizelimit > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sizelimit': must be an integer" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_018: Fail to find with sizelimit equal space"
		rlRun "ipa netgroup-find --sizelimit=\" \" > $tmpout 2>&1" 1
		rlAssertGrep "ipa: ERROR: invalid 'sizelimit': must be an integer" $tmpout
	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_019: Fail to find with non-existent netgroups"
		rlRun "ipa netgroup-find --netgroups=badnetgroups > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_020: Fail to find with netgroups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --netgroups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'netgroups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_021: Fail to find with no-netgroups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --no-netgroups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'no-netgroups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_022: Fail to find with non-existent users"
		rlRun "ipa netgroup-find --users=badusers > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_023: Fail to find with users equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --users=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'users': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_024: Fail to find with no-users equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --no-users=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'no-users': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_025: Fail to find with non-existent groups"
		rlRun "ipa netgroup-find --groups=badgroups > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_026: Fail to find with groups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --groups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'groups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_027: Fail to find with no-groups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --no-groups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'no-groups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_028: Fail to find with non-existent hosts"
		rlRun "ipa netgroup-find --hosts=badhosts > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_029: Fail to find with hosts equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --hosts=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'hosts': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_030: Fail to find with no-hosts equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --no-hosts=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'no-hosts': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_031: Fail to find with non-existent hostgroups"
		rlRun "ipa netgroup-find --hostgroups=badhostgroups > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_032: Fail to find with hostgroups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --hostgroups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'hostgroups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_033: Fail to find with no-hostgroups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --no-hostgroups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'no-hostgroups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

	rlPhaseStartTest "netgroup_find_negative_034: Fail to find with non-existent netgroup for in-netgroups option"
		rlRun "ipa netgroup-find --in-netgroups=badnetgroups > $tmpout 2>&1" 1
		rlAssertGrep "^0 netgroups matched" $tmpout
	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_035: Fail to find with in-netgroups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --in-netgroups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'in-netgroups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd

# Now a positive test per 798792 fix
#	rlPhaseStartTest "netgroup_find_negative_036: Fail to find with not-in-netgroups equal space (BZ 798792)"
#		rlRun "ipa netgroup-find --not-in-netgroups=\" \" > $tmpout 2>&1" 1
#		rlAssertGrep "^0 netgroups matched" $tmpout
#		#rlAssertGrep "ipa: ERROR: invalid 'not-in-netgroups': Leading and trailing spaces are not allowed" $tmpout
#		if [ $(grep "ipa: ERROR: an internal error has occurred" $tmpout|wc -l) -gt 0 ]; then
#			rlFail "BZ 798792 found...ipa netgroup-find options set to space return internal errors"
#		else
#			rlPass "BZ 798792 not found."
#		fi
#	rlPhaseEnd
}

netgroup_find_negative_other()
{
	ng=netgpa
	ngb=netgpb
	ngc=netgpc
	ua=useruu
	ub=userub
	grpa=ngroupt
	grpb=ngroupb
	hosta=thosta
	hostb=thostb
	hgrpa=hostga
	hgrpb=hostgb

	rlPhaseStartTest "ipa_netgroup_find_negative_other_01: Negative in-netgroup hostgroup test."
		rlRun "ipa netgroup-remove-member --hostgroups=$hgrpb $ng" 0 "Remove hostgroupb from netgroup $ng"
		rlRun "ipa hostgroup-find --in-netgroups=$ng | grep $hgrpb" 1 "Make sure that a hostgroup is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_02: Negative in-netgroup host test."
		rlRun "ipa netgroup-remove-member --hosts=$hostb.$DOMAIN $ng" 0 "Remove hostb from netgroup $ng"
		rlRun "ipa host-find --in-netgroups=$ng | grep $hostb" 1 "Make sure that a host is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_03: Negative in-netgroup group test."
		rlRun "ipa netgroup-remove-member --groups=$grpb $ng" 0 "Remove groupb from netgroup $ng"
		rlRun "ipa group-find --in-netgroups=$ng | grep $grpb" 1 "Make sure that a group is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_04: Negative in-netgroup netgroup test."
		rlRun "ipa netgroup-remove-member --netgroups=$ngc $ng" 0 "Remove netgroupb from netgroup $ng"
		rlRun "ipa netgroup-find --in-netgroups=$ng | grep $ngc" 1 "Make sure that a netgroup is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_05: Negative in-netgroup user test."
		rlRun "ipa netgroup-remove-member --users=$ub $ng" 0 "Remove user from netgroup $ng"
		rlRun "ipa user-find --in-netgroups=$ng | grep $ub" 1 "Make sure that a user is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_06: Negative not-in-netgroup hostgroup test."
		rlRun "ipa hostgroup-find --not-in-netgroups=$ng | grep $hgrpa" 1 "Make sure that a hostgroup is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_07: Negative not-in-netgroup host test."
		rlRun "ipa host-find --not-in-netgroups=$ng | grep $hosta" 1 "Make sure that a host is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_08: Negative not-in-netgroup group test."
		rlRun "ipa group-find --not-in-netgroups=$ng | grep $grpa" 1 "Make sure that a group is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_09: Negative not-in-netgroup netgroup test."
		rlRun "ipa netgroup-find --not-in-netgroups=$ng | grep \"Netgroup name: $ngb\"" 1 "Make sure that a netgroup is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_10: Negative not-in-netgroup user test."
		rlRun "ipa user-find --not-in-netgroups=$ng | grep $ua" 1 "Make sure that a user is not returned in a search that it should not be in"
	rlPhaseEnd

	rlPhaseStartTest "ipa_netgroup_find_negative_other_cleanup: Cleanup for negative and positive find other tests."
		ipa hostgroup-del $hgrpa
		ipa hostgroup-del $hgrpb
		ipa host-del $hosta
		ipa host-del $hostb
		ipa dnszone-del 2.2.4.in-addr.arpa.
		ipa group-del $grpa
		ipa group-del $grpb
		ipa user-del $ua	
		ipa user-del $ub	
		ipa netgroup-del $ng
		ipa netgroup-del $ngb
		ipa netgroup-del $ngc
	rlPhaseEnd
}

netgroup_find_pkey()
{
	rlPhaseStartTest "netgroup_find_pkey_001: check of --pkey-only in netgroup find"
		ipa_command_to_test="netgroup"
		pkey_addstringa="--desc testng"
		pkey_addstringb="--desc testng"
		pkeyobja="testng"
		pkeyobjb="testngb"
		grep_string='Netgroup\ name:'
		general_search_string=$pkeyobja
		rlRun "pkey_return_check" 0 "running checks of --pkey-only in netgroup-find"
	rlPhaseEnd
}

netgroup_show_positive()
{
	rlPhaseStartTest "netgroup_show_positive_001: show existing netgroup"
		rlRun "ipa netgroup-show $ngroup1"
	rlPhaseEnd
}

netgroup_show_negative()
{
	rlPhaseStartTest "netgroup_show_negative_001: fail to show non-existent netgroup"
		local tmpout=/tmp/errormsg.out
		rlRun "ipa netgroup-show badnetgroup > $tmpout 2>&1" 2
		rlAssetGrep "ipa: ERROR: one: netgroup not found" $tmpout
	rlPhaseEnd
}
