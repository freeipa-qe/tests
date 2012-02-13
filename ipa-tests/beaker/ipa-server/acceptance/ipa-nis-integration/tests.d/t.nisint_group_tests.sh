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
	rlPhaseStartTest "nisint_group_test_envsetup: "
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "create_ipauser testuser1 NIS USER passw0rd1"
		rlRun "create_ipauser testuser2 NIS USER passw0rd1"
		KinitAsAdmin
		rlRun "ipa group-add testgroup1 --desc=NIS_GROUP_testgroup1"
		rlRun "ipa group-add testgroup2 --desc=NIS_GROUP_testgroup2"
		rlRun "ipa group-add-member testgroup1 --users=testuser1"
		rlRun "ipa group-add-member testgroup2 --users=testuser2"
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

nisint_group_test_envcleanup()
{
	rlPhaseStartTest "nisint_group_test_envcleanup: "
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		KinitAsAdmin
		rlRun "ipa user-del testuser1"
		rlRun "ipa user-del testuser2"
		rlRun "ipa group-del testgroup1"
		rlRun "ipa group-del testgroup2"
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
nisint_group_test_1001()
{
	rlPhaseStartTest "nisint_group_test_1001: ypcat positive test"
	if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
		rlPass "ypbind not running...skipping test"
		rlPhaseEnd
		return 0
	fi

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
		rlRun "ypcat group|grep testgroup1" 0 "ypcat search for existing group"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1002: ypcat negative test"
	if [ $(ps -ef|grep [y]pbind|wc -l) -eq 0 ]; then
		rlPass "ypbind not running...skipping test"
		rlPhaseEnd
		return 0
	fi

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
		rlRun "ypcat group|grep notagroup" 1 "ypcat search for non-existent group"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1003: ipa positive test"
	if [ ! -f /usr/bin/ipa ]; then
		rlPass "ipa not found...skipping"
		rlPhaseEnd
		return 0
	fi

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
		rlRun "ipa group-find|grep testgroup1" 0 "ipa search for existing group"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1004: ipa negative test"
	if [ ! -f /usr/bin/ipa ]; then
		rlPass "ipa not found...skipping"
		rlPhaseEnd
		return 0
	fi

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
		rlRun "ipa group-find|grep notagroup" 1 "failed to ipa search for non-existent group"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1005: getent positive test"
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
		rlRun "getent group testgroup2" 0 "getent search for existing group"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1006: getent negative test"
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
		rlRun "getent group notagroup" 2 "attempt to getent search for non-existent group"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1007: chown positive test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch new file as existing user"
		rlRun "chown testuser1:testuser1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chown testuser1:testgroup1 /tmp/mytestfile.user1'" 0 "chown file to another group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1008: chown negative test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown testuser1:testuser1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chown testuser1:testgroup2 /tmp/mytestfile.user1'" 1 "attempt to chown file as invalid group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1009: chgrp positive test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown testuser1:testuser1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chgrp testgroup1 /tmp/mytestfile.user1'" 0 "chgrp file to another group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1010: chgrp negative test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown testuser1:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'chgrp testgroup2 /tmp/mytestfile.user1'" 1 "attempt to chgrp file as invalid group"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1011: write positive test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "chmod 660 /tmp/mytestfile.user1" 0 "set group write permissions"
		rlRun "su - testuser1 -c 'echo my_test_$FUNCNAME > /tmp/mytestfile.user1'" 0 "write some data to test file"
		rlAssertGrep "my_test_$FUNCNAME" /tmp/mytestfile.user1
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1012: write negative test"
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
		rlRun "touch /tmp/mytestfile.user1" 0 "touch file for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "chmod 660 /tmp/mytestfile.user1" 0 "set group write permissions"
		rlRun "su - testuser2 -c 'echo my_test_$FUNCNAME > /tmp/mytestfile.user1'" 1 "attempt to write some data to test file with invalid group permissions"
		rlAssertNotGrep "my_test_$FUNCNAME" /tmp/mytestfile.user1
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1013: read positive test"
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
		rlRun "echo my_test_$FUNCNAME > /tmp/mytestfile.user1" 0 "create file with data for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser1 -c 'grep my_test_$FUNCNAME /tmp/mytestfile.user1'" 0 "read file"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
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
	rlPhaseStartTest "nisint_group_test_1014: read negative test"
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
		rlRun "echo my_test_$FUNCNAME > /tmp/mytestfile.user1" 0 "create file with data for testing"
		rlRun "chown root:testgroup1 /tmp/mytestfile.user1" 0 "chown file to another group"
		rlRun "su - testuser2 -c 'grep my_test_$FUNCNAME /tmp/mytestfile.user1'" 0 "attempt to read file with invalid group permissions"
		rlRun "rm -f /tmp/mytestfile.user1" 0 "cleanup/remove file"
		rhts-sync-block -s "$FUNCNAME" -m $CLIENT
		[ -f $tmpout ] && rm -f $tmpout
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}


