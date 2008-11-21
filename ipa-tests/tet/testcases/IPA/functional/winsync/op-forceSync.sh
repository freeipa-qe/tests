#!/bin/sh

OP=$1

if [ -z $OP ]
then
	echo "operation= [true / false]"
else
	echo "forceSync configuration [$OP]"
	/usr/lib*/mozldap/ldapmodify -D "cn=directory manager" -w redhat123 -a -c << _EOF_
dn: cn=ipa-winsync,cn=plugins,cn=config
changetype: modify
replace: ipawinsyncforcesync
ipawinsyncforcesync: $OP

_EOF_

fi

