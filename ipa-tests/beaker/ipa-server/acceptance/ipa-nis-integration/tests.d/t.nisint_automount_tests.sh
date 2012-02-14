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
}

nisint_automount_test_envsetup()
{
	rlPhaseStartTest "nisint_automount_test_envsetup: install autofs on client"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $NISCLIENT	"
		rlRun "rhts-sync-block -s '$FUNCNAME.1' $NISMASTER"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $NISCLIENT"
		rlRun "sed -i 's/netgroup:   nisplus/netgroup:   nis/' /etc/nsswitch.conf"
		rlRun "service rpcbind restart"
		rlRun "service ypserv restart"
		rlRun "service ypbind restart"
		rlRun "service nfs restart"
		rlRun "service nfslock restart"
		rlRun "exportfs -a"
		rlRun "rhts-sync-set -s '$FUNCNAME.1' -m $NISMASTER"
		
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "yum -y install autofs" 0 "Install autofs for testing"
		rlRun "service autofs restart"
		rlRun "rhts-sync-set -s '$FUNCNAME.0' -m $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.1' $NISMASTER"
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
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT	"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat -k auto.master |grep nisint" 0 "ypcat search for existing auto.master entry"
			rlRun "ypcat -k auto.home   |grep home" 0 "ypcat search for existing auto.home entry"
			rlRun "ypcat -k auto.nisint |grep app1" 0 "ypcat search for existing auto.nisint entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
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
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT	"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat -k auto.master |grep notamap" 1 "Fail to ypcat search for non-existent auto.master entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
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
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT	"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ ! -f /usr/bin/ipa ]; then
			rlPass "ipa not found...skipping"
		else
			KinitAsAdmin
			rlRun "ipa automountkey-find nis auto.master|grep nisint" 0 "ipa search for existing auto.master entry"
			rlRun "ipa automountkey-find nis auto.home  |grep home" 0 "ipa search for existing auto.home entry"
			rlRun "ipa automountkey-find nis auto.nisint|grep app1" 0 "ipa search for existing auto.nisint entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ipa find positive test
nisint_automount_test_1004()
{
	rlPhaseStartTest "nisint_automount_test_1004: ipa negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT	"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		if [ ! -f /usr/bin/ipa ]; then
			rlPass "ipa not found...skipping"
		else
			KinitAsAdmin
			rlRun "ipa automountkey-find nis auto.master|grep notamap" 1 "fail to ipa search for non-existent auto.master entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.home mount positive test
nisint_automount_test_1005()
{
	rlPhaseStartTest "nisint_automount_test_1005: auto.home mount positive test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nfshome/gooduser1/testfile" 0 "touch a file in dir mounted via NIS auto.home"
		rlAssertExists "/nfshome/gooduser1/testfile" 0 "confirm file in NIS auto.home dir exists"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.home mount negative (non-existent export) test
nisint_automount_test_1006()
{
	rlPhaseStartTest "nisint_automount_test_1006: auto.home mount negative test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nfshome/notauser/testfile" 1 "Fail to touch a file in dir not in automount map and nfs export"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.nisint positive tests
nisint_automount_test_1007()
{
	rlPhaseStartTest "nisint_automount_test_1007: auto.nisint netgroup mount positive test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nisint/app1/testfile" 0 "touch a file in dir mounted via NIS auto.home"
		rlAssertExists "/nisint/app1/testfile" 0 "confirm file in NIS auto.home dir exists"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.nisint negative tests
nisint_automount_test_1008()
{
	rlPhaseStartTest "nisint_automount_test_1008: auto.nisint netgroup mount negative test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "touch /nisint/app2/testfile" 1 "Fail to touch a file in dir mounted via NIS auto.home"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

