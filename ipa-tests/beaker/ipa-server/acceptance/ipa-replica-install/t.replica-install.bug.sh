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
. /dev/shm/ipa-server-shared.sh
. ./install-lib.sh


# BZ 784696 Don't set nsds5replicaupdateschedule in replication agreements
replicaBugCheck_bz784696()
{
	rlPhaseStartTest "bugCheck_bz784696: Dont set nsds5replicaupdateschedule in replication agreements"
		rlLog "First run ipa user-find on MASTER"
		remoteExec root $MASTERIP "ipa user-find"
		rlLog "Quick checks confirming replication.  Add on Master, Check on Replica"
		remoteExec root $MASTERIP "ipa user-add test1 --first=First --last=Last"
		sleep 10
		rlRun "ipa user-show test1"
		remoteExec root $MASTERIP "ipa user-add test2 --first=First --last=Last"
		rlRun "ipa user-show test2"
		remoteExec root $MASTERIP "ipa host-add test1.${DOMAIN} --force"
		rlRun "ipa host-show test1.${DOMAIN}"
		remoteExec root $MASTERIP "ipa host-add test2.${DOMAIN} --force"
		rlRun "ipa host-show test2.${DOMAIN}"
		
		rlLog "Running replica force-sync"
		rlRun "ipa-replica-manage force-sync --from=$MASTER"

		rlLog "Quick checks confirming replication after force-sync.  Add on Master, Check on Replica"
		remoteExec root $MASTERIP "ipa user-add test3 --first=First --last=Last"
		rlRun "ipa user-show test3"
		remoteExec root $MASTERIP "ipa user-add test4 --first=First --last=Last"
		rlRun "ipa user-show test4"
		remoteExec root $MASTERIP "ipa host-add test3.${DOMAIN} --force"
		rlRun "ipa host-show test3.${DOMAIN}"
		remoteExec root $MASTERIP "ipa host-add test4.${DOMAIN} --force"
		rlRun "ipa host-show test4.${DOMAIN}"

		rlLog "Cleanup test entries"
		rlRun "ipa user-del test1"
		rlRun "ipa user-del test2"
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
	rlPhaseEndTest	
}

replicaBugTest_bz823657()
{
	rlPhaseStartTest "bz823657 - ipa-replica-manage connect fails with GSSAPI error after delete if using previous kerberos ticket "
		# This test is to be run on a MASTER with a already connected SLAVE.
		file=/dev/shm/bz823657-output.txt # Output file to be used in next tests
		rlRun "ipa-replica-manage del $SLAVE" 0 "Disconnect the slave agreement"
		rlRun "ipa-replica-manage connect $SLAVE $> $file" 0 "Reconnect the SLAVE."
		rlRun "grep 'Unspecified GSS failure' $file" 1 "Ensure that a failure specified in BZ 823657 does not appear to be in the output file $file"
	rlPhaseEndTest
}

replicaBugTest_bz824492()
{
	rlPhaseStartTest "bz824492 - Cannot re-connect replica to previously disconnected master."
		# This test is to be run on a MASTER with a already connected SLAVE.
		rlLog "This test may fail if bz823567 fails."
		file=/dev/shm/bz824492-output.txt # Output file to be used in next tests
		rlRun "ipa-replica-manage disconnect $SLAVE" 0 "Disconnect the slave agreement"
		rlRun "ipa-replica-manage connect $SLAVE $> $file" 0 "Reconnect the SLAVE."
		rlRun "grep 'You cannot connect to a previously deleted master' $file" 1 "Ensure that a failure specified in BZ 824492 does not appear to be in the output file $file"
		rlRun "grep 'list index out of range' $file" 1 "Ensure that a failure specified in BZ 824492 does not appear to be in the output file $file"
	rlPhaseEndTest
}

replicaInstallBug748987()
{
	rlPhaseStartTest "Bug 748987 - If master has leftover replica agreement from a previous failed attempt, next replica install can fail"
		rlLog "Test for https://bugzilla.redhat.com/show_bug.cgi?id=748987"
		# This test attempts to install a replica. The install should fail because the a and ptr dns records on the master has been deleted
		# A pass will be seeing a error message  
		file=/dev/shm/replica-install-output
		rlLog "Executing ipa-replica-install -U  -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg"
		Executing ipa-replica-install -U  -w $ADMINPW -p $ADMINPW /dev/shm/replica-info-$hostname_s.$DOMAIN.gpg &> $file
		rlRun "grep 'A replication agreement for this host already exists. It needs to be removed' $file" 0 "Make sure that expected warning message appears in ipa-replica-install output"
	rlPhaseEndTest
}

