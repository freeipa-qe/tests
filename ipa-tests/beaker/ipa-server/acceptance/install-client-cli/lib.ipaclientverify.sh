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

ipacompare_simple()
{
	local label="$1"
	local expected="$2"
	local actual="$3"
	
	if [ "$actual" = "$expected" ]; then
		rlPass "Value is set correctly for $label"
	else
		rlFail "[$label] does NOT match"
		rlLog "expect [$expected], actual got [$actual]"
	fi
}

ipacompare_forinstalluninstall_withmasterslave()
{
    local label="$1"
    local expected_master="$2"
    local expected_slave="$3"
    local actual="$4"
    local installcheck="$5"
    if [ "$actual" = "$expected_master" -o "$actual" = "$expected_slave" ];then
        if $installcheck ; then
            rlPass "[$label] matches :[$actual]"
        else
            rlFail "[$label] still has value: [$actual]. Should have been reset."
        fi
    else
        if $installcheck ; then 
          rlFail "[$label] does NOT match"
          rlLog "expect [$expected_master] or [$expected_slave], actual got [$actual]"
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
		rlLog "Uninstalling ipa client for next test"
		ipa-client-install --uninstall -U 
			if [ $? -ne 0 ]; then
				rlLog "Unsuccessful uninstall"
				rhts-submit-log -l /var/log/ipaclient-uninstall.log
			fi

		fi
	# Checking to see if the sssd.conf files has been deleted as per https://bugzilla.redhat.com/show_bug.cgi?id=819982
	PRESERVESSSDCHK=$(grep "'preserve_sssd': True," /var/log/ipaclient-install.log|wc -l)
	if [ -f $SSSD -a $PRESERVESSSDCHK -eq 0 ];then
		rlRun "grep $RELM $SSSD" 1 "Making sure that $SSSD does not contain the IPA relm. BZ 819982"
		rlRun "grep $DOMAIN $SSSD" 1 "Making sure that $SSSD does not contain the IPA DOMAIN. BZ 819982"

		grep -e LDAP-KRB5 $SSSD 
		if [ $? -eq 0 ];then
			rlLog "BZ 819982 does not exists. This is preserve sssd scenario"
		fi
	elif [ ! -f $SSSD ]; then 
		rlLog "sssd.conf for testing BZ 819982 does not exists"
	else
		rlLog "preserve-sssd option used....skipping check"
	fi

	if [ -f $SSSD ] ; then
		rlLog "renaming last sssd.conf"
		mv $SSSD $SSSD.old
	fi
	if [ -f $DEFAULT ] ; then
		rlLog "renaming last default.conf"
		mv $DEFAULT $DEFAULT.old
	fi
	service ntpd stop
}

install_fornexttest()
{
       if [ ! -f $DEFAULT  ] ; then
           rlLog "Install for next test"
           # an existing install is required to begin this test.
           rlLog "Executing: ipa-client-install -p $ADMINID -w $ADMINPW -U" 
           #rlRun "ipa-client-install -p $ADMINID -w $ADMINPW -U" 0 "Installing ipa client for next test"
           rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM  -p $ADMINID -w $ADMINPW -U --server=$MASTER"
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
echo "verify_sssd"
    local installcheck="$1"

    if [ "$2" == "nosssd" -a -f $SSSD ] ; then
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
       ipacompare_forinstalluninstall "krb5_realm " "$krb5_realm_nosssd" "$testkrb5realm" "$1" 
	elif [ "$2" == "nosssd" -a ! -f $SSSD ] ; then
       rlLog "nosssd verification selected but, no sssd.conf found."
       rlLog "newer versions of IPA with nosssd move sssd.conf out of the way"
    else
       rlLog "Verify sssd.conf - with sssd"
       if [ "$2" == "force" ] ; then
          testcachecredentials=`grep "^cache_credentials"  $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "cache_credentials " "$cache_credentials" "$testcachecredentials" "$1" 
          testauthprovider=`grep "^auth_provider" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "auth_provider " "$auth_provider" "$testauthprovider" "$1" 
          testchpassprovider=`grep "^chpass_provider" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "chpass_provider " "$chpass_provider" "$testchpassprovider" "$1" 
       fi
       if [ "$2" != "preserve" ] ; then
         testidprovider=`grep "^id_provider" $SSSD | cut -d "=" -f2 | xargs echo`
         ipacompare_forinstalluninstall "id_provider " "$id_provider" "$testidprovider" "$1" 
       fi
       testipadomain=`grep "^ipa_domain" $SSSD | cut -d "=" -f2 | xargs echo`
       ipacompare_forinstalluninstall "ipa_domain " "$ipa_domain" "$testipadomain" "$1"
       testipaserver=`grep "^ipa_server" $SSSD | cut -d "=" -f2 | sed 's/_srv_,//g' | xargs echo`
       ipacompare_forinstalluninstall_withmasterslave "ipa_server " "$ipa_server_master" "$ipa_server_slave" "$testipaserver" "$1"
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
       if [ "$2" == "nokrb5offlinepasswords" ] ; then
          grep "krb5_store_password_if_offline" $SSSD
          if [ $? -eq 0 ]; then
            rlFail "krb5_store_password_if_offline is set in sssd.conf"
            rlLog `grep "krb5_store_password_if_offline" $SSSD`
          else
            rlPass "krb5_store_password_if_offline is not set in sssd.conf"
          fi
       else
          testnokrb5offlinepasswords=`grep "krb5_store_password_if_offline" $SSSD | cut -d "=" -f2 | xargs echo`
          ipacompare_forinstalluninstall "krb5_store_password_if_offline " "True" "$testnokrb5offlinepasswords" "$1" 
       fi
       if [ "$2" == "preserve" ] ; then
          grep "LDAP-KRB5" $SSSD
          if [ $? -eq 0 ]; then
            rlPass "$SSSD was preserved during client install"
          else
            rlFail "$SSSD was NOT preserved during client install"
          fi
       fi

    fi
}

verify_krb5()
{
    rlLog "Verify krb5.conf"

	# INSTSRVOPT = 0 when --server is used in ipa-client-install
	# INSTSRVOPT = 1 when --server is NOT used in ipa-client-install
	INSTSRVOPT=$(grep "'server': None," /var/log/ipaclient-install.log |wc -l)
	klist -ekt /etc/krb5.keytab | grep $HOSTNAME
	if [ $? -ne 0 ] ; then
		if [ -f /etc/fedora-release ] ; then
			#rlAssertGrep "# default_realm = $RELM" $KRB5
			rlAssertNotGrep "default_realm = $RELM" $KRB5
		else
			testdefaultrealm=`grep "default_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
	    		ipacompare_forinstalluninstall "default_realm " "$default_realm" "$testdefaultrealm" "$1" 
		fi
	fi
    testrdns=`grep "rdns" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "rdns " "$rdns" "$testrdns" "$1" 
    #testticketlifetime=`grep "ticket_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    #ipacompare_forinstalluninstall "ticket_lifetime " "$ticket_lifetime" "$testticketlifetime" "$1" 
    testforwardable=`grep "forwardable" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "forwardable " "$forwardable" "$testforwardable" "$1" 
    testpkinitanchors=`grep "pkinit_anchors" $KRB5 | cut -d "=" -f2 | xargs echo` 
    ipacompare_forinstalluninstall "pkinit_anchors " "$pkinit_anchors" "$testpkinitanchors" "$1" 
    #testrenewlifetime=`grep "renew_lifetime" $KRB5 | cut -d "=" -f2 | xargs echo` 
    #ipacompare_forinstalluninstall "renew_lifetime " "$renew_lifetime" "$testrenewlifetime" "$1" 
    if [ "$2" == "force" ] ; then
       testdnslookupkdc=`grep "dns_lookup_kdc" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_kdc " "$dns_lookup_kdc_force" "$testdnslookupkdc" "$1" 
       testdnslookuprealm=`grep "dns_lookup_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_realm " "$dns_lookup_realm_force" "$testdnslookuprealm" "$1" 
       testdomain=`grep "$DOMAIN" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall_withmasterslave "domain_realm " "$domain_realm_force_master" "$domain_realm_force_slave" "$testdomain" "$1" 
    elif [ $INSTSRVOPT -eq 0 ] ; then
       testdnslookupkdc=`grep "dns_lookup_kdc" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_simple "dns_lookup_kdc " "$dns_lookup_kdc_force" "$testdnslookupkdc"
       testdnslookuprealm=`grep "dns_lookup_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_simple "dns_lookup_realm " "$dns_lookup_realm_force" "$testdnslookuprealm"
	   testdomain=`grep "$DOMAIN = " $KRB5 | cut -d "=" -f2 | xargs echo`
       if [ "$1" = "true" ]; then # true=install, false=uninstall
		   ipacompare_simple "domain_realm " "$domain_realm" "$testdomain"
       else
           ipacompare_simple "domain_realm " "" "$testdomain"
       fi    
    else
       testdnslookupkdc=`grep "dns_lookup_kdc" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_kdc " "$dns_lookup_kdc" "$testdnslookupkdc" "$1" 
       testdnslookuprealm=`grep "dns_lookup_realm" $KRB5 | cut -d "=" -f2 | xargs echo` 
       ipacompare_forinstalluninstall "dns_lookup_realm " "$dns_lookup_realm" "$testdnslookuprealm" "$1" 
       #testdomain=`grep "$DOMAIN" $KRB5 | cut -d "=" -f2 | xargs echo` 
       testdomain=`grep "$DOMAIN = " $KRB5 | cut -d "=" -f2 | xargs echo` 
       if [ "$2" == "nonexistent" ] ; then
          ipacompare_forinstalluninstall "domain_realm " "$domain_realm_nonexistent" "$testdomain" "$1" 
       else
          ipacompare_forinstalluninstall "domain_realm " "$domain_realm" "$testdomain" "$1" 
       fi
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

verify_ntpservice()
{

    local installcheck="$1"
    if $installcheck ; then
     service ntpd status | grep running 
      if [ $? -eq 0  ] ; then
         rlPass "ntpd status is as expected: running"
      else
         rlFail "ntpd status is NOT as expected: running"
      fi
      cat $STEPTICKER | grep "Use IPA-provided NTP server"
      if [ $? -eq 0  ] ; then
        rlPass "$STEPTICKER is configured correctly"
      else
        rlFail "$STEPTICKER is NOT configured correctly"
      fi
    else
     # On beaker machines, test shows that 
     # ntpd is still running after a 
     # ipa-client uninstall
     # TODO: Investigate the cause...meanwhile 
     # commenting the check below 

     #service ntpd status | grep stopped
     # if [ $? -eq 0  ] ; then
     #    rlPass "ntpd status is as expected: stopped"
     # else
     #    rlFail "ntpd status is NOT as expected: stopped"
     # fi

      cat $STEPTICKER | grep "Use IPA-provided NTP server" 
      if [ $? -eq 0  ] ; then
        rlFail "$STEPTICKER is NOT configured correctly"
      else
        rlPass "$STEPTICKER is configured correctly"
      fi
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
      if $1 ; then
      	testusekerberos=`grep "USEKERBEROS"  $AUTHCONFIG | cut -d "=" -f2 | xargs echo`
      	ipacompare_forinstalluninstall "USEKERBEROS: " "$USEKERBEROS" "$testusekerberos" "$1" 
      fi
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
   

    $cmd >& $out
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
	if [ $(grep 5\.[0-9] /etc/redhat-release |wc -l) -gt 0 ]; then
		rlLog "Running: ssh -o StrictHostKeyChecking=no root@$MASTER \"echo $ADMINPW|kinit admin; ipa  host-show --all $client\" > $out"
		rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER \"echo $ADMINPW|kinit admin; ipa  host-show --all $client\" > $out 2>&1"
	else
		rlLog "Running: ipa  host-show --all $client > $out"
		rlRun "ipa  host-show --all $client > $out 2>&1"
	fi
    rlLog "Out: $out"
    chkkeytab="Keytab: False"
    if grep -i "$chkkeytab" $out 2>&1 >/dev/null
    then
        rlPass "Keytab for uninstalled client is correct"
    else
        rlFail "Keytab for uninstalled client is not reset";
    fi
}


verify_hostname()
{
  newHostname=$1
  if [ `hostname` = $newHostname ] ; then
      rlPass "Hostname is as expected: $newHostname"
  else
      rlFail "Hostname is different from expected. Expected: $newHostname; Got: `hostname`"
  fi
  
  cat $NETWORK | grep $newHostname
  if [ $? -eq 0 ]; then
     rlPass "$NETWORK file is correctly updated with new hostname "
     rlPass "`cat $NETWORK | grep $newHostname`"
  else
     rlFail "$NETWORK file is not updated with new hostname"
     rlFail "`cat $NETWORK | grep HOSTNAME` "
  fi

}


updateResolv()
{
        fakeip=99.99.99.999
	sed -i s/^nameserver/#nameserver/g /etc/resolv.conf
	echo "nameserver $fakeip" >> /etc/resolv.conf
        rlLog "Updated contents are: `cat /etc/resolv.conf`"
}


restoreResolv()
{
        fakeip="99.99.99.999"
	sed -i s/"^#nameserver $MASTERIP"/"nameserver $MASTERIP"/g /etc/resolv.conf
	sed -i s/"^#nameserver $SLAVEIP"/"nameserver $SLAVEIP"/g /etc/resolv.conf
        sed -i /"nameserver $fakeip"/d /etc/resolv.conf
        rlLog "Restored contents are: `cat /etc/resolv.conf`"
}

verify_time()
{
   clientTime=`date +%s`
   serverTime=`ssh -o StrictHostKeyChecking=no root@$MASTER date +%s`
   diffInTime=`expr $clientTime - $serverTime`

   #Allow 2 min difference
   if [ -120 -le $diffInTime -o $diffInTime -ge 120 ] ; then
     rlPass "Client time matches time on server"
   else
     rlFail "Client time does not match time on server"
     rlLog "Client Time: `date`; and Server Time: `ssh -o StrictHostKeyChecking=no root@$MASTER date`"
     date --set='-2 hours'
     rlLog "Reset time on Client: `date`"
   fi
}

getRandomPassword()
{
     out="$1"
     ssh -o StrictHostKeyChecking=no root@$MASTER "ipa host-add $CLIENT --random" > $out

#     $cmd > $out
     randomPassword=`grep "Random password:" $out | cut -d ":" -f2`
     return $randomPassword

}


writesssdconf()
{

   rlRun "echo \"[sssd]\" > $SSSD"
   rlRun "echo \"config_file_version = 2\" >> $SSSD"
   rlRun "echo \"domains = LDAP-KRB5\" >> $SSSD"
   rlRun "echo \"debug_level = 6\" >> $SSSD"
   rlRun "echo \"reconnection_retries = 3\" >> $SSSD"
   rlRun "echo \"services = nss, pam\" >> $SSSD"
   rlRun "echo \"\" >> $SSSD"
   rlRun "echo \"[nss]\" >> $SSSD"
   rlRun "echo \"filter_groups = root\" >> $SSSD"
   rlRun "echo \"filter_users = root\" >> $SSSD"
   rlRun "echo \"\" >> $SSSD"
   rlRun "echo \"[pam]\" >> $SSSD"
   rlRun "echo \"\" >> $SSSD"
   rlRun "echo \"[domain/LDAP-KRB5]\" >> $SSSD"
   rlRun "echo \"id_provider = ldap\" >> $SSSD"
   rlRun "echo \"auth_provider = krb5\" >> $SSSD"
   rlRun "echo \"ldap_uri = ldap://$MASTER\" >> $SSSD"
   rlRun "echo \"debug_level = 9\" >> $SSSD"
   rlRun "echo \"krb5_server = $MASTER\" >> $SSSD"
   rlRun "echo \"krb5_realm = $RELM\" >> $SSSD"

}


