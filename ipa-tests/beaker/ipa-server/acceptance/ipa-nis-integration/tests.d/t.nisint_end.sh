#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_end.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration End script to release 
#   servers.
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
nisint_end()
{
	rlLog "$FUNCNAME"

	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "rhts-sync-set -s 'nisint_end_nisclient' -m $MASTER_IP"
		rlRun "rhts-sync-set -s 'nisint_end_nismaster' -m $MASTER_IP"
		rlLog "rhts-sync-block -s 'nisint_end' $NISMASTER_IP $NISCLIENT_IP"
		rlRun "rhts-sync-block -s 'nisint_end' $NISMASTER_IP $NISCLIENT_IP"
		rlLog "Ending IPA MASTER tests."
		rlLog "Ending NIS Integration and Migration tests."
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s 'nisint_end_nisserver' $MASTER_IP"
		rlRun "rhts-sync-block -s 'nisint_end_nisserver' $MASTER_IP"
		rlLog "Ending NISMASTER tests."
		rlRun "rhts-sync-set -s 'nisint_end' -m $NISMASTER_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s 'nisint_end_nisclient' $MASTER_IP"
		rlRun "rhts-sync-block -s 'nisint_end_nisclient' $MASTER_IP"
		rlLog "Ending NISCLIENT tests."
		rlRun "rhts-sync-set -s 'nisint_end' -m $NISCLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac

}
