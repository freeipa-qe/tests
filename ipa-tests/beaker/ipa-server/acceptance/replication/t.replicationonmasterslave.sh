


testReplicationOnMasterAndSlave()
{

     rlLog "MASTER: $MASTER"
     rlLog "SLAVE: $SLAVE"

     # Determine if this is a master
     hostname=`hostname -s`
     echo $MASTER | grep $hostname
     if [ $? -eq 0 ]; then
        echo "this is a MASTER"
        config="master"  
        notconfig="slave"
     else
        echo $SLAVE | grep $hostname
        if [ $? -eq 0 ]; then
           echo "This is a SLAVE"
           config="slave"
           notconfig="master"
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
     rlLog "$SLAVE: Will be READY"
     rhts-sync-set -m $SLAVE -s "READY"
     rlLog "$SLAVE: Is READY"
   fi

    # add objects from master
    if [ $config == "master" ] ; then 
      rlLog "$MASTER: Blocked till slave is READY"
      rhts-sync-block -s "READY" $SLAVE
      rlLog "$MASTER: Slave is ready"
      add_objects 
      rlLog "$MASTER: Will be ADD"
      rhts-sync-set -m $MASTER -s "ADD"
      rlLog "$MASTER: Is ADD"
    fi

    # check objects from replica
   if [ $config == "slave" ] ; then
     rlLog "$SLAVE: Blocked till master is ADD"
     rhts-sync-block -s "ADD" $MASTER
     rlLog "$SLAVE: Master is ADD"
     check_objects 
     rlLog "$SLAVE: Will be CHECK"
     rhts-sync-set -s "CHECK"
     rlLog "$SLAVE: Is CHECK"
   fi

   # add objects from replica
   if [ $config == "slave" ] ; then
      rhts-sync-block -s "CHECK" $SLAVE
      add_objects 
      rhts-sync-set -s SLAVEADDEDOBJS
   fi
 
   # check objects from master
    if [ $config == "master" ] ; then 
      rhts-sync-block -s SLAVEADDEDOBJS $SLAVE
      check_objects
      rhts-sync-set -s MASTERCHECKEDOBJS
    fi

   # modify - update/delete objects on master
    if [ $config == "master" ] ; then 
      rhts-sync-block -s MASTERCHECKEDOBJS $MASTER
      update_objects
      rhts-sync-set -s MASTERUPDATEDOBJS
    fi

   # check objects from replica
   if [ $config == "slave" ] ; then
      rhts-sync-block -s MASTERUPDATEDOBJS $MASTER
      check_updated_objects
      rhts-sync-set -s SLAVECHECKEDUPDATEDOBJS
   fi

   # modify - update/delete objects on replica 
   if [ $config == "slave" ] ; then
      rhts-sync-block -s SLAVECHECKEDUPDATEDOBJS $SLAVE
      update_objects
      rhts-sync-set -s SLAVEUPDATEDOBJS
   fi

   # check objects from master
    if [ $config == "master" ] ; then 
      rhts-sync-block -s SLAVEUPDATEDOBJS $SLAVE
      check_updated_objects
      rhts-sync-set -s MASTERCHECKEDUPDATEDOBJS
    fi
#
#   # kinit user from client to master
#     rhts-sync-block -s READYFORCLIENT {$MASTER, $SLAVE}
#     kinit_user
#     rhts-sync-set -s READY
#
#   # check login on replica
#     check_login
#
#   # kinit user from client to replica
#     kinit_user
#
#   # check login on master
#     check_login
#
#   # user changes password from client to master
#     client_actions
#
#   # ....and so on

}


add_objects()
{

   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to update objects"
   # perform actions to add objects
   rlLog "Adding objects on $hostname"
   # Add a user
   #create_ipauser ${user}$config ${user}$config ${user}$config ${user}$config
   addUserWithPassword ${user}$config ${user}$config ${user}$config ${user}$config
   # Add a group
   # Add a host
   # Add a hostgroup
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
   # check for those objects
   rlLog "Checking objects on $hostname"
   ipauser_exist ${user}$notconfig 
   if [ $? = 0 ] ; then
     rlPass "${user}$notconfig found on $hostname"
   else
     rlFail "${user}$notconfig not found on $hostname"
   fi

}

update_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to update objects"
   rlRun "modifyUser ${user}$notconfig first ${usermod}$notconfig" 0 "Modified ${user}$notconfig's first name"
}


check_updated_objects()
{
   rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials  to verify updated objects"
   rlRun "verifyUserAttr ${user}$config \"First name\" ${usermod}$config" 0 "Verify ${user}$config's first name" 
}




