
#################################################################################
#                      test suite                                               #
#   perform the various combinations of install with fixed-primary parameter    #
#################################################################################

sssd_log_file="/var/log/sssd/sssd_testrelm.com.log"

SLAVE1=`echo $SLAVE|cut -d " " -f1 | xargs echo`
SLAVE2=`echo $SLAVE|cut -d " " -f2 | xargs echo`
SLAVE3=`echo $SLAVE|cut -d " " -f3 | xargs echo`

clientinstall_primary_server()
{
    setup #; touch /tmp/IPAQE_DEBUG_PAUSE
    ipaclientinstall_fixed_primary_param_TC_1  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_2  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_3  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_4  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_5  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_6  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_7  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_8  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_9  ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_10 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_11 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_12 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_13 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_14 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_15 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_16 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_17 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_18 ; debug_pause
    ipaclientinstall_fixed_primary_param_TC_19 ; debug_pause
    #Added following test cases from t.ipa-client-install.sh here because it enables iptables on IPA Servers
    #ipaclientinstall_server_unreachableserver    ; debug_pause
}

setup()
{
        rpm -qa|grep sssd-tools
        if [ $? -eq 1 ];then
            rlRun "yum install sssd-tools -y" 0 "Installing sssd-tools for clearing sssd cache"
        fi
        sleep 60
}

ipaclientinstall_fixed_primary_param_TC_1()
{
    rlPhaseStartTest "client-install-fixed-primary-server 01 [Positive] fixed primary with no param"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary -U"
        rlAssertNotGrep "_srv_" "$SSSD"
        SERVER=`grep -e ipa_server $SSSD|cut -d " " -f3 | xargs echo`
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $SERVER" "$sssd_log_file"
        rlAssertGrep "Added Server $SERVER" "$sssd_log_file"
        rlAssertGrep "Marking server '$SERVER' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_2()
{
    rlPhaseStartTest "client-install-fixed-primary-server 02 [Positive] fixed primary with --server=Master"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlAssertGrep "ipa_server = $MASTER" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_3()
{
    rlPhaseStartTest "client-install-fixed-primary-server 03 [Negative] fixed primary with invalid server"
       uninstall_fornexttest
       host_del
       rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=invalid --domain=$DOMAIN -U"
       command="ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=invalid --domain=$DOMAIN -U"
       expmsg="invalid is not an IPA v2 Server.
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_server_invalidserver.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_4()
{
    rlPhaseStartTest "client-install-fixed-primary-server 04 [Positive] fixed primary with --server=SLAVE"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE1 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE1 --domain=$DOMAIN --realm=$RELM -U"
        rlAssertGrep "ipa_server = $SLAVE1" "$SSSD"
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Marking server '$SLAVE1' as 'working'" "$sssd_log_file"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_5()
{
    rlPhaseStartTest "client-install-fixed-primary-server 05 [Positive] fixed primary with --server=MASTER --server=SLAVE"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE2" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE2
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
        rlAssertNotGrep "Marking server '$SLAVE2' as 'working'" "$sssd_log_file"
        debug_log
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_6()
{
    rlPhaseStartTest "client-install-fixed-primary-server 06 [Positive] fixed primary with --server=SLAVE --server=MASTER"
        uninstall_fornexttest
        host_del
        rlRun "sleep 60"
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE3 --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$SLAVE3 --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $SLAVE3, $MASTER" "$SSSD"
        ipaclientinstall_bugcheck_910410 $SLAVE3 $MASTER
        sssd_set_config_level
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $SLAVE3, $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Marking server '$SLAVE3' as 'working'" "$sssd_log_file"
        rlAssertNotGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
        debug_log
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_7()
{
    rlPhaseStartTest "client-install-fixed-primary-server 07 [Positive] fixed primary with --server=MASTER --server=SLAVE --server=invalid"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=invalid --domain=$DOMAIN --realm=$RELM -U"
        command="ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=invalid --domain=$DOMAIN --realm=$RELM -U"
        expmsg="Client configuration complete"
        local tmpout=$TmpDir/ipaclientinstall_multiple_servers_one_invalidserver.out
        qaRun "$command" "$tmpout" 0 "$expmsg" "Verify IPA Install with invalid server"
        rlAssertNotGrep "ipa_server.*invalid" /etc/sssd/sssd.conf
        if [ $? -gt 0 ]; then
            rlFail "BZ 905626 found...ipa-client-install failed to fall over to replica with master down"
            rlFail "BZ 905626 fix will prevent invalid servers from being included list"
        else
            rlPass "BZ 905626 not found"
            rlPass "--server entry invalid not seen in sssd.conf"
        fi
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_8()
{
    rlPhaseStartTest "client-install-fixed-primary-server 08 [Positive] fixed primary with no SSSD configured"
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
        debug_log
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_9()
{
   rlPhaseStartTest "client-install-fixed-primary-server 09 [Positive] fixed primary with preserve-sssd"
        uninstall_fornexttest
        host_del

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
        rlRun "cat /etc/sssd/sssd.conf"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER" "$SSSD"
        sssd_set_config_level
        rlRun "id admin@LDAP-KRB5;getent passwd admin@LDAP-KRB5;echo Secret123|kinit admin"
        rlAssertGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
        rlAssertGrep "Marking server '$MASTER' as 'working'" "$sssd_log_file"
        submit_log $sssd_log_file
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
        #uninstall_fornexttest
        debug_log
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_10()
{
    rlPhaseStartTest "client-install-fixed-primary-server 10 [Positive] fixed primary with --server=Master only and No Slave communication"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER" "$SSSD"
        sssd_set_config_level
        # Stop the MASTER 
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 1 "kinit failed"
        rlAssertGrep "Option ipa_server has value $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertNotGrep "Marking server '$SLAVE1' as 'working'" "$sssd_log_file"
        # Start the MASTER 
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        debug_log
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_11()
{
    rlPhaseStartTest "client-install-fixed-primary-server 11 [Positive] fixed primary with --server=Master --server=Slave and Slave communication only"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE2" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE2
        sssd_set_config_level
        # Stop the MASTER 
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "Marking server '$SLAVE2' as 'working'" "$sssd_log_file"
        rlAssertNotGrep "server '$SLAVE2' as 'not working'" "$sssd_log_file"
        # Start the MASTER 
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        debug_log
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_12()
{
    rlPhaseStartTest "client-install-fixed-primary-server 12 [Positive] fixed primary with --server=Master --server=Slave and no communication to MASTER and Slave"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1
        sssd_set_config_level
        # Stop the MASTER and Replica
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 1 "kinit failed"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        # Start the MASTER and Replica
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start SLAVE IPA server"
        
        uninstall_fornexttest
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_13()
{
    rlPhaseStartTest "client-install-fixed-primary-server 13 [Positive] fixed primary with --server=Master --server=Replica1 and No Replica2 communication"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1
        sssd_set_config_level
        # Stop the MASTER and REPLICA1
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 1 "kinit failed"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertNotGrep "Marking server '$SLAVE2' as 'working'" "$sssd_log_file"
        # Start the MASTER and REPLICA1
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
        uninstall_fornexttest
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_14()
{
    rlPhaseStartTest "client-install-fixed-primary-server 14 [Positive] fixed primary with --server=Master --server=Replica1 --server=Replica2 and communication to Replica2 only"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1, $SLAVE2" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1 $SLAVE2
        sssd_set_config_level
        # Stop the MASTER and Replica1 
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE2' as 'working'" "$sssd_log_file"
        # Start the MASTER and Replica1
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_15()
{
    rlPhaseStartTest "client-install-fixed-primary-server 15 [Positive] fixed primary with --server=Master --server=Replica1 --server=Replica2 and no communication to any Server"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1, $SLAVE2" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1 $SLAVE2
        sssd_set_config_level
        # Stop the MASTER, Replica1 and Replica2
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA2 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 1 "kinit failed"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE2' as 'not working'" "$sssd_log_file"
        rlAssertNotGrep "server '$SLAVE3' as 'working'" "$sssd_log_file"
        # Start the MASTER, Replica1 and Replica2
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA2 IPA server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_16()
{
    rlPhaseStartTest "client-install-fixed-primary-server 16 [Positive] fixed primary with --server=Master --server=Replica1 --server=Replica2 --server=Replica3 and communication to Replica3 only"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1 $SLAVE2 $SLAVE3
        sssd_set_config_level
        # Stop the MASTER and Replica1 
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA2 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE2' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE3' as 'working'" "$sssd_log_file"
        # Start the MASTER and Replica1
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA2 IPA server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_17()
{
    rlPhaseStartTest "client-install-fixed-primary-server 17 [Positive] fixed primary with --server=Master --server=Replica1 --server=Replica2 --server=Replica3 and no communication to any IPA Server"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1 $SLAVE2 $SLAVE3
        sssd_set_config_level
        # Stop the MASTER and Replica1 
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA2 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE3IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA3 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 1 "kinit failed"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE2' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE3' as 'not working'" "$sssd_log_file"
        # Start the MASTER and Replica1
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA2 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE3IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA3 IPA server"
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_18()
{
    rlPhaseStartTest "client-install-fixed-primary-server 18 [Positive] fixed primary with --server=Master --server=Replica1 --server=Replica2 --server=Replica3 and first communication to Replica3 and then with MASTER"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1 $SLAVE2 $SLAVE3
        sssd_set_config_level
        # Stop the MASTER and Replica1, Replica2
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA2 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE2' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE3' as 'working'" "$sssd_log_file"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE3IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA3 IPA server"
        # Start the MASTER and Replica1
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "sss_cache -u admin"
        rlRun "cat /dev/null > $sssd_log_file;service sssd restart"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertNotGrep "server '$SLAVE3' as 'working'" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'working'" "$sssd_log_file"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA2 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE3IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA2 IPA server"
        uninstall_fornexttest
    rlPhaseEnd
}

ipaclientinstall_fixed_primary_param_TC_19()
{
    rlPhaseStartTest "client-install-fixed-primary-server 19 [Positive] fixed primary with --server=Master --server=Replica1 --server=Replica2 --server=Replica3 and communication fallbacks to MASTER from Repica3"
        uninstall_fornexttest
        host_del
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW --fixed-primary --server=$MASTER --server=$SLAVE1 --server=$SLAVE2 --server=$SLAVE3 --domain=$DOMAIN --realm=$RELM -U"
        rlRun "cat $SSSD"
        rlAssertGrep "ipa_server = $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$SSSD"
        ipaclientinstall_bugcheck_910410 $MASTER $SLAVE1 $SLAVE2 $SLAVE3
        sssd_set_config_level
        # Stop the MASTER and Replica1, Replica2
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Stop MASTER IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA2 IPA server"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE1' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE2' as 'not working'" "$sssd_log_file"
        rlAssertGrep "server '$SLAVE3' as 'working'" "$sssd_log_file"
        # Start the MASTER 
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0 "Start MASTER IPA server"
        rlRun "sss_cache -u admin"
        rlRun "cat /dev/null > $sssd_log_file;service sssd restart"
        rlRun "id admin;getent passwd admin;echo Secret123|kinit admin" 0 "kinit successful"
        rlAssertGrep "Option ipa_server has value $MASTER, $SLAVE1, $SLAVE2, $SLAVE3" "$sssd_log_file"
        rlAssertGrep "Added Server $MASTER" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE1" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE2" "$sssd_log_file"
        rlAssertGrep "Added Server $SLAVE3" "$sssd_log_file"
        rlAssertNotGrep "server '$SLAVE3' as 'working'" "$sssd_log_file"
        rlAssertGrep "server '$MASTER' as 'working'" "$sssd_log_file"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE1IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA1 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA2 IPA server"
        rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE3IP 'bash -s' < $TmpDir/local.sh" 0 "Start REPLICA3 IPA server"
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

host_del()
{
    rlRun "echo \"echo Secret123|kinit admin;ipa host-del $CLIENT\" > $TmpDir/local.sh"
    rlRun "chmod +x $TmpDir/local.sh"
    rlRun "ssh -o StrictHostKeyChecking=no root@$MASTERIP 'bash -s' < $TmpDir/local.sh" 0,1,2
    #0 "Deleting host from MASTER IPA server"
    rlRun "sleep 10"
}

debug_log()
{
    cp /var/log/ipaclient-install.log /var/log/ipaclient-install.log.$FUNC
    submit_log /var/log/ipaclient-install.log.$FUNC
}
