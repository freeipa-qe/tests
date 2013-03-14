###########################################################
#    		INSTALL TESTS				  #
###########################################################

installMaster()
{
   rlPhaseStartTest "Install IPA MASTER Server"
	rlLog "Stopping ntpd service"
	service ntpd stop
	rlLog "Synchronizing time to $NTPSERVER"
	ntpdate $NTPSERVER
	rlRun "configAbrt"
	if [[ "$IPv6SETUP" != "TRUE" ]] ; then
		rlRun "fixHostFile" 0 "Set up /etc/hosts"
		rlRun "fixhostname" 0 "Fix hostname"

	else
		rlRun "fixHostFileIPv6" 0 "Set up /etc/hosts"
                rlRun "fixhostname" 0 "Fix hostname"
		rlRun "fixForwarderIPv6"
		rlRun "rmIPv4addr"
	fi
	rlRun "/bin/cp /etc/resolv.conf /etc/resolv.conf.ipabackup" 0 "backup resolv.conf before IPA changes it"

	if [[ "$SKIPINSTALL" != "TRUE" ]] ; then

	  if [[ "$IPv6SETUP" != "TRUE" ]] ; then
		echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /opt/rhqa_ipa/installipa.bash
		rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
	  else
		echo "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /opt/rhqa_ipa/installipa.bash
                rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
	  fi
        	setenforce 1
		chmod 755 /opt/rhqa_ipa/installipa.bash
        	rlRun "/bin/bash /opt/rhqa_ipa/installipa.bash" 0 "Installing IPA Server"
		# test kinit
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
	fi

	if [ -f /var/log/ipaserver-install.log ]; then
		rhts-submit-log -l /var/log/ipaserver-install.log
	fi
	INSTANCE=$(echo $RELM|sed 's/\./-/g')
	if [ -f /var/log/dirsrv/slapd-$INSTANCE/errors ]; then
		cp /var/log/dirsrv/slapd-$INSTANCE/errors /var/log/dirsrv/slapd-$INSTANCE/errors.quickinstall
		rhts-submit-log -l /var/log/dirsrv/slapd-$INSTANCE/errors.quickinstall
	fi
	if [ -f /var/log/dirsrv/slapd-$INSTANCE/access ]; then
		cp /var/log/dirsrv/slapd-$INSTANCE/access /var/log/dirsrv/slapd-$INSTANCE/access.quickinstall
		rhts-submit-log -l /var/log/dirsrv/slapd-$INSTANCE/access.quickinstall
	fi
		
   rlPhaseEnd

   rlPhaseStartTest "Create Replica Package(s)"
       	for s in $SLAVE; do
               	if [ "$s" != "" ]; then
		        if [[ "$IPv6SETUP" != "TRUE" ]] ; then
                       		# Determine the IP of the slave to be used when creating the replica file.
				# the following does not return ip address is CNAME is alias
	                        #ipofs=$(dig +noquestion $s  | grep $s | grep IN | awk '{print $5}')
				ipofs=$(host -i $s | awk '{ field = $NF }; END{ print field }')
			else
				ipofs=$(nslookup -type=AAAA $s | grep "has AAAA" | awk '{print $5}')
			fi
                        # put the short form of the hostname for server $s into s_short
                        hostname_s=$(echo $s | cut -d. -f1)
                        rlLog "IP of server $s is resolving as $ipofs, using short hostname of $hostname_s" 
                        rlLog "Running: ipa-replica-prepare -p $ADMINPW --ip-address=$ipofs $hostname_s.$DOMAIN"
                        rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$ipofs $hostname_s.$DOMAIN" 0 "Creating replica package"
                        rlRun "service named restart" 0 "Restarting named as work around when adding new reverse zone"
		else
			rlLog "No SLAVES in current recipe set."
              	fi
        done

if [[ "$IPv6SETUP" != "TRUE" ]] ; then
	rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
else
	rlRun "appendEnvIPv6" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
fi
	# stop the firewall
	service iptables stop
	service ip6tables stop
   rlPhaseEnd

}

installSlave()
{
   rlPhaseStartSetup "Install IPA REPLICA Server"
        rlLog "Stopping ntpd service"
        service ntpd stop
        rlLog "Synchronizing time to $NTPSERVER"
        ntpdate $NTPSERVER
	# stop the firewall
        service iptables stop
	service ip6tables stop
        rlRun "AddToKnownHosts $MASTER" 0 "Adding master to known hosts"
	rlRun "configAbrt"
        cd /opt/rhqa_ipa/
        hostname_s=$(hostname -s)
        rlRun "sftp root@$MASTER:/var/lib/ipa/replica-info-$hostname_s.$DOMAIN.gpg" 0 "Get replica package"
        rlLog "Checking for existance of replica gpg file"
        ls /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg
        if [ $? -ne 0 ] ; then
                rlFail "ERROR: Replica Package not found"
        else
       		rlRun "service ntpd stop" 0 "Stopping the ntp server"
		rlLog "Synchronizing clock with: $NTPSERVER"
        	ntpdate $NTPSERVER
		rlLog "SKIPINSTALL: $SKIPINSTALL"	
		if [[ "$SKIPINSTALL" != "TRUE" ]] ; then
			if [[ "$IPv6SETUP" != "TRUE" ]] ; then
				rlRun "fixResolv" 0 "fixing the reoslv.conf to contain the correct nameserver lines"
				rlRun "fixHostFile" 0 "Set up /etc/hosts"
			else
				rlRun "fixResolvIPv6"
				rlRun "fixHostFileIPv6"
			fi

                	rlRun "fixhostname" 0 "Fix hostname"
			DelayUntilMasterReady
			echo "ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg" > /opt/rhqa_ipa/replica-install.bash
                	chmod 755 /opt/rhqa_ipa/replica-install.bash
                	rlLog "EXECUTING: ipa-replica-install -U --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
			rlRun "bash /opt/rhqa_ipa/replica-install.bash" 0 "Replica installation"
			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"

			if [[ "$IPv6SETUP" != "TRUE" ]] ; then
				rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
			else
				rlRun "appendEnvIPv6"
			fi
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

installClient()
{
   rlPhaseStartSetup "Install IPA Client"
        rlLog "Stopping ntpd service"
        service ntpd stop
        rlLog "Synchronizing time to $NTPSERVER"
        ntpdate $NTPSERVER
	rlRun "configAbrt"
	rlLog "SKIPINSTALL: $SKIPINSTALL"
	if [[ "$SKIPINSTALL" != "TRUE" ]] ; then
		if [[ "$IPv6SETUP" != "TRUE" ]] ; then
			rlRun "fixHostFile" 0 "Set up /etc/hosts"
	        	rlRun "fixResolv" 0 "fixing the reoslv.conf to contain the correct nameserver lines"	
		else
			rlRun "fixHostFileIPv6"
			rlRun "fixResolvIPv6"
		fi
        	rlRun "fixhostname" 0 "Fix hostname"
		master_short=`echo $MASTER | cut -d "." -f1`
  		MASTER=$master_short.$DOMAIN
		DelayUntilMasterReady
		rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        	rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Testing kinit as admin"
		if [[ "$IPv6SETUP" != "TRUE" ]] ; then
			rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
		else
			rlRun "appendEnvIPv6"
		fi
	fi

        if [ -f /var/log/ipaclient-install.log ]; then
                rhts-submit-log -l /var/log/ipaclient-install.log
        fi
   rlPhaseEnd
}

