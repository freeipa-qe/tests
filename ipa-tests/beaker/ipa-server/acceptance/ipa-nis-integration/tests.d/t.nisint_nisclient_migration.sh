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
	nisint_nisclient_migration_ipa_client_install
	nisint_nisclient_migration_ipa_autofs_setup

}

nisint_nisclient_migration_envsetup()
{
	rlPhaseStartTest "nisint_nisclient_migration_envsetup: Prep for migration to IPA"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		TNISCLIENT=$(echo $NISCLIENT|cut -f1 -d.).$DOMAIN
		rlRun "ipa host-del $TNISCLIENT"
		rlRun "rhts-sync-set -s '$FUNCNAME.0' -m $MASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.1' $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.1' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.0' $MASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $MASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME.1' $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME.1' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rlLog "rhts-sync-block -s '$FUNCNAME.0' $MASTER"
		rlRun "rhts-sync-block -s '$FUNCNAME.0' $MASTER"
		HOSTNAME_S=$(hostname -s)
		MASTER_S=$(echo $MASTER|cut -f1 -d. )
		MASTER=$MASTER_S.$DOMAIN

		rlRun "yum -y install *ipa-admintools *ipa-client"

		rlRun "sed -i s/^$NISCLIENT_IP.*$HOSTNAME_S.*$// /etc/hosts"
		rlRun "echo '$NISCLIENT_IP $HOSTNAME_S.$DOMAIN $HOSTNAME_S' >> /etc/hosts"

		rlRun "sed -i s/^$MASTER_IP.*$MASTER_S.*$// /etc/hosts" 
		rlRun "echo '$MASTER_IP $MASTER_S.$DOMAIN $MASTER_S' >> /etc/hosts"
		rlRun "cat /etc/hosts"

		rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
		rlRun "echo 'nameserver $MASTER_IP' >> /etc/resolv.conf"
		rlRun "cat /etc/resolv.conf"

		rlRun "grep -v 'HOSTNAME=$HOSTNAME_S' /etc/sysconfig/network > /etc/sysconfig/network.$FUNCNAME"
		rlRun "echo 'HOSTNAME=$HOSTNAME_S.$DOMAIN' >> /etc/sysconfig/network.$FUNCNAME"
		rlRun "mv -f /etc/sysconfig/network.$FUNCNAME /etc/sysconfig/network"
		rlRun "hostname $HOSTNAME_S.$DOMAIN"
		rlRun "hostname"

		rlRun "authconfig --disablekrb5 --update"
		rlRun "authconfig --disablenis --update"
		rlRun "mv -f /etc/krb5.conf /etc/krb5.conf.nismig"
		rlRun "mv -f /etc/krb5.keytab /etc/krb5.keytab.nismig"
		rlRun "service ntpd stop"

		rlRun "rhts-sync-set -s '$FUNCNAME.1' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}

nisint_nisclient_migration_ipa_client_install()
{
	rlPhaseStartTest "nisint_nisclient_migration_ipa_client_install: Install/configure IPA Client"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		HOSTNAME_S=$(hostname -s)
		rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}

nisint_nisclient_migration_ipa_autofs_setup()
{
	rlPhaseStartTest "nisint_nisclient_migration_ipa_autofs_setup: Configure Autofs to use IPA"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		rlRun "rhts-sync-block -s '$FUNCNAME' $NISCLIENT"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		HOSTNAME_S=$(hostname -s)
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		cat > /etc/autofs_ldap_auth.conf <<-EOF
		<?xml version="1.0" ?>
		<!--
		This files contains a single entry with multiple attributes tied to it.
		See autofs_ldap_auth.conf(5) for more information.
		-->

		<autofs_ldap_sasl_conf
				usetls="no"
				tlsrequired="no"
				authrequired="yes"
				authtype="GSSAPI"
				clientprinc="host/$HOSTNAME_S.$DOMAIN@$RELM"
		/>
		EOF

        rlRun "cat /etc/autofs_ldap_auth.conf"

		cat > /etc/sysconfig/autofs <<-EOF
		TIMEOUT=60
		BROWSE_MODE="no"
		MOUNT_NFS_DEFAULT_PROTOCOL=4
		LOGGING="debug"
		LDAP_URI="ldap://$MASTER"
		SEARCH_BASE="cn=nis,cn=automount,$BASEDN"
		MAP_OBJECT_CLASS="automountMap"
		ENTRY_OBJECT_CLASS="automount"
		MAP_ATTRIBUTE="automountMapName"
		ENTRY_ATTRIBUTE="automountKey"
		VALUE_ATTRIBUTE="automountInformation"
		AUTH_CONF_FILE="/etc/autofs_ldap_auth.conf"
		EOF

		rlRun "sed -i 's/automount.*$/automount:  files ldap/' /etc/nsswitch.conf"
        rlRun "cat /etc/sysconfig/autofs"
		rlRun "service autofs restart"
		rlRun "rhts-sync-set -s '$FUNCNAME' -m $NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}
