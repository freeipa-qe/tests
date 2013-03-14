
# A env set for setup and usage of nis is IPA. 


MYHOSTNAME=$(hostname -s)
NISHOST1="$MYHOSTNAME"
NISUSER1="joe1"
NISUSER2="joe2"
NISUSER3="jaKob"
NISUSER4="littleu"
NISUSER1PASSWD="asdfghjk"
NISUSER2PASSWD="asdfghjk"
NISUSER3PASSWD="asdfghjk"
NISUSER4PASSWD="asdfghjk"
NISUSER1PASSWD2="asdf55634gk"
NISUSER2PASSWD2="asdfg2234123412k"
NISUSER3PASSWD2="lllllllasdfxk"
NISUSER4PASSWD2="asdfjosoeorktk"
NISSERVICE1="my-ftp"
NISSERVICE2="my-web"
NISSERVICE3="my-ssh"
NIS_SERVER_PACKAGES="ypbind ypserv yp-tools rpcbind"
if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
	NIS_CLIENT_PACKAGES="ypbind yp-tools portmap nscd"
else
	NIS_CLIENT_PACKAGES="ypbind yp-tools rpcbind nscd"
fi

export NISUSER1 NISUSER2 NISUSER3 NISUSER4 NISUSER1PASSWD NISUSER2PASSWD NISUSER3PASSWD NISUSER4PASSWD
export NISUSER1PASSWD2 NISUSER2PASSWD2 NISUSER3PASSWD2 NISUSER4PASSWD2
export NIS_SERVER_PACKAGES NIS_CLIENT_PACKAGES

setup-nis-server()
{
	# Install RPMs
	yum -y install $NIS_SERVER_PACKAGES

	# Exit if NISDOMAIN variable not set.  Should come from /opt/rhqa_ipa/env.sh
	if [ -z "$NISDOMAIN" ]; then
		echo "NISDOMAIN env var not set"
		return 1
	fi

	# Set libdir since paths vary based on arch
	if [ -d /usr/lib64 ]; then 
		LIBDIR=/usr/lib64
	else
		LIBDIR=/usr/lib
	fi

	# Disable selinux enforcing
	setenforce 0 # This seems to mak ehe installs work faster
	
	# Set NIS Domain Name
	/bin/domainname $NISDOMAIN 
	/bin/ypdomainname $NISDOMAIN 

	# Setup as a NIS Master 
	service ypserv start
	cp /etc/ypserv.conf /etc/ypserv.conf.orig.setup-nis-server
	echo "$MYHOSTNAME" | $LIBDIR/yp/ypinit -m	
	echo "domain $NISDOMAIN server $MYHOSTNAME"
	service ypserv restart

	# Create securenets file for NIS Master
	cp /var/yp/securenets /var/yp/securenets.orig.setup-nis-server
	cat <<-EOF > /var/yp/securenets
	255.0.0.0   127.0.0.1
	0.0.0.0     0.0.0.0
	EOF

	# Set NISDOMAIN in /etc/sysconfig/network for NIS Client
	cp /etc/sysconfig/network /etc/sysconfig/network.orig.setup-nis-server
	sed -i s/^NISDOMAIN/#NISDOMAIN/g /etc/sysconfig/network
	echo "NISDOMAIN=\"$NISDOMAIN\"" >>  /etc/sysconfig/network

	# Setup yp.conf for NIS Client
	cp /etc/yp.conf /etc/yp.conf.orig.setup-nis-server
	sed -i s/^domain/#domain/g /etc/yp.conf
	echo "domain $NISDOMAIN server $MYHOSTNAME" >> /etc/yp.conf

	# Setup nsswitch.conf for NIS Client\
	cp /etc/nsswitch.conf /etc/nsswitch.conf.orig.setup-nis-server
	sed -i 's/^passwd:.*$/passwd: files nis/' /etc/nsswitch.conf
	sed -i 's/^shadow:.*$/shadow: files nis/' /etc/nsswitch.conf
	sed -i 's/^group:.*$/group:  files nis/' /etc/nsswitch.conf

	echo "$MYHOSTNAME" | $LIBDIR/yp/ypinit -m	
	service yppasswdd start
	service ypxfrd start
	chkconfig rpcbind on
	chkconfig ypserv on
	chkconfig ypbind on
	chkconfig yppasswdd on
	chkconfig ypxfrd on
	service ypserv restart
	service ypbind restart

	# disable iptables if not done already
	service iptables stop
	service ip6tables stop

	# add nis users
	adduser --password $NISUSER1PASSWD $NISUSER1
	adduser --password $NISUSER2PASSWD $NISUSER2
	adduser --password $NISUSER3PASSWD $NISUSER3
	adduser --password $NISUSER4PASSWD $NISUSER4
	
	# configuring netgroups
	cat <<-EOF >>/etc/netgroup
	convertpeople (-,$NISUSER1,$NISDOMAIN) (-,$NISUSER2,$NISDOMAIN) (-,$NISUSER3,$NISDOMAIN) (-,$NISUSER4,$NISDOMAIN)
	EOF

	# Enable netgroups, auto.master, and auto.home in the yp makefile
	sedin='^all:\ \ passwd\ group\ hosts\ rpc\ services\ netid\ protocols\ mail'
	sedout='all:\ \ passwd\ group\ hosts\ rpc\ services\ netid\ protocols\ netgrp\ auto.master\ auto.home\ mail'
	mv /var/yp/Makefile /var/yp/backup-Makefile
	cp /var/yp/backup-Makefile /var/yp/Makefile
	sed -i s/"$sedin"/"$sedout"/g /var/yp/Makefile

	# Add custom service 
	cp /etc/services /etc/services.orig.setup-nis-server
	cat <<-EOF >> /etc/services
	my-ftp 488821/tcp # my custom NIS ftp service entry
	my-ftp 488821/udp # my custom NIS ftp service entry
	my-ssh 488822/tcp # my custom NIS ssh service entry
	my-ssh 488822/udp # my custom NIS ssh service entry
	my-web 488880/tcp # my custom NIS web service entry
	my-web 488880/udp # my custom NIS web service entry
	EOF

	# Create auto.master
	cat <<-EOF >/etc/auto.master
	/nfshome +auto.home
	/nfsapps +auto.apps
	EOF

	# Create auto.home
	cat <<-EOF >/etc/auto.home
	* -rw,rsize=65536,wsize=65536,hard,intr,actimeo=3600,timeo=3600 $MYHOSTNAME:/home/&
	EOF

	# Re-run ypinit to pickup new changes and map info
	echo "$MYHOSTNAME" | $LIBDIR/yp/ypinit -m 
	service ypserv restart
	service ypbind restart
	
	# Checking to ensure that it worked
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME passwd | grep $NISUSER1" 0 "Checking to ensure that nis user 1 was added to the passwd map" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME passwd | grep $NISUSER2" 0 "Checking to ensure that nis user 2 was added to the passwd map" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME passwd | grep $NISUSER3" 0 "Checking to ensure that nis user 3 was added to the passwd map" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME passwd | grep $NISUSER4" 0 "Checking to ensure that nis user 4 was added to the passwd map" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME netgroup | grep $NISUSER1" 0 "Checking to ensure that nis user 1 was added to the netgroup" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME netgroup | grep $NISUSER2" 0 "Checking to ensure that nis user 2 was added to the netgroup" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME netgroup | grep $NISUSER3" 0 "Checking to ensure that nis user 3 was added to the netgroup" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME netgroup | grep $NISUSER4" 0 "Checking to ensure that nis user 4 was added to the netgroup" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME services | grep $NISSERVICE1" 0 "Checking to ensure that nis service 1 was added to service" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME services | grep $NISSERVICE2" 0 "Checking to ensure that nis service 2 was added to service" 
	rlRun "/usr/bin/ypcat -d $NISDOMAIN -h $MYHOSTNAME services | grep $NISSERVICE3" 0 "Checking to ensure that nis service 3 was added to service" 

	# Re-enable selinux enforcing
	setenforce 1

	# Check ypserv/ypbind restarts
	rlRun "service ypserv restart" 0 "Checking a ypserv restart"
	rlRun "service ypbind restart" 0 "Checking a ypbind restart"
}

uninstall-nis-server()
{
	rlLog "UnInstalling NIS Server"
	/bin/mv /var/yp/backup-Makefile /var/yp/Makefile	
	yum -y remove ypbind ypserv yp-tools
	/bin/rm /etc/ypserv.conf*
	/bin/rm /etc/yp.conf*
	/bin/rm /etc/auto.master
	/bin/rm /etc/auto.home
	/bin/rm /etc/netgroup
	/bin/mv /etc/services.orig.setup-nis-server /etc/services
	/bin/mv /etc/sysconfig/network.orig.setup-nis-server /etc/sysconfig/network
	/bin/mv /etc/nsswitch.conf.orig.setup-nis-server /etc/nsswitch.conf
	if [ -d /var/yp ]; then
		/bin/rm -rf /var/yp
	fi
}

setup-nis-client()
{
	# Install NIS Client RPMs
	yum -y install $NIS_CLIENT_PACKAGES
	
	if [ -z "$NISDOMAIN" ]; then
		echo "NISDOMAIN env var not set"
		return 1
	fi

	# Set NISDOMAIN in /etc/sysconfig/network
	cp /etc/sysconfig/network /etc/sysconfig/network.orig.setup-nis-client
	echo "NISDOMAIN=$NISDOMAIN" >> /etc/sysconfig/network

	# Setup yp.conf
	cp /etc/yp.conf /etc/yp.conf.orig.setup-nis-client
	echo "domain $NISDOMAIN server $NISMASTER" >> /etc/yp.conf

	# Setup nsswitch.conf for NIS
	cp /etc/nsswitch.conf /etc/nsswitch.conf.orig.setup-nis-client
	sed -i 's/^passwd:.*$/passwd: files nis/' /etc/nsswitch.conf
	sed -i 's/^shadow:.*$/shadow: files nis/' /etc/nsswitch.conf
	sed -i 's/^group:.*$/group:  files nis/' /etc/nsswitch.conf

	# Set NIS Domain Name
	nisdomainname $NISDOMAIN

	# Start/restart services
	if [ $(grep 5\.[0-9] /etc/redhat-release|wc -l) -gt 0 ]; then
		service portmap restart
	else
		service rpcbind restart
	fi
	service ypbind start
	service nscd start
}

uninstall-nis-client()
{
	yum -y remove ypbind yp-tools
	/bin/mv /etc/sysconfig/network.orig.setup-nis-client /etc/sysconfig/network
	/bin/mv /etc/nsswitch.conf.orig.setup-nis-client /etc/nsswitch.conf
	/bin/rm /etc/yp.conf*
	/bin/rm -rf /var/yp
}	
