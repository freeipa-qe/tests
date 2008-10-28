#!/bin/sh


LOG(){
  MSG=$1
  TIMESTAMP=`date "+[%D %H:%M:%S]"`
  if [ -z $LOGFILE ]
  then
	LOGFILE=/tmp/$RANDOM.log
	echo "" > $LOGFILE
  fi
  echo "$TIMESTAMP $MSG" >> $LOGFILE
}

shutdownVM()
{
  vmhoster=$1
  vmguest_hostname=$2
  vmguest_imagename=$3
  status=`ssh root@$vmhoster "virsh list | grep $vmguest_imagename"`
  if echo $status | grep running
  then
	ssh root@$vmguest_hostname poweroff
	echo "send 'poweroff' signal to $vmguest_hostname"
  else
	echo "$vmguest_hostname is already shutdown"
  fi
}

startVM()
{
  vmhoster=$1
  vmguest_hostname=$2
  vmguest_imagename=$3
  status=`ssh root@$vmhoster "virsh list | grep $vmguest_imagename"`
  if echo $status | grep running
  then
        echo "$vmguest_hostname is already started"
  else
        ssh root@$vmhoster "virsh start $vmguest_imagename"
        echo "called virsh start"
  fi
}

reventVM()
{
  vmhoster=$1
  vmguest_hostanme=$2
  vmguest_imagename=$3
  vmguest_currentimage=$4
  vmguest_reventimage=$5
  echo "stutdown $vmguest_hostname"
  shutdownVM $vmhoster $vmguest_hostname $vmguest_imagename
  echo "sleep for 60 seconds, wait for $vmguest_hostanme fully shutdown"
  sleep 60
  echo "revent image with ($vmguest_reventimage)"
  ssh root@$vmhoster "cp -f $vmguest_reventimage $vmguest_currentimage"
  echo "start the revented guest "
  startVM $vmhoster $vmguest_hostname $vmguest_imagename
}

