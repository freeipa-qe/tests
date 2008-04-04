
. ./env.cfg

cfgfile=$1

printusage()
{
	echo "Start VM is used to start a VM on a remote host. That VM needs to be"
	echo "  decompressed with a existinf vmx file"
	echo "Usage:"
	echo "start-vm.ksh <cfgfile>"
	echo "example: start=vm.ksh ./cfgs/fc7.cfg"
}

if [ "$cfgfile" = "" ] || [ "$cfgfile" = "-h" ] || [ "$cfgfile" = "--help" ]; then
	printusage;
	exit;	
fi
if [ ! -f $cfgfile ]; then
	echo ""
	echo "ERROR!  ------ cfg file not found";
	echo ""
	printusage;
	exit;
fi

echo "cfg file seems to exist, running"
. $cfgfile

echo "Using:
vmname=$VMNAME 
vmxfile=$VMXFILE
vmhost=$VMHOST
tarfile=$TARFILE
tarroot=$TARROOT
taronnfs=$TARONNFS
tarballmount=$TARBALLMOUNT
vmip=$VMIP"

# Stopping VM
echo "STOPPING $VMXFILE on $VMHOST"
./stop-vm.ksh $1

# Mounting nfs share
if [ $TARONNFS -ne 0 ]; then
	echo "Mounting $TARBALLMOUNT on host $VMHOST"
	mntlocation=$(echo $TARBALLMOUNT | awk '{print $2}')
	ssh root@$VMHOST "mkdir -p $mntlocation;umount -l $mntlocation >> /dev/null;mount $TARBALLMOUNT"
fi

# Extracting tarball
echo "Extracting $TARFILE to $TARROOT on host $VMHOST"
if [ $VIRSH = 1 ]; then
        echo "stoping virsh of $VMXFILE"
	ssh root@$VMHOST "cd $TARROOT;cp -af $TARFILE ."
else
	ssh root@$VMHOST "cd $TARROOT;tar xvfz $TARFILE"
fi
