#!/bin/sh

######################################################################
#  File: cleanup.sh - cleans up the clients after SSSD testing
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0"
ic0="cleanup"
######################################################################
# Tests
######################################################################
cleanup()
{
  myresult=PASS
  message "START $tet_thistest: Cleanup Clients"
  for c in $CLIENTS; do
	eval_vars $c
        message "Working on $FULLHOSTNAME"

	# restore NSS and PAM configuration to original
        sssdClientCleanup $FULLHOSTNAME 
        if [ $? -ne 0 ] ; then
                message "ERROR:  SSSD Client Cleanup did not complete successfully on client $FULLHOSTNAME."
                myresult=FAIL
        fi

	# uninstall and clean up SSSD
        ssh root@$FULLHOSTNAME "yum -y erase sssd ; rm -rf /var/lib/sss/ ; rm -rf /etc/sssd/ ; rm -rf /etc/yum.repos.d/sssd_* ; yum clean all"
        if [ $? -ne 0 ] ; then
                message "ERROR: Failed to uninstall and cleanup SSSD. Return code: $?"
                myresult=FAIL
        else
                message "SSSD Uninstall and Cleanup Success."
        fi

	# remove custom SELinux policy modification
        ssh root@$FULLHOSTNAME "semanage port -d -t ldap_port_t -p tcp 11329"
        if [ $? -ne 0 ] ; then
                message "ERROR: Removing SSSD SELinux Policy modification for custom LDAP port failed. return code: 0"
                myresult=FAIL
        fi

  done

  result $myresult
  message "END $tet_thistest"
}

##################################################################
. $TESTING_SHARED/instlib.sh
. $TESTING_SHARED/shared.sh
. $TESTING_SHARED/sssdlib.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF

