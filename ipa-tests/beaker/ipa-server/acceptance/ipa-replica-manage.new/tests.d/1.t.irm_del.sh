# irm_del_pos_0001 - del, replica4
#    ssh $REPLICA3 "ipa group-add delgroup1 --desc=desc"
#    ssh $REPLICA4 "ipa group-show delgroup1"
#    ipa-replica-manage del $REPLICA4 -f
#    ipa-replica-manage list $REPLICA3|grep -v $REPLICA4
#??? Should ipa-replica-manage list without specifying hostname show replica4 ??? no
#    ssh $REPLICA3 "ipa group-del delgroup1"
#    ssh $REPLICA4 "ipa group-show delgroup1" # fail
#    ssh $REPLICA3 "ipa group-add delgroup2 --desc=desc"
#    ssh $REPLICA4 "ipa group-show delgroup2"
#    irm_uninstall $REPLICA4
#    irm_install $REPLICA4 $REPLICA3
function irm_del_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_pos_0001: del, replica4"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_pos_0002 - del, replica4, remote
#    ipa-replica-manage -H $MASTER del $REPLICA1 -f
#    ipa-replica-manage list $MASTER|grep -v $REPLICA1
#??? Should ipa-replica-manage list without specifying hostname show replica1 ???
#    ipa host-show $REPLICA1 # fail with errnum 2
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
function irm_del_pos_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_pos_0002: del, replica4, remote"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_neg_0001 - del fail, with disconnected agreement
#    ipa-replica-manage disconnect $REPLICA3 $REPLICA4
#    ipa-replica-manage del $REPLICA3
#    irm_bugcheck_826677
#    ipa-replica-manage list $REPLICA2|grep $REPLICA3
#    ipa-replica-manage connect $REPLICA3 $REPLICA4
function irm_del_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0001: del fail, with disconnected agreement"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_neg_0002 - del fail, with disconnected agreement, remote
#    ipa-replica-manage disconnect $REPLICA3 $REPLICA4
#    ipa-replica-manage -H $REPLICA2 del $REPLICA3
#    irm_bugcheck_826677
#    ipa-replica-manage list $REPLICA2|grep $REPLICA3
#    ipa-replica-manage connect $REPLICA3 $REPLICA4
function irm_del_neg_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0002: del fail, with disconnected agreement, remote"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_neg_0003 - del fail, already deleted agreement [BZ754524]
#    ipa-replica-manage del $REPLICA1 -f
#    ipa-replica-manage del $REPLICA1 -f
#    grep "'$MASTER' has no replication agreement for '$REPLICA1'"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
function irm_del_neg_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0003: del fail, already deleted agreement [BZ754524]"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_neg_0004 - del fail, already deleted agreement, remote [BZ754524]
#    ipa-replica-manage del $REPLICA1 -f
#    ipa-replica-manage -H $MASTER del $REPLICA1 -f
#    grep "'$MASTER' has no replication agreement for '$REPLICA1'"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
function irm_del_neg_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0004: del fail, already deleted agreement, remote [BZ754524]"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_neg_0005 - del fail, non-existent replica
#    ipa-replica-manage del dne.$DOMAIN -f
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_del_neg_0005()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0005: del fail, non-existent replica"
    case "$MYROLE" in
    MASTER_*)
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

# irm_del_neg_0006 - del fail, non-existent replica, remote
#    ipa-replica-manage -H $REPLICA1 del dne.$DOMAIN -f
#    grep "'$REPLICA1' has no replication agreement for 'dne.$DOMAIN'"
function irm_del_neg_0006()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0006: del fail, non-existent replica, remote"
    case "$MYROLE" in
    MASTER_*)
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

