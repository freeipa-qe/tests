#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Steeve Goveas <stv@redhat.com>
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

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

trust_bin=`which ipa-adtrust-install`
IPAhost=`hostname`
rec1="_ldap._tcp.Default-First-Site-Name._sites.dc._msdcs"
rec2="_ldap._tcp.dc._msdcs"
rec3="_kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs"
rec4="_kerberos._tcp.dc._msdcs"
rec5="_kerberos._udp.Default-First-Site-Name._sites.dc._msdcs"
rec6="_kerberos._udp.dc._msdcs"
expfile="/tmp/adtrust_install.exp"
exp=`which expect`
user="tuser"
user1="nuser"
userpw="Secret123"
adminpw="Secret123"
ipacmd=`which ipa`

NB_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' >> $expfile
        echo "spawn $trust_bin --\$var1=\$var2" >> $expfile
	echo 'expect "*assword: "' >> $expfile
	echo "send -s -- \"$adminpw\r\"" >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "Illegal*NetBIOS*name*\[$var2\]*ASCII*\."
}' >> $expfile
        echo "send_user \"\n$var2 name not permitted for netbios name.\n\" ; exit 2" >> $expfile
}


IP_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' >> $expfile
        echo "spawn $trust_bin --\$var1=\$var2" >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "error:*option*--ip-address:*invalid*IP*address"
}' >> $expfile
        echo 'send_user "\n$var2 is not a valid ip address\n" ; exit 2' >> $expfile
}

NBIP_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set var3 [lindex $argv 2]' >> $expfile
        echo 'set var4 [lindex $argv 3]' >> $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' >> $expfile
        echo "spawn $trust_bin --\$var1=\$var2 --\$var3=\"\$var4\"" >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
  "error:*option*--ip-address:*invalid*IP*address" {
     send_user "\n$var2 is not a valid ip address\n" ; exit 2 }
  "*assword: " {
     send -s -- \$adminpw\r
     expect "Illegal*NetBIOS*name*\[$var4\]*ASCII*\." {
     send_user "\n Invalid Netbios name \"$var4\" fails as expected\n" ; exit 2 } 
  } }' >>  $expfile
}

NonRoot_Exp() {
	rm -rf $expfile
        echo 'set timeout 10
        set send_slow {1 .1}' > $expfile
        echo "spawn ssh -o StrictHostKeychecking=no -l $user $IPAhost" >> $expfile
        echo 'expect "*password:*"' >> $expfile
        echo 'sleep 3' >> $expfile
        echo "send -s -- \"$userpw\\r\"" >> $expfile
        echo 'expect "*$ "' >> $expfile
        echo "send -s -- \"$trust_bin\\r\"" >> $expfile
        echo 'expect "Must*be*root*" {' >> $expfile
        echo 'send_user "\nUser is not root\n" ; exit 2 }' >> $expfile
}

RID_Exp() {
	rm -rf $expfile
	echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set var3 [lindex $argv 2]' >> $expfile
        echo 'set timeout 10
        set send_slow {1 .1}
        spawn /bin/bash
        expect "*#"' >> $expfile
        echo "send \"$trust_bin --\$var1=\$var2\r\"" >> $expfile
        echo 'expect "invalid integer value:*"
        expect "*#" {' >> $expfile
        echo "send \"$trust_bin --\$var1=\$var3\r\"" >> $expfile
        echo 'expect "invalid integer value:*" }' >> $expfile
        echo 'send_user "\n\nOnly intergers accepted\n" ; exit 2' >> $expfile
}

No_SRV_Exp() {
	rm -rf $expfile
	echo 'set timeout 300
	spawn /bin/bash
        expect "*# "' >> $expfile
	if [ "$1" = "no-msdcs" ]; then
	  echo "send -- \"$trust_bin --no-msdcs\r\"" >> $expfile
	else
	  echo "send -- \"$trust_bin\r\"" >> $expfile
	fi
	echo 'expect "*assword: "' >> $expfile
	echo "send -- \"$adminpw\r\"" >> $expfile
	if [ "$1" = "no-msdcs" ]; then
	 echo 'expect "*]: "' >> $expfile
	 echo 'send -- "\r"' >> $expfile
	fi
	echo 'expect "*ipa-sidgen task? *]: "' >> $expfile
        echo 'send -- "\r"' >> $expfile
	if [ "$1" = "no-msdcs" ]; then
	 echo 'expect "*no-msdcs was given, *"' >> $expfile
#	 send_user -- "\n------------------\n"' >> $expfile
	else
	 echo 'expect "DNS management was not enabled *"' >> $expfile
#	 send_user -- "\n------------------\n"' >> $expfile
	fi
	echo "expect \"* $rec1\"" >> $expfile
#	echo 'send_user -- "\n------------------\n"' >> $expfile
	echo "expect \"* $rec2\"" >> $expfile
#	echo 'send_user -- "\n------------------\n"' >> $expfile
	echo "expect \"* $rec3\"" >> $expfile
#	echo 'send_user -- "\n------------------\n"' >> $expfile
	echo "expect \"* $rec4\"" >> $expfile
#	echo 'send_user -- "\n------------------\n"' >> $expfile
	echo "expect \"* $rec5\"" >> $expfile
#	echo 'send_user -- "\n------------------\n"' >> $expfile
	echo "expect \"* $rec6\"" >> $expfile
	echo 'send_user -- "\n------------------\n"' >> $expfile
	echo 'expect {
        "Setup*complete" { sleep 10 ; send "exit\r" }
   }
	send_user "\nAdtrust installed successfully without creating service records\n"' >> $expfile
}

Interactive_Exp() {
	rm -rf $expfile
        echo 'set timeout 300
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash' >> $expfile
	echo 'expect "# "' >> $expfile
	echo "send -- \"$trust_bin\r\"" >> $expfile
        echo 'expect {
	"IPA is not configured on this system." { send_user "\nNeed IPA configured on the server before ipa-adtrust-install\n" ; exit 2 }
	"Overwrite smb.conf?*: "
	}' >> $expfile
	echo 'send -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -- \"$adminpw\r\"" >> $expfile
	if [ "$1" = "sidgen" ]; then
	  echo 'expect "*]: "' >> $expfile
          echo 'send -- "\r"' >> $expfile
        fi
	echo 'expect "*ipa-sidgen task? *]: "' >> $expfile
	if [ "$1" = "sidgen" ]; then
	  echo 'send -- "y\r"' >> $expfile
	else
	  echo 'send -- "\r"' >> $expfile
	fi
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
        "Setup*complete" { sleep 10 ; send -- "exit\r" }
}
	send_user "\nInteractive ADtrust install was successful.\n"' >> $expfile
}

Valid_NB_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set timeout 300
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
        echo "send -- \"$trust_bin --\$var1=\$var2\r\"" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
        echo 'expect {
	"*ipa-sidgen task? *]: " { send -- "\r" }
	"*reset the NetBIOS domain name? *]: " {
	send -s -- "y\r" 
	expect "*ipa-sidgen task? *]: "
	send -- "\r"  } }
	expect "Setup*complete" { sleep 10 ; send -- "exit\r" }' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
}

Valid_IP_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set timeout 300
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
        echo "send -- \"$trust_bin --\$var1=\$var2\r\"" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
	echo 'expect "*ipa-sidgen task? *]: "' >> $expfile
        echo 'send -- "\r"' >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
	"Setup*complete" { sleep 10 ; send -- "exit\r" }
}' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
}

Valid_NBIP_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set timeout 300
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
        echo "send -- \"$trust_bin --\$var1=\$var2 --\$var3=\$var4\r\"" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
	echo 'expect {
        "*ipa-sidgen task? *]: " { send -- "\r" }
        "*reset the NetBIOS domain name? *]: " {
        send -s -- "y\r" 
        expect "*ipa-sidgen task? *]: "
        send -- "\r"  } }
        expect "Setup*complete" { sleep 10 ; send -- "exit\r" }' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
}

Valid_RID_Exp() {
	rm -rf $expfile
	echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set timeout 300
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
	if [ -n "$1" -a "$1" = both ]; then
	  echo "send -- \"$trust_bin --\$var1=\$var2 --\$var3=\$var4\r\"" >> $expfile
	else
	  echo "send -- \"$trust_bin --\$var1=\$var2\r\"" >> $expfile
	fi
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
	echo 'expect "*]: "' >> $expfile
        echo 'send -- "\r"' >> $expfile
	echo 'expect "*ipa-sidgen task? *]: "' >> $expfile
        echo 'send -- "\r"' >> $expfile
        echo 'expect "*]: " { send -s -- "\r" } ' >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
	"Setup*complete" { sleep 10 ; send -- "exit\r" }
} ' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
}

NoAdminPriv_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
	set var2 [lindex $argv 1]
	set var3 [lindex $argv 2]
        set timeout 300
        set send_slow {1 .1}' > $expfile
        echo "spawn $trust_bin -\$var1 \$var2 " >> $expfile
	if [ "$1" = "A" ]; then 
          echo 'expect "*assword: "' >> $expfile
          echo "send -s -- \"\$var3\r\"" >> $expfile
	  echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
        "Must have administrative privileges to setup AD trusts on server" { expect "*#" ; exit 2}
} ' >> $expfile
	else
	  echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
        "error to automatically re-kinit your admin user ticket" { expect "*#" ; exit 2}
} ' >> $expfile
	fi
}

AdminPriv_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
	set var2 [lindex $argv 1]
        set timeout 300
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
        echo "send -- \"$trust_bin -\$var1 \$var2\r\"" >> $expfile
	echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
	if [ "$1" = "A" ]; then 
          echo 'expect "*assword: "' >> $expfile
          echo "send -s -- \"$userpw\r\"" >> $expfile
	fi
	echo 'expect "*ipa-sidgen task? *]: "' >> $expfile
        echo 'send -- "\r"' >> $expfile
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
    "Setup*complete" { sleep 10 ; send -- "exit\r" }
} ' >> $expfile
	echo 'send_user "\nADtrust installed.\n"' >> $expfile
}

SID_Exp() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set timeout 300
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
	if [ "$1" = "add-sids" ]; then
          echo "send -- \"$trust_bin --add-sids\r\"" >> $expfile
	else
	  echo "send -- \"$trust_bin\r\"" >> $expfile
	fi
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
	if [ "$1" != "add-sids" ]; then
	  echo 'expect "*ipa-sidgen task? *]: "' >> $expfile
          echo 'send -- "\r"' >> $expfile
	fi
        echo 'expect {
  timeout { send_user "\nExpected error not received\n"; exit 1 }
  eof { send_user "\nSome issue\n"; exit 1 }
	"Setup*complete" { sleep 10 ; send -- "exit\r" }
}' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
}

Unattended_Exp() {
	rm -rf $expfile
        echo 'set timeout 60
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash' >> $expfile
        echo 'expect "# "' >> $expfile
        echo "send -- \"$trust_bin -a $adminpw -U\r\"" >> $expfile
	echo 'expect {
	"Illegal NetBIOS name *" { send_user "\n Error expected - BZ 924079\n"; exit 1 }
        "Setup*complete" { sleep 10 ; send -- "exit\r" }
}
        send_user "\nUnattended ADtrust install was successful.\n"' >> $expfile
}
