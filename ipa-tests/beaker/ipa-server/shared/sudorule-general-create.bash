
testname="ipa-hostgroup-cli"
testtype="hostgroup"
addtype="hostgroup" # Sudorule add type. used in ipa sudorule-add-$addtype
firsttestnumber=46
object1='$group1'
object2='$group2'


testn=$firsttestnumber

echo "sru=sruleta
    rlPhaseStartTest \"$testname-$testn: Positive test of search of $testtype in a sudorules\"
	rlRun \"ipa sudorule-add \$sru\" 0 \"Adding sudorule to test with\"
	rlRun \"ipa sudorule-add-host --hostgroups=$object1 \$sru\" 0 \"adding testtype $object1 to sudorule sru\"
	rlRun \"ipa $testtype-find --in-sudorule=\$sru | grep $object1\" 0 \"ensuring that $testtype $object1 is returned when searching for $testtype in a given sudorule\"
    rlPhaseEnd"
echo ""
let testn=$testn+1;
echo "    rlPhaseStartTest \"$testname-$testn: Negative test of search of $testtype in a sudorule\"
	rlRun \"ipa $testtype-find --in-sudorule=\$sru | grep $object2\" 1 \"ensuring that $testtype $object2 is notreturned when searching for $testtype in a given sudorule\"
    rlPhaseEnd"
echo ""
let testn=$testn+1;

echo "    rlPhaseStartTest \"$testname-$testn: Positive test of search of $testtype not in a sudorule\"
	rlRun \"ipa $testtype-find --not-in-sudorule=\$sru | grep $object2\" 0 \"ensuring that $testtype $object2 is returned when searching for $testtype not in a given sudorule\"
    rlPhaseEnd"
echo ""
let testn=$testn+1;

echo "    rlPhaseStartTest \"$testname-$testn: Negative test of search of $testtype not in a sudorule\"
	rlRun \"ipa $testtype-find --not-in-sudorule=\$sru | grep $object1\" 1 \"ensuring that $testtype $object1 is notreturned when searching for $testtype not in a given sudorule\"
    rlPhaseEnd"
echo ""
let testn=$testn+1;

echo "    rlPhaseStartTest \"$testname-$testn: Positive test of search of $testtype after it has been removed from the sudorule\"
	rlRun \"ipa sudorule-remove-host --hosts=$object1 \$sru\" 0 \"Remove $object1 from sudorule \$sru\"
	rlRun \"ipa $testtype-find --not-in-sudorule=\$sru | grep $object1\" 0 \"ensure that $object1 comes back from a search excluding sudorule \$sru\"
    rlPhaseEnd"
echo ""
let testn=$testn+1;

echo "    rlPhaseStartTest \"$testname-$testn: Negative test of search of $testtype after it has been removed from the sudorule\"
	rlRun \"ipa $testtype-find --in-sudorule=\$sru | grep $object1\" 1 \"ensure that $object1 does not come back from a search in sudorule \$sru\"
        deleteHost $object1
        deleteHost $object2
	rlRun \"ipa sudorule-del \$sru\" 0 \"cleaning up the sudorule used in these tests\"
    rlPhaseEnd"
