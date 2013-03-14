# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.replica-install.bug.sh of /CoreOS/ipa-tests/acceptance/ipa-replica-install
#   Description: IPA Replica install BZ tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: 
#        Scott Poore <spoore@redhat.com>
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

# Include data-driven test data file:

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. ./install-lib.sh


# BZ 784696 Don't set nsds5replicaupdateschedule in replication agreements
replicaBugCheck_bz784696()
{
	rlPhaseStartTest "bugCheck_bz784696: Dont set nsds5replicaupdateschedule in replication agreements"
		rlLog "First run ipa user-find on MASTER"
		remoteExec root $MASTERIP "ipa user-find"
		rlLog "Quick checks confirming replication.  Add on Master, Check on Replica"
		remoteExec root $MASTERIP "ipa user-add test1 --first=First --last=Last"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa user-show test1"
		rlRun "sleep 60"
		remoteExec root $MASTERIP "ipa user-add newtest2 --first=First2 --last=Last2"
		[ $(uname -i) = "i386" ] && rlRun "sleep 30"
		rlRun "ipa user-show newtest2"
		submit_log /var/log/dirsrv/slapd-TESTRELM-COM/errors
		remoteExec root $MASTERIP "ipa host-add test1.${DOMAIN} --force"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa host-show test1.${DOMAIN}"
		remoteExec root $MASTERIP "ipa host-add test2.${DOMAIN} --force"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa host-show test2.${DOMAIN}"
		
		rlLog "Running replica force-sync"
		rlRun "ipa-replica-manage force-sync --from=$MASTER"

		rlRun "ipa user-show newtest2"

		rlLog "Quick checks confirming replication after force-sync.  Add on Master, Check on Replica"
		remoteExec root $MASTERIP "ipa user-add test3 --first=First --last=Last3"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa user-show test3"
		remoteExec root $MASTERIP "ipa user-add test4 --first=First --last=Last4"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa user-show test4"
		remoteExec root $MASTERIP "ipa host-add test3.${DOMAIN} --force"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa host-show test3.${DOMAIN}"
		remoteExec root $MASTERIP "ipa host-add test4.${DOMAIN} --force"
		[ $(uname -i) = "i386" ] && rlRun "sleep 4"
		rlRun "ipa host-show test4.${DOMAIN}"

		rlLog "Cleanup test entries"
		rlRun "ipa user-del test1"
		rlRun "ipa user-del newtest2"
		rlRun "ipa user-del test3"
		rlRun "ipa user-del test4"
		rlRun "ipa host-del test1.${DOMAIN}"
		rlRun "ipa host-del test2.${DOMAIN}"
		rlRun "ipa host-del test3.${DOMAIN}"
		rlRun "ipa host-del test4.${DOMAIN}"

		scheduleCheck=$(ldapsearch -x -D "$ROOTDN" -w "$ROOTDNPWD" -b "cn=mapping tree,cn=config"|grep 'nsDS5ReplicaUpdateSchedule: 0000-2359 0123456'|wc -l)
		if [ $scheduleCheck -gt 0 ]; then
			rlFail "BZ 784696 found...Dont set nsds5replicaupdateschedule in replication agreements"
			rlFail "Replication Schedule found in LDAP config.  This should not be set for continuous replication"
		else
			rlPass "BZ 784696 not found"
			rlPass "Replication Schedule not set.  This is expected config for continuous replication"
		fi
	rlPhaseEnd
}


replicaBugCheck_bz769545()
{
	rlPhaseStartTest "replicaBugCheck_bz769545: ipa-replica-prepare fails when minssf is set to 56 "
		local tmpout=/tmp/errormsg.out
		rlLog "needs to be run on MASTER but, might work on REPLICA"
		rlLog "Adding test hostname to /etc/hosts for prep"
		rlRun "echo \"2.3.4.5 bz769545.$DOMAIN bz769545\" >> /etc/hosts" 
		rlLog "Creating ldif file to modify nsslapd-minssf to a value of 56"
cat > /tmp/bz769545.ldif <<-EOF
dn: cn=config
changetype: modify
replace: nsslapd-minssf
nsslapd-minssf: 56
EOF
		rlRun "ldapmodify -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -f /tmp/bz769545.ldif"
		rlLog "Executing:  ipa-replica-prepare -p \"$ADMINPW\" bz769545.$DOMAIN"
		rlRun "ipa-replica-prepare -p \"$ADMINPW\" bz769545.$DOMAIN > $tmpout 2>&1"
		rlRun "cat $tmpout"
		if [ $(grep "preparation of replica failed: Server is unwilling to perform: Minimum SSF not met" $tmpout|wc -l) -gt 0 ]; then
			rlFail "BZ 769545 found...ipa-replica-prepare fails when minssf is set to 56"
		elif [ -f /var/lib/ipa/replica-info-bz769545.$DOMAIN.gpg ]; then
			rlPass "BZ 769545 not found...ipa-replica-prepare worked with minssf set to 56"
		else
			rlFail "BZ 769545 error message not found but, the replica gpg file not created"
		fi
		rlLog "putting minssf back to 0"
		rlRun "service dirsrv stop"
		INSTANCE=$(echo $RELM|sed 's/\./-/g')
		rlRun "sed -i 's/nsslapd-minssf: 56/nsslapd-minssf: 0/' /etc/dirsrv/slapd-$INSTANCE/dse.ldif"
		rlRun "service dirsrv start"
		rlLog "removing fake host from /etc/hosts"
		rlRun "sed -i '/bz769545/d' /etc/hosts"
	rlPhaseEnd
}

replicaBugCheck_bz830314()
{
	rlPhaseStartTest "replicaBugCheck_bz830314 - ipa-replica-install named failed to start"
		if [ -f /var/log/ipareplica-install.log ]; then
			if [ $(grep "Starting named:.*[FAILED]" /var/log/ipareplica-install.log |wc -l) -gt 0 ]; then
				rlFail "BZ 830314 found...ipa-replica-install named failed to start"
				rlRun "sed -n '/restarting named/,/7\/8/p' /var/log/ipareplica-install.log" 
			else
				rlPass "BZ 830314 not found...named did not seem to fail on ipa install"
			fi
		else
			rlFail "Cannot find ipareplica-install.log to check BZ 830314"
		fi
		####### debugging here #################
		#rlRun "grep named /var/log/ipareplica-install.log"
	rlPhaseEnd
}

replicaBugCheck_bz845405()
{
    rlPhaseStartTest "bz845405 - ipa-replica-install httpd restart failed"
        if [ $(grep "Command '/sbin/service httpd restart ' returned non-zero exit status 1" /var/log/ipareplica-install.log |wc -l) -gt 0 ]; then
            rlFail "BZ 845405 found...ipa-replica-install httpd restart failed"
        else
            rlPass "BZ 845405 not found"
        fi
    rlPhaseEnd
}

replicaBugCheck_bz867640()
{
    rlPhaseStartTest "bz867640 - ipa-replica-install Configuration of CA failed"
        if [ $(grep "CRITICAL failed to configure ca instance" /var/log/ipareplica-install.log|wc -l) -gt 0 ]; then
            rlFail "BZ 867640 found...ipa-replica-install Configuration of CA failed"
        else
            rlPass "BZ 867640 not found"
        fi
    rlPhaseEnd
}

installBug_bz839004()
{
	rlPhaseStartTest "Try installing Slave to test bug 839004"
		installSlave
	rlPhaseEnd
}

installBug_bz830338()
{
	rlPhaseStartTest "bz830338 - Change DS to purge ticket from krb cache in case of authentication error"
		INSTALLTIME=$(date +%d/%b/%Y:%H:%M)
		INSTANCE=$(echo $RELM|sed 's/\./-/g')
		TESTUSER=$FUNCNAME
		rlRun "sftp root@$MASTERIP:/var/log/dirsrv/slapd-$INSTANCE/errors /tmp/errors.$FUNCNAME.0"
		installSlave
		rlRun "remoteExec root $MASTERIP \"ipa user-add $TESTUSER --first=f --last=l\""
		rlRun "sleep 30"
		sftp root@$MASTERIP:/var/log/dirsrv/slapd-$INSTANCE/errors /tmp/errors.$FUNCNAME.1
		DSCHK=$(ldapsearch -xLLL -D "$ROOTDN" -w "$ROOTDNPWD" -b "$BASEDN" cn=$FUNCNAME|wc -l)
		LOGCHK=$(diff /tmp/errors.$FUNCNAME.0 /tmp/errors.$FUNCNAME.1|grep "NSMMReplicationPlugin.*$(hostname).*Replication bind with GSSAPI auth resumed"|wc -l)
		if [ $DSCHK -gt 0 -a $LOGCHK -gt 0 ]; then
			rlPass "bz830338 not found."
		else
			rlFail "bz830338 found...Change DS to purge ticket from krb cache in case of authentication error"
			rlFail "dirsrv still using old Kerberos ticket...must be restarted"
		fi
	rlPhaseEnd
}

replicaBugTest_bz823657()
{
	rlPhaseStartTest "bz823657 - ipa-replica-manage connect fails with GSSAPI error after delete if using previous kerberos ticket "
		# This test is to be run on a MASTER with a already connected SLAVE.
		file=/opt/rhqa_ipa/bz823657-output.txt # Output file to be used in next tests
		rlRun "ipa-replica-manage del $SLAVE" 0 "Disconnect the slave agreement"
		rlRun "echo $ADMINPW | ipa-replica-manage connect $SLAVE $> $file" 0 "Reconnect the SLAVE."
		rlRun "grep 'Unspecified GSS failure' $file" 1 "Ensure that a failure specified in BZ 823657 does not appear to be in the output file $file"
	rlPhaseEnd
}

replicaBugTest_bz824492()
{
	rlPhaseStartTest "bz824492 - Cannot re-connect replica to previously disconnected master."
		# This test is to be run on a MASTER with a already connected SLAVE.
		rlLog "This test may fail if bz823567 fails."
		file=/opt/rhqa_ipa/bz824492-output.txt # Output file to be used in next tests
		rlRun "ipa-replica-manage disconnect $SLAVE" 0 "Disconnect the slave agreement"
		rlRun "echo $ADMINPW | ipa-replica-manage connect $SLAVE $> $file" 0 "Reconnect the SLAVE."
		rlRun "grep 'You cannot connect to a previously deleted master' $file" 1 "Ensure that a failure specified in BZ 824492 does not appear to be in the output file $file"
		rlRun "grep 'list index out of range' $file" 1 "Ensure that a failure specified in BZ 824492 does not appear to be in the output file $file"
	rlPhaseEnd
}

replicaInstallBug748987()
{
	rlPhaseStartTest "Bug 748987 - If master has leftover replica agreement from a previous failed attempt, next replica install can fail"
		rlLog "Test for https://bugzilla.redhat.com/show_bug.cgi?id=748987"
		# This test attempts to install a replica. The install should fail because the a and ptr dns records on the master has been deleted
		# A pass will be seeing a error message  
		file=/opt/rhqa_ipa/replica-install-output
		rlRun "ipa-server-install --uninstall -U"
		rlRun "ssh $MASTERIP \"ipa-replica-manage -p $ADMINPW list $MASTER\""

		rlLog "Executing ipa-replica-install -U  -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg"
		rlRun "ipa-replica-install -U  -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$hostname_s.$DOMAIN.gpg > $file 2>&1" 3
		rlRun "cat $file"
		rlLog "Make sure that expected warning message appears in ipa-replica-install output"
		rlAssertGrep "A replication agreement for this host already exists. It needs to be removed" $file 
		if [ $? -ne 0 ]; then
			rlFail "BZ 748987 found...If master has leftover replica agreement from a previous failed attempt, next replica install can fail"
			rlFail "Did not see proper error messages. See above output"
		else
			rlPass "BZ 748987 not found"
			rlPass "Did see proper error message.  See above output"
		fi
	rlPhaseEnd
}

replicaBugCheck_bz894131()
{
	# change to remoteExec against MASTER to test properly
	MYREVZONE=$1
	local tmpout=/tmp/replicaBugCheck_bz894131.out
	rlPhaseStartTest "Bug 894131 - ipa-replica-install fails to add idnssoaserial for a new zone"
		KinitAsAdmin
		rlLog "First check for idnssoaserial attr for new zone locally"
		rlRun "ipa dnszone-show $MYREVZONE --raw|grep -i idnssoaserial"

		rlLog "Then check for idnssoaserial attr for new zone remotely"
		rlRun "ssh $MASTER \"echo $ADMINPW|kinit admin\""
		rlRun "ssh $MASTER \"ipa dnszone-show $MYREVZONE --raw\" > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "idnssoaserial" $tmpout
		if [ $? -gt 0 ]; then
			rlFail "BZ 894131 found...ipa-replica-install fails to add idnssoaserial for a new zone"
		else
			rlPass "BZ 894131 not found...ipa-replica-install added idnssoaserial for a new zone"
		fi
	rlPhaseEnd
}

replicaBugCheck_bz894143()
{
	MYREVZONE=$1
	local tmpout=/tmp/replicaBugCheck_bz894143.out
	rlPhaseStartTest "Bug 894143 - ipa-replica-prepare fails when reverse zone does not have SOA serial data"
		KinitAsAdmin

		rlRun "sed -i 's/serial_autoincrement yes/serial_autoincrement no/' /etc/named.conf"
		rlRun "service named restart"
		rlRun "ssh $MASTER \"sed -i 's/serial_autoincrement yes/serial_autoincrement no/' /etc/named.conf\""
		rlRun "ssh $MASTER \"service named restart\""

		rlRun "ipa dnszone-add 3.3.3.in-addr.arpa. --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
		rlRun "ssh $MASTER \"echo $ADMINPW|kinit admin\""
		rlRun "ssh $MASTER \"ipa dnszone-show 3.3.3.in-addr.arpa.\" > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertNotGrep "SOA serial:" $tmpout
		rlRun "ssh $MASTER \"ipa-replica-prepare -p $ADMINPW --ip-address=3.3.3.100 bz894143.$DOMAIN\" > $tmpout 2>&1" 1
		rlAssertGrep "Could not create reverse DNS zone for the replica: missing attribute \"idnsSOAserial\"" $tmpout
		if [ $? -ne 0 ]; then
			rlFail "BZ 894143 found...ipa-replica-prepare fails when reverse zone does not have SOA serial data"
		else
			rlPass "BZ 894143 not found"
		fi

		rlRun "sed -i 's/serial_autoincrement no/serial_autoincrement yes/' /etc/named.conf"
		rlRun "service named restart"
		rlRun "ssh $MASTER \"sed -i 's/serial_autoincrement no/serial_autoincrement yes/' /etc/named.conf\""
		rlRun "ssh $MASTER \"service named restart\""
	rlPhaseEnd
}

replicaBugCheck_bz895083()
{
	local tmpout=/tmp/replicaBugCheck_bz895083.out
	rlPhaseStartTest "Bug 895083 - IPA replicated zones can't be loaded because idnssoaserial is missing"
		KinitAsAdmin
		rlRun "ipa dnszone-add 4.4.4.in-addr.arpa. --name-server=${MASTER}. --admin-email=ipaqar.redhat.com"
		rlRun "ssh $MASTER \"echo $ADMINPW|kinit admin\""
		rlRun "ssh $MASTER \"ipa dnszone-show 4.4.4.in-addr.arpa.\" > $tmpout 2>&1"
		rlRun "cat $tmpout"
		rlAssertGrep "SOA serial:" $tmpout
		if [ $? -ne 0 ]; then
			rlFail "BZ 895083 found...IPA replicated zones can't be loaded because idnssoaserial is missing"
		else
			rlPass "BZ 895083 not found"
		fi
	rlPhaseEnd
}

replicaBugCheck_bz905064()
{
	local testlog=$1
	rlPhaseStartTest "Bug 905064 - ipa install error Unable to find preop.pin"
		if [ -z "$testlog" ]; then	
			rlLog "$0 requires a log file to look for...skipping"
			return 0
		fi

		rlAssertNotGrep "Unable to find preop.pin" $testlog
		if [ $? -gt 0 ]; then
			rlFail "BZ 905064 found...ipa install error Unable to find preop.pin"
		else
			rlPass "BZ 905064 not found"
		fi
	rlPhaseEnd
}
