#!/bin/sh

########## functions #############
config_network()
{
	echo "	config /etc/sysconfig/network"
	client=$1
	nisdomain=$2
	ssh root@$client "mv -f /etc/sysconfig/network /etc/sysconfig/network.bk"
	ssh root@$client "cat /etc/sysconfig/network.bk | grep -v -i 'nisdomain' >> /etc/sysconfig/network"
	ssh root@$client  "echo 'NISDOMAIN=$nisdomain' >> /etc/sysconfig/network"
}

config_yp_conf()
{
	echo "	config /etc/yp.conf"
	client=$1
	nisdomain=$2
	nisserver=$3
	ssh root@$client "mv -f /etc/yp.conf /etc/yp.conf.bk"
	ssh root@$client "cat /etc/yp.conf.bk | grep -v -i 'domain' >> /etc/yp.conf"
	ssh root@$client "echo 'domain $nisdomain server $nisserver' >> /etc/yp.conf"
}

config_nsswitch()
{
	echo "	config /etc/nsswitch.conf"
	client=$1
	ssh root@$client "mv -f /etc/nsswitch.conf /etc/nsswitch.conf.bk"
	ssh root@$client "sed 	-e 's/^passwd:.*files$/passwd:	files nis/' -e 's/^shadow:.*files$/shadow:	files nis/' -e 's/^group:.*files$/group:	files nis/'   -e 's/^hosts:.*files$/hosts:	files nis dns/' -e 's/^networks:.*files$/networks:	files nis/' -e 's/^protocols:.*files$/protocols:	files nis/' < /etc/nsswitch.conf.bk > /etc/nsswitch.conf "
}
##################################

client=$1
nisdomain=$2
nisserver=$3

# default client 
if [ -z $client ]
then
	client="mv32b-vm.idm.lab.bos.redhat.com"
fi
# default nisdomain
if [ -z $nisdomain ]
then
	nisdomain="idm.lab.bos.redhat.com"
fi
# default nisserver
if [ -z $nisserver ]
then
	nisserver="mv32a-vm.idm.lab.bos.redhat.com"
fi

# main starts here
echo "config nis client [$client] starts"

#echo "	configurate '/etc/sysconfig/network'"
#result=`ssh root@$client "grep 'NISDOMAIN' /etc/sysconfig/network"`
#if  `echo "$result" | grep "NISDOMAIN" 2>&1 1>/dev/null` 
#then
#	echo -e "\033[31m	client already configurated as"
#	echo -e "	$result"
#	echo -e -n "\033[0m "
#	echo "	this will be replaced"
#fi


config_network $client "$nisdomain"
config_yp_conf $client $nisdomain $nisserver
config_nsswitch $client

echo "configuration finished"
echo "run yptest on [$client]"
ssh root@$client "service portmap restart; service ypbind restart; yptest 2>&1"
