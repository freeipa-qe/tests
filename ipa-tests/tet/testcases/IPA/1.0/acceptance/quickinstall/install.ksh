#!/usr/bin/pdksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="setupssh ic1 ic2 ic3 ic4 ic5"
ic1="setupssh tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"
ic5="tp5 tp6"



setupssh()
{
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
			FixBindServer $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "fix-bind-server on $s ssh failed"
				tet_result FAIL
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
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
# Run some DNS test to make sure everything is working, if so, set 
# resolv.conf to point to the right place.
######################################################################
tp5()
{
	echo "START tp5"
	# Get the IP of the first server to be used in the DNS tests.
	eval_vars M1
	dns=$IP
	for s in "$SERVERS $CLIENTS"; do
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
# Test to ensure that kinit works
######################################################################
tp6()
{
	echo "START tp6"
	for s in $SERVERS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		# Populate kinit expect file
		rm -f $TET_TMP_DIR/kinit.exp
		echo 'set timeout -1
set send_slow {1 .1}
spawn /usr/kerberos/bin/kinit admin
match_max 100000
expect "Password for admin"
sleep 1'  > $TET_TMP_DIR/kinit.exp
echo "send -s -- \"$KERB_MASTER_PASS\r\"" >> $TET_TMP_DIR/kinit.exp
echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp
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
		rm -f $TET_TMP_DIR/kinit.exp
		echo 'set timeout -1
set send_slow {1 .1}
spawn /usr/kerberos/bin/kinit admin
match_max 100000
expect "Password for admin"
sleep 1
send -s -- "Secret123\r"
expect eof ' > $TET_TMP_DIR/kinit.exp
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

	tet_result PASS

}

instclean()
{
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
