#!/bin/sh
. /opt/rhqa_ipa/env.sh

########################################################################
#  HOST CLI SHARED LIBRARY
#######################################################################
# Includes:
#       addNetgroup
#       addMemberNetgroup
#       findNetgroup
#       modNetgroup
#       deletNetgroup
#       RemoveMemberNetgroup
#       ShowNetgroup
######################################################################
# Assumes:
#       For successful command exectution, administrative credentials
#       already exist.
#######################################################################

#######################################################################
# addNetgroup Usage:
#       addNetgroup <netgroup name> <description> <attribute to add>
######################################################################
addNetgroup()
{
#	for args in $1 $2 $3 $4 $5 $6 $7; do
#		echo arg is $args;
#	done
	ngname=$1
	ngdesc=$2
	ngaddatt=$3
	rc=0	

	if [ "$2" = "" ]; then
		echo "ERROR - only on variable decteted, fill in the name and description at a minimum."
		rc=1
	else
		if [ "$3" != "" ]; then
			# attribute to add dected
			echo "running ipa netgroup-add --desc=$2 --addattr=\'$3\' $1"
			ipa netgroup-add --desc=\'$2\' --addattr=\'$3\' $1
			rc=$?
		else
			echo "running ipa netgroup-add --desc=\'$2\' $1"
			ipa netgroup-add --desc=\'$2\' $1
			rc=$?
		fi
	fi

	return $rc
}

#######################################################################
# delNetgroup Usage:
#       delNetgroup <netgroup name>
######################################################################
delNetgroup()
{
#	for args in $1 $2 $3 $4 $5 $6 $7; do
#		echo arg is $args;
#	done
	ngname=$1
	rc=0	

	echo "running ipa netgroup-del --desc=$2 --addattr=\'$3\' $1"
	ipa netgroup-del $1
	rc=$?
	
	# verify that it worked with netgroup fins and netgroup-show
	ipa netgroup-find $1
	let rc=$rc+$?

	ipa netgroup-show $1
	let rc=$rc+$?

	ipa netgroup-find $1| grep $1
	let rc=$rc+$?

	ipa netgroup-show $1| grep $1
	let rc=$rc+$?

	return $rc
}



#######################################################################
# verifyNetgroupAttr Usage:
#       verifyNetgroupAttr <netgroupname> <attribute> <value>
######################################################################

verifyNetgroupAttr()
{
   mygroup=$1
   attribute=$2
   value=$3
   rc=0

   attribute="$attribute:"
   tmpfile="/tmp/netgroupshow.out"

   ipa netgroup-show $mygroup > $tmpfile
   rc=$?
   if [ $rc -eq 0 ] ; then
        myval=`cat $tmpfile | grep "$attribute $value" | xargs echo`
	cat $tmpfile | grep "$attribute $value"
   	if [ $? -ne 0 ] ; then
        	rlLog "ERROR: $mygroup verification failed: Value of $attribute - GOT: $myval EXPECTED: $value"
                rc=1
   	else
		rlLog "Value of $attribute for $mygroup is as expected - $myval"
   	fi
   else
	rlLog "WARNING: ipa host-show command failed."
   fi

   return $rc
}
