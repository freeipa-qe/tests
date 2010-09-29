#!/bin/sh
. /dev/shm/env.sh

########################################################################
#  GROUP CLI SHARED LIBRARY
#######################################################################
# Includes:
#       addGroup
#	addNonPosixGroup
#       findGroup
#       modifyGroup
#       verifyGroupAttr
#       verifyGroupClasses
#	addGroupMembers
#	removeGroupMembers
#	verifyGroupMember
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
# addNonPosixGroup Usage:
#       addNonPosixGroup <description> <groupname>
# Example:
#       addNonPosix Group "Idenity Management Quality Engineering" "IDM QE"
######################################################################
addNonPosixGroup()
{
   description=$1
   groupname=$2
   rc=0

        ipa group-add --nonposix --desc="$description" $groupname
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
#       removeGroupMembers <groups or users> <comma_separated_list_of_groups_or_users> groupname
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

#######################################################################
# verifyGroupMember Usage:
#       verifyGroupMember membername membertype groupname 
# example:
#       verifyGroupMember mdolphin user fish 
######################################################################

verifyGroupMember()
{
  member=$1
  membertype=$2
  mygroup=$3
  rc=0

  # construct memberDN
  if [[ $membertype == "user" ]] ; then
        member="uid=$member"
        memberDN="$member,cn=users,cn=accounts,dc=$RELM"
        rlLog "Verifying User Member: $memberDN"
  elif [[ $membertype == "group" ]] ; then
        member="cn=$member"
        memberDN="$member,cn=groups,cn=accounts,dc=$RELM"
        rlLog "Verifying Group Member: $memberDN"
  else
        rlLog "ERROR: unknown membertype: $membertype"
        rc=1
  fi

  # construct groupDN
  mygroup="cn=$mygroup"
  groupDN="$mygroup,cn=groups,cn=accounts,dc=$RELM"

  rlLog "Member DN: $memberDN"
  rlLog "Group DN: $groupDN"
  if [ $rc -eq 0 ] ; then
  	# verify member attribute for group
  	ldapsearch -x -h $MASTER -p 389 -D "cn=Directory Manager" -w $ROOTDNPWD -b "$groupDN" | grep "member:" > /tmp/member.out
  	cat /tmp/member.out | grep "$memberDN"
  	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: member: $memberDN not found for group $mygroup"
        	rc=2 
  	fi

  	# verify memberof attribute for the member

  	ldapsearch -x -h $MASTER -p 389 -D "cn=Directory Manager" -w $ROOTDNPWD -b "$memberDN" | grep "memberOf:" > /tmp/memberof.out
  	cat /tmp/memberof.out | grep "$groupDN"
  	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: memberOf: $groupDN not found for member $member"
        	let rc=$rc+1
  	fi

  	if [ $rc -eq 0 ] ; then
        	rlLog "member and memberOf attributes for group membership are as expected."
  	fi
  fi

  return $rc
}

#######################################################################
# verifyUPG Usage:
#       verifyManagedEntry username
# example:
#       verifyUPG username
######################################################################

verifyUPG()
{
  member=$1
  rc=0

  # construct memberDN
  memberdn="uid=$member"
  memberDN="$memberdn,cn=users,cn=accounts,dc=$RELM"
  rlLog "Verifying User Member: $memberDN"

  # construct groupDN
  groupdn="cn=$member"
  groupDN="$groupdn,cn=groups,cn=accounts,dc=$RELM"

  rlLog "User DN: $memberDN"
  rlLog "Group DN: $groupDN"

  # verify mepManagedEntry attribute for user
  ldapsearch -x -h $MASTER -p 389 -D "cn=Directory Manager" -w $ROOTDNPWD -b "$memberDN" | grep "mepManagedEntry:" > /tmp/mepManagedEntry.out
  cat /tmp/mepManagedEntry.out | grep "$groupDN"
  if [ $? -ne 0 ] ; then
        rlLog "ERROR: mepManagedEntry: $groupDN not found for group $member"
        rc=1
  fi

  # verify mepManagerBy attribute for the group

  ldapsearch -x -h $MASTER -p 389 -D "cn=Directory Manager" -w $ROOTDNPWD -b "$groupDN" | grep "mepManagedBy:" > /tmp/mepManagedBy.out
  cat /tmp/mepManagedBy.out | grep "$memberDN"
  if [ $? -ne 0 ] ; then
        rlLog "ERROR: mepManagedBy: $memberDN not found for member $member"
        rc=1
  fi

  # verify user's id number and upg's id number match
  ipa user-show --all $member > /tmp/showuser.out
  USERIDNUM=`cat /tmp/showuser.out | grep UID | cut -d ":" -f 2`
  USERIDNUM=`echo $USERIDNUM`
  rlLog " User's uidNumber is $USERIDNUM"
  verifyGroupAttr $member uidNumber $USERIDNUM
  if [ $? -ne 0 ] ; then
	rc=1
  else
	rlLog "User and Group member unique IDs match."
  fi

  return $rc
}


