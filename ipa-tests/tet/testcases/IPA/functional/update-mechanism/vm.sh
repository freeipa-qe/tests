#!/bin/sh

. ./libs.sh
. ./testvars


##############################################
###   CLIENT32 VM possible environments   ####
##############################################

setclient32_clean(){
	vmhoster=$client32_hoster
	vmguest_hostname=$client32_hostname
	vmguest_imagename=$client32_imagename
	vmguest_imagefile=$client32_imagefile
	vmguest_reventimage=$client32_qa
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

#setclient32_ipa10() is missing, i need work on this one later

setclient32_ipa11(){
	vmhoster=$client32_hoster
	vmguest_hostname=$client32_hostname
	vmguest_imagename=$client32_imagename
	vmguest_imagefile=$client32_imagefile
	vmguest_reventimage=$client32_ipa11
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
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
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver32_ipa10(){
	vmhoster=$server32_hoster
	vmguest_hostname=$server32_hostname
	vmguest_imagename=$server32_imagename
	vmguest_imagefile=$server32_imagefile
	vmguest_reventimage=$server32_ipa10
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver32_ipa11(){
	vmhoster=$server32_hoster
	vmguest_hostname=$server32_hostname
	vmguest_imagename=$server32_imagename
	vmguest_imagefile=$server32_imagefile
	vmguest_reventimage=$server32_ipa11
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
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
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica32_ipa10(){
	vmhoster=$replica32_hoster
	vmguest_hostname=$replica32_hostname
	vmguest_imagename=$replica32_imagename
	vmguest_imagefile=$replica32_imagefile
	vmguest_reventimage=$replica32_ipa10
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica32_ipa11(){
	vmhoster=$replica32_hoster
	vmguest_hostname=$replica32_hostname
	vmguest_imagename=$replica32_imagename
	vmguest_imagefile=$replica32_imagefile
	vmguest_reventimage=$replica32_ipa11
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
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
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient64_ipa10(){
	vmhoster=$client64_hoster
	vmguest_hostname=$client64_hostname
	vmguest_imagename=$client64_imagename
	vmguest_imagefile=$client64_imagefile
	vmguest_reventimage=$client64_ipa10
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setclient64_ipa11(){
	vmhoster=$client64_hoster
	vmguest_hostname=$client64_hostname
	vmguest_imagename=$client64_imagename
	vmguest_imagefile=$client64_imagefile
	vmguest_reventimage=$client64_ipa11
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
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
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver64_ipa10(){
	vmhoster=$server64_hoster
	vmguest_hostname=$server64_hostname
	vmguest_imagename=$server64_imagename
	vmguest_imagefile=$server64_imagefile
	vmguest_reventimage=$server64_ipa10
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
	reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setserver64_ipa11(){
	vmhoster=$server64_hoster
	vmguest_hostname=$server64_hostname
	vmguest_imagename=$server64_imagename
	vmguest_imagefile=$server64_imagefile
	vmguest_reventimage=$server64_ipa11
	echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
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
        echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica64_ipa10(){
        vmhoster=$replica64_hoster
        vmguest_hostname=$replica64_hostname
        vmguest_imagename=$replica64_imagename
        vmguest_imagefile=$replica64_imagefile
        vmguest_reventimage=$replica64_ipa10
        echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}

setreplica64_ipa11(){
        vmhoster=$replica64_hoster
        vmguest_hostname=$replica64_hostname
        vmguest_imagename=$replica64_imagename
        vmguest_imagefile=$replica64_imagefile
        vmguest_reventimage=$replica64_ipa11
        echo "($vmhoster) ($vmguest_hostname) ($vmguest_imagename) ($vmguest_imagefile) ($vmguest_reventimage)"
        reventVM $vmhoster $vmguest_hostname $vmguest_imagename $vmguest_imagefile $vmguest_reventimage
}



setclient32_ipa11
setclient64_ipa10
setserver64_ipa10
