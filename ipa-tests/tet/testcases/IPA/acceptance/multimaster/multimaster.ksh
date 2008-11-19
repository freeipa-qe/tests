#!/bin/ksh
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="instclean"
minnum=0
maxnum=3
iclist="ic7"
#iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7"
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
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

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
	echo "STOP $tet_thistest"
}
######################################################################

tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

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
	echo "STOP $tet_thistest"

}

tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

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
	echo "STOP $tet_thistest"
}

tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

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
	echo "STOP $tet_thistest"
}


tp5()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

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
	echo "STOP $tet_thistest"

}

tp6()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

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
	echo "STOP $tet_thistest"
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
		# Create "ipa-replica-manage list" expect file
		rm -f $TET_TMP_DIR/manage-list.exp
		echo '#!/usr/bin/expect -f
set force_conservative 0  ; 
if {$force_conservative} {
        set send_slow {1 .1}
        proc send {ignore arg} {
                sleep .1
                exp_send -s -- $arg
        }
}
set timeout -1' > $TET_TMP_DIR/manage-list.exp
			echo "spawn ipa-replica-manage list" >> $TET_TMP_DIR/manage-list.exp
			echo 'match_max 100000
expect "Directory Manager password: "' >>$TET_TMP_DIR/manage-list.exp
			echo "send -- \"$KERB_MASTER_PASS\"" >> $TET_TMP_DIR/manage-list.exp
			echo 'send -- "rree"' | sed s/rr/'\\'/g | sed s/ee/r/g >> $TET_TMP_DIR/manage-list.exp
			echo 'expect eof' >> $TET_TMP_DIR/manage-list.exp

		# Run the expect file on all of the masters and create a list of all of the fullhostnames in $TET_TMP_DIR/server-list.txt
		rm -f $TET_TMP_DIR/server-list.txt
		for s in $SERVERS; do
			if [ "$s" != "" ]; then
				eval_vars $s
				echo $FULLHOSTNAME >> $TET_TMP_DIR/server-list.txt
				ssh root@$FULLHOSTNAME 'rm -f /tmp/manage-list.exp'
				scp $TET_TMP_DIR/manage-list.exp $FULLHOSTNAME:/tmp/.
				ssh root@$FULLHOSTNAME "expect /tmp/manage-list.exp" > $TET_TMP_DIR/$s-list-out.txt 
				if [ $? -ne 0 ]; then
					echo "ERROR - expect /tmp/manage-list.exp failed on $FULLHOSTNAME"
					tet_result FAIL
				fi
			fi
		done
		# Now check the output of all of the list output files to ensure that hey were correct
		# Start with M1
		eval_vars M1
		s="M1"
		# grep the hostname of the current machine out of the server list, as it will not show up on the ipa-replica-manage list
		grep -v $FULLHOSTNAME $TET_TMP_DIR/server-list.txt > $TET_TMP_DIR/$s-server-list.txt
		cat $TET_TMP_DIR/$s-server-list.txt | while read newlist; do 
			grep $newlist $TET_TMP_DIR/$s-list-out.txt;
			if [ $? -ne 0 ]; then
				echo "ERROR - $newlist not found in server $s's ipa-replica-manage list"
				echo "$s replica-manage list is"
				cat $TET_TMP_DIR/$s-list-out.txt
				tet_result FAIL
			else
				echo "That worked! $newlist was found in the replica list for $FULLHOSTNAME"
			fi
		done
		m1hostname=$FULLHOSTNAME
		# Now do the other servers
		for s in $SERVERS; do
			if [ "$s" != "" ]; then
				eval_vars $s
				grep $m1hostname $TET_TMP_DIR/$s-list-out.txt;
				if [ $? -ne 0 ]; then
					echo "ERROR - $m1hostname not found in server $s's ipa-replica-manage list"
					echo "$s replica-manage list is"
					cat $TET_TMP_DIR/$s-list-out.txt
					tet_result FAIL
				else
					echo "That worked! $m1hostname was found in the replica list for $FULLHOSTNAME"
				fi
			fi
		done
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
