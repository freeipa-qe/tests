#!/bin/ksh 
########################################################
########################################################
#
# FileName :samplegui.ksh 
# Author: Sudesh Chandra 
# Creation Date : 12/02/99
# This File Contains sample testcases 
# Usage : None , Should be invoked by tcc
# Supports : Unix,NT

#######################################################

tet_startup="ServerInfo"
tet_cleanup=""
iclist="ic1 ic2"
ic1="Guitest"
ic2="tp1"


DATA=$TET_ROOT/../data
OUTPUT=output

BASESUFFIX="o=NetscapeRoot"
RESULTS=$TET_TMP_DIR

Guitest()
{

TestComponent=Sample
Scenariofile=`os_getpwd`/Gui/gui_scen
echo "samplegui.ksh: RunSilk with scenariofile : $Scenariofile"
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
message "anonymous search uid=admin"

$LDAPSEARCH -p $LDAPport -h $LDAPhost -b "$BASESUFFIX" "uid=admin" > $RESULTS/ac
ceptance_tp9.out

diff $RESULTS/acceptance_tp9.out $DATA/AS/$VER/acceptance/$CHARSET/tp9.in
RC=$?

if [ $RC != 0 ]; then
    tet_infoline "exact search failed."
    tet_infoline "RC=$RC."
    tet_result FAIL
else
    tet_result PASS
fi
}


. $TESTING_SHARED/AS/$VER/silk/silklib.ksh
. $TESTING_SHARED/AS/$VER/ksh/baselib.ksh
. $TESTING_SHARED/AS/$VER/ksh/applib.ksh
. $TESTING_SHARED/AS/$VER/ksh/appstates.ksh
. $TET_ROOT/lib/ksh/tcm.ksh 

