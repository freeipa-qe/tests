
##################################################################
#                      test suite                                #
#   perform the various combinations of install and uninstall    #
#################################################################

ipaclientinstall()
{

   setup
#   -U, --unattended  Unattended installation. The user will not be prompted.
   ipaclientinstall_adminpwd

#   install with multiple params including
#   --ntp-server=NTP_SERVER Configure ntpd to use this NTP server.
   ipaclientinstall_allparam

#   --uninstall Remove the IPA client software and restore the configuration to the pre-IPA state.
   ipaclientinstall_uninstall

   ipaclientinstall_noparam

#   -N, --no-ntp  Do not configure or enable NTP.
   ipaclientinstall_noNTP

#   --domain=DOMAIN Set the domain name to DOMAIN 
    ipaclientinstall_invaliddomain

#   --server=SERVER Set the IPA server to connect to
   ipaclientinstall_server_nodomain 
   ipaclientinstall_server_invalidserver


#   --realm=REALM_NAME Set the IPA realm name to REALM_NAME 
   ipaclientinstall_realm_casesensitive 
   ipaclientinstall_invalidrealm 

#   --hostname The hostname of this server (FQDN). By default of nodename from uname(2) is used. 
   ipaclientinstall_hostname 


#  --on-master The client is being configured on an IPA server.
####   IPA Server uses this to install client on server machine.   #####
####   End user will not use it. So no tests here for this option. #####

#   -w PASSWORD, --password=PASSWORD Password for joining a machine to the IPA realm. Assumes bulk password unless principal is also set.
    ipaclientinstall_password

#   -W  Prompt for the password for joining a machine to the IPA realm.

#   -p, --principal  Authorized kerberos principal to use to join the IPA realm.
   ipaclientinstall_nonexistentprincipal
   ipaclientinstall_nonadminprincipal
   ipaclientinstall_principalwithinvalidpassword

#   --permit Configure  SSSD  to  permit all access. Otherwise the machine will be controlled by the Host-based Access Controls (HBAC) on the IPA server.
    ipaclientinstall_permit


#   --mkhomedir  Configure pam to create a users home directory if it does not exist.
    ipaclientinstall_mkhomedir


#   --enable-dns-updates This option tells SSSD to automatically update DNS with the IP address of this client.
     ipaclientinstall_enablednsupdates


#   Install client with master down #bug 696193
#   ipaclientinstall_withmasterdown

#   -S, --no-sssd  Do not configure the client to use SSSD for authentication, use nss_ldap instead.
   ipaclientinstall_nosssd



#  --f, --force Force the settings even if errors occur
   ipaclientinstall_force 


}

setup()
{
    rlPhaseStartSetup "ipa-client-install-Setup "
        # edit hosts file and resolv file before starting tests
        rlRun "fixHostFile" 0 "Set up /etc/hosts"
        rlRun "fixhostname" 0 "Fix hostname"
        rlRun "fixResolv" 0 "fixing the resolv.conf to contain the correct nameserver lines"
        rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
        rlLog "Setting up Authorized keys"
        SetUpAuthKeys
        rlLog "Setting up known hosts file"
        SetUpKnownHosts

    
        ## Lines to expect to be changed during the isnatllation process
        ## which reference the MASTER. 
        ## Moved them here from data.ipaclientinstall.acceptance since MASTER is not set there.
        ipa_server_master="_srv_, $MASTER" # sssd.conf updates
        domain_realm_force_master="$MASTER:88 $MASTER:749 ${RELM,,} $RELM $RELM" # krb5.conf updates
        ipa_server_slave="_srv_, $SLAVE" # sssd.conf updates
        domain_realm_force_slave="$SLAVE:88 $MASTER:749 ${RELM,,} $RELM $RELM" # krb5.conf updates
    rlPhaseEnd
}


#############################################################################
#   -U, --unattended  Unattended installation. The user will not be prompted.
#############################################################################
ipaclientinstall_adminpwd()
{
    rlPhaseStartTest "ipa-client-install-01- [Positive] Install with admin & password - with -U"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW -U "
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW -U " 0 "Installing ipa client and configuring - passing admin and password"
        verify_install true nontpspecified 
    rlPhaseEnd
}



############################################################

ipaclientinstall_allparam()
{
    rlPhaseStartTest "ipa-client-install-02- [Positive] Install with all param"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        verify_install true
    rlPhaseEnd
}


#################################################################################################
#   --uninstall Remove the IPA client software and restore the configuration to the pre-IPA state.
#################################################################################################
ipaclientinstall_uninstall()
{
    rlPhaseStartTest "ipa-client-install-03- [Positive] Uninstall"
        install_fornexttest
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        # before uninstalling ipa client, first remove its references from server
    #    rlRun "ipa host-del $CLIENT --updatedns" 0 "Deleting client record and DNS entry from server"
        # now uninstall
        rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
        verify_install false
    rlPhaseEnd
}

#######################################################

ipaclientinstall_noparam()
{
    rlPhaseStartTest "ipa-client-install-04- [Negative] Install with no param"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -U "
        command="ipa-client-install -U"
        expmsg="One of password and principal are required."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no param"
    rlPhaseEnd
}


################################################
#   -N, --no-ntp  Do not configure or enable NTP.
################################################
ipaclientinstall_noNTP()
{
    rlPhaseStartTest "ipa-client-install-05- [Positive] Install with no NTP configured"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -N -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -N -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring - with no NTP configured"
        verify_install true nontp
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-06- [Positive] Uninstall after install with no NTP"
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client after install with no NTP"
        verify_install false
    rlPhaseEnd
    #TODO: Repeat for --no-ntp?
}



#################################################
#   --domain=DOMAIN Set the domain name to DOMAIN 
#################################################
#negative tests for --domain option
ipaclientinstall_invaliddomain()
{
    rlPhaseStartTest "ipa-client-install-07- [Negative] Install with invalid domain"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --domain=xxx -p $ADMINID -w $ADMINPW -U"
       command="ipa-client-install --domain=xxx -p $ADMINID -w $ADMINPW -U"
       expmsg="Unable to find IPA Server to join"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with invalid domain"
    rlPhaseEnd
}

####################################################
#   --server=SERVER Set the IPA server to connect to
####################################################
#negative tests for --server option
ipaclientinstall_server_nodomain()
{
    rlPhaseStartTest "ipa-client-install-08- [Negative] Install with the server, but without the required param - domain - specified"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --server=xxx "
       command="ipa-client-install --server=xxx"
       expmsg="Usage: ipa-client-install [options]

ipa-client-install: error: --server cannot be used without providing --domain"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no domain"
    rlPhaseEnd
}

ipaclientinstall_server_invalidserver()
{
    rlPhaseStartTest "ipa-client-install-09- [Negative] Install with invalid server"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --server=xxx --domain=xxx "
       command="ipa-client-install --server=xxx --domain=xxx"
       expmsg="Retrieving CA from xxx failed."
       local tmpout=$TmpDir/ipaclientinstall_server_invalidresolvconf1.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid server" 
    rlPhaseEnd
}


#########################################################
# --realm=REALM_NAME Set the IPA realm name to REALM_NAME 
#########################################################
#negative tests for --realm option
ipaclientinstall_realm_casesensitive()
{
    rlPhaseStartTest "ipa-client-install-10- [Negative] Install with incorrect case realmname"
       uninstall_fornexttest
       relminlowercase=`echo ${RELM,,}`
       rlLog "EXECUTING: ipa-client-install --realm=$relminlowercase"
       command="ipa-client-install --realm=$relminlowercase"
       expmsg="ERROR: The provided realm name: [$relminlowercase] does not match with the discovered one: [$RELM]"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with incorrect case realmname"

    rlPhaseEnd
}

ipaclientinstall_invalidrealm()
{
    rlPhaseStartTest "ipa-client-install-11- [Negative] Install with invalid realm"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --realm=xxx"
       command="ipa-client-install --realm=xxx"
       expmsg="ERROR: The provided realm name: [xxx] does not match with the discovered one: [$RELM]"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with invalid realmname"
    rlPhaseEnd
}


###############################################################################################
#  --hostname The hostname of this server (FQDN). By default of nodename from uname(2) is used. 
###############################################################################################
#negative tests for --hostname option
## in the case below - client is installed, but a DNS entry is not available on server for this client.
ipaclientinstall_hostname()
{
    rlPhaseStartTest "ipa-client-install-12- [Positive-Negative] IPA Install with invalid hostname"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --hostname=$CLIENT"
       local tmpout=$TmpDir/ipaclientinstall_hostname.$RANDOM.out
       command="ipa-client-install --hostname=$CLIENT.nonexistent --server=$MASTER --domain=$DOMAIN -p $ADMINID -w $ADMINPW --ntp-server=$NTPSERVER -U"
       expmsg1="Warning: Hostname ($CLIENT.nonexistent) not found in DNS"
       expmsg2="DNS server record set to: $CLIENT.nonexistent -> "
       qaExpectedRun "$command" "$tmpout" 0 "Verify expected error message for IPA Install with invalid hostname" "$expmsg1" "$expmsg2" 

       verify_install
    
       # now uninstall
       rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"

       # after uninstall of this - verify keytab for this client is set false on server - bug 681338 
       rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
       local tmpout=$TmpDir/verify_keytab_afteruninstall.$RANDOM.out
       verify_keytab_afteruninstall $CLIENT.nonexistent $tmpout

       # clear the host record, there is no DNS record associated for this host
       rlRun "ipa host-del $CLIENT.nonexistent" 0 "Deleting client record and DNS entry from server"

    rlPhaseEnd

}


####################################################################################
#   -w PASSWORD, --password=PASSWORD Password for joining a machine to the IPA realm.
#                                 Assumes bulk password unless principal is also set.
####################################################################################
ipaclientinstall_password()
{
    rlPhaseStartTest "ipa-client-install-13- [Negative] Install with password, but missing principal"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --password=$ADMINPW"
       command="ipa-client-install --password $ADMINPW -U"
       expmsg="Joining realm failed: Host is already joined.
Certificate subject base is: O=$RELM"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with password, but missing principal"
    rlPhaseEnd
}



#######################################################################
#   -W  Prompt for the password for joining a machine to the IPA realm.
# TODO: test with -W. So far - looks like -w
#######################################################################




################################################################################
#   -p, --principal  Authorized kerberos principal to use to join the IPA realm.
################################################################################
#negative tests for --principal option
ipaclientinstall_nonexistentprincipal()
{
    rlPhaseStartTest "ipa-client-install-14- [Negative] Install with non-existent principal"
        uninstall_fornexttest
        command="ipa-client-install --ntp-server=$NTPSERVER -p $testuser -w $testpwd -U" 
        expmsg="kinit: Client '$testuser@$RELM' not found in Kerberos database while getting initial credentials"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with non-existent principal"
    rlPhaseEnd
}


# using --principal
ipaclientinstall_nonadminprincipal()
{
    rlPhaseStartTest "ipa-client-install-15- [Negative] Install with principal with no admin priviliges"
       install_fornexttest
       create_ipauser $testuser $testuser $testuser $testpwd
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER --principal $testuser -w $testpwd -U"
       command="ipa-client-install --ntp-server=$NTPSERVER --principal $testuser -w $testpwd -U" 
       expmsg="Joining realm failed because of failing XML-RPC request.
  This error may be caused by incompatible server/client major versions."
       tmpout=$TmpDir/ipaclientinstall_nonadminprincipal.out
       qaExpectedRun "$command" "$tmpout" 1 "Verify expected error message for IPA Install with non-admin principal" "$expmsg"

       # delete the user added for this test
       install_fornexttest
       delete_ipauser $testuser
    rlPhaseEnd
}

ipaclientinstall_principalwithinvalidpassword()
{
    rlPhaseStartTest "ipa-client-install-16- [Negative] Install with principal with invalid password"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $testpwd -U" 
       command="ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $testpwd -U" 
       expmsg="kinit: Password incorrect while getting initial credentials"
       tmpout=$TmpDir/ipaclientinstall_principalwithinvalidpassword.out
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with principal with invalid password"
    rlPhaseEnd
}


#############################################################################################
#   --permit Configure  SSSD  to  permit all access. Otherwise the machine will be controlled
#             by the Host-based Access Controls (HBAC) on the IPA server.
#############################################################################################
ipaclientinstall_permit()
{
    rlPhaseStartTest "ipa-client-install-17- [Positive] Install and configure SSSD to permit all access"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --permit"
        rlRun "ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --permit" 0 "Installing ipa client and configure SSSD to permit all access"
        verify_install true permit
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-18- [Positive] Uninstall and disable SSSD to permit all access "
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client and disable SSSD to permit all access"
        verify_install false permit
    rlPhaseEnd
}

######################################################################################
#   --mkhomedir  Configure pam to create a users home directory if it does not exist.
######################################################################################
ipaclientinstall_mkhomedir()
{
    rlPhaseStartTest "ipa-client-install-19- [Positive] Install and configure pam to create home dir if it does not exist"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --mkhomedir"
        rlRun "ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --mkhomedir" 0 "Installing ipa client and configuring pam to create home dir if it does not exist"
        verify_install true mkhomedir
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-20- [Positive] Uninstall and remove configuration for pam to create home dir"
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client and remove configuration for pam to create home dir"
        verify_install false mkhomedir
    rlPhaseEnd
}




###############################################################################################################
#   --enable-dns-updates This option tells SSSD to automatically update DNS with the IP address of this client.
###############################################################################################################
ipaclientinstall_enablednsupdates()
{
    rlPhaseStartTest "ipa-client-install-21- [Positive] Install and enable dynamic dns updates"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --enable-dns-updates"
        rlRun "ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --enable-dns-updates" 0 "Installing ipa client and enable dynamic dns updates"
        verify_install true enablednsupdates
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-22- [Positive] Uninstall and disable dynamic dns updates"
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client and disable dynamic dns updates"
        verify_install false enablednsupdates
    rlPhaseEnd
}


##########################################
# Client Install with primary down, replica up
##########################################
ipaclientinstall_withmasterdown()
{
    rlPhaseStartTest "ipa-client-install-23- [Positive] Install with MASTER down, SLAVE up"
        uninstall_fornexttest
       
        # Stop the MASTER 
        rlRun "ssh root@$MASTER \"ipactl stop\"" 0 "Stop MASTER IPA server"

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended "
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended " 0 "Installing ipa client and configuring - with all params"

        # Start the MASTER back
        rlRun "ssh root@$MASTERIP \"ipactl start\"" 0 "Start MASTER IPA server"

        verify_install true
    rlPhaseEnd
}




####################################################################################################
#   -S, --no-sssd  Do not configure the client to use SSSD for authentication, use nss_ldap instead.
####################################################################################################
ipaclientinstall_nosssd()
{
    rlPhaseStartTest "ipa-client-install-24- [Positive] Install with no SSSD configured"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true nosssd
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-25- [Positive] Uninstall after install with -no-sssd [Bug 692144]"
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client after install with -no-sssd"
        verify_install false
    rlPhaseEnd
    #TODO: Repeat for --no-sssd?
}

#######################################################
#  --f, --force Force the settings even if errors occur
#######################################################
# includes positive and negative tests to force reinstalling and uninsatlling multiple times.
ipaclientinstall_force()
{
    rlPhaseStartTest "ipa-client-install-26- [Negative] Reinstall IPA Client" 
      install_fornexttest
      # A second install will indicate it is already installed.
      command="ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER"
      expmsg="IPA client is already configured on this system."
      rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for reinstall of IPA Install"
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-27- [Positive] Reinstall Client with force" 
      # But now force it to install even though it has been previously installed here.
      rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER -f"
      rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER -f" 0 "Installing ipa client and configuring - second time - force it"
      verify_install true force
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-28- [Positive] Uninstall IPA Client after installing with -f [Bug 690185]" 
       rlLog "EXECUTING: ipa-client-install --uninstall -U"
       command="ipa-client-install --uninstall -U"
       rlRun "$command" 0 "Uninstalling ipa client - after a force install"
       verify_install false
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-29- [Negative] Uninstall IPA Client twice" 
       command="ipa-client-install --uninstall -U"
       expmsg="IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_force.$RANDOM.out
       rlLog "EXECUTING: ipa-client-install --uninstall -U"
       qaExpectedRun "$command" "$tmpout" 2 "Verify expected error message for non-existent IPA Install" "$expmsg"
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-30- [Positive] Uninstall non-existent IPA Client with force [Bug 690185]" 
      # But now force it to install even though it has been previously uninstalled here.
      rlLog "EXECUTING: ipa-client-install --uninstall -U -f"
      rlRun "ipa-client-install --uninstall -U --force" 0 "Uninstalling ipa client - second time - force it"
      verify_install false
    rlPhaseEnd
}


##############################################################
# Verify files updated during install and unistall
# Also does kinit to verify the install
# $1: true for install; false for uninstall
# $2: can be one of nosssd, nontp, nontpspecified, mkhomedir, permit, force. 
##############################################################
verify_install()
{
# verify files changed during install/uninstall
   verify_nsswitch $1 $2
   verify_sssd $1 $2 
   verify_authconfig $1 $2

   verify_ntp $1 $2

   verify_krb5 $1 $2
   verify_default $1

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
