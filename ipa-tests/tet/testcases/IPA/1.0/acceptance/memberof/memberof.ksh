#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="setupssh ic1 ic2"
ic1="tp1"
ic2="tp2"

setupssh()
{
	echo "START setupssh"
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
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				tet_result FAIL
			fi
		fi
	done
	echo $CLIENTS | while read s; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			SetupRepo $s
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
}

instclean()
{
	ssh root@$FULLHOSTNAME 'kdestroy'
	ret=$?
	if [ $ret != 0 ]; then
       		echo "ERROR - kdestroy failed, continuing anyway";
	fi
	tet_result PASS

}

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
