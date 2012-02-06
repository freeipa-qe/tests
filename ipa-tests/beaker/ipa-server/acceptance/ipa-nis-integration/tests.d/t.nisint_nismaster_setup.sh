#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   template.sh of /CoreOS/ipa-tests/acceptance/ipa-nis-integration
#   Description: IPA NIS Integration and Migration TEMPLATE_SCRIPT
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
nisint_nismaster_setup()
{
	rlLog "$FUNCNAME"

	case "$HOSTNAME" in
	"$MASTER")
		rlLog "Machine in recipe is IPAMASTER ($HOSTNAME)"
		rlRun "rhts-sync-set   -s 'nisint_nismaster_setup_start' -m $MASTER"
		rlRun "rhts-sync-block -s 'nisint_nismaster_setup_ended' $NISMASTER"
		rlPass "$FUNCNAME complete for IPAMASTER ($HOSTNAME)"
		;;
	"$NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlRun "rhts-sync-block -s 'nisint_nismaster_setup_start' $MASTER"

		nisint_nismaster_envsetup
		nisint_nismaster_setup_netgroups
		nisint_nismaster_setup_services
		nisint_nismaster_setup_automountmaps
		nisint_nismaster_setup_nfs_exports
		nisint_nismaster_setup_users
		nisint_nismaster_setup_groups
		nisint_nismaster_setup_hosts

		rlRun "rhts-sync-set   -s 'nisint_nismaster_setup_ended' $NISMASTER"
		rlPass "$FUNCNAME complete for NISMASTER ($HOSTNAME)"
		;;
	"$NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac

}

nisint_nismaster_envsetup()
{
	rlPhaseStartTest "nisint_nismaster_envsetup: "
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "setup-nis-server > $tmpout 2>&1" 0 "Running NIS Master Server setup"
		rlRun "ps -ef|grep [y]pserv" 0 "Check that NIS Server (ypserv) is running"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_netgroups()
{
	rlPhaseStartTest "nisint_nismaster_setup_netgroups: Adding Netgroups to NIS map for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		cat <<-EOF >> /etc/netgroup
		nisint_goodusers nisint_goodusers1 nisint_goodusers2 nisint_goodusers3 nisint_goodusers4
		nisint_goodusers1 (,goodusers1,)
		nisint_goodusers2 (,goodusers2,$NISDOMAIN)
		nisint_goodusers3 (-,goodusers3,)
		nisint_goodusers4 (-,goodusers4,$NISDOMAIN)
		
		nisint_nisbadusers ng_nisbadusers1 ng_nisbadusers2 ng_nisbadusers3 ng_nisbadusers4
		nisint_nisbadusers1 (,nisbadusers1,)
		nisint_nisbadusers2 (,nisbadusers2,$NISDOMAIN)
		nisint_nisbadusers3 (-,nisbadusers3,)
		nisint_nisbadusers4 (-,nisbadusers4,$NISDOMAIN)
		
		nisint_evilservers (cracker1,,) (cracker1.cracker.org,,) (cracker2,,) (cracker2.cracker.org,,)
		EOF
	
		GOODSERVERNG="nisint_goodservers"
		for server in $MASTER $NISMASTER $NISCLIENT; do
			GOODSERVERNG="$GOODSERVERNG ($server,,)"
		done
		cat <<-EOF >> /etc/netgroup
		$GOODSERVERNG
		EOF
		
		rlRun "make -C /var/yp" 0 "updating NIS netgroup map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER netgroup|grep nisint_" 0 "Check that new netgroups are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_services()
{
	rlPhaseStartTest "nisint_nismaster_setup_services: Adding Services to NIS map for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		cat <<-EOF >> /etc/services
		nisint_ftp	490021/tcp
		nisint_ftp	490021/udp
		nisint_ssh	490022/tcp
		nisint_ssh	490022/udp
		nisint_web	490080/tcp
		nisint_web	490080/udp
		EOF
	
		rlRun "make -C /var/yp" 0 "updating NIS services map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER services|grep nisint_" 0 "Check that new services are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_automountmaps()
{
	rlPhaseStartTest "nisint_nismaster_setup_automountmaps: Adding Automount maps to NIS for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		cat <<-EOF >> /etc/auto.master
		/nisint +auto.nisint
		EOF
	
		cat <<-EOF >> /etc/auto.nisint
		app1 -rw,rsize=65536,wsize=65536,hard,intr,actimeo=3600,timeo=3600 $NISMASTER:/nisint/app1
		app2 -rw,rsize=65536,wsize=65536,hard,intr,actimeo=3600,timeo=3600 $NISMASTER:/nisint/app2
		EOF

		sed -i 's!^\(AUTO_LOCAL  = .*\)$!\1\nAUTO_NISINT   = \$(YPSRCDIR)/auto.nisint!' /var/yp/Makefile
		sed -i 's!^\(all: .*\) mail \\$!\1 auto.nisint mail \\!' /var/yp/Makefile
		echo >> /var/yp/Makefile
		echo -e "auto.nisint: \$(AUTO_NISINT) \$(YPDIR)/Makefile" >> /var/yp/Makefile
		echo -e "\t@echo \"Updating \$@...\"" >> /var/yp/Makefile
		echo -e "\t-@sed -e "/^#/d" -e s/#.*\$\$// \$(AUTO_NISINT) | \$(DBLOAD) \\" >> /var/yp/Makefile
		echo -e "\t\t-i \$(AUTO_NISINT) -o \$(YPMAPDIR)/\$@ - \$@" >> /var/yp/Makefile
		echo -e "\t-@\$(NOPUSH) || \$(YPPUSH) -d \$(DOMAIN) \$@"  >> /var/yp/Makefile

		rlRun "make -C /var/yp" 0 "updating NIS services map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER services|grep nisint_" 0 "Check that new services are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_nfs_exports()
{
	rlPhaseStartTest "nisint_nismaster_setup_nfs_exports: Setting up NFS exports for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out

		rlRun "mkdir -p /nisint/app{1,2}" 0 "Create NFS export directories"	
		cat <<-EOF >> /etc/exports
		/nisint/app1 @nisint_goodservers(rw,no_root_squash)
		/nisint/app2 @nisint_evilservers(ro)
		EOF
	
		rlRun "setsebool -P nfs_export_all_rw 1" 0 "set nfs_export_all_rw Boolean for SELinux"
		rlRun "setsebool -P nfs_export_all_ro 1" 0 "set nfs_export_all_ro Boolean for SELinux"
		rlRun "service rpcbind restart" 0 "restart rpcbind (new portmap) service"
		rlRun "service nfs restart" 0 "restart nfs services"
		rlRun "service nfslock restart" 0 "restart nfslock service"
		rlRun "exportfs -av" 0 "Export /nisint dirs for NIS Integration testing"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER services|grep nisint_" 0 "Check that new services are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_users()
{
	rlPhaseStartTest "nisint_nismaster_setup_users: Setting up NIS Users for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		useradd --password aiqlepdb gooduser1
		useradd --password aiqlepdb gooduser2
		useradd --password aiqlepdb gooduser3
		useradd --password aiqlepdb gooduser4
		rlRun "make -C /var/yp" 0 "Update NIS passwd/shadow maps"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER passwd|grep gooduser" 0 "Check that new users are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_groups()
{
	rlPhaseStartTest "nisint_nismaster_setup_groups: Setting up NIS Groups for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		groupadd goodgroup1
		groupadd goodgroup2
		groupadd goodgroup3
		groupadd goodgroup4
		rlRun "make -C /var/yp" 0 "Update NIS group map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER group|grep goodgroup" 0 "Check that new groups are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}

nisint_nismaster_setup_hosts()
{
	rlPhaseStartTest "nisint_nismaster_setup_hosts: Setting up NIS Hosts for Integration testing"
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		cat <<-EOF >> /etc/hosts
		192.168.4.1	goodhost1
		192.168.4.2	goodhost2
		192.168.4.3	goodhost3
		192.168.4.4	goodhost4
		EOF
		rlRun "make -C /var/yp" 0 "Update NIS hosts map"
		rlRun "ypcat -d $NISDOMAIN -h $NISMASTER group|grep goodhost" 0 "Check that new hosts are in the map"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}


