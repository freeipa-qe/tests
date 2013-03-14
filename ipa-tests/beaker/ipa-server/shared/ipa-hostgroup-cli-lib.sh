#!/bin/sh
. /opt/rhqa_ipa/env.sh

########################################################################
#  HOSTGROUP CLI SHARED LIBRARY
#######################################################################
# Includes:
#       addHostGroup
#       findHostGroup
#       modifyHostGroup
#       verifyHostGroupAttr
#       showHostGroup
#	addHostGroupMembers
#	removeHostGroupMembers
#	verifyHostGroupMember
#       deleteHostGroup
#	getNumberOfHostGroups
######################################################################
# Assumes:
#       For successful command exectution, administrative credentials
#       already exist.
#######################################################################

#######################################################################
# addHostGroup Usage:
#       addHostGroup <description> <groupname>
######################################################################

addHostGroup()
{
   description=$1
   groupname=$2
   rc=0
	rlLog "Executing: ipa group-add --desc=\"$description\" \"$groupname\""
        ipa hostgroup-add --desc="$description" "$groupname"
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "WARNING: Adding new Host Group \"$groupname\" failed."
        else
                rlLog "Adding new Host Group \"$groupname\" successful."
        fi

   return $rc
}

#######################################################################
# findHostGroup Usage:
#       findHostGroup <groupname> <description>
######################################################################

findHostGroup()
{
   mygroup=$1
   description=$2
   tmpfile=/tmp/findhostgroup.out

   ipa hostgroup-find "$mygroup" > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        # check group
        cat $tmpfile | grep "Host-group: $mygroup"
        if [ $? -ne 0 ] ; then
                rlLog "ERROR: Host Group name not as expected."
                rc=1
        else
                rlLog "Host Group name is as expected."
        fi

        cat $tmpfile | grep "Description: $mygroup"
        if [ $? -ne 0 ] ; then
                rlLog "ERROR: Host Group description not as expected."
                rc=1
        else
                rlLog "Host Group description is as expected."
        fi

   else
                rlLog "WARNING: Failed to find host."
   fi

   return $rc

}

#######################################################################
# modifyHostGroup Usage:
#       modifyHostGroup <groupname> <attribute> <value>
######################################################################

modifyHostGroup()
{

   mygroup=$1
   attribute=$2
   value=$3
   rc=0

   #rlLog "Executing: ipa hostgroup-mod --$attribute=\"$value\" \"$mygroup\""
   ipa hostgroup-mod --$attribute="$value" "$mygroup"
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Modifying host group $mygroup failed."
	rc=1
   else
        rlLog "Modifying host group $mygroup successful."
   fi

   return $rc
}

#######################################################################
# verifyHostGroupAttr Usage:
#       verifyHostGroupAttr <groupname> <attribute> <value>
######################################################################

verifyHostGroupAttr()
{
   mygroup=$1
   attribute=$2
   value=$3
   rc=0

   attribute="$attribute:"
   tmpfile="/tmp/hostgroupshow.out"
   ipa hostgroup-show "$mygroup" > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        cat $tmpfile | grep "$attriute $value"
        if [ $? -ne 0 ] ; then
                rlLog "ERROR: $mygroup verification failed: Value of $attribute is $value."
		rc=1
        else
                rlLog "Value of $attribute for $mygroup is as expected: $value."
        fi
   else
        rlLog "WARNING: ipa hostgroup-show command failed."
   fi

   return $rc
}

#######################################################################
# showHostGroup Usage:
#       showHostGroup <groupname>
######################################################################

showHostGroup()
{
   mygroup=$1
   tmpfile=/tmp/groupshow.out
   rc=0

   ipa hostgroup-show --all "$mygroup" > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	classes=`cat $tmpfile | grep objectclass`
	for item in ipaobject ipahostgroup nestedGroup groupOfNames top ; do
                echo $classes | grep "$item"
                if [ $? -ne 0 ] ; then
                        rlLog "ERROR - objectclass $item was not returned with hostgroup-show --all"
                        rc=1
                else
                        rlLog "objectclass $item was returned as expected with hostgroup-show --all"
                fi
        done
   else
        rlLog "WARNING: Show host group failed."
   fi

   return $rc
}

#######################################################################
# addHostGroupMembers Usage:
#       addHostGroupMembers <groups or hosts> <comma_separated_list_of_groups> <groupname>
######################################################################

addHostGroupMembers()
{
  membertype=$1
  memberlist=$2
  mygroup=$3
  rc=0

  flag="--$membertype"

  rlLog "Executing: ipa hostgroup-add-member $flag=\"$memberlist\" \"$mygroup\""
  ipa hostgroup-add-member $flag="$memberlist" "$mygroup"
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Adding $membertype to host group $mygroup failed."
  else
        rlLog "Adding $membertype \"$memberlist\" to host group $mygroup successful."
  fi

  return $rc
}

#######################################################################
# removeHostGroupMembers Usage:
#       removeHostGroupMembers <groups or users> <comma_separated_list_of_groups_or_users> <groupname>
######################################################################

removeHostGroupMembers()
{
  membertype=$1
  memberlist=$2
  mygroup=$3
  rc=0

  flag="--$membertype"

  #rlLog "Executing: ipa hostgroup-remove-member $flag=\"$memberlist\" \"$mygroup\""
  ipa hostgroup-remove-member $flag="$memberlist" "$mygroup"
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Removing $membertype from group \"$mygroup\" failed."
  else
        rlLog "Removing $membertype \"$memberlist\" from group \"$mygroup\" successful."
  fi

  return $rc
}

#######################################################################
# deleteHostGroup Usage:
#       deleteHostGroup <groupname>
######################################################################

deleteHostGroup()
{
   mygroup=$1
   rc=0

   ipa hostgroup-del "$mygroup"
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting host group $mygroup failed."
   else
        rlLog "Host group $mygroup deleted successfully."
   fi
   return $rc
}

#######################################################################
# verifyHostGroupMember Usage:
#       verifyHostGroupMember <membername> <membertype> <groupname> 
######################################################################

verifyHostGroupMember()
{
  member=$1
  membertype=$2
  group=$3
  rc=0

  # construct groupDN
  mygroup="cn=$group"
  groupDN="$mygroup,cn=hostgroups,cn=accounts,$BASEDN"

  # construct memberDN and verify host group returned with find and show
  if [[ $membertype == "host" ]] ; then
        mymember="fqdn=$member"
        memberDN="$mymember,cn=computers,cn=accounts,$BASEDN"

        ipa hostgroup-find "$group" > /tmp/findhostgroup.out
        members=`cat /tmp/findhostgroup.out | grep "Member hosts:" | cut -d ":" -f2`
        echo $members | grep "$member"
        if [ $? -eq 0 ] ; then
        	rlLog "$membertype \"$member\" returned with hostgroup-find"
        else
        	rlLog "WARNING: $membertype \"$member\" not returned with hostgroup-find"
                let rc=$rc+1
        fi

	ipa hostgroup-show --all "$group" > /tmp/showhostgroup.out
        members=`cat /tmp/showhostgroup.out | grep "Member hosts:" | cut -d ":" -f2`
	rlLog "$members"
	rlLog "Looking for $member"
        echo $members | grep "$member"
        if [ $? -eq 0 ] ; then
                rlLog "$membertype \"$member\" returned with hostgroup-show"
        else
                rlLog "WARNING: $membertype \"$member\" not returned with hostgroup-show"
                let rc=$rc+1
        fi

  elif [[ $membertype == "hostgroup" ]] ; then
        mymember="cn=$member"
        memberDN="$mymember,cn=hostgroups,cn=accounts,$BASEDN"

	ipa hostgroup-find "$member" > /tmp/findhostgroup.out
        members=`cat /tmp/findhostgroup.out | grep "Member of host-groups:" | cut -d ":" -f2`
        echo $members | grep "$group"
        if [ $? -eq 0 ] ; then
                rlLog "$membertype "$group" returned with hostgroup-find on $member"
        else
                rlLog "WARNING: $membertype \"$group\" not returned with hostgroup-find on $member"
                let rc=$rc+1
        fi

        ipa hostgroup-show --all "$group" > /tmp/showhostgroup.out
        members=`cat /tmp/showhostgroup.out | grep "Member host-groups:" | cut -d ":" -f2`
        echo $members | grep "$member"
        if [ $? -eq 0 ] ; then
                rlLog "$membertype \"$member\" returned with hostgroup-show"
        else
                rlLog "WARNING: $membertype \"$member\" not returned with hostgroup-show"
                let rc=$rc+1
        fi
  else
        rlLog "ERROR: unknown membertype: $membertype"
        rc=99
  fi

  rlLog "Member DN: $memberDN"
  rlLog "Host Group DN: $groupDN"
  # verify member attribute for group
  /usr/bin/ldapsearch -x -h $MASTER -p 389 -D "$ROOTDN" -w $ROOTDNPWD -b "$groupDN" | grep "member:" > /tmp/member.out
   cat /tmp/member.out | grep "$member"
  if [ $? -ne 0 ] ; then
  	rlLog "WARNING: member: $member not found for group $group"	
	let rc=$rc+1
  else
        rlLog "member attributes for host group membership is as expected."
  fi

  # verify memberof attribute for the member

  /usr/bin/ldapsearch -x -h $MASTER -p 389 -D "$ROOTDN" -w $ROOTDNPWD -b "$memberDN" | grep "memberOf:" > /tmp/memberof.out
  cat /tmp/memberof.out | grep "$group"
  if [ $? -ne 0 ] ; then
  	rlLog "WARNING: memberOf: $group not found for member $member"
        let rc=$rc+1
  else
        rlLog "memberOf attributes for host group membership is as expected."
  fi

  return $rc
}

#######################################################################
# getNumberOfHostGroups Usage:
#       getNumberOfHostGroups
######################################################################
getNumberOfHostGroups()
{

   rc=0
   tmpfile=/tmp/hostgroups.out

   ipa hostgroup-find > $tmpfile
   rc=$?
   result=`cat $tmpfile | grep "Number of entries returned"`
   number=`echo $result | cut -d " " -f 5`

   echo $number
   return $rc
}

