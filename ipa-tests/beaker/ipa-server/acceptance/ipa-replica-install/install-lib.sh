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
    ipaddr=$(hostname -I | awk '{print $1}') #Added to get ip on Fedora and RHEL using same command
    rlLog "Ip address is $ipaddr"

    # Now, fix the hosts file to work with IPA.
    hostname=$(hostname)
    hostname_s=$(hostname -s)
    cat /etc/hosts | grep -v ^$ipaddr > /dev/shm/hosts
 
    # Remove any existing hostname entries from the hosts file
    sed -i s/$hostname//g /dev/shm/hosts
    sed -i s/$hostname_s//g /dev/shm/hosts
    echo "$ipaddr $hostname_s.$DOMAIN $hostname_s" >> /dev/shm/hosts
    cat /dev/shm/hosts > /etc/hosts
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
    #cat /etc/hosts | grep -v ^$ipv6addr > /dev/shm/hosts

    # Remove any existing hostname entries from the hosts file
    # sed -i s/$hostname//g /dev/shm/hosts
    # sed -i s/$hostname_s//g /dev/shm/hosts
    echo "$ipv6addr $hostname_s.$DOMAIN $hostname_s" >> /dev/shm/hosts
    cat /dev/shm/hosts > /etc/hosts
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
    cat /etc/sysconfig/network | grep -v $hostname_s > /dev/shm/network
    echo "HOSTNAME=$hostname_s.$DOMAIN" >> /dev/shm/network
    mv /etc/sysconfig/network /etc/sysconfig/network-ipabackup
    cat /dev/shm/network > /etc/sysconfig/network
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
   ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | awk '{print $5}')
   rlLog "MASTER IP address is $ipaddr"
   sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
   echo "nameserver $ipaddr" >> /etc/resolv.conf

   # get the Slave's IP address
   if [ "$SLAVE" != "" ]; then
      slaveipaddr=$(dig +noquestion $SLAVE  | grep $SLAVE | grep IN | awk '{print $5}')
      rlLog "SLAVE IP address is $slaveipaddr"
      echo "nameserver $slaveipaddr" >> /etc/resolv.conf
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
   sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
   echo "nameserver $ipv6addr" >> /etc/resolv.conf

   # get the Slave's IP address
   if [ "$SLAVE" != "" ]; then
      slaveipv6addr=$(nslookup -type=AAAA $SLAVE | grep "has AAAA" | awk '{print $5}')
      rlLog "SLAVE IPv6 address is $slaveipv6addr"
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
  ipaddr=$(dig +noquestion $MASTER  | grep A |grep $MASTER | grep IN | awk '{print $5}')
  # Adding MASTER and SLAVE bits to env.sh
  master_short=`echo $MASTER | cut -d "." -f1`
  MASTER=$master_short.$DOMAIN
  echo "export MASTER=$MASTER" >> /dev/shm/env.sh
  echo "export MASTERIP=$ipaddr" >> /dev/shm/env.sh
  if [ "$SLAVE" != "" ]; then
	slave_short=`echo $SLAVE | cut -d "." -f1`
  	SLAVE=$slave_short.$DOMAIN
        slaveipaddr=$(dig +noquestion $SLAVE  | grep A | grep $SLAVE | grep IN | awk '{print $5}')
	echo "export SLAVE=$SLAVE" >> /dev/shm/env.sh
        echo "export SLAVEIP=$slaveipaddr" >> /dev/shm/env.sh
  fi
  if [ "$CLIENT" != "" ]; then
	client_short=`echo $CLIENT | cut -d "." -f1`
	CLIENT=$client_short.$DOMAIN
	echo "export CLIENT=$CLIENT" >> /dev/shm/env.sh
  fi

  if [ "$CLIENT2" != "" ]; then
        client2_short=`echo $CLIENT2 | cut -d "." -f1`
        CLIENT2=$client2_short.$DOMAIN
        echo "export CLIENT2=$CLIENT2" >> /dev/shm/env.sh
  fi


  rlLog "Contents of env.sh are"
  output=`cat /dev/shm/env.sh`
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
  echo "export MASTER=$MASTER" >> /dev/shm/env.sh
  echo "export MASTERIP=$ipv6addr" >> /dev/shm/env.sh
  if [ "$SLAVE" != "" ]; then
        slave_short=`echo $SLAVE | cut -d "." -f1`
        SLAVE=$slave_short.$DOMAIN
        slaveipv6addr=$(nslookup -type=AAAA $SLAVE | grep "has AAAA" | awk '{print $5}')
        echo "export SLAVE=$SLAVE" >> /dev/shm/env.sh
        echo "export SLAVEIP=$slaveipv6addr" >> /dev/shm/env.sh
  fi
  if [ "$CLIENT" != "" ]; then
        client_short=`echo $CLIENT | cut -d "." -f1`
        CLIENT=$client_short.$DOMAIN
        echo "export CLIENT=$CLIENT" >> /dev/shm/env.sh
  fi

  if [ "$CLIENT2" != "" ]; then
        client2_short=`echo $CLIENT2 | cut -d "." -f1`
        CLIENT2=$client2_short.$DOMAIN
        echo "export CLIENT2=$CLIENT2" >> /dev/shm/env.sh
  fi

  rlLog "Contents of env.sh are"
  output=`cat /dev/shm/env.sh`
  rlLog "$output"
}

######################################
#	fix dns forwarder	     #
######################################
fixForwarderIPv6()
{
  ipv6addr=$(ifconfig $currenteth | grep "inet6 " | grep -E 'Scope:Site|Scope:Global' | awk '{print $3}' | awk -F / '{print $1}' | head -1)
  sed -i "s/10.14.63.12/$ipv6addr/g" /dev/shm/env.sh
  . /dev/shm/env.sh
  rlRun "cat /dev/shm/env.sh"
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
   PUBKEY=/dev/shm/id_rsa_global.pub
   PRIVATEKEY=/dev/shm/id_rsa_global
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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# replicaDel
# Usage: replicaDel
# 
# This constructs a expect file which is then executed so as to execute 
# any remote command on the specified hostname.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

replicaDel() {

expfile=/tmp/replicaDel.exp
expout=/tmp/replicaDel.out

rm -rf $expfile $expout

rm -rf $expfile $expout

echo 'set timeout 30
set send_slow {1 .1}' > $expfile
        echo "spawn ssh -l $1 $2" >> $expfile
        echo 'match_max 100000' >> $expfile
        echo 'sleep 3' >> $expfile
        echo 'expect "*: "' >> $expfile
        echo "send \"$3\"" >> $expfile
        echo 'send "\r"' >> $expfile
        echo 'sleep 3' >> $expfile
        echo 'expect "*: "' >> $expfile
        echo "send \"$4\"" >> $expfile
        echo 'send "\r"' >> $expfile
        echo 'expect eof ' >> $expfile

                rlRun "/usr/bin/expect $expfile >> $expout 2>&1"

        # for verbosity
        rlRun "cat $expfile"
        rlRun "cat $expout"
}

