#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.upgrade.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA multihost upgrade script
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
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
upgrade_master()
{
	local repoi=0
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "upgrade_master: upgrade ipa master"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "rpm -q ipa-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"

		# Setup new yum repos from ipa-upgrade.data datafile
		for url in ${repo[@]}; do
			repoi=$(( repoi += 1 ))
			cat > /etc/yum.repos.d/mytestrepo$repoi.repo <<-EOF
			[mytestrepo$repoi]
			name=mytestrepo$repoi
			baseurl=$url
			enabled=1
			gpgcheck=0
			skip_if_unavailable=1
			EOF
		done

		rlRun "yum clean all"
		rlRun "yum -y update 'ipa*'"	
		#rlRun "ipactl restart" ### IS THIS REALLY NEEDED?  BZ 766687?
		rlRun "rpm -q ipa-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"
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

upgrade_slave()
{
	local repoi=0
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "upgrade_slave: upgade ipa slave"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rpm -q ipa-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"

		# Setup new yum repos from ipa-upgrade.data datafile
		for url in ${repo[@]}; do
			repoi=$(( repoi += 1 ))
			cat > /etc/yum.repos.d/mytestrepo$repoi.repo <<-EOF
			[mytestrepo$repoi]
			name=mytestrepo$repoi
			baseurl=$url
			enabled=1
			gpgcheck=0
			skip_if_unavailable=1
			EOF
		done

		rlRun "yum clean all"
		rlRun "yum -y update 'ipa*'"	
		#rlRun "ipactl restart" ### IS THIS REALLY NEEDED?  BZ 766687?
		rlRun "rpm -q ipa-server 389-ds-base bind bind-dyndb-ldap pki-common sssd"
		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $SLAVE_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $SLAVE_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

upgrade_client()
{
	local repoi=0
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "upgrade_client: upgrade ipa client"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $CLIENT_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.$TESTORDER' $CLIENT_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"

		rlRun "rpm -q ipa-client sssd"

		# Setup new yum repos from ipa-upgrade.data datafile
		for url in ${repo[@]}; do
			repoi=$(( repoi += 1 ))
			cat > /etc/yum.repos.d/mytestrepo$repoi.repo <<-EOF
			[mytestrepo$repoi]
			name=mytestrepo$repoi
			baseurl=$url
			enabled=1
			gpgcheck=0
			skip_if_unavailable=1
			EOF
		done

		rlRun "yum clean all"
		rlRun "yum -y update 'ipa*'"	
		#rlRun "ipactl restart" ### IS THIS REALLY NEEDED?  BZ 766687?
		rlRun "rpm -q ipa-client sssd"

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $CLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
