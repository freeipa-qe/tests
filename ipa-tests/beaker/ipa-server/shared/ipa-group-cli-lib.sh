#!/bin/sh

########################################################################
#  GROUP CLI SHARED LIBRARY
#######################################################################
# Includes:
#       addGroup
#       finGroup
#       modGroup
#       verifyGroupAttr
#       verifyGroupClasses
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

        ipa host-group "$description" "$groupname"
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "Adding new group \"$groupname\" failed."
        else
                rlLog "Adding new group \"$groupname\" successful."
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
   ipa host-group $mygroup
   rc=$?
   if [ $rc -eq 0 ] ; then
        rlLog "$mygroup was found."
        # check hostgroup
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

   ipa group-mod --$attribute="${value}" $mygroup
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
                rlLog "Value of $attribute for $mygroup is as expected."
        fi
   else
        rlLog "ERROR: ipa group-show command failed. Return code: $rc"
   fi

   return $rc
}

#######################################################################
# verifyGroupClasses Usage:
#       verifyGroupClasses groupname <yes or no>
# example:
#       verifyGroupClasses test no
######################################################################

verifyGroupClasses()
{
   mygroup=$1
   private=$2
   tmpfile=/tmp/groupshow.out
   rc=0

   ipa group-show --all $mygroup > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
	classes=`cat $tmpfile | grep objectclass`
	rlLog "DEBUG: $classes"
	if [ $private == "no" ] ; then
		for item in top groupofnames nestedgroup ipausergroup ipaobject ; do
                	echo $classes | grep "$item"
                	if [ $? -ne 0 ] ; then
                        	rlLog "ERROR - objectclass $item was not returned with group-show --all"
                        	rc=1
                	else
                        	rlLog "objectclass $item was returned as expected with group-show --all"
                	fi
        	done
	else
                for item in posixGroup mepManagedEntry top ; do
                        echo $classes | grep "$item"
                        if [ $? -ne 0 ] ; then
                                rlLog "ERROR - objectclass $item was not returned with group-show --all"
                                rc=1
                        else
                                rlLog "objectclass $item was returned as expected with group-show --all"
                        fi
                done	
	fi
   else
        rlLog "ERROR: Show group failed."
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
