#!/bin/sh
. /opt/rhqa_ipa/env.sh

# Note - this file might not be used by any test.

########################################################################
#  SERVICE CLI SHARED LIBRARY
#######################################################################
# Includes:
#       verifyServiceAttr
#######################################################################


#######################################################################
# verifyServiceAttr Usage:
#       verifyServiceAttr <servicename> <attribute> <value>
######################################################################

verifyServiceAttr()
{
   myservice=$1
   attribute=$2
   value=$3
   rc=0

   attribute="$attribute:"
   tmpfile="/tmp/serviceshow.out"

   ipa service-find $myservice > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        myval=`cat $tmpfile | grep "$attribute" | cut -d ":" -f2 | xargs echo`
	cat $tmpfile | grep "$attribute $value"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: $myservice verification failed: Value of $attribute - GOT: $myval EXPECTED: $value"
                rc=1
   	else
		rlLog "Value of $attribute for $myservice is as expected - $myval"
   	fi
   else
	rlLog "WARNING: ipa service-show command failed."
   fi

   return $rc
}

