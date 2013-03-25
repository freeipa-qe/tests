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
        bkup="/opt/rhqa_ipa/ipa-client-backup-keytab"
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
ipaclientinstall_bugcheck_767725()
{

        rlPhaseStartTest "BZ-767725 GSS-TSIG DNS updates should update reverse entries as well"
        #Installing client
        uninstall_fornexttest

        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER --enable-dns-updates" 0 "Installing ipa client and configuring - with all params"

        TmpDir=`mktemp -d`
        #Checking existence of ipa-admintools
        rpm -q ipa-admintools
        if [ $? -eq 0 ] ; then
         rlLog "ipa-admintools is installed"
        else
         rlRun "yum install ipa-admintools -y" 0 "Installing ipa-admintools"
        fi

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"

        client_ip=`ip addr|grep brd|grep inet|cut -d "/" -f1|cut -d " " -f6`

        client_ptr=`echo $client_ip|cut -d "." -f4`
        client_revzone=$(echo $client_ip|awk -F. '{print $3 "." $2 "." $1 ".in-addr.arpa."}')
        client_hostnamepart=`hostname|cut -d "." -f1`
        client_newptr=`expr $client_ptr + 1`
        client_newip=$(echo $client_ip|awk -F. '{print $1 "." $2 "." $3 "."$4+1}')

        rlRun "ipa dnsrecord-add $client_revzone $client_ptr --ptr-rec $CLIENT."
        rlRun "ipa dnszone-mod $DOMAIN --allow-sync-ptr=1"

        rlRun "ipa dnsrecord-find $DOMAIN $client_hostnamepart > $TmpDir/output.txt"
        rlRun "cat $TmpDir/output.txt"
        rlAssertGrep "Record name: $client_hostnamepart" "$TmpDir/output.txt"

        rlRun "ipa dnsrecord-find $client_revzone $client_hostnamepart > $TmpDir/output.txt"
        rlRun "cat $TmpDir/output.txt"
        rlAssertGrep "Record name: $client_ptr" "$TmpDir/output.txt"

        #rlRun "/usr/bin/kinit -k -t /etc/krb5.keytab host/`hostname`"
        rlRun "/usr/bin/kinit -k -t /etc/krb5.keytab"
        rlRun "klist > $TmpDir/output.txt"
        rlRun "cat $TmpDir/output.txt"

        nsupdate=$TmpDir/nsupdate.txt
        echo "zone $DOMAIN" > $nsupdate
        echo "update delete `hostname` IN A " >> $nsupdate
        echo "update add `hostname` 86400 IN A $client_newip " >> $nsupdate
        echo "send" >> $nsupdate

        rlRun "cat $nsupdate"
        rlRun "nsupdate -dg $nsupdate > $TmpDir/nsoutput.txt"
        rlRun "cat $TmpDir/nsoutput.txt"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "ipa dnsrecord-find $DOMAIN $client_hostnamepart > $TmpDir/output.txt"
        rlRun "cat $TmpDir/output.txt"
        rlAssertGrep "A record: $client_newip" "$TmpDir/output.txt"

        rlRun "ipa dnsrecord-find $client_revzone $client_hostnamepart > $TmpDir/output.txt"
        rlRun "cat $TmpDir/output.txt"
        rlAssertGrep "Record name: $client_newptr" "$TmpDir/output.txt"

        rlPhaseEnd
}

ipa_bug_verification(){
    ipa-client-install --uninstall -U
    bug_833505
    bug_813387
    bug_805203
    bug_831010
    bug_883166
    ipa-client-install --uninstall -U
}

bug_833505(){
    rlPhaseStartTest "bug automation 833505"
        local original="/etc/sysconfig/network"
        local preserv="/tmp/network.$RANDOM"
        rlRun "mv -fv $original $preserv" 0 "move [$original] to [$preserv]"
        #install ipa client as noted in bug report
        ipa-client-install --hostname=`hostname` --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER -U
        if [ "$?" = "0" ];then
            rlPass "ipa client install with missing $original and use --hostname success"
            rlRun "mv $preserv $original" 0 "restore $original file"
            uninstall_ipa_client
        else
            rlFail "ipa client install with missing $original and use --hotname failed"
        fi
    rlPhaseEnd
}

bug_813387(){
    rlPhaseStartTest "bug automation 813387"
        # preserv the network file: /etc/sysconfig/network
        local original="/etc/sysconfig/network"
        local preserv="/tmp/network.$RANDOM"
        rlRun "cp -fv $original $preserv" 0 "copy $original to $preserv"
        #install ipa client as noted in bug report
        rlRun "ipa-client-install --no-ntp --force --hostname=`hostname` --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER -U" 
        if diff $preserv $original
        then
            rlFail "the original network file $original has been modified after ipa client install"
            echo "========== original content from preserved file [$preserv] ==========="
            cat $preseerv
            echo "========== current content [$original] ==============================="
            cat $original
        else
            rlPass "the original network file $origianl is untouched before and after ipa client install"
            uninstall_ipa_client
        fi
    rlPhaseEnd    
}

bug_805203(){
    rlPhaseStartTest "bug automation 805203"
        local sssd_conf="/etc/sssd/sssd.conf"
        if ipa-client-install  --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER -U
        then
            if grep "^ipa_hostname" $sssd_conf
            then
                rlPass "ipa_hostname has been set in $sssd_conf file"
            else
                rlFail "ipa_hostname does not being set in sssd conf file [$sssd_conf]"
            fi
            echo "========== [$sssd_conf] ===================="
            cat $sssd_conf
            echo "=============================================="
            uninstall_ipa_client
        else
            rlFail "ipa-client-install failed, test can not continue"
        fi
    rlPhaseEnd
}

bug_831010(){
    rlPhaseStartTest "bug automation 831010"
        local sssd_conf="/etc/sssd/sssd.conf"
        if ipa-client-install  --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER --fixed-primary -U
        then
            # expect a line like "ipa_server =  <ipa master>" NO "_srv_" appears
            if grep "^ipa_server" $sssd_conf | grep "_srv_"
            then
                rlFail "found _srv_ record in $sssd_conf file, this is NOT expected when --fixed-primary option used in ipa client install"
            else
                rlPass "no _srv_ record found in $sssd_conf file, test pass"
            fi
            echo "========== [$sssd_conf] ===================="
            cat $sssd_conf
            echo "=============================================="
            uninstall_ipa_client
        else
            rlFail "ipa-client-install failed, test can not continue"
        fi       
    rlPhaseEnd
}

bug_883166(){
    rlPhaseStartTest "bug automation 883166"
        local sys_file_to_check="/etc/krb5.conf"
        local desired_line="includedir /var/lib/sss/pubconf/krb5.include.d/"
        if ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER -U
        then
            if grep "^$desired_line" $sys_file_to_check
            then
                rlPass "subdirectory [includedir /var/lib/sss/pubconf/krb5.include.d/] has detected in $sys_file_to_check file"
            else
                rlFail "subdirectory [includedir /var/lib/sss/pubconf/krb5.include.d/] not found in $sys_file_to_check file"
            fi
            echo "========== [$sys_file_to_check] ===================="
            cat $sys_file_to_check
            echo "=============================================="
            uninstall_ipa_client
        else
            rlFail "ipa-client-install failed, test can not continue"
        fi
    rlPhaseEnd
}
