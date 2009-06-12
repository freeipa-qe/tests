# locallib used by nis.ksh

EnableNIS()
{
# this function requires ipa server is running before execute
	h="EnableNIS"
	logmessage "$h: starts"
	pwfile="/tmp/pw.$RANDOM.txt"
	ssh root@${ipaserver} "echo $KERB_MASTER_PASS > $pwfile"
	ssh root@${ipaserver} "/sbin/service portmap start 2>&1 1>/dev/null "
	ssh root@${ipaserver} "ipa-compat-manage enable -y $pwfile"
	ssh root@${ipaserver} "ipa-nis-manage    enable -y $pwfile"
	ssh root@${ipaserver} "rm -f $pwfile"
	ssh root@${ipaserver} "service dirsrv restart 2>&1 1>/dev/null "
	logmessage "$h: finished"
}


DisableNIS()
{
# this function requires ipa server is running before execute
	h="DisableNIS"
	logmessage "$h: starts"
	pwfile="/tmp/pw.$RANDOM.txt"
	ssh root@${ipaserver} "echo $KERB_MASTER_PASS > $pwfile"
	ssh root@${ipaserver} "ipa-compat-manage disable -y $pwfile"
	ssh root@${ipaserver} "ipa-nis-manage    disable -y $pwfile"
	ssh root@${ipaserver} "rm -f $pwfile"
	ssh root@${ipaserver} "service dirsrv restart 2>&1 1>/dev/null "
	logmessage "$h: finished"
}

CreateIPAUserOnIPAServer()
{
	h="CreateIPAUserOnIPAServer"
	uid=$1
	pw=$2
	homedir=$3
	logmessage "$h: starts"
	logmessage "$h: uid=[$uid] password=[$pw] home dir=[$homedir]"
	if [ -z $pw ]
	then
		result=`ssh root@${ipaserver} "ipa user-add --first=autofs --last='$uid' $uid"`
	else
		result=`ssh root@${ipaserver} "yes '$pw' |  ipa user-add --first=autofs --last='$uid' --password '$uid'"`
	fi

	if [ -z $homedir ]
	then
		result=`ssh root@${ipaserver} "ipa user-mod --home=$homedir '$uid'"`
	fi
	logmessage "$h: [$result]"
	logmessage "$h: finished"
}

DeleteIPAUserOnIPAServer()
{
	h="DeleteIPAUserOnIPAServer"
	uid=$1
	logmessage "$h: starts"
	result=`ssh root@${ipaserver} "ipa user-del '$uid'"`
	logmessage "$h: delete result=[$result]"
	logmessage "$h: finished"
}

ConfigNISClient()
{
	client=$1
	nisdomain=$2
	nisserver=$3
	h="ConfigNISClient"
	logmessage "$h: starts"

	# config network
	logmessage "$h: config [$client] /etc/sysconfig/network"
	ssh root@$client "mv -f /etc/sysconfig/network /etc/sysconfig/network.bk"
	ssh root@$client "cat /etc/sysconfig/network.bk | grep -v -i 'nisdomain' >> /etc/sysconfig/network"
	ssh root@$client  "echo 'NISDOMAIN=$nisdomain' >> /etc/sysconfig/network"

	#config yp.conf
	logmessage "$h: config [$client] /etc/yp.conf"
	ssh root@$client "mv -f /etc/yp.conf /etc/yp.conf.bk"
	ssh root@$client "cat /etc/yp.conf.bk | grep -v -i 'domain' >> /etc/yp.conf"
	ssh root@$client "echo 'domain $nisdomain server $nisserver' >> /etc/yp.conf"

	#config nsswitch
	logmessage "$h: config [$client] /etc/nsswitch.conf"
	ssh root@$client "mv -f /etc/nsswitch.conf /etc/nsswitch.conf.bk"
	ssh root@$client "sed 	-e 's/^passwd:.*files$/passwd:	files nis/' -e 's/^shadow:.*files$/shadow:	files nis/' -e 's/^group:.*files$/group:	files nis/'    -e 's/^networks:.*files$/networks:	files nis/' < /etc/nsswitch.conf.bk > /etc/nsswitch.conf "
	logmessage "$h: starts"
}

RestoreNISClient()
{
	client=$1
	nisdomain=$2
	nisserver=$3
	h="Restore NIS Client"
	logmessage "$h: starts"
	ssh root@$client "mv -f /etc/nsswitch.conf.bk /etc/nsswitch.conf; mv -f /etc/yp.conf.bk /etc/yp.conf; mv -f /etc/sysconfig/network.bk /etc/sysconfig/network; service ypbind stop"
	logmessage "$h: finished"
}


#echo "	configurate '/etc/sysconfig/network'"
#result=`ssh root@$client "grep 'NISDOMAIN' /etc/sysconfig/network"`
#if  `echo "$result" | grep "NISDOMAIN" 2>&1 1>/dev/null` 
#then
#	echo -e "\033[31m	client already configurated as"
#	echo -e "	$result"
#	echo -e -n "\033[0m "
#	echo "	this will be replaced"
#fi

