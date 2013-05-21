# irm_forcesync_pos_0001 - forcesync, master from replica1
#    ipa-replica-manage forcesync --from=$REPLICA1
function irm_forcesync_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_pos_0001: forcesync, master from replica1"
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

        # Cleanup
        irm_userdel $REPLICA1 $testuser

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

# irm_forcesync_pos_0002 - forcesync, replica1 from master, remote
#    ipa-replica-manage -H $REPLICA1 forcesync --from=$MASTER
function irm_forcesync_pos_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_pos_0002: forcesync, replica1 from master, remote"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        irm_rep_pause $MASTER $REPLICA1
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $MASTER $testuser
        irm_userchk $MASTER $testuser
        irm_userchk $REPLICA1 $testuser 2
        
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 force-sync --from $MASTER > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Setting agreement.*to force sync" $tmpout
        rlAssertGrep "Deleting schedule.*from agreement" $tmpout

        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser 
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $REPLICA1 $testuser

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

# irm_forcesync_pos_0003 - forcesync, replica2 from replica3
#    ipa-replica-manage forcesync --from=$REPLICA3
function irm_forcesync_pos_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_pos_0003: forcesync, replica2 from replica3"
    case "$MYROLE" in
    MASTER_*)

        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA2_*)
        # Setup
        irm_rep_pause $REPLICA3 $REPLICA2
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $REPLICA3 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA2 $testuser 2
        
        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync --from $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Setting agreement.*to force sync" $tmpout
        rlAssertGrep "Deleting schedule.*from agreement" $tmpout

        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser 
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $REPLICA1 $testuser

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR2"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_forcesync_pos_0004 - forcesync, replica3 from replica2, remote
#    ipa-replica-manage -H $REPLICA1 forcesync --from=$REPLICA3
function irm_forcesync_pos_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_pos_0004: forcesync, replica3 from replica2, remote"
    case "$MYROLE" in
    MASTER_*)

        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA2_*)
        # Setup
        irm_rep_pause $REPLICA2 $REPLICA3
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $REPLICA2 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser 2
        
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA3 force-sync --from $REPLICA2 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Setting agreement.*to force sync" $tmpout
        rlAssertGrep "Deleting schedule.*from agreement" $tmpout

        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser 
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $REPLICA1 $testuser

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR2"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    *)
    esac
    rlPhaseEnd
}
     
# irm_forcesync_pos_0005 - forcesync, replica3 from replica4
#     ipa-replica-manage forcesync --from=$REPLICA4
function irm_forcesync_pos_0005()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_pos_0005: forcesync, replica3 from replica4"
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
        # Setup
        irm_rep_pause $REPLICA4 $REPLICA3
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $REPLICA4 $testuser
        irm_userchk $REPLICA4 $testuser
        irm_userchk $REPLICA3 $testuser 2
        
        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync --from $REPLICA4 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Setting agreement.*to force sync" $tmpout
        rlAssertGrep "Deleting schedule.*from agreement" $tmpout

        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser 
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $REPLICA4 $testuser

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR3"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    *)
    esac
    rlPhaseEnd
}
     
# irm_forcesync_pos_0006 - forcesync, replica4 from replica3, remote
#     ipa-replica-manage -H $REPLICA2 forcesync --from=$REPLICA4
function irm_forcesync_pos_0006()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_pos_0006: forcesync, replica3 from replica4, remote"
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
        # Setup
        irm_rep_pause $REPLICA3 $REPLICA4
        testuser="testuser$(date +%H%M%S)"
        irm_useradd $REPLICA3 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser 2
        
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA4 force-sync --from $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Setting agreement.*to force sync" $tmpout
        rlAssertGrep "Deleting schedule.*from agreement" $tmpout

        irm_check_ruv_sync "$MASTER $REPLICA1 $REPLICA2 $REPLICA3 $REPLICA4"
        irm_userchk $MASTER $testuser 
        irm_userchk $REPLICA1 $testuser
        irm_userchk $REPLICA2 $testuser
        irm_userchk $REPLICA3 $testuser
        irm_userchk $REPLICA4 $testuser

        # Cleanup
        irm_userdel $REPLICA4 $testuser

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR3"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        ;;
    *)
    esac
    rlPhaseEnd
}
     
# irm_forcesync_neg_0001 - forcesync fail, without --from
#     ipa-replica-manage forcesync 
#     grep "force-sync requires the option --from"
function irm_forcesync_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0001: forcesync fail, without --from"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "force-sync requires the option --from" $tmpout

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

# irm_forcesync_neg_0002 - forcesync fail, without --from, remote
#     ipa-replica-manage -H $REPLICA1 forcesync 
#     grep "force-sync requires the option --from"
function irm_forcesync_neg_0002()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0002: forcesync fail, without --from, remote"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 force-sync > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "force-sync requires the option --from" $tmpout

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

# irm_forcesync_neg_0003 - forcesync fail, from self
#    ipa-replica-manage forcesync --from=$(hostname)
function irm_forcesync_neg_0003()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0003: forcesync fail, from self"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync --from $(hostname) > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$(hostname)' has no replication agreement for '$(hostname)'" $tmpout

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

# irm_forcesync_neg_0004 - forcesync fail, from self, remote
#    ipa-replica-manage -H $REPLICA4 forcesync --from=$(hostname)
function irm_forcesync_neg_0004()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0004: forcesync fail, from self, remote"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 force-sync --from $REPLICA1 > $tmpout 2>&1" 1
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

# irm_forcesync_neg_0005 - forcesync fail, from non-existent replica
#    ipa-replica-manage forcesync --from=dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_forcesync_neg_0005()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0005: forcesync fail, from non-existent replica"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync --from dne.$DOMAIN > $tmpout 2>&1" 1
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

# irm_forcesync_neg_0006 - forcesync fail, from non-existent replica, remote
#    ipa-replica-manage -H $REPLICA2 forcesync --from=dne.$DOMAIN
#    grep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'"
function irm_forcesync_neg_0006()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0006: forcesync fail, from non-existent replica, remote"
    case "$MYROLE" in
    MASTER_*)
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA1 force-sync --from dne.$DOMAIN > $tmpout 2>&1" 1
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

# irm_forcesync_neg_0007 - forcesync fail, with no agreement
#    ipa-replica-manage del $REPLICA1
#    ipa-replica-manage forcesync --from=$REPLICA1
#    grep "some error?"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
function irm_forcesync_neg_0007()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0007: forcesync fail, with no agreement"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT del $REPLICA1"

        # Test
        rlRun "ipa-replica-manage $PWOPT force-sync --from $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for '$REPLICA1'" $tmpout


        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"

        # Cleanup
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

# irm_forcesync_neg_0008 - forcesync fail, with no agreement, remote
#    ipa-replica-manage del $REPLICA1
#    ipa-replica-manage -H $MASTER forcesync --from=$REPLICA1
#    grep "some error?"
#    irm_uninstall $REPLICA1
#    irm_install $REPLICA1 $MASTER
function irm_forcesync_neg_0008()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_forcesync_neg_0008: forcesync fail, with no agreement, remote"
    case "$MYROLE" in
    MASTER_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT del $REPLICA1"

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"

        # Cleanup
        irm_uninstall 
        irm_install $MASTER

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR1"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"

        # Test
        rlRun "ipa-replica-manage $PWOPT -H $MASTER force-sync --from $REPLICA1 > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for '$REPLICA1'" $tmpout

        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
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
