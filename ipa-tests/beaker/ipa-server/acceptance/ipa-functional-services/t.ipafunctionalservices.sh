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
ipafunctionalservices()
{
    setup
    http_services
    cleanup
} 

######################
# SETUP              #
######################

setup()
{
	rlPhaseStartTest "SETUP: IPA server and apache"

		# create a test user
		rlRun "create_ipauser httpuser1 httpuser1 httpuser1 Secret123" 0 "Creating a test user"

		# kinit as admin
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

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
	rlPhaseEnd
}

########################
#  TEST CASES          #
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
                        rlPass "User was NOTauthenticated"
                else
                        rlFail "User was authenticated"
                fi
        rlPhaseEnd
}
########################
# CLEANUP	       #
########################

cleanup()
{
	rlPhaseStartTest "CLEANUP: ipa server and apache"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa user-del httpuser1" 0 "Delete the test user"
		rlRun "service httpd stop" 0 "stopping apache server"
		rlRun "rm -rf $HTTPKRBCFG" 0 "removing kerberos configuration file"
		rlRun "ipa-rmkeytab -p $HTTPPRINC -k $HTTPKEYTAB"
		rlRun "rm -rf $HTTPKEYTAB" 0 "Delete the HTTP keytab file"
		rlRun "ipa service-del $HTTPPRINC" 0 "Remove the HTTP service for this client host"
	rlPhaseEnd
}
	

