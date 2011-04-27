
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


#  --no-forwarders       Do not add any DNS forwarders, use root servers
    ipaserverinstall_noforwarders

#  --no-reverse          Do not create reverse DNS zone
     ipaserverinstall_noreverse

#  -N, --no-ntp          do not configure ntp
     ipaserverinstall_nontp

#  --zonemgr=ZONEMGR     DNS zone manager e-mail address. Defaults to root
     ipaserverinstall_withzonemgr

#  --subject=SUBJECT     The certificate subject base (default O=<realm-name>)
     ipaserverinstall_subject

#  --idstart=IDSTART     The starting value for the IDs range (default random)
#  --idmax=IDMAX         The max value value for the IDs range (default: idstart+199999)
    ipaserverinstall_id

#  --no_hbac_allow       Don't install allow_all HBAC rule
     ipaserverinstall_nohbacallow

#  --no-host-dns         Do not use DNS for hostname lookup during installation
      ipaserverinstall_nohostdns

#  --selfsign            Configure a self-signed CA instance rather than a dogtag CA
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
       ipa_server="_srv_, $MASTER" # sssd.conf updates
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
        expmsg="Unable to resolve host name, check /etc/hosts or DNS name resolution"
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
    rlPhaseStartTest "ipa-server-install - 10 - [Positive] Install with diff ip address [Bug 696268]"
        uninstall_fornexttest
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$NEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --ip-address=$NEWIPADDRESS -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with diff ip address"
        verify_install true newip
    rlPhaseEnd
}

########################################################################
#  --no-forwarders       Do not add any DNS forwarders, use root servers
########################################################################
ipaserverinstall_noforwarders()
{
    rlPhaseStartTest "ipa-server-install - 11 - [Positive] Install with no forwarders"
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
    rlPhaseStartTest "ipa-server-install - 12 - [Positive] Install with no reverse zone [Bug 692950]"
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
    rlPhaseStartTest "ipa-server-install - 13 - [Positive] Install with no ntp" 
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
    rlPhaseStartTest "ipa-server-install - 14 - [Positive] Install with zonemgr" 
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
    rlPhaseStartTest "ipa-server-install - 15 - [Positive] Install with subject" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_subject.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$cert_subject -U" 
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --subject=$cert_subject -U" 0 "Installing ipa server with subject" 
        verify_install true tmpout subject 
    rlPhaseEnd
}

########################################################################################
##  --idstart=IDSTART     The starting value for the IDs range (default random)
##  --idmax=IDMAX         The max value value for the IDs range (default: idstart+199999)
########################################################################################
ipaserverinstall_id()
{
    rlPhaseStartTest "ipa-server-install - 16 - [Positive] Install with id start and id max specified" 
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
    rlPhaseStartTest "ipa-server-install - 17 - [Positive] Do not Install allow_all HBAC rule"
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
    rlPhaseStartTest "ipa-server-install - 18 - [Positive] Install with no host dns" 
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_nohostdns.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-host-dns -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD  -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW --no-host-dns -U" 0 "Install with no-host-dns"
        verify_install true tmpout
    rlPhaseEnd
}


####################################################################################
#  --selfsign            Configure a self-signed CA instance rather than a dogtag CA
####################################################################################
ipaserverinstall_selfsign()
{
    rlPhaseStartTest "ipa-server-install - 19 - [Positive] Install with selfsign "
        uninstall_fornexttest
        local tmpout=$TmpDir/ipaserverinstall_selfsign.out
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --selfsign -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --selfsign -r $RELM -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server with selfsign " 
        verify_selfsign_install tmpout
        verify_install true tmpout selfsign 
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
   verify_kinit $1
   verify_ipactl_status $1 $2 $3 
   verify_sssd $1 $3
   verify_default $1 $3
   verify_ntp $1 $3
   verify_zonemgr $1 $2 $3
   verify_forwarder $1 $2 $3
   verify_subject $1 $2 $3
   verify_password $1 $2 $3
   verify_reverse $1 $2 $3
   verify_krb5 $1 $3 
   verify_nsswitch $1
   verify_authconfig $1
   verify_hbac $1 $3
}


#  -n DOMAIN_NAME, --domain=DOMAIN_NAME       domain name


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
