#!/bin/bash
# helping functions for ipa client automount script

configure_autofs_indirect(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="${autofsTopDir}/${autofsSubDir}"
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add $name auto.share
    ipa automountkey-add $name auto.master --key=${autofsTopDir} --info=auto.share
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="$automountKey_mount_option ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
#    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

configure_autofs_indirect_use_wildcard(){
    local name=$1
    local nfsHost=$2
    local nfsTopDir=$3
    local autofsDir="${autofsTopDir}"
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add $name auto.share
    ipa automountkey-add $name auto.master --key=${autofsTopDir} --info=auto.share
    ipa automountkey-add $name auto.share --key=* --info="$automountKey_mount_option ${nfsHost}:${nfsTopDir}/&"
    show_autofs_configuration $name
#    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

configure_autofs_indirect2(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="${autofsTopDir}/${autofsSubDir}"
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add-indirect $name auto.share --mount=${autofsTopDir} --parentmap=auto.master
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="$automountKey_mount_option ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
#    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

configure_autofs_direct(){
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

verify_autofs_mounting(){
    local startingDir=`pwd`
    rlLog "[verify_autofs_mounting] starts..."
    rlLog "Starting point: [$startingDir]. try get into client side autofs directory: cd $autofsDir"
    if cd $autofsDir; then
        rlLog "get into autofs dir [$autofsDir], great, now check file content"
        pwd
        ls -al
        show_file_content $currentNFSFileName
        echo "-----the secret should be ------"
        echo $currentNFSFileSecret
        echo "--------------------------------"
        echo $currentNFSFileSecret > $TmpDir/secret.txt
        if diff $TmpDir/secret.txt $currentNFSFileName 
        then
            rlPass "autofs mount success, file content matches"
        else
            debuginfo
            rlFail "autofs mount failed, file content does NOT matches"
        fi
    else
        rlLog "can not get into [$autofsDir], now try one step at time"
        if cd $autofsTopDir ;then
            rlLog "get into top dir [$autofsTopDir], continue, ls -al:"
            ls -al
            if cd $autofsSubDir ;then
                rlLog "great, we are where we want to be, now do ls"
                pwd
                ls -al
                show_file_content $currentNFSFileName
                echo $currentNFSFileSecret > $TmpDir/secret.txt
                rlRun "diff $TmpDir/secret.txt $currentNFSFileName" 0 "diff our secret with desired secret, they should match"
            else
                rlLog "it looks like we can not get into sub dir [$autofsSubDir], this is ok, let's try other ways to verify mount: mount -l"
                mount -l
                if mount -l | grep "$autofsSubDir" 2>&1 >/dev/null
                then
                    rlPass "mount -l showed mount location, test still consider pass"
                else
                    rlLog "mount -l shows no sign of mounted location, try ls -al"
                    ls -al
                    if ls -al | grep "$autofsSubDir" 
                    then
                        rlPass "ls -al shows the mounted location, test pass"
                        pwd
                        ls -al
                    else
                        rlLog "try lsof | grep $autofsTopDir to verify whether autofs locked "
                        lsof | grep "$autofsTopDir"
                        if lsof | grep "autofsTopDir"
                        then
                            rlLog "autofs locked, try other solutions later"
                        else
                            debuginfo
                            rlFail "we get into top level dirs, but not the sub level, current dir=[`pwd`], mount -l does not show either"
                        fi
                    fi
                fi
            fi
        else
            rlFail "can not get into autofs directory at all, not even top level, client side dir=[$autofsDir]"
            debuginfo
        fi
    fi
    rlRun "cd $startingDir" 0 "go back to starting point: [$startingDir]"
    rlLog "[verify_autofs_mounting] finished"
}

debuginfo()
{
    show_autofs_configuration $currentLocation
    echo "================ debugging information ===================="
    echo "showmount -e $NFS_IPA"
    showmount -e $NFS_IPA
    echo "rpcinfo -p $NFS_IPA"
    rpcinfo -p $NFS_IPA
    print_logs
    echo "====================[ /var/log/sssd/sssd_autofs.log  ]======================================="
    cat /var/log/sssd/sssd_autofs.log
}

clean_up_direct_map(){
    local name=$1
    local autofs_dir=$2
    rlPhaseStartTest "clean up indirect map location [$name], autofs dir=$autofs_dir"
        echo ipa automountkey-del $name auto.direct --key=$autofs_dir
        ipa automountkey-del $name auto.direct --key=$autofs_dir
        rlRun "umount -f $autofs_dir " 0 "umount -f $autofs_dir"
    rlPhaseEnd
}

umount_autofs_directory()
{
    local currentDir=`pwd`
    rlLog "current directory = [$currentDir]"
    echo "====== mount list before ======"
    mount -l
    echo "====== lsof | grep $autofsTopDir ===="
    lsof | grep "$autofsTopDir"
    echo "====================================="
    if umount -fv $autofsDir
    then
        rlPass "umount [$autofsDir] success"
    else
        rlLog "umount [$autofsDir] failed, try umount [$autofsTopDir]"
        umount -fv $autofsTopDir
        if [ "$?" = "1" ];then
            rlLog "umount [$topDir] also failed, let's pray the rest test will magically work ;)"
            lsof | grep "$autofsTopDir"
            echo "last 15 lines of /var/log/message"
            tail -n 15 /var/log/message
        else
            rlPass "umount [$autofsTopDir] success"
        fi
    fi
}

clean_up_indirect_map_and_umount(){
    local name=$1
    echo ipa automountkey-del $name auto.share --key=${autofsSubDir}
    ipa automountkey-del $name auto.share --key=${subDir}

    echo ipa automountkey-del $name auto.master --key=${autofsTopDir}
    ipa automountkey-del $name auto.master --key=${autofsTopDir}

    echo ipa automountmap-del $name auto.share
    ipa automountmap-del $name auto.share

    echo ipa automountlocation-del $name
    ipa automountlocation-del $name
    umount_autofs_directory 
}

how_to_check_autofs_mounting(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="$autofsTopDir/$autofsSubDir"
    echo "to delete this configuration: ipa automountlocation-del $name"
    echo "to use this autofs configuration: "
    echo "  (1) ipa-client-automount --server=$nfsHost --location=$name"
    echo "  (2) autofs should be automatic restart, if not, do 'service autofs restart'"
    echo "  (3) to use this mount location: do 'cd $autofsDir' on nfs client (where autofs runs)"
}

show_autofs_configuration(){
    local locationName=$1
    echo ""
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "      autofs configuration for location [$locationName]"
    echo "|-------------------------------------------------------------------------------|"
    ipa automountlocation-tofiles $locationName
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
}

check_autofs_sssd_configuration(){
    local configuration_status=$1
#the next line is for temp pass, it relate to bug or undecided 
    #check_sssd $configuration_status
    check_nsswitch $configuration_status
    check_sysconfig_nfs $configuration_status
    check_idmapd $configuration_status
}

check_autofs_no_sssd_configuration(){
    local configuration_status=$1
#the next line is for temp pass, it relate to bug or undecided 
    #check_sssd_no_sssd $configuration_status
    check_autofs_ldap_auth_no_sssd $configuration_status
    check_sysconfig_autofs_no_sssd $configuration_status
    check_nsswitch_no_sssd $configuration_status
    check_sysconfig_nfs_no_sssd $configuration_status
    check_idmapd_no_sssd $configuration_status
}

check_nsswitch(){
    local configuration_status=$1
    local conf="/etc/nsswitch.conf"
    local message="^automount: sss"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_sysconfig_nfs(){
    local configuration_status=$1
    local conf="/etc/sysconfig/nfs"
    local message="^SECURE_NFS=yes$"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_idmapd(){
    local configuration_status=$1
    local conf="/etc/idmapd.conf"
    local message="^Domain=$DOMAIN$"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_sssd(){
    local configuration_status=$1
    local conf="/etc/sssd/sssd.conf"
    local message="ipa_automount_location = ${currentLocation}"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_sssd_no_sssd(){
    local configuration_status=$1
    local conf="/etc/sssd/sssd.conf"
    local message="^ipa_automount_location = ${currentLocation}"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_autofs_ldap_auth_no_sssd(){
    local configuration_status=$1
    local conf="/etc/autofs_ldap_auth.conf"
    local message="authtype=\"GSSAPI\" clientprinc=\"${hostPrinciple}\""
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_sysconfig_autofs_no_sssd(){
    local configuration_status=$1
    local conf="/etc/sysconfig/autofs"

    local message="SEARCH_BASE=cn=${currentLocation},cn=automount,$suffix"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
    if [ "$LDAP_URI" != "" ];then
        ensure_configuration_status "$conf" "$LDAP_URI" "$configuration_status"
    fi
}

check_nsswitch_no_sssd(){
    local configuration_status=$1
    local conf="/etc/nsswitch.conf"
    local message="^automount: ldap"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_sysconfig_nfs_no_sssd(){
    local configuration_status=$1
    check_sysconfig_nfs $configuration_status
}

check_idmapd_no_sssd(){
    local configuration_status=$1
    check_idmapd $configuration_status
}

ensure_configuration_status()
{
    local conf="$1"
    local message="$2"
    local configuration_status="$3"
    
    if [ "$configuration_status" = "configured" ];then
        ensure_expected_message_appears_in_configuration_file "$conf" "$message"
    elif [ "$configuration_status" = "not_configured" ];then
        ensure_message_not_appears_in_configuration_file "$conf" "$message"
    else
        rlLog "unknow configuration status"
    fi
}

ensure_expected_message_appears_in_configuration_file()
{
    local conf="$1"
    local message="$2"
    if grep "$message" $conf 2>&1 > /dev/null
    then
        rlPass "[$conf] contains expected [$message]"
    else
        rlFail "[$conf] does NOT contains expected [$message]"
        show_file_content $conf
    fi
}

ensure_message_not_appears_in_configuration_file()
{
    local conf="$1"
    local message="$2"
    if grep "$message" $conf 2>&1 > /dev/null
    then
        rlFail "[$conf] contain [$message], this is NOT expected"
        show_file_content $conf
    else
        rlPass "[$conf] does NOT contain [$message], this is expected"
    fi
}

clean_up_automount_installation()
{
    local tmp=$TmpDir/ipa.client.automount.uninstall.$RAMDOM.txt
    ipa-client-automount --uninstall -U 2>&1 > $tmp
    if [ "$?" = "0" ];then
        rlPass "clean up ipa-client-automount success"
    else
        rlLog "clean up ipa-client-automount failed, this is not considered as an error"
        cat $tmp
    fi
    rm $tmp
}

show_file_content()
{
    local file=$1
    if [ -f $file ];then
        rlLog "::::::::::::: [$file] :::::::::::::::"
        cat $file | grep -v "^\s*$" | grep -v "^#"
        rlLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    else
        rlFail ":::::::::::: [$file] does NOT exist :::::::::::::"
    fi
}


pause()
{
    local choice="y"
    echo -n "continue? (y/n) "
    read choice
    if [ "$choice" = "n" ];then
        exit
    fi
}


restart_sssd()
{
    rlLog "restart sssd"
    service sssd stop
    echo "remove sssd cache"
    sss_cache -A
    echo "---------- grep /etc/sysconfig/nfs ------------"
    grep "SECURE_NFS" /etc/sysconfig/nfs
    service sssd start
    replace_line "/etc/sysconfig/nfs" "SECURE_NFS=YES" "SECURE_NFS=yes"
    service sssd restart
    service rpcgssd restart
    service sssd status
    rlLog "restart sssd done"
}

restart_autofs()
{
    rlLog "restart autofs"
    service rpcgssd restart
    #original code
#    service autofs restart
#    if service autofs stauts | grep "automount dead but subsys locked"
#    then
#        rlLog "autofs restart failed, found /var/lock/subsys/autofs, remove it and restart"
#        if [ -f /var/lock/subsys/autofs ];then
#            rm /var/lock/subsys/autofs
#            service autofs restart
#        fi
#    fi
    # modified code
    service autofs stop
    if [ -f /var/lock/subsys/autofs ];then
        rlLog "remove autofs lock file: /var/lock/subsys/autofs"
        rm -f /var/lock/subsys/autofs
    fi
    service autofs start
    echo "============ autofs status after restart ======================"
    service autofs status
    echo "==============================================================="
    rlLog "restart autofs done"
}

replace_line()
{
    local file=$1
    local old=$2
    local new=$3
    local changeTo="#$old\n$new"
    local id=$RANDOM
    local tmp="/tmp/replace.oneline.$id.txt"
    local backup="/tmp/replace.oneline.$id.original.txt"
    if sed -e "s/^$old$/$changeTo/" $file > $tmp
    then
        cp $file $backup
        cp -r $tmp $file
        echo "change one line success"
    else
        echo "something wrong, no change made"
    fi
}

replace_line(){
    local file=$1
    local line="$2"
    local newline="$3"
    local fileName=`basename $file`
    local file_bk=/tmp/$fileName.bk.$RANDOM
    local file_modified=/tmp/$fileName.modified.$RANDOM
    cp $file $file_bk
    cat $file | sed -e "s/^$line$/$newline/" > $file_modified
    cp -f $file_modified $file
    rm $file_modified
    echo "original file backup at [$file_bk]"
    echo "check new line [$newline] in [$file]"
    echo "-----------------------------------------"
    grep "$newline" $file
    echo "-----------------------------------------"
}

modify_sysconfig_nfs()
{
    replace_line $nfsSystemConf "#SECURE_NFS=\"yes\""  "SECURE_NFS=\"yes\""
    replace_line $nfsSystemConf "#RPCGSSDARGS=\"\""    "RPCGSSDARGS=\"-vvv\""
    replace_line $nfsSystemConf "#RPCSVCGSSDARGS=\"\"" "RPCSVCGSSDARGS=\"-vvv\""
    echo "========== content of $nfsSystemConf ==============="
    grep -v "^#" $nfsSystemConf
    echo "===================================================="
}

start_nfs_in_kereberized_mode(){
    if kvno -k /etc/krb5.keytab $principle | grep "keytab entry valid"
    then
        echo "keytab file /etc/krb5.keytab is valid, continue"
        cp /var/log/messages /tmp/message.before
        service nfs restart
        cp /var/log/messages /tmp/message.after
        if diff /tmp/message.before /tmp/message.after | grep "rpc.svcgssd.* libnfsidmap: Realms .* " 2>&1 >/dev/null \
           && diff /tmp/message.before /tmp/message.after | grep "rpc.svcgssd.*: libnfsidmap: using (default) domain: $domain" 2>&1 >/dev/null
        then
            echo "NFS starts in kerberized mode success"
        else
            echo "NFS failed to start in kerberized mode"
        fi
        rm /tmp/message.after  /tmp/message.before
    else
        echo "default keytab file /etc/krb5.keytab is INVALID, test can not continue"
    fi
}

configure_kerberized_nfs_server()
{
    rlLog "configure host as kerberized nfs server"
    KinitAsAdmin
    rlRun "ssh -o StrictHostKeyChecking=no admin@$MASTER ipa service-add $nfsServicePrinciple" 0 "add nfs service"
    rlRun "ipa-getkeytab -s $MASTER -k $keytabFile -p $nfsServicePrinciple" 0 "get keytab file, save as $keytabFile"
    verify_nfs_service_keytabfile 
    modify_sysconfig_nfs
    start_nfs_in_kereberized_mode
}

parse_test_roles_from_beaker_job_xml_file()
{
    MASTER="$MASTER_env1"
    Master_hostname=`echo $MASTER | cut -d'.' -f1`
    MASTER_IP=$(dig +short $MASTER)
    MASTER_IPA="${Master_hostname}.${DOMAIN}"
    if [ -z "$MASTER_IP" ]; then
	    MASTER_IP=$(getent ahostsv4 $MASTER | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
    fi

    REPLICA="$REPLICA_env1"
    Replica_hostname=`echo $REPLICA | cut -d'.' -f1`
    REPLICA_IP=$(dig +short $REPLICA)
    REPLICA_IPA="${Replica_hostname}.${DOMAIN}"
    if [ -z "$REPLICA_IP" ]; then
	    REPLICA_IP=$(getent ahostsv4 $REPLICA | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
    fi

    NFS=`echo $CLIENT_env1 | cut -d' ' -f1`
    Nfs_hostname=`echo $NFS | cut -d'.' -f1`
    NFS_IP=$(dig +short $NFS)
    NFS_IPA="${Nfs_hostname}.${DOMAIN}"
    if [ -z "$NFS_IP" ]; then
    	    NFS_IP=$(getent ahostsv4 $NFS | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
    fi

    CLIENT=`echo $CLIENT_env1 | cut -d' ' -f2`
    Client_hostname=`echo $CLIENT | cut -d'.' -f1`
    CLIENT_IP=$(dig +short $CLIENT)
    CLIENT_IPA="${Client_hostname}.${DOMAIN}"
    if [ -z "$CLIENT_IP" ]; then
	    CLIENT_IP=$(getent ahostsv4 $CLIENT | grep -e "^[0-9.]*[ ]*STREAM" | awk '{print $1}')
    fi

}

map_hostname_with_role()
{
    CURRENT_HOST=$(hostname)
    Current_hostname=`echo $CURRENT_HOST | cut -d'.' -f1`
    case $Current_hostname in
        "$Master_hostname")    MYROLE="MASTER"  ;;
        "$Replica_hostname")   MYROLE="REPLICA" ;;
        "$Nfs_hostname")       MYROLE="NFS"     ;;
        "$Client_hostname")    MYROLE="CLIENT"  ;;
        *)                     MYROLE="UNKNOWN" ;;
    esac
}

print_hostname_role_mapping()
{
    echo "------------------------- test host used ------------------------"
    echo " current host [$CURRENT_HOST], role [$MYROLE]"
    echo " MASTER : [$MASTER] [$Master_hostname] IPA: [$MASTER_IPA] IP: [$MASTER_IP]"
    echo " REPLICA: [$REPLICA] [$Replica_hostname] IPA: [$REPLICA_IPA] IP: [$REPLICA_IP]"
    echo " NFS    : [$NFS] [$Nfs_hostname] IPA: [$NFS_IPA] IP: [$NFS_IP]"
    echo " CLIENT : [$CLIENT] [$Client_hostname] IPA: [$CLIENT_IPA] IP: [$CLIENT_IP]"
    echo "-----------------------------------------------------------------"
}

print_logs()
{
    for log in $logs
    do
        if [ -f $log ];then
            local nLines=150
            echo ""
            echo "============ last $nLines lines of $log ==================="
            tail -n $nLines $log
            echo ""
        fi
    done
}

configurate_kerberized_nfs_server()
{
    rlPhaseStartTest "setup secure (Kerberized) NFS server"
        rlLog "Host Info: NFS [$NFS] [$NFS_IPA]"       
        rlLog "MYROLE [$MYROLE], MYHOSTNAME [$MYHOSTNAME], MASTER [$MASTER_IPA]"
        echo "============ Before config $nfsConfigFile  ========"
        cat $nfsConfigFile
        echo "$nfsConfiguration_Kerberized" > $nfsConfigFile
        echo "============ After config $nfsConfigFile =========="
        cat $nfsConfigFile
        echo "=========== Prepare for NFS directories ==========="
        mkdir -p $nfsDir
        echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
        echo "=========== file content of: [$nfsDir/$currentNFSFileName] ============"
        cat $nfsDir/$currentNFSFileName
        KinitAsAdmin
        nfsServicePrinciple="nfs/$CURRENT_HOST@${RELM}"
        rlRun "ipa service-add $nfsServicePrinciple" 0 "add nfs service: $nfsServicePrinciple" 
        rlRun "ipa-getkeytab -s $REPLICA_IPA -p $nfsServicePrinciple -k $keytabFile" 0 "get keytab file from master [$MASTER_IPA], for $nfsServicePrinciple, save it as [$keytabFile]"
        rlRun "kinit -kt $keytabFile" 0 "verify keytab file with kinit -kt $keytabFile"
        echo "======= klist -ket $keytabFile ======"
        klist -ket /etc/krb5.keytab
        modify_sysconfig_nfs
        echo "====== restart nfs ======"
        service nfs restart
        service nfs status
        debuginfo 
    rlPhaseEnd
}

configurate_non_secure_nfs_server()
{
    rlLog "MYHOSTNAME=[$MYHOSTNAME] configure [$MYROLE] as non-secure NFS server"
    rlRun "mkdir -p $nfsDir" 0 "prepare nfs export directory [$nfsDir]"
    echo "$currentNFSFileSecret" > $nfsDir/$currentNFSFileName
    echo "========= content of secret file content ======="
    cat $nfsDir/$currentNFSFileName
    echo "===== end of content of [$nfsDir/$currentNFSFileName] ====="

    echo "$nfsConfiguration_NonSecure" > $nfsConfigFile
    echo "====== configuration [$nfsConfigFile ] ============"
    cat $nfsConfigFile
    echo "============================================="

    rlRun "service nfs restart" 0 "start nfs service"
    rlRun "service iptables stop" 0 "shutdown firewall"
    echo "========  check rpcinfo [$MYHOSTNAME] ======"
    rpcinfo -p $MYHOSTNAME
    echo "=================================================="
}

verify_nfs_service_keytabfile(){
    if kvno -k $keytabFile $principle | grep "keytab entry valid" 
    then
        echo "keytab file [$keytabFile] is valid"
    else
        echo "keytab file [$keytabFile] is NOT valid"
    fi
}

change_autofs_debug_level()
{
    local sssd_conf=/etc/sssd/sssd.conf
    local sssd_conf_org=/etc/sssd/sssd.conf.org
    local tmp_conf=/tmp/sssd.conf
    if ! grep "debug=10" $sssd_conf
    then
        sed -e "s/^\[autofs\]/[autofs]\ndebug_level=10\n/" $sssd_conf > $tmp_conf
        cp -f $sssd_conf $sssd_conf_org
        cp -f $tmp_conf $sssd_conf
        echo "[change_autofs_debug_level] original sssd conf file saved as [$sssd_conf_org]"
        echo "[change_autofs_debug_level] new sssd conf file [$sssd_conf] has content"
        cat $sssd_conf
        service sssd restart
        echo "[change_autofs_debug_level] done"
    fi
}

stop_ipa_master()
{
      rlPhaseStartTest "Stop IPA Master"
        #Stoping ipa sevice on $MASTER
        rlRun "echo \"ipactl stop\" > $TmpDir/local.sh" 0 "Stoping IPA service on $MASTER"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Stop IPA service on MASTER"
        sleep 10
      rlPhaseEnd
}

start_ipa_master()
{
      rlPhaseStartTest "Start IPA Master"
        #Starting ipa sevice on $MASTER
        rlRun "echo \"ipactl start\" > $TmpDir/local.sh" 0 "Starting IPA service on $MASTER"
        rlRun "chmod +x $TmpDir/local.sh"
        rlRun "ssh -o StrictHostKeyChecking=no root@$MASTER 'bash -s' < $TmpDir/local.sh" 0 "Start IPA service on MASTER"
        sleep 10
      rlPhaseEnd
}

