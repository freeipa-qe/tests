#!/bin/sh

########################################################################
#  HOST CLI SHARED LIBRARY
#######################################################################
# Includes:
#	addHBACRule
#	findHBACRule
#	disableHBACRule
#	enableHBACRule
#	verifyHBACStatus
#	addToHBAC
#	removeFromHBAC
#	verifyHBACAssoc
#	deleteHBACRule
######################################################################
# Assumes:
#	For successful command exectution, administrative credentials
#	already exist.
#######################################################################

#######################################################################
# addHBACRule Usage:
#	addHBACRule <type> <usercat> <hostcat> <srchostcat> <servicecat> <rulename>
######################################################################

addHBACRule()
{
   type=$1
   usercat=$2
   hostcat=$3
   srchostcat=$4
   servicecat=$5
   rulename=$6
   rc=0

	rlLog "Executing: ipa hbac-add --type=$type --usercat=$usercat --hostcat=$hostcat --srchostcat=$srchostcat --servicecat=$servicecat $rulename"
	ipa hbac-add --type=$type --usercat=$usercat --hostcat=$hostcat --srchostcat=$srchostcat --servicecat=$servicecat $rulename
	rc=$?
   	if [ $rc -ne 0 ] ; then
        	rlLog "WARNING: Adding new hbac rule $rulename failed."
   	else
        	rlLog "Adding new hbac rule $rulename successful."
   	fi

   return $rc

}

#######################################################################
# findHBACRule Usage:
#       findHBACRule <rulename>
######################################################################

findHBACRule()
{
   rulename=$1
   ipa hbac-find $rulename
   rc=$?
   if [ $rc -eq 0 ] ; then
	result=`ipa hbac-find $rulename`

	# check rule name
 	echo $result | grep "Rule name: $rulename"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: Host name not as expected."
		rc=1        
   	else
		rlLog "Rule name is as expected."
   	fi

   	#check Rule type
   	echo $result | grep "Rule type: Allow"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: Rule type not as expected."
		rc=1
	else
		rlLog "Rule type is as expected."
	fi

        #check Enabled
        echo $result | grep "Enabled: TRUE"
        if [ $? -ne 0 ] ; then
                rlLog "ERROR: Enabled not as expected."
                rc=1
        else
                rlLog "Enabled is TRUE as expected."
        fi
   else
		rlLog "WARNING: Failed to find hbac rule."
   fi

   return $rc

}

#######################################################################
# verifyHBACStatus Usage:
#       verifyHBACStatus <rulename> <TRUE_or_FALSE>
######################################################################

verifyHBACStatus()
{
   rulename=$1
   status=$2
   rc=0
   tmpfile=/tmp/hbacfind.out

   ipa hbac-find $rulename > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	result=`cat $tmpfile | grep "Enabled" | cut -d ":" -f 2`
	result=`echo $result`
   	if [[ $result != $status ]] ; then
        	rlLog "ERROR: Expect $rulename Enabled status to be $status. GOT: $result"
   	else
		rlLog "$rulename is $status as expected."
   	fi
   else
	rlLog "WARNING: ipa hbac-find command failed."
   fi

   return $rc
}


#######################################################################
# disableHBACRule Usage:
#       disableHBACRule <rulename>
######################################################################

disableHBACRule()
{
   rulename=$1
   rc=0

   ipa hbac-disable $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Disabling hbac rule $rulename failed."
   else
        rlLog "HBAC rule $rulename disabled successfully."
   fi

   return $rc
}

#######################################################################
# enableHBACRule Usage:
#       enableHBACRule <rulename>
######################################################################

enableHBACRule()
{
   rulename=$1
   rc=0

   ipa hbac-enable $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Enabling hbac rule $rulename failed."
   else
        rlLog "HBAC rule $rulename enabled successfully."
   fi

   return $rc
}

###################################################################################
# addToHBAC Usage:
#       addToHBAC <rulename> <host|service|user|sourcehost> <type> <list_of_objects>
###################################################################################
addToHBAC()
{
   rulename=$1
   option=$2
   type=$3
   objects=$4
   rc=0

   rlLog "EXECUTING: ipa hbac-add-$option --$type=\"$objects\" $rulename"
   ipa hbac-add-$option --$type="$objects" $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then 
	rlLog "WARNING: ipa hbac-add-$option failed to objects \"$objects\" of type $type to Rule $rulename"
   else
	rlLog "\"$objects\" of type $type successfully added to Rule $rulename"
   fi

   return $rc
}

###################################################################################
# removeFromHBAC Usage:
#       addToHBAC <rulename> <host|service|user|sourcehost> <type> <list_of_objects>
###################################################################################
removeFromHBAC()
{
   rulename=$1
   option=$2
   type=$3
   objects=$4
   rc=0

   rlLog "EXECUTING: ipa hbac-remove-$option --$type=\"$objects\" $rulename"
   ipa hbac-remove-$option --$type="$objects" $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: ipa hbac-remove-$option failed to objects \"$objects\" of type $type to Rule $rulename"
   else
        rlLog "\"$objects\" of type $type successfully removed from Rule $rulename"
   fi

   return $rc
}

############################################################################
# modifyHBACRule Usage:
#	modifyHBACRule <rulename> <option> <value>
############################################################################
modifyHBACRule()
{
  rulename=$1
  option=$2
  value=$3
  rc=0

  ipa hbac-mod --$option="$value" $rulename
  rc=$?
  if [ $rc -eq 0 ] ; then
	rlLog "Modify rule $rulename $option successful. Value: $value"
  else
	rlLog "WARNING: Failed to modify rule $rulename $option to value $value"
	rc=1
  fi

  return $rc
}

#############################################################################
# verifyHBACAssoc Usage
#   verifyHBACAssoc <rulename> <obj_type> <object>
##############################################################################

verifyHBACAssoc()
{
  rulename=$1
  objtype=$2
  object=$3
  rc=0

  tmpfile=/tmp/hbacshow.out

  ipa hbac-show --all $rulename > $tmpfile
  rc=$?
  if [ $rc -eq 0 ] ; then
     objects=`cat $tmpfile | grep "$objtype" | cut -d ":" -f 2`
     echo $objects | grep "$object"
     if [ $? -eq 0 ] ; then 
        rlLog "$ojbtype \"$object\" is associated with rule $rulename"
     else
        rlLog "WARNING: $ojbtype \"$object\" is NOT associated with rule $rulename"
        rc=1
     fi
 else
     rlLog "ERROR: ipa hbac-show command failed"
 fi

 return $rc
}

#######################################################################
# deleteHBACRule Usage:
#       deleteHBAC <rulename>
######################################################################

deleteHBACRule()
{
   rulename=$1
   rc=0

   ipa hbac-del $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting hbac rule $rulename failed."
   else
        rlLog "HBAC rule $rulename deleted successfully."
   fi

   return $rc
}

