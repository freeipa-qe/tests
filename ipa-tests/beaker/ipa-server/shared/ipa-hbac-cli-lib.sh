#!/bin/sh
. /opt/rhqa_ipa/env.sh

########################################################################
#  HOST CLI SHARED LIBRARY
#######################################################################
# Includes:
#	addHBACRule
#	findHBACRule
#	findHBACRuleByOption
#	disableHBACRule
#	enableHBACRule
#	verifyHBACStatus
#	addToHBAC
#	removeFromHBAC
#	verifyHBACAssoc
#	deleteHBACRule
#	addHBACService
#	modifyHBACService
#	findHBACService
#	verifyHBACService
#	verifyHBACServiceRAW
#	deleteHBACService
#	addHBACServiceGroup
#	modifyHBACServiceGroup
#	findHBACServiceGroup
#	verifyHBACServiceGroup
#	verifyHBACGroupMember
#	deleteHBACServiceGroup
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
   usercat=$1
   hostcat=$2
   srchostcat=$3
   servicecat=$4
   rulename=$5
   rc=0

	rlLog "Executing: ipa hbacrule-add --usercat=$usercat --hostcat=$hostcat --srchostcat=$srchostcat --servicecat=$servicecat $rulename"
	ipa hbacrule-add --usercat=$usercat --hostcat=$hostcat --srchostcat=$srchostcat --servicecat=$servicecat $rulename
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
   ipa hbacrule-find $rulename
   rc=$?
   if [ $rc -eq 0 ] ; then
	result=`ipa hbacrule-find $rulename`

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
# findHBACRuleByOption Usage:
#       findHBACRule <option> <value> <space_delimited_list_of_expected_rules>
######################################################################

findHBACRuleByOption()
{
   option=$1
   value=$2
   rules=$3
   rc=0

   flag="--$option"
   tmpfile=/tmp/findrulebyoption.txt
   rm -rf $tmpfile

   rlLog "Executing: ipa hbacrule-find $flag=$value"
   ipa hbacrule-find $flag=$value > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	rlLog "Searching for rules: $rules"
	for item in $rules ; do
		results=`cat $tmpfile | grep "Rule name"`
		echo $results | grep $item
		if [ $? -eq 0 ] ; then
			rlLog "Rule $item found as expected."
		else
			rlLog "WARNING: Rule $item was not found."
			rc=1
		fi
	done
   else
   	rlLog "WARNING: hbacrule-find command faied."
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

   ipa hbacrule-find $rulename > $tmpfile
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
	rlLog "WARNING: ipa hbacrule-find command failed."
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

   ipa hbacrule-disable $rulename
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

   ipa hbacrule-enable $rulename
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

   rlLog "EXECUTING: ipa hbacrule-add-$option --$type=\"$objects\" $rulename"
   ipa hbacrule-add-$option --$type="$objects" $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then 
	rlLog "WARNING: ipa hbacrule-add-$option failed to objects \"$objects\" of type $type to Rule $rulename"
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

   rlLog "EXECUTING: ipa hbacrule-remove-$option --$type=\"$objects\" $rulename"
   ipa hbacrule-remove-$option --$type="$objects" $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: ipa hbacrule-remove-$option failed to objects \"$objects\" of type $type to Rule $rulename"
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

  ipa hbacrule-mod --$option="$value" $rulename
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

  ipa hbacrule-show --all $rulename > $tmpfile
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
     rlLog "ERROR: ipa hbacrule-show command failed"
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

   ipa hbacrule-del $rulename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting hbac rule $rulename failed."
   else
        rlLog "HBAC rule $rulename deleted successfully."
   fi

   return $rc
}

#######################################################################
# addHBACService Usage:
#       addHBACService <servicename> <description>
######################################################################

addHBACService()
{
   servicename=$1
   description=$2
   rc=0

   ipa hbacsvc-add --desc="$description" $servicename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Adding hbac service $servicename failed."
   else
        rlLog "HBAC service $servicename added successfully."
   fi

   return $rc
}

#######################################################################
# modifyHBACService Usage:
#       modifyHBACService <servicename> <attribute> <value>
######################################################################

modifyHBACService()
{

   servicename=$1
   attribute=$2
   value=$3
   rc=0

   rlLog "Executing: ipa hbacsvc-mod --$attribute=\"$value\" $servicename"
   ipa hbacsvc-mod --$attribute="$value" $servicename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Modifying HBAC service $servicename failed."
   else
        rlLog "Modifying HBAC service $servicename successful."
   fi
   return $rc
}


############################################################################
# findHBACService Usage:
#	findHBACService <servicename>
############################################################################

findHBACService()
{
   servicename=$1
   rc=0

   tmpfile=/tmp/hbacsvcfind.out

   ipa hbacsvc-find $servicename >$tmpfile
   rc=$?

   if [ $rc -eq 0 ] ; then
	rlLog "HBAC service $servicename found."
   else
	rlLog "WARNING: HBAC service $servicename NOT found."
	rc=1
   fi

   return $rc
}

#######################################################################
# findHBACServiceByOption Usage:
#       findHBACServiceByOption <option> <value> <space_delimited_list_of_expected_services>
######################################################################

findHBACServiceByOption()
{
   option=$1
   value=$2
   services=$3
   rc=0

   flag="--$option"
   tmpfile=/tmp/findservicebyoption.txt

   rlLog "Executing: ipa hbacsvc-find $flag=$value"
   ipa hbacsvc-find $flag=$value > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        rlLog "Searching for services: $rules"
        for item in $services ; do
                results=`cat $tmpfile | grep "Service name"`
                echo $services | grep $item
                if [ $? -eq 0 ] ; then
                        rlLog "Service $item found as expected."
                else
                        rlLog "ERROR: Service $item was not found."
                        rc=1
                fi
        done
   else
        rlLog "WARNING: hbacsvc-find command faied."
   fi

   return $rc
}

#############################################################################
# verifyHBACService Usage
#   verifyHBACService <servicename> <attr> <value>
##############################################################################

verifyHBACService()
{
  servicename=$1
  attr=$2
  value=$3
  rc=0

  tmpfile=/tmp/hbacsvcshow.out

  ipa hbacsvc-show --all $servicename > $tmpfile
  rc=$?
  if [ $rc -eq 0 ] ; then
     attrs=`cat $tmpfile | grep "$attr" | cut -d ":" -f 2`
     echo $attrs | grep "$value"
     if [ $? -eq 0 ] ; then
        rlLog "$attr \"$value\" is associated with service $servicename"
     else
        rlLog "WARNING: $attr \"$value\" is NOT associated with service $servicename"
        rc=1
     fi
 else
     rlLog "ERROR: ipa hbacsvc-show command failed"
 fi

 return $rc
}


#############################################################################
# verifyHBACServiceRAW Usage
#   verifyHBACServiceRAW <servicename> <attr> <value>
##############################################################################

verifyHBACServiceRAW()
{
  servicename=$1
  attr=$2
  value=$3
  rc=0

  tmpfile=/tmp/hbacsvcshow.out

  # ipa hbacsvc-show --all $servicename > $tmpfile
  # The following change is because --all does not display the attribute name
  ipa hbacsvc-show --all --raw $servicename > $tmpfile
  rc=$?
  if [ $rc -eq 0 ] ; then
     attrs=`cat $tmpfile | grep "$attr" | cut -d ":" -f 2`
     echo $attrs | grep "$value"
     if [ $? -eq 0 ] ; then
        rlLog "$attr \"$value\" is associated with service $servicename"
     else
        rlLog "WARNING: $attr \"$value\" is NOT associated with service $servicename"
        rc=1
     fi
 else
     rlLog "ERROR: ipa hbacsvc-show command failed"
 fi

 return $rc
}

#######################################################################
# deleteHBACService Usage:
#       deleteHBACService <servicename>
######################################################################

deleteHBACService()
{
   servicename=$1
   rc=0

   ipa hbacsvc-del $servicename
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting hbac service $servicename failed."
   else
        rlLog "HBAC service $servicename deleted successfully."
   fi

   return $rc
}

#######################################################################
# addHBACServiceGroup Usage:
#       addHBACServiceGroup <groupname> <description>
######################################################################

addHBACServiceGroup()
{
   groupname=$1
   description=$2
   rc=0

   ipa hbacsvcgroup-add --desc="$description" "$groupname"
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Adding hbac service group $groupname failed."
   else
        rlLog "HBAC service group $groupname added successfully."
   fi

   return $rc
}

#######################################################################
# modifyHBACServiceGroup Usage:
#       modifyHBACServiceGroup <groupname> <attribute> <value>
######################################################################

modifyHBACServiceGroup()
{

   groupnanme=$1
   attribute=$2
   value=$3
   rc=0

   rlLog "Executing: ipa hbacsvcgroup-mod --$attribute=\"$value\" $groupname"
   ipa hbacsvcgroup-mod --$attribute="$value" $groupname
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Modifying HBAC service group $groupname failed."
   else
        rlLog "Modifying HBAC service group $groupname successful."
   fi
   return $rc
}

############################################################################
# findHBACServiceGroup Usage:
#	findHBACServiceGroup <groupname>
############################################################################

findHBACServiceGroup()
{
   groupname=$1
   rc=0

   tmpfile=/tmp/hbacsvcgrpfind.out

   ipa hbacsvcgroup-find "$groupname" > $tmpfile
   rc=$?

   if [ $rc -eq 0 ] ; then
        rlLog "HBAC service group \"$groupname\" found."
   else
        rlLog "WARNING: HBAC service group \"$groupname\" NOT found."
        rc=1
   fi

   return $rc
}

#############################################################################
# verifyHBACServiceGroup Usage
#   verifyHBACServiceGroup <servicename> <attr> <value>
##############################################################################

verifyHBACServiceGroup()
{
  groupname=$1
  attr=$2
  value=$3
  rc=0

  tmpfile=/tmp/hbacsvcgrpshow.out
  ipa hbacsvcgroup-show --all "$groupname" > $tmpfile
  rc=$?
  if [ $rc -eq 0 ] ; then
     attrs=`cat $tmpfile | grep "$attr" | cut -d ":" -f 2`
     echo $attrs | grep "$value"
     if [ $? -eq 0 ] ; then
        rlLog "$attr \"$value\" is associated with service group $groupname"
     else
        rlLog "WARNING: $attr \"$value\" is NOT associated with service group $groupname"
        rc=1
     fi
 else
     rlLog "ERROR: ipa hbacsvcgroup-show command failed"
 fi

 return $rc
}

#######################################################################
# addServiceGroupMembers Usage:
#       addServiceGroupMembers <comma_separated_list_of_services> <groupname>
######################################################################

addServiceGroupMembers()
{
  memberlist=$1
  mygroup=$2
  rc=0


  rlLog "Executing: ipa hbacsvcgroup-add-member --hbacsvcs=$memberlist $mygroup"
  rlRun "ipa hbacsvcgroup-add-member --hbacsvcs=$memberlist $mygroup"
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Adding \"$memberlist\" to HBAC service group $mygroup failed."
  else
        rlLog "Adding \"$memberlist\" to HBAC service group $mygroup successful."
  fi

  return $rc
}

#######################################################################
# removeServiceGroupMembers Usage:
#       removeServiceGroupMembers <comma_separated_list_of_services> <groupname>
######################################################################

removeServiceGroupMembers()
{
  memberlist=$1
  mygroup=$2
  rc=0

  rlLog "Executing: ipa hbacsvcgroup-remove-member --hbacsvcs=$memberlist $mygroup"
  rlRun "ipa hbacsvcgroup-remove-member --hbacsvcs=$memberlist $mygroup"
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Removing \"$memberlist\" from Service group \"$mygroup\" failed."
  else
        rlLog "Removing \"$memberlist\" from Service group \"$mygroup\" successful."
  fi

  return $rc
}

#######################################################################
# verifyHBACGroupMember Usage:
#       verifyGroupMember <membername> <groupname> 
######################################################################

verifyHBACGroupMember()
{
  member=$1
  mygroup=$2
  i=0

  # construct memberDN
  memberCN="cn=$member"
  memberDN="$memberCN,cn=hbacservices,cn=hbac,$BASEDN"
  rlLog "Verifying Service: $memberDN"

  # construct groupDN
  mygroupCN="cn=$mygroup"
  groupDN="$mygroupCN,cn=hbacservicegroups,cn=hbac,$BASEDN"
  rlLog "Verifying Service Group: $groupDN"

  # verify member attribute for group
  /usr/bin/ldapsearch -x -h $MASTER -p 389 -D "$ROOTDN" -w $ROOTDNPWD -b "$groupDN" | grep "member:" > /tmp/member.out
  cat /tmp/member.out | grep "$memberDN"
  if [ $? -ne 0 ] ; then
  	rlLog "WARNING: member: $memberDN not found for group $mygroup"
        let i=$i+1
  else
	rlLog "member: $memberDN found for group $mygroup" 
  fi

  # verify memberof attribute for the member
  /usr/bin/ldapsearch -x -h $MASTER -p 389 -D "cn=Directory Manager" -w $ROOTDNPWD -b "$memberDN" | grep "memberOf:" > /tmp/memberof.out
  cat /tmp/memberof.out | grep "$groupDN"
  if [ $? -ne 0 ] ; then
  	rlLog "WARNING: memberOf: $groupDN not found for member $member"
        let i=$i+1
  else
	rlLog "memberOf: $groupDN found for member $member"
  fi

  # verify show all for member
  verifyHBACServiceRAW $member memberof $groupDN
  rc=$?
  if [ $rc -eq 0 ] ; then
	rlLog "show --all --raw for service: $member is memberof $mygroup."
  else
	rlLog "WARNING: show --all --raw for service: $member is NOT a member of $mygroup."
	let i=$i+1
  fi

  # verify show all for group
  verifyHBACServiceGroup $mygroup "Member HBAC service" $member
  rc=$?
  if [ $rc -eq 0 ] ; then
        rlLog "show --all for service group: $mygroup has member $member."
  else
        rlLog "WARNING: show --all for service group: $mygroup does NOT have member of $member."
        let i=$i+1
  fi

  return $i
}

#######################################################################
# deleteHBACServiceGroup Usage:
#       deleteHBACServiceGroup <groupname>
######################################################################

deleteHBACServiceGroup()
{
   groupname=$1
   rc=0

   ipa hbacsvcgroup-del "$groupname"
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting hbac service group $groupname failed."
   else
        rlLog "HBAC service group $groupname deleted successfully."
   fi

   return $rc
}

