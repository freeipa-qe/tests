



##################################################################
#                      test suite                                #
#   perform the various combinations of install and uninstall    #
#################################################################

ipaclientinstall()
{
#   -U, --unattended  Unattended installation. The user will not be prompted.
   ipaclientinstall_adminpwd

#   --ntp-server=NTP_SERVER Configure ntpd to use this NTP server.
   ipaclientinstall_allparam

#   --uninstall Remove the IPA client software and restore the configuration to the pre-IPA state.
   ipaclientinstall_uninstall

   ipaclientinstall_noparam

#   -N, --no-ntp  Do not configure or enable NTP.
   ipaclientinstall_noNTP

#   -S, --no-sssd  Do not configure the client to use SSSD for authentication, use nss_ldap instead.
   ipaclientinstall_nosssd

#   --domain=DOMAIN Set the domain name to DOMAIN 
#   ipaclientinstall_domain #TODO: No test yet
#   ipaclientinstall_domain_casesensitive #TODO: No test yet

#   --server=SERVER Set the IPA server to connect to
#   ipaclientinstall_server_casesensitive #TODO: No test yet 
   ipaclientinstall_server_nodomain 
   ipaclientinstall_server_invalidresolvconf1 
   ipaclientinstall_server_invalidresolvconf2 
   ipaclientinstall_server_invalidresolvconf3


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
    ipaclientinstall_bulkpassword

#   -W  Prompt for the password for joining a machine to the IPA realm.

#   -p, --principal  Authorized kerberos principal to use to join the IPA realm.
   ipaclientinstall_nonexistentprincipal
   ipaclientinstall_nonadminprincipal
   ipaclientinstall_principalwithinvalidpassword


#   --mkhomedir  Configure pam to create a users home directory if it does not exist.
    ipaclientinstall_mkhomedir


#   --enable-dns-updates This option tells SSSD to automatically update DNS with the IP address of this client.
####  Manual test ####
     ipaclientinstall_enablednsupdates

#   --permit Configure  SSSD  to  permit all access. Otherwise the machine will be controlled by the Host-based Access Controls (HBAC) on the IPA server.
    ipaclientinstall_permit


#   Install client with master down
   ipaclientinstall_withmasterdown


#  --f, --force Force the settings even if errors occur
   ipaclientinstall_force 

}

#################################################################################################
#   --uninstall Remove the IPA client software and restore the configuration to the pre-IPA state.
#################################################################################################
ipaclientinstall_uninstall()
{
    rlPhaseStartTest "[Positive] IPA Uninstall"
        install_fornexttest
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        # before uninstalling ipa client, first remove its references from server
    #    rlRun "ipa host-del $CLIENT --updatedns" 0 "Deleting client record and DNS entry from server"
        # now uninstall
        rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client"
        verify_install false
    rlPhaseEnd
}


#############################################################################
#   -U, --unattended  Unattended installation. The user will not be prompted.
#############################################################################
ipaclientinstall_adminpwd()
{
    rlPhaseStartTest "[Positive] IPA Install with admin & password - with -U"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW -U "
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW -U " 0 "Installing ipa client and configuring - passing admin and password"
        verify_install true nontpspecified 
    rlPhaseEnd
}


ipaclientinstall_noparam()
{
    rlPhaseStartTest "[Negative] IPA Install with no param"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install -U "
        command="ipa-client-install -U"
        expmsg="One of password and principal are required."
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no param"
    rlPhaseEnd
}

############################################################

ipaclientinstall_allparam()
{
    rlPhaseStartTest "[Positive] IPA Install with all param"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        verify_install true
    rlPhaseEnd
}


################################################
#   -N, --no-ntp  Do not configure or enable NTP.
################################################
ipaclientinstall_noNTP()
{
    rlPhaseStartTest "[Positive] IPA Install with no NTP configured"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -N -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -N -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client and configuring - with no NTP configured"
        verify_install true nontp
    rlPhaseEnd
    #TODO: Repeat for --no-ntp
}

####################################################################################################
#   -S, --no-sssd  Do not configure the client to use SSSD for authentication, use nss_ldap instead.
####################################################################################################
ipaclientinstall_nosssd()
{
    rlPhaseStartTest "[Positive] IPA Install with no SSSD configured"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true nosssd
    rlPhaseEnd
    #TODO: Repeat for --no-sssd
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
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --server=xxx "
       command="ipa-client-install --server=xxx"
       expmsg="Usage: ipa-client-install [options]

ipa-client-install: error: --server cannot be used without providing --domain"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with no domain"
    rlPhaseEnd
}

ipaclientinstall_server_invalidresolvconf1()
{
    rlPhaseStartTest "[Negative] IPA Install with invalid server, with invalid resolv.conf 1"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --server=xxx --domain=xxx "

       # for this negative test, invalidate resolv.conf 
       # get the Master's IP address
       ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | grep A | awk '{print $5}')
       rlLog "MASTER IP address is $ipaddr"
       update_resolvconf $ipaddr false 

       command="ipa-client-install --server=xxx --domain=xxx"
       expmsg="Retrieving CA from xxx failed."
       local tmpout=$TmpDir/ipaclientinstall_server_invalidresolvconf1.$RANDOM.out
       qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message for IPA Install with invalid resolv.conf 1"

       # restore back the resolv.conf
       update_resolvconf $ipaddr true 

    rlPhaseEnd
}

ipaclientinstall_server_invalidresolvconf2()
{
    rlPhaseStartTest "[Negative] IPA Install with the server, but with invalid resolv.conf 2"
       uninstall_fornexttest

      # for this negative test, invalidate resolv.conf 
      # get the Master's IP address
      ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | grep A | awk '{print $5}')
      rlLog "MASTER IP address is $ipaddr"
      update_resolvconf $ipaddr false 

       serverparam=`echo $MASTER  | cut -d "." -f1 | xargs echo`
       command="ipa-client-install --server=$serverparam --domain=$DOMAIN"
       expmsg="root        : ERROR    LDAP Error: Connect error: TLS: hostname does not match CN in peer certificate
Failed to verify that rhel61-server is an IPA Server.
This may mean that the remote server is not up or is not reachable
due to network or firewall settings." 
       rlLog "EXECUTING: ipa-client-install --server=$serverparam --domain=$DOMAIN "
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with invalid resolv.conf 2"
      
       # restore back the resolv.conf
       update_resolvconf $ipaddr true 

    rlPhaseEnd
}

ipaclientinstall_server_invalidresolvconf3()
{
    rlPhaseStartTest "[Negative] IPA Install with the server, but with invalid resolv.conf 3"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --server=$MASTER  --domain=$DOMAIN"

       # for this negative test, invalidate resolv.conf 
       # get the Master's IP address
       ipaddr=$(dig +noquestion $MASTER  | grep $MASTER | grep IN | grep A | awk '{print $5}')
       rlLog "MASTER IP address is $ipaddr"
       update_resolvconf $ipaddr false 

       local expfile=/tmp/ipaclientinstall.exp
       rm -rf $expfile
       command="ipa-client-install --server=$MASTER --domain=$DOMAIN"
       echo "spawn -noecho $command" >> $expfile
       echo 'expect "*: "' >> $expfile
       echo 'send -- "\r"' >> $expfile
       echo 'expect eof ' >> $expfile
       expectcommand="/usr/bin/expect $expfile"
       local tmpout=$TmpDir/ipaclientinstall_server_invalidresolvconf3.$RANDOM.out
       expmsg="The failure to use DNS to find your IPA server indicates that your
resolv.conf file is not properly configured.

Autodiscovery of servers for failover cannot work with this configuration.

If you proceed with the installation, services will be configured to always
access the discovered server for all operation and will not fail over to
other servers in case of failure.

Proceed with fixed values and no DNS discovery? [no]: "
       qaExpectedRun "$expectcommand" "$tmpout" 0 "Verify expected error message for IPA Install with invalid resolv.conf" "$expmsg"
      
       # restore back the resolv.conf
       update_resolvconf $ipaddr true 

    rlPhaseEnd
}


#########################################################
# --realm=REALM_NAME Set the IPA realm name to REALM_NAME 
#########################################################
#negative tests for --realm option
ipaclientinstall_realm_casesensitive()
{
    rlPhaseStartTest "[Negative] IPA Install with incorrect case realmname"
       relminlowercase=`echo ${RELM,,}`
       rlLog "EXECUTING: ipa-client-install --realm=$relminlowercase"
       command="ipa-client-install --realm=$relminlowercase"
       expmsg="ERROR: The provided realm name: [$relminlowercase] does not match with the discovered one: [$RELM]"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with incorrect case realmname"

    rlPhaseEnd
}

ipaclientinstall_invalidrealm()
{
    rlPhaseStartTest "[Negative] IPA Install with invalid realm"
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
    rlPhaseStartTest "[Positive-Negative] IPA Install with invalid hostname"
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

#######################################################
#  --f, --force Force the settings even if errors occur
#######################################################
# includes positive and negative tests to force reinstalling and uninsatlling multiple times.
ipaclientinstall_force()
{
    rlPhaseStartTest "[Negative] Reinstall IPA Client" 
      install_fornexttest
      # A second install will indicate it is already installed.
      command="ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER"
      expmsg="IPA client is already configured on this system."
      rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for reinstall of IPA Install"
    rlPhaseEnd
    rlPhaseStartTest "[Positive] IPA Client with force" 
      # But now force it to install even though it has been previously installed here.
      rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER -f"
      rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER -f" 0 "Installing ipa client and configuring - second time - force it"
      verify_install true force
    rlPhaseEnd
    rlPhaseStartTest "[Negative] Uninstall IPA Client twice" 
       rlLog "EXECUTING: ipa-client-install --uninstall -U"
       command="ipa-client-install --uninstall -U"
       rlRun "$command" 0 "Uninstalling ipa client - after a force install"
       verify_install false
       expmsg="IPA client is not configured on this system."
       local tmpout=$TmpDir/ipaclientinstall_force.$RANDOM.out
       rlLog "EXECUTING: ipa-client-install --uninstall -U"
       qaExpectedRun "$command" "$tmpout" 2 "Verify expected error message for non-existent IPA Install" "$expmsg"
    rlPhaseEnd
    rlPhaseStartTest "[Positive] Uninstall non-existent IPA Client with force" 
      # But now force it to install even though it has been previously uninstalled here.
      rlLog "EXECUTING: ipa-client-install --uninstall -U -f"
      rlRun "ipa-client-install --uninstall -U --force" 0 "Uninstalling ipa client - second time - force it"
      verify_install false
    rlPhaseEnd
}

####################################################################################
#   -w PASSWORD, --password=PASSWORD Password for joining a machine to the IPA realm.
#                                 Assumes bulk password unless principal is also set.
####################################################################################
ipaclientinstall_password()
{
    rlPhaseStartTest "[Negative] IPA Install with password, but missing principal"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --password=$ADMINPW"
       command="ipa-client-install --password $ADMINPW -U"
       expmsg="Joining realm failed: Host is already joined.
Certificate subject base is: O=$RELM"
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with password, but missing principal"
    rlPhaseEnd
}



# To use as bulk pwd:
# On server, 
# ipa host-del rhel61-client.testrelm
#
# and leave DNS entries intact.
# Then,
# ipa host-add --random rhel61-client.testrelm
#
# this generates a bulk pwd. Use this (if needed within quotes) to install client with just -w
# ipa-client-install -w "Q*<DW%3#%[ x" -d
#
# Uninstall this client using this same password.
#
#
ipaclientinstall_bulkpassword()
{
    rlPhaseStartTest "[Positive] IPA Install with bulk password"
       install_fornexttest
       rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
       rlRun "ipa host-del $CLIENT" 0 " Delete host record from server, and leave DNS entries intact on server"
       hostadd_cmd="ipa host-add --random $CLIENT"
       tmpout=$TmpDir/ipaclientinstall_bulkpassword.out
       rlLog "Add host record  and generate random password"
       $hostadd_cmd > $tmpout       
       randompwd=`grep "Random " $tmpout | cut -d ":" -f2 | xargs -0 echo`
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --password=\"$randompwd\""
       rlRun "ipa-client-install --ntp-server=$NTPSERVER  --password=\"$randompwd\" -U"
       verify_install true
    rlPhaseEnd
    rlPhaseStartTest "[Positive] IPA Uninstall with bulk password"
       rlLog "EXECUTING: ipa-client-install --uninstall -U --password=\"$randompwd\""
       rlRun "ipa-client-install --uninstall -U --password=\"$randompwd\" " 0 "Uninstalling ipa client using the random password used to install this client."
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
    rlPhaseStartTest "[Negative] IPA Install with non-existent principal"
        uninstall_fornexttest
        command="ipa-client-install --ntp-server=$NTPSERVER -p $testuser -w $testpwd -U" 
        expmsg="kinit: Client '$testuser@$RELM' not found in Kerberos database while getting initial credentials"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with non-existent principal"
    rlPhaseEnd
}


# using --principal
ipaclientinstall_nonadminprincipal()
{
    rlPhaseStartTest "[Negative] IPA Install with principal with no admin priviliges"
       install_fornexttest
       rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
       rlRun "ipa user-add --first=$testuser --last=$testuser $testuser" 0 "Add new user"
       rlRun "ipa passwd $testuser $testpwd" 0 "Set new user's password"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER --principal $testuser -w $testpwd -U"
       command="ipa-client-install --ntp-server=$NTPSERVER --principal $testuser -w $testpwd -U" 
       expmsg="Joining realm failed because of failing XML-RPC request.
  This error may be caused by incompatible server/client major versions."
       tmpout=$TmpDir/ipaclientinstall_nonadminprincipal.out
       qaExpectedRun "$command" "$tmpout" 1 "Verify expected error message for IPA Install with non-admin principal" "$expmsg"

       # delete the user added for this test
       install_fornexttest
       rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
       rlRun "ipa user-del $testuser" 0 "Delete the newly added user" 
    rlPhaseEnd
}

ipaclientinstall_principalwithinvalidpassword()
{
    rlPhaseStartTest "[Negative] IPA Install with principal with invalid password"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $testpwd -U" 
       command="ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $testpwd -U" 
       expmsg="kinit: Password incorrect while getting initial credentials"
       tmpout=$TmpDir/ipaclientinstall_principalwithinvalidpassword.out
       rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with principal with invalid password"
       #qaExpectedRun "$command" "$tmpout" 1 "Verify expected error message for IPA Install with principal with invalid password" "$expmsg"
    rlPhaseEnd
}


#############################################################################################
#   --permit Configure  SSSD  to  permit all access. Otherwise the machine will be controlled
#             by the Host-based Access Controls (HBAC) on the IPA server.
#############################################################################################
ipaclientinstall_permit()
{
    rlPhaseStartTest "[Positive] IPA Install and configure SSSD to permit all access"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --permit"
        rlRun "ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --permit" 0 "Installing ipa client and configure SSSD to permit all access"
        verify_install true permit
    rlPhaseEnd
    rlPhaseStartTest "[Positive] IPA Uninstall and disable SSSD to permit all access "
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
    rlPhaseStartTest "[Positive] IPA Install and configure pam to create home dir if it does not exist"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --mkhomedir"
        rlRun "ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --mkhomedir" 0 "Installing ipa client and configuring pam to create home dir if it does not exist"
        verify_install true mkhomedir
    rlPhaseEnd
    rlPhaseStartTest "[Positive] IPA Uninstall and remove configuration for pam to create home dir"
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
    rlPhaseStartTest "[Positive] IPA Install and enable dynamic dns updates"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --enable-dns-updates"
        rlRun "ipa-client-install --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --enable-dns-updates" 0 "Installing ipa client and enable dynamic dns updates"
        verify_install true enablednsupdates
    rlPhaseEnd
    rlPhaseStartTest "[Positive] IPA Uninstall and disable dynamic dns updates"
        rlLog "EXECUTING: ipa-client-install --uninstall -U"
        rlRun "ipa-client-install --uninstall -U" 0 "Uninstalling ipa client and disable dynamic dns updates"
        verify_install false enablednsupdates
    rlPhaseEnd
}




#####################################
# TODO: When server is not configured with DNS Discovery
######################################


######################################
# TODO: Server and Client in different domain
######################################


##########################################
# Client Install with primary down, replica up
##########################################
ipaclientinstall_withmasterdown()
{
    rlPhaseStartTest "[Positive] IPA Install with MASTER down, SLAVE up"
#        uninstall_fornexttest
       
        # Stop the MASTER 
        rlRun "ssh root@$MASTER \"ipactl stop\"" 0 "Stop MASTER IPA server"

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"

        # Start the MASTER back
        rlRun "ssh root@$MASTER \"ipactl start\"" 0 "Stop MASTER IPA server"

        verify_install true
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
