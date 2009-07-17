#!/bin/ksh

######################################################################
#  File: sssd.ksh - acceptance tests for SSSD
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0"
ic0="sssd_001"
ic1="sssd_002" 
ic2="sssd_003"
ic3="sssd_004"
ic4="sssd_005"
ic5="sssd_006" 
#######################################################################
#  Variables
######################################################################
CFG_DIR=$TET_SUITE_ROOT/config
######################################################################
# Tests
######################################################################
sssd_001()
{
	myresult=PASS
        message "START $tet_thistest: Setup Local SSSD Configuration 1"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for c in $SSSD_CLIENTS ; do
		eval_vars $c
		"Working on $c"
	done

	result $myresult
	message "END $tet_thistest"

}

######################################################################
#
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

