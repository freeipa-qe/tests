#!/bin/ksh

######################################################################
# Run ipa-adduser followed by kdestroy over and over again to see how often it works.
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# This is the number of users to create on every master
mastermax=10000
# The next line is required as it picks up data about the servers to use
tet_startup="TestSetup"
tet_cleanup="ipaadduser_cleanup"
iclist="ic1 "
ic1="tp1 tp2 tp3 tp4"

TestSetup()
{
	eval_vars M1
	#ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife 0"
	tet_result PASS
}

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
#	ipa-adduser as admin, and check to see if it worked $ITTERATIONS times
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	#runnum=0
	#while [[ $runnum -lt $ITTERATIONS ]]; do
	usrnum=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-addusr.bash
			while [[ $usrnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa-adduser -ffirstname-super -llastbname-super u$hexnum&" >> $TET_TMP_DIR/$s-addusr.bash 
				let usrnum=$usrnum+1
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa-adduser -ffirstname-super -llastbname-super u$hexnum&" >> $TET_TMP_DIR/$s-addusr.bash 
				let usrnum=$usrnum+1
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa-adduser -ffirstname-super -llastbname-super u$hexnum" >> $TET_TMP_DIR/$s-addusr.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-addusr.bash
				let usrnum=$usrnum+1
			done
			ssh root@$FULLHOSTNAME "rm -f /tmp/$s-addusr.bash";
			chmod 755 $TET_TMP_DIR/$s-addusr.bash
			scp $TET_TMP_DIR/$s-addusr.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/$s-addusr.bash > /tmp/$s-addusr.bash-output"
			rm -f $TET_TMP_DIR/$s-addusr.bash-output
			scp root@$FULLHOSTNAME:/tmp/$s-addusr.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/$s-addusr.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in adduser output see $TET_TMP_DIR/$s-addusr.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/$s-addusr.bash-output
				fi
				tet_result FAIL
			fi
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
#		let runnum=$runnum+1

#	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
#     check to confirm that the users exist on the masters 
######################################################################
tp3()
######################################################################
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	#runnum=0
	#while [[ $runnum -lt $ITTERATIONS ]]; do
	usrnum=0
	maxnum=$mastermax
	echo '#!/bin/bash' > $TET_TMP_DIR/stress-findusr.bash
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			while [[ $usrnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa-finduser u$hexnum > /dev/shm/find-out.txt" >> $TET_TMP_DIR/stress-findusr.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-findusr.bash
				echo "grep 'First Name: firstname-super' /dev/shm/find-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - firstname-super not in /dev/shm/find-out.txt'; cat /dev/shm/find-out.txt;fi" >> $TET_TMP_DIR/stress-findusr.bash
				let usrnum=$usrnum+1
			done
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "rm -f /tmp/stress-findusr.bash";
			chmod 755 $TET_TMP_DIR/stress-findusr.bash
			scp $TET_TMP_DIR/stress-findusr.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/stress-findusr.bash > /tmp/stress-findusr.bash-output"
			rm -f $TET_TMP_DIR/stress-findusr.bash-output
			scp root@$FULLHOSTNAME:/tmp/stress-findusr.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/stress-findusr.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in finduser output see $TET_TMP_DIR/stress-findusr.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/stress-findusr.bash-output
				fi
				tet_result FAIL
			fi
		fi
	done

#		let runnum=$runnum+1

#	done

	tet_result PASS
	echo "END $tet_thistest"

}

######################################################################
# delete users
######################################################################
tp4()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	#runnum=0
	#while [[ $runnum -lt $ITTERATIONS ]]; do
	usrnum=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-delusr.bash
			while [[ $usrnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa-deluser u$hexnum" >> $TET_TMP_DIR/$s-delusr.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-delusr.bash
				let usrnum=$usrnum+1
			done
			ssh root@$FULLHOSTNAME "rm -f /tmp/$s-delusr.bash";
			chmod 755 $TET_TMP_DIR/$s-delusr.bash
			scp $TET_TMP_DIR/$s-delusr.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/$s-delusr.bash > /tmp/$s-delusr.bash-output"
			rm -f $TET_TMP_DIR/$s-delusr.bash-output
			scp root@$FULLHOSTNAME:/tmp/$s-delusr.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/$s-delusr.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in deluser output see $TET_TMP_DIR/$s-delusr.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/$s-delusr.bash-output
				fi

				tet_result FAIL
			fi
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
#		let runnum=$runnum+1

#	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
# Cleanup Section for the ipa-adduser tests
######################################################################
ipaadduser_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0

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
