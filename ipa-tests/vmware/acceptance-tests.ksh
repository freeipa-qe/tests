#!/bin/bash
# This script will run aginst all of the machines defined in the configurations files stored in ./cfg
# A cfg file can contain the following keys:

# This script will run aginst all of the machines defined in the configurations files stored in ./cfg
# A cfg file can contain the following keys:

# This script will require no human interaction if the AUTOMATION=1 var is exported

set -x
 
. ./env.cfg

serverlog="IPA-server-log.txt"
date=`date +%Y-%m-%d_%H_%M`
emailfiletmp=$resultloc
# Determining if resultloc is a nfs something that needs to be mounted.
echo $resultnfs | grep ":" 
ret=$?
if [ $ret = 0 ]; then
	# It's a NFS something, lets mount it.
	mkdir -p /tmp/$date
	mount $resultnfs /tmp/$date
	resultloc="/tmp/$date/$resultloc"
	export resultloc
fi
		
# Making a new dir for logs
mkdir -p $resultloc/$date

start_host()
{
	ssh root@$VMHOST "/usr/bin/vmrun start $VMXFILE"
}

stop_host()
{
	ssh root@$VMHOST "/usr/bin/vmrun stop $VMXFILE"
}

extract_host()
{
	# Mounting nfs share
	if [ $TARONNFS -ne 0 ]; then
        	echo "Mounting $TARBALLMOUNT on host $VMHOST"
	        mntlocation=$(echo $TARBALLMOUNT | awk '{print $2}')
        	ssh root@$VMHOST "mkdir -p $mntlocation;umount -l $mntlocation >> /dev/null;mount $TARBALLMOUNT"
	fi

	# Extracting tarball
       	echo "Extracting $TARFILE to $TARROOT on host $VMHOST"
        ssh root@$VMHOST "cd $TARROOT;tar xvfz $TARFILE"
}

email_result()
{
#	This sub will email the results of the test to $email
#	Pass it a GOOD if everything works out, and BAD if there is a error.
#	Anything not "GOOD" or "BAD" will report as "Unknown"
	code=$1
	if [ ! -d $resultloc/$date ]; then
		mkdir -p $resultloc/$date;
	fi
	cp $logdir/log.txt $resultloc/$date/.
#	cp $installog $resultloc/$date/.

	if [ -d /tmp/$date ]; then
		echo "umounting /tmp/$date" | tee -a $logdir/log.txt
		umount -l /tmp/$date | tee -a $logdir/log.txt
	fi
	# If the code isn't good or bad, it's unknown.
#	if [ "$code" != "GOOD" ] && [ "$code" != "BAD" ]; then
#		code="UNKNOWN"
#		export code
#	fi
	
	# Checking to see that all of the clients completed successfully, if not, then change the exit code to BAD
	ls $resultloc/$date | grep BAD	
	ret=$?
	if [ $ret == 0 ]; then
		echo "error detected in one or more of the client logs. changing code to BAD" | tee -a $logdir/log.txt
		code="BAD"
	fi

	# Compose email
	echo "Subject: Fedora - $code result of IPA QA run" > /tmp/$date-email.txt
	echo "To: $email" >> /tmp/$date-email.txt
	echo "" >> /tmp/$date-email.txt
	echo " Result was $code, please see:" >> /tmp/$date-email.txt
	echo " $resulturl/$date/log.txt" >> /tmp/$date-email.txt
	echo " The Server's $server install log is: $resulturl/$date/$serverlog" >> /tmp/$date-email.txt
	ls $resultloc/$date/ | grep client | while read c; do
		echo "     A client install log is located at $resulturl/$date/$c" >> /tmp/$date-email.txt
	done
	echo "For details." >> /tmp/$date-email.txt
	echo "These files might be on the local system at $emailfiletmp/$date" >> /tmp/$date-email.txt
	/usr/sbin/sendmail $email < /tmp/$date-email.txt
	
	exit
}

runhost()
{
	echo "Starting work on $workfile" | tee -a $logdir/log.txt	
	#setting bash file to default, this may be changed by the host cfg file
	BASHFILE=rhelgeneric.ksh
	# This next line is where all of the VMHOST and related keys get overwritten.
	. $workfile
	echo "" | tee -a $logdir/log.txt
	echo "Stoping client from $workfile" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt 
	date | tee -a $logdir/log.txt
	stop_host
	#./stop-vm.ksh $workfile | tee -a $logdir/log.txt
	#ssh root@$VMHOST "/usr/bin/vmrun stop $VMXFILE"
	echo "" | tee -a $logdir/log.txt
	echo "Extract client from $workfile" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt 
	date | tee -a $logdir/log.txt
	extract_host
	echo "" | tee -a $logdir/log.txt
	echo "Starting client from $workfile" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt 
	date | tee -a $logdir/log.txt
	start_host
	while true; do
		sleep 6
		echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
		date | tee -a $logdir/log.txt
		ping -c 1 $VMIP
		ret=$?
		if [ $ret = 0 ]; then
			echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
			break;
		fi
		sleep 60
	done 
	echo "sleeping 1 min to allow ssh to come up" | tee -a $logdir/log.txt
	sleep 60
	while true; do
		echo "pinging $VMIP for good measure" | tee -a $logdir/log.txt
		date | tee -a $logdir/log.txt
		ping -c 1 $VMIP 
		ret=$?
		if [ $ret = 0 ]; then
			echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
			break;
		fi
		sleep 60
	done 

	
	vmfqdn=`host $VMNAME | awk {'print $1'}`
	installog=`echo /tmp/client-$VMNAME-log.txt`
	rm -f /tmp/$date.bash
	fc7repo="$fc7repobase/$OS/$PRO/ipa.repo"
	sed s=fc7repo=$fc7repo=g < ./testscripts/$BASHFILE | sed s=VMNAME=$vmfqdn=g |  sed s=ntpserver=$ntpserver=g | sed s=oshere=$OS=g | sed s=serverip=$serverip=g> /tmp/$date.bash
	chmod 755 /tmp/$date.bash
	scp -o GSSAPIAuthentication=no /tmp/$date.bash root@$VMIP:/tmp/. | tee -a $logdir/log.txt
	ssh root@$VMIP " rm -f $installog;set -x;/tmp/$date.bash &> $installog" | tee -a $logdir/log.txt
	rm -f $installog
	if [ ! -d $resultloc/$date ]; then mkdir -p $resultloc/$date; fi
	scp -o GSSAPIAuthentication=no root@$VMIP:$installog /tmp/. | tee -a $logdir/log.txt
	grep -v NOERROR $installog | grep ERROR 
	ret=$?
	if [ $ret == 0 ]; then
		echo "ERROR - A error was detected connecting $VMNAME \(ie $VMIP\) to the IPA server, see $installog for details";
		result="BAD";
		echo "BAD" > /tmp/$OS$PRO.txt
		cp -af $installog $resultloc/$date/client-$VMNAME-$OS-$PRO-BAD-log.txt | tee -a $logdir/log.txt
		#exit;
	else
		echo "GOOD" > /tmp/$OS$PRO.txt
		cp -af $installog $resultloc/$date/client-$VMNAME-$OS-$PRO-GOOD-log.txt | tee -a $logdir/log.txt
	fi

	echo "" | tee -a $logdir/log.txt
	echo "Stopping client from $workfile" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt 
	date | tee -a $logdir/log.txt
	stop_host
#	./stop-vm.ksh $workfile | tee -a $logdir/log.txt
}
press_any_key()
{
    echo ""
    echo "Press any key to continue..."
#    read tmp
    echo ""
    echo ""
    echo ""
    #clear
    return 0
}

echo "WARNING: This test will destroy all of the VM's that it uses because it "
echo " recreates them all"
echo " Hit CTRL-C now if this is not okay? - "
press_any_key

# set the initial result
result="GOOD"

# Fix date
/etc/init.d/ntpd stop | tee $logdir/log.txt
/usr/sbin/ntpdate $ntpserver | tee -a $logdir/log.txt 
ret=$?
if [ $ret != 0 ]; then
        # ntp update didn't work the first time, lets try it again.
        /usr/sbin/ntpdate $ntpserver | tee -a $logdir/log.txt
        ret=$?
fi

# Setup IPA server VM
. ./server.cfg
serverip=$VMIP
export serverip 
echo "" | tee -a $logdir/log.txt
echo "Stopping the previously existing ipa server VM if it's running" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt 
date | tee -a $logdir/log.txt
stop_host
#./stop-vm.ksh ./server.cfg | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
echo "Extracting the IPA server VM image" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt 
date | tee -a $logdir/log.txt
extract_host
#./extract-vm.ksh ./server.cfg | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
echo "Starting the now fresh IPA server" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt 

date | tee -a $logdir/log.txt
start_host
#./start-vm.ksh ./server.cfg | tee -a $logdir/log.txt
while true; do
	sleep 60
	echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
	ping -c 1 $VMIP
	ret=$?
	if [ $ret = 0 ]; then
		echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
		break;
	fi
	sleep 30
done 
echo "sleeping 1 min to allow ssh to come up" | tee -a $logdir/log.txt
sleep 60
# Pinging again to wait for the VMWARE clock sync bug 
while true; do
	echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
#	ping -c 1 $VMIP
ret=0
	ret=$?
	if [ $ret = 0 ]; then
		echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
		echo "continuing with IPA Server install" | tee -a $logdir/log.txt
		break;
	fi
done 
# Install IPA onto the server
#  First, fix the install-ipa.bash file
echo "" | tee -a $logdir/log.txt
echo "Starting the now fresh IPA server" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt 

vmfqdn=`host $VMNAME | awk {'print $1'}`
fc7repo="$fc7repobase/$OS/$PRO/ipa.repo"
sed s=fc7repo=$fc7repo=g < ././install_ipa.bash-base | sed s=VMNAME=$vmfqdn=g |  sed s=ntpserver=$ntpserver=g > ./install_ipa.bash
chmod 755 ./install_ipa.bash
scp -o GSSAPIAuthentication=no ./install_ipa.bash root@$VMIP:/tmp/. | tee -a $logdir/log.txt
ssh root@$VMIP " rm -f $installog;set -x;/tmp/install_ipa.bash &> $installog" | tee -a $logdir/log.txt
rm -f $installog
scp -o GSSAPIAuthentication=no root@$VMIP:$installog /tmp/. | tee -a $logdir/log.txt
if [ ! -d $resultloc/$date ]; then mkdir -p $resultloc/$date; fi
cp -af $installog $resultloc/$date/$serverlog | tee -a $logdir/log.txt
grep -v NOERROR $installog | grep ERROR 
ret=$?
if [ $ret == 0 ]; then
	echo "ERROR - A error was detected installing IPA server onto $VMNAME, see $installog for details";
	result="BAD";
	server="BAD"
#	exit;
else
	server="GOOD"
fi

export server
export result

if [ "$result" != GOOD ]; then
	email_result $result;
fi

# Setup and test client VM's
# For some reason, this doesn't work.
#find ./cfgs/*.cfg -type f -maxdepth 1 | while read workfile;do 
#	runhost;
#done

# Now using the less flexible method
workfile="./cfgs/fc7-x86_64.cfg"
runhost
workfile="./cfgs/fc7.cfg"
runhost
workfile="./cfgs/rhel5-x86_64.cfg"
runhost

# Install IPA
# Download repo

# Stopping IPA server
. ./server.cfg
echo "" | tee -a $logdir/log.txt
echo "Stopping the previously existing ipa server VM if it's running" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt 
date | tee -a $logdir/log.txt
stop_host

if [ "$result" == GOOD ]; then
	email_result GOOD;
else
	email_result $result;
fi
