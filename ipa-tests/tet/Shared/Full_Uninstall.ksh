#!/bin/ksh
# This file is called by engage after everythig gets run to uninstall the rpms and packages 
# from all of the servers and clients.
# Any additions here should also be made to the quickuninstall acceptance test

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

set -x
######################################################################
tp1()
{
	echo "START tp1"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			UninstallServer $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ipa-server-install --uninstall failed"
				return 1:
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
				return 1
			fi
		fi
	done

	return 0
}
######################################################################
tp2()
{
	echo "START tp2"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			UnInstallServerRPM $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "remove of server RPM's on $s ssh failed"
				return 1
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
				return 1
			fi
		fi
	done

	return 0

}
######################################################################

######################################################################
#   Test to make sure the list of files in this test do not exist after uninstall
######################################################################
tp3()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			is_server_alive $s
			Cleanup $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Cleanup on $s failed"
				return 1
			fi
		fi
	done

	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			is_server_alive $s
			Cleanup $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Cleanup on $s failed"
				return 1
			fi
		fi
	done

	return 0

}
######################################################################

main()
{
	tp1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "tp1 failed"
		return 1
	fi
	tp2
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "tp2 failed"
		return 1
	fi
	tp3
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "tp3 failed"
		return 1
	fi

	return 0
}

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh

main
ret=$?
if [ $ret -ne 0 ]; then
	echo "uninstall failed"
	return 1
fi

return 0
