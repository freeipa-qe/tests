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
    rlPhaseStartTest "negative test user interrupt installation"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_while_communication_blocked()
{
    rlPhaseStartTest "negative test ports blocked while install"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_then_uninstall()
{
    rlPhaseStartTest "install then uninstall"
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
    rlPhaseStartTest "reinstall after uninstall, use same ipa server and automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "reinstall after uninstall, use different ipa server, use same automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "reinstall without uninstall first, use same ipa server and automount location"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 
        check_autofs_sssd_configuration "configured"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 1 "reinstall without uninstall first should fail"
    rlPhaseEnd
}

reinstall_without_uninstall_use_different_ipa_server_and_automount_location()
{
    clean_up_automount_installation
    rlPhaseStartTest "reinstall without uninstall first, use different ipa server and automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "repeated install and uninstall, last action=Uninstall, use same set of ipa server and automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "repeated install and uninstall, last action=Install, use same ipa server server and automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "repeated install and uninstall, last action=Uninstall, use different ipa server, use same automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "repeated install and uninstall, last action=Uninstall, use same ipa server, use different automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "repeated install and uninstall, last action=Install, use same ipa server, use same automount location"
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
    clean_up_automount_installation
    rlPhaseStartTest "repeated install and uninstall, last action=Install, use same ipa server, use different automount location"
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
    rlPhaseStartTest "negative test install as non-root user"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_with_no_option_used()
{
    rlPhaseStartTest "simple install, no option used (use DNS _SRV_ auto-discovery)"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install__no_sssd()
{
    rlPhaseStartTest "install with --no-sssd option, no other option used, (use DNS _SRV_ auto-discovery"
        rlPass "test case is not ready, this might end up be a manual test cases"
    rlPhaseEnd
}

install_option__help()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option, check --help or -h , help message"
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
    clean_up_automount_installation
    rlPhaseStartTest "install option single, --server <valid ipa server>"
        currentLocation="default"
        rlRun "ipa-client-automount --server=$currentIPAServer -U" 0 "install should success as valid ipa server used"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__server_invalid()
{
    clean_up_automount_installation
    rlPhaseStartTest "negative test install option, --server <invalid ipa server>"
        currentLocation="default"
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        rlRun "ipa-client-automount --server=$invalidIPAServer -U" 1 "install should fail if invalid ipa server provided"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__location_valid()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option single, --location <valid automount location>"
        rlRun "ipa-client-automount --location=$currentLocation -U" 0 "install should success as valid location used"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__location_invalid()
{
    clean_up_automount_installation
    rlPhaseStartTest "negative test install option single, --location <invalid automount location>"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --location=$invalidLocation -U" 1 "install should ail as invalid location used"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_valid__location_valid()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option combined, --server <valid> --location <valid>"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__server_valid__location_invalid()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option combined, --server <valid> --location <invalid>"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$invalidLocation -U" 1 "invalid location used, install should fail"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_invalid__location_valid()
{
    clean_up_automount_installation
    rlPhaseStartTest "negative test install option combined, --server <invalid> --location <valid>"
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        rlRun "ipa-client-automount --server=$invalidIPAServer --location=$currentLocation -U" 1 "install should fail as invalid ipa server used"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_invalid__location_invalid()
{
    clean_up_automount_installation
    rlPhaseStartTest "negative test install option combined, --server <invalid> --location <invalid>"
        local invalidIPAServer="invalid.$RANDOM.ipa.server.com"
        local invalidLocation="invalid_Automount_Location_$RANDOM"
        rlRun "ipa-client-automount --server=$invalidIPAServer --location=$invalidLocation -U" 1 "install should fail as invalid location and ipa server used"
        check_autofs_sssd_configuration "not_configured"
    rlPhaseEnd
}

install_option__server_valid__location_valid__unattended()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option combined, --server <valid> --location <valid> --U (unattended)"
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U"
        check_autofs_sssd_configuration "configured"
    rlPhaseEnd
}

install_option__server_valid__no_sssd()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option, --no-sssd + --server <valid>"
        currentLocation="default"
        rlRun "ipa-client-automount --no-sssd --server=$currentIPAServer -U"
        LDAP_URI="LDAP_URI=ldap://${currentIPAServer}"
        check_autofs_no_sssd_configuration "configured"
        LDAP_URI="" #reset
    rlPhaseEnd
}

install_option__location_valid__no_sssd()
{
    clean_up_automount_installation
    rlPhaseStartTest "install option, --no-sssd + --location <valid>"
        rlRun "ipa-client-automount --no-sssd --location=$currentLocation -U"
        LDAP_URI="LDAP_URI=ldap:///${suffix}"
        check_autofs_no_sssd_configuration "configured"
        LDAP_URI="" #reset
    rlPhaseEnd
}

install_option__server_valid__location_valid__no_sssd()
{
    rlPhaseStartTest "install option, --no-sssd + --server <valid> --location <valid>"
    clean_up_automount_installation
        rlRun "ipa-client-automount --no-sssd --server=$currentIPAServer --location=$currentLocation -U"
        LDAP_URI="LDAP_URI=ldap://${currentIPAServer}"
        check_autofs_no_sssd_configuration "configured"
        LDAP_URI="" #reset
    rlPhaseEnd
}

install_option__server_invalid__location_invalid__no_sssd()
{
    rlPhaseStartTest "negative test install option, --no-sssd + --server <invalid> --location <invalid>"
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
#    for current_serverEnv in standalone_ipa_dns_nfs combined_ipa_dns_standalone_nfs all_combined
#    do
#        for current_nfsConfiguration in nfs_v3_non_secure nfs_v4_non_secure nfs_v4_kerberized
#        do
            current_serverEnv="all_combined"
            current_nfsConfiguration="nfs_v3_non_secure"
            setup_testing_environment $current_serverEnv $current_nfsConfiguration
            basic_autofs_functional_test
#        done
#    done
}

setup_testing_environment()
{
    local serverEnv=$1
    local nfsConfiguration=$2
    rlPhaseStartTest "autofs functional test env setup, [$serverEnv] - [$nfsConfiguration]"
        echo "::::::: configuration: server [$serverEnv], nfs [$nfsConfiguration] :::::::"
        setup_server $serverEnv
        #setup_nfs $nfsConfiguration
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    rlPhaseEnd
}

setup_server()
{
    local serverEnv=$1
    if [ "$serverEnv" = "standalone_ipa_dns_nfs" ];then
        currentIPAServer=$ipaServerMaster
        currentDNSServer=$dnsServer
        currentNFSServer=$nfsServer 
    elif [ "$serverEnv" = "combined_ipa_dns_standalone_nfs" ];then
        currentIPAServer=$ipaServerMaster
        currentDNSServer=$ipaServerMasterIP
        currentNFSServer=$nfsServer 
    elif [ "$serverEnv" = "all_combined" ];then
        currentIPAServer=$ipaServerMaster
        currentDNSServer=$ipaServerMasterIP
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
        configure_nfs_non_secure "$configuration"
        echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
        service nfs restart
    elif [ "$nfsConfiguration" = "nfs_v4_non_secure" ];then
        echo "NFS v4" 
        configuration=$nfsConfiguration_NonSecure
        currentNFSMountOption="$nfsMountType_nfs4"
        configure_nfs_non_secure "$configuration"
        echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
        service nfs restart
    elif [ "$nfsConfiguration" = "nfs_v4_kerberized" ];then
        echo "NFS v4 + kerberos"
        configuration="$nfsConfiguration_Kerberized"
        currentNFSMountOption="$nfsMountType_kerberized"
        echo "$configuration" > $nfsConf
        echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
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
    ipa-client-automount --uninstall -U 2>&1 > /dev/null
}

test_direct_map()
{
    rlPhaseStartTest "autofs functional test direct map with sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Direct_use_sssd_${RANDOM}"
        currentLocation=$automounLocation
        rlLog "config autofs direct mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_direct $currentLocation $currentNFSServer $nfsDir $autofsDir 
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 0 "setup ipa client automount"
        restart_sssd
        restart_autofs
        verify_autofs_mounting $autofsTopDir $autofsSubDir
    rlPhaseEnd
        clean_up_direct_map $currentLocation $autofsDir
        clean_up_automount_installation
}

test_indirect_map()
{
    rlPhaseStartTest "autofs functional test indirect map with sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_use_sssd_${RANDOM}"
        currentLocation=$automounLocation
        rlLog "config autofs indirect mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_indirect $currentLocation $currentNFSServer $nfsDir $autofsDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 0 "setup ipa client automount"
        restart_sssd
        restart_autofs
        verify_autofs_mounting $autofsTopDir $autofsSubDir
    rlPhaseEnd
        clean_up_indirect_map $currentLocation $autofsTopDir $autofsSubDir
        clean_up_automount_installation   
}


test_indirect_map_using_wildcard()
{
    rlPhaseStartTest "autofs functional test add indirect map using wild card and with sssd[$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_use_sssd_${RANDOM}"
        currentLocation=$automounLocation
        local clientSideDir="${autofsTopDir}/${nfsExportSubDir}"
        rlLog "config autofs indirect mount use wildcard (*,&):"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsExportTopDir/&] [autofs local dir: $autofsTopDir/*]"
        configure_autofs_indirect_use_wildcard $currentLocation $currentNFSServer $nfsExportTopDir $autofsTopDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U" 0 "setup ipa client automount"
        restart_sssd
        restart_autofs
        verify_autofs_mounting $autofsTopDir $nfsExportSubDir 
    rlPhaseEnd
        clean_up_indirect_map $currentLocation $autofsTopDir $autofsSubDir
        clean_up_automount_installation
}

test_direct_map_use_no_sssd()
{
    rlPhaseStartTest "autofs functional test direct map use no sssed [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Direct_no_sssd_${RANDOM}"
        currentLocation=$automounLocation
        rlLog "config autofs direct mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_direct $currentLocation $currentNFSServer $nfsDir $autofsDir 
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --no-sssd -U" 0 "setup ipa client automount"
        restart_autofs
        verify_autofs_mounting $autofsTopDir $autofsSubDir
    rlPhaseEnd
        clean_up_direct_map $currentLocation $autofsDir
        clean_up_automount_installation
}

test_indirect_map_use_no_sssd()
{
    rlPhaseStartTest "autofs functional test indirect map use no sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_no_sssd_${RANDOM}"
        currentLocation=$automounLocation
        rlLog "config autofs indirect mount:"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsDir] [autofs local dir: $autofsDir]"
        configure_autofs_indirect $currentLocation $currentNFSServer $nfsDir $autofsDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --no-sssd -U" 0 "setup ipa client automount"
        restart_autofs
        verify_autofs_mounting $autofsTopDir $autofsSubDir
    rlPhaseEnd
        clean_up_indirect_map $currentLocation $autofsTopDir $autofsSubDir
        clean_up_automount_installation   
}


test_indirect_map_using_wildcard_use_no_sssd()
{
    rlPhaseStartTest "autofs functional test add indirect map using wild card and no sssd [$current_serverEnv] + [$current_nfsConfiguration]"
        local automounLocation="Indirect_no_sssd_${RANDOM}"
        currentLocation=$automounLocation
        local clientSideDir="${autofsTopDir}/${nfsExportSubDir}"
        rlLog "config autofs indirect mount use wildcard (*,&):"
        rlLog "[automountLocation:$currentLocation] [NFS Server:$currentNFSServer:$nfsExportTopDir/&] [autofs local dir: $autofsTopDir/*]"
        configure_autofs_indirect_use_wildcard $currentLocation $currentNFSServer $nfsExportTopDir $autofsTopDir
        rlRun "ipa-client-automount --server=$currentIPAServer --location=$currentLocation --no-sssd -U" 0 "setup ipa client automount"
        restart_autofs
        verify_autofs_mounting $autofsTopDir $nfsExportSubDir 
    rlPhaseEnd
        clean_up_indirect_map $currentLocation $autofsTopDir $autofsSubDir
        clean_up_automount_installation
}

