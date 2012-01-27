#!/bin/sh
    
########################################################################
#  PERMISSION, PRIVILEGE, ROLE CLI SHARED LIBRARY
#######################################################################
# Includes:
#       addPermission
#       findPermission
#       modPermission
#       verifyPermissionAttr
#       verifyPermissionClasses
#       addPermissionManagedBy
#       removePermissionManagedBy
#       disablePermission
#       deletePermission
#       getNumberOfPermissions
######################################################################
# Assumes:
#       For successful command exectution, administrative credentials
#       already exist.
#######################################################################


#######################################################################
# addPermission Usage:
#       addPermission <permissionName> <permissionRights> <permissionTarget> <permissionAttr>
#       addPermission <permissionName> <permissionRights> <permissionTarget> <permisisonAttr> <permissionOtherParam>
######################################################################

addPermission()
{
    if [ `echo $#` > 3 ] ; then
       permissionAttr=$4   
       permissionOtherParam=$5   
    else
       permissionAttr=""  
       permissionOtherParam=""  
    fi
    permissionName=$1
    permissionRights=$2
    permissionTarget=$3
    rc=0

        if [ -z $permissionAttr ] ; then
           rlLog "ipa permission-add $permissionName --permissions=$permissionRights $permissionTarget"
            ipa permission-add $permissionName --permissions=$permissionRights $permissionTarget
        else 
           rlLog " Executing: ipa permission-add $permissionName --permissions=\"$permissionRights\" $permissionTarget --attr=$permissionAttr $permissionOtherParam"
           ipa permission-add $permissionName --permissions=$permissionRights $permissionTarget --attr=$permissionAttr $permissionOtherParam 
        fi
        rc=$?
        if [ $rc -ne 0 ] ; then
            rlLog "There was an error adding $permissionName"
        else
            rlLog "Added new permission $permissionName successfully" 
        fi

   return $rc

}

######################################################################
# deletePermission Usage:
#	deletePermission <permissionName>
######################################################################
deletePermission()
{
	permissionName=$1
	rc=0

	rlLog "Executing: ipa permission-del $permissionName"
	ipa permission-del $permissionName 
	rc=$?
	if [ $rc -ne 0 ]; then
            rlLog "There was an error deleting $permissionName"
	else
            rlLog "Deleted permission $permissionName successfully" 
	fi

	return $rc
}



######################################################################
# verifyPermissionAttr Usage:
# 	verifyPermissionAttr <name> <type> <attribute> <value>
######################################################################
verifyPermissionAttr()
{

        permissionName=$1
        allOrRaw=$2
	attribute="$3:"
        if [ "$attribute" == "dn:" -o "$attribute" == "Subtree:" ] ; then
           value=$4
        else
           value=`echo $4 | sed 's/,/, /g'`
        fi


	tmpfile=/tmp/permissionshow.out.??
	rc=0
	
       if [ "$allOrRaw" == "all" ] ; then
	   rlLog "Executing: ipa permission-show --all $permissionName"
   	   ipa permission-show --all $permissionName > $tmpfile
       else
	   rlLog "Executing: ipa permission-show --all --raw $permissionName"
	   ipa permission-show --all --raw $permissionName > $tmpfile
       fi
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: ipa permission-show command failed."
		return $rc
	fi
	
	cat $tmpfile | grep -i "$attribute $value"
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "ERROR: ipa permission $permissionName verification failed:  Value of $attribute != $value"
		rlLog "ERROR: ipa permission $permissionName verification failed:  it is `cat $tmpfile | grep $attribute`"
	else
		rlLog "ipa permission $permissionName Verification successful: Value of $attribute = $value"
	fi

	return $rc
}
