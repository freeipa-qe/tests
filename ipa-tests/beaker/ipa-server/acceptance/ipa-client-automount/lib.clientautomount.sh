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
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="-ro,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

configure_autofs_indirect2(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="${autofsTopDir}/${autofsSubDir}"
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add-indirect $name auto.share --mount=${autofsTopDir} --parentmap=auto.master
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="-ro,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

configure_autofs_direct(){
# ipa automountkey-add direct001 auto.direct --key=/ipashare001/ipapublic001 --info=f17apple.yzhang.redhat.com:/share/pub
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir=$4
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountkey-add $name auto.direct --key=$autofsDir --info="-ro,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

how_to_check_autofs_mounting(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="$autofsTopDir/$autofsSubDir"
    echo "to delete this configuration: ipa automountlocation-del $name"
    echo "to use this autofs configuration: "
    echo "  (1) ipa-client-automount --server=$nfsHost --location=$name"
    echo "  (2) autofs should be automatic restart, if not, do 'systemctl restart autofs'"
    echo "  (3) to use this mount location: do 'cd $autofsDir' on nfs client (where autofs runs)"
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

check_autofs_sssd_configuration(){
    local configuration_status=$1
    check_sssd $configuration_status
    check_nsswitch $configuration_status
    check_sysconfig_nfs $configuration_status
    check_idmapd $configuration_status
}

check_autofs_no_sssd_configuration(){
    local configuration_status=$1
    check_sssd_no_sssd $configuration_status
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
    local message="^SECURE_NFS=YES$"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
}

check_idmapd(){
    local configuration_status=$1
    local conf="/etc/idmapd.conf"
    local message="^Domain=$domain$"
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
    local message="ipa_automount_location = ${currentLocation}"
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

    message="LDAP_URI=ldap://${currentIPAServer}"
    ensure_configuration_status "$conf" "$message" "$configuration_status"
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

ensure_expected_message_appears_in_configuration_file(){
    local conf="$1"
    local message="$2"
    if grep "$message" $conf 2>&1 > /dev/null
    then
        #echo "PASS: [$conf] contains expected [$message]"
        rlPass "[$conf] contains expected [$message]"
    else
        #echo "FAIL: [$conf] does NOT contains expected [$message]"
        rlFail "[$conf] does NOT contains expected [$message]"
    fi
}

ensure_message_not_appears_in_configuration_file(){
    local conf="$1"
    local message="$2"
    if grep "$message" $conf 2>&1 > /dev/null
    then
        #echo "FAIL: [$conf] contain [$message], this is NOT expected"
        rlFail "[$conf] contain [$message], this is NOT expected"
    else
        #echo "PASS: [$conf] does NOT contain [$message], this is expected"
        rlPass "[$conf] does NOT contain [$message], this is expected"
    fi
}

clean_up_automount_installation()
{
    echo "#################################"
    echo "# clean up ipa-client-automount #"
    echo "#                               #"
    ipa-client-automount --uninstall -U
    echo "#                               #"
    echo "# clean up done                 #"
    echo "#################################"
}
