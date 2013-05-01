# irm_list_pos_0001 # list, no name
function irm_list_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_pos_0001: list, no name"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT list > $tmpout 2>&1"
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
function irm_list_pos_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_pos_0002: list, with name"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA1_*)
        
        rlRun "ipa-replica-manage $PWOPT list $MASTER > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA1" $tmpout
        rlAssertGrep "$REPLICA2" $tmpout
        rlAssertNotGrep "$MASTER" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA1 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertNotGrep "$REPLICA3" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$REPLICA1" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA2" $tmpout
        rlAssertGrep "$REPLICA4" $tmpout
        rlAssertNotGrep "$MASTER" $tmpout

        rlRun "ipa-replica-manage $PWOPT list $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA3" $tmpout
        rlAssertNotGrep "$MASTER" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR1"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_pos_0003 # list, no name, with verbose
function irm_list_pos_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_pos_0003: list, no name, with verbose"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        ;;
    REPLICA2_*)
        rlRun "ipa-replica-manage $PWOPT list -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$MASTER" $tmpout
        rlAssertNotGrep "last init status" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR2"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_pos_0004 # list, with name, with verbose
function irm_list_pos_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_pos_0004: list, with name, with verbose"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        ;;
    REPLICA3_*)
        rlRun "ipa-replica-manage $PWOPT list $REPLICA4 -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA3" $tmpout 
        rlAssertGrep "last init status" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR3"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_pos_0005 # list, with name, remote
function irm_list_pos_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_pos_0004: list, with name, with verbose"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA4_*)
        rlRun "ipa-replica-manage $PWOPT list -H $MASTER $MASTER -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA1" $tmpout 
        rlAssertGrep "$REPLICA2" $tmpout 
        rlAssertGrep "last init status" $tmpout

        rlRun "ipa-replica-manage $PWOPT list -H $REPLICA1 $MASTER -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA1" $tmpout 
        rlAssertGrep "$REPLICA2" $tmpout 
        rlAssertGrep "last init status" $tmpout

        rlRun "ipa-replica-manage $PWOPT list -H $REPLICA2 $MASTER -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA1" $tmpout 
        rlAssertGrep "$REPLICA2" $tmpout 
        rlAssertGrep "last init status" $tmpout

        rlRun "ipa-replica-manage $PWOPT list -H $REPLICA3 $MASTER -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA1" $tmpout 
        rlAssertGrep "$REPLICA2" $tmpout 
        rlAssertGrep "last init status" $tmpout

        rlRun "ipa-replica-manage $PWOPT list -H $REPLICA4 $MASTER -v > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$REPLICA1" $tmpout 
        rlAssertGrep "$REPLICA2" $tmpout 
        rlAssertGrep "last init status" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR4"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_neg_0001 # list fail, no agreement, with name
function irm_list_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_neg_0001: list fail, no agreement, with name"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT list $REPLICA1 | grep -v $REPLICA2 > $tmpout 2>&1" 
        rlRun "cat $tmpout"
        rlAssertNotGrep "$REPLICA2" $tmpout 

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_neg_0002 # list fail, no agreement, with name, remote
function irm_list_neg_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_neg_0002: list fail, no agreement, with name, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT list -H $REPLICA1 $REPLICA1 | grep -v $REPLICA2 > $tmpout 2>&1" 
        rlRun "cat $tmpout"
        rlAssertNotGrep "$REPLICA2" $tmpout 

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_neg_0003 # list fail, non-existent host, with name
function irm_list_neg_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_neg_0003: list fail, non-existent host, with name"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT list dne.$DOMAIN > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "Unknown host dne.$DOMAIN" $tmpout 

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BM"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BM"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_list_neg_0004 # list fail, after uninstalling replica, with name [BZ#754739]
function irm_list_neg_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_list_neg_0004: list fail, after uninstalling replica, with name [BZ#754739]"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"

        rlRun "ipa-replica-manage $PWOPT list $REPLICA4 > $tmpout 2>&1" 
        rlRun "cat $tmpout"
        rlAssertGrep "Cannot find $REPLICA4 in public server list" $tmpout 

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.2' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR4"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR4"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR4"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR4"
        ;;
    REPLICA4_*)
        irm_uninstall 

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR4"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2'  $MY_BM"

        irm_install $REPLICA3

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.3' -m $MY_BR4"

        ;;
    *)
    esac
    rlPhaseEnd
}
