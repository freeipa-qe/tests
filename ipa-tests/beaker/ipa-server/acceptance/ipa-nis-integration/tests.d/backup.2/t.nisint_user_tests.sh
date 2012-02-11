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
	nisint_user_test_1000
	nisint_user_test_1010
	nisint_user_test_1011
	nisint_user_test_1012
	nisint_user_test_1013
	nisint_user_test_1014
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
		rhts-sync-set -s "$FUNCNAME" -m $MASTER
		[ -f $tmpout ] && rm $tmpout
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

nisint_user_test_envcleanup()
{
	rlPhaseStartTest "nisint_user_test_envcleanup: Delete users and cleanup"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
		rhts-sync-set -s "$FUNCNAME" -m $MASTER
		[ -f $tmpout ] && rm $tmpout
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
nisint_user_test_1001()
{
	PhaseStartTest "nisint_user_test_1001: ypcat positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat passwd|grep testuser1" 0 "ypcat search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
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
	PhaseStartTest "nisint_user_test_1002: ypcat negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat passwd|grep notauser" 1 "ypcat search for non-existent user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent positive
nisint_user_test_1003()
{
	PhaseStartTest "nisint_user_test_1003: getent positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "getent passwd testuser2" 0 "getent search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent negative
nisint_user_test_1004()
{
	PhaseStartTest "nisint_user_test_1004: getent negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "getent passwd notauser" 2 "attempt to getent search for non-existent user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# id positive
nisint_user_test_1005()
{
	PhaseStartTest "nisint_user_test_1005: id positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "id testuser1" 0 "id search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# id negative
nisint_user_test_1006()
{
	PhaseStartTest "nisint_user_test_1006: id negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "id notauser" 1 "id search for existing user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# touch positive
nisint_user_test_1007()
{
	PhaseStartTest "nisint_user_test_1007: su touch positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'touch /tmp/mytestfile.user1'" 0 "touch new file as exisiting user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# touch negative
nisint_user_test_1008()
{
	PhaseStartTest "nisint_user_test_1008: su touch negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'touch /tmp/mytestfile.user1'" 1 "attempt to touch existing file fail without permissions"
		rlRun "su - notauser -c 'touch /tmp/mytestfile.user1'" 125 "su fail as non-existent user"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rm negative
nisint_user_test_1009()
{
	PhaseStartTest "nisint_user_test_1009: su rm negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'rm -f /tmp/mytestfile.user1'" 1 "attempt to rm existing file fail without permissions"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rm positive
nisint_user_test_1010()
{
	PhaseStartTest "nisint_user_test_1010: su rm positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'rm -f /tmp/mytestfile.user1'" 0 "rm existing file"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# mkdir positive
nisint_user_test_1011()
{
	PhaseStartTest "nisint_user_test_1011: su mkdir positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'mkdir /tmp/mytmpdir.user1'" 0 "su mkdir new directory"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# mkdir negative
nisint_user_test_1011()
{
	PhaseStartTest "nisint_user_test_1011: su mkdir negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'mkdir /tmp/mytmpdir.user1/mytmpdir.user2'" 1 "attempt to mkdir new directory in dir without permissions"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rmdir negative
nisint_user_test_1012()
{
	PhaseStartTest "nisint_user_test_1012: su rmdir negative test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser2 -c 'rmdir /tmp/mytmpdir.user1'" 1 "attempt to rmdir directory without permissions"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# rmdir positive
nisint_user_test_1013()
{
	PhaseStartTest "nisint_user_test_1013: su rmdir positive test"
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
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "su - testuser1 -c 'rmdir /tmp/mytmpdir.user1'" 0 "rmdir directory"
		rhts-sync-set -s "$FUNCNAME" -m $NISCLIENT
		[ -f $tmpout ] && rm $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ssh as user to localhost # may need to wait on this one till migration...

nisint_user_test_1014()
{
	PhaseStartTest "nisint_user_test_1014: ssh positive test"
	case "$HOSTNAME" in
	"$MASTER")
		KinitAsAdmin
		rlLog "Machine in recipe is IPAMASTER"
		#rlRun "ipa host-add $NISCLIENT --ip-address=$NISCLIENT_IP"
		#rlRun "ipa-getkeytab -s $MASTER -p host/$NISCLIENT@$RELM -k /tmp/krb5.keytab.$NISCLIENT"
		#rlRun "scp /tmp/krb5.keytab.$NISCLIENT root@$NISCLIENT:/etc/krb5.keytab"
		#rhts-sync-set -s "$RUNCNAME.0" -m $MASTER
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		#rhts-sync-block -s "$FUNCNAME.0" $MASTER
		rhts-sync-block -s "$FUNCNAME.1" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		#rhts-sync-block -s "$FUNCNAME.0" $MASTER

		#rlRun "yum -y install krb5-workstation" 0 "Install krb5-workstation"
		#cp /etc/krb5.conf /etc/krb5.conf.orig.nisint
		#sed -i "s/kerberos.example.com/$MASTER/g" /etc/krb5.conf
		#sed -i "s/EXAMPLE.COM/$RELM/g" /etc/krb5.conf
		#sed -i "s/example.com/$DOMAIN/g" /etc/krb5.conf
		#rlRun "authconfig --enablekrb5 --update"

		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "ssh_auth_success testuser1 passw0rd1 localhost" 

		#yum -y remove krb5-workstation
		#mv /etc/krb5.conf.orig.nisint /etc/krb5.conf
		#rlRun "authconfig --disablekrb5 --update"
		#rm /etc/krb5.keytab

		[ -f $tmpout ] && rm $tmpout

		rhts-sync-set -s "$FUNCNAME.1" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}



