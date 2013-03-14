#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-external-ca
#   Description: IPA external ca deployment tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Authors: 
#	     Gowrishankar Rajaiyan <gsr@redhat.com>
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


installMasterExtCA()
{
   rlPhaseStartTest "Install IPA MASTER Server with external CA"

        rlRun "/etc/init.d/ntpd stop" 0 "Stopping the ntp server"
        rlRun "ntpdate $NTPSERVER" 0 "Synchronzing clock with valid time server"
        rlRun "fixHostFile" 0 "Set up /etc/hosts"
	rlRun "fixhostname" 0 "Fix hostname"
	rlRun "appendEnv" 0 "Appending env with new hostname"

	. ./opt/rhqa_ipa/env.sh
	rlRun "cat /opt/rhqa_ipa/env.sh"

	rlRun "yum install -y ipa-server bind-dyndb-ldap bind"
	echo "ipa-server-install --external-ca --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U" > /opt/rhqa_ipa/installipa.bash

	rlLog "Verifies https://bugzilla.redhat.com/show_bug.cgi?id=750828"
	rlLog "EXECUTING: ipa-server-install --external-ca --setup-dns --forwarder=$DNSFORWARD --hostname=$hostname_s.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"

        rlRun "setenforce 1" 0 "Making sure selinux is enforced"
        rlRun "chmod 755 /opt/rhqa_ipa/installipa.bash" 0 "Making ipa install script executable"
        rlRun "/bin/bash /opt/rhqa_ipa/installipa.bash" 0 "Installing IPA Server"

        if [ -f /var/log/ipaserver-install.log ]; then
                rhts-submit-log -l /var/log/ipaserver-install.log
        fi

	rlAssertExists "/root/ipa.csr"
	rlRun "mkdir /root/ipa-ca"
	rlRun "cp /mnt/tests/CoreOS/ipa-server/acceptance/ipa-external-ca/makesub.sh /root/ipa-ca/"
	rlRun "cp /mnt/tests/CoreOS/ipa-server/acceptance/ipa-external-ca/signca.py /root/ipa-ca/"
	pushd .
	rlRun "cd /root/ipa-ca"


expfile="/tmp/expfile"
password="Secret123"

	echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
	echo "spawn /bin/bash ./makesub.sh" >> $expfile
	echo 'match_max 100000' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo 'sleep .5' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect "*: "' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect eof ' >> $expfile


	rlLog "Executing makesub.sh"
	rlRun "/usr/bin/expect $expfile"

	echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
	echo "spawn /usr/bin/python signca.py" >> $expfile
	echo 'match_max 100000' >> $expfile
	echo 'sleep .5' >> $expfile
	echo 'expect "*:"' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'expect eof ' >> $expfile

	rlLog "Executing /usr/bin/python signca.py"
        rlRun "/usr/bin/expect $expfile"
	rlRun "certutil -d . -L"

	rlRun "certutil -L -d . -n \"primary\" -a > ipacacert.asc"
	rlRun "certutil -L -d . -n \"secondary\" -a >> ipacacert.asc"

	popd

	rlLog "Executing: ipa-server-install --external_cert_file=/root/ipa-ca/ipa.crt --external_ca_file=/root/ipa-ca/ipacacert.asc"

	echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $expfile
	echo "spawn /usr/sbin/ipa-server-install --external_cert_file=/root/ipa-ca/ipa.crt --external_ca_file=/root/ipa-ca/ipacacert.asc" >> $expfile
	echo 'match_max 100000' >> $expfile
	echo 'sleep .5' >> $expfile
	echo 'expect "*:"' >> $expfile
	echo "send -s -- "$password"" >> $expfile
	echo 'send -s -- "\r"' >> $expfile
	echo 'wait' >> $expfile
	echo 'expect eof ' >> $expfile

	rlLog "Executing: /usr/sbin/ipa-server-install --external_cert_file=/root/ipa-ca/ipa.crt --external_ca_file=/root/ipa-ca/ipacacert.asc"
	rlRun "/usr/bin/expect $expfile"

#	rlLog "ipa-server-install --external_cert_file=/root/ipa-ca/ipa.crt --external_ca_file=/root/ipa-ca/ipacacert.asc -p $ADMINPW -a $ADMINPW -r $RELM -P $ADMINPW -U --subject \"O=$RELM\""
#        rlRun "ipa-server-install --external_cert_file=/root/ipa-ca/ipa.crt --external_ca_file=/root/ipa-ca/ipacacert.asc -p $ADMINPW -a $ADMINPW -r $RELM -P $ADMINPW -U --subject \"O=$RELM\""


	sleep 30
	rlRun "ipactl restart"
	sleep 30
	rlRun "ipactl status"

	# As part of verifying bug https://bugzilla.redhat.com/show_bug.cgi?id=750828"
        rlAssertGrep "forwarders" "/etc/named.conf"
        rlAssertGrep "$DNSFORWARD" "/etc/named.conf"

}

