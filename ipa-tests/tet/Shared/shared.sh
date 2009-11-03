# Shared subs needed by most tests
# eval_vars(servername) - pass the servername to this sub to expand the servername into hostname, fullhostname, OS, etc.
# setup_ssh_keys(servername) - install a ssh key into the authorized_keys on the remote server. Create a local key if needed
#               It's okay to run this over and over again, if it's already been run, then this sub will complete without
#               interaction or error.
eval_vars()
{
	#if [ "$DSTET_DEBUG" = "y" ]; then set -x; env; fi
        x=\$HOSTNAME_$1
        HOSTNAME=`eval echo $x`
        FULLHOSTNAME=`host $HOSTNAME | grep -v IPv6 | awk '{print $1}'`
	if [ "$FULLHOSTNAME" == "Host" ]; then
		echo "ERROR! FullHostname resolved to $FULLHOSTNAME. Please make sure that you have all of your domains in the search section of your resolv.conf"
		tet_result FAIL
		return 1;
	fi
	IP=`host $FULLHOSTNAME | grep -v IPv6 | awk '{print $4}'`
        x=\$LDAP_PORT_$1
        LDAP_PORT=`eval echo $x`
        x=\$LDAPS_PORT_$1
        LDAPS_PORT=`eval echo $x`
        x=\$SERVER_INSTALL_DIR_$1
        INSTALL_DIR=`eval echo $x`
        x=\$CHANGELOG_DIR_$1
        CHANGELOG_DIR=`eval echo $x`
        if [ "$CHANGELOG_DIR" = "" ]; then
                CHANGELOG_DIR=$INSTALL_DIR/changelogdb
        fi
        x=\$FILE_${1}_IS_ALIVE
        FILE_SERVER_IS_ALIVE=`eval echo $x`
        x=\$REPLICA_ID_$1
        REPLICA_ID=`eval echo $x`
        x=\$OS_$1
        OS=`eval echo $x`
        x=\$OS_VER_$1
        OS_VER=`eval echo $x`
	x=\$REPO_$1
	REPO=`eval echo $x`

	x=\$PASSWORD_$1
	PASSWORD=`eval echo $x`
        export HOSTNAME FULLHOSTNAME OS REPO LDAP_PORT LDAPS_PORT PASSWORD
}

# Runs ntpdate $NTPSERVER on the machine specified in $1
set_date()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	ssh $1 "date;/etc/init.d/ntpd stop;ntpdate -b $NTPSERVER"&
	return 0
}

# This is used to fix the bind configuration on the first server after a ipa-server-install 
FixBindServer()
{

	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars $1

	# Backing up DNS server config on Server
#	ssh root@$FULLHOSTNAME "cat /etc/named.conf > /etc/named.conf.original; cat /etc/named.conf > /etc/named.conf.new;"
#	if [ $? -ne 0 ]; then
#		echo "ERROR! bind fix failed"
#		tet_result FAIL
#		return $ret
#	fi 

	# Put forwarding DNS server into DNS
#	ssh root@$FULLHOSTNAME "sed -i s/dump-file/'forwarders { $DNSMASTER; }; dump-file'/g  /etc/named.conf.new"
#	if [ $? -ne 0 ]; then
#		echo "ERROR! bind fix failed"
#		tet_result FAIL
#		return $ret
#	fi 

	# Copying new DNS config to it's place on the server, and restarting DNS
#	ssh root@$FULLHOSTNAME "mv /etc/named.conf /etc/named.conf.old;cp /etc/named.conf.new /etc/named.conf;/etc/init.d/named restart"
#	if [ $? -ne 0 ]; then
#		echo "ERROR! bind fix failed"
#		tet_result FAIL
#		return $ret
#	fi 

	# Restart bind on M1 in to ensure that everythign is working.
	eval_vars M1
	ssh root@$FULLHOSTNAME "/etc/init.d/named restart"
	if [ $? -ne 0 ]; then
		echo "ERROR! Restart of bind on $FULLHOSTNAME failed"
		tet_result FAIL
		return $ret
	fi 
	eval_vars $1

	# Now we need to populate the ldap dns with all of the new server and client ip's 
	# Add reverse entry of M1 to the DNS server
	# Kiniting as admin  on the servser first
	KinitAs $1 $DS_USER $KERB_MASTER_PASS 
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $DS_USER on $1 fialed"
		tet_result FAIL
		return 1
	fi
	thisserver=$FULLHOSTNAME
	eval_vars M1
	ssh root@$thisserver "ipa dns-add-rr $DNS_DOMAIN $IP PTR \"$HOSTNAME\""	
	# Add forward and reverse entries for all servers and clients
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			# Make sure that we are not trying to add the server that we are working on twice
			if [ "$s" != "$1" ]; then 
				eval_vars $s	
				# Derive the reverse zone
				oct1=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $1 }')
				oct2=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $2 }')
				oct3=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $3 }')
				oct4=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $4 }')
				arpadomain="$oct3.$oct2.$oct1.in-addr.arpa"
				ssh root@$thisserver "ipa dns-add-rr $arpadomain $oct4 PTR \"$FULLHOSTNAME.\";ipa dns-add-rr $DNS_DOMAIN $HOSTNAME A \"$IP\""
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "ERROR - addition of dns entry into $thisserver fialed for $FULLHOSTNAME"
					tet_result FAIL
					return $ret
				fi
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			# Derive the reverse zone
			oct1=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $1 }')
			oct2=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $2 }')
			oct3=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $3 }')
			oct4=$(echo $IP | sed s/'\.'/\ /g |awk '{ print $4 }')
			arpadomain="$oct3.$oct2.$oct1.in-addr.arpa"
			ssh root@$thisserver "ipa dns-add-rr $arpadomain $oct4 PTR \"$FULLHOSTNAME.\";ipa dns-add-rr $DNS_DOMAIN $HOSTNAME A \"$IP\""
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - addition of dns entry into $thisserver fialed for $FULLHOSTNAME"
				tet_result FAIL
				return $ret
			fi
		fi
	done

	return 0;
}

is_server_alive()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	SID=$1
        eval_vars $SID

	ping -c 1 $FULLHOSTNAME
	ret=$?
        if [ $ret != 0 ]; then
                echo "Ping of $FULLHOSTNAME failed. Trying again."
		ping -c 1 $FULLHOSTNAME
		ret=$?
	        if [ $ret != 0 ]; then
			echo "Ping of $FULLHOSTNAME failed. We are done. Server is not up"
			return 1;
		fi
	fi

	return 0;
}

# This sets the password of a new user
# Usage as follows:
# SetUserPassword <server identifer> <username> <password>
# This program produces it's output on the <server identifer> in the /tmp/SetUserPassword-output.txt file
SetUserPassword()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call SetUserPassword with a username in the $2 position'
		return 1;
	fi 

	if [ "$3" = "" ]; then
		echo 'ERROR - You must call SetUserPassword with a password in the $3 position'
		return 1;
	fi 
	SID=$1
	eval_vars $SID
        rm -f $TET_TMP_DIR/SetUserPassword.exp
        echo 'set timeout 60
set send_slow {1 .1}' > $TET_TMP_DIR/SetUserPassword.exp
	echo "spawn ipa passwd $2" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'match_max 100000' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'sleep 7' >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'sleep 4' >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'expect eof ' >> $TET_TMP_DIR/SetUserPassword.exp

	ssh root@$FULLHOSTNAME 'rm -f /tmp/SetUserPassword.exp'
	scp $TET_TMP_DIR/SetUserPassword.exp root@$FULLHOSTNAME:/tmp/.

	ssh root@$FULLHOSTNAME '/usr/bin/expect /tmp/SetUserPassword.exp > /tmp/SetUserPassword-output.txt'
	ret=$?
	if [ $ret != 0 ]; then
		echo "ERROR - Setting the password of user $1, password of $2 failed";
		return 1;
	fi

	return 0;

}


# KinitAs kinits as a defined user on a defined server, using a given password.
# input as follows:
# KinitAs <server identifer> <username> <password> 
KinitAs()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call KinitAs with a username in the $2 position'
		return 1;
	fi 
	if [ "$3" = "" ]; then
		echo 'ERROR - You must call KinitAs with a password in the $3 position'
		return 1;
	fi 
	SID=$1
	username=$2
	password=$3
	eval_vars $SID
        rm -f $TET_TMP_DIR/kinit.exp
        echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $TET_TMP_DIR/kinit.exp
	echo "OS is $OS"
	case $OS in
		"RHEL")     echo "spawn /usr/kerberos/bin/kinit -V $username" >> $TET_TMP_DIR/kinit.exp       ;;
		"FC")       echo "spawn /usr/kerberos/bin/kinit -V $username" >> $TET_TMP_DIR/kinit.exp       ;;
		"solaris")  echo "spawn /usr/bin/kinit $username" >> $TET_TMP_DIR/kinit.exp     ;;
		*)      echo "spawn /usr/bin/kinit $username" >> $TET_TMP_DIR/kinit.exp        ;;
	esac
	echo 'match_max 100000' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$password\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	ssh root@$FULLHOSTNAME 'rm -f /tmp/kinit.exp'
	scp $TET_TMP_DIR/kinit.exp root@$FULLHOSTNAME:/tmp/.

	ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp'
	if [ $? != 0 ]; then
		echo "ERROR - kinit as user $username, password of $password failed";
		return 1;
	fi

	echo "This is a klist on the machine we just kinited on, it should show that user $username is kinited"
	ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAs-output.txt
	grep $username $TET_TMP_DIR/KinitAs-output.txt
	if [ $? -ne 0 ]; then
	        # Setting the time and date on all of the servers and clients if we can
        	for s in $SERVERS; do
	                if [ "$s" != "" ]; then
                        	eval_vars $s
        	                set_date $FULLHOSTNAME
                	fi
	        done
        	for s in $CLIENTS; do
	                if [ "$s" != "" ]; then
                	        eval_vars $s
        	                set_date $FULLHOSTNAME
	                fi
	        done
		sleep 2
		eval_vars $SID
		ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp'
		if [ $? != 0 ]; then
			echo "ERROR - kinit as user $username, password of $password failed";
			return 1
		fi

		ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAs-output.txt
		grep $username $TET_TMP_DIR/KinitAs-output.txt
		if [ $? -ne 0 ]; then
			echo "ERROR - error in KinitAs, kinit didn't appear to work, $username not found in $TET_TMP_DIR/KinitAs-output.txt"
			echo "contents of $TET_TMP_DIR/KinitAs-output.txt:"
			cat $TET_TMP_DIR/KinitAs-output.txt
			return 1;
		fi
	else
		cat $TET_TMP_DIR/KinitAs-output.txt
	fi

	return 0;

}

# KinitAs kinits as a defined user on a defined server, using a given password.
# This is to be used to kinit as a freshly created user that will need to 
# input as follows:
# KinitAs <server identifer> <username> <password> <newpassword>
# This sub produces the output into /tmp/KinitAsFirst-out.txt on the destination machine
KinitAsFirst()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call KinitAs with a username in the $2 position'
		return 1;
	fi 
	if [ "$3" = "" ]; then
		echo 'ERROR - You must call KinitAs with a password in the $3 position'
		return 1;
	fi 
	SID=$1
	username=$2
	password=$3
	newpassword=$4
	eval_vars $SID
        rm -f $TET_TMP_DIR/kinit.exp
        echo 'set timeout 30
set send_slow {1 .1}' > $TET_TMP_DIR/kinit.exp
	echo "OS is $OS"
	case $OS in
		"RHEL")     echo "spawn /usr/kerberos/bin/kinit -V $username" >> $TET_TMP_DIR/kinit.exp       ;;
		"FC")       echo "spawn /usr/kerberos/bin/kinit -V $username" >> $TET_TMP_DIR/kinit.exp       ;;
		"solaris")  echo "spawn /usr/bin/kinit $username" >> $TET_TMP_DIR/kinit.exp     ;;
		*)      echo "spawn /usr/bin/kinit $username" >> $TET_TMP_DIR/kinit.exp        ;;
	esac
	echo 'match_max 100000' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$password\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$newpassword\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$newpassword\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	ssh root@$FULLHOSTNAME 'rm -f /tmp/kinit.exp'
	scp $TET_TMP_DIR/kinit.exp root@$FULLHOSTNAME:/tmp/.

	ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp > /tmp/KinitAsFirst-out.txt'
	if [ $? != 0 ]; then
		echo "ERROR - kinit as user $username, password of $password, newpassword of $newpassword failed";
		return 1;
	fi
	
	if [ "$DSTET_DEBUG" = "y" ]; then
		echo "printing out kinit output"
		ssh root@$FULLHOSTNAME 'cat /tmp/KinitAsFirst-out.txt'
	fi
	echo "This is a klist on the machine we just kinited on, it should show that user $username is kinited"
	ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAsFirst-output.txt
	cat $TET_TMP_DIR/KinitAsFirst-output.txt
	grep $2 $TET_TMP_DIR/KinitAsFirst-output.txt
	if [ $? -ne 0 ]; then
		echo "oops, that didn't work. Re-syncing everything and trying again"
	        # Setting the time and date on all of the servers and clients if we can
        	for s in $SERVERS; do
	                if [ "$s" != "" ]; then
                        	eval_vars $s
        	                set_date $FULLHOSTNAME
                	fi
	        done
        	for s in $CLIENTS; do
	                if [ "$s" != "" ]; then
                	        eval_vars $s
        	                set_date $FULLHOSTNAME
	                fi
	        done
		sleep 2
		eval_vars $SID
		ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp > /tmp/KinitAsFirst-out.txt'
		if [ $? != 0 ]; then
			echo "ERROR - kinit as user $username, password of $password, newpassword of $newpassword failed";
			return 1;
		fi
	
		if [ "$DSTET_DEBUG" = "y" ]; then
			echo "printing out kinit output"
			ssh root@$FULLHOSTNAME 'cat /tmp/KinitAsFirst-out.txt'
		fi
		echo "This is a klist on the machine we just kinited on, it should show that user $username is kinited"
		ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAsFirst-output.txt
		cat $TET_TMP_DIR/KinitAsFirst-output.txt
		grep $username $TET_TMP_DIR/KinitAsFirst-output.txt
		if [ $? -ne 0 ]; then
			echo "ERROR - error in KinitAsFirst, kinit didn't appear to work, $username not found in $TET_TMP_DIR/KinitAsFirst-output.txt"
			echo "contents of $TET_TMP_DIR/KinitAsFirst-output.txt:"
			cat $TET_TMP_DIR/KinitAsFirst-output.txt
			return 1;
		fi
	else 
		cat $TET_TMP_DIR/KinitAsFirst-output.txt
	fi

	return 0;

}

CheckAlive()
{

	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        echo "Checking to see if servers are alive and listening"
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s now"
                        is_server_alive $s
                        ret=$?
                        if [ $ret -ne 0 ]; then
                                echo "Server $s not answering pings"
                                tet_result FAIL
				return 1
                        fi
                fi
        done

        for s in $CLIENTS; do
                if [ "$s" != "" ]; then
                        echo "working on $s now"
                        is_server_alive $s
                        ret=$?
                        if [ $ret -ne 0 ]; then
                                echo "Server $s not answering pings"
                                tet_result FAIL
				return 1
                        fi
                fi
        done

        tet_result PASS
	return 0
}

setup_ssh_keys()
{
	if [ "$DSTET_DEBUG" = "y" ]; then env; set -x; fi
	SID=$1
        eval_vars $SID
	# If there is no local ssh key, create one
	if [ ! -f ~/.ssh/id_dsa.pub ]; then
		echo "creating local key, DO NOT enter passwords here. Hit ENTER for all questions"
		if [ ! -d ~/.ssh ]; then
			mkdir ~/.ssh
			chmod 600 ~/.ssh
		fi
		ssh-keygen -t dsa
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "WARNING! ssh-keygen failed"
#			tet_result FAIL
#			return $ret
		fi 
	fi
	
	if [ ! -f ~/.ssh/id_dsa.pub ]; then
		echo "ERROR! ssh-keygen didn't create a key into ~/.ssh/id_dsa.pub"
		tet_result FAIL
		return 1
	fi

        if [ "$HOSTNAME" = "" ]; then
		echo "ERROR! eval_vars returned $HOSTNAME"
		tet_result FAIL
                return $rc
        fi
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo "setting up ssh key on host $HOSTNAME OS type is $OS"
	echo ""
	echo "When asked for a password, use the root password for host $FULLHOSTNAME"
	echo ""
	echo ""
	echo ""
	echo ""
	if [ $OS == "RHEL" ]; then
		rm -f /tmp/key-ssh.bash; echo "ssh root@$FULLHOSTNAME \"mkdir -p /root/.ssh;chmod 700 /root/.ssh;rm -f /dev/shm/auth-keys.txt;cp -a /root/.ssh/authorized_keys /dev/shm/auth-keys.txt\"" >> /tmp/key-ssh.bash; bash /tmp/key-ssh.bash
		echo ""
		echo "Great!, that seems to have worked, enter the same root password again"
		echo ""
		scp ~/.ssh/id_dsa.pub root@$FULLHOSTNAME:/root/.ssh/authorized_keys
		if [ $? -ne 0 ]; then
			echo "ERROR! scp of id_dsa.pub to $HOSTNAME failed"
			tet_result FAIL
			return 1
		fi 
		# now restore the previous authorized keys config
		ssh root@$FULLHOSTNAME "if [ -f /dev/shm/auth-keys.txt ]; then cat /dev/shm/auth-keys.txt >> /root/.ssh/authorized_keys; fi"
	fi
	if [ $OS == "HPUX" ]; then
		rm -f /tmp/key-ssh.bash; echo "ssh $FULLHOSTNAME \"mkdir -p /.ssh;chmod 700 /.ssh\"" >> /tmp/key-ssh.bash; bash /tmp/key-ssh.bash
		echo ""
		echo "Great!, that seems to have worked, enter the same root password again"
		echo ""
		scp ~/.ssh/id_dsa.pub root@$FULLHOSTNAME:/.ssh/authorized_keys
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ERROR! scp of id_dsa.pub to $HOSTNAME failed"
			tet_result FAIL
			return $ret
		fi 
	fi
	if [ $OS == "solaris" ]; then
		rm -f /tmp/key-ssh.bash; echo "ssh $FULLHOSTNAME \"mkdir -p /.ssh;chmod 700 /.ssh\"" >> /tmp/key-ssh.bash; bash /tmp/key-ssh.bash
		echo ""
		echo "Great!, that seems to have worked, enter the same root password again"
		echo ""
		scp ~/.ssh/id_dsa.pub root@$FULLHOSTNAME:/.ssh/authorized_keys
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ERROR! scp of id_dsa.pub to $HOSTNAME failed"
			tet_result FAIL
			return $ret
		fi 
	fi

}


ResetKinit()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        # Kinit everywhere
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER;/etc/init.d/ipa_kpasswd restart"
                        echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
                        KinitAs $s $DS_USER $DM_ADMIN_PASS
                        ret=$?
                        if [ $ret -ne 0 ]; then
                                echo "ERROR - kinit on $s failed"
				echo "Test - $tet_thistest - ResetKinit"
                                tet_result FAIL
                        fi
                fi
        done
        for s in $CLIENTS; do
                if [ "$s" != "" ]; then
                        echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
                        KinitAs $s $DS_USER $DM_ADMIN_PASS
                        ret=$?
                        if [ $ret -ne 0 ]; then
                                echo "ERROR - kinit on $s failed"
				echo "Test - $tet_thistest - ResetKinit"
                                tet_result FAIL
                        fi
                fi
        done
}

# This function is dedicated to dupplicate message between stdout and 
# tet's journal.
#
message()
{
	echo "$*"
	type tet_infoline > /dev/null 2>&1 && tet_infoline "$*"
}

# This function sets up the local ssh keys. It creates a ssh keyset that has no passwords for use in later tests.
setup_local_ssh_keys()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "Creating expect file for setting up local ssh keys"
	message "removing any currently existing dsa keys in the home directory"
	rm -f ~/.ssh/id_dsa*
	message "creating expect file"
	echo '#!/usr/bin/expect -f
set timeout 30
spawn $env(SHELL)
#match_max 100000
send "ssh-keygen -t dsa\r"
expect "Generating public/private dsa key pair." {
 sleep 2
 send "\r"
 sleep 1
 send "\r"
 sleep 1
 send "\r"
}
expect "*again:" {
sleep 1
send "\r"
}
expect eof' > $TET_TMP_DIR/setup-ssh-local.exp
	message "In the event of a non-existant home directory, create one:"
	if [ ! -d /root/.ssh ]; then mkdir -p /root/.ssh; chmod 777 /root/.ssh; fi
	message "Running expect script"
	/usr/bin/expect $TET_TMP_DIR/setup-ssh-local.exp
	chmod 600 /root/.ssh

	# Check to ensure that worked properly
	if [ -f /root/.ssh/id_dsa.pub ]; then
		message "Creation of local ssh keys seems to have worked."
		return 0;
	else 
		message "ERROR, creation of local ssh keys seems to have failed."
		ls -al /root/.ssh
		ls -al /root
		return 1;
	fi
}

# The purpose of this function is to create a expect script that will set up a public
# key ssh key setup with this host and the remote machine specified in $1
setup_ssh_keys_remote()
{
	eval_vars $1
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "setting ssh keys with $FULLHOSTNAME"
	message "Removing any entries for the new host from knownhosts"
	cat ~/.ssh/known_hosts | grep -v $HOSTNAME > $TET_TMP_DIR/know-hosts
	cat $TET_TMP_DIR/know-hosts > ~/.ssh/known_hosts
	message "creating expect file"
	echo '#!/usr/bin/expect -f
set timeout 30
set send_slow {1 .1}
spawn $env(SHELL)
match_max 100000' > $TET_TMP_DIR/setup-ssh-remote.exp
	echo "send -s -- \"ssh root@$FULLHOSTNAME 'ls /'\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
	echo "expect \"*'ls /'\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
echo 'sleep .1
send -s -- "\r"
expect "*Are you sure you want to continue connecting (yes/no)? "
sleep .1
send -s -- "yes\r"
sleep .5' >> $TET_TMP_DIR/setup-ssh-remote.exp
echo "send -s -- \"$PASSWORD\r\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
echo 'sleep .1
send -s -- "\r"' >> $TET_TMP_DIR/setup-ssh-remote.exp
	message "Running expect script"
	/usr/bin/expect $TET_TMP_DIR/setup-ssh-remote.exp

	message "Creating /root/.ssh dir on $FULLHOSTNAME"
	message "creating expect file"
	echo '#!/usr/bin/expect -f
set timeout 30
set send_slow {1 .1}
spawn $env(SHELL)
match_max 100000' > $TET_TMP_DIR/setup-ssh-remote2.exp
	echo "send -s -- \"ssh root@$FULLHOSTNAME 'mkdir /root/.ssh;chmod 600 /root/.ssh;rm -f /root/.ssh/authorized_keys'\"" >> $TET_TMP_DIR/setup-ssh-remote2.exp
	echo "expect \"*'mkdir /root/.ssh;chmod 600 /root/.ssh;rm -f /root/.ssh/authorized_keys'\"" >> $TET_TMP_DIR/setup-ssh-remote2.exp
echo 'sleep .1
send -s -- "\r"
expect "*password: "
sleep .1' >> $TET_TMP_DIR/setup-ssh-remote2.exp
	echo "send -s -- \"$PASSWORD\r\"" >> $TET_TMP_DIR/setup-ssh-remote2.exp
	echo 'expect eof' >> $TET_TMP_DIR/setup-ssh-remote2.exp
	message "Running expect script"
	/usr/bin/expect $TET_TMP_DIR/setup-ssh-remote2.exp

	message "Great, now copy the ssh keys over to the remote host"
	message "creating expect file"
	echo '#!/usr/bin/expect -f
set timeout 30
set send_slow {1 .1}
spawn $env(SHELL)
match_max 100000' > $TET_TMP_DIR/setup-ssh-remote3.exp
	echo "send -s -- \"scp /root/.ssh/id_dsa.pub root@$FULLHOSTNAME:/root/.ssh/authorized_keys\r\"" >> $TET_TMP_DIR/setup-ssh-remote3.exp

	echo 'expect "*password: "
sleep .1' >> $TET_TMP_DIR/setup-ssh-remote3.exp
	echo "send -s -- \"$PASSWORD\r\"" >> $TET_TMP_DIR/setup-ssh-remote3.exp
	echo 'expect eof' >> $TET_TMP_DIR/setup-ssh-remote3.exp
	message "Running expect script"
	/usr/bin/expect $TET_TMP_DIR/setup-ssh-remote3.exp

	return 0;
}

# Add time stamp before we log the message
logmessage()
{
        MSG=$1
        TIMESTAMP=`date "+[%D %H:%M:%S]"`
        message "$TIMESTAMP $MSG"
}

# This function is dedicated to log a test case result in stdout and
# in tet's journal, associated with a keyword and the test case name.
#
result()
{
	message "TestCaseResult $tet_thistest $*"
	tet_result "$*"
}

