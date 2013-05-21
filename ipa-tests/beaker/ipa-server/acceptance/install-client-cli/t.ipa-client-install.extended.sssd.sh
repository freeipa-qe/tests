ipa_client_install_sssd_option_test() {
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


