#!/bin/bash

# global environment variables
SERVER=$1
DN=$2

CN="cn=directory manager"
PW="redhat123"
LDAPMODIFY=/usr/lib*/mozldap/ldapmodify

# defaults
if [ -z $DN ]
then
	DN="dc=idm,dc=lab,dc=bos,dc=redhat,dc=com"
	echo "using DN=[$DN]"
fi

if [ -z $SERVER ]
then
	SERVER="mv32a-vm.idm.lab.bos.redhat.com"
	echo "using SERVER=[$SERVER]"
fi

echo "copy schema file to [$SERVER]"
scp ./75autofs.ldif root@$SERVER:/etc/dirsrv/slapd-*/schema/
echo "restart DS"
ssh root@$SERVER "service dirsrv restart"

echo "create top level container"
$LDAPMODIFY -v -h $SERVER  -D "$CN" -w "$PW" -a -c <<_EOF
dn: cn=automount,$DN
objectClass: nsContainer
cn: automount
_EOF

echo "create auto.master map"
$LDAPMODIFY -v -h $SERVER  -D "$CN" -w "$PW" -a -c <<_EOF
dn: automountmapname=auto.master,cn=automount,$DN
objectClass: automountMap
automountmapname: auto.master
objectClass: automountMap
_EOF

echo "create automount map under auto.master for /home"
$LDAPMODIFY -v -h $SERVER  -D "$CN" -w "$PW" -a -c <<_EOF
dn: automountmapname=auto.home,cn=automount,$DN
objectClass: automountMap
automountMapName: auto.home
_EOF

echo "create automount key for auto.home"
$LDAPMODIFY -v -h $SERVER  -D "$CN" -w "$PW" -a -c <<_EOF
dn: automountkey=*,automountmapname=auto.home,cn=automount,$DN
objectClass: automount
automountKey: *
automountInformation: mv32a-vm.idm.lab.bos.redhat.com:/ipahome/&
_EOF

echo "create automount key for auto.home (2)"
$LDAPMODIFY -v -h $SERVER  -D "$CN" -w "$PW" -a -c <<_EOF
dn: automountkey=/ipahome,automountmapname=auto.master,cn=automount,$DN
objectClass: automount
automountKey: /ipahome
automountInformation: auto.home
_EOF

