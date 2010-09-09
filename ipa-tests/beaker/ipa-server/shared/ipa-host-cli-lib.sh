#!/bin/sh

########################################################################
#  HOST CLI SHARED LIBRARY
#######################################################################
# Includes:
#	addHost
#	findHost
#	modHost
#	verifyHostAttr
#	deleteHost
######################################################################
# Assumes:
#	For successful command exectution, administrative credentials
#	already exist.
#######################################################################

#######################################################################
# addHost Usage:
#	addHost hostname.domain.com
######################################################################

addHost()
{
   newhost=$1

   ipa host-add $newhost
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "Adding new host $newhost failed"
   else
        rlLog "Adding new host $newhost successful."
   fi
   return $rc

}

#######################################################################
# findHost Usage:
#       findHost hostname.domain.com
# example:
#	findHost jenny.bos.redhat.com
######################################################################

findHost()
{
   myhost=$1
   ipa host-find $myhost
   rc=$?
   echo "DEBUG: return code is $rc"
   if [ $rc -eq 0 ] ; then
	rlLog "$myhost was found."
   	# check hostname
	result=`ipa host-find $myhost`
   	check=`echo $myhost | tr "[A-Z]" "[a-z]"`
 	echo $result | grep "Host name: $check"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: Host name not as expected."
		rc=1        
   	else
		rlLog "Host name is as expected."
   	fi

   	#check pincipal name
   	echo $result | grep "Principal name: host/$check"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: Principal name not as expected."
		rc=1
	else
		rlLog "Principal name is as expected."
	fi
   else
		rlLog "ERROR: Failed to add host. Return code: $rc"
   fi

   return $rc

}

#######################################################################
# modifyHost Usage:
#       modifyHost hostname.domain.com attribute value
# example:
#	modifyHost jenny.bos.redhat.com location "Lab 3"
# returns:
#	return code from ipa host-mod command
######################################################################

modifyHost()
{

   myhost=$1
   attribute=$2
   value=$3
   rc=0

   ipa host-mod --$attribute="${value}" $myhost
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Modifying host $myhost failed."
   else
        rlLog "Modifying host $myhost successful."
   fi
   return $rc
}

#######################################################################
# verifyHostAttr Usage:
#       verifyHostAttr hostname.domain.com attribute value
# example:
#       verifyHostAttr jenny.bos.redhat.com location "Lab 3"
# returns:
#	0 - success
#	1 - failure
######################################################################

verifyHostAttr()
{
   myhost=$1
   attribute=$2
   value=$3
   rc=0

   attribute="$attribute:"
   tmpfile="/tmp/hostshow_$myhost.out"
   delim=":"
   ipa host-show $myhost
   rc=$?
   if [ $rc -eq 0 ] ; then
   	result=`ipa host-show $myhost`
	echo $result | grep "$attriute $value"
	rc=$?
   	if [ $rc -ne 0 ] ; then
        	rlLog "ERROR: $myhost verification failed: Value of $attribute not correct."
   	else
		rlLog "Value of $attribute for $myhost is as expected."
   	fi
   else
	rlLog "ERROR: ipa host-show command failed. Return code: $rc"
   fi

   return $rc
}

#######################################################################
# deleteHost Usage:
#       deleteHost hostname
# example:
#       deleteHost jenny.bos.redhat.com
#	deleteHost jenny
# returns
#	return code from ipa host-del command
######################################################################

deleteHost()
{
   myhost=$1
   rc=0

   ipa host-del $myhost
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Deleting host $myhost failed."
   else
        rlLog "Host $myhost deleted successfully."
   fi
   return $rc
}
