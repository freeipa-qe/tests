#!/bin/bash
# fc7repo will be replaced with $fc7repo from env.cfg
set -x
# Fix date
/etc/init.d/ntpd stop
/usr/sbin/ntpdate ntpserver
ret=$?
if [ $ret != 0 ]; then 
	# ntp update didn't work the first time, lets try it again.
	sleep 60
	/usr/sbin/ntpdate ntpserver
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
# Again, for good measure
/etc/init.d/ntpd stop

OS=oshere
# Getting IPA repo file
if [ "$OS" == "FC6" ]||[ "$OS" == "FC7" ]||[ "$OS" == "FC8" ]; then
	cd /etc/yum.repos.d;wget fc7repo;
fi

# updating
/etc/init.d/yum-updatesd stop
yum -y update
ret=$?
if [ $ret != 0 ]; then 
	echo "WARNING - The first try on updating Fedora didn't work, trying again"
	sleep 60
	yum -y update
	ret=$?
	if [ $ret != 0 ]; then 
		echo "ERROR - yum install of freeipa failed";
		exit;
	fi
fi

/usr/sbin/ntpdate ntpserver 

yum -y install expect ipa-client ipa-admintools
ret=$?
if [ $ret != 0 ]; then 
	echo "WARNING - The first try on IPA install didn't work, trying again"
	sleep 60
	yum -y install expect ipa-client ipa-admintools
	ret=$?
	if [ $ret != 0 ]; then 
		echo "ERROR - yum install of freeipa failed";
		exit;
	fi
fi

/usr/sbin/ntpdate ntpserver

# Finxing DNS
echo 'search DSQA.SJC2.REDHAT.COM' > /etc/resolv.conf
echo 'nameserver serverip' >> /etc/resolv.conf

# Removing IPTABLES rules so that this all works
/sbin/iptables -t nat -F
/sbin/iptables -F

# Syncronizing clock to the IPA server.
/etc/init.d/ntpd stop
/usr/sbin/ntpdate serverip
ret=$?
if [ $ret != 0 ]; then
	# sleeping for some time, waiting for things like the network to wake up
	sleep 60
	# ntp update didn't work the first time, lets try it again.
	/usr/sbin/ntpdate serverip
	ret=$?
	if [ $ret != 0 ]; then
		/usr/sbin/ntpdate serverip
		ret=$?
		if [ $ret != 0 ]; then
			echo "PROBLEM - could not set the time/date to the IPA server, nothing else is going to work...";
#			exit;
		fi
	fi
fi

# Checking to make sure that mod_auth_kerb contains ipa
#rpm -q mod_auth_kerb | grep ipa
#ret=$?
#if [ $ret != 0 ]; then 
#	echo "ERROR - mod_auth doesn't appear to be the right version";
#	exit;
#fi
# Setup ipa server
# VMNAME will be replaced wth the fqdn of this machine as reported by dns
#/usr/sbin/ipa-server-install -U --hostname=VMNAME -r QA -p Secret123 -P Secret123 -a Secret123 --setup-bind -u admin -d
#ret=$?
#if [ $ret != 0 ]; then 
#	echo "ERROR - ipa-server-install did not work";
#	exit;
#fi


dig -x 10.14.0.110 @serverip
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - reverse lookup aginst localhost failed";
        exit;
fi

dig VMNAME @serverip
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - lookup of myself failed";
        exit;
fi

/usr/sbin/ntpdate serverip


# Joining client to IPA Server
echo "Test case 2548"
/usr/sbin/ipa-client-install --domain=BAD.IPA.DOMAIN.REDHAT.COM --server=4.2.2.2 --unattended &> /tmp/neg.txt
ret=$?
if [ $ret == 0 ]; then
        echo "ERROR - ipa-client-install worked when it was fed bad info";
	out=$(cat /tmp/neg.txt)
	echo "output from neg testing was $out"
        exit;
fi
#out=$(cat /tmp/neg.txt | sed s/ERROR/ERR\ OR/g )
#echo "output from test 2548 was $out"

# Joining client to IPA Server
echo "Test case 2399"
/usr/sbin/ipa-client-install --domain=DSQA.SJC2.REDHAT.COM --server=serverip --unattended
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - could not join client to IPA Server";
        exit;
fi

/etc/init.d/ntpd stop
/usr/sbin/ntpdate serverip

# Test kinit
#!/usr/bin/expect -f
echo 'set timeout -1
set send_slow {1 .1}
spawn /usr/kerberos/bin/kinit admin
match_max 100000
expect "Password for admin"
sleep 1
send -s -- "Secret123\r"
expect eof ' > /tmp/kinit.exp

/usr/sbin/ntpdate serverip

/usr/bin/expect /tmp/kinit.exp
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - kinit failed";
fi

/usr/sbin/ntpdate serverip

/usr/sbin/ipa-finduser admin
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - ipa-finduser failed";
fi

/usr/sbin/ntpdate serverip

# Testing ipa-adduser
echo 'set timeout -1
spawn /usr/sbin/ipa-adduser clientuser1
match_max 100000
expect "First name: "
send -- "new\r"
expect "new\r
Last name: "
send -- "user1\r"
expect "user1\r
  Password: "
send -- "newpW1\r"
expect "Password (again): "
send -- "newpW1\r"
expect eof' > /tmp/ipaadduser.exp

/usr/sbin/ntpdate serverip

/usr/bin/expect /tmp/ipaadduser.exp
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - ipa-adduser failed";
        exit;
fi

# Changing the password for clientuser1 so that the accouny is usable
echo 'set timeout -1
spawn /usr/kerberos/bin/kpasswd clientuser1
match_max 100000
expect -exact "Password for clientuser1@DSQA.SJC2.REDHAT.COM: "
send -- "newpW1\r"
expect -exact "\r
Enter new password: "
send -- "Secret123\r"
expect -exact "\r
Enter it again: "
send -- "Secret123\r"
expect eof' > /tmp/testusernewpass.exp

/usr/bin/expect /tmp/testusernewpass.exp
ret=$?
if [ $ret != 0 ]; then
	echo "ERROR - kpasswd for user clientuser1 failed";
        exit;
fi

# Testing ipa-addgroup
echo 'set timeout -1
spawn /usr/sbin/ipa-addgroup
match_max 100000
expect "Group name: "
send -- "test-group\r"
expect "test-group\r
Description: "
send -- "test group for QA tests"
expect "test group for QA tests"
sleep 1
send -- "\r"
expect eof' > /tmp/ipa-addgroup.exp

/usr/sbin/ntpdate serverip

/usr/bin/expect /tmp/ipa-addgroup.exp
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - ipa-addgroup failed";
fi

/usr/sbin/ipa-findgroup test-group
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - ipa-findgroup failed";
fi

/usr/sbin/ntpdate serverip

# Test add clientuser1 to test-group
/usr/sbin/ipa-modgroup -a clientuser1 test-group
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - add of clientuser1 to test-group failed";
fi

/usr/sbin/ntpdate serverip

# Did the ipa-groupmod really work?
/usr/sbin/ipa-findgroup test-group > /tmp/findgroup.txt
/bin/grep clientuser1 /tmp/findgroup.txt
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - add of clientuser1 to test-group really did fail";
fi

/usr/sbin/ntpdate serverip

# Test delete clientuser1 fromo test-group
/usr/sbin/ipa-modgroup -r clientuser1 test-group
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - add of clientuser1 to test-group failed";
fi

/usr/sbin/ntpdate serverip

# Did the removal ipa-groupmod really work?
/usr/sbin/ipa-findgroup test-group > /tmp/findgroup.txt
/bin/grep clientuser1 /tmp/findgroup.txt
ret=$?
if [ $ret == 0 ]; then
        echo "ERROR - remove of clientuser1 from test-group really did fail";
fi

/usr/sbin/ntpdate serverip

/usr/bin/expect /tmp/kinit.exp
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - kinit as test user failed";
fi

/usr/sbin/ipa-finduser admin > /tmp/finduser.txt
grep -v No\ entries /tmp/finduser.txt | grep admin
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - testuser cannot find admin using ipa-finduser";
fi

/usr/sbin/ipa-finduser testuser > /tmp/finduser.txt
grep -v No\ entries /tmp/finduser.txt | grep testuser
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - testuser cannot find him/herself with ipa-finduser";
fi

echo "Generating list to be used for test 2563"
echo 'mobile 3456782345
postalcode 94044-1223
displayname joe*test
initials jt
loginshell /bin/bash
telephonenumber 1234567890
facsimiletelephonenumber +34 7777777777
street fake
roomnumber 12
carlicense b33222344456
employeetype evil' > /tmp/varlist.txt

/usr/sbin/ntpdate serverip

echo "Running test 2563"
cat /tmp/varlist.txt | while read line; do 
	key=$(echo $line | awk '{print $1'}); 
	val=$(echo $line | awk '{print $2'});
	/usr/sbin/ipa-moduser --setattr $key="$val" clientuser1
	ret=$?
	if [ $ret != 0 ]; then
	        echo "ERROR - modification of $key to $val on clientuser1 as clientuser1 did not work";
		exit;
	fi
	# checking to see if it worked
	/usr/sbin/ipa-finduser -a -n clientuser1 | grep $key | grep $val
	if [ $ret != 0 ]; then
	        echo "ERROR - modification of $key to $val on clientuser1 as clientuser1 got accepted by ipa-moduser, but did not take";
		exit;
	fi
done

/usr/kerberos/bin/kdestroy
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - kdestroy from clientuser1 did not work";
	exit;
fi

echo "rebinding as admin to delete clientuser1"
/usr/bin/expect /tmp/kinit.exp

# testing user invalidation
/usr/sbin/ipa-deluser clientuser1
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - invalidation of clientuser1 failed";
fi

/usr/sbin/ntpdate serverip

/usr/sbin/ipa-finduser clientuser1 > /tmp/finduser.txt
grep -v No\ entries /tmp/finduser.txt | grep clientuser1
ret=$?
if [ $ret == 0 ]; then
        echo "ERROR - remove of clientuser1 really seemed to have failed";
fi

/usr/kerberos/bin/kdestroy
ret=$?
if [ $ret != 0 ]; then
        echo "ERROR - kdestroy from admin did not work";
	exit;
fi

# Removing client to IPA Server
#/usr/sbin/ipa-client-install --uninstall --unattended=UNATTENDED
#ret=$?
#if [ $ret != 0 ]; then
#        echo "ERROR - could not remove client to IPA Server";
#        exit;
#fi

# now, do all of the client user avalible functions here..
# Fix date
