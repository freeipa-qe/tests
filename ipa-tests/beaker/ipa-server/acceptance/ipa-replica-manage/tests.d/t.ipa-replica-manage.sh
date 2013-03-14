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
	
	irm_del_positive_0001
	irm_del_positive_0002

	irm_connect_negative_0003

	reconnect_slave1
	reconnect_slave2

	irm_connect_positive_0003

	irm_disconnect_positive_0001
	irm_disconnect_negative_0000

	irm_disconnect_negative_0001
	irm_disconnect_negative_0002
	irm_disconnect_negative_0003
# Following 2 tests no longer valid since cannot disconnect last agreement
# for a node.  Must delete.
#	irm_disconnect_negative_0004 
#	irm_disconnect_negative_0005

	irm_del_negative_0000
	
	irm_forcesync_negative_0004 # must run after master slave2 disconnect
	irm_reinitialize_negative_0004 # must run after master slave2 disconnect

	irm_del_negative_0001
	irm_del_negative_0002
	irm_del_negative_0003
	irm_del_negative_0004

	# need to add bz824492 test here
	# test is to connect after disconnect ...should work now (3.0.0-8)

	reconnect_slave2 # may need to delete this 
	irm_list_negative_0004 # must run after delete negative tests
}

reconnect_slave1()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "reconnect_slave1 - replica prepare, uninstall and re-install to reconnect"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage del $SLAVE1 --force" 0,1
		rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE1_IP $SLAVE1"	
		rlRun "service named restart"
		rlRun "ipa dnsrecord-find $DOMAIN"
		rlRun "dig +short +noquestion $SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE1"
		
		rlRun "ipactl restart"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.3' -m $BEAKERMASTER"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		hostname_s=$(hostname -s)
		rlLog "First uninstall replica from $SLAVE1"
		rlRun "ipa-server-install --uninstall -U"
		if [ $(ps -ef|grep "[s]ssd.*$DOMAIN"|wc -l) -gt 0 ]; then
			rlLog "SSSD not stopped by uninstall...manually stopping"
			rlRun "service sssd stop"
		fi
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi
		rlRun "cp /etc/resolv.conf /etc/resolv.conf.$FUNCNAME.$TESTORDER.backup"
		rlRun "echo \"nameserver $MASTER_IP\" > /etc/resolv.conf"

		rlLog "Next re-install replica on $SLAVE1"
		pushd /opt/rhqa_ipa
		rlRun "sftp root@$MASTER_IP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		popd
		rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --ip-address=$SLAVE1_IP -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"

		rlRun "KinitAsAdmin"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

reconnect_slave2()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "reconnect_slave2 - replica prepare, uninstall and re-install to reconnect"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage del $SLAVE2 --force" 0,1
		rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE2_IP $SLAVE2"	
		rlRun "service named restart"
		rlRun "ipa dnsrecord-find $DOMAIN"
		rlRun "dig +short +noquestion $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		
		rlRun "ipactl restart"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.3' -m $BEAKERMASTER"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		hostname_s=$(hostname -s)
		rlLog "First uninstall replica from $SLAVE2"
		rlRun "ipa-server-install --uninstall -U"
		if [ $(ps -ef|grep "[s]ssd.*$DOMAIN"|wc -l) -gt 0 ]; then
			rlLog "SSSD not stopped by uninstall...manually stopping"
			rlRun "service sssd stop"
		fi
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi
		rlRun "cp /etc/resolv.conf /etc/resolv.conf.$FUNCNAME.$TESTORDER.backup"
		rlRun "echo \"nameserver $MASTER_IP\" > /etc/resolv.conf"

		rlLog "Next re-install replica on $SLAVE2"
		pushd /opt/rhqa_ipa
		rlRun "sftp root@$MASTER_IP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		popd
		rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --ip-address=$SLAVE2_IP -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"

		rlRun "KinitAsAdmin"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_envsetup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_envsetup - Setup environment for test template"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlLog "rhts-sync-block -s '$FUNCNAME.0' $BEAKERSLAVE1 $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $BEAKERSLAVE1 $BEAKERSLAVE2"
		rlRun "KinitAsAdmin"
		hostname_s=$(hostname -s)
		rlLog "Tests to ensure that all of the servers are available"
		rlRun "ipa-replica-manage --password=$ADMINPW list | grep $hostname_s"
		for slave in $SLAVE; do
			slave_s=$(echo $slave|cut -f1 -d.)	
			rlRun "ipa-replica-manage --password=Secret123 list | grep $slave_s"
		done

		rlRun "ipa host-add testhost1.$DOMAIN --force"
		rlRun "ipa user-add testuser1 --first=First --last=Last"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"
		rlRun "rhts-sync-set -s '$FUNCNAME.0' -m $BEAKERSLAVE1"
		rlRun "KinitAsAdmin"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"
		rlRun "rhts-sync-set -s '$FUNCNAME.0' -m $BEAKERSLAVE2"
		rlRun "KinitAsAdmin"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-set -s '$FUNCNAME.0' -m $(hostname)"
		rlRun "KinitAsAdmin"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

irm_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_envcleanup - clean up test environment"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage --version | grep $IRMVERSION" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW list"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep -v $MASTER" 
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $MASTER"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE2|grep $MASTER"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW list -v $MASTER > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "$SLAVE1" $tmpout
		rlAssertGrep "$SLAVE2" $tmpout
		rlAssertGrep "last init status" $tmpout
		rlAssertGrep "last init ended" $tmpout
		rlAssertGrep "last update status" $tmpout
		rlAssertGrep "last update ended" $tmpout
	
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
	rlPhaseStartTest "irm_list_positive_0004 - against remote host using -H option"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE1 $MASTER | grep $SLAVE1"
		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE2 $MASTER | grep $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertNotGrep "$SLAVE2" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW list -H $SLAVE1 $SLAVE1 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertNotGrep "$SLAVE2" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW list dne.$DOMAIN > $tmpout 2>&1" 
		rlRun "cat $tmpout"
		rlAssertGrep "Cannot find dne.$DOMAIN in public server list" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_list_negative_0004_full()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_negative_0004 - After uninstalling replica - Bug 754739"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE2_IP $SLAVE2"	
		rlRun "service named restart"
		rlRun "ipa dnsrecord-find $DOMAIN"
		rlRun "dig +short +noquestion $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.3' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.4' $BEAKERSLAVE2"

		
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlFail "BZ 754739 found...Master Server should not list uninstalled Replicas"
		else 
			rlPass "BZ 754739 not found...uninstalled replica not shown in list"
		fi
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.5' -m $BEAKERMASTER"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		hostname_s=$(hostname -s)
		rlLog "First uninstall replica from $SLAVE2"
		rlRun "ipa-server-install --uninstall -U"
		if [ $(ps -ef|grep "[s]ssd.*$DOMAIN"|wc -l) -gt 0 ]; then
			rlLog "SSSD not stopped by uninstall...manually stopping"
			rlRun "service sssd stop"
		fi
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi
		rlRun "cp /etc/resolv.conf /etc/resolv.conf.irm_list_negative_0004.backup"
		rlRun "echo \"nameserver $MASTER_IP\" > /etc/resolv.conf"

		rlLog "Next re-install replica on $SLAVE2"
		pushd /opt/rhqa_ipa
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		popd
		rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --ip-address=$SLAVE2_IP -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"

		rlRun "ipa-server-install --uninstall -U"
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.4' -m $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.5' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.4' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.5' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.3' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.4' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.5' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_list_negative_0004()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_list_negative_0004 - After uninstalling replica - Bug 754739"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE2"
		
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlFail "BZ 754739 found...Master Server should not list uninstalled Replicas"
		else 
			rlPass "BZ 754739 not found...uninstalled replica not shown in list"
		fi
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERMASTER"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"

		rlRun "ipa-server-install --uninstall -U"
		if [ $(ps -ef|grep "[s]ssd.*$DOMAIN"|wc -l) -gt 0 ]; then
			rlLog "SSSD not stopped by uninstall...manually stopping"
			rlRun "service sssd stop"
		fi
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"
		
		rlRun "KinitAsAdmin"
		rlRun "ipa group-add testgroup1 --desc=testgroup1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE1"
		sleep 10
		rlRun "KinitAsAdmin"
		rlRun "ipa group-show testgroup1|grep testgroup1" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE2"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

irm_connect_positive_0003()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_positive_0003 - Connect Replica1 to Replica2 with -H to Replica1"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"
		
		rlRun "ipa-replica-manage -H $MASTER -p $ADMINPW connect $SLAVE1 $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE1 | grep $SLAVE2"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE1"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		if [ $(ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $SLAVE2|wc -l) -eq 0 ]; then
			rlLog "Did not find $SLAVE1 - $SLAVE2 replica agreement...connecting"
			rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2"
		fi
		rlRun "ipa-replica-manage -p $ADMINPW connect $SLAVE1 $SLAVE2 > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "A replication agreement to $SLAVE2 already exists" $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW connect $MASTER dne.$DOMAIN > $tmpout 2>&1" 1 
		rlRun "cat $tmpout"
		#rlAssertGrep "Can't contact LDAP server" $tmpout
		rlAssertGrep "You cannot connect to a previously deleted master" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

# irm_connect_negative
#     connect m-previously deleted s1
# 

irm_connect_negative_0003()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_connect_negative_0003 - Fail to connect Master to Replica1 after Replica1 deleted"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1|wc -l) -gt 0 ]; then
			rlLog "Found $MASTER - $SLAVE1 replica agreement...deleting"
			rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE1"
		fi
		rlRun "ipa-replica-manage -p $ADMINPW connect $MASTER $SLAVE1 > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "You cannot connect to a previously deleted master" $tmpout
		irm_bugcheck_754539 $tmpout
		irm_bugcheck_823657 $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$SLAVE2"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE1"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER"
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE2"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "force-sync requires the option --from <host name>" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for '$MASTER'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=dne.$DOMAIN > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW force-sync --from=$MASTER > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$SLAVE2' has no replication agreement for '$MASTER'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE2"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
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
	local tmpout=/tmp/irm_msg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0001 - reinitialize Master from Replica1"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$SLAVE1 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		irm_bugcheck_831661 $tmpout $SLAVE1
		rlAssertGrep "Update succeeded" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_reinitialize_positive_0002()
{
	local tmpout=/tmp/irm_msg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0002 - reinitialize Replica1 from Replica2"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$SLAVE2 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		irm_bugcheck_831661 $tmpout $SLAVE2
		rlAssertGrep "Update succeeded" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE1"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_reinitialize_positive_0003()
{
	local tmpout=/tmp/irm_msg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0003 - reinitialize Replica2 from Master"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER > $tmpout 2>&1"
		rlRun "cat $tmpout"
		irm_bugcheck_831661 $tmpout $MASTER
		rlAssertGrep "Update succeeded" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE2"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_reinitialize_positive_0004()
{
	local tmpout=/tmp/irm_msg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_positive_0004 - reinitialize Master from Replica1 with -H Host option"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW -H $MASTER re-initialize --from=$SLAVE1 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		irm_bugcheck_831661 $tmpout $SLAVE1
		rlAssertGrep "Update succeeded" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE1"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "re-initialize requires the option --from <host name>" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for '$MASTER'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_reinitialize_negative_0003()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_reinitialize_negative_0003 - Reinitialize Master from non-existent Replica"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
	
		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=dne.$DOMAIN > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
	rlPhaseStartTest "irm_reinitialize_negative_0004 - Reinitialize replica with master when there is no agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW re-initialize --from=$MASTER > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$SLAVE2' has no replication agreement for '$MASTER'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE2"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE2"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}


# irm_disconnect_positive
#     disconnect m s2
# 

irm_disconnect_positive_0001()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_positive_0001 - Disconnect Master to Replica2 agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE2 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "Deleted replication agreement from '$MASTER' to '$SLAVE2'" $tmpout
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER | grep -v $SLAVE2"
		rlRun "ipa-replica-manage -p $ADMINPW list $SLAVE2 | grep -v $MASTER"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_disconnect_negative_0000()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0000 - Disconnect Master to Replica1 agreement"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE1 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "Cannot remove the last replication link of '$MASTER'" $tmpout
		rlAssertGrep "Please use the 'del' command to remove it from the domain" $tmpout
		irm_bugcheck_839638 $tmpout
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER | grep $SLAVE1"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"

		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlLog "found $MASTER - $SLAVE2 replication agreement...disconnecting"
			rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE2"
		fi
	
		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER $SLAVE2 > $tmpout 2>&1" 
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for '$SLAVE2'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERSLAVE1"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERSLAVE1"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $MASTER dne.$DOMAIN > $tmpout 2>&1" 
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout
	
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa-replica-manage -p $ADMINPW disconnect $SLAVE1 $SLAVE2 > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "Cannot remove the last replication link of '$SLAVE2'" $tmpout
		rlAssertGrep "Please use the 'del' command to remove it from the domain" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

# No longer valid since cannot disconnect last agreement.  
irm_disconnect_negative_0004()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0004 - Deleted data is not replicated after Disconnect (master to replica)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"

		rlRun "ipa host-del testhost1.$DOMAIN" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE1"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE1 ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"

		rlRun "ipa host-show testhost1.$DOMAIN | grep testhost1.$DOMAIN" 
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE1"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE1"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE1"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

# No longer valid since cannot disconnect last agreement.  
irm_disconnect_negative_0005()
{
	local tmpout=/tmp/errormsg.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_disconnect_negative_0005 - Added data is not replicated after Disconnect (replica to master)"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE1"

		rlRun "ipa host-show testhost2.$DOMAIN > $tmpout 2>&1" 2 
		rlRun "cat $tmpout"
		rlAssertGrep "ipa: ERROR: testhost2.$DOMAIN: host not found" $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERMASTER"
		;;
	SLAVE1)
		rlLog "Machine in recipe is SLAVE ($(hostname))"

		rlRun "ipa host-add testhost2.$DOMAIN --force"		

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE1"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
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
	local tmpout=/tmp/irmtest.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_positive_0001 - Remove all replication agreements and data about Replica2"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
			
		rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE2 -f"
		rlRun "sleep 10"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertNotGrep "$SLAVE2" $tmpout
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlFail "ipa-replica-manage still listing deleted replica $MASTER to $SLAVE2"
		else
			rlPass "ipa-replica-manage reporting that $SLAVE2 no longer a replica of $MASTER"
		fi
			
		rlRun "ipa host-show $SLAVE2" 2

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

irm_del_positive_0002()
{
	local tmpout=/tmp/irmtest.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_positive_0002 - Remove all replication agreements and data about Replica1"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
			
		rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE1 -f"
		rlRun "sleep 10"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertNotGrep "$SLAVE1" $tmpout
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1|wc -l) -gt 0 ]; then
			rlFail "ipa-replica-manage still listing deleted replica $MASTER to $SLAVE1"
		else
			rlPass "ipa-replica-manage reporting that $SLAVE1 no longer a replica of $MASTER"
		fi
			
		rlRun "ipa host-show $SLAVE1" 2

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

# irm_del_negative
#     del s2 after s1 disconnected
#      

irm_del_negative_0000()
{
	local tmpout=/tmp/irmtest.out
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "irm_del_negative_0000 - Fail to remove all replication agreements and data about Replica2 after Replica1 disconnect"
	case "$MYROLE" in
	MASTER)
		rlLog "Machine in recipe is MASTER ($(hostname))"
			
		rlRun "ipa-replica-manage -p $ADMINPW del $SLAVE1 -f > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		irm_bugcheck_826677 $tmpout
		rlRun "sleep 10"
		rlRun "ipa-replica-manage -p $ADMINPW list $MASTER > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "$SLAVE1" $tmpout
		if [ $(ipa-replica-manage -p $ADMINPW list $MASTER|grep $SLAVE1|wc -l) -gt 0 ]; then
			rlPass "ipa-replica-manage not able to delete $SLAVE1 because $SLAVE2 would be orphaned"
		else
			rlFail "ipa-replica-manage reporting that $SLAVE1 no longer a replica of $MASTER.  $SLAVE2 has been orphaned"
		fi
			
		rlRun "ipa host-show $SLAVE2" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		if [ $(ipa-replica-manage -p $ADMINPW list $SLAVE1|grep $SLAVE2|wc -l) -gt 0 ]; then
			rlLog "found $SLAVE1 - $SLAVE2 replication agreement...deleting"
			rlRun "ipa-replica-manage -H $SLAVE1 -p $ADMINPW del $SLAVE2 --force"
		fi
	
		rlRun "ipa-replica-manage -H $SLAVE1 -p $ADMINPW del $SLAVE2 --force > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$SLAVE1' has no replication agreement for '$SLAVE2'" $tmpout

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "ipa-replica-manage -p $ADMINPW del dne.$DOMAIN > $tmpout 2>&1" 1
		rlRun "cat $tmpout"
		rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $BEAKERMASTER"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		
		rlRun "ipa user-add testuser2 --first=First --last=Last"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		
		rlRun "ipa user-show testuser2|grep testuser2" 1

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERSLAVE2"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERSLAVE2"
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
		rlLog "Machine in recipe is MASTER ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE2"

		rlRun "KinitAsAdmin"
		rlRun "ipa user-show testuser1|grep testuser1" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $BEAKERMASTER"
		;;
	SLAVE2)
		rlLog "Machine in recipe is SLAVE2 ($(hostname))"
		
		rlRun "KinitAsAdmin"
		rlRun "ipa user-del testuser1"	
		
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	SLAVE*)
		rlLog "Machine in recipe is SLAVE ($(hostname))"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	CLIENT)
		rlLog "Machine in recipe is CLIENT ($CLIENT)"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $BEAKERSLAVE2"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $BEAKERMASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
	[ -f $tmpout ] && rm -f $tmpout
}

