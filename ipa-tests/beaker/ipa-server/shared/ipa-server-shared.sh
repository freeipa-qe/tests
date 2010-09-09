#!/bin/sh

########################################################################
#  IPA SERVER SHARED LIBRARY
#######################################################################
# Includes:
#       os_nslookup
#       os_getdomainname
######################################################################

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

