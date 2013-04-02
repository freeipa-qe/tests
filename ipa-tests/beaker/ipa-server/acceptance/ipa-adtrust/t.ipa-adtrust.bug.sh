. ./adlib.sh


bz_866966() {

rlPhaseStartTest "Httpd is restarted when ipa-server-trust-ad package is installed/updated"
        rlRun "yum remove -y $rpm1" 0 "Remove existing ipa-server-trust-ad package"
	DATE1=$(ps -ef|grep httpd | tail -1 | awk '{print $5}'|sed 's/://g')
	rlRun "yum install -y $rpm1" 0 "Install ipa-server-trust-ad package"
	sleep 60
	DATE2=$(ps -ef|grep httpd | tail -1 | awk '{print $5}'|sed 's/://g')
	if [ "$DATE2" -gt "$DATE1" ];then 
		rlPass "Httpd is restarted as expected"
	else
		rlFail "Httpd failed to restart"
	fi
	rlRun "rpm -q --scripts freeipa-server-trust-ad|grep httpd|grep restart" 0 "Httpd is restarted as expected"
rlPhaseEnd

}

bz_924079() {

rlPhaseStartTest "Unattended install should use the default netbios name otherwise it prompts"
	rlRun "NB_Unattached" 0 "Creating expected script"
	rlRun "$exp $expfile  $adminpw" 0 "Unattended install succeeded  as expected"


}
