#!/bin/sh

OP=$1
if [ -z $OP ]
then
	echo "operation= [none | to_ad | to_ds | both]"
else

echo "perform operation [$OP]"
/usr/lib*/mozldap/ldapmodify -D "cn=directory manager" -w redhat123 -a -c << _EOF_
dn: cn=ipa-winsync,cn=plugins,cn=config
changetype: modify
replace: ipaWinSyncAcctDisable
ipaWinSyncAcctDisable: $OP

_EOF_

fi

