#! /bin/sh

IPA_SERVER=$1
IPA_CLIENT=$2

if [ -z $IPA_SERVER ];then
  IPA_SERVER=`hostname -f`
fi

if [ -z $IPA_CLIENT ];then
  IPA_CLIENT=ipaqa13.dsqa.sjc2.redhat.com
fi

if [ ! -d /export ];then
  mkdir /export
fi

chmod 777 /export

echo "
/export  *(rw,fsid=0,insecure,no_subtree_check)
/export  gss/krb5(rw,fsid=0,insecure,no_subtree_check)
/export  gss/krb5i(rw,fsid=0,insecure,no_subtree_check)
/export  gss/krb5p(rw,fsid=0,insecure,no_subtree_check)
" > /etc/exports

echo "config client ssh password-less login"
ipa-addservice host/$IPA_CLIENT
ipa-getkeytab  -s $IPA_SERVER -p host/$IPA_CLIENT -k /tmp/host.keytab.$IPA_CLIENT -e des-cbc-crc
echo "you need scp the host keytab : [/tmp/host.keytab.$IPA_CLIENT] to [$IPA_CLIENT] host"

echo "config NFS keytab"
echo "step 1: create NFS principle on IPA server and append keytab into /etc/krb5.keytab file"
ipa-addservice nfs/$IPA_SERVER
ipa-getkeytab -s $IPA_SERVER -p nfs/$IPA_SERVER -k /etc/krb5.keytab -e des-cbc-crc

echo "step 2: create NFS client principle on IPA server host and copy it to ipa client"
ipa-addservice nfs/$IPA_CLIENT
ipa-getkeytab -s $IPA_SERVER -p nfs/$IPA_CLIENT -k /etc/nfs.keytab.$IPA_CLIENT -e des-cbc-crc
echo "you need scp the host keytab : [/tmp/nfs.keytab.$IPA_CLIENT] to [$IPA_CLIENT] host"

exportfs -a
service nfs restart
service rpcgssd restart


