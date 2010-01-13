#!/bin/bash

echo "=== remove all DS instances with remove-ds.pl ==="
dirs=`sudo ls /etc/dirsrv/ | grep "slapd-"`
for d in $dirs
do
        echo "try to remove [$d]"
        sudo /usr/sbin/remove-ds.pl -d -i $d
done
# kill ds processes - just in case
echo "kill slapd & httpd"
ps -ef | grep slapd | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep httpd | grep -v grep | awk '{print $2}' | xargs kill -9

echo "=== remove all slapd directories === "
sudo rm -Rvf /etc/dirsrv \
        /var/lib/dirsrv \
        /usr/lib/dirsrv \
        /var/run/dirsrv \
        /var/log/dirsrv \
        /var/lock/dirsrv\
        /var/lib64/dirsrv \
        /usr/lib64/dirsrv

echo "=== remove possible semaphore that left on /dev/shm ==="
sudo rm -f /dev/shm/*slapd*

echo "=== cleal yum cache ==="
sudo yum clean all
sudo rm -Rf /var/cache/yum/*

# remove rpms
echo "=== remove rpms ==="
rpm -qa > /tmp/rpms
for i in `echo dirsec-nspr dirsec-nss dirsec-nss-tools svrcore mozldap6 mozldap6-tools redhat-ds-base redhat-ds-base-selinux perl-Mozilla-LDAP adminutil dirsec-jss fortitude-mod_nss redhat-ds-admin redhat-admin-console redhat-ds-console redhat-idm-console idm-console-framework ldapjdk redhat-ds mozldap mozldap-tools jss icu libicu dirsec-nspr-devel dirsec-nss-devel svrcore-devel mozldap6-devel mozldap6-tools-devel redhat-ds-base-devel perl-Mozilla-LDAP-devel adminutil-devel dirsec-jss-devel fortitude-mod_nss-devel redhat-ds-admin-devel redhat-admin-console-devel redhat-ds-console-devel redhat-idm-consol-devel idm-console-framework-devel ldapjdk-devel redhat-ds-devel mozldap-devel mozldap-tools-devel jss-devel icu-devel libicu-devel dirsec-nspr-debuginfo dirsec-nss-debuginfo svrcore-debuginfo mozldap6-debuginfo mozldap6-tools-debuginfo redhat-ds-base-debuginfo perl-Mozilla-LDAP-debuginfo adminutil-debuginfo dirsec-jss-debuginfo fortitude-mod_nss-debuginfo redhat-ds-admin-debuginfo redhat-admin-console-debuginfo redhat-ds-console-debuginfo redhat-idm-console-debuginfo idm-console-framework-debuginfo ldapjdk-debuginfo redhat-ds-debuginfo icu-debuginfo libicu-debuginfo mozldap-debuginfo mozldap-tools-debuginfo jss-debuginfo`
do
	if grep "$i" /tmp/rpms 2>&1 1>/dev/null
	then
        	echo -e "  rpm remove: [$i]"
        	sudo rpm -e --nodeps $i 
	fi
done
rm /tmp/rpms

echo "=== end of ds clean up ==="

