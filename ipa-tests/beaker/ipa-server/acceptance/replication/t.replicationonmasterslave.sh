
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
        rhts-sync-set -m $BEAKERSLAVE -s READY
      fi
    rlPhaseEnd



################################################
#    add objects from master
################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s READY $BEAKERSLAVE

      rlPhaseStartTest "Add objects from master"
         source $masterDatafile
         add_objects 
         rlRun "ipa passwd $login $password" 0 "Set initial password for the new user"
         rlRun "FirstKinitAs $login $password $ADMINPW" 0 "kinit and set new password for the new user"
      rlPhaseEnd

      rhts-sync-set -m $BEAKERMASTER -s MASTERADDEDOBJS
    fi


################################################
#    check objects from replica
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
      
      rhts-sync-set -m $BEAKERSLAVE -s SLAVECHECKEDOBJS
   fi
   

################################################
#    add objects from replica
################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s SLAVECHECKEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Add objects from slave"
         source $slaveDatafile
         add_objects 
         rlRun "ipa passwd $login $password" 0 "Set initial password for the new user"
         rlRun "FirstKinitAs $login $password $ADMINPW" 0 "kinit and set new password for the new user"
      rlPhaseEnd

      rhts-sync-set -m $BEAKERSLAVE -s SLAVEADDEDOBJS
   fi
 

################################################
#   check objects from master
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

      rhts-sync-set -m $BEAKERMASTER -s MASTERCHECKEDOBJS
    fi


################################################
#    update objects on master
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

      rhts-sync-set -m $BEAKERMASTER -s MASTERUPDATEDOBJS
    fi


################################################
#   check updated objects from replica
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

      rhts-sync-set -m $BEAKERSLAVE -s SLAVECHECKEDUPDATEDOBJS
   fi


################################################
#   update objects on replica 
################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s SLAVECHECKEDUPDATEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Modify objects (added from master) on slave"
         # save away data to check before sourcing datafile
         loginToUpdate=$login
         groupToUpdate=$groupName
         source $slaveDatafile
         update_objects $loginToUpdate $groupToUpdate
         # updated pwpolicy to allow immediate password change from master, so do not have to do it here,
         rlRun "ipa passwd $login_updated $passwordChange" 0 "Modify password for the updated user"
         rlRun "FirstKinitAs $login_updated $passwordChange $updatedPassword" 0 "kinit as user with updated password"
      rlPhaseEnd

      rhts-sync-set -m $BEAKERSLAVE -s SLAVEUPDATEDOBJS
   fi


################################################
#   check updated objects from master
################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s SLAVEUPDATEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Check objects (modified from slave) on master"
         source $slaveDatafile
         check_updated_objects
      rlPhaseEnd
      # kinit on master, as the user updated from slave
      rlPhaseStartTest "Kinit on master, as user updated from slave"
         rlRun "kinitAs $login_updated $updatedPassword" 0 "Kinit on master as user updated from slave"
      rlPhaseEnd

     rhts-sync-set -m $BEAKERMASTER -s MASTERCHECKEDUPDATEDOBJS
    fi


###########################################################################
#   delete object (added from replica, modified from master) from master
###########################################################################

    if [ $config == "master" ] ; then 
      rhts-sync-block -s MASTERCHECKEDUPDATEDOBJS $BEAKERMASTER

      rlPhaseStartTest "Delete objects (added from slave, modified from master) on master"
         source $masterDatafile
         delete_objects
      rlPhaseEnd

      rhts-sync-set -m $BEAKERMASTER -s MASTERDELETEDOBJS
    fi


###################################################
#   check deleted objects not available on replica
###################################################

   if [ $config == "slave" ] ; then
      rhts-sync-block -s MASTERDELETEDOBJS $BEAKERMASTER
     
      rlPhaseStartTest "Check objects (deleted from master) on slave"
         source $masterDatafile
         check_deletedobjects
      rlPhaseEnd

      rhts-sync-set -m $BEAKERSLAVE -s SLAVECHECKDELETEDOBJS
   fi


###########################################################################
#   delete object (added from master, modified from replica) from replica
###########################################################################

    if [ $config == "slave" ] ; then 
      rhts-sync-block -s SLAVECHECKDELETEDOBJS $BEAKERSLAVE

      rlPhaseStartTest "Delete objects (added from slave, modified from master) on master"
         source $slaveDatafile
         delete_objects
      rlPhaseEnd

      rhts-sync-set -m $BEAKERSLAVE -s SLAVEDELETEDOBJS
    fi


################################################
#   check deleted objects not available on master 
################################################

   if [ $config == "master" ] ; then
      rhts-sync-block -s SLAVEDELETEDOBJS $BEAKERSLAVE
     
      rlPhaseStartTest "Check objects (deleted from slave) on master"
         source $slaveDatafile
         check_deletedobjects
     rlPhaseEnd

      rhts-sync-set -m $BEAKERMASTER -s MASTERCHECKDELETEDOBJS
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

   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to update objects"
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
   # Add a service
   # Add a delegation
   # Add a DNS record 
   # Add a HBAC service
   # Add a HBAC service group
   # Add a HBAC rule 
   # Add a permission
   # Add a privilege
   # Add a group password policy
   # Add a role
   # Add a selfservice permission
   # Add a SUDO rule
   # Add a sudo command group
   # Add a sudo command


}


check_objects()
{

   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to update objects"
   check_newuser
   check_newgroup
   check_newhost
   check_newhostgroup
}

update_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to update objects"
   modify_newuser $1
   modify_newgroup $2
   modify_newhost $3
   modify_newhostgroup
}


check_updated_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to verify updated objects"
   check_modifieduser
   check_modifiedgroup
   check_modifiedhost $1
   check_modifiedhostgroup
}


delete_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to verify updated objects"
   delete_user
   delete_group
   delete_host
   delete_hostgroup
}

check_deletedobjects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to verify updated objects"
   check_deleteduser
   check_deletedgroup
   check_deletedhost
   check_deletedhostgroup
}
