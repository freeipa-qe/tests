#!/bin/sh

uid=$1

if [ -z $uid ]
then
	uid=150
fi

echo "modify uid=[$uid]"

/usr/lib*/mozldap/ldapmodify -h win2003.rhqa.net -p 389 -D "cn=administrator,cn=users,dc=rhqa,dc=net" -w redhat -a -c << _EOF_
dn: CN=auser $uid,OU=mmr,DC=rhqa,DC=net
changetype: modify
replace: telephoneNumber
telephoneNumber : 650-123-0000-$uid
_EOF_

ipa-finduser -a a$uid | grep "Work Number"

ipa-moduser --setattr "telephonenumber=650-123-4567-174" a174




uid=$1
field=$2

if [ -z $field ]
then
	field=*
fi

if [ -z $uid ]
then
	echo "ad-finduser <uid>"
else
 /usr/lib*/mozldap/ldapsearch -h win2003.rhqa.net -p 389 -D "cn=administrator,cn=users,dc=rhqa,dc=net" -w redhat -b "dc=rhqa,dc=net" "sAMAccountName=$uid*" "$field" 
fi

