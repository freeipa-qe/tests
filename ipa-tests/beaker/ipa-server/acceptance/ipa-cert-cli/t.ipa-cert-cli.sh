
u1=crtu1
u2=crtu2
u1pass=56tyguigy78
u2pass=56pass

######################
# test suite		 #
######################
certcli()
{
	certcli_envsetup
	certcli_basic
	certcli_envcleanup
} # certcli

######################
# test cases		 #
######################
certcli_envsetup()
{
	rlPhaseStartSetup "certcli_envsetup"
		#environment setup starts here
		KinitAsAdmin	
		create_ipauser $u1 user1 user1 $u1pass
		create_ipauser $u2 user1 user1 $u2pass
		#environment setup ends   here
	rlPhaseEnd
	rlPhaseStartTest "enable debug mode"
		if [ -f /etc/ipa/server.conf ]; then
			dc=$(date +%s)
			mv /etc/ipa/server.conf-original-$dc
		fi
		echo '[global]' >> /etc/ipa/server.conf
		echo 'debug=True' >> /etc/ipa/server.conf
		rlRun "/usr/sbin/ipactl restart" 0 "restarting IPA to enable debug mode"
	rlPhaseEnd
		
} #certcli_envsetup

certcli_basic()
{
	rlPhaseStartTest "kinit as u1 and verify that the keyring gets created"
		kdestroy
		KinitAs $u1 $u1pass
		rlRun "ipa user-find $u1" 0 "show this user to populate the keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 0 "ensure that the ipa session cookie was created"
	rlPhaseEnd

}

certcli_envcleanup()
{
	rlPhaseStartCleanup "certcli_envcleanup"
		#environment cleanup starts here
		KinitAsAdmin
		delete_ipauser $u1
		delete_ipauser $u2
		rm -f /etc/ipa/server.conf-backup
		rlRun "mv /etc/ipa/server.conf /etc/ipa/server.conf-backup" 0 "copying server.conf to a backup"
		rlRun "/usr/sbin/ipactl restart" 0 "restarting IPA to disable debug mode"
		#environment cleanup ends   here
	rlPhaseEnd
} #certcli_envcleanup

