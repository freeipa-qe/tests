#!/bin/bash
. ./lib.ipa-client-install.sh

ipa_client_install_nosssd_option_test() {
    BaseCase
    Complex
}

BaseCase() {
    BaseCase_0001_test_single_option__fixed_primary # [positive] Single Option test: --fixed-primary
    BaseCase_0002_test_single_option__force         # [positive] Single Option test: --force
    BaseCase_0003_test_single_option__force_ntpd    # [positive] Single Option test: --force-ntpd
    BaseCase_0004_test_single_option__hostname      # [positive] Single Option test: --hostname
    BaseCase_0005_test_single_option__mkhomedir     # [positive] Single Option test: --mkhomedir
    BaseCase_0006_test_single_option__no_dns_sshfp  # [positive] Single Option test: --no-dns-sshfp
    BaseCase_0007_test_single_option__no_ntp        # [positive] Single Option test: --no-ntp
    BaseCase_0008_test_single_option__no_ssh        # [positive] Single Option test: --no-ssh
    BaseCase_0009_test_single_option__no_sshd       # [positive] Single Option test: --no-sshd
    BaseCase_0010_test_single_option__noac          # [positive] Single Option test: --noac
    BaseCase_0011_test_single_option__ntp_server    # [positive] Single Option test: --ntp-server
    BaseCase_0012_test_single_option__ssh_trust_dns # [positive] Single Option test: --ssh-trust-dns
}

Complex() {
    Complex_1858_test_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__noac        # [positive] Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--noac
    Complex_1859_test_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__ntp_server  # [positive] Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--ntp-server
}

BaseCase_0001_test_single_option__fixed_primary(){
    rlPhaseStartTest "BaseCase_0001_test_single_option__fixed_primary"
        rlLog "[positive] Single Option test: --fixed-primary"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --fixed-primary "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --fixed-primary"  
        CheckConfig primaryServer  # Verify for: --fixed-primar
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0002_test_single_option__force(){
    rlPhaseStartTest "BaseCase_0002_test_single_option__force"
        rlLog "[positive] Single Option test: --force"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --force "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --force"  
        CheckConfig force_ldap  # Verify for: --forc
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0003_test_single_option__force_ntpd(){
    rlPhaseStartTest "BaseCase_0003_test_single_option__force_ntpd"
        rlLog "[positive] Single Option test: --force-ntpd"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --force-ntpd "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --force-ntpd"  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntp
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0004_test_single_option__hostname(){
    rlPhaseStartTest "BaseCase_0004_test_single_option__hostname"
        rlLog "[positive] Single Option test: --hostname"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --hostname:$HOSTNAME "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --hostname=$HOSTNAME"  
        CheckConfig hostname=ClientHostname  # Verify for: --hostnam
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0005_test_single_option__mkhomedir(){
    rlPhaseStartTest "BaseCase_0005_test_single_option__mkhomedir"
        rlLog "[positive] Single Option test: --mkhomedir"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --mkhomedir "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --mkhomedir"  
        CheckFunction make_home_dir  # Verify for: --mkhomedi
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0006_test_single_option__no_dns_sshfp(){
    rlPhaseStartTest "BaseCase_0006_test_single_option__no_dns_sshfp"
        rlLog "[positive] Single Option test: --no-dns-sshfp"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-dns-sshfp "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-dns-sshfp"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0007_test_single_option__no_ntp(){
    rlPhaseStartTest "BaseCase_0007_test_single_option__no_ntp"
        rlLog "[positive] Single Option test: --no-ntp"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-ntp "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-ntp"  
        CheckConfig ntpserver_untouched  # Verify for: --no-nt
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0008_test_single_option__no_ssh(){
    rlPhaseStartTest "BaseCase_0008_test_single_option__no_ssh"
        rlLog "[positive] Single Option test: --no-ssh"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-ssh "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-ssh"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0009_test_single_option__no_sshd(){
    rlPhaseStartTest "BaseCase_0009_test_single_option__no_sshd"
        rlLog "[positive] Single Option test: --no-sshd"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --no-sshd "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --no-sshd"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0010_test_single_option__noac(){
    rlPhaseStartTest "BaseCase_0010_test_single_option__noac"
        rlLog "[positive] Single Option test: --noac"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --noac "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --noac"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0011_test_single_option__ntp_server(){
    rlPhaseStartTest "BaseCase_0011_test_single_option__ntp_server"
        rlLog "[positive] Single Option test: --ntp-server"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --ntp-server:$NTPSERVER "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --ntp-server=$NTPSERVER"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0012_test_single_option__ssh_trust_dns(){
    rlPhaseStartTest "BaseCase_0012_test_single_option__ssh_trust_dns"
        rlLog "[positive] Single Option test: --ssh-trust-dns"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --ssh-trust-dns "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --ssh-trust-dns"  
        CheckConfig ssh_trust_dns  # Verify for: --ssh-trust-dn
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

Complex_1858_test_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__noac(){
    rlPhaseStartTest "Complex_1858_test_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__noac"
        rlLog "[positive] Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--noac"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --fixed-primary --force --force-ntpd --hostname:$HOSTNAME --mkhomedir --no-dns-sshfp --noac "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --fixed-primary --force --force-ntpd --hostname=$HOSTNAME --mkhomedir --no-dns-sshfp --noac"  
        CheckConfig primaryServer  # Verify for: --fixed-primary  
        CheckConfig force_ldap  # Verify for: --force  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntpd  
        CheckConfig hostname=ClientHostname  # Verify for: --hostname  
        CheckFunction make_home_dir  # Verify for: --mkhomedi
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

Complex_1859_test_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__ntp_server(){
    rlPhaseStartTest "Complex_1859_test_option_combination___fixed_primary__force__force_ntpd__hostname__mkhomedir__no_dns_sshfp__ntp_server"
        rlLog "[positive] Multi Options test: --fixed-primary,--force,--force-ntpd,--hostname,--mkhomedir,--no-dns-sshfp,--ntp-server"
        rlLog "Test Data: --domain:$DOMAIN --principal:$ADMINID --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --fixed-primary --force --force-ntpd --hostname:$HOSTNAME --mkhomedir --no-dns-sshfp --ntp-server:$NTPSERVER "
        rlRun "/sbin/ipa-client-install --domain=$DOMAIN --principal=$ADMINID --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --fixed-primary --force --force-ntpd --hostname=$HOSTNAME --mkhomedir --no-dns-sshfp --ntp-server=$NTPSERVER"  
        CheckConfig primaryServer  # Verify for: --fixed-primary  
        CheckConfig force_ldap  # Verify for: --force  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntpd  
        CheckConfig hostname=ClientHostname  # Verify for: --hostname  
        CheckFunction make_home_dir  # Verify for: --mkhomedi
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

SelfStand_0001_test_single_option__help(){
    rlPhaseStartTest "SelfStand_0001_test_single_option__help"
        rlLog "[positive] Single Option test: --help"
        rlLog "Test Data: --help "
        rlRun "/sbin/ipa-client-install --help"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

SelfStand_0002_test_single_option__version(){
    rlPhaseStartTest "SelfStand_0002_test_single_option__version"
        rlLog "[positive] Single Option test: --version"
        rlLog "Test Data: --version "
        rlRun "/sbin/ipa-client-install --version"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

