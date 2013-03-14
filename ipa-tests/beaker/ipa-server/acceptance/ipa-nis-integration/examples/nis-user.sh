#!/bin/sh
# 1 is the nis domain, 2 is the nis master server
ypcat -d $1 -h $2 passwd > /opt/rhqa_ipa/nis-map.passwd 2>&1

IFS=$'\n'
for line in $(cat /opt/rhqa_ipa/nis-map.passwd); do 
	IFS=' '
        username=$(echo $line|cut -f1 -d:) 
        # Not collecting encrypted password because we need cleartext password to create kerberos key    
        uid=$(echo $line|cut -f3 -d:) 
        gid=$(echo $line|cut -f4 -d:) 
        gecos=$(echo $line|cut -f5 -d:) 
        homedir=$(echo $line|cut -f6 -d:) 
        shell=$(echo $line|cut -f7 -d:) 
                         
        # Now create this entry 
        echo passw0rd1|ipa user-add $username --first=NIS --last=USER --password --gidnumber=$gid --uid=$uid --gecos=$gecos --homedir=$homedir --shell=$shell
        ipa user-show $username
done
