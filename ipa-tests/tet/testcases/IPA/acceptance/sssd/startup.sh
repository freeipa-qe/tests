#!/bin/sh

######################################################################
#  File: startup.sh - sets up the clients for SSSD testing
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0"
ic0="startup"
######################################################################
# Tests
######################################################################
startup()
{
  myresult=PASS
  message "START $tet_thistest: Setup for SSSD Local Domain Testing"
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"

        # set up repo file on the client
        ssh root@$FULLHOSTNAME "cd /etc/yum.repos.d/ ; wget $REPO"
        if [ $? -ne 0 ] ; then
                message "ERROR: Failed to setup up yum repo. return code: $?"
                myresult=FAIL
        fi

	# INSTALL SSSD
	ssh root@$FULLHOSTNAME "yum clean all ; yum -y install sssd"
	if [ $? -ne 0 ] ; then
		message "ERROR:  Failed to install SSSD. Return code: $?"
		myresult=FAIL
        else
                message "SSSD installed successfully."
	fi

	# CONFIG NSS AND PAM
	sssdClientSetup $FULLHOSTNAME
	if [ $? -ne 0 ] ; then
		message "ERROR: SSSD Client Setup Failed for $FULLHOSTNAME."
		myresult=FAIL
	fi
  done
  tet_result $myresult
  message "END $tet_thistest"
}

##################################################################
. $TESTING_SHARED/instlib.sh
. $TESTING_SHARED/shared.sh
. $TESTING_SHARED/sssdlib.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF

