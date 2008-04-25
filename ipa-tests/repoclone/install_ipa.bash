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
#yum -R 1 -y update
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
yum -y install yum-utils createrepo
ret=$?
if [ $ret != 0 ]; then 
	ps -fax
	sleep 60
	yum -y install yum-utils createrepo
	ret=$?
	if [ $ret != 0 ]; then 
		echo "The YUM stuff didn't work, but we have decided that we don't care now as the build stuff is installed in the VM"
	#	echo "ERROR - yum install of build packages failed";
	#	exit;
	fi
fi

# Fixing yumdownloader
sed -i s/'po1.epoch, po1.ver, po1.rel'/'po1.epoch, po1.version, po1.release'/g /usr/lib/python2.4/site-packages/yum/packages.py
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - fixing of packages.py failed";
	exit;
fi
sed -i s/'po2.epoch, po2.ver, po2.rel'/'po2.epoch, po2.version, po2.release'/g /usr/lib/python2.4/site-packages/yum/packages.py
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - fixing of packages.py failed";
	exit;
fi

# Getting the daily files
mkdir -p /root/dist
if [ $ret != 0 ]; then 
	echo "ERROR - create of repo dir failed";
	exit;
fi
cd /root/dist;/usr/bin/yumdownloader --resolve ipa-server ipa-client ipa-admintools selinux-policy-targeted selinux-policy krb5-libs krb5-workstation
if [ $ret != 0 ]; then 
	echo "ERROR - yumdownload of repo dir failed";
	exit;
fi

cd /root;createrepo ./dist
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

