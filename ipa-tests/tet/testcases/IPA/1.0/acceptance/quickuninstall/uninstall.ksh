#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="pass"
iclist="setupssh ic1 ic2 ic3"
ic1="tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"


pass()
{
	tet_result PASS
}

setupssh()
{
	echo "running ssh setup"
	echo $SERVERS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			setup_ssh_keys $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Setup of $s ssh failed"
				tet_result FAIL
			fi
		fi
	done
	echo $CLIENTS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			setup_ssh_keys $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Setup of $s ssh failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
}

######################################################################
tp1()
{
	echo "START tp1"
	echo $SERVERS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			UninstallServer $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ipa-server-install --uninstall failed"
				tet_result FAIL:
			fi
		fi
	done
	echo $CLIENTS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			UninstallClient $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
}
######################################################################
tp2()
{
	echo "START tp2"
	echo $SERVERS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			UnInstallServerRPM $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "remove of server RPM's on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done
	echo $CLIENTS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			UnInstallClientRPM $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "remove of Client RPM's on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS

}
######################################################################

######################################################################
#   Test to make sure the list of files in this test do not exist after uninstall
######################################################################
tp3()
{
	echo "START tp3"
	rm -f $TET_TMP_DIR/filelist.txt
	echo '/usr/sbin/ipa*
	/tmp/ipa*' > $TET_TMP_DIR/filelist.txt
	echo "$SERVERS $CLIENTS" | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			is_server_alive $s
			if [ $ret -ne 0 ]; then
				echo "ERROR - Server $1 appears to not respond to pings."
				return 1;
				tet_result FAIL
			fi
			eval_vars $s
			ssh root@$FULLHOSTNAME 'rm -f /tmp/filelist.txt'
			scp $TET_TMP_DIR/filelist.txt root@$FULLHOSTNAME:/tmp/.
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "scp to $s failed"
				tet_result FAIL
			fi
			# now check to see if any of the files in filelist.txt exist when they should not.
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
		 	ret=$?
			if [ $ret -ne 0 ]; then
				echo "some files still exist that should not"
				tet_result FAIL
			fi
		
		fi
	done

	tet_result PASS

}
######################################################################

######################################################################
tp4()
{
	echo "START tp4"
	echo $SERVERS | while read s; do
		if [ "$s" != "" ]; then
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
		fi
	done
	echo $CLIENTS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			SetupClient $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "client-install of server on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS

}
######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
