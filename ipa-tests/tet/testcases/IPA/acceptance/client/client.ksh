#!/bin/ksh

######################################################################

######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="client_cleanup"
iclist="ic1 "
ic1="tp1 tp2 tp3"

user1='supusr1'
user1pw='o3m4n5bchdy!'

######################################################################
tp1()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			if [ $? -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		else
			echo "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			if [ $? -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Create user to be used in the rest of the test cases 
# This then sets the password for that user
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"

	eval_vars M1
	superuserfirst=firstnamef
	superuserlast=lastnameg
	ssh root@$FULLHOSTNAME "ipa user-add --first=$superuserfirst --last=$superuserlast $user1"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa user-add failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	SetUserPassword M1 $user1 pw
	if [ $? -ne 0 ]; then
		echo "ERROR - SetUserPassword failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	KinitAsFirst M1 $user1 pw $user1pw
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
# Login to M1 using kerberos token key passing
######################################################################
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	# Populate file in M1 to check with
	eval_vars M1
	srvhostname=$FULLHOSTNAME
	# create the file to test through ssh login
	ssh root@$FULLHOSTNAME "touch /tmp/ipa-client-test.txt"
	if [ $? -ne 0 ]
	then
		echo "ERROR - touch /tmp/ipa-client-test.txt failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $CLIENTS; do
		eval_vars $s

		KinitAs $s $user1 $user1pw

		# now we need to run ssh on the client to ok the ssh key from the server
	        rm -f $TET_TMP_DIR/ssh.exp
        	echo 'set timeout 60
set send_slow {1 .1}' > $TET_TMP_DIR/ssh.exp
		echo "spawn /usr/bin/ssh -l $user1 $srvhostname 'ls /tmp'" >> $TET_TMP_DIR/ssh.exp
		echo 'match_max 100000' >> $TET_TMP_DIR/ssh.exp
		echo 'sleep 4' >> $TET_TMP_DIR/ssh.exp
	        echo "send -s -- \"yes\"" >> $TET_TMP_DIR/ssh.exp
	        echo 'send -s -- "\\r"' >> $TET_TMP_DIR/ssh.exp
		ssh root@$FULLHOSTNAME 'rm -f /tmp/ssh.exp'
		scp $TET_TMP_DIR/ssh.exp root@$FULLHOSTNAME:/tmp/.
		ssh root@$FULLHOSTNAME 'expect /tmp/ssh.exp'&
		sleep 10
	
		# Now, ssh from the client to the master, kerberos auth should work here. 
#		ssh root@$FULLHOSTNAME "ssh -l $user1 $srvhostname 'ls /tmp'" > $TET_TMP_DIR/ssh-output.txt &
		rm -f $TET_TMP_DIR/ipa-client-test.txt
		scp root@$FULLHOSTNAME:/tmp/ipa-client-test.txt $TET_TMP_DIR/.
		sleep 15
#		grep "ipa-client-test.txt" $TET_TMP_DIR/ssh-output.txt
#		if [ $? -ne 0 ]; then
		if [ ! -f "$TET_TMP_DIR/ipa-client-test.txt" ]; then
			echo "Well that didn't work, lets try again"
			cat $TET_TMP_DIR/ssh-output.txt
			ssh root@$FULLHOSTNAME "klist;ssh -l $user1 $srvhostname 'ls /tmp'" > $TET_TMP_DIR/ssh-output.txt &
			sleep 15
			grep "ipa-client-test.txt" $TET_TMP_DIR/ssh-output.txt
			if [ $? -ne 0 ]; then
				echo "Well that didn't work, lets try it a THIRD TIME. We will get a new kinit first."
				KinitAs $s $user1 $user1pw
				cat $TET_TMP_DIR/ssh-output.txt
				ssh root@$FULLHOSTNAME "klist;ssh -l $user1 $srvhostname 'ls /tmp'" > $TET_TMP_DIR/ssh-output.txt &
				sleep 15
				grep "ipa-client-test.txt" $TET_TMP_DIR/ssh-output.txt
				if [ $? -ne 0 ]; then
					echo "Well that didn't work, lets try it a FOURTH TIME. We will get a new kinit first. "
					KinitAs $s $user1 $user1pw
					cat $TET_TMP_DIR/ssh-output.txt
					ssh root@$FULLHOSTNAME "klist;ssh -l $user1 $srvhostname 'ls /tmp'" > $TET_TMP_DIR/ssh-output.txt 
#					sleep 60
					grep "ipa-client-test.txt" $TET_TMP_DIR/ssh-output.txt
					if [ $? -ne 0 ]; then
						echo "ERROR - ipa-client-test.txt not found in $TET_TMP_DIR/ssh-output.txt, the ssh login probably didn't work"
						echo "$TET_TMP_DIR/ssh-output.txt contents are:"
						cat $TET_TMP_DIR/ssh-output.txt
						tet_result FAIL
					fi
				fi
			fi
		fi
	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# Cleanup Section for the cli tests
######################################################################
client_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

	KinitAs M1 $DS_USER $DM_ADMIN_PASS

	ssh root@$FULLHOSTNAME "ipa user-del $user1"
	let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a biguser super"
	#let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a usermod1 modusers"
	#let code=$code+$?

	if [ $code -ne 0 ]; then
		echo "ERROR - setup for $tet_thistest failed"
		tet_result FAIL
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
