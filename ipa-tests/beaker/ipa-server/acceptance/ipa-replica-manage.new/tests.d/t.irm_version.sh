irm_version_pos_0001()
{
    tmpout=/tmp/test_${FUNCNAME}.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlPhaseStartTest "irm_version_pos_0001 - version"
    case "$MYROLE" in
    MASTER_*)
        rlRun "ipa-replica-manage --version > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$IRMVERSION" $tmpout

        rlRun "rhts-sync-set -s '$TESTCOUNT.$FUNCNAME.0' -m $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.4' $MY_BR4"
        ;;
    REPLICA1_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"

        rlRun "ipa-replica-manage --version > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$IRMVERSION" $tmpout

        rlRun "rhts-sync-set -s   '$TESTCOUNT.$FUNCNAME.1' -m $MY_BR1"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.4' $MY_BR4"
        ;;
    REPLICA2_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"

        rlRun "ipa-replica-manage --version > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$IRMVERSION" $tmpout

        rlRun "rhts-sync-set -s   '$TESTCOUNT.$FUNCNAME.2' -m $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.4' $MY_BR4"
        ;;
    REPLICA3_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"

        rlRun "ipa-replica-manage --version > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$IRMVERSION" $tmpout

        rlRun "rhts-sync-set -s   '$TESTCOUNT.$FUNCNAME.3' -m $MY_BR3"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.4' $MY_BR4"
        ;;
    REPLICA4_*)
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.0' $MY_BM"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.1' $MY_BR1"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.2' $MY_BR2"
        rlRun "rhts-sync-block -s '$TESTCOUNT.$FUNCNAME.3' $MY_BR3"

        rlRun "ipa-replica-manage --version > $tmpout 2>&1"
        rlRun "cat $tmpout"
        rlAssertGrep "$IRMVERSION" $tmpout

        rlRun "rhts-sync-set -s   '$TESTCOUNT.$FUNCNAME.4' -m $MY_BR4"
        ;;
    *)
    esac
    rlPhaseEnd
}
