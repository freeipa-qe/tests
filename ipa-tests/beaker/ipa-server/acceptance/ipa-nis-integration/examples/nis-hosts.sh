#!/bin/sh
# 1 is the nis domain, 2 is the nis master server

ypcat -d $1 -h $2 hosts | egrep -v "localhost|127.0.0.1" > /opt/rhqa_ipa/nis-map.hosts 2>&1

IFS=$'\n'
for line in $(cat /opt/rhqa_ipa/nis-map.hosts); do 
	IFS=' '
	ipaddress=$(echo $line|awk '{print $1}')
	hostname=$(echo $line|awk '{print $2}')
	master=$(ipa env xmlrpc_uri |tr -d '[:space:]'|cut -f3 -d:|cut -f3 -d/)
	domain=$(ipa env domain|tr -d '[:space:]'|cut -f2 -d:)
	if [ $(echo $hostname|grep "\." |wc -l) -eq 0 ]; then
		hostname=$(echo $hostname.$domain)
	fi 
	zone=$(echo $hostname|cut -f2- -d.)
	if [ $(ipa dnszone-show $zone 2>/dev/null | wc -l) -eq 0 ]; then
		ipa dnszone-add --name-server=$master. --admin-email=root.$master
	fi
	ptrzone=$(echo $ipaddress|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}') 
	if [ $(ipa dnszone-show $ptrzone 2>/dev/null|wc -l) -eq 0 ]; then  
		ipa dnszone-add  $ptrzone --name-server=$master. --admin-email=root.$master
	fi
	# Now create this entry 
	ipa host-add $hostname --ip-address=$ipaddress
	ipa host-show $hostname
done
