#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-automount
#   Description: automount functional tests for autofs
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Gowrishankar Rajaiyan <gsr@redhat.com>
#   Date: Mon May  9 20:56:29 IST 2011 (Initial check-in)
#   Date: Mon Jul 18 05:15:51 EDT 2011 
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

########################################################################
# Test Suite Globals
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`

########################################################################
user1="user1"
user2="user2"
userpw="Secret123"
mount_homedir="/ipahome"
direct_mount="/direct_mount"
#RELM="RHTS-ENG-BRQ-REDHAT-COM"
basedn=`getBaseDN`

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACAKGE3="nfs-utils"
PACKAGE4="autofs"
PACKAGE5="setup"

setup() {
rlPhaseStartTest "Setup for automount configuration tests"

	# Checking for autofs and related packages
        # check for packages
        for item in $PACKAGE1 $PACKAGE2 $PACKAGE3 $PACKAGE4 $PACKAGE5; do
                rpm -qa | grep $item
                if [ $? -eq 0 ] ; then
                        rlPass "$item package is installed"
                else   
                        rlLog "$item package NOT found!"
			rRun "yum install -y $item"
                fi
        done


        # Setup /etc/sysconfig/autofs & /etc/autofs_ldap_auth.conf
cat /etc/autofs_ldap_auth.conf << EOF
<?xml version="1.0" ?>
<!--
This files contains a single entry with multiple attributes tied to it.
See autofs_ldap_auth.conf(5) for more information.
-->

<autofs_ldap_sasl_conf
        usetls="no"
        tlsrequired="no"
        authrequired="simple"
        user="$ROOTDN"
        secret="$ROOTDNPWD"
/>
EOF

cat /etc/sysconfig/autofs << EOF
TIMEOUT=60
BROWSE_MODE="no"
MOUNT_NFS_DEFAULT_PROTOCOL=4
LOGGING="debug"
LDAP_URI="ldap://$MASTER"
SEARCH_BASE="cn=loc1,cn=automount,$basedn"
MAP_OBJECT_CLASS="automountMap"
ENTRY_OBJECT_CLASS="automount"
MAP_ATTRIBUTE="automountMapName"
ENTRY_ATTRIBUTE="automountKey"
VALUE_ATTRIBUTE="automountInformation"
AUTH_CONF_FILE="/etc/autofs_ldap_auth.conf"
EOF
        # kinit as admin and creating users
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user1 $user1 $user1 $userpw"
        sleep 5
        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
        rlRun "create_ipauser $user2 $user2 $user2 $userpw"
        rlRun "TmpDir=\`mktemp -d\`" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

        # stopping firewall
        rlRun "service iptables stop"

	# setting up nfs and automount maps
cat > /etc/exports  << EOF
/ipashare       *(rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534)
/share          *(rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534)
EOF

cat > /etc/auto.master  << EOF
/-      /etc/auto.direct 
/ipashare       /etc/auto.loc1
EOF

cat > /etc/auto.direct << EOF
/share  -rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534 $MASTER:/usr/share/man 
EOF

cat > /etc/auto.loc1 << EOF
*       -rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534 $MASTER:/tmp
EOF

        rlRun "mkdir /share /ipashare"
        rlRun "service nfs restart"
        rlRun "service autofs restart"
	rlRun "showmount -e $MASTER"
rlPhaseEnd
}

automountlocation-add_func_001() {

rlPhaseStartTest "automountlocation-add_func_001: ipa automountlocation-add LOCATION"

	rlRun "ipa automountlocation-add loc1"

	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn"
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=nsContainer\" \"cn=loc1\""
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.master\""
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automount\" \"automountInformation=auto.direct\" \"automountKey=/-\""

        rlRun "ipa automountlocation-del loc1"

rlPhaseEnd
}

automountlocation-del_func_001() {

rlPhaseStartTest "automountlocation-del_func_001: ipa automountlocation-del LOCATION"

        rlRun "ipa automountlocation-add loc1"
	rlRun "ipa automountlocation-del loc1"

        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn" 32
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=nsContainer\" \"cn=loc1\"" 32
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.master\"" 32
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D $ROOTDN -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automount\" \"automountInformation=auto.direct\" \"automountKey=/-\"" 32

rlPhaseEnd
}

automountlocation-import_func_001() {

rlPhaseStartTest "automountlocation-import_func_001: ipa automountlocation-import LOCATION MASTER"

	rlRun "ipa automountlocation-import loc1 /etc/auto.master > $TmpDir/automountlocation-import_func_001.out 2>&1"
	rlAssertGrep "" "$TmpDir/automountlocation-import_func_001.out"

rlPhaseEnd
}

cleanup() {
rlPhaseStartTest "Clean up for automount configuration tests"
        rlRun "kinitAs $ADMINID $ADMINPW" 0
        rlRun "ipa user-del $user1"
        sleep 5
        rlRun "ipa user-del $user2"
        rlRun "kdestroy" 0 "Destroying admin credentials."

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        rlRun "rm -fr /tmp/krb5_1*"
rlPhaseEnd
}

