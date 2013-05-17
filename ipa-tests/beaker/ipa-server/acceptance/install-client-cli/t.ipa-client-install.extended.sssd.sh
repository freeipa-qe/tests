ipa_client_install_sssd_option_test() {
    BaseCase_0001_test_single_option__fixed_primary  # [positive] Single Option test: --fixed-primary
    BaseCase_0002_test_single_option__force          # [positive] Single Option test: --force
    BaseCase_0003_test_single_option__force_ntpd     # [positive] Single Option test: --force-ntpd
    BaseCase_0004_test_single_option__hostname       # [positive] Single Option test: --hostname
    BaseCase_0005_test_single_option__mkhomedir      # [positive] Single Option test: --mkhomedir
    BaseCase_0006_test_single_option__no_dns_sshfp   # [positive] Single Option test: --no-dns-sshfp
    BaseCase_0007_test_single_option__no_ntp         # [positive] Single Option test: --no-ntp
    BaseCase_0008_test_single_option__no_ssh         # [positive] Single Option test: --no-ssh
    BaseCase_0009_test_single_option__no_sshd        # [positive] Single Option test: --no-sshd
    BaseCase_0010_test_single_option__noac           # [positive] Single Option test: --noac
    BaseCase_0011_test_single_option__ntp_server     # [positive] Single Option test: --ntp-server
    BaseCase_0012_test_single_option__ssh_trust_dns  # [positive] Single Option test: --ssh-trust-dns
}

BaseCase_0001_test_single_option__fixed_primary(){
    rlPhaseStartTest "BaseCase_0001_test_single_option__fixed_primary"
        rlLog "[positive] Single Option test: --fixed-primary"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --fixed-primary "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --fixed-primary"  
        CheckConfig primaryServer  # Verify for: --fixed-primar
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0002_test_single_option__force(){
    rlPhaseStartTest "BaseCase_0002_test_single_option__force"
        rlLog "[positive] Single Option test: --force"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --force "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --force"  
        CheckConfig force_ldap  # Verify for: --forc
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0003_test_single_option__force_ntpd(){
    rlPhaseStartTest "BaseCase_0003_test_single_option__force_ntpd"
        rlLog "[positive] Single Option test: --force-ntpd"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --force-ntpd "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --force-ntpd"  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntp
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0004_test_single_option__hostname(){
    rlPhaseStartTest "BaseCase_0004_test_single_option__hostname"
        rlLog "[positive] Single Option test: --hostname"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --hostname:$HOSTNAME "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --hostname=$HOSTNAME"  
        CheckConfig hostname=ClientHostname  # Verify for: --hostnam
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0005_test_single_option__mkhomedir(){
    rlPhaseStartTest "BaseCase_0005_test_single_option__mkhomedir"
        rlLog "[positive] Single Option test: --mkhomedir"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --mkhomedir "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --mkhomedir"  
        CheckFunction make_home_dir  # Verify for: --mkhomedi
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0006_test_single_option__no_dns_sshfp(){
    rlPhaseStartTest "BaseCase_0006_test_single_option__no_dns_sshfp"
        rlLog "[positive] Single Option test: --no-dns-sshfp"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --no-dns-sshfp "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --no-dns-sshfp"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0007_test_single_option__no_ntp(){
    rlPhaseStartTest "BaseCase_0007_test_single_option__no_ntp"
        rlLog "[positive] Single Option test: --no-ntp"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --no-ntp "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --no-ntp"  
        CheckConfig ntpserver_untouched  # Verify for: --no-nt
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0008_test_single_option__no_ssh(){
    rlPhaseStartTest "BaseCase_0008_test_single_option__no_ssh"
        rlLog "[positive] Single Option test: --no-ssh"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --no-ssh "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --no-ssh"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0009_test_single_option__no_sshd(){
    rlPhaseStartTest "BaseCase_0009_test_single_option__no_sshd"
        rlLog "[positive] Single Option test: --no-sshd"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --no-sshd "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --no-sshd"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0010_test_single_option__noac(){
    rlPhaseStartTest "BaseCase_0010_test_single_option__noac"
        rlLog "[positive] Single Option test: --noac"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --noac "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --noac"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0011_test_single_option__ntp_server(){
    rlPhaseStartTest "BaseCase_0011_test_single_option__ntp_server"
        rlLog "[positive] Single Option test: --ntp-server"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --ntp-server:$NTPSERVER "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --ntp-server=$NTPSERVER"
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

BaseCase_0012_test_single_option__ssh_trust_dns(){
    rlPhaseStartTest "BaseCase_0012_test_single_option__ssh_trust_dns"
        rlLog "[positive] Single Option test: --ssh-trust-dns"
        rlLog "Test Data: --server:$MASTER --password:$ADMINPW --unattended --realm:$RELM --domain:$DOMAIN --principal:$ADMINID --ssh-trust-dns "
        rlRun "/sbin/ipa-client-install --server=$MASTER --password=$ADMINPW --unattended --realm=$RELM --domain=$DOMAIN --principal=$ADMINID --ssh-trust-dns"  
        CheckConfig ssh_trust_dns  # Verify for: --ssh-trust-dn
        rlRun "ipa-client-install --uninstall -U" 0 "uninstall ipa client"
    rlPhaseEnd
}

