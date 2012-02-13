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
	rlPhaseStartTest "nisint_user_test_envsetup: Create Users and Prep environment for tests"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "create_ipauser testuser1 NIS USER passw0rd1"
		rlRun "create_ipauser testuser2 NIS USER passw0rd1"
		KinitAsAdmin
		rhts-sync-set -s "$FUNCNAME" -m $MASTER
		[ -f $tmpout ] && rm -f $tmpout
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac

	rlPhaseEnd
}

nisint_user_test_envcleanup()
{
	rlPhaseStartTest "nisint_user_test_envcleanup: Delete users and cleanup"
	case "$HOSTNAME" in
	"$MASTER")
		KinitAsAdmin
		rlLog "Machine in recipe is IPAMASTER"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
		rhts-sync-set -s "$FUNCNAME" -m $MASTER
		[ -f $tmpout ] && rm -f $tmpout
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $MASTER
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rhts-sync-block -s "$FUNCNAME" $MASTER
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
	rlPhaseStartTest "nisint_user_test_1001: ypcat positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat passwd|grep testuser1" 0 "ypcat search for existing user"
		fi
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1002: ypcat negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
			rlPass "ypbind not running...skipping test"
		else
			rlRun "ypcat passwd|grep notauser" 1 "Fail to ypcat search for non-existent user"
		fi
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1003: ipa positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		if [ ! -f /usr/bin/ipa ]; then
			rlPass "ipa not found...skipping"
		else
			rlRun "ipa user-find|grep testuser1" 0 "ipa search for existing user"
		fi
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1004: ipa negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		if [ ! -f /usr/bin/ipa ]; then
			rlPass "ipa not found...skipping"
		else
			rlRun "ipa user-find|grep notauser" 1 "Fail to ipa search for non-existent user"
		fi
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1005: getent positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "getent passwd testuser2" 0 "getent search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1006: getent negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "getent passwd notauser" 2 "attempt to getent search for non-existent user"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1007: id positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "id testuser1" 0 "id search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1008: id negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "id notauser" 1 "id search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1009: su touch positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'touch /tmp/mytestfile.user1'" 0 "touch new file as exisiting user"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1010: su touch negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'touch /tmp/mytestfile.user1'" 1 "attempt to touch existing file fail without permissions"
		rlRun "su - notauser -c 'touch /tmp/mytestfile.user1'" 125 "su fail as non-existent user"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1011: su rm negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'rm -f /tmp/mytestfile.user1'" 1 "attempt to rm existing file fail without permissions"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1012: su rm positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'rm -f /tmp/mytestfile.user1'" 0 "rm existing file"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1013: su mkdir positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'mkdir /tmp/mytmpdir.user1'" 0 "su mkdir new directory"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1014: su mkdir negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'mkdir /tmp/mytmpdir.user1/mytmpdir.user2'" 1 "attempt to mkdir new directory in dir without permissions"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1015: su rmdir negative test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'rmdir /tmp/mytmpdir.user1'" 1 "attempt to rmdir directory without permissions"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1016: su rmdir positive test"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'rmdir /tmp/mytmpdir.user1'" 0 "rmdir directory"
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_user_test_1014: ssh positive test"
	case "$HOSTNAME" in
	"$MASTER")
		KinitAsAdmin
		rlLog "Machine in recipe is IPAMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCNAME" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ssh_auth_success testuser1 passw0rd1 localhost" 
		[ -f $tmpout ] && rm -f $tmpout
		rhts-sync-set -s "$FUNCNAME" -m $CLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh negative test
