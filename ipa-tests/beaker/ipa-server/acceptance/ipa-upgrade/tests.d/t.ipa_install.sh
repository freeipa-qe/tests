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
	ipa_install_master_all
	ipa_install_slave_all
	ipa_install_client
}

install_nodns(){
	ipa_install_master_nodns
	ipa_install_slave_nodns
	ipa_install_client
}

ipa_install_prep(){
	currenteth=$(route | grep ^default | awk '{print $8}')
	ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
	hostname=$(hostname)
	hostname_s=$(hostname -s)

	# Install base software
	if [ "$MYROLE" = "CLIENT" ]; then
		rlRun "yum -y install nscd httpd curl mod_nss mod_auth_kerb 389-ds-base expect ntpdate"
		rlRun "yum -y install ipa-admintools ipa-client"
	else
		rlRun "yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl"
		rlRun "yum -y install ipa-server"
	fi
	
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
	rlRun "cp /etc/sysconfig/network /etc/sysconfig/network-ipabackup"
	rlRun "sed -i \"/$hostname_s/d\" /etc/sysconfig/network"
	rlRun "echo \"HOSTNAME=$hostname_s.$DOMAIN\" >> /etc/sysconfig/network"
	
	# Fix role var hostname
	[ "$MYROLE" = "MASTER" ] && MASTER=$(hostname)
	[ "$MYROLE" = "SLAVE"  ] && SLAVE=$(hostname)
	[ "$MYROLE" = "CLIENT" ] && CLIENT=$(hostname)

	# Backup resolv.conf
	rlRun "cp /etc/resolv.conf /etc/resolv.conf.ipabackup"
	if [ "$MYROLE" = "SLAVE" -o "$MYROLE" = "CLIENT" ]; then
		rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
		rlRun "echo \"nameserver $MASTER_IP\" >> /etc/resolv.conf"
		rlRun "echo \"nameserver $SLAVE_IP\" >> /etc/resolv.conf"
		rlRun "cat /etc/resolv.conf"
	fi

	# Disable iptables
	rlRun "service iptables stop"
	rlRun "service ip6tables stop"
}

ipa_install_master_all(){
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_master_all: Install and configure IPA Master with all services"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		# Configure IPA Server
		ipa_install_prep
		rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

		if [ -f /var/log/ipaserver-install.log ]; then
			DATE=$(date +%Y%m%d-%H%M%S)
			cp -f /var/log/ipaserver-install.log /var/log/ipaserver-install.log.$DATE
			rhts-submit-log -l /var/log/ipaserver-install.log.$DATE
		fi

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
	rlPhaseStartTest "ipa_install_master_nodns: Install and configure IPA Master with no DNS service"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		# Configure IPA Server
		ipa_install_prep
		rlRun "ipa-server-install --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

		if [ -f /var/log/ipaserver-install.log ]; then
			DATE=$(date +%Y%m%d-%H%M%S)
			cp -f /var/log/ipaserver-install.log /var/log/ipaserver-install.log.$DATE
			rhts-submit-log -l /var/log/ipaserver-install.log.$DATE
		fi

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

ipa_install_slave_all(){
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_slave_all: Install and configure IPA Replica/Slave"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE_IP $SLAVE_S.$DOMAIN"
		rlRun "rhts-sync-set -s '$FUNCNAME.1.$TESTORDER' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $SLAVE_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		rlRun "AddToKnownHosts $MASTER"
		rlLog "pushd /dev/shm"
		pushd /dev/shm
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$SLAVE_S.$DOMAIN.gpg"
		if [ -f /dev/shm/replica-info-$SLAVE_S.$DOMAIN.gpg ]; then
			ipa_install_prep
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$SLAVE_S.$DOMAIN.gpg"
		else
			rlFail "ERROR: Replica Package not found"
		fi

		if [ -f /var/log/ipareplica-install.log ]; then
			DATE=$(date +%Y%m%d-%H%M%S)
			cp -f /var/log/ipareplica-install.log /var/log/ipareplica-install.log.$DATE
			rhts-submit-log -l /var/log/ipareplica-install.log.$DATE
		fi
		rlLog "popd"
		popd	
		rlRun "rhts-sync-set -s '$FUNCNAME.2.$TESTORDER' -m $SLAVE_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $SLAVE_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

ipa_install_slave_nodns(){
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_slave_nodns: Install and configure IPA Replica/Slave"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE_IP $SLAVE_S.$DOMAIN"
		rlRun "rhts-sync-set -s '$FUNCNAME.1.$TESTORDER' -m $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $SLAVE_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		rlRun "AddToKnownHosts $MASTER"
		rlLog "pushd /dev/shm"
		pushd /dev/shm
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$SLAVE_S.$DOMAIN.gpg"
		rlLog "Checking for existance of replica gpg file"
		if [ -f /dev/shm/replica-info-$SLAVE_S.$DOMAIN.gpg ]; then
			ipa_install_prep
			rlRun "ipa-replica-install -U -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$SLAVE_S.$DOMAIN.gpg"
		else
			rlFail "ERROR: Replica Package not found"
		fi

		if [ -f /var/log/ipareplica-install.log ]; then
			DATE=$(date +%Y%m%d-%H%M%S)
			cp -f /var/log/ipareplica-install.log /var/log/ipareplica-install.log.$DATE
			rhts-submit-log -l /var/log/ipareplica-install.log.$DATE
		fi
			
		rlLog popd
		popd
		rlRun "rhts-sync-set -s '$FUNCNAME.2.$TESTORDER' -m $SLAVE_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.1.$TESTORDER' $MASTER_IP"
		rlRun "rhts-sync-block -s '$FUNCNAME.2.$TESTORDER' $SLAVE_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

ipa_install_client(){
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_install_client: Install IPA client"
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

		# Configure IPA CLIENT
		ipa_install_prep
		rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER_S.$DOMAIN"

		if [ -f /var/log/ipaclient-install.log ]; then
			DATE=$(date +%Y%m%d-%H%M%S)
			cp -f /var/log/ipaclient-install.log /var/log/ipaclient-install.log.$DATE
			rhts-submit-log -l /var/log/ipaclient-install.log.$DATE
		fi

		rlRun "rhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $CLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
