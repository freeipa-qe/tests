# irm_forcesync_pos_0001 - forcesync, master from replica1
#    ipa-replica-manage forcesync --from=$REPLICA1
function irm_forcesync_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_function_0001: function, test"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        irm_rep_pause $REPLICA1 $MASTER
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $REPLICA1 $testuser
        irm_userchk $REPLICA1 $testuser
        irm_userchk $MASTER $testuser 2
        
        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync --from $REPLICA1 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Setting agreement.*to force sync" $tmpout
        rlAssertGrep "Deleting schedule.*from agreement" $tmpout

        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser 
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

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

# irm_forcesync_pos_0002 - forcesync, master from replica1, remote
#    ipa-replica-manage -H $REPLICA2 forcesync --from=$REPLICA1

# irm_forcesync_pos_0003 - forcesync, replica2 from replica3
#    ipa-replica-manage forcesync --from=$REPLICA3

# irm_forcesync_pos_0004 - forcesync, replica2 from replica3, remote
#    ipa-replica-manage -H $REPLICA1 forcesync --from=$REPLICA3
     
# irm_forcesync_pos_0005 - forcesync, replica3 from replica4
#     ipa-replica-manage forcesync --from=$REPLICA4
     
# irm_forcesync_pos_0006 - forcesync, replica3 from replica4, remote
#     ipa-replica-manage -H $REPLICA2 forcesync --from=$REPLICA4
     
# irm_forcesync_neg_0001 - forcesync fail, without --from
#     ipa-replica-manage forcesync 
#     grep "force-sync requires the option --from"

# irm_forcesync_neg_0002 - forcesync fail, without --from, remote
#     ipa-replica-manage -H $REPLICA1 forcesync 
#     grep "force-sync requires the option --from"

# irm_forcesync_neg_0003 - forcesync fail, from self
#    ipa-replica-manage forcesync --from=$(hostname)

# irm_forcesync_neg_0004 - forcesync fail, from self, remote
#    ipa-replica-manage -H $REPLICA4 forcesync --from=$(hostname)

# irm_forcesync_neg_0005 - forcesync fail, from non-existent replica
#    ipa-replica-manage forcesync --from=dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"

# irm_forcesync_neg_0006 - forcesync fail, from non-existent replica, remote
#    ipa-replica-manage -H $REPLICA2 forcesync --from=dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"

# irm_forcesync_neg_0007 - forcesync fail, with no agreement
#    ipa-replica-manage del $REPLICA1
#    ipa-replica-manage forcesync --from=$REPLICA1
#    grep "some error?"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER

# irm_forcesync_neg_0008 - forcesync fail, with no agreement, remote
#    ipa-replica-manage del $REPLICA1
#    ipa-replica-manage -H $MASTER forcesync --from=$REPLICA1
#    grep "some error?"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
