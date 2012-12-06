#!/bin/bash
# hard code test data used during test, they will be changes when used in beaker environment

id=$RANDOM
HOSTNAME=`hostname`

#domain=`hostname -d`
#relm="YZHANG.REDHAT.COM"
#suffix="dc=yzhang,dc=redhat,dc=com"

hostPrinciple="host/${HOSTNAME}@${RELM}"
nfsServicePrinciple="nfs/${HOSTNAME}@${RELM}"
suffix="$BASEDN"

automountLocationA="Location__A"
automountLocationB="Location__B"

keytabFile="/etc/krb5.keytab"
nfsConfigFile="/etc/exports"
nfsSystemConf="/etc/sysconfig/nfs"
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

log_httpd="/var/log/httpd/error_log"
log_ldap="/var/log/dirsrv/slapd-*/errors"
log_sys="/var/log/messages"
log_krb5="/var/log/krb5kdc.log"
log_selinux="/var/log/audit/audit.log"
logs="$log_sys $log_ldap $log_httpd $log_krb5 $log_selinux"

# special notes: yzhang@redhat.com Nov. 16, 2012
# as one special case: the LDAP_URI in /etc/sysconfig/nfs would have different
# value depends on whether ipa server and automount location is given when run
# ipa-client-automount 
LDAP_URI=""

###################################################################################
# 1. when only --location=< automount location> is given
# expect: "LDAP_URI=ldap:///${suffix}"
# 2. when -server=<ipa server> is given,  or --server=<ipa server> --location=<automount location> both given
#expect: "LDAP_URI=ldap://${currentIPAServer}"
###################################################################################
