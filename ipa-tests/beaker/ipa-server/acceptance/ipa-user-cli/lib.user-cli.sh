#######################################
# lib.user-cli.sh
#######################################

# functions used in user-cli test

makereport()
{
    # capture the result and make a simple report
    total=`rlJournalPrintText | grep "RESULT" | wc -l`
    pass=`rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]" | wc -l`
    fail=`rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]" | wc -l`
    abort=`rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]" | wc -l`
    report=$TmpDir/rhts.report.$RANDOM.txt
    echo "================ final pass/fail report =================" > $report
    echo "   Test Date: `date` " >> $report
    echo "   Total : [$total] "  >> $report
    echo "   Passed: [$pass] "   >> $report
    echo "   Failed: [$fail] "   >> $report
    echo "   Abort : [$abort]"   >> $report
    echo "---------------------------------------------------------" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   PASS   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[   FAIL   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "" >> $report
    rlJournalPrintText | grep "RESULT" | grep "\[  ABORT   \]"| sed -e 's/:/ /g' -e 's/RESULT//g' >> $report
    echo "=========================================================" >> $report
    echo "report saved as: $report"
    cat $report
}

userfind_field_check()
{
    local option="$1"
    local field="$2"
    local value="$3"
    rlRun "ipa user-find --all $option | grep \"$field\" | grep \"$value\" " \
          0 \
          "test option:[$option], verify field [$field] value [$value]"
} #field_check

set_and_check_attr
{
    local out=$TmpDir/setandcheckattr.$RANDOM.out
    local login="$1"
    local attr="$2"
    local value="$3"
    local checkcondition="$2: $3"
    rlRun "ipa user-mod \"$login\" --setattr=$attr=\"$value\"" 0 "set [$attr]=[$value] for [$login]"
    # I might not need the next pass/fail determine statement
    # comment them out for now
    #ipa user-find $login --all > $out
    #if grep "$checkcondition" $out 2>&1 >/dev/null
    #then
    #    rlPass "set success, test pass"
    #else
    #    rlFail "set failed, test failed"
    #fi 
    #rm $out
} #set_and_check_attr

add_and_check_attr
{
    local out=$TmpDir/setandcheckattr.$RANDOM.out
    local login="$1"
    local attr="$2"
    local value="$3"
    local checkcondition="$2: $3"
    rlRun "ipa user-mod \"$login\" --addattr=$attr=\"$value\"" 0 "set [$attr]=[$value] for [$login]"
    # I might not need the next pass/fail determine statement
    # comment them out for now
    #ipa user-find $login --all > $out
    #if grep "$checkcondition" $out 2>&1 >/dev/null
    #then
    #    rlPass "add success, test pass"
    #else
    #    rlFail "add failed, test failed"
    #fi 
    #rm $out
} #set_and_check_attr
