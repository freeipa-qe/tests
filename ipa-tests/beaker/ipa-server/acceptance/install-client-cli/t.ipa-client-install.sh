##################################################################
#                      test suite                                #
#   perform the various combinations of install and uninstall    #
#################################################################
ipamastersetup()
{
	rlPhaseStartTest "ipamastersetup - setup stuff on master that strictly requires ipa command"
       rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials before uninstalling"
       create_ipauser $testuser $testuser $testuser $testpwd
	rlPhaseEnd
}

ipamastercleanup()
{
	rlPhaseStartTest "ipamastercleanup - clean up master server"
		# delete the user added for this test
		delete_ipauser	$testuser
	rlPhaseEnd
}

ipaclientinstall()
{

   install_setup
#   -U, --unattended  Unattended installation. The user will not be prompted.
   ipaclientinstall_adminpwd

#   install with multiple params including
#   --ntp-server=NTP_SERVER Configure ntpd to use this NTP server.
   ipaclientinstall_allparam

   #--uninstall Remove the IPA client software and restore the configuration to the pre-IPA state.
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

# Bug 852746 RHEL5 ipa-client-install --no-sssd fails because of authconfig --enableforcelegacy option
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

# Bug 817869 - Clean keytabs before installing new keys into them 
      ipaclientinstall_dirty_keytab

#  --preserve-sssd     Preserve old SSSD configuration if possible
      ipaclientinstall_preservesssd

# Bug 753526 - ipa-client-install rejects machines with hostname as localhost or localhost.localdomain #Added by Kaleem
      ipaclientinstall_client_hostname_localhost

# Bug 845691 - ipa-client-install Failed to obtain host TGT
	ipaclientinstall_bugcheck_845691_fulltest

# Bug 790105 - Filter inappropriate address for dns dynamic update
       ipaclientinstall_bugcheck_790105

# Bug 817030 - ipa-client-install sets "KerberosAuthenticate no" in sshd.conf 
       ipaclientinstall_bugcheck_817030

# Moved it to be last test because it causes connection failure to IPA Servers, so thats why moved it to last test case even after fixed-primary server test cases
# Moving back here for everything after fixing hang issue with at job to
# stop iptables
   #if [ $slave_count -eq 1 ];then
   ipaclientinstall_server_unreachableserver
   #fi

   install_cleanup

}


install_setup()
{
        echo $SLAVE
        if [ $slave_count -eq 3 ]; then
         SLAVE1=`echo $SLAVE|cut -d " " -f1 | xargs echo`
         SLAVE1IP=$(dig +short $SLAVE1) 
         SLAVE2=`echo $SLAVE|cut -d " " -f2 | xargs echo`
         SLAVE2IP=$(dig +short $SLAVE2) 
         SLAVE3=`echo $SLAVE|cut -d " " -f3 | xargs echo`
         SLAVE3IP=$(dig +short $SLAVE3) 
         SLAVE_ACTIVE=$SLAVE1
         #Stoping ipa sevice on $SLAVE2 and $SLAVE3
         rlRun "echo \"ipactl stop\" > $TmpDir/local.sh"
         rlRun "chmod +x $TmpDir/local.sh"
         rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE2 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA2 IPA server"
         rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE3 'bash -s' < $TmpDir/local.sh" 0 "Stop REPLICA3 IPA server"         
        else
         SLAVE_ACTIVE=`echo $SLAVE|cut -d " " -f1 | xargs echo`
        fi
        echo "Active Slave is $SLAVE_ACTIVE "
    rlPhaseStartSetup "ipa-client-install-Setup "
        rlLog "Setting up Authorized keys"
        SetUpAuthKeys
        rlLog "Setting up known hosts file"
        SetUpKnownHosts

    
        ## Lines to expect to be changed during the isnatllation process
        ## which reference the MASTER. 
        ## Moved them here from data.ipaclientinstall.acceptance since MASTER is not set there.
        #ipa_server_master="_srv_, $MASTER" # sssd.conf updates
        ipa_server_master="$MASTER" # sssd.conf updates
		if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -eq 0 ]; then
			domain_realm_force_master="$MASTER:88 $MASTER:749 ${RELM,,} $RELM $RELM" # krb5.conf updates
		else
			RELMLOWERCASE=$(echo $RELM|tr '[:upper:]' '[:lower:]')
			domain_realm_force_master="$MASTER:88 $MASTER:749 $RELMLOWERCASE $RELM $RELM" # krb5.conf updates
		fi
        slavetoverify=`echo $SLAVE_ACTIVE | sed 's/\"//g' | sed 's/^ //g'`
        #ipa_server_slave="_srv_, $slavetoverify" # sssd.conf updates
        ipa_server_slave="$slavetoverify" # sssd.conf updates
		if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -eq 0 ]; then
			domain_realm_force_slave="$SLAVE_ACTIVE:88 $MASTER:749 ${RELM,,} $RELM $RELM" # krb5.conf updates
		else
			RELMLOWERCASE=$(echo $RELM|tr '[:upper:]' '[:lower:]')
			domain_realm_force_slave="$SLAVE_ACTIVE:88 $MASTER:749 $RELMLOWERCASE $RELM $RELM" # krb5.conf updates
		fi

    rlPhaseEnd
}

install_cleanup()
{
         #Starting ipa sevice on $SLAVE2 and $SLAVE3
        if [ $slave_count -eq 3 ]; then
         sshopts="-o StrictHostKeyChecking=no"
         rlRun "ssh $sshopts root@$SLAVE2 \"ipactl start\"" 
         rlRun "ssh $sshopts root@$SLAVE2 \"echo $ADMINPW|kinit admin\"" 
         rlRun "ssh $sshopts root@$SLAVE2 \"ipa-replica-manage force-sync --from=$MASTER --force \"" 

         rlRun "ssh $sshopts root@$SLAVE3 \"ipactl start\""
         rlRun "ssh $sshopts root@$SLAVE3 \"echo $ADMINPW|kinit admin\"" 
         rlRun "ssh $sshopts root@$SLAVE3 \"ipa-replica-manage force-sync --from=$MASTER --force \"" 
        fi
}

#############################################################################
#   -U, --unattended  Unattended installation. The user will not be prompted.
#############################################################################
ipaclientinstall_adminpwd()
{
    rlPhaseStartTest "ipa-client-install-01- [Positive] Install with admin & password - with -U"
        uninstall_fornexttest
		rlLog "Changing time to make sure client install sets it and doesn't fail"
        rlRun "service ntpd stop" 0 "Stopping the ntp server"
		rlRun "date --set='-2 hours'"
        rlLog "EXECUTING: ipa-client-install -p $ADMINID -w $ADMINPW -U "
        rlRun "ipa-client-install -p $ADMINID -w $ADMINPW -U " 0 "Installing ipa client and configuring - passing admin and password"
        if [ $slave_count -eq 3 ]; then
            ipaclientinstall_bugcheck_905626
        fi
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
       rlRun "cat /etc/resolv.conf"
       rlLog "M=$MASTERIP ; S=$SLAVEIP"
       #ipaddr=$(host -i $CLIENT | awk '{ field = $NF }; END{ print field }')
       ipaddr=$(dig +short $CLIENT A)
       rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER \"echo 'service iptables stop' >> /tmp/at.1.sh\""
       rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER \"at -f /tmp/at.1.sh now + 2 minutes\""
       rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE_ACTIVE \"echo 'service iptables stop' >> /tmp/at.1.sh\""
       rlRun "ssh -o StrictHostKeyChecking=no root@$SLAVE_ACTIVE \"at -f /tmp/at.1.sh now + 2 minutes\""
       rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTER \"iptables -A INPUT -s $ipaddr -j REJECT\"" 0 "Start Firewall on MASTER IPA server"
       rlRun "ssh  -o StrictHostKeyChecking=no root@$SLAVE_ACTIVE \"iptables -A INPUT -s $ipaddr -j REJECT\"" 0 "Start Firewall on SLAVE IPA server"
       rlLog "EXECUTING: ipa-client-install -U"
       command="ipa-client-install -p $ADMINID -w $ADMINPW -U"
       expmsg1="Unable to discover domain, not provided on command line"
       expmsg2="Failed to verify that.*redhat.com is an IPA Server"
       local tmpout=$TmpDir/ipaclientinstall_server_unreachableserver.out
       rlRun "$command > $tmpout 2>&1" 1
       rlRun "cat $tmpout"
       rlLog "Verify expected error message for IPA Install with unreachable server"
       if [ $(grep "$expmsg1" $tmpout|wc -l) -gt 0 ]; then
           rlPass "Expected error seen:  $expmsg1"
       elif [ $(grep "$expmsg2" $tmpout|wc -l) -gt 0 ]; then
           rlPass "Alternate expected error seen due to environment: $expmsg2"	
       else
           rlFail "Unexpected output seen"
           submit_log /var/log/ipaclient-install.log
       fi
	   ipaclientinstall_bugcheck_905626
       rlRun "sleep 150"
       rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTER \"service iptables stop\"" 0 "Stop Firewall on MASTER IPA server"
       rlRun "ssh  -o StrictHostKeyChecking=no root@$SLAVE_ACTIVE \"service iptables stop\"" 0 "Stop Firewall on SLAVE IPA server"
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
       if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
          relminlowercase=$(echo $RELM|tr '[:upper:]' '[:lower:]')
       else
          relminlowercase=`echo ${RELM,,}`
       fi
       rlLog "EXECUTING: ipa-client-install --realm=$relminlowercase"
       command="ipa-client-install --realm=$relminlowercase"
       expmsg="The provided realm name [$relminlowercase] does not match with the discovered one [$RELM]"
       local tmpout=$TmpDir/ipaclientinstall_realm_casesensitive.out

	if [ -f /etc/fedora-release ] ; then
		rlRun "$command > $tmpout 2>&1" 1
		rlAssertGrep "The provided realm name \[$relminlowercase\] does not match discovered one \[$RELM\]" "$tmpout"
	else
       		qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with incorrect case realmname" 
	fi

    rlPhaseEnd
}

ipaclientinstall_invalidrealm()
{
    rlPhaseStartTest "ipa-client-install-12- [Negative] Install with invalid realm"
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install --realm=xxx"
       command="ipa-client-install --realm=xxx"
       expmsg="The provided realm name [xxx] does not match with the discovered one [$RELM]"
       local tmpout=$TmpDir/ipaclientinstall_invalidrealm.out

	if [ -f /etc/fedora-release ] ; then
                rlRun "$command > $tmpout 2>&1" 1
                rlAssertGrep "The provided realm name \[xxx\] does not match discovered one \[$RELM\]" "$tmpout"
	else
	        qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with invalid realmname" 
	fi

    rlPhaseEnd
}

###############################################################################################
#  --hostname The hostname of this server (FQDN). By default of nodename from uname(2) is used. 
#  Bug 690473 - Installing ipa-client indicates DNS is updated for this unknown hostname, but is not on server 
#  Bug 714919 - ipa-client-install should configure hostname
#  Bug 734013 - ipa-client-install breaks network configuration
#  Bug 833505 - ipa-client-install crashes when --hostname is given
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
       expmsg1="Hostname ($CLIENT.nonexistent) not found in DNS"
       expmsg2="Could not update DNS SSHFP records."

		if [ -f /etc/fedora-release ] ; then
			rlRun "$command > $tmpout 2>&1" 
			rlAssertGrep "Hostname ($CLIENT.nonexistent) not found in DNS" "$tmpout"
			rlAssertGrep "Could not update DNS SSHFP records." "$tmpout"
		elif [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
			qaExpectedRun "$command" "$tmpout" 0 "Verify expected message for IPA Install with different hostname" "$expmsg1"
		else
			qaExpectedRun "$command" "$tmpout" 0 "Verify expected message for IPA Install with different hostname" "$expmsg1" "$expmsg2" 
		fi

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
       rlRun "cat $tmpout"

       # clear the host record, there is no DNS record associated for this host
       if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
          rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER \"echo $ADMINPW|kinit admin; ipa host-del $CLIENT.nonexistent\"" 0 "Deleting client record and DNS entry from server"
       else
	      rlRun "ipa host-del $CLIENT.nonexistent" 0 "Deleting client record and DNS entry from server"
       fi
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
       expmsg="Joining realm failed: Incorrect password."
       #expmsg="Joining realm failed: Incorrect password.
#Installation failed. Rolling back changes."
       local tmpout=$TmpDir/ipaclientinstall_password.out
       qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message for IPA Install with password, but missing principal" 
       rlRun "cp /var/log/ipaclient-install.log /var/log/ipaclient-install_password.log"
       rlRun "submit_log /var/log/ipaclient-install_password.log"
       if [ $slave_count -eq 3 ]; then
           ipaclientinstall_bugcheck_905626
       fi
       #rlRun "sleep 1000000"
       
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
        command="ipa-client-install -p $testuserbad -w $testpwd -U" 
		if [ $(grep 5\.[0-9] /etc/redhat-release | wc -l) -gt 0 ]; then
			expmsg="kinit(v5): Client not found in Kerberos database while getting initial credentials"
		else
			expmsg="kinit: Client '$testuserbad@$RELM' not found in Kerberos database while getting initial credentials"
		fi
        local tmpout=$TmpDir/ipaclientinstall_nonexistentprincipal.out
        qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with non-existent principal"
       # rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with non-existent principal"
    rlPhaseEnd
}


# using --principal
ipaclientinstall_nonadminprincipal()
{
    rlPhaseStartTest "ipa-client-install-16- [Negative] Install with principal with no admin priviliges"
       install_fornexttest
       uninstall_fornexttest
       rlLog "EXECUTING: ipa-client-install  --principal $testuser -w $testpwd -U"
       command="ipa-client-install  --principal $testuser -w $testpwd -U" 
       expmsg="Joining realm failed: No permission to join this host to the IPA domain."
       tmpout=$TmpDir/ipaclientinstall_nonadminprincipal.out

        if [ -f /etc/fedora-release ] ; then
                rlRun "$command > $tmpout 2>&1" 1
                rlAssertGrep "Joining realm failed: No permission to join this host to the IPA domain." "$tmpout"
        else
       		qaExpectedRun "$command" "$tmpout" 1 "Verify expected error message for IPA Install with non-admin principal" "$expmsg"
        fi
        if [ $slave_count -eq 3 ]; then
            ipaclientinstall_bugcheck_905626
        fi

       install_fornexttest
       if [ $slave_count -eq 3 ]; then
           ipaclientinstall_bugcheck_905626
       fi
    rlPhaseEnd
}

ipaclientinstall_principalwithinvalidpassword()
{
	rlPhaseStartTest "ipa-client-install-17- [Negative] Install with principal with invalid password"
		uninstall_fornexttest
		rlLog "EXECUTING: ipa-client-install  -p $ADMINID -w $testpwd -U" 
		command="ipa-client-install  -p $ADMINID -w $testpwd -U" 
		if [ $(grep 5\.[0-9] /etc/redhat-release | wc -l) -gt 0 ]; then
			expmsg="kinit(v5): Password incorrect while getting initial credentials"
		else
			expmsg="kinit: Password incorrect while getting initial credentials"
		fi
		tmpout=$TmpDir/ipaclientinstall_principalwithinvalidpassword.out
		qaRun "$command" "$tmpout" 1 $expmsg "Verify expected error message for IPA Install with principal with invalid password" 
        if [ $slave_count -eq 3 ]; then
            ipaclientinstall_bugcheck_905626
        fi
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
        #rlRun "ipa-client-install  -p $ADMINID -w $ADMINPW -U --permit" 0 "Installing ipa client and configure SSSD to permit all access"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --permit" 0 "Installing ipa client and configure SSSD to permit all access"
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
        if [ $slave_count -eq 3 ]; then
            ipaclientinstall_bugcheck_905626
        fi
        verify_install true mkhomedir
    rlPhaseEnd

    rlPhaseStartTest "ipa-client-install-21- [Positive] Uninstall and remove configuration for pam to create home dir"
        if [ $slave_count -eq 3 ]; then
            ipaclientinstall_bugcheck_905626
        fi
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
	sleep 10
        rlLog "EXECUTING: ipa-client-install  -p $ADMINID -w $ADMINPW -U --enable-dns-updates"
        rlRun "ipa-client-install  -p $ADMINID -w $ADMINPW -U --enable-dns-updates" 0 "Installing ipa client and enable dynamic dns updates"
        if [ $slave_count -eq 3 ]; then
            ipaclientinstall_bugcheck_905626
        fi
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

	rpm -q nss-pam-ldapd
	if [ $? = 1 ] ; then
		rlRun "yum install -y nss-pam-ldapd"
	fi

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --no-sssd" 0 "Installing ipa client and configuring - with no SSSD configured"
        verify_install true nosssd
		if [ $(grep "authconfig: error: no such option: --enableforcelegacy" /var/log/ipaclient-install.log|wc -l) -gt 0 ]; then
			rlFail "BZ 852746 found...RHEL5 ipa-client-install --no-sssd fails because of authconfig --enableforcelegacy option"
		else
			rlPass "BZ 852746 not found...no error related to authconfig enableforcelegacy"
		fi
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
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER \"ipa host-del $CLIENT\"" 0 "Delete Client host record from Master"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER \"ipa host-add $CLIENT --random\" > $tmpout" 0 "Get random password"
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

	if [ -f /etc/fedora-release ] ; then 
		rlRun "$command > $tmpout 2>&1" 3
		rlAssertGrep "IPA client is already configured on this system." "$tmpout"
	else
		qaRun "$command" "$tmpout" 3 $expmsg "Verify expected error message for reinstall of IPA Install"
	fi
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
   rlPhaseStartTest "ipa-client-install-32- [Positive] Install with preserve-sssd (BZ 851318)"
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
       rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --preserve-sssd"
       rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER --preserve-sssd" 0 "Installing ipa client with preserve-sssd"
       AVCCHK=$(ausearch -m avc -ts $AVCCHKTS -su root:system_r:sssd_t:s0 -o root:object_r:etc_t:s0 |grep name=\"krb5.conf\"|wc -l)
       if [ $AVCCHK -gt 0 ]; then
           rlFail "BZ 851318 found...RHEL5 ipa-client-install creates krb5.conf with incorrect selinux context"
       else
           rlPass "BZ 851318 not found"
       fi
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
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
        verify_ntpservice true
    rlPhaseEnd

    rlPhaseStartTest "ipa-client-install-33-A [Negative] Verify that ntpdate was not called with the -d option"
        # This test assumes that the date was set back two hourss at the beginning of this test.
        # the current hour should be stored in $currenthour 

        currenthour=$(date +%H) # Get the current hours to be used in a later test
	    rlLog "Current hour is $currenthour, Machine time is $(date)"
	    rlRun "date +%H | grep $currenthour" 0 "Make sure the machine time contains the current hour."
    rlPhaseEnd

    rlPhaseStartTest "ipa-client-install-34- [Negative] Verify ntp service with client uninstall"
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

	if [ -f /etc/fedora-release ] ; then
		# Setting return code as 1 in fedora since installation failure is expected because of 
		# "kinit: Clock skew too great while getting initial credentials"
		# verify_time is success though
	        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER" 1
	else
	        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW -U --server=$MASTER"
	fi

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
      	sleep 5 
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --server=$SLAVE_ACTIVE  -p $ADMINID -w $ADMINPW --unattended "
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --server=$SLAVE_ACTIVE  -p $ADMINID -w $ADMINPW --unattended " 0 "Installing ipa client and configuring - with all params"
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
	local ipalog=/var/log/ipaclient-install.log
    rlPhaseStartTest "ipa-client-install-37- [Positive] Install with MASTER down, SLAVE up [BZ 905626]"
        uninstall_fornexttest
       
        # Stop the MASTER 
        rlRun "ssh -o StrictHostKeyChecking=no  root@$MASTER \"ipactl stop\"" 0 "Stop MASTER IPA server"
		#rlRun "cp /etc/resolv.conf /etc/resolv.conf.withmasterdown"
		#rlRun "echo 'nameserver $SLAVEIP' > /etc/resolv.conf"
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW --unattended"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW --unattended " 0 \
			"Installing ipa client and configuring - with all params"
			
		ipaclientinstall_bugcheck_905626
		submit_log /var/log/ipaclient-install.log

        # Start the MASTER back
        #rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTERIP \"ipactl start\"" 0 "Start MASTER IPA server"
        rlRun "ssh  -o StrictHostKeyChecking=no root@$MASTER \"ipactl start\"" 0 "Start MASTER IPA server"

        verify_install true
    rlPhaseEnd
}

ipaclientinstall_client_hostname_localhost() #Added by Kaleem
{
    rlPhaseStartTest "ipa-client-install-38 (Negative) hostname=localhost or localhost.localdomain - BZ 753526 and 857049(RHEL5)"
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
# check for bug 845691
	if [ "$1" == "true" ]; then
		ipaclientinstall_bugcheck_845691
	fi

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
