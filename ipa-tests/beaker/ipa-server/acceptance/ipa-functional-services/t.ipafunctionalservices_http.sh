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
http_testsetup()
{
    setup_ipa_http
    setup_http
}

ipafunctionalservices_http()
{
    http_tests
} 

disable_httpservice()
{
    disable_service
}

######################
# SETUP              #
######################

setup_ipa_http()
{
	rlPhaseStartSetup "SETUP IPA server - HTTP"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"	
		# create a test http user
		rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER echo 123passworD | ipa user-add --first=httpuser1 --last=httpuser1 --password httpuser1 " 0 "Creating a test http user"

    		local expfile=/tmp/kinit.exp

		rm -rf $expfile
    		echo 'set timeout 30
		set send_slow {1 .1}' > $expfile
    		echo "spawn kinit -V httpuser1" >> $expfile
    		echo 'match_max 100000' >> $expfile
    		echo 'expect "*: "' >> $expfile
    		echo 'sleep .5' >> $expfile
    		echo "send -s -- 123passworD" >> $expfile
    		echo 'send -s -- "\r"' >> $expfile
    		echo 'expect "*: "' >> $expfile
    		echo 'sleep .5' >> $expfile
    		echo "send -s -- Secret123" >> $expfile
    		echo 'send -s -- "\r"' >> $expfile
    		echo 'expect "*: "' >> $expfile
    		echo 'sleep .5' >> $expfile
    		echo "send -s -- Secret123" >> $expfile
    		echo 'send -s -- "\r"' >> $expfile
    		echo 'expect eof ' >> $expfile

    		/usr/bin/expect $expfile

		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                # add HTTP service for this client host 
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-add $HTTPPRINC" 0 "Add HTTP service for this client host"

                # get a keytab
                cd $HTTPCFGDIR
                rlRun "ipa-getkeytab -s $MASTER -k $HTTPKEYTAB -p $HTTPPRINC" 0 "Get keytab for this host's http service"
                rlRun "chown apache.apache $HTTPKEYTAB" 0 "Change keytab ownership to apache.apache."

	rlPhaseEnd
}

setup_http()
{
	rlPhaseStartSetup "SETUP HTTP server"
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
        	certsubj=`ssh -o GSSAPIDelegateCredentials=yes -o GSSAPIAuthentication=yes -o StrictHostKeyChecking=no admin@$MASTER ipa config-show | grep "Certificate Subject base" | cut -d ":" -f2`
        	# trim whitespace
        	certsubj=`echo $certsubj`
        	rlLog "Certificate Subject: $certsubj"

        	# generate a certificate request for the web server
        	certutil -R -s "CN=$HOSTNAME,$certsubj" -d . -a -z /etc/group > /tmp/$HOSTNAME.csr
        	cat /tmp/$HOSTNAME.csr

        	# submit the certificate request
		scp /tmp/$HOSTNAME.csr admin@$MASTER:/tmp/$HOSTNAME.csr
        	rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa cert-request --principal=$HTTPPRINC /tmp/$HOSTNAME.csr" 0 "Submitting certificate request for HTTP server"
        	# get certificate into PEM file
		cd /etc/httpd/alias/
        	rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-show $HTTPPRINC --out=/tmp/$HOSTNAME.crt" 0 "Get HTTP server cert into a PEM file"
		sftp -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes admin@$MASTER:/tmp/$HOSTNAME.crt /tmp/$HOSTNAME.crt

        	# add the HTTP server cert to the certificate database
        	certutil -A -n $HOSTNAME -d . -t u,u,u -a < /tmp/$HOSTNAME.crt

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

	rlPhaseStartTest "ipa-functionalservices-http-000: Check master ldap configuration"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		minssf=`ldapsearch -h $MASTER -p 389 -Y GSSAPI -b "cn=config" | grep nsslapd-minssf:`
		rlLog "Master minssf configuration: $minssf"
		anonaccess=`ldapsearch -h $MASTER -p 389 -Y GSSAPI -b "cn=config" | grep nsslapd-allow-anonymous-access:`
		rlLog "Master anonymous access configuration: $anonaccess"
	rlPhaseEnd

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
                rlLog "Executing: curl -v --negotiate --cacert \"/etc/ipa/ca.crt\" -u: https://${HOSTNAME}:8443/ipatest/"
                curl -v --negotiate --cacert "/etc/ipa/ca.crt" -u: https://${HOSTNAME}:8443/ipatest/ > /tmp/curl_003.out 2>&1
		output=`cat /tmp/curl_003.out`
                rlLog "OUTPUT: $output"
                rlAssertGrep "404 Not Found" "/tmp/curl_003.out"
        rlPhaseEnd

        rlPhaseStartTest "ipa-functionalservices-http-004: Access HTTPS service with out credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: curl -v --negotiate --cacert \"/etc/ipa/ca.crt\" -u: https://${HOSTNAME}:8443/ipatest/"
                curl -v --negotiate --cacert "/etc/ipa/ca.crt" -u: https://${HOSTNAME}:8443/ipatest/ > /tmp/curl_004.out 2>&1
		output=`cat /tmp/curl_004.out`
                rlLog "OUTPUT: $output"
		rlAssertGrep "401 Authorization Required" "/tmp/curl_004.out"
        rlPhaseEnd

}

disable_service()
{
	rlPhaseStartTest "ipa-functionalservices-http-005: Disable Service"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-disable $HTTPPRINC > /tmp/disable_service.out 2>&1" 0 "Disable HTTP service for this client host"
		sftp admin@$MASTER:/tmp/disable_service.out /tmp/disable_service.out
		rlAssertGrep "Disabled service \"$HTTPPRINC@$RELM\"" "/tmp/disable_service.out"
		# verify service is disabled and certificate removed
		rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-show --all $HTTPPRINC > /tmp/disable_http.out"
		sftp admin@MASTER:/tmp/disable_http.out /tmp/disable_http.out
		rlAssertGrep "Keytab: False" "/tmp/disable_http.out"
		rlAssertNotGrep "Certificate" "/tmp/disable_http.out"
		rlRun "kinitAs httpuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: curl -kv --negotiate -u: http://$HOSTNAME/ipatest/"
                curl -kv --negotiate -u: http://$HOSTNAME/ipatest/ > /tmp/curl_005.out 2>&1
		output=`cat /tmp/curl_005.out`
                rlLog "OUTPUT: $output"
		rlAssertGrep "401 Authorization Required" "/tmp/curl_005.out"
		#re-enable service
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	rlPhaseEnd
}

	

