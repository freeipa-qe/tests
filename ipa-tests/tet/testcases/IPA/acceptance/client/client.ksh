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
ic1="tp1 tp2"

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

	KinitAs M1 $user1 pw $user1pw
	if [ $? -ne 0 ]; then
		echo "ERROR - kinit failed on $FULLHOSTNAME"
		tet_result FAIL
	fi

	tet_result PASS
	echo "END $tet_thistest"
}

######################################################################
tp3()
{
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			# test for ipa-addservice
			ssh root@$FULLHOSTNAME "ipa-addservice \"$service1\""
			ret=$?
			if [ $ret -ne 0 ]
			then
				echo "ERROR - ipa-addservice failed on $FULLHOSTNAME"
				tet_result FAIL
			fi
			ssh root@$FULLHOSTNAME "ipa-findservice \"$service1\""
			if [ $? -ne 0 ]
			then
				echo "ERROR - ipa-findservice failed on $FULLHOSTNAME"
				tet_result FAIL
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


	ssh root@$FULLHOSTNAME "ipa-deluser $superuser"
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
