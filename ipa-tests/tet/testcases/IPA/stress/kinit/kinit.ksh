#!/bin/ksh

######################################################################
# Run kinit followed by kdestroy over and over again to see ho often it works.
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="kinit_cleanup"
iclist="ic1 "
ic1="tp1"


######################################################################
tp1()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		for s in $SERVERS; do
			if [ "$s" != "" ]; then
				echo "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s in a fast mode"
				KinitAs $s $DS_USER $DM_ADMIN_PASS fast
				ret=$?
				if [ $ret -ne 0 ]; then
					echo "ERROR - kinit on $s failed"
					tet_result FAIL
				fi
				ssh root@$FULLHOSTNAME "ipa-finduser $DS_USER" > $TET_TMP_DIR/stress-kinit-tmp.txt
				grep Login:\ $DS_USER $TET_TMP_DIR/stress-kinit-tmp.txt
				if [ $? -ne 0 ]; then
					echo "ERROR: Login:\ $DS_USER not found in $TET_TMP_DIR/stress-kinit-tmp.txt"
					echo "contents of $TET_TMP_DIR/stress-kinit-tmp.txt"
					cat $TET_TMP_DIR/stress-kinit-tmp.txt
					echo "$TET_TMP_DIR/stress-kinit-tmp.txt complete"
					tet_result FAIL
				fi
			fi
		done
		let runnum=$runnum+1
	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################


######################################################################
# Cleanup Section for the kinit tests
######################################################################
kinit_cleanup()
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
