#!/bin/ksh 
########################################################
########################################################
#
# FileName :samplegui.ksh 
# Author: Lakshmi Gopal 
# Creation Date : 06/22/99
# This File Contains sample testcases 
# Usage : None , Should be invoked by tcc
# Supports : Unix,NT

#######################################################

tet_startup="ServerInfo"
tet_cleanup=""
iclist="ic1 ic2 ic3 ic4"
ic1="BobStartState"
ic2="Guitest"
ic3="tp1"
ic4="BobEndState"


DATA=$TET_ROOT/../data
OUTPUT=output

BASESUFFIX="o=airius.com"
RESULTS=$TET_TMP_DIR

Guitest()
{

TestComponent=Sample
Scenariofile=`os_getpwd`/Gui/gui_scen
echo "Scenariofile : $Scenariofile"
RunSilk $TestComponent $Scenariofile samplestart sample sampleend

RC=$?
if [ $RC != 0 ] ; then
    tet_infoline " Error in executing silk test"
    tet_infoline  "RC=$RC"
    tet_result FAIL
else
   tet_result PASS
fi

}



tp1()
{
message "anonymous search uid=mlott"

$LDAPSEARCH -p $LDAPport -h $LDAPhost -b "$BASESUFFIX" "uid=mlott" > $RESULTS/ac
ceptance_tp9.out

diff $RESULTS/acceptance_tp9.out $DATA/DS/$VER/acceptance/$CHARSET/tp9.in
RC=$?

if [ $RC != 0 ]; then
    tet_infoline "exact search failed."
    tet_infoline "RC=$RC."
    tet_result FAIL
else
    tet_result PASS
fi
}


. $TESTING_SHARED/DS/$VER/silk/silklib.ksh
. $TESTING_SHARED/DS/$VER/ksh/baselib.ksh
. $TESTING_SHARED/DS/$VER/ksh/applib.ksh
. $TESTING_SHARED/DS/$VER/ksh/appstates.ksh
. $TET_ROOT/lib/ksh/tcm.ksh 

