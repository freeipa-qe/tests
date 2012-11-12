
u1=crtu1
u2=crtu2
u1pass=56tyguigy78
u2pass=9675656pass

######################
# test suite		 #
######################
ipa_cert_cli()
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
			mv /etc/ipa/server.conf /etc/ipa/server.conf-original-${dc}
		fi
		if [ -f /etc/ipa/default.conf-original-${dc} ]; then
			rm -f /etc/ipa/default.conf-original-${dc}
		fi		
		mv /etc/ipa/server.conf /etc/ipa/default.conf-original-${dc}
		echo '[global]' >> /etc/ipa/server.conf
		echo 'debug=True' >> /etc/ipa/server.conf
		echo 'debug=True' >> /etc/ipa/default.conf
		rlRun "/usr/sbin/ipactl restart" 0 "restarting IPA to enable debug mode"
	rlPhaseEnd
		
} #certcli_envsetup

certcli_basic()
{
	rlPhaseStartTest "kinit as u1 and verify that the keyring gets created"
		kdestroy
		keyctl purge user # Purging keys to be certain that the user-find populates the keyring properly.
		KinitAsUser $u1 $u1pass
		rlRun "ipa user-find $u1" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
	rlPhaseEnd

	rlPhaseStartTest "clear local session keyring. Ensure that is appears cleared."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands seem to not find valid session keys"
		outf="/dev/shm/outfilea.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
		rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands do not successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
		rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands seem to find valid session keys now that the keyring should be populated"
		outf="/dev/shm/outfileb.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
		rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands does successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
		rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
	rlPhaseEnd

	rlPhaseStartTest "kinit as u2 and verify that the keyring gets created"
		kdestroy
		KinitAsUser $u2 $u2pass
		rlRun "ipa user-find $u1" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
	rlPhaseEnd

	rlPhaseStartTest "Clear local session keyring. Ensure that is appears cleared."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands seem to not find valid session keys"
		outf="/dev/shm/outfilec.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
		rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands do not successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
		rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands seem to find valid session keys now that the keyring should be populated"
		outf="/dev/shm/outfiled.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
		rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands does successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
		rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
	rlPhaseEnd

	rlPhaseStartTest "Try it all again with host-find. First, clear local session keyring. Ensure that is appears cleared."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands seem to not find valid session keys"
		outf="/dev/shm/outfilee.txt"
		ipa host-find $MASTER &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
		rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands do not successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
		rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands seem to find valid session keys now that the keyring should be populated"
		outf="/dev/shm/outfilef.txt"
		ipa host-find $MASTER &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
		rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
	rlPhaseEnd

	rlPhaseStartTest "Ensure that ipa commands does successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
		rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
	rlPhaseEnd

	rlPhaseStartTest "Kinit as admin. Ensure that the keyring gets populated."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		kdestroy
		KinitAsAdmin
		ipa user-find $u1 &> /dev/null
        rlRun "keyctl list @s | grep ipa_session_cookie | grep admin" 0 "Make sure that a admin key seems around keyctl"
	rlPhaseEnd

	rlPhaseStartTest "clear out admin keyring."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep admin" 1 "Make sure that a admin key is not in the local keyring"
	rlPhaseEnd

	rlPhaseStartTest "Repopulate admin keyring"
		ipa user-find admin &> /dev/null
		rlRun "keyctl list @s | grep ipa_session_cookie | grep admin" 0 "Make sure that a admin key seems around keyctl"
	rlPhaseEnd
	
	# This Section verifies that multiple principals are supported at the same time 
	rlPhaseStartTest "Populate keyring with keys from two different users"
		kdestroy
		keyctl purge user # Purging keys to be certain that the user-find populates the keyring properly.
		KinitAsUser $u1 $u1pass
		ipa user-find $u1 &> /dev/null
		KinitAsUser $u2 $u2pass
		ipa user-find $u2 &> /dev/null
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "Verify that u1 has a valid session key"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u2" 0 "Verify that u2 has a valid session key"
	rlPhaseEnd

	rlPhaseStartTest "Populate keyring for u1. restart ipa_memcache. Ensure that the ipa session id changes"
		kdestroy
		KinitAsUser $u1 $u1pass
		rlRun "ipa user-find $u1 &> /dev/null" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
		# Get current current session ID
		sessid=$(keyctl list @s | grep ipa_session_cookie | grep $u1 |cut -d\  -f1)
		if [ -x $sessid	]; then
			# sometimes the grep and cut do not work, do it again.
			sleep 1
			sessid=$(keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1)
		fi
		rlLog "current session ID is $sessid"
		#rlRun "/bin/systemctl restart ipa_memcached.service" 0 "Restart memcached to break current session keys"
		rlRun "service ipa_memcached restart" 0 "Restart memcached to break current session keys"
		rlRun "ipa user-find $u1 &> /dev/null" 0 "rerun user find to generate new session ID"
		newsessid=$(keyctl list @s | grep ipa_session_cookie | grep $u1 |cut -d\  -f1) # Get new session ID
		if [ -x $newsessid	]; then
			# sometimes the grep and cut do not work, do it again.
			sleep 1
			newsessid=$(keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1)
		fi
		rlLog "new session ID is $newsessid"
		rlRun "echo $newsessid | grep $sessid" 1 "make sure the old session is not the same as the current sessionid"
	rlPhaseEnd
	
	rlPhaseStartTest "Populate keyring for admin. restart ipa_memcache. Ensure that the ipa session id changes"
		kdestroy
		KinitAsAdmin
		rlRun "ipa user-find $u1 &> /dev/null" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
		# Get current current session ID
		sessid=$(keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1)
		if [ -x $sessid	]; then
			# sometimes the grep and cut do not work, do it again.
			sleep 3
			sessid=$(keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1)
		fi
		keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1
		rlLog "current session ID is $sessid"
		#rlRun "/bin/systemctl restart ipa_memcached.service" 0 "Restart memcached to break current session keys"
		rlRun "service ipa_memcached restart" 0 "Restart memcached to break current session keys"
		rlRun "ipa user-find $u1 &> /dev/null" 0 "rerun user find to generate new session ID"
		newsessid=$(keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1) # Get new session ID
		if [ -x $newsessid	]; then
			# sometimes the grep and cut do not work, do it again.
			sleep 3
			newsessid=$(keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1)
		fi
		keyctl list @s | grep ipa_session_cookie | grep admin |cut -d\  -f1
		rlLog "new session ID is $newsessid"
		rlRun "echo $newsessid | grep $sessid" 1 "make sure the old session is not the same as the current sessionid"
	rlPhaseEnd
	
	rlPhaseStartTest "Create a valid keyring, then try issuing a command that will fallback to kerberos auth. Verify that the fallback happens"
		rlLog "This test tends to fail on the following bug https://fedorahosted.org/freeipa/ticket/2331"
		kdestroy
		keyctl purge user # Purging keys to be certain that the user-find populates the keyring properly.
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		KinitAsUser $u1 $u1pass
		outf="/dev/shm/outfileg.txt"
		ipa -vv user-find $u1 &> $outf # running ipa user-find to populate the keyring. 
		ipa user-find admin &> /dev/null
		sleep 5
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "verify u1's ipa session cookie was created"
		rlRun "grep Authorization:\ negotiate $outf" 0 "This first user-find should complete a full kerberos auth."
		outf="/dev/shm/outfileh.txt"
		sleep 5
		ipa -vv user-find $u1 &>/dev/shm/1
        sleep 3
		ipa -vv user-find $u1 &> $outf # This command should work off of the current session.
		ipa -vv user-find $u1 &>/dev/shm/2
		#ipa -vv user-find $u1 &>/dev/shm/3
		#sleep 30
		#ipa -vv user-find $u1 &>/dev/shm/4
		#sleep 30
		#ipa -vv user-find $u1 &>/dev/shm/5

		rlRun "grep Authorization:\ negotiate $outf" 1 "Re-verify that a normal user-find does not do a full kerberos auth"
        rlLog "yi debug starts"
        rlLog ";:::::::::::::::::: 1 :::::::::::::::::::::::"
        cat /dev/shm/1
        rlLog "::::::::::::::::::: outfile :::::::::::::::::"
        cat $outf
        rlLog "::::::::::::::::::: 2 :::::::::::::::::::::::"
        cat /dev/shm/2
        rlLog "yi debug end"
		outf="/dev/shm/outfilei.txt"
		ipa -vv --delegate user-find &> $outf # this command should force a full kerberos auth
		rlRun "grep Authorization:\ negotiate $outf" 0 "ipa delegate should force a full kerberos auth. Verify that it happened."
	rlPhaseEnd		

	rlPhaseStartTest "If this test contains a slave, stop the server on the master."
		if [ -x $BEAKERSLAVE ]; then 
			rlLog "This test does not contain a slave. Not runnign multimaster tests."
			rlPass "test passed"
		else
			rlLog "This test contains a Slave. Running multimaster tests"
			hn=$(hostname -s)
			echo $MASTER | grep $hn
			if [ $? -eq 0 ]; then
				export thishost="master"
			fi
			if [ $thishost -eq "master" ]; then
				# This is the master, stop the master and continue
				rlRun "/usr/sbin/ipactl stop" 0 "restarting IPA to enable debug mode"
				rlRun "rhts-sync-set -s 'multicertcli.starttests' -m $BEAKERMASTER"
			else 
				# This host is a slave
				rlRun "rhts-sync-block -s 'multicertcli.starttests' $BEAKERMASTER"
			fi

		fi
	rlPhaseEnd

	rlPhaseStartTest "get a key for u1 on the slave and make sure that it works."
		if [ -x $BEAKERSLAVE ]; then 
			rlLog "This test does not contain a slave. Not runnign multimaster tests."
			rlPass "test passed"
		else
			rlLog "This test contains a Slave. Running multimaster tests"
			if [ $thishost -eq "master" ]; then
				rlLog "Test not run on the master"
			else
				kdestroy
				KinitAsUser $u1 $u1pass
				rlRun "ipa user-find $u1" 0 "user-find this user to populate the keyring"
				rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
				rlRun "keyctl clear @s" 0 "Clear local session keyring"
				rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
				outf="/dev/shm/outfilej.txt"
				ipa user-find $u1 &> $outf
				rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
				rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
				rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
				rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
				outf="/dev/shm/outfilek.txt"
				ipa user-find $u1 &> $outf
				rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
				rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
				rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
				rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
			fi
		fi
	rlPhaseEnd

	rlPhaseStartTest "Multi-host tests complete. Sync up and start master's IPA server again."
		if [ -x $BEAKERSLAVE ]; then 
			rlLog "This test does not contain a slave. Not runnign multimaster tests."
			rlPass "test passed"
		else
			rlLog "This test contains a Slave. Running multimaster tests"
			if [ $thishost -eq "master" ]; then
				rlRun "rhts-sync-set -s 'multicertcli.finishtests' -m $BEAKERMASTER"
				rlRun "/usr/sbin/ipactl stop" 0 "restarting IPA to enable debug mode"
			else
				rlRun "rhts-sync-block -s 'multicertcli.finishtests' $BEAKERMASTER"
			fi
		fi
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
		cat /etc/ipa/default.conf | grep -v debug > /dev/shm/default.conf
		rm -f /etc/ipa/default.conf
		rlRun "cp -a /dev/shm/default.conf /etc/ipa/default.conf" 0 "Restoring default.conf"
		rlRun "/usr/sbin/ipactl restart" 0 "restarting IPA to disable debug mode"
		#environment cleanup ends   here
	rlPhaseEnd
} #certcli_envcleanup

