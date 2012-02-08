#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_nisclient_integration.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration NIS Client Integration
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
nisint_nisclient_integration()
{
	rlLog "$FUNCNAME"

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-block -s "nisint_nisclient_integration_end" $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s "nisint_nisclient_integration_end" $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"

		nisint_nisclient_integration_check_ipa_nis_data_remotely
		nisint_nisclient_integration_change_to_ipa_nismaster
		nisint_nisclient_integration_check_ipa_nis_data_locally

		rlRun "rhts-sync-set -s "nisint_nisclient_integration_end" -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac

}

nisint_nisclient_integration_check_ipa_nis_data_remotely()
{
	rlPhaseStartTest "nisint_nisclient_integration_check_ipa_nis_data_remotely: Check that expected NIS maps are viewable"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat -k -d $DOMAIN -h $MASTER passwd"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER group"    
		rlRun "ypcat -k -d $DOMAIN -h $MASTER netgroup"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.master"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.home"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.nisint"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd 
}

nisint_nisclient_integration_change_to_ipa_nismaster()
{
	rlPhaseStartTest "nisint_nisclient_integration_change_to_ipa_nismaster: Switch NIS config to point to IPA Master"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "cp /etc/yp.conf /etc/yp.conf.orig.$NISDOMAIN"
		rlRun "sed -i 's/$NISDOMAIN/$DOMAIN/g' /etc/yp.conf"
		rlRun "sed -i 's/$NISMASTER/$MASTER/g' /etc/yp.conf"
		rlRun "cp /etc/sysconfig/network /etc/sysconfig/network.orig.$NISDOMAIN"
		rlRun "sed -i 's/$NISDOMAIN/$DOMAIN/g' /etc/sysconfig/network"
		rlRun "service ypbind restart"
		rlRun "service nscd restart"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd

}

nisint_nisclient_integration_check_ipa_nis_data_locally()
{
	rlPhaseStartTest "nisint_nisclient_integration_check_ipa_nis_data_locally: Check that expected NIS maps are viewable"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypwhich |grep $MASTER"
		rlRun "ypcat -k passwd"
		rlRun "ypcat -k group"    
		rlRun "ypcat -k netgroup"
		rlRun "ypcat -k auto.master"
		rlRun "ypcat -k auto.home"
		rlRun "ypcat -k auto.nisint"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd 
}

