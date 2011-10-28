
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

export NISUSER1 NISUSER2 NISUSER3 NISUSER4 NISUSER1PASSWD NISUSER2PASSWD NISUSER3PASSWD NISUSER4PASSWD
export NISUSER1PASSWD2 NISUSER2PASSWD2 NISUSER3PASSWD2 NISUSER4PASSWD2

setup-nis-server()
{
	if [ -d /usr/lib64 ]; then 
		LIBDIR=/usr/lib64
	else
		LIBDIR=/usr/lib
	fi
	setenforce 0 # This seems to mak ehe installs work faster
	/bin/domainname $NISDOMAIN 
	/bin/ypdomainname $NISDOMAIN 
	echo "$MYHOSTNAME" | $LIBDIR/yp/ypinit -m	
	echo "domain $NISDOMAIN server $MYHOSTNAME"
	service ypserv restart
	sed -i s/^NISDOMAIN/#NISDOMAIN/g /etc/sysconfig/network
	echo "NISDOMAIN=\"$NISDOMAIN\"" >>  /etc/sysconfig/network
	sed -i s/^domain/#domain/g /etc/yp.conf
	echo "domain $NISDOMAIN server $MYHOSTNAME" >> /etc/yp.conf
	# Create securenets file
	echo '255.0.0.0       127.0.0.0
# This line gives access to everybody. 
0.0.0.0         0.0.0.0' > /var/yp/securenets
	adduser --password $NISUSER1PASSWD $NISUSER1
	adduser --password $NISUSER2PASSWD $NISUSER2
	adduser --password $NISUSER3PASSWD $NISUSER3
	adduser --password $NISUSER4PASSWD $NISUSER4
	echo "$MYHOSTNAME" | $LIBDIR/yp/ypinit -m	
	service yppasswdd start
	service ypxfrd start
	chkconfig ypserv on
	chkconfig ypbind on
	chkconfig yppasswdd on
	chkconfig ypxfrd on
	service ypserv restart
	service ypbind restart
	service ypserv restart
	service ypbind restart

	# configuring netgroups
	echo "convertpeople (-,$NISUSER1,$NISDOMAIN) (-,$NISUSER2,$NISDOMAIN) (-,$NISUSER3,$NISDOMAIN) (-,$NISUSER4,$NISDOMAIN)" > /etc/netgroup
	# Enable netgroups in the yp makefile
	sedin='^all:\ \ passwd\ group\ hosts\ rpc\ services\ netid\ protocols\ mail'
	sedout='all:\ \ passwd\ group\ hosts\ rpc\ services\ netid\ protocols\ netgrp\ mail'
	cat /var/yp/Makefile > /var/yp/backup-Makefile
	sed -i s/"$sedin"/"$sedout"/g /var/yp/Makefile

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
	setenforce 1
	service ypserv restart
	service ypbind restart

}
