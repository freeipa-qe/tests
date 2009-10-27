#!/bin/sh

# name : ds.create.example.com.sh
# by   : yzhang
# date : 10-27-2009
# ver  : 0.1
# description:
#       this program accetps argument and create database for us
# options:
#       -h host
#       -p port
#       -D for CN="cn=directory manager"
#       -w for PW="Secret123"
#       -b for basedn="dc=example,dc=com"
#       -i for import ldap file
#       -a for automatic operation : create ldif file, import it into slapd


LDAPSEARCH=`which ldapsearch`
LDAPMODIFY=`which ldapmodify`
OPTIND=1
while getopts h:p:D:w:b:i:a C
do 
  case $C in
	h)
		HOST=$OPTARG
		;;
	p)
		PORT=$OPTARG
		;;
	D)
		CN=$OPTARG
		;;
	w)
		PW=$OPTARG
		;;
	b)
		BASEDN=$OPTARG
		;;
	i)
		LDIF=$OPTARG
		;;
	a)
		AUTO="y"
		;;
	\?)
		echo "unknow option, exiting"
		echo "Usage: ds.create.example.com -h <host> -p <port> -D 'cn=directory manager' -w redhat123 -b 'dc=example,dc=com' -a y
 options:
       -h host
       -p port
       -D for CN="cn=directory manager"
       -w for PW="Secret123"
       -b for basedn="dc=example,dc=com"
       -i for import ldap file
       -a for automatic operation : create ldif file, import it into slapd"
		exit	
  esac
done

## set up defaults ##
: ${HOST:=localhost}
: ${PORT:=389}
: ${CN:="cn=directory manager"}
: ${PW:="Secret123"}
: ${BASEDN="dc=example,dc=com"}
DB=`echo $BASEDN | cut -d',' -f1 | cut -d'=' -f2`
: ${DB="example.com"}


echo "The following values will be used:"
echo "[$HOST]:$PORT,[$CN] [$PW], basedn:[$BASEDN] db=[$DB], [$AUTO] --import ldif file: [$LDIF]"



echo "step 1: create backend"

$LDAPMODIFY -x -h $HOST  -p $PORT -D "$CN" -w "$PW" -c <<-EOF
dn: cn="$BASEDN",cn=mapping tree,cn=config
changetype: add
objectclass: top
objectclass: extensibleObject
objectclass: nsMappingTree
cn: "$BASEDN"
nsslapd-state: backend
nsslapd-backend: $DB
EOF

$LDAPMODIFY -x -h $HOST -p $PORT -D "$CN" -w "$PW" -c <<EOF
dn: cn="$DB" ,cn=ldbm database,cn=plugins,cn=config
changetype: add
objectclass: top
objectclass: extensibleObject
objectclass: nsBackendInstance
cn: $DB
nsslapd-suffix: $BASEDN
nsslapd-cachesize: -1
nsslapd-cachememsize: 10485760
EOF

echo "insert top level records"
$LDAPMODIFY -x -h $HOST -p $PORT -D "$CN" -w "$PW" -a -c <<EOF
dn: $BASEDN
objectClass: top
objectClass: domain
dc: $DB
# above "dc: $DB <-- it is just because DB value is "example", part of BASEDN, 

dn: ou=people,$BASEDN
objectClass: top
objectClass: organizationalunit
ou: people
EOF

echo "insert one test user"
$LDAPMODIFY -x -h $HOST -p $PORT -D "$CN" -w "$PW" -a -c <<EOF
dn: uid=t001,ou=people,$BASEDN
uid: t001
givenName: test
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetorgperson
sn: 001
cn: test 001
mail: t001@example.com
EOF
