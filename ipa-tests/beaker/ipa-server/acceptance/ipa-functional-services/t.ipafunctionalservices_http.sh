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

######################
# test suite         #
######################
ipafunctionalservices_http()
{
    setup_ipa_http
    setup_http
    http_tests
    cleanup_http
    cleanup_ipa_http
} 

######################
# SETUP              #
######################

setup_ipa_http()
{
	rlPhaseStartTest "SETUP: IPA server - HTTP"

		# create a test http user
		rlRun "create_ipauser httpuser1 httpuser1 httpuser1 Secret123" 0 "Creating a test http user"

		# kinit as admin
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

		# add HTTP service for this client host	
		rlRun "ipa service-add $HTTPPRINC" 0 "Add HTTP service for this client host"

		# get a keytab
		cd $HTTPCFGDIR
		rlRun "ipa-getkeytab -s $MASTER -k $HTTPKEYTAB -p $HTTPPRINC" 0 "Get keytab for this host's http service"
		rlRun "chown apache.apache $HTTPKEYTAB" 0 "Change keytab ownership to apache.apache."

	rlPhaseEnd
}

setup_http()
{
	rlPhaseStartTest "SETUP: HTTP server"

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
		cd /etc/httpd/alias/
        	rlRun "ipa service-show $HTTPPRINC --out=$HOSTNAME.crt" 0 "Get HTTP server cert into a PEM file"

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
        	sed -e "s/Server-Cert/$HOSTNAME/g" /etc/httpd/conf.d/nss.conf > /tmp/nss.conf
        	cp /etc/httpd/conf.d/nss.conf /etc/httpd/conf.d/nss.conf.orig
        	cp -f /tmp/nss.conf /etc/httpd/conf.d/nss.conf

        	# restart the apache server
        	rlRun "service httpd restart" 0 "Restarting apache for SSL configuration to take affect"
	rlPhaseEnd
}

http_tests()
{
        rlPhaseStartTest "ipa-functionalservices-http-001: Access HTTP service with valid credentials"
                rlRun "kinitAs httpuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: curl -v --negotiate -u: http://$HOSTNAME/ipatest/"
                curl -v --negotiate -u: http://$HOSTNAME/ipatest/ > /tmp/curl_001.out 2>&1
		output=`cat /tmp/curl_001.out`
		rlLog "OUTPUT: $output"
                cat /tmp/curl_001.out | grep "404 Not Found"
                if [ $? -eq 0 ] ; then
                        rlPass "User was authenticated"
                else
                        rlFail "User was NOT authenticated"
                fi
        rlPhaseEnd

        rlPhaseStartTest "ipa-functionalservices-http-002: Access HTTP service with out credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: curl -v --negotiate -u: http://$HOSTNAME/ipatest/"
                curl -v --negotiate -u: http://$HOSTNAME/ipatest/ > /tmp/curl_002.out 2>&1
		output=`cat /tmp/curl_002.out`
                rlLog "OUTPUT: $output"
		rlAssertGrep "401 Authorization Required" "/tmp/curl_002.out"
        rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-http-003: Access HTTPS service with valid credentials"
                rlRun "kinitAs httpuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: curl -kv --negotiate --cacert \"IPA CA\" -u: https://$HOSTNAME/ipatest/"
                curl -kv --negotiate --cacert "IPA CA" -u: https://$HOSTNAME/ipatest/ > /tmp/curl_003.out 2>&1
		output=`cat /tmp/curl_003.out`
                rlLog "OUTPUT: $output"
                rlAssertGrep "404 Not Found" "/tmp/curl_003.out"
        rlPhaseEnd

        rlPhaseStartTest "ipa-functionalservices-http-004: Access HTTPS service with out credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: curl -kv --negotiate --cacert \"IPA CA\" -u: https://$HOSTNAME/ipatest/"
                curl -kv --negotiate --cacert "IPA CA" -u: https://$HOSTNAME/ipatest/ > /tmp/curl_004.out 2>&1
		output=`cat /tmp/curl_004.out`
                rlLog "OUTPUT: $output"
		rlAssertGrep "401 Authorization Required" "/tmp/curl_004.out"
        rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-http-005: Disable Service"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa service-disable $HTTPPRINC > /tmp/disable_service.out 2>&1" 0 "Disable HTTP service for this client host"
		rlAssertGrep "Disabled service \"$HTTPPRINC@$RELM\"" "/tmp/disable_service.out"
		# verify service is disabled and certificate removed
		rlRun "ipa service-show --all $HTTPPRINC > /tmp/disable_http.out"
		rlAssertGrep "has_keytab: False" "/tmp/disable_http.out"
		rlAssertNotGrep "Certificate" "/tmp/disable_http.out"
		rlRun "kinitAs httpuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: curl -kv --negotiate -u: http://$HOSTNAME/ipatest/"
                curl -kv --negotiate -u: http://$HOSTNAME/ipatest/ > /tmp/curl_005.out 2>&1
		output=`cat /tmp/curl_005.out`
                rlLog "OUTPUT: $output"
		rlAssertGrep "401 Authorization Required" "/tmp/curl_004.out"
	rlPhaseEnd
}

cleanup_http()
{
	rlPhaseStartTest "CLEANUP: HTTP Server"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		cd /etc/httpd/alias/
		# remove cert files
		rm -rf $HOSTNAME.csr ca.crt $HOSTNAME.crt

		# remove the certificates from the web server's database
		cd /etc/httpd/alias/
		rlRun "certutil -d . -D -n $HOSTNAME" 0 "Remove $HOSTNAME certificate from web server certificate database."
		rlRun "certutil -d . -D -n \"IPA CA\"" 0 "Remove IPA CA certificate from web server certificate database."	

		# delete the krb config file
		rlRun "rm -rf $HTTPKRBCFG" 0 "Delete the KRB config file"

		# restore nss.conf
		cp -f /etc/httpd/conf.d/nss.conf.orig /etc/httpd/conf.d/nss.conf
		rlRun "service httpd restart" 0 "Restarting apache server"
	rlPhaseEnd
}

cleanup_ipa_http()
{
	rlPhaseStartTest "CLEANUP: IPA Server - HTTP"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa user-del httpuser1" 0 "Delete the http test user"
		rlRun "service httpd stop" 0 "stopping apache server"
		rlRun "ipa-rmkeytab -p $HTTPPRINC -k $HTTPKEYTAB" 0 "removing http keytab"
		# delete keytab file
                rlRun "rm -rf $HTTPKEYTAB" 0 "Delete the HTTP keytab file"
		rlRun "ipa service-del $HTTPPRINC" 0 "Remove the HTTP service for this client host"
	rlPhaseEnd
}
	

