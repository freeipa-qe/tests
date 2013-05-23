#####################
#  GLOBALS	    #
#####################
BASEDN="o=sasl.com"
LDAPPORT=3389
LDAPSPORT=6636
INSTANCECFG="/tmp/instance.inf"
USERLDIF="/tmp/user.ldif"
SASLCFG="/tmp/sasl.ldif"
PWDSCHEME="/tmp/pwdscheme.ldif"
LDAPPRINC="ldap/$HOSTNAME"
LDAPKEYTAB="/etc/dirsrv/ldap_service.keytab"
CLIENTAUTH="allowed"
CIPHERS="-rsa_null_md5,+rsa_fips_3des_sha,+rsa_fips_des_sha,+rsa_3des_sha,+rsa_rc4_128_md5,+rsa_des_sha,+rsa_rc2_40_md5,+rsa_rc4_40_md5"
INSTANCE="slapd-instance1"
PWDFILE="/tmp/pwdfile.txt"

ARCH=`uname -p`
if [[ "$ARCH" == "x86_64" ]] ; then
	OCSPCLT=/usr/lib64/nss/unsupported-tools/ocspclnt
else
	OCSPCLT=/usr/lib/nss/unsupported-tools/ocspclnt
fi

echo "Base DN: $BASEDN"
echo "LDAP port: $LDAPPORT"
echo "Instance configuration file: $INSTANCECFG"
echo "User ldif file: $USERLDIF"
echo "SASL configuration ldif file: $SASLCFG"
echo "Password scheme ldif file: $PWDSCHEME"
echo "LDAP principal: $LDAPPRINC"
echo "LDAP keytab file: $LDAPKEYTAB"
echo "LDAP instance: $INSTANCE"
echo "OSCP test client is $OCSPCLT"

######################
# test suite         #
######################
ldap_testsetup()
{
    setup_ipa_ldap
    setup_ldap
}

ipafunctionalservices_ldap()
{
    ldap_tests
} 

revoke_ldapcert()
{
    revoke_cert
}

######################
# SETUP              #
######################

setup_ipa_ldap()
{
	rlPhaseStartSetup "SETUP IPA server - LDAP"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                # create a test ldap user
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER echo 123passworD | ipa user-add --first=ldapuser1 --last=ldapuser1 --password ldapuser1" 0 "Creating a test ldap user"

                local expfile=/tmp/kinit.exp

                rm -rf $expfile
                echo 'set timeout 30
                set send_slow {1 .1}' > $expfile
                echo "spawn kinit -V ldapuser1" >> $expfile
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

                # kinit as admin
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

                #  add LDAP service for this client host
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-add $LDAPPRINC" 0 "Add LDAP service for this client host"

                # semanage ldap ssl port
                rlRun "semanage port -a -t ldap_port_t -p tcp $LDAPSPORT" 0 "Semanage - add LDAP SSL port"
		
	rlPhaseEnd
} 

setup_ldap()
{
	rlPhaseStartSetup "SETUP LDAP server"
		cd /etc/dirsrv
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa-getkeytab -s $MASTER -k $LDAPKEYTAB -p $LDAPPRINC" 0 "Get keytab for this host's ldap service"
		rlRun "chown nobody:nobody $LDAPKEYTAB" 0 "Change keytab ownership to nobody.nobody"
		rlRun "chmod 0400 $LDAPKEYTAB" 0 "Change keytab permissions to 0400"

		# set up directory server instance
		rlLog "Setting up Directory Server instance ............."
		echo "[General]" > $INSTANCECFG
		echo "FullMachineName= $HOSTNAME" >> $INSTANCECFG
		echo "SuiteSpotUserID= nobody" >> $INSTANCECFG
		echo "SuiteSpotGroup= nobody" >> $INSTANCECFG
		echo "ConfigDirectoryLdapURL= ldap://$HOSTNAME:$LDAPPORT/o=NetscapeRoot" >> $INSTANCECFG
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

		cat $INSTANCECFG

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

		cat $SASLCFG

		rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $SASLCFG" 0 "Add sasl mappings to directory server"

		# change password scheme
		echo "dn: cn=config" > $PWDSCHEME
		echo "changetype: modify" >> $PWDSCHEME
		echo "replace: passwordstoragescheme" >> $PWDSCHEME
		echo "passwordstoragescheme: clear" >> $PWDSCHEME

		cat $PWDSCHEME

		rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $PWDSCHEME" 0 "Change password scheme for directory server"

		# set the KRB5_KTNAME in /etc/sysconfig/dirsrv
		echo "KRB5_KTNAME=$LDAPKEYTAB ; export KRB5_KTNAME" >> /etc/sysconfig/dirsrv
		# restart the directory server
		rlDistroDiff dirsrv_svc_restart

		sleep 5
		# add directory server user
		echo "dn: uid=ldapuser1,$BASEDN" > $USERLDIF
		echo "userPassword: Secret123" >> $USERLDIF
		echo "objectClass: top" >> $USERLDIF
		echo "objectClass: person" >> $USERLDIF
		echo "objectClass: inetorgperson" >> $USERLDIF
		echo "uid: ldapuser1" >> $USERLDIF
		echo "cn: LDAP User1" >> $USERLDIF
		echo "sn: user1" >> $USERLDIF

		cat $USERLDIF
		rlDistroDiff dirsrv_svc_restart
		sleep 10
	
		rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $USERLDIF" 0 "Add user to directory server"

		# SSL setup
		# generate a noise file for key generation
		echo "Creating noise file ....................................................."
		echo "kjasero;uae8905t76V)e6v7q4wy58w4a5;7t90r798bv2[578rbvr7b90w7rbaw0 brwb7yfbz7rv6vawp9" > /tmp/noise.txt

		# generate a password file for cert database
		echo "Creating password file...................................................."
		echo "Secret123" > $PWDFILE

		# create cert db and certificates
		cd /etc/dirsrv/$INSTANCE
		rlRun "certutil -d . -N -f $PWDFILE" 0 "Creating password for certificate databases"

		# add the IPA CA Cert as a trusted certificate to the ldap server's certificate database
                rlLog "Adding the IPA CA certificate to the web server's certificate database ............"
                cd /etc/dirsrv/$INSTANCE
                wget http://$MASTER/ipa/config/ca.crt
                certutil -A -d . -n 'IPA CA' -t CT,, -a < ca.crt

                rlRun "certutil -L -d . -n 'IPA CA'" 0 "Verify the IPA CA certificate was added to the apache server's certificate database"

 		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

                # Get certificate subject
                certsubj=`ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa config-show | grep "Certificate Subject base" | cut -d ":" -f2`
                # trim whitespace
                certsubj=`echo $certsubj`
                rlLog "Certificate Subject: $certsubj"

                # generate a certificate request for the web server
                certutil -R -s "CN=$HOSTNAME,$certsubj" -d . -a -z /tmp/noise.txt -f $PWDFILE > $HOSTNAME.csr
                cat $HOSTNAME.csr
		scp $HOSTNAME.csr admin@$MASTER:/tmp/$HOSTNAME.csr
                # submit the certificate request
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa cert-request --principal=$LDAPPRINC /tmp/$HOSTNAME.csr" 0 "Submitting certificate request for LDAP server"
                # get certificate into PEM file
                cd /etc/dirsrv/$INSTANCE
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-show $LDAPPRINC --out=/tmp/$HOSTNAME.crt" 0 "Get LDAP server cert into a PEM file"
		sftp -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes admin@$MASTER:/tmp/$HOSTNAME.crt .

                # add the LDAP server cert to the certificate database
                certutil -A -n $HOSTNAME -d . -t u,u,u -a -f $PWDFILE < $HOSTNAME.crt

                # Validate the certificate
                rlRun "certutil -V -u V -d . -n $HOSTNAME > /tmp/certvalid.out 2>&1" 0 "Validating LDAP Server certificate"
                cat /tmp/certvalid.out | grep "certificate is valid"

		# Turn on ssl
		/usr/bin/ldapmodify -x -h $HOSTNAME -p $LDAPPORT -D "cn=Directory Manager" -w $ADMINPW <<EOF
dn: cn=config
changetype: modify
replace: nsslapd-security
nsslapd-security: on
-
replace: nsslapd-securePort
nsslapd-secureport: $LDAPSPORT

dn: cn=encryption,cn=config
changetype: modify
replace: nsssl3
nsssl3: on
-
replace: nsssl3ciphers
nsssl3ciphers: ${CIPHERS}
-
replace: nssslclientauth
nssslclientauth: ${CLIENTAUTH}

dn: cn=RSA,cn=encryption,cn=config
changetype: add
objectclass: top
objectclass: nsEncryptionModule
cn: RSA
nsssltoken: internal (software)
nssslpersonalityssl: ${HOSTNAME}
nssslactivation: on
EOF

		# create password file for restart
		cd /etc/dirsrv/$INSTANCE
		echo "Internal (Software) Token:Secret123" > pin.txt

		sleep 10
		# restart the directory server
		rlDistroDiff dirsrv_svc_restart
		sleep 5

		# set up open ldap configuration file
		cp /etc/openldap/ldap.conf /etc/openldap/ldap.conf.orig
		echo "TLS_CACERT      /etc/dirsrv/$INSTANCE/ca.crt" >> /etc/openldap/ldap.conf
	rlPhaseEnd
}

ldap_tests()
{

        rlPhaseStartTest "ipa-functionalservices-ldap-000: Check master ldap configuration"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
                minssf=`ldapsearch -h $MASTER -p 389 -Y GSSAPI -b "cn=config" | grep nsslapd-minssf:`
                rlLog "Master minssf configuration: $minssf"
                anonaccess=`ldapsearch -h $MASTER -p 389 -Y GSSAPI -b "cn=config" | grep nsslapd-allow-anonymous-access:`
                rlLog "Master anonymous access configuration: $anonaccess"
        rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-ldap-001: Access LDAP service with valid credentials"
		rlRun "kinitAs ldapuser1 Secret123" 0 "kinit as user to get valid credentials"
		klist
		klist -ekt $LDAPKEYTAB
		rlLog "Executing: ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"ou=people,$BASEDN\" \"(uid=*)\" dn"
		rlRun "ldapsearch -d1 -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn" 0 "Verify ldapsearch with valid credentials"
	rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-ldap-002: Access LDAP service with out credentials"
        
        rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"ou=people,$BASEDN\" \"(uid=*)\" dn"
                rlRun "ldapsearch -h $HOSTNAME -p $LDAPPORT -Y GSSAPI -s sub -b \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn > /tmp/ldapsearch_006.out 2>&1" 254 "Verify ldapsearch with out valid credentials"
		cat /tmp/ldapsearch_006.out | grep "Credentials cache file '/tmp/krb5cc_0' not found"
		if [ $? -eq 0 ] ; then
			rlPass "Error as expected Credentials not found"
		else
			rlFail "Error NOT as expected:  Did not find credentials not found message"
		fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-ldap-003: Access LDAPS service with credentials"
		rlRun "kinitAs ldapuser1 Secret123" 0 "kinit as user to get valid credentials"
                rlLog "Executing: ldapsearch -H ldaps://$HOSTNAME:$LDAPSPORT -Y GSSAPI -s sub -b  \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn"
                rlRun "ldapsearch -H ldaps://$HOSTNAME:$LDAPSPORT -Y GSSAPI -s sub -b \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn" 0 "Verify ldapsearch with valid credentials"
        rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-ldap-004: Access LDAPS service without credentials"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: ldapsearch -H ldaps://$HOSTNAME:$LDAPSPORT -Y GSSAPI -s sub -b \"ou=people,$BASEDN\" \"(uid=*)\" dn"
                rlRun "ldapsearch -H ldaps://$HOSTNAME:$LDAPSPORT -Y GSSAPI -s sub -b \"uid=ldapuser1,$BASEDN\" \"(uid=*)\" dn > /tmp/ldapsearch_008.out 2>&1" 254 "Verify ldapsearch with valid credentials"
                cat /tmp/ldapsearch_008.out | grep "Credentials cache file '/tmp/krb5cc_0' not found"
                if [ $? -eq 0 ] ; then
                        rlPass "Error as expected Credentials not found"
                else
                        rlFail "Error NOT as expected:  Did not find credentials not found message"
                fi
        rlPhaseEnd

	rlPhaseStartTest "ipa-functionalservices-ldap-005: LDAPS simple bind"
                rlRun "kdestroy" 0 "destroy kerberos credentials"
                rlLog "Executing: ldapsearch -x -H ldaps://$HOSTNAME:$LDAPSPORT -D \"cn=Directory Manager\" -w $ADMINPW -b \"o=sasl.com\""
                rlRun "ldapsearch -x -H ldaps://$HOSTNAME:$LDAPSPORT -D \"cn=Directory Manager\" -w $ADMINPW -b \"o=sasl.com\"" 0 "Verify ldapsearch SSL Simple Bind"
        rlPhaseEnd
}

revoke_cert()
{
        rlPhaseStartTest "ipa-functionalservices-ldap-006: Revoke certificate"
                rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		# revoke the HTTP server's certificate - first need the certificate's serial number
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa service-show --all $LDAPPRINC > /tmp/certout.txt"
		sftp admin@$MASTER:/tmp/certout.txt /tmp/certout.txt
                serialnos=`cat /tmp/certout.txt | grep "Serial Number" | cut -d ":" -f 2 | cut -d ":" -f 2`
                serialno=`echo $serialnos | cut -d " " -f 1`
                rlLog "$LDAPPRINC certificate serial number: $serialno"
                rlRun "ssh -o GSSAPIAuthentication=yes -o GSSAPIDelegateCredentials=yes -o StrictHostKeyChecking=no admin@$MASTER ipa cert-revoke $serialno" 0 "Revoke LDAP server's certificate"
		rlLog "Checking certificate revokation via OCSP"
		rlLog "EXECUTING: $OCSPCLT -S \"$HOSTNAME\" -d /etc/dirsrv/$INSTANCE/"
		rlRun "$OCSPCLT -S \"$HOSTNAME\" -d /etc/dirsrv/$INSTANCE/ > /tmp/ocsp.out" 0 "Running ocspclnt"
		rlAssertGrep "Peer's Certificate has been revoked." "/tmp/ocsp.out"
        rlPhaseEnd
}

