#######################################
# lib.user-cli.sh
#######################################

# functions used in user-cli test

#  addUserWithPassword
#  modifyUser
#  verifyUserAttr

######################################################################
# addUserWithPassword
#	addUserWithPassword <firstname> <lastname> <userid> <initial_password>
#######################################################################

addUserWithPassword()
{
   firstname=$1
   lastname=$2
   userid=$3
   initpwd=$4
   rc=0

   echo $initpwd | ipa user-add --first=$firstname --last=$lastname --password $userid
   rc=$?
   if [ $? -eq 0 ] ; then
	rlLog "Adding user with password successful."
   else
	rlLog "ERROR: Adding user with password failed."
   fi

   return $rc
}

######################################################################
# modifyUser Usage:
#       modifyUser <username> <attribute> <value>
######################################################################

modifyUser()
{

   myuser=$1
   attribute=$2
   value=$3
   rc=0

   rlLog "Executing: ipa user-mod --$attribute=\"$value\" $myuser"
   ipa user-mod --$attribute="$value" $myuser
   rc=$?
   if [ $rc -ne 0 ] ; then
        rlLog "WARNING: Modifying user $myuser failed."
   else
        rlLog "Modifying user $myuser successful."
   fi
   return $rc
}

#######################################################################
# verifyUserAttr Usage:
#       verifyUserAttr <username> <attribute> <value>
######################################################################

verifyUserAttr()
{
   myuser=$1
   attribute=$2
   value=$3
   rc=0

   tmpfile="/tmp/usershow_$myuser.out"
   rm -rf $tmpfile
   ipa user-show --all $myuser > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        result=`cat $tmpfile | grep "$attribute: $value"`
        rc=$?
        if [ $rc -ne 0 ] ; then
		rlLog "ERROR: Value of $attribute for user $myuser is not as expected.  EXPECTED: $attribute: $value GOT: $result"
		rc=1
	else
		rlLog "Value of $attribute for user $myuser is as expected: $value"
	fi
   else
        rlLog "ERROR: ipa user-show command failed. Return code: $rc"
   fi

   return $rc
}


