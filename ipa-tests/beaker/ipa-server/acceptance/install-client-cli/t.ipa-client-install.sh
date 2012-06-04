
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

   --uninstall Remove the IPA client software and restore the configuration to the pre-IPA state.
   ipaclientinstall_uninstall

   ipaclientinstall_noparam

#   -N, --no-ntp  Do not configure or enable NTP.
   ipaclientinstall_noNTP

#   --domain=DOMAIN Set the domain name to DOMAIN 
    ipaclientinstall_invaliddomain

#   --server=SERVER Set the IPA server to connect to
   ipaclientinstall_server_nodomain 
   ipaclientinstall_server_invalidserver
#   ipaclientinstall_server_unreachableserver


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

#   -S, --no-sssd  Do not configure the client to use SSSD for authentication, use nss_ldap instead.
   ipaclientinstall_nosssd

#  install with random password
#   ipaclientinstall_randompassword

#  --f, --force Force the settings even if errors occur
   ipaclientinstall_force 

# Bug 714600 - ipa-client-install should configure sssd to store password if offline
#  --no-krb5-offline-passwords Configure SSSD not to store user password when the server is offline
      ipaclientinstall_nokrb5offlinepasswords

# Bug 698219 - Uninstalling ipa-client fails, if it joined replica when being installed
      ipaclientinstall_joinreplica


      ipaclientinstall_withmasterdown

# Bug 736684 - ipa-client-install should sync time before kinit 
       ipaclientinstall_synctime


# Bug 736617 - ipa-client-install mishandles ntp service configuration
       ipaclientinstall_ntpservice     

#  --preserve-sssd     Preserve old SSSD configuration if possible
      ipaclientinstall_preservesssd

# Bug 753526  - ipa-client-install rejects machines with hostname as localhost or localhost.localdomain #Added by Kaleem
      ipaclientinstall_client_hostname_localhost

# Moved it to be last test
   ipaclientinstall_server_unreachableserver

}

setup()
{
    rlPhaseStartSetup "ipa-client-install-Setup "
        rlLog "Setting up Authorized keys"
        SetUpAuthKeys
        rlLog "Setting up known hosts file"
        SetUpKnownHosts

    
        ## Lines to expect to be changed during the isnatllation process
        ## which reference the MASTER. 
        ## Moved them here from data.ipaclientinstall.acceptance since MASTER is not set there.
        ipa_server_master="_srv_, $MASTER" # sssd.conf updates
        domain_realm_force_master="$MASTER:88 $MASTER:749 ${RELM,,} $RELM $RELM" # krb5.conf updates
        slavetoverify=`echo $SLAVE | sed 's/\"//g' | sed 's/^ //g'`
        ipa_server_slave="_srv_, $slavetoverify" # sssd.conf updates
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
        #rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        #rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
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
        rlRun "service ntpd stop" 0 "Stopping the ntp server"
    rlPhaseEnd
}

#######################################################

ipaclientinstall_noparam()
{
    rlPhaseStartTest "ipa-client-install-04- [Negative] Install with no param"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -U "
        command="ipa-client-install -U"
        expmsg="One of password and principal are required.
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_noparam.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with no param" debug 
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
       expmsg="Unable to find IPA Server to join
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_invaliddomain.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid domain" 
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
       local tmpout=$TmpDir/ipaclientinstall_server_nodomain.out
       qaRun "$command" "$tmpout" 2 $expmsg "Verify expected error message for IPA Install with no domain" 
#       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no domain"
    rlPhaseEnd
}

ipaclientinstall_server_invalidserver()
{
    rlPhaseStartTest "ipa-client-install-09- [Negative] Install with invalid server"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --server=xxx --domain=xxx "
       command="ipa-client-install --server=xxx --domain=xxx"
       expmsg="xxx is not an IPA v2 Server.
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_server_invalidserver.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid server" 
    rlPhaseEnd
}


# Bug 745392 - ipa-client-install hangs if the discovered server is unresponsive

ipaclientinstall_server_unreachableserver()
{
    rlPhaseStartTest "ipa-client-install-10- [Negative] Install with unreachable server"
       uninstall_fornexttest
        ipaddr=$(host -i $CLIENT | awk '{ field = $NF }; END{ print field }')
        rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTERIP \"iptables -A INPUT -s $ipaddr -j REJECT\"" 0 "Start Firewall on MASTER IPA server"
        rlRun "ssh  -o StrictHostKeyChecking=no root@$SLAVEIP \"iptables -A INPUT -s $ipaddr -j REJECT\"" 0 "Start Firewall on SLAVE IPA server"
       rlLog "EXECUTING: ipa-client-install -U"
       command="ipa-client-install -p $ADMINID -w $ADMINPW -U"
       expmsg="Unable to discover domain, not provided on command line
Installation failed. Rolling back changes.
IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_server_unreachableserver.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with unreachable server" 

#        rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTERIP \"service iptables stop\"" 0 "Stop Firewall on MASTER IPA server"
#        rlRun "ssh  -o StrictHostKeyChecking=no root@$SLAVEIP \"service iptables stop\"" 0 "Stop Firewall on SLAVE IPA server"
    rlPhaseEnd
}


#########################################################
# --realm=REALM_NAME Set the IPA realm name to REALM_NAME 
#########################################################
#negative tests for --realm option
ipaclientinstall_realm_casesensitive()
{
    rlPhaseStartTest "ipa-client-install-11- [Negative] Install with incorrect case realmname"
       uninstall_fornexttest
       rlLog "/etc/resolv.conf contents are: `cat /etc/resolv.conf`"
       relminlowercase=`echo ${RELM,,}`
       rlLog "EXECUTING: ipa-client-install --realm=$relminlowercase"
       command="ipa-client-install --realm=$relminlowercase"
       expmsg="ERROR: The provided realm name: [$relminlowercase] does not match with the discovered one: [$RELM]"
       local tmpout=$TmpDir/ipaclientinstall_realm_casesensitive.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with incorrect case realmname" 

    rlPhaseEnd
}

ipaclientinstall_invalidrealm()
{
    rlPhaseStartTest "ipa-client-install-12- [Negative] Install with invalid realm"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --realm=xxx"
       command="ipa-client-install --realm=xxx"
       expmsg="ERROR: The provided realm name: [xxx] does not match with the discovered one: [$RELM]"
       local tmpout=$TmpDir/ipaclientinstall_invalidrealm.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid realmname" 
    rlPhaseEnd
}


###############################################################################################
#  --hostname The hostname of this server (FQDN). By default of nodename from uname(2) is used. 
#  Bug 690473 - Installing ipa-client indicates DNS is updated for this unknown hostname, but is not on server 
#  Bug 714919 - ipa-client-install should configure hostname
#  Bug 734013 - ipa-client-install breaks network configuration
###############################################################################################
#negative tests for --hostname option
## in the case below - client is installed, but a DNS entry is not available on server for this client.
ipaclientinstall_hostname()
{
    rlPhaseStartTest "ipa-client-install-13- [Positive-Negative] IPA Install with different hostname"
       uninstall_fornexttest
       local tmpout=$TmpDir/ipaclientinstall_hostname.$RANDOM.out
       command="ipa-client-install --hostname=$CLIENT.nonexistent --server=$MASTER --domain=$DOMAIN -p $ADMINID -w $ADMINPW  -U"
       rlLog "EXECUTING: $command" 
       expmsg1="Warning: Hostname ($CLIENT.nonexistent) not found in DNS"
       expmsg2="Could not update DNS SSHFP records."
       qaExpectedRun "$command" "$tmpout" 0 "Verify expected message for IPA Install with different hostname" "$expmsg1" "$expmsg2" 

       verify_install true nonexistent
       verify_hostname $CLIENT.nonexistent
    
       # now uninstall
       rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
       # verify hostname has been restored after uninstall
       verify_hostname $CLIENT
    
       # after uninstall of this - verify keytab for this client is set false on server 
       rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
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
    rlPhaseStartTest "ipa-client-install-14- [Negative] Install with password, but missing principal"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --password=$ADMINPW"
       command="ipa-client-install --password $ADMINPW -U"
       expmsg="Joining realm failed: Incorrect password.
Installation failed. Rolling back changes."
       local tmpout=$TmpDir/ipaclientinstall_password
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with password, but missing principal" 
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
    rlPhaseStartTest "ipa-client-install-15- [Negative] Install with non-existent principal"
        uninstall_fornexttest
        command="ipa-client-install  -p $testuser -w $testpwd -U" 
        expmsg="kinit: Client '$testuser@$RELM' not found in Kerberos database while getting initial credentials"
        local tmpout=$TmpDir/ipaclientinstall_password
        qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with non-existent principal"
       # rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with non-existent principal"
    rlPhaseEnd
}


# using --principal
ipaclientinstall_nonadminprincipal()
{
    rlPhaseStartTest "ipa-client-install-16- [Negative] Install with principal with no admin priviliges"
       install_fornexttest
       create_ipauser $testuser $testuser $testuser $testpwd
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install  --principal $testuser -w $testpwd -U"
       command="ipa-client-install  --principal $testuser -w $testpwd -U" 
       expmsg="Joining realm failed: No permission to join this host to the IPA domain."
       tmpout=$TmpDir/ipaclientinstall_nonadminprincipal.out
       qaExpectedRun "$command" "$tmpout" 1 "Verify expected error message for IPA Install with non-admin principal" "$expmsg"

       # delete the user added for this test
       install_fornexttest
       delete_ipauser $testuser
    rlPhaseEnd
}

ipaclientinstall_principalwithinvalidpassword()
{
    rlPhaseStartTest "ipa-client-install-17- [Negative] Install with principal with invalid password"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install  -p $ADMINID -w $testpwd -U" 
       command="ipa-client-install  -p $ADMINID -w $testpwd -U" 
       expmsg="kinit: Password incorrect while getting initial credentials"
       tmpout=$TmpDir/ipaclientinstall_principalwithinvalidpassword.out
       qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with principal with invalid password" 
    rlPhaseEnd
}


#############################################################################################
#   --permit Configure  SSSD  to  permit all access. Otherwise the machine will be controlled
#             by the Host-based Access Controls (HBAC) on the IPA server.
#############################################################################################
ipaclientinstall_permit()
{
    rlPhaseStartTest "ipa-client-install-18- [Positive] Install and configure SSSD to permit all access"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install  -p $ADMINID -w $ADMINPW -U --permit"
        rlRun "ipa-client-install  -p $ADMINID -w $ADMINPW -U --permit" 0 "Installing ipa client and configure SSSD to permit all access"
        verify_install true permit
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-19- [Positive] Uninstall and disable SSSD to permit all access "
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
    rlPhaseStartTest "ipa-client-install-20- [Positive] Install and configure pam to create home dir if it does not exist"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install  -p $ADMINID -w $ADMINPW -U --mkhomedir"
        rlRun "ipa-client-install  -p $ADMINID -w $ADMINPW -U --mkhomedir" 0 "Installing ipa client and configuring pam to create home dir if it does not exist"
        verify_install true mkhomedir
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-21- [Positive] Uninstall and remove configuration for pam to create home dir"
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
    rlPhaseStartTest "ipa-client-install-22- [Positive] Install and enable dynamic dns updates"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install  -p $ADMINID -w $ADMINPW -U --enable-dns-updates"
        rlRun "ipa-client-install  -p $ADMINID -w $ADMINPW -U --enable-dns-updates" 0 "Installing ipa client and enable dynamic dns updates"
        verify_install true enablednsupdates
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-23- [Positive] Uninstall and disable dynamic dns updates"
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client and disable dynamic dns updates"
        verify_install false enablednsupdates
    rlPhaseEnd
}





####################################################################################################
#   -S, --no-sssd  Do not configure the client to use SSSD for authentication, use nss_ldap instead.
####################################################################################################
ipaclientinstall_nosssd()
{
    rlPhaseStartTest "ipa-client-install-24- [Positive] Install with no SSSD configured"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true nosssd
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-25- [Positive] Uninstall after install with -no-sssd "
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client after install with -no-sssd"
        verify_install false
    rlPhaseEnd
    #TODO: Repeat for --no-sssd?
}

# not running in automation for now, since the password generated sometimes needs to use escape sequence.
ipaclientinstall_randompassword()
{
    rlPhaseStartTest "ipa-client-install-XX- [Positive] Install with random password" 
        local tmpout=$TmpDir/ipaclientinstall_randompassword.out
        rlRun "ssh root@$MASTER \"ipa host-del $CLIENT\"" 0 "Delete Client host record from Master"
        rlRun "ssh root@$MASTER \"ipa host-add $CLIENT --random\" > $tmpout" 0 "Get random password"
        randomPassword=`grep "Random password:" $tmpout | cut -d ":" -f2 | sed s/"^ "//g`
        rlLog "randomPassword: $randomPassword"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  --password=\"$randomPassword\" -U --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  --password=\"$randomPassword\" -U --server=$MASTER" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true
    rlPhaseEnd

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
      command="ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER"
      expmsg="IPA client is already configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_force1.out
       qaRun "$command" "$tmpout" 3 $expmsg "Verify expected error message for reinstall of IPA Install"
#      rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for reinstall of IPA Install"
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-27- [Positive] Reinstall Client with force" 
      # But now force it to install even though it has been previously installed here.
      # Now it behaves same as if a second install is beign attempted.
      rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER -f"
      command="ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER -f"
      expmsg="IPA client is already configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_force1.out
       qaRun "$command" "$tmpout" 3 $expmsg "Verify expected error message for reinstall of IPA Install"
    rlPhaseEnd
    rlPhaseStartTest "ipa-client-install-28- [Positive] Uninstall IPA Client after atemmpting to install with -f" 
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
    rlPhaseStartTest "ipa-client-install-30- [Positive] Uninstall non-existent IPA Client with force" 
      # But now force it to install even though it has been previously uninstalled here.
      rlLog "EXECUTING: ipa-client-install --uninstall -U -f"
       command="ipa-client-install --uninstall -U --force"
       expmsg="IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_force.$RANDOM.out
       qaExpectedRun "$command" "$tmpout" 2 "Verify expected error message for non-existent IPA Install" "$expmsg"
      verify_install false
    rlPhaseEnd
}


#######################################################
#  --no-krb5-offline-passwords Configure SSSD not to store user password when the server is offline
#  Bug 714600 - ipa-client-install should configure sssd to store password if offline
#######################################################
ipaclientinstall_nokrb5offlinepasswords()
{
   rlPhaseStartTest "ipa-client-install-31- [Positive] Install with no-krb5-offline-passwords"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-krb5-offline-passwords"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-krb5-offline-passwords" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true nokrb5offlinepasswords 
    rlPhaseEnd

}


#######################################################
#  --preserve-sssd     Preserve old SSSD configuration if possible
#######################################################
ipaclientinstall_preservesssd()
{
   rlPhaseStartTest "ipa-client-install-32- [Positive] Install with preserve-sssd"
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

     #   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials before installing"

        #install ipa-client with --preserve-sssd
       #saving files to compare for troubleshooting later, if needed
       cp $SSSD $TmpDir
       mv $TmpDir/sssd.conf $TmpDir/sssd.conf_beforeinstall
       cp $KRB5 $TmpDir
       mv $TmpDir/krb5.conf $TmpDir/krb5.conf_beforeinstall
       rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --preserve-sssd"
       rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --preserve-sssd" 0 "Installing ipa client with preserve-sssd"
       cp $SSSD $TmpDir
       mv $TmpDir/sssd.conf $TmpDir/sssd.conf_afterinstall
       cp $KRB5 $TmpDir
       mv $TmpDir/krb5.conf $TmpDir/krb5.conf_afterinstall

        # be able to kinit
          verify_kinit true 

        # verify sssd contents were preserved
        verify_sssd true preserve 

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials before uninstalling"
        uninstall_fornexttest
    rlPhaseEnd
}

#######################################################
# Bug 736617 - ipa-client-install mishandles ntp service configuration
#######################################################
ipaclientinstall_ntpservice()
{
   rlPhaseStartTest "ipa-client-install-33- [Positive] Verify ntp service with client install"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client"
        verify_ntpservice true
   rlPhaseEnd


   rlPhaseStartTest "ipa-client-install-34- [Positive] Verify ntp service with client uninstall"
        uninstall_fornexttest
        verify_ntpservice false 
    rlPhaseEnd
}

     
##############################################################
#Bug 736684 - ipa-client-install should sync time before kinit 
##############################################################
ipaclientinstall_synctime()
{
   rlPhaseStartTest "ipa-client-install-35- [Positive] Verify time is sync'd with client install"
        uninstall_fornexttest

        # uninstall should have stopped the ntpd service. But it didn't, and 
        # for this test - have to make sure we start the test with the service not running.
        rlRun "service ntpd stop" 0 "Stopping the ntp server"

        # set time on this system to be 2 hours ahead
        date --set='+2 hours'
        rlLog "Time on Client is: `date`"

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client"

        # time on this system should match the server time
        verify_time

   rlPhaseEnd
}

##########################################
# Client Install joining replica server specifically, then uninstall 
# Bug 698219 - Uninstalling ipa-client fails, if it joined replica when being installed
##########################################
ipaclientinstall_joinreplica()
{
    rlPhaseStartTest "ipa-client-install-36- [Positive] Install, and join REPLICA, then uninstall"
        uninstall_fornexttest
       
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --server=$SLAVE  -p $ADMINID -w $ADMINPW --unattended "
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --server=$SLAVE  -p $ADMINID -w $ADMINPW --unattended " 0 "Installing ipa client and configuring - with all params"
        verify_install true
  
        # Now uninstall
        uninstall_fornexttest
        verify_install false 

    rlPhaseEnd
}


##########################################
# Client Install with primary down, replica up
##########################################
ipaclientinstall_withmasterdown()
{
    rlPhaseStartTest "ipa-client-install-37- [Positive] Install with MASTER down, SLAVE up"
        uninstall_fornexttest
       
        # Stop the MASTER 
        rlRun "ssh -o StrictHostKeyChecking=no  root@$MASTER \"ipactl stop\"" 0 "Stop MASTER IPA server"

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW --unattended "
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW --unattended " 0 "Installing ipa client and configuring - with all params"

        # Start the MASTER back
        rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTERIP \"ipactl start\"" 0 "Start MASTER IPA server"

        verify_install true
    rlPhaseEnd
}

ipaclientinstall_client_hostname_localhost() #Added by Kaleem
{
    rlPhaseStartTest "ipa-client-install-38 (Negative) hostname=localhost or localhost.localdomain - BZ 753526"
        uninstall_fornexttest
        rlRun "hostname localhost.localdomain"
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER > $TmpDir/temp.out 2>&1" 1 "Installing ipa client where client's hostname is localhost.localdomain"
        rlRun "cat $TmpDir/temp.out"
        rlAssertGrep "Invalid hostname, 'localhost.localdomain' must not be used" "$TmpDir/temp.out"

        rlRun "hostname localhost"
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER > $TmpDir/temp.out 2>&1" 1 "Installing ipa client where client's hostname is localhost"
        rlRun "cat $TmpDir/temp.out"
        rlAssertGrep "Invalid hostname, 'localhost.localdomain' must not be used" "$TmpDir/temp.out"
        rlRun "hostname $CLIENT" 
    rlPhaseEnd
}

##############################################################
# Verify files updated during install and unistall
# Also does kinit to verify the install
# $1: true for install; false for uninstall
# $2: can be one of nosssd, nontp, nontpspecified, mkhomedir, 
#     permit, force, nokrb5offlinepasswords, preserve
##############################################################
verify_install()
{
# verify files changed during install/uninstall
   verify_nsswitch $1 $2
   if [ "$1" == "true" ] ; then
      verify_sssd $1 $2 
   fi
   verify_authconfig $1 $2

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
