#!/bin/bash
# this is a temp script to verify functional test logic

id=$RANDOM
hostname=`hostname`
domain=`hostname -d`
realm="YZHANG.REDHAT.COM"
hostPrinciple="host/${hostname}@${realm}"
suffix="dc=yzhang,dc=redhat,dc=com"

automountLocationA="yztest25388"
automountLocationB="yztest12881"
ipaServerMaster="f17apple.yzhang.redhat.com"
ipaServerMasterIP="192.168.122.171"
ipaServerReplica="f17aqua.yzhang.redhat.com"
ipaServerReplicaIP="192.168.122.173"
dnsServer="192.168.122.171"
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
currentNFSFileName="ipaserver.txt"
currentNFSFileSecret="this is my id" 

echobold(){
    echo -n -e "\033[1m"
    echo -n $@
    echo -e "\033[0m"
    tput sgr0  #set terminal back to normal
}

configure_autofs_indirect(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="${autofsTopDir}/${autofsSubDir}"
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add $name auto.share
    ipa automountkey-add $name auto.master --key=${autofsTopDir} --info=auto.share
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="-rw,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
}

verify_autofs_mounting(){
    local p=`pwd`
    cd $autofsDir
    ls -l
    show_file_content $currentNFSFileName
    echo "-----the secret should be --"
    echo $currentNFSFileSecret
    echo "----------------------------"
    echo $currentNFSFileSecret > $TmpDir/secret.txt
    if diff $TmpDir/secret.txt $currentNFSFileName 
    then
        echobold "$FUNCNAME PASS file content matches"
    else
        echobold "$FUNCNAME FAIL file content does NOT match"
    fi
    cd $p
}


show_autofs_configuration(){
    local locationName=$1
    echo ""
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "      autofs configuration for location [$locationName]"
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    ipa automountlocation-tofiles $name
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
}


clean_up_indirect_map(){
    local name=$1
    local autofsTopDir=$2
    local autofsSubDir=$3
    ipa automountkey-del $name auto.share --key=${autofsSubDir}
    ipa automountkey-del $name auto.master --key=${autofsTopDir}
    ipa automountmap-del $name auto.share
    ipa automountlocation-del $name
    #show_autofs_configuration $name
    echo "umount $autofsDir"
    umount $autofsDir
}

clean_up_automount_installation()
{
    local tmp=$TmpDir/ipa.client.automount.uninstall.$RAMDOM.txt
    echo "#################################################"
    ipa-client-automount --uninstall -U 2>&1 > $tmp
    if [ $? = "0" ];then
        echobold "# clean up ipa-client-automount success"
    else
        echobold "# clean up ipa-client-automount error#"
        cat $tmp
    fi
    echo "#################################################"
    rm $tmp
}

show_file_content(){
    local file=$1
    if [ -f $file ];then
        echo ""
        echo "::::::::::::: [$file] :::::::::::::::"
        cat $file | grep -v "^\s*$" | grep -v "^#"
        echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        echo ""
    else
        echobold ":::::::::::: [$file] does NOT exist :::::::::::::"
    fi
}

pause(){
    local choice="y"
    echo -n "continue? (y/n) "
    read choice
    if [ "$choice" = "n" ];then
        exit
    fi
}

add_indirect_map()
{
        local automounLocation="ipa_indirect_${RANDOM}"
        currentLocation=$automounLocation
        configure_autofs_indirect $currentLocation $currentNFSServer $nfsDir $autofsDir
        echo "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U"
        #pause
        ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U
        #pause
        verify_autofs_mounting
        clean_up_indirect_map $currentLocation $autofsTopDir $autofsSubDir
        clean_up_automount_installation
}



################### main ####################
echobold "test starts"
add_indirect_map
echobold "test finished"
