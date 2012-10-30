#!/bin/bash
# hard code test data used during test, they will be changes when used in beaker environment

id=$RANDOM
HOSTNAME=`hostname`

#domain=`hostname -d`
#realm="YZHANG.REDHAT.COM"
#suffix="dc=yzhang,dc=redhat,dc=com"

# help script
add_dns_record="./add.dns.records.sh"
hostPrinciple="host/${HOSTNAME}@${REALM}"
suffix="$BASEDN"

automountLocationA="Location__A"
automountLocationB="Location__B"

nfsConfigFile="/etc/exports"
nfsExportTopDir="/share"
nfsExportSubDir="pub"
nfsDir="$nfsExportTopDir/$nfsExportSubDir"
nfsConfiguration_NonSecure="$nfsExportTopDir *(rw,async,fsid=0,no_subtree_check,no_root_squash)"
nfs_RPCGSS_security_flavors="krb5"
nfsConfiguration_Kerberized="$nfsExportTopDir gss/${nfs_RPCGSS_security_flavors}(rw,async,subtree_check,fsid=0)"
nfsMountType_nfs3=" --type nfs "
nfsMountType_nfs4=" --type nfs4 "
nfsMountType_kerberized=" --type nfs4 -o sec=${nfs_RPCGSS_security_flavors} "

autofsTopDir="/ipashare"
autofsSubDir="public"
autofsDir="$autofsTopDir/$autofsSubDir"

currentNFSMountOption=""
currentNFSFileName="ipaserver.txt"
currentNFSFileSecret="this_is_nfs_file_secret" 
