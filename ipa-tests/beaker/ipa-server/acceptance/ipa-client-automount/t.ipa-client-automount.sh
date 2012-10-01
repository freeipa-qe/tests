#!/bin/bash
######################################################
# test suite  : ipa-client-automount
# description : IPA client side tool ipa-client-automount test
# created by  : Yi Zhang (yzhang@redhat.com)
# created date: Thu Sep 20 14:10:03 PDT 2012
######################################################

. ./lib.clientautomount.sh

hostname=`hostname`
domain=`hostname -d`
realm="YZHANG.REDHAT.COM"
hostPrinciple="host/${hostname}@${realm}"
automountlocationName="yztest001"
suffix="dc=yzhang,dc=redhat,dc=com"
ipaServer="f17apple.yzhang.redhat.com"

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
    install_without_user_interruption
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

######################
# test set           #
######################
clientautomount_script_install_option_combinations()
{
    install_as_non_root     # negative test
    install_with_no_option_used # use DNS _SRV_ record auto discovery
    install__no_sssd            # use DNS _SRV_ record auto discovery
    
    install_option__help        # just check help message
    install_check_man_page      # similar to check help message

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
basic_autofs_functional_test(){
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

add_direct_map(){
    rlPhaseStartTest "autofs functional test: add direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_into_ipa
        verify_direct_map
    rlPhaseEnd
}

add_direct_map_using_wild_card(){
    rlPhaseStartTest "autofs functional test: add direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_using_wild_card_into_ipa
        verify_direct_map
    rlPhaseEnd
}

modify_direct_map(){
    rlPhaseStartTest "autofs functional test: modify direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_into_ipa
        modify_existing_direct_map
        verify_direct_map
    rlPhaseEnd
}

delete_direct_map(){
    rlPhaseStartTest "autofs functional test: delete direct map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_direct_map_into_ipa
        delete_existing_direct_map
        verify_direct_map
    rlPhaseEnd
}

add_indirect_map(){
    rlPhaseStartTest "autofs functional test: add indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_into_ipa
        verify_indirect_map
    rlPhaseEnd
}

add_direct_map_using_wild_card(){
    rlPhaseStartTest "autofs functional test: add indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_using_wild_card_into_ipa
        verify_indirect_map
    rlPhaseEnd
}

modify_direct_map(){
    rlPhaseStartTest "autofs functional test: modify indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_into_ipa
        modify_existing_indirect_map
        verify_indirect_map
    rlPhaseEnd
}

delete_direct_map(){
    rlPhaseStartTest "autofs functional test: delete indirect map [$current_serverEnv] + [$current_nfsConfiguration]"
        setup_server_env
        setup_nfs
        add_indirect_map_into_ipa
        delete_existing_indirect_map
        verify_indirect_map
    rlPhaseEnd
}

