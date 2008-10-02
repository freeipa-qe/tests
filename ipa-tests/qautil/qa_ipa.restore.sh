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
	echo "ipa stopped"
  	sleep 3
  else
	echo "No $IPACTL found"
  fi
}

current_dir=`pwd`
conf=$1
if [ -e $conf ] && [ -r $conf ] ;then
	echo "using $conf as snapshot restore configuration file"
	echo "stoping ipa"
	stopipa
	while read line
	do
		echo $line
		original=`echo $line | cut -d" " -f1`
		tar=`echo $line | cut -d" " -f2`
		cd $original
		# change current file to backup files
		for f in `ls`
		do
			mv $f bk.$f
		done
		tar xf $tar
	done < $conf
	$IPACTL start
else
	echo "$conf file does not exist or not readable, exit"
fi
