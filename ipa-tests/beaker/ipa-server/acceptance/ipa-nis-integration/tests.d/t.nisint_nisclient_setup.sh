#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   template.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration TEMPLATE_SCRIPT
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
nisint_nisclient_setup()
{
	rlLog "$FUNCNAME"

	rlPhaseStartTest "nisint_nisclient_setup: "
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT"
		rlRun "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT"
		rlPass "$FUNCNAME complete for IPAMASTER ($HOSTNAME)"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT"
		rlRun "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"

		nisint_nisclient_envsetup

		rlRun "rhts-sync-set   -s 'nisint_nisclient_setup_ended' -m $NISCLIENT"
		rlPass "$FUNCNAME complete for NISCLIENT ($HOSTNAME)"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}

nisint_nisclient_envsetup()
{
	rlPhaseStartTest "nisint_nisclient_envsetup: "
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "setup-nis-client" 0 "Running NIS Client setup"
		rlRun "ps -ef|grep [y]pbind" 0 "Check that NIS Client (ypbind) is running"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}
