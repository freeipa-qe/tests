#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_user_tests.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration User functionality tests
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
nisint_user_tests()
{
	nisint_user_test_envsetup
	nisint_user_test_1001
	nisint_user_test_1002
	nisint_user_test_1003
	nisint_user_test_1004
	nisint_user_test_1005
	nisint_user_test_1006
	nisint_user_test_1007
	nisint_user_test_1008
	nisint_user_test_1009
	nisint_user_test_1010
	nisint_user_test_1011
	nisint_user_test_1012
	nisint_user_test_1013
	nisint_user_test_1014
	nisint_user_test_1015
	nisint_user_test_1016
	nisint_user_test_1017
	nisint_user_test_envcleanup
}

nisint_user_test_envsetup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_envsetup: Create Users and Prep environment for tests"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "create_ipauser testuser1 NIS USER passw0rd1"
		rlRun "create_ipauser testuser2 NIS USER passw0rd1"
		KinitAsAdmin
		rlRun "ipa user-mod testuser1 --uid=56678 --gidnumber=56678"
		rlRun "ipa user-mod testuser2 --uid=56679 --gidnumber=56679"
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

nisint_user_test_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_envcleanup: Delete users and cleanup"
	case "$MYROLE" in
	"MASTER")
		KinitAsAdmin
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
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
nisint_user_test_1001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1001: ypcat positive test"
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
			rlRun "ypcat passwd|grep testuser1" 0 "ypcat search for existing user"
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
nisint_user_test_1002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1002: ypcat negative test"
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
			rlRun "ypcat passwd|grep notauser" 1 "Fail to ypcat search for non-existent user"
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
nisint_user_test_1003()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1003: ipa positive test"
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
			rlRun "ipa user-show testuser1" 0 "ipa search for existing user"
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
nisint_user_test_1004()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1004: ipa negative test"
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
			rlRun "ipa user-show testuser1" 0 "ipa search for existing user"
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
nisint_user_test_1005()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1005: getent positive test"
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
		rlRun "getent passwd testuser2" 0 "getent search for existing user"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent negative
nisint_user_test_1006()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1006: getent negative test"
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
		rlRun "getent passwd notauser" 2 "attempt to getent search for non-existent user"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# id positive
nisint_user_test_1007()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1007: id positive test"
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
		rlRun "id testuser1" 0 "id search for existing user"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# id negative
nisint_user_test_1008()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1008: id negative test"
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
		rlRun "id notauser" 1 "id search for non-existent user"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# touch positive
nisint_user_test_1009()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1009: su touch positive test"
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
		rlRun "su - testuser1 -c 'touch /tmp/mytestfile.user1'" 0 "touch new file as exisiting user"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# touch negative
nisint_user_test_1010()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1010: su touch negative test"
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
		rlRun "su - testuser2 -c 'touch /tmp/mytestfile.user1'" 1 "attempt to touch existing file fail without permissions"
		rlRun "su - notauser -c 'touch /tmp/mytestfile.user1'" 1,125 "su fail as non-existent user"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rm negative
nisint_user_test_1011()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1011: su rm negative test"
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
		rlRun "su - testuser2 -c 'rm -f /tmp/mytestfile.user1'" 1 "attempt to rm existing file fail without permissions"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rm positive
nisint_user_test_1012()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1012: su rm positive test"
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
		rlRun "su - testuser1 -c 'rm -f /tmp/mytestfile.user1'" 0 "rm existing file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# mkdir positive
nisint_user_test_1013()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1013: su mkdir positive test"
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
		rlRun "su - testuser1 -c 'mkdir /tmp/mytmpdir.user1'" 0 "su mkdir new directory"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# mkdir negative
nisint_user_test_1014()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1014: su mkdir negative test"
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
		rlRun "su - testuser2 -c 'mkdir /tmp/mytmpdir.user1/mytmpdir.user2'" 1 "attempt to mkdir new directory in dir without permissions"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rmdir negative
nisint_user_test_1015()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1015: su rmdir negative test"
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
		rlRun "su - testuser2 -c 'rmdir /tmp/mytmpdir.user1'" 1 "attempt to rmdir directory without permissions"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rmdir positive
nisint_user_test_1016()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1016: su rmdir positive test"
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
		rlRun "su - testuser1 -c 'rmdir /tmp/mytmpdir.user1'" 0 "rmdir directory"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh as user to localhost # may need to wait on this one till migration...
nisint_user_test_1017()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_user_test_1017: ssh positive test"
	case "$MYROLE" in
	"MASTER")
		KinitAsAdmin
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
		rlRun "ssh_auth_success testuser1 passw0rd1 localhost" 
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh negative test
