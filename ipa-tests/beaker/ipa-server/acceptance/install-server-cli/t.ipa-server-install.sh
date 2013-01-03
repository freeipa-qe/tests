
##################################################################
#                      test suite                                #
#   perform the various combinations of install and uninstall    #
#################################################################

ipaserverinstall()
{

     setup

#  --version             show program's version number and exit
    ipaserver_version

    ipaserverinstall_default

#  --uninstall           uninstall an existing installation
     ipaserver_uninstall

#  -U, --unattended      unattended installation never prompts the user
    ipaserverinstall_unattended


#  --hostname=HOST_NAME  fully qualified name of server
    ipaserverinstall_hostname
    ipaserverinstall_mixedcasehostname

#  -p DM_PASSWORD, --ds-password=DM_PASSWORD      admin password
#  -P MASTER_PASSWORD, --master-password=MASTER_PASSWORD     kerberos master password (normally autogenerated)
#  -a ADMIN_PASSWORD, --admin-password=ADMIN_PASSWORD   admin user kerberos password
     ipaserverinstall_password

#  -r REALM_NAME, --realm=REALM_NAME    realm name
    ipaserverinstall_realm

#  --setup-dns           configure bind with our zone
    ipaserverinstall_setupdns

#  --ip-address=IP_ADDRESS     Master Server IP Address
     ipaserverinstall_ipaddress
#     Add test to verify: bug 696268: IPA server install with DNS setup, and with --ip-address cannot resolve hostnames
     ipaserverinstall_invalidipaddress


#  --no-forwarders       Do not add any DNS forwarders, use root servers
    ipaserverinstall_noforwarders

#  --no-reverse          Do not create reverse DNS zone
     ipaserverinstall_noreverse

#  -N, --no-ntp          do not configure ntp
     ipaserverinstall_nontp

#  --zonemgr=ZONEMGR     DNS zone manager e-mail address. Defaults to root
     ipaserverinstall_withzonemgr
#     Add test to verify: bug 693771 : Preinstall check needed if zonemgr has special char
     ipaserverinstall_withinvalidzonemgr

#  --subject=SUBJECT     The certificate subject base (default O=<realm-name>)
     ipaserverinstall_subject
#     Add test to verify: bug 696282 : Preinstall check needed if subject is not specified in required format
     ipaserverinstall_invalidsubject

#  --idstart=IDSTART     The starting value for the IDs range (default random)
#  --idmax=IDMAX         The max value value for the IDs range (default: idstart+199999)
    ipaserverinstall_id

#  --no_hbac_allow       Don't install allow_all HBAC rule
     ipaserverinstall_nohbacallow

#  --no-host-dns         Do not use DNS for hostname lookup during installation
#    Add test to verify:  bug 707229 : ipa-server-install with --no-host-dns still checks DNS : Also look at bug 729377
     ipaserverinstall_nohostdns
     ipaserverinstall_nohostsentry
     ipaserverinstall_nohostdns_nohostsentry

#  Test for Bug 811295 - Installation fails when CN is set in certificate subject base 
     ipaserverinstall_set_cn

#  --no-ui-redirect      Do not automatically redirect to the Web UI.
     ipaserverinstall_nouiredirect

#  --reverse-zone=REVERSE_ZONE  The reverse DNS zone to use
#     Add test to verify: bug 729166 : ipa-server-install creates wrong reverse zone record in LDAP
      ipaserverinstall_reversezone

#   --zone-refresh=ZONE_REFRESH Number of seconds between regular checks for new DNS zones.
      ipaserverinstall_zonerefresh

#     Add test to verify: bug 681978 : Uninstalling client if the server is installed should be prevented
      ipaclient_uninstall

#     Bug 826152 - zonemgr is set to default for reverse zone even with --zonemgr 
      ipaserverinstall_bz826152

#     Bug 827321 - ipa-server-install does not fill the default value for --subject option and it crashes later.
      ipaserverinstall_bz827321

#     Add test to verify: bug 740403 : invalid Directory Manager password causes ipaserver-install to fail with "Exception in CertSubjectPanel(): java.lang.IndexOutOfBoundsException"
#     Install using DM password with backslash

#     Add test to verify: bug 742875 : named fails to start after installing ipa server when short hostname preceeds fqdn in /etc/hosts. 
      ipaserverinstall_shorthostname
	

 
  --selfsign            Configure a self-signed CA instance rather than a dogtag CA
    ipaserverinstall_selfsign
# This should be last test - then run IPA Functional tests against this server

}

setup()
{
   rlPhaseStartSetup
       # edit hosts file and resolv file before starting tests
       rlRun "fixHostFile" 0 "Set up /etc/hosts"
       rlRun "fixhostname" 0 "Fix hostname"
       rlRun "fixResolv" 0 "fixing the resolv.conf to contain the correct nameserver lines"
       rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
    
       ## Lines to expect to be changed during the isnatllation process
       ## which reference the MASTER. 
       ## Moved them here from data.ipaclientinstall.acceptance since MASTER is not set there.
       # 2.0 ipa_server="_srv_, $MASTER" # sssd.conf updates
       ipa_server="$MASTER" # sssd.conf updates
    rlPhaseEnd
}

###############################################################
#  --version             show program's version number and exit
###############################################################
ipaserver_version()
{
    rlPhaseStartTest "ipa-server-install - 01 - [Positive] Verify version "
        command="ipa-server-install --version"
        local tmpout=$TmpDir/ipaserverinstall_version.out
        qaExpectedRun "$command" "$tmpout" 0 "Verify version for ipa-server-install" "$VERSION" 
    rlPhaseEnd
}
#############################################################################
#   
#  -n DOMAIN_NAME, --domain=DOMAIN_NAME       domain name
#  --setup-dns           configure bind with our zone
#  --forwarder=FORWARDERS     Add a DNS forwarder
#############################################################################
ipaserverinstall_default()
{
    rlPhaseStartTest "ipa-server-install - 02 - [Positive] Install "
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_default.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server" 
        verify_install true tmpout 
    rlPhaseEnd
}

###########################################################
#  --uninstall           uninstall an existing installation
###########################################################
ipaserver_uninstall()
{
    rlPhaseStartTest "ipa-server-install - 03 - [Positive] Uninstall "
        install_fornexttest
        local tmpout=$TmpDir/ipaserver_uninstall.out
        rlLog "EXECUTING: ipa-server-install --uninstall -U"
        rlRun "ipa-server-install --uninstall -U" 0 "Uninstalling ipa server" 
        verify_install false tmpout 
    rlPhaseEnd
}

#######################################################################
#  -U, --unattended      unattended installation never prompts the user
#######################################################################
ipaserverinstall_unattended()
{
    rlPhaseStartTest "ipa-server-install - 04 - [Negative] Unattended Install with missing required params "
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        expmsg="Usage: ipa-server-install [options]

ipa-server-install: error: In unattended mode you need to provide at least -r, -p and -a options"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install in unattended mode"
    rlPhaseEnd
}

#######################################################
#  --hostname=HOST_NAME  fully qualified name of server
#######################################################
ipaserverinstall_hostname()
{
    rlPhaseStartTest "ipa-server-install - 05 - [Negative] Install with incorrect hostname"
        uninstall_fornexttest
         rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$MYHOSTNAME -r $RELM --p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$MYHOSTNAME -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        local tmpout=$TmpDir/ipaserverinstall_hostname.out
        #expmsg="Unable to resolve host name, check /etc/hosts or DNS name resolution"
        expmsg="Unable to resolve IP address for host name"
        qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message when installing with incorrect hostname"
    rlPhaseEnd
}


ipaserverinstall_mixedcasehostname()
{
    rlPhaseStartTest "ipa-server-install - 06 - [Negative] Install with mixed case hostname"
        uninstall_fornexttest
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=${HOSTNAME^} -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        local tmpout=$TmpDir/ipaserverinstall_hostname.out
        expmsg="Invalid hostname '${HOSTNAME^}', must be lower-case."
        qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message when installing with mixed case hostname"
    rlPhaseEnd
}


######################################################################################
#  -p DM_PASSWORD, --ds-password=DM_PASSWORD      admin password
#  -P MASTER_PASSWORD, --master-password=MASTER_PASSWORD     kerberos master password
#                        (normally autogenerated)
#  -a ADMIN_PASSWORD, --admin-password=ADMIN_PASSWORD   admin user kerberos password
######################################################################################
ipaserverinstall_password()
{
    rlPhaseStartTest "ipa-server-install - 07 - [Positive] Install with three different passwords"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_password.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD -r $RELM -p $dm_pw -P $master_pw -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD -r $RELM -p $dm_pw -P $master_pw -a $ADMINPW -U" 0 "Installing ipa server with three different passwords" 
        verify_install true tmpout password
    rlPhaseEnd
}


###################################################
#  -r REALM_NAME, --realm=REALM_NAME    realm name
###################################################
ipaserverinstall_realm()
{
    rlPhaseStartTest "ipa-server-install - 08 - [Positive] Install with realm specified"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_realm.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $MYREALM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $MYREALM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with realm specified" 
        verify_install true tmpout realm 
    rlPhaseEnd
}

#####################################################
#  --setup-dns           configure bind with our zone
#####################################################
ipaserverinstall_setupdns()
{
    rlPhaseStartTest "ipa-server-install - 09 - [Negative] Install with setup-dns"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-server-install --setup-dns -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        command="ipa-server-install --setup-dns -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        expmsg="Usage: ipa-server-install [options]

ipa-server-install: error: You must specify at least one --forwarder option or --no-forwarders option"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with missing options for setup dns" 
    rlPhaseEnd
}

#######################################################
#  --ip-address=IP_ADDRESS     Master Server IP Address
#######################################################
ipaserverinstall_ipaddress()
{
    rlPhaseStartTest "ipa-server-install - 10 - [Negative] Install with diff ip address"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$NEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$NEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        expmsg="Usage: ipa-server-install [options]

ipa-server-install: error: option --ip-address: invalid IP address $NEWIPADDRESS: No network interface matches the provided IP address and netmask"
        rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message for IPA Install with different ip address" 
    rlPhaseEnd
}

ipaserverinstall_invalidipaddress()
{
    rlPhaseStartTest "ipa-server-install - 11 - [Negative] Install with invalid ipaddress" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_invalidipaddress.out
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$ANOTHERNEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        expmsg="ipa-server-install: error: option --ip-address: invalid IP address $ANOTHERNEWIPADDRESS: failed to detect a valid IP address from '$ANOTHERNEWIPADDRESS'"
        qaRun "$command" "$tmpout" 2 "$expmsg" "Verify expected error message for IPA Install with invalid ipaddress"  debug
    rlPhaseEnd


}


########################################################################
#  --no-forwarders       Do not add any DNS forwarders, use root servers
########################################################################
ipaserverinstall_noforwarders()
{
    rlPhaseStartTest "ipa-server-install - 12 - [Positive] Install with no forwarders"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_noforwarders.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --no-forwarders  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --no-forwarders  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with no forwarders"
        verify_install true tmpout noforwarders
    rlPhaseEnd
}

#######################################################
#  --no-reverse          Do not create reverse DNS zone
#######################################################
ipaserverinstall_noreverse()
{
    rlPhaseStartTest "ipa-server-install - 13 - [Positive] Install with no reverse zone"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_noreverse.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --no-reverse -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --no-reverse -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with no reverse zone" 
        verify_install true tmpout noreverse
    rlPhaseEnd
}

###############################################
#   -N, --no-ntp          do not configure ntp
###############################################
ipaserverinstall_nontp()
{
    rlPhaseStartTest "ipa-server-install - 14 - [Positive] Install with no ntp" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nontp.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-ntp -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-ntp -U" 0 "Installing ipa server with no ntp" 
        verify_install true tmpout nontp
    rlPhaseEnd
}


#########################################################################
#  --zonemgr=ZONEMGR     DNS zone manager e-mail address. Defaults to root
#########################################################################
ipaserverinstall_withzonemgr()
{
    rlPhaseStartTest "ipa-server-install - 15 - [Positive] Install with zonemgr" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_zonemgr.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --zonemgr=$non_default_admin_email -U" 
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --zonemgr=$non_default_admin_email -U" 0 "Installing ipa server with zonemgr" 
        verify_install true tmpout zonemgr 
    rlPhaseEnd
}

ipaserverinstall_withinvalidzonemgr()
{
    rlPhaseStartTest "ipa-server-install - 16 - [Negative] Install with invalid zonemgr" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_invalidzonemgr.out
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --zonemgr=$special_char_in_admin_email -U"
        expmsg="error: invalid zonemgr: mail account may only include letters, numbers, -, _ and a dot. There may not be consecutive -, _ and . characters. Its parts may not start or end with - or _"
        qaRun "$command" "$tmpout" 2 "$expmsg" "Verify expected error message for IPA Install with invalid zonemgr"  debug
    rlPhaseEnd
}
#####################################################
#  --subject=SUBJECT     The certificate subject base 
#                        (default O=<realm-name>)
#####################################################
ipaserverinstall_subject()
{
    rlPhaseStartTest "ipa-server-install - 17 - [Positive] Install with subject" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_subject.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$cert_subject -U" 
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$cert_subject -U" 0 "Installing ipa server with subject" 
        verify_install true tmpout subject 
    rlPhaseEnd
}

ipaserverinstall_invalidsubject()
{
    rlPhaseStartTest "ipa-server-install - 18 - [Negative] Install with invalid subject" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_invalidzonemgr.out
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$invalid_cert_subject -U"
        expmsg="ipa-server-install: error: --subject=$invalid_cert_subject has invalid subject base format: malformed RDN string = \"$invalid_cert_subject\""

        qaRun "$command" "$tmpout" 2 "$expmsg" "Verify expected error message for IPA Install with invalid subject"  debug
    rlPhaseEnd

}


########################################################################################
##  --idstart=IDSTART     The starting value for the IDs range (default random)
##  --idmax=IDMAX         The max value value for the IDs range (default: idstart+199999)
########################################################################################
ipaserverinstall_id()
{
    rlPhaseStartTest "ipa-server-install - 19 - [Positive] Install with id start and id max specified" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_id.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --idstart=$idstart --idmax=$idmax -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --idstart=5000 --idmax=5010 -U" 0 "Installing ipa server with id start and id max specified" 
        verify_install true tmpout
        verify_useradd
    rlPhaseEnd
}


###########################################################
#  --no_hbac_allow       Don't install allow_all HBAC rule
###########################################################
ipaserverinstall_nohbacallow()
{
    rlPhaseStartTest "ipa-server-install - 20 - [Positive] Do not Install allow_all HBAC rule"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nohbacallow.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no_hbac_allow -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no_hbac_allow -U" 0 "Do not install allow_all hbac rule"
        verify_install true tmpout nohbac
    rlPhaseEnd
}


###############################################################################
#  --no-host-dns         Do not use DNS for hostname lookup during installation
###############################################################################
ipaserverinstall_nohostdns()
{
    rlPhaseStartTest "ipa-server-install - 21 - [Positive] Install with no host dns" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nohostdns.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-host-dns -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-host-dns -U" 0 "Install with no-host-dns"
        verify_install true tmpout
    rlPhaseEnd
}


ipaserverinstall_nohostsentry()
{
    rlPhaseStartTest "ipa-server-install - 22 - [Negative] Install with no /etc/hosts entry" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nohostdns.out
        hostsFileUpdateForTest
        command="ipa-server-install --hostname=$MASTER -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        expmsg="Unable to resolve host name, check /etc/hosts or DNS name resolution"
        qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message for IPA Install with no /etc/hosts entry for server" debug 
        restoreHostsFile
    rlPhaseEnd
}

ipaserverinstall_nohostdns_nohostsentry()
{
    rlPhaseStartTest "ipa-server-install - 23 - [Positive] Install with --no-host-dns, and with no /etc/hosts entry" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nohostdns.out
        hostsFileUpdateForTest
        command="ipa-server-install --hostname=$MASTER -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-host-dns -U"
        expmsg="Warning: skipping DNS resolution of host $MASTER"
        qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message for IPA Install with no /etc/hosts entry for server" debug
        restoreHostsFile
    rlPhaseEnd
}


####################################################################################
#   --zone-refresh=ZONE_REFRESH Number of seconds between regular checks for new DNS zones.
####################################################################################
ipaserverinstall_zonerefresh()
{
    rlPhaseStartTest "ipa-server-install - 24 - [Positive] Install with --zone-refresh" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_zonerefresh.out
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --zone-refresh=90 -U" 0 "Install with zone-refresh"
        verify_install true tmpout zonerefresh 
    rlPhaseEnd
}


####################################################################################
#  --no-ui-redirect      Do not automatically redirect to the Web UI.
####################################################################################
ipaserverinstall_nouiredirect()
{
    rlPhaseStartTest "ipa-server-install - 25 - [Positive] Install with --no-ui-redirect" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nouiredirect.out
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-ui-redirect -U" 0 "Install with no-ui-redirect"
        verify_install true tmpout noredirect
    rlPhaseEnd
}


####################################################################################
#   bug 681978 : Uninstalling client if the server is installed should be prevented
####################################################################################
ipaclient_uninstall()
{
    rlPhaseStartTest "ipa-server-install - 26 - [Negative] Uninstall ipa-client on a sever machine "
       install_fornexttest
       local tmpout=$TmpDir/ipaclientuninstall.out
       command="ipa-client-install --uninstall -U"
       expmsg="IPA client is configured as a part of IPA server on this system."
       qaRun "$command" "$tmpout" 2 "$expmsg" "Verify expected error message when uninstalling ipa-client on a server machine" debug
    rlPhaseEnd
}

####################################################################################
#   Bug 826152 : zonemgr is set to default for reverse zone even with --zonemgr 
####################################################################################
ipaserverinstall_bz826152()
{
    rlPhaseStartTest "ipa-server-install - BZ 826152"
	kdestroy
	ipa-server-install --uninstall -U
	ipa-server-install --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-ui-redirect -U
	testemail="testemail@$DOMAIN"
	KinitAsAdmin
	ipa-dns-install --zonemgr $testemail -U --forwarder=10.14.63.12
	rlRun "ipa dnszone-find | grep $testemail" 0 "Make sure that the test email seems to have been installed into the useful zone"
	ipa-server-install --uninstall -U
    rlPhaseEnd
}

####################################################################################
# Bug 827321 : ipa-server-install does not fill the default value for --subject option and it crashes later.
####################################################################################
ipaserverinstall_bz827321()
{
    rlPhaseStartTest "ipa-server-install - BZ 827321 : ipa-server-install does not fill the default value for --subject option and it crashes later."
	kdestroy
	ipa-server-install --uninstall -U
	fileout="/dev/shm/bz827321out.txt"
	ipa-server-install --external_cert_file=/root/ipa-ca/ipa.crt --external_ca_file=/root/ipa-ca/ipacacert.asc -p Secret123 -U -a Secret123 -r TESTRELM.COM &> $fileout
	rlRun "grep 'Unexpected error' $fileout" 1 "See if install failed as specified in BZ 827321."
	rlRun "grep 'DEBUG must be str,unicode,tuple, or RDN' /var/log/ipaserver-install.log" 1 "See if ipaserver-install log contains error reported in BZ 827321"
	ipa-server-install --uninstall -U # Cleanup
    rlPhaseEnd
}

####################################################################################
#    bug 742875 : named fails to start after installing ipa server when short 
#    hostname preceeds fqdn in /etc/hosts. 
####################################################################################
ipaserverinstall_shorthostname()
{
    rlPhaseStartTest "ipa-server-install - 27 - [Negative] Install with short hostname first in /etc/hosts"
       uninstall_fornexttest
       hostsFileSwithHostForTest
       local tmpout=$TmpDir/ipashorthostnameinstall.out
       command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 
       expmsg="The host name $HOSTNAME does not match the primary host name $(hostname -s). Please check /etc/hosts or DNS name resolution"
       qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message when installing with short hostnamefirst in /etc/hosts" debug
       restoreHostsFile
    rlPhaseEnd

}


####################################################################################
#   --reverse-zone=REVERSE_ZONE  The reverse DNS zone to use
#    bug 729166 : ipa-server-install creates wrong reverse zone record in LDAP
####################################################################################
ipaserverinstall_reversezone()
{
    rlPhaseStartTest "ipa-server-install - 28 - [Positive] Verify reverse zone and idnsUpdatePolicy after Install" 
       uninstall_fornexttest
       local tmpout=$TmpDir/ipaserverinstall_reversezone.out
       rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --reverse-zone=$reversezone -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with selfsign " 
       verify_kinit $1
       verify_reversezone $tmpout
    rlPhaseEnd
}


####################################################################################
#  --selfsign            Configure a self-signed CA instance rather than a dogtag CA
####################################################################################
ipaserverinstall_selfsign()
{
    rlPhaseStartTest "ipa-server-install - 29 - [Positive] Install with selfsign "
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_selfsign.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --selfsign -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --selfsign -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with selfsign " 
        verify_selfsign_install tmpout
        verify_install true tmpout selfsign 
    rlPhaseEnd
}

####################################################################################
# Test for Bug 811295 - Installation fails when CN is set in certificate subject base 
# This test sets the --subject CN=test
# Now a negative test as this is not allowed via 811295 fix
####################################################################################
ipaserverinstall_set_cn()
{
    rlPhaseStartTest "ipa-server-install - 30 - [Negative] Install test involving setting the CN subject value [bz 811295]"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U --subject CN=Test"
        local tmpout=$TmpDir/ipaserverinstall_cnsubject.out
        local command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject CN=Test -U"
		local expmsg="ipa-server-install: error: --subject=CN=Test has invalid attribute: \"CN\""
        qaRun "$command" "$tmpout" 2 "$expmsg" "Verify expected error message for IPA Install with invalid subject using CN value"  debug
    rlPhaseEnd

}

##############################################################
# Verify files updated during install and unistall
# Also does kinit to verify the install
# $1: true for install; false for uninstall
# $2: the temp file used to write out ipactl status 
# $3: can be one of selfsign, realm, nontp, zonemgr, noforwarders, 
#     newip, subject, allow, password, noreverse, nohbac, noredirect,
#     zonerefresh
##############################################################
verify_install()
{
    verify_kinit $1
    verify_ipactl_status $1 $2 $3 
    if [ "$1" == "true" ] ; then
      verify_sssd $1 $3
    fi
    verify_default $1 $3
    verify_ntp $1 $3
    verify_zonemgr $1 $2 $3
    verify_forwarder $1 $2 $3
    verify_subject $1 $2 $3
    verify_password $1 $2 $3
    verify_kinit $1
    verify_reverse $1 $2 $3
    verify_krb5 $1 $3 
    verify_nsswitch $1
    verify_authconfig $1
    verify_hbac $1 $3
    verify_noredirect $1 $3
    verify_zonerefresh $1 $3
    verify_833515 $1 $3
    verify_782920 $1 $3
    verify_819629 $1 $3
}



# Options below covered in External CA tests
#  --external-ca         Generate a CSR to be signed by an external CA
#  --external_cert_file=EXTERNAL_CERT_FILE
#                        File containing PKCS#10 certificate
#  --external_ca_file=EXTERNAL_CA_FILE
#                        File containing PKCS#10 of the external CA chain
#  --dirsrv_pkcs12=DIRSRV_PKCS12
#                        PKCS#12 file containing the Directory Server SSL
#                        certificate
#  --http_pkcs12=HTTP_PKCS12
#                        PKCS#12 file containing the Apache Server SSL
#                        certificate
#  --dirsrv_pin=DIRSRV_PIN
#                        The password of the Directory Server PKCS#12 file
#  --http_pin=HTTP_PIN   The password of the Apache Server PKCS#12 file
