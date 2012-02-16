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

			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

                        # put the short form of the hostname for server $s into s_short
                        hostname_s=$(echo $s | cut -d. -f1)

			# Preparing replica without --ip-address option
			rlRun "cat /etc/hosts"
			rlRun "ipa dnsrecord-add $DOMAIN $hostname_s --a-rec=$SLAVEIP"
			REVERSE_ZONE=`ipa dnszone-find | grep -i "zone name" | grep -i "arpa" | cut -d ":" -f 2`
			LAST_OCTET=`echo $SLAVEIP | cut -d . -f 4`
			rlRun "ipa dnsrecord-add $REVERSE_ZONE $LAST_OCTET --ptr-rec=$hostname_s.$DOMAIN."

                        rlLog "Running: ipa-replica-prepare -p $ADMINPW $hostname_s.$DOMAIN"
			rlRun "ipa-replica-prepare -p $ADMINPW $hostname_s.$DOMAIN"
                        rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"

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

			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
			rlRun "rm -fr /var/lib/ipa/replica-info-*"

			# Preparing replica with --ip-address option
                        rlLog "IP of server $s is resolving as $SLAVEIP, using short hostname of $hostname_s"
                        rlLog "Running: ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN"
                        rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN" 0 "Creating replica package"
                        rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"

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
			rlRun "rm -fr /var/lib/ipa/replica-info-*"

			# Verifying the cert
			rlRun "certutil -L -d /etc/httpd/alias/ -n \"Server-Cert\" -a > /var/tmp/httpdcacert.asc"
			rlRun "openssl x509 -text -in /var/tmp/httpdcacert.asc" 

			rlRun "certutil -L -d /etc/dirsrv/slapd-PKI-IPA/ -n \"Server-Cert\" -a > /var/tmp/dirsrvcacert.asc"
			rlRun "openssl x509 -text -in /var/tmp/dirsrvcacert.asc"

			# Preparing replica with pkcs#12 options

			http_nss_cert_db_pin=`cat /etc/httpd/alias/pwdfile.txt`
			dirsrv_nss_cert_db_pin=`cat /etc/dirsrv/slapd-PKI-IPA/pwdfile.txt`

			rlLog "Executing: /usr/bin/pk12util -o http_pkcs.p12 -d /etc/httpd/alias/ -n Server-Cert"

			expfile=/tmp/pk12util.exp
			expout=/tmp/pk12util.out

			rm -rf $expfile $expout

echo 'set timeout 30
set send_slow {1 .1}' > $expfile
echo "spawn /usr/bin/pk12util -o http_pkcs.p12 -d /etc/httpd/alias/ -n Server-Cert" >> $expfile
echo 'match_max 100000' >> $expfile
echo 'expect "*: "' >> $expfile
echo 'sleep .5' >> $expfile
echo "send -s -- \"$http_nss_cert_db_pin\"" >> $expfile
echo 'send -s -- "\r"' >> $expfile
echo 'expect "*: "' >> $expfile
echo 'sleep .5' >> $expfile
echo "send -s -- \"$ADMINPW\"" >> $expfile
echo 'send -s -- "\r"' >> $expfile
echo 'expect "*: "' >> $expfile
echo 'sleep .5' >> $expfile
echo "send -s -- \"$ADMINPW\"" >> $expfile
echo 'send -s -- "\r"' >> $expfile
echo 'expect eof ' >> $expfile

		        rlLog "Constructed expect file as:"
        	        rlRun "/bin/cat $expfile"
		        rlLog "Executing: /usr/bin/expect $expfile >> $expout 2>&1"
        	        rlRun "/usr/bin/expect $expfile >> $expout 2>&1"
		        rlLog "pk12util command output:"
                	rlRun "/bin/cat $expout"

			rlAssertGrep "pk12util: PKCS12 EXPORT SUCCESSFUL" "$expout"


			rlLog "Executing: /usr/bin/pk12util -o dirsrv_pkcs.p12 -d /etc/dirsrv/slapd-PKI-IPA/ -n Server-Cert"

                        rm -rf $expfile $expout
                        
echo 'set timeout 30
set send_slow {1 .1}' > $expfile
echo "spawn /usr/bin/pk12util -o dirsrv_pkcs.p12 -d /etc/dirsrv/slapd-PKI-IPA/ -n Server-Cert" >> $expfile
echo 'match_max 100000' >> $expfile
echo 'expect "*: "' >> $expfile
echo 'sleep .5' >> $expfile
echo "send -s -- \"$dirsrv_nss_cert_db_pin\"" >> $expfile
echo 'send -s -- "\r"' >> $expfile
echo 'expect "*: "' >> $expfile
echo 'sleep .5' >> $expfile
echo "send -s -- \"$ADMINPW\"" >> $expfile
echo 'send -s -- "\r"' >> $expfile
echo 'expect "*: "' >> $expfile
echo 'sleep .5' >> $expfile
echo "send -s -- \"$ADMINPW\"" >> $expfile
echo 'send -s -- "\r"' >> $expfile
echo 'expect eof ' >> $expfile
        
                        rlLog "Constructed expect file as:"
                        rlRun "/bin/cat $expfile"
                        rlLog "Executing: /usr/bin/expect $expfile >> $expout 2>&1"
                        rlRun "/usr/bin/expect $expfile >> $expout 2>&1"
                        rlLog "pk12util command output:"
                        rlRun "/bin/cat $expout"

                        rlAssertGrep "pk12util: PKCS12 EXPORT SUCCESSFUL" "$expout"


			rlLog "IP of server $s is resolving as $ipofs, using short hostname of $hostname_s"
			rlLog "Executing: ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN --dirsrv_pkcs12=dirsrv_pkcs.p12 --dirsrv_pin=Secret123 --http_pkcs12=http_pkcs.p12 --http_pin=Secret123"
			rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$SLAVEIP $hostname_s.$DOMAIN --dirsrv_pkcs12=dirsrv_pkcs.p12 --dirsrv_pin=Secret123 --http_pkcs12=http_pkcs.p12 --http_pin=Secret123"
                        rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"


                else

                        rlLog "No SLAVES in current recipe set."

                fi
        done

        rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"


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
		rlAssertGrep "forwarders" "/etc/named.conf"
		rlAssertGrep "$DNSFORWARD" "/etc/named.conf"


	# Verifies: Bug 782979 - Replication Failure: Allocation of a new value for range cn=posix ids.

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

	rlRun "ipa user-show $user1"
	rlRun "ipa user-show $user2"

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


installSlave_nf()
{

   rlPhaseStartTest "Installing replica with --no-forwarders option"

        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/resolv.conf"

                echo "ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
                rlAssertNotGrep "forwarders" "/etc/named.conf"
                rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi

   rlPhaseEnd
}

installSlave_nr()
{

   rlPhaseStartTest "Installing replica with --no-reverse option"

        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else

                rlRun "cat /etc/resolv.conf"

                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-reverse -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-reverse -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
                rlAssertNotGrep "forwarders" "/etc/named.conf"
                rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=757644"
		rlRun "ipa dnszone-find | grep in-addr.arpa." 1

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
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
		rlRun "dig $SLAVE"

		rlRun "cat /etc/hosts"


                echo "ipa-replica-install -U --setup-dns --no-forwarders --no-host-dns -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                chmod 755 /dev/shm/replica-install.bash
                rlLog "EXECUTING: ipa-replica-install -U --setup-dns --no-forwarders --no-host-dns -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
                rlRun "/bin/bash /dev/shm/replica-install.bash" 0 "Replica installation"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
                rlAssertNotGrep "forwarders" "/etc/named.conf"
                rlAssertNotGrep "$DNSFORWARD" "/etc/named.conf"

		rlRun "service ipa status"


		rlRun "mv -f /etc/resolv.conf_backup /etc/resolv.conf" 0 "Restoring /etc/resolv.conf"

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
                rlAssertGrep "forwarders" "/etc/named.conf"
                rlAssertGrep "$DNSFORWARD" "/etc/named.conf"

                rlRun "ipa dnszone-find | grep in-addr.arpa."

                rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi

   rlPhaseEnd
}


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


	rlRun "ipa-replica-manage list"
	rlRun "remoteExec root $MASTERIP redhat \"ipa-replica-manage del $SLAVE\""

	sleep 10

	rlLog "Executing: ipa-server-install --uninstall -U"
	rlRun "ipa-server-install --uninstall -U"

}

