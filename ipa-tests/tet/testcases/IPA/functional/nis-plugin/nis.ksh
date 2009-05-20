#!/bin/ksh

# standard section to trigger the debug mode

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

# tet section : The next line is required as it picks up data about the servers to use
#tet_startup="nis_startup"
#tet_cleanup="nis_cleanup"

iclist="ic0 ic1 ic2 ic3 ic99"

ic0="nis_startup"
ic1="s1"
ic2="s2"
ic3="s3"
ic99="nis_cleanup"

############## testing environment variable #########################

#target host: $HOSTNAME_M1
ipaserver=$HOSTNAME_M1
client_1=$HOSTNAME_C1

############## Include local functions before we start test below  ##
. ./functions.nis.ksh

############## Test environment: set up and clean up  ###############
# startup section
nis_startup()
{
	tc="nis startup"
	logmessage "$tc: starts"
	ticketinfo=`ssh root@${ipaserver} "kdestroy; echo \"$KERB_MASTER_PASS\" | kinit admin; klist 2>&1 "`
	logmessage "$tc: klist [$ticketinfo]"
	if echo $ticketinfo | grep "admin@$RELM_NAME"
	then
		tet_result PASS	
	else
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

# cleanup section
nis_cleanup()
{
	tc="nis cleanup"
	logmessage "$tc: starts"
	ticket=`ssh root@${ipaserver} "kdestroy"`
	logmessage "$tc: remove kerberos ticket "
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

s4
{ # s4: 
  # dependency: s2
	tc="nis-4"
	logmessage "$tc: starts"
	
	logmessage "$tc: finished"
}


######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

