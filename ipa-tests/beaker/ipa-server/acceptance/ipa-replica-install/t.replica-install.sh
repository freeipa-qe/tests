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
. /opt/rhqa_ipa/ipa-server-shared.sh
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

	rlRun "yum install -y $PKG-server bind-dyndb-ldap bind"

	# Determine my IP address
	currenteth=$(route | grep ^default | awk '{print $8}')
	# get the ip address of that interface
	ipaddr=$(hostname -i)
	echo $ipaddr | grep : # test the returned string to see if it contains a IPv6 address
	if [ $? -eq 0 ]; then 
		rlLog "IP contains a IPv6 address"; 
		ipv4=$(echo $ipaddr | cut -d\  -f2); 
		rlLog "Now using $ipv4 as IP address"
		ipaddr=$ipv4
	fi

	# Including --idstart=3000 --idmax=50000 to verify bug 782979.
	echo "ipa-server-install --idstart=3000 --ip-address $ipaddr --idmax=50000 --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /opt/rhqa_ipa/installipa.bash

	rlLog "EXECUTING: $(cat /opt/rhqa_ipa/installipa.bash)"

        rlRun "setenforce 1" 0 "Making sure selinux is enforced"
        rlRun "chmod 755 /opt/rhqa_ipa/installipa.bash" 0 "Making ipa install script executable"
        rlRun "/bin/bash /opt/rhqa_ipa/installipa.bash" 0 "Installing IPA Server"

        rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=797563"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
        verifyErrorMsg "ipa host-del $MASTER" "ipa: ERROR: invalid 'hostname': An IPA master host cannot be deleted or disabled"

		replicaBugCheck_bz905064 /var/log/ipaserver-install.log

        if [ -f /var/log/ipaserver-install.log ]; then
                rhts-submit-log -l /var/log/ipaserver-install.log
        fi

	rlRun "service ipa status"
	
   rlPhaseEnd
}

createReplica1()
{
	rlPhaseStartTest "Create Replica Package(s) without --ip-address option"
		if [ -z "$SLAVE" ]; then
			rlLog "No SLAVES in current recipe set."
		fi
		for s in $SLAVE; do
			s_short=$(echo $s | cut -d. -f1)

			rlRun "rm -fr /var/lib/ipa/replica-info-*"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			# Preparing replica without --ip-address option
			rlRun "sed -i /$SLAVEIP/d /etc/hosts"
			rlRun "echo \"$SLAVEIP $s_short.$DOMAIN\" >> /etc/hosts"
			rlRun "cat /etc/hosts"
			rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf" 
			rlRun "cat /etc/resolv.conf"

			rlRun "ipa dnszone-find"
			REVERSE_ZONE=$(echo $SLAVEIP|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			if [ $(ipa dnszone-show $REVERSE_ZONE 2>/dev/null | wc -l) -eq 0 ]; then
				rlRun "ipa dnszone-add $REVERSE_ZONE --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
			fi
			rlRun "ipa dnsrecord-add $DOMAIN $s_short --a-rec=$SLAVEIP --a-create-reverse"

			if [ $(ipa dnszone-find|grep $ZONE1|wc -l) -eq 0 ]; then 
				rlRun "ipa dnszone-add $ZONE1 --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
			fi
	
			rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"
			sleep 10

			rlLog "Running: ipa-replica-prepare -p $ADMINPW $s_short.$DOMAIN"
			rlRun "ipa-replica-prepare -p $ADMINPW $s_short.$DOMAIN"

			if [ $(ipa dnszone-find|grep $ZONE2|wc -l) -eq 0 ]; then 
				rlRun "ipa dnszone-add $ZONE2 --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
			fi
		done
	rlPhaseEnd
}

createReplica2() 
{

	rlPhaseStartTest "Create Replica Package(s) with --ip-address option"
		for s in $SLAVE; do
			if [ "$s" != "" ]; then
				local tmpout=/tmp/ipa-replica-install.out.$s
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
				rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN > $tmpout 2>&1" 0 "Creating replica package"
				rlRun "cat $tmpout"
				rlAssertNotGrep "preparation of replica failed:" $tmpout
				rlAssertNotGrep "missing attribute.*idnsSOAserial" $tmpout
				if [ $? -gt 0 ]; then
					rlFail "BZ 894143 found...ipa-replica-prepare fails when reverse zone does not have SOA serial data"
					rlLog "removing bad zone and re-adding"
					rlRun "ipa dnszone-del $SLAVEZONE"
					rlRun "ipa dnszone-add $SLAVEZONE --name-server=$MASTER. --admin-email=ipaqar.redhat.com"
					rlLog "IP of server $s is resolving as $SLAVEIP, using short hostname of $hostname_s"
					rlLog "Running: ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN"
					rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN > $tmpout 2>&1" 0 "Creating replica package"
				else
					rlPass "BZ 894143 not found"
				fi
				

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
		if [ -z "$SLAVE" ]; then
			rlLog "No SLAVES in current recipe set."
		fi
		for s in $SLAVE; do
			SLAVE_S=$(echo $s|cut -f1 -d.)
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
			rlRun "rm -fr /var/lib/ipa/replica-info-*"
			# Cleanup server and network info from DNS
			MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			if [ $(ipa dnszone-find|grep $SLAVEZONE|wc -l) -gt 0 ]; then	
				rlLog "Deleting ZONE ($SLAVEZONE) for no-reverse tests"
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

			rlRun "ipa dnszone-find"
		done

	rlPhaseEnd
}
	
installSlave()
{
	rlPhaseStartSetup "Install IPA REPLICA Server"

		rlRun "yum install -y openssh-clients"
		rlRun "yum install -y $PKG-server bind-dyndb-ldap bind"

		rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"

		# stop the firewall
		service iptables stop
		service ip6tables stop

		rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
		rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"

		cd /opt/rhqa_ipa/
		hostname_s=$(hostname -s)
		AddToKnownHosts $MASTERIP
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlLog "Checking for existance of replica gpg file"
		ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
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
			echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
			chmod 755 /opt/rhqa_ipa/replica-install.bash
			rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
			# Disabling the following since empty forwarders exist in named.conf
			# rlAssertGrep "forwarders" "/etc/named.conf"
			rlAssertGrep "$DNSFORWARD" "/etc/named.conf"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

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

			rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757644"
			rlLog "ipa-replica-install without --no-reverse should create new reverse zone if it does not already exist"
			MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
			#rlRun "ipa dnszone-find | grep in-addr.arpa." 1
			if [ "x$MASTERZONE" != "x$SLAVEZONE" ]; then
				rlRun "ipa dnszone-find $SLAVEZONE" 
			else
				rlLog "Cannot test --no-reverse here since SLAVE ($SLAVEIP) is in same network as MASTER ($MASTERIP)"
			fi
		fi

		if [ -f /var/log/ipareplica-install.log ]; then
			rhts-submit-log -l /var/log/ipareplica-install.log
		fi
		# stop the firewall
		service iptables stop
		service ip6tables stop

		miscDNSCheckup_positive
	rlPhaseEnd

}


installSlave_nf()
{

   rlPhaseStartTest "Installing replica with --no-forwarders option"

        cd /opt/rhqa_ipa/
        hostname_s=$(hostname -s)
		AddToKnownHosts $MASTERIP
	rlRun "rm -fr /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        rlLog "Checking for existance of replica gpg file"
        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

		rlRun "host -t srv _kerberos._tcp.$DOMAIN"
		#rlRun "> /var/lib/sss/pubconf/kdcinfo.$RELM"
                rlRun "cat /etc/resolv.conf"
		sleep 10
                echo "ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
				# Disabling the following since empty forwarders exist in named.conf
                # rlAssertNotGrep "forwarders" "/etc/named.conf"
                rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"
				rlRun "cat /etc/named.conf"
				rlRun "cat /etc/resolv.conf"

				replicaBugCheck_bz830314
				replicaBugCheck_bz905064 /var/log/ipareplica-install.log
 
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


		miscDNSCheckup_positive
   rlPhaseEnd
}

installSlave_nr()
{
	rlPhaseStartTest "installSlave_nr - Installing replica with --no-reverse option"
		cd /opt/rhqa_ipa/
		[ -z "$hostname_s" ] && hostname_s=$(echo $SLAVE|cut -f1 -d.)
		rlRun "rm -f /opt/rhqa_ipa/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else

			rlRun "cat /etc/resolv.conf"
			rlRun "sed -i /$MASTERIP/d /etc/hosts"
			rlRun "echo \"$MASTERIP $MASTER\" >> /etc/hosts"
			rlRun "cat /etc/hosts"

			echo "ipa-replica-install -U --setup-dns --no-forwarders --no-reverse -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
			chmod 755 /opt/rhqa_ipa/replica-install.bash
			rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-reverse -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

			# Disabling the following since empty forwarders exist in named.conf
			# rlAssertNotGrep "forwarders" "/etc/named.conf"
			rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"

			rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757644"
			rlLog "ipa-replica-install with --no-reverse should not create new reverse zone if it does not already exist"
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


		miscDNSCheckup_positive
	rlPhaseEnd
}

installSlave_nr1()
{
	rlPhaseStartTest "installSlave_nr1 - Installing replica with --no-reverse WITH reverse zones"
		SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		[ -z "$s_short" ] && s_short=$(echo $SLAVE|cut -f1 -d.)
		cd /opt/rhqa_ipa/
		rlRun "rm -f /opt/rhqa_ipa/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$s_short.$DOMAIN.gpg /opt/rhqa_ipa"
		ls /opt/rhqa_ipa/replica-info-$s_short.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else
			rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf"
			rlRun "cat /etc/resolv.conf"
			rlRun "sed -i /$MASTERIP/d /etc/hosts"
			rlRun "echo \"$MASTERIP $MASTER\" >> /etc/hosts"
			rlRun "cat /etc/hosts"

			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --no-reverse -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$s_short.$DOMAIN.gpg" 

			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

			rlLog "Checking that the SLAVEs zone is created locally"
			rlRun "ipa dnszone-show $SLAVEZONE"
			rlLog "Checking that the zone added before ipa-replica-prepare is created locally"
			rlRun "ipa dnszone-show $ZONE1"
			rlLog "Checking that the zone added after ipa-replica-prepare is created locally"
			rlRun "ipa dnszone-show $ZONE2"

			rlRun "appendEnv" 0 "Append the machine information to the env.sh"
		fi

		miscDNSCheckup_positive
	rlPhaseEnd
}

installSlave_nr2()
{
	rlPhaseStartTest "installSlave_nr2 - Installing replica with --no-reverse WITHOUT reverse zones"
		MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		[ -z "$s_short" ] && s_short=$(echo $SLAVE|cut -f1 -d.)
		cd /opt/rhqa_ipa/
		rlRun "rm -f /opt/rhqa_ipa/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$s_short.$DOMAIN.gpg /opt/rhqa_ipa"
		ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else
			rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf"
			rlRun "cat /etc/resolv.conf"
			rlRun "sed -i /$MASTERIP/d /etc/hosts"
			rlRun "echo \"$MASTERIP $MASTER\" >> /etc/hosts"
			rlRun "cat /etc/hosts"

			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --no-reverse -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$s_short.$DOMAIN.gpg"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

			rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757644"
			rlLog "ipa-replica-install with --no-reverse should not create new reverse zone if it does not already exist"
			rlLog "Checking that the SLAVEs zone is not created locally"
			rlRun "ipa dnszone-show $SLAVEZONE" 2
			rlLog "Checking that the zone added before ipa-replica-prepare is created locally"
			rlRun "ipa dnszone-show $ZONE1"
			rlLog "Checking that the zone added after ipa-replica-prepare is created locally"
			rlRun "ipa dnszone-show $ZONE2"
			rlRun "appendEnv" 0 "Append the machine information to the env.sh"

			if [ ! -f /tmp/SKIPMYREVERSEZONECHECK ]; then
				rlLog "touching file to indicate to uninstall not to check for my reverse zone as it is not there"
				rlRun "touch /tmp/SKIPMYREVERSEZONECHECK"
			fi
		fi

		miscDNSCheckup_positive
	rlPhaseEnd
}

installSlave_nr3()
{
	rlPhaseStartTest "installSlave_nr3 - Installing replica WITHOUT reverse zones"
		MASTERZONE=$(echo $MASTERIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		SLAVEZONE=$(echo $SLAVEIP|awk -F . '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
		[ -z "$s_short" ] && s_short=$(echo $SLAVE|cut -f1 -d.)
		cd /opt/rhqa_ipa/
		rlRun "rm -f /opt/rhqa_ipa/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$s_short.$DOMAIN.gpg /opt/rhqa_ipa"
		ls /opt/rhqa_ipa/replica-info-$s_short.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else
			rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf"
			rlRun "cat /etc/resolv.conf"
			rlRun "sed -i /$MASTERIP/d /etc/hosts"
			rlRun "echo \"$MASTERIP $MASTER\" >> /etc/hosts"
			rlRun "cat /etc/hosts"

			rlRun "ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$s_short.$DOMAIN.gpg"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log
			replicaBugCheck_bz894131 $SLAVEZONE
			replicaBugCheck_bz894143 
			replicaBugCheck_bz895083

			rlLog "Checking that the SLAVEs zone is created locally"
			rlRun "ipa dnszone-show $SLAVEZONE"
			rlLog "Checking that the zone added before ipa-replica-prepare is created locally"
			rlRun "ipa dnszone-show $ZONE1"
			rlLog "Checking that the zone added after ipa-replica-prepare is created locally"
			rlRun "ipa dnszone-show $ZONE2"

			rlRun "appendEnv" 0 "Append the machine information to the env.sh"
		fi

		miscDNSCheckup_positive
	rlPhaseEnd
}

installSlave_nhostdns()
{

   rlPhaseStartTest "Installing replica with --no-host-dns option"

                rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757681"

        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cp /etc/resolv.conf /etc/resolv.conf_backup"
		rlRun "> /etc/resolv.conf"

		rlRun "remoteExec root $MASTERIP redhat \"service named restart\""
		rlRun "dig $SLAVE" 9

		rlRun "echo \"$MASTERIP		$MASTER\" >> /etc/hosts"
		rlRun "cat /etc/hosts"


                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-host-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-host-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

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


		miscDNSCheckup_positive
   rlPhaseEnd
}


installSlave_ca()
{

   rlPhaseStartTest "Installing replica with --setup-ca option"

        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/resolv.conf"

                echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --setup-ca -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD --setup-ca -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log
            replicaBugCheck_bz867640

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


		miscDNSCheckup_positive
   rlPhaseEnd
}

installSlave_sshtrustdns() {

   rlPhaseStartTest "Installing replica with --ssh-trust-dns option"
		cd /opt/rhqa_ipa/
		[ -z "$hostname_s" ] && hostname_s=$(echo $SLAVE|cut -f1 -d.)
		rlRun "rm -f /opt/rhqa_ipa/replica-info-*"
		rlRun "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlLog "sftp root@$MASTERIP:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg"
        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/hosts"
				rlRun "cat /etc/resolv.conf"

                echo "ipa-replica-install -U --setup-dns --no-forwarders --ssh-trust-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --ssh-trust-dns --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

                rlRun "service ipa status"
				rlRun "service named restart"
        	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "cat /etc/ssh/ssh_config | grep -i \"VerifyHostKeyDNS yes\""
		rlRun "cat /etc/ssh/ssh_config | grep -i VerifyHostKeyDNS"

        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi


		miscDNSCheckup_positive
	rlPhaseEnd
} #installSlave_sshtrustdns

installSlave_configuresshd() {

	rlPhaseStartTest "Installing replica with --configure-sshd option"
		ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else

			rlRun "cat /etc/hosts"
			CFGSSHD=$(ipa-replica-install --help|grep '\-\-configure-sshd'|awk '{print $1}')
			if [ -z "${CFGSSHD}" ]; then
				rlLog "no configure-sshd option supported in this version"
				rlLog "skipping option but, will still test for proper settings"
			fi

			echo "ipa-replica-install -U --setup-dns --no-forwarders $CFGSSHD --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
			chmod 755 /opt/rhqa_ipa/replica-install.bash
			rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders $CFGSSHD --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

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

		miscDNSCheckup_positive
	rlPhaseEnd
} #installSlave_configuresshd

installSlave_nosshd() {

	rlPhaseStartTest "Installing replica with --no-sshd option"
		ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else

			rlRun "cat /etc/hosts"
			NOSSHD=$(ipa-replica-install --help|grep '\-\-no-sshd'|awk '{print $1}')
			if [ -z "${NOSSHD}" ]; then
				rlLog "no configure-sshd option supported in this version"
				rlLog "skipping option but, will still test for proper settings"
			fi

			echo "ipa-replica-install -U --setup-dns --no-forwarders $NOSSHD --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
			chmod 755 /opt/rhqa_ipa/replica-install.bash
			rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-sshd --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			replicaBugCheck_bz830314
			replicaBugCheck_bz905064 /var/log/ipareplica-install.log

			rlRun "service ipa status"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

			rlRun "grep -i \"#KerberosAuthentication no\" /etc/ssh/sshd_config" 0 "sshd_config should have #KerberosAuthentication no"
			rlRun "grep -i \"GSSAPIAuthentication yes\" /etc/ssh/sshd_config" 0 "sshd_config should have GSSAPIAuthentication yes"
			rlRun "grep -i \"#AuthorizedKeysCommand none\" /etc/ssh/sshd_config" 0 "sshd_config should have #AuthorizedKeysCommand none"
			# Checking if sshfp record gets created by default
			rlRun "ipa dnsrecord-find $DOMAIN $hostname_s | grep -i \"sshfp record\""

		fi

		if [ -f /var/log/ipareplica-install.log ]; then
			rhts-submit-log -l /var/log/ipareplica-install.log
		fi

		miscDNSCheckup_positive
	rlPhaseEnd
} #installSlave_nosshd

installSlave_nodnssshfp() {

   rlPhaseStartTest "Installing replica with --no-dns-sshfp option"

        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
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


                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-dns-sshfp --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-dns-sshfp --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

				replicaBugCheck_bz830314
				replicaBugCheck_bz905064 /var/log/ipareplica-install.log

                rlRun "service ipa status"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

		rlRun "ipa dnsrecord-find $DOMAIN $hostname_s | grep -i \"sshfp record\"" 1 "SSHFP record should not be created"

        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi

		miscDNSCheckup_positive
	rlPhaseEnd
} #installSlave_nodnssshfp


installSlave_nouiredirect() {

   rlPhaseStartTest "Installing replica with --no-ui-redirect"

        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else   

                rlRun "cat /etc/hosts"

                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-ui-redirect --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                chmod 755 /opt/rhqa_ipa/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-ui-redirect --skip-conncheck -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

				replicaBugCheck_bz830314
				replicaBugCheck_bz905064 /var/log/ipareplica-install.log

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

		miscDNSCheckup_positive
	rlPhaseEnd
} #installSlave_nouiredirect


installCA()
{

   rlPhaseStartTest "Installing CA Replica"

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

installSlave_negative1()
{
	local tmpout=/tmp/error_msg.out
	rlPhaseStartTest "installSlave_negative1 - Installing replica fails during conncheck if ports not accessible"
		[ -z "$s_short" ] && s_short=$(echo $SLAVE|cut -f1 -d.)
		ls /opt/rhqa_ipa/replica-info-$s_short.$DOMAIN.gpg
		if [ $? -ne 0 ] ; then
			rlFail "ERROR: Replica Package not found"
		else
			rlRun "echo \"nameserver $MASTERIP\" > /etc/resolv.conf"
			rlRun "cat /etc/resolv.conf"
			rlRun "sed -i /$MASTERIP/d /etc/hosts"
			rlRun "echo \"$MASTERIP $MASTER\" >> /etc/hosts"
			rlRun "cat /etc/hosts"

			
			########### HTTP ###############
			rlLog "Testing HTTP TCP and UDP port access"
			rlRun "ssh root@$MASTERIP 'iptables -A INPUT -m tcp -p tcp --dport 80  -j REJECT --reject-with icmp-host-prohibited'"
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg > $tmpout 2>&1" 1
			rlAssertGrep "HTTP Server: Unsecure port (80): FAILED" $tmpout
			rlAssertGrep "Port check failed! Inaccessible port(s): 80 (TCP)" $tmpout
			rlRun "cat $tmpout"
			rlRun "ssh root@$MASTERIP 'iptables -D INPUT -m tcp -p tcp --dport 80  -j REJECT --reject-with icmp-host-prohibited'"

			########### HTTPS ##############
			rlLog "Testing HTTPS TCP port access"
			rlRun "ssh root@$MASTERIP 'iptables -A INPUT -m tcp -p tcp --dport 443 -j REJECT --reject-with icmp-host-prohibited'"
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg > $tmpout 2>&1" 1
			rlAssertGrep "HTTP Server: Secure port (443): FAILED" $tmpout
			rlAssertGrep "Port check failed! Inaccessible port(s): 443 (TCP)" $tmpout
			rlRun "ssh root@$MASTERIP 'iptables -D INPUT -m tcp -p tcp --dport 443 -j REJECT --reject-with icmp-host-prohibited'"

			########### LDAP ##############
			rlLog "Testing LDAP TCP port access"
			rlRun "ssh root@$MASTERIP 'iptables -A INPUT -m tcp -p tcp --dport 389 -j REJECT --reject-with icmp-host-prohibited'"
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg > $tmpout 2>&1" 1
			rlAssertGrep "Directory Service: Unsecure port (389): FAILED" $tmpout
			rlAssertGrep "Port check failed! Inaccessible port(s): 389 (TCP)" $tmpout
			rlRun "ssh root@$MASTERIP 'iptables -D INPUT -m tcp -p tcp --dport 389 -j REJECT --reject-with icmp-host-prohibited'"

			########### LDAPS ##############
			rlLog "Testing LDAPS TCP port access"
			rlRun "ssh root@$MASTERIP 'iptables -A INPUT -m tcp -p tcp --dport 636 -j REJECT --reject-with icmp-host-prohibited'"
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg > $tmpout 2>&1" 1
			rlAssertGrep "Directory Service: Secure port (636): FAILED" $tmpout
			rlAssertGrep "Port check failed! Inaccessible port(s): 636 (TCP)" $tmpout
			rlRun "ssh root@$MASTERIP 'iptables -D INPUT -m tcp -p tcp --dport 636 -j REJECT --reject-with icmp-host-prohibited'"

			########### Kerberos KDC TCP ##############
			rlLog "Testing Kerberos KDC TCP port access"
			rlRun "ssh root@$MASTERIP 'iptables -A INPUT -m tcp -p tcp --dport 88  -j REJECT --reject-with icmp-host-prohibited'"
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg > $tmpout 2>&1" 1
			rlAssertGrep "Kerberos KDC: TCP (88): FAILED" $tmpout
			rlAssertGrep "Port check failed! Inaccessible port(s): 88 (TCP)" $tmpout
			rlRun "ssh root@$MASTERIP 'iptables -D INPUT -m tcp -p tcp --dport 88  -j REJECT --reject-with icmp-host-prohibited'"

			########### Kerberos Kpasswd TCP ##############
			rlLog "Testing Kerberos Kpasswd TCP port access"
			rlRun "ssh root@$MASTERIP 'iptables -A INPUT -m tcp -p tcp --dport 464 -j REJECT --reject-with icmp-host-prohibited'"
			rlRun "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$SLAVE.gpg > $tmpout 2>&1" 1
			rlAssertGrep "Kerberos Kpasswd: TCP (464): FAILED" $tmpout
			rlAssertGrep "Port check failed! Inaccessible port(s): 464 (TCP)" $tmpout
			rlRun "ssh root@$MASTERIP 'iptables -D INPUT -m tcp -p tcp --dport 464 -j REJECT --reject-with icmp-host-prohibited'"

			########### Finally MAKE SURE it's not installed #############
			if [ $(ipactl status|grep RUNNING|wc -l) -gt 0 ]; then
				rlRun "ssh root@$MASTERIP 'ipa-replica-manage -p $ADMINPW del $SLAVE -f'"
				rlRun "ipa-server-install --uninstall -U"
				rlRun "service sssd stop"
				rlRun "rm -f /var/lib/sss/pubconf/kdcinfo.$RELM"
			fi
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

		if [ ! -f /tmp/SKIPMYREVERSEZONECHECK ]; then
			MASTERIPOCT1=$(echo $MASTERIP|cut -f1 -d.)
			rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=801380"
			rlRun "remoteExec root $MASTERIP redhat \"ipa dnszone-find\""
			rlRun "egrep $MASTERIPOCT1.in-addr.arpa. /tmp/remote_exec.out"
			rlRun "cat /tmp/remote_exec.out"
		else
			rlLog "Found file indicating to skip checking for my reverse zone.  Removing file and moving on"
			rlRun "rm /tmp/SKIPMYREVERSEZONECHECK"
		fi

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
			rlRun "ipa-replica-manage -H $MASTER del $SLAVE -p $ADMINPW -f > /tmp/remote_exec.out 2>&1"
			rlRun "dig @$MASTER +short _kerberos-master._tcp.testrelm.com srv|grep $SLAVE" 1
			if [ $? -ne 1 ]; then
				rlFail "BZ 896699 found...ipa-replica-manage -H does not delete DNS SRV records"
			else
				rlPass "BZ 896699 not found"
			fi
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
		if [ $RESTARTDS -eq 1 ]; then
			rlLog "restart dirsrv on master to clear out old kerberos ticket for replica"
			rlRun "remoteExec root $MASTERIP \"service dirsrv restart; service named restart; ipactl status\""
		else
			rlLog "skipping MASTER server dirsrv restart"
		fi

### see if sssd is still running...should be down
		rlLog "verifying https://bugzilla.redhat.com/show_bug.cgi?id=830598"
		if [ $(ps -ef|grep '[s]ssd.*testrelm.com'|wc -l) -gt 0 ]; then
			rlFail "BZ 830598 found...ipa-server-install --uninstall not stopping sssd and seeing ipa-replica-conncheck kinit errors"
			rlLog "stopping sssd separately"
			rlRun "service sssd stop"
		fi
		
### clean up sssd config if left around
		if [ -f /var/lib/sss/pubconf/kdcinfo.$RELM ]; then
			rlRun "cat /var/lib/sss/pubconf/kdcinfo.$RELM"
			rlRun "rm /var/lib/sss/pubconf/kdcinfo.$RELM"
		fi

		rlRun "ls /var/lib/sss/pubconf/kdcinfo.$RELM" 2 "Make sure that uninstall removed /var/lib/sss/pubconf/kdcinfo.$RELM. Bug BZ 829070"
		rlRun "ps -ef|grep -v grep|grep sssd" 1 "Make sure that sssd appears to be stopped as per BZ 830598"
		rlRun "cat /etc/resolv.conf"

		rlLog "Waiting for 1 minute for everything to clear..."
		rlRun "sleep 60"

		miscDNSCheckup_negative
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

miscDNSCheckup_positive(){
	s=$(echo $SLAVE)
	s_short=$(echo $SLAVE|cut -f1 -d.)
	rlLog "Checking for DNS SRV record _kerberos-master._tcp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _kerberos-master._tcp	| grep $s_short"

	rlLog "Checking for DNS SRV record _kerberos._tcp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _kerberos._tcp | grep $s_short"

	rlLog "Checking for DNS SRV record _kerberos._udp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _kerberos._udp | grep $s_short"

	rlLog "Checking for DNS SRV record _kpasswd._tcp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _kpasswd._tcp | grep $s_short"

	rlLog "Checking for DNS SRV record _kpasswd._udp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _kpasswd._udp | grep $s_short"

	rlLog "Checking for DNS SRV record _ldap._tcp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _ldap._tcp | grep $s_short"

	rlLog "Checking for DNS SRV record _ntp._udp for $s"
	rlRun "ipa dnsrecord-show $DOMAIN _ntp._udp | grep $s_short"
}

miscDNSCheckup_negative(){
	s=$(echo $SLAVE)
	s_short=$(echo $SLAVE|cut -f1 -d.)

	rlLog "grabbing ipa dnsrecord-find output from MASTER"
	rlRun "remoteExec root $MASTERIP \"ipa dnsrecord-find $DOMAIN\""
	
	rlLog "Checking for NO DNS SRV record _kerberos-master._tcp for $s"
	rlRun "sed -n '/_kerberos-master._tcp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1
		
	rlLog "Checking for NO DNS SRV record _kerberos._tcp for $s"
	rlRun "sed -n '/_kerberos._tcp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1

	rlLog "Checking for NO DNS SRV record _kerberos._udp for $s"
	rlRun "sed -n '/_kerberos._udp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1

	rlLog "Checking for NO DNS SRV record _kpasswd._tcp for $s"
	rlRun "sed -n '/_kpasswd._tcp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1

	rlLog "Checking for NO DNS SRV record _kpasswd._udp for $s"
	rlRun "sed -n '/_kpasswd._tcp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1

	rlLog "Checking for NO DNS SRV record _ldap._tcp for $s"
	rlRun "sed -n '/_ldap._tcp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1

	rlLog "Checking for NO DNS SRV record _ntp._udp for $s"
	rlRun "sed -n '/_ntp._udp/,/^[[:space:]]*$/p' /tmp/remote_exec.out|grep $s_short" 1

	if [ "$CA2INSTALL" = "true" ]; then
		rlRun "dig @$MASTER +short _kerberos-master._tcp.testrelm.com srv|grep $SLAVE" 1
		if [ $? -ne 1 ]; then
			rlFail "BZ 896699 found...ipa-replica-manage -H does not delete DNS SRV records"
			rlFail "All above SRV checks will fail if this is the case"
		else
			rlPass "BZ 896699 not found"
		fi
	fi
}

# Enable IPv6
diableIpv6(){
	/sbin/sysctl -a | grep ipv6  | grep disable | cut -d\  -f1 | \
	while read var
	do 
		sysctl -w $var=1
		sed -i "/$var = /d" /etc/sysctl.conf
		echo "$var = 1" >> /etc/sysctl.conf
	done
	service ip6tables stop
	rmmod ipv6
}

# Disable IPv6
enableIpv6(){
	/sbin/sysctl -a | grep ipv6  | grep disable | cut -d\  -f1 | \
	while read var
	do 
		sysctl -w $var=0
		sed -i "/$var = /d" /etc/sysctl.conf
		echo "$var = 0" >> /etc/sysctl.conf
	done
	modprobe ipv6
}

