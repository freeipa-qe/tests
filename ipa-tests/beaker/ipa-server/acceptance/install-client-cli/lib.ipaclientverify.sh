#/bin/sh

#ipa default libs

ipacompare()
{
    local label="$1"
    local expected="$2"
    local actual="$3"
    if [ "$actual" = "$expected" ];then
        rlPass "[$label] matches :[$expected]"
    else
        rlLog "expect [$expected], actual got [$actual]"
        rlFail "[$label] does NOT match"
    fi
}



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
    local withsssd=$2
    local installcheck="$1"

    if $withsssd ; then 
       rlLog "Verify sssd.conf - with sssd"
       testidprovider=`grep "^id_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "id_provider " "$id_provider" "$testidprovider" "$1" 
       testcachecredentials=`grep "^cache_credentials"  $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "cache_credentials " "$cache_credentials" "$testcachecredentials" "$1" 
       testauthprovider=`grep "^auth_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "auth_provider " "$auth_provider" "$testauthprovider" "$1" 
       testaccessprovider=`grep "^access_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "access_provider " "$access_provider" "$testaccessprovider" "$1" 
       testchpassprovider=`grep "^chpass_provider" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "chpass_provider " "$chpass_provider" "$testchpassprovider" "$1" 
       testipadomain=`grep "^ipa_domain" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "ipa_domain " "$ipa_domain" "$testipadomain" "$1" 
       if $installcheck ; then
          testkrb5realm=`grep "^krb5_realm" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "krb5_realm " "$krb5_realm" "$testkrb5realm" "$1" 
       fi
       testipaserver=`grep "^ipa_server" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "ipa_server " "$ipa_server" "$testipaserver" "$1" 
    else
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
    fi
}

verify_krb5()
{
    rlLog "Verify krb5.conf"

    testdnslookupkdc=`grep "dns_lookup_kdc" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "dns_lookup_kdc " "$dns_lookup_kdc" "$testdnslookupkdc" "$1" 
    testdefaultrealm=`grep "default_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "default_realm " "$default_realm" "$testdefaultrealm" "$1" 
    testdnslookuprealm=`grep "dns_lookup_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "dns_lookup_realm " "$dns_lookup_realm" "$testdnslookuprealm" "$1" 
    testrdns=`grep "rdns" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "rdns " "$rdns" "$testrdns" "$1" 
    testticketlifetime=`grep "ticket_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "ticket_lifetime " "$ticket_lifetime" "$testticketlifetime" "$1" 
    testforwardable=`grep "forwardable" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "forwardable " "$forwardable" "$testforwardable" "$1" 
    testpkinitanchors=`grep "pkinit_anchors" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "pkinit_anchors " "$pkinit_anchors" "$testpkinitanchors" "$1" 
    testdomain=`grep "$DOMAIN" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "$DOMAIN " "$domain_realm" "$testdomain" "$1" 
    testdebug=`grep "debug" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "debug " "$debug" "$testdebug" "$1" 
    testrenewlifetime=`grep "renew_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "renew_lifetime " "$renew_lifetime" "$testrenewlifetime" "$1" 
    testkrb4convert=`grep "krb4_convert" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "krb4_convert " "$krb4_convert" "$testkrb4convert" "$1" 
}



verify_nsswitch()
{

    local withsssd=$2

    if $withsssd ; then 
       rlLog "Verify nsswitch.conf - with sssd"
       testpasswd=`grep "^passwd:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "passwd:" "$passwd" "$testpasswd" "$1" 
       testshadow=`grep "^shadow:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "shadow: " "$shadow" "$testshadow" "$1"
       testgroup=`grep "^group:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "group: " "$group" "$testgroup" "$1"
       testnetgroup=`grep "^netgroup:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "netgroup: " "$netgroup" "$testnetgroup" "$1"
    else
       rlLog "Verify nsswitch.conf - with no sssd"
       testpasswd=`grep "^passwd:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "passwd:" "$passwd_nosssd" "$testpasswd" "$1" 
       testshadow=`grep "^shadow:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "shadow: " "$shadow_nosssd" "$testshadow" "$1"
       testgroup=`grep "^group:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "group: " "$group_nosssd" "$testgroup" "$1"
       testnetgroup=`grep "^netgroup:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
       ipacompare_forinstalluninstall "netgroup: " "$netgroup_nosssd" "$testnetgroup" "$1"
    fi
}


verify_ntp()
{
   rlLog "Verify ntp.conf"

   testntpserver=`grep "$ntpserver" $NTP`
   ipacompare_forinstalluninstall "ntpserver: " "$ntpserver" "$testntpserver" "$1" 
   testntplocalserver=`grep "$ntplocalserver" $NTP`
   ipacompare_forinstalluninstall "ntplocalserver: " "$ntplocalserver" "$testntplocalserver" "$1" 
}


verify_authconfig()
{
   local withsssd=$2

   if $withsssd ; then 
      rlLog "Verify authconfig -with sssd"
      testusesssdauth=`grep "USESSSDAUTH"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSDAUTH: " "$USESSSDAUTH" "$testusesssdauth" "$1" 
      testusekerberos=`grep "USEKERBEROS"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USEKERBEROS: " "$USEKERBEROS" "$testusekerberos" "$1" 
      testusesssd=`grep -w "USESSSD"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSD: " "$USESSSD" "$testusesssd" "$1" 
   else
      rlLog "Verify authconfig -with no sssd"
      testusesssdauth=`grep "USESSSDAUTH"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSDAUTH: " "$USESSSDAUTH_nosssd" "$testusesssdauth" "$1" 
      testusekerberos=`grep "USEKERBEROS"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USEKERBEROS: " "$USEKERBEROS_nosssd" "$testusekerberos" "$1" 
      testusesssd=`grep -w "USESSSD"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      ipacompare_forinstalluninstall "USESSSD: " "$USESSSD_nosssd" "$testusesssd" "$1" 
   fi

}

verify_ldap()
{
# My systems do not have these files..but changes are made to these files...todo: check what these changes are
# /etc/ldap.conf
# /etc/nss_ldap.conf
# /etc/libnss-ldap.conf
# /etc/pam_ldap.conf


###from my no sssd test
#    var=passwd_${nosssd}
#expected_passwd=`eval echo \$$var`

#eval echo \$$var
#
#rlLog " What is this 1: $var"
#rlLog " What is this 2: $expected_passwd"
#rlLog " What is this 3: `eval echo \$$var` "
}




