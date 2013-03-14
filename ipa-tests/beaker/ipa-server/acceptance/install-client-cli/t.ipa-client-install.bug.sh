#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.ipa-client-install.bug.sh of /CoreOS/ipa-server/acceptance/install-client-cli
#   Description: IPA Client Install and Uninstall bug tests
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ipaclientinstall_bugcheck_905626()
{
	ipalog=/var/log/ipaclient-install.log
	#rlAssertNotGrep "Installation failed." $ipalog
	rlAssertNotGrep "Can't contact LDAP server" $ipalog
	rlAssertNotGrep "Failed to verify that.*is an IPA Server" $ipalog
	if [ $? -gt 0 ]; then
		rlFail "BZ 905626 found...ipa-client-install failed to fall over to replica with master down"
	else
		rlPass "BZ 905626 not found"
	fi
}

ipaclientinstall_bugcheck_845691()
{
	rlPhaseStartTest "ipaclientinstall_bugcheck_845691 - ipa-client-install Failed to obtain host TGT"	
		CHK1=$(grep "kinit: Preauthentication failed while getting initial credentials" /var/log/ipaclient-install.log|wc -l)
		if [ $CHK1 -gt 0 ]; then
			rlLog "[FAIL1] BZ 845691 found...ipa-client-install Failed to obtain host TGT"
			submit_log /var/log/ipaclient-install.log
			#rlRun "mail -s BZ845691 spoore@redhat.com </dev/null"
			#rlRun "sleep 86400"
		fi

		CHK2=$(grep "kinit: Client.*not found in Kerberos database while getting initial credentials" /var/log/ipaclient-install.log|wc -l)
		if [ $CHK2 -gt 0 ]; then
			rlLog "[FAIL2] BZ 845691 found...ipa-client-install Failed to obtain host TGT"
			submit_log /var/log/ipaclient-install.log
			#rlRun "mail -s BZ845691 spoore@redhat.com </dev/null"
			#rlRun "sleep 86400"
		fi
	rlPhaseEnd
}

ipaclientinstall_bugcheck_845691_fulltest()
{
	tmpout=/tmp/bz845691.testout
	SLAVE_S=$(echo $SLAVE|cut -f1 -d.)
	MASTER_S=$(echo $MASTER|cut -f1 -d.)
	rlPhaseStartTest "ipaclientinstall_bugcheck_845691_fulltest - ipa-client-install Failed to obtain host TGT"	
			
		uninstall_fornexttest
		rlRun "ssh $MASTER \"echo $ADMINPW|kinit admin\""
		for REC in '_kerberos-master._tcp:88' '_kerberos-master._udp:88' '_kerberos._tcp:88' '_kerberos._udp:88' '_kpasswd._tcp:464' '_kpasswd._udp:464'; do
			REC_NAME=$(echo $REC|cut -f1 -d:)
			REC_PORT=$(echo $REC|cut -f2 -d:)
			REC_ENTRY="0 100 $REC_PORT $SLAVE_S"
			rlRun "ssh $MASTER \"ipa dnsrecord-mod $DOMAIN $REC_NAME --srv-rec='$REC_ENTRY'\""	
		done
		rlRun "ssh $MASTER \"ipa dnsrecord-mod $DOMAIN _ldap._tcp --srv-rec='0 100 389 $MASTER_S'\""

		rlRun "ssh $MASTER \"service iptables stop\""
		rlRun "ssh $MASTER \"iptables -A INPUT -j DROP -p all --source $SLAVEIP\""
		
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER > $tmpout 2>&1" 0 "Installing ipa client and configuring - with all params"
		if [ $(grep "Failed to obtain host TGT" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 845691 found...ipa-client-install Failed to obtain host TGT"
		else
			rlPass "BZ 845691 not found"
		fi

		CHK1=$(grep "kinit: Preauthentication failed while getting initial credentials" /var/log/ipaclient-install.log|wc -l)
		if [ $CHK1 -gt 0 ]; then
			rlLog "[FAIL1] BZ 845691 found...ipa-client-install Failed to obtain host TGT"
			submit_log /var/log/ipaclient-install.log
		fi

		CHK2=$(grep "kinit: Client.*not found in Kerberos database while getting initial credentials" /var/log/ipaclient-install.log|wc -l)
		if [ $CHK2 -gt 0 ]; then
			rlLog "[FAIL2] BZ 845691 found...ipa-client-install Failed to obtain host TGT"
			submit_log /var/log/ipaclient-install.log
		fi

		rlLog "Putting MASTER DNS and Firewall settings back"
		for i in $SLAVE; do
			SLAVE_S_ALL="$SLAVE_S_ALL $(echo $i|cut -f1 -d.)"
		done	
		SRVS="$MASTER_S $SLAVE_S_ALL"
		for REC in '_kerberos-master._tcp:88' '_kerberos-master._udp:88' '_kerberos._tcp:88' '_kerberos._udp:88' '_kpasswd._tcp:464' '_kpasswd._udp:464'; do
			REC_NAME=$(echo $REC|cut -f1 -d:)
			REC_PORT=$(echo $REC|cut -f2 -d:)
			REC_ENTRY=""
			for SRV in $SRVS; do
				REC_ENTRY="$REC_ENTRY, 0 100 $REC_PORT $SRV"
			done
			REC_ENTRY=$(echo $REC_ENTRY|sed 's/^, //')
			rlRun "ssh $MASTER \"ipa dnsrecord-mod $DOMAIN $REC_NAME --srv-rec='$REC_ENTRY'\""	
		done
		REC_NAME="_ldap._tcp"
		REC_PORT=389
		REC_ENTRY=""
		for SRV in $SRVS; do
			REC_ENTRY="$REC_ENTRY, 0 100 $REC_PORT $SRV"
		done
		REC_ENTRY=$(echo $REC_ENTRY|sed 's/^, //')
		rlRun "ssh $MASTER \"ipa dnsrecord-mod $DOMAIN $REC_NAME --srv-rec='$REC_ENTRY'\""
		rlRun "ssh $MASTER \"service iptables stop\""
	
	rlPhaseEnd
}
	
###############################################################################################
#  Bug 817869 - Clean keytabs before installing new keys into them
###############################################################################################
ipaclientinstall_dirty_keytab()
{
	local tmpout=/tmp/ipaclientinstall_dirty_keytab.out
    rlPhaseStartTest "ipa_client_install-39 - Install with a dirty keytab"
        rlLog "Test for BZ 817869, install ipa-client with a dirty keytab"
        uninstall_fornexttest
        # Backup keytab 
        bkup="/dev/shm/ipa-client-backup-keytab"
        ktab="/etc/krb5.keytab"
		rlRun "scp $MASTER:/etc/krb5.keytab /etc/krb5.keytab"
        cp -a $ktab $bkup

        rlRun "klist -kt /etc/krb5.keytab|grep 'host/$MASTER'"

        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 \
            "Installing ipa client and configuring - with all params"
        verify_install true

        rlRun "klist -kt /etc/krb5.keytab|grep 'host/$(hostname)' > $tmpout 2>&1"
        diff $bkup $ktab
        if [ $? -eq 0 ]; then 
            rlFail "FAIL - $bkup and $ktab match when they should not."
            cont=$(cat $bkup)
            rlLog "Contents of $bkup are $cont"
            cont=$(cat $ktab)
            rlLog "Contents of $ktab are $cont"
        fi
    rlPhaseEnd
}

ipaclientinstall_bugcheck_910410()
{
    S1="$1" ; S2="$2" ; S3="$3" ; S4="$4"
    CHK1=$(grep "ipa_server.*$S1.*$S2.*$S3.*$S4" $SSSD|wc -l) 
    CHK2=$(grep "ipa_server" $SSSD|grep "$S1"|grep "$S2"|grep "$S3"|grep "$S4"|wc -l)
    if [ $CHK1 -eq $CHK2 ]; then
        rlPass "BZ 910410 not found...ipa_server line in correct order"
    else
        rlFail "BZ 910410 found..ipa-client-install fixed-primary server list out of order in sssd.conf"
    fi
}


ipaclientinstall_bugcheck_790105()
{
        #Installing client
        uninstall_fornexttest

        sssd_log_file="/var/log/sssd/sssd_testrelm.com.log"

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER --enable-dns-updates --mkhomedir"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER --enable-dns-updates --mkhomedir" 0 "Installing ipa client and configuring - with all params"

        #Configuring sssd to pick lo interface for loopback addresses for dynamic dns update
        rlRun "sed '/cache_credentials/ a debug_level = 0x200' $SSSD > /tmp/sssd.conf"
        rlRun "cp /tmp/sssd.conf $SSSD"
        rlRun "sed '/ipa_dyndns_update/ a ipa_dyndns_iface = lo' $SSSD > /tmp/sssd.conf"
        rlRun "cp /tmp/sssd.conf $SSSD"
        rlRun "cat $SSSD"
        rlRun "service sssd restart"

        exp=/tmp/expfile.out
        local cmd="ssh admin@localhost"
        echo "set timeout 5" > $exp
        echo "set force_conservative 0" >> $exp
        echo "set send_slow {1 .1}" >> $exp
        echo "spawn $cmd" >> $exp
        echo 'expect "*assword: "' >> $exp
        echo "send -s -- \"\r\"" >> $exp
        echo 'expect "*assword: "' >> $exp
        echo "send -s -- \"\r\"" >> $exp
        echo 'expect "*assword: "' >> $exp
        echo "send -s -- \"\r\"" >> $exp
        echo 'expect eof ' >> $exp
        /usr/bin/expect $exp
        
        rlAssertGrep "\[ok_for_dns\] (0x0200): Loopback IPv4 address" "$sssd_log_file"
        rlAssertGrep "\[ok_for_dns\] (0x0200): Loopback IPv6 address" "$sssd_log_file"

        #Configuring sssd to pick eth0 interface for link-local ipv6 address for dynamic dns update
        rlRun "sed 's/ipa_dyndns_iface = lo/ipa_dyndns_iface = eth0/' $SSSD > /tmp/sssd.conf"
        rlRun "cp /tmp/sssd.conf $SSSD"
        rlRun "cat $SSSD"
        rlRun "service sssd restart"

        exp=/tmp/expfile.out
        local cmd="ssh admin@localhost"
        echo "set timeout 5" > $exp
        echo "set force_conservative 0" >> $exp
        echo "set send_slow {1 .1}" >> $exp
        echo "spawn $cmd" >> $exp
        echo 'expect "*assword: "' >> $exp
        echo "send -s -- \"\r\"" >> $exp
        echo 'expect "*assword: "' >> $exp
        echo "send -s -- \"\r\"" >> $exp
        echo 'expect "*assword: "' >> $exp
        echo "send -s -- \"\r\"" >> $exp
        echo 'expect eof ' >> $exp
        /usr/bin/expect $exp
 
        rlAssertGrep "\[ok_for_dns\] (0x0200): Link local IPv6 address" "$sssd_log_file"

}

ipaclientinstall_bugcheck_817030()
{

        rlPhaseStartTest "BZ-817030 ipa-client-install sets "KerberosAuthenticate no" in sshd.conf"
        #Installing client
        uninstall_fornexttest

        sshd_config="/etc/ssh/sshd_config"
        #rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"

        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER --enable-dns-updates --mkhomedir"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER --enable-dns-updates --mkhomedir" 0 "Installing ipa client and configuring - with all params"

        #Checking sshd_config does not contains "KerberosAuthentication yes"
 
        rlAssertGrep "KerberosAuthentication no" "$sshd_config"

	#Modifying sssd config for kerberos renewal 
	
	SSSD=/etc/sssd/sssd.conf
	rlRun "sed '/cache_credentials/ a krb5_renewable_lifetime = 5d' $SSSD > /tmp/sssd.conf;cp /tmp/sssd.conf $SSSD"
	rlRun "sed '/cache_credentials/ a krb5_renew_interval = 500' $SSSD > /tmp/sssd.conf;cp /tmp/sssd.conf $SSSD"
	rlRun "service sssd restart"
		
        klist_before=/tmp/klist_before.out
        klist_after=/tmp/klist_after.out
        klist_diff=/tmp/klist_diff.out
        userpw="Secret123"

        cat > /tmp/sudo_list.exp << EOF
#!/usr/bin/expect -f

set timeout 30
set send_slow {1 .1}
match_max 100000

spawn ssh -o StrictHostKeyChecking=no -l admin localhost
expect "*: "
send -s "$userpw\r"
expect "*$ "
send -s "klist > $klist_before 2>&1 \r"
expect "*$ "
send -s "kinit -R\r"
expect "*$ "
send -s "klist > $klist_after 2>&1 \r"
expect eof
EOF

	chmod 755 /tmp/sudo_list.exp
	cat /tmp/sudo_list.exp
	/tmp/sudo_list.exp
        rlRun "cat $klist_before"
        rlRun "cat $klist_after"
        rlRun "diff $klist_before $klist_after > $klist_diff" 1 
        rlRun "cat $klist_diff"
        if [ -s $klist_diff ] ; then
           rlPass "Kerberos tkt is renewed"
        else
           rlFail "Kerberos tkt renewal failed"
        fi
        rlRun "rm -rf /tmp/sudo_list.exp /tmp/klist*"
   rlPhaseEnd
}

