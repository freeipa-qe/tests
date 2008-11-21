#!/bin/sh

QA_DIR=/export/share
QAUTIL_DIR=$QA_DIR/qautil
WINSYNC_DIR=$QA_DIR/testcases-ipa/functional/winsync

echo "this is a procedure i followed currently"
echo "
1. install ipa-server
2. enable replica logging
3. inject data
4. enable replica logging run 'op-enablereplicalogging.sh'
5. ensure account Disable fucntion is setting to 'both' run 'op-accDisableSync.sh both'
6. make sure the connection with AD is be able to establish
 /usr/lib*/mozldap/ldapsearch -h win2003.rhqa.net -p 389 -D "cn=administrator,cn=users,dc=rhqa,dc=net" -w redhat -b "cn=users,dc=rhqa,dc=net" "" "*" 
7. create winsync agreement run the following command
    ipa-replica-manage add --winsync 
                       --binddn cn=administrator,cn=users,dc=rhqa,dc=net 
                       --bindpw redhat 
                       --cacert /export/share/testcase-ipa/functional/winsync/certs/win2003-ad-cert.cer 
                       --passsync passsync123
                       win2003.rhqa.net -v 

   or copy the following line
ipa-replica-manage add --winsync --binddn 'cn=administrator,cn=users,dc=rhqa,dc=net' --bindpw redhat --cacert /export/share/testcase-ipa/functional/winsync/certs/win2003-ad-cert.cer --passsync passsync123  --win-subtree "ou=mmr,dc=rhqa,dc=net" -v win2003.rhqa.net

"

