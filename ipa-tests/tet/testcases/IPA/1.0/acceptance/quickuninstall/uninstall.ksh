#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup=""
iclist="setupssh ic1 ic2"
ic1="tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"



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
set -x
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
# This is a negitive test case. The test itself will succeeed, but the 
# underlying test runs a bad ipa-server-install that should fail
######################################################################
tp3()
{
	echo $SERVERS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			SetupServerBogus $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "server-install of server on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done
	echo $CLIENTS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			SetupClientBogus $s
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

######################################################################
tp4()
{
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
