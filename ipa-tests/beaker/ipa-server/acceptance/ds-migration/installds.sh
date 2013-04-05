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
#service iptables stop
systemctl stop firewalld.service

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

# change password scheme
echo "dn: cn=config" > $PWDSCHEME
echo "changetype: modify" >> $PWDSCHEME
echo "replace: passwordstoragescheme" >> $PWDSCHEME
echo "passwordstoragescheme: clear" >> $PWDSCHEME

cat $PWDSCHEME

/usr/bin/ldapmodify -a -x -h $HOSTNAME -p $LDAPPORT -D "cn=Directory Manager" -w $ADMINPW -c -f $PWDSCHEME

##########################################################################
# SSL Secure instance 
##########################################################################


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

##########################################################################
# Transfer CA certificate to the IPA Server for SSL migration test
##########################################################################

cd /etc/dirsrv/$INSTANCE
rlLog "EXECUTING: certutil -d . -L -n "CA certificate" -a > remoteds.crt"
certutil -d . -L -n "CA certificate" -a > remoteds.crt
ls /etc/dirsrv/$INSTANCE/remoteds.crt
rlLog "EXECUTING: scp remoteds.crt root@$MASTER:/ipa/crt/remoteds.crt"
scp remoteds.crt root@$MASTER:/etc/ipa/remoteds.crt

###########################################################################
#  add a couple users and a couple of groups
###########################################################################
	cat > instance1.ldif << instance1.ldif_EOF

version: 1

dn: ou=Boston,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: Boston

dn: ou=BostonUsers,ou=Boston,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: BostonUsers

dn: ou=BostonGroups,ou=Boston,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: BostonGroups

dn: uid=puser1,ou=People,dc=example,dc=com
passwordGraceUserTime: 0
modifiersName: cn=directory manager
uidNumber: 1001
gidNumber: 1001
objectClass: top
objectClass: person
objectClass: posixAccount
uid: puser1
cn: Posix User1
sn: User1
homeDirectory: /home/puser1
loginshell: /bin/bash
userPassword: fo0m4nchU
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8a-1dd211b2-8f88fe1c-fcc30000

dn: uid=puser2,ou=People,dc=example,dc=com
passwordGraceUserTime: 0
uidNumber: 1002
gidNumber: 1002
objectClass: top
objectClass: person
objectClass: posixAccount
uid: puser2
cn: Posix User2
sn: User2
homeDirectory: /home/puser2
loginshell: /bin/bash
userPassword: Secret123
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
modifiersName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8b-1dd211b2-8f88fe1c-fcc30000

dn: cn=Philomena Hazen, ou=People, dc=example,dc=com
carLicense: PV7JWI8
cn: Philomena Hazen
departmentNumber: 5959
description: This is Philomena Hazen's description
employeeType: Manager
facsimileTelephoneNumber: +1 804 471-8791
givenName: Philomena
homePhone: +1 408 746-4902
initials: P. H.
l: Santa Clara
mail: Philomena_Hazen@example.com
manager: cn=Torrie Paluso,ou=People,dc=example,dc=com
mobile: +1 818 300-2476
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
ou: Human Resources
pager: +1 206 932-6524
postalAddress: example.com, Human Resources Dept #204, Room#545
roomNumber: 5433
secretary: cn=Tiphany Samieian,ou=People,dc=example,dc=com
sn: Hazen
telephoneNumber: +1 206 660-3641
title: Senior Human Resources Accountant
uid: Philomena_Hazen
userPassword: nezaHanemo
objectclass: posixAccount
uidNumber: 18795
gidNumber: 28795
homeDirectory: /home/Philomena_Hazen

dn: uid=bosusr,ou=BostonUsers,ou=Boston,dc=example,dc=com
passwordGraceUserTime: 0
modifiersName: cn=directory manager
uidNumber: 1003
gidNumber: 1003
objectClass: top
objectClass: person
objectClass: posixAccount
uid: bosusr
cn: Boston User
sn: User
homeDirectory: /home/bosusr
loginshell: /bin/bash
userPassword: fo0m4nchU
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8a-1dd211b2-8f88fe1c-fcc30001

dn: cn=Group1,ou=groups,dc=example,dc=com
gidNumber: 1001
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: Group1
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
modifiersName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8c-1dd211b2-8f88fe1c-fcc30000

dn: cn=Group2,ou=groups,dc=example,dc=com
gidNumber: 1002
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: Group2
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
modifiersName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8d-1dd211b2-8f88fe1c-fcc30003

dn: cn=bosgrp,ou=BostonGroups,ou=Boston,dc=example,dc=com
gidNumber: 1003
objectClass: top
objectClass: groupOfNames
objectClass: posixGroup
cn: bosgrp
creatorsName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
modifiersName: uid=admin,ou=administrators,ou=topologymanagement,o=netscaperoot
nsUniqueId: 42598c8d-1dd211b2-8f88fe1c-fcc30005
instance1.ldif_EOF

rlRun "/usr/bin/ldapmodify -a -x -h $HOSTNAME -p 389 -D \"cn=Directory Manager\" -w $ADMINPW -c -f instance1.ldif" 0


}
