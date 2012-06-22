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

create_ldif() {
# $1 first name # $2 Surname # $3 Username # $4 changetype (add, modify, delete)

cat > ADuser.ldif << EOF
dn: CN=$1 $2,CN=Users,DC=adrelm,DC=com
changetype: $4
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: $1 $2
sn: $2
givenName: $1
distinguishedName: CN=$1 $2,CN=Users,DC=adrelm,DC=com
name: $1 $2
sAMAccountName: $3
displayName: $1 $2
userPrincipalName: $3@adrelm.com
EOF
}

# Microsoft stores a quoted password in little endian UTF16 base64 encoded. Hence to generate the password, use the command:
#echo -n "\"Secret123\"" | iconv -f UTF8 -t UTF16LE | base64 -w 0

create_passwd_ldif() {
cat > ADuser_passwd.ldif << EOF
dn: CN=$1 $2,CN=Users,DC=adrelm,DC=com
changetype: modify
replace: unicodePwd
unicodePwd::IgBTAGUAYwByAGUAdAAxADIAMwAiAA==
EOF
}

# Modify userAccountControl
create_cntrl_ldif() {
cat > ADuser_cntrl.ldif << EOF
dn: CN=$1 $2,CN=Users,DC=adrelm,DC=com
changetype: modify
replace: userAccountControl
userAccountControl: $3
EOF
}

syncinterval_ldif() {
cat > syncinterval.ldif << EOF
dn: cn=meTo$ADhost,cn=replica,cn=dc\3Dtestrelm\2Cdc\3Dcom,cn=mapping tree,cn=config
changetype: modify
add: winSyncInterval
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

modify_ldif() {
cat > modify.ldif << EOF
dn: cn=ipa-winsync,cn=plugins,cn=config
changetype: modify
replace: ipawinsyncacctdisable
ipawinsyncacctdisable: $1
EOF
}


