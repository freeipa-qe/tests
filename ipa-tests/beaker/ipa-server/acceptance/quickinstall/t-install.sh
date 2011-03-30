###########################################################
#    		INSTALL TESTS				  #
###########################################################

installMaster()
{
   rlPhaseStartTest "Install IPA MASTER Server"
	rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
	rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
	rlRun "fixHostFile" 0 "Set up /etc/hosts"
	rlRun "fixhostname" 0 "Fix hostname"
	if [[ "$SKIPINSTALL" != "TRUE" ]] ; then
		echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /dev/shm/installipa.bash
		rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        	setenforce 1
		chmod 755 /dev/shm/installipa.bash
        	rlRun "/bin/bash /dev/shm/installipa.bash" 0 "Installing IPA Server"
		# test kinit
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
	fi

	if [ -f /var/log/ipaserver-install.log ]; then
        	rhts-submit-log -l /var/log/ipaserver-install.log
        fi
   rlPhaseEnd

   rlPhaseStartTest "Create Replica Package(s)"
       	for s in $SLAVE; do
               	if [ "$s" != "" ]; then
                       	# Determine the IP of the slave to be used when creating the replica file.
                        ipofs=$(dig +noquestion $s  | grep $s | grep IN | awk '{print $5}')
                        # put the short form of the hostname for server $s into s_short
                        hostname_s=$(echo $s | cut -d. -f1)
                        rlLog "IP of server $s is resolving as $ipofs, using short hostname of $hostname_s" 
                        rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$ipofs $hostname_s.$DOMAIN" 0 "Creating replica package"
		else
			rlLog "No SLAVES in current recipe set."
              	fi
        done

	rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
	# stop the firewall
	service iptables stop
   rlPhaseEnd

}

installSlave()
{
   rlPhaseStartSetup "Install IPA REPLICA Server"
	rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
	# stop the firewall
        service iptables stop
	rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"
        cd /dev/shm/
        hostname_s=$(hostname -s)
        rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Get replica package"
        rlLog "Checking for existance of replica gpg file"
        ls /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else
       		rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
        	rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
		rlLog "SKIPINSTALL: $SKIPINSTALL"	
		if [[ "$SKIPINSTALL" != "TRUE" ]] ; then
			rlRun "fixHostFile" 0 "Set up /etc/hosts"
                	rlRun "fixhostname" 0 "Fix hostname"
                	rlRun "fixResolv" 0 "fixing the reoslv.conf to contain the correct nameserver lines"
			echo "ipa-replica-install --setup-dns -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg" > /dev/shm/replica-install.bash
                	chmod 755 /dev/shm/replica-install.bash
                	rlLog "EXECUTING: ipa-replica-install -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "bash /dev/shm/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
			rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
		fi
	fi

        if [ -f /var/log/ipareplica-install.log ]; then
                rhts-submit-log -l /var/log/ipareplica-install.log
        fi
	# stop the firewall
	service iptables stop
   rlPhaseEnd
 
}

installClient()
{
   rlPhaseStartSetup "Install IPA Client"
	rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
	rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with corp time server"
	rlLog "SKIPINSTALL: $SKIPINSTALL"
	if [[ "$SKIPINSTALL" != "TRUE" ]] ; then
		rlRun "fixHostFile" 0 "Set up /etc/hosts"
        	rlRun "fixhostname" 0 "Fix hostname"
        	rlRun "fixResolv" 0 "fixing the reoslv.conf to contain the correct nameserver lines"	
		master_short=`echo $MASTER | cut -d "." -f1`
  		MASTER=$master_short.$DOMAIN
		rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        	rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
	fi

        if [ -f /var/log/ipaclient-install.log ]; then
                rhts-submit-log -l /var/log/ipaclient-install.log
        fi
   rlPhaseEnd
}

