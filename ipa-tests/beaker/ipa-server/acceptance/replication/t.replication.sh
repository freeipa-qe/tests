
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
	rlPhaseStartTest "ipa-replication-1: check basic user-add replication"
		hfile="ipa-replication-1"
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
				fi
			done
			# Now, we are don waiting for the master, the slave can proceed.
			rlRun "ipa user-find $user1 | grep $user1" 0 "Check to ensure that the user is searchable on the slave"
		fi 
	rlPhaseEnd

}

