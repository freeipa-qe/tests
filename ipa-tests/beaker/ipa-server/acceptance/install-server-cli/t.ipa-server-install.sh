
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

#  -r REALM_NAME, --realm=REALM_NAME    realm name
    ipaserverinstall_realm
    ipaserverinstall_hostname
    ipaserverinstall_mixedcasehostname

#  -U, --unattended      unattended installation never prompts the user
    ipaserverinstall_unattended

#  --setup-dns           configure bind with our zone
    ipaserverinstall_setupdns

#  --ip-address=IP_ADDRESS     Master Server IP Address
     ipaserverinstall_ipaddress


#  --no-forwarders       Do not add any DNS forwarders, use root servers
    ipaserverinstall_noforwarders

#  -N, --no-ntp          do not configure ntp
     ipaserverinstall_nontp

#  --zonemgr=ZONEMGR     DNS zone manager e-mail address. Defaults to root
     ipaserverinstall_withzonemgr

#  --subject=SUBJECT     The certificate subject base (default O=<realm-name>)
     ipaserverinstall_subject

#  --selfsign            Configure a self-signed CA instance rather than a dogtag CA
    ipaserverinstall_selfsign
# This should be last test - then run IPA Functional tests against this server

}

setup()
{
    # edit hosts file and resolv file before starting tests
    rlRun "fixHostFile" 0 "Set up /etc/hosts"
    rlRun "fixhostname" 0 "Fix hostname"
    rlRun "fixResolv" 0 "fixing the resolv.conf to contain the correct nameserver lines"
    rlRun "appendEnv" 0 "Append the machine information to the env.sh with the information for the machines in the recipe set"
    
    ## Lines to expect to be changed during the isnatllation process
    ## which reference the MASTER. 
    ## Moved them here from data.ipaclientinstall.acceptance since MASTER is not set there.
    ipa_server="_srv_, $MASTER" # sssd.conf updates
    ipa_server_slave="_srv_, $SLAVE" # sssd.conf updates
}

###############################################################
#  --version             show program's version number and exit
###############################################################
ipaserver_version()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Verify version "
        command="ipa-server-install --version"
        local tmpout=$TmpDir/ipaserverinstall_version.out
        qaExpectedRun "$command" "$tmpout" 0 "Verify version for ipa-server-install" "$VERSION" 
    rlPhaseEnd
}
#############################################################################
#   
#  --hostname=HOST_NAME  fully qualified name of server
#############################################################################
ipaserverinstall_default()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install "
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_default.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server" 
        verify_install true tmpout 
    rlPhaseEnd
}

#######################################################################
#  -U, --unattended      unattended installation never prompts the user
#######################################################################
ipaserverinstall_unattended()
{
    rlPhaseStartTest "ipa-server-install: 01: [Negative] Unattended Install with missing required params "
        uninstall_fornexttest
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
    rlPhaseStartTest "ipa-server-install: 01: [Negative] Install with incorrect hostname"
        uninstall_fornexttest
         rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$MYHOSTNAME -r $RELM --p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$MYHOSTNAME -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        local tmpout=$TmpDir/ipaserverinstall_hostname.out
        expmsg="Unable to resolve host name, check /etc/hosts or DNS name resolution"
        qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message when installing with incorrect hostname"
    rlPhaseEnd
}


ipaserverinstall_mixedcasehostname()
{
    rlPhaseStartTest "ipa-server-install: 01: [Negative] Install with mixed case hostname"
        uninstall_fornexttest
        command="ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=${HOSTNAME^} -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        local tmpout=$TmpDir/ipaserverinstall_hostname.out
        expmsg="Invalid hostname '${HOSTNAME^}', must be lower-case."
        qaRun "$command" "$tmpout" 1 "$expmsg" "Verify expected error message when installing with incorrect hostname"
    rlPhaseEnd
}

####################################################################################
#  --selfsign            Configure a self-signed CA instance rather than a dogtag CA
####################################################################################
ipaserverinstall_selfsign()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with selfsign "
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_selfsign.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --selfsign -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --selfsign -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with selfsign " 
        verify_selfsign_install tmpout
        verify_install true tmpout selfsign 
    rlPhaseEnd
}



###################################################
#  -r REALM_NAME, --realm=REALM_NAME    realm name
###################################################
ipaserverinstall_realm()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with realm specified"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_selfsign.out
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
    rlPhaseStartTest "ipa-server-install: 01: [Negative] Install with setup-dns"
        uninstall_fornexttest
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
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with diff ip address"
        uninstall_fornexttest
        rlLog "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$NEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$NEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with diff ip address"
        verify_install true newip
    rlPhaseEnd
}

########################################################################
#  --no-forwarders       Do not add any DNS forwarders, use root servers
########################################################################
ipaserverinstall_noforwarders()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with no forwarders"
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_noforwarders.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --no-forwarders  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --no-forwarders  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with no forwarders"
        verify_install true tmpout noforwarders
    rlPhaseEnd
}


###############################################
#   -N, --no-ntp          do not configure ntp
###############################################
ipaserverinstall_nontp()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with no ntp" 
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
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with zonemgr" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_zonemgr.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --zonemgr=$non_default_admin_email -U" 
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --zonemgr=$non_default_admin_email -U" 0 "Installing ipa server with zonemgr" 
        verify_install true tmpout zonemgr 
    rlPhaseEnd
}

#####################################################
#  --subject=SUBJECT     The certificate subject base 
#                        (default O=<realm-name>)
#####################################################
ipaserverinstall_subject()
{
    rlPhaseStartTest "ipa-server-install: 01: [Positive] Install with subject" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_subject.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$cert_subject -U" 
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$cert_subject -U" 0 "Installing ipa server with subject" 
        verify_install true tmpout subject 
    rlPhaseEnd
}

##############################################################
# Verify files updated during install and unistall
# Also does kinit to verify the install
# $1: true for install; false for uninstall
# $2: the temp file used to write out ipactl status 
# $3: can be one of selfsign, realm. 
##############################################################
verify_install()
{
   verify_kinit
   verify_ipactl_status $2 $3 
   verify_sssd $1 $3
   verify_default $1 $3
   verify_ntp $1 $3
   verify_zonemgr $1 $2 $3
   verify_forwarder $1 $2 $3
   verify_subject $1 $2 $3
   verify_krb5 $1 
   verify_nsswitch $1
   verify_authconfig $1
}


#  -h, --help            show this help message and exit
#  -n DOMAIN_NAME, --domain=DOMAIN_NAME
#                        domain name
#  -p DM_PASSWORD, --ds-password=DM_PASSWORD
#                        admin password
#  -P MASTER_PASSWORD, --master-password=MASTER_PASSWORD
#                        kerberos master password (normally autogenerated)
#  -a ADMIN_PASSWORD, --admin-password=ADMIN_PASSWORD
#                        admin user kerberos password
#  -d, --debug           print debugging information
#  --setup-dns           configure bind with our zone
#  --forwarder=FORWARDERS
#                        Add a DNS forwarder
#  --no-reverse          Do not create reverse DNS zone
#  --uninstall           uninstall an existing installation
#  --no-host-dns         Do not use DNS for hostname lookup during installation
#  --idstart=IDSTART     The starting value for the IDs range (default random)
#  --idmax=IDMAX         The max value value for the IDs range (default:
#                        idstart+199999)
#  --no_hbac_allow       Don't install allow_all HBAC rule


### TODO: Later - when testing with external certs
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
