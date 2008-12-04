#!/bin/ksh

######################################################################
# Run ipa-adduser followed by kdestroy over and over again to see how often it works.
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="TestSetup"
tet_cleanup="ipaadduser_cleanup"
iclist="ic1 "
ic1="tp1 tp2 tp3"

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
#	ipa-adduser as admin, and check to see if it worked $ITTERATIONS times
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	echo "START $tet_thistest"
	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		for s in $SERVERS; do
			if [ "$s" != "" ]; then
				echo "working on $s"
			fi
		done
		let runnum=$runnum+1

	done

	tet_result PASS
	echo "END $tet_thistest"
}
######################################################################

######################################################################
#     check to confirm that the users exist on the masters 
######################################################################
tp2()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	failcount=0
	runnum=0
	while [[ $runnum -lt $ITTERATIONS ]]; do
		for s in $SERVERS; do
			if [ "$s" != "" ]; then
				echo "working on $s"
			fi
		done
		let runnum=$runnum+1
	done

	if [ $failcount -eq 0 ]; then
		tet_result PASS
	else
		echo "ERROR - failcount wasn't 0, it's $failcount"
		tet_result FAIL
	fi
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
