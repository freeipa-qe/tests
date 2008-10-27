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
	ssh root@$FULLHOSTNAME "ipa-adduser -ffirstname-super -llastbname-super $user1"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME"
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
	# create the file to test through ssh login
	ssh root@$FULLHOSTNAME "touch /tmp/ipa-client-test.txt"
	if [ $? -ne 0 ]
	then
		echo "ERROR - touch /tmp/ipa-client-test.txt failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	for s in $CLIENTS; do
		eval_vars $s

		if [ "$OS" = "RHEL" ]; then
			# run ssh once to list the contents of /tmp
		        rm -f $TET_TMP_DIR/ssh.exp
	        	echo 'set timeout 60
set send_slow {1 .1}' > $TET_TMP_DIR/ssh.exp
			echo "spawn /usr/bin/ssh -l $user1 $FULLHOSTNAME 'ls /tmp'" >> $TET_TMP_DIR/ssh.exp
			echo 'match_max 100000' >> $TET_TMP_DIR/ssh.exp
			echo 'sleep 4' >> $TET_TMP_DIR/ssh.exp
		        echo "send -s -- \"yes\"" >> $TET_TMP_DIR/ssh.exp
		        echo 'send -s -- "\\r"' >> $TET_TMP_DIR/ssh.exp
			echo 'sleep 7' >> $TET_TMP_DIR/ssh.exp
		        echo "send -s -- \"$user1pw\"" >> $TET_TMP_DIR/ssh.exp
		        echo 'send -s -- "\\r"' >> $TET_TMP_DIR/ssh.exp
			expect $TET_TMP_DIR/ssh.exp >$TET_TMP_DIR/ssh-output.txt
			if [ $? -ne 0 ]; then
				echo "ERROR - expect $TET_TMP_DIR/ssh.exp failed"
				tet_result FAIL
			fi
	
			grep "ipa-client-test.txt" $TET_TMP_DIR/ssh-output.txt
			if [ $? -ne 0 ]; then
				echo "ERROR - ipa-client-test.txt not found in $TET_TMP_DIR/ssh-output.txt, the ssh login probably didn't work"
				echo "$TET_TMP_DIR/ssh-output.txt contents are:"
				cat $TET_TMP_DIR/ssh-output.txt
				tet_result FAIL
			fi
		else
			 echo "skipping, OS is not RHEL"
		fi
	
#		ssh root@$FULLHOSTNAME "ipa-findservice \"$service1\""
#		if [ $? -ne 0 ]
#		then
#			echo "ERROR - ipa-findservice failed on $FULLHOSTNAME"
#			tet_result FAIL
#		fi

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

	ssh root@$FULLHOSTNAME "ipa-deluser $user1"
	let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a biguser super"
	#let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a usermod1 modusers"
	#let code=$code+$?

	if [ $code -ne 0 ]
	then
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
