#!/bin/sh

########################################################################
#  HOST CLI SHARED LIBRARY
#######################################################################
# Includes:
#	addHABCRule
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

	ipa hbac-add $type $usercat $hostcat $srchostcat $servicecat $rulename
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
	result=`cat $tmpfile | grep "Enabled | cut -d ":" -f 2"`
	result=`echo $result`
   	if [ $result != $status ] ; then
        	rlLog "ERROR: Expect $rulename Enabled status to be $status. GOT: $result"
   	else
		rlLog "$myrule is $status as expected."
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

