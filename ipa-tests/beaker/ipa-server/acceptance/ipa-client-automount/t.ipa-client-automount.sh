#!/bin/bash
######################################################
# test suite  : ipa-client-automount
# description : IPA client side tool ipa-client-automount test
# created by  : Yi Zhang (yzhang@redhat.com)
# created date: Thu Sep 20 14:10:03 PDT 2012
######################################################

. ./d.clientautomount.sh
. ./echoline.sh
. ./lib.clientautomount.sh

#check_autofs_sssd_configuration
#check_autofs_no_sssd_configuration

######################
# test suite         #
######################
ipaclientautomount()
{
    configure_autofs_direct $automountLocationA $currentNFSServer $nfsDir $autofsDir 
    configure_autofs_direct $automountLocationB $currentNFSServer $nfsDir $autofsDir 
    clientautomount_script_install_and_uninstall #done script writing
    clientautomount_script_install_option_combinations # done script writing, need debug in official environment
    clientautomount_autofs_functional_test
    clientautomount_autofs_functional_test_offline
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
    rlPhaseStartTest "ipa-client-automount-001: install without user interruption"
        rlPass "this scenario will be covered by test set: clientautomount_script_install_option_combinations, there is no need to test here"
    rlPhaseEnd
}

install_with_user_interruption()
{
    rlPhaseStartTest "ipa-client-automount-002: negative test user interrupt installation"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_while_communication_blocked()
{
    rlPhaseStartTest "ipa-client-automount-003: negative test ports blocked while install"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_then_uninstall()
{
    rlPhaseStartTest "ipa-client-automount-004: install then uninstall"
        clean_up_automount_installation
        # install
        ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U
        check_autofs_sssd_configuration "configured"
        # uninstall
        rlRun "ipa-client-automount --uninstall -U"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

reinstall_after_uninstall_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-005: reinstall after uninstall, use same ipa server and automount location"
        clean_up_automount_installation
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --uninstall -U"
        check_autofs_sssd_configuration "not_configured"

        # reinstall after install-uninstall cycle
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

reinstall_after_uninstall_use_different_ipa_server_and_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-006: reinstall after uninstall, use different ipa server, use same automount location"
        clean_up_automount_installation
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --uninstall -U"
        check_autofs_sssd_configuration "not_configured"

        # reinstall after install-uninstall cycle
        currentIPAServer=$ipaServerReplica
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

reinstall_without_uninstall_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-007: reinstall without uninstall first, use same ipa server and automount location"
        clean_up_automount_installation
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 1 "reinstall without uninstall first should fail"
    rlPhaseEnd
}

reinstall_without_uninstall_use_different_ipa_server_and_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-008: reinstall without uninstall first, use different ipa server and automount location"
        clean_up_automount_installation
        currentIPAServer=$ipaServerMaster
        currentLocation=$automountLocationA
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        currentIPAServer=$ipaServerReplica
        currentLocation=$automountLocationB
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 1 "reinstall without uninstall first should fail"
    rlPhaseEnd
}

repeat_install_uninstall_end_with_uninstall_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-009: repeated install and uninstall, last action=Uninstall, use same set of ipa server and automount location"
        clean_up_automount_installation
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
    rlPhaseEnd
}

repeat_install_uninstall_end_with_install_use_same_ipa_server_and_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-010: repeated install and uninstall, last action=Install, use same ipa server server and automount location"
        clean_up_automount_installation
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
    rlPhaseEnd
}

repeat_install_uninstall_end_with_uninstall_use_different_ipa_server_same_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-011: repeated install and uninstall, last action=Uninstall, use different ipa server, use same automount location"
        clean_up_automount_installation
        local counter=0
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
    rlPhaseEnd
}

repeat_install_uninstall_end_with_uninstall_use_same_ipa_server_different_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-012: repeated install and uninstall, last action=Uninstall, use same ipa server, use different automount location"
        clean_up_automount_installation
        local counter=0
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
    rlPhaseEnd
}

repeat_install_uninstall_end_with_install_use_different_ipa_server_same_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-013: repeated install and uninstall, last action=Install, use same ipa server, use same automount location"
        clean_up_automount_installation
        local counter=0
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
    rlPhaseEnd
}

repeat_install_uninstall_end_with_install_use_same_ipa_server_different_automount_location()
{
    rlPhaseStartTest "ipa-client-automount-014: repeated install and uninstall, last action=Install, use same ipa server, use different automount location"
        clean_up_automount_installation
        currentLocation=$automountLocationA
        local counter=0
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
    rlPhaseStartTest "ipa-client-automount-015: negative test install as non-root user"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_with_no_option_used()
{
    rlPhaseStartTest "ipa-client-automount-016: simple install, no option used (use DNS _SRV_ auto-discovery)"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install__no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-017: install with --no-sssd option, no other option used, (use DNS _SRV_ auto-discovery"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_option__help()
{
    rlPhaseStartTest "ipa-client-automount-018: install option, check --help or -h , help message"
        clean_up_automount_installation
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
    rlPhaseStartTest "ipa-client-automount-019: install option single, --server <valid ipa server>"
        clean_up_automount_installation
        currentLocation="default"
        rlRun "ipa-client-automount --server=$currentIPAServer -U" 0 "install should success as valid ipa server used"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__server_invalid()
{
    rlPhaseStartTest "ipa-client-automount-020: negative test install option, --server <invalid ipa server>"
        clean_up_automount_installation
        currentLocation="default"
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        rlRun "ipa-client-automount --server=$invalidIPAServer -U" 1 "install should fail if invalid ipa server provided"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__location_valid()
{
    rlPhaseStartTest "ipa-client-automount-021: install option single, --location <valid automount location>"
        clean_up_automount_installation
        rlRun "ipa-client-automount --location=$currentLocation -U" 0 "install should success as valid location used"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__location_invalid()
{
    rlPhaseStartTest "ipa-client-automount-022: negative test install option single, --location <invalid automount location>"
        clean_up_automount_installation
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --location=$invalidLocation -U" 1 "install should ail as invalid location used"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_valid__location_valid()
{
    rlPhaseStartTest "ipa-client-automount-023: install option combined, --server <valid> --location <valid>"
        clean_up_automount_installation
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__server_valid__location_invalid()
{
    clean_up_automount_installation
    rlPhaseStartTest "ipa-client-automount-024: install option combined, --server <valid> --location <invalid>"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$invalidLocation -U" 1 "invalid location used, install should fail"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_invalid__location_valid()
{
    rlPhaseStartTest "ipa-client-automount-025: negative test install option combined, --server <invalid> --location <valid>"
        clean_up_automount_installation
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        rlRun "ipa-client-automount --server=$invalidIPAServer --location=$currentLocation -U" 1 "install should fail as invalid ipa server used"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_invalid__location_invalid()
{
    rlPhaseStartTest "ipa-client-automount-026: negative test install option combined, --server <invalid> --location <invalid>"
        clean_up_automount_installation
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --server=$invalidIPAServer --location=$invalidLocation -U" 1 "install should fail as invalid location and ipa server used"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_valid__location_valid__unattended()
{
    rlPhaseStartTest "ipa-client-automount-027: install option combined, --server <valid> --location <valid> --U (unattended)"
        clean_up_automount_installation
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__server_valid__no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-028: install option, --no-sssd + --server <valid>"
        clean_up_automount_installation
        currentLocation="default"
        rlRun "ipa-client-automount --no-sssd --server=$currentIPAServer -U"
        LDAP_URI="LDAP_URI=ldap://${currentIPAServer}"
        check_autofs_no_sssd_configuration "configured"
        LDAP_URI="" #reset
    rlPhaseEnd
}

install_option__location_valid__no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-029: install option, --no-sssd + --location <valid>"
        clean_up_automount_installation
        rlRun "ipa-client-automount --no-sssd --location=$currentLocation -U"
        LDAP_URI="LDAP_URI=ldap:///${suffix}"
        check_autofs_no_sssd_configuration "configured"
        LDAP_URI="" #reset
    rlPhaseEnd
}

install_option__server_valid__location_valid__no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-030: install option, --no-sssd + --server <valid> --location <valid>"
        clean_up_automount_installation
        rlRun "ipa-client-automount --no-sssd --server=$currentIPAServer --location=$currentLocation -U"
        LDAP_URI="LDAP_URI=ldap://${currentIPAServer}"
        check_autofs_no_sssd_configuration "configured"
        LDAP_URI="" #reset
    rlPhaseEnd
}

install_option__server_invalid__location_invalid__no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-031: negative test install option, --no-sssd + --server <invalid> --location <invalid>"
        clean_up_automount_installation
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --no-sssd --server=$invalidIPAServer --location=$invalidLocation -U" 1 "install should fail as invalid location used"
        check_autofs_no_sssd_configuration "not_configured"
    rlPhaseEnd
}

######################
# test set           #
######################
clientautomount_autofs_functional_test()
{
    # there will be total 9 environment setup: 
    change_autofs_debug_level
#    for current_serverEnv in standalone_ipa_dns_nfs combined_ipa_dns_standalone_nfs all_combined
#    do
        current_serverEnv="all_combined"
        #for current_nfsConfiguration in nfs_v3_non_secure nfs_v4_non_secure nfs_v4_kerberized
        for current_nfsConfiguration in nfs_v4_non_secure nfs_v4_kerberized
        do
            #current_serverEnv="all_combined"
            #current_nfsConfiguration="nfs_v3_non_secure"
            #current_serverEnv="combined_ipa_dns_standalone_nfs"
            #current_nfsConfiguration="nfs_v3_non_secure"
            #current_nfsConfiguration="nfs_v4_non_secure"
            #current_nfsConfiguration="nfs_v4_kerberized"
            setup_testing_environment $current_serverEnv $current_nfsConfiguration
            basic_autofs_functional_test
        done
#    done
}

setup_testing_environment()
{
    local serverEnv=$1
    local nfsConfiguration=$2
    rlPhaseStartSetup "autofs functional test env setup, [$serverEnv] - [$nfsConfiguration]"
        echo "::::::: configuration: server [$serverEnv], nfs [$nfsConfiguration] :::::::"
        setup_server $serverEnv
        setup_nfs $nfsConfiguration
        echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    rlPhaseEnd
}

setup_server()
{
    local serverEnv=$1
    if [ "$serverEnv" = "standalone_ipa_dns_nfs" ];then
        currentIPAServer=$ipaServerMaster
        currentDNSServer=$dnsServer
        currentNFSServer=$ipaServerReplica
    elif [ "$serverEnv" = "combined_ipa_dns_standalone_nfs" ];then
        currentIPAServer=$ipaServerMaster
        currentDNSServer=$ipaServerMaster
        currentNFSServer=$nfsServer 
    elif [ "$serverEnv" = "all_combined" ];then
        currentIPAServer=$ipaServerMaster
        currentDNSServer=$ipaServerMaster
        currentNFSServer=$ipaServerMaster
    fi
    echo "ipa server : [$currentIPAServer]"
    echo "dns server : [$currentDNSServer]"
    echo "nfs server : [$currentNFSServer]"
}

setup_nfs()
{
    local $nfsConfiguration=$1
    local nfsConf=$TmpDir/nfs.$RANDOM.conf
    local configuration=""
    if [ "$nfsConfiguration" = "nfs_v3_non_secure" ];then
        echo "NFS v3"
        configuration=$nfsConfiguration_NonSecure
        currentNFSMountOption="$nfsMountType_nfs3"
        automountKey_mount_option="$automountKey_non_secure_options"
        #configure_nfs_non_secure "$configuration"
        #echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
        #service nfs restart
    elif [ "$nfsConfiguration" = "nfs_v4_non_secure" ];then
        echo "NFS v4" 
        currentNFSServer=$NFS_IPA
        configuration=$nfsConfiguration_NonSecure
        currentNFSMountOption="$nfsMountType_nfs4"
        automountKey_mount_option="$automountKey_non_secure_options"
        #configure_nfs_non_secure "$configuration"
        #echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
        #service nfs restart
    elif [ "$nfsConfiguration" = "nfs_v4_kerberized" ];then
        echo "NFS v4 + kerberos"
        currentNFSServer=$ipaServerReplica
        configuration="$nfsConfiguration_Kerberized"
        currentNFSMountOption="$nfsMountType_kerberized"
        automountKey_mount_option="$automountKey_krb5_options"
        #echo "$configuration" > $nfsConf
        #echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
    fi
}

basic_autofs_functional_test()
{
    KinitAsAdmin
    rlLog "clean up ipa-client-automount"
    ipa-client-automount --uninstall -U 

    test_direct_map
    test_indirect_map
    test_indirect_map_using_wildcard

    test_direct_map_use_no_sssd
    test_indirect_map_use_no_sssd
    test_indirect_map_using_wildcard_use_no_sssd

    rlLog "clean up ipa-client-automount"
    ipa-client-automount --uninstall -U
}

test_direct_map()
{
    rlPhaseStartTest "ipa-client-automount-032: autofs functional test direct map with sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Direct_use_sssd_${RANDOM}"
        currentLocation=$automounLocation
        autofsTopDir="/ipashare_${RANDOM}"
        autofsSubDir="public_${RANDOM}"
        autofsDir="$autofsTopDir/$autofsSubDir"
        rlLog "config autofs direct mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_direct $currentLocation $currentNFSServer $nfsDir $autofsDir 
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 0 "setup ipa client automount"
        restart_sssd
        restart_autofs
        verify_autofs_mounting 
        clean_up_indirect_map_and_umount $currentLocation
        clean_up_automount_installation
    rlPhaseEnd
}

test_indirect_map()
{
    rlPhaseStartTest "ipa-client-automount-033: autofs functional test indirect map with sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_use_sssd_${RANDOM}"
        currentLocation=$automounLocation
        autofsTopDir="/ipashare_${RANDOM}"
        autofsSubDir="public_${RANDOM}"
        autofsDir="$autofsTopDir/$autofsSubDir"
        rlLog "config autofs indirect mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_indirect $currentLocation $currentNFSServer $nfsDir $autofsDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 0 "setup ipa client automount"
        restart_sssd
        restart_autofs
        verify_autofs_mounting 
        clean_up_indirect_map_and_umount $currentLocation
        clean_up_automount_installation   
    rlPhaseEnd
}


test_indirect_map_using_wildcard()
{
    rlPhaseStartTest "ipa-client-automount-034: autofs functional test add indirect map using wild card and with sssd[$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_use_sssd_${RANDOM}"
        currentLocation=$automounLocation
        autofsTopDir="/ipashare_${RANDOM}"
        autofsDir="$autofsTopDir/$nfsExportSubDir"
        rlLog "config autofs indirect mount use wildcard (*,&):"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsExportTopDir/&] [autofs local dir: $autofsTopDir/*]"
        configure_autofs_indirect_use_wildcard $currentLocation $currentNFSServer $nfsExportTopDir $autofsTopDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 0 "setup ipa client automount"
        restart_sssd
        restart_autofs
        verify_autofs_mounting 
        clean_up_indirect_map_and_umount $currentLocation 
        clean_up_automount_installation
    rlPhaseEnd
}

test_direct_map_use_no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-035: autofs functional test direct map use no sssed [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Direct_no_sssd_${RANDOM}"
        currentLocation=$automounLocation
        autofsTopDir="/ipashare_${RANDOM}"
        autofsSubDir="public_${RANDOM}"
        autofsDir="$autofsTopDir/$autofsSubDir"
        rlLog "config autofs direct mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_direct $currentLocation $currentNFSServer $nfsDir $autofsDir 
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --no-sssd -U" 0 "setup ipa client automount"
        restart_autofs
        verify_autofs_mounting
        clean_up_indirect_map_and_umount $currentLocation
        clean_up_automount_installation
    rlPhaseEnd
}

test_indirect_map_use_no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-036: autofs functional test indirect map use no sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_no_sssd_${RANDOM}"
        currentLocation=$automounLocation
        autofsTopDir="/ipashare_${RANDOM}"
        autofsSubDir="public_${RANDOM}"
        autofsDir="$autofsTopDir/$autofsSubDir"
        rlLog "config autofs indirect mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_indirect $currentLocation $currentNFSServer $nfsDir $autofsDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --no-sssd -U" 0 "setup ipa client automount"
        restart_autofs
        verify_autofs_mounting 
        clean_up_indirect_map_and_umount $currentLocation 
        clean_up_automount_installation   
    rlPhaseEnd
}


test_indirect_map_using_wildcard_use_no_sssd()
{
    rlPhaseStartTest "ipa-client-automount-037: autofs functional test add indirect map using wild card and no sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_no_sssd_${RANDOM}"
        currentLocation=$automounLocation
        autofsTopDir="/ipashare_${RANDOM}"
        autofsSubDir="$nfsExportSubDir"
        autofsDir="$autofsTopDir/$autofsSubDir"
        rlLog "config autofs indirect mount use wildcard (*,&):"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsExportTopDir/&] [autofs local dir: $autofsTopDir/*]"
        configure_autofs_indirect_use_wildcard $currentLocation $currentNFSServer $nfsExportTopDir $autofsTopDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --no-sssd -U" 0 "setup ipa client automount: --server=$currentIPAServer --location=$currentLocation --no-sssd -U"
        restart_autofs
        verify_autofs_mounting 
        clean_up_indirect_map_and_umount $currentLocation 
        clean_up_automount_installation
    rlPhaseEnd
}

clientautomount_autofs_functional_test_offline()
{
    KinitAsAdmin
    rlLog "clean up ipa-client-automount"
    ipa-client-automount --uninstall -U

    #Checking existence of ipa-admintools
    rpm -q ipa-admintools
    if [ $? -eq 0 ] ; then
      rlLog "ipa-admintools is installed"
    else
      #rlRun "yum install ipa-admintools -y" 0 "Installing ipa-admintools"
      rlRun "yum install ipa-admintools -y --nogpg" 0 "Installing ipa-admintools"
    fi

    rlRun "echo \"mkdir -p /ipashare/share/\" > $TmpDir/local.sh" 0
    rlRun "echo \"echo mounted_file > /ipashare/share/mount.txt\" >> $TmpDir/local.sh" 0
    rlRun "echo \"cp /etc/exports /etc/exports.old\" >> $TmpDir/local.sh" 0
    text="/ipashare/share/\ *\(rw,async,fsid=0,no_subtree_check,no_root_squash\)"
    rlRun "echo \"echo $text > /etc/exports\" >> $TmpDir/local.sh" 0
    rlRun "echo \"service nfs restart\">> $TmpDir/local.sh" 0
    rlRun "chmod +x $TmpDir/local.sh"
    rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Creating shared directory and file on $MASTER"

    test_direct_map_offline
    test_indirect_map_offline
    test_indirect_map_using_wildcard_offline

    rlRun "echo \"rm -rf /ipashare/share/\" > $TmpDir/local.sh" 0
    rlRun "echo \"cp /etc/exports.old /etc/exports\" >> $TmpDir/local.sh" 0
    rlRun "echo \"service nfs restart\">> $TmpDir/local.sh" 0
    rlRun "chmod +x $TmpDir/local.sh"
    rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Removing shared directory and file on $MASTER"

    rlLog "clean up ipa-client-automount"
    ipa-client-automount --uninstall -U
}

test_direct_map_offline()
{
    rlPhaseStartTest "ipa-client-automount-038: autofs functional test offline -- direct map"
        local automounLocation="direct_map_${RANDOM}"
        currentLocation=$automounLocation

        #Adding direct automount map and installing ipa-client-automount 
        rlRun "ipa automountlocation-add $currentLocation" 0 "Added automount localtion"
        rlRun "ipa automountkey-add $currentLocation auto.direct --key=/$currentLocation/ --info=\"-rw,soft,rsize=8192,wsize=8192  $MASTER:/ipashare/share/\"" 0 "Added automountkey"
        rlRun "ipa automountlocation-tofiles $currentLocation" 0 "automount direct map info"
        rlRun "ipa-client-automount --server=$MASTER --location=$currentLocation -U" 0 "setup ipa client automount"
        rlRun "service autofs restart" 0 "Restarting automount to fetch updated configuration"

        #Mounting the localtion added by direct automount map

        rlRun "cd /$currentLocation/;pwd" 0 "mounting the localtion specified in automount direct map"
        rlRun "cat mount.txt |grep mounted_file" 0 "verifying the content of mounted file"
        rlRun "cd; umount /$currentLocation/" 0 "unmount the location specified by automount direct map"

	#Stoping ipa sevice on $MASTER
        stop_ipa_master

        sleep 10
        rlRun "cd /$currentLocation/;pwd" 0 "mounting the localtion specified in automount direct map"
        rlRun "cat mount.txt |grep mounted_file" 0 "verifying the content of mounted file"
        rlRun "cd; umount /$currentLocation/" 0 "unmount the location specified by automount direct map"

	#Starting ipa sevice on $MASTER
        start_ipa_master

        #clean-up
        rlRun "ipa-client-automount --uninstall -U" 0 "uninstall ipa client automount"
        rlRun "service autofs restart" 0 "Restarting automount to fetch updated configuration"
        rlRun "ipa automountkey-del $currentLocation auto.direct --key=/$currentLocation/" 0 "Removed automount key"
        rlRun "ipa automountlocation-del $currentLocation" 0 "Removed automount location"

    rlPhaseEnd
}

test_indirect_map_offline()
{
    rlPhaseStartTest "ipa-client-automount-039: autofs functional test offline -- indirect map"
        local automounLocation="indirect_map_${RANDOM}"
        currentLocation=$automounLocation
     
        #Adding indirect automount map and installing ipa-client-automount
        rlRun "ipa automountlocation-add $currentLocation" 0 "Added automount localtion"
        rlRun "ipa automountmap-add $currentLocation auto.share" 0 "Added automount map"
        rlRun "ipa automountkey-add $currentLocation auto.master --key=/$currentLocation --info=auto.share" 0 "Added direct automountkey in auto.share"
        rlRun "ipa automountkey-add $currentLocation auto.share --key=public --info=\"-rw,soft,rsize=8192,wsize=8192  $MASTER:/ipashare/share/\"" 0 "Added indirect automount key in auto.share"
        rlRun "ipa automountlocation-tofiles $currentLocation" 0 "automount direct map info"
        rlRun "ipa-client-automount --server=$MASTER --location=$currentLocation -U" 0 "setup ipa client automount"
        rlRun "service autofs restart" 0 "Restarting automount to fetch updated configuration"

        #sleep 60
        #Mounting the localtion added by indirect automount map
        rlRun "cd /$currentLocation;ls -al;cd public/;pwd" 0 "mounting the localtion specified in automount direct map"
        rlRun "cat mount.txt |grep mounted_file" 0 "verifying the content of mounted file"
        rlRun "cd; umount /$currentLocation/public/" 0 "unmount the location specified by automount direct map"

	#Stoping ipa sevice on $MASTER
        stop_ipa_master

        #sleep 60
        #Un-mounting the localtion added by indirect automount map
        rlRun "cd /$currentLocation/public/;pwd" 0 "mounting the localtion specified in automount direct map"
        rlRun "cat mount.txt |grep mounted_file" 0 "verifying the content of mounted file"
        rlRun "cd; umount /$currentLocation/public/" 0 "unmount the location specified by automount direct map"

	#Starting ipa sevice on $MASTER
        start_ipa_master

        #clean-up
        rlRun "ipa-client-automount --uninstall -U" 0 "uninstall ipa client automount"
        rlRun "service autofs restart" 0 "Restarting automount to fetch updated configuration"
        rlRun "ipa automountkey-del $currentLocation auto.share --key=public" 0 "Removed automount key"
        rlRun "ipa automountmap-del $currentLocation auto.share" 0 "Removed automount map"
        rlRun "ipa automountlocation-del $currentLocation" 0 "Removed automount location"

    rlPhaseEnd
}


test_indirect_map_using_wildcard_offline()
{
    rlPhaseStartTest "ipa-client-automount-040: autofs functional test offline -- indirect map with wildcard"
        local automounLocation="indirect_map_wildcard_${RANDOM}"
        currentLocation=$automounLocation
     
        #Adding indirect automount map and installing ipa-client-automount
        rlRun "ipa automountlocation-add $currentLocation" 0 "Added automount localtion"
        rlRun "ipa automountmap-add $currentLocation auto.share" 0 "Added automount map"
        rlRun "ipa automountkey-add $currentLocation auto.master --key=/$currentLocation --info=auto.share" 0 "Added direct automountkey in auto.share"
        rlRun "ipa automountkey-add $currentLocation auto.share --key=* --info=\"-rw,soft,rsize=8192,wsize=8192  $MASTER:/ipashare/&\"" 0 "Added indirect automount key in auto.share"
        rlRun "ipa automountlocation-tofiles $currentLocation" 0 "automount direct map info"
        rlRun "ipa-client-automount --server=$MASTER --location=$currentLocation -U" 0 "setup ipa client automount"
        rlRun "service autofs restart" 0 "Restarting automount to fetch updated configuration"

        #sleep 60
        #Mounting the localtion added by indirect automount map
        rlRun "cd /$currentLocation;ls -la;cd share/;pwd" 0 "mounting the localtion specified in automount direct map"
        rlRun "cat mount.txt |grep mounted_file" 0 "verifying the content of mounted file"
        rlRun "cd; umount /$currentLocation/share/" 0 "unmount the location specified by automount direct map"

	#Stoping ipa sevice on $MASTER
        stop_ipa_master

        #sleep 60
        #Un-mounting the localtion added by indirect automount map
        rlRun "cd /$currentLocation;ls;cd share/;pwd" 0 "mounting the localtion specified in automount direct map"
        rlRun "cat mount.txt |grep mounted_file" 0 "verifying the content of mounted file"
        rlRun "cd; umount /$currentLocation/share/" 0 "unmount the location specified by automount direct map"

	#Starting ipa sevice on $MASTER
        start_ipa_master

        #clean-up
        rlRun "ipa-client-automount --uninstall -U" 0 "uninstall ipa client automount"
        rlRun "service autofs restart" 0 "Restarting automount to fetch updated configuration"
        rlRun "ipa automountkey-del $currentLocation auto.share --key=*" 0 "Removed automount key"
        rlRun "ipa automountmap-del $currentLocation auto.share" 0 "Removed automount map"
        rlRun "ipa automountlocation-del $currentLocation" 0 "Removed automount location"

    rlPhaseEnd
}

