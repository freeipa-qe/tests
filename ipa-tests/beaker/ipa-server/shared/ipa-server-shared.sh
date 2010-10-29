#!/bin/sh

########################################################################
#  IPA SERVER SHARED LIBRARY
#######################################################################
# Includes:
#	kinitAs
#	FirstKinitAs
#       os_nslookup
#       os_getdomainname
#	getBaseDN
#	verifyErrorMsg
#	AddToKnowHosts
#	setAttribute
#	addAttribute
######################################################################
#######################################################################
# kinitAs Usage:
#       kinitAs <username> <password>
#####################################################################
kinitAs()
{
   username=$1
   password=$2
   rc=0
   expfile=/tmp/kinit.exp
   outfile=/tmp/kinitAs.out

   rm -rf $expfile
   echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
   echo "spawn /usr/kerberos/bin/kinit -V $username" >> $expfile
   echo 'match_max 100000' >> $expfile
   echo 'expect "*: "' >> $expfile
   echo 'sleep .5' >> $expfile
   echo "send -s -- \"$password\"" >> $expfile
   echo 'send -s -- "\r"' >> $expfile
   echo 'expect eof ' >> $expfile

   kdestroy;/usr/bin/expect $expfile
   
   # verify credentials
   klist > $outfile
   grep $username $outfile
   if [ $? -ne 0 ] ; then
	rlLog "ERROR: kinit as $username with password $password failed."
	rc=1
   else
	rlLog "kinit as $username with password $password was successful."
   fi
   return $rc
}  

#######################################################################
# FirstKinitAs Usage:
#       FirstKinitAs <username> <initial_password> <new_password>
#####################################################################
FirstKinitAs()
{
   username=$1
   password=$2
   newpassword=$3
   rc=0
   expfile=/tmp/kinit.exp
   outfile=/tmp/kinitAs.out

   rm -rf $expfile
   echo 'set timeout 30
set send_slow {1 .1}' > $expfile
   echo "spawn /usr/kerberos/bin/kinit -V $username" >> $expfile
   echo 'match_max 100000' >> $expfile
   echo 'expect "*: "' >> $expfile
   echo 'sleep .5' >> $expfile
   echo "send -s -- \"$password\"" >> $expfile
   echo 'send -s -- "\r"' >> $expfile
   echo 'expect "*: "' >> $expfile
   echo 'sleep .5' >> $expfile
   echo "send -s -- \"$newpassword\"" >> $expfile
   echo 'send -s -- "\r"' >> $expfile
   echo 'expect "*: "' >> $expfile
   echo 'sleep .5' >> $expfile
   echo "send -s -- \"$newpassword\"" >> $expfile
   echo 'send -s -- "\r"' >> $expfile
   echo 'expect eof ' >> $expfile

   kdestroy;/usr/bin/expect $expfile

   # verify credentials
   klist > $outfile
   grep $username $outfile
   if [ $? -ne 0 ] ; then
        rlLog "ERROR: kinit as $username with password $password failed."
        rc=1
   else
        rlLog "kinit as $username with password $password was successful."
   fi

   return $rc
}

#######################################################################
# os_nslookup Usage:
#       os_nslookup
#####################################################################
os_nslookup()
{
h=$1
case $ARCH in
        "Linux "*)
                rval=`nslookup -sil $h`
                if [ `expr "$rval" : "server can't find"` -gt 0 ]; then
                        tmpdn=`domainname -f`
                        echo "Name: $tmpdn"
                        tmpaddr=`/sbin/ifconfig -a | egrep inet | egrep -v 127.0.0.1 | egrep -v inet6 | awk '{print $2}' | awk -F: '{print $2}'`
                        echo "Addr: $tmpaddr"
                else
                        nslookup -sil $h
                fi
                ;;
        *)
                nslookup $h
                ;;
esac
}

#######################################################################
# os_getdomainname Usage:
#       mydomain=`os_getdomainname`
#####################################################################

os_getdomainname()
{
   mydn=`hostname | nslookup 2> /dev/null | grep 'Name:' | cut -d"." -f2-`
   if [ "$mydn" = "" ]; then
     mydn=`hostname -f |  cut -d"." -f2-`
   fi
   echo "$mydn"
}

#######################################################################
# getBaseDN Usage:
#       basedn=`getBaseDN`
#####################################################################
getBaseDN()
{
  domain=`os_getdomainname`
  echo dc=$domain > /tmp/domain.out
  basedn=`cat /tmp/domain.out | sed -e 's/\./,dc=/g'`

  echo "$basedn"
}

#########################################################################
# verifyErrorMsg Usage:
#	verifyErrorMsg <command> <expected_msg>
#######################################################################

verifyErrorMsg()
{
   command=$1
   expmsg=$2
   rc=0

   rm -rf /tmp/errormsg.out /tmp/errormsg_clean.out
   rlLog "Executing: $command"
   $command
   rc=$?
   if [ $rc -eq 0 ] ; then
        rlLog "ERROR: Expected \"$command\" to fail."
        rc=1
   else
	rc=0
	rlLog "\"$command\" failed as expected."
        $command 2> /tmp/errormsg.out
	sed 's/"//g' /tmp/errormsg.out > /tmp/errormsg_clean.out
        actual=`cat /tmp/errormsg_clean.out`
        if [[ "$actual" == "$expmsg" ]] ; then
                rlLog "Error message as expected: $actual"
        else
                rlLog "ERROR: Message not as expected. GOT: $actual  EXP: $expmsg"
                rc=1
        fi
  fi

  return $rc
}

#########################################################################
# AddToKnownHosts
#   Add the machine with the hostname in $1 to the sshknown hosts file.
#   This sub will also remove any entries for the defined hostname from 
#    known hosts before completing. This sub assumes that the shared libs are 
#    installed, this should set up id_rsa and id_dsa in the root's .ssh dir
#   Usage: AddToKnownHosts <fullhostname>
#   Returns 1 if $1 is empty
#   Returns 0 if everything seems to have worked.
#######################################################################
AddToKnownHosts()
{
	TET_TMP_DIR=/dev/shm
	if [ "$1" != "" ]; then 
		rlLog "creating expect file to add $1 to known hosts file"
		export SHELL="/bin/bash"
		echo '#!/usr/bin/expect -f
set timeout 30
set send_slow {1 .1}
spawn $env(SHELL)
match_max 100000' > $TET_TMP_DIR/setup-ssh-remote.exp
		echo "send -s -- \"ssh root@$1 'ls /'\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
		echo "expect \"*'ls /'\"" >> $TET_TMP_DIR/setup-ssh-remote.exp
		echo 'sleep .1
send -s -- "\r"
expect "*Are you sure you want to continue connecting (yes/no)? "
sleep .1
send -s "yes\r"
#expect "*"
expect eof' >> $TET_TMP_DIR/setup-ssh-remote.exp
		rlLog "Running expect script to add $1 to known hosts file"
		$TET_TMP_DIR/setup-ssh-remote.exp
	else
		rlLog "AddToKnownHosts called improperly, please see shared lib for usage"
		return 1
	fi
	chmod 777 $TET_TMP_DIR/setup-ssh-remote.exp
	expect $TET_TMP_DIR/setup-ssh-remote.exp &> /dev/shm/ssh-known-setup-update.txt
	return 0
}

#######################################################################
# setAttribute Usage:
#       setAttribute <topic> <attribute> <value> <object>
# Example:
#	setAttribute host location "Lab 3" jennyv2.bos.redhat.com
#####################################################################

setAttribute()
{
  topic=$1
  attr=$2
  value=$3
  object=$4
  rc=0

  rlLog "Executing: ipa $topic-mod --setattr $attr=\"$value\" $object"
  ipa $topic-mod --setattr $attr="$value" $object
  rc=$?
  if [ $rc -ne 0 ] ; then
	rlLog "ERROR: Failed to set value for attribute $attr."
	rc=1
  else
	rlLog "Successfully set attribute $attr to \"$value\""
  fi

  return $rc

}

#######################################################################
# addAttribute Usage:
#       addAttribute <topic> <attribute> <value> <object>
# Example:
#       addAttribute host location "Lab 3" jennyv2.bos.redhat.com
#####################################################################

addAttribute()
{
  topic=$1
  attr=$2
  value=$3
  object=$4
  rc=0

  rlLog "Executing: ipa $topic-mod --addattr $attr=\"$value\" $object"
  ipa $topic-mod --addattr $attr="$value" $object
  rc=$?
  if [ $rc -ne 0 ] ; then
        rlLog "ERROR: Failed to add additional attribute value for attribute $attr."
        rc=1
  else
        rlLog "Successfully added additional attribute $attr with value \"$value\""
  fi

  return $rc

}


