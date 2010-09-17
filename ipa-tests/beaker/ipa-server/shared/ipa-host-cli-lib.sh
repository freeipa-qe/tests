#!/bin/sh

########################################################################
#  HOST CLI SHARED LIBRARY
#######################################################################
# Includes:
#	addHost
#	findHost
#	modHost
#	verifyHostAttr
#	verifyHostClasses
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
   rc=0

	ipa host-add $newhost --force
	rc=$?
   	if [ $rc -ne 0 ] ; then
        	rlLog "Adding new host $newhost failed with force option"
   	else
        	rlLog "Adding new host $newhost successful with force option."
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
        	rlLog "$myhost verification failed: Value of $attribute is $value."
   	else
		rlLog "Value of $attribute for $myhost is as expected."
   	fi
   else
	rlLog "ERROR: ipa host-show command failed. Return code: $rc"
   fi

   return $rc
}

verifyHostClasses()
{
   myhost=$1
   rc=0

   ipa host-show --all $myhost
   rc=$?
   if [ $rc -eq 0 ] ; then
	i=0
	set -a expected ipaobject nshost ipahost pkiuser ipaservice krbprincipalaux krbprincipal top
	classes=`ipa host-show --all $myhost | grep objectclass`
	while [ $i -le 8 ] ; do
		echo $classes | grep "${classes[$i]}"
		if [ $? -ne 0 ] ; then
			rlLog "ERROR - objectclass \"${classes[$i]}\" was not returned with host-show --all"
			rc=1
		else
			rlLog "objectclass \"${classes[$i]}\" was returned as expected with host-show --all"
		fi
		((i=$i+1))
	done
   else
	rlLog "ERROR: Show host failed. Return Code: $rc"
   fi

   return $rc
}

#######################################################################
# disableHost Usage:
#       disableHost hostname
# example:
#       disableHost jenny.bos.redhat.com
#       disableHost jenny
# returns
#       return code from ipa host-disable command
######################################################################

disableHost()
{
   myhost=$1
   rc=0

   ipa host-disable $myhost
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Disabling host $myhost failed."
   else
        rlLog "Host $myhost disabled successfully."
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
