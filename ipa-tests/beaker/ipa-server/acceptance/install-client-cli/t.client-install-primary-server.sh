
#################################################################################
#                      test suite                                #
#   perform the various combinations of install with fixed-primary parameter    #
#################################################################################

sssd_log_file="/var/log/sssd/sssd_testrelm.com.log"

clientinstall_primary_server()
{
 setup
 ipaclientinstall_fixed_primary_param_only
 ipaclientinstall_fixed_primary_param_with_Master
 ipaclientinstall_fixed_primary_invalidserver
 ipaclientinstall_fixed_primary_multiple_servers_one_invalidserver
 ipaclientinstall_fixed_primary_param_with_SLAVE
 ipaclientinstall_fixed_primary_param_with_MASTER_and_SLAVE
 ipaclientinstall_fixed_primary_param_with_SLAVE_and_MASTER
 ipaclientinstall_fixed_primary_param_with_MASTERSLAVE_and_invalidserver
 ipaclientinstall_fixed_primary_nosssd
 ipaclientinstall_fixed_primary_preservesssd

}

setup()
{
       rpm -qa|grep sssd-tools
       if [ $? -eq 1 ];then
         rlRun "yum install sssd-tools -y" 0 "Installing sssd-tools for clearing sssd cache"
       fi
}

ipaclientinstall_fixed_primary_param_only()
{
    rlPhaseStartTest "client-install-fixed-primary-server 01 [Positive] fixed primary with no param"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary -U"
        rlAssertGrep "ipa_server = $MASTER" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
	rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
	rlAssertGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
      
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_with_Master()
{
    rlPhaseStartTest "client-install-fixed-primary-server 02 [Positive] fixed primary with --server=Master"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        #sssd_config_check $MASTER
        rlAssertGrep "ipa_server = $MASTER" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
	rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
	rlAssertGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_invalidserver()
{
    rlPhaseStartTest "client-install-fixed-primary-server 03 [Negative] fixed primary with invalid server"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=invalid --domain=$DOMAIN -U"
       command="ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=invalid --domain=$DOMAIN -U"
       expmsg="invalid is not an IPA v2 Server.
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_server_invalidserver.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_multiple_servers_one_invalidserver()
{
    rlPhaseStartTest "client-install-fixed-primary-server 04 [Negative] fixed primary with multiple servers along with one invalid server"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=invalid --domain=$DOMAIN -U"
       command="ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=invalid --domain=$DOMAIN -U"
       expmsg="invalid is not an IPA v2 Server.
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_multiple_servers_one_invalidserver.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_with_SLAVE()
{
    rlPhaseStartTest "client-install-fixed-primary-server 05 [Positive] fixed primary with --server=SLAVE"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE --domain=$DOMAIN --realm=$RELM -U"
        #sssd_config_check $SLAVE
        rlAssertGrep "ipa_server = $SLAVE" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $SLAVE" "$sssd_log_file"
	rlAssertGrep "Added Server $SLAVE" "$sssd_log_file"
	rlAssertGrep "Marking server '$SLAVE' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_with_MASTER_and_SLAVE()
{
    rlPhaseStartTest "client-install-fixed-primary-server 06 [Positive] fixed primary with --server=MASTER --server=SLAVE"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE --domain=$DOMAIN --realm=$RELM -U"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE" "$sssd_log_file"
        rlAssertGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
        rlAssertNotGrep "Marking server '$SLAVE' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_with_SLAVE_and_MASTER()
{
    rlPhaseStartTest "client-install-fixed-primary-server 07 [Positive] fixed primary with --server=SLAVE --server=MASTER"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlAssertGrep "ipa_server = $SLAVE, $MASTER" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $SLAVE, $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Marking server '$SLAVE' as 'working'" "$sssd_log_file"
        rlAssertNotGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_with_MASTERSLAVE_and_invalidserver()
{
    rlPhaseStartTest "client-install-fixed-primary-server 08 [Positive] fixed primary with --server=MASTER --server=SLAVE --server=invalid"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE --server=invalid --domain=$DOMAIN --realm=$RELM -U"
       command="ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE --server=invalid --domain=$DOMAIN --realm=$RELM -U"
       expmsg="invalid is not an IPA v2 Server.
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_multiple_servers_one_invalidserver.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_nosssd()
{
    rlPhaseStartTest "client-install-fixed-primary-server 09 [Positive] fixed primary with no SSSD configured"
        uninstall_fornexttest

        rpm -q nss-pam-ldapd
        if [ $? = 1 ] ; then
                rlRun "yum install -y nss-pam-ldapd"
        fi
        
        rlRun "cat /dev/null > $sssd_log_file"
        rlLog "EXECUTING: ipa-client-install --fixed-primary  -p $ADMINID -w $ADMINPW -U --no-sssd"
        rlRun "ipa-client-install --fixed-primary -p $ADMINID -w $ADMINPW -U --no-sssd" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true nosssd
        rlAssertNotGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_preservesssd()
{
   rlPhaseStartTest "client-install-fixed-primary-server 10 [Positive] fixed primary with preserve-sssd"
        uninstall_fornexttest

        # To set up an sssd.conf that can be preserved: 
        # create a sssd.conf
          writesssdconf
          chmod 0600 $SSSD
          ls -l /etc/sssd
        # update /etc/nsswitch.conf, and vim /etc/pam.d/system-auth to use sssd
          rlLog "Executing: authconfig --enablesssd --enablesssdauth --updateall"
          rlRun "authconfig --enablesssd --enablesssdauth --updateall" 0 "Authconfig"
        # restart sssd service
          rlServiceStop "sssd"
          if [ $? -ne 0 ]; then
             rlLog "Failed to stop sssd service"
          fi
          rlServiceStart "sssd"
          if [ $? -ne 0 ]; then
             rlLog "Failed to start sssd service"
          fi
        # edit /etc/krb5.conf
          rlLog "Executing: perl -pi -e 's/EXAMPLE.COM/TESTRELM.COM/g' $KRB5"
          rlRun "perl -pi -e 's/EXAMPLE.COM/TESTRELM.COM/g' $KRB5" 0 "Updating $KRB5"
          rlLog "Executing: perl -pi -e 's/example.com/testrelm.com/g' $KRB5"
          rlRun "perl -pi -e 's/example.com/testrelm.com/g' $KRB5" 0 "Updating $KRB5"
          rlLog "Executing: perl -pi -e 's/kerberos.example.com/$MASTER/g' $KRB5"
          rlRun "perl -pi -e 's/kerberos.example.com/$MASTER/g' $KRB5" 0 "Updating $KRB5"

          rlLog "Check SELinux context of /etc/krb5.conf"
          rlRun "ls -lZ /etc/krb5.conf"

     #   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials before installing"

        #install ipa-client with --preserve-sssd
       #saving files to compare for troubleshooting later, if needed
       cp $SSSD $TmpDir
       mv $TmpDir/sssd.conf $TmpDir/sssd.conf_beforeinstall
       cp $KRB5 $TmpDir
       mv $TmpDir/krb5.conf $TmpDir/krb5.conf_beforeinstall
       AVCCHKTS=$(date +%H:%M:%S)
       rlLog "EXECUTING: ipa-client-install --fixed-primary --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --preserve-sssd"
       rlRun "ipa-client-install --fixed-primary --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --preserve-sssd" 0 "Installing ipa client with preserve-sssd"
       rlAssertGrep "ipa_server = $MASTER" "$SSSD"
       sssd_set_config_level
       rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
       rlAssertGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
       rlAssertGrep "Added Server $MASTER" "/var/log/sssd/sssd_LDAP-KRB5.log"
       rlAssertGrep "Marking server '$MASTER' as 'working'" "/var/log/sssd/sssd_LDAP-KRB5.log"

       cp $SSSD $TmpDir
       mv $TmpDir/sssd.conf $TmpDir/sssd.conf_afterinstall
       cp $KRB5 $TmpDir
       mv $TmpDir/krb5.conf $TmpDir/krb5.conf_afterinstall

        # be able to kinit
          verify_kinit true
        sleep 20
        # verify sssd contents were preserved
        verify_sssd true preserve

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials before uninstalling"
        uninstall_fornexttest
    rlPhaseEnd
}

sssd_set_config_level()
{
  rlRun "sed '/cache_credentials/ a debug_level = 9' $SSSD > /tmp/sssd.conf"
  rlRun "cp /tmp/sssd.conf $SSSD"
  rlRun "cat /dev/null > $sssd_log_file"
  rlRun "service sssd restart"
  rlRun "sss_cache -u admin"
}
