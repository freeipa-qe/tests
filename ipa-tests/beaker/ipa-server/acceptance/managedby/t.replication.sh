
hdir=/var/www/html
#wget http://$MASTER/$hfile

# Determine if this is a master
hostname=`hostname -s`
echo $MASTER | grep $hostname
if [ $? -eq 0 ]; then
	echo "this is a MASTER"
	export master=1
else
	echo "This is a SLAVE"
	export master=0
fi

forceSyncToSlaves()
{
	for s in $SLAVE; do
		ipa-replica-manage -p $ADMINPW force-sync $s
	done
}

replication()
{
	user1=u34va
	user2=p03045
	user3=mnuyyet

	hfile="ipa-replication-1"
	rlPhaseStartTest "ipa-replication-1: check basic user-add replication"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-add --first=f --last=l $user1" 0 "Create a user on the master"
			forceSyncToSlaves
			# Populate the notification file to let the slave know to proceed
			touch $hdir/rt/$hfile
		else # This is a slave
			done=0
			while [ $done -eq 0 ]; do
				wget http://$MASTER/rt/$hfile
				if [ $? -eq 0 ]; then # if successfully downloaded file, then break out of while loop
					done=1
				else 
					sleep 5
				fi
			done
			ipa-replica-manage -p $ADMINPW force-sync $MASTER
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user1 | grep $user1" 0 "Check to ensure that the user is searchable on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-2"
	fname="yyou7"
	rlPhaseStartTest "ipa-replication-2: change the first name of user1"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-mod --first=$fname $user1" 0 "modify the name of user1"
			forceSyncToSlaves
			# Populate the notification file to let the slave know to proceed
			touch $hdir/rt/$hfile
		else # This is a slave
			done=0
			while [ $done -eq 0 ]; do
				wget http://$MASTER/rt/$hfile
				if [ $? -eq 0 ]; then # if successfully downloaded file, then break out of while loop
					done=1
				else 
					sleep 5
				fi
			done
			ipa-replica-manage -p $ADMINPW force-sync $MASTER
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find --all $user1 | grep $fname" 0 "Check to ensure that the first name of user1 changed on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-3"
	lname="loepyou7"
	rlPhaseStartTest "ipa-replication-3: change the last name of user1"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-mod --last=$lname $user1" 0 "modify the name of user1"
			forceSyncToSlaves
			# Populate the notification file to let the slave know to proceed
			touch $hdir/rt/$hfile
		else # This is a slave
			done=0
			while [ $done -eq 0 ]; do
				wget http://$MASTER/rt/$hfile
				if [ $? -eq 0 ]; then # if successfully downloaded file, then break out of while loop
					done=1
				else 
					sleep 5
				fi
			done
			ipa-replica-manage -p $ADMINPW force-sync $MASTER
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find --all $user1 | grep $lname" 0 "Check to ensure that the last name of user1 changed on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-4"
	rlPhaseStartTest "ipa-replication-4: add more users"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-add --first=f$user2 --last=l$user2 $user2" 0 "Create a user on the master"
			rlRun "ipa user-add --first=f$user3 --last=l$user3 $user3" 0 "Create a user on the master"
			rlRun "ipa user-add --first=f$user4 --last=l$user4 $user4" 0 "Create a user on the master"
			forceSyncToSlaves
			# Populate the notification file to let the slave know to proceed
			touch $hdir/rt/$hfile
		else # This is a slave
			done=0
			while [ $done -eq 0 ]; do
				wget http://$MASTER/rt/$hfile
				if [ $? -eq 0 ]; then # if successfully downloaded file, then break out of while loop
					done=1
				else 
					sleep 5
				fi
			done
			ipa-replica-manage -p $ADMINPW force-sync $MASTER
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user2 | grep $user2" 0 "Check to ensure that user2 is searchable on the slave"
			rlRun "ipa user-find $user3 | grep $user3" 0 "Check to ensure that user3 is searchable on the slave"
			rlRun "ipa user-find $user4 | grep $user4" 0 "Check to ensure that user4 is searchable on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-5"
	rlPhaseStartTest "ipa-replication-5: delete multiple users"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-del $user2" 0 "Create a user on the master"
			rlRun "ipa user-del $user3" 0 "Create a user on the master"
			rlRun "ipa user-del $user4" 0 "Create a user on the master"
			forceSyncToSlaves
			# Populate the notification file to let the slave know to proceed
			touch $hdir/rt/$hfile
		else # This is a slave
			done=0
			while [ $done -eq 0 ]; do
				wget http://$MASTER/rt/$hfile
				if [ $? -eq 0 ]; then # if successfully downloaded file, then break out of while loop
					done=1
				else 
					sleep 5
				fi
			done
			ipa-replica-manage -p $ADMINPW force-sync $MASTER
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user2" 1 "Check to ensure that user2 is not searchable on the slave"
			rlRun "ipa user-find $user3" 1 "Check to ensure that user3 is not searchable on the slave"
			rlRun "ipa user-find $user4" 1 "Check to ensure that user4 is not searchable on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-"
	rlPhaseStartTest "ipa-replication-: delete user1"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-del $user1" 0 "destroy user user1 on master"
			forceSyncToSlaves
			# Populate the notification file to let the slave know to proceed
			touch $hdir/rt/$hfile
		else # This is a slave
			done=0
			while [ $done -eq 0 ]; do
				wget http://$MASTER/rt/$hfile
				if [ $? -eq 0 ]; then # if successfully downloaded file, then break out of while loop
					done=1
				else 
					sleep 5
				fi
			done
			ipa-replica-manage -p $ADMINPW force-sync $MASTER
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user1 | grep $user1" 1 "Check to ensure that the user is not searchable on the slave"
		fi 
	rlPhaseEnd

}

