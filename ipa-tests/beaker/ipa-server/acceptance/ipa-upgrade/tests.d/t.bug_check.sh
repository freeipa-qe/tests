#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   t.upgrade_bug_check.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA multihost upgrade bug check script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following needs to be tested:
#   
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2012 Red Hat, Inc. All rights reserved.
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


######################################################################
# variables
######################################################################
### Relies on MYROLE variable to be set appropriately.  This is done
### manually or in runtest.sh
######################################################################

######################################################################
# test suite
######################################################################
upgrade_bz_766096()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_766096: Handle schema upgrades from IPA v2 to v3"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        rlRun "ldapsearch -xLLL -D '$ROOTDN' -w '$ROOTDNPWD' -s base -b cn=schema '*' attributeTypes objectClasses | perl -p0e 's/\n //g' > $tmpout"
        rlRun "grep memberPrincipal $tmpout"       0 "Checking for memberPrincipal attribute added to schema"
        rlRun "grep ipaAllowToImpersonate $tmpout" 0 "Checking for ipaAllowToImpersonate attribute added to schema"
        rlRun "grep ipaAllowedTarget $tmpout"      0 "Checking for ipaAllowedTarget attribute added to schema"
        rlRun "grep groupOfPrincipals $tmpout"     0 "Checking for groupOfPrincipals attribute added to schema"
        rlRun "grep ipaKrb5DelegationACL $tmpout"  0 "Checking for ipaKrb5DelegationACL attribute added to schema"
        checkattrs=$(egrep "memberPrincipal|ipaAllowToImpersonate|ipaAllowedTarget|groupOfPrincipals|ipaKrb5DelegationACL" $tmpout|wc -l)

        if [ -f /usr/share/ipa/updates/10-60basev3.update -a $checkattrs -eq 5 ]; then
            rlPass "BZ 766096 not found....all v3 attributes found in schema"
        else
            rlFail "BZ 766096 found...Handle schema upgrades from IPA v2 to v3"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}


upgrade_bz_746589()
{
    local tmpout=/tmp/$FUNCNAME.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "upgrade_bz_746589: automember functionality not available for upgraded IPA server"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        KinitAsAdmin
        rlLog "checking if upgrade"
        isUpgrade=$(yum history package  $PKG-server|head -5|grep Update|wc -l)
        if [ $isUpgrade -eq 0 ]; then
            rlPass "IPA not an upgrade...skipping test"
        else
            rlRun "ipa group-add --desc=ipa-automember-bz-746589 ipa-automember-bz-746589"
            rlRun "ipa automember-add --type=group ipa-automember-bz-746589  > $tmpout 2>&1"
            if [ $? -eq 0 ]; then
                rlPass "BZ 746589 not found"
            elif [ $(grep "ipa: ERROR: Auto Membership is not configured" $tmpout|wc -l) -eq 1 ]; then
                rlFail "BZ 746589 found...automember functionality not available for upgraded IPA server"
            fi      
            ipa automember-del --type=group ipa-automember-bz-746589 > /dev/null
            ipa group-del ipa-automember-bz-746589 > /dev/null
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_782918()
{
    local tmpout=/tmp/$FUNCNAME.out
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    rlLog "upgrade_bz_782918: Provide man page for ipa-upgradeconfig"
    case "$MYROLE" in
    MASTER*)
        rlRun "test -f /usr/share/man/man8/ipa-upgradeconfig.8.gz"
        if [ ! -f /usr/share/man/man8/ipa-upgradeconfig.8.gz ]; then
            rlLog "No man page for ipa-upgradeconfig found"
            rlFail "BZ 782918 found...Provide man page for ipa-upgradeconfig"
        else
            rlLog "Man page for ipa-upgradeconfig found"
            rlPass "BZ 782918 not found"
        fi
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_803054()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_803054: ipa commands after upgrade return Insufficient access: KDC returned NOT_ALLOWED_TO_DELEGATE"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "ipactl restart"
        rlRun "ipa user-find > $tmpout 2>&1"
        if [ $(grep "ipa: ERROR: Insufficient access: KDC returned NOT_ALLOWED_TO_DELEGATE" $tmpout|wc -l) -gt 0 ]; then
            rlFail "Need SELinux check for BZ799102 fix for this too"
            rlFail "BZ 803054 found...ipa commands after upgrade return Insufficient access: KDC returned NOT_ALLOWED_TO_DELEGATE"
        elif [ $(grep "User login: admin" $tmpout | wc -l) -gt 0 ]; then
            rlPass "BZ 803054 not found...ipa user-find succeeded.  No error returned"
        else
            rlFail "Unknown error found.  Manually check upgrade"
        fi
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_809262()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_809262: IPA Upgrade Web UI failure with internal server error"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        rlLog "Checking SELinux Boolean httpd_manage_ipa"
        seboolchk=$(getsebool httpd_manage_ipa|grep " on$"|wc -l)
        if [ $seboolchk -eq 0 ]; then
            rlFail "SELinux Boolean httpd_manage_ipa needs to be set to on/true for WebUI to work."
        else
            rlPass "SELinux Boolean httpd_manage_ipa is enabled"
        fi  
        
        rlLog "Checking Web UI"

        rlLog "Prepare json query in file"
        jsonfile=/tmp/jsoninput
        echo '{"method":"user_find","params":[[],{"sizelimit":0,"pkey_only":true}]}' > $jsonfile

        rlLog "Getting Session ID with:  curl -v --negotiate -u: https://$MASTER/ipa/session/login_kerberos --cacert /etc/ipa/ca.crt"
        sessionid=$(curl -v --negotiate -u: https://$MASTER/ipa/session/login_kerberos --cacert /etc/ipa/ca.crt 2>&1 |grep ipa_session 2>&1|sed 's/^.*ipa_session=\([0-Z]*\).*$/\1/')

        rlRun "curl  -H \"Content-Type:application/json\" -H \"Referer: https://$MASTER/ipa/xml\" -H \"Accept:application/json\"  -H \"Accept-Language:en\" --cacert /etc/ipa/ca.crt -d  @$jsonfile -X POST -b \"ipa_session=$sessionid; httponly; Path=/ipa; secure\" https://$MASTER/ipa/session/json > $tmpout 2>&1" 
        rlRun "cat $tmpout"
        rlLog "Checking $tmpout for \"Internal Server Error\""
        weberrors=$(grep -i "Internal Server Error" $tmpout|wc -l)
        if [ $weberrors -gt 0 ]; then
            rlLog "Internal Server Error Found"
            rlFail "BZ 809262 found...IPA Upgrade Web UI failure with internal server error"
        else
            rlLog "Internal Server Error Not Found"
            rlPass "BZ 809262 not found...WebUI did not return Internal Server Error"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_808201()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_808201: IPA Master Upgrade failed with argument of type 'NoneType' is not iterable"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlLog "Restarting IPA services"
        rlRun "ipactl restart"

        rlLog "Check for Kerberos error from ipa user-find command"
        rlRun "ipa user-find > $tmpout 2>&1"
        if [ $(grep "ipa: ERROR: Kerberos error: did not receive Kerberos credentials/" $tmpout|wc -l) -gt 0 ]; then
            rlFail "ipa command returns kerberos error"
        fi

        rlLog "check for NoneType is not iterable error in /var/log/ipaupgrade"
        if [ $(grep "ERROR Upgrade failed with argument of type 'NoneType' is not iterable" /var/log/ipaupgrade.log |wc -l) -gt 0 ]; then
            rlFail "Upgrade NoneType not iterable error found in /var/log/ipaupgrade"
            rlFail "BZ 808201 found...IPA Master Upgrade failed with argument of type 'NoneType' is not iterable"
        else
            rlPass "BZ 808201 not found...ipa user-find after upgrade succeeded.  No error returned."
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_803930()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local failcount=0
    rlLog "upgrade_bz_803930: ipa not starting after upgade because of missing data"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        rlLog "Restarting IPA services and checking for list of services error"
        rlRun "ipactl restart > $tmpout 2>&1"
        rlRun "cat $tmpout"
        if [ $(grep "Failed to read data from Directory Service: Failed to get list of services to probe status" $tmpout | wc -l) -gt 0 ]; then
            rlFail "BZ 803930 ipactl restart error found"
        else
            rlPass "BZ 803930 ipactl restart error not found.  IPA restarted cleanly"   
        fi
        
        rlLog "Checking for NoneType error in upgrade log"
        if [ $(grep "ERROR Add failure 'NoneType' object is not callable" /var/log/ipaupgrade.log | wc -l) -gt 0 ]; then
            rlFail "BZ 803930 NoneType errors found in ipaupgrade.log"
        else
            rlPass "BZ 803930 NoneType errors not found in ipaupgrade.log"
        fi

        rlLog "Checking for errors in dirsrv log"
        INSTANCE=$(echo $RELM|sed 's/\./-/g')
        if [ $(grep _get_and_add /var/log/dirsrv/slapd-$INSTANCE/errors|wc -l) -gt 0 ]; then
            rlFail "BZ 803930 dirsrv _get_and_add errors found"
            rlFail "BZ 803930 found...ipa not starting after upgade because of missing data"
        else
            rlPass "BZ 803930 _get_and_add errors not found in dirsrv log"
            rlPass "BZ 803930 not found."
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_772359_start()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_772359_start: Need tool to update exclusive list in replication agreements"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        
        rlLog "capture LDAP mapping tree data before upgrade from MASTER ($MASTER)"
        rlRun "ldapsearch -x -D '$ROOTDN' -w '$ROOTDNPWD' -b 'cn=mapping tree,cn=config' > /tmp/ldap_mapping_tree.out"
        
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"

        rlLog "capture LDAP mapping tree data before upgrade from REPLICA ($REPLICA)"
        rlRun "ldapsearch -x -D '$ROOTDN' -w '$ROOTDNPWD' -b 'cn=mapping tree,cn=config' > /tmp/ldap_mapping_tree.out"

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_772359_finish()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_772359_finish: Need tool to update exclusive list in replication agreements"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        
        rlLog "capture LDAP mapping tree data before upgrade from MASTER ($MASTER)"
        rlRun "ldapsearch -x -D '$ROOTDN' -w '$ROOTDNPWD' -b 'cn=mapping tree,cn=config' > /tmp/ldap_mapping_tree_after_upgrade.out"
        rlRun "diff /tmp/ldap_mapping_tree.out /tmp/ldap_mapping_tree_after_upgrade.out" 1
        if [ $(grep "nsDS5ReplicatedAttributeList:.*EXCLUDE.*memberof" /tmp/ldap_mapping_tree_after_upgrade.out | wc -l) -gt 0 ]; then
            rlPass "memberof found in Replication Agreement EXCLUDE list"
            rlPass "BZ 772359 not found."
        else
            rlFail "memberof not found in Replication Agreement EXCLUDE list"
            rlFail "BZ 772359 found."
        fi
        
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"

        rlLog "capture LDAP mapping tree data after upgrade from REPLICA ($REPLICA)"
        rlRun "ldapsearch -x -D '$ROOTDN' -w '$ROOTDNPWD' -b 'cn=mapping tree,cn=config' > /tmp/ldap_mapping_tree_after_upgrade.out"
        rlRun "diff /tmp/ldap_mapping_tree.out /tmp/ldap_mapping_tree_after_upgrade.out" 1
        if [ $(grep "nsDS5ReplicatedAttributeList:.*EXCLUDE.*memberof" /tmp/ldap_mapping_tree_after_upgrade.out | wc -l) -gt 0 ]; then
            rlPass "memberof found in Replication Agreement EXCLUDE list"
            rlPass "BZ 772359 not found."
        else
            rlFail "memberof not found in Replication Agreement EXCLUDE list"
            rlFail "BZ 772359 found."
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_812391()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local failcount=0
    rlLog "upgrade_bz_812391: IPA uninstall after upgrade returns some sysrestore.state errors"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
            
        rlLog "Checking ipaserver-uninstall.log on MASTER ($MASTER) for BZ 812391 Errors"
        if [ $(grep "ERROR Some installation state for dirsrv has not been restored" /var/log/ipaserver-uninstall.log | wc -l) -gt 0 ]; then
            rlFail "Found installation state not restored errors in ipaserver-uninstall.log"
            grep "ERROR Some installation state for dirsrv has not been restored" /var/log/ipaserver-uninstall.log
            rlFail "BZ 812391 found...IPA uninstall after upgrade returns some sysrestore.state errors"
        else
            rlPass "BZ 812391 not found...installation state errors not found in ipaserver-uninstall.log"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"

        rlLog "Checking ipaserver-uninstall.log on MASTER ($MASTER) for BZ 812391 Errors"
        if [ $(grep "ERROR Some installation state for dirsrv has not been restored" /var/log/ipaserver-uninstall.log | wc -l) -gt 0 ]; then
            rlFail "Found installation state not restored errors in ipaserver-uninstall.log"
            grep "ERROR Some installation state for dirsrv has not been restored" /var/log/ipaserver-uninstall.log
            rlFail "BZ 812391 found...IPA uninstall after upgrade returns some sysrestore.state errors"
        else
            rlPass "BZ 812391 not found...installation state errors not found in ipaserver-uninstall.log"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_821176()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_821176: ns-slapd segfault in libreplication-plugin after IPA upgrade from 2.1.3 to 2.2.0"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlLog "Restarting IPA services"
        rlRun "ipactl restart"
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.1' -m $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        rlLog "Checking /var/log/messages for ns-slapd segfault"
        if [ $(grep "ns-slapd.*segfault.*at.*error 4 in libreplication-plugin.so" /var/log/messages|wc -l) -gt 0 ]; then
            rlFail "BZ 821176 found...ns-slapd segfault in libreplication-plugin after IPA upgrade from 2.1.3 to 2.2.0"
            rlFail "ns-slapd segfault messages found in /var/log/messages"
            rlRun "grep \"ns-slapd.*segfault.*at.*error 4 in libreplication-plugin.so\" /var/log/messages" 
        else
            rlPass "BZ 821176 not found.  No ns-slapd segfault found in /var/log/messages"
        fi
        
        INSTANCE=$(echo $RELM|sed 's/\./-/g')
        rlLog "Checking /var/log/dirsrv/slapd-$INSTANCE/errors for LDAP error"
        if [ $(grep "NSMMReplicationPlugin.*Warning: unable to send endReplication extended operation.*Can't contact LDAP server" /var/log/dirsrv/slapd-$INSTANCE/errors|wc -l) -gt 0 ]; then
            rlFail "BZ 821176 found...found Can't contact LDAP server messages in dirsrv log"
        else
            rlPass "BZ 821176 not found...didn't find LDAP error in dirsrv log"
        fi
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.3' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlLog "Running ipa-replica-manage force-sync to make sure that works"
        rlRun "ipa-replica-manage force-sync --from=$MASTER_S.$DOMAIN --password=$ROOTDNPWD"
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT.2' -m $MYBEAKERREPLICA1"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.3' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.1' $MYBEAKERMASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.2' $MYBEAKERREPLICA1"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT.3' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_819629_setup()
{
    # Setup section for BZ 819629
    # Backup /etc/named.conf, then, remove any psearch line from the file.  
    # Upgrade needs to be run after this setup section to ensure that psearch is enabled after upgrade.
    
    rlLog "backup/section for BZ 819629"
    case "$MYROLE" in
    MASTER*)
        dc=$(date +%m-%d-%Y-%s)
        cp -a /etc/named.conf /etc/named-conf-backup-$dc
        cat /etc/named.conf | grep -v psearch > /opt/rhqa_ipa/named.conf-tmp
        cat /opt/rhqa_ipa/named.conf-tmp > /etc/named.conf
        # For fedora
        systemctl restart named.service
        # For RHEL
        /etc/init.d/named restart
        rlRun "grep psearch /etc/named.conf" 1 "Make sure a psearch is not anywhere in named.conf"
        ;;
    *)
        rlPass "Machine in recipe is not a ROLE that needs to be tested...set MYROLE variable"
        ;;
    esac
    rlPhaseEnd

}

upgrade_bz_819629()
{
    # Make sure that psearch is reinserted into named.conf after a upgrade. 

    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_819629 - Enable persistent search in bind-dyndb-ldap during IPA upgrade"
    case "$MYROLE" in
    MASTER*)
        rlRun "grep psearch /etc/named.conf  | grep yes" 0 "Make sure a psearch enabled line exists in named.conf"
        rlRun "grep psearch /etc/named.conf  | grep no" 1 "Make sure a psearch is not disabled anywhere in named.conf"
        ;;
    *)
        rlPass "Machine in recipe is not a ROLE that needs to be tested...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_824074()
{
    # 824074 - Create ipaserver-upgrade.log on upgrades

    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    rlLog "upgrade_bz_824074 - Create ipaserver-upgrade.log on upgrades"
    case "$MYROLE" in
    MASTER*)
        rlRun "ls /var/log/ipaupgrade.log" 0 "Basic sanity check to ensure that /var/log/ipaupgrade.log was created"
        ;;
    *)
        rlPass "Machine in recipe is not a ROLE that needs to be tested...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_893722()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local failcount=0
    rlLog "upgrade_bz_893722: ipa-server upgrade ERROR Cannot move CRL file to new directory"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        if [ -f /var/log/ipaupgrade.log ]; then 
            rlAssertNotGrep "Cannot move CRL file to new directory" /var/log/ipaupgrade.log
            if [ $? -gt 0 ]; then
                rlFail "BZ 893722 found...ipa-server upgrade ERROR Cannot move CRL file to new directory"
            else
                rlPass "BZ 893722 not found"
            fi
        else
            rlLog "No /var/log/ipaupgrade.log to check BZ 893722"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_895298_check_master()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local logfile=/var/log/ipaupgrade.log
    local failcount=0
    rlLog "upgrade_bz_895298_check_master: IPA upgrade error restarting named when dirsrv off before upgrade"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        if [ -f $logfile ]; then 
            submit_log $logfile
            rlAssertNotGrep "The ipa-upgradeconfig command failed.*named restart" $logfile
            if [ $? -gt 0 ]; then
                rlFail "BZ 895298 found...IPA upgrade error restarting named when dirsrv off before upgrade"
            else
                rlPass "BZ 895298 not found"
            fi
            rlRun "grep 'ERROR Failed to restart named' $logfile" 0,1
            if [ $? -eq 0 ]; then
                rlLog "workaround: restarting everything"
                rlRun "ipactl restart"
                rlRun "service sssd restart"
                submit_log $logfile
            fi
        else
            rlLog "No /var/log/ipaupgrade.log to check BZ 895298"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_895298_check_slave()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local logfile=/var/log/ipaupgrade.log
    local failcount=0
    rlLog "upgrade_bz_895298_check_slave: IPA upgrade error restarting named when dirsrv off before upgrade"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERREPLICA1"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"

        if [ -f $logfile ]; then 
            submit_log $logfile
            rlAssertNotGrep "The ipa-upgradeconfig command failed.*named restart" $logfile
            if [ $? -gt 0 ]; then
                rlFail "BZ 895298 found...IPA upgrade error restarting named when dirsrv off before upgrade"
            else
                rlPass "BZ 895298 not found"
            fi
            rlRun "grep 'ERROR Failed to restart named' $logfile" 0,1
            if [ $? -eq 0 ]; then
                rlLog "workaround: restarting everything"
                rlRun "ipactl restart"
                rlRun "service sssd restart"
                submit_log $logfile
            fi
        else
            rlLog "No /var/log/ipaupgrade.log to check BZ 895298"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERREPLICA1"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERREPLICA1"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgade_bz_866977_setup()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local logfile=/var/log/ipaupgrade.log
    local failcount=0
    rlLog "upgade_bz_866977_setup: Prepare to test BZ 866977"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        # sed named.conf and change something...
        # sed -i '/dynamic-db \"ipa\"/,/^}/s/\(};\)/\targ "connections 1";\n\1/' /etc/named.conf
        rlRun "sed -i '/dynamic-db \"ipa\"/,/\^}/ s/\\(};\\)/\\targ \"connections 1\";\\n\\1/' /etc/named.conf"
        rlRun "chattr +i /etc/named.conf"
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_866977_check()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local logfile=/var/log/ipaupgrade.log
    local outfile=/tmp/upgrade_master_bz_866977.out
    local failcount=0
    rlLog "upgrade_bz_866977_check: Inform user when ipa-upgradeconfig reports errors"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"
        if [ -f $logfile ]; then
            rlAssertGrep "ERROR Cannot update connections in /etc/named.conf:" $logfile
        fi
        if [ -f $outfile ]; then
            rlAssertGrep "Cannot update connections in /etc/named.conf.*Permission denied" $outfile
            if [ $? -ne 0 ]; then
                rlFail "BZ 866977 found...Inform user when ipa-upgradeconfig reports errors"    
            else
                rlPass "BZ 866977 not found."
            fi      
        else
            rlLog "Not output file to scan for bug info"
        fi
        rlRun "chattr -i /etc/named.conf"
        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_903758()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local failcount=0
    rlLog "upgrade_bz_903758: upgrading IPA from 2.2 to 3.0 sees certmonger errors"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        if [ -f /var/log/ipaupgrade.log ]; then 
            rlAssertNotGrep "ERROR certmonger failed to start tracking certificate:.*dogtag-ipa-renew-agent" /var/log/ipaupgrade.log
            if [ $? -gt 0 ]; then
                rlFail "BZ 903758 found...upgrading IPA from 2.2 to 3.0 sees certmonger errors"
                rlRun "grep -B 4 'ERROR certmonger failed to start tracking certificate:' /var/log/ipaupgrade.log"
            else
                rlPass "BZ 903758 not found"
            fi
        else
            rlLog "No /var/log/ipaupgrade.log to check BZ 893722"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

upgrade_bz_902474()
{
    TESTCOUNT=$(( TESTCOUNT += 1 ))
    local tmpout=/tmp/errormsg.out
    local failcount=0
    rlLog "upgrade_bz_902474: upgrading IPA from 2.2 to 3.0 sees certmonger errors"
    case "$MYROLE" in
    MASTER*)
        rlLog "Machine in recipe is MASTER"

        rlRun "ausearch -m avc > $tmpout 2>&1" 1
        rlAssertNotGrep  "certmonger_t:.*pki_ca_var_lib_t" $tmpout
        if [ $? -gt 0 ]; then
            rlFail "BZ 902474 found...upgrading IPA from 2.2 to 3.0 sees certmonger errors"
        else
            rlPass "BZ 902474 not found"
        fi

        rlRun "rhts-sync-set -s '$FUNCNAME.$TESTCOUNT' -m $MYBEAKERMASTER"
        ;;
    REPLICA*)
        rlLog "Machine in recipe is REPLICA"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    CLIENT*)
        rlLog "Machine in recipe is CLIENT"
        rlRun "rhts-sync-block -s '$FUNCNAME.$TESTCOUNT' $MYBEAKERMASTER"
        ;;
    *)
        rlLog "Machine in recipe is not a known ROLE...set MYROLE variable"
        ;;
    esac
    [ -f $tmpout ] && rm -f $tmpout
}

replicaBugCheck_bz830314()
{
    rlLog "replicaBugCheck_bz830314 - ipa-replica-install named failed to start"
    if [ -f /var/log/ipareplica-install.log ]; then
        if [ $(grep "Starting named:.*[FAILED]" /var/log/ipareplica-install.log |wc -l) -gt 0 ]; then
            rlFail "BZ 830314 found...ipa-replica-install named failed to start"
            rlRun "sed -n '/restarting named/,/7\/8/p' /var/log/ipareplica-install.log" 
            rlRun "submit_log /var/log/ipareplica-install.log"
            rlRun "submit_log /var/log/messages"
            rlRun "service named start"
        else
            rlPass "BZ 830314 not found...named did not seem to fail on ipa install"
        fi
    else
        rlFail "Cannot find ipareplica-install.log to check BZ 830314"
    fi
    ####### debugging here #################
    #rlRun "grep named /var/log/ipareplica-install.log"
}
