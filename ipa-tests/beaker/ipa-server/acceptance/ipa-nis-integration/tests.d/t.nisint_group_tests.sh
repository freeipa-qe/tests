#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_group_tests.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration group functionality testing
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
nisint_group_tests()
{
	nisint_group_test_envsetup
	nisint_group_test_1001
	nisint_group_test_1002
	nisint_group_test_1003
	nisint_group_test_1004
	nisint_group_test_1005
	nisint_group_test_1006
	nisint_group_test_1007
	nisint_group_test_1008
	nisint_group_test_1009
	nisint_group_test_1010
	nisint_group_test_1011
	nisint_group_test_1012
	nisint_group_test_1013
	nisint_group_test_1014
	nisint_group_test_envcleanup
}

nisint_group_test_envsetup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_envsetup: "
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "create_ipauser testuser1 NIS USER passw0rd1"
		rlRun "create_ipauser testuser2 NIS USER passw0rd1"
		KinitAsAdmin
		rlRun "ipa user-mod testuser1 --uid=56678 --gidnumber=56678"
		rlRun "ipa user-mod testuser2 --uid=56679 --gidnumber=56679"
		rlRun "ipa group-add testgroup1 --gid=90001 --desc=NIS_GROUP_testgroup1"
		rlRun "ipa group-add testgroup2 --gid=90002 --desc=NIS_GROUP_testgroup2"
		rlRun "ipa group-add-member testgroup1 --users=testuser1"
		rlRun "ipa group-add-member testgroup2 --users=testuser2"
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

nisint_group_test_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_envcleanup: "
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		KinitAsAdmin
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
		rlRun "ipa group-del testgroup1"
		rlRun "ipa group-del testgroup2"
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
nisint_group_test_1001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1001: ypcat positive test"
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
			rlRun "ypcat group|grep testgroup1" 0 "ypcat search for existing group"
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
nisint_group_test_1002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1002: ypcat negative test"
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
			rlRun "ypcat group|grep notagroup" 1 "ypcat search for non-existent group"
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
nisint_group_test_1003()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1003: ipa positive test"
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
			rlRun "ipa group-show testgroup1" 0 "ipa search for existing group"
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
nisint_group_test_1004()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1004: ipa negative test"
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
			rlRun "ipa group-show notagroup" 2 "failed to ipa search for non-existent group"
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
nisint_group_test_1005()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1005: getent positive test"
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
		rlRun "getent group testgroup2" 0 "getent search for existing group"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# getent negative
nisint_group_test_1006()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1006: getent negative test"
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
		rlRun "getent group notagroup" 2 "attempt to getent search for non-existent group"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# chown positive
nisint_group_test_1007()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1007: chown positive test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch new file as existing user"
		rlRun "chown testuser1:testuser1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chown testuser1:testgroup1 /tmp/mytestfile.user1'" 0 "chown file to another group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# chown negative
nisint_group_test_1008()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1008: chown negative test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown testuser1:testuser1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chown testuser1:testgroup2 /tmp/mytestfile.user1'" 1 "attempt to chown file as invalid group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# chgrp positive
nisint_group_test_1009()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1009: chgrp positive test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown testuser1:testuser1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chgrp testgroup1 /tmp/mytestfile.user1'" 0 "chgrp file to another group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# chgrp negative
nisint_group_test_1010()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1010: chgrp negative test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown testuser1:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chgrp testgroup2 /tmp/mytestfile.user1'" 1 "attempt to chgrp file as invalid group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# write positive
nisint_group_test_1011()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1011: write positive test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "chmod 660 /tmp/mytestfile.user1" 0 "set group write permissions"
		rlRun "su - testuser1 -c 'echo my_test_$FUNCNAME > /tmp/mytestfile.user1'" 0 "write some data to test file"
		rlAssertGrep "my_test_$FUNCNAME" /tmp/mytestfile.user1
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# write negative
nisint_group_test_1012()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1012: write negative test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "chmod 660 /tmp/mytestfile.user1" 0 "set group write permissions"
		rlRun "su - testuser2 -c 'echo my_test_$FUNCNAME > /tmp/mytestfile.user1'" 1 "attempt to write some data to test file with invalid group permissions"
		rlAssertNotGrep "my_test_$FUNCNAME" /tmp/mytestfile.user1
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# read positive
nisint_group_test_1013()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1013: read positive test"
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
		rlRun "echo my_test_$FUNCNAME > /tmp/mytestfile.user1" 0 "create file with data for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'grep my_test_$FUNCNAME /tmp/mytestfile.user1'" 0 "read file"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# read negative 
nisint_group_test_1014()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_group_test_1014: read negative test"
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
		rlRun "echo my_test_$FUNCNAME > /tmp/mytestfile.user1" 0 "create file with data for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser2 -c 'grep my_test_$FUNCNAME /tmp/mytestfile.user1'" 0 "attempt to read file with invalid group permissions"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}


