#!/bin/bash
# hard code test data used during test, they will be changes when used in beaker environment

id=$RANDOM
hostname=`hostname`
domain=`hostname -d`
realm="YZHANG.REDHAT.COM"
hostPrinciple="host/${hostname}@${realm}"
suffix="dc=yzhang,dc=redhat,dc=com"

automountLocationA="yztest25388"
automountLocationB="yztest12881"
ipaServerMaster="apple.yzhang.redhat.com"
ipaServerMasterIP="192.168.122.101"
ipaServerReplica="aqua.yzhang.redhat.com"
ipaServerReplicaIP="192.168.122.102"
dnsServer="192.168.122.101"
nfsServer=$ipaServerMaster
nfsExportTopDir="/share"
nfsExportSubDir="pub"
nfsDir="$nfsExportTopDir/$nfsExportSubDir"
autofsTopDir="/ipashare${id}"
autofsSubDir="public${id}"
autofsDir="$autofsTopDir/$autofsSubDir"
nfsConfiguration_NonSecure="$nfsExportTopDir *(rw,async,fsid=0,no_subtree_check,no_root_squash)"
nfs_RPCGSS_security_flavors="krb5"
nfsConfiguration_Kerberized="$nfsExportTopDir gss/${nfs_RPCGSS_security_flavors}(rw,async,subtree_check,fsid=0)"
nfsMountType_nfs3=" --type nfs "
nfsMountType_nfs4=" --type nfs4 "
nfsMountType_kerberized=" --type nfs4 -o sec=${nfs_RPCGSS_security_flavors} "

currentLocation=$automountLocationA
currentIPAServer=$ipaServerMaster
currentDNSServer=$dnsServer
currentNFSServer=$nfsServer
currentNFSMountOption=""
#currentNFSFileSecret="[`id`] [`date`]" 
#currentNFSFileName="ipaserver.$id.txt" for test purpose
currentNFSFileName="ipaserver.txt"
currentNFSFileSecret="this is my id" 
