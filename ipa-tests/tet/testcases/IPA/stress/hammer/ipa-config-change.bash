#!/bin/bash

# edit maxuserlength config param
suffix=
echo "dn: cn=ipaConfig,cn=etc,dc=dsqa,dc=sjc2,dc=redhat,dc=com" > /tmp/a.ldif
echo "changetype: modify" >> /tmp/a.ldif
echo "replace: ipamaxusernamelength" >> /tmp/a.ldif
echo "ipamaxusernamelength: 5000000 " >> /tmp/a.ldif

/usr/lib64/mozldap/ldapmodify -h localhost -p 389 -D "cn=directory manager" -w Secret123 -cvf /tmp/a.ldif


# replace ipa-adduser

/bin/cp ./ipa-adduser /usr/sbin/
