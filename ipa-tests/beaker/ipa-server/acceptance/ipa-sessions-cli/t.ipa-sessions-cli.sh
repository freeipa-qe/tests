
u1=crtu1
u2=crtu2
u1pass=56tyguigy78
u2pass=9675656pass

read_session_id()
{
    local user=$1
    local sessionid=`keyctl list @s | grep ipa_session_cookie | grep $user | cut -d":"  -f1`
    if [ -z $sessionid ];then
        sleep 3
        sessionid=`keyctl list @s | grep ipa_session_cookie | grep $user | cut -d":"  -f1`
        echo $sessionid
    else
        echo $sessionid
    fi
}

######################
# test suite		 #
######################
ipa_sessions_cli()
{
	sessionscli_envsetup
	sessionscli_basic
	sessionscli_envcleanup
} 

######################
# test cases		 #
######################
sessionscli_envsetup()
{
	rlPhaseStartSetup "sessions_envsetup"
		#environment setup starts here
		KinitAsAdmin	
		create_ipauser $u1 user1 user1 $u1pass
		create_ipauser $u2 user1 user1 $u2pass

		#set up debug
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
		
}

sessionscli_basic()
{
	rlPhaseStartTest "ipa-sessions-001: kinit as u1 and verify that the keyring gets created"
		kdestroy
		#keyctl purge user # Fedora only command: Purging keys to be certain that the user-find populates the keyring properly.
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		KinitAsUser $u1 $u1pass
		rlRun "ipa user-find $u1" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s" 0 "DEBUG: keyctl list @s"
		rlRun "keyctl list -3" 0 "DEBUG:keyctl list -3"
		rlRun "keyctl show" 0 "DEBUG:keyctl show"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-002: clear local session keyring. Ensure that is appears cleared."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-003: Ensure that ipa commands seem to not find valid session keys"
		outf="$TmpDir/outfilea.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
		rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-004: Ensure that ipa commands do not successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
		rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-005: Ensure that ipa commands seem to find valid session keys now that the keyring should be populated"
		outf="$TmpDir/outfileb.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
		rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-006: Ensure that ipa commands does successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
		rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-007: kinit as u2 and verify that the keyring gets created"
		kdestroy
		KinitAsUser $u2 $u2pass
		rlRun "ipa user-find $u1" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s" 0 "DEBUG: ensure that the ipa session cookie was created"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-008: Clear local session keyring. Ensure that is appears cleared."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-009: Ensure that ipa commands seem to not find valid session keys"
		outf="$TmpDir/outfilec.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
		rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-010: Ensure that ipa commands do not successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
		rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-011: Ensure that ipa commands seem to find valid session keys now that the keyring should be populated"
		outf="$TmpDir/outfiled.txt"
		ipa user-find $u1 &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
		rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-012: Ensure that ipa commands does successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
		rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-013: Try it all again with host-find. First, clear local session keyring. Ensure that is appears cleared."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie" 1 "Make sure that session keyring appears clear"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-014: Ensure that ipa commands seem to not find valid session keys"
		outf="$TmpDir/outfilee.txt"
		ipa host-find $MASTER &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
		rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-015: Ensure that ipa commands do not successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
		rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-016: Ensure that ipa commands seem to find valid session keys now that the keyring should be populated"
		outf="$TmpDir/outfilef.txt"
		ipa host-find $MASTER &> $outf
		rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
		rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-017: Ensure that ipa commands does successfully find session keys"
		rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
		rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-018: Kinit as admin. Ensure that the keyring gets populated."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		kdestroy
		KinitAsAdmin
		ipa user-find $u1 &> /dev/null
        rlRun "keyctl list @s" 0 "DEBUG: Make sure that a admin key seems around keyctl"
        rlRun "keyctl list @s | grep ipa_session_cookie | grep admin" 0 "Make sure that a admin key seems around keyctl"
        
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-019: clear out admin keyring."
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep admin" 1 "Make sure that a admin key is not in the local keyring"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-020: Repopulate admin keyring"
		ipa user-find admin &> /dev/null
		rlRun "keyctl list @s" 0 "DEBUG: Make sure that a admin key seems around keyctl"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep admin" 0 "Make sure that a admin key seems around keyctl"
	rlPhaseEnd
	
	# This Section verifies that multiple principals are supported at the same time 
	rlPhaseStartTest "ipa-sessions-021: Populate keyring with keys from two different users"
		kdestroy
		#keyctl purge user # Fedora only command: Purging keys to be certain that the user-find populates the keyring properly.
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"
		KinitAsUser $u1 $u1pass
        
		ipa user-find $u1 &> /dev/null
		KinitAsUser $u2 $u2pass
		ipa user-find $u2 &> /dev/null
		rlRun "keyctl list @s" 0 "DEBUG: Verify that u1 and u2 has a valid session key"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "Verify that u1 has a valid session key"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u2" 0 "Verify that u2 has a valid session key"
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-022: Populate keyring for u1. restart ipa_memcache. Ensure that the ipa session id changes"
		kdestroy
        local user="$u1"
		KinitAsUser $u1 $u1pass
        
		rlRun "ipa user-find $u1 &> /dev/null" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s " 0 "ensure that the ipa session cookie was created"
		# Get current current session ID
        sessid=`read_session_id $user`
		rlLog "current session ID is [$sessid]"
        rlLog "restart both ipa_memcached and httpd to break current session keys"
		rlRun "service ipa_memcached restart"
		rlRun "service httpd restart"
		rlRun "ipa user-find $u1 &> /dev/null" 0 "rerun user find to generate new session ID"
        newsessid=`read_session_id $user`
		rlLog "new session ID is [$newsessid]"
        if [ "$sessid" = "$newsessid" ];then
            rlFail "ipa_memcached and httpd restart does not trigger new session id being issued for user [$u1]"
        else
            rlPass "ipa_memcached and httpd restart creates a new session id for user [$u1]"
        fi
		#rlRun "echo $newsessid | grep $sessid" 1 "make sure the old session is not the same as the current sessionid"
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-sessions-023: Populate keyring for admin. restart ipa_memcache. Ensure that the ipa session id changes"
		kdestroy
        local user="admin"
		KinitAsAdmin
        
		rlRun "ipa user-find $u1 &> /dev/null" 0 "user-find this user to populate the keyring"
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "ensure that the ipa session cookie was created"
		# Get current current session ID
        sessid=`read_session_id $user`
		rlLog "current session ID is [$sessid]"
        rlLog "restart both ipa_memcached and httpd to break current session keys"
		rlRun "service ipa_memcached restart"
		rlRun "service httpd restart"
		rlRun "ipa user-find $u1 &> /dev/null" 0 "rerun user find to generate new session ID"
        newsessid=`read_session_id $user`
		rlLog "new session ID is [$newsessid]"
        if [ "$sessid" = "$newsessid" ];then
            rlFail "ipa_memcached and httpd restart does not trigger new session id being issued for admin"
        else
            rlPass "ipa_memcached and httpd restart creates a new session id for admin"
        fi
	rlPhaseEnd
	
	rlPhaseStartTest "ipa-sessions-024: Create a valid keyring, then try issuing a command that will fallback to kerberos auth. Verify that the fallback happens"
		kdestroy
		#keyctl purge user # Fedora only command: Purging keys to be certain that the user-find populates the keyring properly.
		rlRun "keyctl clear @s" 0 "Clear local session keyring"
		rlRun "keyctl clear @u" 0 "Clear local user keyring"

		KinitAsUser $u1 $u1pass
		outf="$TmpDir/outfileg.txt"
        rlRun "service ipa_memcached restart"
		ipa -vv user-find $u1 &> $outf # running ipa user-find to populate the keyring. 
		rlRun "keyctl list @s | grep ipa_session_cookie | grep $u1" 0 "verify u1's ipa session cookie was created"
		rlRun "grep Authorization:\ negotiate $outf" 0 "This first user-find should complete a full kerberos auth."
		outf="$TmpDir/outfileh.txt"
        sleep 30 # after restart ipa_memcached, we need wait for 30 seconds till httpd re-establish the session via mem_cached
		ipa -vv user-find $u1 &> $outf # This command should work off of the current session.
		rlRun "grep Authorization:\ negotiate $outf" 0 "Re-verify that a normal user-find does not do a full kerberos auth, after 30 seconds"

		outf="$TmpDir/outfilei.txt"
		ipa -vv --delegate user-find &> $outf # this command should force a full kerberos auth
		rlRun "grep Authorization:\ negotiate $outf" 0 "ipa delegate should force a full kerberos auth. Verify that it happened."
	rlPhaseEnd		

	rlPhaseStartTest "ipa-sessions-025: If this test contains a slave, stop the server on the master."
		if [ -z $BEAKERSLAVE ]; then 
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

	rlPhaseStartTest "ipa-sessions-026: get a key for u1 on the slave and make sure that it works."
		if [ -z $BEAKERSLAVE ]; then 
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
				outf="$TmpDir/outfilej.txt"
				ipa user-find $u1 &> $outf
				rlRun "grep 'keyctl_search: Required key not available' $outf" 0 "look for session key lookup failure in output"
				rlRun "grep 'padd user' $outf" 0 "Ensure that keyctl seems to be populating local session key"
				rlRun "grep 'keyctl pipe' $outf" 1 "Ensure that keyctl pipe is not found"
				rlRun "grep 'keyctl pupdate' $outf" 1 "Ensure that keyctl update is not found"
				outf="$TmpDir/outfilek.txt"
				ipa user-find $u1 &> $outf
				rlRun "grep 'keyctl_search: Required key not available' $outf" 1 "look for session key lookup failure is not in output"
				rlRun "grep 'padd user' $outf" 1 "Ensure that keyctl is not populating local session key, as it should be popluated already."
				rlRun "grep 'keyctl pipe' $outf" 0 "Ensure that keyctl pipe is found"
				rlRun "grep 'keyctl pupdate' $outf" 0 "Ensure that keyctl update is found"
			fi
		fi
	rlPhaseEnd

	rlPhaseStartTest "ipa-sessions-027: Multi-host tests complete. Sync up and start master's IPA server again."
		if [ -z $BEAKERSLAVE ]; then 
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

sessionscli_envcleanup()
{
	rlPhaseStartCleanup "sessionscli_envcleanup"
		#environment cleanup starts here
		KinitAsAdmin
		delete_ipauser $u1
		delete_ipauser $u2
		rm -f /etc/ipa/server.conf-backup
		rlRun "mv /etc/ipa/server.conf /etc/ipa/server.conf-backup" 0 "copying server.conf to a backup"
		cat /etc/ipa/default.conf | grep -v debug > $TmpDir/default.conf
		rm -f /etc/ipa/default.conf
		rlRun "cp -a $TmpDir/default.conf /etc/ipa/default.conf" 0 "Restoring default.conf"
		rlRun "restorecon -Fvv /etc/ipa/default.conf" 0 "Restoring SELINUX content for default.conf"
		rlRun "/usr/sbin/ipactl restart" 0 "restarting IPA to disable debug mode"
		#environment cleanup ends   here
	rlPhaseEnd
}

