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
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh

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
basedn=`getBaseDN`

PACKAGE1="ipa-admintools"
PACKAGE2="ipa-client"
PACAKGE3="nfs-utils"
PACKAGE4="autofs"
PACKAGE5="setup"

func_setup() {
rlPhaseStartTest "Setup for automount configuration tests"

	# Checking for autofs and related packages
        # check for packages
        for item in $PACKAGE1 $PACKAGE2 $PACKAGE3 $PACKAGE4 $PACKAGE5; do
                rpm -qa | grep $item
                if [ $? -eq 0 ] ; then
                        rlPass "$item package is installed"
                else   
                        rlLog "$item package NOT found!"
			rlRun "yum install -y $item"
                fi
        done


        # Setup /etc/sysconfig/autofs & /etc/autofs_ldap_auth.conf
cat > /etc/autofs_ldap_auth.conf << EOF
<?xml version="1.0" ?>
<!--
This files contains a single entry with multiple attributes tied to it.
See autofs_ldap_auth.conf(5) for more information.
-->

<autofs_ldap_sasl_conf
	usetls="no"
	tlsrequired="no"
	authrequired="yes"
	authtype="GSSAPI"
	clientprinc="host/$MASTER@$RELM"
/>
EOF

	rlRun "cat /etc/autofs_ldap_auth.conf"

cat > /etc/sysconfig/autofs << EOF
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

	rlRun "cat /etc/sysconfig/autofs"

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
	rlRun "perl -pi -e 's/automount:  files/automount:  ldap/g'  /etc/nsswitch.conf"

        cat /etc/redhat-release | grep "Fedora"
        if [ $? -eq 0 ] ; then
                FLAVOR="Fedora"
                rlLog "Automation is running against Fedora"
		rlRun "service nfs-server restart"
        else   
                FLAVOR="RedHat"
                rlLog "Automation is running against RedHat"
        	rlRun "service nfs restart"
        fi

        rlRun "service autofs restart"
	rlRun "showmount -e $MASTER"
rlPhaseEnd
}

automountlocation-add_func_001() {

rlPhaseStartTest "automountlocation-add_func_001: ipa automountlocation-add LOCATION"

        rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	rlRun "ipa automountlocation-add loc1"

	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn"
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=nsContainer\" \"cn=loc1\""
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.master\""
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automount\" \"automountInformation=auto.direct\" \"automountKey=/-\""

        rlRun "ipa automountlocation-del loc1"

rlPhaseEnd
}

automountlocation-del_func_001() {

rlPhaseStartTest "automountlocation-del_func_001: ipa automountlocation-del LOCATION"

        rlRun "ipa automountlocation-add loc1"
	rlRun "ipa automountlocation-del loc1"

        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn" 32
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=nsContainer\" \"cn=loc1\"" 32
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.master\"" 32
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn \"objectClass=automount\" \"automountInformation=auto.direct\" \"automountKey=/-\"" 32

rlPhaseEnd
}

automountlocation-import_func_001() {

rlPhaseStartTest "automountlocation-import_func_001: ipa automountlocation-import LOCATION MASTER"

	rlRun "ipa automountlocation-add loc1"

	rlRun "ipa automountlocation-import loc1 /etc/auto.master > $TmpDir/automountlocation-import_func_001.out 2>&1"
	rlAssertGrep "Imported maps:" "$TmpDir/automountlocation-import_func_001.out"
	# Commenting the following test since auto.direct would already exist and it would just import the key not the map.
	# rlAssertGrep "Added auto.direct" "$TmpDir/automountlocation-import_func_001.out"
	rlAssertGrep "Added auto.loc1" "$TmpDir/automountlocation-import_func_001.out"
	rlAssertGrep "Imported keys:" "$TmpDir/automountlocation-import_func_001.out"
	# Commenting the following test since auto.master would already have /~ while creating a location.
	# rlAssertGrep "Added /- to auto.master" "$TmpDir/automountlocation-import_func_001.out"
	rlAssertGrep "Added /ipashare to auto.master" "$TmpDir/automountlocation-import_func_001.out"
	rlAssertGrep "Added \* to auto.loc1" "$TmpDir/automountlocation-import_func_001.out"
	rlAssertGrep "Added /share to auto.direct" "$TmpDir/automountlocation-import_func_001.out"

	rlRun "cat $TmpDir/automountlocation-import_func_001.out"

	rlRun "ipa automountlocation-tofiles loc1 > $TmpDir/automountlocation-import_func_001.out 2>&1"
	rlAssertGrep "/etc/auto.master:" "$TmpDir/automountlocation-import_func_001.out"
	# Commenting the following test since auto.master would already have /~ while creating a location.
	# rlAssertGrep "/-        /etc/auto.direct" "$TmpDir/automountlocation-import_func_001.out"
	# Commented the following test and grepping in a different way.
	#rlAssertGrep "/ipashare        /etc/auto.loc1" "$TmpDir/automountlocation-import_func_001.out"
	rlRun "cat $TmpDir/automountlocation-import_func_001.out | grep -E '(/ipashare|/etc/auto.loc1)'"
	rlAssertGrep "/etc/auto.direct:" "$TmpDir/automountlocation-import_func_001.out"
	# Commented the following test and grepping in a different way
	# rlAssertGrep "/share  -rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534 $MASTER:/usr/share/man" "$TmpDir/automountlocation-import_func_001.out"
	rlRun "cat $TmpDir/automountlocation-import_func_001.out | grep -E '(share|rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534|$MASTER:/usr/share/man)'"
	rlAssertGrep "/etc/auto.loc1:" "$TmpDir/automountlocation-import_func_001.out"
	# Commented the following test and grepping in a different way
	# rlAssertGrep "*        -rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534 $MASTER:/tmp" "$TmpDir/automountlocation-import_func_001.out"
	rlRun "cat $TmpDir/automountlocation-import_func_001.out | grep -E '(*|rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534|$MASTER:/tmp)'"

	rlRun "cat $TmpDir/automountlocation-import_func_001.out"

        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b cn=loc1,cn=automount,$basedn" 
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn"
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b description=/share,automountmapname=auto.direct,cn=loc1,cn=automount,$basedn"
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b description=/ipashare,automountmapname=auto.master,cn=loc1,cn=automount,$basedn"
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b \"description=/- auto.direct,automountmapname=auto.master,cn=loc1,cn=automount,$basedn\""

	rlRun "ipa automountlocation-del loc1"
	rlRun "rm -fr /etc/auto.master /etc/auto.direct /etc/auto.loc1"

rlPhaseEnd
}

automountmap-add_func_001() {

rlPhaseStartTest "automountmap-add_func_001: ipa automountmap-add LOCATION MAP"

	rlRun "ipa automountlocation-add loc1"

	rlRun "ipa automountmap-add loc1 auto.loc1"
	rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.loc1\""

	rlRun "ipa automountlocation-del loc1"

rlPhaseEnd
}

automountmap-del_func_001() {

rlPhaseStartTest "automountmap-del_func_001: ipa automountmap-del LOCATION MAP"

        rlRun "ipa automountlocation-add loc1"
        rlRun "ipa automountmap-add loc1 auto.loc1"
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.loc1\""


        rlRun "ipa automountlocation-del loc1"
        rlRun "/usr/bin/ldapsearch -LLL -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn \"objectClass=automountmap\" \"automountMapName=auto.loc1\"" 32

rlPhaseEnd
}

automountmap-mod_func_001() {

rlPhaseStartTest "automountmap-mod_func_001: ipa automountmap-mod LOCATION MAP"

        rlRun "ipa automountlocation-add loc1"
        rlRun "ipa automountmap-add loc1 auto.loc1"

	# Testing --desc option
	rlRun "ipa automountmap-mod loc1 auto.loc1 --desc=loc1"
	rlRun "/usr/bin/ldapsearch  -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn > $TmpDir/automountmap-mod_func_001.out 2>&1"
	rlAssertGrep "objectClass: automountmap" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "automountMapName: auto.loc1" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "description: loc1" "$TmpDir/automountmap-mod_func_001.out"
	rlRun "cat $TmpDir/automountmap-mod_func_001.out"

	# Testing --setattr
	rlRun "ipa automountmap-mod loc1 auto.loc1 --setattr=description=testmod"
	rlRun "/usr/bin/ldapsearch  -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn > $TmpDir/automountmap-mod_func_001.out 2>&1"
        rlAssertGrep "objectClass: automountmap" "$TmpDir/automountmap-mod_func_001.out"
        rlAssertGrep "automountMapName: auto.loc1" "$TmpDir/automountmap-mod_func_001.out"
        rlAssertGrep "description: testmod" "$TmpDir/automountmap-mod_func_001.out"
	rlRun "cat $TmpDir/automountmap-mod_func_001.out"

        # Testing --addattr
	rlRun "ipa automountmap-mod loc1 auto.loc1 --setattr=description="
	rlRun "/usr/bin/ldapsearch  -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn > $TmpDir/automountmap-mod_func_001.out 2>&1"
        rlAssertNotGrep "description: testmod" "$TmpDir/automountmap-mod_func_001.out"
        rlRun "ipa automountmap-mod loc1 auto.loc1 --addattr=description=testmod"
        rlRun "/usr/bin/ldapsearch  -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn > $TmpDir/automountmap-mod_func_001.out 2>&1"
        rlAssertGrep "description: testmod" "$TmpDir/automountmap-mod_func_001.out"
        rlRun "cat $TmpDir/automountmap-mod_func_001.out"

	# Testing --all --raw --rights
        rlRun "ipa automountmap-mod loc1 auto.loc1 --setattr=description="
        rlRun "/usr/bin/ldapsearch  -x -h localhost -D \"$ROOTDN\" -w $ROOTDNPWD -b automountmapname=auto.loc1,cn=loc1,cn=automount,$basedn > $TmpDir/automountmap-mod_func_001.out 2>&1"
        rlAssertNotGrep "description: testmod" "$TmpDir/automountmap-mod_func_001.out"
        rlRun "ipa automountmap-mod loc1 auto.loc1 --addattr=description=testmod --all --rights --raw > $TmpDir/automountmap-mod_func_001.out 2>&1"
	rlAssertGrep "Modified automount map \"auto.loc1\"" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "automountmapname: auto.loc1" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "description: testmod" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "attributelevelrights: {'objectclass': u'rscwo', 'aci': u'rscwo', 'description': u'rscwo', 'nsaccountlock': u'rscwo', 'automountmapname': u'rscwo'}" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "objectclass: automountmap" "$TmpDir/automountmap-mod_func_001.out"
	rlAssertGrep "objectclass: top" "$TmpDir/automountmap-mod_func_001.out"
	rlRun "cat $TmpDir/automountmap-mod_func_001.out"

        rlRun "ipa automountlocation-del loc1"
rlPhaseEnd
}

direct_mount_functionality_001() {

rlPhaseStartTest "direct_mount_functionality_001: functionaly testing direct mount."

	rlRun "ipa automountlocation-add loc1"
	rlRun "ipa automountkey-add loc1 auto.direct --key=/share --info=\"-rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534 $MASTER:/usr/share/man\""
	rlRun "ipa automountlocation-tofiles loc1"
	rlRun "touch /usr/share/man/test"
	rlRun "> /var/log/messages"
	rlRun "service autofs restart"

	rlAssertExists "/share/test"
	rlAssertGrep " mounting root /share, mountpoint /share, what $MASTER:/usr/share/man, fstype nfs, options rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534" "/var/log/messages"
	rlAssertGrep "mount(nfs): /share is local, attempt bind mount" "/var/log/messages"
        rlAssertGrep "mount_mount: mount(bind): calling mount --bind -s  -o defaults /usr/share/man /share" "/var/log/messages"
	rlAssertGrep "mount_mount: mount(bind): mounted /usr/share/man type bind on /share" "/var/log/messages"

	rlRun "cat /var/log/messages"
	rlRun "ipa automountlocation-del loc1"

rlPhaseEnd
}

indirect_mount_functionality_001() {

rlPhaseStartTest "indirect_mount_functionality_001: functionality testing indirect mount."
	rlRun "kinitAs $ADMINID $ADMINPW" 0

        rlRun "ipa automountlocation-add loc1"
	rlRun "ipa automountmap-add loc1 auto.shanks"
	rlRun "ipa automountkey-add loc1 auto.master --key=/ipashare --info=auto.shanks"
	rlRun "ipa automountkey-add loc1 auto.shanks --key=* --info=\"-rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534 $MASTER:/tmp\""
	rlRun "ipa automountlocation-tofiles loc1"
	rlRun "> /var/log/messages"
	rlRun "service autofs restart"

	rlRun "touch /tmp/shanks.txt"
	rlRun "ipa user-mod $user1 --homedir=/ipashare/$user1"

	rlRun "touch /tmp/sudo_list.exp"

testout=/tmp/testout.txt
touch $testout
chown user1:user1 $testout
cat > /tmp/test_list.exp << EOF
#!/usr/bin/expect -f

set timeout 30
set send_slow {1 .1}
match_max 100000

spawn ssh -o StrictHostKeyChecking=no -l $user1 $MASTER
expect "*: "
send -s "$userpw\r"
expect "*$ "
send -s "ls -l /tmp > $testout 2>&1 \r"
expect eof
EOF

chmod 755 /tmp/test_list.exp
cat /tmp/test_list.exp
/tmp/test_list.exp
cat $testout

	rlAssertGrep "shanks.txt" "$testout"
	rlAssertGrep "mounting root /ipashare, mountpoint $user1, what $MASTER:/tmp, fstype nfs, options rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534" "/var/log/messages"
	rlAssertGrep "mount(nfs): root=/ipashare name=$user1 what=$MASTER:/tmp, fstype=nfs, options=rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534" "/var/log/messages"
	#rlAssertGrep "mount(nfs): nfs options=\"rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534\", nosymlink=0, ro=0" "/var/log/messages"
	rlAssertGrep "mount(nfs): nfs options=\"rw,fsid=0,insecure,no_root_squash,sync,anonuid=65534,anongid=65534\", nobind=0, nosymlink=0, ro=0" "/var/log/messages"
	rlAssertGrep "mount(nfs): calling mkdir_path /ipashare/$user1" "/var/log/messages"
	rlAssertGrep "mount(bind): calling mount --bind -s  -o defaults /tmp /ipashare/$user1" "/var/log/messages"
	rlAssertGrep "mount(bind): mounted /tmp type bind on /ipashare/$user1" "/var/log/messages"
	rlAssertGrep "mounted /ipashare/$user1" "/var/log/messages"

	rlRun "cat /var/log/messages"
	rlRun "kinitAs $ADMINID $ADMINPW" 0
	rlRun "ipa automountlocation-del loc1"

rlPhaseEnd
}


func_cleanup() {
rlPhaseStartTest "Clean up for automount configuration tests"
        rlRun "kinitAs $ADMINID $ADMINPW" 0
        rlRun "ipa user-del $user1"
        sleep 5
        rlRun "ipa user-del $user2"
        rlRun "kdestroy" 0 "Destroying admin credentials."

        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
        rlRun "rm -fr /tmp/krb5_1*"
	rlRun "rm -fr /etc/auto.master /etc/auto.direct /etc/auto.loc1"
	rlRun "> /etc/exports"
	rlRun "service autofs stop" 
	rlRun "rm -rf /ipashare /share"
	rlRun "service autofs start"
rlPhaseEnd
}

