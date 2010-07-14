#!/bin/sh

ramdom=$RANDOM
setupfile=/tmp/setup.$random.ini
fqdn=`hostname`
short_hostname=`echo $fqdn | cut -d"." -f1`
domainname=`dnsdomainname`
installcmd=/usr/sbin/setup-ds.pl
removalcmd=/usr/sbin/remove-ds.pl

echo "--- variable used ---"
echo "fqdn=$fqdn"
echo "host=$short_hostname"
echo "domain=$domainname"

if [ -f $removalcmd ]
then
	if [ -d /etc/dirsrv/slapd-${short_hostname} ]
	then
		echo "--> remove instance: /etc/dirsrv/slapd-${short_hostname}"
		$removalcmd -i slapd-${short_hostname}
	fi
	echo "=== now ready for fresh install ==="
fi


if [ -f $installcmd ]
then
  touch $setupfile
  echo "[General]" >> $setupfile
  echo "FullMachineName=         $fqdn" >> $setupfile
  echo "AdminDomain=             $domainname" >> $setupfile
  echo "SuiteSpotUserID=         nobody" >> $setupfile
  echo "SuiteSpotGroup=          nobody" >> $setupfile
  echo "[slapd]" >> $setupfile
  echo "SlapdConfigForMC=        Yes" >> $setupfile
  echo "UseExistingMC=           No" >> $setupfile
  echo "ServerPort=              389" >> $setupfile
  echo "ServerIdentifier=        $short_hostname" >> $setupfile
  echo "RootDN=                  cn=directory manager" >> $setupfile
  echo "RootDNPwd=               redhat123" >> $setupfile
  echo "using the next file to setup ds instance"
  cat $setupfile
  $installcmd -s --file=$setupfile
  rm $setupfile
else
  echo "can not find the install perl script: [$installcmd]"
fi

echo "--------- done -----------"
echo ""
