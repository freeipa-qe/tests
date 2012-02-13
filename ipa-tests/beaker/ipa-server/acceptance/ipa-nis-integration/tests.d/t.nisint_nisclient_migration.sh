#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_nisclient_migration.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration switch to IPA Client 
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
nisint_nisclient_migration()
{
	nisint_nisclient_migration_envsetup

}

nisint_nisclient_migration_envsetup()
{
	rlPhaseStartTest "nisint_nisclient_migration_envsetup: Install/configure IPA Client"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "ipa host-del $CLIENT --updatedns"
		rhts-sync-set -s "$FUNCTION.0" -m $MASTER
		rhts-sync-block -s "$FUNCTION.1" $CLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCTION.0" $MASTER
		rhts-sync-block -s "$FUNCTION.1" $CLIENT
		;;
	"$CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rhts-sync-block -s "$FUNCTION.0" $MASTER
		HOSTNAME_S=$(hostname -s)
		rlRun "yum -y install *ipa-admintools *ipa-client"
		rlRun "sed -i s/^$CLIENT_IP.*$HOSTNAME_S.*$// /etc/hosts"
		rlRun "echo '$CLIENT_IP $HOSTNAME_S.$DOMAIN $HOSTNAME_S' >> /etc/hosts"
		rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
		rlRun "echo 'nameserver $MASTER_IP' >> /etc/resolv.conf"
		rlRun "authconfig --disablenis --update"
		rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		rhts-sync-set -s "$FUNCTION.1" -m $CLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}
