#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa_uninstall.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA multihost uninstall scripts
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
uninstall()
{
	ipa_uninstall_client
	ipa_uninstall_slave
	ipa_uninstall_master
}

ipa_uninstall_master()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_uninstall_master: Uninstall IPA Master software"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlLog "backing up MASTER log files before uninstall"
		#logtar=/tmp/master.$(hostname -s).$(date +%Y%m%d-%H%M%S).tar.gz
		#rlRun "tar zcvf $logtar /var/log"
		#if [ -f $logtar ]; then
		#	rhts-submit-log -l $logtar
		#fi

		#submit_logs

		ipa_quick_uninstall

		[ -n $MASTER_IP ] && MASTER=$(dig +short -x $MASTER_IP|sed 's/\.$//g')

		#submit_log /var/log/ipaserver-uninstall.log
		#if [ -f /var/log/ipaserver-uninstall.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipaserver-uninstall.log /var/log/ipaserver-uninstall.log.$DATE
		#	rhts-submit-log -l /var/log/ipaserver-uninstall.log.$DATE
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
	if [ -f /tmp/ipa.master.is.2.2.0 ]; then
		rm /tmp/ipa.master.is.2.2.0
	fi
}

ipa_uninstall_slave()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_uninstall_slave: Uninstall IPA Replica/Slave Software"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $MASTER_IP"
		if [ "x$USEDNS" = "xyes" ]; then
			rlRun "ipa-replica-manage del $SLAVE_S.$DOMAIN -f"
		else
			rlRun "ipa-replica-manage del $SLAVE -f"
		fi
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $SLAVE_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $MASTER_IP"
		rlLog "backing up SLAVE log files before uninstall"
		#logtar=/tmp/replica.$(hostname -s).$(date +%Y%m%d-%H%M%S).tar.gz
		#rlRun "tar zcvf $logtar /var/log"
		#if [ -f $logtar ]; then
		#	rhts-submit-log -l $logtar
		#fi

		#submit_logs

		ipa_quick_uninstall
		[ -n $SLAVE_IP ] && SLAVE=$(dig +short -x $SLAVE_IP|sed 's/\.$//g')

		#submit_log /var/log/ipaserver-uninstall.log
		#if [ -f /var/log/ipaserver-uninstall.log ]; then
		#	DATE=$(date +%Y%m%d-%H%M%S)
		#	cp -f /var/log/ipaserver-uninstall.log /var/log/ipaserver-uninstall.log.$DATE
		#	rhts-submit-log -l /var/log/ipaserver-uninstall.log.$DATE
		#fi
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
	if [ -f /tmp/ipa.slave.is.2.2.0 ]; then
		rm /tmp/ipa.slave.is.2.2.0
	fi
}

ipa_uninstall_client()
{
	TESTORDER=$(( TESTORDER += 1 ))
	rlPhaseStartTest "ipa_uninstall_client: Uninstall IPA Client Software"
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is MASTER"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $CLIENT_IP"
		if [ "x$USEDNS" = "xyes" ]; then
			rlRun "ipa host-del $CLIENT_S.$DOMAIN" # --updatedns"
			if [ $(ipa dnsrecord-find $DOMAIN | grep $CLIENT_S|wc -l) -gt 0 ]; then
				rlRun "ipa dnsrecord-del $DOMAIN $CLIENT_S --del-all" 
			fi
		else
			[ -n $CLIENT_IP ] && CLIENT=$(dig +short -x $CLIENT_IP|sed 's/\.$//g')
			rlRun "ipa host-del $CLIENT"
		fi
			
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.2' -m $MASTER_IP"
		;;
	"SLAVE")
		rlLog "Machine in recipe is SLAVE"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.1' $CLIENT_IP"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	"CLIENT")
		rlLog "Machine in recipe is CLIENT"
		KinitAsAdmin
		kdestroy
		rlLog "backing up CLIENT log files before uninstall"
		#logtar=/tmp/client.$(hostname -s).$(date +%Y%m%d).tar.gz
		#rlRun "tar zcvf $logtar /var/log"
		#if [ -f $logtar ]; then
		#	rhts-submit-log -l $logtar
		#fi

		#submit_logs

		ipa_quick_uninstall

		#submit_log /var/log/ipaclient-uninstall.log

		rlRun "yum -y downgrade curl nss* openldap* libselinux* nspr* libcurl*"
		rlRun "yum -y remove http*"

		[ -n $CLIENT_IP ] && CLIENT=$(dig +short -x $CLIENT_IP|sed 's/\.$//g')
		rlRun "iparhts-sync-set -s '$FUNCNAME.$TESTORDER.1' -m $CLIENT_IP"
		rlRun "iparhts-sync-block -s '$FUNCNAME.$TESTORDER.2' $MASTER_IP"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
		;;
	esac
	rlPhaseEnd
}
