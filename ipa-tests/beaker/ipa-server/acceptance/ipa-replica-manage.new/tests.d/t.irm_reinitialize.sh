# irm_reinitialize_pos_0001 - reinitialize, master from replica1 [BZ831661]
#    ssh $MASTER "ipa-replica-manage re-initialize --from=$REPLICA1"
#    grep "Update succeeded"
#    irm_bugcheck_831661 $tmpout $REPLICA1 
function irm_reinitialize_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_pos_0001: reinitialize, master from replica1 [BZ831661]"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT re-initialize --from=$REPLICA1 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Update succeeded" $tmpout
        irm_userchk $MASTER admin

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

# irm_reinitialize_pos_0002 - reinitialize, replica2 from master, remote [BZ831661]
#    ipa-replica-manage -H $REPLICA2 re-initialize --from=$MASTER
#    grep "Update succeeded"
#    irm_bugcheck_831661 $tmpout $MASTER 
function irm_reinitialize_pos_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_pos_0002: reinitialize, replica2 from master, remote [BZ831661]"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA2 re-initialize --from=$MASTER > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Update succeeded" $tmpout
        irm_userchk $MASTER admin
        
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

# irm_reinitialize_pos_0003 - reinitialize, replica3 from replica2 [BZ831661]
#    ssh $REPLICA3 "ipa-replica-manage re-initialize --from=$REPLICA2"
#    grep "Update succeeded"
#    irm_bugcheck_831661 $tmpout $REPLICA1 
function irm_reinitialize_pos_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_pos_0003: reinitialize, replica3 from replica2 [BZ831661]"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    REPLICA3_*)
        rlRun "ipa-replica-manage $PWOPT re-initialize --from=$REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Update succeeded" $tmpout
        irm_userchk $REPLICA3 admin

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR3"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_reinitialize_pos_0004 - reinitialize, replica4 from replica3, remote [BZ831661]
#    ipa-replica-manage -H $REPLICA4 re-initialize --from=$REPLICA3
#    grep "Update succeeded"
#    irm_bugcheck_831661 $tmpout $REPLICA1 
function irm_reinitialize_pos_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_pos_0004: reinitialize, replica4 from replica3, remote [BZ831661]"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    REPLICA3_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA4 re-initialize --from=$REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Update succeeded" $tmpout
        irm_userchk $REPLICA4 admin

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR3"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_reinitialize_neg_0001 - reinitialize fail, without --from
#    ipa-replica-manage reinitialize 
#    grep "re-initialize requires the option --from"
function irm_reinitialize_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0001: reinitialize fail, without --from"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT re-initialize > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "re-initialize requires the option --from" $tmpout

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

# irm_reinitialize_neg_0002 - reinitialize fail, without --from, remote
#    ipa-replica-manage -H $REPLICA1 reinitialize
#    grep "re-initialize requires the option --from"
function irm_reinitialize_neg_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0002: reinitialize fail, without --from, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 re-initialize > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "re-initialize requires the option --from" $tmpout

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

# irm_reinitialize_neg_0003 - reinitialize fail, from self
#    ipa-replica-manage reinitialize --from=$(hostname)
#    grep "'$MASTER' has no replication agreement for '$MASTER'"
function irm_reinitialize_neg_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0003: reinitialize fail, from self"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT re-initialize --from $MASTER > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for '$MASTER'" $tmpout

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

# irm_reinitialize_neg_0004 - reinitialize fail, from self, remote
#    ipa-replica-manage -H $REPLICA1 reinitialize --from=$REPLICA1
#    grep "'$REPLICA1' has no replication agreement for '$REPLICA1'"
function irm_reinitialize_neg_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0003: reinitialize fail, from self, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 re-initialize --from $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$REPLICA1' has no replication agreement for '$REPLICA1'" $tmpout

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

# irm_reinitialize_neg_0005 - reinitialize fail, from non-existent replica
#    ipa-replica-manage  reinitialize --from=dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_reinitialize_neg_0005()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0005: reinitialize fail, from non-existent replica"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT re-initialize --from dne.$DOMAIN > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "Unknown host dne.$DOMAIN" $tmpout

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

# irm_reinitialize_neg_0006 - reinitialize fail, from non-existent replica, remote
#    ipa-replica-manage  -H $MASTER reinitialize --from=dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_reinitialize_neg_0006()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0006: reinitialize fail, from non-existent replica, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 re-initialize --from dne.$DOMAIN > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "Unknown host dne.$DOMAIN" $tmpout

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

# irm_reinitialize_neg_0007 - reinitialize fail, with no agreement
#    ipa-replica-manage del $REPLICA1
#    ipa-replica-manage reinitialize --from=$REPLICA1
#    grep "'$MASTER' has no replication agreement for '$REPLICA1'"
#    irm_uninstall $REPLICA1
function irm_reinitialize_neg_0007()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0007: reinitialize fail, with no agreement"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT del $REPLICA1 -f -c"

        # Test
        rlRun "ipa-replica-manage $PWOPT re-initialize --from $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "Unknown host $REPLICA1" $tmpout
        
        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"

        # Cleanup
        rlRun "ssh $MASTER \"ipactl stop\""
        rlRun "ssh $MASTER \"ipactl start\""
        rlRun "ssh $MASTER \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA2\""
        irm_uninstall
        irm_install $MASTER
        
        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR1"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_reinitialize_neg_0008 - reinitialize fail, with no agreement, remote
#    ipa-replica-manage del $REPLICA1
#    ipa-replica-manage -H $MASTER reinitialize --from=$REPLICA1
#    grep "'$MASTER' has no replication agreement for '$REPLICA1'"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
function irm_reinitialize_neg_0008()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_reinitialize_neg_0008: reinitialize fail, with no agreement, remote"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT del $REPLICA1 -f -c"

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"

        # Cleanup
        rlRun "ssh $MASTER \"ipactl stop\""
        rlRun "ssh $MASTER \"ipactl start\""
        rlRun "ssh $MASTER \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA2\""
        irm_uninstall 
        irm_install $MASTER

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.2' -m $MY_BR1"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"

        # Test
        rlRun "ipa-replica-manage $PWOPT -H $MASTER re-initialize --from $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "Unknown host $REPLICA1" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR1"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR1"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR1"
        ;;
    *)
    esac
    rlPhaseEnd
}
