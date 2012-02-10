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
	nisint_automount_test_1001
}

# ypcat positive test
nisint_automount_test_1001()
{
	rlPhaseStartTest "nisint_automount_test_1001: ypcat positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISCLIENT	
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rlRun "ypcat -k auto.master |grep nisint" 0 "ypcat search for existing auto.master entry"
		rlRun "ypcat -k auto.home   |grep home" 0 "ypcat search for existing auto.home entry"
		rlRun "ypcat -k auto.nisint |grep app1" 0 "ypcat search for existing auto.nisint entry"
		rhts-sync-set -s "$FUNCNAME.1" $NISCLIENT
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
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT	
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME" $NISMASTER	
		rlRun "ypcat -k auto.master |grep notamap" 1 "Fail to ypcat search for non-existent auto.master entry"
		rhts-sync-set -s "$FUNCNAME" $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.home mount positive test
nisint_automount_test_1003()
{
	rlPhaseStartTest "nisint_automount_test_1003: auto.home mount positive test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "exportfs -o 'rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534' *:/home" 0 "Export /home for auto.home test"
		rhts-sync-set -s "$FUNCNAME.0" $NISMASTER
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rlRun "mkdir /nfshome"
		rlRun "service autofs restart"
		rlRun "touch /nfshome/gooduser1/testfile" 0 "touch a file in dir mounted via NIS auto.home"
		rlAssertExists "/nfshome/gooduser1/testfile" 0 "confirm file in NIS auto.home dir exists"
		rhts-sync-set -s "$FUNCNAME.1" $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.home mount negative (non-existent export) test
nisint_automount_test_1004()
{
	rlPhaseStartTest "nisint_automount_test_1004: auto.home mount negative test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "exportfs -o 'rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534' *:/home" 0 "Export /home for auto.home test"
		rhts-sync-set -s "$FUNCNAME.0" $NISMASTER
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rlRun "mkdir /nfshome"
		rlRun "service autofs restart"
		rlRun "touch /nfshome/notauser/testfile" 1 "Fail to touch a file in dir not in automount map and nfs export"
		rhts-sync-set -s "$FUNCNAME.1" $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.nisint positive tests
nisint_automount_test_1005()
{
	rlPhaseStartTest "nisint_automount_test_1005: auto.nisint mount positive test"	
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "exportfs -o 'rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534' *:/home" 0 "Export /home for auto.home test"
		rhts-sync-set -s "$FUNCNAME.0" $NISMASTER
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCNAME.0" $NISMASTER	
		rlRun "mkdir /nfshome"
		rlRun "service autofs restart"
		rlRun "touch /nfshome/gooduser1/testfile" 0 "touch a file in dir mounted via NIS auto.home"
		rlAssertExists "/nfshome/gooduser1/testfile" 0 "confirm file in NIS auto.home dir exists"
		rhts-sync-set -s "$FUNCNAME.1" $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# auto.nisint negative tests
