#!/bin/ksh

######################################################################
# ipa host group stress tests
######################################################################
DOMAIN="idm.lab.bos.redhat.com"

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# This is the number of hosts to create on every master
mastermax=2000

# Tests
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8"
ic0="startup"
ic1="addhostgrps"
ic2="findhostgrps"
ic3="modhostgrps"
ic4="showhostgrps"
ic5="addmembers"
ic6="removemembers"
ic7="deletehostgrps"
ic8="cleanup"

######################################################################
startup()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: kinit and add hosts and user groups"
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

	# add hosts and user groups for host group memberships
	num=0
	eval_vars "M1"
	echo '#!/bin/bash' > $TET_TMP_DIR/addhosts.bash
        echo '#!/bin/bash' > $TET_TMP_DIR/addgroups.bash
	while [ $num -lt $mastermax ] ; do
		hexnum=$(printf '%02X' $num)
		echo "ipa host-add host$hexnum.$DOMAIN --password=Secret123" >> $TET_TMP_DIR/addhosts.bash 
		echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/addhosts.bash
		echo "ipa group-add group$hexnum --description=blah" >> $TET_TMP_DIR/addgroups.bash
		echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/addgroups.bash
		let num=$num+1
	done
	ssh root@$FULLHOSTNAME "rm -f /tmp/addhosts.bash /tmp/addgroups.bash";
	chmod 755 $TET_TMP_DIR/addhosts.bash $TET_TMP_DIR/addgroups.bash
	scp $TET_TMP_DIR/addhosts.bash $TET_TMP_DIR/addgroups.bash root@$FULLHOSTNAME:/tmp/.
	ssh root@$FULLHOSTNAME "/tmp/addhosts.bash > /tmp/addhosts.bash-output"
	ssh root@$FULLHOSTNAME "/tmp/addgroups.bash > /tmp/addgroups.bash-output"
	rm -f $TET_TMP_DIR/addhosts.bash-output $TET_TMP_DIR/addgroups.bash-output
	scp root@$FULLHOSTNAME:/tmp/addhosts.bash-output $TET_TMP_DIR/.
	scp root@$FULLHOSTNAME:/tmp/addgroups.bash-output $TET_TMP_DIR/.

	grep ERROR $TET_TMP_DIR/addhosts.bash-output
	if [ $? -eq 0 ]; then
		echo "ERROR - ERROR detected in host-add output see $TET_TMP_DIR/addhosts.bash-output for details"
		if [ "$DSTET_DEBUG" = "y" ]; then
			echo "debugging output:"
			cat $TET_TMP_DIR/addhosts.bash-output
		fi
		tet_result FAIL
	fi

	grep ERROR $TET_TMP_DIR/addgroups.bash-output
        if [ $? -eq 0 ]; then 
                echo "ERROR - ERROR detected in group-add output see $TET_TMP_DIR/addgroups.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then 
                        echo "debugging output:"
                        cat $TET_TMP_DIR/addgroups.bash-output
                fi
                tet_result FAIL
        fi

	tet_result PASS
	message "END $tet_thistest"
}
#################################################################################################################
addhostgrps()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add $mastermax Host Groups"
	num=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-addhostgrp.bash
			while [[ $num -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $num)
				echo "ipa hostgroup-add --description=blah hostgroup$hexnum" >> $TET_TMP_DIR/$s-addhostgrp.bash 
				let num=$num+1
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-addhostgrp.bash
			done
			ssh root@$FULLHOSTNAME "rm -f /tmp/$s-addhostgrp.bash";
			chmod 755 $TET_TMP_DIR/$s-addhostgrp.bash
			scp $TET_TMP_DIR/$s-addhostgrp.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/$s-addhostgrp.bash > /tmp/$s-addhostgrp.bash-output"
			rm -f $TET_TMP_DIR/$s-addhostgrp.bash-output
			scp root@$FULLHOSTNAME:/tmp/$s-addhostgrp.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/$s-addhostgrp.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in hostgroup-add output see $TET_TMP_DIR/$s-addhostgrp.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/$s-addhostgrp.bash-output
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
findhostgrps()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Find $mastermax Host Groups"
	num=0
	maxnum=$mastermax
	echo '#!/bin/bash' > $TET_TMP_DIR/stress-findhostgrp.bash
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s

			while [[ $num -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $num)
				hexnum=`echo $hexnum | tr "[A-Z]" "[a-z]"`
				echo "ipa hostgroup-find hostgroup$hexnum > /dev/shm/find-out.txt" >> $TET_TMP_DIR/stress-findhostgrp.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-findhostgrp.bash
				echo "grep 'cn: hostgroup$hexnum' /dev/shm/find-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - hostgroup$hexnum not in /dev/shm/find-out.txt'; cat /dev/shm/find-out.txt;fi" >> $TET_TMP_DIR/stress-findhostgrp.bash
				let num=$num+1
			done
			# Incriment maxnum for the next server
			let maxnum=$maxnum+$mastermax
		fi
	done
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			ssh root@$FULLHOSTNAME "rm -f /tmp/stress-findhostgrp.bash";
			chmod 755 $TET_TMP_DIR/stress-findhostgrp.bash
			scp $TET_TMP_DIR/stress-findhostgrp.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/stress-findhostgrp.bash > /tmp/stress-findhostgrp.bash-output"
			rm -f $TET_TMP_DIR/stress-findhostgrp.bash-output
			scp root@$FULLHOSTNAME:/tmp/stress-findhostgrp.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/stress-findhostgrp.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in find host group output see $TET_TMP_DIR/stress-findhostgrp.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/stress-findhostgrp.bash-output
				fi
				
	tet_result FAIL
			fi
		fi
	done

	tet_result PASS
	message "END $tet_thistest"
}
#############################################################################################################################
modhostgrps()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Modify $mastermax Host Groups"
        num=0
        maxnum=$mastermax
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-modhostgrp.bash
                        while [[ $num -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $num)
                                echo "ipa hostgroup-mod --description=NewDescription hostgroup$hexnum" >> $TET_TMP_DIR/$s-modhostgrp.bash
				let num=$num+1
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-modhostgrp.bash
                        done

                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-modhostgrp.bash";
                        chmod 755 $TET_TMP_DIR/$s-modhostgrp.bash
                        scp $TET_TMP_DIR/$s-modhostgrp.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-modhostgrp.bash > /tmp/$s-modhostgrp.bash-output"
                        rm -f $TET_TMP_DIR/$s-modhostgrp.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-modhostgrp.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-modhostgrp.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in hostgroup-mod output see $TET_TMP_DIR/$s-modhostgrp.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/$s-modhostgrp.bash-output 
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
showhostgrps()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Show $mastermax Host Groups"
        num=0
        maxnum=$mastermax
        echo '#!/bin/bash' > $TET_TMP_DIR/stress-showhostgrp.bash
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s

                        while [[ $num -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $num)
                                echo "ipa hostgroup-show hostgroup$hexnum > /dev/shm/show-out.txt" >> $TET_TMP_DIR/stress-showhostgrp.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-showhostgrp.bash
                                echo "grep 'description: NewDescription' /dev/shm/show-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - description: NewDescription not in /dev/shm/show-out.txt'; cat /dev/shm/show-out.txt;fi" >> $TET_TMP_DIR/stress-showhostgrp.bash
                                let num=$num+1
                        done
                        # Incriment maxnum for the next server
                        let maxnum=$maxnum+$mastermax
                fi
        done
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
                        ssh root@$FULLHOSTNAME "rm -f /tmp/stress-showhostgrp.bash";
                        chmod 755 $TET_TMP_DIR/stress-showhostgrp.bash
                        scp $TET_TMP_DIR/stress-showhostgrp.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/stress-showhostgrp.bash > /tmp/stress-showhostgrp.bash-output"
                        rm -f $TET_TMP_DIR/stress-showhostgrp.bash-output
                        scp root@$FULLHOSTNAME:/tmp/stress-showhostgrp.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/stress-showhostgrp.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in show host group output see $TET_TMP_DIR/stress-showhostgrp.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/stress-showhostgrp.bash-output
                                fi
               
        tet_result FAIL
                        fi
                fi
        done

        tet_result PASS
        message "END $tet_thistest"
}
##########################################################################################################################
addmembers()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Add $mastermax Hosts and User Groups to Host Group"
        num=0
        maxnum=$mastermax
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-memhostgrp.bash
			hgnum=$(printf '%02X' $num)
                        while [[ $num -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $num)
                                echo "ipa hostgroup-add-member --hosts=host$hexnum.$DOMAIN --groups=group$hexnum hostgroup$hgnum" >> $TET_TMP_DIR/$s-memhostgrp.bash
                                let num=$num+1
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-memhostgrp.bash
                        done

                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-memhostgrp.bash";
                        chmod 755 $TET_TMP_DIR/$s-memhostgrp.bash
                        scp $TET_TMP_DIR/$s-memhostgrp.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-memhostgrp.bash > /tmp/$s-memhostgrp.bash-output"
                        rm -f $TET_TMP_DIR/$s-memhostgrp.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-memhostgrp.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-memhostgrp.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in hostgroup-add-member output see $TET_TMP_DIR/$s-memhostgrp.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/$s-memhostgrp.bash-output
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

##########################################################################################################################
removemembers()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Remove $mastermax Hosts and User Groups to Host Group"
        num=0
        maxnum=$mastermax
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-rmemhostgrp.bash
                        hgnum=$(printf '%02X' $num)
                        while [[ $num -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $num)
                                echo "ipa hostgroup-remove-member --hosts=host$hexnum.$DOMAIN --groups=group$hexnum hostgroup$hgnum" >> $TET_TMP_DIR/$s-rmemhostgrp.bash
                                let num=$num+1
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-rmemhostgrp.bash
                        done

                        ssh root@$FULLHOSTNAME "rm -f /tmp/$s-rmemhostgrp.bash";
                        chmod 755 $TET_TMP_DIR/$s-rmemhostgrp.bash
                        scp $TET_TMP_DIR/$s-rmemhostgrp.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/$s-rmemhostgrp.bash > /tmp/$s-rmemhostgrp.bash-output"
                        rm -f $TET_TMP_DIR/$s-rmemhostgrp.bash-output
                        scp root@$FULLHOSTNAME:/tmp/$s-rmemhostgrp.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/$s-rmemhostgrp.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in hostgroup-remove-member output see $TET_TMP_DIR/$s-rmemhostgrp.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/$s-rmemhostgrp.bash-output
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
deletehostgrps()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Delete $mastermax Host Groups"
	num=0
	maxnum=$mastermax
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s
			echo '#!/bin/bash' > $TET_TMP_DIR/$s-delhostgrp.bash
			while [[ $num -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $num)
				echo "ipa hostgroup-del hostgroup$hexnum" >> $TET_TMP_DIR/$s-delhostgrp.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-delhostgrp.bash
				let num=$num+1
			done
			ssh root@$FULLHOSTNAME "rm -f /tmp/$s-delhostgrp.bash";
			chmod 755 $TET_TMP_DIR/$s-delhostgrp.bash
			scp $TET_TMP_DIR/$s-delhostgrp.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/$s-delhostgrp.bash > /tmp/$s-delhostgrp.bash-output"
			rm -f $TET_TMP_DIR/$s-delhostgrp.bash-output
			scp root@$FULLHOSTNAME:/tmp/$s-delhostgrp.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/$s-delhostgrp.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in delete host group output see $TET_TMP_DIR/$s-delhostgrp.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/$s-delhostgrp.bash-output
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
cleanup()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest:  Delete all hosts and user groups"
	eval_vars "M1"
        num=0
        echo '#!/bin/bash' > $TET_TMP_DIR/delhosts.bash
        echo '#!/bin/bash' > $TET_TMP_DIR/delgroups.bash

        while [ $num -lt $mastermax ] ; do
                hexnum=$(printf '%02X' $num)
                echo "ipa host-del host$hexnum.$DOMAIN" >> $TET_TMP_DIR/delhosts.bash                                                      
                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/delhosts.bash
                echo "ipa group-del group$hexnum" >> $TET_TMP_DIR/delgroups.bash
                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/delgroups.bash
                let num=$num+1
        done
        ssh root@$FULLHOSTNAME "rm -f /tmp/delhosts.bash /tmp/delgroups.bash";
        chmod 755 $TET_TMP_DIR/delhosts.bash $TET_TMP_DIR/delgroups.bash
        scp $TET_TMP_DIR/delhosts.bash $TET_TMP_DIR/delgroups.bash root@$FULLHOSTNAME:/tmp/.
        ssh root@$FULLHOSTNAME "/tmp/delhosts.bash > /tmp/delhosts.bash-output"
        ssh root@$FULLHOSTNAME "/tmp/delgroups.bash > /tmp/delgroups.bash-output"
        rm -f $TET_TMP_DIR/delhosts.bash-output $TET_TMP_DIR/delgroups.bash-output
        scp root@$FULLHOSTNAME:/tmp/delhosts.bash-output $TET_TMP_DIR/.
        scp root@$FULLHOSTNAME:/tmp/delgroups.bash-output $TET_TMP_DIR/.

        grep ERROR $TET_TMP_DIR/delhosts.bash-output
        if [ $? -eq 0 ]; then
                echo "ERROR - ERROR detected in host-del output see $TET_TMP_DIR/delhosts.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then 
                        echo "debugging output:"
                        cat $TET_TMP_DIR/delhosts.bash-output
                fi
                tet_result FAIL
        fi

        grep ERROR $TET_TMP_DIR/delgroups.bash-output
        if [ $? -eq 0 ]; then
                echo "ERROR - ERROR detected in group-del output see $TET_TMP_DIR/delgroups.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then
                        echo "debugging output:"
                        cat $TET_TMP_DIR/delgroups.bash-output
                fi
                tet_result FAIL
        fi

        tet_result PASS
        message "END $tet_thistest"
}
#########################################################################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
