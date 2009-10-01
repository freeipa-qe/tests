#!/bin/sh
# This file is called by engage to install the rpms and packages 
# to all of the servers and clients.
# Any additions here should also be made to the quickinstall acceptance test

setupssh()
{
	echo "START setupssh"
	echo "running ssh setup"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			setup_ssh_keys $s
			if [ $? -ne 0 ]; then
				echo "Setup of $s ssh failed"
				return 1
			fi
			set_date $s
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			setup_ssh_keys $s
			if [ $? -ne 0 ]; then
				echo "Setup of $s ssh failed"
				return 1
			fi
			set_date $s
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	return 0
}

######################################################################
tp1()
{
	echo "START tp1"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			BackupResolv $s
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				return 1
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			BackupResolv $s
			SetupRepo $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Install of server RPM on $s ssh failed"
				return 1
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	return 0
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
				return 1
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
				return 1
			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	return 0

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

			ntpdate $NTPSERVER
			eval_vars $s
			ssh root@$FULLHOSTNAME "/etc/init.d/ntpd stop; ntpdate $NTPSERVER"
			SetupServer $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "server-install of server on $s ssh failed"
				return 1
			fi
			if [ "$s" == "M1" ]; then
				FixBindServer $s
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "fix-bind-server on $s ssh failed"
					return 1
				fi
			eval_vars $s
			ssh root@$FULLHOSTNAME "ps -ef | grep slapd"

			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

			ssh root@$FULLHOSTNAME "ps -ef | grep slapd"
	return 0

}
######################################################################

######################################################################
# Run some DNS test to make sure everything is working, if so, set 
# resolv.conf to point to the right place.
######################################################################
tp5()
{
	set -x
	echo "START tp5"
	# Get the IP of the first server to be used in the DNS tests.
	eval_vars M1
	export dnss=$IP
	for s in $SERVERS; do

			ssh root@$FULLHOSTNAME "ps -ef | grep slapd"
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		FixResolv $s
		ret=$?
		if [ $ret != 0 ]; then
			echo "ERROR - repair of resolv.conf on $s failed";
			return 1
		fi
			eval_vars $s
			ssh root@$FULLHOSTNAME "ps -ef | grep slapd"

	done

	for s in $CLIENTS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		FixResolv $s
		ret=$?
		if [ $ret != 0 ]; then
			echo "ERROR - repair of resolv.conf on $s failed";
			return 1
		fi
	done

	if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	return 0

}
######################################################################

######################################################################
# Setup the clients
######################################################################
tp6()
{
	set -x
	echo "START tp6"

	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "working on $s now"
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			eval_vars $s
			ssh root@$FULLHOSTNAME "/etc/init.d/ntpd stop; ntpdate $NTPSERVER"
			SetupClient $s
			if [ $? -ne 0 ]; then
				echo "client-install of server on $s ssh failed"
				return 1
			fi
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

			ssh root@$FULLHOSTNAME "ps -ef | grep slapd"
	return 0
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
			ssh root@$FULLHOSTNAME "ps -ef | grep slapd"

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

	return 0
	echo "instclean finish"

}

######################################################################

RunFullInstall()
{
	echo "Running setup on all hosts"

	# The next line is required as it picks up data about the servers to use
	CheckAlive
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "Some servers or clients not alive"
		return 1
	fi
	setupssh
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "Setup of ssh on one or more of the servers or clients failed"
		return 1
	fi
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
#	tp3
#	ret=$?
#	if [ $ret -ne 0 ]; then
#		echo "tp3 failed"
#		return 1
#	fi
	tp4
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "tp4 failed"
		return 1
	fi
	tp5
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "tp5 failed"
		return 1
	fi
	tp6
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "tp6 failed"
		return 1
	fi

	instclean

	return 0
}

. $TESTING_SHARED/instlib.sh
. $TESTING_SHARED/shared.sh

if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
RunFullInstall


