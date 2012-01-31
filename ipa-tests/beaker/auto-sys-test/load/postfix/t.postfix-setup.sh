setup-dns()
{
	rlPhaseStartTest "add users and groups for use with dns setup"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		# Determine my IP address
		currenteth=$(route | grep ^default | awk '{print $8}')
		# get the ip address of that interface
		ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
		rlRun "ipa dnsrecord-add $DOMAIN @ --mx-rec '10 $ipaddr.'" 0 "add record type MX"
		rlRun "ipa dnsrecord-add $DOMAIN @ --a-rec '$ipaddr'" 0 "add record type A to domain"
		rlRun "ipa dnsrecord-add $DOMAIN imap --a-rec '$ipaddr'" 0 "add imap A record"
		rlRun "ipa dnsrecord-add $DOMAIN smtp --a-rec '$ipaddr'" 0 "add smtp A record"
		rlRun "ipa dnsrecord-add $DOMAIN www --a-rec '$ipaddr'" 0 "add www A record"
		rlRun "/etc/init.d/named restart" 0 "restart bind"
	rlPhaseEnd
}

setup-postfix()
{
	testuser=uone
	testuseremail="tone@$DOMAIN"
	rlPhaseStartTest "Setting up core postfix files"
		seconds=$(date +%s)
		rlRun "mv /etc/postfix/main.cf /etc/postfix/main.cf-backup-$seconds" 0 "backing up main.cf"
		rlRun "cp -a /dev/shm/main.cf /etc/postfix/." 0 "copying over main.cf"
		rlRun "rm -f /etc/postfix/ldap-*" 0 "removing any conf files from a previous run"
		rlRun "cp /dev/shm/ldap-uid.cf /etc/postfix/." 0 "copying over ldap-uid.cf"
		rlRun "cp /dev/shm/ldap-gid.cf /etc/postfix/." 0 "copying over ldap-gid.cf"
		rlRun "cp /dev/shm/ldap-users.cf /etc/postfix/." 0 "copying over ldap-users.cf"
		rlRun "ipa user-add --first=tuserfirst --last=tuserlast --email=$testuseremail $testuser" 0 "add first user for testing with"
		testuser=utwo
		testuseremail="two@$DOMAIN"
		rlRun "ipa user-add --first=tuserfirst --last=tuserlast --email=$testuseremail $testuser" 0 "add second user for testing with"
		testuser=uthree
		testuseremail="three@$DOMAIN"
		rlRun "ipa user-add --first=tuserfirst --last=tuserlast --email=$testuseremail $testuser" 0 "add third user for testing with"
		/etc/init.d/sendmail stop
		/etc/init.d/postfix stop
		rlRun "/etc/init.d/postfix start" 0 "Starting the postfix service"	
	
}

setup-cyrus()
{
		mv /etc/imapd.conf /imapd.conf-backup
		rlRun "cp -a /dev/shm/imapd.conf /etc/." 0 "copying over ldap-users.conf"
		mv /etc/cyrus.conf /etc/cyrus.conf-backup
		rlRun "cp -a /dev/shm/cyrus.conf /etc/." 0 "copying over cyrus.conf"
		/etc/init.d/cyrus-imapd stop
		rlRun "/etc/init.d/cyrus-imapd start" 0 "Starting the cyrus service"	
		ipa user-add --first=user --last=one uone
		ipa user-add --first=user --last=two utwo
		ipa user-add --first=user --last=three uthree
		# set user cyrus password
		rlRun "echo $ADMINPW | saslpasswd2 cyrus" 0 "setting cyrus user password to admin password"
		# create script to create mailboxes
		echo 'cm testrelm.com!user.uone
cm testrelm.com!user.utwo
cm testrelm.com!user.uthree
cm testrelm.com!user.cyrus' > /dev/shm/create-users.txt
		rlRun "cyradm --user cyrus --auth login --pass $ADMINPW localhost < /dev/shm/create-users.txt" 0 "creating mailboxes for test users"
		echo 'mail from:mgregg@redhat.com
Subject: test
test' > /dev/shm/test-email.txt
		rlRun "/usr/sbin/sendmail uone@$DOMAIN < /dev/shm/test-email.txt" 0 "Sending a test email to user uone"

}
