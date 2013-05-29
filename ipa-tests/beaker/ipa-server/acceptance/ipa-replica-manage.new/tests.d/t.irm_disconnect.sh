# irm_disconnect_pos_0001 - disconnect, master to replica2 agreement
#    ipa-replica-manage connect $REPLICA1 $REPLICA4    # prep for test
#    ipa-replica-manage disconnect $MASTER $REPLICA2   # test
#    ipa-replica-manage connect $MASTER $REPLICA2      # undo after test
#    ipa-replica-manage disconnect $REPLICA1 $REPLICA4 # undo after test
#??? Should I add data on 1 and test that I can see it on 4? ???
function irm_disconnect_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_pos_0001: disconnect, master to replica2 agreement"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA1 $REPLICA4"
        testuser="testuser$(date +%H%M%S)"

        # Test 
        rlRun "ipa-replica-manage $PWOPT disconnect $MASTER $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Deleted replication agreement" $tmpout
        irm_useradd $MASTER $testuser 
        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $MASTER $testuser
        rlRun "ipa-replica-manage $PWOPT connect $MASTER $REPLICA2"
        rlRun "ssh $REPLICA2 \"ipactl stop\""
        rlRun "ssh $REPLICA2 \"ipactl start\""
        rlRun "ssh $REPLICA2 \"ipa-replica-manage $PWOPT re-initialize --from $MASTER\""
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA1 $REPLICA4"      

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_pos_0002 - disconnect, master to replica2 agreement, remote
#    ipa-replica-manage connect $REPLICA1 $REPLICA4
#    ipa-replica-manage -H $REPLICA1 disconnect $MASTER $REPLICA2
#    ipa-replica-manage connect $MASTER $REPLICA2
#    ipa-replica-manage disconnect $REPLICA1 $REPLICA4
#??? Should I add data on 1 and test that I can see it on 4? ???
function irm_disconnect_pos_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_pos_0002: disconnect, master to replica2 agreement, remote"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA1 $REPLICA4"
        testuser="testuser$(date +%H%M%S)"

        # Test 
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 disconnect $MASTER $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Deleted replication agreement" $tmpout
        irm_useradd $REPLICA1 $testuser 
        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $MASTER $testuser
        rlRun "ipa-replica-manage $PWOPT connect $MASTER $REPLICA2"
        rlRun "ssh $REPLICA2 \"ipactl stop\""
        rlRun "ssh $REPLICA2 \"ipactl start\""
        rlRun "ssh $REPLICA2 \"ipa-replica-manage $PWOPT re-initialize --from $MASTER\""
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA1 $REPLICA4"      

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_neg_0001 - disconnect fail, replica with last agreement
#    ipa-replica-manage disconnect $REPLICA3 $REPLICA4
#    grep "Cannot remove the last replication link"
#    grep "Please use the 'del' command to remove it from the domain"
function irm_disconnect_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_neg_0001: disconnect fail, replica with last agreement"
    case "$MYROLE" in
    MASTER_*)

        # Test 
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA3 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Cannot remove the last replication link" $tmpout
        rlAssertGrep "Please use the 'del' command to remove it" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_neg_0002 - disconnect fail, replica with last agreement, remote
#    ipa-replica-manage -H $REPLICA1 disconnect $REPLICA3 $REPLICA4
#    grep "Cannot remove the last replication link"
#    grep "Please use the 'del' command to remove it from the domain"
function irm_disconnect_neg_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_neg_0002: disconnect fail, replica with last agreement, remote"
    case "$MYROLE" in
    MASTER_*)

        # Test 
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 disconnect $REPLICA3 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Cannot remove the last replication link" $tmpout
        rlAssertGrep "Please use the 'del' command to remove it" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_neg_0003 - disconnect fail, non-existent replica
#    ipa-replica-manage disconnect $MASTER dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_disconnect_neg_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_neg_0003: disconnect fail, non-existent replica"
    case "$MYROLE" in
    MASTER_*)

        # Test 
        rlRun "ipa-replica-manage $PWOPT disconnect $MASTER dne.$DOMAIN > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_neg_0004 - disconnect fail, non-existent replica, remote
#    ipa-replica-manage -H $REPLICA2 disconnect $MASTER dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_disconnect_neg_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_neg_0004: disconnect fail, non-existent replica, remote"
    case "$MYROLE" in
    MASTER_*)

        # Test 
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA2 disconnect $MASTER dne.$DOMAIN > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_neg_0005 - disconnect fail, after already disconnected
#    ipa-replica-manage connect $REPLICA1 $REPLICA4 # prep for test
#    ipa-replica-manage disconnect $REPLICA3 $REPLICA4 # pass
#    ipa-replica-manage disconnect $REPLICA3 $REPLICA4
#    grep "'$REPLICA3' has no replication agreement for '$REPLICA4'"
#    ipa-replica-manage connect $REPLICA3 $REPLICA4
#    ipa-replica-manage disconnect $REPLICA1 $REPLICA4 # undo after test
function irm_disconnect_neg_0005()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_neg_0005: disconnect fail, after already disconnected"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA1 $REPLICA4"
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA3 $REPLICA4"

        # Test 
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA3 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "'$REPLICA3' has no replication agreement for '$REPLICA4'" $tmpout

        # Cleanup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA3 $REPLICA4"
        rlRun "ssh $REPLICA3 \"ipactl stop\""
        rlRun "ssh $REPLICA3 \"ipactl start\""
        rlRun "ssh $REPLICA3 \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA2\""
        rlRun "ssh $REPLICA4 \"ipactl stop\""
        rlRun "ssh $REPLICA4 \"ipactl start\""
        rlRun "ssh $REPLICA4 \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA3\""
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA1 $REPLICA4"      

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_disconnect_neg_0006 - disconnect fail, after already disconnected, remote
#    ipa-replica-manage connect $REPLICA1 $REPLICA4 # prep for test
#    ipa-replica-manage disconnect $REPLICA3 $REPLICA4 # pass
#    ipa-replica-manage -H $REPLICA4 disconnect $REPLICA3 $REPLICA4
#    grep "'$REPLICA3' has no replication agreement for '$REPLICA4'"
#    ipa-replica-manage connect $REPLICA3 $REPLICA4
#    ipa-replica-manage disconnect $REPLICA1 $REPLICA4 # undo after test
function irm_disconnect_neg_0006()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_neg_0006: disconnect fail, after already disconnected, remote"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA1 $REPLICA4"
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA3 $REPLICA4"

        # Test 
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA4 disconnect $REPLICA3 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "'$REPLICA3' has no replication agreement for '$REPLICA4'" $tmpout

        # Cleanup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA3 $REPLICA4"
        rlRun "ssh $REPLICA3 \"ipactl stop\""
        rlRun "ssh $REPLICA3 \"ipactl start\""
        rlRun "ssh $REPLICA3 \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA2\""
        rlRun "ssh $REPLICA4 \"ipactl stop\""
        rlRun "ssh $REPLICA4 \"ipactl start\""
        rlRun "ssh $REPLICA4 \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA3\""
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA1 $REPLICA4"      

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}
