#!/bin/sh

########################################################################
#  GROUP CLI SHARED LIBRARY
#######################################################################
# Includes:
#       addGroup
#	addPosixGroup
#       findGroup
#       modifyGroup
#       verifyGroupAttr
#       verifyGroupClasses
#	addGroupMembers
#	verifyGroupMembers
#	verifyUserMembers
#	detachGroup
#       deleteGroup
######################################################################
# Assumes:
#       For successful command exectution, administrative credentials
#       already exist.
#######################################################################

#######################################################################
# addGroup Usage:
#       addGroup <description> <groupname>
# Example:
#	addGroup "Idenity Management Quality Engineering" "IDM QE"
######################################################################

addGroup()
{
   description=$1
   groupname=$2
   rc=0
	rlLog "Executing: ipa group-add --desc=\"$description\" \"$groupname\""
        ipa group-add --desc="$description" $groupname
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "Adding new group \"$groupname\" failed."
        else
                rlLog "Adding new group \"$groupname\" successful."
        fi

   return $rc
}

#######################################################################
# addPosixGroup Usage:
#       addPosixGroup <description> <groupname>
# Example:
#       addPosix Group "Idenity Management Quality Engineering" "IDM QE"
######################################################################
addPosixGroup()
{
   description=$1
   groupname=$2
   rc=0

        ipa group-add --posix --desc="$description" $groupname
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "Adding new posix group \"$groupname\" failed."
        else
                rlLog "Adding new posix group \"$groupname\" successful."
        fi

   return $rc
}


#######################################################################
# findGroup Usage:
#       findGroup <groupname>
# example:
#       findGroup "IDM QE"
######################################################################

findGroup()
{
   mygroup=$1
   ipa group-find $mygroup
   rc=$?
   if [ $rc -eq 0 ] ; then
        rlLog "$mygroup was found."
        # check group
        result=`ipa group-find $mygroup`
        check=`echo $mygroup | tr "[A-Z]" "[a-z]"`
        echo $result | grep "Group name: $check"
        if [ $? -ne 0 ] ; then
                rlLog "ERROR: Group name not as expected."
                rc=1
        else
                rlLog "Group name is as expected."
        fi

   else
                rlLog "ERROR: Failed to add host. Return code: $rc"
   fi

   return $rc

}

#######################################################################
# modifyGroup Usage:
#       modifyGroup groupname attribute value
# example:
#       modifyGroup test desc "new description"
######################################################################

modifyGroup()
{

   mygroup=$1
   attribute=$2
   value=$3
   rc=0

   rlLog "Executing: ipa group-mod --$attribute=\"$value\" $mygroup"
   ipa group-mod --$attribute="$value" $mygroup
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Modifying group $mygroup failed."
   else
        rlLog "Modifying group $mygroup successful."
   fi
   return $rc
}

#######################################################################
# verifyGroupAttr Usage:
#       verifyGroupAttr groupname attribute value
# example:
#       verifyGroupAttr test desc "my description"
######################################################################

verifyGroupAttr()
{
   mygroup=$1
   attribute=$2
   value=$3
   rc=0

   attribute="$attribute:"
   tmpfile="/tmp/groupshow_$mygroup.out"
   delim=":"
   ipa group-show $mygroup
   rc=$?
   if [ $rc -eq 0 ] ; then
        result=`ipa group-show $mygroup`
        echo $result | grep "$attriute $value"
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "$mygroup verification failed: Value of $attribute is $value."
        else
                rlLog "Value of $attribute for $mygroup is as expected: $value."
        fi
   else
        rlLog "ERROR: ipa group-show command failed. Return code: $rc"
   fi

   return $rc
}

#######################################################################
# verifyGroupClasses Usage:
#       verifyGroupClasses groupname <ipa or upg or posix>
# example:
#       verifyGroupClasses test ipa
######################################################################

verifyGroupClasses()
{
   mygroup=$1
   grptype=$2
   tmpfile=/tmp/groupshow.out
   rc=0

   ipa group-show --all $mygroup > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	classes=`cat $tmpfile | grep objectclass`
	rlLog "DEBUG: $classes"
	if [ $grptype == "ipa" ] ; then
		rlLog "Group type is ipa"
		for item in top groupofnames nestedgroup ipausergroup ipaobject ; do
                	echo $classes | grep "$item"
                	if [ $? -ne 0 ] ; then
                        	rlLog "ERROR - objectclass $item was not returned with group-show --all"
                        	rc=1
                	else
                        	rlLog "objectclass $item was returned as expected with group-show --all"
                	fi
        	done
	elif [ $grptype == "upg" ] ; then
		rlLog "Group type is user private"
                for item in posixGroup mepManagedEntry top ; do
                        echo $classes | grep "$item"
                        if [ $? -ne 0 ] ; then
                                rlLog "ERROR - objectclass $item was not returned with group-show --all"
                                rc=1
                        else
                                rlLog "objectclass $item was returned as expected with group-show --all"
                        fi
                done	
	elif [ $grptype == "posix" ] ; then
		rlLog "Group type is posix"
		for item in top groupofnames nestedgroup ipausergroup ipaobject posixgroup ; do
                        echo $classes | grep "$item"
                        if [ $? -ne 0 ] ; then
                                rlLog "ERROR - objectclass $item was not returned with group-show --all"
                                rc=1
                        else
                                rlLog "objectclass $item was returned as expected with group-show --all"
                        fi
		done
	else
		rlLog "ERROR: Unknown Group Type."
		rc=1
	fi
   else
        rlLog "ERROR: Show group failed."
   fi

   return $rc
}

#######################################################################
# addGroupMembers Usage:
#       addGroupMembers <groups or users> <comma_separated_list_of_groups> groupname
# example:
#       addGroupMembers groups "animalkingdom,epcot" disneyworld
######################################################################

addGroupMembers()
{
  membertype=$1
  memberlist=$2
  mygroup=$3
  rc=0

  flag="--$membertype"

  rlLog "Executing: ipa group-add-member $flag=\"$memberlist\" $mygroup"
  ipa group-add-member $flag="$memberlist" $mygroup
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Adding $membertype to group $mygroup failed."
  else
        rlLog "Adding $membertype \"$memberlist\" to group $mygroup successful."
  fi

  return $rc
}

#######################################################################
# removeGroupMembers Usage:
#       removeGroupMembers <groups or users> <comma_separated_list_of_groups> groupname
# example:
#       removeGroupMembers groups "animalkingdom,epcot" disneyworld
######################################################################

removeGroupMembers()
{
  membertype=$1
  memberlist=$2
  mygroup=$3
  rc=0

  flag="--$membertype"

  rlLog "Executing: ipa group-remove-member $flag=\"$memberlist\" $mygroup"
  ipa group-remove-member $flag="$memberlist" $mygroup
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Removing $membertype from group $mygroup failed."
  else
        rlLog "Removing $membertype \"$memberlist\" from group $mygroup successful."
  fi

  return $rc
}


#######################################################################
# detachUPG Usage:
#       detachUPG userprivategroupname
# example:
#       deleteUPG test
######################################################################

detachUPG()
{
   upgroup=$1
   rc=0

   ipa group-detach $upgroup
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Detaching user private group $upgroup failed."
   else
        rlLog "User Private Group $upgroup detached successfully."
   fi
   return $rc
}

#######################################################################
# deleteGroup Usage:
#       deleteGroup groupname
# example:
#       deleteGroup test
######################################################################

deleteGroup()
{
   mygroup=$1
   rc=0

   ipa group-del $mygroup
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Deleting group $mygroup failed."
   else
        rlLog "Group $mygroup deleted successfully."
   fi
   return $rc
}
