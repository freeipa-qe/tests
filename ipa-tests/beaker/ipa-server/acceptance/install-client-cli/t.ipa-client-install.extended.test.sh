#!/bin/bash
# extended test for ipa-client-install

ipa_client_install_extended_test() {
    ipa_client_install_nosssd_option_test
    ipa_client_install_sssd_option_test
}

ipa_client_install_nosssd_option_test() {
    rlLog "ensure ipa client is not installed before enter the test script"
    ipa-client-install --uninstall -U
    ipaclientinstall_non_sssd_single_option_test
    ipaclientinstall_non_sssd_multiple_options_test
}

ipaclientinstall_non_sssd_single_option_test() {
    ipaclientinstall_non_sssd_option_0001_test_single_option__fixed_primary #  Single Option test: --fixed-primary
    ipaclientinstall_non_sssd_option_0002_test_single_option__force         #  Single Option test: --force
    ipaclientinstall_non_sssd_option_0003_test_single_option__force_ntpd    #  Single Option test: --force-ntpd
    ipaclientinstall_non_sssd_option_0004_test_single_option__hostname      #  Single Option test: --hostname
    ipaclientinstall_non_sssd_option_0005_test_single_option__mkhomedir     #  Single Option test: --mkhomedir
    ipaclientinstall_non_sssd_option_0006_test_single_option__no_dns_sshfp  #  Single Option test: --no-dns-sshfp
    ipaclientinstall_non_sssd_option_0007_test_single_option__no_ntp        #  Single Option test: --no-ntp
    ipaclientinstall_non_sssd_option_0008_test_single_option__no_ssh        #  Single Option test: --no-ssh
    ipaclientinstall_non_sssd_option_0009_test_single_option__no_sshd       #  Single Option test: --no-sshd
    ipaclientinstall_non_sssd_option_0010_test_single_option__noac          #  Single Option test: --noac
    ipaclientinstall_non_sssd_option_0011_test_single_option__ntp_server    #  Single Option test: --ntp-server
    ipaclientinstall_non_sssd_option_0012_test_single_option__ssh_trust_dns #  Single Option test: --ssh-trust-dns
}

ipaclientinstall_non_sssd_multiple_options_test() {
    ipaclientinstall_no_sssd_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__noac        #  Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--noac
    ipaclientinstall_no_sssd_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__ntp_server  #  Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--ntp-server
}

ipaclientinstall_non_sssd_option_0001_test_single_option__fixed_primary(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0001_test_single_option__fixed_primary"
        rlLog " Single Option test: --fixed-primary"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --fixed-primary "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --fixed-primary"  
        CheckConfig primaryServer  # Verify for: --fixed-primary
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0002_test_single_option__force(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0002_test_single_option__force"
        rlLog " Single Option test: --force"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --force "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --force"  
        CheckConfig force_ldap  # Verify for: --force
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0003_test_single_option__force_ntpd(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0003_test_single_option__force_ntpd"
        rlLog " Single Option test: --force-ntpd"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --force-ntpd "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --force-ntpd"  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntp
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0004_test_single_option__hostname(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0004_test_single_option__hostname"
        rlLog " Single Option test: --hostname"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --hostname:$HOSTNAME "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --hostname=$HOSTNAME"  
        CheckConfig hostname  # Verify for: --hostname
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0005_test_single_option__mkhomedir(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0005_test_single_option__mkhomedir"
        rlLog " Single Option test: --mkhomedir"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --mkhomedir "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --mkhomedir"  
        CheckConfig make_home_dir  # Verify for: --mkhomedir
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0006_test_single_option__no_dns_sshfp(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0006_test_single_option__no_dns_sshfp"
        rlLog " Single Option test: --no-dns-sshfp"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-dns-sshfp "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-dns-sshfp"
        CheckConfig no_dns_sshfp # Verify for: --no-dns-sshfp
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0007_test_single_option__no_ntp(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0007_test_single_option__no_ntp"
        rlLog " Single Option test: --no-ntp"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-ntp "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-ntp"  
        CheckConfig ntpserver_untouched  # Verify for: --no-ntp
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0008_test_single_option__no_ssh(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0008_test_single_option__no_ssh"
        rlLog " Single Option test: --no-ssh"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-ssh "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-ssh"
        CheckConfig no_ssh # Verify for: --no-ssh
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0009_test_single_option__no_sshd(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0009_test_single_option__no_sshd"
        rlLog " Single Option test: --no-sshd"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-sshd "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-sshd"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
        CheckConfig no_sshd # Verify for: --no-sshd
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0010_test_single_option__noac(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0010_test_single_option__noac"
        rlLog " Single Option test: --noac"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --noac "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --noac"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
        CheckConfig noac # Verify for: --no-ac
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0011_test_single_option__ntp_server(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0011_test_single_option__ntp_server"
        rlLog " Single Option test: --ntp-server"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --ntp-server:$NTPSERVER "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --ntp-server=$NTPSERVER"
        CheckConfig ntpserver_setting "server $NTPSERVER"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_non_sssd_option_0012_test_single_option__ssh_trust_dns(){
    rlPhaseStartTest "ipaclientinstall_non_sssd_option_0012_test_single_option__ssh_trust_dns"
        rlLog " Single Option test: --ssh-trust-dns"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --ssh-trust-dns "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --ssh-trust-dns"  
        CheckConfig ssh_trust_dns  # Verify for: --ssh-trust-dns
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_no_sssd_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__noac(){
    rlPhaseStartTest "ipaclientinstall_no_sssd_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__noac"
        rlLog " Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--noac"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --fixed-primary --force --force-ntpd --hostname:$HOSTNAME --mkhomedir --no-dns-sshfp --noac "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --fixed-primary --force --force-ntpd --hostname=$HOSTNAME --mkhomedir --no-dns-sshfp --noac"  
        CheckConfig noac
        CheckConfig no_dns_sshfp        # Verify sshfp when no flag "--no-dns-sshfp" is given
        CheckConfig primaryServer       # Verify for: --fixed-primary  
        #CheckConfig force_ldap          # Verify for: --force  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntpd  
        CheckConfig hostname            # Verify for: --hostname  
        #CheckConfig make_home_dir       # Verify for: --mkhomedir
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_no_sssd_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__ntp_server(){
    rlPhaseStartTest "ipaclientinstall_no_sssd_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__ntp_server"
        rlLog " Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--ntp-server"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --fixed-primary --force --force-ntpd --hostname:$HOSTNAME --mkhomedir --no-dns-sshfp --ntp-server:$NTPSERVER "
        rlRun "ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --fixed-primary --force --force-ntpd --hostname=$HOSTNAME --mkhomedir --no-dns-sshfp --ntp-server=$NTPSERVER"  
        CheckConfig no_dns_sshfp        # Verify sshfp when no flag "--no-dns-sshfp" is given
        CheckConfig primaryServer       # Verify for: --fixed-primary  
        CheckConfig force_ldap          # Verify for: --force  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntpd  
        CheckConfig hostname            # Verify for: --hostname  
        CheckConfig make_home_dir       # Verify for: --mkhomedir
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}


ipa_client_install_sssd_option_test() {
    rlLog "ensure ipa client is not installed before enter the test script"
    ipa-client-install --uninstall -U
    ipaclientinstall_sssd_options_0001_test_single_option__permit                      #  Single Option test: --permit
    ipaclientinstall_sssd_options_0002_test_single_option__enable_dns_updates          #  Single Option test: --enable_dns_updates
    ipaclientinstall_sssd_options_0003_test_single_option__no_sssd                     #  Single Option test: --no-sssd
    ipaclientinstall_sssd_options_0004_test_single_option__no_krb5_offline_passwords   #  Single Option test: --no-krb5-offline-passwords
    ipaclientinstall_sssd_options_0005_test_single_option__preserve_sssd               #  Single Option test: --preserve-sssd

}

ipaclientinstall_sssd_options_0001_test_single_option__permit(){
    rlPhaseStartTest "ipaclientinstall_sssd_options_0001_test_single_option__permit"
        rlLog " Single Option test: --permit"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --permit "
        rlRun "ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --permit"  
        CheckConfig permit # Verify for: --permit
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_sssd_options_0002_test_single_option__enable_dns_updates(){
    rlPhaseStartTest "ipaclientinstall_sssd_options_0002_test_single_option__enable_dns_updates"
        rlLog " Single Option test: --enable_dns_updates"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --enable_dns_updates "
        rlRun "ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --enable-dns-updates"  
        CheckConfig enable_dns_updates  # Verify for: --enable-dns-updates
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_sssd_options_0003_test_single_option__no_sssd(){
    rlPhaseStartTest "ipaclientinstall_sssd_options_0003_test_single_option__no_sssd"
        rlLog " Single Option test: --no-sssd"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --no-sssd:$HOSTNAME "
        rlRun "ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --no-sssd"  
        CheckConfig no_sssd  # Verify for: --no-sssd
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_sssd_options_0004_test_single_option__no_krb5_offline_passwords(){
    rlPhaseStartTest "ipaclientinstall_sssd_options_0004_test_single_option__no_krb5_offline_passwords"
        rlLog " Single Option test: --no-krb5-offline-passwords"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --no-krb5-offline-passwords "
        rlRun "ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --no-krb5-offline-passwords"
        CheckConfig no_krb5_offline_passwords # Verify for: --no-krb5-offline-passwords
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

ipaclientinstall_sssd_options_0005_test_single_option__preserve_sssd(){
    rlPhaseStartTest "ipaclientinstall_sssd_options_0005_test_single_option__preserve_sssd"
        rlLog " Single Option test: --preserve-sssd"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --preserve-sssd "
        rlRun "ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --preserve-sssd"  
        CheckConfig preserv_sssd  # Verify for: --preserve-sssd
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}


