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
	irm_version_0001

	irm_list_positive_0001
	irm_list_positive_0002
	irm_list_positive_0003
	irm_list_positive_0004

	irm_list_negative_0001
	irm_list_negative_0002
	irm_list_negative_0003

	irm_connect_positive_0001
	irm_connect_positive_0002

	irm_connect_negative_0001
	irm_connect_negative_0002

	irm_forcesync_positive_0001
	irm_forcesync_positive_0002
	irm_forcesync_positive_0003

	irm_forcesync_negative_0001
	irm_forcesync_negative_0002
	irm_forcesync_negative_0003

	irm_reinitialize_positive_0001
	irm_reinitialize_positive_0002
	irm_reinitialize_positive_0003
	irm_reinitialize_positive_0004

	irm_reinitialize_negative_0001
	irm_reinitialize_negative_0002
	irm_reinitialize_negative_0003

	irm_disconnect_positive_0001
	irm_disconnect_positive_0002

	irm_disconnect_negative_0001
	irm_disconnect_negative_0002
	irm_disconnect_negative_0003
	irm_disconnect_negative_0004
	irm_disconnect_negative_0005

	irm_del_positive_0001
	
	irm_forcesync_negative_0004 # must run after delete
	irm_reinitialize_negative_0004 # must run after delete

	irm_del_negative_0001
	irm_del_negative_0002
	irm_del_negative_0003
	irm_del_negative_0004
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

irm_version_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_version_0001 - check valid version is returned"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

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

irm_list_positive_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_positive_0001 - List replica without specifying hostname"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW list"

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

irm_list_positive_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_positive_0002 - Specify the hostname, with 2 replicas installed"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep -v $MASTER" 
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $MASTER"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE2|grep $MASTER"

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

irm_list_positive_0003()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_positive_0003 - verbose"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW list -v $MASTER > $tmpout 2>&1"
		rlAssertGrep "$SLAVE1" $tmpout
		rlAssertGrep "$SLAVE2" $tmpout
		rlAssertGrep "last init status" $tmpout
		rlAssertGrep "last init ended" $tmpout
		rlAssertGrep "last update status" $tmpout
		rlAssertGrep "last update ended" $tmpout
	
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

irm_list_positive_0004()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_positive - against remote host using -H option"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

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

irm_list_negative_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_negative_0001 - look for non-existent agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1 > $tmpout 2>&1"
		rlAssertNotGrep "$SLAVE2" $tmpout

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

irm_list_negative_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_negative_0002 - look for non-existent agreement with remote Host option"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE1 $SLAVE1 > $tmpout 2>&1"
		rlAssertNotGrep "$SLAVE2" $tmpout

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

irm_list_negative_0003()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_negative_0003 - look for agreement for non-existent host"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlRun "ipa-replica-manage -p $ADMINPW list dne.$DOMAIN > $tmpout 2>&1" 1
		rlAssertNotGrep "Cannot find dne.$DOMAIN in public server list" $tmpout

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

irm_connect_positive_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_positive_0001 - Connect Replica1 to Replica2"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
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

irm_connect_positive_0002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_positive_0002 - Verify data is replicated after a connect"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($SLAVE1)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE1_IP"
		
		rlRun "ipa group-add testgroup1 --desc=testgroup1"

		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($SLAVE2)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		
		rlRun "ipa group-show testgroup1|grep testgroup1" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE2_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
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

irm_connect_negative_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_negative_0001 - Connect Replica1 to Replica2 Again"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		if [ $(ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $SLAVE2|wc -l) -eq 0 ]; then
			rlLog "Did not find $SLAVE1 - $SLAVE2 replica agreement...connecting"
			rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2"
		fi
		rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2 > $tmpout 2>&1" 1
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

irm_connect_negative_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_negative_0002 - Connect Master to non-existent host"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

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

irm_forcesync_positive_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_positive_0001 - Force-sync Master from Replica1"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$SLAVE1"

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

irm_forcesync_positive_0002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_positive_0002 - Force-sync Replica1 from Replica2"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$SLAVE2"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $(hostname -i)"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

irm_forcesync_positive_0003()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_positive_0003 - Force-sync Replica2 from Master"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($SLAVE2)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $(hostname -i)"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}


# irm_forcesync_negative
#     force-sync without --from
#     force-sync --from=m
#     force-sync --from=dne.$DOMAIN
# 

irm_forcesync_negative_0001()
{
	local tmpout=/tmp/errormsg.out

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_negative_0001 - not using --from"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync > $tmpout 2>&1"
		rlAssertGrep "force-sync requires the option --from <host name>" $tmpout

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

irm_forcesync_negative_0002()
{
	local tmpout=/tmp/errormsg.out

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_negative_0002 - Force-sync master with self"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER > $tmpout 2>&1"
		rlAssertGrep "'$MASTER' has no replication agreement for '$MASTER'" $tmpout

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

irm_forcesync_negative_0003()
{
	local tmpout=/tmp/errormsg.out

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_negative_0003 - Force-sync master with non-existent replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=dne.$DOMAIN > $tmpout 2>&1"
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

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

# has to run after del master slave agreement
irm_forcesync_negative_0004()
{
	local tmpout=/tmp/errormsg.out

	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_forcesync_negative_0004 - Force-sync replica with master when there is no agreement (after del)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($SLAVE2)"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' -m $SLAVE2_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
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

irm_reinitialize_positive_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0001 - reinitialize Master from Replica1"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$SLAVE1"

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

irm_reinitialize_positive_0002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0002 - reinitialize Replica1 from Replica2"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE1_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

irm_reinitialize_positive_0003()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0003 - reinitialize Replica2 from Master"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE2_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

irm_reinitialize_positive_0004()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0003 - reinitialize Master from Replica1 with -H Host option"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($SLAVE1)"

		rlRun "ipa-replica-manage -p $ADMINPW -H $MASTER re-initialize --from=$SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE1_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE1_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

# irm_reinitialize_negative
#     re-initialize without --from
#     re-initialize --from=m
#     re-initialize --from=dne.$DOMAIN
# 

irm_reinitialize_negative_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_negative_0001 - Reinitialize not using --from"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize > $tmpout 2>&1" 1
		rlAssertGrep "re-initialize requires the option --from <host name>" $tmpout

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

irm_reinitialize_negative_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_negative_0002 - Reinitialize Master from self"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER > $tmpout 2>&1" 1
		rlAssertGrep "'$MASTER' has no replication agreement for '$MASTER'" $tmpout

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

irm_reinitialize_negative_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_negative - Reinitialize Master from non-existent Replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=dne.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

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

# must be run after slave2 del
irm_reinitialize_negative_0004()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_negative - Reinitialize replica with master when there is no agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE2_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE2_IP"
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

irm_disconnect_positive_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_positive_0001 - Disconnect Replica1 to Replica2 agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $SLAVE1 $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1 | grep -v $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE2 | grep -v $SLAVE1"

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

irm_disconnect_positive_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_positive_0002 - Disconnect Master to Replica1 agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

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

irm_disconnect_negative_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0001 - Disconnect Replica with no agreement ... after was disconnected"
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

irm_disconnect_negative_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0002 - Disconnect non-existent replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER dne.$DOMAIN > $tmpout 2>&1" 
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout
	
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
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

irm_disconnect_negative_0003()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0003 - Disconnect Replica with last agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE2 > $tmpout 2>&1" 1
		rlAssertGrep "Cannot remove the last replication link of '$MASTER'" $tmpout
		rlAssertGrep "Please use the 'del' command to remove it from the domain" $tmpout

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

irm_disconnect_negative_0004()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0004 - Deleted data is not replicated after Disconnect (master to replica)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"

		rlRun "ipa host-del testhost1.$DOMAIN" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"

		rlRun "ipa host-show testhost1.$DOMAIN | grep testhost1.$DOMAIN" 1
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE1_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' $(hostname -i)"
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

irm_disconnect_negative_0005()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0005 - Added data is not replicated after Disconnect (replica to master)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $SLAVE1_IP $SLAVE2_IP"

		rlRun "ipa host-show testhost2.$DOMAIN > $tmpout 2>&1" 2 
		rlAssertGrep "ipa: ERROR: testhost1.$DOMAIN: host not found" $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $MASTER_IP"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"

		rlRun "ipa host-add testhost2.$DOMAIN"		

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $SLAVE1_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($SLAVE)"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $(hostname -i)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $SLAVE1_IP $SLAVE2_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
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

irm_del_positive_0001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_positive_0001 - Remove all replication agreements and data about Replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
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

irm_del_negative_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_negative_0001 - Delete Replica that has already been deleted (BZ 754524)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlLog "found $MASTER - $SLAVE2 replication agreement...deleting"
			rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE2"
		fi
	
		rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE2 > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
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

irm_del_negative_0002()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_negative_0002 - Delete non-existent Replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlRun "ipa-replica-manage -p $ADMINPW del dne.$DOMAIN > $tmpout 2>&1" 1
		rlAssertGrep "NEEDERROR" $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
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

irm_del_negative_0003()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_negative_0003 - Added data is not replicated after del (master to replica)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		
		rlRun "ipa user-add testuser2 --first=First --last=Last"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($SLAVE2)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		
		rlLog "0017.1 - del - Added data is not replicated after del (master to replica)"
		rlRun "ipa user-show testuser2|grep testuser2" 1

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE2_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' $(hostname -i)"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE1_IP $SLAVE2_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_del_negative_0004()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_negative_0004 - Deleted data is not replicated after del (replica to master)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($MASTER)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $SLAVE1_IP $SLAVE2_IP"

		rlRun "ipa user-show testuser1|grep testuser1" 1

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $MASTER_IP"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($SLAVE2)"
		
		rlRun "ipa user-del testuser1"	
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $SLAVE2_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' $(hostname -i)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $SLAVE1_IP $SLAVE2_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

