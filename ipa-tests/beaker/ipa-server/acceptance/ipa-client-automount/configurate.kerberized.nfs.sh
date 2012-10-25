#!/bin/bash

####################################################
#                 functions                        #
####################################################
usage(){
    echo " -------- "
    echo "| USAGE: |"
    echo "|  $0 -h <nfs server fqdn> -i <nfs server ip address> -s <ipa server> -r <realm> -k <output keytab file> |"
    echo " ------------------------------------------------------ "
}

compute_dns_variables(){
    local hostname=$1
    local hostip=$2
    ptrIP=`echo $hostip | cut -d"." -f4`
    ptrRecord="${hostname}."
    zonename="`echo $hostip | cut -d"." -f3`.`echo $hostip | cut -d"." -f2`.`echo $hostip | cut -d"." -f1`.in-addr.arpa."
    domain="`echo $hostname | cut -d"." -f2-`"
    shortHostname="`echo $hostname | cut -d"." -f1`"
    aRecord=$hostip
    FQDN=$hostname
    service="nfs"
    serviceRecord="$service/${FQDN}"
    REALM=$ipaRealm
    principle="${serviceRecord}@${REALM}"
    echo "#########################################"
    echo "hostname  : $hostname"
    echo "hostip    : $hostip"
    echo "#---------------------------------------#"
    echo "ptrIP     : $ptrIP"
    echo "ptrRecord : $ptrRecord"
    echo "zonename  : $zonename"
    echo "shortHost : $shortHostname"
    echo "domain    : $domain"
    echo "aRecord   : $aRecord"
    echo "fqdn      : $hostname"
    echo "service   : $service"
    echo "principle : $principle"
    echo "#########################################"
}


add_ipa_dns_ptr_record(){
    if ! ipa dnsrecord-find $zonename --ptr-rec=$ptrRecord 2>&1 > /dev/null
    then
        ipa dnsrecord-add $zonename $ptrIP --ptr-rec $ptrRecord    
    else
        echo "ipa already have dns ptr record [$ptrRecord] in zone [$zonename]"
    fi
}

add_ipa_dns_a_record(){
    if ! ipa dnsrecord-find $domain $shortHostname --a-rec=$aRecord 2>&1 > /dev/null
    then
        ipa dnsrecord-add $domain $shortHostname --a-rec $aRecord
    else
        echo "ipa already have dns a record [$aRecord] in zone [$zonename]"
    fi
}

add_ipa_host_record(){
    if ! ipa host-find $FQDN 2>&1 > /dev/null
    then
        ipa host-add $FQDN
    else
        echo "ipa already have host record [$FQDN]"
    fi
}

add_ipa_nfs_service(){
    if ! ipa service-find $serviceRecord 2>&1 > /dev/null
    then
        ipa service-add $serviceRecord
    else
        echo "ipa already have service record [$serviceRecord]"
    fi
}

get_nfs_service_keytabFile(){
    ipa-getkeytab -s $ipaServer -p $principle -k $keytabFile
}

verify_service_keytabFile(){
    if kvno -k $keytabFile $principle | grep "keytab entry valid" 
    then
        echo "keytab file [$keytabFile] is valid"
    else
        echo "keytab file [$keytabFile] is NOT valid"
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
    echo "check new line in the [$file]"
    echo "-----------------------------------------"
    grep "$newline" $file
    echo "-----------------------------------------"
}

modify_nfs_configurate_file(){
    local nfsconf="/etc/sysconfig/nfs"
    replace_line $nfsconf "RPCGSSDARGS=\"\"" "RPCGSSDARGS=\"-vvv\""
    replace_line $nfsconf "RPCSVCGSSDARGS=\"\"" "RPCSVCGSSDARGS=\"-vvv\""
}


start_nfs_in_kereberized_mode(){
    if kvno -k /etc/krb5.keytab $principle | grep "keytab entry valid"
    then
        echo "keytab file /etc/krb5.keytab is valid, continue"
        cp /var/log/messages /tmp/message.before
        # the following works find in Fedora 17, we might have to change in RHEL
        systemctl enable nfs-server.service
        #systemctl start nfs-server.service  # will start nfs-secure-server.service also start nfs-server.service?
        systemctl start nfs-secure-server.service 
        systemctl status nfs-server.service
        cp /var/log/messages /tmp/message.after
        if diff /tmp/message.before /tmp/message.after | grep "rpc.svcgssd.* libnfsidmap: Realms .* 'YZHANG.REDHAT.COM" 2>&1 >/dev/null \
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


cleanup(){
    ipa service-del $service/${FQDN}
    ipa host-del $FQDN
    ipa dnsrecord-del $domain $shortHostname --a-rec=$aRecord
    ipa dnsrecord-del $zonename $ptrIP --ptr-rec=$ptrRecord
}

####################################################

nfsServerFQDN=""
nfsServerIP=""
ipaServer=""
paramMsg="configure using "
while getopts ":h:i:s:r:k:" opt ;do
    case $opt in
    h)
        nfsServerFQDN=$OPTARG
        paramMsg="$paramMsg -h [$nfsServerFQDN]"
        ;;
    i)
        nfsServerIP=$OPTARG
        paramMsg="$paramMsg -i [$nfsServerIP]"
        ;;
    s)
        ipaServer=$OPTARG
        paramMsg="$paramMsg -s [$ipaServer]"
        ;;
    r)
        ipaRealm=$OPTARG
        paramMsg="$paramMsg -r [$ipaRealm]"
        ;;
    k)
        keytabFile=$OPTARG
        paramMsg="$paramMsg -k [$keytabFile]"
        ;;
    \?)
        paramMsg="$0 :ERROR: invalid options: -$OPTARG "
        usage
        echo "$paramMsg" 
        exit
        ;;
    esac
done
echo $paramMsg

compute_dns_variables $nfsServerFQDN $nfsServerIP
#add_ipa_dns_ptr_record
#add_ipa_dns_a_record
#add_ipa_host_record
#add_ipa_nfs_service
#get_nfs_service_keytabFile
verify_service_keytabFile
modify_nfs_configurate_file
start_nfs_in_kereberized_mode

#cleanup
