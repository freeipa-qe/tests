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
        if [ "$attribute" == "dn:" -o "$attribute" == "Subtree:" -o "$attribute" == "attributelevelrights:" ] ; then
           value=$4
           if [ "$attribute" == "attributelevelrights:" ] ; then
            showrights="--rights"
           else
            showrights=""
           fi
        else
           value=`echo $4 | sed 's/,/, /g'`
        fi
        if [ "$5" == "find" ] ; then
           command=permission-find
        else
          command=permission-show
        fi


	tmpfile=/tmp/permissionshow.out.??
	rc=0
	
       if [ "$allOrRaw" == "all" ] ; then
	   rlLog "Executing: ipa $command --all $permissionName $showrights"
   	   ipa $command --all $permissionName  $showrights > $tmpfile
       else
	   rlLog "Executing: ipa $command --all --raw $permissionName"
	   ipa $command --all --raw $permissionName > $tmpfile
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



#######################################################################
# findPermissionByOption Usage:
#       findPermissionByOption <option> <value> <space_delimited_list_of_expected_rules>
######################################################################

findPermissionByOption()
{
   option=$1
   shift
   value=$1
   shift
   allOrRaw="--$1"
   shift
   rc=0

   flag="--$option"
   tmpfile=/tmp/findpermissionbyoption.txt
   rm -rf $tmpfile

   rlLog "Executing: ipa permission-find $flag=$value $allOrRaw"
   ipa permission-find $flag=$value $allOrRaw > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	results=`cat $tmpfile | grep "Permission name"`
        if [ `cat $tmpfile | grep "Permission name" | wc -l` -gt  ${#-2} ] ; then
          rlLog "ERROR: Exceeded number of expected permissions"
          rc=1
        else
            while [ "$#" -gt "0" ]
            do
                permissions=$1
	        rlLog "Searching for permissions: $permissions"
		echo $results | grep "$permissions"
		if [ $? -eq 0 ] ; then
			rlLog "Permission $permissions found as expected."
		else
			rlLog "WARNING: Permission $permissions was not found."
			rc=1
		fi
                shift
            done
        fi
   else
   	rlLog "WARNING: permission-find command failed."
   fi

   return $rc
}


findPermissionByMultipleOptions()
{
   numberOfOptions=$1
   shift
   partOfCommand=""
   limit=${#-($numberOfOptions*2)}
   for ((i=1; i<=$numberOfOptions; i++)); do
      partOfCommand=$partOfCommand" --$1=$2"
      if [ "$1" == "sizelimit" ] ; then
         limit=$2
      fi
     shift
     shift
   done
   tmpfile=/tmp/findpermissionbyoption.txt
   rm -rf $tmpfile

   rlLog "Executing: ipa permissionrule-find $partOfCommand" 
   ipa permission-find $partOfCommand > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	results=`cat $tmpfile | grep "Permission name"`
        permissionsFound=`cat $tmpfile | grep "Permission name" | wc -l`
        if [ $permissionsFound -gt  $limit ] ; then
          rlLog "ERROR: Exceeded number of expected permissions"
          rlLog "Expected: $limit; Found: $permissionsFound"
          rc=1
        else
       	  echo $partOfCommand | grep "sizelimit"
  	  if [ $? -eq 0 ] ; then
	     rlLog "Number of Permissions found as expected."
	  else
            while [ "$#" -gt "0" ]
            do
                permissions=$1
	        rlLog "Searching for permissions: $permissions"
		echo $results | grep "$permissions"
		if [ $? -eq 0 ] ; then
			rlLog "Permission $permissions found as expected."
		else
			rlLog "WARNING: Permission $permissions was not found."
			rc=1
		fi
                shift
            done
	  fi
        fi
   else
   	rlLog "WARNING: permission-find command failed."
   fi

   return $rc

}



verifyPermissionAttrFindUsingOptions()
{
   attribute="$1:"
   if [ "$attribute" == "dn:" -o "$attribute" == "Subtree:" -o "$attribute" == "attributelevelrights:" ] ; then
     value=$2
     if [ "$attribute" == "attributelevelrights:" ] ; then
        showrights="--rights"
     else
        showrights=""
     fi
   else
     value=`echo $2 | sed 's/,/, /g'`
   fi
    
    tmpfile=/tmp/findpermissionbyoption.txt
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
