#!/bin/sh
# 1 is the nis domain, 2 is the nis master server
ypcat -k -d $1 -h $2 netgroup > /opt/rhqa_ipa/nis-map.netgroup 2>&1

IFS=$'\n'
for line in $(cat /opt/rhqa_ipa/nis-map.netgroup); do 
	IFS=' '
        netgroupname=$(echo $line|awk '{print $1}')
	triples=$(echo $line|sed "s/^$netgroupname //")
	echo "ipa netgroup-add $netgroupname --desc=NIS_NG_$netgroupname"
	if [ $(echo $line|grep "(,"|wc -l) -gt 0 ]; then
		echo "ipa netgroup-mod $netgroupname --hostcat=all"
	fi
	if [ $(echo $line|grep ",,"|wc -l) -gt 0 ]; then
		echo "ipa netgroup-mod $netgroupname --usercat=all"
	fi

	for triple in $triples; do
		triple=$(echo $triple|sed -e 's/-//g' -e 's/(//' -e 's/)//')
		if [ $(echo $triple|grep ",.*,"|wc -l) -gt 0 ]; then
			hostname=$(echo $triple|cut -f1 -d,)
			username=$(echo $triple|cut -f2 -d,)
			domain=$(echo $triple|cut -f3 -d,)
			hosts=""; users=""; doms="";
			[ -n "$hostname" ] && hosts="--hosts=$hostname"
			[ -n "$username" ] && users="--users=$username"
			[ -n "$domain"   ] && doms="--nisdomain=$domain"
			echo "ipa netgroup-add-member $hosts $users $doms"
		else
			netgroup=$triple
			echo "ipa netgroup-add $netgroup --desc=NIS_NG_$netgroup"
		fi
	done
done
