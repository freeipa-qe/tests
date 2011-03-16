



######################
# test suite         #
######################

ipaclientinstall()
{

## perform the various combinations of install and uninstall
## pass true when verifying files after install
## pass false when verifying files after uninstall

ipaclientinstall_server_invalidresolvconf2


#   ipaclientinstall_uninstall
#   verify_files false true
#
#   ipaclientinstall_adminpwd
#   verify_files true
#
#   ipaclientinstall_allparam
#   verify_files true

#   ipaclientinstall_noparam

#   ipaclientinstall_noNTP
#    verify_ntp false

#   ipaclientinstall_nosssd
#   verify_files true false

#   --domain=DOMAIN Set the domain name to DOMAIN 
##ipaclientinstall_domain #Negative
##ipaclientinstall_domain_casesensitive #Negative

#   --server=SERVER Set the IPA server to connect to
##ipaclientinstall_server #Negative
##ipaclientinstall_server_casesensitive # Negative
##ipaclientinstall_server_nodomain #Negative
##ipaclientinstall_server_invalidresolvconf1 #Negative
##ipaclientinstall_server_invalidresolvconf2 #Negative


# --realm=REALM_NAME Set the IPA realm name to REALM_NAME 
##ipaclientinstall_realm_casesensitive #Negative
##ipaclientinstall_realm #Negative

#  --f, --force Force the settings even if errors occur
##ipaclientinstall_hostname 

#  --hostname The hostname of this server (FQDN). By default of nodename from uname(2) is used. 
##ipaclientinstall_force


}


ipaclientinstall_uninstall()
{
rlPhaseStartTest "IPA Uninstall"
    rlLog "EXECUTING: ipa-client-install --uninstall -U"
    rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
rlPhaseEnd
}


ipaclientinstall_adminpwd()
{
rlPhaseStartTest "[Positive] IPA Install with admin & password"
    rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW -U "
    rlRun "ipa-client-install -p $ADMINID -w $ADMINPW -U " 0 "Installing ipa client and configuring - passing admin and password"
rlPhaseEnd
}



ipaclientinstall_noparam()
{
rlPhaseStartTest "[Negative] IPA Install with no param"
    rlLog "EXECUTING: ipa-client-install -U "
    command="ipa-client-install -U"
    expmsg="One of password and principal are required."
    rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no param"
rlPhaseEnd
}


ipaclientinstall_allparam()
{
rlPhaseStartTest "[Positive] IPA Install with all param"
    #rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
    rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER"
    rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
    rlLog "==================="
rlPhaseEnd
}



ipaclientinstall_noNTP()
{
rlPhaseStartTest "[Positive] IPA Install with no NTP configured"
    rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
    rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -N -p $ADMINID -w $ADMINPW -U --server=$MASTER"
    rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -N -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring - with no NTP configured"
rlPhaseEnd
}


ipaclientinstall_nosssd()
{
rlPhaseStartTest "[Positive] IPA Install with no SSSD configured"
    rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
    rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd"
    rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd" 0 "Installing ipa client and configuring - with no SSSD configured"
    rlLog "==================="
rlPhaseEnd
}

#################################################
#   --domain=DOMAIN Set the domain name to DOMAIN 
#################################################
#negative tests for --domain option
ipaclientinstall_domain()
{
    rlPhaseStartTest "[Negative] IPA Install with invalid domain"
    #Bug 684780
    rlPhaseEnd
}

ipaclientinstall_domain_casesensitive()
{
    rlPhaseStartTest "[Negative] IPA Install with incorrect case domainname"
    #Bug 684780
    rlPhaseEnd
}


####################################################
#   --server=SERVER Set the IPA server to connect to
####################################################
#negative tests for --server option
ipaclientinstall_server_casesensitive()
{
    rlPhaseStartTest "[Negative] IPA Install with incorrect case servername"
    #Bug 684780
    rlPhaseEnd
}

ipaclientinstall_server_nodomain()
{
    rlPhaseStartTest "[Negative] IPA Install with the server, but without the required param - domain - specified"
       rlLog "EXECUTING: ipa-client-install --server=xxx "
       command="ipa-client-install --server=xxx"
       expmsg="ipa-client-install: error: --server cannot be used without providing --domain"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no domain"
    rlPhaseEnd
}

ipaclientinstall_server_invalidresolvconf1()
{
    rlPhaseStartTest "[Negative] IPA Install with invalid server, with invalid resolv.conf 1"
    rlLog "EXECUTING: ipa-client-install --server=xxx --domain=xxx "
    command="ipa-client-install --server=xxx --domain=xxx"
    expmsg="Retrieving CA from xxx failed."
    rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with invalid resolv.conf 1" 
    rlPhaseEnd
}

ipaclientinstall_server_invalidresolvconf2()
{
    rlPhaseStartTest "[Negative] IPA Install with the server, but with invalid resolv.conf 2"
       serverparam=`echo $MASTER  | cut -d "." -f1 | xargs echo`
       command="ipa-client-install --server=$serverparam --domain=$DOMAIN"
       expmsg="root        : ERROR    LDAP Error: Connect error: TLS: hostname does not match CN in peer certificate
Failed to verify that rhel61-server is an IPA Server.
This may mean that the remote server is not up or is not reachable
due to network or firewall settings." 
       rlLog "EXECUTING: ipa-client-install --server=$serverparam "
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with invalid resolv.conf 2"

    rlPhaseEnd
}


ipaclientinstall_server_invalidresolvconf3()
{
    rlPhaseStartTest "[Negative] IPA Install with the server, but with invalid resolv.conf 3"
    # error: --server=rhel61.testrelm but resolv.conf is not correct 
    #The failure to use DNS to find your IPA server indicates that your 
    #resolv.conf file is not properly configured. 

    #Autodiscovery of servers for failover cannot work with this configuration. 

    #If you proceed with the installation, services will be configured to always 
    #access the discovered server for all operation and will not fail over to 
    #other servers in case of failure. 

    rlPhaseEnd
}


ipaclientinstall_realm_casesensitive()
{
    rlPhaseStartTest "[Negative] IPA Install with incorrect case realmname"
    #ERROR: The provided realm name: [Testrelm] does not match with the discovered one: [TESTRELM]
    rlPhaseEnd
}

ipaclientinstall_realm()
{
    rlPhaseStartTest "[Negative] IPA Install with invalid realm"
    #ERROR: The provided realm name: [xxx] does not match with the discovered one: [TESTRELM] 
    rlPhaseEnd
}


ipaclientinstall_hostname()
{
    rlPhaseStartTest "[Negative but installs] IPA Install with invalid hostname"
    #Warning: Hostname (RHEL61-client.testrelm) not found in DNS 
    #Failed to obtain host TGT. 
    #DNS server record set to: RHEL61-client.testrelm -> 10.16.19.131 
    #SSSD enabled 
    #nss_ldap is not able to use DNS discovery! 
    #Changing configuration to use hardcoded server name: rhel61-server.testrelm 
    #Kerberos 5 enabled


## after uninstall of this - verify keytab for this client is set false on server - bug 681338 


## verify - since this is installed - using kinit
    rlPhaseEnd
}


ipaclientinstall_force()
{
    rlPhaseStartTest "[Positive] IPA Install with force" 
    # reinstall with option - should be successful
    # uninstall twice - should exit with error code 1
    rlPhaseEnd
}


verify_files()
{
# verify files changed during install/uninstall
   verify_nsswitch $1 $2
   verify_sssd $1 $2 
   verify_authconfig $1 $2

  verify_krb5 $1
  verify_default $1
  verify_ntp $1

# verify if admin can kinit after install/uninstall
   verify_kinit $1

}




save_logs()
{
     if [ -f /var/log/ipaclient-install.log ]; then
        rhts-submit-log -l /var/log/ipaclient-install.log
     fi
     if [ -f /var/log/ipaclient-uninstall.log ]; then
        rhts-submit-log -l /var/log/ipaclient-uninstall.log
     fi
}
