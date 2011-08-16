
# A env set for setup and usage of nis is IPA. 


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
	/bin/domainname $NISDOMAIN 
	/bin/ypdomainname $NISDOMAIN 
	echo "$SLAVE" | /usr/lib64/yp/ypinit -m	
	echo "domain $NISDOMAIN server $MASTER"
	/etc/init.d/ypbind restart
	sed -i s/^NISDOMAIN/#NISDOMAIN/g /etc/sysconfig/network
	echo 'NISDOMAIN="internal"' >>  /etc/sysconfig/network
	# Create securenets file
	echo '255.0.0.0       127.0.0.0
# This line gives access to everybody. 
0.0.0.0         0.0.0.0' > /var/yp/securenets
	/etc/init.d/ypbind restart
	service ypbind start
	service yppasswdd start
	service ypxfrd start
	service ypserv start
	chkconfig ypserv on
	chkconfig ypbind on
	chkconfig yppasswdd on
	chkconfig ypxfrd on

}
