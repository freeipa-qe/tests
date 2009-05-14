#!/usr/bin/pdksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9"
ic1="setupssh tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"
ic5="tp5"
ic6="tp6"
ic7="tp7"
ic8="tp8"
ic9="tp9"

resetdate()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START resetdate"
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			set_date $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "set date on $s failed"
				tet_result FAIL
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
			echo "working on $s now"
			set_date $s
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "Setdate on $s failed"
				tet_result FAIL
			fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done

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

	tet_result PASS
}

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
	echo "START $tet_thistest"
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
	echo "STOP $tet_thistest"
}
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
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
	echo "STOP $tet_thistest"

}
######################################################################

######################################################################
# This is a negitive test case. The test itself will succeeed, but the 
# underlying test runs a bad ipa-server-install that should fail
######################################################################
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
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
	echo "STOP $tet_thistest"

}
######################################################################

######################################################################
tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
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
	# This should be run as part of SetupServer
#			if [ "$s" = "M1" ]; then
#				FixBindServer $s
#				ret=$?
#				if [ $ret -ne 0 ]; then
#					echo "fix-bind-server on $s ssh failed"
#					tet_result FAIL
#				fi
#			fi
			if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
		fi
	done
	
	tet_result PASS	
	echo "STOP $tet_thistest"

}
######################################################################

######################################################################
# Run some DNS test to make sure everything is working, if so, set 
# resolv.conf to point to the right place.
######################################################################
tp5()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
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
	echo "STOP $tet_thistest"

}
######################################################################

######################################################################
# Set up clients
######################################################################
tp6()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
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
	echo "STOP $tet_thistest"

}
######################################################################

######################################################################
# Test to ensure that kinit works
######################################################################
tp7()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	for s in $SERVERS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		KinitAs $s $DS_USER $DM_ADMIN_PASS	
		if [ $? != 0 ]; then
		        echo "ERROR - kinit failed";
			tet_result FAIL
		fi

		ssh root@$FULLHOSTNAME 'ipa user-find admin'
		ret=$?
		if [ $ret != 0 ]; then
        		echo "ERROR - ipa user-find admin failed";
			tet_result FAIL
		fi

		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	for s in $CLIENTS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s

		KinitAs $s $DS_USER $DM_ADMIN_PASS
		if [ $? != 0 ]; then
	        	echo "ERROR - kinit failed";
			tet_result FAIL
		fi

		if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
			ssh root@$FULLHOSTNAME 'ipa user-find admin'
			ret=$?
			if [ $ret != 0 ]; then
        			echo "ERROR - ipa user-find admin failed";
				tet_result FAIL
			fi
		fi

		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	tet_result PASS
	echo "STOP $tet_thistest"

}

######################################################################
# Test to ensure that ipa-replica-manage shows proper information
######################################################################
tp8()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	if [ $NUMSERVERS -ne 1 ]; then
		echo "We have more than one master, great! Let's test to ensure that ipa-replica-manage shows what is should"
		
	fi

	tet_result PASS
	echo "STOP $tet_thistest"

}

######################################################################
# Test to ensure that all of the machines seem to sync up when creating users
######################################################################
tp9()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	eval_vars M1
	user1="testusr1"
	user2="testusr2"
	group1="testgroup1"
	ssh root@$FULLHOSTNAME "ipa user-add --first='test user 1' --last='lastname' $user1;"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa user-add failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa user-add --first='test user 1' --last='lastname' $user2;"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa user-add failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa group-add $group1 --gid=725 --description='group for testing';"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa group-add failed on $FULLHOSTNAME";
		tet_result FAIL
	fi
	ssh root@$FULLHOSTNAME "ipa group-mod --add $user1 $group1"
	if [ $? != 0 ]; then
	        echo "ERROR - ipa group-mod failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	for s in $SERVERS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		ssh root@$FULLHOSTNAME "ipa user-finduser $user1"
		if [ $? != 0 ]; then
        		echo "ERROR - ipa user-find failed on $FULLHOSTNAME";
			tet_result FAIL
		fi
		ssh root@$FULLHOSTNAME "ipa user-finduser $user2"
		if [ $? != 0 ]; then
        		echo "ERROR - ipa user-find failed on $FULLHOSTNAME";
			tet_result FAIL
		fi

		ssh root@$FULLHOSTNAME "ipa group-find -v $group1 | grep $user1"
		if [ $? != 0 ]; then
        		echo "ERROR - ipa $user1 not found in $group1 failed on $FULLHOSTNAME";
			tet_result FAIL
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	for s in $CLIENTS; do
		if [ "$DSTET_DEBUG" = "y" ]; then echo "working on $s now"; fi
		eval_vars $s
		if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
			ssh root@$FULLHOSTNAME "ipa user-finduser $user1"
			if [ $? != 0 ]; then
        			echo "ERROR - ipa user-find failed on $FULLHOSTNAME";
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa user-finduser $user2"
			if [ $? != 0 ]; then
        			echo "ERROR - ipa user-find failed on $FULLHOSTNAME";
				tet_result FAIL
			fi
	
			ssh root@$FULLHOSTNAME "ipa group-find -v $group1 | grep $user1"
			if [ $? != 0 ]; then
        			echo "ERROR - ipa $user1 not found in $group1 failed on $FULLHOSTNAME";
			tet_result FAIL
			fi
		fi
		if [ "$DSTET_DEBUG" = "y" ]; then echo "done working on $s"; fi
	done

	# Cleanup
	eval_vars M1
	ssh root@$FULLHOSTNAME "ipa group-del $group1; \
ipa user-del $user1; \
ipa user-del $user2;"
	
	tet_result PASS
	echo "STOP $tet_thistest"

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
