#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/repoclone
#   Description: IPA shared libraries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Libraries Included:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Michael Gregg <mgregg@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nfslocation="n0abos-0.bos.redhat.com:/vol/archives_mp1"
iparepo="http://jdennis.fedorapeople.org/ipa-devel/ipa-devel-fedora.repo"

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh

rlJournalStart
	rlPhaseStartSetup "list files in /dev/shm"
		rlRun "ls /dev/shm"
	rlPhaseEnd

	rlPhaseStartTest "run the repobackup now"
# Fix date
/etc/init.d/ntpd stop
/usr/sbin/ntpdate clock.redhat.com
ret=$?
if [ $ret != 0 ]; then 
	# ntp update didn't work the first time, lets try it again.
	sleep 60
	/usr/sbin/ntpdate clock.redhat.com
	ret=$?
	if [ $ret != 0 ]; then 
		sleep 10
		/usr/sbin/ntpdate tigger.dsqa.sjc2.redhat.com
		ret=$?
		if [ $ret != 0 ]; then 
			sleep 10
			/usr/sbin/ntpdate -u ntp2.usno.navy.mil
			ret=$?
			if [ $ret != 0 ]; then 
				echo "ERROR - could not set the date.... and for some reason we care...";
				exit;
			fi
		fi	
	fi
fi

# Downloading repo file
rlRun "rm -f /etc/yum.repos.d/ipa*"
rlRun "cd /etc/yum.repos.d;wget $iparepo"

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
yum clean all
yum -y erase fedora-ds-base fedora-ds-base-devel 
yum -y install yum-utils createrepo portmap nfs-utils
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
#sed -i s/'po1.epoch, po1.ver, po1.rel'/'po1.epoch, po1.version, po1.release'/g /usr/lib/python2.4/site-packages/yum/packages.py
#ret=$?
#if [ $ret != 0 ]; then 
#	echo "ERROR - fixing of packages.py failed";
#	exit;
#fi
#sed -i s/'po2.epoch, po2.ver, po2.rel'/'po2.epoch, po2.version, po2.release'/g /usr/lib/python2.4/site-packages/yum/packages.py
#ret=$?
#if [ $ret != 0 ]; then 
#	echo "ERROR - fixing of packages.py failed";
#	exit;
#fi

# Determining OS, variant, and processor type
if [ -x $VARIANT ]; then
	cat /etc/redhat-release | grep Fedora
	if [ $? -eq 0 ]; then
		VARIANT="Fedora"
	fi
	cat /etc/redhat-release | grep Red
	if [ $? -eq 0 ]; then
		VARIANT="RHEL"
	fi
fi
if [ -x $ARCH ]; then
	file /bin/ls | grep 32-bit
	if [ $? -eq 0 ]; then
		ARCH=i386
	else
		ARCH=x86_64
	fi
fi

if [ "$VARIANT" = "Fedora" ]; then
	VER=$(cat /etc/redhat-release | cut -d\  -f3)
fi
if [ "$VARIANT" = "rhel" ]; then
	VER=$(cat /etc/redhat-release | cut -d\  -f7)
fi

tempdir="/root/dist/$VARIANT/$VER/$ARCH"
datecode=$(date +%m-%d-%y)

rm -Rf /root/dist
rlRun "mkdir -p $tempdir" 0 "creating temp dir $tempdir"

# Getting the daily files
cd $tempdir;
rlRun "/usr/bin/yumdownloader --resolve ipa-server ipa-client ipa-admintools selinux-policy-targeted selinux-policy krb5-libs krb5-workstation bind caching-nameserver expect bind-dyndb-ldap ntpdate" 0 "downloading needed packages now"
if [ $? != 0 ]; then 
	echo "ERROR - yumdownload of repo dir failed";
	exit;
fi

# Creating repo files
cd $tempdir;createrepo .
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - create of yum repo failed";
	exit;
fi

# Tarring up everything
cd /root/dist; tar cvfz /tmp/ipa-repoclone-$datecode.tar.gz .
ret=$?
if [ $ret != 0 ]; then 
	echo "ERROR - compress yum repo failed";
	exit;
fi
	
# Mounting nfs location
/etc/init.d/portmap start
iptables -F
setenforce 0
mkdir -p /mnt/nfslocation
mount $nfslocation /mnt/nfslocation

# Creating dir on nef server, and copying files to it. 
rlRun "ls /mnt/nfslocation/archives/ipa" 0" Checking to ensure that the destination directory exists"
mkdir /mnt/nfslocation/archives/ipa/$datecode
cd /root/dist;rsync -av * /mnt/nfslocation/archives/ipa/$datecode/.

rlRun "umount /mnt/nfslocation" 0 "Unmounting nfs share"
	rlPhaseEnd


rlJournalPrintText
rlJournalEnd


