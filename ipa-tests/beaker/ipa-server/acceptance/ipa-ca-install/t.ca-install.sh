#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-ca-install
#   Description: IPA CA install tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: 
#	     Gowrishankar Rajaiyan <gsr@redhat.com>
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. ./install-lib.sh


installMaster()
{
   rlPhaseStartTest "Install IPA MASTER Server"

        rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "fixHostFile" 0 "Set up /etc/hosts"
	rlRun "fixhostname" 0 "Fix hostname"

	rlRun "yum install -y ipa-server bind-dyndb-ldap bind"
	echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /dev/shm/installipa.bash

	rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

        rlRun "setenforce 1" 0 "Making sure selinux is enforced"
        rlRun "chmod 755 /dev/shm/installipa.bash" 0 "Making ipa install script executable"
        rlRun "/bin/bash /dev/shm/installipa.bash" 0 "Installing IPA Server"

        if [ -f /var/log/ipaserver-install.log ]; then
                rhts-submit-log -l /var/log/ipaserver-install.log
        fi

	rlRun "service ipa status"
   rlPhaseEnd

   rlPhaseStartTest "Create Replica Package(s)"
        for s in $SLAVE; do
                if [ "$s" != "" ]; then
                        # Determine the IP of the slave to be used when creating the replica file.
                        ipofs=$(dig +noquestion $s  | grep $s | grep IN | grep A | awk '{print $5}')
			ipofs2=`cat /etc/hosts | grep $s | cut -f 1 -d " "`

                        # put the short form of the hostname for server $s into s_short
                        hostname_s=$(echo $s | cut -d. -f1)

                        rlLog "IP of server $s is resolving as $ipofs2, using short hostname of $hostname_s"
                        rlLog "Running: ipa-replica-prepare -p $ADMINPW --ip-address=$ipofs2 $hostname_s.$DOMAIN"
                        rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$ipofs2 $hostname_s.$DOMAIN" 0 "Creating replica package"
                        rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"

                else

                        rlLog "No SLAVES in current recipe set."

                fi
        done

        rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"

        # stop the firewall
        service iptables stop
        service ip6tables stop

   rlPhaseEnd

}

	
installSlave()
{
   rlPhaseStartSetup "Install IPA REPLICA Server"
	
	yum install -y openssh-clients
	yum install -y ipa-server bind-dyndb-ldap bind
        
	rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
        # stop the firewall
        service iptables stop
        service ip6tables stop
        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"
        cd /dev/shm/
        hostname_s=$(hostname -s)
        rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Get replica package"
        rlLog "sftp root@$MASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "Checking for existance of replica gpg file"
        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else
                rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
                rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
                rlLog "SKIPINSTALL: $SKIPINSTALL"       
                rlRun "fixResolv" 0 "fixing the reoslv.conf to contain the correct nameserver lines"
                rlRun "fixHostFile" 0 "Set up /etc/hosts"

                rlRun "fixhostname" 0 "Fix hostname"
                echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi
        # stop the firewall
        service iptables stop
        service ip6tables stop
   rlPhaseEnd
 
}


installCA()
{

   rlPhaseStartSetup "Installing CA Replica"

	rlLog "Executing: ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
	echo "ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-ca-install.bash
	chmod 755 /dev/shm/replica-ca-install.bash
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
	rlRun "/bin/bash /dev/shm/replica-ca-install.bash" 0 "CA Replica installation"

	if [ -f /var/log/ipareplica-ca-install.log ]; then
		rhts-submit-log -l /var/log/ipareplica-ca-install.log
	fi

}
