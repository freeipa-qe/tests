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
nisint_nisclient_setup()
{
	rlLog "$FUNCNAME"

	rlPhaseStartTest "nisint_nisclient_setup: "
	case "$MYROLE" in
	"MASTER")
		rlLog "Machine in recipe is IPAMASTER"
		rlLog "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT_IP"
		rlPass "$FUNCNAME complete for IPAMASTER ($HOSTNAME)"
		;;
	"NISMASTER")
		rlLog "Machine in recipe is NISMASTER"
		rlLog "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT_IP"
		rlRun "rhts-sync-block -s 'nisint_nisclient_setup_ended' $NISCLIENT_IP"
		;;
	"NISCLIENT")
		rlLog "Machine in recipe is NISCLIENT"

		#rlRun "yum -y remove *ipa-client *ipa-admintools"
		rlRun "yum -y install openldap-clients ntp ntpdate"
		nisint_nisclient_envsetup

		rlRun "rhts-sync-set   -s 'nisint_nisclient_setup_ended' -m $NISCLIENT_IP"
		rlPass "$FUNCNAME complete for NISCLIENT ($HOSTNAME)"
		;;
	*)
		rlLog "Machine in recipe is not a known ROLE"
		;;
	esac
	rlPhaseEnd

}

nisint_nisclient_envsetup()
{
	rlPhaseStartTest "nisint_nisclient_envsetup: "
		local tmpout=$TmpDir/$FUNCNAME.$RANDOM.out
		rlRun "setup-nis-client" 0 "Running NIS Client setup"
		#rlRun "service iptables stop" 0,1 "Disabling iptables"
		if [ $(cat /etc/redhat-release|grep "5\.[0-9]"|wc -l) -gt 0 ]; then
			service iptables stop
			if [ $? -eq 1 ]; then
				rlLog "[ FAIL ] BZ 845301 found -- service iptables stop returns 1 when already stopped"
				rlLog "This affects RHEL5 version of iptables service"
			else
				rlLog "[ PASS ] BZ 845301 not found -- service iptables stop succeeeded"
			fi
		fi
                if [ -f /etc/init.d/iptables ]; then
                 rlRun "service iptables stop"
                fi
                if [ -f /etc/init.d/ip6tables ]; then
                 rlRun "service ip6tables stop"
                fi
                if [ -f /usr/lib/systemd/system/firewalld.service ]; then
                 rlRun "systemctl stop firewalld"
                fi

		rlRun "ps -ef|grep [y]pbind" 0 "Check that NIS Client (ypbind) is running"
		[ -f $tmpout ] && rm -f $tmpout
	rlPhaseEnd
}
