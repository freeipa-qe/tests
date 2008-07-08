#!/bin/ksh
#
# filename : sample.ksh
#
tet_startup=""
tet_cleanup=""
iclist="ic1 ic2 ic3"
ic1="tp1"
ic2="tp2"
ic3="tp3"

DATA=$TET_ROOT/../data
BASESUFFIX="o=airius.com"
#set -x
echo "sample.ksh called here"

tp1() 
{
echo "passed"
echo "this is tp1 test"
tet_result PASS
}
tp2() 
{
echo "passed"
echo "this is tp2 test"
tet_result PASS
}
tp3() 
{
echo "passed"
echo "this is tp3 test"
tet_result PASS
}

#. $TESTING_SHARED/DS/$VER/ksh/baselib.ksh
#. $TESTING_SHARED/DS/$VER/ksh/applib.ksh
#. $TESTING_SHARED/DS/$VER/ksh/appstates.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
