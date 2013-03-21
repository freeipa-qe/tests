#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/ipa-tests/acceptance/ipa-upgrade
#   Description: IPA ipa-upgrade acceptance tests
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The following ipa will be tested:
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Scott Poore <spoore@redhat.com>
#   Date  : Nar 12, 2012
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


ipa_upgrade_master_replica_client_all()
{   
    USEDNS="yes"
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    rlPhaseStartSetup "ipa_upgrade_master_replica_client_all_setup: setup to test full setup for master, then replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
    rlPhaseEnd
        
    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_1: test upgrade with new master, old replica, and old client"
        upgrade_master 
        ipa_upgrade_data_check $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
        ipa_upgrade_data_check $MYBEAKERCLIENT
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_2: test upgrade with new master, new replica, and old client"
        upgrade_replica
        ipa_upgrade_data_check $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
        ipa_upgrade_data_check $MYBEAKERCLIENT
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_3: test upgrade with new master, new replica, and new client"
        upgrade_client
        ipa_upgrade_data_check $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
        ipa_upgrade_data_check $MYBEAKERCLIENT
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_master_replica_client_all_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}
    
ipa_upgrade_test_master_replica_parallel()
{
    use_beaker_repos
    USEDNS="yes"
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    rlPhaseStartSetup "ipa_upgrade_test_master_replica_parallel_setup: setup to test parallel upgrade for master and replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
    rlPhaseEnd
        
    rlPhaseStartTest "ipa_upgrade_test_master_replica_parallel_1: test upgrade with new master, old replica, and old client"
        upgrade_master_replica
        ipa_upgrade_data_check $MYBEAKERMASTER
        ipa_upgrade_data_check $MYBEAKERREPLICA1
        ipa_upgrade_data_check $MYBEAKERCLIENT
    rlPhaseEnd

    rlPhaseStartCleanup "ipa_upgrade_master_replica_parallel_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_inc_setup()
{   
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"
    USEDNS="yes"

    rlPhaseStartSetup "ipa_upgrade_master_replica_client_inc_setup: setup to test full setup for master, then replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_upgrade_install_master
        ipa_upgrade_install_replica
        ipa_upgrade_install_client
        ipa_upgrade_data_add $MYBEAKERMASTER
    rlPhaseEnd
}
        
ipa_upgrade_master_replica_client_inc_cleanup()
{
    rlPhaseStartCleanup "ipa_upgrade_master_replica_client_inc_cleanup: cleanup from test full setup for master, then replica, then client"
        ipa_upgrade_uninstall_client
        ipa_upgrade_uninstall_replica
        ipa_upgrade_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_inc_63()
{   
    unset ${!myrepo*}
    myrepo1=http://download.devel.redhat.com/released/RHEL-6/6.3/Server/\$basearch/os/
    myrepo2=http://download.devel.redhat.com/released/RHEL-6/6.3/Server/optional/\$basearch/os/
    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_63_1: test upgrade with new master, old replica, and old client"
        upgrade_master
        ipa_upgrade_data_add   $MYBEAKERMASTER   63

        ipa_upgrade_data_check $MYBEAKERMASTER   63 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 63 old
        ipa_upgrade_data_check $MYBEAKERCLIENT   63 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_63_2: test upgrade with new master, new replica, and old client"
        upgrade_replica

        ipa_upgrade_data_check $MYBEAKERMASTER   63 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 63 new
        ipa_upgrade_data_check $MYBEAKERCLIENT   63 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_63_3: test upgrade with new master, new replica, and new client"
        upgrade_client

        ipa_upgrade_data_check $MYBEAKERMASTER   63 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 63 new
        ipa_upgrade_data_check $MYBEAKERCLIENT   63 new
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_inc_64()
{   
    unset ${!myrepo*}
    myrepo1=http://download.devel.redhat.com/released/RHEL-6/6.4/Server/\$basearch/os/
    myrepo2=http://download.devel.redhat.com/released/RHEL-6/6.4/Server/optional/\$basearch/os/
    IPA_SERVER_OPTIONS="-U --setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"
    USEDNS="yes"

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_64_1: test upgrade with new master, old replica, and old client"
        upgrade_master
        ipa_upgrade_data_add   $MYBEAKERMASTER   64

        ipa_upgrade_data_check $MYBEAKERMASTER   64 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 64 old
        ipa_upgrade_data_check $MYBEAKERCLIENT   64 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_64_2: test upgrade with new master, new replica, and old client"
        upgrade_replica

        ipa_upgrade_data_check $MYBEAKERMASTER   64 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 64 new 
        ipa_upgrade_data_check $MYBEAKERCLIENT   64 old
    rlPhaseEnd

    rlPhaseStartTest "ipa_upgrade_master_replica_client_inc_64_3: test upgrade with new master, new replica, and new client"
        upgrade_client

        ipa_upgrade_data_check $MYBEAKERMASTER   64 new
        ipa_upgrade_data_check $MYBEAKERREPLICA1 64 new
        ipa_upgrade_data_check $MYBEAKERCLIENT   64 new
    rlPhaseEnd
}

ipa_upgrade_client_replica_master_all()
{
    USEDNS="yes"
    IPA_SERVER_OPTIONS="--setup-dns --forwarder=$DNSFORWARD --hostname=$MASTER_S.$DOMAIN -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
    IPA_REPLICA_OPTIONS="-U --setup-ca --setup-dns --forwarder=$DNSFORWARD -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$REPLICA1_S.$DOMAIN.gpg"
    IPA_CLIENT_OPTIONS="-U --domain=$DOMAIN --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MASTER_S.$DOMAIN"

    local tmpout=/tmp/errormsg.out
    rlPhaseStartTest "ipa_upgrade_client_replica_master_all: test full setup for client, then replica, then master"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_install_master_all
        ipa_install_replica_all
        ipa_install_client
        data_add

        # test upgrade with old master, old replica, and new client
        upgrade_client
        # No data_check here because it will fail...need negative checks for ipa commands
        # can't upgrade client first or ipa commands won't work.  native ones do but, ipa ones don't.
        if [ "$MYROLE" = "CLIENT" ]; then
            KinitAsAdmin 
            rlLog "Running negative test for ipa commands failing when client upgraded first"
            rlRun "ipa --delegate user-find > $tmpout 2>&1" 1
            if [ $(grep "ERROR.*client incompatible with.*server" $tmpout| wc -l) -gt 0 ]; then
                rlPass "Expected failure seen running ipa commands after upgrading client first"
            fi
            rlRun "cat $tmpout"
        fi

        # test upgrade with old master, new replica, and new client 
        upgrade_replica
        data_check $REPLICA1_IP

        # test upgrade with new master, new replica, and new client
        upgrade_master 
        data_check $MYBEAKERMASTER
        
        # check data from client again to make sure things look good now
        data_check $MYBEAKERCLIENT

        # uninstall everything so we can start over
        ipa_uninstall_client
        ipa_uninstall_replica
        ipa_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_nodns()
{
    USEDNS="no"
    IPA_SERVER_OPTIONS="-U --hostname=$MYBEAKERMASTER -r $RELM -n $DOMAIN -p $ADMINPW -P $ADMINPW -a $ADMINPW -U"
    IPA_REPLICA_OPTIONS="-U -w $ADMINPW -p $ADMINPW /opt/rhqa_ipa/replica-info-$MYBEAKERREPLICA1.gpg"
    IPA_CLIENT_OPTIONS="-U --realm=$RELM -p $ADMINID -w $ADMINPW --server=$MYBEAKERMASTER"

    rlPhaseStartTest "ipa_upgrade_master_replica_client_nodns: Test setup without dns for master, then replica, then client"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_install_master_nodns
        ipa_install_replica_nodns
        ipa_install_client
        data_add

        # test upgrade with old master, old replica, and old client
        upgrade_master
        data_check $MYBEAKERMASTER

        # test upgrade with new master, new replica, and old client
        upgrade_replica
        data_check $REPLICA1_IP

        # test upgrade with new master, new replica, and new client
        upgrade_client
        data_check $MYBEAKERCLIENT

        # uninstall everything so we can start over
        ipa_uninstall_client
        ipa_uninstall_replica
        ipa_uninstall_master
    rlPhaseEnd
}


ipa_upgrade_master_replica_client_dirsrv_off()
{
    rlPhaseStartTest "ipa_upgrade_master_replica_client_dirsrv_off: Test upgrade with dirsrv down before upgrade"
        rlRun "env|sort"
        # Install and setup environment and add data
        ipa_install_master_all
        ipa_install_replica_all
        ipa_install_client
        data_add

        # test master upgrade with dirsrv down
        if [ "$MYROLE" = "MASTER" ]; then
            rlLog "Shutting down dirsrv before upgrading MASTER ($MASTER)"
            rlRun "service dirsrv stop"
        fi
        upgrade_master
        upgrade_bz_895298_check_master  
        data_check $MYBEAKERMASTER
        
        # test replica upgrade with dirsrv down
        if [ "$MYROLE" = "REPLICA" ]; then
            rlLog "Shutting down dirsrv before upgrading REPLICA ($REPLICA)"
            rlRun "service dirsrv stop"
        fi
        upgrade_replica
        upgrade_bz_895298_check_replica
        data_check $REPLICA1_IP

        # test client upgrade after master and replica upgrades with dirsrv down
        upgrade_client
        data_check $MYBEAKERCLIENT

        # uninstall everything so we can start over
        ipa_uninstall_client
        ipa_uninstall_replica
        ipa_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_bz_tests()
{
    rlPhaseStartTest "ipa_upgrade_master_bz_tests: execute bug tests against a master upgrade"
        rlRun "env|sort"
        # Install and setup master for bug checks
        ipa_install_master_all
        ipa_install_replica_all

        # Running start function for 772359 to capture info before upgrade
        upgrade_bz_772359_start

        # Alter the bind configuration to ensure that BZ 819629 will be tested properly
        upgrade_bz_819629_setup

        # upgrade master and check data
        upgrade_master
        upgrade_replica
        
        # Now execute bug checks
        upgrade_bz_819629
        upgrade_bz_772359_finish
        upgrade_bz_766096
        upgrade_bz_746589
        upgrade_bz_782918
        upgrade_bz_803054
        upgrade_bz_809262
        upgrade_bz_808201
        upgrade_bz_803930
        upgrade_bz_812391
        upgrade_bz_821176
        upgrade_bz_824074
        upgrade_bz_893722
        upgrade_bz_902474
        upgrade_bz_903758

        # uninstall everything so we can start over
        ipa_uninstall_replica
        ipa_uninstall_master
            
    rlPhaseEnd
}

ipa_upgrade_master_bz_866977()
{
    rlPhaseStartTest "ipa_upgrade_master_bz_866977: Inform user when ipa-upgradeconfig reports errors"
        rlRun "env|sort"
        ipa_install_master_all
        upgrade_bz_866977_setup
        upgrade_master 2>&1 | tee /tmp/upgrade_master_bz_866977.out
        upgrade_bz_866977_check
        ipa_uninstall_master
    rlPhaseEnd
}

ipa_upgrade_master_replica_client_all_final()
{   
    rlPhaseStartTest "ipa_upgrade_master_replica_client_all_final: Install and upgrade to leave in a state for other testing"
        rlRun "env|sort"
        ipa_install_master_all
        ipa_install_replica_all
        ipa_install_client
        upgrade_master 
        upgrade_replica
        upgrade_client
    rlPhaseEnd
}
