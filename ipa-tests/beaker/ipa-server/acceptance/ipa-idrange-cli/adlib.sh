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
expfile="/tmp/idrange_test.exp"

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
	expect "Trust status: Established and verified" { send_user "\nTrust added with Secret\n"; exit 0 } } }' >> $expfile
	
}

IDrange_Add() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set timeout 10
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	echo "send \"$ipacmd idrange-add\r\"" >> $expfile
	echo 'expect "Range name: "
	send -s -- "$var1\r"
	expect "First*range: "
	send -s -- "$var2\r"
	expect "Number*range: "
	send -s -- "$var3\r"' >> $expfile
	if [ "$1" = "same_name" ]; then
	  echo 'expect {
	"ipa: ERROR: range with name \"$var1\" already exists" { send_user "\nRange Exists\n"; exit 2 } }' >> $expfile
	elif [ "$1" = "same_startid" ]; then
	  echo 'expect {
	"ipa: ERROR: Constraint violation: New base range overlaps with existing base range." { send_user "\n\nRange Overlaps\n\n"; exit 1 } }' >> $expfile
	elif [ "$1" = "interactive" ]; then
	  echo 'expect {
	"Added ID range*" { send_user "\nRange Added\n" } }' >> $expfile
	fi
}

Wrong_Values() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set var5 [lindex $argv 4]
        set var6 [lindex $argv 5]
        set var7 [lindex $argv 6]
        set timeout 10
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash
        expect "*#"' >> $expfile
        echo "send \"$ipacmd idrange-add \$var1\r\"" >> $expfile
        echo 'expect "First*range: "'  >> $expfile
        echo 'send -s -- "$var2\r"' >> $expfile
	echo 'expect {
	"*must be an integer" { 
	send -s -- "$var3\r"
	expect "*must be an integer" { send_user "\nNeeds Integer value\n" } }
	}
	send -s -- "$var4\r"
	expect {
	"Number*range: " {
	send -s -- "$var5\r"
	expect {
        "*must be an integer" {
	send -s -- "$var6\r"
	expect "*must be an integer" { send_user "\nNeeds Integer value\n" } }
        }
	send -s -- "$var7\r"
	expect "Added ID range*" { send_user "\n" } } }' >> $expfile
}

IDrange_Add2() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set var5 [lindex $argv 4]
	set timeout 10
        set send_slow {1 .1}' > $expfile
	echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	echo "send \"$ipacmd idrange-add --\$var1 \$var2 --base-id \$var3 --range-size \$var4 \$var5\r\"" >> $expfile
	echo "expect {
	 \"ipa: ERROR: invalid \'ID Range setup\': Options secondary-rid-base and rid-base must be used together\" { send_user \"\nBoth options required\n\n\" ; exit 1 }
	}" >> $expfile
}

IDrange_Add3() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set var5 [lindex $argv 4]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	echo "send \"$ipacmd idrange-add --rid-base \$var1 --secondary-rid-base \$var2 --base-id \$var3 --range-size \$var4 \$var5\r\"" >> $expfile
	if [ "$1" = "primary" ]; then
	  echo 'expect {
	  "ipa: ERROR: Constraint violation: New primary rid range overlaps with existing primary rid range." { send_user "\nCant use exiting rid-basevalue"; exit 1 } }' >> $expfile
	elif [ "$1" = "secondary" ]; then
	  echo 'expect {
	"ipa: ERROR: Constraint violation: New secondary rid range overlaps with existing secondary rid range." { send_user "\nCant use exiting rid values\n"; exit 1 } }' >> $expfile
	elif [ "$1" = "rid_sec" ]; then
	  echo 'expect {
	  "Added ID range*" { send_user "\nRange added\n"} }' >> $expfile
	elif [ "$1" = "same_value" ]; then
	  echo "expect {
	  \"ipa: ERROR: invalid 'ID Range setup': Primary RID range and secondary RID range cannot overlap\" { send_user \"\n\nCant use same values for rid-base and secondary-rid-base\n\n\"; exit 1 } }" >> $expfile
	fi
}

Dom_Sec_Rid() {
	rm -rf $expfile
	echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set var5 [lindex $argv 4]
        set var6 [lindex $argv 5]
	set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	if [ "$1" = "domsec" ]; then
	  echo "send \"$ipacmd idrange-add --\$var1 \$var2 --secondary-rid-base \$var3 --base-id \$var4 --range-size \$var5 \$var6\r\"" >> $expfile
	  echo "expect {
	\"ipa: ERROR: invalid \'ID Range setup\': Options dom-sid/dom-name and secondary-rid-base cannot be used together\" { send_user \"\n\ndom-sid/dom-name dont need secondary-rid-base\n\n\"; exit 1 }
	}" >> $expfile
	elif [ "$1" = "domsid" ]; then
          echo "send \"$ipacmd idrange-add --\$var1 \$var2 --rid-base \$var3 --base-id \$var4 --range-size \$var5 \$var6\r\"" >> $expfile
	  echo "expect {
	\"ipa: ERROR: invalid \'domain SID\': SID is not recognized as a valid SID for a trusted domain\" { send_user \"\n\n\$var2 is not valid sid\n\n\" ; exit 1 }
	\"Added ID range*\" { send_user \"\n\nAD range added\n\n\"}
	}" >> $expfile
	elif [ "$1" = "domname" ]; then
	  echo "send \"$ipacmd idrange-add --\$var1 \$var2 --rid-base \$var3 --base-id \$var4 --range-size \$var5 \$var6\r\"" >> $expfile
	  echo "expect {
	  \"ipa: ERROR: invalid \'ID Range setup\': SID for the specified trusted domain name could not be found. Please specify the SID directly using dom-sid option.\" { send_user \"\n\n\$var2 is not a valid domain name\n\n\"; exit 1 }
	  \"Added ID range*\" { send_user \"\n\nAD range added\n\n\"}
	}" >> $expfile
	elif [ "$1" = "norid" ]; then
	  echo "send \"$ipacmd idrange-add --\$var1 \$var2 --base-id \$var3 --range-size \$var4 \$var5\r\"" >> $expfile
	  echo "expect {
	  \"ipa: ERROR: invalid 'ID Range setup': Options dom-sid/dom-name and rid-base must be used together\" { send_user \"\n\nCmd did not prompt for rid-base\n\n\"; exit 1 }
	  \"First RID of the corresponding RID range*\" { send_user \"\n\nCmd prompts for rid-base\n\n\"; exit }
	}" >> $expfile
	fi
}

Del_Range() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
	set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	echo "send \"$ipacmd idrange-del \$var1 --continue\r\"" >> $expfile
	if [ "$1" = "contd" ]; then
	  echo 'expect {
	  "*Failed to remove: $var1" { send_user "\n$var1 does not exist\n"; exit 1 } 
	  "Deleted ID range \"$var1\"" { send_user "\n$var1 deleted\n" }
	}' >> $expfile
	else
	  echo 'expect {
	  "*range modification leaving objects with ID out of the defined range is not allowed" { send_user "\n Local range has Objects with ID\n"; exit 1 } }' >> $expfile 
	fi
}

IDrange_Find() {
	rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
	set var2 [lindex $argv 1]
	set var3 [lindex $argv 2]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	if [ "$1" = "novalue" ]; then
	  echo "send \"$ipacmd idrange-find --\$var1\r\"" >> $expfile
	  echo 'expect {
	"*--$var1 option requires an argument" { send_user "\n"; exit 2 }
	}' >> $expfile
	elif [ "$1" = "invalid" ]; then
	  echo "send \"$ipacmd idrange-find --\$var1 \$var2\r\"" >> $expfile
          echo "expect {
	\"ipa: ERROR: invalid '\$var3': must be an integer\" { send_user \"\n\nOption takes integer\n\n\"; exit 1 } }" >> $expfile
	fi
}

IDrange_Mod() {
rm -rf $expfile
        echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
        if [ "$1" = "novalue" ]; then
          echo "send \"$ipacmd idrange-mod --\$var1\r\"" >> $expfile
          echo 'expect {
        "*--$var1 option requires an argument" { send_user "\n"; exit 2 }
        }' >> $expfile
	elif [ "$1" = "invalid" ]; then
          echo "send \"$ipacmd idrange-mod --\$var1 \$var2 \$var3\r\"" >> $expfile
          echo "expect {
	\"ipa: ERROR: invalid '\$var4': must be an integer\" { send_user \"\n\nOption takes integer\n\n\"; exit 1 } }" >> $expfile
	elif [ "$1" = "domsid" ]; then
	  echo "send \"$ipacmd idrange-mod --\$var1 \$var2 \$var3\r\"" >> $expfile
          echo "expect {
	  \"ipa: ERROR: invalid 'domain SID': SID is not recognized as a valid SID for a trusted domain\" { send_user \"\n\nSID not Valid\n\n\"; exit 1 }
	  }" >> $expfile
	elif [ "$1" = "domname" ]; then
	  echo "send \"$ipacmd idrange-mod --\$var1 \$var2 \$var3\r\"" >> $expfile
          echo "expect {
	  \"ipa: ERROR: invalid 'ID Range setup': SID for the specified trusted domain name could not be found. Please specify the SID directly using dom-sid option.\" { send_user \"\n\nDomain name not Valid\n\n\"; exit 1 } }" >> $expfile
	elif [ "$1" = "outofrange" ]; then
	  echo "send \"$ipacmd idrange-mod --\$var1 \$var2 \$var3\r\"" >> $expfile
          echo "expect {
	  \"ipa: ERROR: invalid 'ipabaseid,ipaidrangesize': range modification leaving objects with ID out of the defined range is not allowed\" { send_user \"\n\nModifying range will make objects fall out of range\n\n\"; exit 1 } }"  >> $expfile
        fi
}

Zero_Val() {
	echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set var4 [lindex $argv 3]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	if [ "$1" = "add" ]; then
	  echo "send \"$ipacmd idrange-add --\$var1 \$var2 --\$var3 0 \$var4\r\"" >> $expfile
	elif [ "$1" = "mod" ]; then
	  echo "send \"$ipacmd idrange-mod --\$var1 0 \$var2\r\"" >> $expfile
	fi
	echo 'expect {
	"ipa: ERROR: Invalid DN syntax: Range Check error" { send_user "\nCryptic Error\n"; exit 1 } }' >> $expfile
}

DNAmod_ldif() {
if [ "$1" = "replace" ]; then
cat > DNAmod.ldif << EOF
dn: $2
changetype: modify
replace: $3
$3: $4
EOF
elif [ "$1" = "add" ]; then
cat > DNAmod.ldif << EOF
dn: $2
changetype: modify
add: $3
$3: $4-$5
EOF
fi
}

Add_User() {
	echo 'set var1 [lindex $argv 0]
        set var2 [lindex $argv 1]
        set var3 [lindex $argv 2]
        set timeout 10
        set send_slow {1 .1}' > $expfile
        echo 'spawn /bin/bash
        expect "*#"' >> $expfile
	echo "send \"$ipacmd user-add \$var1 --first \$var2 --last \$var3\r\"" >> $expfile
	echo 'expect {
	"ipa: ERROR: Operations error: Allocation of a new value for range cn=posix ids,cn=distributed numeric assignment plugin,cn=plugins,cn=config failed! Unable to proceed." { send_user "\nUser cannot be added as range is depleted\n"; exit 1 } }' >> $expfile
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
