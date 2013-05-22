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

installMaster()
{
   rlPhaseStartTest "Install IPA MASTER Server"

        rlRun "service ntpd stop" 0 "Stopping the ntp server"
        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "fixHostFile" 0 "Set up /etc/hosts"
	rlRun "fixhostname" 0 "Fix hostname"

	echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /opt/rhqa_ipa/installipa.bash

	rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

        rlRun "setenforce 1" 0 "Making sure selinux is enforced"
        rlRun "chmod 755 /opt/rhqa_ipa/installipa.bash" 0 "Making ipa install script executable"
        rlRun "/bin/bash /opt/rhqa_ipa/installipa.bash" 0 "Installing IPA Server"

        if [ -f /var/log/ipaserver-install.log ]; then
                rhts-submit-log -l /var/log/ipaserver-install.log
        fi

	rlRun "service ipa status"

   rlPhaseEnd

   rlPhaseStartTest "Create Replica Package(s)"
        for s in $SLAVE; do
                if [ "$s" != "" ]; then

                        # put the short form of the hostname for server $s into s_short
                        hostname_s=$(echo $s | cut -d. -f1)

                        rlLog "IP of server $s is resolving as $SLAVEIP, using short hostname of $hostname_s"
                        rlLog "Running: ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN"
                        rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN" 0 "Creating replica package"
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
   rlPhaseStartTest "Install IPA REPLICA Server"
	
	yum install -y openssh-clients
	yum install -y bind-dyndb-ldap bind
 
        #Install ipa-server on RHEL and freeipa-server on Fedora
        rpm -qa | grep ipa-server
        if [ $? -eq 0 ] ; then
                rlPass "ipa-server package is installed"
        else
             cat /etc/redhat-release | grep "Fedora"
              if [ $? -eq 0 ] ; then
               yum install -y freeipa-server
              else
               yum install -y ipa-server
              fi
        fi

        
	rlRun "service ntpd stop" 0 "Stopping the ntp server"
        # stop the firewall

        if [ -f /etc/init.d/iptables ]; then
         rlRun "service iptables stop"
        fi
        if [ -f /etc/init.d/ip6tables ]; then
         rlRun "service ip6tables stop"
        fi
        if [ -f /usr/lib/systemd/system/firewalld.service ]; then
         rlRun "systemctl stop firewalld"
        fi
        
	. /opt/rhqa_ipa/env.sh
        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "fixHostFile" 0 "Set up /etc/hosts"
	rlRun "fixhostname" 0 "Fix hostname"

        cd /opt/rhqa_ipa/
        hostname_s=$(hostname -s)

        ipofm=`dig +short $BEAKERMASTER`
        ipofs=`dig +short $BEAKERSLAVE`
        export MASTERIP=$ipofm
        export SLAVEIP=$ipofs
	eval "echo \"export MASTERIP=$ipofm\" >> /opt/rhqa_ipa/env.sh"
	eval "echo \"export SLAVEIP=$ipofs\" >> /opt/rhqa_ipa/env.sh"

        rlRun "echo $MASTERIP" 0 "Master IP"
        rlRun "echo $SLAVEIP" 0 "Master IP"
        rlRun "cat /opt/rhqa_ipa/env.sh" 0 "env.sh"
	#AddToKnownHosts $MASTERIP
	#AddToKnownHosts $MASTER
       	rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"

        rlRun "sftp -o StrictHostKeyChecking=no root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Get replica package"
        rlLog "sftp -o StrictHostKeyChecking=no root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "Checking for existance of replica gpg file"
        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else
                rlRun "service ntpd stop" 0 "Stopping the ntp server"
                rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
                rlLog "SKIPINSTALL: $SKIPINSTALL"       
                echo "nameserver $MASTERIP" > /etc/resolv.conf
		rlRun "cat /etc/resolv.conf"
                rlRun "fixhostname" 0 "Fix hostname"
                rlRun "fixHostFile" 0 "Set up /etc/hosts"
        	rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"

                echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi
        # stop the firewall

   rlPhaseEnd
 
}


installCA()
{

   rlPhaseStartTest "Installing CA Replica with --no-host-dns option"

	rlRun "mv /etc/hosts /var/tmp/"
	echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts

        export FORWARD_ZONE=`ipa dnszone-find | grep -i "zone name" | grep com | cut -d : -f 2`
        export REV_ZONE=`ipa dnszone-find | grep -i "zone name" | grep arpa | cut -d : -f 2`
	export PTR_NAME=`echo $SLAVEIP | cut -d . -f 4`

expfile=/tmp/remote_exec.exp
expout=/tmp/remote_exec.out

rm -rf $expfile $expout

echo 'set timeout 30
set send_slow {1 .1}' > $expfile
echo "spawn ssh -l root $MASTER" >> $expfile
echo 'match_max 100000' >> $expfile
echo 'sleep 2' >> $expfile
echo 'expect "#: "' >> $expfile
echo "send \"kinit $ADMINID\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'expect "*d: "' >> $expfile
echo "send \"$ADMINPW\"" >> $expfile
echo 'send "\r"' >> $expfile
echo "send \"ipa dnsrecord-del $FORWARD_ZONE `hostname -s` --del-all\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'expect "#: "' >> $expfile
echo "send \"service named restart\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'expect eof ' >> $expfile

        rlRun "/usr/bin/expect $expfile >> $expout 2>&1"
        rlRun "cat $expfile"
        rlRun "cat $expout"

	rlRun "cat /etc/resolv.conf"
	echo "nameserver	$MASTERIP" > /etc/resolv.conf
	rlRun "cat /etc/resolv.conf"

	echo "$MASTERIP		$MASTER" >> /etc/hosts
	echo "$SLAVEIP		$SLAVE" >> /etc/hosts
	rlRun "cat /etc/hosts"

	rlRun "nslookup $MASTER"
	rlRun "nslookup $SLAVE"
	rlLog "Executing: ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended --no-host-dns /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"

	rlLog "Verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=757681"
	echo "ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended --no-host-dns /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-ca-install.bash
        chmod 755 /opt/rhqa_ipa/replica-ca-install.bash
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
        rlRun "/bin/bash /opt/rhqa_ipa/replica-ca-install.bash" 0 "CA Replica installation with --no-host-dns"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"


	sleep 5
	rlRun "service ipa status"
	rlRun "ipa-server-install --uninstall -U"
	sleep 5

rlPhaseEnd


	rlPhaseStartTest "Installing CA Replica without --no-host-dns option"

expfile=/tmp/remote_exec.exp
expout=/tmp/remote_exec.out

rm -rf $expfile $expout

echo 'set timeout 30
set send_slow {1 .1}' > $expfile
echo "spawn ssh -l root $MASTERIP" >> $expfile
echo 'match_max 100000' >> $expfile
echo 'sleep 2' >> $expfile
echo 'expect "#: "' >> $expfile
echo "send \"ipa-replica-manage del $SLAVE --force\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'sleep 3' >> $expfile
echo 'expect "*: "' >> $expfile
echo "send \"$ADMINPW\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'expect "#: "' >> $expfile
echo "send \"ipa dnsrecord-add $FORWARD_ZONE `hostname -s` --a-record=$SLAVEIP\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'expect "#: "' >> $expfile
echo "send \"ipa dnsrecord-add $REV_ZONE $PTR_NAME --ptr-hostname=$SLAVE\"" >> $expfile
echo 'send "\r"' >> $expfile
echo 'expect eof ' >> $expfile

	rlRun "/usr/bin/expect $expfile >> $expout 2>&1"
	rlRun "cat $expfile"
	rlRun "cat $expout"

	rlRun "mv /etc/hosts /tmp/"
	rlRun "mv /var/tmp/hosts /etc/hosts" 0 " Restoring /etc/hosts"
	rlRun "cat /etc/hosts"
	rlRun "cat /etc/resolv.conf"

        echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
        chmod 755 /opt/rhqa_ipa/replica-install.bash
        rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

	rlLog "Executing: ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
	echo "ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-ca-install.bash
	chmod 755 /opt/rhqa_ipa/replica-ca-install.bash
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
	rlRun "/bin/bash /opt/rhqa_ipa/replica-ca-install.bash" 0 "CA Replica installation"

	if [ -f /var/log/ipareplica-ca-install.log ]; then
		rhts-submit-log -l /var/log/ipareplica-ca-install.log
	fi

rlPhaseEnd
}
