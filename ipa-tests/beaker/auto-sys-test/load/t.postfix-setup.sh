setup-dns()
{
	rlPhaseStartTest "add users and groups for use with dns setup"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		# Determine my IP address
		currenteth=$(route | grep ^default | awk '{print $8}')
		# get the ip address of that interface
		ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
		rlRun "ipa dnsrecord-add $DOMAIN @ --mx-rec '10 $ipaddr.'" 0 "add record type MX"
		rlRun "/etc/init.d/named restart" 0 "restart bind"
	rlPhaseEnd
}

setup-postfix()
{
	testuser=tuserone
	testuseremail="tuserone@$DOMAIN"
	rlPhaseStartTest "Setting up core postfix files"
		seconds=$(date +%s)
		rlRun "mv /etc/postfix/main.cf /etc/postfix/main.cf-backup-$seconds" 0 "backing up main.cf"
		rlRun "cp /dev/shm/main.cf /etc/postfix/." 0 "copying over main.cf"
		rlRun "rm -f /etc/postfix/ldap-*" 0 "removing any conf files from a previous run"
		rlRun "cp /dev/shm/ldap-uid.cf /etc/postfix/." 0 "copying over ldap-uid.cf"
		rlRun "cp /dev/shm/ldap-gid.cf /etc/postfix/." 0 "copying over ldap-gid.cf"
		rlRun "cp /dev/shm/ldap-users.cf /etc/postfix/." 0 "copying over ldap-users.cf"
		rlRun "ipa user-add --first=tuserfirst --last=tuserlast --email=$testuseremail $testuser" 0 "add user for testing with"
		
	
}
