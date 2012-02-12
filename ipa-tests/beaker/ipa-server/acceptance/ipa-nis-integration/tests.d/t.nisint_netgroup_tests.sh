#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_netgroup_tests.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration Netgroup functional tests
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

######################################################################
# test suite
######################################################################
nisint_netgroup_tests()
{
	nisint_netgroup_test_envsetup
	nisint_netgroup_test_1001
	nisint_netgroup_test_1002
	nisint_netgroup_test_1003
	nisint_netgroup_test_1004
	nisint_netgroup_test_1005
	nisint_netgroup_test_1006
	nisint_netgroup_test_1007
	nisint_netgroup_test_1008
	nisint_netgroup_test_1009
	nisint_netgroup_test_1010
	nisint_netgroup_test_envcleanup
}

nisint_netgroup_test_envsetup()
{
	rlPhaseStartTest "nisint_netgroup_test_envsetup: "
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "create_ipauser testuser1 test user passw0rd1"
		rlRun "create_ipauser testuser2 test user passw0rd1"
		KinitAsAdmin
		rlRun "ipa netgroup-add testnetgroup1 --desc=testnetgroup1"
		rlRun "ipa netgroup-add testnetgroup2 --desc=testnetgroup2"
		rlRun "ipa netgroup-add-member testnetgroup1 --users=testuser1 --hosts=$MASTER"
		rlRun "ipa netgroup-add-member testnetgroup2 --users=testuser2 --hosts=$NISCLIENT"
		rhts-sync-set -s "$FUNCNAME" -m $MASTER
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

nisint_netgroup_test_envcleanup()
{
	rlPhaseStartTest "nisint_netgroup_test_envcleanup: "
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		KinitAsAdmin
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
		rlRun "ipa netgroup-del testnetgroup1"
		rlRun "ipa netgroup-del testnetgroup2"
		rhts-sync-set -s "$FUNCNAME" -m $MASTER
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ypcat positive
nisint_netgroup_test_1001()
{
	rlPhaseStartTest "nisint_netgroup_test_1001: ypcat positive test"
	if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
		rlPass "ypbind not running...skipping test"
		rlPhaseEnd
		return 0
	fi

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "ypcat -k netgroup|grep testnetgroup1" 0 "ypcat search for existing netgroup"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ypcat negative
nisint_netgroup_test_1002()
{
	rlPhaseStartTest "nisint_netgroup_test_1002: ypcat negative test"
	if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
		rlPass "ypbind not running...skipping test"
		rlPhaseEnd
		return 0
	fi

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "ypcat -k netgroup|grep notanetgroup" 1 "attempt to ypcat search for non-existent netgroup"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ipa positive
nisint_netgroup_test_1003()
{
	rlPhaseStartTest "nisint_netgroup_test_1003: ipa positive test"
	if [ ! -f /usr/bin/ipa ]; then
		rlPass "ipa not found...skipping"
		rlPhaseEnd
		return 0
	fi

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "ipa netgroup-find|grep testnetgroup1" 0 "ipa search for existing netgroup"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ipa negative
nisint_netgroup_test_1004()
{
	rlPhaseStartTest "nisint_netgroup_test_1004: ipa negative test"
	if [ ! -f /usr/bin/ipa ]; then
		rlPass "ipa not found...skipping"
		rlPhaseEnd
		return 0
	fi

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "ipa netgroup-find|grep notanetgroup" 1 "fail to ipa search for non-existent netgroup"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent positive
nisint_netgroup_test_1005()
{
	rlPhaseStartTest "nisint_netgroup_test_1005: getent positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "getent netgroup testnetgroup1" 0 "getent search for existing netgroup"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent negative
nisint_netgroup_test_1006()
{
	rlPhaseStartTest "nisint_netgroup_test_1006: getent negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "getent netgroup|grep notanetgroup" 1 "attempt to getent search for non-existent netgroup"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh positive
nisint_netgroup_test_1007()
{
	rlPhaseStartTest "nisint_netgroup_test_1007: ssh positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT

		ssh_auth_success testuser1 passw0rd1 $NISCLIENT

		rhts-sync-set -s "$FUNCNAME.2" -m $MASTER
		rhts-sync-block -s "$FUNCNAME.3" $NISCLIENT	
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.2" $MASTER
		rhts-sync-block -s "$FUNCNAME.3" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		# setup hosts.allow/hosts.deny files using netgroups
		cp /etc/hosts.allow /etc/hosts.allow.orig.nisint
		cp /etc/hosts.deny /etc/hosts.deny.orig.nisint
		echo "ALL: @testnetgroup1" > /etc/hosts.allow
		echo "ALL: ALL" > /etc/hosts.deny

		rhts-sync-set -s "$FUNCNAME.1" -m $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.2" $MASTER

		# cleanup/undo hosts.allow/host.deny files
		mv -f /etc/hosts.allow.orig.nisint /etc/hosts.allow
		mv -f /etc/hosts.deny.orig.nisint /etc/hosts.deny

		rhts-sync-set -s "$FUNCNAME.3" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh negative
nisint_netgroup_test_1008()
{
	rlPhaseStartTest "nisint_netgroup_test_1008: ssh negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT

		ssh_auth_failure testuser1 passw0rd1 $NISCLIENT

		rhts-sync-set -s "$FUNCNAME.2" -m $MASTER
		rhts-sync-block -s "$FUNCNAME.3" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.2" $MASTER
		rhts-sync-block -s "$FUNCNAME.3" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"

		# setup hosts.allow/hosts.deny files using netgroups
		cp /etc/hosts.allow /etc/hosts.allow.orig.nisint
		cp /etc/hosts.deny /etc/hosts.deny.orig.nisint
		echo "ALL: @testnetgroup1" > /etc/hosts.deny
		echo "#ALL: ALL" > /etc/hosts.allow

		rhts-sync-set -s "$FUNCNAME.1" -m $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.2" $MASTER
		
		mv -f /etc/hosts.allow.orig.nisint /etc/hosts.allow
        mv -f /etc/hosts.deny.orig.nisint /etc/hosts.deny

		rhts-sync-set -s "$FUNCNAME.3" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# nfs mount positive
nisint_netgroup_test_1009()
{
	rlPhaseStartTest "nisint_netgroup_test_1009: nfs mount positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISCLIENT
		rlRun "mkdir /nctmp" 0 "Create temp mount point."
		rlRun "mount $NISCLIENT:/tmp /nctmp" 0 "NFS Mount with netgroup access"
		rlRun "umount /nctmp" 0 "Unmount NFS export"
		rlRun "rmdir /nctmp" 0 "Remove temp mount point."
		rhts-sync-set -s "$FUNCNAME.1" -m $MASTER
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.1" $MASTER
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "service rpcbind restart"
		rlRun "service nfs restart"
		rlRun "service nfslock restart"
		rlRun "exportfs @testnetgroup1:/tmp"
		rhts-sync-set -s "$FUNCNAME.0" -m $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.1" $MASTER
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# nfs mount negative
nisint_netgroup_test_1010()
{
	rlPhaseStartTest "nisint_netgroup_test_1010: nfs mount negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.1" $NISMASTER
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISCLIENT
		rlRun "mkdir /nctmp"
		rlRun "mount $NISCLIENT:/tmp /nctmp" 32 "Fail to NFS Mount with no netgroup access"
		rlRun "rmdir /nctmp" 0 "Remove temp mount point."
		rhts-sync-set -s "$FUNCNAME.1" $NISMASTER
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "service rpcbind restart"
		rlRun "service nfs restart"
		rlRun "service nfslock restart"
		rlRun "exportfs @testnetgroup1:/tmp"
		rhts-sync-set -s "$FUNCNAME.0" -m $NISCLIENT
		rhts-sync-block -s "$FUNCNAME.1" $NISMASTER
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
