#####################
#  GLOBALS	    #
#####################
HTTPCFGDIR="/etc/httpd/conf"
HTTPCERTDIR="$HTTPCFGDIR/alias"
HTTPPRINC="HTTP/$HOSTNAME"
HTTPKEYTAB="$HTTPCFGDIR/$HOSTNAME.keytab"
HTTPKRBCFG="/etc/httpd/conf.d/krb.conf"

echo " HTTP configuration directory:  $HTTPCFGDIR"
echo " HTTP certificate directory:  $HTTPCERTDIR"
echo " HTTP krb configuration file: $HTTPKRBCFG"
echo " HTTP principal:  $HTTPPRINC"
echo " HTTP keytab: $HTTPKEYTAB"

BASEDN="o=sasl.com"
LDAPPORT=3389
INSTANCECFG="/tmp/instance.inf"
USERLDIF="/tmp/user.ldif"
SASLCFG="/tmp/sasl.ldif"
PWDSCHEME="/tmp/pwdscheme.ldif"
LDAPPRINC="ldap/$HOSTNAME"
LDAPKEYTAB="/etc/dirsrv/ldap_service.keytab"
USERKEYTAB="/tmp/ldapuser1.keytab"

######################
# test suite         #
######################
ipafunctionalservices()
{
    setup
    http_services
    https
    ldap_services
    #ldaps
    cleanup
} 

https()
{
    https_setup
    https_tests
    https_cleanup
}

######################
# SETUP              #
######################

setup()
{
	rlPhaseStartTest "SETUP: IPA server,apache and directory server"

		# create a test http user
		rlRun "create_ipauser httpuser1 httpuser1 httpuser1 Secret123" 0 "Creating a test http user"

                # create a test ldap user
                rlRun "create_ipauser ldapuser1 ldapuser1 ldapuser1 Secret123" 0 "Creating a test ldap user"

		# kinit as admin
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

		rlLog "######################################################################################################"
		rlLog "#                                       Setup for HTTP Service					    #"
		rlLog "######################################################################################################"
		# add HTTP service for this client host	
		rlRun "ipa service-add $HTTPPRINC" 0 "Add HTTP service for this client host"

		# get a keytab
		cd $HTTPCFGDIR
		rlRun "ipa-getkeytab -s $MASTER -k $HTTPKEYTAB -p $HTTPPRINC" 0 "Get keytab for this host's http service"
		rlRun "chown apache.apache $HTTPKEYTAB" 0 "Change keytab ownership to apache.apache."

		service httpd stop
		rlLog "Setting up $HTTPKRBCFG  ..............."
		rm -rf $HTTPKRBCFG
		echo "<Location \"/ipatest\">" > $HTTPKRBCFG
		echo "  AuthType Kerberos" >> $HTTPKRBCFG
		echo "  AuthName \"Kerberos Login\"" >> $HTTPKRBCFG
		echo "  KrbMethodNegotiate on" >> $HTTPKRBCFG
		echo "  KrbMethodK5Passwd off" >> $HTTPKRBCFG
		echo "  KrbServiceName HTTP" >> $HTTPKRBCFG
		echo "  KrbAuthRealms $RELM" >> $HTTPKRBCFG
		echo "  Krb5KeyTab $HTTPKEYTAB" >> $HTTPKRBCFG
		echo "  KrbSaveCredentials off" >> $HTTPKRBCFG
		echo "  Require valid-user" >> $HTTPKRBCFG
		echo "</Location>" >> $HTTPKRBCFG

		cat $HTTPKRBCFG 

		rlRun "service httpd start" 0 "Restarting apache service with kerberos configuration in place"

                rlLog "######################################################################################################"
                rlLog "#                                       Setup for LDAP Service                                       #"
                rlLog "######################################################################################################"
		#  add LDAP service for this client host
		rlRun "ipa service-add $LDAPPRINC" 0 "Add LDAP service for this client host"

		cd /etc/dirsrv
		rlRun "ipa-getkeytab -s $MASTER -k $LDAPKEYTAB -p $LDAPPRINC" 0 "Get keytab for this host's ldap service"
		rlRun "chown nobody:nobody $LDAPKEYTAB" 0 "Change keytab ownership to nobody.nobody"
		rlRun "chmod 0400 $LDAPKEYTAB" 0 "Change keytab permissions to 0400"

		# set up directory server instance
		rlLog "Setting up Directory Server instance ............."
		echo "[General]" > $INSTANCECFG
		echo "FullMachineName= $HOSTNAME" >> $INSTANCECFG
		echo "SuiteSpotUserID= nobody" >> $INSTANCECFG
		echo "SuiteSpotGroup= nobody" >> $INSTANCECFG
		echo "ConfigDirectoryLdapURL= ldap://$HOSTNAME:389/o=NetscapeRoot" >> $INSTANCECFG
		echo "ConfigDirectoryAdminID= admin" >> $INSTANCECFG
		echo "ConfigDirectoryAdminPwd= $ADMINPW" >> $INSTANCECFG
		echo "AdminDomain= example.com" >> $INSTANCECFG
		echo "" >> $INSTANCECFG
		echo "[slapd]" >> $INSTANCECFG
		echo "ServerIdentifier= instance1" >> $INSTANCECFG
		echo "ServerPort= $LDAPPORT" >> $INSTANCECFG
		echo "Suffix= $BASEDN" >> $INSTANCECFG
		echo "RootDN= cn=Directory Manager" >> $INSTANCECFG
		echo "RootDNPwd= $ADMINPW" >> $INSTANCECFG
		echo "" >> $INSTANCECFG
		echo "[admin]" >> $INSTANCECFG
		echo "ServerAdminID= admin" >> $INSTANCECFG
		echo "ServerAdminPwd= $ADMINPW" >> $INSTANCECFG
		echo "SysUser= nobody" >> $INSTANCECFG

		rlLog "################################################################################################"
		rlLog "################################  Adding Directory Server Instance  ############################"
		rlLog "################################################################################################"
		rlRun "/usr/sbin/setup-ds.pl --silent --file=$INSTANCECFG" 0 "Seting up directory server instance"

		rlRun "/usr/bin/ldapsearch -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory manager\" -w $ADMINPW -b \"$BASEDN\"" 0 "Verifying directory server instance"

		# Directory Server SASL setup
		echo "dn: cn=Kerberos uid mapping,cn=mapping,cn=sasl,cn=config" > $SASLCFG
		echo "changetype: modify" >> $SASLCFG
		echo "replace: nsSaslMapBaseDNTemplate" >> $SASLCFG
		echo "nsSaslMapBaseDNTemplate: o=sasl.com" >> $SASLCFG
		echo "" >> $SASLCFG
		echo "dn: cn=rfc 2829 dn syntax,cn=mapping,cn=sasl,cn=config" >> $SASLCFG
		echo "changetype: modify" >> $SASLCFG
		echo "replace: nsSaslMapBaseDNTemplate" >> $SASLCFG
		echo "nsSaslMapBaseDNTemplate: o=sasl.com" >> $SASLCFG
		echo "" >> $SASLCFG
		echo "dn: cn=rfc 2829 u syntax,cn=mapping,cn=sasl,cn=config" >> $SASLCFG
		echo "changetype: modify" >> $SASLCFG
		echo "replace: nsSaslMapBaseDNTemplate" >> $SASLCFG
		echo "nsSaslMapBaseDNTemplate: o=sasl.com" >> $SASLCFG
		echo "" >> $SASLCFG
		echo "dn: cn=uid mapping,cn=mapping,cn=sasl,cn=config" >> $SASLCFG
		echo "changetype: modify" >> $SASLCFG
		echo "replace: nsSaslMapBaseDNTemplate" >> $SASLCFG
		echo "nsSaslMapBaseDNTemplate: o=sasl.com" >> $SASLCFG

		rlLog "################################################################################################"
		rlLog "#####################################  Adding SASL MAPS   ######################################"
		rlLog "################################################################################################"
		rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $SASLCFG" 0 "Add sasl mappings to directory server"

		# change password scheme
		echo "dn: cn=config" > $PWDSCHEME
		echo "changetype: modify" >> $PWDSCHEME
		echo "replace: passwordstoragescheme" >> $PWDSCHEME
		echo "passwordstoragescheme: clear" >> $PWDSCHEME

		rlLog "################################################################################################"
		rlLog "################################  Changing Password Storage Scheme   ###########################"
		rlLog "################################################################################################"
		rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $PWDSCHEME" 0 "Change password scheme for directory server"

		# set the KRB5_KTNAME in /etc/sysconfig/dirsrv
		echo "KRB5_KTNAME=$LDAPKEYTAB ; export KRB5_KTNAME" >> /etc/sysconfig/dirsrv
		# restart the directory server
		rlRun "service dirsrv restart" 0 "Restarting the directory server for changes to take effect"

		# add directory server user
		echo "dn: uid=ldapuser1,$BASEDN" > $USERLDIF
		echo "userPassword: Secret123" >> $USERLDIF
		echo "objectClass: top" >> $USERLDIF
		echo "objectClass: person" >> $USERLDIF
		echo "objectClass: inetorgperson" >> $USERLDIF
		echo "uid: ldapuser1" >> $USERLDIF
		echo "cn: LDAP User1" >> $USERLDIF
		echo "sn: user1" >> $USERLDIF
	
		rlLog "################################################################################################"
		rlLog "################################  Adding Directory Server Test user  ###########################"
		rlLog "################################################################################################"
		rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $USERLDIF" 0 "Add user to directory server"
	rlPhaseEnd
}

########################
#  HTTP TEST CASES     #
########################
http_services()
{
        rlPhaseStartTest "ipa-functionalservices-001: Access HTTP service with valid credentials"
                rlRun "kinitAs httpuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: curl -v --negotiate -u: http://$HOSTNAME/ipatest/"
                curl -v --negotiate -u: http://$HOSTNAME/ipatest/ > /tmp/curl_001.out
                cat /tmp/curl_001.out | grep "404 Not Found"
                if [ $? -eq 0 ] ; then
                        rlPass "User was authenticated"
                else
                        rlFail "User was NOT authenticated"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-functionalservices-002: Access HTTP service with out credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: curl -v --negotiate -u: http://$HOSTNAME/ipatest/"
                curl -v --negotiate -u: http://$HOSTNAME/ipatest/ > /tmp/curl_002.out
                cat /tmp/curl_002.out | grep "401 Authorization Required"
                if [ $? -eq 0 ] ; then
                        rlPass "User was NOT authenticated"
                else
                        rlFail "User was authenticated"
                fi
        rlPhaseEnd
}

#######################
#  HTTPS TEST CASES   #
#######################
https_setup()
{
   	# add the IPA CA Cert as a trusted certificate to the apache server's certificate database
   	rlLog "Adding the IPA CA certificate to the web server's certificate database ............"
   	cd /etc/httpd/alias
   	wget http://$MASTER/ipa/config/ca.crt
   	certutil -A -d . -n 'IPA CA' -t CT,, -a < ca.crt

   	rlRun "certutil -L -d . -n 'IPA CA'" 0 "Verify the IPA CA certificate was added to the apache server's certificate database"

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

   	# Get certificate subject
   	certsubj=`ipa config-show | grep "Certificate Subject base" | cut -d ":" -f2`
	# trim whitespace
	certsubj=`echo $certsubj`
	rlLog "Certificate Subject: $certsubj"

	# generate a certificate request for the web server
	certutil -R -s "CN=$HOSTNAME,$certsubj" -d . -a -z /etc/group > $HOSTNAME.csr
	cat $HOSTNAME.csr

	# submit the certificate request
	rlRun "ipa cert-request --principal=$HTTPPRINC $HOSTNAME.csr" 0 "Submitting certificate request for HTTP server"
	# get certificate into PEM file
	rlRun "ipa cert-show $HTTPPRINC --out $HOSTNAME.crt" 0 "Get HTTP server cert into a PEM file"

	# add the HTTP server cert to the certificate database
	certutil -A -n $HOSTNAME -d . -t u,u,u -a < $HOSTNAME.crt

	# Validate the certificate
	rlRun "certutil -V -u V -d . -n $HOSTNAME > /tmp/certvalid.out 2>&1" 0 "Validating HTTP Server certificate"
	cat /tmp/certvalid.out | grep "certificate is valid"
	if [ $? -eq 0 ] ; then
		rlPass "SUCCESS: HTTP Server Certificate is valid"
	else
		rlRun "ERROR: HTTP Server Certificate is not valid."
	fi

	# configuring http server for SSL
	sed -e "s/#NSSNicknameServer-Cert/NSSNickname $HOSTNAME" /etc/httpd/conf.d/nss.conf /tmp/nss.conf
	rlFileBackup /etc/httpd/conf.d/nss.conf
	cp -f /tmp/nss.conf /etc/httpd/conf.d/nss.conf

	# restart the apache server
	rlRun "service httpd restart" 0 "Restarting apache for SSL configuration to take affect"
}

https_tests()
{

	rlPhaseStartTest "ipa-functionalservices-003: Access HTTPS service with valid credentials"
                rlRun "kinitAs httpuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: curl -v --negotiate -u: https://$HOSTNAME/ipatest/"
                curl -v --negotiate -u: https://$HOSTNAME/ipatest/ > /tmp/curl_001.out
                cat /tmp/curl_001.out | grep "404 Not Found"
                if [ $? -eq 0 ] ; then
                        rlPass "User was authenticated"
                else
                        rlFail "User was NOT authenticated"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-functionalservices-004: Access HTTPS service with out credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: curl -v --negotiate -u: https://$HOSTNAME/ipatest/"
                curl -v --negotiate -u: https://$HOSTNAME/ipatest/ > /tmp/curl_002.out
                cat /tmp/curl_002.out | grep "401 Authorization Required"
                if [ $? -eq 0 ] ; then
                        rlPass "User was NOT authenticated"
                else
                        rlFail "User was authenticated"
                fi
        rlPhaseEnd

}

https_cleanup()
{
	# revoke the HTTP server's certificate - first need the certificate's serial number
	certutil -L -d . -n "$HOSTNAME" > /tmp/certout.txt
	serialno=`cat /tmp/certout.txt | grep "Serial Number" | cut -d ":" -f 2 | cut -d "(" -f 1`
	serialno=`echo $serialno`
	rlRun "ipa cert-revoke $serialno" 0 "Revoke HTTP server's certificate"

	# remove cert files
	rm -rf /etc/httpd/alias/$HOSTNAME.csr /etc/httpd/alias/ca.crt /etc/httpd/alias/$HOSTNAME.crt

	# remove the certificates from the web server's database
	cd /etc/httpd/alias/
	certutil -d . -D -n "$HOSTNAME"
	certutil -d . -D -n "IPA CA"	

	# restore nss.conf
	rlFileRestore /etc/httpd/conf.d/nss.conf
	rlRun "service httpd restart" 0 "Restarting apache server"
}

#######################
# LDAP TEST CASES     #
#######################
ldap_services()
{
	rlPhaseStartTest "ipa-functionalservices-005: Access LDAP service with valid credentials"
		rlRun "kdestroy" 0 "destroying kerberos credentials"
		rlRun "kinitAs ldapuser1 Secret123" 0 "kinit as user to get valid credentials"
		klist
		rlLog "Executing: ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"ou=people,$BASEDN\"(uid=*)\" dn"
		rlRun "ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn > /tmp/ldapsearch_003.out 2>&1" 0 "Verify ldapsearch with valid credentials"
	rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-006: Access LDAP service with out credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"ou=people,$BASEDN\"(uid=*)\" dn"
                rlRun "ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn > /tmp/ldapsearch_004.out 2>&1" 254 "Verify ldapsearch with valid credentials"
		cat /tmp/ldapsearch_004.out | grep "Credentials cache file '/tmp/krb5cc_0' not found"
		if [ $? -eq 0 ] ; then
			rlPass "Error as expected Credentials not found"
		else
			rlFail "Error NOT as expected:  Did not find credentials not found message"
		fi
        rlPhaseEnd
}

########################
# LDAPS TEST CASES     #
########################
ldaps_setup()
{
}

ldaps_tests()
{
}

ldaps_cleanup()
{
}
########################
# CLEANUP	       #
########################

cleanup()
{
	rlPhaseStartTest "CLEANUP: ipa server and apache"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa user-del httpuser1" 0 "Delete the http test user"
		rlRun "ipa user-del ldapuser1" 0 "Delete the ldap test user"
		rlRun "service httpd stop" 0 "stopping apache server"
		rlRun "rm -rf $HTTPKRBCFG" 0 "removing kerberos configuration file"
		rlRun "ipa-rmkeytab -p $HTTPPRINC -k $HTTPKEYTAB" 0 "removing http keytab"
		rlRun "ipa service-del $HTTPPRINC" 0 "Remove the HTTP service for this client host"
		rlRun "/usr/sbin/remove-ds.pl -i SLAPD-instance1" 0 "Removing directory server instance"
		rlRun "rm -rf $HTTPKEYTAB" 0 "Delete the HTTP keytab file"
		rlRun "ipa-rmkeytab -p $LDAPPRINC -k $LDAPKEYTAB" 0 "removing http keytab"
		rlRun "ipa service-del $LDAPPRINC" 0 "Remove the LDAP service for this client host"
		rlRun "rm -rf $LDAPKEYTAB $USERKEYTAB" 0 "removing ldap and user keytab files"
	rlPhaseEnd
}
	

