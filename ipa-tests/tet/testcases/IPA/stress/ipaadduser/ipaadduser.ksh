#!/bin/ksh

######################################################################
# User CLI stress tests
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# This is the number of users to create on every master
mastermax=2000
# The next line is required as it picks up data about the servers to use
tet_startup="kinit"
tet_cleanup="ipaadduser_cleanup"
iclist="ic1 ic2 ic3 ic4 ic5 ic6 ic7"
ic1="addusers"
ic2="findusers"
ic3="modusers"
ic4="showusers"
ic5="lockusers"
ic6="unlockusers"
ic7="delusers"


######################################################################
kinit()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: kinit Everywhere"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			if [ $? -ne 0 ]; then
				message "ERROR - kinit on $s failed"
				myresult=FAIL
			fi
		else
			message "skipping $s"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			if [ $? -ne 0 ]; then
				message "ERROR - kinit on $s failed"
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

######################################################################
#	ipa-adduser as admin, and check to see if it worked $ITTERATIONS times
######################################################################
addusers()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: Add $mastermax Users"
	#runnum=0
	#while [[ $runnum -lt $ITTERATIONS ]]; do
	usrnum=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "working on $s"
			eval_vars $s
			message '#!/bin/bash' > $TET_TMP_DIR/$s-addusr.bash
			while [[ $usrnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa -n user-add --first=f$hexnum --last=l$hexnum" >> $TET_TMP_DIR/$s-addusr.bash 
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
				message "ERROR - ERROR detected in adduser output see $TET_TMP_DIR/$s-addusr.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					message "debugging output:"
					cat $TET_TMP_DIR/$s-addusr.bash-output
				fi
				myresult=FAIL
			fi
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
#		let runnum=$runnum+1

#	done

	result $myresult
	message "END $tet_thistest"
}
######################################################################

######################################################################
#     check to confirm that the users exist on the masters 
######################################################################
findusers()
######################################################################
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: Find $mastermax Users"
	#runnum=0
	#while [[ $runnum -lt $ITTERATIONS ]]; do
	usrnum=0
	maxnum=$mastermax
	message '#!/bin/bash' > $TET_TMP_DIR/stress-findusr.bash
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "working on $s"
			eval_vars $s
			while [[ $usrnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa user-find fl$hexnum > /dev/shm/find-out.txt" >> $TET_TMP_DIR/stress-findusr.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-findusr.bash
				echo "grep 'givenname: f$hexnum' /dev/shm/find-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - f$hexnum not in /dev/shm/find-out.txt'; cat /dev/shm/find-out.txt;fi" >> $TET_TMP_DIR/stress-findusr.bash
				let usrnum=$usrnum+1
			done
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "working on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "rm -f /tmp/stress-findusr.bash";
			chmod 755 $TET_TMP_DIR/stress-findusr.bash
			scp $TET_TMP_DIR/stress-findusr.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/stress-findusr.bash > /tmp/stress-findusr.bash-output"
			rm -f $TET_TMP_DIR/stress-findusr.bash-output
			scp root@$FULLHOSTNAME:/tmp/stress-findusr.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/stress-findusr.bash-output
			if [ $? -eq 0 ]; then
				message "ERROR - ERROR detected in finduser output see $TET_TMP_DIR/stress-findusr.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					message "debugging output:"
					cat $TET_TMP_DIR/stress-findusr.bash-output
				fi
				myresult=FAIL
			fi
		fi
	done

#		let runnum=$runnum+1

#	done

	result $myresult
	message "END $tet_thistest"

}

######################################################################
# modify users
######################################################################

modusers()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Modify $mastermax Users"
        usrnum=0
        maxnum=$mastermax
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
                        echo '#!/bin/bash' > $TET_TMP_DIR/$s-moduser.bash
                        while [[ $usrnum -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $usrnum)
                                echo "ipa user-mod --home=/usr/local/bin/bash fl$hexnum" >> $TET_TMP_DIR/$s-moduser.bash
                                let usrnum=$usrnum+1
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-moduser.bash
                        done

                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-moduser.bash";
                        chmod 755 $TET_TMP_DIR/$s-moduser.bash
                        scp $TET_TMP_DIR/$s-moduser.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-moduser.bash > /tmp/$s-moduser.bash-output"
                        rm -f $TET_TMP_DIR/$s-moduser.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-moduser.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-moduser.bash-output
                        if [ $? -eq 0 ]; then 
                                echo "ERROR - ERROR detected in user-mod output see $TET_TMP_DIR/$s-moduser.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/$s-moduser.bash-output
                                fi 
                                myresult=FAIL
                        fi
                        # Incriment maxnum for the next server
                        let maxnum=$maxnum+$mastermax
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

######################################################################
# show users
######################################################################

showusers()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Show $mastmax Users"
        usrnum=0
        maxnum=$mastermax
        echo '#!/bin/bash' > $TET_TMP_DIR/stress-showuser.bash
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s

                        while [[ $usrnum -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $usrnum)
                                echo "ipa user-show fl$hexnum > /dev/shm/show-out.txt" >> $TET_TMP_DIR/stress-showuser.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-showuser.bash
                                echo "grep 'homedirectory: /usr/local/bin/bash' /dev/shm/show-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - homedirectory: /usr/local/bin/bash not in /dev/shm/show-out.txt'; cat /dev/shm/show-out.txt;fi" >> $TET_TMP_DIR/stress-showuser.bash
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
                        ssh root@$FULLHOSTNAME "rm -f /tmp/stress-showuser.bash";
                        chmod 755 $TET_TMP_DIR/stress-showuser.bash
                        scp $TET_TMP_DIR/stress-showuser.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/stress-showuser.bash > /tmp/stress-showuser.bash-output"
                        rm -f $TET_TMP_DIR/stress-showuser.bash-output
                        scp root@$FULLHOSTNAME:/tmp/stress-showuser.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/stress-showuser.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in showuser output see $TET_TMP_DIR/stress-showuser.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/stress-showuser.bash-output
                                fi
               
        			myresult=FAIL
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

######################################################################
# lock users
######################################################################
lockusers()
{
        myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Lock $mastermax Users"
        usrnum=0
        maxnum=$mastermax
	echo '#!/bin/bash' > $TET_TMP_DIR/stress-showuser.bash
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        message "working on $s"
                        eval_vars $s
                        message '#!/bin/bash' > $TET_TMP_DIR/$s-lockusr.bash
                        while [[ $usrnum -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $usrnum)
                                echo "ipa -n user-lock fl$hexnum" >> $TET_TMP_DIR/$s-lockusr.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-lockusr.bash

                                echo "ipa user-show --all fl$hexnum > /dev/shm/show-out.txt" >> $TET_TMP_DIR/stress-showuser.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-showuser.bash
                                echo "grep 'inactivated' /dev/shm/show-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - inactivated not in /dev/shm/show-out.txt'; cat /dev/shm/show-out.txt;fi" >> $TET_TMP_DIR/stress-showuser.bash

                                let usrnum=$usrnum+1
                        done
                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-lockusr.bash /tmp/stress-showuser.bash";
                        chmod 755 $TET_TMP_DIR/$s-lockusr.bash $TET_TMP_DIR/stress-showuser.bash
                        scp $TET_TMP_DIR/stress-showuser.bash $TET_TMP_DIR/$s-lockusr.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-lockusr.bash > /tmp/$s-lockusr.bash-output"
			ssh root@$FULLHOSTNAME "/tmp/stress-showuser.bash > /tmp/stress-showuser.bash-output"
                        rm -f $TET_TMP_DIR/$s-lockusr.bash-output $TET_TMP_DIR/stress-showuser.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-lockusr.bash-output $TET_TMP_DIR/.
			scp root@$FULLHOSTNAME:/tmp/stress-showuser.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-lockusr.bash-output
                        if [ $? -eq 0 ]; then
                                message "ERROR - ERROR detected in user-lock output see $TET_TMP_DIR/$s-lockusr.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        message "debugging output:"
                                        cat $TET_TMP_DIR/$s-lockusr.bash-output
                                fi
                                myresult=FAIL
                        fi

                        grep ERROR $TET_TMP_DIR/stress-showuser.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in showuser output see $TET_TMP_DIR/stress-showuser.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/stress-showuser.bash-output
                                fi

                                myresult=FAIL
                        fi

                        # Incriment maxnum for the next server
                        let maxnum=$maxnum+$mastermax
                fi
        done

        result $myresult
        message "END $tet_thistest"

}
######################################################################
# unlock users
######################################################################
unlockusers()
{
        myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Unlock $mastermax Users"
        usrnum=0
        maxnum=$mastermax
        echo '#!/bin/bash' > $TET_TMP_DIR/stress-showuser.bash
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        message "working on $s"
                        eval_vars $s
                        message '#!/bin/bash' > $TET_TMP_DIR/$s-unlockusr.bash
                        while [[ $usrnum -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $usrnum)
                                echo "ipa -n user-unlock fl$hexnum" >> $TET_TMP_DIR/$s-unlockusr.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-unlockusr.bash

                                echo "ipa user-show --all fl$hexnum > /dev/shm/show-out.txt" >> $TET_TMP_DIR/stress-showuser.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-showuser.bash
                                echo "grep 'inactivated' /dev/shm/show-out.txt; if [ \$? -eq 0 ];then echo 'ERROR - inactivated found in /dev/shm/show-out.txt'; cat /dev/shm/show-out.txt;fi" >> $TET_TMP_DIR/stress-showuser.bash

                                let usrnum=$usrnum+1
                        done
                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-unlockusr.bash /tmp/stress-showuser.bash";
                        chmod 755 $TET_TMP_DIR/$s-unlockusr.bash $TET_TMP_DIR/stress-showuser.bash
                        scp $TET_TMP_DIR/stress-showuser.bash $TET_TMP_DIR/$s-unlockusr.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-unlockusr.bash > /tmp/$s-unlockusr.bash-output"
                        ssh root@$FULLHOSTNAME "/tmp/stress-showuser.bash > /tmp/stress-showuser.bash-output"
                        rm -f $TET_TMP_DIR/$s-unlockusr.bash-output $TET_TMP_DIR/stress-showuser.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-unlockusr.bash-output $TET_TMP_DIR/.
                        scp root@$FULLHOSTNAME:/tmp/stress-showuser.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-unlockusr.bash-output
                        if [ $? -eq 0 ]; then
                                message "ERROR - ERROR detected in user-unlock output see $TET_TMP_DIR/$s-unlockusr.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        message "debugging output:"
                                        cat $TET_TMP_DIR/$s-unlockusr.bash-output
                                fi
                                myresult=FAIL
                        fi

                        grep ERROR $TET_TMP_DIR/stress-showuser.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in showuser output see $TET_TMP_DIR/stress-showuser.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/stress-showuser.bash-output
                                fi

                                myresult=FAIL
                        fi

                        # Incriment maxnum for the next server
                        let maxnum=$maxnum+$mastermax
                fi
        done

        result $myresult
        message "END $tet_thistest"

}
######################################################################
# delete users
######################################################################
delusers()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: Delete $mastermax Users"
	#runnum=0
	#while [[ $runnum -lt $ITTERATIONS ]]; do
	usrnum=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			message "working on $s"
			eval_vars $s
			message '#!/bin/bash' > $TET_TMP_DIR/$s-delusr.bash
			while [[ $usrnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $usrnum)
				echo "ipa user-del fl$hexnum" >> $TET_TMP_DIR/$s-delusr.bash 
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
				message "ERROR - ERROR detected in deluser output see $TET_TMP_DIR/$s-delusr.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					message "debugging output:"
					cat $TET_TMP_DIR/$s-delusr.bash-output
				fi

				myresult=FAIL
			fi
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
#		let runnum=$runnum+1

#	done

	result $myresult
	message "END $tet_thistest"
}
######################################################################

######################################################################
# Cleanup Section for the ipa-adduser tests
######################################################################
ipaadduser_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest"
	eval_vars M1
	code=0

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a biguser super"
	#let code=$code+$?

	#ssh root@$FULLHOSTNAME "ipa-modgroup -a usermod1 modusers"
	#let code=$code+$?

	if [ $code -ne 0 ]
	then
		message "ERROR - setup for $tet_thistest failed"
		tet_result FAIL
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
