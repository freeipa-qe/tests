#!/bin/ksh
# by yzhang
# standard section to trigger the debug mode

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

# tet section : The next line is required as it picks up data about the servers to use

iclist="ic0 ic1 ic2 ic3 ic99"

ic0="autofs_startup"
ic1="autofs_001"
ic2="autofs_002"
ic3="autofs_003"
ic4="autofs_101"
ic5="autofs_102"
ic6="autofs_103"
ic7="autofs_104"
ic8="autofs_105"
ic9="autofs_106"
ic10="autofs_107"
ic99="autofs_cleanup"

############## testing environment variable #########################

#target host: $HOSTNAME_M1
ipaserver=$HOSTNAME_M1
client=$HOSTNAME_C1
# nisdomain should be removed, but for now I don't find a better way to get ipa account information in client host
nisdomain=$DNS_DOMAIN
FQDN="$ipaserver.$DNS_DOMAIN"

# if /home is used, then it will be a confilict problem that cause the machine hangs. 
# using /ipahome would be sufficient 
mount_homedir="/ipahome"

############## Include local functions before we start test [if any] ##
. ./functions.autofs.ksh

############## Test environment: set up and clean up  ###############
# startup section
autofs_startup()
{
	tc="autofs startup"
	logmessage "$tc: starts"
	logmessage "$tc: (1) authenticate as 'admin' in $ipaserver"
	ticketinfo=`ssh root@${ipaserver} "kdestroy; echo \"$KERB_MASTER_PASS\" | kinit admin; klist 2>&1 "`
	logmessage "$tc: klist [$ticketinfo]"
	if echo $ticketinfo | grep "admin@$RELM_NAME" 2>&1 1>/dev/null
	then
		tet_result PASS	
	else
		tet_result FAIL
	fi
	logmessage "$tc: (2) shutdown firewall on both server [$ipaserver] and client [$client]"
	# stop firewall on ipa server
	result=`ssh root@${ipaserver} "service iptables stop; sleep 1; service iptables status"`
	if echo $result | grep "Firewall is stopped" 2>&1 1>/dev/null
	then
		echo "$tc: firewall stopped in ipaserver [$ipaserver]"
	else
		echo "$tc: firewall did not stop in ipaserver [$ipaserver], the rest of test cases are expected to fail"
		tet_result FAIL
	fi
	# stop firewall on client
	result==`ssh root@${client} "service iptables stop; sleep 1; service iptables status"`
	if echo $result | grep "Firewall is stopped" 2>&1 1>/dev/null
	then
		echo "$tc: firewall stopped in client [$client]"
	else
		echo "$tc: firewall did not stop in client [$client], the rest of test cases are expected to fail"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

# cleanup section
autofs_cleanup()
{
	tc="autofs cleanup"
	logmessage "$tc: starts"
	ssh root@${ipaserver} "kdestroy"
	logmessage "$tc: (1) remove kerberos ticket "
	logmessage "$tc: (2) restore firewall on both server [$ipaserver] and client [$client]"
	#ssh root@${ipaserver} "service iptables start"
	#ssh root@${client} "service iptables start"
	logmessage "$tc: finished: fixme, when finished, umcomment the above statement relate to iptables then change the result to PASS"
	#tet_result PASS
	tet_result FAIL
}

################# test cases start here ################
autofs_001()
{ # schema file check: the schema is : ls /etc/dirsrv/schema/60autofs.ldif
	tc="autofs_001"
	schema_dir="/etc/dirsrv/schema/"
	logmessage "$tc: starts [schema file check on server host]"
	result=`ssh root@${ipaserver} "ls $schema_dir | grep autofs "`
	logmessage "$tc: [$result]"
	if echo "$result" | grep "autofs.ldif" 2>&1 1>/dev/null
	then
		logmessage "$tc: success"
		tet_result PASS
	else
		logmessage "$tc: failed"
		logmessage "$tc: [suggest] does the schema file renamed? it used to be '60autofs.ldif'"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

autofs_002()
{ # s2: autofs configure server and client
	tc="autofs_002"
	# configurate ipa server : load autofs info into ldap, set up mounting points, start NFS
	logmessage "$tc: starts [basic server configuration and verification on client host]"
	ssh root@${ipaserver} "ipa automount-addindirectmap --key=$mount_homedir --description='Home directories' auto.home" 
	ssh root@${ipaserver} "ipa automount-addkey --key='*' --info='$FQDN:$mount_homedir/&' auto.home" 
	ssh root@${ipaserver} "mv /etc/exports /etc/exports.bk"
	ssh root@${ipaserver} " if [ ! -e $mount_homedir ] ; then mkdir $mount_homedir; fi"
	ssh root@${ipaserver} "echo '$mount_homedir 10.16.0.0/16(rw,sync)' > /etc/exports "
	ssh root@${ipaserver} "setsebool use_nfs_home_dirs on" 
	ssh root@${ipaserver} "service nfs restart"
	logmessage "$tc: server configuration finished"

	# verify the mounting on client side
	result=`ssh root@${client} " showmount -e $ipaserver"`
	logmessage "$tc: showmount result[$result]"
	if echo $result | grep "$mount_homedir" 2>&1 1>/dev/null
	then
		logmessage "$tc: success"
		tet_result PASS 
	else
		logmessage "$tc: failed"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

autofs_003()
{ # s3: configurate client and do actual mount on client, this test is based on the success of autofs_002
	tc="autofs_003"
	uid=$tc.$RANDOM
	logmessage "$tc: starts [do acutal mounting on client host]"
	logmessage "$tc: 1. create user [$uid]"
	CreateIPAUserOnIPAServer $uid "" "$mount_homedir/$uid"
	result=`ssh root@${ipaserver} "mkdir $mount_homedir/$uid"`
	logmessage "$tc: 2. enable nis on client [$client] to get account info (there might be another way"
	EnableNIS 
	ConfigNISClient $client $nisdomain $ipaserver

	logmessage "$tc: 3. configure autofs client"
	ssh root@${client} " mv -f /etc/nsswitch.conf /etc/nsswitch.conf.bk"
	ssh root@${client} " sed -e 's/^automount.*$/automount: ldap/' < /etc/nsswitch.conf.bk > /etc/nsswitch.conf "
	ssh root@${client} " cp -f /etc/sysconfig/autofs /etc/sysconfig/autofs.bk"
	ssh root@${client} " echo 'LDAP_URI=\"ldap://$FQDN\"' >> /etc/sysconfig/autofs "
	ssh root@${client} " echo 'SEARCH_BASE=\"cn=automount,dc=idm,dc=lab,dc=bos,dc=redhat,dc=com\"' >> /etc/sysconfig/autofs"
	ssh root@${client} " if [ ! -e $mount_homedir ] ; then mkdir $mount_homedir; fi"
	ssh root@${client} " service autofs restart"

	logmessage "$tc: 4. actual test starts"
	logmessage "$tc: 4.1 create a user account on server"
	result=`ssh root@${client} "cd $mount_homedir/$uid; ls $mount_homedir | grep '$uid' "`
	logmessage "$tc: 4.2 cd to user homedir, and then do 'ls', result=[$result]"
	if echo $result | grep "$uid" 2>&1 1>/dev/null
	then
		logmessage "$tc: success"
		tet_result PASS
	else
		logmessage "$tc: failed"
		tet_result FAIL
	fi
	# clean up the account and directory
	logmessage "$tc: cleanup 1. remove directory on ipaserver [$ipaserver]"
	ssh root@{ipaserver} "rm $mount_homedir/$uid"
	logmessage "$tc: cleanup 2. delete this user on ipa server"
	DeleteIPAUserOnIPAServer $uid
	logmessage "$tc: cleanup 3. disable nis on ipa server [$ipaserver]"
	DisableNIS
	logmessage "$tc: cleanup 4. restore the nis configuration on client [$client]"
	RestoreNISClient $client $nisdomain $ipaserver
	logmessage "$tc: finished"
}

autofs_101()
{
 # yptest: this is a autofs slef test command
	tc="autofs_101"
	logmessage "$tc: starts"
	logmessage "$tc: config autofs client host and run yptest"
	#result=`ssh root@${client} "service portmap restart; service ypbind restart" `
	ssh root@${client} "service portmap restart; service ypbind restart"
	logmessage "$tc: after restarts, return-[$result], now run yptest"
	result=`ssh root@${client} "yptest 2>&1 "`
	logmessage "$tc: yptest result as below"
	logmessage "----------------------------"
	logmessage "$result"
	logmessage "----------------------------"
	if echo $result | grep "tests failed" 2>&1 1>/dev/null
	then
		logmessage "$tc: yptest result: [$result]"
		if echo $result | grep "1 tests failed" 2>&1 1>/dev/null
		then
			logmessage "$tc: yptest success, one test failed is expected"
			tet_result PASS
		else
			logmessage "$tc: yptest failed"
			tet_result FAIL
		fi
	else
		logmessage "$tc: yptest success"
		tet_result PASS
	fi
	logmessage "$tc: finished"
}

autofs_102()
{ # s5: verify autofs command execution on nis client host
	tc="autofs_102"
	logmessage "$tc: starts"
	logmessage "$tc: create random user on ipa server"
	uid=$tc.$RANDOM
	CreateIPAUserOnIPAServer $uid
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid' 2>&1 "
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		result=`ssh root@${client} "ypmatch $uid passwd" 2>&1  `
		if echo $result | grep "$uid" 2>&1 1>/dev/null
		then
			logmessage "$tc: ypmatch found this user on [$client] host"
			logmessage "$tc: return=[$result]"
			logmessage "$tc: success"
			tet_result PASS
		else
			logmessage "$tc: ypmatch DID NOT find this user on [$client] host"
			logmessage "$tc: return=[$result]"
			logmessage "$tc: failed"
			tet_result FAIL
		fi
		DeleteIPAUserOnIPAServer $uid
	else
		logmessage "$tc: failed create a user [$uid] on ipa server"
		logmessage "$tc: test can not continue"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

autofs_103()
{ # s6: verify the ipa user account modification on autofs client host

	tc="autofs_103"
	logmessage "$tc: starts"
	logmessage "$tc: ypwhich -m to check the current mapping"
	result=`ssh root@${client} "ypwhich -m" 2>&1`
	logmessage "$tc: ypwhich return=[$result]"
	if    echo $result | grep "passwd.byuid $ipaserver"  \
	   && echo $result | grep "passwd.byname $ipaserver" \
	   && echo $result | grep "netid.byname $ipaserver"  \
	   && echo $result | grep "netgroup $ipaserver"      \
	   && echo $result | grep "group.upg $ipaserver"     \
	   && echo $result | grep "group.byname $ipaserver"  \
	   && echo $result | grep "group.bygid $ipaserver" 
	then	
		logmessage "$tc: ypwhich sucess"
		tet_result PASS
	else
		logmessage "$tc: ypwhich failed"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

autofs_104()
{
# check ypcat -kt passwd.byname | grep "$uid"
	tc="autofs_104"
	logmessage "$tc: starts"
	logmessage "$tc: scenario: ypcat passwd check"
	logmessage "$tc: create random user on ipa server"
	uid=$tc.$RANDOM
	CreateIPAUserOnIPAServer $uid
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid'"
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		result=`ssh root@${client} "ypcat -kt passwd.byname | grep $uid 2>&1" `
		if echo $result | grep "$uid" 2>&1 1>/dev/null
		then
			logmessage "$tc: ypcat found this user on [$client] host"
			logmessage "$tc: return=[$result]"
			logmessage "$tc: success"
			tet_result PASS
		else
			logmessage "$tc: ypcat DID NOT find this user on [$client] host"
			logmessage "$tc: return=[$result]"
			logmessage "$tc: failed"
			tet_result FAIL
		fi
		DeleteIPAUserOnIPAServer $uid
	else
		logmessage "$tc: failed create a user [$uid] on ipa server"
		logmessage "$tc: test can not continue"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

autofs_105()
{ # s4: account verification: for ipa users
  # dependency: s2, also, client host must have autofs configuration ready
	tc="autofs_105"
	logmessage "$tc: starts"
	#logmessage "$tc: restart ypbind on client: [$client]"
	#result=`ssh root@$client "service ypbind restart"`
	#logmessage "$tc: [$result]"
	logmessage "$tc: create random user on ipa server"
	uid=$tc.$RANDOM
	CreateIPAUserOnIPAServer $uid
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid' 2>&1 "
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		result=`ssh root@${client} "getent passwd | grep '$uid' 2>&1 " `
		if echo $result | grep "$uid" 2>&1 1>/dev/null
		then
			logmessage "$tc: found this user on [$client] host"
			logmessage "$tc: return=[$result]"
			logmessage "$tc: success"
			tet_result PASS
		else
			logmessage "$tc: CAN NOT find this user on [$client] host"
			logmessage "$tc: return=[$result]"
			logmessage "$tc: failed"
			tet_result FAIL
		fi
		DeleteIPAUserOnIPAServer $uid
	else
		logmessage "$tc: failed create a user [$uid] on ipa server"
		logmessage "$tc: test can not continue"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

autofs_106()
{
 # autofs_106: ssh login (resource check)
	tc="autofs_106"
	logmessage "$tc: starts"
	logmessage "$tc: create random user on ipa server"
	uid=$tc.$RANDOM
	pw=$tc${RANDOM}
	CreateIPAUserOnIPAServer $uid $pw
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid' 2>&1 "
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		logmessage "$tc: this test case will not work, fix me"
		tet_result FAIL
		# the following code will not work, FIXME
		#result=`ssh $uid@${client} "hostname" `
		#if echo $result | grep "$client"
		#then
		#	logmessage "$tc: success"
		#	tet_result PASS
		#else
		#	logmessage "$tc: failed"
		#	tet_result FAIL 
		#fi
	fi
	DeleteIPAUserOnIPAServer $uid	
	logmessage "$tc: finished"
}


autofs_107()
{
	tc="autofs_107"
	logmessage "$tc: starts"
	logmessage "$tc: create random user on ipa server"
	uid=$tc.$RANDOM
	pw=$tc${RANDOM}
	CreateIPAUserOnIPAServer $uid $pw
	result=`ssh root@${ipaserver} "ipa user-find $uid 2>&1 "`
	if echo $result | grep $uid 2>&1 1>/dev/null
	then
		#checking variables
		ypcat=0
		logmessage "$tc: create a user [$uid] on ipa server, now try to delete"
		result=`ssh root@${ipaserver} "ypcat passwd | grep $uid" 2>&1 `
		logmessage "$tc: ypcat result before delete : [$result]"
		if echo $result | grep $uid 2>&1 1>/dev/null ;then
			ypcat=1
			logmessage "$tc: ypcat checked"
		fi
		DeleteIPAUserOnIPAServer $uid	
		result=`ssh root@${ipaserver} "ypcat passwd | grep $uid" 2>&1 `
		logmessage "$tc: ypcat result after delete : [$result]"
		if echo $result | grep $uid 2>&1 1>/dev/null ;then
			ypcat=0
			logmessage "$tc: ypcat check failed"
		else
			ypcat=1
			logmessage "$tc: ypcat check success"
		fi
		# make sure mark the result based on all test result
		if [ $ypcat ];then
			tet_result PASS
		else
			tet_result FAIL
		fi
	else
		logmessage "$tc: can NOT create user [$uid] on ipa server, cannot continue"
		logmessage "$tc: failed"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

template()
{
	tc="autofs_?"
	logmessage "$tc: starts"
	logmessage "$tc: finished"
}


######################################################################
# master-slave structure? ypxfrd, performaince testing
# password change
# account modification : change in ipa side, check on autofs client side and vise versa
# increate the teting data I am going to use, and possiblly start stress testing
# some test cases for ipa groups

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

