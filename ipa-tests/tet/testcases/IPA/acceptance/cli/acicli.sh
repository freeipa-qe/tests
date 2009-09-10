#!/bin/ksh

######################################################################

# The following ipa cli commands needs to be tested:
#  aci-add                   Add a new aci.
#  aci-del                   Delete an existing aci.
#  aci-find                  Search for a aci.
#  aci-mod                   Edit an existing aci.
#  aci-show                  Examine an existing aci.
#  aci-showall               Examine all existing acis.

######################################################################
echo "start acicli"
if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi
# The next line is required as it picks up data about the servers to use
tet_startup="CheckAlive"
tet_cleanup="user_cleanup"
iclist="ic1"
ic1="kinit"
# These services will be used by the tests, and removed when the cli test is complete
host1='alpha.dsdev.sjc.redhat.com'

# Users to be used in varios tests
superuser="sup35a"

######################################################################
kinit()
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
# Cleanup Section for the cli tests
######################################################################
user_cleanup()
{
	tet_thistest="cleanup"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	echo "START $tet_thistest"
	eval_vars M1
	code=0


	ssh root@$FULLHOSTNAME "ipa user-del $superuser"
	let code=$code+$?

	if [ $code -ne 0 ]
	then
		echo "WARNING - $tet_thistest failed... not that it matters"
	fi

	tet_result PASS
}

######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
