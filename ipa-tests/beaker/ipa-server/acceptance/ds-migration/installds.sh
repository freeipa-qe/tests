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

rlRun "/usr/sbin/setup-ds.pl --silent --file=$INSTANCECFG" 0 "Silent instance creation"
rlRun "/usr/bin/ldapsearch -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory manager\" -w $ADMINPW -b \"$BASEDN\"" 0 "Verifying directory server instance"

# change password scheme
echo "dn: cn=config" > $PWDSCHEME
echo "changetype: modify" >> $PWDSCHEME
echo "replace: passwordstoragescheme" >> $PWDSCHEME
echo "passwordstoragescheme: clear" >> $PWDSCHEME

cat $PWDSCHEME

rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D \"cn=Directory Manager\" -w $ADMINPW -c -f $PWDSCHEME" 0 "Change password scheme for directory server"

##########################################################################
# SSL Secure instance 
##########################################################################


rlLog "Creating noise file ....................................................."
rlRun "echo \"kjasero;uae8905t76V)e6v7q4wy58w4a5;7t90r798bv2[578rbvr7b90w7rbaw0 brwb7yfbz7rv6vawp9\" > /tmp/noise.txt" 0
rlLog "Creating password file...................................................."
rlRun "echo Secret123 > /tmp/pwdfile.txt"

rlLog "Creating password for certificate databases .............................."
rlRun "cd /etc/dirsrv/$INSTANCE" 0 
rlRun "certutil -d . -N -f /tmp/pwdfile.txt" 0

rlLog "Creating CA certificate .................................................."
rlRun "cd /etc/dirsrv/$INSTANCE" 0
	rlRun "echo -e \"y\n\ny\n\" | certutil -S -n \"CA certificate\" -s \"cn=CA cert,dc=example,dc=com\" -2 -x -t \"CT,,\" -m 1000 -v 120 -d . -k rsa -f /tmp/pwdfile.txt -z /tmp/noise.txt" 0

rlLog "Creating Server certificate ................................................"
rlRun "cd /etc/dirsrv/$INSTANCE" 0
rlRun "certutil -S -n \"Server-Cert\" -s \"cn=$HOSTNAME, cn=Directory Server\" -c \"CA certificate\" -t \"u,u,u\" -m 1001 -v 120 -d . -k rsa -f /tmp/pwdfile.txt -z /tmp/noise.txt"

rlLog "Creating cacert.asc file .................................................."
rlRun "certutil -d . -L -n \"CA certificate\" -a > cacert.asc" 0

###########################################################################
# Turn on ssl
###########################################################################

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

rlRun "/usr/bin/ldapmodify -x -h $SERVERS -p 389 -D \"$ROOTDN\" -w $ROOTDNPWD -c -f ssl.ldif" 0
rlRun "service dirsrv restart" 0 "Restarting directory server for SSL configuration"
