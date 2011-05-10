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
#	addHostManagedBy
#	removeHostManagedBy
#	disableHost
#	deleteHost
#	getNumberOfHosts
######################################################################
# Assumes:
#	For successful command exectution, administrative credentials
#	already exist.
#######################################################################

#######################################################################
# addHost Usage:
#	addHost <hostname>
######################################################################

addHost()
{
   newhost=$1
   rc=0

	ipa host-add $newhost --force
	rc=$?
   	if [ $rc -ne 0 ] ; then
        	rlLog "WARNING: Adding new host $newhost failed with force option"
   	else
        	rlLog "Adding new host $newhost successful with force option."
   	fi

   return $rc

}

#######################################################################
# findHost Usage:
#       findHost <hostname>
######################################################################

findHost()
{
   myhost=$1
   ipa host-find $myhost
   rc=$?
   if [ $rc -eq 0 ] ; then
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
		rlLog "WARNING: Failed to find host."
   fi

   return $rc

}

#######################################################################
# modifyHost Usage:
#       modifyHost <hostname> <attribute> <value>
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
        rlLog "WARNING: Modifying host $myhost failed."
   else
        rlLog "Modifying host $myhost successful."
   fi

   return $rc
}

#######################################################################
# addHostManagedBy Usage"
#	addHostManagedBy <managedByHostname_list> <hostname>
#######################################################################

addHostManagedBy()
{
  managedbylist="$1"
  myhost=$2
  rc=0

  ipa host-add-managedby --hosts="$managedbylist" $myhost
  rc=$?
  if [ $rc -ne 0 ] ; then
	rlLog "WARNING: Adding Managed By Hosts failed for $myhost."
  else
	rlLog "Adding Managed By Hosts Successful."
  fi

  return $rc
}

#######################################################################
# removeHostManagedBy Usage"
#       removeHostManagedBy <managedByHostname> <hostname>
#######################################################################

removeHostManagedBy()
{
  managedbylist=$1
  myhost=$2
  rc=0

  ipa host-remove-managedby --hosts="$managedbylist" $myhost
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Removing Managed By Hosts failed for $myhost."
  else  
        rlLog "Removing Managed By Hosts Successful."
  fi

  return $rc
}

#######################################################################
# verifyHostAttr Usage:
#       verifyHostAttr <hostname> <attribute> <value>
######################################################################

verifyHostAttr()
{
   myhost=$1
   attribute=$2
   value=$3
   rc=0

   attribute="$attribute:"
   tmpfile="/tmp/hostshow_$myhost.out"

   ipa host-show $myhost > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        myval=`cat $tmpfile | grep "$attribute $value" | xargs echo`
	cat $tmpfile | grep "$attribute $value"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: $myhost verification failed: Value of $attribute - GOT: $myval EXPECTED: $value"
                rc=1
   	else
		rlLog "Value of $attribute for $myhost is as expected - $myval"
   	fi
   else
	rlLog "WARNING: ipa host-show command failed."
   fi

   return $rc
}

#######################################################################
# verifyHostClasses Usage:
#       verifyHostClasses <hostname>
######################################################################
verifyHostClasses()
{
   myhost=$1
   tmpfile=/tmp/show_$myhost.out
   rc=0

   ipa host-show --all $myhost > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	i=0
	set -a expected ipaobject nshost ipahost pkiuser ipaservice krbprincipalaux krbprincipal top
	classes=`cat $tmpfile | grep objectclass`
	for item in ipaobject nshost ipahost pkiuser ipaservice krbprincipalaux krbprincipal top ; do
		echo $classes | grep $item
		if [ $? -ne 0 ] ; then
			rlLog "ERROR - objectclass \"$item\" was not returned with host-show --all"
			rc=1
		else
			rlLog "objectclass \"$item\" was returned as expected with host-show --all"
		fi
	done
   else
	rlLog "ERROR: Show host failed. Return Code: $rc"
   fi

   return $rc
}

#######################################################################
# disableHost Usage:
#       disableHost <hostname>
######################################################################

disableHost()
{
   myhost=$1
   rc=0

   ipa host-disable $myhost
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Disabling host $myhost failed."
   else
        rlLog "Host $myhost disabled successfully."
   fi

   return $rc
}

#######################################################################
# deleteHost Usage:
#       deleteHost <hostname>
######################################################################

deleteHost()
{
   myhost=$1
   rc=0

   ipa host-del $myhost
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting host $myhost failed."
   else
        rlLog "Host $myhost deleted successfully."
   fi

   return $rc
}

#######################################################################
# getNumberOfHosts Usage:
#       getNumberOfHosts
######################################################################
getNumberOfHosts()
{

   rc=0
   ipa host-find > /tmp/hosts.out
   rc=$?
   result=`cat /tmp/hosts.out | grep "Number of entries returned"`
   number=`echo $result | cut -d " " -f 5`

   echo $number
   return $rc
}

