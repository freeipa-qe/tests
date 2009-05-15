#!/bin/ksh

# standard section to trigger the debug mode

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

# tet section : The next line is required as it picks up data about the servers to use
tet_startup="nis_startup"
tet_cleanup="nis_cleanup"

iclist="ic0 ic1 ic2 ic99"
#iclist="ic1 ic2"

ic0="nis_startup"
ic1="s1"
ic2="s2"
ic99="nis_cleanup"

# startup section
nis_startup()
{
	echo "nis start up: setup testing environment"
}

# cleanup section
nis_cleanup()
{
	echo "nis cleanup: remove all nis related setting and restore the ipa to the state before the nis test run"
}

################# test cases start here ################
s1()
{
	echo "this is test case 1"
}
s2()
{
	echo "this is test case 2"
}
