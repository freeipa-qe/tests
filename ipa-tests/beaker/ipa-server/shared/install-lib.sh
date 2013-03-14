
### WARNING
#  This file is mostly depricated, it is still used by the install-server-cli test
#  Please do not use this file in new tests
# Michael


######################################
#  	fix /etc/hosts		     #
######################################
fixHostFile()
{
    HOSTSFILE="/etc/hosts"
    rm -f $HOSTSFILE.ipabackup
    cp -af $HOSTSFILE $HOSTSFILE.ipabackup
    
    # figure out what my active eth is from the machine's route
    currenteth=$(route | grep ^default | awk '{print $8}')

    # get the ip address of that interface
    #ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
	if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
		ipaddr=$(hostname -i|awk '{print $1}')
	else
		ipaddr=$(hostname -I | awk '{print $1}')
	fi
    rlLog "Ip address is $ipaddr"

    # Now, fix the hosts file to work with IPA.
    hostname=$(hostname)
    hostname_s=$(hostname -s)
    cat /etc/hosts | grep -v ^$ipaddr > /opt/rhqa_ipa/hosts
 
    # Remove any existing hostname entries from the hosts file
    sed -i s/$hostname//g /opt/rhqa_ipa/hosts
    sed -i s/$hostname_s//g /opt/rhqa_ipa/hosts
    echo "$ipaddr $hostname_s.$DOMAIN $hostname_s" >> /opt/rhqa_ipa/hosts
    cat /opt/rhqa_ipa/hosts > /etc/hosts
    rlLog "Hosts file contains:"
    output=`cat /etc/hosts`
    rlLog "$output"

    return
}

######################################
#	fix /etc/hosts ipv6	     #
######################################
fixHostFileIPv6()
{
    HOSTSFILE="/etc/hosts"
    rm -f $HOSTSFILE.ipabackup
    cp -af $HOSTSFILE $HOSTSFILE.ipaipv6backup

    # figure out what my active eth is from the machine's route
    currenteth=$(/sbin/ip -6 route show | grep ^default | awk '{print $5}' | head -1)

    # get the ip address of that interface
    ipv6addr=$(ifconfig $currenteth | grep "inet6 " | grep -E 'Scope:Site|Scope:Global' | awk '{print $3}' | awk -F / '{print $1}' | head -1)
    rlLog "IPv6 address is $ipv6addr"

    # Now, fix the hosts file to work with IPA.
    hostname=$(hostname)
    hostname_s=$(hostname -s)
    #cat /etc/hosts | grep -v ^$ipv6addr > /opt/rhqa_ipa/hosts

    # Remove any existing hostname entries from the hosts file
    # sed -i s/$hostname//g /opt/rhqa_ipa/hosts
    # sed -i s/$hostname_s//g /opt/rhqa_ipa/hosts
    echo "$ipv6addr $hostname_s.$DOMAIN $hostname_s" >> /opt/rhqa_ipa/hosts
    cat /opt/rhqa_ipa/hosts > /etc/hosts
    rlLog "Hosts file contains:"
    output=`cat /etc/hosts`
    rlLog "$output"

    return
}


######################################
#       fix hostname                 #
######################################
fixhostname()
{
    hostname_s=$(hostname -s)

    # Fix hostname
    rlRun "hostname $hostname_s.$DOMAIN"
    hostname $hostname_s.$DOMAIN
    cat /etc/sysconfig/network | grep -v $hostname_s > /opt/rhqa_ipa/network
    echo "HOSTNAME=$hostname_s.$DOMAIN" >> /opt/rhqa_ipa/network
    mv /etc/sysconfig/network /etc/sysconfig/network-ipabackup
    cat /opt/rhqa_ipa/network > /etc/sysconfig/network
    rlLog "/etc/sysconfig/network contains:"
    output=`cat /etc/sysconfig/network`
    rlLog "$output"

    return
}


#####################################
#  	fix resolv.conf             #
#####################################
fixResolv()
{
   rlLog "Fixing resolv.con to point to master"

   # get the Master's IP address
   #ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | awk '{print $5}')
   ipaddr=$(host -i $MASTER | awk '{ field = $NF }; END{ print field }')
   rlLog "MASTER IP address is $ipaddr"
   cp /etc/resolv.conf /etc/resolv.conf.ipabackup
   sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
   echo "nameserver $ipaddr" >> /etc/resolv.conf

   # get the Slave's IP address
   if [ "$SLAVE" != "" ]; then
      #cp /etc/resolv.conf /etc/resolv.conf.ipabackup
      for s in $SLAVE; do
         #slaveipaddr=$(dig +noquestion $SLAVE  | grep $SLAVE | grep IN | awk '{print $5}')
         slaveipaddr=$(host -i $s | awk '{ field = $NF }; END{ print field }')
         rlLog "SLAVE IP address is $slaveipaddr"
         echo "nameserver $slaveipaddr" >> /etc/resolv.conf
      done
   fi

   rlLog "/etc/resolv.conf contains:"
   output=`cat /etc/resolv.conf`
   rlLog "$output"

   return
}


#####################################
#       fix resolv.conf ipv6        #
#####################################
fixResolvIPv6()
{
   rlLog "Fixing resolv.conf to point to master for IPv6"

   # get the Master's IP address
   ipv6addr=$(nslookup -type=AAAA $MASTER | grep "has AAAA" | awk '{print $5}')
   rlLog "MASTER IP address is $ipv6addr"
   cp /etc/resolv.conf /etc/resolv.conf.ipabackup
   sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
   echo "nameserver $ipv6addr" >> /etc/resolv.conf

   # get the Slave's IP address
   if [ "$SLAVE" != "" ]; then
      slaveipv6addr=$(nslookup -type=AAAA $SLAVE | grep "has AAAA" | awk '{print $5}')
      rlLog "SLAVE IPv6 address is $slaveipv6addr"
      cp /etc/resolv.conf /etc/resolv.conf.ipabackup
      echo "nameserver $slaveipv6addr" >> /etc/resolv.conf
   fi

   rlLog "/etc/resolv.conf contains:"
   output=`cat /etc/resolv.conf`
   rlLog "$output"

   return
}



######################################
#       Append env.sh                #
######################################
appendEnv()
{
  #ipaddr=$(dig +noquestion $MASTER  | grep A |grep $MASTER | grep IN | awk '{print $5}')
  ipaddr=$(host -i $MASTER | awk '{ field = $NF }; END{ print field }')
  # Adding MASTER and SLAVE bits to env.sh
  master_short=`echo $MASTER | cut -d "." -f1`
  MASTER=$master_short.$DOMAIN
  echo "export MASTER=$MASTER" >> /opt/rhqa_ipa/env.sh
  echo "export MASTERIP=$ipaddr" >> /opt/rhqa_ipa/env.sh
  if [ "$SLAVE" != "" ]; then
    NEWSLAVE=""
    for s in $SLAVE; do
      NEWSLAVE="$NEWSLAVE $(echo $s|cut -f1 -d.|sed s/$/.$DOMAIN/)"
    done
	NEWSLAVE=$(echo $NEWSLAVE) # strip initial space
	slave_short=`echo $SLAVE | cut -d "." -f1`
  	SLAVE=$slave_short.$DOMAIN
    #slaveipaddr=$(dig +noquestion $SLAVE  | grep A | grep $SLAVE | grep IN | awk '{print $5}')
	slaveipaddr=$(host -i $SLAVE | awk '{ field = $NF }; END{ print field }')
	SLAVE="$NEWSLAVE"
	echo "export SLAVE=\"$SLAVE\"" >> /opt/rhqa_ipa/env.sh
    echo "export SLAVEIP=$slaveipaddr" >> /opt/rhqa_ipa/env.sh
  fi
  if [ "$CLIENT" != "" ]; then
	client_short=`echo $CLIENT | cut -d "." -f1`
	CLIENT=$client_short.$DOMAIN
	echo "export CLIENT=$CLIENT" >> /opt/rhqa_ipa/env.sh
  fi

  if [ "$CLIENT2" != "" ]; then
        client2_short=`echo $CLIENT2 | cut -d "." -f1`
        CLIENT2=$client2_short.$DOMAIN
        echo "export CLIENT2=$CLIENT2" >> /opt/rhqa_ipa/env.sh
  fi


  rlLog "Contents of env.sh are"
  output=`cat /opt/rhqa_ipa/env.sh`
  rlLog "$output"
}

######################################
#       Append env.sh for ipv6       #
######################################
appendEnvIPv6()
{
  ipv6addr=$(nslookup -type=AAAA $MASTER | grep "has AAAA" | awk '{print $5}')
  # Adding MASTER and SLAVE bits to env.sh
  master_short=`echo $MASTER | cut -d "." -f1`
  MASTER=$master_short.$DOMAIN
  echo "export MASTER=$MASTER" >> /opt/rhqa_ipa/env.sh
  echo "export MASTERIP=$ipv6addr" >> /opt/rhqa_ipa/env.sh
  if [ "$SLAVE" != "" ]; then
        NEWSLAVE=""
        for s in $SLAVE; do
            NEWSLAVE="$NEWSLAVE $(echo $s|cut -f1 -d.|sed s/$/.$DOMAIN/)"
        done
		NEWSLAVE=$(echo $NEWSLAVE) # strip initial space
        slave_short=`echo $SLAVE | cut -d "." -f1`
        SLAVE=$slave_short.$DOMAIN
        slaveipv6addr=$(nslookup -type=AAAA $SLAVE | grep "has AAAA" | awk '{print $5}')
        SLAVE="$NEWSLAVE"
        echo "export SLAVE=\"$SLAVE\"" >> /opt/rhqa_ipa/env.sh
        echo "export SLAVEIP=$slaveipv6addr" >> /opt/rhqa_ipa/env.sh
  fi
  if [ "$CLIENT" != "" ]; then
        client_short=`echo $CLIENT | cut -d "." -f1`
        CLIENT=$client_short.$DOMAIN
        echo "export CLIENT=$CLIENT" >> /opt/rhqa_ipa/env.sh
  fi

  if [ "$CLIENT2" != "" ]; then
        client2_short=`echo $CLIENT2 | cut -d "." -f1`
        CLIENT2=$client2_short.$DOMAIN
        echo "export CLIENT2=$CLIENT2" >> /opt/rhqa_ipa/env.sh
  fi

  rlLog "Contents of env.sh are"
  output=`cat /opt/rhqa_ipa/env.sh`
  rlLog "$output"
}

######################################
#	fix dns forwarder	     #
######################################
fixForwarderIPv6()
{
  ipv6addr=$(ifconfig $currenteth | grep "inet6 " | grep -E 'Scope:Site|Scope:Global' | awk '{print $3}' | awk -F / '{print $1}' | head -1)
  sed -i "s/10.14.63.12/$ipv6addr/g" /opt/rhqa_ipa/env.sh
  . /opt/rhqa_ipa/env.sh
  rlRun "cat /opt/rhqa_ipa/env.sh"
  rlLog "fixing DNSFORWARD in env.sh"
}

######################################
#	remove ipv4 addr	     #
######################################
rmIPv4addr()
{
  ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | awk '{print $5}')
  ipv4gw=$(route -n | awk '{print $2}' | tail -n 1)
  currenteth=$(route | grep ^default | awk '{print $8}')
  /sbin/ip -4 addr del $ipaddr dev $currenteth
}

#################################################################
#  SetUpAuthKeys ... all hosts will have the same public and    #
#    private key for the root user                              #
#################################################################
SetUpAuthKeys()
{
   PUBKEY=/opt/rhqa_ipa/id_rsa_global.pub
   PRIVATEKEY=/opt/rhqa_ipa/id_rsa_global
   SSHROOT=/root/.ssh/
   PUBKEYFILE=$SSHR0OT/id_rsa
   AUTHKEYFILE=$SSHROOT/authorized_keys
   ls $SSHROOT
   if [ $? -ne 0 ] ; then
        make dir $SSHROOT
   else
        rlLog "/root/.ssh/ directory exists"
   fi

   # set up authorized keys
   cp -f $PUBKEY $PUBKEYFILE
   cat $PUBKEY >> $AUTHKEYFILE
   sed -i -e "s/localhost/$MASTER/g" $AUTHKEYFILE

   for s in $SLAVE ; do
        cat $PUBKEY  >> $SSHROOT/authorized_keys
        sed -i -e "s/localhost/$s/g" $AUTHKEYFILE
   done

   for s in $CLIENT ; do
        cat $PUBKEY  >> $SSHROOT/authorized_keys
        sed -i -e "s/localhost/$s/g" $AUTHKEYFILE
   done

   rlLog "Authorized Keys are:"
   authkeys=`cat $AUTHKEYFILE`
   rlLog "$authkeys"

   # copy corresponding public key
   cp -f $PUBKEY $PUBKEYFILE
   rlLog "Private key is:"
   privatekey=`cat $SSHROOT/id_rsa`
   rlLog "$privatekey"

}

##########################################################
#  SetUpKnowHosts  ... all hosts will share the same key #
##########################################################
SetUpKnownHosts()
{
  KNOWNHOSTS=/root/.ssh/known_hosts
  for s in $CLIENT; do
  	if [ "$s" != "" ]; then
  		AddToKnownHosts $s
  	fi
  done
  for s in $MASTER; do
  	if [ "$s" != "" ]; then
  		AddToKnownHosts $s
  	fi
  done
  for s in $SLAVE; do
  	if [ "$s" != "" ]; then
  		AddToKnownHosts $s
  	fi
  done

   rlLog "Known Hosts are:"
   knownhosts=`cat $KNOWNHOSTS`
   rlLog "$knownhosts"
}

#####################
# config abrt
#####################
configAbrt()
{
cat /etc/redhat-release | grep 5
if [ $? -eq 0 ] ; then
        rlLog "configAbrt : Machine is a RHEL 5 machine - no abrt"
else

	hostname_s=`hostname -s`
	for rpm in abrt-tui abrt-addon-ccpp libreport-plugin-mailx; do
        	rlCheckRpm "$rpm"
                	if [ $? -ne 0 ]; then
                        	rlRun "yum install -y $rpm"
                	fi
        done

	if [ -z "$JOBID" ]; then 
		eval $(echo $(grep JOBID /etc/motd))
	fi

cat > /etc/abrt/abrt-action-save-package-data.conf << EOF
OpenGPGCheck = no
BlackList = nspluginwrapper, valgrind, strace, mono-core
ProcessUnpackaged = yes
BlackListedPaths = /usr/share/doc/*, */example*, /usr/bin/nspluginviewer, /usr/lib/xulrunner-*/plugin-container
EOF

cat > /etc/libreport/plugins/mailx.conf << EOF
Subject=CRASH ALERT: Crash detected in ipa automation [Beaker Job: $JOBID].
EmailFrom=root@$hostname_s
EmailTo=seceng-idm-qe-list@redhat.com
SendBinaryData=no
EOF

	rlRun "service abrtd restart"
fi
}

#########################################
# DelayUntilMasterReady 
#  This sub delays for upto 14 minuites while it waits for the Master to finish installs.
#########################################
DelayUntilMasterReady()
{
	delayinterval=120
	let maxcount=($delayinterval/120)*7
	count=0
	done=1
	ls /usr/bin/nmap
	while [ $count -lt $maxcount ]; do
		/usr/bin/nmap $MASTER | /bin/grep kerberos-adm
		if [ $? -ne 0 ]; then
			rlLog "Master $MASTER does not appear to be up yet, delaying $delayinterval seconds.";
			rlLog "outputting nmap $MASTER"
			/usr/bin/nmap $MASTER
			sleep $delayinterval;
			let count=$count+1;
		else
			rlPass "Master $MASTER is up! Sleeping for $delayinterval, then continuing."
			sleep $delayinterval;
			let count=$maxcount+1;
		fi
		if [ $count -eq $maxcount ]; then
			let mcount=$delayinterval*$maxcount
			rlFail "FAIL - Master $MASTER did not bring up kerberos in $mcount seconds"
		fi
	done
}

