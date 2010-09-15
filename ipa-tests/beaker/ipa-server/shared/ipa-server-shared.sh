#!/bin/sh

########################################################################
#  IPA SERVER SHARED LIBRARY
#######################################################################
# Includes:
#	kinitAs
#	FirstKinitAs
#       os_nslookup
#       os_getdomainname
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

#########################################################################
# verifyErrorMsg Usage:
#	verifyErrorMsg <command> <expected_msg>
#######################################################################

verifyErrorMsg()
{
   command=$1
   expmsg=$2
   rc=0

   rlLog "Executing: $command"
   $command 2> /tmp/errormsg.out
   actual=`cat /tmp/errormsg.out`
   if [[ "$actual" == "$expmsg" ]] ; then
	rlLog "Error message as expected: $actual"
   else
	rlLog "ERROR: Message not as expected. GOT: $actual  EXP: $expmsg"
	rc=1
   fi

   return $rc
}
