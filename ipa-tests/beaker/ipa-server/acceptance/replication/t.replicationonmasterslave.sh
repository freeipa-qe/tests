# Testing plan:
# 1) add all objects from master
# 2) add all (different) objects on slave
# 3) verify all objects on slave
# 4) verify all objects on master
# 5) modify objects from the master data on master
# 6) verify modifications on the slave
# 7) modify objects rrom the slave data on slave
# 8) verify modifications on the master
# 9) delete all objects from the master data on master
# 10) verify on the slave
# 11) delete all objects from the slave data on slave
# 12) verify on the master

testReplicationOnMasterAndSlave()
{
################################################
#     setup   
################################################

     rlPhaseStartSetup "Replication tests setup"
        rlLog "MASTER: $MASTER; MASTERIP: $MASTERIP"
        rlLog "BEAKERMASTER: $BEAKERMASTER"
        rlLog "SLAVE: $SLAVE; SLAVEIP: $SLAVEIP"
        rlLog "BEAKERSLAVE: $BEAKERSLAVE"
        masterDatafile="/mnt/tests/CoreOS/ipa-server/acceptance/replication/data.replication.master"
        slaveDatafile="/mnt/tests/CoreOS/ipa-server/acceptance/replication/data.replication.slave"

        # Determine if this is a master
        hostname=`hostname -s`
        echo $MASTER | grep $hostname
        if [ $? -eq 0 ]; then
           echo "this is a MASTER"
           config="master"  
        else
           echo $SLAVE | grep $hostname
           if [ $? -eq 0 ]; then
              echo "This is a SLAVE"
              config="slave"
           else
              echo "This is a CLIENT"
              config="client"
           fi
        fi

   
      if [ $config == "slave" ] ; then
        slaveIsInstalled=false
        while [ $slaveIsInstalled == "false" ] ; do  
          kinitAs $ADMINID $ADMINPW
          if [ $? != 0 ] ; then
           sleep 500
          else 
            slaveIsInstalled=true
          fi
        done
        rhts-sync-set -s READY
      fi
    rlPhaseEnd



################################################
# 1   add objects from master
################################################

    if [ $config == "master" ] ; then 
      echo "starting master add objects section"
      rhts-sync-block -s READY $BEAKERSLAVE

      rlPhaseStartTest "Add objects from master"
         source $masterDatafile
         add_objects 
         rlRun "ipa passwd $login $password" 0 "Set initial password for the new user"
         rlRun "FirstKinitAs $login $password $ADMINPW" 0 "kinit and set new password for the new user"
      rlPhaseEnd

      rhts-sync-set -s MASTERADDEDOBJS
    fi


################################################
# 2   add objects on replica
################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s SLAVECHECKEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Add objects from slave"
         source $slaveDatafile
         slave_add_objects 
         rlRun "ipa passwd $login $password" 0 "Set initial password for the new user"
         rlRun "FirstKinitAs $login $password $ADMINPW" 0 "kinit and set new password for the new user"
      rlPhaseEnd

      rhts-sync-set -s SLAVEADDEDOBJS
   fi
 
################################################
# 3   verify objects from replica
################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s MASTERADDEDOBJS $BEAKERMASTER
     
      rlPhaseStartTest "Check objects (added from master) on slave"
         source $masterDatafile
         check_objects 
      rlPhaseEnd
      # kinit on slave, as the new user added from master
      rlPhaseStartTest "Kinit on slave, as user added from master"
         rlRun "kinitAs $login $ADMINPW" 0 "Kinit on slave as user added from master"
      rlPhaseEnd
      
      rhts-sync-set -s SLAVECHECKEDOBJS
   fi
   


################################################
# 4  check objects on master
################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s SLAVEADDEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Check objects (added from slave) on master"
         source $slaveDatafile
         check_objects
      rlPhaseEnd
      # kinit on master, as the new user added from slave
      rlPhaseStartTest "Kinit on master, as user added from slave"
         rlRun "kinitAs $login $ADMINPW" 0 "Kinit on master as user added from slave"
      rlPhaseEnd

      rhts-sync-set -s MASTERCHECKEDOBJS
    fi


################################################
# 5   update objects on master
################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s MASTERCHECKEDOBJS $BEAKERMASTER

      rlPhaseStartTest "Modify objects (added from slave) on master"
         # save away data to check before sourcing datafile
         loginToUpdate=$login
         groupToUpdate=$groupName
         source $masterDatafile
         update_objects $loginToUpdate $groupToUpdate
         rlRun "ipa pwpolicy-mod --minlife=0" 0 "Modify password policy to allow password change immediately"
         rlRun "ipa passwd $login_updated $passwordChange" 0 "Modify password for the updated user"
         rlRun "FirstKinitAs $login_updated $passwordChange $updatedPassword" 0 "kinit as user with updated password"
      rlPhaseEnd

      rhts-sync-set -s MASTERUPDATEDOBJS
    fi


################################################
# 6  check updated objects on replica
################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s MASTERUPDATEDOBJS $BEAKERMASTER

      rlPhaseStartTest "Check objects (modified from master) on slave"
         source $masterDatafile
         check_updated_objects
      rlPhaseEnd
      # kinit on slave, as the user updated from master
      rlPhaseStartTest "Kinit on slave, as user updated from master"
         rlRun "kinitAs $login_updated $updatedPassword" 0 "Kinit on slave as user updated from master"
      rlPhaseEnd

      rhts-sync-set -s SLAVECHECKEDUPDATEDOBJS
   fi


################################################
# 7  modify objects on replica 
################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s SLAVECHECKEDUPDATEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Modify objects (added from master) on slave"
         # save away data to check before sourcing datafile
         loginToUpdate=$login
         groupToUpdate=$groupName
         source $slaveDatafile
         slave_update_objects $loginToUpdate $groupToUpdate
         # updated pwpolicy to allow immediate password change from master, so do not have to do it here,
         rlRun "ipa passwd $login_updated $passwordChange" 0 "Modify password for the updated user"
         rlRun "FirstKinitAs $login_updated $passwordChange $updatedPassword" 0 "kinit as user with updated password"
      rlPhaseEnd

      rhts-sync-set -s SLAVEUPDATEDOBJS
   fi


################################################
# 8   check updated objects from master
################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s SLAVEUPDATEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Check objects (modified from slave) on master"
         source $slaveDatafile
         check_updated_objects_slave
      rlPhaseEnd
      # kinit on master, as the user updated from slave
      rlPhaseStartTest "Kinit on master, as user updated from slave"
         rlRun "kinitAs $login_updated $updatedPassword" 0 "Kinit on master as user updated from slave"
     rhts-sync-set -s MASTERCHECKEDUPDATEDOBJS
    fi


###########################################################################
# 9  delete object (added from replica, modified from master) from master
###########################################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s MASTERCHECKEDUPDATEDOBJS $BEAKERMASTER

      rlPhaseStartTest "Delete objects (added from slave, modified from master) on master"
         source $masterDatafile
         delete_objects
      rlPhaseEnd

      rhts-sync-set -s MASTERDELETEDOBJS
    fi


###########################################################################
# 10  delete object (added from master, modified from replica) from replica
###########################################################################

    if [ $config == "slave" ] ; then 
      rhts-sync-block -s SLAVECHECKDELETEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Delete objects (added from master, modified from master) on master"
         source $slaveDatafile
         delete_slave_objects
      rlPhaseEnd

      rhts-sync-set -s SLAVEDELETEDOBJS
    fi


###################################################
# 11  check deleted objects not available on replica
###################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s MASTERDELETEDOBJS $BEAKERMASTER
     
      rlPhaseStartTest "Check objects (deleted from master) on slave"
         source $masterDatafile
         check_deletedobjects
      rlPhaseEnd

      rhts-sync-set -s SLAVECHECKDELETEDOBJS
   fi


   if [ $config == "master" ] ; then
     
      rlPhaseStartTest "Check deleted objects on master"
         source $masterDatafile
         check_deletedobjects
      rlPhaseEnd

   fi


##
##   # kinit user from client to master
##     rhts-sync-block -s READYFORCLIENT {$MASTER, $SLAVE}
##     kinit_user
##     rhts-sync-set -s READY
##
##   # check login on replica
##     check_login
##
##   # kinit user from client to replica
##     kinit_user
##
##   # check login on master
##     check_login
##
##   # user changes password from client to master
##     client_actions
##
##   # ....and so on

}

add_objects()
{

   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to add objects"
   # perform actions to add objects
   rlLog "Adding objects on $hostname"
   # Add a user
	add_newuser

   # Add a group
	add_newgroup

   # Add a host
	add_newhost

   # Add a hostgroup
	add_newhostgroup

   # Add a netgroup
	add_newnetgroup

   # Add a service
	add_newservice

   # Add a delegation
#	add_delegation

   # Add a DNS record 
	add_dns

   # Add a HBAC rule
	add_hbac

   # Add a HBAC service 
	add_hbac_service

   # Add a permission
	add_permission

   # Add a privilege
	add_privilege

   # Add a password policy
	add_pwpolicy

   # Add a role
	add_role

   # Add a selfservice permission
	add_selfservice

   # Add a SUDO rule
	add_sudorule

   # Add a sudo command
	add_sudocmd

   # Add a sudo command group
	add_sudocmdgroup

   # Add or modify a config value
	add_config
}

slave_objects_add()
{
	add_slave_user
	add_slave_group
	add_slave_host
	add_slave_hostgroup
	add_slave_netgroup
	add_slave_newservice
	add_slave_dns
	add_slave_hbac
	add_slave_hbac_service
	add_slave_permission
	add_slave_sudorule
	add_slave_sudocmd
	add_slave_sudocmdgroup
	add_slave_config
	add_slave_pwpolicy
	add_slave_selfservice
	add_slave_privilege
	add_slave_role
}

check_objects()
{

   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to check objects"
   check_newuser
   check_newgroup
   check_newhost
   check_newhostgroup
   check_newnetgroup
   check_newservice
#   check_delegation
   check_dns
   check_hbac
   check_hbac_service
   check_permission
   check_privilege
   check_pwpolicy
   check_role
   check_selfservice
   check_sudorule
   check_sudocmdgroup
   check_sudocmd
   check_config
}

update_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to update objects"
   modify_newuser $1
   modify_newgroup $2
   modify_newhost $3
   modify_newhostgroup
   modify_newnetgroup
   modify_newservice
   modify_hbac
   modify_hbac_service
   modify_permission
   modify_privilege
   modify_pwpolicy
   modify_role
   modify_selfservice
   modify_sudorule
   modify_sudocmdgroup
   modify_sudocmd
}

check_updated_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to verify updated objects"
   check_modifieduser
   check_modifiedgroup
   check_modifiedhost $1
   check_modifiedhostgroup
   check_modifiednetgroup
   check_modifiedservice
   check_modifiedhbac
   check_modifiedhbacservice
   check_modifiedpermission
   check_modifiedprivilege
   check_modifiedpwpolicy
   check_modifiedrole
   check_modifiedselfservice
   check_modifiedsudorule
   check_modifiedsudocmdgroup
   check_modifiedsudocmd
}

slave_update_objects()
{
	modify_slave_user
	modify_slave_group
	modify_slave_host
	modify_slave_hostgroup
	modify_slave_netgroup
	modify_slave_newservice
	modify_slave_hbacservice
	modify_slave_service
	modify_slave_sudorule
	modify_slave_sudocmd
	modify_slave_sudocmdgroup
	modify_slave_pwpolicy
	modify_slave_selfservice
	modify_slave_privilege
	modify_slave_role
}

check_updated_slave_objects()
{
	check_slave_modifieduser
	check_slave_modifiedgroup
	check_slave_modifiedhost
	check_slave_modifiedhostgroup
	check_slave_modifiednetgroup
	check_slave_modifiednewservice
	check_slave_modifiedhbacservice
	check_slave_modifiedservice
	check_slave_modifiedsudorule
	check_slave_modifiedsudocmd
	check_slave_modifiedsudocmdgroup
	check_slave_modifiedpwpolicy
	check_slave_modifiedselfservice
	check_slave_modifiedprivilege
	check_slave_modifiedrole
}

delete_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to delete objects"
   delete_user
   delete_group
   delete_host
   delete_hostgroup
   delete_netgroup
   delete_service
   delete_dns
   delete_hbac
   delete_hbac_service
   delete_permission
   delete_privilege
   delete_role
   delete_pwpolicy
   delete_selfservice
   delete_sudorule
   delete_sudocmdgroup
   delete_sudocmd
   delete_config
}

delete_slave_objects()
{
	delete_slave_user
	delete_slave_group
	delete_slave_host
	delete_slave_hostgroup
	delete_slave_netgroup
	delete_slave_newservice
	delete_slave_dns
	delete_slave_hbac
	delete_slave_hbac_service
	delete_slave_service
	delete_slave_sudorule
	delete_slave_sudocmd
	delete_slave_sudocmdgroup
	delete_slave_config
	delete_slave_pwpolicy
	delete_slave_selfservice
	delete_slave_privilege
	delete_slave_role
}

check_deletedobjects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to verify deleted objects"
   check_deleteduser
   check_deletedgroup
   check_deletedhost
   check_deletedhostgroup
   check_deletednetgroup
   check_deletedservice
   check_deleteddns
   check_deletedhbac
   check_deletedhbacservice
   check_deletedpermission
   check_deletedprivilege
   check_deletedpwpolicy
   check_deletedrole
   check_deletedselfservice
   check_deletedsudorule
   check_deletedsudocmdgroup
   check_deletedsudocmd
   check_deleteconfig
}
