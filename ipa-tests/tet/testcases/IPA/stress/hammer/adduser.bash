#!/bin/bash

PREFIX=hammertest
COUNT=10000
DEPTH=10
REALM=DSQA.SJC2.REDHAT.COM
for i in `seq $COUNT` ; do
 template=${PREFIX}${i}-DEPTH-
 name=
 for j in `seq $DEPTH` ; do
   name=${name}${name:+/}${template}${j}
   echo ${name}
   ipa-adduser -f "${name}" -l "${name}" -k "${name}@${REALM}" -p "${name}@${REALM}"  "${name}" 
   echo "dn: uid=${name},cn=users,cn=accounts,dc=dsqa,dc=sjc2,dc=redhat,dc=com" > /tmp/a.ldif
   echo "changetype: modify" >> /tmp/a.ldif
   echo "replace: krbpasswordexpiration" >> /tmp/a.ldif
   echo "krbpasswordexpiration: 20120812162634Z" >> /tmp/a.ldif
   /usr/lib64/mozldap/ldapmodify -h localhost -p 389 -D "cn=directory manager" -w Secret123 -cvf /tmp/a.ldif
 done
done

