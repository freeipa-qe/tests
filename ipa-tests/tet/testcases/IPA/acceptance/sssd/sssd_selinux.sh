#!/bin/sh

######################################################################
#  File: sssd_selinux.sh - Verify no SELinux errors found
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
        set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0"
ic0="sssd_selinux_001"
######################################################################
# Tests
######################################################################
sssd_selinux_001()
{
  myresult=PASS
  message "START $tet_thistest: Verify No SELinux Errors in Audit Log"
  for c in $CLIENTS; do
        eval_vars $c
        message "Working on $FULLHOSTNAME"
	ssh root@$FULLHOSTNAME "cat /var/log/audit/audit.log | grep AVC"
	if [ $? -eq 0 ] ; then
		message "ERROR: SELinux AVC messages found in the audit log"
		ssh root@$FULLHOSTNAME "cat /var/log/audit/audit.log | grep AVC > /tmp/sssd_selinux.errs"
		sftp root@$FULLHOSTNAME:/tmp/sssd_selinux.errs $TET_TMP_DIR/sssd_selinux.errs
		message "Please see $TET_TMP_DIR/sssd_selinux.errs for details."
		myresult=FAIL
	else
		message "No SELinux AVC messages found in the audit log"
	fi
  done
  result $myresult
  message "END $tet_thistest"
}

##################################################################
. $TESTING_SHARED/shared.sh
. $TET_ROOT/lib/sh/tcm.sh

#EOF

