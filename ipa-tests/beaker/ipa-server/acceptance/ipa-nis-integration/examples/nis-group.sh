#!/bin/sh
# 1 is the nis domain, 2 is the nis master server
ypcat -d $1 -h $2 group > /opt/rhqa_ipa/nis-map.group 2>&1

IFS=$'\n'
for line in $(cat /opt/rhqa_ipa/nis-map.group); do 
	IFS=' '
	groupname=$(echo $line|cut -f1 -d:) 
	# Not collecting encrypted password because we need cleartext password to create kerberos key    
	gid=$(echo $line|cut -f3 -d:) 
	members=$(echo $line|cut -f4 -d:) 
			 
	# Now create this entry 
	ipa group-add $groupname --desc=NIS_GROUP_$groupname --gid=$gid
	if [ -n "$members" ]; then
		ipa group-add-member $groupname --users=$members
	fi
	ipa group-show $groupname
done
