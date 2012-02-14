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
	nisint_nisclient_migration_autofs_setup

}

nisint_nisclient_migration_envsetup()
{
	rlPhaseStartTest "nisint_nisclient_migration_envsetup: Prep for migration to IPA"
	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlRun "ipa host-del $NISCLIENT"
		rhts-sync-set -s "$FUNCTION.0" -m $MASTER
		rhts-sync-block -s "$FUNCTION.1" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCTION.0" $MASTER
		rhts-sync-block -s "$FUNCTION.1" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		rhts-sync-block -s "$FUNCTION.0" $MASTER
		HOSTNAME_S=$(hostname -s)
		rlRun "yum -y install *ipa-admintools *ipa-client"
		rlRun "sed -i s/^$NISCLIENT_IP.*$HOSTNAME_S.*$// /etc/hosts"
		rlRun "echo '$NISCLIENT_IP $HOSTNAME_S.$DOMAIN $HOSTNAME_S' >> /etc/hosts"
		rlRun "sed -i s/^nameserver/#nameserver/g /etc/resolv.conf"
		rlRun "echo 'nameserver $MASTER_IP' >> /etc/resolv.conf"
		rlRun "authconfig --disablekrb5 --update"
		rlRun "authconfig --disablenis --update"
		rlRun "mv -f /etc/krb5.conf /etc/krb5.conf.nismig"
		rlRun "mv -f /etc/krb5.keytab /etc/krb5.keytab.nismig"
		rlRun "service ntpd stop"
		rhts-sync-set -s "$FUNCTION.1" -m $NISCLIENT
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
		rhts-sync-block -s "$FUNCTION" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCTION" $NISCLIENT
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		HOSTNAME_S=$(hostname -s)
		rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		rhts-sync-set -s "$FUNCTION" -m $NISCLIENT
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
		rhts-sync-block -s "$FUNCTION" $NISCLIENT
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rhts-sync-block -s "$FUNCTION" $NISCLIENT
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
				clientprinc="host/$NISCLIENT@$RELM"
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
		rhts-sync-set -s "$FUNCTION" -m $NISCLIENT
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}
