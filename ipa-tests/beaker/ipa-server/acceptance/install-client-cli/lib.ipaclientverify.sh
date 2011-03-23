#/bin/sh

#ipa default libs

####################################################################
#  Compare files changed during the install/uninstall process
#  $1 Label in the file being checked
#  $2 Value being expected to be in the file for this label
#  $3 Value actually available in the file for this label
#  $4 if true, indicates IPA Client was installed
####################################################################
ipacompare_forinstalluninstall()
{
    local label="$1"
    local expected="$2"
    local actual="$3"
    local installcheck="$4"
    if [ "$actual" = "$expected" ];then
        if $installcheck ; then
            rlPass "[$label] matches :[$expected]"
        else
            rlFail "[$label] still has value: [$actual]. Should have been reset."
        fi
    else
        if $installcheck ; then 
          rlFail "[$label] does NOT match"
          rlLog "expect [$expected], actual got [$actual]"
        else
          rlPass "Value has been cleared and reset for $label"
        fi
    fi
}



uninstall_fornexttest()
{
    if [ -f $DEFAULT  ] ; then
       rlLog "Uninstall for next test"
       # before uninstalling ipa client, first remove its references from server
#       rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
#       rlRun "ipa host-del $CLIENT --updatedns" 0 "Deleting client record and DNS entry from server"
       # now uninstall
       rlRun "ipa-client-install --uninstall -U " 0 "Uninstalling ipa client for next test"
    fi
}

install_fornexttest()
{
       if [ ! -f $DEFAULT  ] ; then
           rlLog "Install for next test"
           # an existing install is required to begin this test.
           rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW -U --server=$MASTER" 0 "Installing ipa client for next test"
       fi
}


verify_kinit()
{
    # kinit as admin
     local installcheck="$1"
     if $installcheck ; then 
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
     else
        rlRun "kinitAs $ADMINID $ADMINPW" 1 "Get administrator credentials after uninstalling"
     fi 
}


verify_default() 
{

    local installcheck="$1"
     if [ -f $DEFAULT ];then
        if $installcheck ; then 
          rlPass "$DEFAULT created"
        else
          rlFail "$DEFAULT not removed when IPA was uninstalled"
        fi
     else
        if $installcheck ; then 
            rlFail "$DEFAULT not created when IPA was installed"
        else
            rlPass "$DEFAULT removed "
        fi
     fi

}

verify_sssd()
{
    local installcheck="$1"

    if [ "$2" == "nosssd" ] ; then
       rlLog "Verify sssd.conf - with no sssd"
       testidprovider=`grep "^id_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "id_provider " "$id_provider_nosssd" "$testidprovider" "$1" 
       testcachecredentials=`grep "^cache_credentials"  $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "cache_credentials " "$cache_credentials_nosssd" "$testcachecredentials" "$1" 
       testauthprovider=`grep "^auth_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "auth_provider " "$auth_provider_nosssd" "$testauthprovider" "$1" 
       testchpassprovider=`grep "^chpass_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "chpass_provider " "$chpass_provider_nosssd" "$testchpassprovider" "$1" 
       testkrb5realm=`grep "^krb5_realm" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "krb5_realm " "$krb5_realm" "$testkrb5realm" "$1" 
    else
       rlLog "Verify sssd.conf - with sssd"
       if [ "$2" == "force" ] ; then
          testcachecredentials=`grep "^cache_credentials"  $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "cache_credentials " "$cache_credentials_force" "$testcachecredentials" "$1" 
          testauthprovider=`grep "^auth_provider" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "auth_provider " "$auth_provider_force" "$testauthprovider" "$1" 
          testchpassprovider=`grep "^chpass_provider" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "chpass_provider " "$chpass_provider_force" "$testchpassprovider" "$1" 
       fi
       testidprovider=`grep "^id_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "id_provider " "$id_provider" "$testidprovider" "$1" 
       testipadomain=`grep "^ipa_domain" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "ipa_domain " "$ipa_domain" "$testipadomain" "$1" 
       if [ $installcheck -a "$2" != "force"] ; then
          testkrb5realm=`grep "^krb5_realm" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "krb5_realm " "$krb5_realm" "$testkrb5realm" "$1" 
       fi
       testipaserver=`grep "^ipa_server" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "ipa_server " "$ipa_server" "$testipaserver" "$1" 
       if [ "$2" == "enablednsupdates" ] ; then
          testipadyndnsupdate=`grep "^ipa_dyndns_update" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "ipa_dyndns_update " "$ipa_dyndns_update" "$testipadyndnsupdate" "$1" 
       fi
       if [ "$2" == "permit" ] ; then
          testaccessproviderpermit=`grep "^access_provider" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "access_provider " "$access_provider_permit" "$testaccessproviderpermit" "$1" 
       else
          testaccessprovider=`grep "^access_provider" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "access_provider " "$access_provider" "$testaccessprovider" "$1" 
       fi
    fi
}

verify_krb5()
{
    rlLog "Verify krb5.conf"

    testdefaultrealm=`grep "default_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "default_realm " "$default_realm" "$testdefaultrealm" "$1" 
    testrdns=`grep "rdns" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "rdns " "$rdns" "$testrdns" "$1" 
    testticketlifetime=`grep "ticket_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "ticket_lifetime " "$ticket_lifetime" "$testticketlifetime" "$1" 
    testforwardable=`grep "forwardable" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "forwardable " "$forwardable" "$testforwardable" "$1" 
    testpkinitanchors=`grep "pkinit_anchors" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "pkinit_anchors " "$pkinit_anchors" "$testpkinitanchors" "$1" 
    testdebug=`grep "debug" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "debug " "$debug_krb5" "$testdebug" "$1" 
    testrenewlifetime=`grep "renew_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "renew_lifetime " "$renew_lifetime" "$testrenewlifetime" "$1" 
    testkrb4convert=`grep "krb4_convert" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "krb4_convert " "$krb4_convert" "$testkrb4convert" "$1" 
    if [ "$2" == "force" ] ; then
       testdnslookupkdc=`grep "dns_lookup_kdc" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_kdc " "$dns_lookup_kdc_force" "$testdnslookupkdc" "$1" 
       testdnslookuprealm=`grep "dns_lookup_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_realm " "$dns_lookup_realm_force" "$testdnslookuprealm" "$1" 
       testdomain=`grep "$DOMAIN" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "domain_realm " "$domain_realm_force" "$testdomain" "$1" 
    else
       testdnslookupkdc=`grep "dns_lookup_kdc" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_kdc " "$dns_lookup_kdc" "$testdnslookupkdc" "$1" 
       testdnslookuprealm=`grep "dns_lookup_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_realm " "$dns_lookup_realm" "$testdnslookuprealm" "$1" 
       testdomain=`grep "$DOMAIN" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "domain_realm " "$domain_realm" "$testdomain" "$1" 
    fi
}



verify_nsswitch()
{

    if [ "$2" == "nosssd" ] ; then
       rlLog "Verify nsswitch.conf - with no sssd"
       testpasswd=`grep "^passwd:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "passwd:" "$passwd_nosssd" "$testpasswd" "$1" 
       testshadow=`grep "^shadow:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "shadow: " "$shadow_nosssd" "$testshadow" "$1"
       testgroup=`grep "^group:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "group: " "$group_nosssd" "$testgroup" "$1"
       testnetgroup=`grep "^netgroup:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "netgroup: " "$netgroup_nosssd" "$testnetgroup" "$1"
    else
       rlLog "Verify nsswitch.conf - with sssd"
       testpasswd=`grep "^passwd:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "passwd:" "$passwd" "$testpasswd" "$1" 
       testshadow=`grep "^shadow:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "shadow: " "$shadow" "$testshadow" "$1"
       testgroup=`grep "^group:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "group: " "$group" "$testgroup" "$1"
       testnetgroup=`grep "^netgroup:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "netgroup: " "$netgroup" "$testnetgroup" "$1"
    fi
}


verify_ntp()
{
   if [ "$2" == "nontp" ] ; then
      rlLog "Verify ntp.conf -with no ntp"
      nontp=false
      testntpserver=`grep "$ntpserver" $NTP`
      ipacompare_forinstalluninstall "ntpserver: " "$ntpserver" "$testntpserver" "$nontp" 
      testntplocalserver=`grep "$ntplocalserver" $NTP`
      ipacompare_forinstalluninstall "ntplocalserver: " "$ntplocalserver" "$testntplocalserver" "$nontp" 
   else
      rlLog "Verify ntp.conf"
      if [ "$2" != "nontpspecified" ] ; then
         testntpserver=`grep "$ntpserver" $NTP`
         ipacompare_forinstalluninstall "ntpserver: " "$ntpserver" "$testntpserver" "$1" 
      fi
      testntplocalserver=`grep "$ntplocalserver" $NTP`
      ipacompare_forinstalluninstall "ntplocalserver: " "$ntplocalserver" "$testntplocalserver" "$1" 
   fi

   
}


verify_authconfig()
{

   if [ "$2" == "nosssd" ] ; then
      rlLog "Verify authconfig -with no sssd"
      testusesssdauth=`grep "USESSSDAUTH"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSDAUTH: " "$USESSSDAUTH_nosssd" "$testusesssdauth" "$1" 
      testusekerberos=`grep "USEKERBEROS"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USEKERBEROS: " "$USEKERBEROS_nosssd" "$testusekerberos" "$1" 
      testusesssd=`grep -w "USESSSD"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSD: " "$USESSSD_nosssd" "$testusesssd" "$1" 
   else
      rlLog "Verify authconfig -with sssd"
      testusesssdauth=`grep "USESSSDAUTH"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSDAUTH: " "$USESSSDAUTH" "$testusesssdauth" "$1" 
      testusekerberos=`grep "USEKERBEROS"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USEKERBEROS: " "$USEKERBEROS" "$testusekerberos" "$1" 
      testusesssd=`grep -w "USESSSD"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSD: " "$USESSSD" "$testusesssd" "$1" 
      if [ "$2" == "mkhomedir" ] ; then
        testusemkhomedir=`grep -w "USEMKHOMEDIR"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
        ipacompare_forinstalluninstall "USEMKHOMEDIR: " "$USEMKHOMEDIR" "$testusemkhomedir" "$1" 
      fi
   fi
}




###############################################################
#  This checks the return code received, and if that 
#  matches the expected, then checks the message.
#  This method only greps for the messsage - so only 
#  partial expected message can be checked.
#
#  Since number of the expected messages can vary depending
#  how many phrases need to be verified, this method is called
#  passing iby passing parameters in order below:
#  1. the command to run
#  2. the temp file to use to write the output of command to
#  3. the expected retun code when the command runs
#  4. a comment to indicate what the command does
#  5. expected messages to verify the output. A list of these 
#  can be passed, and this method will grep for each of them.
###############################################################
qaExpectedRun()
{

    local cmd="$1"
    shift
    local out="$1"
    shift
    local expectCode="$1"
    shift
    local comment="$1"
    shift
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
   

    $cmd >$out
    actualCode=$?
    if [ "$actualCode" = "$expectCode" ];then
        rlLog "return code matches, now check the message"
        while [ "$#" -gt "0" ]
        do 
            expectMsg=$1
            rlLog "expectMsg: $expectMsg"
            if grep -i "$expectMsg" $out 2>&1 >/dev/null
            then
                rlPass "expected return code and msg matches"
            else
                rlFail "return code matches,but message does not match expection";
                debug=true
            fi
            shift
        done

    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug=true
    fi
    # if debug is defined
    if $debug ;then
        echo "--------- expected msg ---------"
        echo "[$expectMsg]"
        echo "========== execution output ==============="
        cat $out
        echo "============== end of output =============="
    fi
} 


########################################################
#  For some negative tests, the resolv.conf 
#  should be invalid.
#  IPA Client install uses this file to do 
#  its Discovery.
#  The method below invalidates or recovers 
#  based on
#  $2 - if true, recover, and have a valid resolv.conf
########################################################
update_resolvconf()
{
    ipaddr=$1
    recover=$2

    if $recover ; then 
       rlLog "Recovering resolv.conf after negative tests"
       sed -i s/"^#nameserver $ipaddr"/"nameserver $ipaddr"/g /etc/resolv.conf
    else
       rlLog "Invalidating resolv.conf for negative tests"
       sed -i s/"^nameserver $ipaddr"/"#nameserver $ipaddr"/g /etc/resolv.conf
    fi

   rlLog "/etc/resolv.conf contains:"
   output=`cat /etc/resolv.conf`
   rlLog "$output"

   return
}

# Note: To use this call, have to install ipa client
# So Keytab now for this client is true
# Using this when the hostname is not same as $CLIENT
verify_keytab_afteruninstall()
{
    client=$1
    out=$2
    command="ipa  host-show --all $client"
    $command > $out
rlLog "Out: $out"
    chkkeytab="Keytab: False"
    if grep -i "$chkkeytab" $out 2>&1 >/dev/null
    then
        rlPass "Keytab for uninstalled client is correct"
    else
        rlFail "Keytab for uninstalled client is not reset";
    fi
}
