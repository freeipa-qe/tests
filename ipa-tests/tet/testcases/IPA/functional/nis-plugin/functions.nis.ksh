# locallib used by nis.ksh

EnableNIS()
{
# this function requires ipa server is running before execute
	pwfile="/tmp/pw.$RANDOM.txt"
	ssh root@${ipaserver} "echo $KERB_MASTER_PASS > $pwfile"
	ssh root@${ipaserver} "/sbin/service portmap start 2>&1 1>/dev/null "
	ssh root@${ipaserver} "ipa-compat-manage enable -y $pwfile"
	ssh root@${ipaserver} "ipa-nis-manage    enable -y $pwfile"
	ssh root@${ipaserver} "rm -f $pwfile"
	ssh root@${ipaserver} "service dirsrv restart 2>&1 1>/dev/null "
}


DisableNIS()
{
# this function requires ipa server is running before execute
	pwfile="/tmp/pw.$RANDOM.txt"
	ssh root@${ipaserver} "echo $KERB_MASTER_PASS > $pwfile"
	ssh root@${ipaserver} "/sbin/service portmap stop 2>&1 1>/dev/null "
	ssh root@${ipaserver} "ipa-compat-manage disable -y $pwfile"
	ssh root@${ipaserver} "ipa-nis-manage    disable -y $pwfile"
	ssh root@${ipaserver} "rm -f $pwfile"
	ssh root@${ipaserver} "service dirsrv restart 2>&1 1>/dev/null "
}
