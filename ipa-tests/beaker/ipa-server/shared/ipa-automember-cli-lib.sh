#!/bin/sh
. /opt/rhqa_ipa/env.sh
. /usr/share/beakerlib/beakerlib.sh

######################################################################
# Includes:
# Note:		<type> = group | hostgroup
#		<regextype> = inclusive | exclusive
#
# 	addAutomember                 <type> <name>
# 	deleteAutomember              <type> <name>
# 	findAutomember                <type> <name>
# 	modifyAutomember              <type> <name> <attribute> <value>
# 	verifyAutomemberAttr          <type> <name> <attribute> <value>
# 	showAutomember                <type> <name>
#	addAutomemberCondition        <type> <name> <key> <regextype> <regex>
#	removeAutomemberCondition     <type> <name> <key> <regextype> <regex>
#	setAutomemberDefaultGroup     <type> <name>
#	removeAutomemberDefaultGroup  <type>
#	showAutomemberDefaultGroup    <type>
######################################################################
# Assumes:
#       For successful command exectution, administrative credentials
#       already exist.
######################################################################

######################################################################
# addAutomember Usage:
#	addAutomember <group|hostgroup> <name>
######################################################################
addAutomember()
{
	type=$1
	name=$2
	rc=0

	rlLog "Executing: ipa automember-add --type=$type $name"
	ipa automember-add --type=$type $name
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Adding new Automember Rule \"$name\" failed."
	else
		rlLog "Adding new Automember Rule \"$name\" successful."
	fi

	return $rc
}

######################################################################
# deleteAutomember Usage:
#	deleteAutomember <group|hostgroup> <name>
######################################################################
deleteAutomember()
{
	type=$1
	name=$2
	rc=0

	rlLog "Executing: ipa automember-del --type=$type $name"
	ipa automember-del --type=$type $name
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Deleting Automember Rule \"$name\" failed."
	else
		rlLog "Deleting Automember Rule \"$name\" successful."
	fi

	return $rc
}

######################################################################
# findAutomember Usage:
# 	findAutomember <group|hostgroup> <name>
######################################################################
findAutomember()
{
	type=$1
	name=$2
	tmpfile=/tmp/findautomember.out.$$
	rc=0

	rlLog "Executing: ipa automember-find --type=$type $name"
	ipa automember-find --type=$type $name > $tmpfile
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Failed to find automember \"$name\""
		return $rc
	fi

	cat $tmpfile | grep "Automember Rule: $name"
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "ERROR: Automember Rule name not as expected."
	else
		rlLog "Automember Rule name is as expected."
	fi
	
	return $rc
		
}

######################################################################
# modifyAutomember Usage:
# 	modifyAutomember <type> <name> <attribute> <value>
######################################################################
modifyAutomember()
{
	type=$1
	name=$2
	attribute=$3
	value=$4
	rc=0

	rlLog "Executing: ipa automember-mod --type=$type $name --$attribute=\"$value\""
	ipa automember-mod --type=$type $name --$attribute="$value"
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Modifying automember $name failed."
		rc=1
	else
		rlLog "Modifying automember $name successful."
	fi

	return $rc
}

######################################################################
# verifyAutomemberAttr Usage:
# 	verifyAutomemberAttr <type> <name> <attribute> <value>
######################################################################
verifyAutomemberAttr()
{
	type=$1
	name=$2
	attribute="$3:"
	value=$4
	tmpfile=/tmp/automembershow.out.??
	rc=0
	
	rlLog "Executing: ipa automember-show --type=$type $name "
	ipa automember-show --type=$type $name > $tmpfile
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: ipa automember-show command failed."
		return $rc
	fi
	
	cat $tmpfile | grep "$attribute $value"
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "ERROR: ipa automember $name verification failed:  Value of $attribute != $value."
	else
		rlLog "ipa automember $name Verification successful: Value of $attribute = $value."
	fi

	return $rc
}

######################################################################
# showAutomember Usage:
# 	showAutomember <type> <name>
######################################################################
showAutomember()
{
	type=$1
	name=$2
	tmpfile=/tmp/automembershow.out.??
	rc=0

	rlLog "Executing: ipa automember-show --all --type=$type $name."
	ipa automember-show --all --type=$type $name > $tmpfile
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: ipa automember-show failed."
		return $rc
	fi

	classes=$(cat $tmpfile | grep objectclass)
	for class in automemberregexrule ; do
		echo $classes | grep "$class"
		rc=$?
		if [ $rc -ne 0 ]; then
			rlLog "ERROR: automember $name objectclass $class was not returned."
		else
			rlLog "automember $name objectclass $class was returned as successful."
		fi
	done

	return $rc
}

######################################################################
# addAutomemberCondition Usage:
# 	addAutomemberCondition <type> <name> <key> <regextype> <regex>
# 		<regextype> = inclusive | exclusive
######################################################################
addAutomemberCondition()
{
	type=$1
	name=$2
	key=$3
	regextype=$4
	regex=$5
	rc=0

	rlLog "Executing: ipa automember-add-condition --type=$type $name --key=$key --${regextype}-regex=$regex"
	ipa automember-add-condition --type=$type $name --key=$key --${regextype}-regex=$regex
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "ERROR: ipa automember-add-condition failed."
	else
		rlLog "ipa automember-add-condition successful."
	fi

	return $rc
}

######################################################################
# removeAutomemberCondition Usage:
# 	removeAutomemberCondition <type> <name> <key> <regextype> <regex>
# 		<regextype> = inclusive | exclusive
######################################################################
removeAutomemberCondition()
{
	type=$1
	name=$2
	key=$3
	regextype=$4
	regex=$5
	rc=0

	rlLog "Executing: ipa automember-remove-condition --type=$type $name --key=$key --${regextype}-regex=$regex"
	ipa automember-remove-condition --type=$type $name --key=$key --${regextype}-regex=$regex
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "ERROR: ipa automember-remove-condition failed."
	else
		rlLog "ipa automember-remove-condition successful."
	fi

	return $rc
}


######################################################################
# setAutomemberDefaultGroup Usage:
#	setAutomemberDefaultGroup  <type> <name>
######################################################################
setAutomemberDefaultGroup()
{
	type=$1
	name=$2
	rc=0

	rlLog "Executing: ipa automember-default-group-set --type=$type --default-group=$name"
	ipa automember-default-group-set --type=$type --default-group=$name
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Setting Automember Default Group for type \"$type\" failed."
	else
		rlLog "Setting Default Group for type \"$type\" successful."
	fi

	return $rc
}

######################################################################
# removeAutomemberDefaultGroup Usage:
#	removeAutomemberDefaultGroup  <type>
######################################################################
removeAutomemberDefaultGroup()
{
	type=$1
	rc=0

	rlLog "Executing: ipa automember-default-group-remove --type=$type"
	ipa automember-default-group-remove --type=$type
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Removing Automember Default Group for type \"$type\" failed."
	else
		rlLog "Removing Default Group for type \"$type\" successful."
	fi

	return $rc
}

######################################################################
# showAutomemberDefaultGroup Usage:
#	showAutomemberDefaultGroup  <type>
######################################################################
showAutomemberDefaultGroup()
{
	type=$1
	rc=0

	rlLog "Executing: ipa automember-default-group-show --type=$type"
	ipa automember-default-group-show --type=$type
	rc=$?
	if [ $rc -ne 0 ]; then
		rlLog "WARNING: Showing Automember Default Group for type \"$type\" failed."
	else
		rlLog "Showing Default Group for type \"$type\" successful."
	fi

	return $rc
}
