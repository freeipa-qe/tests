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
	echo "$FUNCNAME"
}

nisint_bz_766320()
{
	rlPhaseStartTest "nisint_bz_766320: Hang possible in schema compat when calling in a transaction"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		KinitAsAdmin
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		OLDNSSLAPDPLUGINTYPE=$(ldapsearch -xLLL -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=MemberOf Plugin,cn=plugins,cn=config" |grep -i nsslapd-plugintype)

		rlLog "Changing nsslapd plugin type setting to betxnpostoperation to try to reproduce hang"
cat > /tmp/bz766320_hang.ldif <<-EOF
dn: cn=MemberOf Plugin,cn=plugins,cn=config
changetype: modify
replace: nsslapd-plugintype
nsslapd-plugintype: betxnpostoperation
EOF
		rlRun "ldapmodify -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f /tmp/bz766320_hang.ldif"

		rlLog "If job/test hangs after group-add-member, then you have hit BZ 766320"
		rlRun "ipa group-add-member --users=admin editors"

		if [ $(ipa group-show editors --raw|grep "uid=admin,cn=users,cn=accounts,$BASEDN"|wc -l) -gt 0 ]; then
			rlRun "ipa group-show editors --raw"
			rlRun "ipactl status"
			rlPass "BZ 766320 not found.  apparently the ipa command didnt hang"
		fi

		rlLog "Returning plugintype setting back to original"
cat > /tmp/bz766320_fix.ldif <<-EOF
dn: cn=MemberOf Plugin,cn=plugins,cn=config
changetype: modify
replace: nsslapd-plugintype
$OLDNSSLAPDPLUGINTYPE
EOF
		rlRun "ldapmodify -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f /tmp/bz766320_fix.ldif"
		
		rlRun "ipa group-remove-member --users=admin editors"
		

		[ -f $tmpout ] && rm -f $tmpout
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $MASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
		
example_bz_788625()
{
	rlLog "This is just an EXAMPLE!!!"
	rlLog "This test is actually run from ipa-netgroup-cli"
	rlPhaseStartTest "netgroup_bz_788625: IPA nested netgroups not seen from ypcat"
	case "$MYROLE" in
	"MASTER")
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
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $MASTER_IP"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd
}
