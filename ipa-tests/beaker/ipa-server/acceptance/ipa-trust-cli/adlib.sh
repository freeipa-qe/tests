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

# AD values
. ./Config

ipacmd=`which ipa`
expfile="/tmp/trust_add.exp"

ADuser_ldif() {
# $1 first name # $2 Surname # $3 Username # $4 Password # $5 Userctrl # $6 changetype (add/ modify)
PASSWD=`echo -n \"$4\" | iconv -f UTF8 -t UTF16LE | base64 -w 0`
[ $# -eq 6 ] && DN="CN=$1 $2,CN=Users,$ADdc"
cat > ADuser.ldif << EOF
dn: $DN
changetype: $6
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: $1 $2
sn: $2
givenName: $1
distinguishedName: $DN
name: $1 $2
sAMAccountName: $3
displayName: $1 $2
unicodePwd::$PASSWD
userAccountControl: $5
EOF
}

User_Admin_ldif() {
cat > User_Admin.ldif << EOF
dn: CN=Administrators,CN=Builtin,$ADdc
changetype: $3
add: member
member: CN=$1 $2,CN=Users,$ADdc
EOF
}

ADuserdel_ldif() {
[ $# -eq 2 ] && DN="CN=$1 $2,CN=Users,$ADdc"
cat > ADuserdel.ldif << EOF
dn: $DN
changetype: delete
EOF
}

Add_Trust() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set timeout 30
        set send_slow {1 .1}' >> $expfile
	echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	if [ "$1" = "type" ]; then
	  echo "send \"$ipacmd trust-add --type=ad \$var1\r\"" >> $expfile
	  echo "expect {
	  \"ipa: ERROR: invalid 'AD Trust setup': Not enough arguments specified to perform trust setup\" { send_user \"More arguments required\n\"; exit 1 } }" >> $expfile
	elif [ "$1" = "server" ]; then
	  echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password --server=\$var4\r\"" >> $expfile
	elif [ "$1" = "no_ad" ]; then
	  echo "send \"$ipacmd trust-add --type=ad --admin \$var2 --password --server=\$var4\r\"" >> $expfile
	  echo 'expect "Realm name: " { send -s -- "$var1\r" }' >> $expfile
	elif [ "$1" = "secret" ]; then
	  echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password --trust-secret\r\"" >> $expfile
	elif [ "$1" = "domain" ]; then
	  echo "send \"$ipacmd trust-add --type=ad --admin \$var2 --password\r\"" >> $expfile
	  echo 'expect "Realm name: " { send -s -- "$var1\r" }' >> $expfile
	elif [ "$1" = "onlyserver" ]; then
	  echo "send \"$ipacmd trust-add --type=ad --admin \$var2 --password --server=\$var4\r\"" >> $expfile
          echo 'expect "Realm name: " { send -s -- "$var1\r" }' >> $expfile
	elif [ "$1" = "base-id" ]; then
	  echo "send \"$ipacmd trust-add --type=ad --admin \$var2 --password --base-id \$var4\r\"" >> $expfile
	elif [ "$1" = "range" ]; then
	  echo "send \"$ipacmd trust-add --type=ad --admin \$var2 --password --range-size \$var4\r\"" >> $expfile
	elif [ "$1" = "base_range" ]; then
	  echo 'set var5 [lindex $argv 4]' >> $expfile
	  echo "send \"$ipacmd trust-add --type=ad --admin \$var2 --password --base-id \$var4 --range-size \$var5\r\"" >> $expfile
	else
          echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password\r\"" >> $expfile
	fi
	echo 'expect "*assword: "' >> $expfile
	echo 'send -s -- "$var3\r"' >> $expfile
	echo "expect {
	\"ipa: ERROR: Unable to resolve domain controller for '\$var1' domain\" { send_user \"\n\n\"; exit 2 }" >> $expfile
	echo '"Trust status: Established and verified" { send_user "\nTrust added\n"; exit 0 }' >> $expfile
	echo '"Shared secret for the trust: " { 
	send -s -- "$var4\r"
	expect "Trust status: Established and verified" { send_user "\nTrust added with Secret\n"; exit 0 } }
	"ipa: ERROR: Constraint violation: New base range overlaps with existing base range." { send_user "\nOverlaps existing local range\n"; exit 1 } }' >> $expfile
	
}

Passwd_Cli() {
	rm -rf $expfile
	echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
        if [ -n "$1" -a "$1" = "passwd" ]; then
          echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password=\$var3\r\"" >> $expfile
          echo 'expect {
          "ipa: error: --password option does not take a value" { send_user "\nError as expected with password value\n"; exit 2 } }' >> $expfile
        else
          echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password \$var3\r\"" >> $expfile
          echo "expect {
          \"ipa: ERROR: command 'trust_add' takes at most 1 argument\" { send_user \"\nError as expected with password on cli\n\"; exit 1 } }" >> $expfile
        fi
}

Non_Admin() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set timeout 10
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash
        expect "*#"' >> $expfile
        if [ -n "$1" -a "$1" = "wrng_passwd" ]; then
	  echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password\r\"" >> $expfile
	  echo 'expect "*assword: "' >> $expfile
	  echo 'send -s -- "$var3\r"' >> $expfile
	  echo "expect {
	  \"ipa: ERROR: Insufficient access: CIFS server *.\$var1 denied your credentials\" { send_user \"\n\"; exit 1 } }" >> $expfile
	else
	  echo "send \"$ipacmd trust-add --type=ad \$var1 --admin \$var2 --password\r\"" >> $expfile
          echo 'expect "*assword: "' >> $expfile
          echo 'send -s -- "$var3\r"' >> $expfile
	  echo 'expect {
	  "ipa: ERROR: Insufficient access: CIFS server denied your credentials" { send_user "\n"; exit 1 } }' >> $expfile
	fi
}

Interactive_trust() {
	rm -rf $expfile
	echo 'set var1 [lindex $argv 0]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	echo "send \"$ipacmd trust-add\r\"" >> $expfile
	echo "expect \"Realm name: \" {
	send -s -- \"\$var1\r\" }
	expect \"ipa: ERROR: invalid 'AD Trust setup': Not enough arguments specified to perform trust setup\" { 
	send_user \"\nTrust add needs more arguments\n\"; exit 1 }" >> $expfile
}

Trust_Del() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
	set var2 [lindex $argv 1]
        set timeout 20
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	if [ "$1" = "domain" ]; then
	  echo "send \"$ipacmd trust-del \$var1\r\"" >> $expfile
	  echo 'expect {
	  "ipa: ERROR: $var1: trust not found" { send_user "\nTrust does not exist\n"; exit 2 }
	  "Deleted trust \"$var1\"" { send_user "\nTrust deleted\n"; exit 0 }
	  "ipa: ERROR: Insufficient access: Insufficient *" { send_user "\nUser as no admin rights in IPA server\n"; exit 1 } }' >> $expfile 
	elif [ "$1" = "continue" ]; then
	  echo "send \"$ipacmd trust-del \$var1 --continue\r\"" >> $expfile
	  echo 'expect {
	  "Failed to remove: $var1" { send_user "\nDomain invalid\n"; exit 1 }
	  "Deleted trust \"$var1\"" { send_user "\nValid domain trust deleted\n"; exit 0 } }' >> $expfile
	elif [ "$1" = "multi" ]; then
	  echo "send \"$ipacmd trust-del \$var1 \$var2\r\"" >> $expfile
	  echo 'expect "Deleted trust \"$var1,$var2\"" { send_user "2 Trusts deleted"; exit 0 }' >> $expfile
	else
	  echo "send \"$ipacmd trust-del\r\"" >> $expfile
	  echo 'expect "Realm name: " {
          send -s -- "$var1\r" }
          expect "Deleted trust \"$var1\"" { send_user "\nRealm given interactively\n"; exit 0 }' >> $expfile
	fi

}

Trust_Show() {
	rm -rf $expfile
	echo 'set var1 [lindex $argv 0]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	if [ "$1" = "allraw" ]; then
	  echo "send \"$ipacmd trust-show \$var1 --raw --all\r\"" >> $expfile
	  echo 'expect "ipa: ERROR: an internal error has occurred" { send_user "\nNeeds fixing https://fedorahosted.org/freeipa/ticket/3525\n"; exit 1 }' >> $expfile
	elif [ "$1" = "all" ]; then
	  echo "send \"$ipacmd trust-show \$var1 --all\r\"" >> $expfile
	  echo 'expect "objectclass: ipaNTTrustedDomain, ipaIDobject, top" { send_user "\nTrust show all\n"; exit 0 }' >> $expfile
	elif [ "$1" = "raw" ]; then
	  echo "send \"$ipacmd trust-show \$var1 --raw\r\"" >> $expfile
	  echo 'expect "trusttype: Active Directory domain" { send_user "\nTrust show raw\n"; exit 0 }' >> $expfile
	elif [ "$1" = "rights" ]; then
	  echo "send \"$ipacmd trust-show \$var1 --rights --all\r\"" >> $expfile
	  echo 'expect "attributelevelrights: *" { send_user "\nTrust show rights\n"; exit 0 }' >> $expfile
	elif [ "$1" = "domain" ]; then
	  echo "send \"$ipacmd trust-show \$var1\r\"" >> $expfile
	  echo 'expect "Trust type: Active Directory domain" { send_user "\nTrust show\n"; exit 0 }' >> $expfile
	else
	  echo "send \"$ipacmd trust-show\r\"" >> $expfile
	  echo 'expect "Realm name: "
	  send -s -- "$var1\r"
	  expect "Trust type: Active Directory domain" { send_user "\nShowing trust interactively\n"; exit 0 }' >> $expfile
	fi
}

NBAD_Exp() {

        rm -rf $expfile
        echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set var3 [lindex $argv 2]' >> $expfile
        echo 'set var4 [lindex $argv 3]' >> $expfile
        echo 'set var5 [lindex $argv 4]' >> $expfile
	echo 'set timeout 30
        set send_slow {1 .1}' >> $expfile
        echo "spawn $trust_bin --\$var1=\$var2" >> $expfile
        echo 'expect "Overwrite smb.conf?*: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo "send -s -- \"$adminpw\r\"" >> $expfile
#       echo 'expect  "*ipa-sidgen task? *: "' >> $expfile 
#       echo 'send -- "\r"' >> $expfile
        echo 'expect "*reset the NetBIOS domain name? *: "' >> $expfile
        echo 'send -s -- "y\r"' >> $expfile
        echo 'expect "Setup*complete"' >> $expfile
        echo 'send_user "\nADtrust installed.\n"' >> $expfile
        echo "spawn $ipacmd trust-add --type=ad \$var3 --admin \$var4 --password" >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo 'send -s -- "$var5\r"' >> $expfile
        echo 'expect "*the IPA server and the remote domain cannot share the same NetBIOS name*" {send_user "\nTrust added failed as expected\n"; exit 2}' >> $expfile



}

Readd_Exp() {

        rm -rf $expfile
        echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set var3 [lindex $argv 2]' >> $expfile
        echo 'set timeout 60
        set send_slow {1 .1}' >> $expfile
        echo "spawn $ipacmd trust-add --type=ad \$var1 --admin \$var2 --password" >> $expfile
        echo 'expect "*assword: "' >> $expfile
        echo 'send -s -- "$var3\r"' >> $expfile
        echo 'expect "Added Active Directory trust for realm \"$var1\"" {
        send_user "\n\n----Trust added as expected----\n\n"}' >> $expfile
        echo "spawn $ipacmd trust-add --type=ad \$var1 --admin \$var2 --password" >> $expfile
        echo 'expect "*assword: "'>> $expfile
        echo 'send -s -- "$var3\r"'>> $expfile
        echo 'expect "Re-established trust to domain \"$var1\"" {
        send_user "\n\n----Trust re-added as expected----\n\n"; exit 1}' >> $expfile 

}

Trust_ID() {

	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]' > $expfile
        echo 'set var2 [lindex $argv 1]' >> $expfile
        echo 'set var3 [lindex $argv 2]' >> $expfile
        echo 'set var4 [lindex $argv 3]' >> $expfile
        echo 'set var5 [lindex $argv 4]' >> $expfile
        echo 'set timeout 20
        set send_slow {1 .1}' >> $expfile
	if [ "$1" = "empty" ]; then
	  echo "spawn $ipacmd trust-add --type=ad \$var1 --admin \$var2 --password --\$var4" >> $expfile
	  echo "expect {
	\"ipa: error: --\$var4 option requires an argument\" { send_user \"\n\nOption takes an argument\n\n\"; exit 2 } 
	  }" >> $expfile
	elif [ "$1" = "invalid" ]; then
	  echo "spawn $ipacmd trust-add --type=ad \$var1 --admin \$var2 --password --\$var4 \$var5" >> $expfile
          echo 'expect "*assword: "
          send -s -- "$var3\r"' >> $expfile
	echo "expect {
	\"*: must be an integer\" { send_user \"\n\nOption takes integer\n\n\"; exit 1 }
	  }" >> $expfile
	fi
}
