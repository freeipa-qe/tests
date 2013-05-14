#!/bin/sh
    
########################################################################
#  PERMISSION, PRIVILEGE, ROLE CLI SHARED LIBRARY
#######################################################################
# Includes:
#      addPermission
#      deletePermission
#      verifyPermissionAttr
#      findPermissionByOption
#      findPermissionByMultipleOptions
#      verifyPermissionAttrFindUsingOptions
#      modifyPermission
#
#      addPrivilege
#      deletePrivilege
#      addPermissionToPrivilege
#      removePermissionFromPrivilege
#      verifyPrivilegeAttr
#      modifyPrivilege
#
#      addRole
#      addPrivilegeToRole
#      removePrivilegeFromRole
#      addMemberToRole
#      removeMemberFromRole
#      deleteRole
#      modifyRole
#      verifyRoleAttr
#      findRole

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
#    if [ `echo $#` > 3 ] ; then
#       permissionAttr=$4   
#       permissionOtherParam=$5   
#    else
#       permissionAttr=""  
#       permissionOtherParam=""  
#    fi
    permissionName=$1
    shift
    restOfCommand=""
   while [ "$#" -gt "0" ]
   do
     restOfCommand=$restOfCommand$1
     restOfCommand=$restOfCommand" "
     shift
     rlLog "cmd: $restOfCommand"
   done
#    permissionRights=$2
#    permissionTarget=$3
    rc=0

        if [ -z \"$permissionAttr\" ] ; then
           rlLog "ipa permission-add $permissionName $permissionRights $permissionTarget"
            ipa permission-add $permissionName $permissionRights $permissionTarget
        else 
#           rlLog " Executing: ipa permission-add $permissionName \"$permissionRights\" $permissionTarget $permissionAttr $permissionOtherParam"
#           ipa permission-add $permissionName $permissionRights $permissionTarget $permissionAttr $permissionOtherParam 
            rlLog " Executing: ipa permission-add $permissionName $restOfCommand" 
            ipa permission-add $permissionName $restOfCommand 
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


	tmpfile=$TmpDir/permissionshow.out
	rc=0
	
       if [ "$allOrRaw" == "all" ] ; then
	   rlLog "Executing: ipa $command --all \"$permissionName\" $showrights > $tmpfile"
   	   ipa $command --all "$permissionName"  $showrights > $tmpfile
       else
	   rlLog "Executing: ipa $command --all --raw \"$permissionName\" > $tmpfile"
	   ipa $command --all --raw "$permissionName" > $tmpfile
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
#       findPermissionByOption <option> <value> <space_delimited_list_of_expected_perms>
######################################################################

findPermissionByOption()
{
   value=$1
   shift
   if [ "$1" == "raw" ] ; then
     allOrRaw="--all --$1"
   else
     allOrRaw="--$1"
   fi
   shift
   rc=0

#   flag="--$option"
   tmpfile=$TmpDir/findpermissionbyoption.txt
   rm -rf $tmpfile

   rlLog "Executing: ipa permission-find $value $allOrRaw"
   ipa permission-find $value $allOrRaw > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        if [ "$allOrRaw" == "--all" ] ; then
   	   results=`cat $tmpfile | grep "Permission name"`
         else
           results=`cat $tmpfile | grep "cn:"`
         fi

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


#######################################################################################################
# findPermissionByMultipleOptions Usage:
#       findPermissionByMultipleOptions <numberOfOptions> <option1> <value1> <option2> <value2> .....
######################################################################################################
findPermissionByMultipleOptions()
{
   numberOfOptions=$1
   shift
   partOfCommand=""
   limit=${#-($numberOfOptions*2)}
   for ((i=1; i<=$numberOfOptions; i++)); do
      partOfCommand=$partOfCommand" $1"
#      if [ "$1" == "--sizelimit" ] ; then
#         limit=$2
#         shift
#      fi
     shift
   done
   tmpfile=$TmpDir/findpermissionbyoption.txt
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


#######################################################################
# After finding permission, verify the attributes found.
# verifyPermissionAttrFindUsingOptions Usage:
#       verifyPermissionAttrFindUsingOptions <attribute> <value>
#######################################################################

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
    
    tmpfile=$TmpDir/findpermissionbyoption.txt
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
# modifyPermission Usage:
#       modifyPermission <permissionName> <attrToUpdate> <value>
#######################################################################
modifyPermission()
{

   permissionName="$1"
  # attrToUpdate="--$2"
   value="$2"
   if [ `echo $#` = 3 ] ; then
      restOfCommand="$3"
   else
      restOfCommand=""
   fi
   rc=0

   rlLog "Executing: ipa permission-mod $permissionName $value $restOfCommand"
   ipa permission-mod "$permissionName" $value $restOfCommand
   rc=$?
   if [ $rc -ne 0 ] ; then
     rlLog "There was an error modifying $permissionName"
   else
     rlLog "Modified permission $permissionName successfully" 
   fi

   return $rc

}


############################################################
# addPrivilege Usage:
#       addPrivilege <privilegeName> <privilegeDesc> <attr>
############################################################
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

############################################################
# deletePrivilege Usage:
#       deletePrivilege <privilegeName> 
############################################################
deletePrivilege()
{
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

############################################################
# addPermissionToPrivilege Usage:
#       addPermissionToPrivilege <permission list> <privilegeName> 
############################################################
addPermissionToPrivilege()
{
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

############################################################
# removePermissionFromPrivilege Usage:
#       removePermissionFromPrivilege <permission list> <privilegeName> 
############################################################
removePermissionFromPrivilege()
{
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

##############################################################################
# verifyPrivilegeAttr Usage:
#       verifyPrivilegeAttr <privilegeName> <attr to verify> <expected value>  
##############################################################################
verifyPrivilegeAttr()
{

   privilegeName=$1
   attribute="$2:"
   value=$3
   tmpfile=$TmpDir/privilegeshow.out
   rc=0

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


#######################################################################################################
# modifyPrivilege Usage:
#       modifyPrivilege <privilegeName> <attr to modify> <new value>  <attr to modify> <new value> .... 
#######################################################################################################
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

################################################################################
# findPrivilege Usage:
#       findPrivilege <criteria> <attr to validate> <expected value> <expected result msg> 
#       findPrivilege <criteria> <expected result msg> 
#       findPrivilege <criteria> <attr to validate> <expected value> <expected result msg> <all or raw>
################################################################################
findPrivilege()
{

   criteria="$1"
   if [ `echo $#` = 5 ] ; then 
      attribute="$2:"
      value=$3
      resultMsg=$4
   else
      attribute=""
      value=""
      resultMsg=$2
   fi
   if [ `echo $#` = 5 ] ; then
     if [ "$5" == "raw" ] ; then
       allOrRaw="--all --$5"
     else
       allOrRaw="--$5"
     fi
   else
     allOrRaw="--all"
   fi

   tmpfile=$TmpDir/privilegefind.out
   rc=0

   rlLog "Executing: ipa privilege-find $allOrRaw \"$criteria\" > $tmpfile"
   ipa privilege-find $allOrRaw "$criteria" > $tmpfile
   rc=$?

   if [ $rc -ne 0 ]; then
      rlLog "WARNING: ipa privilege-find command failed."
      return $rc
   fi

   if [ -n "$attribute" ] ; then
     cat $tmpfile | grep -i "$attribute $value"
     rc=$?
     if [ $rc -ne 0 ]; then
        rlLog "ERROR: ipa privilege verification failed:  Value of \"$attribute\" != \"$value\""
        rlLog "ERROR: ipa privilege verification failed:  it is `cat $tmpfile | grep \"$attribute\"`"
     else
        rlLog "ipa privilege Verification successful: Value of \"$attribute\" = \"$value\""
        if [ -n "$resultMsg" ] ; then
          cat $tmpfile | grep -i "$resultMsg"
          rc=$?
          if [ $rc -ne 0 ]; then
             rlLog "ERROR: ipa privilege verification failed:  \"$resultMsg not found"
          else
            rlLog "ipa privilege Verification successful: \"$resultMsg found" 
          fi
        fi
     fi
   else
        cat $tmpfile | grep -i "$resultMsg"
        rc=$?
        if [ $rc -ne 0 ]; then
           rlLog "ERROR: ipa privilege verification failed:  \"$resultMsg not found"
        else
           rlLog "ipa privilege Verification successful: \"$resultMsg found" 
        fi
   fi
   return $rc

}


##############################################
# addRole Usage:
#       addRole <roleName> <roleDesc>
#       addRole <roleName> <roleDesc> <attr>
##############################################
addRole()
{
  roleName=$1
  roleDesc=$2
  attr=""
  if [ `echo $#` > 3 ] ; then
    attr=$3   
  fi

   rc=0

   if [ -z "$attr" ] ; then
     rlLog "Executing: ipa role-add \"$roleName\" --desc=\"$roleDesc\""
     ipa role-add "$roleName" --desc="$roleDesc"
   else 
     rlLog " Executing: ipa role-add \"$roleName\" --desc=\"$roleDesc\" $attr "
     ipa role-add "$roleName" --desc="$roleDesc" $attr
   fi
  if [ $rc -ne 0 ] ; then
    rlLog "There was an error adding $roleName"
  else
    rlLog "Added new role $roleName successfully"
  fi
 
  return $rc
}


##################################################################
# addPrivilegeToRole Usage:
#       addPrivilegeToRole <privilegeList> <roleName>
#       addPrivilegeToRole <privilegeList> <roleName> <all or raw>
##################################################################
addPrivilegeToRole()
{
  privilegeList=$1
  roleName=$2
   if [ `echo $#` = 3 ] ; then
     if [ "$3" == "raw" ] ; then
       allOrRaw="--all --$3"
     else
       allOrRaw="--$3"
     fi
   else
     allOrRaw=""
   fi

  rc=0
  rlLog "Executing: ipa role-add-privilege --privileges=\"$privilegeList\" \"$roleName\" $allOrRaw"
  ipa role-add-privilege --privileges="$privilegeList" "$roleName" $allOrRaw

  if [ $rc -ne 0 ] ; then
    rlLog "There was an error adding  $privilegeList to $roleName"
  else
    rlLog "Added $privilegeList to $roleName successfully"
  fi

}

##################################################################
# removePrivilegeFromRole Usage:
#       removePrivilegeFromRole <privilegeList> <roleName>
#       removePrivilegeFromRole <privilegeList> <roleName> <all or raw>
##################################################################
removePrivilegeFromRole()
{
   privilegeList=$1
   roleName=$2
   if [ `echo $#` = 3 ] ; then
     if [ "$3" == "raw" ] ; then
       allOrRaw="--all --$3"
     else
       allOrRaw="--$3"
     fi
   else
     allOrRaw=""
   fi
 
   rc=0
   rlLog "Executing: ipa role-remove-member --privileges=\"$privilegeList\" \"$roleName\" $allOrRaw"
   ipa role-remove-privilege --privileges="$privilegeList" "$roleName" $allOrRaw
 
   if [ $rc -ne 0 ] ; then
     rlLog "There was an error removing  $privilegeList from $roleName"
   else
     rlLog "Removed $privilegeList from $roleName successfully"
   fi


}

##########################################################################################
# addMemberToRole Usage:
#       addMemberToRole <roleName> <type> <memberList>
#       addMemberToRole <roleName> <type> <memberList> <all or raw>
#       addMemberToRole <roleName> <type> <memberList> <all or raw> <type <memberlist>
##########################################################################################
addMemberToRole()
{
   roleName=$1
   type="--$2"
   memberList=$3
   allOrRaw="--$4"
   if [ `echo $#` -gt 4 ] ; then
    type2="--$5"
    memberList2=$6
  else
    type2=""
    memberList2=""
  fi

   rc=0
   if [ -z "$type2" ] ; then
     rlLog "Executing: ipa role-add-member $type=$memberList \"$roleName\" $allOrRaw"
     ipa role-add-member $type=$memberList "$roleName" $allOrRaw
   else
     rlLog "Executing: ipa role-add-member $type=$memberList \"$roleName\" $allOrRaw $type2=$memberList2"
     ipa role-add-member $type=$memberList "$roleName" $allOrRaw $type2=$memberList2
   fi

   if [ $rc -ne 0 ] ; then
     rlLog "There was an error adding  $memberList to $roleName"
   else
     rlLog "Added $memberList to $roleName successfully"
   fi
}

##########################################################################################
# removeMemberFromRole Usage:
#       removeMemberFromRole <memberList> <roleName> <type>
#       removeMemberFromRole <memberList> <roleName> <type> <all or raw>
##########################################################################################
removeMemberFromRole()
{
   memberList=$1
   roleName=$2
   type="--$3"
   if [ `echo $#` = 4 ] ; then
     if [ "$4" == "raw" ] ; then
       allOrRaw="--all --$4"
     else
       allOrRaw="--$4"
     fi
   else
     allOrRaw=""
   fi

   rc=0
   rlLog "Executing: ipa role-remove-member $type=\"$memberList\" \"$roleName\" $allOrRaw"
   ipa role-remove-member $type="$memberList" "$roleName" $allOrRaw

   if [ $rc -ne 0 ] ; then
     rlLog "There was an error removing  $memberList from $roleName"
   else
     rlLog "Removed $memberList from $roleName successfully"
   fi
}


################################
# deleteRole Usage:
#       deleteRole <roleName>
###############################
deleteRole()
{
       roleName=$1
        rc=0

        rlLog "Executing: ipa role-del \"$roleName\""
        ipa role-del "$roleName"
        rc=$?
        if [ $rc -ne 0 ]; then
            rlLog "There was an error deleting $roleName"
        else
            rlLog "Deleted role $roleName successfully"
        fi

        return $rc
}

########################################################################
# modifyRole Usage:
#       modifyRole <roleName> <attr to modify> <new value>
#       modifyRole <roleName> <attr to modify> <new value> <all or raw>
#######################################################################
modifyRole()
{
       roleName="$1"
       attrToUpdate="--$2"
       value="$3"
    if [ `echo $#` = 4 ] ; then
     if [ "$4" == "raw" -o "$4" == "rights" ] ; then
       allOrRaw="--all --$4"
     else
       allOrRaw="--$4"
     fi
    else
     allOrRaw="--all"
    fi

       rc=0

       rlLog "Executing: ipa role-mod $attrToUpdate=$value $roleName $allOrRaw"
       ipa role-mod "$attrToUpdate"="$value" "$roleName" $allOrRaw
       rc=$?
       if [ $rc -ne 0 ]; then
           rlLog "There was an error modifying $roleName"
       else
           rlLog "Modified role $roleName successfully"
       fi

       return $rc
}

################################################################################
# verifyRoleAttr Usage:
#       verifyRoleAttr <roleName> <attr to verify> <expected value>
#       verifyRoleAttr <roleName> <attr to verify> <expected value> <all or raw>
################################################################################
verifyRoleAttr()
{

   roleName=$1
   attribute="$2:"
   value=$3
    if [ `echo $#` = 4 ] ; then
     if [ "$4" == "raw" ] ; then
       allOrRaw="--all --$4"
     else
       allOrRaw="--$4"
     fi
   else
     allOrRaw="--all"
   fi
   tmpfile=$TmpDir/roleshow.out
   rc=0

   rlLog "Executing: ipa role-show $allOrRaw \"$roleName\""
   ipa role-show $allOrRaw "$roleName" > $tmpfile
   rc=$?
   if [ $rc -ne 0 ]; then
      rlLog "WARNING: ipa role-show command failed."
      return $rc
   fi
	
   cat $tmpfile | grep -i "$attribute $value"
   rc=$?
   if [ $rc -ne 0 ]; then
      rlLog "ERROR: ipa role \"$roleName\" verification failed:  Value of \"$attribute\" != \"$value\""
      rlLog "ERROR: ipa role \"$roleName\" verification failed:  it is `cat $tmpfile | grep \"$attribute\"`"
   else
      rlLog "ipa role \"$roleName\" Verification successful: Value of \"$attribute\" = \"$value\""
   fi

   return $rc
}

################################################################################
# findRole Usage:
#       findRole <criteria> <attr to validate> <expected value> <expected result msg> 
#       findRole <criteria> <expected result msg> 
#       findRole <criteria> <attr to validate> <expected value> <expected result msg> <all or raw>
################################################################################
findRole()
{

   criteria="$1"
   if [ `echo $#` = 5 ] ; then 
      attribute="$2:"
      value=$3
      resultMsg=$4
   else
      attribute=""
      value=""
      resultMsg=$2
   fi
   if [ `echo $#` = 5 ] ; then
     if [ "$5" == "raw" ] ; then
       allOrRaw="--all --$5"
     else
       allOrRaw="--$5"
     fi
   else
     allOrRaw="--all"
   fi

   tmpfile=$TmpDir/rolefind.out
   rc=0

   rlLog "Executing: ipa role-find $allOrRaw \"$criteria\" > $tmpfile"
   ipa role-find $allOrRaw "$criteria" > $tmpfile
   rc=$?

   if [ $rc -ne 0 ]; then
      rlLog "WARNING: ipa role-find command failed."
      return $rc
   fi

   if [ -n "$attribute" ] ; then
     cat $tmpfile | grep -i "$attribute $value"
     rc=$?
     if [ $rc -ne 0 ]; then
        rlLog "ERROR: ipa role verification failed:  Value of \"$attribute\" != \"$value\""
        rlLog "ERROR: ipa role verification failed:  it is `cat $tmpfile | grep \"$attribute\"`"
     else
        rlLog "ipa role Verification successful: Value of \"$attribute\" = \"$value\""
        if [ -n "$resultMsg" ] ; then
          cat $tmpfile | grep -i "$resultMsg"
          rc=$?
          if [ $rc -ne 0 ]; then
             rlLog "ERROR: ipa role verification failed:  \"$resultMsg not found"
          else
            rlLog "ipa role Verification successful: \"$resultMsg found" 
          fi
        fi
     fi
   else
        cat $tmpfile | grep -i "$resultMsg"
        rc=$?
        if [ $rc -ne 0 ]; then
           rlLog "ERROR: ipa role verification failed:  \"$resultMsg not found"
        else
           rlLog "ipa role Verification successful: \"$resultMsg found" 
        fi
   fi
   return $rc

}
