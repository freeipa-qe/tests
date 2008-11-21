#!/bin/sh

. ./winsync-libs.sh

echo "before running mmr-ac-check, you have to
1. make sure the host that runs this script already setup ssh password-less login to all mmr host
2. winsync agreement already setup
"

h=$1
total=$2
start=$3
runtime=$4

if [ -z $h ];then
	h="z"
fi
if [ -z $total ];then
	total=9999
fi
if [ -z $start ];then
	total=0
fi
if [ -z $runtime ];then
	runtime=1800
	#1800 second = 30 minutes
fi

echo ""
echo "search user in all ipa hosts and AD server"

base=10000
i=$start
now=`date +%s`
((end=now+runtime))
((total=total+base))
echo "total runtime $runtime seconds"

while [ $i -lt $total ] && [ $now -lt $end ]
do
        ((uid=base+i))
        firstname=$uid
        lastname=$h
        username=$lastname$firstname
	found=1
	echo "searching...[$username]"
	for server in $MMR_HOSTS
	do
		ipastatus=`$LDAPSEARCH -h $server -D "$IPA_ADMIN" -w $IPA_ADMIN_PW -s sub -b $IPA_SUFFIX "uid=$username" "dn"`
		#echo "[$server] $ipastatus"
		if  echo $ipastatus | grep "uid=$username"  > /dev/null 2>&1
		then
			echo "	found on [$server]"
		else
			echo "	NOT found on [$server]"
			found=0
		fi	
	done
	adstatus=`$LDAPSEARCH -h $AD_SERVER -p 389 -D $AD_ADMIT -w $AD_ADMIT_PW -b $AD_SUFFIX "sAMAccountName=$username" "dn"`
	if echo $adstatus | grep "$lastname $firstname" > /dev/null 2>&1
	then
		echo "	found on [$AD_SERVER]"
	else
		echo "	NOT found on [$AD_SERVER]"
		found=0
	fi
	
	if [ $found -eq 0 ]	
	then
		echo "	sleep 1 seconds, wait for it sync from other server, next time starts from [$i] "
		sleep 1
	else
		((i=i+1))
	fi
	now=`date +%s`
	if [ $now -gt $end ]; then
		echo "time is up, quit test"
	fi
done


