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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_envsetup: "
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "create_ipauser testuser1 test user passw0rd1"
		rlRun "create_ipauser testuser2 test user passw0rd1"
		KinitAsAdmin
		rlRun "ipa user-mod testuser1 --uid=56678 --gidnumber=56678"
		rlRun "ipa user-mod testuser2 --uid=56679 --gidnumber=56679"
		rlRun "ipa netgroup-add testnetgroup1 --desc=testnetgroup1"
		rlRun "ipa netgroup-add testnetgroup2 --desc=testnetgroup2"
		rlRun "ipa netgroup-add-member testnetgroup1 --users=testuser1 --hosts=$MASTER"
		rlRun "ipa netgroup-add-member testnetgroup2 --users=testuser2 --hosts=$NISCLIENT"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		rlRun "sed -i 's/netgroup:   nisplus/netgroup:   nis/' /etc/nsswitch.conf"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		rlRun "sed -i 's/netgroup:   nisplus/netgroup:   nis/' /etc/nsswitch.conf"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

nisint_netgroup_test_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_envcleanup: "
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		KinitAsAdmin
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
		rlRun "ipa netgroup-del testnetgroup1"
		rlRun "ipa netgroup-del testnetgroup2"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1001: ypcat positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat -k netgroup|grep \"testnetgroup1.*($MASTER,testuser1,$DOMAIN)\"" 0 "ypcat search for existing netgroup"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1002: ypcat negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat -k netgroup|grep notanetgroup" 1 "attempt to ypcat search for non-existent netgroup"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1003: ipa positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(grep "auth_provider = .*ipa" /etc/sssd/sssd.conf 2>/dev/null|wc -l) -eq 0 ]; then
			rlPass "ipa not configured...skipping"
		else
			if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) ]; then
				rlPass "ipa command not provided with RHEL 5...skipping"
			else
				rlRun "ipa netgroup-show testnetgroup1" 0 "ipa search for existing netgroup"
			fi
			rlRun "ldapsearch -x -h $MASTER_IP -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -b cn=testnetgroup1,cn=ng,cn=compat,$BASEDN \"nisNetgroupTriple=*\($MASTER,testuser1,$DOMAIN\)*\""
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1004: ipa negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(grep "auth_provider = .*ipa" /etc/sssd/sssd.conf 2>/dev/null|wc -l) -eq 0 ]; then
			rlPass "ipa not configured...skipping"
		elif [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) ]; then
			rlPass "ipa command not provided with RHEL 5...skipping"
		else
			rlRun "ipa netgroup-show notanetgroup" 2 "fail to ipa search for non-existent netgroup"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1005: getent positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ypwhich 2>/dev/null |wc -l) -gt 0 ]; then
			rlRun "getent -s nis netgroup testnetgroup1" 0 "getent search for existing netgroup"
		else
			rlRun "getent netgroup testnetgroup1" 0 "getent search for existing netgroup"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1006: getent negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "getent -s nis netgroup notanetgroup|grep notanetgroup" 1 "attempt to getent search for non-existent netgroup"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1007: ssh positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"

		ssh_auth_success testuser1 passw0rd1 $NISCLIENT

		rlRun "rhts-sync-set -s '$FUNCNAME.2.$TESTORDER' -m $MASTER_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP	"
		rlRun "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP	"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		# setup hosts.allow/hosts.deny files using netgroups
		rlRun "cp /etc/hosts.allow /etc/hosts.allow.orig.nisint"
		rlRun "cp /etc/hosts.deny /etc/hosts.deny.orig.nisint"
		rlRun "echo 'ALL: @testnetgroup1' > /etc/hosts.allow"
		rlRun "echo 'ALL: ALL' > /etc/hosts.deny"

		rlRun "rhts-sync-set -s '$FUNCNAME.1.$TESTORDER' -m $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"

		# cleanup/undo hosts.allow/host.deny files
		rlRun "mv -f /etc/hosts.allow.orig.nisint /etc/hosts.allow"
		rlRun "mv -f /etc/hosts.deny.orig.nisint /etc/hosts.deny"

		rlRun "rhts-sync-set -s '$FUNCNAME.3.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1008: ssh negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"

		ssh_auth_failure testuser1 passw0rd1 $NISCLIENT

		rlRun "rhts-sync-set -s '$FUNCNAME.2.$TESTORDER' -m $MASTER_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.3.$TESTORDER' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"

		# setup hosts.allow/hosts.deny files using netgroups
		rlRun "cp /etc/hosts.allow /etc/hosts.allow.orig.nisint"
		rlRun "cp /etc/hosts.deny /etc/hosts.deny.orig.nisint"
		rlRun "echo 'ALL: @testnetgroup1' > /etc/hosts.deny"
		rlRun "echo '#ALL: ALL' > /etc/hosts.allow"

		rlRun "rhts-sync-set -s '$FUNCNAME.1.$TESTORDER' -m $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $MASTER_IP"
		
		rlRun "mv -f /etc/hosts.allow.orig.nisint /etc/hosts.allow"
        rlRun "mv -f /etc/hosts.deny.orig.nisint /etc/hosts.deny"

		rlRun "rhts-sync-set -s '$FUNCNAME.3.$TESTORDER' -m $NISCLIENT_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1009: nfs mount positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlRun "mkdir /nctmp" 0 "Create temp mount point."
		rlRun "mount -o intr,soft,timeo=100 $NISCLIENT:/tmp /nctmp" 0 "NFS Mount with netgroup access"
		rlRun "umount /nctmp" 0 "Unmount NFS export"
		rlRun "rmdir /nctmp" 0 "Remove temp mount point."
		rlRun "rhts-sync-set -s '$FUNCNAME.1.$TESTORDER' -m $MASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
			rlRun "service portmap restart"
		else
			rlRun "service rpcbind restart"
		fi
		
		#if [ $(mount|grep /proc/fs/nfsd|wc -l) -eq 0 ]; then
		if [ $(grep /proc/fs/nfsd /etc/mtab|wc -l) -eq 0 ]; then
			rlRun "mount"
			rlRun "cat /etc/mtab"
			rlRun "cat /proc/mounts"
			rlRun "mount -t nfsd nfsd /proc/fs/nfsd" 0,32
			rlRun "mount"
			rlRun "cat /etc/mtab"
			rlRun "cat /proc/mounts"
		fi
		if [ -f /usr/lib/systemd/system/nfs-server.service ]; then
			rlRun "systemctl restart nfs-server.service"
		else
			rlRun "service nfs restart"
		fi
		if [ -f /usr/lib/systemd/system/nfs-lock.service ]; then
			rlRun "systemctl restart nfs-lock.service"
		else
			rlRun "service nfslock restart"
		fi
		rlRun "exportfs -o fsid=0 @testnetgroup1:/tmp"
		rlRun "rhts-sync-set -s '$FUNCNAME.0.$TESTORDER' -m $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
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
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_netgroup_test_1010: nfs mount negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISMASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISMASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.0.$TESTORDER' $NISCLIENT_IP"
		rlRun "mkdir /nctmp"
		rlRun "mount -o intr,soft,timeo=100 $NISCLIENT:/tmp /nctmp" 32 "Fail to NFS Mount with no netgroup access"
		rlRun "rmdir /nctmp" 0 "Remove temp mount point."
		rlRun "rhts-sync-set -s '$FUNCNAME.1.$TESTORDER' -m $NISMASTER_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
			rlRun "service portmap restart"
		else
			rlRun "service rpcbind restart"
		fi
		if [ -f /usr/lib/systemd/system/nfs-server.service ]; then
			rlRun "systemctl restart nfs-server.service"
		else
			rlRun "service nfs restart"
		fi
		if [ -f /usr/lib/systemd/system/nfs-lock.service ]; then
			rlRun "systemctl restart nfs-lock.service"
		else
			rlRun "service nfslock restart"
		fi
		rlRun "exportfs @testnetgroup1:/tmp"
		rlRun "rhts-sync-set -s '$FUNCNAME.0.$TESTORDER' -m $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISMASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $NISMASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
