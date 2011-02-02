#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#######################################################################
# VARIABLES
#######################################################################
ngroup1=testg1
ngroup2=testgaga2
user1=usrjjk1r
user2=userl33t
user3=usern00b
user4=lopcr4k
group1=grpddee
group2=grplloo
group3=grpmmpp
group4=grpeeww
hgroup1=hg144335566
hgroup2=hg2
hgroup3=hg3afdsk

#########################################################################
# TEST SECTIONS TO RUN
#########################################################################
netgroups()
{
	setup
	add_netgroups
	show_netgroups
	mod_netgroups
	member_netgroups
	attr_netgroups
	del_netgroups
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
    rlPhaseEnd
}

add_netgroups()
{
	add_netgroups_positive
	add_netgroups_negative
}

show_netgroups()
{
	show_netgroups_positive
	show_netgroups_negative
}

member_netgroups()
{
        member_netgroups_positive
        member_netgroups_negative
}

mod_netgroups()
{
	mod_netgroups_positive
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
    rlPhaseEnd
}

##########################################################################
#  ADD NETGROUPS
#########################################################################
# positive tests
add_netgroups_positive()
{
	rlPhaseStartTest "ipa-netgroup-01: add netgroups"
		echo "Add netgroup $ngroup1"
        	rlRun "addNetgroup $ngroup1 test-group-1" 0 "adding first netgroup"
		echo "Add netgroup $ngroup2"
        	rlRun "addNetgroup $ngroup2 test-group-1" 0 "adding second netgroup"
		# Verify if it exists
		rlRun "ipa netgroup-find $ngroup1 | grep $ngroup1" 0 "checking to ensure first netgroup was created"
		rlRun "ipa netgroup-find $ngroup2 | grep $ngroup2" 0 "checking to ensure second netgroup was created"
	rlPhaseEnd 
}

# negative add netgroups tests
add_netgroups_negative()
{
	rlPass "FIXME"
}

###########################################################################
# SHOW NETGROUS
###########################################################################
# positive show netgroups tests
show_netgroups_positive()
{
	rlPass "FIXME"
}
# negative show netgroups tests
show_netgroups_negative()
{
	rlPass "FIXME"
}

##########################################################################
# NETGROUP MEMBERS
##########################################################################
# positive member netgroups tests
member_netgroups_positive()
{
        rlPhaseStartTest  "ipa-netgroup-02: Add users to netgroup"
                # Adding users to group1
                rlRun "ipa netgroup-add-member --users=$user1,$user2 $ngroup1" 0 "Adding $user1 and $user2 to $ngroup1"
                rlRun "ipa netgroup-add-member --users=$user3 $ngroup1" 0 "Adding $user3 to $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1|grep $user1" 0 "Verifying that $user1 is in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1|grep $user2" 0 "Verifying that $user2 is in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1|grep $user3" 0 "Verifying that $user3 is in Rngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-03: Add groups to netgroup"
                # Adding users to group1
                rlRun "ipa netgroup-add-member --groups=$group1,$group2 $ngroup1" 0 "Adding $group1 and $group2 to $ngroup1"
                rlRun "ipa netgroup-add-member --groups=$group3 $ngroup1" 0 "Adding $group3 to $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1|grep $group1" 0 "Verifying that $group1 is in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1|grep $group2" 0 "Verifying that $group2 is in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1|grep $group3" 0 "Verifying that $group3 is in $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-04: Add hosts to netgroup"
                # Checking to ensure that addign a host to a netgroup works
                rlRun "ipa netgroup-add-member --hosts=$HOSTNAME $ngroup1" 0 "Adding local $HOSTNAME to $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 0 "Verifying that $HOSTNAME is in $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-05: Add hostgroups to netgroup"
                # Adding a hostgroup to a netgroup
                rlRun "ipa netgroup-add-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "adding $hgroup1 and $hgroup2 to $ngroup1"
                rlRun "ipa netgroup-add-member --hostgroups=$hgroup3 $ngroup1" 0 "adding $hgroup3 to $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 0 "Verifying that $hgroup1 is in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 0 "Verifying that $hgroup2 is in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 0 "Verifying that $hgroup1 is in $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-06: Remove users from netgroup"
                # Removing users from ngroup1
                rlRun "ipa netgroup-remove-member --users=$user1,$user2 $ngroup1" 0 "Removing $user1 and $user2 from $ngroup1"
                rlRun "ipa netgroup-remove-member --users=$user3 $ngroup1" 0 "Removing $user3 from $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1 | grep $user1" 1 "Verifying that $user1 is not in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $user2" 1 "Verifying that $user2 is not in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $user3" 1 "Verifying that $user3 is not in $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-07: Remove groups from netgroup"
                # Removing groups from ngroup1
                rlRun "ipa netgroup-remove-member --groups=$group1,$group2 $ngroup1" 0 "Removing $group1 and $group2 from $ngroup1"
                rlRun "ipa netgroup-remove-member --groups=$group3 $ngroup1" 0 "Removing $group3 from $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1 | grep $group1" 1 "Verifying that $group1 is not in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $group2" 1 "Verifying that $group2 is not in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $group3" 1 "Verifying that $group3 is not in $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-08: Remove hostgroups from netgroup"
                # Removing hostgroups from ngroup1
                rlRun "ipa netgroup-remove-member --hostgroups=$hgroup1,$hgroup2 $ngroup1" 0 "Removing $hgroup1 and $hgroup2 from $ngroup1"
                rlRun "ipa netgroup-remove-member --hostgroups=$hgroup3 $ngroup1" 0 "Removing $hgroup3 from $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup1" 1 "Verifying that $hgroup1 is not in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup2" 1 "Verifying that $hgroup2 is not in $ngroup1"
                rlRun "ipa netgroup-show --all $ngroup1 | grep $hgroup3" 1 "Verifying that $hgroup3 is not in $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-09: Remove host from netgroup"
                # Removing a host from ngroup1
                rlRun "ipa netgroup-remove-member --hosts=$HOSTNAME $ngroup1" 0 "Removing $HOSTNAME from $ngroup1"
                # Checking to ensure that it happened.
                rlRun "ipa netgroup-show --all $ngroup1 | grep Host | grep $HOSTNAME" 1 "Verifying that $HOSTNAME is not in $ngroup1"
        rlPhaseEnd

}

# negative member netgroups tests
member_netgroups_negative()
{
	rlPass "FIXME"
}


##########################################################################
# MODIFY NETGROUPS
##########################################################################
# positive modify netgroups tests
mod_netgroups_positive()
{
        rlPhaseStartTest  "ipa-netgroup-10: Modify description of netgroup"
                # checking description hostgroup-mod
                rlRun "ipa netgroup-mod --desc=testdesc11 $ngroup1" 0 "change the description on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep testdesc11" 0 "Verifying that the description changed on $ngroup1"
        rlPhaseEnd
}

# negative modify netgroups tests
mod_netgroups_negative()
{
	rlPass "FIXME"
}


##########################################################################
# SETATTR AND ADDATTR NETGROUP
##########################################################################
# positive attr netgroups tests
attr_netgroups_positive()
{
        rlPhaseStartTest  "ipa-netgroup-11: Add custom attribute to netgroup"
                # checking setaddr hostgroup-mod
                rlRun "ipa netgroup-mod --addattr=externalHost=ipaqatesthost $ngroup1" 0 "add custom attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep ipaqatesthost" 0 "Verifying that the attr added to $ngroup1"
        rlPhaseEnd
        rlPhaseStartTest  "ipa-netgroup-12: Set custom attribute on netgroup"
                # checking setaddr hostgroup-mod --setattr
                rlRun "ipa netgroup-mod --setattr=externalHost=althost $ngroup1" 0 "setting custom attribute on $ngroup1"
                # Verify
                rlRun "ipa netgroup-show --all $ngroup1 | grep althost" 0 "Verifying that the attr changed on $ngroup1"
        rlPhaseEnd

}

# negative attr netgroups tests
attr_netgroups_negative()
{
	rlPass "FIXME"
}


##########################################################################
# DELETE NETGROUPS
##########################################################################
# positive show netgroups tests
del_netgroups_positive()
{
        rlPhaseStartTest  "ipa-netgroup-13: Delete Netgroups"
                # verifying hostgroup-del
		for item in $ngroup1 $ngroup2 $ngroup3 ; do
                	rlRun "ipa netgroup-del $item" 0 "Deleting $item"
                	# Verify
                	rlRun "ipa netgroup-show $item" 2 "Verifying that $item doesn't deleted"
		done
        rlPhaseEnd
}

# negative show netgroups tests
del_netgroups_negative()
{
	rlPass "FIXME"
}

