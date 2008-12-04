#!/bin/sh

echo "enable replica logging"
/usr/lib*/mozldap/ldapmodify -D "cn=directory manager" -w redhat123 -a -c << _EOF_ 
dn: cn=config
changetype: modify
replace: nsslapd-errorlog-level
nsslapd-errorlog-level: 8192

_EOF_
