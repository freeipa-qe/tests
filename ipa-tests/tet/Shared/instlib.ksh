# This file installs and uninstalls IPA server and client
# It's got several subs:
#       servername is usally S1, or S2, or C1, or C2, etc.
#       servername will be 
# InstallServerRPM(servername) 
#       Installs the server specified at servername.
# InstallClientRPM(servername)
#	Installs the client rpms on the specified (not needed on servers that have the server RPM's installed)
# SetupServer(servername)
#	Runs ipa-server-install on the specified server.
# UninstallServer(servername)
#	runs ipa-server-install --uninstall
# SetupServerBogus(servername)
#	Runs ipa-server-install on the specified server with bad options.
# SetupClient(servername)
#	Runs ipa-client-install on the specified client. (not needed on servers with ipa-server set up.)
# SetupRepo(servername)
#	Downloads the repo specifed in the env file to the specified server.
# UninstallServerRPM(servername)
#	Runs ipa-server-install --uninstall. Then it verifies that assortment of files still looks good.
# UninstallClientRPM(servername)
#	Runs ipa-client-install --uninstall. Then it verifies that assortment of files still looks good.

UninstallServer()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
	ssh root@$FULLHOSTNAME "ipa-server-install -U --uninstall"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - ipa-server-install -uninstall on $FULLHOSTNAME FAILED"
#		return 1;
	fi
	return 0;

}

UninstallClientRedhat()
{
	eval_vars $1
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\", it's $OS"
		echo "returning"
		return 1
	fi

	ssh root@$fullhostname "ipa-client-install -u --uninstall"
	ret1=$?
	ssh root@$fullhostname "ipa-client-setup -u --uninstall"
	ret2=$?
	if [ $ret1 -ne 0 ]&&[ $ret2 -ne 0]; then
		echo "error - ipa-client-install -uninstall on $fullhostname failed"
#		return 1;
	fi
	return 0;
}

UninstallClientSolaris()
{
	eval_vars $1
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	if [ "$OS" != "solaris" ]; then
		echo "OS isn't \"solaris\", it's $OS";
		echo "returning";
		return 1;
	fi
	
	bkup="/ipa-original"
	ssh root@$FULLHOSTNAME "cat $bkup/nsswitch.conf >/etc/nsswitch.conf;
cat $bkup/resolv.conf > cp /etc/resolv.conf;
cat $bkup/pam.conf >/etc/pam.conf;
rm -f /etc/ldap.conf;
cat $bkup/krb5.conf > /etc/krb5/krb5.conf;
rm -f /etc/krb5/krb5.keytab";
	
#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa-uninstall.txt'&
	return 0;
}

UninstallClient()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
        case $OS in
                "RHEL")     UninstallClientRedhat $1; return $?       ;;
                "FC")       UninstallClientRedhat $1; return $?      ;;
		"solaris")  UninstallClientSolaris $1; return $?     ;;
                *)      echo "unknown OS"        ;;
        esac

	return 0;

}

InstallClientSolaris()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	echo "gathering hostname for M1"
	eval_vars M1
	m1hostname=$FULLHOSTNAME
	echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
	KinitAs M1 $DS_USER $DM_ADMIN_PASS
	if [ $ret -ne 0 ]; then
		echo "ERROR - kinit on M1 failed"
		return 1;
	fi

	# Reloading vars for the machine we are working on
	eval_vars $1	

	echo "changing nsswitch"
	echo "sed s/passwd.*files/'passwd: files ldap[NOTFOUND=return]'/g < /etc/nsswitch.conf > /tmp/nsswitchtmp;
sed s/group.*files/'group: files ldap[NOTFOUND=return]'/g < /tmp/nsswitchtmp > /etc/nsswitch.conf;" > $TET_TMP_DIR/nsswitch.sh
	chmod 755 $TET_TMP_DIR/nsswitch.sh
	scp $TET_TMP_DIR/nsswitch.sh root@$FULLHOSTNAME:/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $FULLHOSTNAME failed"
		return 1;
	fi
	ssh root@$FULLHOSTNAME "/nsswitch.sh"
	if [ $? -ne 0 ]; then
		echo "ERROR - ssh of file to $FULLHOSTNAME failed"
		return 1;
	fi

	echo "changing pam.conf"
	echo "login auth requisite pam_authtok_get.so.1
login auth sufficient pam_krb5.so.1
login auth required pam_dhkeys.so.1
login auth required pam_unix_cred.so.1
login auth required pam_unix_auth.so.1 use_first_pass
login auth required pam_dial_auth.so.1" > $TET_TMP_DIR/solaris-pam-tmp.txt
	scp $TET_TMP_DIR/solaris-pam-tmp.txt root@$FULLHOSTNAME:/tmp/. 
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $FULLHOSTNAME failed"
		return 1;
	fi

	 echo "sed s/'^login'/'#login'/g < /etc/pam.conf > /tmp/pam-tmp.conf;
cat /tmp/solaris-pam-tmp.txt >> /tmp/pam-tmp.conf;
cat /tmp/pam-tmp.conf > /etc/pam.conf" > $TET_TMP_DIR/pam.sh
	chmod 755 $TET_TMP_DIR/pam.sh
	scp $TET_TMP_DIR/pam.sh root@$FULLHOSTNAME:/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $FULLHOSTNAME failed"
		return 1;
	fi
	ssh root@$FULLHOSTNAME "/pam.sh"
	if [ $? -ne 0 ]; then
		echo "ERROR - ssh of file to $FULLHOSTNAME failed"
		return 1;
	fi
	
	echo "copying ldap.conf from M1 to $1"
	rm -f $TET_TMP_DIR/solaris-ldap.conf
	scp root@$m1hostname:/etc/ldap.conf $TET_TMP_DIR/solaris-ldap.conf
	scp $TET_TMP_DIR/solaris-ldap.conf root@$FULLHOSTNAME:/etc/ldap.conf 
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $FULLHOSTNAME failed"
		return 1;
	fi

	echo "copying krb5.conf from M1 to $1"
	rm -f $TET_TMP_DIR/solaris-krb5.conf
	scp root@$m1hostname:/etc/krb5.conf $TET_TMP_DIR/solaris-krb5.conf
	scp $TET_TMP_DIR/solaris-krb5.conf root@$FULLHOSTNAME:/etc/krb5/krb5.conf 
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $FULLHOSTNAME failed"
		return 1;
	fi

	echo "adding services host/$FULLHOSTNAME to M1"
	echo "rm -f /tmp/krb5.keytab.$FULLHOSTNAME
ipa-addservice nfs/$FULLHOSTNAME
ipa-getkeytab -s $m1hostname -p nfs/$FULLHOSTNAME -k /tmp/krb5.keytab.$FULLHOSTNAME -e des-cbc-crc 
ipa-addservice host/$FULLHOSTNAME 
ipa-getkeytab -s $m1hostname -p host/$FULLHOSTNAME -k /tmp/krb5.keytab.$FULLHOSTNAME -e des-cbc-crc
klist -ket /tmp/krb5.keytab.$FULLHOSTNAME" > $TET_TMP_DIR/$1-cmds.txt

	chmod 755 $TET_TMP_DIR/$1-cmds.txt
	ssh root@$m1hostname "rm -f /tmp/$1-cmds.txt"
	scp $TET_TMP_DIR/$1-cmds.txt root@$m1hostname:/tmp/.
	ssh root@$m1hostname "/tmp/$1-cmds.txt"
	# for all in file do ssh blah	
#	cat $TET_TMP_DIR/$1-cmds.txt | while read c; do
#		ssh root@$m1hostname "$c"
#		if [ $? -ne 0 ]; then
#			echo "ERROR - $c on $m1hostname failed!"
#			return 1;
#		fi
#	done

	echo "Improve keytab on $FULLHOSTNAME"
	rm -f $TET_TMP_DIR/krb5.keytab.$FULLHOSTNAME
	scp root@$m1hostname:/tmp/krb5.keytab.$FULLHOSTNAME $TET_TMP_DIR/krb5.keytab.$FULLHOSTNAME
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $m1hostname failed"
		return 1;
	fi
	ssh root@$FULLHOSTNAME "rm -f /tmp/krb5.keytab.$FULLHOSTNAME;rm -f /etc/krb5/krb5.keytab"
	if [ $? -ne 0 ]; then
		echo "ERROR - ssh of file to $FULLHOSTNAME failed"
		return 1;
	fi
	scp $TET_TMP_DIR/krb5.keytab.$FULLHOSTNAME root@$FULLHOSTNAME:/etc/krb5/krb5.keytab
	if [ $? -ne 0 ]; then
		echo "ERROR - scp of file to $FULLHOSTNAME failed"
		return 1;
	fi
#		echo 'set force_conservative 0  ; 
#if {$force_conservative} {
#        set send_slow {1 .1}
#        proc send {ignore arg} {
#                sleep .1
#                exp_send -s -- $arg
#        }
#}
#set timeout -1' > $TET_TMP_DIR/replica-install.exp
#		echo "spawn ipa-replica-install --debug /tmp/replica-info-$replica_hostname" >> $TET_TMP_DIR/replica-install.exp
#		echo 'match_max 100000
#expect -exact "Directory Manager (existing master) password: "' >> $TET_TMP_DIR/replica-install.exp
#		echo "send -- \"$KERB_MASTER_PASS\"" >> $TET_TMP_DIR/replica-install.exp
#		echo 'send -- "rree"' | sed s/rr/'\\'/g | sed s/ee/r/g

#	echo "read_kt /tmp/krb5.keytab
#write_kt /etc/krb5/krb5.keytab
#q"
	return 0;
}

SetupClientRedhat()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi

	eval_vars M1
	master=$FULLHOSTNAME
	eval_vars $1
	thishost=$FULLHOSTNAME

	ssh root@$thishost "rm -f /etc/resolv.conf.original; \
		cp -a /etc/resolv.conf /etc/resolv.conf.original;"

	# Running uninstall to reduce the number of errors
	ssh root@$thishost "ipa-client-install --uninstall -U"

	if [ "$OS_VER" == "5" ]; then
		echo "ipa-client-install --realm=$RELM_NAME -U" 
		ssh root@$thishost "ipa-client-install --realm=$RELM_NAME --domain=$RELM_NAME -U" 
		if [ $? -ne 0 ]; then
			echo "ERROR - ipa-client-setup on $thishost failed."
			return 1;
		fi
	elif [ "$OS_VER" == "4" ]; then
		echo "ipa-client-setup --server=$master -U"
		ssh root@$thishost "ipa-client-setup --server=$master -U"
		if [ $? -ne 0 ]; then
			echo "ERROR - ipa-client-setup on $thishost failed."
			return 1;
		fi
	fi

	return 0;
}

SetupClient()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
        case $OS in
                "RHEL")     SetupClientRedhat $1       ;;
                "FC")       SetupClientRedhat $1       ;;
		"solaris")  InstallClientSolaris $1     ;;
                *)      echo "unknown OS"        ;;
        esac
	if [ $? -ne 0 ]; then
		return 1;
	fi
	return 0
}

SetupServer()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi

	eval_vars $1
	ssh root@$FULLHOSTNAME "rm -f /etc/resolv.conf.original; \
		cp -a /etc/resolv.conf /etc/resolv.conf.original;"

	# Just in case a previous uninstall didn't finish:
	ssh root@$FULLHOSTNAME "ipa-server-install --uninstall -U"

	if [ "$1" == "M1" ]; then
		echo "setting up server $1 as a master server"
		echo "ipa-server-install -U --hostname=$FULLHOSTNAME -r $RELM_NAME -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS -u root --setup-bind -d"
		ssh root@$FULLHOSTNAME "ipa-server-install -U --hostname=$FULLHOSTNAME -r $RELM_NAME -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS -u root --setup-bind -d"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ERROR - ipa-server-install on $FULLHOSTNAME failed."
			echo "contents of ipaserver-install.log and krb5kdc.log:: "
			ssh root@$FULLHOSTNAME "cat /var/log/ipaserver-install.log;cat /var/log/krb5kdc.log";
			return 1;
		fi
		FixBindServer M1
		if [ $? -ne 0 ]; then
			echo "ERROR - FixBindServer on $FULLHOSTNAME failed."
			return 1;
		fi
	else 
		echo "setting up server $1 as a replica"
		replica_hostname=$FULLHOSTNAME
		eval_vars M1
		echo "Clearing out any pre-existing replica files before we start"
		ssh root@$FULLHOSTNAME "rm -f /var/lib/ipa/replica-info-$replica_hostname*"
		echo "Generating replica prepare file for $replica_hostname on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "/usr/sbin/ipa-replica-prepare -p $DM_ADMIN_PASS $replica_hostname"
		if [ $? -ne 0 ]; then
			echo "Method one did not work, trying method 2"
			ssh root@$FULLHOSTNAME "/usr/sbin/ipa-replica-prepare $replica_hostname"
			if [ $? -ne 0 ]; then
				echo "ERROR - /usr/sbin/ipa-replica-prepare $replica_hostname on $FULLHOSTNAME failed."
				return 1;
			fi
		fi
		# Checking to ensure that the files got created
		ssh root@$FULLHOSTNAME "ls /var/lib/ipa/replica-info-$replica_hostname*"
		if [ $? -ne 0 ]; then
			echo "ERROR - ipa-replica-prepare did not create /var/lib/ipa/replica-info-$replica_hostname*"
			return 1;
		fi

		# Create ldif file for use on replica
#		echo 'dn: cn=config
#changetype: modify
#replace: nsslapd-errorlog-level
#nsslapd-errorlog-level: 1' > $TET_TMP_DIR/debug.ldif
#		chmod 755 $TET_TMP_DIR/debug.ldif
#		ssh root@$replica_hostname "rm -f /tmp/debug.ldif"
#		scp $TET_TMP_DIR/debug.ldif root@$replica_hostname:/tmp/.

		# copying the relica prepare file from the master server to the replica	
		rm -f $TET_TMP_DIR/replica-info-$replica_hostname
		scp root@$FULLHOSTNAME:/var/lib/ipa/replica-info-$replica_hostname* $TET_TMP_DIR/.
		ret=$?
		ssh root@$replica_hostname "rm -f /dev/shm/replica-info-$replica_hostname"
		scp $TET_TMP_DIR/replica-info-$replica_hostname* root@$replica_hostname:/dev/shm/.
		ret2=$?
		if [ $ret -ne 0 ]||[ $ret2 -ne 0 ]; then
			echo "ERROR - scp root@$FULLHOSTNAME:/var/lib/ipa/replica-info-$replica_hostname to root@$replica_hostname:/dev/shm/. failed"
			return 1;
		fi
		# prepare the replica server
		# create expect file for use on the replica server
		echo '#!/usr/bin/expect -f
set force_conservative 0  ; 
if {$force_conservative} {
        set send_slow {1 .1}
        proc send {ignore arg} {
                sleep .1
                exp_send -s -- $arg
        }
}
set timeout -1' > $TET_TMP_DIR/replica-install.exp
		echo "spawn ipa-replica-install --debug /dev/shm/replica-info-$replica_hostname" >> $TET_TMP_DIR/replica-install.exp
		echo 'match_max 100000
expect -exact "Directory Manager (existing master) password: "' >> $TET_TMP_DIR/replica-install.exp
		echo "send -- \"$KERB_MASTER_PASS\"" >> $TET_TMP_DIR/replica-install.exp
		echo 'send -- "rree"' | sed s/rr/'\\'/g | sed s/ee/r/g
		echo 'send -- "rree"' | sed s/rr/'\\'/g | sed s/ee/r/g >> $TET_TMP_DIR/replica-install.exp
		echo 'expect eof' >> $TET_TMP_DIR/replica-install.exp

		ssh root@$replica_hostname "ps -ef | grep slapd"

		chmod 755 $TET_TMP_DIR/replica-install.exp
		scp $TET_TMP_DIR/replica-install.exp root@$replica_hostname:/dev/shm/.
		ssh root@$replica_hostname "/usr/bin/expect /dev/shm/replica-install.exp"
		if [ $? -ne 0 ]; then
			echo "Method 1 did not work, trying method 2"
			# Replacing name in expect script
			ssh root@$replica_hostname "sed -i s/$replica_hostname/$replica_hostname.gpg/g /dev/shm/replica-install.exp"
			ssh root@$replica_hostname "/usr/bin/expect /dev/shm/replica-install.exp"
			if [ $? -ne 0 ]; then
				# replica install failed. Trying it all over again
				echo "trying it all again"
				# Just in case a previous uninstall didn't finish:
				ssh root@$replica_hostname "ipa-server-install --uninstall -U"
				ssh root@$FULLHOSTNAME "rm -f /var/lib/ipa/replica-info-$replica_hostname*"
				echo "Generating replica prepare file for $replica_hostname on $FULLHOSTNAME"
				ssh root@$FULLHOSTNAME "/usr/sbin/ipa-replica-prepare -p $DM_ADMIN_PASS $replica_hostname"
				if [ $? -ne 0 ]; then
					echo "Method one did not work, trying method 2"
					ssh root@$FULLHOSTNAME "/usr/sbin/ipa-replica-prepare $replica_hostname"
					if [ $? -ne 0 ]; then
						echo "ERROR - /usr/sbin/ipa-replica-prepare $replica_hostname on $FULLHOSTNAME failed."
						return 1;
					fi
				fi
				# copying the relica prepare file from the master server to the replica	
				rm -f $TET_TMP_DIR/replica-info-$replica_hostname
				scp root@$FULLHOSTNAME:/var/lib/ipa/replica-info-$replica_hostname* $TET_TMP_DIR/.
				ret=$?
				ssh root@$replica_hostname "rm -f /dev/shm/replica-info-$replica_hostname"
				scp $TET_TMP_DIR/replica-info-$replica_hostname* root@$replica_hostname:/dev/shm/.
				ret2=$?
				if [ $ret -ne 0 ]||[ $ret2 -ne 0 ]; then
					echo "ERROR - scp root@$FULLHOSTNAME:/var/lib/ipa/replica-info-$replica_hostname to root@$replica_hostname:/dev/shm/. failed"
					return 1;
				fi
				ssh root@$replica_hostname "sed -i s/$replica_hostname.gpg/$replica_hostname/g /dev/shm/replica-install.exp"
				ssh root@$replica_hostname "/usr/bin/expect /dev/shm/replica-install.exp"
				if [ $? -ne 0 ]; then
					echo "Method 1 did not work, trying method 2"
					# Replacing name in expect script
					ssh root@$replica_hostname "sed -i s/$replica_hostname/$replica_hostname.gpg/g /dev/shm/replica-install.exp"
					ssh root@$replica_hostname "/usr/bin/expect /dev/shm/replica-install.exp"
					if [ $? -ne 0 ]; then	
						echo "ERROR - /usr/bin/expect /dev/shm/replica-install.exp on $replica_hostname:/dev/shm/. failed"
						return 1;
					fi
				fi
			fi
			ssh root@$replica_hostname "ps -ef | grep slapd"
		fi
	fi
	# The next section is a workaround for bug #450632
	eval_vars $1
	ssh root@$FULLHOSTNAME "ps -ef | grep slapd"
	sleep 4
	ssh root@$FULLHOSTNAME "/etc/init.d/dirsrv stop"
	ssh root@$FULLHOSTNAME "/etc/init.d/dirsrv start"
	ssh root@$FULLHOSTNAME "ps -ef | grep slapd"

	return 0;
}

SetupServerBogus()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
	echo "ipa-server-install -U --hostname=BOGUSNAME -r BOGUSRELM -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS --setup-bind -u $DS_USER -d"
	ssh root@$FULLHOSTNAME "ipa-server-install -U --hostname=BOGUSNAME -r BOGUSRELM -p $DM_ADMIN_PASS -P $KERB_MASTER_PASS -a $DM_ADMIN_PASS --setup-bind -u $DS_USER -d"
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "ERROR - ipa-server-install on $FULLHOSTNAME passed when it shouldn't have."
		return 1;
	fi
	return 0;
}

SetupClientBogus()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1
	echo "ipa-client-install --domain=BOGUSNAME -U"
	ssh root@$FULLHOSTNAME "ipa-client-install --domain=BOGUSNAME -U"
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "ERROR - ipa-client-install on $FULLHOSTNAME passed when it shouldn't have."
		return 1;
	fi
	return 0;
}


SetupRepoRHEL()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	

	echo $REPO |grep ^http 
	if [ $? -eq 0 ]; then
		# the repo file is on http, going to wget it on the server
		ssh root@$FULLHOSTNAME "cd /etc/yum.repos.d;wget $REPO"
		if [ $? -ne 0 ]; then
			echo "ERROR ssh to $FULLHOSTNAME failed"
			return 1
		fi	
	else
		echo $REPO | grep repo
		if [ $? -eq 0 ]; then
			# the repo file is likley a file.
			if [ ! -f $REPO ]; then
				echo "ERROR - File $REPO not found."
				echo "Try using a absolute path in the env file, or, use a file on a http source (http://<path/file.repo)"
				return 1
			fi
			scp $REPO root@$FULLHOSTNAME:/etc/yum.repos.d/.
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - scp to $FULLHOSTNAME failed"
				return 1
			fi	
		else
			# the file is likley a rpm, putting it in /dev/shm/ipa-$day-$month
			day=$(date +%d)
			month=$(date +%m)
			env
			ssh root@$FULLHOSTNAME "rm -Rf /dev/shm/ipa-$day-$month;mkdir -p /dev/shm/ipa-$day-$month"
			scp $REPO root@$FULLHOSTNAME:/dev/shm/ipa-$day-$month/.
			if [ $? -ne 0 ]; then
				echo "ERROR scp to $FULLHOSTNAME failed"
				return 1
			fi	
		fi
	fi
	return 0;
}

PreSetupSolaris()
{
	# If the os is solaris, this section does some of the pre-setup for solaris clients
	echo "If this is the first run of install, back up everything to /ipa-original"
	echo "backing everything up for restore later"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	bkup="/ipa-original"
	ssh root@$FULLHOSTNAME "if [ ! -d $bkup ]; then mkdir -p $bkup;
rm -f $bkup/nsswitch.conf; cp /etc/nsswitch.conf $bkup/.;
rm -f $bkup/resolv.conf; cp /etc/resolv.conf $bkup/.;
rm -f $bkup/pam.conf; cp /etc/pam.conf $bkup/.;
rm -f $bkup/krb5.conf;cp /etc/krb5/krb5.conf $bkup/.; fi;"
	if [ $? -ne 0 ]; then
		echo "backing up of files on $FULLHOSTNAME to $bkup failed"
		return 1;
	fi

	echo "backing everything up for restore later, these files may be corrupted from a previous install"
	bkup="/ipa-backup"
	ssh root@$FULLHOSTNAME "mkdir -p $bkup;
rm -f $bkup/nsswitch.conf; cp /etc/nsswitch.conf $bkup/.;
rm -f $bkup/resolv.conf; cp /etc/resolv.conf $bkup/.;
rm -f $bkup/pam.conf; cp /etc/pam.conf $bkup/.;
rm -f $bkup/krb5.conf;cp /etc/krb5/krb5.conf $bkup/.;
rm -f /tmp/solaris-pam-tmp.txt
rm -f /tmp/solaris-ldap.conf"
	if [ $? -ne 0 ]; then
		echo "backing up of files on $FULLHOSTNAME to $bkup failed"
		return 1;
	fi

	return 0;
}

SetupRepo()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
        case $OS in
                "RHEL")     SetupRepoRHEL $1       ;;
                "FC")       SetupRepoRHEL $1       ;;
		"solaris")  PreSetupSolaris $1     ;;
                *)      echo "unknown OS"        ;;
        esac
	if [ $? -ne 0 ]; then
		return 1;
	fi
	return 0
}

InstallClientRPMSolaris()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	return 0;
}

InstallClientRedhat()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	

	if [ "$OS_VER" == "5" ]; then 
		ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop;killall yum; killall yum-updatesd-helper; sleep 1; killall -9 yum;/usr/bin/yum clean all;rm /var/cache/yum/* -Rf;rpm -e --allmatches krb5-devel"

		ssh root@$FULLHOSTNAME "/usr/bin/yum clean all"

		pkglistB="ipa-client ipa-admintools"
		ssh root@$FULLHOSTNAME "yum -y install $pkglistB"
		if [ $? -ne 0 ]; then
			echo "That rpm install didn't work, lets try that again. Sleeping for 60 seconds first" 
			sleep 60
			ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop;killall yum;sleep 1; killall -9 yum;/usr/bin/yum clean all;yum -y install $pkglistB"
			if [ $? -ne 0 ]; then
				echo "That rpm install didn't work, lets try that again. Sleeping for 60 seconds first" 
				sleep 60
				ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop;killall yum;sleep 1; killall -9 yum;/usr/bin/yum clean all;yum -y install $pkglistB"
				if [ $? -ne 0 ]; then
					echo "ERROR - install of $pkglistB on $FULLHOSTNAME failed"
					return 1
				fi
			fi
		fi	
	elif [ "$OS_VER" == "4" ]; then
		# The SetupRepo sub should put a rpm in /dev/shm/ipa-<2 digit day>-<2-digit month>
		# This will install the rpm from that dir.
		# All needed dependacnies should already exist
		day=$(date +%d)
		month=$(date +%m)
			ssh root@$FULLHOSTNAME "rpm -i /dev/shm/ipa-$day-$month/*.rpm"
			if [ $? -ne 0 ]; then
				echo "ERROR - install of client rpm on $FULLHOSTNAME failed"
				return 1;
			fi
	fi
	return 0;
}

InstallClientRPM()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	if [ $? -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-before-ipa.txt'
#	if [ $? -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
#	fi	

        case $OS in
                "RHEL")     InstallClientRedhat $1       ;;
                "FC")       InstallClientRedhat $1       ;;
		"solaris")  InstallClientRPMSolaris $1     ;;
                *)      echo "unknown OS"        ;;
        esac
	if [ $? -ne 0 ]; then
		return 1;
	fi

#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa.txt'
#	if [ $? -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		echo 'find / | grep -v proc | grep -v dev > /list-after-ipa.txt'
#		return 1
#	fi	

	return 0

}

InstallServerRPM()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\", it's $OS"
		echo "Returning"
		return 0
	fi
	ssh root@$FULLHOSTNAME "rpm -e --allmatches fedora-ds-base fedora-ds-base-devel"
	ssh root@$FULLHOSTNAME "rpm -e --allmatches redhat-ds-base-devel"
	ssh root@$FULLHOSTNAME "rpm -e --allmatches redhat-ds-base"
	ssh root@$FULLHOSTNAME "/usr/bin/yum clean all"
#	pkglistA="TurboGears cyrus-sasl-gssapi fedora-ds-base krb5-server krb5-server-ldap lm_sensors mod_python mozldap mozldap-tools perl-Mozilla-LDAP postgresql-libs python-cheetah python-cherrypy python-configobj python-decoratortools python-elixir python-formencode python-genshi python-json python-kerberos python-kid python-krbV python-nose python-paste python-paste-deploy python-paste-script python-protocols python-psycopg2 python-pyasn1 python-ruledispatch python-setuptools python-simplejson python-sqlalchemy python-sqlite2 python-sqlobject python-tgexpandingformwidget python-tgfastdata python-turbocheetah python-turbojson python-turbokid svrcore tcl Updating bind-libs bind-utils cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib cyrus-sasl-md5 cyrus-sasl-plain krb5-devel krb5-libs bind caching-nameserver expect krb5-workstation"
#	ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop; killall yum; killall yum-updatesd-helper; sleep 1; killall -9 yum;rpm -e --allmatches krb5-devel;yum -y install $pkglistA"
#	ret=$?
#	if [ $ret -ne 0 ]; then
#		echo "That rpm install didn't work, lets try that again. Sleeping for 60 seconds first" 
#		sleep 60
#		ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop; killall yum; killall yum-updatesd-helper; sleep 1; killall -9 yum;/usr/bin/yum clean all;yum -y install $pkglistA"
#		ret=$?
#		if [ $ret -ne 0 ]; then
#			echo "ERROR - install of $pkglistA on $FULLHOSTNAME failed"
#			return 1
#		fi
#	fi	

#	ssh root@$FULLHOSTNAME "yum -y update TurboGears cyrus-sasl-gssapi fedora-ds-base krb5-server krb5-server-ldap lm_sensors mod_python mozldap mozldap-tools perl-Mozilla-LDAP postgresql-libs python-cheetah python-cherrypy python-configobj python-decoratortools python-elixir python-formencode python-genshi python-json python-kerberos python-kid python-krbV python-nose python-paste python-paste-deploy python-paste-script python-protocols python-psycopg2 python-pyasn1 python-ruledispatch python-setuptools python-simplejson python-sqlalchemy python-sqlite2 python-sqlobject python-tgexpandingformwidget python-tgfastdata python-turbocheetah python-turbojson python-turbokid svrcore tcl Updating bind-libs bind-utils cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib cyrus-sasl-md5 cyrus-sasl-plain krb5-devel krb5-libs"
#	ret=$?
#	if [ $ret -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
##		return 1
#	fi	

	# Checking to ensure that expect is installed
#	ssh root@$FULLHOSTNAME 'ls /usr/bin/expect'
#	if [ $? -ne 0 ]; then
#		echo "ERROR - expect not found on $FULLHOSTNAME This could mean that the RPM install failed."
#		return 1
#	fi	

#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-before-ipa.txt'
#	if [ $? -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
#	fi	

	pkglistB="ipa-server ipa-admintools bind caching-nameserver expect krb5-workstation"
	ssh root@$FULLHOSTNAME "yum -y install $pkglistB"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "That rpm install didn't work, lets try that again. Sleeping for 60 seconds first" 
		sleep 60
		ssh root@$FULLHOSTNAME "/etc/init.d/yum-updatesd stop;killall yum;sleep 1; killall -9 yum;rpm -e --allmatches krb5-devel;/usr/bin/yum clean all;rm /var/cache/yum/* -Rf;yum -y install $pkglistB"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ERROR - install of $pkglistB on $FULLHOSTNAME failed"
			return 1
		fi
	fi	

#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa.txt'
#	ret=$?
#	if [ $ret -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
#	fi	

}

UnInstallClientRPM()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\", it's $OS"
		echo "Returning"
		return 0
	fi
	ssh root@$FULLHOSTNAME "rpm -e --allmatches ipa-admintools"
	ssh root@$FULLHOSTNAME "rpm -e --allmatches ipa-client"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
	fi	

	# Create a working resolv.conf, and remove any lingering redhat-ds packages"
	ssh root@$FULLHOSTNAME "rm -f /etc/bind.conf.ipasave; \
		mv /etc/bind.conf /etc/bind.cond.ipasave; \
		rpm -e --allmatches fedora-ds-base fedora-ds-base-devel; \
		rpm -e --allmatches redhat-ds-base-devel; \
		rpm -e --allmatches redhat-ds-base"

#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa-uninstall.txt'
#	ret=$?
#	if [ $ret -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
#	fi
	return 0
}

UnInstallServerRPM()
{
	if [ $DSTET_DEBUG = y ]; then set -x; fi
	. $TESTING_SHARED/shared.ksh
	is_server_alive $1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $1	
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "OS isn't \"RHEL\" or \"FC\", it's $OS"
		echo "Returning"
		return 0
	fi
	ssh root@$FULLHOSTNAME "rpm -e --allmatches redhat-ds-base ipa-server ipa-admintools bind caching-nameserver krb5-workstation ipa-client ipa-server-selinux"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
	fi	

	# Create a working resolv.conf, and remove any lingering redhat-ds packages"
	ssh root@$FULLHOSTNAME "rm -f /etc/bind.conf.ipasave; \
		mv /etc/bind.conf /etc/bind.cond.ipasave; \
		rpm -e --allmatches fedora-ds-base fedora-ds-base-devel; \
		rpm -e --allmatches redhat-ds-base-devel; \
		rpm -e --allmatches redhat-ds-base"

#	ssh root@$FULLHOSTNAME 'find / | grep -v proc | grep -v dev > /list-after-ipa-uninstall.txt'
#	ret=$?
#	if [ $ret -ne 0 ]; then
#		echo "ERROR - ssh to $FULLHOSTNAME failed"
#		return 1
#	fi
	return 0
}

Cleanup()
{
	echo "START Cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	rm -f $TET_TMP_DIR/filelist.txt
	echo '/usr/sbin/ipa*
/tmp/ipa*' > $TET_TMP_DIR/filelist.txt
	echo "working on $s now"
	is_server_alive $s
	if [ $ret -ne 0 ]; then
		echo "ERROR - Server $1 appears to not respond to pings."
		return 1;
	fi
	eval_vars $s

	# resolv.conf cleanup
	ssh root@$FULLHOSTNAME "if [ -f /etc/resolv.conf.original ]; then \
		rm -f /etc/resolv.conf.ipasave; \
		mv /etc/resolv.conf /etc/resolv.conf.ipasave; \
		cat /etc/resolv.conf.original > /etc/resolv.conf; \
		cp /etc/resolv.conf.original /etc/resolv.conf; \
		fi"

	ssh root@$FULLHOSTNAME 'rm -f /tmp/filelist.txt'
	scp $TET_TMP_DIR/filelist.txt root@$FULLHOSTNAME:/tmp/.
	if [ $? -ne 0 ]; then
		echo " ERROR - scp to $s failed"
		return 1
	fi
	# now check to see if any of the files in filelist.txt exist when they should not.
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "Not a RHEL or FC system, continuing"
	else
		echo "The list of files in the next test should NOT exist, disreguard errors stating that files do not exist"
		ssh root@$FULLHOSTNAME 'cat /tmp/filelist.txt | \
			while read f; \
			do ls $f; if [ $? -eq 0 ]; \
				then echo "ERROR - $f still exists"; \
				export setexit=1; fi; \
			done; \
			if [ $setexit -eq 1 ]; \
				then exit 1; fi; 
			\exit 0'
		if [ $? -ne 0 ]; then
			echo "ERROR - some files still exist that should not"
			return 1
		fi
	fi

	# save and then remove old bind configuration
	echo $s | grep M
	if [ $? -eq 0 ]; then
		ssh root@$FULLHOSTNAME "rm -f /var/named.ipasave.tar.gz; \
			tar cvfz /var/named.ipasave.tar.gz /var/named; \
			rm -Rf /var/named;"
	else
		echo "system doesn't appear to be a master, continuing."
	fi
	
	# yum repo cleanup
	ssh root@$FULLHOSTNAME "ls /etc/yum.repos.d/ipa*"
	if [ $? -ne 0 ]; then
		echo "ERROR - no /etc/yum.repos.d/ipa* files exist. This may mean that uninstall got broken"
		echo "This is just fine if this system isn't a RHEL or FC machine"
	#	return 1
	fi
	ssh root@$FULLHOSTNAME "rm -f /etc/yum.repos.d/ipa*"

	# Test to ensure that ns-slapd isn't still hanging around.
	if [ "$OS" != "RHEL" ]&&[ "$OS" != "FC" ]; then
		echo "Not a RHEL or FC system, continuing"
	else
		ssh root@$FULLHOSTNAME "ps -ef | grep -v grep | grep ns-slapd"
		if [ $? -eq 0 ]; then
			echo "ERROR - ns-slapd is still running. It should be gone"
			echo "psef.txt contains:"
			cat $TET_TMP_DIR/psef.txt
			echo "ps -ef from $FULLHOSTNAME is:"
			ssh root@$FULLHOSTNAME "ps -ef"
			return 1
		else
			echo "cleaning up dirsec directories"
			ssh root@$FULLHOSTNAME "rm -Rf /etc/dirsrv/;rm -Rf /var/run/dirsrv/;"
		fi
	fi

	return 0

}
######################################################################

######################################################################
# Run some DNS test to make sure everything is working, if so, set 
# resolv.conf to point to the right place.
######################################################################
FixResolv()
{
	set -x
	echo "START tp5"
	# Get the IP of the first server to be used in the DNS tests.
	eval_vars M1
	export dnss=$IP
	if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
	eval_vars $s
	# Fix Resolv.conf
	ssh root@$FULLHOSTNAME "echo 'search $DNS_DOMAIN' > /etc/resolv.conf;
echo 'nameserver $dnss' >> /etc/resolv.conf;
echo 'nameserver $DNSMASTER' >> /etc/resolv.conf"
	
	# Now test to ensure that DNS works.
	ssh root@$FULLHOSTNAME "/usr/bin/dig -x 10.14.0.110"
	if [ $? != 0 ]; then
		echo "ERROR - reverse lookup aginst localhost failed";
		echo "This might be fine on non RHEL clients"
		if [ "$OS" = "RHEL" ]; then
			return 1;
		fi
	fi

	ssh root@$FULLHOSTNAME "/usr/bin/dig $FULLHOSTNAME"
	if [ $? != 0 ]; then
		echo "ERROR - lookup of myself failed";
		echo "This might be fine on non RHEL clients"
		if [ "$OS" = "RHEL" ]; then
			return 1;
		fi
	fi
	if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi

	return 0

}
######################################################################

