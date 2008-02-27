#!/bin/bash
# fc7repo will be replaced with $fc7repo from env.cfg
set -x

# Fix date
/etc/init.d/ntpd stop
/usr/sbin/ntpdate homer.sfbay.redhat.com
ret=$?
if [ $ret != 0 ]; then 
	# ntp update didn't work the first time, lets try it again.
	sleep 60
	/usr/sbin/ntpdate homer.sfbay.redhat.com
	ret=$?
	if [ $ret != 0 ]; then 
		sleep 10
		/usr/sbin/ntpdate tigger.dsqa.sjc2.redhat.com
		ret=$?
		if [ $ret != 0 ]; then 
			sleep 10
			/usr/sbin/ntpdate ntp2.usno.navy.mil
			ret=$?
			if [ $ret != 0 ]; then 
				echo "ERROR - could not set the date.... and for some reason we care...";
				exit;
			fi
		fi	
	fi
fi

# Killing all currently running yum processes
if [ -f /var/run/yum.pid ]; then
	ypid=`cat /var/run/yum.pid`
	kill $ypid
	sleep 5
	kill -9 $ypid
	if [ -f /var/run/yum.pid ]; then
		rm -f /var/run/yum.pid
	fi
fi

rpm -e --allmatches fedora-ds-base fedora-ds-base-devel
# updating
/etc/init.d/yum-updatesd stop
yum -R 1 -y update
ret=$?
if [ $ret != 0 ]; then
        echo "WARNING - The first try on updating Fedora didn't work, trying again"
        sleep 60
        yum -R 1 -y update
        ret=$?
        if [ $ret != 0 ]; then 
                echo "ERROR - yum install of freeipa failed";
                exit;
        fi
fi
yum -y install mercurial rpm-build openldap-devel krb5-devel nss-devel mozldap-devel openssl-devel fedora-ds-base-devel gcc python-devel createrepo autoconf automake libtool libcap-devel TurboGears selinux-policy-devel
ret=$?
if [ $ret != 0 ]; then 
	ps -fax
	sleep 60
	yum -y install mercurial rpm-build openldap-devel krb5-devel nss-devel mozldap-devel openssl-devel fedora-ds-base-devel gcc python-devel createrepo autoconf automake libtool libcap-devel TurboGears selinux-policy-devel
	ret=$?
	if [ $ret != 0 ]; then 
		echo "The YUM stuff didn't work, but we have decided that we don't care now as the build stuff is installed in the VM"
	#	echo "ERROR - yum install of build packages failed";
	#	exit;
	fi
fi

# get the IPA repo
cd
mkdir ipa
cd ipa
hg clone http://hg.fedorahosted.org/hg/freeipa
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - ipa-server checkout did not work";
	exit;
fi

cd freeipa
make dist
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - make dist of IPA did not work";
	exit;
fi

# Make a yum repo of the data
cd dist
if [ -d ./rpms ]; then
	mv ./rpms/* .
fi
if [ -d ./srpms ]; then
	mv ./srpms/* .
fi
wget http://freeipa.com/downloads/devel/rpms/F7/i386/PyKerberos-0.1735-1.fc7.i386.rpm
wget http://freeipa.com/downloads/devel/rpms/F7/i386/PyKerberos-0.1735-2.fc7.i386.rpm
wget http://freeipa.com/downloads/devel/rpms/F7/i386/mod_auth_kerb-5.3-4.ipa.i386.rpm
wget http://freeipa.com/downloads/devel/rpms/F7/i386/mod_nss-1.0.7-2.fc7.i386.rpm
wget http://freeipa.com/downloads/devel/rpms/F7/i386/pyasn1-0.0.7a-2.fc7.noarch.rpm
wget http://freeipa.com/downloads/devel/rpms/F7/i386/pyasn1-0.0.7a-1.noarch.rpm
cd ..
createrepo ./dist
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - create of yum repo failed";
	exit;
fi

tar cvfz /tmp/dist.tgz ./dist
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - compress yum repo failed";
	exit;
fi

