#####################
#  GLOBALS	    #
#####################
BASEDN="dc=example,dc=com"
LDAPPORT=389
LDAPSPORT=636
INSTANCECFG="/tmp/instance.inf"
PWDSCHEME="/tmp/pwdscheme.ldif"
CLIENTAUTH="allowed"
CIPHERS="-rsa_null_md5,+rsa_fips_3des_sha,+rsa_fips_des_sha,+rsa_3des_sha,+rsa_rc4_128_md5,+rsa_des_sha,+rsa_rc2_40_md5,+rsa_rc4_40_md5"
INSTANCE="slapd-instance1"
PWDFILE="/tmp/pwdfile.txt"

echo "Base DN: $BASEDN"
echo "LDAP port: $LDAPPORT"
echo "LDAPS port: $LDAPSPORT"
echo "Instance configuration file: $INSTANCECFG"
echo "Password scheme ldif file: $PWDSCHEME"
echo "LDAP instance: $INSTANCE"

installds(){

####################################################
# turn off firewall
####################################################
service iptables stop

####################################################
# set up directory server instance
####################################################

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

/usr/sbin/setup-ds.pl --silent --file=$INSTANCECFG
/usr/bin/ldapsearch -x -h $HOSTNAME -p $LDAPPORT -D "cn=Directory manager" -w $ADMINPW -b "$BASEDN"

##########################################################################
# SSL Secure instance 
##########################################################################
HERE=`echo $PWD`

rlLog "Creating noise file ....................................................."
echo "kjasero;uae8905t76V)e6v7q4wy58w4a5;7t90r798bv2[578rbvr7b90w7rbaw0 brwb7yfbz7rv6vawp9" > /tmp/noise.txt
rlLog "Creating password file...................................................."
echo "echo Secret123 > /tmp/pwdfile.txt"

rlLog "Creating password for certificate databases .............................."
cd /etc/dirsrv/$INSTANCE 
certutil -d . -N -f /tmp/pwdfile.txt

rlLog "Creating CA certificate .................................................."
cd /etc/dirsrv/$INSTANCE
echo -e "y\n\ny\n" | certutil -S -n "CA certificate" -s "cn=CA cert,dc=example,dc=com" -2 -x -t "CT,," -m 1000 -v 120 -d . -k rsa -f /tmp/pwdfile.txt -z /tmp/noise.txt

rlLog "Creating Server certificate ................................................"
cd /etc/dirsrv/$INSTANCE
certutil -S -n "Server-Cert" -s "cn=$HOSTNAME, cn=Directory Server" -c "CA certificate" -t "u,u,u" -m 1001 -v 120 -d . -k rsa -f /tmp/pwdfile.txt -z /tmp/noise.txt

###########################################################################
# Turn on ssl
###########################################################################
rlLog "Turning on ssl ............................................."
cat > ssl.ldif << ssl.ldif_EOF

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
nssslclientauth: $CLIENTAUTH

dn: cn=RSA,cn=encryption,cn=config
changetype: add
objectclass: top
objectclass: nsEncryptionModule
cn: RSA
nsssltoken: internal (software)
nssslpersonalityssl: Server-Cert
nssslactivation: on
ssl.ldif_EOF

/usr/bin/ldapmodify -x -h $HOSTNAME -p 389 -D "cn=Directory Manager" -w $ADMINPW -c -f ./ssl.ldif

rlRun "echo \"Internal (Software) Token:Secret123\" > /etc/dirsrv/$INSTANCE/pin.txt" 0

# restart the directory server
if [ "$FLAVOR" == "Fedora" ] ; then
	rlRun "systemctl restart dirsrv.target" 0 "Restarting directory server for ssl changes"
else
	rlRun "service dirsrv restart" 0 "Restarting directory server for ssl changes"
fi

sleep 3

rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p 389 -D \"cn=Directory Manager\" -w $ADMINPW -c -f $HERE/setup.ldif" 0


}
