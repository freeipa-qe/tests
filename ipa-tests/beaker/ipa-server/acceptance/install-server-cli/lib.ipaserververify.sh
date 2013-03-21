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
       # Checking to see if the sssd.conf files has been deleted as per https://bugzilla.redhat.com/show_bug.cgi?id=819982
       rlRun "ls $SSSD" 2 "Making sure that $SSSD does not exist. BZ 819982"
	
		if [ -d /var/lib/pki-ca ]; then
			rlLog "Looks like pki needs to be cleaned up..."
			rlRun "pkiremove -pki_instance_root=/var/lib -pki_instance_name=pki-ca --force"
			rlRun "yum -y reinstall pki-selinux"
		fi
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

     verify_bz878288 # Make sure sssd is running
     verify_bz888124 # Make sure sssd is enabled to start on boot
	
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
  command="ping -c 1 -w 3 engineering.redhat.com"
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
   local userlist=""
   KinitAsAdmin

   # add users without specifying uid....uids will be assigned within the range used when installed.
   for x in {1..9}
   do
     rlLog "EXECUTING: ipa user-add --first=${testuser}$x --last=${testuser}$x ${testuser}$x"
     rlRun "ipa user-add --first=${testuser}$x --last=${testuser}$x ${testuser}$x" 0 " Added new user within given uid range"
     uid=$(ipa user-find ${testuser}$x --raw |grep uidnumber:|awk '{print $2}') 
     userlist="$userlist $(echo ${testuser}$x,$uid)"
   done
 
   # test adding user with uid with manual override
   largeuid="20"
   uidBeyondRange=$((idstart+20))
   rlRun "ipa user-add --first=${testuser}$largeuid --last=${testuser}$largeuid ${testuser}$largeuid --uid=$uidBeyondRange" 0 " Added new user outside uid range"

   # verify the users were added with expected uids
   #for y in {1..9}
   #do 
   # assigneduid=$((idstart+$((y))))
   #  rlLog "EXECUTING: ipa user-find --uid=$assigneduid"
   #  rlRun "ipa user-find --uid=$assigneduid" 0 "Verifying user with expected uid"
   #done
   for entry in $userlist
   do
      username=$(echo $entry|cut -f1 -d,)
      uid=$(echo $entry|cut -f2 -d,) 
      rlLog "EXECUTING: ipa user-find --uid=$uid"
      rlRun "ipa user-find --uid=$uid"
   done
  
   # verify the gids were also assigned within the given range
   for z in {3..5}
   do 
    assignedgid=$((idstart+$((z))))
     rlLog "EXECUTING: ipa group-find --private --gid=$assignedgid"
     rlRun "ipa group-find --private --gid=$assignedgid" 0 "Verifying group with expected gid"
   done

   # Negative tests:
    command="ipa user-add --first=${testuser} --last=${testuser} ${testuser}" 
    expmsg="ipa: ERROR: Operations error: Allocation of a new value for range cn=posix ids,cn=distributed numeric assignment plugin,cn=plugins,cn=config failed! Unable to proceed."
    rlRun "verifyErrorMsg \"$command\" \"$expmsg\"" 0 "Verify expected error message when adding users after uid range is depleted" 
	if [ $? -eq 1 ]; then
		rlFail "BZ 891930 found...DNA plugin no longer reports additional info when range is depleted"
	else
		rlPass "BZ 891930 not found"
	fi
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

verify_833515()
{
	if [ "$1" == "false" ]; then
		return
	fi

  	if [ "$2" == "nodns" ] ; then
		rlLog "DNS not configured with this install"
	else
		rlLog "Test for BZ 833515 :: permissions of replica files should be 0600"
		rlRun "ls -al /var/lib/ipa | grep sysrestore | grep drwx------" 0 "Ensure that /var/lib/ipa/sysrestore appears to be set to a 600 permission set BZ 833515"
		rlRun "ls -al /var/lib/ipa | grep sysupgrade | grep drwx------" 0 "Ensure that /var/lib/ipa/sysupgrade appears to be set to a 600 permission set BZ 833515"
	fi
}

verify_782920()
{
	if [ "$1" == "false" ]; then
		return
	fi

	if [ "$2" == "realm" ]; then
		ORIGBASEDN=$BASEDN
		BASEDN=$basedn
	fi

  	if [ "$2" == "nodns" ] ; then
		rlLog "DNS not configured with this install"
	else
		rlLog "Test for BZ 782920 - Make life easier to admins by configuring /etc/openldap/ldap.conf"
		rlRun "ls /etc/openldap/ldap.conf" 0 "Make sure that ldap.conf was created"
		rlRun "grep '$BASEDN' /etc/openldap/ldap.conf" 0 "Check to see if the Base DN seems to be in ldap.conf"
		rlRun "grep '$MASTER' /etc/openldap/ldap.conf" 0 "Check to see the MASTER dns seems to be in ldap.conf"
	fi

	if [ "$2" == "realm" ]; then
		BASEDN=$ORIGBASEDN
	fi
}

# BZ 891793 CLOSED NOTABUG...that is expected behavior
verify_bz891793()
{
	if [ ! -f "$1" ]; then
		return
	else
		local tmpout="$1"
	fi
	
	local errmsg="ipa-server-install: error: persistent search feature is required for DNS SOA serial autoincrement"

	if [ $(grep "$errmsg" $tmpout|wc -l) -gt 0 ]; then
		rlFail "BZ 891793 found...ipa-server-install --zone-refresh set to non-zero fails unless --no-serial-autoincrement is used"	
	else
		rlPass "BZ 891793 not found."
	fi
}

verify_819629()
{
	if [ "$1" == "false" ]; then
		return
	fi

  	if [ "$2" == "nodns" ] ; then
		rlLog "DNS not configured with this install"
	elif [ "$2" == "zonerefresh" ]; then
		rlLog "zonerefresh option set to non-zero for this test."
		rlLog "Skipping psearch install because psearch and zonerefresh are mutually exclusive"
	else
		rlLog "Test for BZ 819629 - Enable persistent search in bind-dyndb-ldap during IPA upgrade"
		rlRun "grep psearch /etc/named.conf  | grep yes" 0 "Make sure a psearch enabled line exists in named.conf"
		rlRun "grep psearch /etc/named.conf  | grep no" 1 "Make sure a psearch is not disabled anywhere in named.conf"
	fi
}

verify_noredirect()
{
  rlLog "Verify ipa-rewrite to verify for redirect"

  if [ "$1" == "false" ]; then
    return
  fi

  testRewrite=`grep $rewriteLine $REWRITE`
  if [ "$2" == "noredirect" ] ; then
      if [ ${testRewrite:0:1} == "#" ] ; then
         rlPass "Redirect line is commented"
      else
        rlFail "Redirect line is NOT commented"
      fi
  else
      if [ ${testRewrite:0:1} == "#" ] ; then
         rlFail "Redirect line is commented"
      else
        rlPass "Redirect line is not commented"
      fi
  fi
  
}


hostsFileUpdateForTest()
{
    HOSTSFILE="/etc/hosts"
    rm -f $HOSTSFILE.ipaservertestbackup
    cp -af $HOSTSFILE $HOSTSFILE.ipaservertestbackup 
    sed -i s/^$MASTERIP/#$MASTERIP/g $HOSTSFILE 
}


hostsFileSwithHostForTest()
{
    HOSTSFILE="/etc/hosts"
    rm -f $HOSTSFILE.ipaservertestbackup
    cp -af $HOSTSFILE $HOSTSFILE.ipaservertestbackup 
    sed -i s/^$MASTERIP/#$MASTERIP/g /etc/hosts
    hostname=$(hostname)
    hostname_s=$(hostname -s)
    echo "$MASTERIP $hostname_s $hostname_s.$DOMAIN" >> $HOSTSFILE
}

restoreHostsFile()
{
    HOSTSFILE="/etc/hosts"
    mv $HOSTSFILE.ipaservertestbackup /etc/hosts
 
}


verify_reversezone()
{

   out=$1
   command="ipa dnszone-find $reversezone --all" 
   $command > $out
   
   testidnsUpdatePolicy=`grep -m 1 "BIND update policy" $out | cut -d ":" -f2 | xargs echo`
   expectedidnsUpdatePolicy="grant $RELM krb5-subdomain $reversezone PTR;"
   ipacompare_forinstalluninstall "BIND update policy: " "$expectedidnsUpdatePolicy" "$testidnsUpdatePolicy" true 
}




verify_zonerefresh()
{
  if [ "$1" == "false" ]; then
    return
  fi

  testzonerefresh=`grep $zoneRefreshLine $NAMED | cut -d " " -f3 | cut -d "\"" -f1`
  grep $zoneRefreshLine $NAMED
  grep $zoneRefreshLine $NAMED | cut -d " " -f3 
  grep $zoneRefreshLine $NAMED | cut -d " " -f3 | cut -d "\"" -f1

  testpsearch=$(grep "psearch.*yes" $NAMED|wc -l)
  grep "psearch.*yes" $NAMED

  if [ "$2" == "zonerefresh" ] ; then
      if [ "$testzonerefresh" == "$zone_refresh_value" ] ; then
         rlPass "Zone Refresh is set correctly to $zone_refresh_value in $NAMED"
      else
         rlFail "Zone Refresh is NOT set correctly in $NAMED, and is $testzonerefresh"
      fi
  else
      if [ "$testzonerefresh" == "$zone_refresh_value_default" -a $testpsearch -eq 0 ] ; then
         rlPass "Zone Refresh is set correctly to $testzonerefresh in $NAMED"
      elif [ "$testzonerefresh" == "0" -a $testpsearch -eq 1 ]; then
         rlPass "Zone Refresh is set correctly to 0 in $NAMED when psearch is set to yes"
      else
         rlFail "Zone Refresh is NOT set correctly in $NAMED, and is $testzonerefresh"
      fi
  fi

}

verify_cachememsize_error()
{
	# Detailed in:
	# https://bugzilla.redhat.com/show_bug.cgi?id=820003
	# https://fedorahosted.org/freeipa/ticket/2739
	logfile="/var/log/dirsrv/slapd-$(echo $RELM| sed s/'\.'/-/g)/errors"
	rlLog "Errors file to check is $logfile"
	rlRun "grep 'entry cache size' $logfile | grep 'is less than db size'" 1 "Ensure that offending error message is not coming up in the slapd error log"
	
}

verify_bz878288()
{
	if [ $(ps -ef|grep "/usr/libexec/s[s]sd"|wc -l) -eq 0 ]; then
		rlFail "BZ 878288 found...IPA users are not available after ipa-server-install because sssd not running"
	else
		rlPass "BZ 878288 not found"
	fi
}

verify_bz888124()
{
	chkconfig sssd
	if [ $? -eq 1 ]; then
		rlFail "BZ 888124 found...ipa install does not enable sssd start on boot"
	else
		rlPass "BZ 888124 not found"
	fi
}

verify_bz889583()
{
	IPAD=$(grep ^domain= /etc/ipa/default.conf |cut -f2 -d=|tr '[:upper:]' '[:lower:]')
	IPAR=$(grep ^realm=  /etc/ipa/default.conf |cut -f2 -d=|tr '[:upper:]' '[:lower:]')
	if [ -z "$IPAR" -o -z "$IPAR" ]; then
		rlLog "Cannot find domain or realm name to check bz889583"
		return 0
	fi

	if [ "$IPAR" != "$IPAD" ]; then
		rlLog "IPA Realm and Domain differ...checking BZ 889583"
		KinitAsAdmin
		rlAssertNotGrep "Configuration of client side components failed" /var/log/ipaserver-install.log
		if [ $? -eq 1 ]; then
			rlFail "BZ 889583 found...ipa server install failing when realm differs from domain"
		else
			rlPass "BZ 889583 not found"
		fi
	fi
}

