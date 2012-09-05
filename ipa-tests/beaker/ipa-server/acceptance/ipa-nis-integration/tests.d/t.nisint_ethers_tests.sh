#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_ethers_tests.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration Ethers functionality tests
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
nisint_ethers_map_enabled_check() 
{
	rlPhaseStartTest "nisint_ethers_map_enabled_check: check if ethers map is enabled"
		export ENABLE_ETHERS=$(ldapsearch -h $MASTER_IP -xLLL -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=NIS Server,cn=plugins,cn=config" "nis-map=ethers.byaddr"|grep "dn: nis-domain=$DOMAIN+nis-map=ethers.byaddr"|wc -l)
		rlLog "ENABLE_ETHERS=$ENABLE_ETHER"
	rlPhaseEnd
}

nisint_ethers_tests()
{
	nisint_ethers_test_envsetup
	nisint_ethers_test_1001
	nisint_ethers_test_1002
	nisint_ethers_test_1003
	nisint_ethers_test_1004
	nisint_ethers_test_envcleanup
}

nisint_ethers_test_envsetup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_ethers_test_envsetup: Create Hosts and Ethers entries and Prep environment for tests"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		KinitAsAdmin
		rlRun "ipa host-add testethershost1.$DOMAIN --macaddress=99:88:77:66:55:44 --force"
		rlRun "ipa host-add testethershost2.$DOMAIN --macaddress=11:22:33:44:55:66 --force"
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

nisint_ethers_test_envcleanup()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_ethers_test_envcleanup: Delete etherss and cleanup"
	case "$MYROLE" in
	"MASTER")
		KinitAsAdmin
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "ipa host-del testethershost1.$DOMAIN"
		rlRun "ipa host-del testethershost2.$DOMAIN"
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
nisint_ethers_test_1001()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_ethers_test_1001: ypcat positive test"
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
			rlRun "ypcat ethers|grep testethershost1" 0 "ypcat search for existing ethers"
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
nisint_ethers_test_1002()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_ethers_test_1002: ypcat negative test"
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
			rlRun "ypcat ethers|grep notaethers" 1 "Fail to ypcat search for non-existent ethers"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ypmatch positive
nisint_ethers_test_1003()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_ethers_test_1003: ypmatch positive test"
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
			rlLog "Checking the ipa added entries"
			rlRun "ypmatch 99:88:77:66:55:44 ethers.byaddr | grep testethershost1.$DOMAIN"
			rlRun "ypmatch 11:22:33:44:55:66 ethers.byaddr | grep testethershost2.$DOMAIN"
			rlRun "ypmatch testethershost1.$DOMAIN ethers.byname | grep 99:88:77:66:55:44"
			rlRun "ypmatch testethershost2.$DOMAIN ethers.byname | grep 11:22:33:44:55:66"
	
			rlLog "Checking the ldif added entries"
			for i in 1 2 3 4; do
				rlRun "ypmatch 00:00:00:00:00:0$i ethers.byaddr | grep etherhost$i.$DOMAIN" 0 "Successfully run ypmatch to find ethers.byaddr entry"
			done
			for i in 1 2 3 4; do
				rlRun "ypmatch etherhost$i.$DOMAIN ethers.byname | grep 00:00:00:00:00:0$i" 0 "Successfully run ypmatch to find ethers.byname entry"
			done
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}

# ypmatch negative
nisint_ethers_test_1004()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "nisint_ethers_test_1004: ypmatch negative test"
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
			rlRun "ypmatch FF:FF:FF:00:00:0F ethers.byaddr" 1 "Successfully run ypmatch to find ethers.byaddr entry"
			rlRun "ypmatch nonexistent.server.com ethers.byname" 1 "Successfully run ypmatch to find ethers.byname entry"
		fi
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
