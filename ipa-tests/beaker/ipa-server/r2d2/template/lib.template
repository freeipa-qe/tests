#######################################
# lib.user-cli.sh
#######################################

# functions used in user-cli test

# this is empty right now
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
