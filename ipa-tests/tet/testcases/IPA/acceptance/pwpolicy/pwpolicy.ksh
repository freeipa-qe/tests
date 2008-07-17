#!/bin/ksh

######################################################################

######################################################################
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="pw_cleanup"
iclist="ic1 ic2"
ic1="tp1"
ic2="tp2"
hour=0
min=0
sec=0
month=0
day=0
year=0

# options to use throughout the tests
minlife=2

# This function populates the current date into the hour, min, sec, month, day and year vars
get_time()
{
	export month=$(date +%m)
	export day=$(date +%d)
	export year=$(date +%Y)
	export hour=$(date +%H)
	export min=$(date +%M)
	export sec=$(date +%S)
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
                        ret=$?
                        if [ $ret -ne 0 ]; then
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
                        ret=$?
                        if [ $ret -ne 0 ]; then
                                echo "ERROR - kinit on $s failed"
                                tet_result FAIL
                        fi
                fi
        done

        tet_result PASS
        echo "END $tet_thistest"
}


######################################################################
# minlife
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi

	user1="testusr1"
	user1pw1="D4mkcidytte3."
	user1pw2="93847ccjdmeo8765"
	user1pw3="lo9sh3nchd765"
	user1pw4="lso9383j4nchst63^"

	eval_vars M1
	# set date on m1 to make sure it's what we think it is
	get_time
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# add user to test with
	ssh root@$FULLHOSTNAME "ipa-adduser -f 'test user 1' -l 'lastname' $user1;"
	if [ $? != 0 ]; then
		echo "ERROR - ipa-adduser failed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set that users password
	SetUserPassword M1 $user1 $user1pw1	
	if [ $? != 0 ]; then
		echo "ERROR - SetUserPasswordfailed on $FULLHOSTNAME";
		tet_result FAIL
	fi

	# set password policy
	ssh root@$FULLHOSTNAME "ipa-pwpolicy --minlife $minlife"
	if [ $? -ne 0 ]; then
		echo "ERROR - ipa-pwpolicy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# kinit as the user
	ssh root@$FULLHOSTNAME "kdestroy"
	if [ $? -ne 0 ]; then
		echo "ERROR - kdestroy on $FULLHOSTNAME failed"
		tet_result FAIL
	fi
	KinitAsFirst M1 $user1 $user1pw1 $user1pw2
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit as $user1 on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Now attempt to set the password of user1, this should fail.
	SetUserPassword M1 $user1 $user1pw3
	# Download the output from M1 to ensuer that it didn't work
	rm -f $TET_TMP_DIR/SetUserPassword.tmp
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/.
	cat $TET_TMP_DIR/SetUserPassword.tmp
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword-output.txt $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi
	
	# incriment date 
	let newhour=$hour+$minlife+1
	if [ $newhour -gt 23 ]; then
		# Hour would be two high, incrimenting day
		let day=$day+1;
		export hour='02'
	fi

	# Set the date forward to make the date change valid
	ssh root@$FULLHOSTNAME "date $month$day$hour$min$year"
	if [ $? -ne 0 ]; then
		echo "ERROR - setting the date on $FULLHOSTNAME failed"
		tet_result FAIL
	fi

	# Now attempt to set the password of user1, this should fail.
	SetUserPassword M1 $user1 $user1pw4
	# Download the output from M1 to ensuer that it didn't work
	rm -f $TET_TMP_DIR/SetUserPassword.tmp
	scp root@$FULLHOSTNAME:/tmp/SetUserPassword.tmp $TET_TMP_DIR/.
	if [ $? -ne 0 ]; then
		echo "ERROR - scp root@$FULLHOSTNAME:/tmp/SetUserPassword.tmp $TET_TMP_DIR/. failed"
		tet_result FAIL
	fi

	#
	tet_result PASS

	tp1

	echo "END $tet_thistest"
}
######################################################################


######################################################################
# Cleanup Section for the cli tests
######################################################################
pw_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0


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
