#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
minnum=0
maxnum=3
iclist="ic1 ic2 ic3 ic4 ic5 ic6"
ic1="tp1"
ic2="tp2"
ic3="tp3"
ic4="tp4"
ic5="tp5"
ic6="tp6"
ic7="tp7"

######################################################################
tp1()
{
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	echo "START tp1"
	echo "kiniting as admin on all hosts"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER on $s now"
			KinitAs $s $DS_USER $DM_ADMIN_PASS 
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kinit as $DS_USER on $s, using $DM_ADMIN_PASS failed"
				tet_result FAIL
			fi
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER on $s now"
			KinitAs $s $DS_USER $DM_ADMIN_PASS 
			ret=$?
			if [ $ret -ne 0 ]; then
				echo "ERROR - kinit as $DS_USER on $s, using $DM_ADMIN_PASS failed"
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
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	echo "creating 10 users on M1"
	eval_vars M1
	usernum=$minnum
	while [[ $usernum -lt $maxnum ]] ; do
		echo "creating user usr$usernum-x on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "ipa-adduser -p $DM_ADMIN_PASS -f userfirstname$usernum -l userlastname$usernum usr$usernum-x"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ERROR - creation of usr$usernum-x on M1 failed ssh failed"
			tet_result FAIL
		fi
	let usernum+=1
	done

	tet_result PASS

}

tp3()
{
	echo "START tp3"
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "verifying that the users exist on the server $s"
			eval_vars $s
			usernum=$minnum
			while [[ $usernum -lt $maxnum ]] ; do
				ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser usr$usernum-x | /bin/grep Login: | /bin/grep usr$usernum-x"
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "ERROR - serch for usr$usernum-x on server $FULLHOSTNAME failed"
					tet_result FAIL
				fi
				let usernum+=1
			done
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "verifying that the users exist on the client $s"
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				usernum=$minnum
				while [[ $usernum -lt $maxnum ]] ; do
					ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser usr$usernum-x | /bin/grep Login: | /bin/grep usr$usernum-x"
					ret=$?
					if [ $ret -ne 0 ]; then
						echo "ERROR - serch for usr$usernum-x on client $FULLHOSTNAME failed"
						tet_result FAIL
					fi
					let usernum+=1
				done
			fi
			echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
		fi
	done

	tet_result PASS
}

tp4()
{
	echo "START tp4"
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "modifying lastname for users on the server $s"
			eval_vars $s
			usernum=$minnum
			while [[ $usernum -lt $maxnum ]] ; do
				ssh root@$FULLHOSTNAME "/usr/sbin/ipa-moduser -l testtesttestk$s usr$usernum-x"
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "ERROR - search for usr$usernum-x on server $FULLHOSTNAME failed"
					tet_result FAIL
				fi
				eval_vars M1
				ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser -a usr$usernum-x | /bin/grep Last\ Name | /bin/grep testtesttestk$s"
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "ERROR - search for testtesttestk$s in usr$usernum-x on server $FULLHOSTNAME failed"
					tet_result FAIL
				fi

				let usernum+=1
			done
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "modifying lastname for users on the server $s"
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				usernum=$minnum
				while [[ $usernum -lt $maxnum ]] ; do
					ssh root@$FULLHOSTNAME "/usr/sbin/ipa-moduser -l testtesttestk$s usr$usernum-x"
					ret=$?
					if [ $ret -ne 0 ]; then
						echo "ERROR - search for usr$usernum-x on server $FULLHOSTNAME failed"
						tet_result FAIL
					fi
					eval_vars M1
					ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser -a usr$usernum-x | /bin/grep Last\ Name | /bin/grep testtesttestk$s"
					ret=$?
					if [ $ret -ne 0 ]; then
						echo "ERROR - search for testtesttestk$s in usr$usernum-x on server $FULLHOSTNAME failed"
						tet_result FAIL
					fi
	
					let usernum+=1
				done
			fi
			echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
		fi
	done

	tet_result PASS
}


tp5()
{
	echo "START tp5"
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	echo "deleting 10 users on M1"
	eval_vars M1
	usernum=$minnum
	while [[ $usernum -lt $maxnum ]] ; do
		echo "deleting user usr$usernum-x on $FULLHOSTNAME"
		ssh root@$FULLHOSTNAME "/usr/sbin/ipa-deluser usr$usernum-x"
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "ERROR - deletion of usr$usernum-x on M1 failed ssh failed"
			tet_result FAIL
		fi
	let usernum+=1
	done

	tet_result PASS

}

tp6()
{
	echo "START tp6"
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "verifying that the users DO NOT exist on the server $s"
			eval_vars $s
			usernum=$minnum
			while [[ $usernum -lt $maxnum ]] ; do
				ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser usr$usernum-x"
				ret=$?
				if [ $ret -eq 0 ]; then
					echo "ERROR - search for usr$usernum-x on server $FULLHOSTNAME succeeded, and it shouldn't have"
					tet_result FAIL
				fi
				let usernum+=1
			done
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "verifying that the users DO NOT exist on the client $s"
			eval_vars $s
			if [ "$OS_VER" -eq "5" ] && [ "$OS" -eq "RHEL" ]; then
				usernum=$minnum
				while [[ $usernum -lt $maxnum ]] ; do
					ssh root@$FULLHOSTNAME "/usr/sbin/ipa-finduser usr$usernum-x"
					ret=$?
					if [ $ret -eq 0 ]; then
						echo "ERROR - search for usr$usernum-x on client $FULLHOSTNAME succeeded, and it shouldn't have"
						tet_result FAIL
					fi
					let usernum+=1
				done
			fi
			echo "Client $s is not rhel5, it's os is $OS, it's version is $OS_VER"
		fi
	done

	tet_result PASS
}

######################################################################
# Test to ensure that ipa-replica-manage shows proper information
######################################################################
tp7()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	if [ $NUMSERVERS -ne 1 ]; then
		echo "We have more than one master, great! Let's test to ensure that ipa-replica-manage shows what is should"
		
	fi

	tet_result PASS
	echo "STOP $tet_thistest"

}

instclean()
{
	if [ "$DSTET_DEBUG" = "y" ]; then
		set -x
	fi

	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "It is okay if this kdestroy fails"
			ssh root@$FULLHOSTNAME 'kdestroy'
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "It is okay if this kdestroy fails"
			ssh root@$FULLHOSTNAME 'kdestroy'
		fi
	done

	tet_result PASS

}

######################################################################

. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
