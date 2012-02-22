#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_automount_tests.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration Automount tests
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
nisint_automount_tests()
{
	nisint_automount_test_envsetup
	nisint_automount_test_1001
	nisint_automount_test_1002
	nisint_automount_test_1003
	nisint_automount_test_1004
	nisint_automount_test_1005
	nisint_automount_test_1006
	nisint_automount_test_1007
	nisint_automount_test_1008
	nisint_automount_test_1009
	nisint_automount_test_1010
}

nisint_automount_test_envsetup()
{
	rlPhaseStartTest "nisint_automount_test_envsetup: install autofs on client"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0' $NISCLIENT_IP	"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $NISCLIENT_IP	"
		rlLog "rhts-sync-block -s '$FUNCNAME.1' $NISMASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1' $NISMASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $NISCLIENT_IP"
		rlRun "sed -i 's/netgroup:   nisplus/netgroup:   nis/' /etc/nsswitch.conf"
		rlRun "service rpcbind restart"
		rlRun "service ypserv restart"
		rlRun "service ypbind restart"
		rlRun "service nfs restart"
		rlRun "service nfslock restart"
		rlRun "exportfs -a"
		rlRun "rhts-sync-set -s '$FUNCNAME.1' -m $NISMASTER_IP"
		
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "yum -y install autofs" 0 "Install autofs for testing"
		rlRun "service autofs restart"
		rlRun "rhts-sync-set -s '$FUNCNAME.0' -m $NISCLIENT_IP"
		rlLog "rhts-sync-block -s '$FUNCNAME.1' $NISMASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.1' $NISMASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
# ypcat positive test
nisint_automount_test_1001()
{
	rlPhaseStartTest "nisint_automount_test_1001: ypcat positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat -k auto.master |grep nisint" 0 "ypcat search for existing auto.master entry"
			rlRun "ypcat -k auto.home   |grep home" 0 "ypcat search for existing auto.home entry"
			rlRun "ypcat -k auto.nisint |grep app1" 0 "ypcat search for existing auto.nisint entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ypcat negative test
nisint_automount_test_1002()
{
	rlPhaseStartTest "nisint_automount_test_1002: ypcat negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat -k auto.master |grep notamap" 1 "Fail to ypcat search for non-existent auto.master entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ipa find positive test
nisint_automount_test_1003()
{
	rlPhaseStartTest "nisint_automount_test_1003: ipa positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(grep "auth_provider = .*ipa" /etc/sssd/sssd.conf|wc -l) -gt 0 ]; then
			rlPass "ipa not configured...skipping"
		else
			KinitAsAdmin
			rlRun "ipa automountkey-find nis auto.master|grep nisint" 0 "ipa search for existing auto.master entry"
			rlRun "ipa automountkey-find nis auto.home  |grep home" 0 "ipa search for existing auto.home entry"
			rlRun "ipa automountkey-find nis auto.nisint|grep app1" 0 "ipa search for existing auto.nisint entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ipa find negative test
nisint_automount_test_1004()
{
	rlPhaseStartTest "nisint_automount_test_1004: ipa negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(grep "auth_provider = .*ipa" /etc/sssd/sssd.conf|wc -l) -gt 0 ]; then
			rlPass "ipa not configured...skipping"
		else
			KinitAsAdmin
			rlRun "ipa automountkey-find nis auto.master|grep notamap" 1 "fail to ipa search for non-existent auto.master entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# automount -m positive test
nisint_automount_test_1005()
{
	rlPhaseStartTest "nisint_automount_test_1005: automount -m positive test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP	"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP	"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "automount -m|grep auto.home" 0 "automount -m search for existing auto.home entry"
		rlRun "automount -m|grep auto.nisint" 0 "automount -m search for existing auto.nisint entry"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# automount -m negative test?
nisint_automount_test_1006()
{
	rlPhaseStartTest "nisint_automount_test_1006: automount -m negative test"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "automount -m|grep map:.*notamap" 1 "failed automount -m search for non-existent automount map entry"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}


# auto.home mount positive test
nisint_automount_test_1007()
{
	rlPhaseStartTest "nisint_automount_test_1007: auto.home mount positive test"	
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nfshome/gooduser1/testfile" 0 "touch a file in dir mounted via NIS auto.home"
		rlAssertExists "/nfshome/gooduser1/testfile" 0 "confirm file in NIS auto.home dir exists"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.home mount negative (non-existent export) test
nisint_automount_test_1008()
{
	rlPhaseStartTest "nisint_automount_test_1008: auto.home mount negative test"	
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nfshome/notauser/testfile" 1 "Fail to touch a file in dir not in automount map and nfs export"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.nisint positive tests
nisint_automount_test_1009()
{
	rlPhaseStartTest "nisint_automount_test_1009: auto.nisint netgroup mount positive test"	
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nisint/app1/testfile" 0 "touch a file in dir mounted via NIS auto.home"
		rlAssertExists "/nisint/app1/testfile" 0 "confirm file in NIS auto.home dir exists"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.nisint negative tests
nisint_automount_test_1010()
{
	rlPhaseStartTest "nisint_automount_test_1010: auto.nisint netgroup mount negative test"	
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nisint/app2/testfile" 1 "Fail to touch a file in dir mounted via NIS auto.home"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

