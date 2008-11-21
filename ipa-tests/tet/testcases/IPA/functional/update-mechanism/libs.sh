#!/bin/sh

. ./testvars

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

techo(){
  # echo but add timestamp as beginning
  MSG=$1
  TIMESTAMP=`date "+[%D %H:%M:%S]"`
  echo "$TIMESTAMP $MSG"
}

shutdownVM()
{
  vmhoster=$1
  vmguest_hostname=$2
  vmguest_imagename=$3
  status=`ssh root@$vmhoster "virsh list | grep $vmguest_imagename"`
  if echo $status | grep running
  then
	techo "	image is running, sending 'poweroff' signal to $vmguest_hostname"
  	techo "	sleep for 60 seconds, wait for $vmguest_hostanme fully shutdown"
	ssh root@$vmguest_hostname poweroff
	sleep 60
  else
	techo "	$vmguest_hostname is already shutdown"
  fi
}

startVM()
{
  vmhoster=$1
  vmguest_hostname=$2
  vmguest_imagename=$3
  status=`ssh root@$vmhoster "virsh list | grep $vmguest_imagename /dev/null 2>&1"`
  if echo $status | grep running
  then
        techo "	$vmguest_hostname is already started"
  else
        ssh root@$vmhoster "virsh start $vmguest_imagename > /dev/null 2>&1 "
        techo "	virsh start called "
  fi
}

reventVM()
{
  vmhoster=$1
  vmguest_hostanme=$2
  vmguest_imagename=$3
  vmguest_currentimage=$4
  vmguest_reventimage=$5
  echo ""
  techo "[$vmguest_imagename] Revent VM STARTS..."
  techo "	vm hoster   : ($vmhoster)"
  techo "	vm guest    : ($vmguest_hostanme)"
  techo "	vm image    : ($vmguest_imagename)"
  techo "	revent image: ($vmguest_reventimage)"

  techo "  [1/3] : stutdown $vmguest_hostname"
  shutdownVM $vmhoster $vmguest_hostname $vmguest_imagename
  techo "  [2/3] : revent image with ($vmguest_reventimage)"
  ssh root@$vmhoster "cp -f $vmguest_reventimage $vmguest_currentimage"
  techo "  [3/3] : start the revented guest "
  startVM $vmhoster $vmguest_hostname $vmguest_imagename
  techo "[$vmguest_imagename] Revent VM Finished"
  echo ""
}

##############################################
###   CLIENT32 VM possible environments   ####
##############################################

setclient32_qa(){
	vmhoster=$client32_hoster
	vmguest_hostname=$client32_hostname
	vmguest_imagename=$client32_imagename
	vmguest_imagefile=$client32_imagefile
	vmguest_reventimage=$client32_qa
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient32_ipa10(){
	vmhoster=$client32_hoster
	vmguest_hostname=$client32_hostname
	vmguest_imagename=$client32_imagename
	vmguest_imagefile=$client32_imagefile
	vmguest_reventimage=$client32_ipa10
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient32_ipa11(){
	vmhoster=$client32_hoster
	vmguest_hostname=$client32_hostname
	vmguest_imagename=$client32_imagename
	vmguest_imagefile=$client32_imagefile
	vmguest_reventimage=$client32_ipa11
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

##############################################
###   SERVER32 VM possible environments   ####
##############################################

setserver32_qa(){
	vmhoster=$server32_hoster
	vmguest_hostname=$server32_hostname
	vmguest_imagename=$server32_imagename
	vmguest_imagefile=$server32_imagefile
	vmguest_reventimage=$server32_qa
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver32_ipa10(){
	vmhoster=$server32_hoster
	vmguest_hostname=$server32_hostname
	vmguest_imagename=$server32_imagename
	vmguest_imagefile=$server32_imagefile
	vmguest_reventimage=$server32_ipa10
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver32_ipa11(){
	vmhoster=$server32_hoster
	vmguest_hostname=$server32_hostname
	vmguest_imagename=$server32_imagename
	vmguest_imagefile=$server32_imagefile
	vmguest_reventimage=$server32_ipa11
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}


##############################################
###   REPLICA32 VM possible environments   ####
##############################################

setreplica32_qa(){
	vmhoster=$replica32_hoster
	vmguest_hostname=$replica32_hostname
	vmguest_imagename=$replica32_imagename
	vmguest_imagefile=$replica32_imagefile
	vmguest_reventimage=$replica32_qa
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica32_ipa10(){
	vmhoster=$replica32_hoster
	vmguest_hostname=$replica32_hostname
	vmguest_imagename=$replica32_imagename
	vmguest_imagefile=$replica32_imagefile
	vmguest_reventimage=$replica32_ipa10
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica32_ipa11(){
	vmhoster=$replica32_hoster
	vmguest_hostname=$replica32_hostname
	vmguest_imagename=$replica32_imagename
	vmguest_imagefile=$replica32_imagefile
	vmguest_reventimage=$replica32_ipa11
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

##############################################
###   REPLICA32 VM possible environments   ####
##############################################

setclient32_rh4__qa(){
        vmhoster=$client32_rh4_hoster
        vmguest_hostname=$client32_rh4_hostname
        vmguest_imagename=$client32_rh4_imagename
        vmguest_imagefile=$client32_rh4_imagefile
        vmguest_reventimage=$client32_rh4_qa
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient32_rh4_ipa10(){
        vmhoster=$client32_rh4_hoster
        vmguest_hostname=$client32_rh4_hostname
        vmguest_imagename=$client32_rh4_imagename
        vmguest_imagefile=$client32_rh4_imagefile
        vmguest_reventimage=$client32_rh4_ipa10
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient32_rh4_ipa11(){
        vmhoster=$client32_rh4_hoster
        vmguest_hostname=$client32_rh4_hostname
        vmguest_imagename=$client32_rh4_imagename
        vmguest_imagefile=$client32_rh4_imagefile
        vmguest_reventimage=$client32_rh4_ipa11
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}


##############################################
###   CLIENT64 VM possible environments   ####
##############################################

setclient64_qa(){
	vmhoster=$client64_hoster
	vmguest_hostname=$client64_hostname
	vmguest_imagename=$client64_imagename
	vmguest_imagefile=$client64_imagefile
	vmguest_reventimage=$client64_qa
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient64_ipa10(){
	vmhoster=$client64_hoster
	vmguest_hostname=$client64_hostname
	vmguest_imagename=$client64_imagename
	vmguest_imagefile=$client64_imagefile
	vmguest_reventimage=$client64_ipa10
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient64_ipa11(){
	vmhoster=$client64_hoster
	vmguest_hostname=$client64_hostname
	vmguest_imagename=$client64_imagename
	vmguest_imagefile=$client64_imagefile
	vmguest_reventimage=$client64_ipa11
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}


##############################################
###   SERVER64 VM possible environments   ####
##############################################

setserver64_qa(){
	vmhoster=$server64_hoster
	vmguest_hostname=$server64_hostname
	vmguest_imagename=$server64_imagename
	vmguest_imagefile=$server64_imagefile
	vmguest_reventimage=$server64_qa
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver64_ipa10(){
	vmhoster=$server64_hoster
	vmguest_hostname=$server64_hostname
	vmguest_imagename=$server64_imagename
	vmguest_imagefile=$server64_imagefile
	vmguest_reventimage=$server64_ipa10
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver64_ipa11(){
	vmhoster=$server64_hoster
	vmguest_hostname=$server64_hostname
	vmguest_imagename=$server64_imagename
	vmguest_imagefile=$server64_imagefile
	vmguest_reventimage=$server64_ipa11
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}



##############################################
###   REPLICA64 VM possible environments   ####
##############################################

setreplica64_qa(){
        vmhoster=$replica64_hoster
        vmguest_hostname=$replica64_hostname
        vmguest_imagename=$replica64_imagename
        vmguest_imagefile=$replica64_imagefile
        vmguest_reventimage=$replica64_qa
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica64_ipa10(){
        vmhoster=$replica64_hoster
        vmguest_hostname=$replica64_hostname
        vmguest_imagename=$replica64_imagename
        vmguest_imagefile=$replica64_imagefile
        vmguest_reventimage=$replica64_ipa10
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica64_ipa11(){
        vmhoster=$replica64_hoster
        vmguest_hostname=$replica64_hostname
        vmguest_imagename=$replica64_imagename
        vmguest_imagefile=$replica64_imagefile
        vmguest_reventimage=$replica64_ipa11
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

####################################################
###   CLIENT64-RHEL4 VM possible environments   ####
####################################################

setclient64_rh4_qa(){
        vmhoster=$client64_rh4_hoster
        vmguest_hostname=$client64_rh4_hostname
        vmguest_imagename=$client64_rh4_imagename
        vmguest_imagefile=$client64_rh4_imagefile
        vmguest_reventimage=$client64_rh4_qa
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient64_rh4_ipa10(){
        vmhoster=$client64_rh4_hoster
        vmguest_hostname=$client64_rh4_hostname
        vmguest_imagename=$client64_rh4_imagename
        vmguest_imagefile=$client64_rh4_imagefile
        vmguest_reventimage=$client64_rh4_ipa10
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient64_rh4_ipa11(){
        vmhoster=$client64_rh4_hoster
        vmguest_hostname=$client64_rh4_hostname
        vmguest_imagename=$client64_rh4_imagename
        vmguest_imagefile=$client64_rh4_imagefile
        vmguest_reventimage=$client64_rh4_ipa11
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

