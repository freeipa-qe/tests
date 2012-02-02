#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_nisclient.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration NIS Client acceptance tests
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
nisint_nisclient()
{
	##################################################################
	# nisclient_setup: run NISCLIENT Setup
	##################################################################
	rhts-sync-block -s "nisclient_setup_start" $BEAKERMASTER
	nisint_nisclient_envsetup
	nisint_nisclient_check_nis_master
	rhts-sync-set -s "nisclient_setup_end" -m $BEAKERNISCLIENT

	##################################################################
	# nisclient_nisintegration: run NISCLIENT NIS Integration tests
	##################################################################
	rhts-sync-block -s "DONE_ipamaster_nisintegration" $BEAKERMASTER
	nisint_nisclient_check_ipa_nis 
	nisint_nisclient_change_to_ipa_nismaster 
	nisint_nisclient_check_ipa_nis 
	nisint_nisclient_netgroup_use_tests
	nisint_nisclient_automount_use_tests
	nisint_nisclient_services_use_tests
	rhts-sync-set -s "DONE_nisclient_nisintegration" -m $BEAKERNISCLIENT

	##################################################################
	# nisclient_bzs: run NISCLIENT related BZ checks
	##################################################################
	rhts-sync-block -s "nisclient_bzs_start" $BEAKERMASTER
	nisint_nisclient_netgroup_bzs
	nisint_nisclient_automount_bzs
	nisint_nisclient_services_bzs
	nisint_nisclient_other_bzs
	rhts-sync-set -s "nisclient_bzs_end" -m $BEAKERNISCLIENT

	##################################################################
	# nisclient_migration: run NISCLIENT Migration tests
	##################################################################
	rhts-sync-block -s "nisclient_migration_start" $BEAKERMASTER
	nisint_nisclient_migrate_to_ipa
	nisint_nisclient_envcleanup
	rhts-sync-set -s "nisclient_migration_end" -m $BEAKERNISCLIENT
}
