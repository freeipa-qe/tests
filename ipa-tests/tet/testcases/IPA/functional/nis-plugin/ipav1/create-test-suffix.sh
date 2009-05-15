#!/bin/bash

LDAPMODIFY=/usr/lib*/mozldap/ldapmodify
LDAPSEARCH=/usr/lib*/mozldap/ldapsearch
DN="cn=directory manager"
PW="redhat123"

SERVER="mv32a-vm.idm.lab.bos.redhat.com"
SUFFIX="cn=nisaccounts,dc=idm,dc=lab,dc=bos,dc=redhat,dc=com"
DB="nisData"

echo "AddSuffix..."

echo "add the suffix (1) : add into cn=mapping tree,cn=plugin,cn=config"

$LDAPMODIFY -v -h $SERVER -D "$DN" -w $PW -c <<-EOF
dn: cn="$SUFFIX",cn=mapping tree,cn=config
changetype: add
objectclass: top
objectclass: extensibleObject
objectclass: nsMappingTree
cn: "$SUFFIX"
nsslapd-state: backend
nsslapd-backend: $DB
nsslapd-parent-suffix: "dc=idm,dc=lab,dc=bos,dc=redhat,dc=com"
EOF

echo "add the suffix (2) : setup database :add into ldbm database,cn=plugin,cn=config"
$LDAPMODIFY -v -h $SERVER -D "$DN" -w $PW -c <<-EOF
dn: cn=$DB,cn=ldbm database,cn=plugins,cn=config
changetype: add
objectclass: top
objectclass: extensibleObject
objectclass: nsBackendInstance
cn: $DB
nsslapd-suffix: $SUFFIX
nsslapd-cachesize: -1
nsslapd-cachememsize: 10485760
EOF

echo "Done with AddSuffix"
echo ""

