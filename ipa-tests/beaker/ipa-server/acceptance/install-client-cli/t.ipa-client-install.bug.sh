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

ipaclientinstall_bugcheck_845691()
{
	rlPhaseStartTest "ipaclientinstall_bugcheck_845691 - ipa-client-install Failed to obtain host TGT"	
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
	rlPhaseEnd
}

ipaclientinstall_bugcheck_845691_fulltest()
{
	tmpout=/tmp/bz845691.testout
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
		SRVS="$MASTER_S $SLAVE_S"
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
    rlPhaseStartTest "ipa_client_install-39 - Install with a dirty keytab"
        rlLog "Test for BZ 817869, install ipa-client with a dirty keytab"
        uninstall_fornexttest
        #rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        #rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM --ntp-server=$NTPSERVER -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        rlLog "EXECUTING: ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER"
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        verify_install true
        # Backup keytab 
        bkup="/dev/shm/ipa-client-backup-keytab"
        ktab="/etc/krb5.keytab"
        rm -f $bkup
        cp -a $ktab $bkup
        # Now uninstall
        uninstall_fornexttest
        verify_install false 

        rlLog "$command"
        rlRun "$command" 0 "Uninstalling ipa client - after a force install"
        rm -f $ktab
        if [ ! -f $ktab ]; then
            cp -a $kbup $ktab
        fi

        klist -kt /etc/krb5.keytab
        rlRun "ipa-client-install --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --unattended --server=$MASTER" 0 "Installing ipa client and configuring - with all params"
        verify_install true

        klist -kt /etc/krb5.keytab
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

