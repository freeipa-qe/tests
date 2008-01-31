# This script will run aginst all of the machines defined in the configurations files stored in ./cfg
# A cfg file can contain the following keys:

# This script will run aginst all of the machines defined in the configurations files stored in ./cfg
# A cfg file can contain the following keys:

# This script will require no human interaction if the AUTOMATION=1 var is exported

set -x
 
pwd=$(pwd)

. ./env.cfg

email_result()
{
#	This sub will email the results of the test to $email
#	Pass it a GOOD if everything works out, and BAD if there is a error.
#	Anything not "GOOD" or "BAD" will report as "Unknown"
	code=$1
	section=$2
		
	if [ ! -d $logdir/$date ]; then
		mkdir -p $logdir/$date;
	fi
	if [ ! -d $resultloc/$date ]; then
		mkdir -p $resultloc/$date;
	fi

	cp $logdir/log.txt $resultloc/$date/.
	if [ -d /tmp/$date ]; then
		echo "umounting /tmp/$date"
		umount -l /tmp/$date;
	fi
	# If the code isn't good or bad, it's unknown.
	if [ "$code" != "GOOD" ] && [ "$code" != "BAD" ]; then
		code="UNKNOWN"
		export code
	fi

	# Compose email
	echo "Subject: $code IPA nightly build" > /tmp/$date-email.txt
	echo "To: $email" >> /tmp/$date-email.txt
	echo "" >> /tmp/$date-email.txt
	echo " Result was $code, please see:" >> /tmp/$date-email.txt
	echo " $resulturl/$date/log.txt" >> /tmp/$date-email.txt
#	echo " and $resulturl/$date/ipa_install_log.txt" >> /tmp/$date-email.txt
	echo "For details." >> /tmp/$date-email.txt
	echo "These files might be on the local system at $emailfiletmp/$date" >> /tmp/$date-email.txt
	echo "" >> /tmp/$date-email.txt
	if [ "$code" == "GOOD" ]; then	
		. ./server.cfg
		echo "The YUM REPO should be at:" >> /tmp/$date-email.txt
		echo "$resulturl/$OS/$PRO/$date/ipa.repo" >> /tmp/$date-email.txt
		find ./cfgs/ -type f | while read cfg; do
			. $cfg
			echo "for $OS $PRO the YUM REPO will be at:" >> /tmp/$date-email.txt
			echo "$resulturl/$OS/$PRO/$date/ipa.repo" >> /tmp/$date-email.txt
			echo "          Buildlog should be at:" >> /tmp/$date-email.txt
                        echo "          $resulturl/$OS/$PRO/$date/ipa_install_log.txt" >> /tmp/$date-email.txt
		done
	else
		echo "No new yum repo for you, the build seemed to fail" >> /tmp/$date-email.txt
	fi
	echo "" >> /tmp/$date-email.txt
	echo "The last good YUM repo file of freeIPA is avalible at $resulturl/ipa.repo" >> /tmp/$date-email.txt
	/usr/sbin/sendmail $email < /tmp/$date-email.txt
}

press_any_key()
{
    echo ""
    echo "Press any key to continue..."
    read tmp
    echo ""
    echo ""
    echo ""
    #clear
    return 0
}

echo "WARNING: This test will destroy all of the VM's that it uses because it "
echo " recreates them all"
echo " Hit CTRL-C now if this is not okay? - "
echo " "
echo " If you don't want to have to hit a key for this message in the future,"
echo '   set tht $automated env var to 1'
if [ $automated -ne 1 ]; then
	press_any_key
fi

echo '' > $logdir/log.txt

# Fix date
/etc/init.d/ntpd stop
/usr/sbin/ntpdate $ntpserver | tee -a $logdir/log.txt
ret=$?
if [ $ret != 0 ]; then
        # ntp update didn't work the first time, lets try it again.
        /usr/sbin/ntpdate $ntpserver | tee -a $logdir/log.txt
        ret=$?
fi

date=`date +%Y-%m-%d_%H_%M`
date2=`echo $date-build`
date=$date2
emailfiletmp=$resultloc
export date
export emailfiletmp

# Setup IPA server VM
. ./server.cfg
cfg="server.cfg"
echo "" | tee -a $logdir/log.txt
echo "Stoping the VM specified in ./$cfg" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
date | tee -a $logdir/log.txt
./stop-vm.ksh ./$cfg | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
echo "Extracting the VM image from the server specified in ./$cfg" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
date | tee -a $logdir/log.txt
./extract-vm.ksh ./$cfg | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
echo "Starting the image that was just extracted" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
date | tee -a $logdir/log.txt
./start-vm.ksh ./$cfg | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
echo "Pinging the server specified in $cfg until it is up" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
while true; do
	echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
	sleep 60
	date | tee -a $logdir/log.txt
	ping -c 1 $VMIP
	ret=$?
	if [ $ret = 0 ]; then
		echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
		break;
	fi
done 
echo "sleeping 1 min to allow ssh to come up" | tee -a $logdir/log.txt
sleep 60
# Pinging again to wait for the VMWARE clock sync bug 
echo "" | tee -a $logdir/log.txt
echo "Pinging again to ensure that the VM is up" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
while true; do
	echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
	ping -c 1 $VMIP
	ret=$?
	if [ $ret = 0 ]; then
		echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
		echo "continuing with IPA Server Build" | tee -a $logdir/log.txt
		break;
	fi
done 
# Determining if resultloc is a nfs something that needs to be mounted.
echo $resultnfs | grep ":" 
ret=$?
if [ $ret = 0 ]; then
	# It's a NFS something, lets mount it.
	mkdir -p /tmp/$date | tee -a $logdir/log.txt
	mount $resultnfs /tmp/$date | tee -a $logdir/log.txt
	resultloc="/tmp/$date/$resultloc"
	export resultloc
fi

oldresult=$resultloc
resultloc="$resultloc/$OS/$PRO"
oldurl=$resulturl
resulturl="$oldurl/$OS/$PRO"
# Making a new dir for logs
mkdir -p $resultloc/$date | tee -a $logdir/log.txt

# Install IPA onto the server
#  First, fix the install-ipa.bash file
echo "" | tee -a $logdir/log.txt
echo "This script is now fixing the install_ipa.bash template. The output of install_ipa.bash will not appear in this log" | tee -a $logdir/log.txt
echo "Please see ipa_install_log.txt for output of install_ipa.bash" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
vmfqdn=`host $VMNAME | awk {'print $1'}`
sed s=ipamercurial=$ipamercurial=g < ././install_ipa.bash-base | sed s=VMNAME=$vmfqdn=g | sed s=ntpserver=$ntpserver=g > ./install_ipa.bash
chmod 755 ./install_ipa.bash
scp ./install_ipa.bash root@$VMNAME:/tmp/.
ssh root@$VMNAME " rm -f $installog;set -x;/tmp/install_ipa.bash &> $installog" | tee -a $logdir/log.txt
rm -f $installog
scp root@$VMNAME:$installog /tmp/. | tee -a $logdir/log.txt
cp $installog $resultloc/$date/. | tee -a $logdir/log.txt
grep ERROR $installog
ret=$?
if [ $ret == 0 ]; then
	echo "ERROR - A error was detected installing IPA server onto $VMNAME, see $installog for details";
	echo "ERROR - A error was detected installing IPA server onto $VMNAME, see $installog for details" >>  $logdir/log.txt;
	email_result BAD fc7-32;
	exit;
fi

# Download repo
scp root@$VMNAME:/tmp/dist.tgz /tmp/. | tee -a $logdir/log.txt
ret=$?
if [ $ret != 0 ]; then
	echo "ERROR - Unable to download the dist repo from $VMNAME";
	echo "ERROR - Unable to download the dist repo from $VMNAME" >>  $logdir/log.txt;
	email_result BAD fc7-32;
	exit;
fi

# Untar repo
cd $resultloc/$date;pwd;tar xvfz /tmp/dist.tgz | tee -a $logdir/log.txt

# Create REPO file
echo "[ipa]" > $resultloc/$date/ipa.repo
echo "name=IPA" >> $resultloc/$date/ipa.repo
echo "baseurl=$resulturl/$date/dist" >> $resultloc/$date/ipa.repo
echo '#mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch' >> $resulloc/$date/ipa.repo
echo "enabled=1" >> $resultloc/$date/ipa.repo
echo "gpgcheck=0" >> $resultloc/$date/ipa.repo
cat $resultloc/$date/ipa.repo > $resultloc/ipa.repo
cat $resultloc/$date/ipa.repo > $oldresult/ipa.repo

resultloc=$oldresult
resulturl=$oldurl
cd $pwd
# Okay, now doing FC7 64-bit

# Setup IPA server VM
find ./cfgs/ -type f | while read cfg; do 
	. $cfg
	echo "" | tee -a $logdir/log.txt
	echo "Stoping the VM specified in ./$cfg" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
	./stop-vm.ksh ./$cfg | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	echo "Extracting the VM image from the server specified in ./$cfg" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
	./extract-vm.ksh ./$cfg | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	echo "Starting the image that was just extracted" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
	./start-vm.ksh ./$cfg | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	echo "Pinging the server specified in $cfg until it is up" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	while true; do
	echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
	sleep 60
	date | tee -a $logdir/log.txt
	ping -c 1 $VMIP
	ret=$?
	if [ $ret = 0 ]; then
			echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
			break;
		fi
	done 
	echo "sleeping 1 min to allow ssh to come up" | tee -a $logdir/log.txt
	sleep 60
	# Pinging again to wait for the VMWARE clock sync bug 
	echo "" | tee -a $logdir/log.txt
	echo "Pinging again to ensure that the VM is up" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	while true; do
		echo "trying to ping to $VMIP" | tee -a $logdir/log.txt
		date | tee -a $logdir/log.txt
		ping -c 1 $VMIP
		ret=$?
		if [ $ret = 0 ]; then
			echo "$VMNAME seems to be responding to pings now" | tee -a $logdir/log.txt
			echo "continuing with IPA Server Build" | tee -a $logdir/log.txt
			break;
		fi
	done 
	# Install IPA onto the server
	#  First, fix the install-ipa.bash file
	echo "" | tee -a $logdir/log.txt
	echo "This script is now fixing the install_ipa.bash template. The output of install_ipa.bash will not appear in this log" | tee -a $logdir/log.txt
	echo "Please see ipa_install_log.txt for output of install_ipa.bash" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	vmfqdn=`host $VMNAME | awk {'print $1'}`
	sed s=ipamercurial=$ipamercurial=g < ././install_ipa.bash-base | sed s=VMNAME=$vmfqdn=g | sed s=ntpserver=$ntpserver=g > ./install_ipa.bash
	chmod 755 ./install_ipa.bash
	scp ./install_ipa.bash root@$VMNAME:/tmp/.
	ssh root@$VMNAME " rm -f $installog;set -x;/tmp/install_ipa.bash &> $installog" | tee -a $logdir/log.txt
	rm -f $installog
	scp root@$VMNAME:$installog /tmp/. | tee -a $logdir/log.txt
	# Making a new dir for logs
	originalresultloc=$resultloc
	resultloc="$resultloc/$OS/$PRO"
	mkdir -p $resultloc/$date | tee -a $logdir/log.txt
	cp $installog $resultloc/$date/. | tee -a $logdir/log.txt

	grep ERROR $installog
	ret=$?
	if [ $ret == 0 ]; then
		echo "ERROR - A error was detected installing IPA server onto $VMNAME, see $installog for details";
		email_result BAD fc7-64;
		exit;
	fi

	# Download repo
	scp root@$VMNAME:/tmp/dist.tgz /tmp/. | tee -a $logdir/log.txt
	ret=$?
	if [ $ret != 0 ]; then
		echo "ERROR - Unable to download the dist repo from $VMNAME";
		email_result BAD fc7-64;
		exit;
	fi

	# Untar repo
	cd $resultloc/$date
	tar xvfz /tmp/dist.tgz | tee -a $logdir/log.txt

	oldurl=$resulturl
	resulturl="$oldurl/$OS/$PRO"

	# Create REPO file
	echo "[ipa]" > $resultloc/$date/ipa.repo
	echo "name=IPA" >> $resultloc/$date/ipa.repo
	echo "baseurl=$resulturl/$date/dist" >> $resultloc/$date/ipa.repo
	echo "#mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch" >> $resulloc/$date/ipa.repo
	echo "enabled=1" >> $resultloc/$date/ipa.repo
	echo "gpgcheck=0" >> $resultloc/$date/ipa.repo
	cat $resultloc/$date/ipa.repo > $resultloc/ipa.repo
	resultloc=$originalresultloc

	resulturl=$oldurl

	# Stopping the VM
	echo "" | tee -a $logdir/log.txt
	echo "Stoping the VM specified in ./$cfg" | tee -a $logdir/log.txt
	echo "" | tee -a $logdir/log.txt
	date | tee -a $logdir/log.txt
	cd $pwd;./stop-vm.ksh ./$cfg | tee -a $logdir/log.txt

done

# stopping the server
. ./server.cfg
cfg="server.cfg"
echo "" | tee -a $logdir/log.txt
echo "Stoping the VM specified in ./$cfg" | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt
date | tee -a $logdir/log.txt
./stop-vm.ksh ./$cfg | tee -a $logdir/log.txt
echo "" | tee -a $logdir/log.txt

email_result GOOD;
