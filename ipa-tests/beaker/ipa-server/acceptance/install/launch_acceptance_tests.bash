#!/bin/bash
set -x

echo "Starting DS acceptance tests" 

tpwd=$(pwd)

ds_test_root=/export/svrbld/tet_root/
todays_date="`date '+%Y%m%d'`.1"
log_file=/tmp/launchDStests.log.${todays_date}
todays_build="yum"
OWNER="dummy_entry_to_be_replaced_by_runtest.sh"

# cleanup first
# kill ds processes
ps -ef | grep slapd | grep -v grep | awk '{print $2}' | xargs kill -9
#ps -ef | grep httpd | grep -v grep | awk '{print $2}' | xargs kill -9
sudo rm -Rf /etc/dirsrv/ /var/lib/dirsrv/ /usr/lib/dirsrv/ /var/run/dirsrv/ /var/log/dirsrv/ 
sudo rm -Rf /etc/dirsrv/ /var/lib64/dirsrv/ /usr/lib64/dirsrv/ /var/run/dirsrv/ /var/log/dirsrv/
sudo rm -Rf ${ds_test_root}
sudo yum clean all
sudo rm -Rf /var/cache/yum/*

# remove rpms
for i in `echo dirsec-nspr dirsec-nss dirsec-nss-tools svrcore mozldap6 mozldap6-tools redhat-ds-base perl-Mozilla-LDAP adminutil dirsec-jss fortitude-mod_nss redhat-ds-admin redhat-admin-console redhat-ds-console redhat-idm-console idm-console-framework ldapjdk redhat-ds mozldap mozldap-tools jss icu libicu dirsec-nspr-devel dirsec-nss-devel svrcore-devel mozldap6-devel mozldap6-tools-devel redhat-ds-base-devel perl-Mozilla-LDAP-devel adminutil-devel dirsec-jss-devel fortitude-mod_nss-devel redhat-ds-admin-devel redhat-admin-console-devel redhat-ds-console-devel redhat-idm-consol-devel idm-console-framework-devel ldapjdk-devel redhat-ds-devel mozldap-devel mozldap-tools-devel jss-devel icu-devel libicu-devel dirsec-nspr-debuginfo dirsec-nss-debuginfo svrcore-debuginfo mozldap6-debuginfo mozldap6-tools-debuginfo redhat-ds-base-debuginfo perl-Mozilla-LDAP-debuginfo adminutil-debuginfo dirsec-jss-debuginfo fortitude-mod_nss-debuginfo redhat-ds-admin-debuginfo redhat-admin-console-debuginfo redhat-ds-console-debuginfo redhat-idm-console-debuginfo idm-console-framework-debuginfo ldapjdk-debuginfo redhat-ds-debuginfo icu-debuginfo libicu-debuginfo mozldap-debuginfo mozldap-tools-debuginfo jss-debuginfo bind bind-dyndb-ldap caching-nameserver ipa-server ipa-server-selinux`; do rpm -ev --nodeps $i; done


# create dirs as needed
ds_test_root="/dirsec/archives-mp1/archives/rhts/ipa";export ds_test_root
mkdir -p ${ds_test_root}


# checkout testframework
cd ${ds_test_root}

# copy framework
cd ${ds_test_root};wget http://apoc.dsdev.sjc.redhat.com/tet/ipa2/ipa-tests/tet.tar.gz
gunzip -c tet.tar.gz | tar -xvf -
pwd=$(pwd)

# Installing expect
yum -y install expect
if [ $? -ne 0 ]; then 
	yum -y install expect
	if [ $? -ne 0 ]; then 
		yum -y install expect
	fi
fi

# Setting root password

SHELL=/bin/bash
export SHELL
expect $tpwd/set-root-pw.exp
pwd
# Get repo
rm -f /etc/yum.repos.d/ipa*.repo
cd /etc/yum.repos.d
wget http://jdennis.fedorapeople.org/ipa-devel/fedora/ipa-devel.repo

# copying ssh keys over
mkdir -p /root/.ssh
chmod 777 /root/.ssh
cp $tpwd/id_dsa.pub /root/.ssh/.
cp $tpwd/id_dsa /root/.ssh/.
chmod 600 /root/.ssh/id_dsa
chmod 600 /root/.ssh/id_dsa.pub
chmod g+r /root/.ssh/id_dsa.pub
chmod o+r /root/.ssh/id_dsa.pub
chmod 600 /root/.ssh

# Fixing ksh
rpm -e --nodeps ksh
rpm -i $pwd/tet/pdksh/rhel/pdksh-5.2.14-30.3.i386.rpm 
rpm -i $pwd/tet/pdksh/rhel/pdksh-5.2.14-30.3.x86_64.rpm 

# permissions
chmod -R 777 ${ds_test_root}
groupadd dsrel
adduser -g dsrel svrbld
#chown -R svrbld:dsrel ${ds_test_root}

# Fixing search domains for tet.
hn=$(hostname -s)
fhn=$(ping $hn -c 1 | grep time= | awk '{print $4}')
domain=$(echo $fhn | sed s/$hn.//g)
sed -i s/^search/\#search/g /etc/resolv.conf
echo "search $domain sjc.redhat.com dsdev.sjc.redhat.com idm.lab.bos.redhat.com dsqa.sjc2.redhat.com sfbay.redhat.com usersys.redhat.com dsdev.sjc2.redhat.com corp.redhat.com" >> /etc/resolv.conf
cat /etc/resolv.conf

# Change engage template
cat $pwd/tet/templates/engage.quickinstall.cfg | sed s=-TET-ROOT-=$pwd/tet=g | \
sed   s=-HOSTNAME-M1-=$hn=g | \
sed   s=-OS-M1-=RHEL=g | \
sed   s=-REPO-M1-='http://apoc.dsdev.sjc.redhat.com/tet/ipa2/ipa-tests/tet/testcases/IPA/ipa-9-11-09.repo'=g | \
sed   s=-DOMAIN-=$domain=g | \
sed   s=-ROOT-PW-M1-=redhat=g | \
sed   s=-REPORT-SERVER-='http://wiki.idm.lab.bos.redhat.com'=g | \
sed   s=-EMAIL-=$OWNER=g > /dev/shm/engage.$fhn.cfg

cat /dev/shm/engage.$fhn.cfg

# Running tet
./tet/testcases/IPA/engage -c /dev/shm/engage.$fhn.cfg

echo "start ENV"
env
echo "end ENV"

# Gather results
datecode=$(date +%m-%d-%y-%H_%M)
tar cvfz /tmp/results-$datecode.tar.gz ./tet/testcases/IPA/results

echo "open wiki.idm.lab.bos.redhat.com" > /tmp/script.txt
echo "user svrbld redhat9" >> /tmp/script.txt
echo "cd /dirsec/archives-mp1/archives/rhts/ipa/" >> /tmp/script.txt
echo "put /tmp/results-$datecode.tar.gz" >> /tmp/script.txt

cd /tmp;lftp -f script.txt

