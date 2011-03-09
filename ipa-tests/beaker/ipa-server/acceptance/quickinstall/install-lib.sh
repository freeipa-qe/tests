######################################
#   	packages install             #
######################################
installPkgs()
{
   SERVER_PACKAGES="ipa-server bind bind-dyndb-ldap expect"
   CLIENT_PACKAGES="ipa-admintools ipa-client httpd mod_nss mod_auth_kerb 389-ds-base expect"
   rc=0

   echo $MASTER | grep $HOSTNAME
   if [ $? -eq 0 ] ; then
	rlLog "Machine is a MASTER"
	rlLog "Installing server packages"
	yum -y install $SERVER_PACKGES
   	for item in $SERVER_PACKAGES ; do
   		rpm -qa | grep $item
        	if [ $? -eq 0 ] ; then
        		rlLog "$item package is installed"
        	else
        		rlLog "ERROR: $item package is NOT installed"
        		rc=1
        	fi
   	done
   else
   	rlLog "Machine in recipe in not a MASTER"
   fi

   echo $SLAVE | grep $HOSTNAME
   if [ $? -eq 0 ] ; then
        rlLog "Machine is a SLAVE"
 	rlLog "Installing server packages"
	yum -y install $SERVER_PACKAGES
        for item in $SERVER_PACKAGES ; do
                rpm -qa | grep $item
                if [ $? -eq 0 ] ; then
                        rlLog "$item package is installed"
                else
                        rlLog "ERROR: $item package is NOT installed"
                        rc=1
                fi
        done
   else
        rlLog "Machine in recipe in not a SLAVE"
   fi 

   echo $CLIENT | grep $HOSTNAME
        if [ $? -eq 0 ] ; then
		rlLog "Machine is a CLIENT"
		rlLog "installing client packages"
		yum -y install $CLIENT_PACKAGES
                for item in $CLIENT_PACKAGES ; do
                rpm -qa | grep $item
                        if [ $? -eq 0 ] ; then
                                rlLog "$item package is installed"
                        else
                                rlLog "ERROR: $item package is NOT installed"
                                rc=1
                        fi
                done
        else
                rlLog "Machine in recipe in not a CLIENT"
        fi

   return $rc
}

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
    ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
    rlLog "Ip address is $ipaddr"

    # Now, fix the hosts file to work with IPA.
    hostname=$(hostname)
    hostname_s=$(hostname -s)
    cat /etc/hosts | grep -v ^$ipaddr > /dev/shm/hosts
 
    # Remove any existing hostname entries from the hosts file
    sed -i s/$hostname//g /dev/shm/hosts
    sed -i s/$hostname_s//g /dev/shm/hosts
    echo "$ipaddr $hostname_s.$DOMAIN $hostname $hostname_s" >> /dev/shm/hosts
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
  ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | awk '{print $5}')
  # Adding MASTER and SLAVE bits to env.sh
  echo "export MASTER=$MASTER" >> /dev/shm/env.sh
  echo "export MASTERIP=$ipaddr" >> /dev/shm/env.sh
  echo "export SLAVE=$SLAVE" >> /dev/shm/env.sh
  echo "export CLIENT=$CLIENT" >> /dev/shm/env.sh
  rlLog "Contents of env.sh are"
  output=`cat /dev/shm/env.sh`
  rlLog "$output"

  return
}


