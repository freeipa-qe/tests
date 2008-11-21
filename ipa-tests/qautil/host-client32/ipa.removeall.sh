#!/bin/sh

RPM_LIST=./ipa.rpms.txt
IPA_FLIST=./ipa.flist.txt
LEFTOVER=./leftover.txt

echo "[step 1]: using ipa buildin function to uninstall server"
yes yes | ipa-server-install --uninstall

echo ""
echo "[step 2]: remove all rpms that installed using rpm.diff.txt file"

rpm -e `cat $RPM_LIST`

echo "[step 3]: after rpm -e to erase IPA rpms, check if there are anything left"

for f in `cat $IPA_FLIST`
do
	if [ -e $f ] && [ -f $f ]
	then
		#echo "	not clean [$f]"
		echo $f >> $LEFTOVER
	fi
done
if [ -e $LEFTOVER ] &&  [ `wc $LEFTOVER -l | cut -d" " -f1` -gt 0 ]
then
	echo "	some left over file listed on file [$LEFTOVER], check it and remove it manually"
fi

echo "[step 4]: check the log files"

if [ -e /var/log/dirsrv ];then
	echo "dirsrv log file exist, remove it"
	rm -rf /var/log/dirsrv
	rm -rf /var/log/dirsrv*
fi

if [ -e /var/log/krb5kdc.log ];then
	echo "kdc server log file exist, remove it"
	rm -rf /var/log/krb5kdc.log
fi

if [ -e /var/kerberos ];then
	echo "kerberos server data exist, remove it"
	rm -rf /var/kerberos
fi

if [ -e /var/log/httpd ];then
	echo "httpd server log file exist, remove it"
	rm -rf /var/log/httpd
fi

if [ -e /var/cache/yum ];then
        echo "clear yum cache for future install"
        rm -rf /var/cache/yum/*
fi
