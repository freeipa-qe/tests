
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
if [ $VIRSH = 1 ]; then
        echo "stoping virsh of $VMXFILE"
        ssh root@$VMHOST "/usr/bin/virsh -c qemu:///system destroy $VMXFILE"
else
	ssh root@$VMHOST "if [ \$(/usr/bin/vmrun list | grep $VMXFILE) != \"\" ]; then /usr/bin/vmrun stop $VMXFILE; else echo VM not running; fi"
fi
