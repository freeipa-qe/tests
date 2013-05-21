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

