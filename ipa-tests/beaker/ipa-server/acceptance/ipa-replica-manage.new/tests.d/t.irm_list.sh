# irm_list_pos_0001 # list, no name
function irm_list_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_pos_0001: list, no name"
    case "$MYROLE" in
    MASTER_*)
        rlRun "KinitAsAdmin"
        rlRun "ipa-replica-manage list > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertGrep "$REPLICA1" $tmpout
        rlAssertGrep "$REPLICA2" $tmpout
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertGrep "$REPLICA4" $tmpout

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

# irm_list_pos_0002 # list, with name
# irm_list_pos_0003 # list, no name, with verbose
# irm_list_pos_0004 # list, with name, with verbose
# irm_list_pos_0005 # list, with name, remote
# irm_list_neg_0001 # list fail, no agreement, with name
# irm_list_neg_0002 # list fail, no agreement, with name, remote
# irm_list_neg_0003 # list fail, non-existent host, with name
# irm_list_neg_0004 # list fail, after uninstalling replica, with name [BZ#754739]
