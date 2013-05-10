ipa_client_install_sssd_option_test{
    BaseCase
    SelfStand
}

BaseCase{
    BaseCase_0001_single_option_test_fixed_primary  # [positive] Single Option test: --fixed-primary
    BaseCase_0002_single_option_test_force  # [positive] Single Option test: --force
    BaseCase_0003_single_option_test_force_ntpd  # [positive] Single Option test: --force-ntpd
    BaseCase_0004_single_option_test_hostname  # [positive] Single Option test: --hostname
    BaseCase_0005_single_option_test_mkhomedir  # [positive] Single Option test: --mkhomedir
    BaseCase_0006_single_option_test_no_dns_sshfp  # [positive] Single Option test: --no-dns-sshfp
    BaseCase_0007_single_option_test_no_ntp  # [positive] Single Option test: --no-ntp
    BaseCase_0008_single_option_test_no_ssh  # [positive] Single Option test: --no-ssh
    BaseCase_0009_single_option_test_no_sshd  # [positive] Single Option test: --no-sshd
    BaseCase_0010_single_option_test_noac  # [positive] Single Option test: --noac
    BaseCase_0011_single_option_test_ntp_server  # [positive] Single Option test: --ntp-server
    BaseCase_0012_single_option_test_ssh_trust_dns  # [positive] Single Option test: --ssh-trust-dns
}

SelfStand{
    SelfStand_0001_single_option_test_help  # [positive] Single Option test: --help
    SelfStand_0002_single_option_test_version  # [positive] Single Option test: --version
}


BaseCase_0001_single_option_test_fixed_primary(){
    rlPhaseStartTest "BaseCase_0001_single_option_test_fixed_primary"
        rlLog "[positive] Single Option test: --fixed-primary"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --fixed-primary "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --fixed-primary"  
        CheckConfig primaryServer  # Verify for: --fixed-primar
    rlPhaseEnd
}

BaseCase_0002_single_option_test_force(){
    rlPhaseStartTest "BaseCase_0002_single_option_test_force"
        rlLog "[positive] Single Option test: --force"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --force "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --force"  
        CheckConfig force_ldap  # Verify for: --forc
    rlPhaseEnd
}

BaseCase_0003_single_option_test_force_ntpd(){
    rlPhaseStartTest "BaseCase_0003_single_option_test_force_ntpd"
        rlLog "[positive] Single Option test: --force-ntpd"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --force-ntpd "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --force-ntpd"  
        CheckConfig ntpserver_disabled  # Verify for: --force-ntp
    rlPhaseEnd
}

BaseCase_0004_single_option_test_hostname(){
    rlPhaseStartTest "BaseCase_0004_single_option_test_hostname"
        rlLog "[positive] Single Option test: --hostname"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --hostname:f18a.yzhang.redhat.com "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --hostname=f18a.yzhang.redhat.com"  
        CheckConfig hostname=ClientHostname  # Verify for: --hostnam
    rlPhaseEnd
}

BaseCase_0005_single_option_test_mkhomedir(){
    rlPhaseStartTest "BaseCase_0005_single_option_test_mkhomedir"
        rlLog "[positive] Single Option test: --mkhomedir"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --mkhomedir "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --mkhomedir"  
        CheckFunction make_home_dir  # Verify for: --mkhomedi
    rlPhaseEnd
}

BaseCase_0006_single_option_test_no_dns_sshfp(){
    rlPhaseStartTest "BaseCase_0006_single_option_test_no_dns_sshfp"
        rlLog "[positive] Single Option test: --no-dns-sshfp"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --no-dns-sshfp "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --no-dns-sshfp"
    rlPhaseEnd
}

BaseCase_0007_single_option_test_no_ntp(){
    rlPhaseStartTest "BaseCase_0007_single_option_test_no_ntp"
        rlLog "[positive] Single Option test: --no-ntp"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --no-ntp "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --no-ntp"  
        CheckConfig ntpserver_untouched  # Verify for: --no-nt
    rlPhaseEnd
}

BaseCase_0008_single_option_test_no_ssh(){
    rlPhaseStartTest "BaseCase_0008_single_option_test_no_ssh"
        rlLog "[positive] Single Option test: --no-ssh"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --no-ssh "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --no-ssh"
    rlPhaseEnd
}

BaseCase_0009_single_option_test_no_sshd(){
    rlPhaseStartTest "BaseCase_0009_single_option_test_no_sshd"
        rlLog "[positive] Single Option test: --no-sshd"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --no-sshd "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --no-sshd"
    rlPhaseEnd
}

BaseCase_0010_single_option_test_noac(){
    rlPhaseStartTest "BaseCase_0010_single_option_test_noac"
        rlLog "[positive] Single Option test: --noac"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --noac "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --noac"
    rlPhaseEnd
}

BaseCase_0011_single_option_test_ntp_server(){
    rlPhaseStartTest "BaseCase_0011_single_option_test_ntp_server"
        rlLog "[positive] Single Option test: --ntp-server"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --ntp-server:wiki.idm.lab.bos.redhat.com "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --ntp-server=wiki.idm.lab.bos.redhat.com"
    rlPhaseEnd
}

BaseCase_0012_single_option_test_ssh_trust_dns(){
    rlPhaseStartTest "BaseCase_0012_single_option_test_ssh_trust_dns"
        rlLog "[positive] Single Option test: --ssh-trust-dns"
        rlLog "Test Data: --server:f18b.yzhang.redhat.com --password:Secret123 --unattended --realm:YZHANG.REDHAT.COM --domain:YZHANG.REDHAT.COM --principal:admin --ssh-trust-dns "
        rlRun "/sbin/ipa-client-install --server=f18b.yzhang.redhat.com --password=Secret123 --unattended --realm=YZHANG.REDHAT.COM --domain=YZHANG.REDHAT.COM --principal=admin --ssh-trust-dns"  
        CheckConfig ssh_trust_dns  # Verify for: --ssh-trust-dn
    rlPhaseEnd
}

SelfStand_0001_single_option_test_help(){
    rlPhaseStartTest "SelfStand_0001_single_option_test_help"
        rlLog "[positive] Single Option test: --help"
        rlLog "Test Data: --help "
        rlRun "/sbin/ipa-client-install --help"
    rlPhaseEnd
}

SelfStand_0002_single_option_test_version(){
    rlPhaseStartTest "SelfStand_0002_single_option_test_version"
        rlLog "[positive] Single Option test: --version"
        rlLog "Test Data: --version "
        rlRun "/sbin/ipa-client-install --version"
    rlPhaseEnd
}
