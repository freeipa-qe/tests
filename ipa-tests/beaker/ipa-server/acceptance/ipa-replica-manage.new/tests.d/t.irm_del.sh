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
    testuser1="testuser1.$FUNCNAME"
    testuser2="testuser2.$FUNCNAME"
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_pos_0001: del, replica4"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA3_*)
        # Setup
        irm_useradd $REPLICA3 $testuser1
        irm_userchk $REPLICA4 $testuser1

        # Test 1
        rlRun "ipa-replica-manage $PWOPT del $REPLICA4 -f > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Deleted replication agreement from '$REPLICA3' to '$REPLICA4'" $tmpout
        rlRun "ipa-replica-manage $PWOPT list $REPLICA3 > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertNotGrep "$REPLICA4" $tmpout
        irm_userdel $REPLICA3 $testuser1
        irm_useradd $REPLICA3 $testuser2
        irm_userchk $REPLICA3 $testuser1 2

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR4"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR3"

        # Test 2
        irm_userchk $REPLICA4 $testuser1
        irm_userchk $REPLICA4 $testuser2 2

        # Cleanup
        irm_uninstall
        irm_install $REPLICA3
        irm_userdel $REPLICA4 $testuser1
        irm_userdel $REPLICA4 $testuser2

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR4"
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
    testuser1="testuser1.$FUNCNAME"
    testuser2="testuser2.$FUNCNAME"
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_pos_0002: del, replica4, remote"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"

        # Test 2
        irm_userchk $REPLICA1 $testuser1
        irm_userchk $REPLICA1 $testuser2 2

        # Cleanup
        irm_uninstall
        irm_install $MASTER
        irm_userdel $REPLICA1 $testuser2

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR1"
        ;;
    REPLICA2_*)
        # Setup
        irm_useradd $MASTER $testuser1
        irm_userchk $REPLICA1 $testuser1

        # Test 1
        rlRun "ipa-replica-manage $PWOPT -H $MASTER del $REPLICA1 -f > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "Deleted replication agreement from '$MASTER' to '$REPLICA1'" $tmpout
        rlRun "ipa-replica-manage $PWOPT list $MASTER > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertNotGrep "$REPLICA1" $tmpout
        irm_userdel $MASTER $testuser1
        irm_userchk $MASTER $testuser1 2
        irm_useradd $MASTER $testuser2

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1'  $MY_BR1"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    *)
    esac
    rlPhaseEnd
}

# irm_del_neg_0001 - del fail, with disconnected agreement
#    ipa-replica-manage disconnect $REPLICA2 $REPLICA2
#    ipa-replica-manage del $REPLICA4
#    irm_bugcheck_826677
#    ipa-replica-manage list $REPLICA2|grep $REPLICA3 #fail
#    ipa-replica-manage connect $REPLICA3 $REPLICA4
function irm_del_neg_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_del_neg_0001: del fail, with disconnected agreement [BZ826677]"
    case "$MYROLE" in
    MASTER_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
        ;;
    REPLICA2_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA2 $REPLICA3"
        
        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1'  $MY_BR3"

        # Cleanup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA2 $REPLICA3"
        rlRun "ipactl stop"
        rlRun "ipactl start"
        rlRun "ssh $REPLICA3 \"ipactl stop\""
        rlRun "ssh $REPLICA3 \"ipactl start\""
        rlRun "ssh $REPLICA3 \"ipa-replica-manage $PWOPT re-initialize --from $REPLICA2\""

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.2' -m $MY_BR2"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"

        # Test
        rlRun "ipa-replica-manage $PWOPT del $REPLICA4 -f > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        irm_bugcheck_826677 $tmpout
        rlRun "ipa-replica-manage $PWOPT list $REPLICA2 > $tmpout 2>&1"
        rlAssertNotGrep "$REPLICA3" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
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
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BR2"
        ;;
    REPLICA2_*)
        # Setup
        rlRun "ipa-replica-manage $PWOPT disconnect $REPLICA2 $REPLICA3"
        
        # Test
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA3 del $REPLICA4 -f > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        irm_bugcheck_826677 $tmpout
        rlRun "ipa-replica-manage $PWOPT list $REPLICA2 > $tmpout 2>&1"
        rlAssertNotGrep "$REPLICA3" $tmpout

        # Cleanup
        rlRun "ipa-replica-manage $PWOPT connect $REPLICA2 $REPLICA3"
        rlRun "ipactl stop"
        rlRun "ipactl start"
        rlRun "ssh $REPLICA3 \"ipactl stop\""
        rlRun "ssh $REPLICA3 \"ipactl start\""
        rlRun "ssh $REPLICA3 \"ipa-replica-manage -p $ADMINPW re-initialize --from $REPLICA2\""

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
        rlRun "ipactl stop"
        rlRun "ipactl start"
        rlRun "ipa-replica-manage $PWOPT re-initialize --from $REPLICA1"
        rlRun "echo yes|ipa-replica-manage $PWOPT del $REPLICA1 -f -c"
        rlRun "ipa-replica-manage $PWOPT del $REPLICA1 -f > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for '$REPLICA1'" $tmpout
        
        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0'  $MY_BM"

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
        rlRun "ipactl stop"
        rlRun "ipactl start"
        rlRun "ipa-replica-manage $PWOPT re-initialize --from $REPLICA1"
        rlRun "echo yes|ipa-replica-manage $PWOPT del $REPLICA1 -f -c"

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR1"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR2"

        irm_uninstall
        irm_install $MASTER

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.2' -m $MY_BR1"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"

        rlRun "ipa-replica-manage $PWOPT -H $MASTER del $REPLICA1 -f > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for '$REPLICA1'" $tmpout
        
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
        rlRun "ipa-replica-manage $PWOPT del dne.$DOMAIN -f > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$MASTER' has no replication agreement for 'dne.$DOMAIN'" $tmpout

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
        rlRun "ipa-replica-manage $PWOPT -H $REPLICA4 del dne.$DOMAIN -f > $tmpout 2>&1" 1
        rlRun "cat $tmpout"
        rlAssertGrep "'$REPLICA4' has no replication agreement for 'dne.$DOMAIN'" $tmpout

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

