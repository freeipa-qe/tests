#!/bin/sh
. /dev/shm/env.sh

########################################################################
#  selinuxusermap CLI SHARED LIBRARY
#######################################################################
# Includes:
#	addSelinuxusermap
#	addSelinuxusermapAllOptions
#	addHostSelinuxusermap
#	addUserSelinuxusermap
#	findSelinuxusermap
#	findSelinuxusermapByOption
#	verifySelinuxusermapAttr
#
######################################################################
# Assumes:
#	For successful command execution, administrative credentials
#	already exist.
#######################################################################

#######################################################################
# addSelinuxusermap Usage:
#       addSelinuxusermap <selinuxuser>  <selinuxusermapName>
######################################################################

addSelinuxusermap()
{
   selinuxuser=$1
   selinuxusermapname=$2
   rc=0

        rlLog "Executing: ipa selinuxusermap-add --selinuxuser=$selinuxuser $selinuxusermapname"
        ipa selinuxusermap-add --selinuxuser=$selinuxuser $selinuxusermapname
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "WARNING: Adding new selinuxusermap $selinuxusermapname failed."
        else
                rlLog "Adding new selinuxusermap $selinuxusermapname successful."
        fi

   return $rc

}

#######################################################################
# addSelinuxusermapAllOptions Usage:
#	addSelinuxusermapAllOptions <selinuxuser> <hbacrule> <usercat> <hostcat> <desc> <selinuxusermapName>
######################################################################

addSelinuxusermapAllOptions()
{
   selinuxuser=$1
   hbacrule=$2
   usercat=$3
   hostcat=$4
   desc=\"$5\"
   selinuxusermapname=$6
   rc=0

	rlLog "Executing: ipa selinuxusermap-add --selinuxuser=$selinuxuser --hbacrule=$hbacrule --usercat=$usercat --hostcat=$hostcat --desc=\"$desc\" $selinuxusermapname"
	ipa selinuxusermap-add --selinuxuser=$selinuxuser --hbacrule=$hbacrule --usercat=$usercat --hostcat=$hostcat --desc=$desc $selinuxusermapname
	rc=$?
   	if [ $rc -ne 0 ] ; then
        	rlLog "WARNING: Adding new selinuxusermap $selinuxusermapname failed."
   	else
        	rlLog "Adding new selinuxusermap $selinuxusermapname successful."
   	fi

   return $rc

}

#######################################################################
# addHostSelinuxusermap Usage:
#       addHostSelinuxusermap <hosts> <hostgroups> <selinuxusermapName>
######################################################################

addHostSelinuxusermap()
{
   hosts=$1
   hostgroups=$2
   selinuxusermapname=$3
   rc=0

        rlLog "Executing: ipa selinuxusermap-add-host --hosts=$hosts --hostgroups=$hostgroups  $selinuxusermapname"
	ipa selinuxusermap-add-host --hosts=$hosts --hostgroups=$hostgroups  $selinuxusermapname > /tmp/selinuxusermap_slloptions.out
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "WARNING: Adding new $hosts and $hostgroups to $selinuxusermapname failed."
		rlRun "cat /tmp/selinuxusermap_slloptions.out"
        else
                rlLog "Adding new $hosts and $hostgroups to $selinuxusermapname successful."
        fi

   return $rc

}

#######################################################################
# addUserSelinuxusermap Usage:
#       addUserSelinuxusermap <users> <groups> <selinuxusermapName>
######################################################################

addUserSelinuxusermap()
{
   users=$1
   groups=$2
   selinuxusermapname=$3
   rc=0
        
        rlLog "Executing: ipa selinuxusermap-add-user --users=$users --groups=$groups  $selinuxusermapname"
	ipa selinuxusermap-add-user --users=$users --groups=$groups  $selinuxusermapname
        rc=$?
        if [ $rc -ne 0 ] ; then
                rlLog "WARNING: Adding new $users and $groups to $selinuxusermapname failed."
        else
                rlLog "Adding new $users and $groups to $selinuxusermapname successful."
        fi

   return $rc

}

#######################################################################
# findSelinuxusermap Usage:
#       findSelinuxusermap <selinuxusermapname>
######################################################################

findSelinuxusermap()
{
   selinuxusermapname=$1
   ipa selinuxusermap-find $selinuxusermapname
   rc=$?
   if [ $rc -eq 0 ] ; then
	result=`ipa selinuxusermap-find $selinuxusermapname`

	# check selinuxusermap rule name
 	echo $result | grep "Rule name: $selinuxusermapname"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: $selinuxusermapname not as expected."
		rc=1        
   	else
		rlLog "Rule $selinuxusermapname is as expected."
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
		rlLog "WARNING: Failed to find selinuxusermap rule."
   fi

   return $rc

}

#######################################################################
# findSelinuxusermapByOption Usage:
#       findSelinuxusermap <option> <value> <space_delimited_list_of_expected_rules>
######################################################################

findSelinuxusermapByOption()
{
   option=$1
   value=$2
   selinuxusermapname=$3
   rc=0

   flag="--$option"
   tmpfile=/tmp/findselinuxusermapbyoption.txt
   rm -rf $tmpfile

   rlLog "Executing: ipa selinuxusermap-find $flag=$value"
   ipa selinuxusermap-find $flag=$value > $tmpfile
   rc=$?
   rlRun "cat $tmpfile"
   if [ $rc -eq 0 ] ; then
	rlLog "Searching for rules: $selinuxusermapname"
	for item in $selinuxusermapname ; do
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
   	rlLog "WARNING: selinuxusermap-find command faied."
   fi

   return $rc
}

#############################################################################
# verifySelinuxusermapAttr Usage
#   verifySelinuxusermapAttr <servicename> <attr> <value>
##############################################################################

verifySelinuxusermapAttr()
{
   selinuxusermapname=$1
   attribute=$2
   value=$3
   rc=0


   attribute="$attribute:"
   tmpfile="/tmp/selinuxusermapshow_$selinuxusermapname.out"

   ipa selinuxusermap-show $selinuxusermapname > $tmpfile

   rc=$?
   if [ $rc -eq 0 ] ; then
        myval=`cat $tmpfile | grep -i "$attribute $value" | xargs echo`
        cat $tmpfile | grep -i "$attribute $value"
        if [ $? -ne 0 ] ; then
                rlLog "ERROR: $selinuxusermapname verification failed: Value of $attribute - GOT: $myval EXPECTED: $value"
                rc=1
        else
                rlLog "Value of $attribute for $selinuxusermapname is as expected - $myval"
        fi
   else
        rlLog "WARNING: ipa selinuxusermap-show command failed."
   fi

   return $rc
}

#######################################################################
# deleteSelinuxusermap Usage:
#       deleteSelinuxusermap <rulename>
######################################################################

deleteSelinuxusermap()
{
   selinuxusermapname=$1
   rc=0

   ipa selinuxusermap-del $selinuxusermapname
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Deleting selinuxusermap rule $selinuxusermapname failed."
   else
        rlLog "Selinuxusermap rule $selinuxusermapname deleted successfully."
   fi

   return $rc
}

#######################################################################
# disableSelinuxusermap Usage:
#       disableSelinuxusermap <rulename>
######################################################################

disableSelinuxusermap()
{
   selinuxusermapname=$1
   rc=0

   ipa selinuxusermap-disable $selinuxusermapname
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Disabling selinuxusermap rule $selinuxusermapname failed."
   else
        rlLog "Selinuxusermap rule $selinuxusermapname disabled successfully."
   fi
   return $rc
}

#######################################################################
# enableSelinuxusermap Usage:
#       enableSelinuxusermap <rulename>
######################################################################

enableSelinuxusermap()
{
   selinuxusermapname=$1
   rc=0

   ipa selinuxusermap-enable $selinuxusermapname
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Enabling selinuxusermap rule $selinuxusermapname failed."
   else
        rlLog "Selinuxusermap rule $selinuxusermapname enabled successfully."
   fi
   return $rc
}

