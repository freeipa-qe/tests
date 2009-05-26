#!/bin/ksh

######################################################################
# ipa host stress test
######################################################################
DOMAIN="idm.lab.bos.redhat.com"

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# This is the number of hosts to create on every master
mastermax=1000

# Tests
iclist="ic0 ic1 ic2 ic3 ic4 ic5"
#iclist="ic0 ic1"
ic0="kinit"
ic1="addhosts"
ic2="findhosts"
ic3="modhosts"
ic4="showhosts"
ic5="deletehosts"

######################################################################
kinit()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: kinit everywhere"
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
	message "END $tet_thistest"
}
#################################################################################################################
addhosts()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add $mastermax Hosts"
	hostnum=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-addhost.bash
			while [[ $hostnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $hostnum)
				echo "ipa host-add --description=\"Host description for host$hexnum\" host$hexnum.$DOMAIN" >> $TET_TMP_DIR/$s-addhost.bash 
				let hostnum=$hostnum+1
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-addhost.bash
			done
			ssh root@$FULLHOSTNAME "rm -f /tmp/$s-addhost.bash";
			chmod 755 $TET_TMP_DIR/$s-addhost.bash
			scp $TET_TMP_DIR/$s-addhost.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/$s-addhost.bash > /tmp/$s-addhost.bash-output"
			rm -f $TET_TMP_DIR/$s-addhost.bash-output
			scp root@$FULLHOSTNAME:/tmp/$s-addhost.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/$s-addhost.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in host-add output see $TET_TMP_DIR/$s-addhost.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/$s-addhost.bash-output
				fi
				tet_result FAIL
			fi
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done

	tet_result PASS
	message "END $tet_thistest"
}
#####################################################################################################################
findhosts()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Find All Hosts Added"
	hostnum=0
	maxnum=$mastermax
	echo '#!/bin/bash' > $TET_TMP_DIR/stress-findhost.bash
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s

			while [[ $hostnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $hostnum)
				hexnum=`echo $hexnum | tr "[A-Z]" "[a-z]"`
				echo "ipa host-find host$hexnum.$DOMAIN > /dev/shm/find-out.txt" >> $TET_TMP_DIR/stress-findhost.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-findhost.bash
				echo "grep 'fqdn: host$hexnum.$DOMAIN' /dev/shm/find-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - host$hexnum.$DOMAIN not in /dev/shm/find-out.txt'; cat /dev/shm/find-out.txt;fi" >> $TET_TMP_DIR/stress-findhost.bash
				let hostnum=$hostnum+1
			done
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "rm -f /tmp/stress-findhost.bash";
			chmod 755 $TET_TMP_DIR/stress-findhost.bash
			scp $TET_TMP_DIR/stress-findhost.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/stress-findhost.bash > /tmp/stress-findhost.bash-output"
			rm -f $TET_TMP_DIR/stress-findhost.bash-output
			scp root@$FULLHOSTNAME:/tmp/stress-findhost.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/stress-findhost.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in finduser output see $TET_TMP_DIR/stress-findhost.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/stress-findhost.bash-output
				fi
				
	tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	message "END $tet_thistest"
}
#############################################################################################################################
modhosts()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Modify $mastermax Hosts"
        hostnum=0
        maxnum=$mastermax
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-modhost.bash
                        while [[ $hostnum -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $hostnum)
                                echo "ipa host-mod --location=Westford host$hexnum.$DOMAIN" >> $TET_TMP_DIR/$s-modhost.bash
				let hostnum=$hostnum+1
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-modhost.bash
                        done

                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-modhost.bash";
                        chmod 755 $TET_TMP_DIR/$s-modhost.bash
                        scp $TET_TMP_DIR/$s-modhost.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-modhost.bash > /tmp/$s-modhost.bash-output"
                        rm -f $TET_TMP_DIR/$s-modhost.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-modhost.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-modhost.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in host-mod output see $TET_TMP_DIR/$s-modhost.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/$s-modhost.bash-output 
                                fi 
                                tet_result FAIL
                        fi
                        # Incriment maxnum for the next server
                        let maxnum=$maxnum+$mastermax
                fi
        done

        tet_result PASS
        message "END $tet_thistest"
}

#######################################################################################################################
showhosts()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Show All Hosts Modified"
        hostnum=0
        maxnum=$mastermax
        echo '#!/bin/bash' > $TET_TMP_DIR/stress-showhost.bash
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s

                        while [[ $hostnum -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $hostnum)
                                echo "ipa host-show host$hexnum.$DOMAIN > /dev/shm/show-out.txt" >> $TET_TMP_DIR/stress-findshow.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-showhost.bash
                                echo "grep 'nshostlocation: Westford' /dev/shm/show-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - nshostlocation: Westord not in /dev/shm/show-out.txt'; cat /dev/shm/show-out.txt;fi" >> $TET_TMP_DIR/stress-showhost.bash
                                let hostnum=$hostnum+1
                        done
                        # Incriment maxnum for the next server
                        let maxnum=$maxnum+$mastermax
                fi
        done
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
                        ssh root@$FULLHOSTNAME "rm -f /tmp/stress-showhost.bash";
                        chmod 755 $TET_TMP_DIR/stress-showhost.bash
                        scp $TET_TMP_DIR/stress-showhost.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/stress-showhost.bash > /tmp/stress-showhost.bash-output"
                        rm -f $TET_TMP_DIR/stress-showhost.bash-output
                        scp root@$FULLHOSTNAME:/tmp/stress-showhost.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/stress-showhost.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in showuser output see $TET_TMP_DIR/stress-showhost.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/stress-showhost.bash-output
                                fi
               
        tet_result FAIL
                        fi
                fi
        done

        tet_result PASS
        message "END $tet_thistest"
}

#####################################################################################################################
deletehosts()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Delete $mastermax Hosts"
	hostnum=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-delhost.bash
			while [[ $hostnum -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $hostnum)
				echo "ipa host-del host$hexnum.$DOMAIN" >> $TET_TMP_DIR/$s-delhost.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-delhost.bash
				let hostnum=$hostnum+1
			done
			ssh root@$FULLHOSTNAME "rm -f /tmp/$s-delhost.bash";
			chmod 755 $TET_TMP_DIR/$s-delhost.bash
			scp $TET_TMP_DIR/$s-delhost.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/$s-delhost.bash > /tmp/$s-delhost.bash-output"
			rm -f $TET_TMP_DIR/$s-delhost.bash-output
			scp root@$FULLHOSTNAME:/tmp/$s-delhost.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/$s-delhost.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in deluser output see $TET_TMP_DIR/$s-delhost.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/$s-delhost.bash-output
				fi

				tet_result FAIL
			fi
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done

	tet_result PASS
	message "END $tet_thistest"
}
#########################################################################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
