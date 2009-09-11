#!/bin/sh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="pass"
iclist="ic1 ic2 ic3"
ic1="tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"

pass()
{
	tet_result PASS
}


######################################################################
tp1()
{
	echo "START $tet_thistest"
	for s in $SERVERS; do
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
	for s in $CLIENTS; do
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
	echo "END $tet_thistest"
}
######################################################################
tp2()
{
	echo "START $tet_thistest"
	for s in $SERVERS; do
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
	for s in $CLIENTS; do
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
	echo "END $tet_thistest"

}
######################################################################

######################################################################
#   Test to make sure the list of files in this test do not exist after uninstall
######################################################################
tp3()
{
	echo "START $tet_thistest"
	rm -f $TET_TMP_DIR/filelist.txt
	echo '/usr/sbin/ipa*
	/tmp/ipa*' > $TET_TMP_DIR/filelist.txt
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			Cleanup $s
			if [ $? -ne 0 ]; then
				echo "ERROR - Cleanup of Server $s failed"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			Cleanup $s
			if [ $? -ne 0 ]; then
				echo "ERROR - Cleanup of Server $s failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}
######################################################################

. $TESTING_SHARED/instlib.sh
. $TESTING_SHARED/shared.sh
. $TET_ROOT/lib/sh/tcm.sh
