#!/bin/ksh
# File Name : startup.ksh
# Author: JSG
# Creation Date : 17/07/2009 (dd/mm/yy)
# Modified Date : 
# Desc :  This file contains the setup required to run SSSD acceptance tests
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

ic0="startup"

##################################################################
# LIBRARIES
##################################################################
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh
. $TET_ROOT/testcases/IPA/acceptance/sssd/sssd_lib.ksh
#################################################################
#  GLOBALS
#################################################################
SSSD_CLIENTS="jennyv2.bos.redhat.com"
export SSSD_CLIENTS
DIRSERV="jennyv4.bos.redhat.com"
export DIRSERV
##################################################################
# SETUP
##################################################################
#   Add local users on all clients

startup()
{
  myresult=PASS
  message "START $tet_this_test: Adding local users to all clients"
  for c in $SSSD_CLIENTS; do
	eval_vars $c
	message "Working on $c"
   	i=999
   	userprefix=testuser
   	userpwd=!online3

   	while [ $i -lt 1012 ] ; do
		ssh root@$FULLHOSTNAME "useradd -d /home/$userprefix$i -g 100 -p '$userpwd' -s /bin/bash -u $i $userprefix$i"
		if [ $? -ne 0 ] ; then
			message "ERROR: Failed to add local user $userprefix$i on client $c."
			myresult=FAIL
		fi
		let i=$i+1
   	done

	sssdClientSetup $c $DIRSERV
	if [ $? -ne 0 ] ; then
		message "ERROR: SSSD Client Setup Failed for $c."
		myresult=FAIL
	fi
  done
  tet_result $myresult
  message "END $tet_this_test"
}

#EOF


