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
echo "restore start..."
if [ -e $conf ] && [ -r $conf ] ;then
	echo "restore configuration file used: [$conf]"
	echo "step 1: stopping ipa"
	counter=0
	stopipa
	while read line
	do
		counter=$((counter+1))
		echo "step $counter: parsing [$line]"
		original=`echo $line | cut -d" " -f1`
		tar=`echo $line | cut -d" " -f2`
		echo "	targetted dir: [$original]"
		echo "	source tar   : [$tar]"
		cd $original
		# change current file to backup files
		flist=$RANDOM.flist
		for f in `ls`
		do
			echo $f >> $flist
		done
		cat $flist | xargs  tar cf backup.tar
		echo "	save current file to [$tar.bk]"
		mv -f backup.tar $tar.bk
		rm $flist
		echo "	extract tar file into targetted dir"
		tar xf $tar
	done < $conf
	$IPACTL start
else
	echo "[$conf] file does not exist or not readable, exit"
fi
echo "restore done"
