# irm_disconnect_pos_0001: disconnect, master to replica2 agreement
function irm_disconnect_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_disconnect_pos_0001 - disconnect, master to replica2 agreement"
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

# irm_disconnect_pos_0002: disconnect, master to replica2 agreement, remote
# irm_disconnect_neg_0001: disconnect fail, replica with last agreement
# irm_disconnect_neg_0002: disconnect fail, replica with last agreement, remote
# irm_disconnect_neg_0003: disconnect fail, non-existent replica
# irm_disconnect_neg_0004: disconnect fail, non-existent replica, remote
# irm_disconnect_neg_0005: disconnect fail, after already disconnected
# irm_disconnect_neg_0006: disconnect fail, after already disconnected, remote

