#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_client_is_nis_bz_tests.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration Client NIS BZ tests
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
nisint_client_is_nis_bz_tests()
{
	echo '$FUNCNAME'
}

example_bz_788625()
{
	rlLog "This is just an EXAMPLE!!!"
	rlLog "This test is actually run from ipa-netgroup-cli"
	rlPhaseStartTest "netgroup_bz_788625: IPA nested netgroups not seen from ypcat"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ipa netgroup-add netgroup_bz_788625_test1 --desc=netgroup_bz_788625_test1"
		rlRun "ipa netgroup-add-member netgroup_bz_788625_test1 --users=admin"
		rlRun "ipa netgroup-add netgroup_bz_788625_test --desc=netgroup_bz_788625_test"
		rlRun "ipa netgroup-add-member netgroup_bz_788625_test --netgroups=netgroup_bz_788625_test1"
		if [ $(ypcat -d $DOMAIN -h localhost -k netgroup|grep "^netgroup_bz_788625_test $"|wc -l) -gt 0 ]; then
			rlFail "BZ 788625 found ...IPA nested netgroups not seen from ypcat"
		else
			rlPass "BZ 788625 not found"
		fi		
		rlRun "ipa netgroup-del netgroup_bz_788625_test1"
		rlRun "ipa netgroup-del netgroup_bz_788625_test"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $MASTER"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME' $MASTER"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME' $MASTER"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
