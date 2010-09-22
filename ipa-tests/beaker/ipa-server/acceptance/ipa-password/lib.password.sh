#######################################
# lib.password.sh
#######################################

# functions used in password test

# This function populates the current date into the hour, min, sec, month, day and year vars
get_time()
{
	export month=$(date +%m)
	export day=$(date +%d)
	export year=$(date +%Y)
	export hour=$(date +%H)
	export min=$(date +%M)
	export sec=$(date +%S)
}

SyncDate()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"
		fi
	done
}

SyncKpasswd()
{
	for s in $SERVERS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER;/etc/init.d/ipa_kpasswd restart"
		fi
	done
	for s in $CLIENTS; do
		if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER"
		fi
	done
}

ResetKinit()
{
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        # Kinit everywhere
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
			eval_vars $s
			ssh $FULLHOSTNAME "/etc/init.d/ntpd stop;ntpdate $NTPSERVER;/etc/init.d/ipa_kpasswd restart"
                        message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
                        KinitAs $s $DS_USER $DM_ADMIN_PASS
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
				message "Test - $tet_thistest - ResetKinit"
				return 1
                        fi
                fi
        done
        for s in $CLIENTS; do
                if [ "$s" != "" ]; then
                        message "kiniting as $DS_USER, password $DM_ADMIN_PASS on $s"
                        KinitAs $s $DS_USER $DM_ADMIN_PASS
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
				message "Test - $tet_thistest - ResetKinit"
				return 1
                        fi
                fi
        done
	return 0
}

makereport()
{
    # capture the result and make a simple report
    total=`rlJournalPrintText | grep "RESULT" | wc -l`
    pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
    fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
    report=/tmp/rhts.report.$RANDOM.txt
    echo "======= final pass/fail report ========" >> $report
    echo "   Test Date: `date` " > $report
    echo "   Total: [$total] passed: [$pass] failed: [$fail]" >> $report
    echo "---------------------------------------" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" >> $report
    echo "------- the following failed ----------" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" >> $report
    echo "========================================" >> $report
    echo "report saved as: $report"
    cat $report
}
