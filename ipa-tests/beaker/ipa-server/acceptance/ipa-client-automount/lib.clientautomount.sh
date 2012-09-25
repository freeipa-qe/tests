#!/bin/bash
# helping functions for ipa client automount script

configAutofs_indirect(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir]"
    ipa automountlocation-add $name
    ipa automountmap-add $name auto.share
    ipa automountkey-add $name auto.master --key=${autofsTopDir} --info=auto.share
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="-ro,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    ipa automountlocation-tofiles $name
    echo "to delete this configuration: ipa automountlocation-del $name"
    echo "to use this autofs configuration: "
    echo "  (1) ipa-client-automount --server=$nfsHost --location=$name"
    echo "  (2) autofs should be automatic restart, if not, do 'systemctl restart autofs'"
    echo "  (3) to use this mount location: do 'cd /$autofsTopDir/$autofsSubDir' on nfs client (where autofs runs)"
}
