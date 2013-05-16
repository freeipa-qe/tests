#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-ca-install
#   Description: IPA CA install tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
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

##########################################################################

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh
. ./install-lib.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include tests file
. ./t.ca-install.sh

COMMON_SERVER_PACKAGES="bind expect krb5-workstation bind-dyndb-ldap krb5-pkinit-openssl"
RHELIPA_SERVER_PACKAGES="ipa-server"
COMMON_CLIENT_PACKAGES="httpd curl mod_nss mod_auth_kerb 389-ds-base expect ntpdate"
RHELIPA_CLIENT_PACKAGES="ipa-admintools ipa-client"
FREEIPA_SERVER_PACKAGES="freeipa-server"
FREEIPA_CLIENTi_PACKAGES="freeipa-admintools freeipa-client"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
########################################################################
# Test Suite Globals
########################################################################
cat /opt/rhqa_ipa/env.sh
########################################################################



PACKAGELIST="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"

rlJournalStart

        #####################################################################

        #####################################################################
        #               IS THIS MACHINE A MASTER?                           #
        #####################################################################
        rc=0

	echo "Hostname of this machine is $HOSTNAME"
	echo "Hostname of master is $MASTER"

	myhostname=`hostname`
	rlLog "hostname command: $myhostname"
        rlLog "HOSTNAME: $HOSTNAME"
        rlLog "MASTER: $MASTER"
        rlLog "SLAVE: $SLAVE"
        rlLog "CLIENT: $CLIENT"
        rlLog "CLIENT2: $CLIENT2"

        eval "echo \"export BEAKERMASTER=$MASTER\" >> /opt/rhqa_ipa/env.sh"
        eval "echo \"export BEAKERSLAVE=$SLAVE\" >> /opt/rhqa_ipa/env.sh"
        eval "echo \"export BEAKERCLIENT=$CLIENT\" >> /opt/rhqa_ipa/env.sh"
        eval "echo \"export BEAKERCLIENT2=$CLIENT2\" >> /opt/rhqa_ipa/env.sh"
	MASTER_S=`echo $MASTER | cut -d . -f 1`
	eval "echo \"export MASTER=$MASTER_S.$DOMAIN\" >> /opt/rhqa_ipa/env.sh"
	SLAVE_S=`echo $SLAVE | cut -d . -f 1`
	eval "echo \"export SLAVE=$SLAVE_S.$DOMAIN\" >> /opt/rhqa_ipa/env.sh"

	. /opt/rhqa_ipa/env.sh

	ipofm=`dig +short $BEAKERMASTER`
	ipofs=`dig +short $BEAKERSLAVE`

	eval "echo \"export MASTERIP=$ipofm\" >> /opt/rhqa_ipa/env.sh"
	eval "echo \"export SLAVEIP=$ipofs\" >> /opt/rhqa_ipa/env.sh"

	. /opt/rhqa_ipa/env.sh
	cat /opt/rhqa_ipa/env.sh

        cat /etc/redhat-release | grep "Fedora"
        if [ $? -eq 0 ] ; then
                FLAVOR="Fedora"
                rlLog "Automation is running against Fedora"
        else
                FLAVOR="RedHat"
                rlLog "Automation is running against RedHat"
        fi

        echo $BEAKERMASTER | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                rlLog "Machine in recipe is MASTER"

	rlPhaseStartSetup "ipa-ca-install: ipa-server installation"
               
         if [ -f /etc/init.d/iptables ]; then
           rlRun "service iptables stop" 0 "Stoping firewall"
         fi
         if [ -f /etc/init.d/ip6tables ]; then
          rlRun "service ip6tables stop"
         fi
         if [ -f /usr/lib/systemd/system/firewalld.service ]; then
          rlRun "systemctl stop firewalld"
         fi

        	rlRun "cat /opt/rhqa_ipa/env.sh"
	        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        	rlRun "pushd $TmpDir"

	rlPhaseEnd

	rlPhaseStartTest "MASTER tests start"

                if [ "$FLAVOR" == "Fedora" ] ; then
                        yum -y install $FREEIPA_SERVER_PACKAGES
                        yum -y update

                        for item in $FREEIPA_SERVER_PACKAGES $COMMON_SERVER_PACKAGES ; do
                                rpm -qa | grep $item
                                if [ $? -eq 0 ] ; then
                                        rlLog "$item package is installed"
                                else
                                        rlLog "ERROR: $item package is NOT installed"
                                        rc=1
                                fi
                        done
                else
                        yum -y install $RHELIPA_SERVER_PACKAGES $COMMON_SERVER_PACKAGES
                        yum -y update

                        for item in $RHELIPA_SERVER_PACKAGES ; do
                                rpm -qa | grep $item
                                if [ $? -eq 0 ] ; then
                                        rlLog "$item package is installed"
                                else
                                        rlLog "ERROR: $item package is NOT installed"
                                        rc=1
                                fi
                        done
                fi

		installMaster

                rhts-sync-set -s READY $BEAKERMASTER
		rhts-sync-block -s DONE $BEAKERSLAVE

	rlPhaseEnd

	rlPhaseStartCleanup "ipa-ca-install: ipa-server clean up."
        	# dummy section
		rlLog "dummy section"
	rlPhaseEnd


        else
                rlLog "Machine in recipe in not a MASTER"
        fi

        #####################################################################


        #####################################################################
        #               IS THIS MACHINE A SLAVE?                            #
        #####################################################################
        rc=0
        echo $BEAKERSLAVE | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
                yum clean all
                yum -y install $COMMON_SERVER_PACKAGES

                if [ "$FLAVOR" == "Fedora" ] ; then
                        yum -y install $FREEIPA_SERVER_PACKAGES
                        yum -y update

                        for item in $FREEIPA_SERVER_PACKAGES ; do
                                rpm -qa | grep $item
                                if [ $? -eq 0 ] ; then
                                        rlLog "$item package is installed"
                                else
                                        rlLog "ERROR: $item package is NOT installed"
                                        rc=1
                                fi
                        done
                else
                        yum -y install $RHELIPA_SERVER_PACKAGES
                        yum -y update

                        for item in $RHELIPA_SERVER_PACKAGES ; do
                                rpm -qa | grep $item
                                if [ $? -eq 0 ] ; then
                                        rlLog "$item package is installed"
                                else
                                        rlLog "ERROR: $item package is NOT installed"
                                        rc=1
                                fi
                        done
                fi


                if [ $rc -eq 0 ] ; then
                        rhts-sync-block -s READY $BEAKERMASTER
                        installSlave
			installCA
                        rhts-sync-set -s DONE $BEAKERSLAVE
                        rlLog "Setting up Authorized keys"
                        SetUpAuthKeys
                        rlLog "Setting up known hosts file"
                        SetUpKnownHosts
                fi
        else
                rlLog "Machine in recipe in not a SLAVE"
	fi


rlJournalPrintText
report=$TmpDir/rhts.report.$RANDOM.txt
makereport $report
rhts-submit-log -l $report
rlJournalEnd
