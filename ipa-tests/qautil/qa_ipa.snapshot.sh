#!/bin/sh

# functions
stopipa()
{
  IPACTL=/usr/sbin/ipactl
  if [ -e $IPACTL ] &&  [ -x $IPACTL ];then
	$IPACTL stop
	ps -eo pid,cmd | grep ipa_web    | grep -v "grep" | cut -d" " -f1 > pid.txt	
	ps -eo pid,cmd | grep kdc        | grep -v "grep" | cut -d" " -f1 >> pid.txt
	ps -eo pid,cmd | grep ipa_kpasswd| grep -v "grep" | cut -d" " -f1 >> pid.txt
	ps -eo pid,cmd | grep ns-slapd   | grep -v "grep" | cut -d" " -f1 >> pid.txt
	if [ `wc pid.txt -l | cut -d" " -f1` -gt 0 ];then
		for pid in `cat pid.txt`
		do
		  kill -9 $pid
		done
		rm pid.txt
	fi
	sleep 3
	echo "ipa stopped"
  else
	echo "No $IPACTL found"
  fi
}

snapshot_base=$1
snapshot_name=$2
if [ -z $snapshot_base ];then
	snapshot_base=/tmp/snapshot
fi

if [ -z $snapshot_name ];then
        timestr=`date +%F_%H_%k_%M_%S`
        snapshot_dir=$snapshot_base/$timestr
else
	snapshot_dir=$snapshot_base/$snapshot_name
fi
echo "using $snapshot_dir as snapshot directory storage"

current_dir=`pwd`

mkdir -p $snapshot_dir 
if [ -d $snapshot_dir ] && [ -d /etc/dirsrv ] && [ -d /var/lib/dirsrv ] && [ -d /var/log/dirsrv ]
then
	echo "using [$snapshot_dir]"
	echo "step 1: stop ipa"
	stopipa

	echo "step 2: archive ipa config directory"
	cd /etc/dirsrv
	tar cf config.tar *
	mv config.tar $snapshot_dir/.
	echo "/etc/dirsrv $snapshot_dir/config.tar" >> $snapshot_dir/restore.conf
			
	echo "step 3: archive ipa log directory"
	cd /var/log/dirsrv
	tar cf log.tar *
	mv log.tar $snapshot_dir/.
	echo "/var/log/dirsrv $snapshot_dir/log.tar" >> $snapshot_dir/restore.conf

	echo "step 4: archive ipa db directory"
	cd /var/lib/dirsrv
	tar cf db.tar *
	mv db.tar $snapshot_dir/.
	echo "/var/lib/dirsrv $snapshot_dir/db.tar" >> $snapshot_dir/restore.conf

	cd $snapshot_dir
	pwd
	ls -lh
	echo "content of restore.conf file:"
	cat restore.conf
	$IPACTL start
	echo "done"
	cd $current_dir
fi
