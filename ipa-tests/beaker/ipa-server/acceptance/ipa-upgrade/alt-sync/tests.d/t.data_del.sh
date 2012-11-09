#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.data_del.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA Upgade delete test data script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
# user
# group
# dns record
# host
# 
# hostgroup
# netgroup
# automount
# 
# automember
# selfservice
# delegation
# privilege
# permission
# 
# sudo
# hbac
# service
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
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
data_del()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "upgrade_data_del: delete the test data to cleanup"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		KinitAsAdmin
		
		# delete  automount
		rlRun "ipa automountlocation-del testloc"

		# delete  netgroups
		rlRun "ipa netgroup-del ${netgroup[1]}"
		rlRun "ipa netgroup-del ${netgroup[2]}"
		
		# check  hostgroups
		rlRun "ipa hostgroup-del ${hostgroup[1]}"
		rlRun "ipa hostgroup-del ${hostgroup[2]}"

		# check  hosts
		rlRun "ipa host-del ${host[1]} --updatedns"
		rlRun "ipa host-del ${host[2]} --updatedns"

		# check  DNS Records (PTR)
		rlRun "ipa dnszone-del ${dnsptr[1]}"
		rlRun "ipa dnszone-del ${dnsptr[2]}"

		# check  groups
		rlRun "ipa group-del ${group[1]}"
		rlRun "ipa group-del ${group[2]}"

		# check  users
		rlRun "ipa user-del ${user[1]}" 
		rlRun "ipa user-del ${user[2]}" 

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
