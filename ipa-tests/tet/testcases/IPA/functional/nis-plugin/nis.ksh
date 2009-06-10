#!/bin/ksh

# standard section to trigger the debug mode

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

# tet section : The next line is required as it picks up data about the servers to use
#tet_startup="nis_startup"
#tet_cleanup="nis_cleanup"

iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10 ic99"
#iclist="ic0 ic1 ic2 ic3 ic4 ic99"

ic0="nis_startup"
ic1="nis_001"
ic2="nis_002"
ic3="nis_003"
ic4="nis_101"
ic5="nis_102"
ic6="nis_103"
ic7="nis_104"
ic8="nis_105"
ic9="nis_106"
ic10="nis_107"
ic99="nis_cleanup"

############## testing environment variable #########################

#target host: $HOSTNAME_M1
ipaserver=$HOSTNAME_M1
client=$HOSTNAME_C1
nisdomain=$DNS_DOMAIN

############## Include local functions before we start test below  ##
. ./functions.nis.ksh

############## Test environment: set up and clean up  ###############
# startup section
nis_startup()
{
	tc="nis startup"
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
	ssh root@${ipaserver} "service iptables stop"
	ssh root@${client} "service iptables stop"
	ConfigNISClient $client $nisdomain $server
	ssh root@${client} "service iptables stop"
	logmessage "$tc: finished"
}

# cleanup section
nis_cleanup()
{
	tc="nis cleanup"
	logmessage "$tc: starts"
	ticket=`ssh root@${ipaserver} "kdestroy"`
	logmessage "$tc: (1) remove kerberos ticket "
	DisableNIS
	result=`/usr/sbin/rpcinfo -p $ipaserver | grep ypserv`
	logmessage "$tc: rpcinfo [$result]"
	if echo $result | grep ypserv 2>&1 1>/dev/null
	then
		logmessage "$tc: disable nis failed"
		tet_result FAIL
	else
		logmessage "$tc: disable nis success"
		tet_result PASS
	fi
	logmessage "$tc: (2) restore firewall on both server [$ipaserver] and client [$client]"
	ssh root@${ipaserver} "service iptables start"
	ssh root@${client} "service iptables start"
	ssh root@${client} "service ypbind stop"
	logmessage "$tc: restore nis client"
	RestoreNISClient $client
	logmessage "$tc: finished"
	tet_result PASS
}

################# test cases start here ################
nis_001()
{ # rpm dependency check: rpm -qR ipa-server | grep slapi-nis should get: slapi-nis >= 0.15
	tc="nis_001"
	logmessage "$tc: starts"
	result=`ssh root@${ipaserver} "rpm -qR ipa-server | grep slapi-nis"`
	logmessage "$tc: rpm -qR ipa-server gets [$result]"
	if echo "$result" | grep "slapi-nis" 2>&1 1>/dev/null
	then
		logmessage "$tc: success"
		tet_result PASS
	else
		logmessage "$tc: failed"
		logmessage "$tc: [suggest] does ipa-server installed?"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

nis_002()
{ # s2: check the default setting: default = nis plug in disabled
	tc="nis_002"
	logmessage "$tc: starts"
	logmessage "$tc: nis plugin disabled by default"
	result=`/usr/sbin/rpcinfo -p $ipaserver | grep ypserv`
	logmessage "$tc: rpcinfo [$result]"
	if echo $result | grep ypserv 2>&1 1>/dev/null
	then
		logmessage "$tc: failed"
		logmessage "$tc: [suggest] is this ipa server fresh installed?"
		tet_result FAIL
	else
		logmessage "$tc: success"
		tet_result PASS
	fi
	logmessage "$tc: finished"
}

nis_003()
{ # s3: enable nis plug in and check the port it listening to
	tc="nis_003"
	logmessage "$tc: starts"
	logmessage "$tc: enable nis plug in"
	EnableNIS 
	result=`/usr/sbin/rpcinfo -p $ipaserver | grep ypserv`
	logmessage "$tc: rpcinfo [$result]"
	if echo $result | grep ypserv 2>&1 1>/dev/null
	then
		logmessage "$tc: success"
		tet_result PASS
	else
		logmessage "$tc: failed"
		logmessage "$tc: [suggest] check firewall on [$ipaserver]"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

nis_101()
{
 # yptest: this is a nis slef test command
	tc="nis_101"
	logmessage "$tc: starts"
	logmessage "$tc: config nis client host and run yptest"
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

nis_102()
{ # s5: verify nis command execution on nis client host
	tc="nis_102"
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

nis_103()
{ # s6: verify the ipa user account modification on nis client host

	tc="nis_103"
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

nis_104()
{
# check ypcat -kt passwd.byname | grep "$uid"
	tc="nis_104"
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

nis_105()
{ # s4: account verification: for ipa users
  # dependency: s2, also, client host must have nis configuration ready
	tc="nis_105"
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

nis_106()
{
 # nis_106: ssh login (resource check)
	tc="nis_106"
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


nis_107()
{
	tc="nis_107"
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

s()
{
	tc="nis_?"
	logmessage "$tc: starts"
	logmessage "$tc: finished"
}


######################################################################
# master-slave structure? ypxfrd, performaince testing
# password change
# account modification : change in ipa side, check on nis client side and vise versa
# increate the teting data I am going to use, and possiblly start stress testing
# some test cases for ipa groups

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

