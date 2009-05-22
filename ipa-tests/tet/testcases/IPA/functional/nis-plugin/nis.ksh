#!/bin/ksh

# standard section to trigger the debug mode

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

# tet section : The next line is required as it picks up data about the servers to use
#tet_startup="nis_startup"
#tet_cleanup="nis_cleanup"

iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic99"

ic0="nis_startup"
ic1="s1"
ic2="s2"
ic3="s3"
ic4="s4"
ic5="s5"
ic6="s6"
ic7="s7"
ic8="s8"
ic9="s9"
ic99="nis_cleanup"

############## testing environment variable #########################

#target host: $HOSTNAME_M1
ipaserver=$HOSTNAME_M1
client=$HOSTNAME_C1

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
	if echo $ticketinfo | grep "admin@$RELM_NAME"
	then
		tet_result PASS	
	else
		tet_result FAIL
	fi
	logmessage "$tc: (2) shutdown firewall on both server [$ipaserver] and client [$client]"
	ssh root@${ipaserver} "service iptables stop"
	ssh root@${client} "service iptables stop"
	logmessage "$tc: fix me: I have to manually config the client host to make it work, so this is not real automation, fix me"
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
	if echo $result | grep ypserv
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
	logmessage "$tc: finished"
}

################# test cases start here ################
s1()
{ # rpm dependency check: rpm -qR ipa-server | grep slapi-nis should get: slapi-nis >= 0.15
	tc="nis-1"
	logmessage "$tc: starts"
	result=`ssh root@${ipaserver} "rpm -qR ipa-server | grep slapi-nis"`
	logmessage "$tc: rpm -qR ipa-server gets [$result]"
	if echo "$result" | grep "slapi-nis"
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

s2()
{ # s2: check the default setting: default = nis plug in disabled
	tc="nis-2"
	logmessage "$tc: starts"
	logmessage "$tc: nis plugin disabled by default"
	result=`/usr/sbin/rpcinfo -p $ipaserver | grep ypserv`
	logmessage "$tc: rpcinfo [$result]"
	if echo $result | grep ypserv
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

s3()
{ # s3: enable nis plug in and check the port it listening to
	tc="nis-3"
	logmessage "$tc: starts"
	logmessage "$tc: enable nis plug in"
	EnableNIS 
	result=`/usr/sbin/rpcinfo -p $ipaserver | grep ypserv`
	logmessage "$tc: rpcinfo [$result]"
	if echo $result | grep ypserv
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

s4()
{ # s4: account verification: for ipa users
  # dependency: s2, also, client host must have nis configuration ready
	tc="nis-4"
	logmessage "$tc: starts"
	logmessage "$tc: create random user on ipa server"
	uid=s4.$RANDOM.$RANDOM
	CreateIPAUserOnIPAServer $uid
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid'"
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		result=`ssh root@${client} "getent passwd | grep '$uid' " `
		if echo $result | grep "$uid"
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

s5()
{ # s5: verify nis command execution on nis client host
	tc="nis-5"
	logmessage "$tc: starts"
	logmessage "$tc: create random user on ipa server"
	uid=s5.$RANDOM.$RANDOM
	CreateIPAUserOnIPAServer $uid
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid'"
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		result=`ssh root@${client} "ypmatch $uid passwd" `
		if echo $result | grep "$uid"
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

s6()
{ # s6: verify the ipa user account modification on nis client host
	# ypwhich -m
	#passwd.byuid mv32a-vm.idm.lab.bos.redhat.com
	#passwd.byname mv32a-vm.idm.lab.bos.redhat.com
	#netid.byname mv32a-vm.idm.lab.bos.redhat.com
	#netgroup mv32a-vm.idm.lab.bos.redhat.com
	#group.upg mv32a-vm.idm.lab.bos.redhat.com
	#group.byname mv32a-vm.idm.lab.bos.redhat.com
	#group.bygid mv32a-vm.idm.lab.bos.redhat.com

	tc="nis-6"
	logmessage "$tc: starts"
	logmessage "$tc: ypwhich -m to check the current mapping"
	result=`ssh root@${client} "ypwhich -m" `
	logmessage "$tc: ypwhich return=[$result]"
	if    echo $result | grep "passwd.byuid $ipaserver" \
	   && echo $result | grep "passwd.byname $ipaserver"\
	   && echo $result | grep "netid.byname $ipaserver" \
	   && echo $result | grep "netgroup $ipaserver" \
	   && echo $result | grep "group.upg $ipaserver" \
	   && echo $result | grep "group.byname $ipaserver" \
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

s7()
{
 # s7: ssh login (resource check)
	tc="nis-7"
	logmessage "$tc: starts"
	logmessage "$tc: create random user on ipa server"
	uid=s7.$RANDOM.$RANDOM
	pw=s7${RANDOM}
	CreateIPAUserOnIPAServer $uid $pw
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid'"
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
	logmessage "$tc: finished"
}

s8()
{
# check ypcat -kt passwd.byname | grep "$uid"
	tc="nis-8"
	logmessage "$tc: starts"
	logmessage "$tc: scenario: ypcat passwd check"
	logmessage "$tc: create random user on ipa server"
	uid=s8.$RANDOM.$RANDOM
	CreateIPAUserOnIPAServer $uid
	if ssh root@${ipaserver} "ipa user-find $uid | grep '$uid'"
	then
		logmessage "$tc: create a user [$uid] on ipa server"
		result=`ssh root@${client} "ypcat -kt passwd.byname | grep $uid" `
		if echo $result | grep "$uid"
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

s9()
{
 # yptest: this is a nis slef test command
	tc="nis-9"
	logmessage "$tc: starts"
	logmessage "$tc: run yptest"
	ssh root@${client} "service portmap restart; service ybind restart"
	result=`ssh root@${client} "yptest"`
	logmessage "$tc: yptest result as below"
	logmessage "----------------------------"
	logmessage "$result"
	logmessage "----------------------------"
	if echo $result | grep "tests failed"
	then
		logmessage "$tc: ytest failed"
		tet_result FAIL
	else
		logmessage "$tc: yptest success"
		tet_result PASS
	fi
	logmessage "$tc: finished"
}

s()
{
	tc="nis-?"
	logmessage "$tc: starts"
	logmessage "$tc: finished"
# master-slave structure? ypxfrd, performaince testing
# password change

}
######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

