#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-replica-manage.sh of /CoreOS/ipa-tests/acceptance/ipa-ipa-replica-manage
#   Description: IPA multihost Test Template 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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


######################################################################
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
irm_envsetup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_envsetup - Setup environment for test template"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		hostname_s=$(hostname -s)
		rlRun "Tests to ensure that all of the servers are available"
		rlRun "ipa-replica-manage --password=$ADMINPW list | grep $hostname -s"
		for slave in $SLAVE; do
			slave_s=$(echo $slave|cut -f1 -d.)	
			rlRun "ipa-replica-manage --password=Secret123 list | grep $slave_s"
		done

		rlRun "ipa host-add testhost1.$DOMAIN --force"
		rlRun "ipa user-add testuser1 --first=First --last=Last"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "hostname"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "hostname"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

irm_run()
{
	irm_version
	irm_list_positive
	irm_list_negative
	irm_connect_positive
	irm_connect_negative
	irm_forcesync_positive
	irm_forcesync_negative
	irm_reinitialize_positive
	irm_reinitialize_negative
	irm_disconnect_positive
	irm_disconnect_negative
	irm_del_positive
	irm_del_negative
}

irm_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_envcleanup - clean up test environment"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# irm_version
#     --version # returns 2.1.90 on RHEL6.3

irm_version()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_version - check valid version is returned"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlLog "0001 --version"
		rlRun "ipa-replica-manage --version | grep $IRMVERSION" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# irm_list_positive
#     list # lists all known servers
#     list m-s1
#     list m-s2
#     list -H s1 m-s1
#     list -H s2 m-s2
# 

irm_list_positive()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_positive - list and check existing connections"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlLog "0002 - list - List replica without specifying hostname"
		rlRun "ipa-replica-manage -p $ADMINPW list"

		rlLog "0003 - list - Specify the hostname, with 2 replicas installed"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep -v $MASTER" 
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $MASTER"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE2|grep $MASTER"

		rlLog "ipa-replica-manage : 0005 - list - verbose"
		rlRun "ipa-replica-manage -p $ADMINPW list -v $MASTER > $tmpout 2>&1"
		rlAssertGrep "$SLAVE1" $tmpout
		rlAssertGrep "$SLAVE2" $tmpout
		rlAssertGrep "last init status" $tmpout
		rlAssertGrep "last init ended" $tmpout
		rlAssertGrep "last update status" $tmpout
		rlAssertGrep "last update ended" $tmpout
	
		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE1 $MASTER | grep $SLAVE1"
		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE2 $MASTER | grep $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


# irm_list_negative
#     list !s1-s2
#     list -H s1 !s1-s2
#     list dne.$DOMAIN
# 

irm_list_negative()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_negative - list and check for expected failures and error messages"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1 > $tmpout 2>&1"
		rlAssertNotGrep "$SLAVE2" $tmpout

		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE1 $SLAVE1 > $tmpout 2>&1"
		rlAssertNotGrep "$SLAVE2" $tmpout

		rlRun "ipa-replica-manage -p $ADMINPW list dne.$DOMAIN > $tmpout" 1
		rlAssertNotGrep "Cannot find dne.testrelm.com in public server list"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


# irm_connect_positive
#     connect s1-s2
# 

irm_connect_positive()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_positive - create a new replication agreement between two replicas"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlLog "0011 - connect - Connect Replica1 to Replica2"
		rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


# irm_connect_negative
#     connect m-dne
# 

irm_connect_negative()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_negative - test for expected failure connecting non-existant server"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlLog "0012 - connect - Connect Replica1 to Replica2 Again"
		if [ $(ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $SLAVE2|wc -l) -eq 0 ]; then
			rlLog "Did not find $SLAVE1 - $SLAVE2 replica agreement...connecting"
			rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2"
		fi
		rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2 > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout
		
		rlRun "ipa-replica-manage -p $ADMINPW connect $MASTER dne.$DOMAIN > $tmpout 2>&1" 
		rlAssertGrep "Can't contact LDAP server" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


# irm_forcesync_positive
#     force-sync --from=s1 # on master
#     force-sync --from=s2 # on s1
#     force-sync --from=m  # on s2
# 

irm_forcesync_positive()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_positive - test force-sync from different replicas"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE1_IP $SLAVE2_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		
		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$SLAVE2"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $(hostname -i)"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $(hostname -i)"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE1_IP $SLAVE2_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


# irm_forcesync_negative
#     force-sync --from=m
#     force-sync --from=dne.$DOMAIN
# 

irm_forcesync_negative()
{
	local tmpout=/tmp/errormsg.out

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_negative - test force-sync for expected errors"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW --from=$MASTER > $tmpout 2>&1"
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "ipa-replica-manage -p $ADMINPW --from=dne.$DOMAIN > $tmpout 2>&1"
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

# irm_reinitialize_positive
#     re-initialize s1 # on master
#     re-initialize s2 # on s1
#     re-initialize m  # on s2
# 

irm_reinitialize_positive()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive - reinitialize servers from other replicas"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $(hostname -i)"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $(hostname -i)"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


# irm_reinitialize_negative
#     re-initialize --from=m
#     re-initialize --from=dne.$DOMAIN
# 

irm_reinitialize_negative()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_negative - test re-initialize for expected errors"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=dne.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


# irm_disconnect_positive
#     disconnect s1 s2
# 

irm_disconnect_positive()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_positive - disconnect a replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlLog "0008 - disconnect - Disconnect Replica with agreement"
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $SLAVE1 $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1 | grep -v $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE2 | grep -v $SLAVE1"

		rlLog "0008 - disconnect - Disconnect Replica with agreement"
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE1"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER | grep -v $SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


# irm_disconnect_negative
#     disconnect s1 s2 # again should fail
#     disconnect m dne.$DOMAIN
# 

irm_disconnect_negative()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative - test for expected errors for disconnect"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		if [ $(ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlLog "found $SLAVE1 - $SLAVE2 replication agreement...disconnecting"
			rlRun "ipa-replica-manage -p $ADMINPW disconnect $SLAVE1 $SLAVE2"
		fi
	
		rlLog "0006 - disconnect - Disconnect Replica with no agreement ... after was disconnected"
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $SLAVE1 $SLAVE2 > $tmpout 2>&1" 1
		rlAssertGrep "'$SLAVE1' has no replication agreement for '$SLAVE2'" $tmpout

		rlLog "0006 - disconnect - Disconnect Replica with no agreement"
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER dne.$DOMAIN > $tmpout 2>&1" 
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout
	
		rlLog "0007 - disconnect - Disconnect Replica with last agreement"
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE2 > $tmpout 2>&1" 1
		rlAssertGrep "Cannot remove the last replication link of '$MASTER'" $tmpout
		rlAssertGrep "Please use the 'del' command to remove it from the domain" $tmpout

		rlLog "0009.0 - disconnect - Deleted data is not replicated after Disconnect (master to replica)"
		rlRun "ipa host-del testhost1.$DOMAIN" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"

		rlLog "0010.1 - disconnect - Added data is not replicated after Disconnect (replica to master)"
		rlRun "ipa host-show testhost2.$DOMAIN > $tmpout 2>&1" 2 
		rlAssertGrep "ipa: ERROR: testhost1.$DOMAIN: host not found" $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.3' -m $MASTER_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"

		rlLog "0009.1 - disconnect - Deleted data is not replicated after Disconnect (master to replica)"
		rlRun "ipa host-show testhost1.$DOMAIN | grep testhost1.$DOMAIN" 1
		
		rlLog "0010.0 - disconnect - Added data is not replicated after Disconnect (replica to master)"
		rlRun "ipa host-add testhost2.$DOMAIN"		

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE1_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' $(hostname -i)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


# irm_del_positive
#     del s2
# 

irm_del_positive()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_positive - delete a replica from domain"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlLog "0015 - del - Remove all replication agreements and data about Replica"
		rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER | grep -v $SLAVE2"
		rlRun "ipa host-show $SLAVE2" 2

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


# irm_del_negative
#     del s2 # again should fail
#     del dne.$DOMAIN
# 

irm_del_negative()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_negative - test expected errors for del"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlLog "found $MASTER - $SLAVE2 replication agreement...deleting"
			rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE2"
		fi
	
		rlLog "0018 - del - del Replica with no agreement - Bug 754524"
		rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE2 > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout

		rlLog "0018 - del - del Replica with no agreement - Bug 754524"
		rlRun "ipa-replica-manage -p $ADMINPW del dne.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout
		
		rlLog "0017.0 - del - Added data is not replicated after del (master to replica)"
		rlRun "ipa user-add testuser2 --first=First --last=Last"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"

		rlLog "0016.1 - del - Deleted data is not replicated after del (replica to master)"
		rlRun "ipa user-show testuser1|grep testuser1" 1

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.3' -m $MASTER_IP"
		
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($SLAVE2)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		
		rlLog "0017.1 - del - Added data is not replicated after del (master to replica)"
		rlRun "ipa user-show testuser2|grep testuser2" 1

		rlLog "0016.0 - del - Deleted data is not replicated after del (replica to master)"
		rlRun "ipa user-del testuser1"	
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE2_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' $(hostname -i)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


