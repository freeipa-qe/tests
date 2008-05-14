#!/bin/ksh
#
# filename : sample.ksh
#
tet_startup="ServerInfo"
tet_cleanup=""
iclist="ic1 ic2 ic3"
ic1="BobStartState"
#ic2="tp1 tp2"
ic2="tp3"
ic3="BobEndState"

DATA=$TET_ROOT/../data
BASESUFFIX="o=airius.com"

echo "sample.ksh called here"
exit
tp1() 
{
message "anonymous search uid=mlott"

$LDAPSEARCH -p $LDAPport -h $LDAPhost -b "$BASESUFFIX" "uid=mlott" > $RESULTS/acceptance_tp9.out

diff $RESULTS/acceptance_tp9.out $DATA/DS/$VER/acceptance/$CHARSET/tp9.in
RC=$?

if [ $RC != 0 ]; then
    tet_infoline "exact search failed."
    tet_infoline "RC=$RC."
set -x
    tet_result FAIL
exit
else
    tet_result PASS
fi
}

tp2()
{
message "turn off access to user uid=mward,ou=People,o=airius.com"
os_run $LDAPMODIFY -p $LDAPport -h $LDAPhost -D "$ROOTDN" -w $ROOTDNPW -f $DATA/DS/$VER/acceptance/$CHARSET/acl.in

RC=$?

if [ $RC != 0 ]; then
	tet_infoline "Could not turn off access for particular user."
	tet_infoline "RC=$RC."
	tet_infoline "$LDAPMODIFY -p $LDAPport -h $LDAPhost -D "$ROOTDN" -w $ROOTDNP
	W -f $DATA/DS/$VER/acceptance/$CHARSET/acl.in"
	tet_result FAIL
else
	tet_result PASS
fi
}

tp3()
{
	ls /tmp
	ret=$?
	if [ $ret eq 0 ]; then
		echo "it worked!"
		tet_result PASS
	else	
		tet_result FAIL
	fi
}
#. $TESTING_SHARED/DS/$VER/ksh/baselib.ksh
#. $TESTING_SHARED/DS/$VER/ksh/applib.ksh
#. $TESTING_SHARED/DS/$VER/ksh/appstates.ksh
#. $TET_ROOT/lib/ksh/tcm.ksh
