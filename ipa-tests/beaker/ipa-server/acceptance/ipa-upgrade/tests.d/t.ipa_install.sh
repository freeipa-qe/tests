#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_install.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA 
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

install_all(){
	ipa_install_master_prep
	ipa_install_master_all
	#ipa_install_slave
	#ipa_install_client
}

install_nodns(){
	ipa_install_master_prep
	ipa_install_master_nodns
	#ipa_install_slave
	#ipa_install_client
}

ipa_install_master_prep(){
	rlPhaseStartTest "ipa_install_master_prep: Install software and pre-req configs for IPA"
		currenteth=$(route | grep ^default | awk '{print $8}')
		ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
		hostname=$(hostname)
		hostname_s=$(hostname -s)

		# Install base software
		rlRun "yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl"
		rlRun "yum -y install ipa-server"
		rlRun "yum -y update"

		# Set time
		rlRun "service ntpd stop"
		rlRun "service ntpdate start"

		# Fix /etc/hosts
		rlRun "cp -af /etc/hosts /etc/hosts.ipabackup"
		rlRun "sed -i /^$ipaddr/d /etc/hosts"
		rlRun "sed -i s/$hostname//g /etc/hosts"
		rlRun "sed -i s/$hostname_s//g /etc/hosts"
		rlRun "echo \"$ipaddr $hostname_s.$DOMAIN $hostname_s\" >> /etc/hosts"

		# Fix hostname
		rlRun "hostname $hostname_s.$DOMAIN"
		rlRun "cp /etc/sysconfig/network /etc/sysconfig/network.ipabackup"
		rlRun "sed -i \"/$hostname_s/d\" /etc/sysconfig/network"
		rlRun "echo \"HOSTNAME=$hostname_s.$DOMAIN\" >> /etc/sysconfig/network"
	rlPhaseEnd
}

ipa_install_master_all(){
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "template_function: template function start phase"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		# Configure IPA Server
		ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U

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

ipa_install_master_nodns(){
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "template_function: template function start phase"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		# Configure IPA Server
		ipa-server-install --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U

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
