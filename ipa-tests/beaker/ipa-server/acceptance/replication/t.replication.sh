
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

replication()
{
	user1=u34va

	hfile="ipa-replication-1"
	rlPhaseStartTest "ipa-replication-1: check basic user-add replication"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-add --first=f --last=l $user1" 0 "Create a user on the master"
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
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user1 | grep $user1" 0 "Check to ensure that the user is searchable on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-2"
	fname="yyou7"
	rlPhaseStartTest "ipa-replication-2: change the first name of user1"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-add --first=$fname $user1" 0 "modify the name of user1"
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
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find --all $user1 | grep $fname" 0 "Check to ensure that the first name of user1 changed on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-3"
	lname="loepyou7"
	rlPhaseStartTest "ipa-replication-3: change the last name of user1"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-add --last=$lname $user1" 0 "modify the name of user1"
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
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find --all $user1 | grep $lname" 0 "Check to ensure that the last name of user1 changed on the slave"
		fi 
	rlPhaseEnd

	hfile="ipa-replication-"
	rlPhaseStartTest "ipa-replication-: delete user1"
		if [ $master -eq 1 ]; then 
			rlRun "ipa user-add --first=f --last=l $user1" 0 "Create a user on the master"
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
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user1 | grep $user1" 1 "Check to ensure that the user is not searchable on the slave"
		fi 
	rlPhaseEnd

}

