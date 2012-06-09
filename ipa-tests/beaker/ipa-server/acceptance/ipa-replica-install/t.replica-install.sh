#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-replica-install
#   Description: IPA Replica install tests
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
. ./t.replica-install.bug.sh


installMaster()
{
   rlPhaseStartTest "Install IPA MASTER Server"

        rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "fixHostFile" 0 "Set up /etc/hosts"
	rlRun "fixhostname" 0 "Fix hostname"

        # Determine the IP of the slave to be used when creating the replica file.
        ipofs=$(dig +noquestion $SLAVE  | grep $SLAVE | grep IN | grep A | awk '{print $5}')
	rlLog "IP address of SLAVE: $SLAVE is $ipofs"

	rlRun "yum install -y ipa-server bind-dyndb-ldap bind"

	# Including --idstart=3000 --idmax=50000 to verify bug 782979.
	echo "ipa-server-install --idstart=3000 --idmax=50000 --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /dev/shm/installipa.bash

	rlLog "EXECUTING: ipa-server-install --idstart=3000 --idmax=50000 --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

        rlRun "setenforce 1" 0 "Making sure selinux is enforced"
        rlRun "chmod 755 /dev/shm/installipa.bash" 0 "Making ipa install script executable"
        rlRun "/bin/bash /dev/shm/installipa.bash" 0 "Installing IPA Server"

        rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=797563"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
        verifyErrorMsg "ipa host-del $MASTER" "ipa: ERROR: invalid 'hostname': An IPA master host cannot be deleted or disabled"


        if [ -f /var/log/ipaserver-install.log ]; then
                rhts-submit-log -l /var/log/ipaserver-install.log
        fi

	rlRun "service ipa status"
   rlPhaseEnd
}

createReplica1()
{

	rlPhaseStartTest "Create Replica Package(s) without --ip-address option"
		for s in $SLAVE; do
			if [ "$s" != "" ]; then

				rlRun "rm -fr /var/lib/ipa/replica-info-*"
				rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

				# put the short form of the hostname for server $s into s_short
				hostname_s=$(echo $s | cut -d. -f1)

				# Preparing replica without --ip-address option
				rlRun "sed -i /$SLAVEIP/d /etc/hosts"
				rlRun "echo \"$SLAVEIP $hostname_s.$DOMAIN\" >> /etc/hosts"
				rlRun "cat /etc/hosts"
				rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf" 0 "fixing the reoslv.conf to contain the correct nameserver lines"
				rlRun "cat /etc/resolv.conf"
				rlRun "ipa dnszone-find"
				### Commenting this because it creates the reverse zone which we don't want for no-reverse
				REVERSE_ZONE=$(echo $SLAVEIP|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
				if [ $(ipa dnszone-show $REVERSE_ZONE 2>/dev/null | wc -l) -eq 0 ]; then
					rlRun "ipa dnszone-add $REVERSE_ZONE --name-server=$MASTER --admin-email=ipaqar.redhat.com"
				fi
				rlRun "ipa dnsrecord-add $DOMAIN $hostname_s --a-rec=$SLAVEIP --a-create-reverse"
				# Making use of --a-create-reverse ... hence comenting the following :-)
				# REVERSE_ZONE=`ipa dnszone-find | grep -i "zone name" | grep -i "arpa" | cut -d ":" -f 2`
				# LAST_OCTET=`echo $SLAVEIP | cut -d . -f 4`
				# rlRun "ipa dnsrecord-add $REVERSE_ZONE $LAST_OCTET --ptr-rec=$hostname_s.$DOMAIN."

				rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"
				sleep 10

				rlLog "Running: ipa-replica-prepare -p $ADMINPW $hostname_s.$DOMAIN"
				rlRun "ipa-replica-prepare -p $ADMINPW $hostname_s.$DOMAIN"

			else

				rlLog "No SLAVES in current recipe set."

			fi
		done

	rlPhaseEnd
}

createReplica2() 
{

	rlPhaseStartTest "Create Replica Package(s) with --ip-address option"
		for s in $SLAVE; do
			if [ "$s" != "" ]; then
				# put the short form of the hostname for server $s into s_short
				hostname_s=$(echo $s | cut -d. -f1)

				rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
				rlRun "rm -fr /var/lib/ipa/replica-info-*"
				MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
				SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
				ZONECHECK=$(ipa dnszone-show $SLAVEZONE 2>/dev/null | wc -l)
				if [ "x$MASTERZONE" != "x$SLAVEZONE" -a $ZONECHECK -gt 0 ]; then
					rlLog "Deleting ZONE ($SLAVEZONE) so ipa-replica-prepare creates it"
					rlRun "ipa dnszone-del $SLAVEZONE"
					rlRun "service named restart"
				fi
				rlRun "ipa dnszone-find"
				if [ $(ipa dnsrecord-show $DOMAIN $hostname_s 2>/dev/null | wc -l) -gt 0 ]; then
					rlLog "Deleting $hostname_s.$DOMAIN records so ipa-replica-prepare creates it"
					rlRun "ipa dnsrecord-del $DOMAIN $hostname_s --del-all"
					miscDNSCleanup 
				fi
				rlRun "ipa dnsrecord-find $DOMAIN"
				rlRun "cat /etc/hosts"
				

				# Preparing replica with --ip-address option
				rlRun "service named restart"
				rlLog "IP of server $s is resolving as $SLAVEIP, using short hostname of $hostname_s"
				rlLog "Running: ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN"
				rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN" 0 "Creating replica package"

				# Checking DNS records added for Replica
				rlRun "ipa dnsrecord-find $SLAVEZONE"
				rlRun "ipa dnsrecord-find $DOMAIN"
				rlRun "dig +short $hostname_s.$DOMAIN"
				rlRun "dig +short -x $SLAVEIP"
				rlRun "service named restart"
				rlRun "ipa dnsrecord-find $SLAVEZONE"
				rlRun "ipa dnsrecord-find $DOMAIN"
				rlRun "dig +short $hostname_s.$DOMAIN"
				rlRun "dig +short -x $SLAVEIP"

			else

				rlLog "No SLAVES in current recipe set."

			fi
		done

	rlPhaseEnd
}

createReplica3()
{
	rlPhaseStartTest "Create Replica Package(s) with pkcs#12 options"
		for s in $SLAVE; do
			if [ "$s" != "" ]; then
				rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
				#rlRun "rm -fr /var/lib/ipa/replica-info-*"
				rlRun "rm -rf /tmp/httpcert /tmp/ldapcert"
				
				cd /var/lib/ipa
				rlRun "cp replica-info-$SLAVE.gpg replica-info-$SLAVE.gpg.createReplica3.backup"
				rlRun "echo $ADMINPW | gpg --batch --passphrase-fd 0 -d replica-info-$SLAVE.gpg | tar xvf -"
				rlRun "rm -f replica-info-$SLAVE.gpg"

				hostname_s=$(echo $s|cut -f1 -d.)
				rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN --dirsrv_pkcs12=realm_info/dscert.p12 --dirsrv_pin='' --http_pkcs12=realm_info/httpcert.p12 --http_pin=''"
				rlRun "rm -rf realm_info"

				rlRun "service named restart"	
				rlRun "dig +short $hostname_s.$DOMAIN"
				rlRun "dig +short $MASTER"
				rlRun "dig +short -x $MASTERIP"
				rlRun "dig +short $SLAVE"
				rlRun "dig +short -x $SLAVEIP"
			else
				rlLog "No SLAVES in current recipe set."
			fi
		done

		rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"

	rlPhaseEnd

}

createReplica4() 
{

	rlPhaseStartTest "Create Replica Package(s) without --ip-address option and with reverse zone deleted"
		for s in $SLAVE; do
			if [ "$s" != "" ]; then

				SLAVE_S=$(echo $s|cut -f1 -d.)
				rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
				rlRun "rm -fr /var/lib/ipa/replica-info-*"
				# Cleanup server and network info from DNS
				MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
				SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
				ZONECHECK=$(ipa dnszone-show $SLAVEZONE 2>/dev/null | wc -l)
				if [ "x$MASTERZONE" != "x$SLAVEZONE" -a $ZONECHECK -gt 0 ]; then
					rlLog "Deleting ZONE ($SLAVEZONE) so ipa-replica-prepare creates it"
					rlRun "ipa dnszone-del $SLAVEZONE"
					rlRun "service named restart"
				fi
				if [ $(ipa dnsrecord-show $DOMAIN $hostname_s 2>/dev/null | wc -l) -gt 0 ]; then
					rlRun "ipa dnsrecord-del $DOMAIN $SLAVE_S --del-all"
				fi

				# Make sure /etc/hosts has correct info
				rlRun "sed -i /$SLAVEIP/d  /etc/hosts"
				rlRun "sed -i s/$SLAVE//   /etc/hosts"
				rlRun "sed -i s/$SLAVE_S// /etc/hosts"
				rlRun "echo \"$SLAVEIP $SLAVE $SLAVE_S\" >> /etc/hosts"
				rlRun "cat /etc/hosts"
				
				# Preparing replica without --ip-address option for no-reverse test
				rlRun "service named restart"
				rlLog "IP of server $s is resolving as $SLAVEIP, using short hostname of $SLAVE_S"
				rlLog "Running: ipa-replica-prepare -p $ADMINPW $SLAVE_S.$DOMAIN"
				rlRun "ipa-replica-prepare -p $ADMINPW $SLAVE_S.$DOMAIN" 0 "Creating replica package"

			else

				rlLog "No SLAVES in current recipe set."

			fi
		done

	rlPhaseEnd
}
	
installSlave()
{
   rlPhaseStartSetup "Install IPA REPLICA Server"
	
	rlRun "yum install -y openssh-clients"
	rlRun "yum install -y ipa-server bind-dyndb-ldap bind"
        
	rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"

        # stop the firewall
        service iptables stop
        service ip6tables stop

        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"

        cd /dev/shm/
        hostname_s=$(hostname -s)
	AddToKnownHosts $MASTERIP
        rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "Checking for existance of replica gpg file"
        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else
                rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
                rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
                rlLog "SKIPINSTALL: $SKIPINSTALL"       
                rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf" 0 "fixing the reoslv.conf to contain the correct nameserver lines"
		rlRun "cat /etc/resolv.conf"
                rlRun "fixHostFile" 0 "Set up /etc/hosts"

                rlRun "fixhostname" 0 "Fix hostname"
                echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		# Disabling the following since empty forwarders exist in named.conf
		# rlAssertGrep "forwarders" "/etc/named.conf"
		rlAssertGrep "$DNSFORWARD" "/etc/named.conf"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"

				# Verifying bug 784696
				rlLog "Verifying https://bugzilla.redhat.com/show_bug.cgi?id=784696"
				rlLog "ldapsearch -x -D '$ROOTDN' -w '$ROOTDNPWD' -b 'cn=config' |grep 'nsDS5ReplicaUpdateSchedule: 0000-2359 0123456'"
				BZCHECK=$(ldapsearch -x -D '$ROOTDN' -w '$ROOTDNPWD' -b 'cn=config' |grep 'nsDS5ReplicaUpdateSchedule: 0000-2359 0123456'|wc -l)
				if [ $BZCHECK -gt 0 ]; then
					rlFail "BZ 784696 found...Dont set nsds5replicaupdateschedule in replication agreements"
				else
					rlPass "BZ 784696 not found....nsds5replicaupdateschedule not set"
				fi
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi
        # stop the firewall
        service iptables stop
        service ip6tables stop
   rlPhaseEnd
 
}


installSlave_nf()
{

   rlPhaseStartTest "Installing replica with --no-forwarders option"

        cd /dev/shm/
        hostname_s=$(hostname -s)
		AddToKnownHosts $MASTERIP
	rlRun "rm -fr /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
        rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "Checking for existance of replica gpg file"
        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

		rlRun "host -t srv _kerberos._tcp.$DOMAIN"
		#rlRun "> /var/lib/sss/pubconf/kdcinfo.$RELM"
                rlRun "cat /etc/resolv.conf"
		sleep 10
                echo "ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
				# Disabling the following since empty forwarders exist in named.conf
                # rlAssertNotGrep "forwarders" "/etc/named.conf"
                rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"
				rlRun "cat /etc/named.conf"
				rlRun "cat /etc/resolv.conf"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
				rlRun "dig +short $MASTER"
				rlRun "dig +short -x $MASTERIP"
				rlRun "dig +short $SLAVE"
				rlRun "dig +short -x $SLAVEIP"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
				cp /var/log/ipareplica-install.log /var/log/ipareplica-install.log_installSlave_nf
                rhts-submit-log -l /var/log/ipareplica-install.log_installSlave_nf
        fi
		if [ -f /var/log/ipareplica-conncheck.log ]; then
				cp /var/log/ipareplica-conncheck.log /var/log/ipareplica-conncheck.log_nf
				rhts-submit-log -l /var/log/ipareplica-conncheck.log_nf
		fi
		INSTANCE=$(echo $RELM|sed 's/\./-/g')
		if [ -f /var/log/dirsrv/slapd-$INSTANCE/errors ]; then
			cp /var/log/dirsrv/slapd-$INSTANCE/errors /var/log/dirsrv/slapd-$INSTANCE/errors_nf
			rhts-submit-log -l /var/log/dirsrv/slapd-$INSTANCE/errors_nf
		fi
		if [ -f /var/log/dirsrv/slapd-$INSTANCE/access ]; then
			cp /var/log/dirsrv/slapd-$INSTANCE/access /var/log/dirsrv/slapd-$INSTANCE/access_nf
			rhts-submit-log -l /var/log/dirsrv/slapd-$INSTANCE/access_nf
		fi

   rlPhaseEnd
}

installSlave_nr()
{

	rlPhaseStartTest "Installing replica with --no-reverse option"
		cd /dev/shm/
		[ -z "$hostname_s" ] && hostname_s=$(echo $SLAVE|cut -f1 -d.)
		rlRun "rm -f /dev/shm/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else

			rlRun "cat /etc/resolv.conf"
			rlRun "sed -i /$MASTERIP/d /etc/hosts"
			rlRun "echo \"$MASTERIP $MASTER\" >> /etc/hosts"
			rlRun "cat /etc/hosts"

			echo "ipa-replica-install -U --setup-dns --no-forwarders --no-reverse -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
			chmod 755 /dev/shm/replica-install.bash
			rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-reverse -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			# Disabling the following since empty forwarders exist in named.conf
			# rlAssertNotGrep "forwarders" "/etc/named.conf"
			rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"

			rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757644"
			MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			#rlRun "ipa dnszone-find | grep in-addr.arpa." 1
			if [ "x$MASTERZONE" != "x$SLAVEZONE" ]; then
				rlRun "ipa dnszone-find $SLAVEZONE" 1
			else
				rlLog "Cannot test --no-reverse here since SLAVE ($SLAVEIP) is in same network as MASTER ($MASTERIP)"
			fi

			rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
		fi

		if [ -f /var/log/ipareplica-install.log ]; then
			cp /var/log/ipareplica-install.log /var/log/ipareplica-install.log_installSlave_nr
			rhts-submit-log -l /var/log/ipareplica-install.log_installSlave_nr
		fi
		if [ -f /var/log/ipareplica-conncheck.log ]; then
				cp /var/log/ipareplica-conncheck.log /var/log/ipareplica-conncheck.log_nr
				rhts-submit-log -l /var/log/ipareplica-conncheck.log_nr
		fi

	rlPhaseEnd
}

installSlave_nhostdns()
{

   rlPhaseStartTest "Installing replica with --no-host-dns option"

                rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757681"

        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cp /etc/resolv.conf /etc/resolv.conf_backup"
		rlRun "> /etc/resolv.conf"

		rlRun "remoteExec root $MASTERIP redhat \"service named restart\""
		rlRun "dig $SLAVE" 9

		rlRun "echo \"$MASTERIP		$MASTER\" >> /etc/hosts"
		rlRun "cat /etc/hosts"


                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-host-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-host-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

		# Disabling the following since empty forwarders exist in named.conf
                # rlAssertNotGrep "forwarders" "/etc/named.conf"
                rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"

		rlRun "service ipa status"


		rlRun "mv -f /etc/resolv.conf_backup /etc/resolv.conf" 0 "Restoring /etc/resolv.conf"
		rlRun "remoteExec root $MASTERIP redhat \"service named restart\""
		rlRun "service named restart"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi

   rlPhaseEnd
}


installSlave_ca()
{

   rlPhaseStartTest "Installing replica with --setup-ca option"

        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/resolv.conf"

                echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --setup-ca -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --setup-ca -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

		# Disabling the following since empty forwarders exist in named.conf
                # rlAssertGrep "forwarders" "/etc/named.conf"
                rlAssertGrep "$DNSFORWARD" "/etc/named.conf"

                rlRun "ipa dnszone-find | grep in-addr.arpa."


	        # Verifies: Bug 782979 - Replication Failure: Allocation of a new value for range cn=posix ids.
		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=782979"
		user1="user1"
		user2="user2"
		user3="user3"
		userpw="Secret123"

        rlRun "create_ipauser $user1 $user1 $user1 $userpw"
        sleep 5
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user2 $user2 $user2 $userpw"
        sleep 5
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user3 $user3 $user3 $userpw"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

        rlRun "ipa user-show $user1"
        rlRun "ipa user-show $user2"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=788726"
		rlRun "remoteExec root $MASTERIP \"grep 'NSMMReplicationPlugin.*Schema replication update failed: Invalid syntax' /var/log/dirsrv/slapd-PKI-IPA/errors\""
		rlRun "grep -v 'Schema replication update failed:' /tmp/remote_exec.out" 0
		rlRun "cat /tmp/remote_exec.out"
		
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi

		CA2INSTALL=true

   rlPhaseEnd
}

installSlave_sshtrustdns() {

   rlPhaseStartTest "Installing replica with --ssh-trust-dns option"
		cd /dev/shm/
		[ -z "$hostname_s" ] && hostname_s=$(echo $SLAVE|cut -f1 -d.)
		rlRun "rm -f /dev/shm/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/hosts"
				rlRun "cat /etc/resolv.conf"

                echo "ipa-replica-install -U --setup-dns --no-forwarders --configure-ssh --ssh-trust-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --configure-ssh --ssh-trust-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

                rlRun "service ipa status"
				rlRun "service named restart"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "cat /etc/ssh/ssh_config | grep -i \"VerifyHostKeyDNS yes\""
		rlRun "cat /etc/ssh/ssh_config | grep -i VerifyHostKeyDNS"

        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi

	rlPhaseEnd
} #installSlave_sshtrustdns

installSlave_configuresshd() {

	rlPhaseStartTest "Installing replica with --configure-sshd option"
		ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else

			rlRun "cat /etc/hosts"

			echo "ipa-replica-install -U --setup-dns --no-forwarders --configure-sshd --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
			chmod 755 /dev/shm/replica-install.bash
			rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --configure-sshd --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			rlRun "service ipa status"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

			rlRun "grep -i \"KerberosAuthentication no\" /etc/ssh/sshd_config" 0 "sshd_config should have KerberosAuthentication yes"
			rlRun "grep -i \"GSSAPIAuthentication yes\" /etc/ssh/sshd_config" 0 "sshd_config should have GSSAPIAuthentication yes"
			rlRun "grep -i \"AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys\" /etc/ssh/sshd_config" 0 "sshd_config should have AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys"

			# Checking if sshfp record gets created by default
			rlRun "ipa dnsrecord-find $DOMAIN $hostname_s | grep -i \"sshfp record\""

		fi

		if [ -f /var/log/ipareplica-install.log ]; then
			rhts-submit-log -l /var/log/ipareplica-install.log
		fi
	rlPhaseEnd
} #installSlave_configuresshd


installSlave_nodnssshfp() {

   rlPhaseStartTest "Installing replica with --no-dns-sshfp option"

        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/hosts"
				rlLog "delete sshfp dns records before install to make sure this is clean"
				ORIGIFS="$IFS"
				IFS=$'\n'	
				for SSHFPREC in $(dig +short @$MASTERIP $hostname_s.$DOMAIN sshfp); do
					IFS="$ORIGIFS"
					remoteExec root $MASTERIP "ipa dnsrecord-del testrelm.com $hostname_s --sshfp-rec=\\\"$SSHFPREC\\\""
				done


                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-dns-sshfp --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-dns-sshfp --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

                rlRun "service ipa status"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "ipa dnsrecord-find $DOMAIN $hostname_s | grep -i \"sshfp record\"" 1 "SSHFP record should not be created"

        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi
	rlPhaseEnd
} #installSlave_nodnssshfp


installSlave_nouiredirect() {

   rlPhaseStartTest "Installing replica with --no-ui-redirect"

        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else   

                rlRun "cat /etc/hosts"

                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-ui-redirect --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-ui-redirect --skip-conncheck -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

                rlRun "service ipa status"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

				#commenting out since this test is properly handled in installSlave_nodnssshfp
                #rlRun "ipa dnsrecord-find $DOMAIN $hostname_s | grep -i \"sshfp record\"" 1 "SSHFP record should not be created"

		rlRun "curl http://$hostname_s.$DOMAIN > /tmp/curl.out 2>&1"
		rlAssertGrep "Test Page for the Apache HTTP" "/tmp/curl.out"
		rlAssertNotGrep "301 Moved Permanently" "/tmp/curl.out"
		rlAssertNotGrep "ipa/ui" "/tmp/curl.out"

        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi
	rlPhaseEnd
} #installSlave_nouiredirect


installCA()
{

   rlPhaseStartTest "Installing CA Replica"

	rlLog "Executing: ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
	echo "ipa-ca-install -p $ADMINPW -w $ADMINPW --skip-conncheck --unattended /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-ca-install.bash
	chmod 755 /dev/shm/replica-ca-install.bash
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
	rlRun "/bin/bash /dev/shm/replica-ca-install.bash" 0 "CA Replica installation"

	if [ -f /var/log/ipareplica-ca-install.log ]; then
		rhts-submit-log -l /var/log/ipareplica-ca-install.log
	fi
   rlPhaseEnd
}

uninstall()
{
	rlPhaseStartTest "Uninstalling replica"

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=797563"
		rlRun "ipa host-del $MASTER 2>&1| grep -i \"ipa: ERROR: invalid 'hostname': An IPA master host cannot be deleted\""
		rlRun "ipa host-del $SLAVE 2>&1| grep -i \"ipa: ERROR: invalid 'hostname': An IPA master host cannot be deleted\""

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=755094"
		rlRun "ipa-replica-manage list | grep \"$MASTER: master\""
		rlRun "ipa-replica-manage list | grep \"$SLAVE: master\""
		rlRun "ipa-replica-manage list -p Secret123 | grep \"$MASTER: master\""
		rlRun "ipa-replica-manage list -p Secret123 | grep \"$SLAVE: master\""
		rlRun "ipa-replica-manage list -p Secret123 $MASTER | grep \"$SLAVE: replica\""
		rlRun "ipa-replica-manage list -p Secret123 $SLAVE | grep \"$MASTER: replica\""

		MASTERIPOCT1=$(echo $MASTERIP|cut -f1 -d.)
		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=801380"
		rlRun "remoteExec root $MASTERIP redhat \"ipa dnszone-find\""
		rlRun "egrep $MASTERIPOCT1.in-addr.arpa. /tmp/remote_exec.out"
		rlRun "cat /tmp/remote_exec.out"

### ipa-csreplica-manage tests
		if [ -d /var/lib/pki-ca ]; then
			rlLog "verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=750524"
			# Adding some logic to check for a csreplica before trying to delete
			rlLog "checking if there is a csreplia agreement to delete" 
			rlRun "remoteExec root $MASTERIP \"ipa-csreplica-manage list -p $ADMINPW\""
			rlRun "cat /tmp/remote_exec.out"
			rlRun "ipa-csreplica-manage -H $MASTER list -p $ADMINPW -f > /tmp/remote_exec.out 2>&1"	
			rlRun "cat /tmp/remote_exec.out"
			grep $SLAVE /tmp/remote_exec.out | grep -v "CA not configured"|grep -v "Last login"
			if [ $? -eq 0 ]; then
				rlLog "Running initial ipa-csreplica-manage del positive test"
				if [ "$CA2INSTALL" = "true" ]; then	
					rlRun "ipa-csreplica-manage -H $MASTER del $SLAVE -p $ADMINPW -f > /tmp/remote_exec.out 2>&1"
				else
					rlRun "remoteExec root $MASTERIP \"ipa-csreplica-manage del $SLAVE -p $ADMINPW\""
				fi
				rlRun "egrep \"Deleted replication agreement from '$MASTER' to '$SLAVE'\" /tmp/remote_exec.out"
				rlRun "cat /tmp/remote_exec.out"
			fi

			rlLog "Running ipa-csreplica-manage-del negative test"
			rlRun "remoteExec root $MASTERIP \"ipa-csreplica-manage del $SLAVE -p $ADMINPW\""
			rlRun "egrep \"'$MASTER' has no replication agreement for '$SLAVE'\" /tmp/remote_exec.out"
			# Testing again with -H
			rlRun "ipa-csreplica-manage -H $MASTER del $SLAVE -p $ADMINPW -f > /tmp/remote_exec.out 2>&1" 1
			rlRun "egrep \"'$MASTER' has no replication agreement for '$SLAVE'\" /tmp/remote_exec.out"
			rlRun "cat /tmp/remote_exec.out"
		fi

### ipa-replica-manage tests

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=754524"
		rlRun "remoteExec root $MASTERIP redhat \"echo $ADMINPW | kinit admin; klist\""
		# comment for debugging...running ipa-replica-manage locally with -H option
		# issues with the remote executed yes hanging jobs if it irm doesn't prompt for confirmation
		#rlRun "replicaDel root $MASTERIP \"ipa-replica-manage del $SLAVE\" yes"
		if [ "$CA2INSTALL" = "true" ]; then	
			rlRun "ipa-replica-manage -H $MASTER del $SLAVE -p $ADMINPW -f > /tmp/remove_exec.out 2>&1"
		else
			rlRun "remoteExec root $MASTERIP \"ipa-replica-manage del $SLAVE -f\""
		fi
		rlRun "egrep \"Deleted replication agreement from '$MASTER' to '$SLAVE'\" /tmp/remote_exec.out"
		rlRun "cat /tmp/remote_exec.out"

		# comment for debugging...running ipa-replica-manage locally with -H option
		rlRun "replicaDel root $MASTERIP  \"ipa-replica-manage del $SLAVE -f\"" 
		rlRun "egrep \"'$MASTER' has no replication agreement for '$SLAVE'\" /tmp/replicaDel.out"
		# running again with -H
		rlRun "ipa-replica-manage -H $MASTER del $SLAVE -p $ADMINPW -f > /tmp/replicaDel.out 2>&1" 1
		rlRun "egrep \"'$MASTER' has no replication agreement for '$SLAVE'\" /tmp/replicaDel.out"
		rlRun "cat /tmp/replicaDel.out"

		rlLog "verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=754539"
		rlLog "With PASSWORD on command line"
		rlRun "remoteExec root $MASTERIP \"ipa-replica-manage connect $SLAVE -p $ADMINPW\""
		rlRun "egrep \"You cannot connect to a previously deleted master\" /tmp/remote_exec.out"

		rlLog "verifies bug https://bugzilla.redhat.com/show_bug.cgi?id=823657"
		rlLog "Without PASSWORD on command line...using kerberos creds"
		rlRun "remoteExec root $MASTERIP \"ipa-replica-manage connect $SLAVE \""
		rlRun "egrep \"You cannot connect to a previously deleted master\" /tmp/remote_exec.out"

		sleep 10

		rlLog "Executing: ipa-server-install --uninstall -U"
		rlRun "ipa-server-install --uninstall -U"

### cleanruv to be safe
		ESCBASEDN=$(echo $BASEDN|sed -e 's/=/\\3D/g' -e 's/,/\\2C/g')
		for RID in $(ldapsearch -xLLL -h $MASTERIP -D "$ROOTDN" -w "$ROOTDNPWD" -b dc=testrelm,dc=com  '(&(nsuniqueid=ffffffff-ffffffff-ffffffff-ffffffff)(objectclass=nstombstone))'|grep "nsds50ruv:.*$SLAVE"|awk '{print $3}'|sort -n)
		do
			ldapmodify -x -h $MASTERIP -D "$ROOTDN" -w "$ROOTDNPWD" <<-EOF
			dn: cn=replica,cn=$ESCBASEDN,cn=mapping tree,cn=config
			changetype: modify
			replace: nsds5task
			nsds5task: CLEANRUV$RID
			EOF
		done

### restart ipa on master to clear out old kerberos ticket for replica
		rlLog "restart dirsrv on master to clear out old kerberos ticket for replica"
		rlRun "remoteExec root $MASTERIP \"service dirsrv restart; service named restart; ipactl status\""

### clean up sssd config if left around
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "cat /var/lib/sss/pubconf/kdcinfo.$RELM"
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi

		rlRun "cat /etc/resolv.conf"

		rlLog "Waiting for 1 minute for everything to clear..."
		rlRun "sleep 60"

	rlPhaseEnd
}

miscDNSCleanup()
{
	hostname_s=$(echo $SLAVE|cut -f1 -d.)
	if [ $(ipa dnsrecord-show $DOMAIN _kerberos-master._tcp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _kerberos-master._tcp --srv-rec=\"0 100 88 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _kerberos-master._udp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _kerberos-master._udp --srv-rec=\"0 100 88 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _kerberos._tcp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _kerberos._tcp --srv-rec=\"0 100 88 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _kerberos._udp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _kerberos._udp --srv-rec=\"0 100 88 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _kpasswd._tcp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _kpasswd._tcp --srv-rec=\"0 100 464 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _kpasswd._udp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _kpasswd._udp --srv-rec=\"0 100 464 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _ldap._tcp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _ldap._tcp --srv-rec=\"0 100 389 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _ntp._udp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN _ntp._udp --srv-rec=\"0 100 123 $hostname_s\""
	fi
	if [ $(ipa dnsrecord-show $DOMAIN _kerberos-master._tcp |grep $hostname_s|wc -l) -gt 0 ]; then
		rlRun "ipa dnsrecord-del $DOMAIN \"@\" --ns-rec=$hostname_s.$DOMAIN"
	fi
}
