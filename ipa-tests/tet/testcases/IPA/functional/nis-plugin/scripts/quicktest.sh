#!/bin/sh

. ./config.nis.server.sh 
. ./config.nis.client.sh 

server="mv32a-vm.idm.lab.bos.redhat.com"
client="mv32b-vm.idm.lab.bos.redhat.com"
nisdomain="idm.lab.bos.redhat.com"
nisserver=$server

echo "enable nis on remote ipa server : [$server]"
config_nis_server $server
echo "done with nis server"

echo "config nis client : [$client]"
config_nis_client $client $nisdomain $nisserver
echo "done with nis client"

ssh root@$server "service iptables stop"
ssh root@$client "service iptables stop; service ypbind restart"

echo "run yptest on client [$client]"
result=`ssh root@$client "yptest 2>&1" `
echo "yptest result:"
echo "------------------------------"
echo $result
echo "------------------------------"

# try some ypmatch test
uid=u0001
ssh root@$server "echo redhat123 | kinit admin; ipa user-add --first=user --last=0001 $uid"
ssh root@$client "ypmatch $uid passwd "
#echo "starts to disable nis on $server"
#pwfile="/tmp/pw.$RANDOM.txt"
#ssh root@${server} "echo redhat123 > $pwfile"
#ssh root@${server} "ipa-compat-manage disable -y $pwfile"
#ssh root@${server} "ipa-nis-manage    disable -y $pwfile"
#ssh root@${server} "rm -f $pwfile"
#ssh root@${server} "service dirsrv restart 2>&1 1>/dev/null "
#echo "finished"
