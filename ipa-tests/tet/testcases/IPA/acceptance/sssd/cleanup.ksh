#!/bin/ksh
# File Name : cleanup.sh
# Author: JSG
# Creation Date : 17/07/2009 (dd/mm/yy)
# Modified Date : 
# Desc :  This file contains cleanup required after the SSSD acceptance tests
#
# Usage : None, should be invoked by tcc
#
# Target : All supported platforms

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

tet_startup=""
tet_cleanup=""
iclist="ic0"

ic0="cleanup"

##################################################################
# LIBRARIES
##################################################################
. $TET_ROOT/testcases/IPA/acceptance/sssd/sssd_lib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
##################################################################
# CLEANUP
##################################################################
cleanup()
{
  message "Deleting local users from clients"
  for c in $SSSD_CLIENTS; do
        eval_vars $c
        message "Working on $c"

        i=999
        userprefix=testuser

        while [ $i -lt 1012 ] ; do
                ssh root@$FULLHOSTNAME "userdel $userprefix$i"
                if [ $? -ne 0 ] ; then
                        message "ERROR: Failed to delete local user $userprefix$i on client $c."
                fi
                let i=$i+1
        done

	sssdClientCleanup $c
  done
}

#EOF

