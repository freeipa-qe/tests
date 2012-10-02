#!/bin/bash
######################################################
# test suite  : ipa-client-automount
# description : IPA client side tool ipa-client-automount test
# created by  : Yi Zhang (yzhang@redhat.com)
# created date: Thu Sep 20 14:10:03 PDT 2012
######################################################

. ./d.clientautomount.sh
. ./lib.clientautomount.sh

#check_autofs_sssd_configuration
#check_autofs_no_sssd_configuration

######################
# test suite         #
######################
ipaclientautomount()
{
    clientautomount_script_install_and_uninstall
    clientautomount_script_install_option_combinations
    clientautomount_autofs_functional_test
} #ipaclientautomount 

######################
# test set           #
######################
clientautomount_script_install_and_uninstall()
{
    # simple install and uninstall case
    install_without_user_interruption   # such case will be covered by test set: clientautomount_script_install_option_combinations
    install_with_user_interruption      # negative test case
    install_while_communication_blocked # negative test case
    install_then_uninstall

    # re-install test cases: one install-uninstall-reinstall cycle
    reinstall_after_uninstall_use_same_ipa_server_and_automount_location
    reinstall_after_uninstall_use_different_ipa_server_and_automount_location
    reinstall_without_uninstall_use_same_ipa_server_and_automount_location
    reinstall_without_uninstall_use_different_ipa_server_and_automount_location

    # re-install test case: 
    #       (1) more than one install-uninstall-reinstall cycle 
    #       (2) use same & different ipa server and location information
    repeat_install_uninstall_end_with_uninstall_use_same_ipa_server_and_automount_location
    repeat_install_uninstall_end_with_install_use_same_ipa_server_and_automount_location

    repeat_install_uninstall_end_with_uninstall_use_different_ipa_server_same_automount_location
    repeat_install_uninstall_end_with_uninstall_use_same_ipa_server_different_automount_location

    repeat_install_uninstall_end_with_install_use_different_ipa_server_same_automount_location
    repeat_install_uninstall_end_with_install_use_same_ipa_server_different_automount_location

}

install_without_user_interruption()
{
    rlPhaseStartTest "install without user interruption"
        rlPass "this scenario will be covered by test set: clientautomount_script_install_option_combinations, there is no need to test here"
    rlPhaseEnd
}

install_with_user_interruption()
{
    rlPhaseStartTest "negative test: user interrupt installation"
        rlFail "not ready"
    rlPhaseEnd
}

install_while_communication_blocked()
{
    rlPhaseStartTest "negative test: ports blocked while install"
        rlFail "not ready"
    rlPhaseEnd
}

install_then_uninstall()
{
    rlPhaseStartTest "install then uninstall"
        # install
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        # uninstall
        rlRun "ipa-client-install --uninstall -U"
        check_autofs_sssd_configuration "not_configured"
    clean_up_installation
    rlPhaseEnd
}

reinstall_after_uninstall_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "reinstall after uninstall: use same ipa server and automount location"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-install --uninstall -U"
        check_autofs_sssd_configuration "not_configured"

        # reinstall after install-uninstall cycle
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    clean_up_installation
    rlPhaseEnd
}

reinstall_after_uninstall_use_different_ipa_server_and_automount_location()
{
    rlPhaseStartTest "reinstall after uninstall: use different ipa server, use same automount location"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-install --uninstall -U"
        check_autofs_sssd_configuration "not_configured"

        # reinstall after install-uninstall cycle
        currentIPAServer=$ipaServerReplica
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    clean_up_installation
    rlPhaseEnd
}

reinstall_without_uninstall_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "reinstall without uninstall first: use same ipa server and automount location"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 1 "reinstall without uninstall first should fail"
    clean_up_installation
    rlPhaseEnd
}

reinstall_without_uninstall_use_different_ipa_server_and_automount_location()
{
    rlPhaseStartTest "reinstall without uninstall first: use different ipa server and automount location"
        currentIPAServer=$ipaServerMaster
        currentLocation=$automountLocationA
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        currentIPAServer=$ipaServerReplica
        currentLocation=$automountLocationB
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 1 "reinstall without uninstall first should fail"
    clean_up_installation
    rlPhaseEnd
}

repeat_install_uninstall_end_with_uninstall_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "repeated install and uninstall: last action=Uninstall: use same set of ipa server and automount location"
        currentIPAServer=$ipaServerMaster
        currentLocation=$automountLocationA
        local counter=0
        while [ $counter -lt 2 ];do
            rlLog "repeat install and uninstall, cycle [$counter]";
            rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
            check_autofs_sssd_configuration "configured"
            rlRun "ipa-client-automount --uninstall -U"
            check_autofs_sssd_configuration "not_configured"
            counter=$((counter + 1))
        done
    clean_up_installation
    rlPhaseEnd
}

repeat_install_uninstall_end_with_install_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "repeated install and uninstall: last action=Install: use same ipa server server and automount location"
        local counter=0
        while [ $counter -lt 2 ];do
            rlLog "repeat install and uninstall, cycle [$counter]";
            rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
            rlRun "ipa-client-automount --uninstall -U"
            counter=$((counter + 1))
        done
        rlLog "out of the repeat cycle, last action: install";
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    clean_up_installation
    rlPhaseEnd
}

repeat_install_uninstall_end_with_uninstall_use_different_ipa_server_same_automount_location()
{
    rlPhaseStartTest "repeated install and uninstall: last action=Uninstall, use different ipa server, use same automount location"
        currentIPAServer=$ipaServerMaster
        while [ $counter -lt 2 ];do
            rlLog "repeat install and uninstall, cycle [$counter]";
            rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
            rlRun "ipa-client-automount --uninstall -U"
            counter=$((counter + 1))
        done

        rlLog "out of repeat cycle, last action: uninstall"
        currentIPAServer=$ipaServerReplica
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --uninstall -U"
        check_autofs_sssd_configuration "not_configured"
    clean_up_installation
    rlPhaseEnd
}

repeat_install_uninstall_end_with_uninstall_use_same_ipa_server_different_automount_location()
{
    rlPhaseStartTest "repeated install and uninstall: last action=Uninstall, use same ipa server, use different automount location"
        currentLocation=$automountLocationA
        while [ $counter -lt 2 ];do
            rlLog "repeat install and uninstall, cycle [$counter]";
            rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
            rlRun "ipa-client-automount --uninstall -U"
            counter=$((counter + 1))
        done

        rlLog "out of repeat cycle, last action: uninstall"
        currentLocation=$automountLocationB
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --uninstall -U"
        check_autofs_sssd_configuration "not_configured"
    clean_up_installation
    rlPhaseEnd
}

repeat_install_uninstall_end_with_install_use_different_ipa_server_same_automount_location()
{
    rlPhaseStartTest "repeated install and uninstall: last action=Install, use same ipa server, use same automount location"
        currentIPAServer=$ipaServerMaster
        while [ $counter -lt 2 ];do
            rlLog "repeat install and uninstall, cycle [$counter]";
            rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
            rlRun "ipa-client-automount --uninstall -U"
            counter=$((counter + 1))
        done

        rlLog "out of repeat cycle, last action: uninstall"
        currentIPAServer=$ipaServerReplica
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    clean_up_installation
    rlPhaseEnd
}

repeat_install_uninstall_end_with_install_use_same_ipa_server_different_automount_location()
{
    rlPhaseStartTest "repeated install and uninstall: last action=Install, use same ipa server, use different automount location"
        currentLocation=$automountLocationA
        while [ $counter -lt 2 ];do
            rlLog "repeat install and uninstall, cycle [$counter]";
            rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
            rlRun "ipa-client-automount --uninstall -U"
            counter=$((counter + 1))
        done

        rlLog "out of repeat cycle, last action: uninstall"
        currentLocation=$automountLocationB
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    clean_up_installation
    rlPhaseEnd
}

######################
# test set           #
######################
clientautomount_script_install_option_combinations()
{
    install_as_non_root     # negative test
    install_with_no_option_used # use DNS _SRV_ record auto discovery
    install__no_sssd            # use DNS _SRV_ record auto discovery
    
    install_option__help        # just check help message

    install_option__server_valid
    install_option__server_invalid
    install_option__location_valid
    install_option__location_invalid

    install_option__server_valid__location_valid     # negative test case
    install_option__server_valid__location_invalid   # negative test case
    install_option__server_invalid__location_valid   # negative test case
    install_option__server_invalid__location_invalid # negative test case

    install_option__server_valid__location_valid__unattended

    install_option__server_valid__no_sssd
    install_option__location_valid__no_sssd
    install_option__server_valid__location_valid__no_sssd
    install_option__server_invalid__location_invalid__no_sssd
}

install_as_non_root()
{
    rlPhaseStartTest "negative test: install as non-root user"
        rlFail "not ready"
    rlPhaseEnd
}

install_with_no_option_used()
{
    rlPhaseStartTest "install: no option used (use DNS _SRV_ auto-discovery)"
        rlFail "not ready"
    rlPhaseEnd
}

install__no_sssd()
{
    rlPhaseStartTest "install with --no-sssd option: no other option used, (use DNS _SRV_ auto-discovery"
        rlFail "not ready"
    rlPhaseEnd
}

install_option__help()
{
    rlPhaseStartTest "install option: check --help or -h : help message"
        local temp=$TmpDir/helpmsg.$RANDOM.txt
        # check option --help
        ipa-client-automount --help > $temp
        if grep "Usage:" $temp 2>&1 > /dev/null
        then
            rlPass "--help does produce usage message"
        else
            rlFail "--help produce no usage message"
        fi

        # check option -h
        ipa-client-automount -h > $temp
        if grep "Usage:" $temp 2>&1 > /dev/null
        then
            rlPass "-h does produce usage message"
        else
            rlFail "-h produce no usage message"
        fi
        rm $temp
    rlPhaseEnd
}

install_option__server_valid()
{
    rlPhaseStartTest "install option single: --server <valid ipa server>"
        rlRun "ipa-client-automount --server=$currentIPAServer"
        ensure_configuration_status "configured"
    rlPhaseEnd
}

install_option__server_invalid()
{
    rlPhaseStartTest "negative test: install option: --server <invalid ipa server>"
        local invalidIPAServer="invalid.$RANCOM.ipa.server.com"
        rlRun "ipa-client-automount --server=$invalidIPAServer" 1 "install should fail if invalid ipa server provided"
        ensure_configuration_status "not_configured"
    rlPhaseEnd
}

install_option__location_valid()
{
    rlPhaseStartTest "install option single: --location <valid automount location>"
        rlRun "ipa-client-automount --location=$currentLocation"
        ensure_configuration_status "configured"
    rlPhaseEnd
}

install_option__location_invalid()
{
    rlPhaseStartTest "negative test: install option single: --location <invalid automount location>"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --location=$invalidLocation"
        ensure_configuration_status "not_configured"
    rlPhaseEnd
}

install_option__server_valid__location_valid()
{
    rlPhaseStartTest "install option combined: --server <valid> --location <valid>"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation"
        ensure_configuration_status "configured"
    rlPhaseEnd
}

install_option__server_valid__location_invalid()
{
    rlPhaseStartTest "install option combined: --server <valid> --location <invalid>"
    rlPhaseEnd
}

install_option__server_invalid__location_valid()
{
    rlPhaseStartTest "negative test: install option combined: --server <invalid> --location <valid>"
        local invalidIPAServer="invalid.$RANCOM.ipa.server.com"
        rlRun "ipa-client-automount --server=$invalidIPAServer --location=$currentLocation"
        ensure_configuration_status "not_configured"
    rlPhaseEnd
}

install_option__server_invalid__location_invalid()
{
    rlPhaseStartTest "negative test: install option combined: --server <invalid> --location <invalid>"
        local invalidIPAServer="invalid.$RANCOM.ipa.server.com"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --server=$invalidIPAServer --location=$invalidLocation"
        ensure_configuration_status "not_configured"
    rlPhaseEnd
}

install_option__server_valid__location_valid__unattended()
{
    rlPhaseStartTest "install option combined: --server <valid> --location <valid> --U (unattended)"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --U"
        ensure_configuration_status "configured"
    rlPhaseEnd
}

install_option__server_valid__no_sssd()
{
    rlPhaseStartTest "install option : --no-sssd + --server <valid>"
        rlRun "ipa-client-automount --no-sssd --server=$currentIPAServer"
        ensure_configuration_status "configured" "no-sssd"
    rlPhaseEnd
}

install_option__location_valid__no_sssd()
{
    rlPhaseStartTest "install option: --no-sssd + --location <valid>"
        rlRun "ipa-client-automount --no-sssd --location=$currentLocation"
        ensure_configuration_status "configured" "no-sssd"
    rlPhaseEnd
}

install_option__server_valid__location_valid__no_sssd()
{
    rlPhaseStartTest "install option: --no-sssd + --server <valid> --location <valid>"
        rlRun "ipa-client-automount --no-sssd --server=$currentIPAServer --location=$currentLocation"
        ensure_configuration_status "configured" "no-sssd"
    rlPhaseEnd
}

install_option__server_invalid__location_invalid__no_sssd()
{
    rlPhaseStartTest "negative test: install option: --no-sssd + --server <invalid> --location <invalid>"
        local invalidIPAServer="invalid.$RANCOM.ipa.server.com"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --no-sssd --server=$invalidIPAServer --location=$invalidLocation"
        ensure_configuration_status "not_configured" "no-sssd"
    rlPhaseEnd
}

######################
# test set           #
######################
clientautomount_autofs_functional_test()
{
    # there will be total 9 environment setup: 
    for serverEnv in "standalone_ipa_dns_nfs combined_ipa_dns_standalone_nfs all_combined"
    do
        for nfsConfiguration in "nfs_v3_non_secure nfs_v4_non_secure nfs_v4_kerberized"
        do
            basic_autofs_functional_test $serverEnf $nfsConfiguration
        done
    done
}

basic_autofs_functional_test()
{
    current_serverEnv=$1
    current_nfsConfiguration=$2
    add_direct_map
    add_disrect_map_using_wild_card
    modify_direct_map
    delete_direct_map
    
    add_indirect_map
    add_indirect_map_using_wild_card
    modify_indirect_map
    delete_indirect_map
}

add_direct_map()
{
    rlPhaseStartTest "autofs functional test: add direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_into_ipa
        verify_direct_map
    rlPhaseEnd
}

add_direct_map_using_wild_card()
{
    rlPhaseStartTest "autofs functional test: add direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_using_wild_card_into_ipa
        verify_direct_map
    rlPhaseEnd
}

modify_direct_map()
{
    rlPhaseStartTest "autofs functional test: modify direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_into_ipa
        modify_existing_direct_map
        verify_direct_map
    rlPhaseEnd
}

delete_direct_map()
{
    rlPhaseStartTest "autofs functional test: delete direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_into_ipa
        delete_existing_direct_map
        verify_direct_map
    rlPhaseEnd
}

add_indirect_map()
{
    rlPhaseStartTest "autofs functional test: add indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_into_ipa
        verify_indirect_map
    rlPhaseEnd
}

add_direct_map_using_wild_card()
{
    rlPhaseStartTest "autofs functional test: add indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_using_wild_card_into_ipa
        verify_indirect_map
    rlPhaseEnd
}

modify_direct_map()
{
    rlPhaseStartTest "autofs functional test: modify indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_into_ipa
        modify_existing_indirect_map
        verify_indirect_map
    rlPhaseEnd
}

delete_direct_map()
{
    rlPhaseStartTest "autofs functional test: delete indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_into_ipa
        delete_existing_indirect_map
        verify_indirect_map
    rlPhaseEnd
}

