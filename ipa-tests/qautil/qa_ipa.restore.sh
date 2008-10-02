#!/bin/sh

# functions
stopipa()
{
  IPACTL=/usr/sbin/ipactl
  if [ -e $IPACTL ] &&  [ -x $IPACTL ];then
	#$IPACTL stop
	ps -eo pid,cmd | grep ipa_web    | grep -v "grep" | cut -d" " -f1 > pid.txt	
	ps -eo pid,cmd | grep kdc        | grep -v "grep" | cut -d" " -f1 >> pid.txt
	ps -eo pid,cmd | grep ipa_kpasswd| grep -v "grep" | cut -d" " -f1 >> pid.txt
	ps -eo pid,cmd | grep ns-slapd   | grep -v "grep" | cut -d" " -f1 >> pid.txt
	if [ `wc pid.txt -l | cut -d" " -f1` -gt 0 ];then
		for pid in `cat pid.txt`
		do
		  kill -9 $pid
		done
		sleep 3
		rm pid.txt
	else
		echo "ipa stopped"
	fi
  else
	echo "No $IPACTL found"
  fi
}

cleanup_runningfile()
{
  echo "clean up the lock and run file"
  rm -rf /var/lock/subsys/dirsrv
  rm -rf /var/lock/dirsrv
  rm -rf /var/run/dirsrv
}

current_dir=`pwd`
conf=$1
if [ -e $conf ] && [ -r $conf ] ;then
	echo "using $conf as snapshot restore configuration file"
	while read line
	do
		echo $line
		original=`echo $line | cut -d" " -f1`
		tar=`echo $line | cut -d" " -f2`
		cd $original
		tar xf $tar
	done < $conf
	cleanup_runningfile
else
	echo "$conf file does not exist or not readable, exit"
fi
