#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.nisint_nisclient_integration.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration NIS Client Integration
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
nisint_nisclient_integration()
{
	rlLog "$FUNCNAME"

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		nisint_nisclient_integration_master_envsetup
		rlRun "rhts-sync-set -s 'nisint_nisclient_integration_start' -m $MASTER"
		rlRun "rhts-sync-block -s 'nisint_nisclient_integration_end' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s 'nisint_nisclient_integration_start' $MASTER"
		rlRun "rhts-sync-block -s 'nisint_nisclient_integration_end' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlRun "rhts-sync-block -s 'nisint_nisclient_integration_start' $MASTER"

		nisint_nisclient_integration_check_ipa_nis_data_remotely
		nisint_nisclient_integration_change_to_ipa_nismaster
		nisint_nisclient_integration_setup_kerberos_for_auth
		nisint_nisclient_integration_check_ipa_nis_data_locally

		rlRun "rhts-sync-set -s 'nisint_nisclient_integration_end' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac

}

nisint_nisclient_integration_master_envsetup()
{
	rlPhaseStartTest "nisint_nisclient_integration_master_envsetup: Run setup on MASTER to prep for Client Integration"
		rlLog "prep for Kerberos setup for auth on the client"
		NISCLIENT_S=$(echo $NISCLIENT|cut -f1 -d.)
		#NISCLIENT=$NISCLIENT_S.$DOMAIN
		TNISCLIENT=$NISCLIENT_S.$DOMAIN
		ptrzone=$(echo $NISCLIENT_IP|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		if [ $(ipa dnszone-show $ptrzone 2>/dev/null|wc -l) -eq 0 ]; then 
			rlRun "ipa dnszone-add $ptrzone --name-server=$MASTER --admin-email=ipaqar.redhat.com"
		fi
		if [ $(ipa host-show $TNISCLIENT 2>&1|grep -i "host not found"|wc -l) -gt 0 ]; then
			rlRun "ipa host-add $TNISCLIENT --ip-address=$NISCLIENT_IP"
		fi
		rlRun "ipa-getkeytab -s $MASTER -p host/$TNISCLIENT@$RELM -k /tmp/krb5.keytab.$TNISCLIENT"
		rlRun "scp -q -o StrictHostKeyChecking=no /tmp/krb5.keytab.$TNISCLIENT root@$TNISCLIENT:/etc/krb5.keytab"
	rlPhaseEnd
}

nisint_nisclient_integration_check_ipa_nis_data_remotely()
{
	rlPhaseStartTest "nisint_nisclient_integration_check_ipa_nis_data_remotely: Check that expected NIS maps are viewable"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypcat -k -d $DOMAIN -h $MASTER passwd"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER group"    
		rlRun "ypcat -k -d $DOMAIN -h $MASTER netgroup"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.master"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.home"
		rlRun "ypcat -k -d $DOMAIN -h $MASTER auto.nisint"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd 
}

nisint_nisclient_integration_change_to_ipa_nismaster()
{
	rlPhaseStartTest "nisint_nisclient_integration_change_to_ipa_nismaster: Switch NIS config to point to IPA Master"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		MASTER_S=$(echo $MASTER|cut -f1 -d.)
		MASTER=$MASTER_S.$DOMAIN
		rlRun "cp /etc/yp.conf /etc/yp.conf.orig.$NISDOMAIN"
		rlRun "sed -i 's/$NISDOMAIN/$DOMAIN/g' /etc/yp.conf"
		rlRun "sed -i 's/$NISMASTER/$MASTER/g' /etc/yp.conf"

		rlRun "cp /etc/sysconfig/network /etc/sysconfig/network.orig.$NISDOMAIN"
		rlRun "sed -i 's/$NISDOMAIN/$DOMAIN/g' /etc/sysconfig/network"

		rlRun "cp /etc/resolv.conf /etc/resolv.conf.orig.$NISDOMAIN"
		rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
		rlRun "echo 'nameserver $MASTER_IP' >> /etc/resolv.conf"

		rlRun "cp /etc/hosts /etc/hosts.orig.$NISDOMAIN"
		rlRun "sed -i s/^$NISCLIENT_IP.*$HOSTNAME_S.*$// /etc/hosts"
		rlRun "echo '$NISCLIENT_IP $HOSTNAME_S.$DOMAIN $HOSTNAME_S' >> /etc/hosts"

		rlRun "grep -v 'HOSTNAME=$HOSTNAME_S' /etc/sysconfig/network > /etc/sysconfig/network.$FUNCNAME"
		rlRun "echo 'HOSTNAME=$HOSTNAME_S.$DOMAIN' >> /etc/sysconfig/network.$FUNCNAME"
		rlRun "mv -f /etc/sysconfig/network.$FUNCNAME /etc/sysconfig/network"
		rlRun "hostname $HOSTNAME_S.$DOMAIN"

		rlRun "nisdomainname $DOMAIN"
		rlRun "service rpcbind restart"
		rlRun "service ypbind restart"
		rlRun "service nscd restart"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd

}

nisint_nisclient_integration_setup_kerberos_for_auth()
{
	rlPhaseStartTest "nisint_nisclient_integration_setup_kerberos_for_auth: Setup Kerberos for NIS Client"
		rlRun "yum -y install krb5-workstation pam_krb5" 0 "Install krb5-workstation pam_krb5"
		rlRun "service ntpd stop"
		rlRun "service ntpdate start"
		rlRun "service ntpd start"
		rlRun "chkconfig ntpd on"
		rlRun "touch /etc/krb5.keytab"
		rlRun "cp /etc/krb5.conf /etc/krb5.conf.orig.nisint"
		rlRun "sed -i \"s/kerberos.example.com/$MASTER/g\" /etc/krb5.conf"
		rlRun "sed -i \"s/EXAMPLE.COM/$RELM/g\" /etc/krb5.conf"
		rlRun "sed -i \"s/example.com/$DOMAIN/g\" /etc/krb5.conf"
		rlRun "authconfig --enablekrb5 --update"
		rlRun "KinitAsAdmin"
	rlPhaseEnd
}

nisint_nisclient_integration_undo_kerberos_setup()
{
	rlPhaseStartTest "nisint_nisclient_integration_undo_kerberos_setup: Undo Kerberos Setup to put server back"
		yum -y remove krb5-workstation
		mv /etc/krb5.conf.orig.nisint /etc/krb5.conf
		rlRun "authconfig --disablekrb5 --update"
		rm /etc/krb5.keytab
	rlPhaseEnd
}

nisint_nisclient_integration_check_ipa_nis_data_locally()
{
	rlPhaseStartTest "nisint_nisclient_integration_check_ipa_nis_data_locally: Check that expected NIS maps are viewable"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "ypwhich |grep $MASTER"
		rlRun "ypcat -k passwd"
		rlRun "ypcat -k group"    
		rlRun "ypcat -k netgroup"
		rlRun "ypcat -k auto.master"
		rlRun "ypcat -k auto.home"
		rlRun "ypcat -k auto.nisint"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd 
}

