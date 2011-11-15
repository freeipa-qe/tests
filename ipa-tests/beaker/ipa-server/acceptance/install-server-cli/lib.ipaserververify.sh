#/bin/sh

#ipa default libs

####################################################################
#  Compare files changed during the install/uninstall process
#  $1 Label in the file being checked
#  $2 Value being expected to be in the file for this label
#  $3 Value actually available in the file for this label
#  $4 if true, indicates IPA Server was installed
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
       rlRun "ipa-server-install --uninstall -U " 0 "Uninstalling ipa server for next test"
    fi
}

install_fornexttest()
{
    if [ ! -f $DEFAULT  ] ; then
        rlLog "EXECUTING: ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
        rlRun "ipa-server-install --setup-dns --forwarder=$DNSFORWARD --hostname=$HOSTNAME -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" 0 "Installing ipa server" 
    fi
}

verify_kinit()
{
   rlLog "Verify kinit"

    # kinit as admin
     local installcheck="$1"
     if $installcheck ; then 
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials after installing"
     else
        rlRun "kinitAs $ADMINID $ADMINPW" 1 "Did not get administrator credentials after uninstalling"
     fi 
}


verify_default() 
{
    rlLog "Verify default.conf"

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
     if [ "$2" == "realm" ]; then
        testbasedn=`grep "^basedn"  $DEFAULT | cut -d "=" -f 2,3 | xargs echo`
        ipacompare_forinstalluninstall "basedn " "$basedn" "$testbasedn" "$1" 
        testrealm=`grep "^realm"  $DEFAULT | cut -d "=" -f2 | xargs echo`
        ipacompare_forinstalluninstall "realm " "$realm" "$testrealm" "$1" 
        testdomain=`grep "^domain"  $DEFAULT | cut -d "=" -f2 | xargs echo`
        ipacompare_forinstalluninstall "domain " "$domain" "$testdomain" "$1" 
     fi
}

verify_sssd()
{
     rlLog "Verify sssd.conf"

     testcachecredentials=`grep "^cache_credentials"  $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "cache_credentials " "$cache_credentials" "$testcachecredentials" "$1" 
     local installcheck="$1"
     if $installcheck ; then
        if [ "$2" == "realm" ] ; then
           testkrb5realm=`grep "^krb5_realm" $SSSD | cut -d "=" -f2 | xargs echo`
           ipacompare_forinstalluninstall "krb5_realm " "$krb5_realm_myrealm" "$testkrb5realm" "$1" 
        else
           testkrb5realm=`grep "^krb5_realm" $SSSD | cut -d "=" -f2 | xargs echo`
           ipacompare_forinstalluninstall "krb5_realm " "$krb5_realm" "$testkrb5realm" "$1" 
        fi
     fi
     testipadomain=`grep "^ipa_domain" $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "ipa_domain " "$ipa_domain" "$testipadomain" "$1" 
     testidprovider=`grep "^id_provider" $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "id_provider " "$id_provider" "$testidprovider" "$1" 
     testauthprovider=`grep "^auth_provider" $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "auth_provider " "$auth_provider" "$testauthprovider" "$1" 
     testaccessproviderpermit=`grep "^access_provider" $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "access_provider " "$access_provider" "$testaccessproviderpermit" "$1" 
     testchpassprovider=`grep "^chpass_provider" $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "chpass_provider " "$chpass_provider" "$testchpassprovider" "$1" 
     testipaserver=`grep "^ipa_server" $SSSD | cut -d "=" -f2 | xargs echo`
     ipacompare_forinstalluninstall "ipa_server " "$ipa_server" "$testipaserver" "$1" 
}

verify_krb5()
{
    rlLog "Verify krb5.conf"

    if [ "$2" == "realm" ] ; then
       testdefaultrealm=`grep "default_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "default_realm " "$default_myrealm" "$testdefaultrealm" "$1" 
    else
       testdefaultrealm=`grep "default_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "default_realm " "$default_realm" "$testdefaultrealm" "$1" 
    fi
    testrdns=`grep "rdns" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "rdns " "$rdns" "$testrdns" "$1" 
    testforwardable=`grep "forwardable" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "forwardable " "$forwardable" "$testforwardable" "$1" 
    testpkinitanchors=`grep "pkinit_anchors" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "pkinit_anchors " "$pkinit_anchors" "$testpkinitanchors" "$1" 
    testrenewlifetime=`grep "renew_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "renew_lifetime " "$renew_lifetime" "$testrenewlifetime" "$1" 
    local installcheck="$1"
    if $installcheck ; then
       testticketlifetime=`grep "ticket_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "ticket_lifetime " "$ticket_lifetime" "$testticketlifetime" "$1" 
       testdebug=`grep "debug" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "debug " "$debug_krb5" "$testdebug" "$1" 
       testkrb4convert=`grep "krb4_convert" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "krb4_convert " "$krb4_convert" "$testkrb4convert" "$1" 
    fi
}



verify_nsswitch()
{
    rlLog "Verify nsswitch.conf"

    testpasswd=`grep "^passwd:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
    ipacompare_forinstalluninstall "passwd:" "$passwd" "$testpasswd" "$1" 
    testshadow=`grep "^shadow:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
    ipacompare_forinstalluninstall "shadow: " "$shadow" "$testshadow" "$1"
    testgroup=`grep "^group:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
    ipacompare_forinstalluninstall "group: " "$group" "$testgroup" "$1"
    testnetgroup=`grep "^netgroup:"  $NSSWITCH | cut -d ":" -f2 | xargs echo`
    ipacompare_forinstalluninstall "netgroup: " "$netgroup" "$testnetgroup" "$1"
}


verify_authconfig()
{
    rlLog "Verify authconfig"

    testusesssdauth=`grep "USESSSDAUTH"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
    ipacompare_forinstalluninstall "USESSSDAUTH: " "$USESSSDAUTH" "$testusesssdauth" "$1" 
    #testusekerberos=`grep "USEKERBEROS"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
    #ipacompare_forinstalluninstall "USEKERBEROS: " "$USEKERBEROS" "$testusekerberos" "$1" 
    testusesssd=`grep -w "USESSSD"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
    ipacompare_forinstalluninstall "USESSSD: " "$USESSSD" "$testusesssd" "$1" 
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


verify_ipactl_status()
{
   rlLog "Verify ipactl status"

   out=$2
   command="ipactl status"
   $command > $out
   status_DS=`grep "Directory Service" $out | cut -d ":" -f2 | xargs echo`
   status_KDC=`grep "KDC Service" $out | cut -d ":" -f2 | xargs echo`
   status_KPASSWD=`grep "KPASSWD Service" $out | cut -d ":" -f2 | xargs echo`
   status_DNS=`grep "DNS Service" $out | cut -d ":" -f2 | xargs echo`
   status_HTTP=`grep "HTTP Service" $out | cut -d ":" -f2 | xargs echo`
   local installcheck="$1"
   if $installcheck ; then
      if [ $status_DS == "RUNNING" -a $status_KDC == "RUNNING" -a $status_KPASSWD == "RUNNING" -a $status_DNS == "RUNNING" -a $status_HTTP == "RUNNING" ] ; then 
         rlPass "ipactl status as expected for DS, KDC, KPASSWD, DNS, HTTP"
      else
         rlPass "ipactl status not as expected for DS, KDC, KPASSWD, DNS, HTTP"
         rlLog "ipactl status:\n`cat $out`"
      fi
      if [ "$2" != "selfsign" ]; then
         status_CA=`grep "CA Service" $out | cut -d ":" -f2 | xargs echo`
         if [ -n $status_CA ] ; then
            rlPass "ipctl status as expected for CA"
         else
            rlFail "ipctl status not as expected for CA"
         fi
      fi 
  else
     $command 2> $out
     ipactl_result=`cat $out`
     if [ "$ipactl_result" == "$ipactl_uninstall" ] ; then
        rlPass "ipactl status not available since server has been uninstalled"
     else
       rlFail "Not expecting to get ipactl status"
       rlLog "Found status to be: $ipactl_result"
     fi
  fi
}


verify_selfsign_install()
{
      rlLog "Verify install with selfsign"

      out=$1
      command="getcert list"
      $command > $out
      testselfsigncert=`grep -w certificate $out | cut -d ":" -f2 | xargs echo`
      ipacompare_forinstalluninstall "Selfsign cert list: " "$selfsign_cert" "$testselfsigncert" "true" 
      testselfsignissuer=`grep -w issuer $out | cut -d ":" -f2 | xargs echo`
      ipacompare_forinstalluninstall "Selfsign issuer: " "$selfsign_issuer" "$testselfsignissuer" "true" 
      if [ -d $SLAPD_PKI ]; then
         rlFail "$SLAPD_PKI dir created"
      else
         rlPass "$SLAPD_PKI dir not created"
      fi
}


verify_ntp()
{
   rlLog "Verify ntp config"

   ntpcheck=$1

   if [ "$2" == "nontp" ] ; then
     ntpcheck=false
   fi
   testntpserver=`grep "$ntpserver" $NTP`
   ipacompare_forinstalluninstall "ntpserver: " "$ntpserver" "$testntpserver" "$ntpcheck"
   testntpfudgeserver=`grep "$ntpfudgeserver" $NTP`
   ipacompare_forinstalluninstall "ntpfudgeserver: " "$ntpfudgeserver" "$testntpfudgeserver" "$ntpcheck"
}


verify_zonemgr()
{
   if [ "$1" == "false" ]; then
     return
   fi
   rlLog "Verify zonemgr addr"

   out=$2
   command="ipa dnszone-show $DOMAIN"
   $command > $out
   if [ "$3" == "zonemgr" ]; then
      testadminemail=`grep -m 1 "Administrator e-mail address" $out | cut -d ":" -f2 | xargs echo`
      ipacompare_forinstalluninstall "Administrator e-mail address: " "$non_default_admin_email_zonemgr" "$testadminemail" $1
   else
      testadminemail=`grep -m 1 "Administrator e-mail address" $out | cut -d ":" -f2 | xargs echo`
      ipacompare_forinstalluninstall "Administrator e-mail address: " "$admin_email" "$testadminemail" $1
   fi
}


verify_forwarder()
{
   if [ "$1" == "false" ]; then
     return
   fi

  rlLog "Verify forwarder"

  out=$2
  command="ping -c 1 -w 3 redhat.com"
  if [ "$3" == "noforwarders" ]; then
      $command 2> $out
      ping_result=`cat $out`
      if [ "$ping_result" == "$bad_ping" ] ; then
         rlPass "Server configured correctly with no forwarders"
      else
         rlFail "Server not configured correctly for no forwarders"
         rlLog "Ping result: $ping_result"
      fi
  else
      $command > $out
      testforwarder=`grep "ping statistics " $out | xargs echo`
      ipacompare_forinstalluninstall "Forwarder: " "$good_ping" "$testforwarder" true 
  fi
}


verify_newip()
{
   rlLog "Verify when server is installed with new IP"

   if [ "$2" == "newip" ] ; then 
      testhosts=`grep $NEWIPADDRESS /etc/hosts| sed 's/ //g'`
      rlLog "testhosts: $testhosts"
      ipacompare_forinstalluninstall "Hosts file: " "$hosts_newip" "$testhosts" $1
      testresolv=`grep $NEWIPADDRESS /etc/resolv.conf| sed 's/ //g'`
      rlLog "testresolv: $testresolv"
      ipacompare_forinstalluninstall "Resolv.conf file: " "$resolv_newip" "$testresolv" $1
   fi
}


verify_subject()
{
   if [ "$1" == "false" ]; then
     return
   fi
   rlLog "Verify Cerificate Subject base for server install"

   out=$2
   command="ipa config-show"
   $command > $out
   if [ "$3" == "subject" ]; then
      testsubject=`grep "Certificate Subject base" $out | cut -d ":" -f2 | xargs echo`
      ipacompare_forinstalluninstall "Certificate Subject base" "$cert_subject" "$testsubject" $1
   else
      if [ "$3" == "realm" ]; then
         testsubject=`grep "Certificate Subject base" $out | cut -d ":" -f2 | xargs echo`
         ipacompare_forinstalluninstall "Certificate Subject base" "$realm_subject" "$testsubject" $1
      else
         testsubject=`grep "Certificate Subject base" $out | cut -d ":" -f2 | xargs echo`
         ipacompare_forinstalluninstall "Certificate Subject base" "$default_subject" "$testsubject" $1
      fi
   fi
}

verify_ldapsearch()
{
  out_error=$1
  tmpout=$TmpDir/ipaserverinstall_ldapsearch.out
   ldaperror="ldap_bind: Invalid credentials (49)"
   ldapsearch -x -D "cn=Directory Manager" -w $2 -b "dc=$DOMAIN" > $tmpout 2> $out
   if [ "$3" == "allow" ] ; then
     error_size=`stat -c%s $out`
     if [ $error_size == 0 ]; then
       rlPass "ldapsearch accepted password - $2"
     else
       rlFail "ldapsearch failed to accept password - $2"
       rlFail "Error: `cat $out`"
     fi
   else
     result=`cat $out`
     rlLog " result: $result"
     if [ "$result" == "$ldaperror" ] ; then
        rlPass "ldapsearch failed as expected with password - $2"
     else
        rlFail "ldapsearch accepted password - $2"
        rlLog "ldapsearch result: $result"
     fi
   fi
}

verify_password()
{
  if [ "$1" == "false" ]; then
    return
  fi
  out=$2
  if [ "$3" == "password" ]; then 
     # ldapsearch with three passwords 
     verify_ldapsearch $out $dm_pw allow
     verify_ldapsearch $out $ADMINPW 
     verify_ldapsearch $out $master_pw
    
     # kinit with DM_PWD, MASTER_PWD  will fail
     command_dm="kinitAs $ADMINID $dm_pw"
     command_master="kinitAs $ADMINID $master_pw"
     expmsg="kinit: Password incorrect while getting initial credentials"
     qaExpectedRun "$command_dm" "$out" 1 "Verify kinit error for DM Password " "$expmsg" 
     qaExpectedRun "$command_master" "$out" 1 "Verify kinit error for Master Password " "$expmsg" 
  else
     verify_ldapsearch $out $ADMINPW allow
  fi
}


verify_reverse()
{
  if [ "$1" == "false" ]; then
    return
  fi
   out=$2
   testreversedns=`ipa dnszone-find --all | grep arpa | grep Zone | cut -d ":" -f2 | xargs echo`
   if [ "$3" == "noreverse" ] ; then
      if [ -z $testreversedns ] ; then 
         rlPass "No Reverse DNS found"
      else
        rlFail "Unexpected Reverse DNS found: $testreversedns "
      fi
   else
      if [ -n $testreversedns ] ; then 
         rlPass "Reverse DNS found : $testreversedns"
      else
        rlFail "No Reverse DNS found"
      fi
   fi
}



verify_useradd()
{

   # add users without specifying uid....uids will be assigned within the range used when installed.
   for x in {1..8}
   do
     rlLog "EXECUTING: ipa user-add --first=${testuser}$x --last=${testuser}$x ${testuser}$x"
     rlRun "ipa user-add --first=${testuser}$x --last=${testuser}$x ${testuser}$x" 0 " Added new user within given uid range"
   done
 
   # test adding user with uid with manual override
   largeuid="20"
   uidBeyondRange=$((idstart+20))
   rlRun "ipa user-add --first=${testuser}$largeuid --last=${testuser}$largeuid ${testuser}$largeuid --uid=$uidBeyondRange" 0 " Added new user outside uid range"

   # verify the users were added with expected uids
   for y in {3..10}
   do 
    assigneduid=$((idstart+$((y))))
     rlLog "EXECUTING: ipa user-find --uid=$assigneduid"
     rlRun "ipa user-find --uid=$assigneduid" 0 "Verifying user with expected uid"
   done
  
   # verify the gids were also assigned within the given range
   for z in {0..2}
   do 
    assignedgid=$((idstart+$((z))))
     rlLog "EXECUTING: ipa group-find --gid=$assignedgid"
     rlRun "ipa group-find --gid=$assignedgid" 0 "Verifying group with expected gid"
   done

   # Negative tests:
    command="ipa user-add --first=${testuser} --last=${testuser} ${testuser}" 
    expmsg="ipa: ERROR: Operations error: Allocation of a new value for range cn=posix ids,cn=distributed numeric assignment plugin,cn=plugins,cn=config failed! Unable to proceed."
    rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message when adding users after uid range is depleted" 

}


verify_hbac()
{
  rlLog "Verify HBAC rules"

  if [ "$1" == "false" ]; then
    return
  fi

  rlLog "EXECUTING: ipa hbacrule-find --name=allow_all"
  if [ "$2" == "nohbac" ] ; then
    rlRun "ipa hbacrule-find --name=allow_all" 1 "hbac rule - allow_all is not installed" 
  else
    rlRun "ipa hbacrule-find --name=allow_all" 0 "hbac rule - allow_all is installed" 
  fi
}



