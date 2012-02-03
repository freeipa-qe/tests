#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_ipamaster.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration IPA Master acceptance tests
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
nisint_ipamaster()
{
	##################################################################
	# nismaster_setup: signal NISMASTER Setup
	##################################################################
	rhts-sync-set -s "nismaster_setup_start" -m $MASTER
	rhts-sync-block -s "nismaster_setup_end" $NISMASTER
	
	##################################################################
	# nisclient_setup: signal NISCLIENT Setup
	##################################################################
	rhts-sync-set -s "nisclient_setup_start" -m $MASTER
	rhts-sync-block -s "nisclient_setup_end" $NISCLIENT

	##################################################################
	# ipamaster_nisintegration: Run IPAMASTER NIS Integration Tests
	##################################################################
	nisint_ipamaster_envsetup
	nisint_ipamaster_add
	nisint_ipamaster_del
	nisint_ipamaster_add_ldif
	nisint_ipamaster_setup_nis_listener
	nisint_ipamaster_check_ipa_nis

	##################################################################
	# nisclient_nisintegration: signal NISCLIENT NIS Integration tests
	##################################################################
	rhts-sync-set -s "nisclient_nisintegration_start" -m $MASTER
	rhts-sync-block -s "nisclient_nisintegration_end" $NISCLIENT

	##################################################################
	# ipamaster_bzs: Run IPAMASTER related BZ checks
	##################################################################
	nisint_ipamaster_netgroup_bzs
	nisint_ipamaster_automount_bzs
	nisint_ipamaster_service_bzs
	nisint_ipamaster_other_bzs

	##################################################################
	# nisclient_bzs: signal NISCLIENT related BZ checks
	##################################################################
	rhts-sync-set -s "nisclient_bzs_start" -m $MASTER
	rhts-sync-block -s "nisclient_bzs_end" $NISCLIENT

	##################################################################
	# nisclient_migration: signal NISCLIENT Migration tests
	##################################################################
	rhts-sync-set -s "nisclient_migration_start" -m $MASTER
	rhts-sync-block -s "nisclient_migration_end" $NISCLIENT

	##################################################################
	# nismaster_bzs: signal NISMASTER related BZ checks
	##################################################################
	rhts-sync-set -s "nismaster_bzs_start" -m $MASTER
	rhts-sync-block -s "nismaster_bzs_end" $NISMASTER

	nisint_nisclient_envcleanup
}
