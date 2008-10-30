# Shared subs needed by most tests
# eval_vars(servername) - pass the servername to this sub to expand the servername into hostname, fullhostname, OS, etc.
# setup_ssh_keys(servername) - install a ssh key into the authorized_keys on the remote server. Create a local key if needed
#               It's okay to run this over and over again, if it's already been run, then this sub will complete without
#               interaction or error.
eval_vars()
{
	#if [ $DSTET_DEBUG = y ]; then set -x; fi
        x=\$HOSTNAME_$1
        HOSTNAME=`eval echo $x`
        FULLHOSTNAME=`host $HOSTNAME | awk '{print $1}'`
	IP=`host $FULLHOSTNAME | awk '{print $4}'`
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
	
        export HOSTNAME FULLHOSTNAME OS REPO LDAP_PORT LDAPS_PORT
}

# Runs ntpdate $NTPSERVER on the machine specified in $1
set_date()
{
	ssh $1 "date;/etc/init.d/ntpd stop;ntpdate $NTPSERVER"&
	return 0
}

# This is used to fix the bind configuration on the first server after a ipa-server-install 
FixBindServer()
{

	if [ $DSTET_DEBUG = y ]; then set -x; fi
	eval_vars $1
	rm -f $TET_TMP_DIR/replace.pl
	echo '#!/usr/bin/perl
my $file = "";
my $string = "";
my $replace = 0;
foreach $num (0 .. $#ARGV) {
        ($a1, $a2) = split(/=/, $ARGV[$num]);
        if ( $a1 =~ "file" ) { $file = $a2;}
        if ( $a1 =~ "string" ) { $string = $a2;}
        if ( $a1 =~ "replace" ) { $replace = $a2;} 
#        print "$ARGV[$num]\\n"; 
}
my $match = 0;
open (LIST, "$file") or die "\\nPROBLEM\\nunable to open file $file\\n";
while (<LIST>)
{
        chomp $_;
        if ( $_ =~ /$string/ ) 
        {
                $match = $match + 1;

        #       print "\\nmatch is $match replace is $replace\\n";
                if ( "$replace" =~ "$match" )
                {
                        print "#$string\\n";
                } else {
                        print "$_\\n";
                }
        } else {
                print "$_\\n";
        }
}' > $TET_TMP_DIR/replace.pl
	chmod 755 $TET_TMP_DIR/replace.pl
	scp $TET_TMP_DIR/replace.pl root@$FULLHOSTNAME:/bin/.
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR! scp of $TET_TMP_DIR/replace.pl to $FULLHOSTNAME failed"
		tet_result FAIL
		return $ret
	fi 
	
	ssh root@$FULLHOSTNAME "/bin/replace.pl replace=5 string='};' file=/etc/named.conf |  
	sed s='type hint'='#type hint'=g | 
	sed s='file \"named.ca\";'='#file \"named.ca\";'=g | 
	sed s='zone \".\" IN {'='#zone \".\" IN {'=g > /etc/named.conf.new"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR! bind fix failed"
		tet_result FAIL
		return $ret
	fi 

	# Put forwarding DNS server into DNS
	ssh root@$FULLHOSTNAME "sed -i s/dump-file/'forwarders { $DNSMASTER; }; dump-file'/g  /etc/named.conf.new"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR! bind fix failed"
		tet_result FAIL
		return $ret
	fi 

	ssh root@$FULLHOSTNAME "mv /etc/named.conf /etc/named.conf.old;cp /etc/named.conf.new /etc/named.conf;/etc/init.d/named restart"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR! bind fix failed"
		tet_result FAIL
		return $ret
	fi 

	# Generate a file containing additions for the zone file referenced by $DNS_DOMAIN
	rm -f $TET_TMP_DIR/dns-addon-tmp.txt
	for s in $SERVERS; do
		if [ "$s" != "" ]; then 
			eval_vars $s
			echo "$HOSTNAME IN A $IP" >> $TET_TMP_DIR/dns-addon-tmp.txt
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then 
			eval_vars $s
			echo "$HOSTNAME IN A $IP" >> $TET_TMP_DIR/dns-addon-tmp.txt
		fi
	done

	# Add those changes to the DNS server.
	eval_vars $1
	ssh root@$FULLHOSTNAME 'rm -f /tmp/dns-addon-tmp.txt'
	scp $TET_TMP_DIR/dns-addon-tmp.txt root@$FULLHOSTNAME:/tmp/.
	ssh root@$FULLHOSTNAME "ls /var/named/$DNS_DOMAIN.zone.db"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR /var/named/$DNS_DOMAIN.zone.db on $FULLHOSTNAME does not exist!"
		tet_result FAIL
		return $ret
	fi
	ssh root@$FULLHOSTNAME "rm -f /var/named/$DNS_DOMAIN.zone.db-ipasave; \
		cp -a /var/named/$DNS_DOMAIN.zone.db /var/named/$DNS_DOMAIN.zone.db.ipasave;"
	ssh root@$FULLHOSTNAME "cat /tmp/dns-addon-tmp.txt >> /var/named/$DNS_DOMAIN.zone.db"
	ssh root@$FULLHOSTNAME "/etc/init.d/named restart"	
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - restart of bind on $FULLHOSTNAME failed!"
		tet_result FAIL
		return $ret
	fi

	return 0
}

is_server_alive()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
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
	if [ $DSTET_DEBUG = y ]; then set -x; fi
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
	echo "spawn ipa-passwd $2" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'match_max 100000' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'sleep 7' >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'sleep 4' >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/SetUserPassword.exp
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
# KinitAs <server identifer> <username> <password> fast
# The "fast" is optional. If fast is specified then expect only waits 2 seconds between input.
# Otherwise it waits a much safer 15 seconds
KinitAs()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call KinitAs with a username in the $2 position'
		return 1;
	fi 
	if [ "$3" = "" ]; then
		echo 'ERROR - You must call KinitAs with a password in the $3 position'
		return 1;
	fi 
	if [ "$4" = "fast" ] || [ "$4" = "Fast" ]; then
		fast=1;
	else
		fast=0;
	fi
	SID=$1
	eval_vars $SID
        rm -f $TET_TMP_DIR/kinit.exp
        echo 'set timeout 60
set send_slow {1 .1}' > $TET_TMP_DIR/kinit.exp
	echo "OS is $OS"
	case $OS in
		"RHEL")     echo "spawn /usr/kerberos/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp       ;;
		"FC")       echo "spawn /usr/kerberos/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp       ;;
		"solaris")  echo "spawn /usr/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp     ;;
		*)      echo "spawn /usr/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp        ;;
	esac
	echo 'match_max 100000' >> $TET_TMP_DIR/kinit.exp
	if [ $fast -eq 1 ]; then
		echo 'sleep 2' >> $TET_TMP_DIR/kinit.exp
	else	
		echo 'sleep 7' >> $TET_TMP_DIR/kinit.exp
	fi
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	ssh root@$FULLHOSTNAME 'rm -f /tmp/kinit.exp'
	scp $TET_TMP_DIR/kinit.exp root@$FULLHOSTNAME:/tmp/.

	ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp'
	if [ $? != 0 ]; then
		echo "ERROR - kinit as user $1, password of $2 failed";
		return 1;
	fi

	echo "This is a klist on the machine we just kinited on, it should show that user $2 is kinited"
	ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAs-output.txt
	grep $2 $TET_TMP_DIR/KinitAs-output.txt
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
			echo "ERROR - kinit as user $1, password of $2 failed";
			return 1
		fi

		ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAs-output.txt
		grep $2 $TET_TMP_DIR/KinitAs-output.txt
		if [ $? -ne 0 ]; then
			echo "ERROR - error in KinitAs, kinit didn't appear to work, $2 not found in $TET_TMP_DIR/KinitAs-output.txt"
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
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call KinitAs with a username in the $2 position'
		return 1;
	fi 
	if [ "$3" = "" ]; then
		echo 'ERROR - You must call KinitAs with a password in the $3 position'
		return 1;
	fi 
	SID=$1
	eval_vars $SID
        rm -f $TET_TMP_DIR/kinit.exp
        echo 'set timeout 60
set send_slow {1 .1}' > $TET_TMP_DIR/kinit.exp
	echo "OS is $OS"
	case $OS in
		"RHEL")     echo "spawn /usr/kerberos/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp       ;;
		"FC")       echo "spawn /usr/kerberos/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp       ;;
		"solaris")  echo "spawn /usr/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp     ;;
		*)      echo "spawn /usr/bin/kinit -V $2" >> $TET_TMP_DIR/kinit.exp        ;;
	esac
	echo 'match_max 100000' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep 7' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep 5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$4\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep 5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$4\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	ssh root@$FULLHOSTNAME 'rm -f /tmp/kinit.exp'
	scp $TET_TMP_DIR/kinit.exp root@$FULLHOSTNAME:/tmp/.

	ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp > /tmp/KinitAsFirst-out.txt'
	if [ $? != 0 ]; then
		echo "ERROR - kinit as user $1, password of $2 failed";
		return 1;
	fi
	
	if [ $DSTET_DEBUG = y ]; then
		echo "printing out kinit output"
		ssh root@$FULLHOSTNAME 'cat /tmp/KinitAsFirst-out.txt'
	fi
	echo "This is a klist on the machine we just kinited on, it should show that user $2 is kinited"
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
			echo "ERROR - kinit as user $1, password of $2 failed";
			return 1;
		fi
	
		if [ $DSTET_DEBUG = y ]; then
			echo "printing out kinit output"
			ssh root@$FULLHOSTNAME 'cat /tmp/KinitAsFirst-out.txt'
		fi
		echo "This is a klist on the machine we just kinited on, it should show that user $2 is kinited"
		ssh root@$FULLHOSTNAME 'klist' > $TET_TMP_DIR/KinitAsFirst-output.txt
		cat $TET_TMP_DIR/KinitAsFirst-output.txt
		grep $2 $TET_TMP_DIR/KinitAsFirst-output.txt
		if [ $? -ne 0 ]; then
			echo "ERROR - error in KinitAsFirst, kinit didn't appear to work, $2 not found in $TET_TMP_DIR/KinitAsFirst-output.txt"
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

	if [ $DSTET_DEBUG = y ]; then set -x; fi
        echo "Checking to see if servers are alive and listening"
        for f in $SERVERS; do
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
	if [ $DSTET_DEBUG = y ]; then env; set -x; fi
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
			echo "ERROR! ssh-keygen failed"
			tet_result FAIL
			return $ret
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

