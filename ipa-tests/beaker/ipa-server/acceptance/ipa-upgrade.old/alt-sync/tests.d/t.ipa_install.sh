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
		rlRun "yum -y install $PKG-admintools $PKG-client"
	else
		rlRun "yum -y install bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl"
		rlRun "yum -y install $PKG-server"
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
	if [ "x$USEDNS" = "xyes" ]; then
		rlRun "cp /etc/resolv.conf /etc/resolv.conf.ipabackup"
		if [ "$MYROLE" = "SLAVE" -o "$MYROLE" = "CLIENT" ]; then
			rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
			rlRun "echo \"nameserver $MASTER_IP\" >> /etc/resolv.conf"
			rlRun "echo \"nameserver $SLAVE_IP\" >> /etc/resolv.conf"
			rlRun "cat /etc/resolv.conf"
		fi
	fi

	# Disable iptables
	rlRun "service iptables stop"
	rlRun "service ip6tables stop"
}

ipa_install_master_all(){
	USEDNS="yes"
	TESTORDER=$(( TESTORDER += 1 ))
	DOMAIN=$(grep ^DOMAIN= /dev/shm/env.sh|cut -f2- -d=)
	rlPhaseStartTest "ipa_install_master_all: Install and configure IPA Master with all services"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		# Configure IPA Server
		ipa_install_prep
		rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

		#submit_log /var/log/ipaserver-install.log
		#if [ -f /var/log/ipaserver-install.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipaserver-install.log /var/log/ipaserver-install.log.$DATE
		#	rhts-submit-log -l /var/log/ipaserver-install.log.$DATE
		#fi

		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

ipa_install_master_nodns(){
	USEDNS="no"
	TESTORDER=$(( TESTORDER += 1 ))
	DOMAIN=$(dnsdomainname)
	rlPhaseStartTest "ipa_install_master_nodns: Install and configure IPA Master with no DNS service"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"

		# Configure IPA Server
		ipa_install_prep
		rlRun "ipa-server-install --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW --ip-address=$MASTER_IP -U"

		#submit_log /var/log/ipaserver-install.log
		#if [ -f /var/log/ipaserver-install.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipaserver-install.log /var/log/ipaserver-install.log.$DATE
		#	rhts-submit-log -l /var/log/ipaserver-install.log.$DATE
		#fi

		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

ipa_install_slave_all(){
	USEDNS="yes"
	TESTORDER=$(( TESTORDER += 1 ))
	DOMAIN=$(grep ^DOMAIN= /dev/shm/env.sh|cut -f2- -d=)
	rlPhaseStartTest "ipa_install_slave_all: Install and configure IPA Replica/Slave"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		if [ "x$USEDNS" = "xyes" ]; then
			rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE_IP $SLAVE_S.$DOMAIN"
		else
			rlRun "ipa-replica-prepare -p $ADMINPW $SLAVE"
		fi
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		if [ -f ~/.ssh/known_hosts ]; then
			rlRun "sed -i /$MASTER_S/d ~/.ssh/known_hosts"
			rlRun "sed -i /$MASTER_IP/d ~/.ssh/known_hosts"
		fi
		rlRun "AddToKnownHosts $MASTER"
		rlLog "pushd /dev/shm"
		pushd /dev/shm
		if [ "x$USEDNS" = "xyes" ]; then
			SLAVEFQDN=$SLAVE_S.$DOMAIN
		else
			SLAVEFQDN=$SLAVE
		fi
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$SLAVEFQDN.gpg"
		if [ -f /dev/shm/replica-info-$SLAVEFQDN.gpg ]; then
			ipa_install_prep
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$SLAVEFQDN.gpg"
		else
			rlFail "ERROR: Replica Package not found"
		fi

		#submit_log /var/log/ipareplica-install.log
		#if [ -f /var/log/ipareplica-install.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipareplica-install.log /var/log/ipareplica-install.log.$DATE
		#	rhts-submit-log -l /var/log/ipareplica-install.log.$DATE
		#fi
		rlLog "popd"
		popd	
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}

ipa_install_slave_nodns()
{
	USEDNS="no"
	TESTORDER=$(( TESTORDER += 1 ))
	DOMAIN=$(dnsdomainname)
	rlPhaseStartTest "ipa_install_slave_nodns: Install and configure IPA Replica/Slave"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		if [ "x$USEDNS" = "xyes" ]; then
			rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVE_IP $SLAVE_S.$DOMAIN"
		else
			rlRun "sed -i '/$SLAVE_S/d' /etc/hosts"
			rlRun "echo '$SLAVE_IP $SLAVE $SLAVE_S' >> /etc/hosts"
			rlRun "ipa-replica-prepare -p $ADMINPW $SLAVE"
		fi
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		if [ -f ~/.ssh/known_hosts ]; then
			rlRun "sed -i /$MASTER_S/d ~/.ssh/known_hosts"
			rlRun "sed -i /$MASTER_IP/d ~/.ssh/known_hosts"
		fi
		rlRun "AddToKnownHosts $MASTER"
		rlLog "pushd /dev/shm"
		pushd /dev/shm
		if [ "x$USEDNS" = "xyes" ]; then
			SLAVEFQDN=$SLAVE_S.$DOMAIN
		else
			SLAVEFQDN=$SLAVE
		fi
		rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$SLAVEFQDN.gpg"
		rlLog "Checking for existance of replica gpg file"
		if [ -f /dev/shm/replica-info-$SLAVEFQDN.gpg ]; then
			ipa_install_prep
			rlRun "ipa-replica-install -U -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$SLAVEFQDN.gpg"
		else
			rlFail "ERROR: Replica Package not found"
		fi

		#submit_log /var/log/ipareplica-install.log
		#if [ -f /var/log/ipareplica-install.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipareplica-install.log /var/log/ipareplica-install.log.$DATE
		#	rhts-submit-log -l /var/log/ipareplica-install.log.$DATE
		#fi
			
		rlLog popd
		popd
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $SLAVE_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE_IP"
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
		#commenting out debugging code
		#rlRun "cat /etc/hosts"
		#rlRun "nslookup $CLIENT"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $CLIENT_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER' $CLIENT_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		if [ "x$USEDNS" = "xyes" ]; then
			DOMAIN=$(grep ^DOMAIN= /dev/shm/env.sh|cut -f2- -d=)
		else
			DOMAIN=$(dnsdomainname)
		fi
		#commenting out debugging code
		#rlRun "cat /etc/hosts"
		#rlRun "nslookup $CLIENT_S.$DOMAIN"

		# Configure IPA CLIENT
		ipa_install_prep
		
		if [ "x$USEDNS" = "xyes" ]; then
			rlRun "echo \"$MASTER_IP $MASTER_S.$DOMAIN $MASTER_S\" >> /etc/hosts"
		fi

		if [ "x$USEDNS" = "xyes" ]; then
			rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER_S.$DOMAIN"
		else
			rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
		fi
			

		#submit_log /var/log/ipaclient-install.log
		#if [ -f /var/log/ipaclient-install.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipaclient-install.log /var/log/ipaclient-install.log.$DATE
		#	rhts-submit-log -l /var/log/ipaclient-install.log.$DATE
		#fi

		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER' -m $CLIENT_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
