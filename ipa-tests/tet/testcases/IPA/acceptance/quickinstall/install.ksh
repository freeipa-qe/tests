#!/usr/bin/pdksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8"
ic1="setupssh tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"
ic5="tp5"
ic6="tp6"
ic7="tp7"
ic8="tp8"


setupssh()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START setupssh"
	echo "running ssh setup"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			setup_ssh_keys $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Setup of $s ssh failed"
				tet_result FAIL
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			setup_ssh_keys $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Setup of $s ssh failed"
				tet_result FAIL
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	tet_result PASS
}

######################################################################
tp1()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp1"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	tet_result PASS
	echo "tp1 finish"
}
######################################################################
tp2()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp2"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			InstallServerRPM $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			InstallClientRPM $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	tet_result PASS

}
######################################################################

######################################################################
# This is a negitive test case. The test itself will succeeed, but the 
# underlying test runs a bad ipa-server-install that should fail
######################################################################
tp3()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp3"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			SetupServerBogus $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "server-install of server on $s ssh failed"
				tet_result FAIL
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			SetupClientBogus $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "client-install of server on $s ssh failed"
				tet_result FAIL
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	tet_result PASS

}
######################################################################

######################################################################
tp4()
{
	echo "START tp4"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			SetupServer $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "server-install of server on $s ssh failed"
				tet_result FAIL
			fi
			if [ "$s" = "M1" ]; then
				FixBindServer $s
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "fix-bind-server on $s ssh failed"
					tet_result FAIL
				fi
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	
	tet_result PASS

}
######################################################################

######################################################################
# Run some DNS test to make sure everything is working, if so, set 
# resolv.conf to point to the right place.
######################################################################
tp5()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp5"
	# Get the IP of the first server to be used in the DNS tests.
	eval_vars M1
	dns=$IP
	for s in $SERVERS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		FixResolv $s
		ret=$?
		if [ $ret != 0 ]; then
			echo "ERROR - fix of resolv.conf failed";
			tet_result FAIL
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	for s in $CLIENTS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		FixResolv $s
		ret=$?
		if [ $ret != 0 ]; then
			echo "ERROR - fix of resolv.conf failed";
			tet_result FAIL
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	tet_result PASS

}
######################################################################

######################################################################
# Set up clients
######################################################################
tp6()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp6"
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			SetupClient $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "client-install of server on $s ssh failed"
				tet_result FAIL
			fi
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	tet_result PASS

}
######################################################################

######################################################################
# Test to ensure that kinit works
######################################################################
tp7()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START tp7"
	rm -f $TET_TMP_DIR/kinit.exp
	echo 'set timeout 60
set send_slow {1 .1}
spawn /usr/kerberos/bin/kinit admin
match_max 100000
sleep 15'  > $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$KERB_MASTER_PASS\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	for s in $SERVERS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		# Populate kinit expect file
		ssh root@$FULLHOSTNAME 'rm -f /tmp/kinit.exp'
		scp $TET_TMP_DIR/kinit.exp root@$FULLHOSTNAME:/tmp/.		

		ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp'
		ret=$?
		if [ $ret != 0 ]; then
		        echo "ERROR - kinit failed";
			tet_result FAIL
		fi

		ssh root@$FULLHOSTNAME '/usr/sbin/ipa-finduser admin'
		ret=$?
		if [ $ret != 0 ]; then
        		echo "ERROR - ipa-finduser failed";
			tet_result FAIL
		fi

		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	for s in $CLIENTS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		# Populate kinit expect file
		ssh root@$FULLHOSTNAME 'rm -f /tmp/kinit.exp'
		scp $TET_TMP_DIR/kinit.exp root@$FULLHOSTNAME:/tmp/.		

		ssh root@$FULLHOSTNAME 'kdestroy;/usr/bin/expect /tmp/kinit.exp'
		ret=$?
		if [ $ret != 0 ]; then
	        	echo "ERROR - kinit failed";
			tet_result FAIL
		fi

		if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
			ssh root@$FULLHOSTNAME '/usr/sbin/ipa-finduser admin'
			ret=$?
			if [ $ret != 0 ]; then
        			echo "ERROR - ipa-finduser failed";
				tet_result FAIL
			fi
		fi

		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	tet_result PASS

}

######################################################################
# Test to ensure that all of the machines seem to sync up when creating users
######################################################################
tp8()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	user1="testusr1"
	user2="testusr2"
	group1="testgroup1"
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 2' -l 'lastname' $user2;"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa-addgroup $group1 -g 725 -d 'group for testing';"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa-addgroup failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa-modgroup --add $user1 $group1"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa-modgroup failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser $user1"
		if [ $? != 0 ]; then
        		echo "ERROR - ipa-finduser failed on $FULLHOSTNAME";
			tet_result FAIL
		fi
		ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser $user2"
		if [ $? != 0 ]; then
        		echo "ERROR - ipa-finduser failed on $FULLHOSTNAME";
			tet_result FAIL
		fi
		ssh root@$FULLHOSTNAME "/usr/sbin/ipa-findgroup -v $group1 | grep $user1"
		if [ $? != 0 ]; then
        		echo "ERROR - ipa-finduser failed on $FULLHOSTNAME";
			tet_result FAIL
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	for s in $CLIENTS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
			ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser $user1"
			if [ $? != 0 ]; then
        			echo "ERROR - ipa-finduser failed on $FULLHOSTNAME";
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser $user2"
			if [ $? != 0 ]; then
        			echo "ERROR - ipa-finduser failed on $FULLHOSTNAME";
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "/usr/sbin/ipa-findgroup -v $group1 | grep $user1"
			if [ $? != 0 ]; then
        			echo "ERROR - ipa-finduser failed on $FULLHOSTNAME";
				tet_result FAIL
			fi
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	# Cleanup
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa-delgroup $group1; \
ipa-deluser $user1; \
ipa-deluser $user2;"
	
	tet_result PASS

}

instclean()
{
if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "instclean start"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			eval_vars $s
			ssh root@$FULLHOSTNAME 'kdestroy'
			ret=$?
			if [ $ret != 0 ]; then
	       			echo "ERROR - kdestroy on server $s failed, continuing anyway";
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi

	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			eval_vars $s
			ssh root@$FULLHOSTNAME 'kdestroy'
			ret=$?
			if [ $ret != 0 ]; then
	       			echo "ERROR - kdestroy on client $s failed, continuing anyway";
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	tet_result PASS
	echo "instclean finish"

}

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
