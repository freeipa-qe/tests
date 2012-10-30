#!/bin/bash

####################################################
#                 functions                        #
####################################################
usage(){
    echo " -------- "
    echo "| USAGE: |"
    echo "|  $0 -s <ipa server> -h <host fqdn> -i <host ip address> |"
    echo " ------------------------------------------------------ "
}

compute_dns_variables(){
    ptrIP=`echo $hostip | cut -d"." -f4`
    ptrRecord="${hostname}."
    zonename="`echo $hostip | cut -d"." -f3`.`echo $hostip | cut -d"." -f2`.`echo $hostip | cut -d"." -f1`.in-addr.arpa."
    domain="`echo $hostname | cut -d"." -f2-`"
    shortHostname="`echo $hostname | cut -d"." -f1`"
    aRecord=$hostip
    FQDN=$hostname
}

show_compute_result()
{
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
####################################################

hostName=""
hostIP=""
ipaServer=""
paramMsg="configure using "
while getopts ":h:i:s:r:k:" opt ;do
    case $opt in
    h)
        hostname=$OPTARG
        paramMsg="$paramMsg -h [$hostname]"
        ;;
    i)
        hostip=$OPTARG
        paramMsg="$paramMsg -i [$hostip]"
        ;;
    s)
        ipaServer=$OPTARG
        paramMsg="$paramMsg -s [$ipaServer]"
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

compute_dns_variables
add_ipa_dns_ptr_record
add_ipa_dns_a_record
add_ipa_host_record
