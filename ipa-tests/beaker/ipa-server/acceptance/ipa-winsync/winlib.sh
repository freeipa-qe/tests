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
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# AD values
. ./Config

# Commonly used routines

ADuser_ldif() {
# $1 first name # $2 Surname # $3 Username # $4 changetype (add, modify, delete)
[ $# -eq 6 ] && DN="CN=$1 $2,OU=$6,OU=$5,$ADdc"
[ $# -eq 5 ] && DN="CN=$1 $2,OU=$5,$ADdc"
[ $# -eq 4 ] && DN="CN=$1 $2,CN=Users,$ADdc"
cat > ADuser.ldif << EOF
dn: $DN
changetype: $4
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
EOF
}

ADuserdel_ldif() {
[ $# -eq 6 ] && DN="CN=$1 $2,OU=$6,OU=$5,$ADdc"
[ $# -eq 5 ] && DN="CN=$1 $2,OU=$5,$ADdc"
[ $# -eq 4 ] && DN="CN=$1 $2,CN=Users,$ADdc"
cat > ADuserdel.ldif << EOF
dn: $DN
changetype: delete
EOF
}

# Microsoft stores a quoted password in little endian UTF16 base64 encoded. Hence to generate the password, use the command:
#echo -n "\"Secret123\"" | iconv -f UTF8 -t UTF16LE | base64 -w 0
#ADuser_passwd_ldif() {
#PASSWD=`echo -n "\"$3\"" | iconv -f UTF8 -t UTF16LE | base64 -w 0`
#cat > ADuser_passwd.ldif << EOF
#dn: CN=$1 $2,CN=Users,$ADdc
#changetype: modify
#replace: unicodePwd
#unicodePwd::$PASSWD
#EOF
#}
ADuser_passwd_ldif() {
PASSWD=`echo -n "\"$3\"" | iconv -f UTF8 -t UTF16LE | base64 -w 0`
[ $# -eq 5 ] && DN="CN=$1 $2,OU=$5,OU=$4,$ADdc"
[ $# -eq 4 ] && DN="CN=$1 $2,OU=$4,$ADdc"
[ $# -eq 3 ] && DN="CN=$1 $2,CN=Users,$ADdc"
cat > ADuser_passwd.ldif << EOF
dn: $DN
changetype: modify
replace: unicodePwd
unicodePwd::$PASSWD
EOF
}

# Modify userAccountControl
ADuser_cntrl_ldif() {
[ $# -eq 5 ] && DN="CN=$1 $2,OU=$5,OU=$4,$ADdc"
[ $# -eq 4 ] && DN="CN=$1 $2,OU=$4,$ADdc"
[ $# -eq 3 ] && DN="CN=$1 $2,CN=Users,$ADdc"
cat > ADuser_cntrl.ldif << EOF
dn: $DN
changetype: modify
replace: userAccountControl
userAccountControl: $3
EOF
}

syncinterval_ldif() {
cat > syncinterval.ldif << EOF
dn: cn=meTo$ADhost,cn=replica,cn=dc\3Dtestrelm\2Cdc\3Dcom,cn=mapping tree,cn=config
changetype: modify
$2: winSyncInterval
winSyncInterval: $1
EOF
}

errorlog_ldif() {
cat > errorlog.ldif << EOF
dn: cn=config
changetype: modify
replace: nsslapd-errorlog-level
nsslapd-errorlog-level: $1
EOF
}

acctdisable_ldif() {
cat > acctdisable.ldif << EOF
dn: cn=ipa-winsync,cn=plugins,cn=config
changetype: modify
replace: ipawinsyncacctdisable
ipawinsyncacctdisable: $1
EOF
}

# Modify telephoneNumber
telephoneNumber_ldif() {
cat > telephoneNumber.ldif << EOF
dn: CN=$1 $2,CN=Users,$ADdc
changetype: modify
replace: telephoneNumber
telephoneNumber: $3
EOF
}

employeetype_ldif() {
cat > employeetype.ldif << EOF
dn: cn=ipa-winsync,cn=plugins,cn=config
changetype: modify
$1: ipaWinSyncUserAttr
ipaWinSyncUserAttr: employeetype unknown
EOF
}

AD_employeetype_ldif() {
cat > AD_employeetype.ldif << EOF
dn: CN=$1 $2,CN=Users,$ADdc
changetype: modify
replace: employeetype
employeetype: $3
EOF
}

uidNumber_ldif() {
cat > uidNumber.ldif << EOF
dn: CN=$1 $2,CN=Users,$ADdc
changetype: modify
add: uidNumber
uidNumber: $3
EOF
}

deleteuser_ldif() {
cat > deleteuser.ldif << EOF
dn: CN=$1 $2,CN=Users,$ADdc
changetype: delete
EOF
}

addOU_ldif() {
cat > addOU.ldif << EOF
dn: OU=$1,$ADdc
changetype: $2
ou: $1
objectClass: top
objectClass: organizationalUnit
distinguishedName: OU=$1,$ADdc
EOF
}

addsubOU_ldif() {
cat > addsubOU.ldif << EOF
dn: OU=$1,OU=$2,$ADdc
changetype: $3
ou: $1
objectClass: top
objectClass: organizationalUnit
distinguishedName: OU=$1,OU=$2,$ADdc
EOF
}
