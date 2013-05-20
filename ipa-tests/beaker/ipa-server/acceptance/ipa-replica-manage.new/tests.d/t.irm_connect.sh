# irm_connect_pos_0001 - connect, replica1 to replica4
#    ipa-replica-manage connect $REPLICA1 $REPLICA4
#    ssh $REPLICA1 "ipa user-add testuser1"
#    ssh $REPLICA4 "ipa user-show testuser1" # pass
#    ipa-replica-manage disconnect $REPLICA1 $REPLICA4
function irm_connect_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_connect_pos_0001: connect, replica1 to replica4"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA1 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Connected '$REPLICA1' to '$REPLICA4'" $tmpout
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $MASTER $testuser
        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $MASTER $testuser
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

# irm_connect_pos_0002 - connect, replica1 to replica4, remote
#    ipa-replica-manage -H $REPLICA3 connect $REPLICA1 $REPLICA4
#    ssh $REPLICA4 "ipa user-add testuser2"
#    ssh $REPLICA1 "ipa user-show testuser2" # pass
#    ipa-replica-manage disconnect $REPLICA1 $REPLICA4
function irm_connect_pos_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_connect_pos_0002: connect, replica1 to replica4, remote"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA3 connect $REPLICA1 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Connected '$REPLICA1' to '$REPLICA4'" $tmpout
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $MASTER $testuser
        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $MASTER $testuser
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

# irm_connect_neg_0001 - connect fail, existing agreement
#    ipa-replica-manage connect $MASTER $REPLICA1
#    grep "A replication agreement to $REPLICA1 already exists"
function irm_connect_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_connect_neg_0001: connect fail, existing agreement"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT connect $MASTER $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "A replication agreement to $REPLICA1 already exists" $tmpout

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

# irm_connect_neg_0002 - connect fail, existing agreement, remote
#    ipa-replica-manage -H $REPLICA1 connect $MASTER $REPLICA1
#    grep "A replication agreement to $REPLICA1 already exists"
function irm_connect_neg_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_connect_neg_0002: connect fail, existing agreement, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 connect $MASTER $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "A replication agreement to $REPLICA1 already exists" $tmpout

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
