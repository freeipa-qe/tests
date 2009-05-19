#!/bin/ksh

# standard section to trigger the debug mode

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

# tet section : The next line is required as it picks up data about the servers to use
#tet_startup="nis_startup"
#tet_cleanup="nis_cleanup"

iclist="ic0 ic1 ic2 ic99"

ic0="nis_startup"

ic1="s1"
ic2="s2"

ic99="nis_cleanup"

# testing environment variable

#target host: $HOSTNAME_M1
host=$HOSTNAME_M1

################# Test environment: set up and clean up  ################
# startup section
nis_startup()
{
	logmessage "nis start up: setup testing environment: no specific setup, using default"
	ssh root@${host} "kdestroy; echo \"$KERB_MASTER_PASS\" | kinit admin"
	ticket=`ssh root@${host} "klist 2>&1 "`
	if echo $ticket | grep "admin@$RELM_NAME"
	then
		tet_result PASS	
	else
		tet_result FAIL
	fi
}

# cleanup section
nis_cleanup()
{
	logmessage "nis cleanup: remove all nis related setting and restore the ipa to the state before the nis test run"
	tet_result PASS	
}

################# test cases start here ################
s1()
{
	tc="nis-1"
	logmessage "$tc: starts"
	logmessage "$tc: nis plugin disabled by default"
	result=`/usr/sbin/rpcinfo -p $host`
	if echo $result | grep ypserv
	then
		logmessage "$tc: failed, $result"
		tet_result FAIL
	else
		tet_result PASS
	fi
	logmessage "$tc: finished"
}
s2()
{
	tc="nis-2"
	logmessage "$tc: starts"
	logmessage "$tc: enable nis plug in"
	# create a password file on remote host
	pwfile="/tmp/pw.txt"
	ssh root@${host} "echo $KERB_MASTER_PASS > $pwfile"
	ssh root@${host} "ipa-compat-manage enable -y $pwfile"
	ssh root@${host} "ipa-nis-manage    enable -y $pwfile"
	ssh root@${host} "service dirsrv restart "
	result=`/usr/sbin/rpcinfo -p $host`
	if echo $result | grep ypserv
	then
		tet_result PASS
	else
		logmessage "$tc: failed, $result"
		tet_result FAIL
	fi
	logmessage "$tc: finished"
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

