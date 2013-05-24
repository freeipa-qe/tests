# start quickinstall tree2
#        M
#       / \
#     r1   r2
#           \
#            r3
#             \
#              r4
#
# list to make sure r1 and r4 are not connected.
function irm_func_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_func_0001: list open ended environment"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT list $MASTER > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertNotGrep "$MASTER" $tmpout
        rlAssertGrep "$REPLICA1" $tmpout
        rlAssertGrep "$REPLICA2" $tmpout
        rlAssertNotGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$REPLICA4" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA1 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA1" $tmpout
        rlAssertNotGrep "$REPLICA2" $tmpout
        rlAssertNotGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$REPLICA4" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA1" $tmpout
        rlAssertNotGrep "$REPLICA2" $tmpout
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$REPLICA4" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertNotGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA1" $tmpout
        rlAssertGrep "$REPLICA2" $tmpout
        rlAssertNotGrep "$REPLICA3" $tmpout
        rlAssertGrep "$REPLICA4" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertNotGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA1" $tmpout
        rlAssertNotGrep "$REPLICA2" $tmpout
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$REPLICA4" $tmpout

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

#  connect r1 r4
#        M
#       / \
#     r1   r2
#      |   |
#     r4---r3
function irm_func_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_func_0002: connect replica1 and replic4"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)

        rlRun "ipa-replica-manage $PWOPT connect $REPLICA1 $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Connected '$REPLICA1' to '$REPLICA4'" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA1 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertGrep "$REPLICA4" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertGrep "$REPLICA1" $tmpout

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

# disconnect r2 r3
#        M
#       / \
#     r1   r2
#      |    
#     r4---r3
function irm_func_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_func_0003: disconnect replica2 and replica3"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA2 $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Deleted replication agreement from '$REPLICA2' to '$REPLICA3'" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA3" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA4" $tmpout
        rlAssertNotGrep "$REPLICA2" $tmpout

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

# connect -H r2 r3
#        M
#       / \
#     r1   r2
#      |   |
#     r4---r3

function irm_func_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_func_0004: connect replica2 and replica3, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA2 connect $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Connected '$REPLICA2' to '$REPLICA3'" $tmpout
        
        rlRun "ipa-replica-manage $PWOPT list $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertGrep "$REPLICA3" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA4" $tmpout
        rlAssertGrep "$REPLICA2" $tmpout

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

# disconnect -H r1 r4
#        M
#       / \
#     r1   r2
#          |
#     r4---r3

function irm_func_0005()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_func_0005: disconnect replica1 and replica4, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 disconnect $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Deleted replication agreement from '$REPLICA1' to '$REPLICA4'" $tmpout
        
        rlRun "ipa-replica-manage $PWOPT list $REPLICA1 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA4" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$REPLICA1" $tmpout

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
