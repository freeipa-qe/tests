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

modifyPermission()
{

   permissionName=$1
   attrToUpdate="--$2"
   value=$3
   rc=0

   rlLog "Excecuting: ipa permission-mod $attrToUpdate=$value $permissionName"
   ipa permission-mod $attrToUpdate=$value $permissionName
   rc=$?
   if [ $rc -ne 0 ] ; then
     rlLog "There was an error modifying $permissionName"
   else
     rlLog "Modified permission $permissionName successfully" 
   fi

   return $rc

}


addPrivilege()
{
   privilegeName=$1
   privilegeDesc=$2

   if [ `echo $#` > 3 ] ; then
     shift
     shift
     privilegeAttr=$1   
   else
     privilegeAttr=""  
   fi
   rc=0

   if [ -z "$privilegeAttr" ] ; then
     rlLog "Executing: ipa privilege-add \"$privilegeName\" --desc=\"$privilegeDesc\""
     ipa privilege-add "$privilegeName" --desc="$privilegeDesc"
   else 
     rlLog " Executing: ipa privilege-add \"$privilegeName\" --desc=\"$privilegeDesc\" $privilegeAttr "
     ipa privilege-add "$privilegeName" --desc="$privilegeDesc" $privilegeAttr 
   fi
   rc=$?
   if [ $rc -ne 0 ] ; then
     rlLog "There was an error adding $privilegeName"
   else
     rlLog "Added new privilege $privilegeName successfully" 
   fi

   return $rc
}

deletePrivilege()
{
    rlLog "Entering deletePrivilege with $1"
       privilegeName=$1
        rc=0

        rlLog "Executing: ipa privilege-del $privilegeName"
        ipa privilege-del "$privilegeName"
        rc=$?
        if [ $rc -ne 0 ]; then
            rlLog "There was an error deleting $privilegeName"
        else
            rlLog "Deleted privilege $privilegeName successfully"
        fi

        return $rc
}

addPermissionToPrivilege()
{
  rlLog "Entering addPermissionToPrivilege with $2"
  permissionList="$1"
  privilegeName="${2}"

  rc=0
  rlLog "Executing: ipa privilege-add-permission --permissions=\"$permissionList\" \"$privilegeName\""
  ipa privilege-add-permission --permissions="$permissionList" "$privilegeName"

  if [ $rc -ne 0 ] ; then
    rlLog "There was an error adding  $permissionList to $privilegeName"
  else
    rlLog "Added $permissionList to $privilegeName successfully"
  fi
}

removePermissionFromPrivilege()
{
  rlLog "Entering removePermissionFromPrivilege with $2"
  permissionList="$1"
  privilegeName="${2}"

  rc=0
  rlLog "Executing: ipa privilege-remove-permission --permissions=\"$permissionList\" \"$privilegeName\""
  ipa privilege-remove-permission --permissions="$permissionList" "$privilegeName"

  if [ $rc -ne 0 ] ; then
    rlLog "There was an error removing  $permissionList from $privilegeName"
  else
    rlLog "Removed $permissionList from $privilegeName successfully"
  fi
}

verifyPrivilegeAttr()
{

   privilegeName=$1
   attribute="$2:"
   value=$3
   tmpfile=/tmp/privilegeshow.out
   rc=0

   rlLog "NAMITA: value is $value"

   rlLog "Executing: ipa privilege-show --all \"$privilegeName\""
   ipa privilege-show --all "$privilegeName" > $tmpfile
   rc=$?
   if [ $rc -ne 0 ]; then
      rlLog "WARNING: ipa privilege-show command failed."
      return $rc
   fi
	
   cat $tmpfile | grep -i "$attribute $value"
   rc=$?
   if [ $rc -ne 0 ]; then
      rlLog "ERROR: ipa privilege \"$privilegeName\" verification failed:  Value of \"$attribute\" != \"$value\""
      rlLog "ERROR: ipa privilege \"$privilegeName\" verification failed:  it is `cat $tmpfile | grep \"$attribute\"`"
   else
      rlLog "ipa privilege \"$privilegeName\" Verification successful: Value of \"$attribute\" = \"$value\""
   fi

   return $rc
}


## TODO: Unable to modify to a value containing space
modifyPrivilege()
{

   privilegeName=$1
   shift
   cmd="" 
   while [ "$#" -gt "0" ]
   do
     attrToUpdate=" --$1"
     value=$2
     cmd=$cmd$attrToUpdate=$value
     shift
     shift
     rlLog "cmd: $cmd"
   done

   rc=0
   
   rlLog "Executing: ipa privilege-mod $cmd \"$privilegeName\" --all"
   ipa privilege-mod $cmd "$privilegeName" --all
   rc=$?
   if [ $rc -ne 0 ] ; then
     rlLog "There was an error modifying $privilegeName"
   else
     rlLog "Modified privilege $privilegeName successfully" 
   fi

   return $rc

}



addRole()
{
    rlLog "Entering addRole with $1 $2"
  roleName=$1
  roleDesc=$2

  rc=0
  rlLog "Executing: ipa role-add \"$roleName\" --desc=\"$roleDesc\""
  ipa role-add "$roleName" --desc="$roleDesc"
  if [ $rc -ne 0 ] ; then
    rlLog "There was an error adding $roleName"
  else
    rlLog "Added new role $roleName successfully"
  fi
 
  return $rc
}


addPrivilegeToRole()
{
    rlLog "Entering addPrivilegeToRole with $1 $2"

  privilegeList=$1
  roleName=$2

  rc=0
  rlLog "Executing: ipa role-add-privilege --privileges=\"$privilegeList\" \"$roleName\""
  ipa role-add-privilege --privileges="$privilegeList" "$roleName"

  if [ $rc -ne 0 ] ; then
    rlLog "There was an error adding  $privilegeList to $roleName"
  else
    rlLog "Added $privilegeList to $roleName successfully"
  fi

}


addMemberToRole()
{
    rlLog "Entering addMemberToRole with $1 $2"

   memberList=$1
   roleName=$2
   type="--$3"

   rc=0
   rlLog "Executing: ipa role-add-member $type=$memberList \"$roleName\""
   ipa role-add-member $type=$memberList "$roleName"

   if [ $rc -ne 0 ] ; then
     rlLog "There was an error adding  $memberList to $roleName"
   else
     rlLog "Added $memberList to $roleName successfully"
   fi
}


deleteRole()
{
    rlLog "Entering deleteRole with $1"
       roleName=$1
        rc=0

        rlLog "Executing: ipa role-del $roleName"
        ipa role-del "$roleName"
        rc=$?
        if [ $rc -ne 0 ]; then
            rlLog "There was an error deleting $roleName"
        else
            rlLog "Deleted role $roleName successfully"
        fi

        return $rc
}

modifyRole()
{
    rlLog "Entering modifyRole with $1 $2 $3"
       roleName="$1"
       attrToUpdate="--$2"
       value="$3"
       rc=0

       rlLog "Executing: ipa role-mod $attrToUpdate=$value $roleName"
       ipa role-mod "$attrToUpdate"="$value" "$roleName"
       rc=$?
       if [ $rc -ne 0 ]; then
           rlLog "There was an error modifying $roleName"
       else
           rlLog "Modified role $roleName successfully"
       fi

       return $rc
}
