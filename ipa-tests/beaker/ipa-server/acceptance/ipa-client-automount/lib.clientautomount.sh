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
    check_sssd
    check_nsswitch
    check_sysconfig_nfs
    check_idmapd
}

check_autofs_no_sssd_configuration(){
    check_sssd_no_sssd
    check_autofs_ldap_auth_no_sssd
    check_sysconfig_autofs_no_sssd
    check_nsswitch_no_sssd    
    check_sysconfig_nfs_no_sssd
    check_idmapd_no_sssd
}

check_nsswitch(){
    local conf="/etc/nsswitch.conf"
    local message="^automount: sss"
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_sysconfig_nfs(){
    local conf="/etc/sysconfig/nfs"
    local message="^SECURE_NFS=YES$"
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_idmapd(){
    local conf="/etc/idmapd.conf"
    local message="^Domain=$domain$"
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_sssd_no_sssd(){
    local conf="/etc/sssd/sssd.conf"
    local message="ipa_automount_location = ${automountlocationName}"
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_autofs_ldap_auth_no_sssd(){
    local conf="/etc/autofs_ldap_auth.conf"
    message="authtype=\"GSSAPI\" clientprinc=\"${hostPrinciple}\""
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_sysconfig_autofs_no_sssd(){
    local conf="/etc/sysconfig/autofs"

    local message="SEARCH_BASE=cn=${automountlocationName},cn=automount,$suffix"
    check_expected_message_in_expected_conf "$conf" "$message"

    message="LDAP_URI=ldap://${ipaServer}"
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_nsswitch_no_sssd(){
    local conf="/etc/nsswitch.conf"
    local message="^automount: ldap"
    check_expected_message_in_expected_conf "$conf" "$message"
}

check_sysconfig_nfs_no_sssd(){
    check_sysconfig_nfs
}

check_idmapd_no_sssd(){
    check_idmapd
}

check_expected_message_in_expected_conf(){
    local conf="$1"
    local message="$2"
    if grep "$message" $conf 2>&1 > /dev/null
    then
        echo "PASS: [$conf] contains expected [$message]"
    else
        echo "FAIL: [$conf] does NOT contains expected [$message]"
    fi
}

