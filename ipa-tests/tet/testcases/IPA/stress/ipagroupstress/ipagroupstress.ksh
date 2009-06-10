#!/bin/ksh

######################################################################
# ipa group stress tests
######################################################################
DOMAIN="idm.lab.bos.redhat.com"

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# This is the number of groups to create on every master
mastermax=2000

# Tests
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8"
ic0="startup"
ic1="addgroups"
ic2="findgroups"
ic3="modgroups"
ic4="showgroups"
ic5="addusermembers"
ic6="removeusermembers"
ic7="deletegroups"
ic8="cleanup"

######################################################################
startup()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest: kinit and users"
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
			KinitAs $s $DS_USER $DM_ADMIN_PASS
			if [ $? -ne 0 ]; then
				echo "ERROR - kinit on $s failed"
				myresult=FAIL
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
				myresult=FAIL
			fi
		fi
	done

	# add users for group memberships
	num=0
	eval_vars "M1"
	echo '#!/bin/bash' > $TET_TMP_DIR/addusers.bash
	while [ $num -lt $mastermax ] ; do
		hexnum=$(printf '%02X' $num)
		echo "ipa -n user-add --first=f$hexnum --last=l$hexnum" >> $TET_TMP_DIR/addusers.bash
		echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/addusers.bash
		let num=$num+1
	done
	ssh root@$FULLHOSTNAME "rm -f /tmp/addusers.bash";
	chmod 755 $TET_TMP_DIR/addusers.bash
	scp $TET_TMP_DIR/addusers.bash root@$FULLHOSTNAME:/tmp/.
	ssh root@$FULLHOSTNAME "/tmp/addusers.bash > /tmp/addusers.bash-output"
	scp root@$FULLHOSTNAME:/tmp/addusers.bash-output $TET_TMP_DIR/.

	grep ERROR $TET_TMP_DIR/addusers.bash-output
	if [ $? -eq 0 ]; then
		echo "ERROR - ERROR detected in user-add output see $TET_TMP_DIR/addusers.bash-output for details"
		if [ "$DSTET_DEBUG" = "y" ]; then
			echo "debugging output:"
			cat $TET_TMP_DIR/addusers.bash-output
		fi
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}
#################################################################################################################
addgroups()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Add $mastermax User Groups"
	num=0
	maxnum=$mastermax
	echo "working on M1"
	eval_vars M1
	echo '#!/bin/bash' > $TET_TMP_DIR/$s-addgroups.bash
	while [[ $num -lt $maxnum ]]; do
		hexnum=$(printf '%02X' $num)
		echo "ipa group-add --description=blah group$hexnum" >> $TET_TMP_DIR/$s-addgroups.bash 
		let num=$num+1
		echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/$s-addgroups.bash
	done
	ssh root@$FULLHOSTNAME "rm -f /tmp/$s-addgroups.bash";
	chmod 755 $TET_TMP_DIR/$s-addgroups.bash
	scp $TET_TMP_DIR/$s-addgroups.bash root@$FULLHOSTNAME:/tmp/.
	ssh root@$FULLHOSTNAME "/tmp/$s-addgroups.bash > /tmp/$s-addgroups.bash-output"
	rm -f $TET_TMP_DIR/$s-addgroups.bash-output
	scp root@$FULLHOSTNAME:/tmp/$s-addgroups.bash-output $TET_TMP_DIR/.
	grep ERROR $TET_TMP_DIR/$s-addgroups.bash-output
	if [ $? -eq 0 ]; then
		echo "ERROR - ERROR detected in group-add output see $TET_TMP_DIR/$s-addgroups.bash-output for details"
		if [ "$DSTET_DEBUG" = "y" ]; then
			echo "debugging output:"
			cat $TET_TMP_DIR/$s-addgroups.bash-output
		fi
		myresult=FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}
#####################################################################################################################
findgroups()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Find $mastermax User Groups"
	num=0
	maxnum=$mastermax
	echo '#!/bin/bash' > $TET_TMP_DIR/stress-findgroups.bash
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			echo "working on $s"
			eval_vars $s

			while [[ $num -lt $maxnum ]]; do
				hexnum=$(printf '%02X' $num)
				hexnum=`echo $hexnum | tr "[A-Z]" "[a-z]"`
				echo "ipa group-find group$hexnum > /dev/shm/find-out.txt" >> $TET_TMP_DIR/stress-findgroups.bash 
				echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-findgroups.bash
				echo "grep 'cn: group$hexnum' /dev/shm/find-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - group$hexnum not in /dev/shm/find-out.txt'; cat /dev/shm/find-out.txt;fi" >> $TET_TMP_DIR/stress-findgroups.bash
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
			ssh root@$FULLHOSTNAME "rm -f /tmp/stress-findgroups.bash";
			chmod 755 $TET_TMP_DIR/stress-findgroups.bash
			scp $TET_TMP_DIR/stress-findgroups.bash root@$FULLHOSTNAME:/tmp/.
			ssh root@$FULLHOSTNAME "/tmp/stress-findgroups.bash > /tmp/stress-findgroups.bash-output"
			rm -f $TET_TMP_DIR/stress-findgroups.bash-output
			scp root@$FULLHOSTNAME:/tmp/stress-findgroups.bash-output $TET_TMP_DIR/.
			grep ERROR $TET_TMP_DIR/stress-findgroups.bash-output
			if [ $? -eq 0 ]; then
				echo "ERROR - ERROR detected in find group output see $TET_TMP_DIR/stress-findgroups.bash-output for details"
				if [ "$DSTET_DEBUG" = "y" ]; then
					echo "debugging output:"
					cat $TET_TMP_DIR/stress-findgroups.bash-output
				fi
				
				myresult=FAIL
			fi
		fi
	done

	result $myresult
	message "END $tet_thistest"
}
#############################################################################################################################
modgroups()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Modify $mastermax Groups"
        num=0
        maxnum=$mastermax
        echo "working on M1"
        eval_vars M1
	echo '#!/bin/bash' > $TET_TMP_DIR/$modgroups.bash
        while [[ $num -lt $maxnum ]]; do
        	hexnum=$(printf '%02X' $num)
        	echo "ipa group-mod --description=NewDescription group$hexnum" >> $TET_TMP_DIR/modgroups.bash
        	echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/modgroups.bash
		let num=$num+1
        done

        ssh root@$FULLHOSTNAME "rm -f /tmp/modgroups.bash";
        chmod 755 $TET_TMP_DIR/modgroups.bash
        scp $TET_TMP_DIR/modgroups.bash root@$FULLHOSTNAME:/tmp/.
        ssh root@$FULLHOSTNAME "/tmp/modgroups.bash > /tmp/modgroups.bash-output"
        rm -f $TET_TMP_DIR/modgroups.bash-output
        scp root@$FULLHOSTNAME:/tmp/modgroups.bash-output $TET_TMP_DIR/.
        grep ERROR $TET_TMP_DIR/modgroups.bash-output
        if [ $? -eq 0 ]; then
        	echo "ERROR - ERROR detected in group-mod output see $TET_TMP_DIR/modgroups.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then
                	echo "debugging output:"
                        cat $TET_TMP_DIR/modgroups.bash-output 
                fi 
                myresult=FAIL
        fi

        result $myresult
        message "END $tet_thistest"
}

#######################################################################################################################
showgroups()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Show $mastermax Groups"
        num=0
        maxnum=$mastermax
        echo '#!/bin/bash' > $TET_TMP_DIR/stress-showgroups.bash
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        echo "working on $s"
                        eval_vars $s

                        while [[ $num -lt $maxnum ]]; do
                                hexnum=$(printf '%02X' $num)
                                echo "ipa group-show group$hexnum > /dev/shm/show-out.txt" >> $TET_TMP_DIR/stress-showgroups.bash
                                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/stress-showgroups.bash
                                echo "grep 'description: NewDescription' /dev/shm/show-out.txt; if [ \$? -ne 0 ];then echo 'ERROR - description: NewDescription not in /dev/shm/show-out.txt'; cat /dev/shm/show-out.txt;fi" >> $TET_TMP_DIR/stress-showgroups.bash
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
                        ssh root@$FULLHOSTNAME "rm -f /tmp/stress-showgroups.bash";
                        chmod 755 $TET_TMP_DIR/stress-showgroups.bash
                        scp $TET_TMP_DIR/stress-showgroups.bash root@$FULLHOSTNAME:/tmp/.
                        ssh root@$FULLHOSTNAME "/tmp/stress-showgroups.bash > /tmp/stress-showgroups.bash-output"
                        rm -f $TET_TMP_DIR/stress-showgroups.bash-output
                        scp root@$FULLHOSTNAME:/tmp/stress-showgroups.bash-output $TET_TMP_DIR/.
                        grep ERROR $TET_TMP_DIR/stress-showgroups.bash-output
                        if [ $? -eq 0 ]; then
                                echo "ERROR - ERROR detected in show group output see $TET_TMP_DIR/stress-showgroups.bash-output for details"
                                if [ "$DSTET_DEBUG" = "y" ]; then
                                        echo "debugging output:"
                                        cat $TET_TMP_DIR/stress-showgroups.bash-output
                                fi
               
        			myresult=FAIL
                        fi
                fi
        done

        result $myresult
        message "END $tet_thistest"
}
##########################################################################################################################
addusermembers()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Add $mastermax Users to Group"
        num=0
        maxnum=$mastermax
	gnum=$(printf '%02X' $num)
        echo "working on M1"
        eval_vars M1
	echo '#!/bin/bash' > $TET_TMP_DIR/memgroup.bash
        while [[ $num -lt $maxnum ]]; do
        	hexnum=$(printf '%02X' $num)
                echo "ipa group-add-member --users=fl$hexnum group$gnum" >> $TET_TMP_DIR/memgroup.bash
                let num=$num+1
                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/memgroup.bash
        done

        ssh root@$FULLHOSTNAME "rm -f /tmp/memgroup.bash";
        chmod 755 $TET_TMP_DIR/memgroup.bash
        scp $TET_TMP_DIR/memgroup.bash root@$FULLHOSTNAME:/tmp/.
        ssh root@$FULLHOSTNAME "/tmp/memgroup.bash > /tmp/memgroup.bash-output"
        rm -f $TET_TMP_DIR/memgroup.bash-output
        scp root@$FULLHOSTNAME:/tmp/memgroup.bash-output $TET_TMP_DIR/.
        grep ERROR $TET_TMP_DIR/memgroup.bash-output
        if [ $? -eq 0 ]; then
        	echo "ERROR - ERROR detected in group-add-member output see $TET_TMP_DIR/memgroup.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then
                	echo "debugging output:"
                        cat $TET_TMP_DIR/$s-memhostgrp.bash-output
                fi
                myresult=FAIL
        fi

        result $myresult
        message "END $tet_thistest"
}

##########################################################################################################################
removeusermembers()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest: Remove $mastermax User from Group"
        num=0
        maxnum=$mastermax
	gnum=$(printf '%02X' $num)
        echo "working on M1"
        eval_vars M1
	echo '#!/bin/bash' > $TET_TMP_DIR/rmemgroup.bash
        while [[ $num -lt $maxnum ]]; do
        	hexnum=$(printf '%02X' $num)
                echo "ipa group-remove-member --users=fl$hexnum group$gnum" >> $TET_TMP_DIR/rmemgroup.bash
                let num=$num+1
                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/rmemgroup.bash
        done

        ssh root@$FULLHOSTNAME "rm -f /tmp/rmemgroup.bash";
        chmod 755 $TET_TMP_DIR/rmemgroup.bash
        scp $TET_TMP_DIR/rmemgroup.bash root@$FULLHOSTNAME:/tmp/.
        ssh root@$FULLHOSTNAME "/tmp/rmemgroup.bash > /tmp/rmemgroup.bash-output"
        rm -f $TET_TMP_DIR/$s-rmemgroup.bash-output
        scp root@$FULLHOSTNAME:/tmp/rmemgroup.bash-output $TET_TMP_DIR/.
        grep ERROR $TET_TMP_DIR/rmemgroup.bash-output
        if [ $? -eq 0 ]; then
        	echo "ERROR - ERROR detected in group-remove-member output see $TET_TMP_DIR/rmemgroup.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then
                	echo "debugging output:"
                        cat $TET_TMP_DIR/rmemgroup.bash-output
                fi
                myresult=FAIL
        fi

        result $myresult
        message "END $tet_thistest"
}

#####################################################################################################################
deletegroups()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	message "START $tet_thistest: Delete $mastermax User Groups"
	num=0
	maxnum=$mastermax
	echo "working on M1"
	eval_vars M1
	echo '#!/bin/bash' > $TET_TMP_DIR/delgroups.bash
	while [[ $num -lt $maxnum ]]; do
		hexnum=$(printf '%02X' $num)
		echo "ipa group-del group$hexnum" >> $TET_TMP_DIR/delgroups.bash 
		echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/delgroups.bash
		let num=$num+1
	done
	ssh root@$FULLHOSTNAME "rm -f /tmp/delgroups.bash";
	chmod 755 $TET_TMP_DIR/delgroups.bash
	scp $TET_TMP_DIR/delgroups.bash root@$FULLHOSTNAME:/tmp/.
	ssh root@$FULLHOSTNAME "/tmp/delgroups.bash > /tmp/delgroups.bash-output"
	rm -f $TET_TMP_DIR/delgroups.bash-output
	scp root@$FULLHOSTNAME:/tmp/delgroups.bash-output $TET_TMP_DIR/.
	grep ERROR $TET_TMP_DIR/delgroups.bash-output
	if [ $? -eq 0 ]; then
		echo "ERROR - ERROR detected in delete group output see $TET_TMP_DIR/delgroup.bash-output for details"
		if [ "$DSTET_DEBUG" = "y" ]; then
			echo "debugging output:"
			cat $TET_TMP_DIR/delgroup.bash-output
		fi

		myresult FAIL
	fi

	result $myresult
	message "END $tet_thistest"
}
#####################################################################################################################
cleanup()
{
	myresult=PASS
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        message "START $tet_thistest:  Delete All Users"
	eval_vars "M1"
        num=0
        echo '#!/bin/bash' > $TET_TMP_DIR/delusers.bash

        while [ $num -lt $mastermax ] ; do
                hexnum=$(printf '%02X' $num)
                echo "ipa user-del fl$hexnum" >> $TET_TMP_DIR/delusers.bash                                                      
                echo "if [ \$? -ne 0 ];then echo 'ERROR - return code was not 0'; fi" >> $TET_TMP_DIR/delusers.bash
                let num=$num+1
        done
        ssh root@$FULLHOSTNAME "rm -f /tmp/delusers.bash";
        chmod 755 $TET_TMP_DIR/delusers.bash
        scp $TET_TMP_DIR/delusers.bash root@$FULLHOSTNAME:/tmp/.
        ssh root@$FULLHOSTNAME "/tmp/delusers.bash > /tmp/delusers.bash-output"
        rm -f $TET_TMP_DIR/delusers.bash-output
        scp root@$FULLHOSTNAME:/tmp/delusers.bash-output $TET_TMP_DIR/.

        grep ERROR $TET_TMP_DIR/delusers.bash-output
        if [ $? -eq 0 ]; then
                echo "ERROR - ERROR detected in user-del output see $TET_TMP_DIR/delusers.bash-output for details"
                if [ "$DSTET_DEBUG" = "y" ]; then 
                        echo "debugging output:"
                        cat $TET_TMP_DIR/delusers.bash-output
                fi
                myresult=FAIL
        fi

        result $myresult
        message "END $tet_thistest"
}
#########################################################################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
