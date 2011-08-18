
# A env set for setup and usage of nis is IPA. 

NISHOST1="$MASTER"
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
	/bin/domainname $NISDOMAIN 
	/bin/ypdomainname $NISDOMAIN 
	echo "$SLAVE" | $LIBDIR/yp/ypinit -m	
	echo "domain $NISDOMAIN server $MASTER"
	/etc/init.d/ypbind restart
	sed -i s/^NISDOMAIN/#NISDOMAIN/g /etc/sysconfig/network
	echo "NISDOMAIN=\"$NISDOMAIN\"" >>  /etc/sysconfig/network
	sed -i s/^domain/#domain/g /etc/yp.conf
	echo "domain $NISDOMAIN server $MASTER" >> /etc/yp.conf
	# Create securenets file
	echo '255.0.0.0       127.0.0.0
# This line gives access to everybody. 
0.0.0.0         0.0.0.0' > /var/yp/securenets
	adduser --password $NISUSER1PASSWD $NISUSER1
	adduser --password $NISUSER2PASSWD $NISUSER2
	adduser --password $NISUSER3PASSWD $NISUSER3
	adduser --password $NISUSER4PASSWD $NISUSER4
	echo "$SLAVE" | $LIBDIR/yp/ypinit -m	
	/etc/init.d/ypbind restart
	service ypbind start
	service yppasswdd start
	service ypxfrd start
	service ypserv start
	chkconfig ypserv on
	chkconfig ypbind on
	chkconfig yppasswdd on
	chkconfig ypxfrd on

	# configuring netgroups
	echo "trustedhost ($NISHOST1,-)" /etc/netgroup
	# Enable netgroups in the yp makefile
	sed -i s/^"all:  passwd group hosts rpc services netid protocols mail"/"all:  passwd group hosts rpc services netid protocols netgrp mail"\\/g /var/yp/Makefile
	echo "$SLAVE" | $LIBDIR/yp/ypinit -m 

}
