#!/bin/bash
# this is a temp script to verify functional test logic

. ./echoline.sh

id=$RANDOM
log="/tmp/test.indirect.$id.log"
hostname=`hostname`
domain=`hostname -d`
realm="YZHANG.REDHAT.COM"
hostPrinciple="host/${hostname}@${realm}"
suffix="dc=yzhang,dc=redhat,dc=com"

automountLocationA="yztest${id}"
ipaServerMaster="apple.yzhang.redhat.com"
dnsServer="192.168.122.101"
nfsServer=$ipaServerMaster
nfsExportTopDir="/share"
nfsExportSubDir="pub"
nfsDir="$nfsExportTopDir/$nfsExportSubDir"
autofsTopDir="/ipashare${id}"
autofsSubDir="public${id}"
autofsDir="$autofsTopDir/$autofsSubDir"
nfsConfiguration_NonSecure="$nfsExportTopDir *(rw,async,fsid=0,no_subtree_check,no_root_squash)"
nfs_RPCGSS_security_optioin="krb5"
nfsConfiguration_Kerberized="$nfsExportTopDir gss/${nfs_RPCGSS_security_optioin}(rw,async,subtree_check,fsid=0)"
nfsMountType_nfs3=" --type nfs "
nfsMountType_nfs4=" --type nfs4 "
nfsMountType_kerberized=" --type nfs4 -o sec=${nfs_RPCGSS_security_optioin} "

currentLocation=$automountLocationA
currentIPAServer=$ipaServerMaster
currentDNSServer=$dnsServer
currentNFSServer=$nfsServer
currentNFSMountOption=""
currentNFSFileName="ipaserver.txt"
currentNFSFileSecret="this_is_nfs_file_secret" 

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
    #ipa automountkey-add $name auto.share --key=${autofsSubDir}  --info="-rw,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsExportTopDir}/${nfsExportSubDir}"
    #ipa automountkey-add $name auto.share --key=${autofsSubDir}  --info="-fstype=nfs4,rw,sec=krb5 ${nfsHost}:${nfsExportTopDir}/${nfsExportSubDir}"
    #ipa automountkey-add $name auto.share --key=${autofsSubDir}  --info="-fstype=nfs4,rw,sec=krb5 ${nfsHost}:/share"
    ipa automountkey-add $name auto.share --key=*  --info="-fstype=nfs4,rw,sec=krb5 ${nfsHost}:/share/&"
    show_autofs_configuration $name
}

verify_autofs_mounting(){
    local p=`pwd`
    cd $autofsTopDir
    mount -l
    echo `pwd`
    ls -l
    show_file_content $currentNFSFileName
    echo "-----the secret should be --"
    echo $currentNFSFileSecret
    echo "----------------------------"
    echo $currentNFSFileSecret > $TmpDir/secret.txt
    if diff $TmpDir/secret.txt $currentNFSFileName 
    then
        echoboldgreen "[$FUNCNAME] :::::::: PASS file content matches"
        echo "test round [$c] pass" >> $log
    else
        echoboldred "[$FUNCNAME] :::::::: FAIL file content does NOT match"
        echo "test round [$c] failed" >> $log
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
        echoboldred ":::::::::::: [$file] does NOT exist :::::::::::::"
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
        sleep 3
        ipa-client-automount --uninstall -U 2>&1 > $tmp
        echo "ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U"
        ipa-client-automount --server=$currentIPAServer --location=$currentLocation -U
        service sssd stop
        sss_cache -A
        #cat /etc/sssd/sssd.conf
        service sssd start
        service sssd status
        service autofs restart
        verify_autofs_mounting
        #clean_up_indirect_map $currentLocation $autofsTopDir $autofsSubDir
        #clean_up_automount_installation
}

add_direct_map(){
# ipa automountkey-add direct001 auto.direct --key=/ipashare001/ipapublic001 --info=f17apple.yzhang.redhat.com:/share/pub
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir=$4
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add $name auto.direct
    ipa automountkey-add $name auto.direct --key=$autofsDir --info="$automountKey_mount_option ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
#    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}
install_ipa_client()
{
    ipa-client-install --domain=yzhang.redhat.com --server=apple.yzhang.redhat.com --unattended --principal=admin --password=Secret123 --hostname=banana.yzhang.redhat.com --mkhomedir 
    echo Secret123 | kinit admin
}

uninstall_ipa_client()
{
    ipa-client-install --uninstall -U
}

################### main ####################
echo Secret123 | kinit admin
c=0
max=1
while [ $c -lt $max ];do
    echobold ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echobold "                            test ($c) starts"
    echobold ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    #install_ipa_client
    add_indirect_map
    #uninstall_ipa_client
    echobold "::::::::::::::::::::::::::::: test finished::::::::::::::::::::::::::::::::::"
    c=$((c+1))
done
echo "log file: $log"
cat $log
